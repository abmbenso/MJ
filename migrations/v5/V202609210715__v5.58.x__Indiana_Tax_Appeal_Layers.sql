/* ============================================================================
   Indiana Property Tax Expert -- appeal layers for Property Search
   v5.58.x   (design: Indiana_Tax_Expert/docs/proposals/multi-county-ci-intake.md §12)

   1. IBTRAppeal.ParcelMatchMethod -- how ParcelID was resolved. The first match
      was the 18-digit state number only (1,903 of 10,249). A second pass matches
      the docketed number to Parcel.GISParcelNumber inside the same county, unique
      keys only; the method travels with the link so a local-number match is never
      mistaken for a state-number match.
   2. TaxCourtCase / TaxCourtIBTRLink -- the Indiana Tax Court catalog
      (~/Projects/Indiana_Tax_Court, data-flow register row 18) and its candidate
      links to the Board determinations a case reviews. Opinions do not print the
      petition number: a link is county + taxpayer-name similarity + a decision date
      0-75 days before filing. NameScore travels with every link; Property Search
      flags a parcel only at NameScore >= 0.95. A link is a lead, never a holding.
   ============================================================================ */

ALTER TABLE indiana_tax.IBTRAppeal ADD ParcelMatchMethod NVARCHAR(30) NULL;
GO
UPDATE indiana_tax.IBTRAppeal SET ParcelMatchMethod = N'StateParcel18' WHERE ParcelID IS NOT NULL;
GO
ALTER TABLE indiana_tax.IBTRAppeal ADD
    CONSTRAINT CK_IBTRAppeal_ParcelMatchMethod CHECK (ParcelMatchMethod IS NULL OR ParcelMatchMethod IN (N'StateParcel18', N'CountyLocalNumber')),
    CONSTRAINT CK_IBTRAppeal_ParcelMatchPair CHECK ((ParcelID IS NULL AND ParcelMatchMethod IS NULL) OR (ParcelID IS NOT NULL AND ParcelMatchMethod IS NOT NULL));
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'How ParcelID was resolved: StateParcel18 (the docketed number normalises to an 18-digit state parcel number held in Parcel.ParcelNumber) or CountyLocalNumber (its digits equal Parcel.GISParcelNumber inside the same county, and that key is unique there). NULL exactly when ParcelID is NULL. indiana_tax.Parcel is C&I only, so most residential appeals match nothing by design.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'ParcelMatchMethod';
GO
EXEC sp_updateextendedproperty @name=N'MS_Description', @value=N'indiana_tax.Parcel resolved from the docketed parcel number; see ParcelMatchMethod for how. NULL when the number matches no C&I parcel.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'ParcelID';
GO

