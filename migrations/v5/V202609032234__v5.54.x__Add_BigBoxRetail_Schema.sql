/* ============================================================================
   Big Box Retail — Indiana store roster
   v5.54.x

   Introduces the big_box_retail schema: an isolated home for the Big Box
   Retail research project's (~/Projects/Big_Box_Retail) confirmed Indiana
   store roster. Deliberately separate from indiana_tax — no foreign keys
   either direction. Full design:
   docs/superpowers/specs/2026-09-04-big-box-retail-mj-import-design.md

   One table: Store — one row per address/owner-confirmed big-box retail
   store, imported by Big_Box_Retail/states/indiana/scripts/
   import-roster-to-mj.js from Big_Box_Retail/states/indiana/data/
   indiana-bigbox-roster.csv.

   CodeGen convention (per migrations/CLAUDE.md):
     * NO __mj_CreatedAt / __mj_UpdatedAt columns — CodeGen adds + triggers them.
     * NO indexes — there are no foreign keys on this table to index.
     * sp_addextendedproperty for every non-PK column.
   ============================================================================ */

CREATE SCHEMA big_box_retail;
GO

CREATE TABLE big_box_retail.Store (
    ID                  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Brand               NVARCHAR(100)    NOT NULL,
    StoreName           NVARCHAR(200)    NULL,
    Address             NVARCHAR(200)    NOT NULL,
    City                NVARCHAR(100)    NOT NULL,
    State               NCHAR(2)         NOT NULL DEFAULT 'IN',
    ZIP                 NVARCHAR(10)     NULL,
    County              NVARCHAR(50)     NULL,
    Latitude            DECIMAL(9,6)     NULL,
    Longitude           DECIMAL(9,6)     NULL,
    LocatorSource       NVARCHAR(30)     NULL,
    MatchMethod         NVARCHAR(30)     NULL,
    ParcelCount         INT              NOT NULL DEFAULT 0,
    Parcels             NVARCHAR(MAX)    NULL,
    TotalBuildingSqFt   INT              NULL,
    MaxBuildingSqFt     INT              NULL,
    TotalAssessedValue  MONEY            NULL,
    Tenure              NVARCHAR(30)     NULL,
    OwnerName           NVARCHAR(200)    NULL,
    AppealCount         INT              NOT NULL DEFAULT 0,
    LastAppealYear      SMALLINT         NULL,
    TaxReps             NVARCHAR(300)    NULL,
    SourceFile          NVARCHAR(300)    NOT NULL,
    ImportedAt          DATETIMEOFFSET   NOT NULL,
    CONSTRAINT PK_Store PRIMARY KEY (ID),
    CONSTRAINT UQ_Store_Address_City_ZIP UNIQUE (Address, City, ZIP),
    CONSTRAINT CK_Store_LocatorSource CHECK (LocatorSource IN (N'overpass', N'nominatim', N'nominatim+overpass')),
    CONSTRAINT CK_Store_MatchMethod CHECK (MatchMethod IN (N'exact addr', N'street + near #', N'subset street + #', N'owner + city')),
    CONSTRAINT CK_Store_Tenure CHECK (Tenure IN (N'retailer-owned', N'leased / investor'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per address/owner-confirmed big-box retail store, imported from the separate Big Box Retail research project''s Indiana roster (Big_Box_Retail/states/indiana/data/indiana-bigbox-roster.csv). Deliberately isolated from indiana_tax -- no foreign keys either direction. See docs/superpowers/specs/2026-09-04-big-box-retail-mj-import-design.md.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The tenant/retailer brand name (e.g. Walmart, Kohl''s, Menards). One row per confirmed store, not per parcel -- a multi-parcel site is one Store row with multiple parcels listed in Parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Brand';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The store''s display name as returned by the locator source, when it differs from Brand (e.g. "Walmart Supercenter", "Meijer Express").',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'StoreName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Street address of the store.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Address';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'City.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'City';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Two-letter state code. Indiana-only for now (''IN'') -- a placeholder for future states, not yet used for any multi-state logic.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'State';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'ZIP code, as returned by the locator source.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'ZIP';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana county name (DLGF numbering -- see Big_Box_Retail/states/indiana/data/COUNTY_CODES.md), derived from the matched parcel''s county code.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'County';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Latitude';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Longitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Longitude';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which store-locator source(s) found this store: overpass, nominatim, or both (nominatim+overpass).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'LocatorSource';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which address-matching tier confirmed this store against a county assessor parcel -- see Big_Box_Retail/states/indiana/data/README.md for the methodology and how each tier was verified.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'MatchMethod';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of assessor parcels this store''s building spans (a store is often 2-4 parcels: pad, parking, outlots).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'ParcelCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Delimited county:parcel;county:parcel... list of every matched assessor parcel, using DLGF county numbers.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Parcels';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sum of building square footage across this store''s matched parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'TotalBuildingSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Max building square footage across this store''s matched parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'MaxBuildingSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sum of total assessed value (land + improvement) across this store''s matched parcels, in dollars.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'TotalAssessedValue';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the matched parcel''s owner is the retailer itself (retailer-owned) or a separate landlord/investor (leased / investor).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Tenure';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'County assessor''s owner-of-record name for the matched parcel(s).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'OwnerName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of PTABOA appeals on record for this store''s matched parcel(s).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'AppealCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Most recent assessment year with an appeal on record, if any.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'LastAppealYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tax representative(s) of record from the most recent appeal, if any.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'TaxReps';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Path/name of the CSV file this row was last imported from -- provenance for every row, per this project''s documentation standard.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'SourceFile';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this row was last written by the importer script.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'ImportedAt';
GO


















































-- =============================================================================
-- =============================================================================
-- =============================================================================
--
--                    ⚙️  CODEGEN OUTPUT BELOW THIS LINE  ⚙️
--
-- Everything below this block was generated by the MemberJunction CodeGen tool
-- after the hand-written DDL above was applied to the development database.
-- It contains the framework plumbing for the new big_box_retail.Store table:
-- the new Entity/EntityField metadata inserts, the regenerated base view
-- (vwStores), stored procedures (spCreate/spUpdate/spDelete), permission
-- grants, and related sp_addextendedproperty calls.
--
-- DO NOT EDIT BY HAND. If the hand-written DDL above changes, re-run CodeGen
-- and replace this entire section with the fresh output.
--
-- =============================================================================
-- =============================================================================
-- =============================================================================


/* SQL generated to create new entity Stores */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '264d8245-edfe-4635-8e69-2fa450171711',
         'Stores',
         NULL,
         'One row per address/owner-confirmed big-box retail store, imported from the separate Big Box Retail research project''s Indiana roster (Big_Box_Retail/states/indiana/data/indiana-bigbox-roster.csv). Deliberately isolated from indiana_tax -- no foreign keys either direction. See docs/superpowers/specs/2026-09-04-big-box-retail-mj-import-design.md.',
         NULL,
         'Store',
         'vwStores',
         'big_box_retail',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to create new application big_box_retail */
IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[Application] WHERE [ID] = '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[Application] (ID, Name, Description, SchemaAutoAddNewEntities, Path, AutoUpdatePath)
                       VALUES ('1ca63bf6-f3ed-4b23-ad96-83b6810cbe44', 'big_box_retail', 'Generated for schema', 'big_box_retail', 'bigboxretail', 1)
   END;

/* Adding role UI to application big_box_retail */
IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[ApplicationRole] WHERE [ApplicationID] = '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44' AND [RoleID] = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('1ca63bf6-f3ed-4b23-ad96-83b6810cbe44', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0)
   END;

/* Adding role Developer to application big_box_retail */
IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[ApplicationRole] WHERE [ApplicationID] = '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44' AND [RoleID] = 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('1ca63bf6-f3ed-4b23-ad96-83b6810cbe44', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1)
   END;

/* Adding role Integration to application big_box_retail */
IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[ApplicationRole] WHERE [ApplicationID] = '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44' AND [RoleID] = 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[ApplicationRole]
                                 ([ApplicationID], [RoleID], [CanAccess], [CanAdmin]) VALUES
                                 ('1ca63bf6-f3ed-4b23-ad96-83b6810cbe44', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0)
   END;

/* SQL generated to add new entity Stores to application ID: '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('1ca63bf6-f3ed-4b23-ad96-83b6810cbe44', '264d8245-edfe-4635-8e69-2fa450171711', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '1ca63bf6-f3ed-4b23-ad96-83b6810cbe44'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Stores for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('264d8245-edfe-4635-8e69-2fa450171711', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Stores for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('264d8245-edfe-4635-8e69-2fa450171711', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Stores for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('264d8245-edfe-4635-8e69-2fa450171711', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity big_box_retail.Store */
UPDATE [big_box_retail].[Store] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ADD CONSTRAINT [DF_big_box_retail_Store___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity big_box_retail.Store */
UPDATE [big_box_retail].[Store] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity big_box_retail.Store */
ALTER TABLE [big_box_retail].[Store] ADD CONSTRAINT [DF_big_box_retail_Store___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 26 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e2514348-2208-45b6-b131-c58e590029a9' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e2514348-2208-45b6-b131-c58e590029a9',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bf5f4130-6681-4d61-b1c7-e60c6c8163dd' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Brand')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bf5f4130-6681-4d61-b1c7-e60c6c8163dd',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100002,
            'Brand',
            'Brand',
            'The tenant/retailer brand name (e.g. Walmart, Kohl''s, Menards). One row per confirmed store, not per parcel -- a multi-parcel site is one Store row with multiple parcels listed in Parcels.',
            'nvarchar',
            200,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6806e7ef-36a0-418a-ae77-30b9c8d016d5' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'StoreName')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6806e7ef-36a0-418a-ae77-30b9c8d016d5',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100003,
            'StoreName',
            'Store Name',
            'The store''s display name as returned by the locator source, when it differs from Brand (e.g. "Walmart Supercenter", "Meijer Express").',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8e4faf84-0193-4a1a-bd84-cfd23166d25d' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Address')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8e4faf84-0193-4a1a-bd84-cfd23166d25d',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100004,
            'Address',
            'Address',
            'Street address of the store.',
            'nvarchar',
            400,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '419ab9bc-176a-47ac-8b21-aa1d0ed2f252' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'City')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '419ab9bc-176a-47ac-8b21-aa1d0ed2f252',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100005,
            'City',
            'City',
            'City.',
            'nvarchar',
            200,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c2c1c206-7d8a-4576-949d-04c437961283' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'State')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c2c1c206-7d8a-4576-949d-04c437961283',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100006,
            'State',
            'State',
            'Two-letter state code. Indiana-only for now (''IN'') -- a placeholder for future states, not yet used for any multi-state logic.',
            'nchar',
            4,
            0,
            0,
            0,
            'IN',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1d7b7956-d6b9-45f6-9df5-77f21642a930' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'ZIP')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1d7b7956-d6b9-45f6-9df5-77f21642a930',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100007,
            'ZIP',
            'Zip',
            'ZIP code, as returned by the locator source.',
            'nvarchar',
            20,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3f39d6d5-8a05-47c6-8bda-177838bc3992' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'County')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3f39d6d5-8a05-47c6-8bda-177838bc3992',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100008,
            'County',
            'County',
            'Indiana county name (DLGF numbering -- see Big_Box_Retail/states/indiana/data/COUNTY_CODES.md), derived from the matched parcel''s county code.',
            'nvarchar',
            100,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f3436826-5a7d-4b38-918a-d8b34b816fe9' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Latitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f3436826-5a7d-4b38-918a-d8b34b816fe9',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100009,
            'Latitude',
            'Latitude',
            'Latitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).',
            'decimal',
            5,
            9,
            6,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '29fddf2e-33e5-484d-b4fa-7b7d5517a141' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Longitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '29fddf2e-33e5-484d-b4fa-7b7d5517a141',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100010,
            'Longitude',
            'Longitude',
            'Longitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).',
            'decimal',
            5,
            9,
            6,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '11cc3d83-0a9f-4c5a-91e6-61b726fb0e42' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'LocatorSource')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '11cc3d83-0a9f-4c5a-91e6-61b726fb0e42',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100011,
            'LocatorSource',
            'Locator Source',
            'Which store-locator source(s) found this store: overpass, nominatim, or both (nominatim+overpass).',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0cacf088-aaf6-486e-b7de-c1bd6353b1b0' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'MatchMethod')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0cacf088-aaf6-486e-b7de-c1bd6353b1b0',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100012,
            'MatchMethod',
            'Match Method',
            'Which address-matching tier confirmed this store against a county assessor parcel -- see Big_Box_Retail/states/indiana/data/README.md for the methodology and how each tier was verified.',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '31ee6924-3e68-495c-85a1-cc50f04329b2' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'ParcelCount')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '31ee6924-3e68-495c-85a1-cc50f04329b2',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100013,
            'ParcelCount',
            'Parcel Count',
            'Number of assessor parcels this store''s building spans (a store is often 2-4 parcels: pad, parking, outlots).',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dae58029-0747-4775-a6cb-117164e654d1' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Parcels')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dae58029-0747-4775-a6cb-117164e654d1',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100014,
            'Parcels',
            'Parcels',
            'Delimited county:parcel;county:parcel... list of every matched assessor parcel, using DLGF county numbers.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5ba83891-f091-4da5-8049-cdae355e6e2b' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'TotalBuildingSqFt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5ba83891-f091-4da5-8049-cdae355e6e2b',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100015,
            'TotalBuildingSqFt',
            'Total Building Sq Ft',
            'Sum of building square footage across this store''s matched parcels.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '886c326d-24ae-4ff5-a148-f48b1c67f759' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'MaxBuildingSqFt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '886c326d-24ae-4ff5-a148-f48b1c67f759',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100016,
            'MaxBuildingSqFt',
            'Max Building Sq Ft',
            'Max building square footage across this store''s matched parcels.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '47d5fc3a-ccf3-455c-a3ab-57f40af4c7dc' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'TotalAssessedValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '47d5fc3a-ccf3-455c-a3ab-57f40af4c7dc',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100017,
            'TotalAssessedValue',
            'Total Assessed Value',
            'Sum of total assessed value (land + improvement) across this store''s matched parcels, in dollars.',
            'money',
            8,
            19,
            4,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '28a90937-213b-40dd-9a54-a8591da2e148' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'Tenure')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '28a90937-213b-40dd-9a54-a8591da2e148',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100018,
            'Tenure',
            'Tenure',
            'Whether the matched parcel''s owner is the retailer itself (retailer-owned) or a separate landlord/investor (leased / investor).',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6f39a407-417a-43c0-9a3a-0970021c0312' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'OwnerName')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6f39a407-417a-43c0-9a3a-0970021c0312',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100019,
            'OwnerName',
            'Owner Name',
            'County assessor''s owner-of-record name for the matched parcel(s).',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7e98b857-d01b-47f1-a6b1-21066634a1cc' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'AppealCount')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7e98b857-d01b-47f1-a6b1-21066634a1cc',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100020,
            'AppealCount',
            'Appeal Count',
            'Number of PTABOA appeals on record for this store''s matched parcel(s).',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '759ae164-dca1-49ff-908c-64d0b789a40e' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'LastAppealYear')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '759ae164-dca1-49ff-908c-64d0b789a40e',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100021,
            'LastAppealYear',
            'Last Appeal Year',
            'Most recent assessment year with an appeal on record, if any.',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0269baed-3b32-43e8-8f30-c0809c2457d6' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'TaxReps')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0269baed-3b32-43e8-8f30-c0809c2457d6',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100022,
            'TaxReps',
            'Tax Reps',
            'Tax representative(s) of record from the most recent appeal, if any.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '933ee62e-92a1-4344-82d8-2c5ce8500853' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'SourceFile')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '933ee62e-92a1-4344-82d8-2c5ce8500853',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100023,
            'SourceFile',
            'Source File',
            'Path/name of the CSV file this row was last imported from -- provenance for every row, per this project''s documentation standard.',
            'nvarchar',
            600,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7db2753f-568a-4a2e-a150-8fffeb6a4b6d' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = 'ImportedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7db2753f-568a-4a2e-a150-8fffeb6a4b6d',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100024,
            'ImportedAt',
            'Imported At',
            'When this row was last written by the importer script.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5d2920e5-aaa0-4660-993a-1f1cdf73d326' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5d2920e5-aaa0-4660-993a-1f1cdf73d326',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100025,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5f862a2a-9200-416e-a1f8-c65213ec9f1d' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5f862a2a-9200-416e-a1f8-c65213ec9f1d',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100026,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert entity field value with ID 22e6676f-47b0-4d95-a4b0-a7d7a8104328 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('22e6676f-47b0-4d95-a4b0-a7d7a8104328', '11CC3D83-0A9F-4C5A-91E6-61B726FB0E42', 1, 'nominatim', 'nominatim', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID cf422e05-9b9e-444b-8ca7-a08108fda836 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cf422e05-9b9e-444b-8ca7-a08108fda836', '11CC3D83-0A9F-4C5A-91E6-61B726FB0E42', 2, 'nominatim+overpass', 'nominatim+overpass', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1dfbcdec-6bad-4c42-9c32-2958e75dfb07 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1dfbcdec-6bad-4c42-9c32-2958e75dfb07', '11CC3D83-0A9F-4C5A-91E6-61B726FB0E42', 3, 'overpass', 'overpass', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 11CC3D83-0A9F-4C5A-91E6-61B726FB0E42 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='11CC3D83-0A9F-4C5A-91E6-61B726FB0E42';

