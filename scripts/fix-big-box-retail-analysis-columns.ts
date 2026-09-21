/**
 * Set DefaultInView on the "Store Analysis" entity (big_box_retail.vwStoreAnalysis, 72
 * fields) so the stock grid opens with everything the user actually has to scan: the 44
 * columns below are turned ON, every other field is turned OFF.
 *
 * WHY 33 AND NOT 18. The original draft of this script kept 18 columns and left the rest
 * "one click away in the column chooser". That premise is false on this surface, and the
 * final review's I5 established why: the grid's "Manage Columns" button emits
 * ManageColumnsRequested -> configureRequested -> EntityViewerComponent.ConfigureRequested,
 * and the ONLY component in the repo that subscribes to that output is mj-view-workspace,
 * which is used solely by the Data Explorer dashboard. The component behind an Explorer nav
 * item pointing at a saved view is ViewResource, and its template mounts <mj-entity-viewer>
 * without binding (ConfigureRequested) — see
 * packages/Angular/Explorer/explorer-core/src/lib/resource-wrappers/view-resource.component.html.
 * The button emits into nothing. This is pre-existing MJ behaviour (it fails identically on
 * the pre-existing Stores nav item) and is deliberately NOT fixed here.
 *
 * The consequence is that on a nav item the DefaultInView set is not a starting point, it is
 * the complete set. The dashboard's primary requirement is multiple years of assessed value
 * and tax liability for extensive comparison, and an 18-column default carrying only 2025 and
 * 2026 does not deliver that — the earlier years exist in the view and are simply unreachable.
 * So every year of AV, Tax, AV/SF and Tax/SF is visible by default. A wide grid the user can
 * scroll and export beats correct data they cannot reach.
 *
 * Column ORDER is not set here: it follows EntityField.Sequence, which follows the view's own
 * column order, which already runs AV2021..AV2026, Tax2022..Tax2026, AVPerSF2021..AVPerSF2026,
 * TaxPerSF2022..TaxPerSF2026. Each series therefore reads chronologically left to right.
 *
 * DELIBERATELY STILL HIDDEN, and reachable through the Data Explorer dashboard (where the
 * config panel does open): every AVSource / TaxSource provenance column, TaxpayerOfRecord,
 * RosterSquareFeet, AttributedSquareFeet, ParcelsTotal, every AVComplete / TaxComplete flag,
 * UniformityEligible and ID. Those answer a specific question about a specific row; they are
 * not scanning material, and putting 28 more columns on the grid would bury the ones that are.
 *
 * Idempotent: check-then-set for each field, so re-running is a no-op once the desired
 * state is already in place. Unlike fix-big-box-retail-grid-columns.ts (which only ever
 * turns fields ON), this script also actively turns OFF any field not on the allowlist,
 * since CodeGen may have defaulted some of the 47 fields to DefaultInView = true.
 *
 * Usage (repo root): npx tsx scripts/fix-big-box-retail-analysis-columns.ts
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

// Exactly these 33 fields are DefaultInView = true. Names verified against
// packages/GeneratedEntities/src/generated/entity_subclasses.ts
// (bigboxretailvwStoreAnalysisSchema).
//
// OwnershipStructure IS on the list (it was not in the 18-column draft): owner-occupied vs
// leased/investor is a tenure question the user asked about directly, and with the column
// chooser inert there is no other way to reach it. It is an ownership-structure heuristic and
// explicitly NOT a dark-store/occupancy indicator — that is stated in its column description,
// which is why the column was renamed from OccupancySignal (Ruling 13).
const VISIBLE_FIELDS = [
    // Identity and physical
    'Occupant',
    'AssessedOwner',
    'County',
    'City',
    'Address',
    'Acres',
    'YearBuilt',
    'SquareFeet',
    'AttributionTier',
    'EconomicUnitReview',
    'OwnershipStructure',
    // Assessed value — ASSESSMENT years, oldest first
    'AV2021',
    'AV2022',
    'AV2023',
    'AV2024',
    'AV2025',
    'AV2026',
    // Tax liability — PAY years (the bill for the prior assessment year), oldest first
    'Tax2022',
    'Tax2023',
    'Tax2024',
    'Tax2025',
    'Tax2026',
    // Assessed value per square foot — ASSESSMENT years
    'AVPerSF2021',
    'AVPerSF2022',
    'AVPerSF2023',
    'AVPerSF2024',
    'AVPerSF2025',
    'AVPerSF2026',
    // Tax per square foot — PAY years
    'TaxPerSF2022',
    'TaxPerSF2023',
    'TaxPerSF2024',
    'TaxPerSF2025',
    'TaxPerSF2026',
    // Appeal evidence (V202609081400). On this surface DefaultInView is the complete
    // visible set -- the column-chooser button emits into nothing on a nav item, per the
    // note above -- so evidence left off this list would be unreachable rather than one
    // click away. All ten are therefore on.
    'BurdenShiftYears',
    'LatestBurdenShiftYear',
    'BurdenShiftAVAtStake',
    'BurdenShiftPosture',
    'SettlementCount',
    'HighestSettlementAV',
    'LowestAgreedPSF',
    'UsableCompCount',
    'UnverifiedCompCount',
    'LowestCompPSF',
    'LatestCompDate'
] as const;

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

async function getAllEntityFields(entityID: string, user: UserInfo): Promise<MJEntityFieldEntity[]> {
    const result = await new RunView().RunView<MJEntityFieldEntity>({
        EntityName: 'MJ: Entity Fields',
        ExtraFilter: `EntityID='${entityID}'`,
        ResultType: 'entity_object'
    }, user);
    if (!result.Success) throw new Error(`Failed to load fields for entity: ${result.ErrorMessage}`);
    return result.Results;
}

async function ensureDefaultInView(field: MJEntityFieldEntity, shouldBeVisible: boolean): Promise<void> {
    if (field.DefaultInView === shouldBeVisible) {
        console.log(`✓ ${field.Name}: DefaultInView already ${shouldBeVisible} — no change`);
        return;
    }

    field.DefaultInView = shouldBeVisible;
    if (!(await field.Save())) {
        throw new Error(`Failed to save EntityField ${field.Name}: ${field.LatestResult?.CompleteMessage}`);
    }
    console.log(`✓ ${field.Name}: DefaultInView set ${!shouldBeVisible} → ${shouldBeVisible}`);
}

async function main(): Promise<void> {
    const user = await bootstrap();
    const md = new Metadata();
    const entity = md.EntityByName(ENTITY_NAME);
    if (!entity) throw new Error(`Entity "${ENTITY_NAME}" not found — did CodeGen run?`);

    const allFields = await getAllEntityFields(entity.ID, user);
    if (allFields.length === 0) throw new Error(`No EntityFields found for "${ENTITY_NAME}" — did CodeGen run?`);

    const visibleSet = new Set<string>(VISIBLE_FIELDS);
    const foundNames = new Set<string>();

    for (const field of allFields) {
        const shouldBeVisible = visibleSet.has(field.Name);
        if (shouldBeVisible) foundNames.add(field.Name);
        await ensureDefaultInView(field, shouldBeVisible);
    }

    const missing = VISIBLE_FIELDS.filter((name) => !foundNames.has(name));
    if (missing.length > 0) {
        throw new Error(`These expected visible fields were not found on "${ENTITY_NAME}": ${missing.join(', ')}`);
    }

    console.log(`\n✓ Done. ${VISIBLE_FIELDS.length} fields visible, ${allFields.length - VISIBLE_FIELDS.length} hidden, out of ${allFields.length} total.`);
}

main().catch((err) => { console.error('❌ FAILED:', err instanceof Error ? err.stack : err); process.exit(1); });
