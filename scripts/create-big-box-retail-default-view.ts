/**
 * Create a shared default grid view for the "Stores" entity (big_box_retail.Store),
 * so the new Application (Task 3) has something to point its nav item at. Also grants
 * the base "UI" role View access on that view via an `MJ: Resource Permissions` row —
 * `IsShared = true` alone does NOT grant non-owner users access; MJUserViewEntityExtended
 * .CalculateUserCanView() (packages/MJCoreEntities/src/custom/MJUserViewEntityExtended.ts)
 * requires an actual approved Resource Permission row for any non-owner user.
 *
 * Idempotent: re-running reuses the existing view by (EntityID, Name), and the existing
 * permission by (ResourceTypeID, ResourceRecordID, Type='Role', RoleID, Status='Approved'),
 * if present.
 *
 * Usage (repo root): npx tsx scripts/create-big-box-retail-default-view.ts
 */
import { Metadata, RunView, UserInfo } from '@memberjunction/core';
import { setupSQLServerClient, SQLServerProviderConfigData, UserCache } from '@memberjunction/sqlserver-dataprovider';
import { MJUserViewEntityExtended, MJResourcePermissionEntity } from '@memberjunction/core-entities';
import sql from 'mssql';
import dotenv from 'dotenv';
import path from 'path';

import '@memberjunction/server-bootstrap-lite';

dotenv.config({ path: path.resolve(process.cwd(), '.env'), quiet: true });

// NOTE: Task 2 Step 1 confirmed CodeGen assigned the entity name "Stores" (not "Big Box Retail Store"
// as originally assumed in the brief) for the big_box_retail.Store table — verified via
// packages/GeneratedEntities/src/generated/entity_subclasses.ts (@RegisterClass(BaseEntity, 'Stores'))
// and the __mj.Entity table (ID 264D8245-EDFE-4635-8E69-2FA450171711).
const ENTITY_NAME = 'Stores';
const VIEW_NAME = 'All Big Box Retail Stores';

// The "UI" / "Basic UI" role — controller-confirmed standard base role every logged-in
// Explorer user holds, queried directly from __mj.Role.
const UI_ROLE_ID = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';

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

async function findExistingView(entityID: string, user: UserInfo): Promise<MJUserViewEntityExtended | null> {
    const existing = await new RunView().RunView<MJUserViewEntityExtended>({
        EntityName: 'MJ: User Views',
        ExtraFilter: `EntityID='${entityID}' AND Name='${VIEW_NAME}'`,
        ResultType: 'entity_object'
    }, user);
    return existing.Success && existing.Results.length > 0 ? existing.Results[0] : null;
}

async function createView(entityID: string, md: Metadata, user: UserInfo): Promise<MJUserViewEntityExtended> {
    const view = await md.GetEntityObject<MJUserViewEntityExtended>('MJ: User Views', user);
    view.NewRecord();
    // Deterministic ID across environments — metadata/CLAUDE.md rule 1 convention for
    // hardcoded record IDs, applied here since this row is created by script rather than
    // `mj sync`. metadata/applications/.big-box-retail-application.json's nav item hardcodes
    // this exact GUID as its RecordID; without setting it explicitly here, BaseEntity would
    // leave the uniqueidentifier PK null on NewRecord() and the server would mint a random
    // GUID at save time, breaking the Application's nav item on a fresh environment/rebuild.
    view.ID = 'DF0F833D-0F8A-4334-BCE4-A5B35DA11B95';
    view.UserID = user.ID;
    view.EntityID = entityID;
    view.Name = VIEW_NAME;
    view.Description = 'Default grid of every address/owner-confirmed Big Box Retail store.';
    view.IsShared = true;
    view.IsDefault = true;
    if (!(await view.Save())) throw new Error(`Failed to save view: ${view.LatestResult?.CompleteMessage}`);
    return view;
}

async function findExistingUIRolePermission(resourceTypeID: string, resourceRecordID: string, user: UserInfo): Promise<MJResourcePermissionEntity | null> {
    const existing = await new RunView().RunView<MJResourcePermissionEntity>({
        EntityName: 'MJ: Resource Permissions',
        ExtraFilter: `ResourceTypeID='${resourceTypeID}' AND ResourceRecordID='${resourceRecordID}' AND Type='Role' AND RoleID='${UI_ROLE_ID}' AND Status='Approved'`,
        ResultType: 'entity_object'
    }, user);
    return existing.Success && existing.Results.length > 0 ? existing.Results[0] : null;
}

async function createUIRolePermission(resourceTypeID: string, resourceRecordID: string, md: Metadata, user: UserInfo): Promise<MJResourcePermissionEntity> {
    const permission = await md.GetEntityObject<MJResourcePermissionEntity>('MJ: Resource Permissions', user);
    permission.NewRecord();
    permission.ResourceTypeID = resourceTypeID;
    permission.ResourceRecordID = resourceRecordID;
    permission.Type = 'Role';
    permission.RoleID = UI_ROLE_ID;
    permission.PermissionLevel = 'View';
    permission.Status = 'Approved';
    permission.SharedByUserID = user.ID;
    if (!(await permission.Save())) throw new Error(`Failed to save resource permission: ${permission.LatestResult?.CompleteMessage}`);
    return permission;
}

async function ensureView(entityID: string, md: Metadata, user: UserInfo): Promise<MJUserViewEntityExtended> {
    const existingView = await findExistingView(entityID, user);
    if (existingView) {
        console.log(`✓ View already exists: ${existingView.ID}`);
        return existingView;
    }
    const view = await createView(entityID, md, user);
    console.log(`✓ View created: ${view.ID}`);
    return view;
}

async function ensureUIRolePermission(view: MJUserViewEntityExtended, md: Metadata, user: UserInfo): Promise<void> {
    const resourceTypeID = view.ViewResourceTypeID;
    const existingPermission = await findExistingUIRolePermission(resourceTypeID, view.ID, user);
    if (existingPermission) {
        console.log(`✓ UI role permission already exists: ${existingPermission.ID}`);
        return;
    }
    const permission = await createUIRolePermission(resourceTypeID, view.ID, md, user);
    console.log(`✓ UI role permission created: ${permission.ID}`);
}

async function main(): Promise<void> {
    const user = await bootstrap();
    const md = new Metadata();
    const entity = md.EntityByName(ENTITY_NAME);
    if (!entity) throw new Error(`Entity "${ENTITY_NAME}" not found — did CodeGen run (Task 2 Step 1)?`);

    const view = await ensureView(entity.ID, md, user);
    await ensureUIRolePermission(view, md, user);
}

main().catch((err) => { console.error('❌ FAILED:', err instanceof Error ? err.stack : err); process.exit(1); });