/* SQL text to insert entity field value with ID 281df0fc-c2df-4cc7-b73e-a3812cfb1c13 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('281df0fc-c2df-4cc7-b73e-a3812cfb1c13', '0CACF088-AAF6-486E-B7DE-C1BD6353B1B0', 1, 'exact addr', 'exact addr', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b9fbd510-7924-4270-8405-45f44ffc250b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b9fbd510-7924-4270-8405-45f44ffc250b', '0CACF088-AAF6-486E-B7DE-C1BD6353B1B0', 2, 'owner + city', 'owner + city', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 027479ac-96fb-4bee-953c-c44ca9b864ac */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('027479ac-96fb-4bee-953c-c44ca9b864ac', '0CACF088-AAF6-486E-B7DE-C1BD6353B1B0', 3, 'street + near #', 'street + near #', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ad8a7b29-b8e6-4935-8758-b2bcf395d4d2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ad8a7b29-b8e6-4935-8758-b2bcf395d4d2', '0CACF088-AAF6-486E-B7DE-C1BD6353B1B0', 4, 'subset street + #', 'subset street + #', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 0CACF088-AAF6-486E-B7DE-C1BD6353B1B0 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='0CACF088-AAF6-486E-B7DE-C1BD6353B1B0';

/* SQL text to insert entity field value with ID 36ffa646-bfe6-42ea-8c12-32a4584a2527 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('36ffa646-bfe6-42ea-8c12-32a4584a2527', '28A90937-213B-40DD-9A54-A8591DA2E148', 1, 'leased / investor', 'leased / investor', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID aac95202-baf0-4194-a043-29854e3c77f6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('aac95202-baf0-4194-a043-29854e3c77f6', '28A90937-213B-40DD-9A54-A8591DA2E148', 2, 'retailer-owned', 'retailer-owned', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 28A90937-213B-40DD-9A54-A8591DA2E148 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='28A90937-213B-40DD-9A54-A8591DA2E148';

/* Index for Foreign Keys for Store */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: vwStores
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Stores
-----               SCHEMA:      big_box_retail
-----               BASE TABLE:  Store
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[vwStores]', 'V') IS NOT NULL
    DROP VIEW [big_box_retail].[vwStores];
GO

CREATE VIEW [big_box_retail].[vwStores]
AS
SELECT
    s.*
FROM
    [big_box_retail].[Store] AS s
GO
GRANT SELECT ON [big_box_retail].[vwStores] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: Permissions for vwStores
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [big_box_retail].[vwStores] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spCreateStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spCreateStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spCreateStore];
GO

