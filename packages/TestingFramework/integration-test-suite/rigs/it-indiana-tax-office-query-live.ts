/**
 * it-indiana-tax-office-query-live.ts — live capability check: can the Indiana Property Tax
 * Expert answer "top 10 highest assessed office properties per square foot, over 100,000 sqft"
 * using its real action roster against indiana_tax.CountyAssessorRecord? Ground truth is computed
 * directly first so the agent's answer can be checked against it, not just eyeballed for plausibility.
 *
 * REAL Anthropic API call, not mocked. Run from repo root:
 *   npx tsx packages/TestingFramework/integration-test-suite/rigs/it-indiana-tax-office-query-live.ts
 */
import 'dotenv/config';
import sql from 'mssql';
import { RunView, UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import '@memberjunction/server-bootstrap-lite';
import { AIEngine } from '@memberjunction/aiengine';
import { AgentRunner } from '@memberjunction/ai-agents';

const AGENT_NAME = 'Indiana Property Tax Expert';

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
    const user = UserCache.Users.find((u) => u?.Type?.trim().toLowerCase() === 'owner') ?? UserCache.Users[0];
    if (!user) throw new Error('No context user found.');
    await AIEngine.Instance.Config(false, user);
    return { user };
}

async function main(): Promise<void> {
    const { user } = await bootstrap();

    console.log('=== Ground truth (direct query) ===');
    const truth = await new RunView().RunView<{ CountyParcelID: string; PropertySubClassDescription: string; EstimatedSqFt: number; AssessedTotalAV: number }>(
        {
            EntityName: 'County Assessor Records',
            ExtraFilter: `PropertySubClassDescription LIKE '%OFF%' AND EstimatedSqFt >= 100000`,
            Fields: ['CountyParcelID', 'PropertySubClassDescription', 'EstimatedSqFt', 'AssessedTotalAV'],
            ResultType: 'simple',
            MaxRows: 2000,
        },
        user
    );
    const ranked = (truth.Results ?? [])
        .map((r) => ({ ...r, avPerSqFt: r.AssessedTotalAV / r.EstimatedSqFt }))
        .sort((a, b) => b.avPerSqFt - a.avPerSqFt)
        .slice(0, 10);
    for (const r of ranked) {
        console.log(`  ${r.CountyParcelID}  $${r.avPerSqFt.toFixed(2)}/sqft  (${r.EstimatedSqFt} sqft, $${r.AssessedTotalAV.toLocaleString()})`);
    }

    console.log('\n=== Agent answer (live) ===');
    const agent = AIEngine.Instance.Agents.find((a) => a.Name?.toLowerCase() === AGENT_NAME.toLowerCase());
    if (!agent) { console.error(`Agent '${AGENT_NAME}' not found.`); process.exit(1); }

    const prompt =
        `Using the county assessor data available to you, list the top 10 office properties by ` +
        `assessed value per square foot, restricted to properties with at least 100,000 square feet ` +
        `of building area. For each, give the parcel identifier, square footage, total assessed value, ` +
        `and the computed assessed-value-per-square-foot. Tell me plainly if this data isn't available ` +
        `rather than guessing.`;

    const t0 = Date.now();
    const result = await new AgentRunner().RunAgent({
        agent: agent!,
        conversationMessages: [{ role: 'user', content: prompt }],
        contextUser: user,
    });
    console.log(`(${Date.now() - t0}ms, status=${result.agentRun?.Status}, success=${result.success})\n`);
    console.log(result.agentRun?.Message ?? '(no message)');
    process.exit(0);
}

main().catch((e) => { console.error('ERROR:', e instanceof Error ? e.stack : e); process.exit(2); });
