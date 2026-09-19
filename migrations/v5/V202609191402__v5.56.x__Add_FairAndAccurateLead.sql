/* ============================================================================
   Fair & Accurate — public taxpayer-facing lead intake
   v5.56.x

   One entity: FairAndAccurateLead — a minimal intake record captured when an
   anonymous visitor on the public "Fair & Accurate" taxpayer site asks to be
   contacted about a parcel. This mirrors the SHAPE of an intake record, not a
   full CRM: the firm's existing intake process consumes Status / ContactEmail
   / ParcelID off this table and does the rest downstream. Written by the
   public API under a restricted Role (Create only — see the accompanying
   metadata/entity-permissions + metadata/roles sync files); read/update/delete
   are handled by internal staff through the normal Explorer UI under their own
   (unrestricted) roles.
   ============================================================================ */

/* -------------------------------------------------------------------------- */
/* FairAndAccurateLead                                                        */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.FairAndAccurateLead (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,

    ContactName NVARCHAR(200) NOT NULL,
    ContactEmail NVARCHAR(320) NOT NULL,
    ContactPhone NVARCHAR(30) NULL,
    Message NVARCHAR(2000) NULL,
    SubmittedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_FairAndAccurateLead_SubmittedAt DEFAULT (SYSDATETIMEOFFSET()),
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_FairAndAccurateLead_Status DEFAULT ('new'),

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_FairAndAccurateLead_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_FairAndAccurateLead_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_FairAndAccurateLead PRIMARY KEY (ID),
    CONSTRAINT FK_FairAndAccurateLead_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT CK_FairAndAccurateLead_Status CHECK (Status IN ('new', 'contacted', 'qualified', 'disqualified', 'converted'))
);
GO

/* ========================================================================== */
/* Extended properties — table + every non-PK/FK column                        */
/* ========================================================================== */

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A public taxpayer-site lead: captured when an anonymous "Fair & Accurate" site visitor asks to be contacted about a specific parcel. Mirrors the shape of an intake record, not a full CRM — the firm''s existing intake process consumes Status/ContactEmail/ParcelID and does the rest. Written by the public API under a restricted, Create-only Role.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The visitor''s self-reported name, taken verbatim from the public site form.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'ContactName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The visitor''s self-reported email address, taken verbatim from the public site form. The firm''s intake process uses this to follow up.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'ContactEmail';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The visitor''s self-reported phone number, taken verbatim from the public site form. Optional.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'ContactPhone';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Free-text message the visitor entered on the public site form. Optional.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'Message';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'When the public API received this lead. Defaults to the moment of insert; the public API does not set this explicitly.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'SubmittedAt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The firm''s intake-pipeline status for this lead. Always inserted as ''new'' by the public API (which has Create-only access); internal staff advance it through the rest of the intake process from the Explorer UI.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'FairAndAccurateLead', @level2type = N'COLUMN', @level2name = N'Status';
GO




















































/* ============================================================================
   Everything below this point was generated by the MemberJunction CodeGen
   tool (`mj codegen`, run 2026-09-19) against the hand-written DDL above.
   It registers the Fair And Accurate Leads entity's metadata (Entity,
   EntityField x11, EntityFieldValue x5 for the Status value list, the
   Parcels -> Fair And Accurate Leads EntityRelationship, default UI /
   Developer / Integration role EntityPermission grants, field categories,
   and application placement), plus the generated SQL objects: the FK index,
   base view (vwFairAndAccurateLeads), and spCreate/spUpdate/spDelete
   procedures + their GRANTs and the __mj_UpdatedAt trigger.

   Contains EntityField inserts, regenerated views, spCreate/spUpdate/
   spDelete procs, and permission grants. Do NOT edit by hand — if the
   hand-written DDL above changes, re-run CodeGen and replace this entire
   generated section.

   EXCLUDED: this run's raw CodeGen_Run_*.sql also contained one unrelated
   statement --- an UPDATE to indiana_tax.EntityField fixing a pre-existing
   field-sequence inconsistency on the Big Box Retail "Store Analysis"
   virtual entity's UnverifiedCompCount field (Sequence 100141 -> 70). That
   drift predates this migration, is unrelated to Fair And Accurate Leads,
   and was deliberately left out of this file per migrations/CLAUDE.md's
   guidance to exclude unrelated regenerations from an appended CodeGen
   section. It is a live discrepancy on the shared dev database, tracked
   separately -- not part of this change.
   ============================================================================ */

