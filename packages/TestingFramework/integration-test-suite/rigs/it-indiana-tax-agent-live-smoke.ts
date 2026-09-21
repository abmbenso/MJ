/**
 * it-indiana-tax-agent-live-smoke.ts — live proof that the Anthropic max_tokens fix
 * (packages/AI/Providers/Anthropic/src/models/anthropic.ts) actually unblocks the real
 * "Indiana Property Tax Expert" agent end-to-end, not just the unit tests. Before the fix,
 * every turn against this agent failed after 305 failover attempts across every configured
 * Claude model/vendor combo, each rejected by Anthropic with "max_tokens: Field required",
 * because createStreamingRequest sent `max_tokens: params.maxOutputTokens` with no fallback
 * when maxOutputTokens was unset -- which is exactly the case for a Loop-type agent's system
 * prompt run through AgentRunner via MJExplorer's Conversations UI.
 *
 * This is a REAL Anthropic API call (costs a few cents) -- not mocked. Run from repo root:
 *   npx tsx packages/TestingFramework/integration-test-suite/rigs/it-indiana-tax-agent-live-smoke.ts
 */
import 'dotenv/config';
import sql from 'mssql';
import { UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import '@memberjunction/server-bootstrap-lite';
import { AIEngine } from '@memberjunction/aiengine';
import { AgentRunner } from '@memberjunction/ai-agents';

const AGENT_NAME = 'Indiana Property Tax Expert';

let failures = 0;
function check(label: string, ok: boolean, detail?: string): void {
    if (ok) {
        console.log(`  ✓ ${label}`);
    } else {
        failures++;
        console.error(`  ✗ ${label}${detail ? ` — ${detail}` : ''}`);
    }
}

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
    await AIEngine.Instance.Config(false, user);
    return { user };
}

async function main(): Promise<void> {
    const { user } = await bootstrap();

    const agent = AIEngine.Instance.Agents.find((a) => a.Name?.toLowerCase() === AGENT_NAME.toLowerCase());
    check(`'${AGENT_NAME}' agent found in metadata`, !!agent);
    if (!agent) { process.exit(1); }

    console.log(`\nRunning a real turn against '${AGENT_NAME}'...\n`);
    const t0 = Date.now();
    const result = await new AgentRunner().RunAgent({
        agent: agent!,
        conversationMessages: [{ role: 'user', content: 'In one sentence, what is PTABOA?' }],
        contextUser: user,
    });
    console.log(`  Ran in ${Date.now() - t0}ms — agentRun=${result.agentRun?.ID} status=${result.agentRun?.Status} success=${result.success}`);

    check('Agent run succeeded (no consecutive-failed-steps termination)', result.success === true, result.agentRun?.ErrorMessage ?? undefined);
    check('Agent run status is not Error', result.agentRun?.Status !== 'Error', result.agentRun?.ErrorMessage ?? undefined);
    check('Agent produced a non-empty final message', !!result.agentRun?.Message && result.agentRun.Message.trim().length > 0);
    if (result.agentRun?.Message) {
        console.log(`\n  Agent's response:\n  "${result.agentRun.Message.trim().slice(0, 300)}"\n`);
    }

    console.log(failures === 0 ? 'ALL CHECKS PASSED — the live agent turn completed without the max_tokens failure.' : `${failures} CHECK(S) FAILED.`);
    process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => { console.error('BOOTSTRAP/RUN ERROR:', e instanceof Error ? e.stack : e); process.exit(2); });
