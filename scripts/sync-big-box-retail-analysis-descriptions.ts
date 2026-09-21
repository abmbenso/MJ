/**
 * Copy vwStoreAnalysis's SQL column descriptions onto the "Store Analysis" entity's
 * EntityField.Description values.
 *
 * Why this script has to exist: CodeGen will not do it. `__mj.spUpdateExistingEntityFieldsFromSchema`
 * — the proc that refreshes an existing EntityField from the schema, descriptions included —
 * filters on `e.VirtualEntity = 0`. "Store Analysis" is a virtual (view-backed) entity, so
 * CodeGen sets a field's Description once, when it first inserts the field, and never
 * updates it afterwards. V202609072130 attached MS_Description to all 61 view columns;
 * CodeGen picked up the 15 columns that migration ADDED and left the 46 pre-existing ones
 * blank, which is the state the final review flagged. This closes that gap.
 *
 * Reads the descriptions straight from sys.extended_properties on the view, so the
 * migration stays the single source of truth and this script never carries its own copy of
 * the text. Writes through MJEntityFieldEntity so BaseEntity.Validate() and the
 * __mj.RecordChange audit trail both run, per this project's standard.
 *
 * Idempotent: compares before writing, so a second run reports 0 updated.
 *
 * Usage (repo root): npx tsx scripts/sync-big-box-retail-analysis-descriptions.ts
 */
import { Metadata, RunView, UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import { MJEntityFieldEntity } from '@memberjunction/core-entities';
import sql from 'mssql';
import dotenv from 'dotenv';
import path from 'path';

import '@memberjunction/server-bootstrap-lite';

dotenv.config({ path: path.resolve(process.cwd(), '.env'), quiet: true });

const ENTITY_NAME = 'Store Analysis';
const VIEW_NAME = 'big_box_retail.vwStoreAnalysis';

interface ColumnDescription {
    ColumnName: string;
    Description: string;
}

async function bootstrap(): Promise<{ user: UserInfo; pool: sql.ConnectionPool }> {
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
    return { user: contextUser, pool };
}

async function readViewColumnDescriptions(pool: sql.ConnectionPool): Promise<Map<string, string>> {
    const result = await pool.request().query<ColumnDescription>(`
        SELECT c.name AS ColumnName, CONVERT(NVARCHAR(MAX), ep.value) AS Description
        FROM sys.columns c
        INNER JOIN sys.extended_properties ep
            ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
           AND ep.name = 'MS_Description' AND ep.class_desc = 'OBJECT_OR_COLUMN'
        WHERE c.object_id = OBJECT_ID('${VIEW_NAME}')`);
    return new Map(result.recordset.map((r) => [r.ColumnName, r.Description]));
}

async function main(): Promise<void> {
    const { user, pool } = await bootstrap();
    const md = new Metadata();
    const entity = md.EntityByName(ENTITY_NAME);
    if (!entity) throw new Error(`Entity "${ENTITY_NAME}" not found — did CodeGen run?`);

    const descriptions = await readViewColumnDescriptions(pool);
    if (descriptions.size === 0) {
        throw new Error(`No column descriptions found on ${VIEW_NAME} — is the migration applied?`);
    }

    const fields = await new RunView().RunView<MJEntityFieldEntity>({
        EntityName: 'MJ: Entity Fields',
        ExtraFilter: `EntityID='${entity.ID}'`,
        ResultType: 'entity_object',
        MaxRows: 1000
    }, user);
    if (!fields.Success) throw new Error(`Failed to load fields: ${fields.ErrorMessage}`);

    let updated = 0, unchanged = 0;
    const missing: string[] = [];
    for (const field of fields.Results) {
        const want = descriptions.get(field.Name);
        if (want === undefined) { missing.push(field.Name); continue; }
        if ((field.Description ?? '') === want) { unchanged++; continue; }
        field.Description = want;
        if (!(await field.Save())) {
            throw new Error(`Failed to save EntityField ${field.Name}: ${field.LatestResult?.CompleteMessage}`);
        }
        updated++;
        console.log(`✓ ${field.Name}: description set`);
    }

    console.log(`\n${fields.Results.length} fields · updated ${updated} · unchanged ${unchanged}`);
    if (missing.length > 0) {
        // Not fatal on its own, but it means a view column lost its MS_Description, which
        // is the exact state this script exists to prevent — so it fails rather than
        // reporting success over a documentation hole.
        throw new Error(`No MS_Description on ${VIEW_NAME} for: ${missing.join(', ')}`);
    }
    await pool.close();
}

main().catch((err) => { console.error('❌ FAILED:', err instanceof Error ? err.stack : err); process.exit(1); });
