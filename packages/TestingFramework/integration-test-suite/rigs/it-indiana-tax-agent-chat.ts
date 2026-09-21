/**
 * it-indiana-tax-agent-chat.ts — ad-hoc interactive driver for a real conversation with the
 * "Indiana Property Tax Expert" agent, run turn-by-turn via AgentRunner (same production code
 * path MJExplorer/MJAPI use, not a mock). Each invocation is ONE turn: it loads the running
 * transcript from a JSON file on disk, appends the new user message, runs the agent, prints the
 * reply, and saves the updated transcript back — so repeated invocations form a real multi-turn
 * conversation without needing a UI.
 *
 * Bootstraps its own minimal provider stack (inlined rather than importing rigs/lib/ai-bootstrap.ts,
 * whose harness.ts re-export currently fails — see it-indiana-tax-getrecords-filter-probe.ts for
 * the same note).
 *
 * USAGE (from repo root):
 *   npx tsx packages/TestingFramework/integration-test-suite/rigs/it-indiana-tax-agent-chat.ts "<message>" [transcriptPath]
 *
 * transcriptPath defaults to /tmp/indiana-tax-agent-chat.json. Pass a fresh path (or delete the
 * file) to start a new conversation.
 */
import 'dotenv/config';
import fs from 'fs';
import sql from 'mssql';
import { UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import '@memberjunction/server-bootstrap-lite';
import { AIEngine } from '@memberjunction/aiengine';
import { AgentRunner } from '@memberjunction/ai-agents';
import type { ChatMessage } from '@memberjunction/ai';

const AGENT_NAME = 'Indiana Property Tax Expert';
const DEFAULT_TRANSCRIPT_PATH = '/tmp/indiana-tax-agent-chat.json';

async function bootstrap(): Promise<{ user: UserInfo }> {
    const pool = await new sql.ConnectionPool({
        server: process.env.DB_HOST!,
        port: Number(process.env.DB_PORT ?? 1433),
        user: process.env.DB_USERNAME!,
        password: process.env.DB_PASSWORD!,
        database: process.env.DB_DATABASE!,
        options: { encrypt: false, trustServerCertificate: true },
    }).connect();

    await setupSQLServerClient(new SQLServerProviderConfigData(pool, '__mj'));
    await UserCache.Instance.Refresh(pool);

    const email = process.env.MJ_TEST_USER_EMAIL?.toLowerCase();
    const user =
        (email ? UserCache.Users.find((u) => u.Email?.toLowerCase() === email) : undefined)
        ?? UserCache.Users.find((u) => u?.Type?.trim().toLowerCase() === 'owner')
        ?? UserCache.Users[0];
    if (!user) throw new Error('No context user found in UserCache.');
    return { user };
}

function loadTranscript(transcriptPath: string): ChatMessage[] {
    if (!fs.existsSync(transcriptPath)) return [];
    try {
        return JSON.parse(fs.readFileSync(transcriptPath, 'utf8')) as ChatMessage[];
    } catch {
        return [];
    }
}

function saveTranscript(transcriptPath: string, messages: ChatMessage[]): void {
    fs.writeFileSync(transcriptPath, JSON.stringify(messages, null, 2), 'utf8');
}

async function main(): Promise<void> {
    const userMessage = process.argv[2];
    const transcriptPath = process.argv[3] || DEFAULT_TRANSCRIPT_PATH;
    if (!userMessage) {
        console.error('Usage: npx tsx it-indiana-tax-agent-chat.ts "<message>" [transcriptPath]');
        process.exit(2);
    }

    const { user } = await bootstrap();
    await AIEngine.Instance.Config(false, user);
    const agent = AIEngine.Instance.Agents.find((a) => a.Name?.toLowerCase() === AGENT_NAME.toLowerCase());
    if (!agent) {
        console.error(`Agent '${AGENT_NAME}' not found in metadata.`);
        process.exit(1);
    }

    const history = loadTranscript(transcriptPath);
    const messages: ChatMessage[] = [...history, { role: 'user', content: userMessage }];

    console.log(`\n> ${userMessage}\n`);
    const t0 = Date.now();
    const result = await new AgentRunner().RunAgent({
        agent,
        conversationMessages: messages,
        contextUser: user,
    });
    const elapsed = Date.now() - t0;

    if (!result.success) {
        console.error(`AGENT RUN FAILED (${elapsed}ms): ${result.agentRun?.ErrorMessage ?? '(no error message)'}`);
        process.exit(1);
    }

    const reply = result.agentRun?.Message ?? '(no message returned)';
    console.log(reply);
    console.log(`\n[${elapsed}ms · agentRun=${result.agentRun?.ID}]`);

    messages.push({ role: 'assistant', content: reply });
    saveTranscript(transcriptPath, messages);
    process.exit(0);
}

main().catch((e) => { console.error('BOOTSTRAP/RUN ERROR:', e instanceof Error ? e.stack : e); process.exit(2); });