/* SQL generated to create new entity Fair And Accurate Leads */

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
         '8c1e3f25-daa3-4c9a-8eee-172fba165a33',
         'Fair And Accurate Leads',
         NULL,
         'A public taxpayer-site lead: captured when an anonymous "Fair & Accurate" site visitor asks to be contacted about a specific parcel. Mirrors the shape of an intake record, not a full CRM — the firm''s existing intake process consumes Status/ContactEmail/ParcelID and does the rest. Written by the public API under a restricted, Create-only Role.',
         NULL,
         'FairAndAccurateLead',
         'vwFairAndAccurateLeads',
         'indiana_tax',
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

/* SQL generated to add new entity Fair And Accurate Leads to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '8c1e3f25-daa3-4c9a-8eee-172fba165a33', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Fair And Accurate Leads for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8c1e3f25-daa3-4c9a-8eee-172fba165a33', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Fair And Accurate Leads for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8c1e3f25-daa3-4c9a-8eee-172fba165a33', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Fair And Accurate Leads for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8c1e3f25-daa3-4c9a-8eee-172fba165a33', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to drop default existing default constraints in entity indiana_tax.FairAndAccurateLead */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'FairAndAccurateLead'
AND c.name = '__mj_CreatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[FairAndAccurateLead] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_CreatedAt in entity indiana_tax.FairAndAccurateLead */
ALTER TABLE [indiana_tax].[FairAndAccurateLead] ADD CONSTRAINT [DF_indiana_tax_FairAndAccurateLead___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.FairAndAccurateLead */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'FairAndAccurateLead'
AND c.name = '__mj_UpdatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[FairAndAccurateLead] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_UpdatedAt in entity indiana_tax.FairAndAccurateLead */
ALTER TABLE [indiana_tax].[FairAndAccurateLead] ADD CONSTRAINT [DF_indiana_tax_FairAndAccurateLead___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];

/* SQL text to insert 10 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9bcbefc-9693-4a6c-ae28-c60fad34ba7c' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'ID')) BEGIN
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
            'a9bcbefc-9693-4a6c-ae28-c60fad34ba7c',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9841d180-38b1-4946-bec1-b828ff868ef1' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'ParcelID')) BEGIN
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
            '9841d180-38b1-4946-bec1-b828ff868ef1',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100002,
            'ParcelID',
            'Parcel ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bf460cca-0d30-4740-b871-4d90bd0e2c4c' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'ContactName')) BEGIN
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
            'bf460cca-0d30-4740-b871-4d90bd0e2c4c',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100003,
            'ContactName',
            'Contact Name',
            'The visitor''s self-reported name, taken verbatim from the public site form.',
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
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6d3a420d-957e-4f0a-a049-0855c8156239' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'ContactEmail')) BEGIN
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
            '6d3a420d-957e-4f0a-a049-0855c8156239',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100004,
            'ContactEmail',
            'Contact Email',
            'The visitor''s self-reported email address, taken verbatim from the public site form. The firm''s intake process uses this to follow up.',
            'nvarchar',
            640,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bd4df3bf-0572-418d-94b7-6e25eb2ae354' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'ContactPhone')) BEGIN
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
            'bd4df3bf-0572-418d-94b7-6e25eb2ae354',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100005,
            'ContactPhone',
            'Contact Phone',
            'The visitor''s self-reported phone number, taken verbatim from the public site form. Optional.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6fc7d9d0-083d-43fc-b84e-934aea33c51a' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'Message')) BEGIN
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
            '6fc7d9d0-083d-43fc-b84e-934aea33c51a',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100006,
            'Message',
            'Message',
            'Free-text message the visitor entered on the public site form. Optional.',
            'nvarchar',
            4000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'aaa27dfd-5413-470e-8438-6e5df2409def' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'SubmittedAt')) BEGIN
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
            'aaa27dfd-5413-470e-8438-6e5df2409def',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100007,
            'SubmittedAt',
            'Submitted At',
            'When the public API received this lead. Defaults to the moment of insert; the public API does not set this explicitly.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'sysdatetimeoffset()',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd79ca607-f583-4f77-9534-a4285e488288' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'Status')) BEGIN
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
            'd79ca607-f583-4f77-9534-a4285e488288',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100008,
            'Status',
            'Status',
            'The firm''s intake-pipeline status for this lead. Always inserted as ''new'' by the public API (which has Create-only access); internal staff advance it through the rest of the intake process from the Explorer UI.',
            'nvarchar',
            60,
            0,
            0,
            0,
            'new',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '88408529-e084-4619-84ce-04908d0eb754' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = '__mj_CreatedAt')) BEGIN
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
            '88408529-e084-4619-84ce-04908d0eb754',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100009,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '026ba2f0-4ff5-4d51-a1fb-dd2656ebe460' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '026ba2f0-4ff5-4d51-a1fb-dd2656ebe460',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100010,
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

/* SQL text to insert entity field value with ID 50f1406d-8ce7-47c0-8b74-abf6369b2720 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('50f1406d-8ce7-47c0-8b74-abf6369b2720', 'D79CA607-F583-4F77-9534-A4285E488288', 1, 'contacted', 'contacted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID fcfb3daa-3998-4158-ba17-75903c87c078 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fcfb3daa-3998-4158-ba17-75903c87c078', 'D79CA607-F583-4F77-9534-A4285E488288', 2, 'converted', 'converted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3972e2ad-ce3e-4aed-8116-1531d310622b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3972e2ad-ce3e-4aed-8116-1531d310622b', 'D79CA607-F583-4F77-9534-A4285E488288', 3, 'disqualified', 'disqualified', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3ea251c2-ac2b-41fe-8621-1738cf96aa08 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3ea251c2-ac2b-41fe-8621-1738cf96aa08', 'D79CA607-F583-4F77-9534-A4285E488288', 4, 'new', 'new', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c53f8823-afdd-4490-8019-8a523c768472 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c53f8823-afdd-4490-8019-8a523c768472', 'D79CA607-F583-4F77-9534-A4285E488288', 5, 'qualified', 'qualified', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID D79CA607-F583-4F77-9534-A4285E488288 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='D79CA607-F583-4F77-9534-A4285E488288';


/* Create Entity Relationship: Parcels -> Fair And Accurate Leads (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '7a5e363d-fcd8-4450-a2e0-9a8329259d75'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7a5e363d-fcd8-4450-a2e0-9a8329259d75', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', 'ParcelID', 'One To Many', 1, 1, 29, GETUTCDATE(), GETUTCDATE())
   END;

/* Index for Foreign Keys for FairAndAccurateLead */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table FairAndAccurateLead
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_FairAndAccurateLead_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[FairAndAccurateLead]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_FairAndAccurateLead_ParcelID ON [indiana_tax].[FairAndAccurateLead] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 9841D180-38B1-4946-BEC1-B828FF868EF1 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9841D180-38B1-4946-BEC1-B828FF868EF1', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Fair And Accurate Leads */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: vwFairAndAccurateLeads
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Fair And Accurate Leads
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  FairAndAccurateLead
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwFairAndAccurateLeads]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwFairAndAccurateLeads];
GO