CREATE PROCEDURE [big_box_retail].[spCreateStore]
    @ID uniqueidentifier = NULL,
    @Brand nvarchar(100),
    @StoreName_Clear bit = 0,
    @StoreName nvarchar(200) = NULL,
    @Address nvarchar(200),
    @City nvarchar(100),
    @State nchar(2) = NULL,
    @ZIP_Clear bit = 0,
    @ZIP nvarchar(10) = NULL,
    @County_Clear bit = 0,
    @County nvarchar(50) = NULL,
    @Latitude_Clear bit = 0,
    @Latitude decimal(9, 6) = NULL,
    @Longitude_Clear bit = 0,
    @Longitude decimal(9, 6) = NULL,
    @LocatorSource_Clear bit = 0,
    @LocatorSource nvarchar(30) = NULL,
    @MatchMethod_Clear bit = 0,
    @MatchMethod nvarchar(30) = NULL,
    @ParcelCount int = NULL,
    @Parcels_Clear bit = 0,
    @Parcels nvarchar(MAX) = NULL,
    @TotalBuildingSqFt_Clear bit = 0,
    @TotalBuildingSqFt int = NULL,
    @MaxBuildingSqFt_Clear bit = 0,
    @MaxBuildingSqFt int = NULL,
    @TotalAssessedValue_Clear bit = 0,
    @TotalAssessedValue money = NULL,
    @Tenure_Clear bit = 0,
    @Tenure nvarchar(30) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(200) = NULL,
    @AppealCount int = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear smallint = NULL,
    @TaxReps_Clear bit = 0,
    @TaxReps nvarchar(300) = NULL,
    @SourceFile nvarchar(300),
    @ImportedAt datetimeoffset
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [big_box_retail].[Store]
            (
                [ID],
                [Brand],
                [StoreName],
                [Address],
                [City],
                [State],
                [ZIP],
                [County],
                [Latitude],
                [Longitude],
                [LocatorSource],
                [MatchMethod],
                [ParcelCount],
                [Parcels],
                [TotalBuildingSqFt],
                [MaxBuildingSqFt],
                [TotalAssessedValue],
                [Tenure],
                [OwnerName],
                [AppealCount],
                [LastAppealYear],
                [TaxReps],
                [SourceFile],
                [ImportedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Brand,
                CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, NULL) END,
                @Address,
                @City,
                ISNULL(@State, 'IN'),
                CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, NULL) END,
                CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, NULL) END,
                CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, NULL) END,
                CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, NULL) END,
                CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, NULL) END,
                CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, NULL) END,
                ISNULL(@ParcelCount, 0),
                CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, NULL) END,
                CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, NULL) END,
                CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, NULL) END,
                CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, NULL) END,
                CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                ISNULL(@AppealCount, 0),
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END,
                CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, NULL) END,
                @SourceFile,
                @ImportedAt
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [big_box_retail].[Store]
            (
                [Brand],
                [StoreName],
                [Address],
                [City],
                [State],
                [ZIP],
                [County],
                [Latitude],
                [Longitude],
                [LocatorSource],
                [MatchMethod],
                [ParcelCount],
                [Parcels],
                [TotalBuildingSqFt],
                [MaxBuildingSqFt],
                [TotalAssessedValue],
                [Tenure],
                [OwnerName],
                [AppealCount],
                [LastAppealYear],
                [TaxReps],
                [SourceFile],
                [ImportedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Brand,
                CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, NULL) END,
                @Address,
                @City,
                ISNULL(@State, 'IN'),
                CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, NULL) END,
                CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, NULL) END,
                CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, NULL) END,
                CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, NULL) END,
                CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, NULL) END,
                CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, NULL) END,
                ISNULL(@ParcelCount, 0),
                CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, NULL) END,
                CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, NULL) END,
                CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, NULL) END,
                CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, NULL) END,
                CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                ISNULL(@AppealCount, 0),
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END,
                CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, NULL) END,
                @SourceFile,
                @ImportedAt
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [big_box_retail].[vwStores] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [big_box_retail].[spCreateStore] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spCreateStore] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spUpdateStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spUpdateStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spUpdateStore];
GO

