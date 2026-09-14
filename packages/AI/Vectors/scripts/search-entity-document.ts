// search-entity-document.ts -- ranked SearchEntity over one entity, for checking a vector index.
// Usage (repo root): npx tsx packages/AI/Vectors/scripts/search-entity-document.ts "IBTR Appeals" "taxpayer's own purchase price as evidence of value" [semantic|hybrid|lexical]
// Added 2026-09-13 for the Indiana IBTR corpus; untracked on purpose (MJ repo: no commits from this session).
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import { RunView } from '@memberjunction/core';
import sql from 'mssql';
import dotenv from 'dotenv';
import path from 'path';
import '@memberjunction/server-bootstrap-lite';
dotenv.config({ path: path.resolve(process.cwd(), '.env'), quiet: true });

async function main() {
    const [entityName, searchText, mode] = [process.argv[2], process.argv[3], (process.argv[4] ?? 'semantic') as 'semantic' | 'hybrid' | 'lexical'];
    if (!entityName || !searchText) throw new Error('usage: search-entity-document.ts "<Entity>" "<query>" [mode]');
    const { cosmiconfig } = await import('cosmiconfig');
    const configResult = await cosmiconfig('mj').search();
    if (!configResult) throw new Error('No mj.config.cjs found; run from the repo root.');
    const config = configResult.config; const db = config.databaseSettings ?? {};
    const pool = await new sql.ConnectionPool({ server: db.host || process.env.DB_HOST || 'localhost', port: Number(db.port ?? process.env.DB_PORT ?? 1433),
        user: db.user || process.env.DB_USERNAME, password: db.password || process.env.DB_PASSWORD, database: db.database || process.env.DB_DATABASE,
        options: { encrypt: false, trustServerCertificate: true } }).connect();
    const provider = await setupSQLServerClient(new SQLServerProviderConfigData(pool, config.mjCoreSchema || db.mjCoreSchema || '__mj'));
    await UserCache.Instance.Refresh(pool);
    const user = UserCache.Users.find(u => u?.Type?.trim().toLowerCase() === 'owner') ?? UserCache.Users[0];
    const t0 = Date.now();
    const results = await provider.SearchEntity({ entityName, searchText, options: { mode, topK: 6, contextUser: user } });
    console.log(`\n"${searchText}" (${mode}) -> ${results.length} results in ${Date.now() - t0} ms`);
    if (results.length) {
        const ids = results.map(r => `'${r.recordId}'`).join(',');
        const rv = new RunView();
        const rows = await rv.RunView<Record<string, unknown>>({ EntityName: entityName, ExtraFilter: `ID IN (${ids})`, ResultType: 'simple' }, user);
        const byId = new Map((rows.Results ?? []).map(r => [String(r['ID']).toUpperCase(), r]));
        for (const r of results) {
            const row = byId.get(String(r.recordId).toUpperCase()) ?? {};
            const label = row['PetitionNumber'] ? `${row['PetitionNumber']} | ${row['PetitionerName'] ?? ''} | ${row['CountyName'] ?? ''} ${String(row['DecisionDate'] ?? '').slice(0, 10)} | ${String(row['IssuesPhrase'] || row['Summary'] || '').slice(0, 90)}`
                : `${row['SectionNumber'] ?? ''} ${String(row['Title'] ?? row['Name'] ?? '').slice(0, 90)}`;
            console.log(`  ${r.score.toFixed(3)} ${r.matchType.padEnd(8)} ${label}`);
        }
    }
    await pool.close();
}
main().catch(e => { console.error(e instanceof Error ? (e.stack ?? e.message) : e); process.exit(1); });