CREATE VIEW [indiana_tax].[vwFairAndAccurateLeads]
AS
SELECT
    f.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[FairAndAccurateLead] AS f
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [f].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwFairAndAccurateLeads] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Fair And Accurate Leads */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: Permissions for vwFairAndAccurateLeads
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwFairAndAccurateLeads] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Fair And Accurate Leads */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: spCreateFairAndAccurateLead
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR FairAndAccurateLead
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateFairAndAccurateLead]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateFairAndAccurateLead];
GO

CREATE PROCEDURE [indiana_tax].[spCreateFairAndAccurateLead]
    @ID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier,
    @ContactName nvarchar(200),
    @ContactEmail nvarchar(320),
    @ContactPhone_Clear bit = 0,
    @ContactPhone nvarchar(30) = NULL,
    @Message_Clear bit = 0,
    @Message nvarchar(2000) = NULL,
    @SubmittedAt datetimeoffset = NULL,
    @Status nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[FairAndAccurateLead]
            (
                [ID],
                [ParcelID],
                [ContactName],
                [ContactEmail],
                [ContactPhone],
                [Message],
                [SubmittedAt],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ParcelID,
                @ContactName,
                @ContactEmail,
                CASE WHEN @ContactPhone_Clear = 1 THEN NULL ELSE ISNULL(@ContactPhone, NULL) END,
                CASE WHEN @Message_Clear = 1 THEN NULL ELSE ISNULL(@Message, NULL) END,
                ISNULL(@SubmittedAt, sysdatetimeoffset()),
                ISNULL(@Status, 'new')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[FairAndAccurateLead]
            (
                [ParcelID],
                [ContactName],
                [ContactEmail],
                [ContactPhone],
                [Message],
                [SubmittedAt],
                [Status]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ParcelID,
                @ContactName,
                @ContactEmail,
                CASE WHEN @ContactPhone_Clear = 1 THEN NULL ELSE ISNULL(@ContactPhone, NULL) END,
                CASE WHEN @Message_Clear = 1 THEN NULL ELSE ISNULL(@Message, NULL) END,
                ISNULL(@SubmittedAt, sysdatetimeoffset()),
                ISNULL(@Status, 'new')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwFairAndAccurateLeads] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Fair And Accurate Leads */

GRANT EXECUTE ON [indiana_tax].[spCreateFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Fair And Accurate Leads */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: spUpdateFairAndAccurateLead
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR FairAndAccurateLead
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateFairAndAccurateLead]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateFairAndAccurateLead];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateFairAndAccurateLead]
    @ID uniqueidentifier,
    @ParcelID uniqueidentifier = NULL,
    @ContactName nvarchar(200) = NULL,
    @ContactEmail nvarchar(320) = NULL,
    @ContactPhone_Clear bit = 0,
    @ContactPhone nvarchar(30) = NULL,
    @Message_Clear bit = 0,
    @Message nvarchar(2000) = NULL,
    @SubmittedAt datetimeoffset = NULL,
    @Status nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[FairAndAccurateLead]
    SET
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [ContactName] = ISNULL(@ContactName, [ContactName]),
        [ContactEmail] = ISNULL(@ContactEmail, [ContactEmail]),
        [ContactPhone] = CASE WHEN @ContactPhone_Clear = 1 THEN NULL ELSE ISNULL(@ContactPhone, [ContactPhone]) END,
        [Message] = CASE WHEN @Message_Clear = 1 THEN NULL ELSE ISNULL(@Message, [Message]) END,
        [SubmittedAt] = ISNULL(@SubmittedAt, [SubmittedAt]),
        [Status] = ISNULL(@Status, [Status])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwFairAndAccurateLeads] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwFairAndAccurateLeads]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the FairAndAccurateLead table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateFairAndAccurateLead]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateFairAndAccurateLead];