CREATE TABLE indiana_tax.TaxCourtCase (
    ID                 UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    DocketNumber       NVARCHAR(40)     NOT NULL,
    CaseName           NVARCHAR(500)    NOT NULL,
    DateFiled          DATE             NULL,
    TaxCategory        NVARCHAR(60)     NULL,
    DecisionCount      INT              NOT NULL DEFAULT 0,
    FirstDecisionDate  DATE             NULL,
    LastDecisionDate   DATE             NULL,
    Dispositions       NVARCHAR(300)    NULL,
    OpinionURL         NVARCHAR(1000)   NULL,
    CONSTRAINT PK_TaxCourtCase PRIMARY KEY (ID),
    CONSTRAINT UQ_TaxCourtCase_DocketNumber UNIQUE (DocketNumber)
);
GO
CREATE TABLE indiana_tax.TaxCourtIBTRLink (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    TaxCourtCaseID    UNIQUEIDENTIFIER NOT NULL,
    IBTRAppealID      UNIQUEIDENTIFIER NOT NULL,
    NameScore         DECIMAL(4,3)     NOT NULL,
    DaysBeforeFiling  INT              NULL,
    MatchMethod       NVARCHAR(40)     NOT NULL,
    IsConfirmed       BIT              NULL,
    CONSTRAINT PK_TaxCourtIBTRLink PRIMARY KEY (ID),
    CONSTRAINT UQ_TaxCourtIBTRLink_Case_Appeal UNIQUE (TaxCourtCaseID, IBTRAppealID),
    CONSTRAINT FK_TaxCourtIBTRLink_Case FOREIGN KEY (TaxCourtCaseID) REFERENCES indiana_tax.TaxCourtCase(ID),
    CONSTRAINT FK_TaxCourtIBTRLink_Appeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT CK_TaxCourtIBTRLink_NameScore CHECK (NameScore >= 0 AND NameScore <= 1)
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One Indiana Tax Court case (docket) from the Indiana_Tax_Court catalog (catalog/cases.csv): every tax type, 1986 onward. Loaded whole so a docket can be looked up; only real-property cases link to Board determinations. Full rebuild on every load.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Normalised docket number, e.g. 49T10-1405-TA-00019. Unique.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'DocketNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Caption as catalogued (petitioner v. respondent).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'CaseName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Filing date from the Tax Court filing list; NULL for cases known only from a published opinion.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'DateFiled';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Tax type as catalogued (Real property, Sales & Use, Income, Personal property, ...).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'TaxCategory';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Number of catalogued decisions (opinions and orders) in the case.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'DecisionCount';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the earliest catalogued decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'FirstDecisionDate';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the latest catalogued decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'LastDecisionDate';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Disposition(s) as catalogued, semicolon-separated when a case has several decisions.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'Dispositions';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Public URL of the latest decision: the court portal opinion where held, else CourtListener.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtCase', @level2type=N'COLUMN', @level2name=N'OpinionURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A candidate link from a Tax Court case to an IBTR disposition it reviews (Indiana_Tax_Court/data/extracted/ibtr_links.csv). Many-to-many by design: a consolidated appeal reviews several petitions. Unconfirmed name matches -- Property Search flags a parcel only at NameScore >= 0.95, and shows lower scores as candidates. Full rebuild on every load; rebuilt after any IBTRAppeal rebuild.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The Tax Court case.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'TaxCourtCaseID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The IBTR disposition the case is a candidate review of.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Similarity (0-1) between the taxpayer as filed in the Tax Court and the IBTR petitioner; 1.000 = identical after normalisation.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'NameScore';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Days between the IBTR decision and the Tax Court filing (0-75; IC 6-1.1-15-5 allows 45).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'DaysBeforeFiling';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'How the candidate was found, e.g. PetitionerCountyDate.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'MatchMethod';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 when a person confirmed the link, 0 when rejected, NULL when unreviewed (all rows at first load).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'TaxCourtIBTRLink', @level2type=N'COLUMN', @level2name=N'IsConfirmed';
GO


















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   EntityField inserts, regenerated views, spCreate/spUpdate/spDelete procedures,
   permission grants and extended properties for TaxCourtCase, TaxCourtIBTRLink
   and the altered IBTRAppeal.
   DO NOT EDIT BY HAND. If the DDL above changes, re-run CodeGen and replace this section.
   ============================================================================ */

/* SQL generated to create new entity Tax Court Cases */

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
         'c3f033ea-4df0-4717-9d94-ee5c0334d9bc',
         'Tax Court Cases',
         NULL,
         'One Indiana Tax Court case (docket) from the Indiana_Tax_Court catalog (catalog/cases.csv): every tax type, 1986 onward. Loaded whole so a docket can be looked up; only real-property cases link to Board determinations. Full rebuild on every load.',
         NULL,
         'TaxCourtCase',
         'vwTaxCourtCases',
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

/* SQL generated to add new entity Tax Court Cases to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', 'c3f033ea-4df0-4717-9d94-ee5c0334d9bc', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court Cases for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c3f033ea-4df0-4717-9d94-ee5c0334d9bc', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court Cases for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c3f033ea-4df0-4717-9d94-ee5c0334d9bc', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court Cases for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('c3f033ea-4df0-4717-9d94-ee5c0334d9bc', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Tax Court IBTR Links */

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
         'f49320d2-bf8c-43ee-bd8a-1932ef984375',
         'Tax Court IBTR Links',
         NULL,
         'A candidate link from a Tax Court case to an IBTR disposition it reviews (Indiana_Tax_Court/data/extracted/ibtr_links.csv). Many-to-many by design: a consolidated appeal reviews several petitions. Unconfirmed name matches -- Property Search flags a parcel only at NameScore >= 0.95, and shows lower scores as candidates. Full rebuild on every load; rebuilt after any IBTRAppeal rebuild.',
         NULL,
         'TaxCourtIBTRLink',
         'vwTaxCourtIBTRLinks',
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

/* SQL generated to add new entity Tax Court IBTR Links to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', 'f49320d2-bf8c-43ee-bd8a-1932ef984375', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court IBTR Links for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f49320d2-bf8c-43ee-bd8a-1932ef984375', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court IBTR Links for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f49320d2-bf8c-43ee-bd8a-1932ef984375', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Tax Court IBTR Links for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('f49320d2-bf8c-43ee-bd8a-1932ef984375', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtIBTRLink */
UPDATE [indiana_tax].[TaxCourtIBTRLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ADD CONSTRAINT [DF_indiana_tax_TaxCourtIBTRLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtIBTRLink */
UPDATE [indiana_tax].[TaxCourtIBTRLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtIBTRLink */
ALTER TABLE [indiana_tax].[TaxCourtIBTRLink] ADD CONSTRAINT [DF_indiana_tax_TaxCourtIBTRLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtCase */
UPDATE [indiana_tax].[TaxCourtCase] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ADD CONSTRAINT [DF_indiana_tax_TaxCourtCase___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtCase */
UPDATE [indiana_tax].[TaxCourtCase] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.TaxCourtCase */
ALTER TABLE [indiana_tax].[TaxCourtCase] ADD CONSTRAINT [DF_indiana_tax_TaxCourtCase___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 22 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1e128d61-2727-4f1b-a394-afd2952de071' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'ID')) BEGIN
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
            '1e128d61-2727-4f1b-a394-afd2952de071',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'da12cf84-2d1a-4e7c-a74e-b0702e7d7f46' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'TaxCourtCaseID')) BEGIN
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
            'da12cf84-2d1a-4e7c-a74e-b0702e7d7f46',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100002,
            'TaxCourtCaseID',
            'Tax Court Case ID',
            'The Tax Court case.',
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
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '96ecbf07-b741-4d25-b969-8b9edf9e02f6' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'IBTRAppealID')) BEGIN
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
            '96ecbf07-b741-4d25-b969-8b9edf9e02f6',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100003,
            'IBTRAppealID',
            'IBTR Appeal ID',
            'The IBTR disposition the case is a candidate review of.',
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
            '476A4E53-E135-4FEB-8D25-2385C741544F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a272cd46-d769-47b5-aaa5-c71defeb2f28' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'NameScore')) BEGIN
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
            'a272cd46-d769-47b5-aaa5-c71defeb2f28',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100004,
            'NameScore',
            'Name Score',
            'Similarity (0-1) between the taxpayer as filed in the Tax Court and the IBTR petitioner; 1.000 = identical after normalisation.',
            'decimal',
            5,
            4,
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '00a851a8-fecc-4579-9047-6858e58fdd06' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'DaysBeforeFiling')) BEGIN
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
            '00a851a8-fecc-4579-9047-6858e58fdd06',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100005,
            'DaysBeforeFiling',
            'Days Before Filing',
            'Days between the IBTR decision and the Tax Court filing (0-75; IC 6-1.1-15-5 allows 45).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4d090099-51c7-40ee-bcbc-600ae3d06c37' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'MatchMethod')) BEGIN
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
            '4d090099-51c7-40ee-bcbc-600ae3d06c37',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100006,
            'MatchMethod',
            'Match Method',
            'How the candidate was found, e.g. PetitionerCountyDate.',
            'nvarchar',
            80,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8831df0d-17f3-470b-a2a3-6ec942f2af82' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = 'IsConfirmed')) BEGIN
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
            '8831df0d-17f3-470b-a2a3-6ec942f2af82',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100007,
            'IsConfirmed',
            'Is Confirmed',
            '1 when a person confirmed the link, 0 when rejected, NULL when unreviewed (all rows at first load).',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'be15cbd3-6601-4412-acf0-e2d090665e75' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = '__mj_CreatedAt')) BEGIN
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
            'be15cbd3-6601-4412-acf0-e2d090665e75',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100008,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c10339b4-619f-4652-b343-d23b1d012d32' OR (EntityID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'c10339b4-619f-4652-b343-d23b1d012d32',
            'F49320D2-BF8C-43EE-BD8A-1932EF984375', -- Entity: Tax Court IBTR Links
            100009,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6bdedb8c-94eb-471d-9f1d-2eb501a7fb3b' OR (EntityID = '476A4E53-E135-4FEB-8D25-2385C741544F' AND Name = 'ParcelMatchMethod')) BEGIN
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
            '6bdedb8c-94eb-471d-9f1d-2eb501a7fb3b',
            '476A4E53-E135-4FEB-8D25-2385C741544F', -- Entity: IBTR Appeals
            100068,
            'ParcelMatchMethod',
            'Parcel Match Method',
            'How ParcelID was resolved: StateParcel18 (the docketed number normalises to an 18-digit state parcel number held in Parcel.ParcelNumber) or CountyLocalNumber (its digits equal Parcel.GISParcelNumber inside the same county, and that key is unique there). NULL exactly when ParcelID is NULL. indiana_tax.Parcel is C&I only, so most residential appeals match nothing by design.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1089431e-8c90-4d22-ad25-883283019b15' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'ID')) BEGIN
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
            '1089431e-8c90-4d22-ad25-883283019b15',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f0dc9c65-415f-44bf-9058-2782609c2339' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'DocketNumber')) BEGIN
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
            'f0dc9c65-415f-44bf-9058-2782609c2339',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100002,
            'DocketNumber',
            'Docket Number',
            'Normalised docket number, e.g. 49T10-1405-TA-00019. Unique.',
            'nvarchar',
            80,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '40bfa7eb-8427-4235-85f4-c60c62aef951' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'CaseName')) BEGIN
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
            '40bfa7eb-8427-4235-85f4-c60c62aef951',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100003,
            'CaseName',
            'Case Name',
            'Caption as catalogued (petitioner v. respondent).',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f7828d5a-2b5b-4c63-8364-1c40b3419564' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'DateFiled')) BEGIN
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
            'f7828d5a-2b5b-4c63-8364-1c40b3419564',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100004,
            'DateFiled',
            'Date Filed',
            'Filing date from the Tax Court filing list; NULL for cases known only from a published opinion.',
            'date',
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'accb802b-9890-4722-8e50-ddcff1a7758e' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'TaxCategory')) BEGIN
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
            'accb802b-9890-4722-8e50-ddcff1a7758e',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100005,
            'TaxCategory',
            'Tax Category',
            'Tax type as catalogued (Real property, Sales & Use, Income, Personal property, ...).',
            'nvarchar',
            120,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8f210265-2781-44ad-ac87-a6d9cc56dd05' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'DecisionCount')) BEGIN
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
            '8f210265-2781-44ad-ac87-a6d9cc56dd05',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100006,
            'DecisionCount',
            'Decision Count',
            'Number of catalogued decisions (opinions and orders) in the case.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e45eadce-3dda-4eac-8035-91c7375e326b' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'FirstDecisionDate')) BEGIN
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
            'e45eadce-3dda-4eac-8035-91c7375e326b',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100007,
            'FirstDecisionDate',
            'First Decision Date',
            'Date of the earliest catalogued decision.',
            'date',
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3eea9859-c631-4f39-b0ba-3153007c4cfa' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'LastDecisionDate')) BEGIN
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
            '3eea9859-c631-4f39-b0ba-3153007c4cfa',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100008,
            'LastDecisionDate',
            'Last Decision Date',
            'Date of the latest catalogued decision.',
            'date',
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b732d03c-c68a-4285-8102-cd9f693302e5' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'Dispositions')) BEGIN
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
            'b732d03c-c68a-4285-8102-cd9f693302e5',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100009,
            'Dispositions',
            'Dispositions',
            'Disposition(s) as catalogued, semicolon-separated when a case has several decisions.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1be82280-ba3a-4a93-bc99-62d0e6bbc462' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = 'OpinionURL')) BEGIN
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
            '1be82280-ba3a-4a93-bc99-62d0e6bbc462',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100010,
            'OpinionURL',
            'Opinion URL',
            'Public URL of the latest decision: the court portal opinion where held, else CourtListener.',
            'nvarchar',
            2000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '803a7208-7fa2-4889-87cd-9b1df4c3ed0d' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = '__mj_CreatedAt')) BEGIN
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
            '803a7208-7fa2-4889-87cd-9b1df4c3ed0d',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100011,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0e45a4aa-1215-4feb-b733-522b903df106' OR (EntityID = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '0e45a4aa-1215-4feb-b733-522b903df106',
            'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', -- Entity: Tax Court Cases
            100012,
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

