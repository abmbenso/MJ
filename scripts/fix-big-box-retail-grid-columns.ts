/**
 * Turn on DefaultInView for TotalAssessedValue and Tenure on the "Stores" entity
 * (big_box_retail.Store). Both fields exist, are correctly typed, and are fully
 * populated with data, but EntityField.DefaultInView was left false for both, so
 * they don't show up in the stock grid by default.
 *
 * Idempotent: check-then-set for each field, so re-running is a no-op once both
 * are already true.
 *
 * Usage (repo root): npx tsx scripts/fix-big-box-retail-grid-columns.ts
 */
import { Metadata, RunView, UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import { MJEntityFieldEntity } from '@memberjunction/core-entities';
import sql from 'mssql';
import dotenv from 'dotenv';
import path from 'path';

import '@memberjunction/server-bootstrap-lite';

dotenv.config({ path: path.resolve(process.cwd(), '.env'), quiet: true });

const ENTITY_NAME = 'Stores';
const FIELD_NAMES = ['TotalAssessedValue', 'Tenure'] as const;

async function bootstrap(): Promise<UserInfo> {
    const { cosmiconfig } = await import('cosmiconfig');
    const configResult = await cosmiconfig('mj').search();
    if (!configResult) throw new Error('No mj.config.cjs found — run from the repo root.');
    const config = configResult.config;

    const pool = new sql.ConnectionPool({
        server: config.dbHost || process.env.DB_HOST || 'localhost',
        port: parseInt(config.dbPort || process.env.DB_PORT || '1433', 10),
        database: config.dbDatabase || process.env.DB_DATABASE,
        user: config.dbUsername || process.env.DB_USERNAME,
        password: config.dbPassword || process.env.DB_PASSWORD,
        options: { encrypt: true, trustServerCertificate: true, enableArithAbort: true },
        pool: { max: 5, min: 1, idleTimeoutMillis: 30000 }
    });
    await pool.connect();
    await setupSQLServerClient(new SQLServerProviderConfigData(pool, config.coreSchema || '__mj', 180000));
    const contextUser = UserCache.Instance.GetSystemUser();
    if (!contextUser) throw new Error('No system user found in UserCache');
    return contextUser;
}

async function findEntityField(entityID: string, fieldName: string, user: UserInfo): Promise<MJEntityFieldEntity | null> {
    const result = await new RunView().RunView<MJEntityFieldEntity>({
        EntityName: 'MJ: Entity Fields',
        ExtraFilter: `EntityID='${entityID}' AND Name='${fieldName}'`,
        ResultType: 'entity_object'
    }, user);
    if (!result.Success) throw new Error(`Failed to look up field ${fieldName}: ${result.ErrorMessage}`);
    return result.Results.length > 0 ? result.Results[0] : null;
}

async function ensureDefaultInView(entityID: string, fieldName: string, user: UserInfo): Promise<void> {
    const field = await findEntityField(entityID, fieldName, user);
    if (!field) throw new Error(`EntityField "${fieldName}" not found on entity "${ENTITY_NAME}" — did CodeGen run?`);

    if (field.DefaultInView) {
        console.log(`✓ ${fieldName}: DefaultInView already true — no change`);
        return;
    }

    field.DefaultInView = true;
    if (!(await field.Save())) {
        throw new Error(`Failed to save EntityField ${fieldName}: ${field.LatestResult?.CompleteMessage}`);
    }
    console.log(`✓ ${fieldName}: DefaultInView set false → true`);
}

async function main(): Promise<void> {
    const user = await bootstrap();
    const md = new Metadata();
    const entity = md.EntityByName(ENTITY_NAME);
    if (!entity) throw new Error(`Entity "${ENTITY_NAME}" not found — did CodeGen run?`);

    for (const fieldName of FIELD_NAMES) {
        await ensureDefaultInView(entity.ID, fieldName, user);
    }
}

main().catch((err) => { console.error('❌ FAILED:', err instanceof Error ? err.stack : err); process.exit(1); });