CREATE PROCEDURE [big_box_retail].[spUpdateStore]
    @ID uniqueidentifier,
    @Brand nvarchar(100) = NULL,
    @StoreName_Clear bit = 0,
    @StoreName nvarchar(200) = NULL,
    @Address nvarchar(200) = NULL,
    @City nvarchar(100) = NULL,
    @State nchar(2) = NULL,
    @ZIP_Clear bit = 0,
    @ZIP nvarchar(10) = NULL,
    @County_Clear bit = 0,
    @County nvarchar(50) = NULL,
    @Latitude_Clear bit = 0,
    @Latitude decimal(9, 6) = NULL,
    @Longitude_Clear bit = 0,
    @Longitude decimal(9, 6) = NULL,
    @LocatorSource_Clear bit = 0,
    @LocatorSource nvarchar(30) = NULL,
    @MatchMethod_Clear bit = 0,
    @MatchMethod nvarchar(30) = NULL,
    @ParcelCount int = NULL,
    @Parcels_Clear bit = 0,
    @Parcels nvarchar(MAX) = NULL,
    @TotalBuildingSqFt_Clear bit = 0,
    @TotalBuildingSqFt int = NULL,
    @MaxBuildingSqFt_Clear bit = 0,
    @MaxBuildingSqFt int = NULL,
    @TotalAssessedValue_Clear bit = 0,
    @TotalAssessedValue money = NULL,
    @Tenure_Clear bit = 0,
    @Tenure nvarchar(30) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(200) = NULL,
    @AppealCount int = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear smallint = NULL,
    @TaxReps_Clear bit = 0,
    @TaxReps nvarchar(300) = NULL,
    @SourceFile nvarchar(300) = NULL,
    @ImportedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [big_box_retail].[Store]
    SET
        [Brand] = ISNULL(@Brand, [Brand]),
        [StoreName] = CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, [StoreName]) END,
        [Address] = ISNULL(@Address, [Address]),
        [City] = ISNULL(@City, [City]),
        [State] = ISNULL(@State, [State]),
        [ZIP] = CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, [ZIP]) END,
        [County] = CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, [County]) END,
        [Latitude] = CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, [Latitude]) END,
        [Longitude] = CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, [Longitude]) END,
        [LocatorSource] = CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, [LocatorSource]) END,
        [MatchMethod] = CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, [MatchMethod]) END,
        [ParcelCount] = ISNULL(@ParcelCount, [ParcelCount]),
        [Parcels] = CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, [Parcels]) END,
        [TotalBuildingSqFt] = CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, [TotalBuildingSqFt]) END,
        [MaxBuildingSqFt] = CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, [MaxBuildingSqFt]) END,
        [TotalAssessedValue] = CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, [TotalAssessedValue]) END,
        [Tenure] = CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, [Tenure]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [AppealCount] = ISNULL(@AppealCount, [AppealCount]),
        [LastAppealYear] = CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, [LastAppealYear]) END,
        [TaxReps] = CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, [TaxReps]) END,
        [SourceFile] = ISNULL(@SourceFile, [SourceFile]),
        [ImportedAt] = ISNULL(@ImportedAt, [ImportedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [big_box_retail].[vwStores] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [big_box_retail].[vwStores]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [big_box_retail].[spUpdateStore] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Store table
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[trgUpdateStore]', 'TR') IS NOT NULL
    DROP TRIGGER [big_box_retail].[trgUpdateStore];
GO
CREATE TRIGGER [big_box_retail].trgUpdateStore
ON [big_box_retail].[Store]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [big_box_retail].[Store]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [big_box_retail].[Store] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spUpdateStore] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spDeleteStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spDeleteStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spDeleteStore];
GO