/* SQL text to insert entity field value with ID 01ae51f3-b45d-4db3-9d70-858508dd8ead */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('01ae51f3-b45d-4db3-9d70-858508dd8ead', '6BDEDB8C-94EB-471D-9F1D-2EB501A7FB3B', 1, 'CountyLocalNumber', 'CountyLocalNumber', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b2f37b6a-bb67-42f9-a904-e345259752d3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b2f37b6a-bb67-42f9-a904-e345259752d3', '6BDEDB8C-94EB-471D-9F1D-2EB501A7FB3B', 2, 'StateParcel18', 'StateParcel18', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 6BDEDB8C-94EB-471D-9F1D-2EB501A7FB3B */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='6BDEDB8C-94EB-471D-9F1D-2EB501A7FB3B';


/* Create Entity Relationship: IBTR Appeals -> Tax Court IBTR Links (One To Many via IBTRAppealID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '8c543b5f-8ede-4581-9c76-107edd4af457'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8c543b5f-8ede-4581-9c76-107edd4af457', '476A4E53-E135-4FEB-8D25-2385C741544F', 'F49320D2-BF8C-43EE-BD8A-1932EF984375', 'IBTRAppealID', 'One To Many', 1, 1, 6, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Tax Court Cases -> Tax Court IBTR Links (One To Many via TaxCourtCaseID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'c3d94e00-eb76-49c9-b76b-95de5dbc5f48'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c3d94e00-eb76-49c9-b76b-95de5dbc5f48', 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', 'F49320D2-BF8C-43EE-BD8A-1932EF984375', 'TaxCourtCaseID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to update virtual entity field UnverifiedCompCount for entity Store Analysis */
UPDATE
                                    [${flyway:defaultSchema}].[EntityField]
                                  SET
                                    Sequence=70,
                                    Type='int',
                                    AllowsNull=1,
                                    
                                    Length=4,
                                    Precision=10,
                                    Scale=0
                                  WHERE
                                    ID = '377D324C-20CB-4A76-AB06-CB439830F01E';

/* Index for Foreign Keys for IBTRAppeal */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_ParcelID ON [indiana_tax].[IBTRAppeal] ([ParcelID]);

-- Index for foreign key SourceDocumentID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_SourceDocumentID ON [indiana_tax].[IBTRAppeal] ([SourceDocumentID]);

-- Index for foreign key LegacyBoardDecisionID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_LegacyBoardDecisionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_LegacyBoardDecisionID ON [indiana_tax].[IBTRAppeal] ([LegacyBoardDecisionID]);

/* Base View SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: vwIBTRAppeals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      IBTR Appeals
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  IBTRAppeal
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwIBTRAppeals]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwIBTRAppeals];
GO

CREATE VIEW [indiana_tax].[vwIBTRAppeals]
AS
SELECT
    i.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    indianataxBoardDecision_LegacyBoardDecisionID.[CaseNumber] AS [LegacyBoardDecision]
FROM
    [indiana_tax].[IBTRAppeal] AS i
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [i].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[BoardDecision] AS indianataxBoardDecision_LegacyBoardDecisionID
  ON
    [i].[LegacyBoardDecisionID] = indianataxBoardDecision_LegacyBoardDecisionID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwIBTRAppeals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: Permissions for vwIBTRAppeals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwIBTRAppeals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spCreateIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spCreateIBTRAppeal]
    @ID uniqueidentifier = NULL,
    @POPLARAppealID int,
    @PetitionNumber nvarchar(200),
    @PetitionerName_Clear bit = 0,
    @PetitionerName nvarchar(300) = NULL,
    @CountyNumber_Clear bit = 0,
    @CountyNumber smallint = NULL,
    @CountyName_Clear bit = 0,
    @CountyName nvarchar(50) = NULL,
    @TownshipName_Clear bit = 0,
    @TownshipName nvarchar(100) = NULL,
    @StateParcelNumber_Clear bit = 0,
    @StateParcelNumber nvarchar(60) = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @LocationAddress_Clear bit = 0,
    @LocationAddress nvarchar(300) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @AppealType_Clear bit = 0,
    @AppealType nvarchar(20) = NULL,
    @DateReceived_Clear bit = 0,
    @DateReceived date = NULL,
    @DecisionDate_Clear bit = 0,
    @DecisionDate date = NULL,
    @DispositionType nvarchar(40),
    @HearingOfficer_Clear bit = 0,
    @HearingOfficer nvarchar(100) = NULL,
    @YearFiled_Clear bit = 0,
    @YearFiled smallint = NULL,
    @StatusName_Clear bit = 0,
    @StatusName nvarchar(30) = NULL,
    @IssuesPhrase_Clear bit = 0,
    @IssuesPhrase nvarchar(500) = NULL,
    @IsSmallClaims_Clear bit = 0,
    @IsSmallClaims bit = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TextChars_Clear bit = 0,
    @TextChars int = NULL,
    @TextIsOCR_Clear bit = 0,
    @TextIsOCR bit = NULL,
    @ExtractionStatus nvarchar(20) = NULL,
    @ModelConfidence_Clear bit = 0,
    @ModelConfidence nvarchar(10) = NULL,
    @Summary_Clear bit = 0,
    @Summary nvarchar(MAX) = NULL,
    @KeyReasoning_Clear bit = 0,
    @KeyReasoning nvarchar(MAX) = NULL,
    @PropertyType_Clear bit = 0,
    @PropertyType nvarchar(300) = NULL,
    @UseCategory_Clear bit = 0,
    @UseCategory nvarchar(40) = NULL,
    @LegacyBoardDecisionID_Clear bit = 0,
    @LegacyBoardDecisionID uniqueidentifier = NULL,
    @ParcelMatchMethod_Clear bit = 0,
    @ParcelMatchMethod nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[IBTRAppeal]
            (
                [ID],
                [POPLARAppealID],
                [PetitionNumber],
                [PetitionerName],
                [CountyNumber],
                [CountyName],
                [TownshipName],
                [StateParcelNumber],
                [ParcelID],
                [LocationAddress],
                [AssessmentYear],
                [AppealType],
                [DateReceived],
                [DecisionDate],
                [DispositionType],
                [HearingOfficer],
                [YearFiled],
                [StatusName],
                [IssuesPhrase],
                [IsSmallClaims],
                [SourceDocumentID],
                [TextChars],
                [TextIsOCR],
                [ExtractionStatus],
                [ModelConfidence],
                [Summary],
                [KeyReasoning],
                [PropertyType],
                [UseCategory],
                [LegacyBoardDecisionID],
                [ParcelMatchMethod]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @POPLARAppealID,
                @PetitionNumber,
                CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, NULL) END,
                CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, NULL) END,
                CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, NULL) END,
                CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, NULL) END,
                CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, NULL) END,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, NULL) END,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, NULL) END,
                CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, NULL) END,
                CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, NULL) END,
                @DispositionType,
                CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, NULL) END,
                CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, NULL) END,
                CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, NULL) END,
                CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, NULL) END,
                CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, NULL) END,
                CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, NULL) END,
                ISNULL(@ExtractionStatus, 'None'),
                CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, NULL) END,
                CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, NULL) END,
                CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, NULL) END,
                CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, NULL) END,
                CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, NULL) END,
                CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, NULL) END,
                CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[IBTRAppeal]
            (
                [POPLARAppealID],
                [PetitionNumber],
                [PetitionerName],
                [CountyNumber],
                [CountyName],
                [TownshipName],
                [StateParcelNumber],
                [ParcelID],
                [LocationAddress],
                [AssessmentYear],
                [AppealType],
                [DateReceived],
                [DecisionDate],
                [DispositionType],
                [HearingOfficer],
                [YearFiled],
                [StatusName],
                [IssuesPhrase],
                [IsSmallClaims],
                [SourceDocumentID],
                [TextChars],
                [TextIsOCR],
                [ExtractionStatus],
                [ModelConfidence],
                [Summary],
                [KeyReasoning],
                [PropertyType],
                [UseCategory],
                [LegacyBoardDecisionID],
                [ParcelMatchMethod]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @POPLARAppealID,
                @PetitionNumber,
                CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, NULL) END,
                CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, NULL) END,
                CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, NULL) END,
                CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, NULL) END,
                CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, NULL) END,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, NULL) END,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, NULL) END,
                CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, NULL) END,
                CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, NULL) END,
                @DispositionType,
                CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, NULL) END,
                CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, NULL) END,
                CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, NULL) END,
                CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, NULL) END,
                CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, NULL) END,
                CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, NULL) END,
                ISNULL(@ExtractionStatus, 'None'),
                CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, NULL) END,
                CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, NULL) END,
                CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, NULL) END,
                CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, NULL) END,
                CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, NULL) END,
                CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, NULL) END,
                CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwIBTRAppeals] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spCreateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spUpdateIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateIBTRAppeal]
    @ID uniqueidentifier,
    @POPLARAppealID int = NULL,
    @PetitionNumber nvarchar(200) = NULL,
    @PetitionerName_Clear bit = 0,
    @PetitionerName nvarchar(300) = NULL,
    @CountyNumber_Clear bit = 0,
    @CountyNumber smallint = NULL,
    @CountyName_Clear bit = 0,
    @CountyName nvarchar(50) = NULL,
    @TownshipName_Clear bit = 0,
    @TownshipName nvarchar(100) = NULL,
    @StateParcelNumber_Clear bit = 0,
    @StateParcelNumber nvarchar(60) = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @LocationAddress_Clear bit = 0,
    @LocationAddress nvarchar(300) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @AppealType_Clear bit = 0,
    @AppealType nvarchar(20) = NULL,
    @DateReceived_Clear bit = 0,
    @DateReceived date = NULL,
    @DecisionDate_Clear bit = 0,
    @DecisionDate date = NULL,
    @DispositionType nvarchar(40) = NULL,
    @HearingOfficer_Clear bit = 0,
    @HearingOfficer nvarchar(100) = NULL,
    @YearFiled_Clear bit = 0,
    @YearFiled smallint = NULL,
    @StatusName_Clear bit = 0,
    @StatusName nvarchar(30) = NULL,
    @IssuesPhrase_Clear bit = 0,
    @IssuesPhrase nvarchar(500) = NULL,
    @IsSmallClaims_Clear bit = 0,
    @IsSmallClaims bit = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TextChars_Clear bit = 0,
    @TextChars int = NULL,
    @TextIsOCR_Clear bit = 0,
    @TextIsOCR bit = NULL,
    @ExtractionStatus nvarchar(20) = NULL,
    @ModelConfidence_Clear bit = 0,
    @ModelConfidence nvarchar(10) = NULL,
    @Summary_Clear bit = 0,
    @Summary nvarchar(MAX) = NULL,
    @KeyReasoning_Clear bit = 0,
    @KeyReasoning nvarchar(MAX) = NULL,
    @PropertyType_Clear bit = 0,
    @PropertyType nvarchar(300) = NULL,
    @UseCategory_Clear bit = 0,
    @UseCategory nvarchar(40) = NULL,
    @LegacyBoardDecisionID_Clear bit = 0,
    @LegacyBoardDecisionID uniqueidentifier = NULL,
    @ParcelMatchMethod_Clear bit = 0,
    @ParcelMatchMethod nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRAppeal]
    SET
        [POPLARAppealID] = ISNULL(@POPLARAppealID, [POPLARAppealID]),
        [PetitionNumber] = ISNULL(@PetitionNumber, [PetitionNumber]),
        [PetitionerName] = CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, [PetitionerName]) END,
        [CountyNumber] = CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, [CountyNumber]) END,
        [CountyName] = CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, [CountyName]) END,
        [TownshipName] = CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, [TownshipName]) END,
        [StateParcelNumber] = CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, [StateParcelNumber]) END,
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [LocationAddress] = CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, [LocationAddress]) END,
        [AssessmentYear] = CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, [AssessmentYear]) END,
        [AppealType] = CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, [AppealType]) END,
        [DateReceived] = CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, [DateReceived]) END,
        [DecisionDate] = CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, [DecisionDate]) END,
        [DispositionType] = ISNULL(@DispositionType, [DispositionType]),
        [HearingOfficer] = CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, [HearingOfficer]) END,
        [YearFiled] = CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, [YearFiled]) END,
        [StatusName] = CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, [StatusName]) END,
        [IssuesPhrase] = CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, [IssuesPhrase]) END,
        [IsSmallClaims] = CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, [IsSmallClaims]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [TextChars] = CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, [TextChars]) END,
        [TextIsOCR] = CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, [TextIsOCR]) END,
        [ExtractionStatus] = ISNULL(@ExtractionStatus, [ExtractionStatus]),
        [ModelConfidence] = CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, [ModelConfidence]) END,
        [Summary] = CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, [Summary]) END,
        [KeyReasoning] = CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, [KeyReasoning]) END,
        [PropertyType] = CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, [PropertyType]) END,
        [UseCategory] = CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, [UseCategory]) END,
        [LegacyBoardDecisionID] = CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, [LegacyBoardDecisionID]) END,
        [ParcelMatchMethod] = CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, [ParcelMatchMethod]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwIBTRAppeals] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwIBTRAppeals]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRAppeal] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the IBTRAppeal table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateIBTRAppeal]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateIBTRAppeal];
GO
CREATE TRIGGER [indiana_tax].trgUpdateIBTRAppeal
ON [indiana_tax].[IBTRAppeal]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRAppeal]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[IBTRAppeal] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spDeleteIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteIBTRAppeal]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[IBTRAppeal]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaxCourtCase */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for TaxCourtIBTRLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaxCourtCaseID in table TaxCourtIBTRLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaxCourtIBTRLink_TaxCourtCaseID' 
    AND object_id = OBJECT_ID('[indiana_tax].[TaxCourtIBTRLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaxCourtIBTRLink_TaxCourtCaseID ON [indiana_tax].[TaxCourtIBTRLink] ([TaxCourtCaseID]);

-- Index for foreign key IBTRAppealID in table TaxCourtIBTRLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaxCourtIBTRLink_IBTRAppealID' 
    AND object_id = OBJECT_ID('[indiana_tax].[TaxCourtIBTRLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaxCourtIBTRLink_IBTRAppealID ON [indiana_tax].[TaxCourtIBTRLink] ([IBTRAppealID]);

/* Base View SQL for Tax Court Cases */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: vwTaxCourtCases
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Tax Court Cases
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  TaxCourtCase
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwTaxCourtCases]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwTaxCourtCases];
GO

CREATE VIEW [indiana_tax].[vwTaxCourtCases]
AS
SELECT
    t.*
FROM
    [indiana_tax].[TaxCourtCase] AS t
GO
GRANT SELECT ON [indiana_tax].[vwTaxCourtCases] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Tax Court Cases */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: Permissions for vwTaxCourtCases
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwTaxCourtCases] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Tax Court Cases */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: spCreateTaxCourtCase
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaxCourtCase
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateTaxCourtCase]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateTaxCourtCase];
GO