GO
CREATE TRIGGER [indiana_tax].trgUpdateFairAndAccurateLead
ON [indiana_tax].[FairAndAccurateLead]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[FairAndAccurateLead]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[FairAndAccurateLead] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Fair And Accurate Leads */

GRANT EXECUTE ON [indiana_tax].[spUpdateFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Fair And Accurate Leads */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Fair And Accurate Leads
-- Item: spDeleteFairAndAccurateLead
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR FairAndAccurateLead
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteFairAndAccurateLead]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteFairAndAccurateLead];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteFairAndAccurateLead]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[FairAndAccurateLead]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Fair And Accurate Leads */

GRANT EXECUTE ON [indiana_tax].[spDeleteFairAndAccurateLead] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 1 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5d47eccc-31d5-469a-a602-9d5531ed745c' OR (EntityID = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33' AND Name = 'Parcel')) BEGIN
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
            '5d47eccc-31d5-469a-a602-9d5531ed745c',
            '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', -- Entity: Fair And Accurate Leads
            100021,
            'Parcel',
            'Parcel',
            NULL,
            'nvarchar',
            60,
            0,
            0,
            0,
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

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'BF460CCA-0D30-4740-B871-4D90BD0E2C4C'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'BF460CCA-0D30-4740-B871-4D90BD0E2C4C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6D3A420D-957E-4F0A-A049-0855C8156239'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'AAA27DFD-5413-470E-8438-6E5DF2409DEF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D79CA607-F583-4F77-9534-A4285E488288'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'BF460CCA-0D30-4740-B871-4D90BD0E2C4C'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6D3A420D-957E-4F0A-A049-0855C8156239'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'BD4DF3BF-0572-418D-94B7-6E25EB2AE354'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'BF460CCA-0D30-4740-B871-4D90BD0E2C4C'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '6D3A420D-957E-4F0A-A049-0855C8156239'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'BD4DF3BF-0572-418D-94B7-6E25EB2AE354'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 11 fields */