CREATE PROCEDURE [big_box_retail].[spDeleteStore]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [big_box_retail].[Store]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [big_box_retail].[spDeleteStore] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spDeleteStore] TO [cdp_Developer], [cdp_Integration];

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'BF5F4130-6681-4D61-B1C7-E60C6C8163DD'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'BF5F4130-6681-4D61-B1C7-E60C6C8163DD'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6806E7EF-36A0-418A-AE77-30B9C8D016D5'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8E4FAF84-0193-4A1A-BD84-CFD23166D25D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '419AB9BC-176A-47AC-8B21-AA1D0ED2F252'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3F39D6D5-8A05-47C6-8BDA-177838BC3992'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '31EE6924-3E68-495C-85A1-CC50F04329B2'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'BF5F4130-6681-4D61-B1C7-E60C6C8163DD'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6806E7EF-36A0-418A-AE77-30B9C8D016D5'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '8E4FAF84-0193-4A1A-BD84-CFD23166D25D'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '419AB9BC-176A-47AC-8B21-AA1D0ED2F252'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '3F39D6D5-8A05-47C6-8BDA-177838BC3992'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'BF5F4130-6681-4D61-B1C7-E60C6C8163DD'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '6806E7EF-36A0-418A-AE77-30B9C8D016D5'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '419AB9BC-176A-47AC-8B21-AA1D0ED2F252'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '3F39D6D5-8A05-47C6-8BDA-177838BC3992'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 26 fields */