CREATE PROCEDURE [indiana_tax].[spCreateTaxCourtCase]
    @ID uniqueidentifier = NULL,
    @DocketNumber nvarchar(40),
    @CaseName nvarchar(500),
    @DateFiled_Clear bit = 0,
    @DateFiled date = NULL,
    @TaxCategory_Clear bit = 0,
    @TaxCategory nvarchar(60) = NULL,
    @DecisionCount int = NULL,
    @FirstDecisionDate_Clear bit = 0,
    @FirstDecisionDate date = NULL,
    @LastDecisionDate_Clear bit = 0,
    @LastDecisionDate date = NULL,
    @Dispositions_Clear bit = 0,
    @Dispositions nvarchar(300) = NULL,
    @OpinionURL_Clear bit = 0,
    @OpinionURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[TaxCourtCase]
            (
                [ID],
                [DocketNumber],
                [CaseName],
                [DateFiled],
                [TaxCategory],
                [DecisionCount],
                [FirstDecisionDate],
                [LastDecisionDate],
                [Dispositions],
                [OpinionURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @DocketNumber,
                @CaseName,
                CASE WHEN @DateFiled_Clear = 1 THEN NULL ELSE ISNULL(@DateFiled, NULL) END,
                CASE WHEN @TaxCategory_Clear = 1 THEN NULL ELSE ISNULL(@TaxCategory, NULL) END,
                ISNULL(@DecisionCount, 0),
                CASE WHEN @FirstDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@FirstDecisionDate, NULL) END,
                CASE WHEN @LastDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@LastDecisionDate, NULL) END,
                CASE WHEN @Dispositions_Clear = 1 THEN NULL ELSE ISNULL(@Dispositions, NULL) END,
                CASE WHEN @OpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@OpinionURL, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[TaxCourtCase]
            (
                [DocketNumber],
                [CaseName],
                [DateFiled],
                [TaxCategory],
                [DecisionCount],
                [FirstDecisionDate],
                [LastDecisionDate],
                [Dispositions],
                [OpinionURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @DocketNumber,
                @CaseName,
                CASE WHEN @DateFiled_Clear = 1 THEN NULL ELSE ISNULL(@DateFiled, NULL) END,
                CASE WHEN @TaxCategory_Clear = 1 THEN NULL ELSE ISNULL(@TaxCategory, NULL) END,
                ISNULL(@DecisionCount, 0),
                CASE WHEN @FirstDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@FirstDecisionDate, NULL) END,
                CASE WHEN @LastDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@LastDecisionDate, NULL) END,
                CASE WHEN @Dispositions_Clear = 1 THEN NULL ELSE ISNULL(@Dispositions, NULL) END,
                CASE WHEN @OpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@OpinionURL, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwTaxCourtCases] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateTaxCourtCase] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Tax Court Cases */

GRANT EXECUTE ON [indiana_tax].[spCreateTaxCourtCase] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Tax Court Cases */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: spUpdateTaxCourtCase
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaxCourtCase
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateTaxCourtCase]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateTaxCourtCase];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateTaxCourtCase]
    @ID uniqueidentifier,
    @DocketNumber nvarchar(40) = NULL,
    @CaseName nvarchar(500) = NULL,
    @DateFiled_Clear bit = 0,
    @DateFiled date = NULL,
    @TaxCategory_Clear bit = 0,
    @TaxCategory nvarchar(60) = NULL,
    @DecisionCount int = NULL,
    @FirstDecisionDate_Clear bit = 0,
    @FirstDecisionDate date = NULL,
    @LastDecisionDate_Clear bit = 0,
    @LastDecisionDate date = NULL,
    @Dispositions_Clear bit = 0,
    @Dispositions nvarchar(300) = NULL,
    @OpinionURL_Clear bit = 0,
    @OpinionURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[TaxCourtCase]
    SET
        [DocketNumber] = ISNULL(@DocketNumber, [DocketNumber]),
        [CaseName] = ISNULL(@CaseName, [CaseName]),
        [DateFiled] = CASE WHEN @DateFiled_Clear = 1 THEN NULL ELSE ISNULL(@DateFiled, [DateFiled]) END,
        [TaxCategory] = CASE WHEN @TaxCategory_Clear = 1 THEN NULL ELSE ISNULL(@TaxCategory, [TaxCategory]) END,
        [DecisionCount] = ISNULL(@DecisionCount, [DecisionCount]),
        [FirstDecisionDate] = CASE WHEN @FirstDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@FirstDecisionDate, [FirstDecisionDate]) END,
        [LastDecisionDate] = CASE WHEN @LastDecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@LastDecisionDate, [LastDecisionDate]) END,
        [Dispositions] = CASE WHEN @Dispositions_Clear = 1 THEN NULL ELSE ISNULL(@Dispositions, [Dispositions]) END,
        [OpinionURL] = CASE WHEN @OpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@OpinionURL, [OpinionURL]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwTaxCourtCases] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwTaxCourtCases]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateTaxCourtCase] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaxCourtCase table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateTaxCourtCase]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateTaxCourtCase];