-- UPDATE Entity Field Category Info Fair And Accurate Leads.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A9BCBEFC-9693-4A6C-AE28-C60FAD34BA7C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9841D180-38B1-4946-BEC1-B828FF868EF1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Details',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5D47ECCC-31D5-469A-A602-9D5531ED745C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.ContactName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Visitor Contact Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BF460CCA-0D30-4740-B871-4D90BD0E2C4C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.ContactEmail 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Visitor Contact Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Email',
   CodeType = NULL
WHERE 
   ID = '6D3A420D-957E-4F0A-A049-0855C8156239' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.ContactPhone 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Visitor Contact Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Tel',
   CodeType = NULL
WHERE 
   ID = 'BD4DF3BF-0572-418D-94B7-6E25EB2AE354' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.Message 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Lead Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6FC7D9D0-083D-43FC-B84E-934AEA33C51A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.Status 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Lead Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D79CA607-F583-4F77-9534-A4285E488288' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.SubmittedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Lead Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AAA27DFD-5413-470E-8438-6E5DF2409DEF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '88408529-E084-4619-84CE-04908D0EB754' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Fair And Accurate Leads.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '026BA2F0-4FF5-4D51-A1FB-DD2656EBE460' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-envelope */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-envelope', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('46af23f4-c508-418b-8371-829b33a51346', '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', 'FieldCategoryInfo', '{"Property Information":{"icon":"fa fa-home","description":"Identifies the specific parcel or property the visitor is inquiring about"},"Visitor Contact Information":{"icon":"fa fa-address-card","description":"The visitor''s name, email, and phone number for follow-up contact"},"Lead Details":{"icon":"fa fa-inbox","description":"Inquiry message, status tracking, and submission timestamp"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('a78def5c-57a0-4fbe-b96c-801a1bd5ccde', '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33', 'FieldCategoryIcons', '{"Property Information":"fa fa-home","Visitor Contact Information":"fa fa-address-card","Lead Details":"fa fa-inbox","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '8C1E3F25-DAA3-4C9A-8EEE-172FBA165A33';