-- UPDATE Entity Field Category Info Stores.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E2514348-2208-45B6-B131-C58E590029A9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Brand 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BF5F4130-6681-4D61-B1C7-E60C6C8163DD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.StoreName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6806E7EF-36A0-418A-AE77-30B9C8D016D5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Address 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   DisplayName = 'Street Address',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = '8E4FAF84-0193-4A1A-BD84-CFD23166D25D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.City 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoCity',
   CodeType = NULL
WHERE 
   ID = '419AB9BC-176A-47AC-8B21-AA1D0ED2F252' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.State 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoStateProvince',
   CodeType = NULL
WHERE 
   ID = 'C2C1C206-7D8A-4576-949D-04C437961283' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.ZIP 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   DisplayName = 'ZIP Code',
   ExtendedType = 'GeoPostalCode',
   CodeType = NULL
WHERE 
   ID = '1D7B7956-D6B9-45F6-9DF5-77F21642A930' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.County 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3F39D6D5-8A05-47C6-8BDA-177838BC3992' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Latitude 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoLatitude',
   CodeType = NULL
WHERE 
   ID = 'F3436826-5A7D-4B38-918A-D8B34B816FE9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Longitude 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Store Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoLongitude',
   CodeType = NULL
WHERE 
   ID = '29FDDF2E-33E5-484D-B4FA-7B7D5517A141' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.LocatorSource 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Data Source and Matching',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '11CC3D83-0A9F-4C5A-91E6-61B726FB0E42' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.MatchMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Data Source and Matching',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0CACF088-AAF6-486E-B7DE-C1BD6353B1B0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.ParcelCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '31EE6924-3E68-495C-85A1-CC50F04329B2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Parcels 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DAE58029-0747-4775-A6CB-117164E654D1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.TotalBuildingSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Building Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5BA83891-F091-4DA5-8049-CDAE355E6E2B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.MaxBuildingSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Max Building Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '886C326D-24AE-4FF5-A148-F48B1C67F759' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.TotalAssessedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '47D5FC3A-CCF3-455C-A3AB-57F40AF4C7DC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.Tenure 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ownership Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '28A90937-213B-40DD-9A54-A8591DA2E148' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.OwnerName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ownership Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6F39A407-417A-43C0-9A3A-0970021C0312' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.AppealCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Assessment Appeals',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7E98B857-D01B-47F1-A6B1-21066634A1CC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.LastAppealYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Assessment Appeals',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '759AE164-DCA1-49FF-908C-64D0B789A40E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.TaxReps 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Assessment Appeals',
   GeneratedFormSection = 'Category',
   DisplayName = 'Tax Representatives',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0269BAED-3B32-43E8-8F30-C0809C2457D6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.SourceFile 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '933EE62E-92A1-4344-82D8-2C5CE8500853' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.ImportedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7DB2753F-568A-4A2E-A150-8FFFEB6A4B6D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5D2920E5-AAA0-4660-993A-1F1CDF73D326' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Stores.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5F862A2A-9200-416E-A1F8-C65213EC9F1D' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for Stores */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '264D8245-EDFE-4635-8E69-2FA450171711' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-store */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-store', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '264D8245-EDFE-4635-8E69-2FA450171711';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('b5d79624-7645-4a32-b5e9-7f0f3bbbe4ce', '264D8245-EDFE-4635-8E69-2FA450171711', 'FieldCategoryInfo', '{"Store Identification":{"icon":"fa fa-store","description":"Brand name and store identifiers"},"Store Location":{"icon":"fa fa-map-marker-alt","description":"Physical address and geographic coordinates of the store"},"Data Source and Matching":{"icon":"fa fa-link","description":"Information about how this store was located and verified"},"Property Details":{"icon":"fa fa-building","description":"Property assessor information including parcels, building size, and assessed value"},"Ownership Information":{"icon":"fa fa-file-contract","description":"Ownership status and legal owner information"},"Tax Assessment Appeals":{"icon":"fa fa-gavel","description":"Property tax appeal history and tax representative information"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and import tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8a7d3b0b-9a9a-4df6-987a-d2c99b4b0960', '264D8245-EDFE-4635-8E69-2FA450171711', 'FieldCategoryIcons', '{"Store Identification":"fa fa-store","Store Location":"fa fa-map-marker-alt","Data Source and Matching":"fa fa-link","Property Details":"fa fa-building","Ownership Information":"fa fa-file-contract","Tax Assessment Appeals":"fa fa-gavel","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '264D8245-EDFE-4635-8E69-2FA450171711';

/* Index for Foreign Keys for Store */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: vwStores
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Stores
-----               SCHEMA:      big_box_retail
-----               BASE TABLE:  Store
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[vwStores]', 'V') IS NOT NULL
    DROP VIEW [big_box_retail].[vwStores];
GO

CREATE VIEW [big_box_retail].[vwStores]
AS
SELECT
    s.*,    [s].[Latitude] AS [${flyway:defaultSchema}_Latitude],
    [s].[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [big_box_retail].[Store] AS s
GO
GRANT SELECT ON [big_box_retail].[vwStores] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: Permissions for vwStores
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [big_box_retail].[vwStores] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spCreateStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spCreateStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spCreateStore];
GO

CREATE PROCEDURE [big_box_retail].[spCreateStore]
    @ID uniqueidentifier = NULL,
    @Brand nvarchar(100),
    @StoreName_Clear bit = 0,
    @StoreName nvarchar(200) = NULL,
    @Address nvarchar(200),
    @City nvarchar(100),
    @State nchar(2) = NULL,
    @ZIP_Clear bit = 0,
    @ZIP nvarchar(10) = NULL,
    @County_Clear bit = 0,
    @County nvarchar(50) = NULL,
    @Latitude_Clear bit = 0,
    @Latitude decimal(9, 6) = NULL,
    @Longitude_Clear bit = 0,
    @Longitude decimal(9, 6) = NULL,
    @LocatorSource_Clear bit = 0,
    @LocatorSource nvarchar(30) = NULL,
    @MatchMethod_Clear bit = 0,
    @MatchMethod nvarchar(30) = NULL,
    @ParcelCount int = NULL,
    @Parcels_Clear bit = 0,
    @Parcels nvarchar(MAX) = NULL,
    @TotalBuildingSqFt_Clear bit = 0,
    @TotalBuildingSqFt int = NULL,
    @MaxBuildingSqFt_Clear bit = 0,
    @MaxBuildingSqFt int = NULL,
    @TotalAssessedValue_Clear bit = 0,
    @TotalAssessedValue money = NULL,
    @Tenure_Clear bit = 0,
    @Tenure nvarchar(30) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(200) = NULL,
    @AppealCount int = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear smallint = NULL,
    @TaxReps_Clear bit = 0,
    @TaxReps nvarchar(300) = NULL,
    @SourceFile nvarchar(300),
    @ImportedAt datetimeoffset
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [big_box_retail].[Store]
            (
                [ID],
                [Brand],
                [StoreName],
                [Address],
                [City],
                [State],
                [ZIP],
                [County],
                [Latitude],
                [Longitude],
                [LocatorSource],
                [MatchMethod],
                [ParcelCount],
                [Parcels],
                [TotalBuildingSqFt],
                [MaxBuildingSqFt],
                [TotalAssessedValue],
                [Tenure],
                [OwnerName],
                [AppealCount],
                [LastAppealYear],
                [TaxReps],
                [SourceFile],
                [ImportedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Brand,
                CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, NULL) END,
                @Address,
                @City,
                ISNULL(@State, 'IN'),
                CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, NULL) END,
                CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, NULL) END,
                CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, NULL) END,
                CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, NULL) END,
                CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, NULL) END,
                CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, NULL) END,
                ISNULL(@ParcelCount, 0),
                CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, NULL) END,
                CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, NULL) END,
                CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, NULL) END,
                CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, NULL) END,
                CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                ISNULL(@AppealCount, 0),
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END,
                CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, NULL) END,
                @SourceFile,
                @ImportedAt
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [big_box_retail].[Store]
            (
                [Brand],
                [StoreName],
                [Address],
                [City],
                [State],
                [ZIP],
                [County],
                [Latitude],
                [Longitude],
                [LocatorSource],
                [MatchMethod],
                [ParcelCount],
                [Parcels],
                [TotalBuildingSqFt],
                [MaxBuildingSqFt],
                [TotalAssessedValue],
                [Tenure],
                [OwnerName],
                [AppealCount],
                [LastAppealYear],
                [TaxReps],
                [SourceFile],
                [ImportedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Brand,
                CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, NULL) END,
                @Address,
                @City,
                ISNULL(@State, 'IN'),
                CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, NULL) END,
                CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, NULL) END,
                CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, NULL) END,
                CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, NULL) END,
                CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, NULL) END,
                CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, NULL) END,
                ISNULL(@ParcelCount, 0),
                CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, NULL) END,
                CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, NULL) END,
                CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, NULL) END,
                CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, NULL) END,
                CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                ISNULL(@AppealCount, 0),
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END,
                CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, NULL) END,
                @SourceFile,
                @ImportedAt
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [big_box_retail].[vwStores] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [big_box_retail].[spCreateStore] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spCreateStore] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spUpdateStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spUpdateStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spUpdateStore];
GO