GO
CREATE TRIGGER [indiana_tax].trgUpdateTaxCourtCase
ON [indiana_tax].[TaxCourtCase]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[TaxCourtCase]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[TaxCourtCase] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Tax Court Cases */

GRANT EXECUTE ON [indiana_tax].[spUpdateTaxCourtCase] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Tax Court IBTR Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: vwTaxCourtIBTRLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Tax Court IBTR Links
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  TaxCourtIBTRLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwTaxCourtIBTRLinks]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwTaxCourtIBTRLinks];
GO

CREATE VIEW [indiana_tax].[vwTaxCourtIBTRLinks]
AS
SELECT
    t.*
FROM
    [indiana_tax].[TaxCourtIBTRLink] AS t
GO
GRANT SELECT ON [indiana_tax].[vwTaxCourtIBTRLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Tax Court IBTR Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: Permissions for vwTaxCourtIBTRLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwTaxCourtIBTRLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Tax Court IBTR Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: spCreateTaxCourtIBTRLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaxCourtIBTRLink
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateTaxCourtIBTRLink]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateTaxCourtIBTRLink];
GO

CREATE PROCEDURE [indiana_tax].[spCreateTaxCourtIBTRLink]
    @ID uniqueidentifier = NULL,
    @TaxCourtCaseID uniqueidentifier,
    @IBTRAppealID uniqueidentifier,
    @NameScore decimal(4, 3),
    @DaysBeforeFiling_Clear bit = 0,
    @DaysBeforeFiling int = NULL,
    @MatchMethod nvarchar(40),
    @IsConfirmed_Clear bit = 0,
    @IsConfirmed bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[TaxCourtIBTRLink]
            (
                [ID],
                [TaxCourtCaseID],
                [IBTRAppealID],
                [NameScore],
                [DaysBeforeFiling],
                [MatchMethod],
                [IsConfirmed]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaxCourtCaseID,
                @IBTRAppealID,
                @NameScore,
                CASE WHEN @DaysBeforeFiling_Clear = 1 THEN NULL ELSE ISNULL(@DaysBeforeFiling, NULL) END,
                @MatchMethod,
                CASE WHEN @IsConfirmed_Clear = 1 THEN NULL ELSE ISNULL(@IsConfirmed, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[TaxCourtIBTRLink]
            (
                [TaxCourtCaseID],
                [IBTRAppealID],
                [NameScore],
                [DaysBeforeFiling],
                [MatchMethod],
                [IsConfirmed]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaxCourtCaseID,
                @IBTRAppealID,
                @NameScore,
                CASE WHEN @DaysBeforeFiling_Clear = 1 THEN NULL ELSE ISNULL(@DaysBeforeFiling, NULL) END,
                @MatchMethod,
                CASE WHEN @IsConfirmed_Clear = 1 THEN NULL ELSE ISNULL(@IsConfirmed, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwTaxCourtIBTRLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Tax Court IBTR Links */

GRANT EXECUTE ON [indiana_tax].[spCreateTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Tax Court IBTR Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: spUpdateTaxCourtIBTRLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaxCourtIBTRLink
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateTaxCourtIBTRLink]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateTaxCourtIBTRLink];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateTaxCourtIBTRLink]
    @ID uniqueidentifier,
    @TaxCourtCaseID uniqueidentifier = NULL,
    @IBTRAppealID uniqueidentifier = NULL,
    @NameScore decimal(4, 3) = NULL,
    @DaysBeforeFiling_Clear bit = 0,
    @DaysBeforeFiling int = NULL,
    @MatchMethod nvarchar(40) = NULL,
    @IsConfirmed_Clear bit = 0,
    @IsConfirmed bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[TaxCourtIBTRLink]
    SET
        [TaxCourtCaseID] = ISNULL(@TaxCourtCaseID, [TaxCourtCaseID]),
        [IBTRAppealID] = ISNULL(@IBTRAppealID, [IBTRAppealID]),
        [NameScore] = ISNULL(@NameScore, [NameScore]),
        [DaysBeforeFiling] = CASE WHEN @DaysBeforeFiling_Clear = 1 THEN NULL ELSE ISNULL(@DaysBeforeFiling, [DaysBeforeFiling]) END,
        [MatchMethod] = ISNULL(@MatchMethod, [MatchMethod]),
        [IsConfirmed] = CASE WHEN @IsConfirmed_Clear = 1 THEN NULL ELSE ISNULL(@IsConfirmed, [IsConfirmed]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwTaxCourtIBTRLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwTaxCourtIBTRLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaxCourtIBTRLink table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateTaxCourtIBTRLink]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateTaxCourtIBTRLink];
GO
CREATE TRIGGER [indiana_tax].trgUpdateTaxCourtIBTRLink
ON [indiana_tax].[TaxCourtIBTRLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[TaxCourtIBTRLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[TaxCourtIBTRLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Tax Court IBTR Links */

GRANT EXECUTE ON [indiana_tax].[spUpdateTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Tax Court Cases */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court Cases
-- Item: spDeleteTaxCourtCase
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaxCourtCase
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteTaxCourtCase]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteTaxCourtCase];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteTaxCourtCase]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[TaxCourtCase]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteTaxCourtCase] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Tax Court Cases */

GRANT EXECUTE ON [indiana_tax].[spDeleteTaxCourtCase] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Tax Court IBTR Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Tax Court IBTR Links
-- Item: spDeleteTaxCourtIBTRLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaxCourtIBTRLink
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteTaxCourtIBTRLink]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteTaxCourtIBTRLink];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteTaxCourtIBTRLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[TaxCourtIBTRLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Tax Court IBTR Links */

GRANT EXECUTE ON [indiana_tax].[spDeleteTaxCourtIBTRLink] TO [cdp_Developer], [cdp_Integration];

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DA12CF84-2D1A-4E7C-A74E-B0702E7D7F46'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '96ECBF07-B741-4D25-B969-8B9EDF9E02F6'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A272CD46-D769-47B5-AAA5-C71DEFEB2F28'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4D090099-51C7-40EE-BCBC-600AE3D06C37'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8831DF0D-17F3-470B-A2A3-6EC942F2AF82'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '4D090099-51C7-40EE-BCBC-600AE3D06C37'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET AllowUserSearchAPI = 0
            WHERE ID = 'F49320D2-BF8C-43EE-BD8A-1932EF984375'
            AND AutoUpdateAllowUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'F0DC9C65-415F-44BF-9058-2782609C2339'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F0DC9C65-415F-44BF-9058-2782609C2339'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '40BFA7EB-8427-4235-85F4-C60C62AEF951'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F7828D5A-2B5B-4C63-8364-1C40B3419564'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'ACCB802B-9890-4722-8E50-DDCFF1A7758E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3EEA9859-C631-4F39-B0BA-3153007C4CFA'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'F0DC9C65-415F-44BF-9058-2782609C2339'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '40BFA7EB-8427-4235-85F4-C60C62AEF951'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'ACCB802B-9890-4722-8E50-DDCFF1A7758E'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'F0DC9C65-415F-44BF-9058-2782609C2339'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'ACCB802B-9890-4722-8E50-DDCFF1A7758E'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'E6D0DC7B-47A8-48D3-8688-7F5B327E34F0'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'E6D0DC7B-47A8-48D3-8688-7F5B327E34F0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '518649CE-7B64-4884-8915-7A7D7577A062'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '96DE6C5E-1A1B-4EC1-A231-8AFA56A7FD59'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'BFB3B168-953A-408D-9771-F72F1D226D8E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '44910697-6B3E-4151-926D-3A5FACDC66CF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '938F7918-B016-43C5-B966-14DF97B8CE2D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'E6D0DC7B-47A8-48D3-8688-7F5B327E34F0'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '518649CE-7B64-4884-8915-7A7D7577A062'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '96DE6C5E-1A1B-4EC1-A231-8AFA56A7FD59'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '3CE4F057-98AB-4E29-BAF0-0600162D725C'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A62E7E02-A7A1-4808-986D-DCCACF4AB524'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'E6D0DC7B-47A8-48D3-8688-7F5B327E34F0'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '96DE6C5E-1A1B-4EC1-A231-8AFA56A7FD59'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A62E7E02-A7A1-4808-986D-DCCACF4AB524'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 9 fields */

-- UPDATE Entity Field Category Info Tax Court IBTR Links.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1E128D61-2727-4F1B-A394-AFD2952DE071' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.TaxCourtCaseID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Link Relationships',
   GeneratedFormSection = 'Category',
   DisplayName = 'Tax Court Case',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DA12CF84-2D1A-4E7C-A74E-B0702E7D7F46' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.IBTRAppealID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Link Relationships',
   GeneratedFormSection = 'Category',
   DisplayName = 'IBTR Appeal',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '96ECBF07-B741-4D25-B969-8B9EDF9E02F6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.NameScore 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Match Quality',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A272CD46-D769-47B5-AAA5-C71DEFEB2F28' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.DaysBeforeFiling 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Match Quality',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '00A851A8-FECC-4579-9047-6858E58FDD06' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.MatchMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Match Quality',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4D090099-51C7-40EE-BCBC-600AE3D06C37' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.IsConfirmed 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Confirmation Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8831DF0D-17F3-470B-A2A3-6EC942F2AF82' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE15CBD3-6601-4412-ACF0-E2D090665E75' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court IBTR Links.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C10339B4-619F-4652-B343-D23B1D012D32' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-link */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-link', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'F49320D2-BF8C-43EE-BD8A-1932EF984375';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e4e4ab93-41b5-4d99-a551-88e222eba7f6', 'F49320D2-BF8C-43EE-BD8A-1932EF984375', 'FieldCategoryInfo', '{"Link Relationships":{"icon":"fa fa-link","description":"Foreign key references linking Tax Court cases to IBTR dispositions"},"Match Quality":{"icon":"fa fa-chart-line","description":"Scoring and matching criteria used to identify candidate links between cases and dispositions"},"Confirmation Status":{"icon":"fa fa-check-circle","description":"Human review and confirmation status of the candidate link"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('4a8c89a8-460f-45c0-bc3d-2036338474bf', 'F49320D2-BF8C-43EE-BD8A-1932EF984375', 'FieldCategoryIcons', '{"Link Relationships":"fa fa-link","Match Quality":"fa fa-chart-line","Confirmation Status":"fa fa-check-circle","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=false for NEW entity (category: junction, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'F49320D2-BF8C-43EE-BD8A-1932EF984375';

/* Set categories for 12 fields */

-- UPDATE Entity Field Category Info Tax Court Cases.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1089431E-8C90-4D22-AD25-883283019B15' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.DocketNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = NULL
WHERE 
   ID = 'F0DC9C65-415F-44BF-9058-2782609C2339' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.CaseName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '40BFA7EB-8427-4235-85F4-C60C62AEF951' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.TaxCategory 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ACCB802B-9890-4722-8E50-DDCFF1A7758E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.DateFiled 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F7828D5A-2B5B-4C63-8364-1C40B3419564' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.FirstDecisionDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E45EADCE-3DDA-4EAC-8035-91C7375E326B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.LastDecisionDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3EEA9859-C631-4F39-B0BA-3153007C4CFA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.DecisionCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Decisions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8F210265-2781-44AD-AC87-A6D9CC56DD05' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.Dispositions 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Decisions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B732D03C-C68A-4285-8102-CD9F693302E5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.OpinionURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Case Decisions',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = '1BE82280-BA3A-4A93-BC99-62D0E6BBC462' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '803A7208-7FA2-4889-87CD-9B1DF4C3ED0D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Tax Court Cases.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0E45A4AA-1215-4FEB-B733-522B903DF106' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-gavel */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-gavel', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('bebc29f7-975d-4234-ab5c-fa10f2d9cd90', 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', 'FieldCategoryInfo', '{"Case Identification":{"icon":"fa fa-file-alt","description":"Unique identifiers and official case naming information"},"Case Classification":{"icon":"fa fa-tags","description":"Tax type and categorical information for case organization"},"Case Timeline":{"icon":"fa fa-calendar-alt","description":"Key dates marking case filing and decision milestones"},"Case Decisions":{"icon":"fa fa-gavel","description":"Court decisions, dispositions, and links to published opinions"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('ac9035b2-8674-424f-ac00-f583c39806d0', 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC', 'FieldCategoryIcons', '{"Case Identification":"fa fa-file-alt","Case Classification":"fa fa-tags","Case Timeline":"fa fa-calendar-alt","Case Decisions":"fa fa-gavel","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'C3F033EA-4DF0-4717-9D94-EE5C0334D9BC';

/* Set categories for 35 fields */

-- UPDATE Entity Field Category Info IBTR Appeals.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5DDE2CA4-6D9F-44D0-9CAD-077FA4D2D35B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.POPLARAppealID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Docket Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0543242E-6843-4C21-B370-5B0907BA3A8C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.PetitionNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Docket Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'E6D0DC7B-47A8-48D3-8688-7F5B327E34F0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.PetitionerName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Petitioner Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '518649CE-7B64-4884-8915-7A7D7577A062' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.CountyNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Location',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F8D1CA77-1972-4813-A69F-0E86C8D11472' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.CountyName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoCountry',
   CodeType = NULL
WHERE 
   ID = '96DE6C5E-1A1B-4EC1-A231-8AFA56A7FD59' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.TownshipName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Location',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '97BC88D8-AF26-4CFE-96C8-A5B2C8614F2D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.StateParcelNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5F2A1C0B-9C44-44B1-8706-FE44F192CC9F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2A9B8EFF-3688-44B9-8139-EE9AC668E78C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.ParcelMatchMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6BDEDB8C-94EB-471D-9F1D-2EB501A7FB3B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.LocationAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Location',
   GeneratedFormSection = 'Category',
   DisplayName = 'Property Address',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = '3CE4F057-98AB-4E29-BAF0-0600162D725C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.PropertyType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CC974916-CC91-4B1C-B214-189F82318FDF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.UseCategory 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7DCCC19B-C7B8-4C57-A0EA-0E91591D3B34' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BFB3B168-953A-408D-9771-F72F1D226D8E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.AppealType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B1ED7EDF-693B-48DE-8A2B-383E15846C4A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.DateReceived 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3756D1AF-DDBD-46B5-A311-C5255167C140' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.YearFiled 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '20661BEF-8C8C-4249-B8F3-6C9D9C656F4B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.DecisionDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '44910697-6B3E-4151-926D-3A5FACDC66CF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.DispositionType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Outcome',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '938F7918-B016-43C5-B966-14DF97B8CE2D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.StatusName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Outcome',
   GeneratedFormSection = 'Category',
   DisplayName = 'Status',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2AB7FDD1-B441-46F3-B0BC-24FC0D59136D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.IsSmallClaims 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Small Claims',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A427D083-D67A-4C38-B420-C34EC094B2C8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.HearingOfficer 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Hearing Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A62E7E02-A7A1-4808-986D-DCCACF4AB524' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.IssuesPhrase 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AA08F710-EE83-49D2-A977-9040A5CDB170' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.Summary 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6166E6EA-4AE9-4FCC-964C-F2D4C7346BBD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.KeyReasoning 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AEFEC96E-ED05-428C-A5A0-F5F27CF4916E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Document',
   GeneratedFormSection = 'Category',
   DisplayName = 'Decision Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6D71E2EE-DCD2-49BD-BDEF-57BD72D558DE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.TextChars 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Document',
   GeneratedFormSection = 'Category',
   DisplayName = 'Text Characters',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2E933F34-9A36-4891-A2A2-43633A9FFF2D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.TextIsOCR 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Document',
   GeneratedFormSection = 'Category',
   DisplayName = 'Text is OCR',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '352DD4DB-8B12-4AC4-B370-5AAE22B7FD56' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.ExtractionStatus 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Processing',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7D56F20D-2592-4D57-A9EC-1D87F460F2DC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.ModelConfidence 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Decision Processing',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '85F31C8D-E7DE-417C-9607-E9FA98998B5A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.LegacyBoardDecisionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'EF1CDC48-DB9E-4FDF-B94C-1F8CCF17E63A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.LegacyBoardDecision 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0E8086AA-D202-4E4E-995A-6475725C2DFA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D4146AC7-6649-4F98-93AE-1F916A0E7E21' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '63DA9FD7-FAAE-4739-89AD-3610AE73D1D0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Appeals.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BFF59F31-119D-45DD-AF16-714293B11050' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for IBTR Appeals */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '476A4E53-E135-4FEB-8D25-2385C741544F' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-gavel */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-gavel', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '476A4E53-E135-4FEB-8D25-2385C741544F';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e4c85ab7-9cd7-4a56-8a88-720413ae2a8d', '476A4E53-E135-4FEB-8D25-2385C741544F', 'FieldCategoryInfo', '{"Appeal Docket Information":{"icon":"fa fa-file-alt","description":"POPLAR system identifiers and petition numbers for tracking and citation"},"Petitioner Information":{"icon":"fa fa-user","description":"Information about the party filing the appeal"},"Property Location":{"icon":"fa fa-map-marker-alt","description":"Geographic location details including county, township, and address"},"Property Information":{"icon":"fa fa-home","description":"Parcel identification and matching method from docketed information"},"Property Classification":{"icon":"fa fa-tag","description":"Property type and use category from decision analysis"},"Appeal Details":{"icon":"fa fa-gavel","description":"Specific appeal information including form type, assessment year, and claims classification"},"Appeal Timeline":{"icon":"fa fa-calendar-alt","description":"Important dates in the appeal process from filing through decision"},"Appeal Outcome":{"icon":"fa fa-check-circle","description":"How the appeal was resolved and its current status"},"Hearing Information":{"icon":"fa fa-user-tie","description":"Administrative law judge or hearing officer assigned to the appeal"},"Decision Content":{"icon":"fa fa-align-left","description":"Extracted summaries and reasoning from the Board''s written decision"},"Decision Document":{"icon":"fa fa-file-pdf","description":"The written decision file and extracted text metrics"},"Decision Processing":{"icon":"fa fa-cog","description":"Data quality and processing status for decision content extraction"},"System Metadata":{"icon":"fa fa-database","description":"System-managed audit, relationship, and technical tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('87b4f7c2-7dab-45ea-93a7-741131c508b7', '476A4E53-E135-4FEB-8D25-2385C741544F', 'FieldCategoryIcons', '{"Appeal Docket Information":"fa fa-file-alt","Petitioner Information":"fa fa-user","Property Location":"fa fa-map-marker-alt","Property Information":"fa fa-home","Property Classification":"fa fa-tag","Appeal Details":"fa fa-gavel","Appeal Timeline":"fa fa-calendar-alt","Appeal Outcome":"fa fa-check-circle","Hearing Information":"fa fa-user-tie","Decision Content":"fa fa-align-left","Decision Document":"fa fa-file-pdf","Decision Processing":"fa fa-cog","System Metadata":"fa fa-database"}', GETUTCDATE(), GETUTCDATE());

/* Index for Foreign Keys for IBTRAppeal */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_ParcelID ON [indiana_tax].[IBTRAppeal] ([ParcelID]);

-- Index for foreign key SourceDocumentID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_SourceDocumentID ON [indiana_tax].[IBTRAppeal] ([SourceDocumentID]);

-- Index for foreign key LegacyBoardDecisionID in table IBTRAppeal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRAppeal_LegacyBoardDecisionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRAppeal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRAppeal_LegacyBoardDecisionID ON [indiana_tax].[IBTRAppeal] ([LegacyBoardDecisionID]);

/* Base View SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: vwIBTRAppeals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      IBTR Appeals
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  IBTRAppeal
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwIBTRAppeals]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwIBTRAppeals];
GO

CREATE VIEW [indiana_tax].[vwIBTRAppeals]
AS
SELECT
    i.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    indianataxBoardDecision_LegacyBoardDecisionID.[CaseNumber] AS [LegacyBoardDecision],
    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[IBTRAppeal] AS i
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [i].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[BoardDecision] AS indianataxBoardDecision_LegacyBoardDecisionID
  ON
    [i].[LegacyBoardDecisionID] = indianataxBoardDecision_LegacyBoardDecisionID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '476A4E53-E135-4FEB-8D25-2385C741544F'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([i].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwIBTRAppeals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: Permissions for vwIBTRAppeals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwIBTRAppeals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spCreateIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spCreateIBTRAppeal]
    @ID uniqueidentifier = NULL,
    @POPLARAppealID int,
    @PetitionNumber nvarchar(200),
    @PetitionerName_Clear bit = 0,
    @PetitionerName nvarchar(300) = NULL,
    @CountyNumber_Clear bit = 0,
    @CountyNumber smallint = NULL,
    @CountyName_Clear bit = 0,
    @CountyName nvarchar(50) = NULL,
    @TownshipName_Clear bit = 0,
    @TownshipName nvarchar(100) = NULL,
    @StateParcelNumber_Clear bit = 0,
    @StateParcelNumber nvarchar(60) = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @LocationAddress_Clear bit = 0,
    @LocationAddress nvarchar(300) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @AppealType_Clear bit = 0,
    @AppealType nvarchar(20) = NULL,
    @DateReceived_Clear bit = 0,
    @DateReceived date = NULL,
    @DecisionDate_Clear bit = 0,
    @DecisionDate date = NULL,
    @DispositionType nvarchar(40),
    @HearingOfficer_Clear bit = 0,
    @HearingOfficer nvarchar(100) = NULL,
    @YearFiled_Clear bit = 0,
    @YearFiled smallint = NULL,
    @StatusName_Clear bit = 0,
    @StatusName nvarchar(30) = NULL,
    @IssuesPhrase_Clear bit = 0,
    @IssuesPhrase nvarchar(500) = NULL,
    @IsSmallClaims_Clear bit = 0,
    @IsSmallClaims bit = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TextChars_Clear bit = 0,
    @TextChars int = NULL,
    @TextIsOCR_Clear bit = 0,
    @TextIsOCR bit = NULL,
    @ExtractionStatus nvarchar(20) = NULL,
    @ModelConfidence_Clear bit = 0,
    @ModelConfidence nvarchar(10) = NULL,
    @Summary_Clear bit = 0,
    @Summary nvarchar(MAX) = NULL,
    @KeyReasoning_Clear bit = 0,
    @KeyReasoning nvarchar(MAX) = NULL,
    @PropertyType_Clear bit = 0,
    @PropertyType nvarchar(300) = NULL,
    @UseCategory_Clear bit = 0,
    @UseCategory nvarchar(40) = NULL,
    @LegacyBoardDecisionID_Clear bit = 0,
    @LegacyBoardDecisionID uniqueidentifier = NULL,
    @ParcelMatchMethod_Clear bit = 0,
    @ParcelMatchMethod nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[IBTRAppeal]
            (
                [ID],
                [POPLARAppealID],
                [PetitionNumber],
                [PetitionerName],
                [CountyNumber],
                [CountyName],
                [TownshipName],
                [StateParcelNumber],
                [ParcelID],
                [LocationAddress],
                [AssessmentYear],
                [AppealType],
                [DateReceived],
                [DecisionDate],
                [DispositionType],
                [HearingOfficer],
                [YearFiled],
                [StatusName],
                [IssuesPhrase],
                [IsSmallClaims],
                [SourceDocumentID],
                [TextChars],
                [TextIsOCR],
                [ExtractionStatus],
                [ModelConfidence],
                [Summary],
                [KeyReasoning],
                [PropertyType],
                [UseCategory],
                [LegacyBoardDecisionID],
                [ParcelMatchMethod]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @POPLARAppealID,
                @PetitionNumber,
                CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, NULL) END,
                CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, NULL) END,
                CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, NULL) END,
                CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, NULL) END,
                CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, NULL) END,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, NULL) END,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, NULL) END,
                CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, NULL) END,
                CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, NULL) END,
                @DispositionType,
                CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, NULL) END,
                CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, NULL) END,
                CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, NULL) END,
                CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, NULL) END,
                CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, NULL) END,
                CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, NULL) END,
                ISNULL(@ExtractionStatus, 'None'),
                CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, NULL) END,
                CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, NULL) END,
                CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, NULL) END,
                CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, NULL) END,
                CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, NULL) END,
                CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, NULL) END,
                CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[IBTRAppeal]
            (
                [POPLARAppealID],
                [PetitionNumber],
                [PetitionerName],
                [CountyNumber],
                [CountyName],
                [TownshipName],
                [StateParcelNumber],
                [ParcelID],
                [LocationAddress],
                [AssessmentYear],
                [AppealType],
                [DateReceived],
                [DecisionDate],
                [DispositionType],
                [HearingOfficer],
                [YearFiled],
                [StatusName],
                [IssuesPhrase],
                [IsSmallClaims],
                [SourceDocumentID],
                [TextChars],
                [TextIsOCR],
                [ExtractionStatus],
                [ModelConfidence],
                [Summary],
                [KeyReasoning],
                [PropertyType],
                [UseCategory],
                [LegacyBoardDecisionID],
                [ParcelMatchMethod]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @POPLARAppealID,
                @PetitionNumber,
                CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, NULL) END,
                CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, NULL) END,
                CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, NULL) END,
                CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, NULL) END,
                CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, NULL) END,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, NULL) END,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, NULL) END,
                CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, NULL) END,
                CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, NULL) END,
                @DispositionType,
                CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, NULL) END,
                CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, NULL) END,
                CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, NULL) END,
                CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, NULL) END,
                CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, NULL) END,
                CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, NULL) END,
                ISNULL(@ExtractionStatus, 'None'),
                CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, NULL) END,
                CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, NULL) END,
                CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, NULL) END,
                CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, NULL) END,
                CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, NULL) END,
                CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, NULL) END,
                CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwIBTRAppeals] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spCreateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spUpdateIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateIBTRAppeal]
    @ID uniqueidentifier,
    @POPLARAppealID int = NULL,
    @PetitionNumber nvarchar(200) = NULL,
    @PetitionerName_Clear bit = 0,
    @PetitionerName nvarchar(300) = NULL,
    @CountyNumber_Clear bit = 0,
    @CountyNumber smallint = NULL,
    @CountyName_Clear bit = 0,
    @CountyName nvarchar(50) = NULL,
    @TownshipName_Clear bit = 0,
    @TownshipName nvarchar(100) = NULL,
    @StateParcelNumber_Clear bit = 0,
    @StateParcelNumber nvarchar(60) = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @LocationAddress_Clear bit = 0,
    @LocationAddress nvarchar(300) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @AppealType_Clear bit = 0,
    @AppealType nvarchar(20) = NULL,
    @DateReceived_Clear bit = 0,
    @DateReceived date = NULL,
    @DecisionDate_Clear bit = 0,
    @DecisionDate date = NULL,
    @DispositionType nvarchar(40) = NULL,
    @HearingOfficer_Clear bit = 0,
    @HearingOfficer nvarchar(100) = NULL,
    @YearFiled_Clear bit = 0,
    @YearFiled smallint = NULL,
    @StatusName_Clear bit = 0,
    @StatusName nvarchar(30) = NULL,
    @IssuesPhrase_Clear bit = 0,
    @IssuesPhrase nvarchar(500) = NULL,
    @IsSmallClaims_Clear bit = 0,
    @IsSmallClaims bit = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TextChars_Clear bit = 0,
    @TextChars int = NULL,
    @TextIsOCR_Clear bit = 0,
    @TextIsOCR bit = NULL,
    @ExtractionStatus nvarchar(20) = NULL,
    @ModelConfidence_Clear bit = 0,
    @ModelConfidence nvarchar(10) = NULL,
    @Summary_Clear bit = 0,
    @Summary nvarchar(MAX) = NULL,
    @KeyReasoning_Clear bit = 0,
    @KeyReasoning nvarchar(MAX) = NULL,
    @PropertyType_Clear bit = 0,
    @PropertyType nvarchar(300) = NULL,
    @UseCategory_Clear bit = 0,
    @UseCategory nvarchar(40) = NULL,
    @LegacyBoardDecisionID_Clear bit = 0,
    @LegacyBoardDecisionID uniqueidentifier = NULL,
    @ParcelMatchMethod_Clear bit = 0,
    @ParcelMatchMethod nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRAppeal]
    SET
        [POPLARAppealID] = ISNULL(@POPLARAppealID, [POPLARAppealID]),
        [PetitionNumber] = ISNULL(@PetitionNumber, [PetitionNumber]),
        [PetitionerName] = CASE WHEN @PetitionerName_Clear = 1 THEN NULL ELSE ISNULL(@PetitionerName, [PetitionerName]) END,
        [CountyNumber] = CASE WHEN @CountyNumber_Clear = 1 THEN NULL ELSE ISNULL(@CountyNumber, [CountyNumber]) END,
        [CountyName] = CASE WHEN @CountyName_Clear = 1 THEN NULL ELSE ISNULL(@CountyName, [CountyName]) END,
        [TownshipName] = CASE WHEN @TownshipName_Clear = 1 THEN NULL ELSE ISNULL(@TownshipName, [TownshipName]) END,
        [StateParcelNumber] = CASE WHEN @StateParcelNumber_Clear = 1 THEN NULL ELSE ISNULL(@StateParcelNumber, [StateParcelNumber]) END,
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [LocationAddress] = CASE WHEN @LocationAddress_Clear = 1 THEN NULL ELSE ISNULL(@LocationAddress, [LocationAddress]) END,
        [AssessmentYear] = CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, [AssessmentYear]) END,
        [AppealType] = CASE WHEN @AppealType_Clear = 1 THEN NULL ELSE ISNULL(@AppealType, [AppealType]) END,
        [DateReceived] = CASE WHEN @DateReceived_Clear = 1 THEN NULL ELSE ISNULL(@DateReceived, [DateReceived]) END,
        [DecisionDate] = CASE WHEN @DecisionDate_Clear = 1 THEN NULL ELSE ISNULL(@DecisionDate, [DecisionDate]) END,
        [DispositionType] = ISNULL(@DispositionType, [DispositionType]),
        [HearingOfficer] = CASE WHEN @HearingOfficer_Clear = 1 THEN NULL ELSE ISNULL(@HearingOfficer, [HearingOfficer]) END,
        [YearFiled] = CASE WHEN @YearFiled_Clear = 1 THEN NULL ELSE ISNULL(@YearFiled, [YearFiled]) END,
        [StatusName] = CASE WHEN @StatusName_Clear = 1 THEN NULL ELSE ISNULL(@StatusName, [StatusName]) END,
        [IssuesPhrase] = CASE WHEN @IssuesPhrase_Clear = 1 THEN NULL ELSE ISNULL(@IssuesPhrase, [IssuesPhrase]) END,
        [IsSmallClaims] = CASE WHEN @IsSmallClaims_Clear = 1 THEN NULL ELSE ISNULL(@IsSmallClaims, [IsSmallClaims]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [TextChars] = CASE WHEN @TextChars_Clear = 1 THEN NULL ELSE ISNULL(@TextChars, [TextChars]) END,
        [TextIsOCR] = CASE WHEN @TextIsOCR_Clear = 1 THEN NULL ELSE ISNULL(@TextIsOCR, [TextIsOCR]) END,
        [ExtractionStatus] = ISNULL(@ExtractionStatus, [ExtractionStatus]),
        [ModelConfidence] = CASE WHEN @ModelConfidence_Clear = 1 THEN NULL ELSE ISNULL(@ModelConfidence, [ModelConfidence]) END,
        [Summary] = CASE WHEN @Summary_Clear = 1 THEN NULL ELSE ISNULL(@Summary, [Summary]) END,
        [KeyReasoning] = CASE WHEN @KeyReasoning_Clear = 1 THEN NULL ELSE ISNULL(@KeyReasoning, [KeyReasoning]) END,
        [PropertyType] = CASE WHEN @PropertyType_Clear = 1 THEN NULL ELSE ISNULL(@PropertyType, [PropertyType]) END,
        [UseCategory] = CASE WHEN @UseCategory_Clear = 1 THEN NULL ELSE ISNULL(@UseCategory, [UseCategory]) END,
        [LegacyBoardDecisionID] = CASE WHEN @LegacyBoardDecisionID_Clear = 1 THEN NULL ELSE ISNULL(@LegacyBoardDecisionID, [LegacyBoardDecisionID]) END,
        [ParcelMatchMethod] = CASE WHEN @ParcelMatchMethod_Clear = 1 THEN NULL ELSE ISNULL(@ParcelMatchMethod, [ParcelMatchMethod]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwIBTRAppeals] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwIBTRAppeals]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRAppeal] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the IBTRAppeal table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateIBTRAppeal]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateIBTRAppeal];
GO
CREATE TRIGGER [indiana_tax].trgUpdateIBTRAppeal
ON [indiana_tax].[IBTRAppeal]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRAppeal]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[IBTRAppeal] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for IBTR Appeals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Appeals
-- Item: spDeleteIBTRAppeal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR IBTRAppeal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteIBTRAppeal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteIBTRAppeal];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteIBTRAppeal]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[IBTRAppeal]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for IBTR Appeals */

GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRAppeal] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '55811a1c-37cd-4238-b29b-4a009debc6f2' OR (EntityID = '476A4E53-E135-4FEB-8D25-2385C741544F' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
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
            '55811a1c-37cd-4238-b29b-4a009debc6f2',
            '476A4E53-E135-4FEB-8D25-2385C741544F', -- Entity: IBTR Appeals
            100071,
            '${flyway:defaultSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd8239018-7073-48cb-b5b5-85aed39060ea' OR (EntityID = '476A4E53-E135-4FEB-8D25-2385C741544F' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
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
            'd8239018-7073-48cb-b5b5-85aed39060ea',
            '476A4E53-E135-4FEB-8D25-2385C741544F', -- Entity: IBTR Appeals
            100072,
            '${flyway:defaultSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
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
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${flyway:defaultSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('476A4E53-E135-4FEB-8D25-2385C741544F');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${flyway:defaultSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('476A4E53-E135-4FEB-8D25-2385C741544F');

/* Generated Validation Functions for IBTR Appeals */
-- CHECK constraint for IBTR Appeals @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([ParcelID] IS NULL AND [ParcelMatchMethod] IS NULL OR [ParcelID] IS NOT NULL AND [ParcelMatchMethod] IS NOT NULL)', 'public ValidateParcelIDAndMatchMethodRequired(result: ValidationResult) {
	const parcelIDIsNull = this.ParcelID == null;
	const matchMethodIsNull = this.ParcelMatchMethod == null;

	if (parcelIDIsNull !== matchMethodIsNull) {
		result.Errors.push(new ValidationErrorInfo(
			"ParcelID",
			"ParcelID and ParcelMatchMethod must both be provided together, or both must be empty. You cannot have one without the other.",
			this.ParcelID,
			ValidationErrorType.Failure
		));
	}
}', 'Either both ParcelID and ParcelMatchMethod must be provided together, or both must be empty. You cannot have one without the other. This ensures that whenever a parcel is matched to an appeal, the method used for that match is also recorded, and vice versa.', 'ValidateParcelIDAndMatchMethodRequired', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '476A4E53-E135-4FEB-8D25-2385C741544F');

/* Generated Validation Functions for Tax Court IBTR Links */
-- CHECK constraint for Tax Court IBTR Links: Field: NameScore was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([NameScore]>=(0) AND [NameScore]<=(1))', 'public ValidateNameScoreRange(result: ValidationResult) {
	if (this.NameScore < 0 || this.NameScore > 1) {
		result.Errors.push(new ValidationErrorInfo(
			"NameScore",
			"Name score must be between 0 and 1",
			this.NameScore,
			ValidationErrorType.Failure
		));
	}
}', 'The name score must be between 0 and 1 (inclusive). This represents a normalized matching score where 0 indicates no match and 1 indicates a perfect match.', 'ValidateNameScoreRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'A272CD46-D769-47B5-AAA5-C71DEFEB2F28');

