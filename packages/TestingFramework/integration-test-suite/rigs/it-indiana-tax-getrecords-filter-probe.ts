/**
 * it-indiana-tax-getrecords-filter-probe.ts — direct, live proof that the "Get Records" CoreActions
 * action actually filters against a real database, not just unit-tested in isolation. Two bugs used
 * to make this false and are both already fixed on `next`:
 *   1. get-records.action was never exported from CoreActions/src/index.ts (silent no-op registration)
 *      — fixed in edd6edefcb ("fix(core-actions): export Get Records, which has never been resolvable")
 *   2. get-records.action set RunViewParams.Filter (no such property) instead of .ExtraFilter, so
 *      every call silently ran unfiltered regardless of what filter was requested
 *      — fixed in 137a31a390 ("fix(actions): Get Records silently dropped its filter, returning the
 *      whole entity"), which retyped the params as RunViewParams so the compiler now catches this
 *      class of typo
 * Neither fix commit added a regression test against a live database, so this rig adds one: it
 * proves the ExtraFilter fix holds against real data rather than resting on the fix commits alone.
 *
 * Follows the action-testing pattern from packages/Actions/CLAUDE.md ("Integration Tests — Test
 * Action Execution": instantiate the action directly, call InternalRunAction, assert on the result)
 * rather than routing through an LLM agent — this is a more deterministic regression check on the
 * actual code path than an LLM-driven end-to-end run would be, since it isolates the fix from any
 * variability in whether/how a model chooses to phrase the tool call.
 *
 * Bootstraps its own minimal provider stack (inlined rather than importing rigs/lib/ai-bootstrap.ts,
 * whose harness.ts re-export currently fails: @memberjunction/testing-integration does not export
 * createRunQueryFixtures — a pre-existing, unrelated break in the shared test harness).
 *
 * READ-ONLY: no records are created, mutated, or deleted. Run from repo root:
 *   npx tsx packages/TestingFramework/integration-test-suite/rigs/it-indiana-tax-getrecords-filter-probe.ts
 */
import 'dotenv/config';
import path from 'path';
import sql from 'mssql';
import { RunView, UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import '@memberjunction/server-bootstrap-lite';
import { GetRecordsAction } from '@memberjunction/core-actions';
import { RunActionParams } from '@memberjunction/actions-base';

// dotenv/config above loads cwd-relative .env; running from repo root picks up MJ/.env directly.
void path;

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
    return { user };
}

function makeParams(user: UserInfo, entityName: string, filter?: string): RunActionParams {
    const params = new RunActionParams();
    params.ContextUser = user;
    params.Params = [
        { Name: 'EntityName', Type: 'Input', Value: entityName },
        ...(filter ? [{ Name: 'Filter', Type: 'Input' as const, Value: filter }] : []),
    ];
    return params;
}

async function main(): Promise<void> {
    const { user } = await bootstrap();

    // Ground truth via direct RunView, independent of the action under test.
    const openTasks = await new RunView().RunView<{ ID: string; Title: string }>(
        { EntityName: 'Research Tasks', ExtraFilter: `Status='Open'`, Fields: ['ID', 'Title'], ResultType: 'simple' },
        user
    );
    check('Ground-truth RunView succeeded', openTasks.Success, openTasks.ErrorMessage);
    const allTasks = await new RunView().RunView<{ ID: string }>(
        { EntityName: 'Research Tasks', Fields: ['ID'], ResultType: 'simple' },
        user
    );
    const openIds = new Set((openTasks.Results ?? []).map((r) => r.ID));
    const openCount = openIds.size;
    const totalCount = allTasks.Results?.length ?? 0;
    console.log(`  Ground truth: ${openCount} of ${totalCount} Research Tasks have Status='Open'.`);
    check('There are both Open and non-Open tasks (test is meaningful)', openCount > 0 && openCount < totalCount);

    // 1) Unfiltered call — should return all rows (sanity baseline).
    const unfilteredResult = await new GetRecordsAction().InternalRunAction(
        makeParams(user, 'Research Tasks')
    );
    check('Unfiltered Get Records call succeeded', unfilteredResult.Success === true, unfilteredResult.Message);
    const unfilteredRecords = (unfilteredResult.Params?.find((p) => p.Name === 'Records')?.Value ?? []) as Array<{ ID: string; Status: string }>;
    check(`Unfiltered call returned all ${totalCount} rows (got ${unfilteredRecords.length})`, unfilteredRecords.length === totalCount);

    // 2) Filtered call — the actual regression check for the ExtraFilter fix.
    const filteredResult = await new GetRecordsAction().InternalRunAction(
        makeParams(user, 'Research Tasks', `Status='Open'`)
    );
    check('Filtered Get Records call succeeded', filteredResult.Success === true, filteredResult.Message);
    const filteredRecords = (filteredResult.Params?.find((p) => p.Name === 'Records')?.Value ?? []) as Array<{ ID: string; Status: string }>;
    console.log(`  Filtered call returned ${filteredRecords.length} records (expected ${openCount}).`);

    check(`Filtered call returned exactly the ${openCount} Open rows, not all ${totalCount}`, filteredRecords.length === openCount);
    check('Every returned record has Status=Open', filteredRecords.every((r) => r.Status === 'Open'));
    check('Every returned record ID is in the ground-truth Open set', filteredRecords.every((r) => openIds.has(r.ID)));
    // The decisive proof: if ExtraFilter were still broken (silently ignored, as before the fix),
    // this call would return the same totalCount as the unfiltered call above.
    check('Filtered result differs from unfiltered result (filter was NOT silently dropped)', filteredRecords.length !== unfilteredRecords.length || totalCount === openCount);

    console.log(failures === 0 ? '\nALL CHECKS PASSED — ExtraFilter fix confirmed against a live database.' : `\n${failures} CHECK(S) FAILED.`);
    process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => { console.error('BOOTSTRAP/RUN ERROR:', e instanceof Error ? e.stack : e); process.exit(2); });