CREATE PROCEDURE [big_box_retail].[spUpdateStore]
    @ID uniqueidentifier,
    @Brand nvarchar(100) = NULL,
    @StoreName_Clear bit = 0,
    @StoreName nvarchar(200) = NULL,
    @Address nvarchar(200) = NULL,
    @City nvarchar(100) = NULL,
    @State nchar(2) = NULL,
    @ZIP_Clear bit = 0,
    @ZIP nvarchar(10) = NULL,
    @County_Clear bit = 0,
    @County nvarchar(50) = NULL,
    @Latitude_Clear bit = 0,
    @Latitude decimal(9, 6) = NULL,
    @Longitude_Clear bit = 0,
    @Longitude decimal(9, 6) = NULL,
    @LocatorSource_Clear bit = 0,
    @LocatorSource nvarchar(30) = NULL,
    @MatchMethod_Clear bit = 0,
    @MatchMethod nvarchar(30) = NULL,
    @ParcelCount int = NULL,
    @Parcels_Clear bit = 0,
    @Parcels nvarchar(MAX) = NULL,
    @TotalBuildingSqFt_Clear bit = 0,
    @TotalBuildingSqFt int = NULL,
    @MaxBuildingSqFt_Clear bit = 0,
    @MaxBuildingSqFt int = NULL,
    @TotalAssessedValue_Clear bit = 0,
    @TotalAssessedValue money = NULL,
    @Tenure_Clear bit = 0,
    @Tenure nvarchar(30) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(200) = NULL,
    @AppealCount int = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear smallint = NULL,
    @TaxReps_Clear bit = 0,
    @TaxReps nvarchar(300) = NULL,
    @SourceFile nvarchar(300) = NULL,
    @ImportedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [big_box_retail].[Store]
    SET
        [Brand] = ISNULL(@Brand, [Brand]),
        [StoreName] = CASE WHEN @StoreName_Clear = 1 THEN NULL ELSE ISNULL(@StoreName, [StoreName]) END,
        [Address] = ISNULL(@Address, [Address]),
        [City] = ISNULL(@City, [City]),
        [State] = ISNULL(@State, [State]),
        [ZIP] = CASE WHEN @ZIP_Clear = 1 THEN NULL ELSE ISNULL(@ZIP, [ZIP]) END,
        [County] = CASE WHEN @County_Clear = 1 THEN NULL ELSE ISNULL(@County, [County]) END,
        [Latitude] = CASE WHEN @Latitude_Clear = 1 THEN NULL ELSE ISNULL(@Latitude, [Latitude]) END,
        [Longitude] = CASE WHEN @Longitude_Clear = 1 THEN NULL ELSE ISNULL(@Longitude, [Longitude]) END,
        [LocatorSource] = CASE WHEN @LocatorSource_Clear = 1 THEN NULL ELSE ISNULL(@LocatorSource, [LocatorSource]) END,
        [MatchMethod] = CASE WHEN @MatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@MatchMethod, [MatchMethod]) END,
        [ParcelCount] = ISNULL(@ParcelCount, [ParcelCount]),
        [Parcels] = CASE WHEN @Parcels_Clear = 1 THEN NULL ELSE ISNULL(@Parcels, [Parcels]) END,
        [TotalBuildingSqFt] = CASE WHEN @TotalBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalBuildingSqFt, [TotalBuildingSqFt]) END,
        [MaxBuildingSqFt] = CASE WHEN @MaxBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MaxBuildingSqFt, [MaxBuildingSqFt]) END,
        [TotalAssessedValue] = CASE WHEN @TotalAssessedValue_Clear = 1 THEN NULL ELSE ISNULL(@TotalAssessedValue, [TotalAssessedValue]) END,
        [Tenure] = CASE WHEN @Tenure_Clear = 1 THEN NULL ELSE ISNULL(@Tenure, [Tenure]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [AppealCount] = ISNULL(@AppealCount, [AppealCount]),
        [LastAppealYear] = CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, [LastAppealYear]) END,
        [TaxReps] = CASE WHEN @TaxReps_Clear = 1 THEN NULL ELSE ISNULL(@TaxReps, [TaxReps]) END,
        [SourceFile] = ISNULL(@SourceFile, [SourceFile]),
        [ImportedAt] = ISNULL(@ImportedAt, [ImportedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [big_box_retail].[vwStores] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [big_box_retail].[vwStores]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [big_box_retail].[spUpdateStore] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Store table
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[trgUpdateStore]', 'TR') IS NOT NULL
    DROP TRIGGER [big_box_retail].[trgUpdateStore];
GO
CREATE TRIGGER [big_box_retail].trgUpdateStore
ON [big_box_retail].[Store]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [big_box_retail].[Store]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [big_box_retail].[Store] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spUpdateStore] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Stores */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Stores
-- Item: spDeleteStore
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Store
------------------------------------------------------------
IF OBJECT_ID('[big_box_retail].[spDeleteStore]', 'P') IS NOT NULL
    DROP PROCEDURE [big_box_retail].[spDeleteStore];
GO

CREATE PROCEDURE [big_box_retail].[spDeleteStore]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [big_box_retail].[Store]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [big_box_retail].[spDeleteStore] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Stores */

GRANT EXECUTE ON [big_box_retail].[spDeleteStore] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3c8fbaa8-754d-4a67-a382-a6267fef2a03' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3c8fbaa8-754d-4a67-a382-a6267fef2a03',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100053,
            '${flyway:defaultSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            5,
            9,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '269b4d6d-e9ee-444e-8e3f-a70cd5b3e809' OR (EntityID = '264D8245-EDFE-4635-8E69-2FA450171711' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '269b4d6d-e9ee-444e-8e3f-a70cd5b3e809',
            '264D8245-EDFE-4635-8E69-2FA450171711', -- Entity: Stores
            100054,
            '${flyway:defaultSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            5,
            9,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* Set ExtendedType=GeoLatitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${flyway:defaultSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('264D8245-EDFE-4635-8E69-2FA450171711');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${flyway:defaultSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('264D8245-EDFE-4635-8E69-2FA450171711');

