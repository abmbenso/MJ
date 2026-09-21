-- Appeal Workbench: an analyst's per-parcel analysis with every input as a sourced row.
-- Spec: Indiana_Tax_Expert/docs/proposals/appeal-workbench-design.md §4.

CREATE TABLE indiana_tax.AppealAnalysis (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear SMALLINT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    PropertyTypeGroup NVARCHAR(30) NULL,
    Status NVARCHAR(10) NOT NULL CONSTRAINT DF_AppealAnalysis_Status DEFAULT ('Draft')
        CONSTRAINT CK_AppealAnalysis_Status CHECK (Status IN ('Draft', 'Final')),
    UnitOfComparison NVARCHAR(10) NOT NULL CONSTRAINT DF_AppealAnalysis_UoC DEFAULT ('$/SF')
        CONSTRAINT CK_AppealAnalysis_UoC CHECK (UnitOfComparison IN ('$/SF', '$/unit')),
    SubjectDenominator DECIMAL(14, 2) NULL,
    CurrentTotalAV DECIMAL(14, 2) NULL,
    PriorTotalAV DECIMAL(14, 2) NULL,
    BurdenOnAssessor BIT NULL,
    AskPolicy NVARCHAR(14) NOT NULL CONSTRAINT DF_AppealAnalysis_AskPolicy DEFAULT ('Lowest')
        CONSTRAINT CK_AppealAnalysis_AskPolicy CHECK (AskPolicy IN ('Lowest', 'SecondLowest')),
    RequestedValue DECIMAL(14, 2) NULL,
    RequestedValueApproach NVARCHAR(20) NULL,
    FloorValue DECIMAL(14, 2) NULL,
    FloorApproach NVARCHAR(20) NULL,
    Recommendation NVARCHAR(12) NULL
        CONSTRAINT CK_AppealAnalysis_Recommendation CHECK (Recommendation IN ('Appeal', 'No Appeal', 'Monitor')),
    EstimatedTaxSavings DECIMAL(14, 2) NULL,
    SavingsRate DECIMAL(9, 6) NULL,
    Comments NVARCHAR(MAX) NULL,
    ValuationAnalysisID UNIQUEIDENTIFIER NULL,
    ComparableAssessmentSetID UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_AppealAnalysis PRIMARY KEY (ID),
    CONSTRAINT FK_AppealAnalysis_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_AppealAnalysis_ValuationAnalysis FOREIGN KEY (ValuationAnalysisID) REFERENCES indiana_tax.ValuationAnalysis (ID),
    CONSTRAINT FK_AppealAnalysis_ComparableAssessmentSet FOREIGN KEY (ComparableAssessmentSetID) REFERENCES indiana_tax.ComparableAssessmentSet (ID)
);

CREATE TABLE indiana_tax.AppealAnalysisAssumption (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    AppealAnalysisID UNIQUEIDENTIFIER NOT NULL,
    Section NVARCHAR(20) NOT NULL
        CONSTRAINT CK_AppealAnalysisAssumption_Section CHECK (Section IN ('Income', 'Sales', 'AssessmentComps', 'Cost', 'Tax')),
    AssumptionKey NVARCHAR(60) NOT NULL,
    Label NVARCHAR(120) NOT NULL,
    Value DECIMAL(18, 6) NULL,
    Unit NVARCHAR(12) NULL,
    Mode NVARCHAR(10) NOT NULL
        CONSTRAINT CK_AppealAnalysisAssumption_Mode CHECK (Mode IN ('perSF', 'perUnit', 'annual', 'pctPGI', 'pctEGI', 'pct', 'rate', 'count', 'flag')),
    Source NVARCHAR(10) NOT NULL
        CONSTRAINT CK_AppealAnalysisAssumption_Source CHECK (Source IN ('County', 'Market', 'Default', 'Analyst')),
    SourceRef NVARCHAR(400) NULL,
    ProposedValue DECIMAL(18, 6) NULL,
    ProposedSource NVARCHAR(10) NULL,
    SortOrder INT NOT NULL CONSTRAINT DF_AppealAnalysisAssumption_Sort DEFAULT (0),
    CONSTRAINT PK_AppealAnalysisAssumption PRIMARY KEY (ID),
    CONSTRAINT FK_AppealAnalysisAssumption_Analysis FOREIGN KEY (AppealAnalysisID) REFERENCES indiana_tax.AppealAnalysis (ID),
    CONSTRAINT UQ_AppealAnalysisAssumption UNIQUE (AppealAnalysisID, Section, AssumptionKey)
);

CREATE TABLE indiana_tax.AppealAnalysisIndication (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    AppealAnalysisID UNIQUEIDENTIFIER NOT NULL,
    Approach NVARCHAR(20) NOT NULL
        CONSTRAINT CK_AppealAnalysisIndication_Approach CHECK (Approach IN ('Income', 'Sales', 'AssessmentComps', 'Cost', 'ActualIE')),
    IndicatedValue DECIMAL(14, 2) NULL,
    PerUnit DECIMAL(14, 2) NULL,
    PctOfAV DECIMAL(8, 4) NULL,
    Credible BIT NOT NULL CONSTRAINT DF_AppealAnalysisIndication_Credible DEFAULT (0),
    Supports BIT NOT NULL CONSTRAINT DF_AppealAnalysisIndication_Supports DEFAULT (0),
    Status NVARCHAR(12) NOT NULL CONSTRAINT DF_AppealAnalysisIndication_Status DEFAULT ('NotProvided')
        CONSTRAINT CK_AppealAnalysisIndication_Status CHECK (Status IN ('Computed', 'NotProvided', 'Excluded')),
    Rationale NVARCHAR(MAX) NULL,
    ComputedAt DATETIMEOFFSET NULL,
    CONSTRAINT PK_AppealAnalysisIndication PRIMARY KEY (ID),
    CONSTRAINT FK_AppealAnalysisIndication_Analysis FOREIGN KEY (AppealAnalysisID) REFERENCES indiana_tax.AppealAnalysis (ID),
    CONSTRAINT UQ_AppealAnalysisIndication UNIQUE (AppealAnalysisID, Approach)
);

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'One analyst analysis of one parcel for one assessment year; the Cover page of the Appeal Workbench. Many per parcel; the newest Draft opens by default.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysis';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Prior-year total AV as finally determined (PTABOA value first), the comparand for IC 6-1.1-15-17.2; rule owner: burden_shift_screen.sql.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysis', @level2type = N'COLUMN', @level2name = N'PriorTotalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Lowest = the ask is the lowest supporting indication (batch engine rule); SecondLowest = the second-lowest, so two approaches sit at or below the ask.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysis', @level2type = N'COLUMN', @level2name = N'AskPolicy';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Marginal tax rate the saving was computed at: min(district rate, cap + referendum) as a decimal.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysis', @level2type = N'COLUMN', @level2name = N'SavingsRate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Every input to an analysis, one row each. Value NULL means unknown, never zero. Source is where the current value came from; ProposedValue/ProposedSource keep what the system offered beside an Analyst override.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysisAssumption';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'How Value is applied: perSF/perUnit x denominator; annual as-is; pctPGI/pctEGI x that subtotal; pct and rate are decimals (0.08); count is a plain number; flag is 0/1.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysisAssumption', @level2type = N'COLUMN', @level2name = N'Mode';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'One row per approach to value. Credible = within [0.5, 1.2] x current AV; Supports = credible and below AV. Rule owner: appeal-rules.ts reconcile().', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealAnalysisIndication';





















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   It contains: the Entity/EntityField/EntityRelationship inserts, permission
   grants, EntityFieldValue rows (from the CHECK-constraint-derived value
   lists), the vwAppealAnalysis / vwAppealAnalysisAssumptions /
   vwAppealAnalysisIndications base views, spCreate/spUpdate/spDelete
   procedures, foreign-key indexes, and the AI-generated form-layout
   metadata (field categories, entity icons, DefaultForNewUser) for the
   three tables in this migration: AppealAnalysis, AppealAnalysisAssumption,
   AppealAnalysisIndication.

   DO NOT EDIT BY HAND. If the hand-written DDL above changes, re-run CodeGen
   and replace this entire section.

   Source: CodeGen_Run_2026-09-15_02-04-18.sql, produced by `mj codegen`
   against a worktree database that already carried unrelated schema work
   from other Indiana Tax branches (the APRA worktree's APRARequestEvent /
   APRAResponseFile tables) that this branch's checked-out code had not yet
   caught up to, plus one pre-existing, unrelated EntityField sequence fix
   for the "Store Analysis" entity. All such unrelated regeneration was
   excluded from what follows (each excision point is marked inline below).
   Nothing from the earlier CodeGen_Run_2026-09-15_01-58-44.sql (the Step-2
   drift-check run, which predates this migration) is included here, for
   the same reason: none of it is ours.
   ============================================================================ */

/* SQL generated to create new entity Appeal Analysis */

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
         '517c9950-0669-4474-93a1-9ef12f348879',
         'Appeal Analysis',
         NULL,
         'One analyst analysis of one parcel for one assessment year; the Cover page of the Appeal Workbench. Many per parcel; the newest Draft opens by default.',
         NULL,
         'AppealAnalysis',
         'vwAppealAnalysis',
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

/* SQL generated to add new entity Appeal Analysis to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '517c9950-0669-4474-93a1-9ef12f348879', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('517c9950-0669-4474-93a1-9ef12f348879', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('517c9950-0669-4474-93a1-9ef12f348879', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('517c9950-0669-4474-93a1-9ef12f348879', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Appeal Analysis Assumptions */

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
         'd1b77fb8-6e32-418b-ac03-dee35ef0b3e7',
         'Appeal Analysis Assumptions',
         NULL,
         'Every input to an analysis, one row each. Value NULL means unknown, never zero. Source is where the current value came from; ProposedValue/ProposedSource keep what the system offered beside an Analyst override.',
         NULL,
         'AppealAnalysisAssumption',
         'vwAppealAnalysisAssumptions',
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

/* SQL generated to add new entity Appeal Analysis Assumptions to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', 'd1b77fb8-6e32-418b-ac03-dee35ef0b3e7', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Assumptions for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d1b77fb8-6e32-418b-ac03-dee35ef0b3e7', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Assumptions for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d1b77fb8-6e32-418b-ac03-dee35ef0b3e7', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Assumptions for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d1b77fb8-6e32-418b-ac03-dee35ef0b3e7', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Appeal Analysis Indications */

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
         '365b6812-ef70-4d3b-9231-ca6515e2cc7f',
         'Appeal Analysis Indications',
         NULL,
         'One row per approach to value. Credible = within [0.5, 1.2] x current AV; Supports = credible and below AV. Rule owner: appeal-rules.ts reconcile().',
         NULL,
         'AppealAnalysisIndication',
         'vwAppealAnalysisIndications',
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

/* SQL generated to add new entity Appeal Analysis Indications to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '365b6812-ef70-4d3b-9231-ca6515e2cc7f', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Indications for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('365b6812-ef70-4d3b-9231-ca6515e2cc7f', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Indications for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('365b6812-ef70-4d3b-9231-ca6515e2cc7f', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Analysis Indications for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('365b6812-ef70-4d3b-9231-ca6515e2cc7f', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysis */
UPDATE [indiana_tax].[AppealAnalysis] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysis___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysis */
UPDATE [indiana_tax].[AppealAnalysis] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysis */
ALTER TABLE [indiana_tax].[AppealAnalysis] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysis___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisIndication */
UPDATE [indiana_tax].[AppealAnalysisIndication] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysisIndication___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisIndication */
UPDATE [indiana_tax].[AppealAnalysisIndication] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisIndication */
ALTER TABLE [indiana_tax].[AppealAnalysisIndication] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysisIndication___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisAssumption */
UPDATE [indiana_tax].[AppealAnalysisAssumption] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysisAssumption___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisAssumption */
UPDATE [indiana_tax].[AppealAnalysisAssumption] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealAnalysisAssumption */
ALTER TABLE [indiana_tax].[AppealAnalysisAssumption] ADD CONSTRAINT [DF_indiana_tax_AppealAnalysisAssumption___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO


-- [excluded: EntityField inserts for APRA Request Events / APRA Response Files -- unrelated, see header note above]

/* SQL text to insert 52 new entity field(s) -- 2 excluded (APRA Request Events, APRA Response Files; unrelated, see header note above) */


      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f7b8ca75-5b4c-41f5-9145-404fa2bd2b51' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'ID')) BEGIN
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
            'f7b8ca75-5b4c-41f5-9145-404fa2bd2b51',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c9d99658-0817-473e-8050-d39ce4a383ee' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'ParcelID')) BEGIN
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
            'c9d99658-0817-473e-8050-d39ce4a383ee',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4211a467-964d-42ba-8676-261ffb797b2b' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'AssessmentYear')) BEGIN
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
            '4211a467-964d-42ba-8676-261ffb797b2b',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100003,
            'AssessmentYear',
            'Assessment Year',
            NULL,
            'smallint',
            2,
            5,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bd8301fe-410f-4e81-b04d-41e9dacb8a18' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'Name')) BEGIN
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
            'bd8301fe-410f-4e81-b04d-41e9dacb8a18',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100004,
            'Name',
            'Name',
            NULL,
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
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b34add81-4c47-476d-8130-181654a7f98f' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'PropertyTypeGroup')) BEGIN
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
            'b34add81-4c47-476d-8130-181654a7f98f',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100005,
            'PropertyTypeGroup',
            'Property Type Group',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cb8b901d-2d7d-45fb-ba32-c058e1c6c04e' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'Status')) BEGIN
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
            'cb8b901d-2d7d-45fb-ba32-c058e1c6c04e',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100006,
            'Status',
            'Status',
            NULL,
            'nvarchar',
            20,
            0,
            0,
            0,
            'Draft',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4befbd92-e732-46cd-8f90-b8ff7320991c' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'UnitOfComparison')) BEGIN
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
            '4befbd92-e732-46cd-8f90-b8ff7320991c',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100007,
            'UnitOfComparison',
            'Unit Of Comparison',
            NULL,
            'nvarchar',
            20,
            0,
            0,
            0,
            '$/SF',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cc62b869-6be2-4c20-b899-6c840360e8be' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'SubjectDenominator')) BEGIN
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
            'cc62b869-6be2-4c20-b899-6c840360e8be',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100008,
            'SubjectDenominator',
            'Subject Denominator',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0f6bb5c5-1d45-479a-a1f7-6e563fc163de' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'CurrentTotalAV')) BEGIN
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
            '0f6bb5c5-1d45-479a-a1f7-6e563fc163de',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100009,
            'CurrentTotalAV',
            'Current Total AV',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a05eecdf-4596-44b2-a014-0fd4ccad407b' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'PriorTotalAV')) BEGIN
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
            'a05eecdf-4596-44b2-a014-0fd4ccad407b',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100010,
            'PriorTotalAV',
            'Prior Total AV',
            'Prior-year total AV as finally determined (PTABOA value first), the comparand for IC 6-1.1-15-17.2; rule owner: burden_shift_screen.sql.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4db5ab5d-0136-4788-8e91-279cd38fc92f' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'BurdenOnAssessor')) BEGIN
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
            '4db5ab5d-0136-4788-8e91-279cd38fc92f',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100011,
            'BurdenOnAssessor',
            'Burden On Assessor',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7df84992-a187-4c0f-b422-e38168a788f8' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'AskPolicy')) BEGIN
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
            '7df84992-a187-4c0f-b422-e38168a788f8',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100012,
            'AskPolicy',
            'Ask Policy',
            'Lowest = the ask is the lowest supporting indication (batch engine rule); SecondLowest = the second-lowest, so two approaches sit at or below the ask.',
            'nvarchar',
            28,
            0,
            0,
            0,
            'Lowest',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0c29d554-8c86-4139-bfe2-8d855490d0b3' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'RequestedValue')) BEGIN
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
            '0c29d554-8c86-4139-bfe2-8d855490d0b3',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100013,
            'RequestedValue',
            'Requested Value',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '773f8168-5954-4873-859e-335da488a2c6' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'RequestedValueApproach')) BEGIN
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
            '773f8168-5954-4873-859e-335da488a2c6',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100014,
            'RequestedValueApproach',
            'Requested Value Approach',
            NULL,
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8996f3ba-5648-4396-9112-1135c03c0675' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'FloorValue')) BEGIN
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
            '8996f3ba-5648-4396-9112-1135c03c0675',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100015,
            'FloorValue',
            'Floor Value',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c70d3ab8-6fab-48ff-bf85-692754662339' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'FloorApproach')) BEGIN
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
            'c70d3ab8-6fab-48ff-bf85-692754662339',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100016,
            'FloorApproach',
            'Floor Approach',
            NULL,
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e5155530-8803-4c53-9a18-1de23514e42f' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'Recommendation')) BEGIN
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
            'e5155530-8803-4c53-9a18-1de23514e42f',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100017,
            'Recommendation',
            'Recommendation',
            NULL,
            'nvarchar',
            24,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2870323d-1b58-454d-81f0-c884b8074055' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'EstimatedTaxSavings')) BEGIN
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
            '2870323d-1b58-454d-81f0-c884b8074055',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100018,
            'EstimatedTaxSavings',
            'Estimated Tax Savings',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0e693b5e-e953-4014-8d4b-d0e23130b131' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'SavingsRate')) BEGIN
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
            '0e693b5e-e953-4014-8d4b-d0e23130b131',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100019,
            'SavingsRate',
            'Savings Rate',
            'Marginal tax rate the saving was computed at: min(district rate, cap + referendum) as a decimal.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '678bab0d-68cf-4142-b5e6-bba9b18a41a5' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'Comments')) BEGIN
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
            '678bab0d-68cf-4142-b5e6-bba9b18a41a5',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100020,
            'Comments',
            'Comments',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '675bc526-eb01-433e-8a8e-c5e0924c7bc6' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'ValuationAnalysisID')) BEGIN
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
            '675bc526-eb01-433e-8a8e-c5e0924c7bc6',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100021,
            'ValuationAnalysisID',
            'Valuation Analysis ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '0D7C5F78-5879-430B-8D8F-F12FAB81DBC2',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7468ed6c-5ffa-4fa9-8f7a-35b495514f89' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'ComparableAssessmentSetID')) BEGIN
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
            '7468ed6c-5ffa-4fa9-8f7a-35b495514f89',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100022,
            'ComparableAssessmentSetID',
            'Comparable Assessment Set ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'F6C3C1CE-9CF5-45CE-9AD1-E62C2B09D91D',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '86dc1dbf-0977-49c8-89d7-ead97f43ba27' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = '__mj_CreatedAt')) BEGIN
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
            '86dc1dbf-0977-49c8-89d7-ead97f43ba27',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100023,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd382d96b-ac0b-4b7a-a50a-9b79c918020a' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd382d96b-ac0b-4b7a-a50a-9b79c918020a',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100024,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '90d77ec7-34ea-49a3-b6ef-367a2374ea49' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'ID')) BEGIN
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
            '90d77ec7-34ea-49a3-b6ef-367a2374ea49',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ddbb336d-20b8-4afa-8702-d7ef27ac53d3' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'AppealAnalysisID')) BEGIN
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
            'ddbb336d-20b8-4afa-8702-d7ef27ac53d3',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100002,
            'AppealAnalysisID',
            'Appeal Analysis ID',
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
            '517C9950-0669-4474-93A1-9EF12F348879',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '11d5d3bf-eea8-4e5d-92b1-282f1253c90a' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'Approach')) BEGIN
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
            '11d5d3bf-eea8-4e5d-92b1-282f1253c90a',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100003,
            'Approach',
            'Approach',
            NULL,
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '66c43dd9-e477-42b6-9bc3-ac7c80af29b5' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'IndicatedValue')) BEGIN
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
            '66c43dd9-e477-42b6-9bc3-ac7c80af29b5',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100004,
            'IndicatedValue',
            'Indicated Value',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '47390156-1f70-47d4-a237-11b892d0f487' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'PerUnit')) BEGIN
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
            '47390156-1f70-47d4-a237-11b892d0f487',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100005,
            'PerUnit',
            'Per Unit',
            NULL,
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '732a048b-d549-4322-bd9a-7b6bcf911849' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'PctOfAV')) BEGIN
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
            '732a048b-d549-4322-bd9a-7b6bcf911849',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100006,
            'PctOfAV',
            'Pct Of AV',
            NULL,
            'decimal',
            5,
            8,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c83dadc1-08d4-4ca5-b8e3-7844e34fcb51' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'Credible')) BEGIN
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
            'c83dadc1-08d4-4ca5-b8e3-7844e34fcb51',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100007,
            'Credible',
            'Credible',
            NULL,
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '358de65e-e7c2-4fd3-a8f5-66e824f002cf' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'Supports')) BEGIN
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
            '358de65e-e7c2-4fd3-a8f5-66e824f002cf',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100008,
            'Supports',
            'Supports',
            NULL,
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4ab0f530-9ab7-40c4-93c0-786e291d5160' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'Status')) BEGIN
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
            '4ab0f530-9ab7-40c4-93c0-786e291d5160',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100009,
            'Status',
            'Status',
            NULL,
            'nvarchar',
            24,
            0,
            0,
            0,
            'NotProvided',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '080d17e3-a8a5-4d31-82dd-852587abb74b' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'Rationale')) BEGIN
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
            '080d17e3-a8a5-4d31-82dd-852587abb74b',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100010,
            'Rationale',
            'Rationale',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a47c1344-e052-4b66-bc1b-ce8122cf34bd' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'ComputedAt')) BEGIN
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
            'a47c1344-e052-4b66-bc1b-ce8122cf34bd',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100011,
            'ComputedAt',
            'Computed At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b3e7ced2-60f0-424e-a7c8-e43161305d54' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = '__mj_CreatedAt')) BEGIN
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
            'b3e7ced2-60f0-424e-a7c8-e43161305d54',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100012,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '12d32ffb-b1c8-418c-bdd0-efa4c4c66e2a' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '12d32ffb-b1c8-418c-bdd0-efa4c4c66e2a',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100013,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6200e755-a6fb-4a7e-8cf4-9b16f7810460' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'ID')) BEGIN
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
            '6200e755-a6fb-4a7e-8cf4-9b16f7810460',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9bf84437-d01f-4e0a-b20a-f590a2cd78e4' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'AppealAnalysisID')) BEGIN
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
            '9bf84437-d01f-4e0a-b20a-f590a2cd78e4',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100002,
            'AppealAnalysisID',
            'Appeal Analysis ID',
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
            '517C9950-0669-4474-93A1-9EF12F348879',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'abfcc7d3-40ee-4d0d-8718-edacd572827c' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Section')) BEGIN
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
            'abfcc7d3-40ee-4d0d-8718-edacd572827c',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100003,
            'Section',
            'Section',
            NULL,
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f18ea70a-0a29-4491-bd58-8b39b5b67a0d' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'AssumptionKey')) BEGIN
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
            'f18ea70a-0a29-4491-bd58-8b39b5b67a0d',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100004,
            'AssumptionKey',
            'Assumption Key',
            NULL,
            'nvarchar',
            120,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '523d8d82-a2e4-451d-9d9b-610b99f3df48' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Label')) BEGIN
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
            '523d8d82-a2e4-451d-9d9b-610b99f3df48',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100005,
            'Label',
            'Label',
            NULL,
            'nvarchar',
            240,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a8e2caa0-4327-4d2a-9e89-5248752c6bca' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Value')) BEGIN
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
            'a8e2caa0-4327-4d2a-9e89-5248752c6bca',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100006,
            'Value',
            'Value',
            NULL,
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8ae02934-d627-427c-b7e6-d67ace3d7d25' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Unit')) BEGIN
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
            '8ae02934-d627-427c-b7e6-d67ace3d7d25',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100007,
            'Unit',
            'Unit',
            NULL,
            'nvarchar',
            24,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9efe5bdf-8e47-42f3-82b0-d2eeede24de0' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Mode')) BEGIN
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
            '9efe5bdf-8e47-42f3-82b0-d2eeede24de0',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100008,
            'Mode',
            'Mode',
            'How Value is applied: perSF/perUnit x denominator; annual as-is; pctPGI/pctEGI x that subtotal; pct and rate are decimals (0.08); count is a plain number; flag is 0/1.',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '87303973-50ac-4967-8cbf-64fa0a2801dd' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'Source')) BEGIN
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
            '87303973-50ac-4967-8cbf-64fa0a2801dd',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100009,
            'Source',
            'Source',
            NULL,
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7cd37b81-1047-4235-9db3-7d9d6efab82d' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'SourceRef')) BEGIN
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
            '7cd37b81-1047-4235-9db3-7d9d6efab82d',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100010,
            'SourceRef',
            'Source Ref',
            NULL,
            'nvarchar',
            800,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd50212c2-b6f8-4f6f-8998-47c4d8a319ec' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'ProposedValue')) BEGIN
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
            'd50212c2-b6f8-4f6f-8998-47c4d8a319ec',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100011,
            'ProposedValue',
            'Proposed Value',
            NULL,
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c6558ac3-c0e2-4a90-85b2-81a312e2622b' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'ProposedSource')) BEGIN
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
            'c6558ac3-c0e2-4a90-85b2-81a312e2622b',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100012,
            'ProposedSource',
            'Proposed Source',
            NULL,
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
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ae2ea1e6-2496-4843-a310-98bd7deb2f88' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'SortOrder')) BEGIN
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
            'ae2ea1e6-2496-4843-a310-98bd7deb2f88',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100013,
            'SortOrder',
            'Sort Order',
            NULL,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9fdcc57e-8ef8-46bd-ad38-7c10133a99bb' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = '__mj_CreatedAt')) BEGIN
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
            '9fdcc57e-8ef8-46bd-ad38-7c10133a99bb',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100014,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '10d00125-a648-4ee6-ba3c-51067f2b8c93' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '10d00125-a648-4ee6-ba3c-51067f2b8c93',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100015,
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


/* SQL text to insert entity field value with ID fd388513-47ff-41c1-8359-0d0345404c36 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fd388513-47ff-41c1-8359-0d0345404c36', 'CB8B901D-2D7D-45FB-BA32-C058E1C6C04E', 1, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID fdd4d013-50a4-4d13-9fdf-78142b77d44c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fdd4d013-50a4-4d13-9fdf-78142b77d44c', 'CB8B901D-2D7D-45FB-BA32-C058E1C6C04E', 2, 'Final', 'Final', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID CB8B901D-2D7D-45FB-BA32-C058E1C6C04E */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='CB8B901D-2D7D-45FB-BA32-C058E1C6C04E';

/* SQL text to insert entity field value with ID e83f0f1b-58e8-4435-8058-773aaab772a1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e83f0f1b-58e8-4435-8058-773aaab772a1', '4BEFBD92-E732-46CD-8F90-B8FF7320991C', 1, '$/SF', '$/SF', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e5f18bd6-f8ec-450c-a958-5087ecd7f8b6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e5f18bd6-f8ec-450c-a958-5087ecd7f8b6', '4BEFBD92-E732-46CD-8F90-B8FF7320991C', 2, '$/unit', '$/unit', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 4BEFBD92-E732-46CD-8F90-B8FF7320991C */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='4BEFBD92-E732-46CD-8F90-B8FF7320991C';

/* SQL text to insert entity field value with ID 813d1536-b3db-44b4-8be2-2cf9516d1a40 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('813d1536-b3db-44b4-8be2-2cf9516d1a40', '7DF84992-A187-4C0F-B422-E38168A788F8', 1, 'Lowest', 'Lowest', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dd7c1b9f-b015-4fc1-8d7d-e7ca613f3a2c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dd7c1b9f-b015-4fc1-8d7d-e7ca613f3a2c', '7DF84992-A187-4C0F-B422-E38168A788F8', 2, 'SecondLowest', 'SecondLowest', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7DF84992-A187-4C0F-B422-E38168A788F8 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='7DF84992-A187-4C0F-B422-E38168A788F8';

/* SQL text to insert entity field value with ID a9755d75-463c-400b-8b3c-bd5291386a14 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a9755d75-463c-400b-8b3c-bd5291386a14', 'E5155530-8803-4C53-9A18-1DE23514E42F', 1, 'Appeal', 'Appeal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6dd865e5-170c-41ab-a894-b585b9dca0b9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6dd865e5-170c-41ab-a894-b585b9dca0b9', 'E5155530-8803-4C53-9A18-1DE23514E42F', 2, 'Monitor', 'Monitor', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9a6d851d-8243-4619-ba4f-87ff021cb0ea */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9a6d851d-8243-4619-ba4f-87ff021cb0ea', 'E5155530-8803-4C53-9A18-1DE23514E42F', 3, 'No Appeal', 'No Appeal', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID E5155530-8803-4C53-9A18-1DE23514E42F */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='E5155530-8803-4C53-9A18-1DE23514E42F';

/* SQL text to insert entity field value with ID 997a9ead-31e2-44a9-996f-b949f4c3bf80 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('997a9ead-31e2-44a9-996f-b949f4c3bf80', 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C', 1, 'AssessmentComps', 'AssessmentComps', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7dbc5c92-a663-4402-95f0-abc37f1332de */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7dbc5c92-a663-4402-95f0-abc37f1332de', 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C', 2, 'Cost', 'Cost', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 44c6116f-5d2a-4b3d-8b43-1d68ba5e063c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('44c6116f-5d2a-4b3d-8b43-1d68ba5e063c', 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C', 3, 'Income', 'Income', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ca6fcf11-51d2-4d83-b103-ddc1bf338c9e */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ca6fcf11-51d2-4d83-b103-ddc1bf338c9e', 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C', 4, 'Sales', 'Sales', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a4384ff0-3c9a-447c-a000-6e4ead873132 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a4384ff0-3c9a-447c-a000-6e4ead873132', 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C', 5, 'Tax', 'Tax', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID ABFCC7D3-40EE-4D0D-8718-EDACD572827C */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='ABFCC7D3-40EE-4D0D-8718-EDACD572827C';

/* SQL text to insert entity field value with ID c15448ef-3240-46fc-81c5-59f973b34b1d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c15448ef-3240-46fc-81c5-59f973b34b1d', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 1, 'annual', 'annual', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b63326fe-c799-43f7-9c6b-bd2a7427c10d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b63326fe-c799-43f7-9c6b-bd2a7427c10d', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 2, 'count', 'count', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 05311c49-eb7e-43a6-879c-059289986bc8 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('05311c49-eb7e-43a6-879c-059289986bc8', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 3, 'flag', 'flag', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b993d29c-12c2-46b2-ba7b-8577423e837d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b993d29c-12c2-46b2-ba7b-8577423e837d', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 4, 'pct', 'pct', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b787d351-e4f9-47da-baab-01fcb8a3c329 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b787d351-e4f9-47da-baab-01fcb8a3c329', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 5, 'pctEGI', 'pctEGI', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1d725ba7-0282-4031-8b53-db4de8e7f4e9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1d725ba7-0282-4031-8b53-db4de8e7f4e9', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 6, 'pctPGI', 'pctPGI', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 575c2d60-2772-4a32-a2f4-d4f6c78f20db */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('575c2d60-2772-4a32-a2f4-d4f6c78f20db', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 7, 'perSF', 'perSF', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0bbe83db-c65d-4f48-8b67-75863056036b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0bbe83db-c65d-4f48-8b67-75863056036b', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 8, 'perUnit', 'perUnit', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6ff49953-9a61-4e40-880c-921429b32b4a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6ff49953-9a61-4e40-880c-921429b32b4a', '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0', 9, 'rate', 'rate', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0';

/* SQL text to insert entity field value with ID 066e25f4-054e-4e1b-b39c-7eb6d0bc20a9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('066e25f4-054e-4e1b-b39c-7eb6d0bc20a9', '87303973-50AC-4967-8CBF-64FA0A2801DD', 1, 'Analyst', 'Analyst', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e5040820-dbf8-475e-b69f-f6345d1f008f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e5040820-dbf8-475e-b69f-f6345d1f008f', '87303973-50AC-4967-8CBF-64FA0A2801DD', 2, 'County', 'County', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 250e89ba-7c2f-4b10-a89f-00d77e567e50 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('250e89ba-7c2f-4b10-a89f-00d77e567e50', '87303973-50AC-4967-8CBF-64FA0A2801DD', 3, 'Default', 'Default', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4198ffbf-848a-44c5-b95b-aa21141f632f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4198ffbf-848a-44c5-b95b-aa21141f632f', '87303973-50AC-4967-8CBF-64FA0A2801DD', 4, 'Market', 'Market', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 87303973-50AC-4967-8CBF-64FA0A2801DD */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='87303973-50AC-4967-8CBF-64FA0A2801DD';

/* SQL text to insert entity field value with ID 5d9caf9b-e23b-4812-bf15-0cd0fc01b59c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5d9caf9b-e23b-4812-bf15-0cd0fc01b59c', '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A', 1, 'ActualIE', 'ActualIE', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1fc7a5c1-88a7-43de-94ce-359bca2adfd1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1fc7a5c1-88a7-43de-94ce-359bca2adfd1', '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A', 2, 'AssessmentComps', 'AssessmentComps', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b008541b-11f8-49c5-a0bd-5ce2b0eeefb5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b008541b-11f8-49c5-a0bd-5ce2b0eeefb5', '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A', 3, 'Cost', 'Cost', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6619d2da-b48e-4286-b20b-1a253a1bf91d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6619d2da-b48e-4286-b20b-1a253a1bf91d', '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A', 4, 'Income', 'Income', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b34e52d0-2095-4717-8634-9d0460420e9c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b34e52d0-2095-4717-8634-9d0460420e9c', '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A', 5, 'Sales', 'Sales', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 11D5D3BF-EEA8-4E5D-92B1-282F1253C90A */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='11D5D3BF-EEA8-4E5D-92B1-282F1253C90A';

/* SQL text to insert entity field value with ID d813f207-20dd-4014-b9d7-04c98b346623 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d813f207-20dd-4014-b9d7-04c98b346623', '4AB0F530-9AB7-40C4-93C0-786E291D5160', 1, 'Computed', 'Computed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9b5864a5-00fb-4436-8c4a-7aa5910a325d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9b5864a5-00fb-4436-8c4a-7aa5910a325d', '4AB0F530-9AB7-40C4-93C0-786E291D5160', 2, 'Excluded', 'Excluded', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9332f65c-43e6-4e6f-ab81-a443e1b87397 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9332f65c-43e6-4e6f-ab81-a443e1b87397', '4AB0F530-9AB7-40C4-93C0-786E291D5160', 3, 'NotProvided', 'NotProvided', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 4AB0F530-9AB7-40C4-93C0-786E291D5160 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='4AB0F530-9AB7-40C4-93C0-786E291D5160';


/* Create Entity Relationship: Parcels -> Appeal Analysis (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '94d849f9-80a2-42c1-a32c-e775d7b0af95'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('94d849f9-80a2-42c1-a32c-e775d7b0af95', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '517C9950-0669-4474-93A1-9EF12F348879', 'ParcelID', 'One To Many', 1, 1, 28, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Appeal Analysis -> Appeal Analysis Assumptions (One To Many via AppealAnalysisID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '9b29101d-b872-485c-846b-4d3aecd70349'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9b29101d-b872-485c-846b-4d3aecd70349', '517C9950-0669-4474-93A1-9EF12F348879', 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', 'AppealAnalysisID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Appeal Analysis -> Appeal Analysis Indications (One To Many via AppealAnalysisID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '461ad9ca-a2b0-4ddc-a76e-92ec3ee3451d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('461ad9ca-a2b0-4ddc-a76e-92ec3ee3451d', '517C9950-0669-4474-93A1-9EF12F348879', '365B6812-EF70-4D3B-9231-CA6515E2CC7F', 'AppealAnalysisID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Comparable Assessment Sets -> Appeal Analysis (One To Many via ComparableAssessmentSetID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '991e4dae-5aa6-4220-9087-3a8fbdc02a0a'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('991e4dae-5aa6-4220-9087-3a8fbdc02a0a', 'F6C3C1CE-9CF5-45CE-9AD1-E62C2B09D91D', '517C9950-0669-4474-93A1-9EF12F348879', 'ComparableAssessmentSetID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Valuation Analysis -> Appeal Analysis (One To Many via ValuationAnalysisID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '6b33a635-ee35-4e86-80b4-ea23222e7c2c'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6b33a635-ee35-4e86-80b4-ea23222e7c2c', '0D7C5F78-5879-430B-8D8F-F12FAB81DBC2', '517C9950-0669-4474-93A1-9EF12F348879', 'ValuationAnalysisID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


-- [excluded: EntityField sequence fix for the pre-existing "Store Analysis" entity -- unrelated, see header note above]

/* Index for Foreign Keys for AppealAnalysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table AppealAnalysis
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealAnalysis_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealAnalysis]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealAnalysis_ParcelID ON [indiana_tax].[AppealAnalysis] ([ParcelID]);

-- Index for foreign key ValuationAnalysisID in table AppealAnalysis
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealAnalysis_ValuationAnalysisID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealAnalysis]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealAnalysis_ValuationAnalysisID ON [indiana_tax].[AppealAnalysis] ([ValuationAnalysisID]);

-- Index for foreign key ComparableAssessmentSetID in table AppealAnalysis
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealAnalysis_ComparableAssessmentSetID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealAnalysis]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealAnalysis_ComparableAssessmentSetID ON [indiana_tax].[AppealAnalysis] ([ComparableAssessmentSetID]);

/* SQL text to update entity field related entity name field map for entity field ID C9D99658-0817-473E-8050-D39CE4A383EE */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C9D99658-0817-473E-8050-D39CE4A383EE', @RelatedEntityNameFieldMap='Parcel';

/* Index for Foreign Keys for AppealAnalysisAssumption */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key AppealAnalysisID in table AppealAnalysisAssumption
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealAnalysisAssumption_AppealAnalysisID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealAnalysisAssumption]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealAnalysisAssumption_AppealAnalysisID ON [indiana_tax].[AppealAnalysisAssumption] ([AppealAnalysisID]);

/* SQL text to update entity field related entity name field map for entity field ID 9BF84437-D01F-4E0A-B20A-F590A2CD78E4 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9BF84437-D01F-4E0A-B20A-F590A2CD78E4', @RelatedEntityNameFieldMap='AppealAnalysis';

/* Index for Foreign Keys for AppealAnalysisIndication */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key AppealAnalysisID in table AppealAnalysisIndication
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealAnalysisIndication_AppealAnalysisID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealAnalysisIndication]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealAnalysisIndication_AppealAnalysisID ON [indiana_tax].[AppealAnalysisIndication] ([AppealAnalysisID]);

/* SQL text to update entity field related entity name field map for entity field ID DDBB336D-20B8-4AFA-8702-D7EF27AC53D3 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DDBB336D-20B8-4AFA-8702-D7EF27AC53D3', @RelatedEntityNameFieldMap='AppealAnalysis';

/* Base View SQL for Appeal Analysis Assumptions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: vwAppealAnalysisAssumptions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Analysis Assumptions
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealAnalysisAssumption
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealAnalysisAssumptions]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealAnalysisAssumptions];
GO

CREATE VIEW [indiana_tax].[vwAppealAnalysisAssumptions]
AS
SELECT
    a.*,
    indianataxAppealAnalysis_AppealAnalysisID.[Name] AS [AppealAnalysis]
FROM
    [indiana_tax].[AppealAnalysisAssumption] AS a
INNER JOIN
    [indiana_tax].[AppealAnalysis] AS indianataxAppealAnalysis_AppealAnalysisID
  ON
    [a].[AppealAnalysisID] = indianataxAppealAnalysis_AppealAnalysisID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAppealAnalysisAssumptions] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Analysis Assumptions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: Permissions for vwAppealAnalysisAssumptions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealAnalysisAssumptions] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Analysis Assumptions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: spCreateAppealAnalysisAssumption
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealAnalysisAssumption
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealAnalysisAssumption]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealAnalysisAssumption];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealAnalysisAssumption]
    @ID uniqueidentifier = NULL,
    @AppealAnalysisID uniqueidentifier,
    @Section nvarchar(20),
    @AssumptionKey nvarchar(60),
    @Label nvarchar(120),
    @Value_Clear bit = 0,
    @Value decimal(18, 6) = NULL,
    @Unit_Clear bit = 0,
    @Unit nvarchar(12) = NULL,
    @Mode nvarchar(10),
    @Source nvarchar(10),
    @SourceRef_Clear bit = 0,
    @SourceRef nvarchar(400) = NULL,
    @ProposedValue_Clear bit = 0,
    @ProposedValue decimal(18, 6) = NULL,
    @ProposedSource_Clear bit = 0,
    @ProposedSource nvarchar(10) = NULL,
    @SortOrder int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealAnalysisAssumption]
            (
                [ID],
                [AppealAnalysisID],
                [Section],
                [AssumptionKey],
                [Label],
                [Value],
                [Unit],
                [Mode],
                [Source],
                [SourceRef],
                [ProposedValue],
                [ProposedSource],
                [SortOrder]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @AppealAnalysisID,
                @Section,
                @AssumptionKey,
                @Label,
                CASE WHEN @Value_Clear = 1 THEN NULL ELSE ISNULL(@Value, NULL) END,
                CASE WHEN @Unit_Clear = 1 THEN NULL ELSE ISNULL(@Unit, NULL) END,
                @Mode,
                @Source,
                CASE WHEN @SourceRef_Clear = 1 THEN NULL ELSE ISNULL(@SourceRef, NULL) END,
                CASE WHEN @ProposedValue_Clear = 1 THEN NULL ELSE ISNULL(@ProposedValue, NULL) END,
                CASE WHEN @ProposedSource_Clear = 1 THEN NULL ELSE ISNULL(@ProposedSource, NULL) END,
                ISNULL(@SortOrder, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealAnalysisAssumption]
            (
                [AppealAnalysisID],
                [Section],
                [AssumptionKey],
                [Label],
                [Value],
                [Unit],
                [Mode],
                [Source],
                [SourceRef],
                [ProposedValue],
                [ProposedSource],
                [SortOrder]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @AppealAnalysisID,
                @Section,
                @AssumptionKey,
                @Label,
                CASE WHEN @Value_Clear = 1 THEN NULL ELSE ISNULL(@Value, NULL) END,
                CASE WHEN @Unit_Clear = 1 THEN NULL ELSE ISNULL(@Unit, NULL) END,
                @Mode,
                @Source,
                CASE WHEN @SourceRef_Clear = 1 THEN NULL ELSE ISNULL(@SourceRef, NULL) END,
                CASE WHEN @ProposedValue_Clear = 1 THEN NULL ELSE ISNULL(@ProposedValue, NULL) END,
                CASE WHEN @ProposedSource_Clear = 1 THEN NULL ELSE ISNULL(@ProposedSource, NULL) END,
                ISNULL(@SortOrder, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealAnalysisAssumptions] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Analysis Assumptions */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Analysis Assumptions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: spUpdateAppealAnalysisAssumption
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealAnalysisAssumption
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealAnalysisAssumption]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealAnalysisAssumption];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealAnalysisAssumption]
    @ID uniqueidentifier,
    @AppealAnalysisID uniqueidentifier = NULL,
    @Section nvarchar(20) = NULL,
    @AssumptionKey nvarchar(60) = NULL,
    @Label nvarchar(120) = NULL,
    @Value_Clear bit = 0,
    @Value decimal(18, 6) = NULL,
    @Unit_Clear bit = 0,
    @Unit nvarchar(12) = NULL,
    @Mode nvarchar(10) = NULL,
    @Source nvarchar(10) = NULL,
    @SourceRef_Clear bit = 0,
    @SourceRef nvarchar(400) = NULL,
    @ProposedValue_Clear bit = 0,
    @ProposedValue decimal(18, 6) = NULL,
    @ProposedSource_Clear bit = 0,
    @ProposedSource nvarchar(10) = NULL,
    @SortOrder int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysisAssumption]
    SET
        [AppealAnalysisID] = ISNULL(@AppealAnalysisID, [AppealAnalysisID]),
        [Section] = ISNULL(@Section, [Section]),
        [AssumptionKey] = ISNULL(@AssumptionKey, [AssumptionKey]),
        [Label] = ISNULL(@Label, [Label]),
        [Value] = CASE WHEN @Value_Clear = 1 THEN NULL ELSE ISNULL(@Value, [Value]) END,
        [Unit] = CASE WHEN @Unit_Clear = 1 THEN NULL ELSE ISNULL(@Unit, [Unit]) END,
        [Mode] = ISNULL(@Mode, [Mode]),
        [Source] = ISNULL(@Source, [Source]),
        [SourceRef] = CASE WHEN @SourceRef_Clear = 1 THEN NULL ELSE ISNULL(@SourceRef, [SourceRef]) END,
        [ProposedValue] = CASE WHEN @ProposedValue_Clear = 1 THEN NULL ELSE ISNULL(@ProposedValue, [ProposedValue]) END,
        [ProposedSource] = CASE WHEN @ProposedSource_Clear = 1 THEN NULL ELSE ISNULL(@ProposedSource, [ProposedSource]) END,
        [SortOrder] = ISNULL(@SortOrder, [SortOrder])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealAnalysisAssumptions] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealAnalysisAssumptions]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealAnalysisAssumption table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealAnalysisAssumption]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealAnalysisAssumption];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealAnalysisAssumption
ON [indiana_tax].[AppealAnalysisAssumption]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysisAssumption]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealAnalysisAssumption] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Analysis Assumptions */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Analysis Assumptions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Assumptions
-- Item: spDeleteAppealAnalysisAssumption
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealAnalysisAssumption
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealAnalysisAssumption]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealAnalysisAssumption];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealAnalysisAssumption]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealAnalysisAssumption]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Analysis Assumptions */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysisAssumption] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Appeal Analysis Indications */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: vwAppealAnalysisIndications
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Analysis Indications
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealAnalysisIndication
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealAnalysisIndications]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealAnalysisIndications];
GO

CREATE VIEW [indiana_tax].[vwAppealAnalysisIndications]
AS
SELECT
    a.*,
    indianataxAppealAnalysis_AppealAnalysisID.[Name] AS [AppealAnalysis]
FROM
    [indiana_tax].[AppealAnalysisIndication] AS a
INNER JOIN
    [indiana_tax].[AppealAnalysis] AS indianataxAppealAnalysis_AppealAnalysisID
  ON
    [a].[AppealAnalysisID] = indianataxAppealAnalysis_AppealAnalysisID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAppealAnalysisIndications] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Analysis Indications */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: Permissions for vwAppealAnalysisIndications
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealAnalysisIndications] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Analysis Indications */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: spCreateAppealAnalysisIndication
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealAnalysisIndication
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealAnalysisIndication]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealAnalysisIndication];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealAnalysisIndication]
    @ID uniqueidentifier = NULL,
    @AppealAnalysisID uniqueidentifier,
    @Approach nvarchar(20),
    @IndicatedValue_Clear bit = 0,
    @IndicatedValue decimal(14, 2) = NULL,
    @PerUnit_Clear bit = 0,
    @PerUnit decimal(14, 2) = NULL,
    @PctOfAV_Clear bit = 0,
    @PctOfAV decimal(8, 4) = NULL,
    @Credible bit = NULL,
    @Supports bit = NULL,
    @Status nvarchar(12) = NULL,
    @Rationale_Clear bit = 0,
    @Rationale nvarchar(MAX) = NULL,
    @ComputedAt_Clear bit = 0,
    @ComputedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealAnalysisIndication]
            (
                [ID],
                [AppealAnalysisID],
                [Approach],
                [IndicatedValue],
                [PerUnit],
                [PctOfAV],
                [Credible],
                [Supports],
                [Status],
                [Rationale],
                [ComputedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @AppealAnalysisID,
                @Approach,
                CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, NULL) END,
                CASE WHEN @PerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PerUnit, NULL) END,
                CASE WHEN @PctOfAV_Clear = 1 THEN NULL ELSE ISNULL(@PctOfAV, NULL) END,
                ISNULL(@Credible, 0),
                ISNULL(@Supports, 0),
                ISNULL(@Status, 'NotProvided'),
                CASE WHEN @Rationale_Clear = 1 THEN NULL ELSE ISNULL(@Rationale, NULL) END,
                CASE WHEN @ComputedAt_Clear = 1 THEN NULL ELSE ISNULL(@ComputedAt, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealAnalysisIndication]
            (
                [AppealAnalysisID],
                [Approach],
                [IndicatedValue],
                [PerUnit],
                [PctOfAV],
                [Credible],
                [Supports],
                [Status],
                [Rationale],
                [ComputedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @AppealAnalysisID,
                @Approach,
                CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, NULL) END,
                CASE WHEN @PerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PerUnit, NULL) END,
                CASE WHEN @PctOfAV_Clear = 1 THEN NULL ELSE ISNULL(@PctOfAV, NULL) END,
                ISNULL(@Credible, 0),
                ISNULL(@Supports, 0),
                ISNULL(@Status, 'NotProvided'),
                CASE WHEN @Rationale_Clear = 1 THEN NULL ELSE ISNULL(@Rationale, NULL) END,
                CASE WHEN @ComputedAt_Clear = 1 THEN NULL ELSE ISNULL(@ComputedAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealAnalysisIndications] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Analysis Indications */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Analysis Indications */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: spUpdateAppealAnalysisIndication
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealAnalysisIndication
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealAnalysisIndication]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealAnalysisIndication];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealAnalysisIndication]
    @ID uniqueidentifier,
    @AppealAnalysisID uniqueidentifier = NULL,
    @Approach nvarchar(20) = NULL,
    @IndicatedValue_Clear bit = 0,
    @IndicatedValue decimal(14, 2) = NULL,
    @PerUnit_Clear bit = 0,
    @PerUnit decimal(14, 2) = NULL,
    @PctOfAV_Clear bit = 0,
    @PctOfAV decimal(8, 4) = NULL,
    @Credible bit = NULL,
    @Supports bit = NULL,
    @Status nvarchar(12) = NULL,
    @Rationale_Clear bit = 0,
    @Rationale nvarchar(MAX) = NULL,
    @ComputedAt_Clear bit = 0,
    @ComputedAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysisIndication]
    SET
        [AppealAnalysisID] = ISNULL(@AppealAnalysisID, [AppealAnalysisID]),
        [Approach] = ISNULL(@Approach, [Approach]),
        [IndicatedValue] = CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, [IndicatedValue]) END,
        [PerUnit] = CASE WHEN @PerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PerUnit, [PerUnit]) END,
        [PctOfAV] = CASE WHEN @PctOfAV_Clear = 1 THEN NULL ELSE ISNULL(@PctOfAV, [PctOfAV]) END,
        [Credible] = ISNULL(@Credible, [Credible]),
        [Supports] = ISNULL(@Supports, [Supports]),
        [Status] = ISNULL(@Status, [Status]),
        [Rationale] = CASE WHEN @Rationale_Clear = 1 THEN NULL ELSE ISNULL(@Rationale, [Rationale]) END,
        [ComputedAt] = CASE WHEN @ComputedAt_Clear = 1 THEN NULL ELSE ISNULL(@ComputedAt, [ComputedAt]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealAnalysisIndications] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealAnalysisIndications]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealAnalysisIndication table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealAnalysisIndication]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealAnalysisIndication];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealAnalysisIndication
ON [indiana_tax].[AppealAnalysisIndication]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysisIndication]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealAnalysisIndication] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Analysis Indications */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Analysis Indications */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis Indications
-- Item: spDeleteAppealAnalysisIndication
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealAnalysisIndication
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealAnalysisIndication]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealAnalysisIndication];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealAnalysisIndication]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealAnalysisIndication]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Analysis Indications */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysisIndication] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Appeal Analysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: vwAppealAnalysis
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Analysis
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealAnalysis
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealAnalysis]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealAnalysis];
GO

CREATE VIEW [indiana_tax].[vwAppealAnalysis]
AS
SELECT
    a.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[AppealAnalysis] AS a
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [a].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAppealAnalysis] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Analysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: Permissions for vwAppealAnalysis
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealAnalysis] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Analysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: spCreateAppealAnalysis
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealAnalysis
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealAnalysis]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealAnalysis];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealAnalysis]
    @ID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier,
    @AssessmentYear smallint,
    @Name nvarchar(200),
    @PropertyTypeGroup_Clear bit = 0,
    @PropertyTypeGroup nvarchar(30) = NULL,
    @Status nvarchar(10) = NULL,
    @UnitOfComparison nvarchar(10) = NULL,
    @SubjectDenominator_Clear bit = 0,
    @SubjectDenominator decimal(14, 2) = NULL,
    @CurrentTotalAV_Clear bit = 0,
    @CurrentTotalAV decimal(14, 2) = NULL,
    @PriorTotalAV_Clear bit = 0,
    @PriorTotalAV decimal(14, 2) = NULL,
    @BurdenOnAssessor_Clear bit = 0,
    @BurdenOnAssessor bit = NULL,
    @AskPolicy nvarchar(14) = NULL,
    @RequestedValue_Clear bit = 0,
    @RequestedValue decimal(14, 2) = NULL,
    @RequestedValueApproach_Clear bit = 0,
    @RequestedValueApproach nvarchar(20) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(14, 2) = NULL,
    @FloorApproach_Clear bit = 0,
    @FloorApproach nvarchar(20) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(12) = NULL,
    @EstimatedTaxSavings_Clear bit = 0,
    @EstimatedTaxSavings decimal(14, 2) = NULL,
    @SavingsRate_Clear bit = 0,
    @SavingsRate decimal(9, 6) = NULL,
    @Comments_Clear bit = 0,
    @Comments nvarchar(MAX) = NULL,
    @ValuationAnalysisID_Clear bit = 0,
    @ValuationAnalysisID uniqueidentifier = NULL,
    @ComparableAssessmentSetID_Clear bit = 0,
    @ComparableAssessmentSetID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealAnalysis]
            (
                [ID],
                [ParcelID],
                [AssessmentYear],
                [Name],
                [PropertyTypeGroup],
                [Status],
                [UnitOfComparison],
                [SubjectDenominator],
                [CurrentTotalAV],
                [PriorTotalAV],
                [BurdenOnAssessor],
                [AskPolicy],
                [RequestedValue],
                [RequestedValueApproach],
                [FloorValue],
                [FloorApproach],
                [Recommendation],
                [EstimatedTaxSavings],
                [SavingsRate],
                [Comments],
                [ValuationAnalysisID],
                [ComparableAssessmentSetID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ParcelID,
                @AssessmentYear,
                @Name,
                CASE WHEN @PropertyTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@PropertyTypeGroup, NULL) END,
                ISNULL(@Status, 'Draft'),
                ISNULL(@UnitOfComparison, '$/SF'),
                CASE WHEN @SubjectDenominator_Clear = 1 THEN NULL ELSE ISNULL(@SubjectDenominator, NULL) END,
                CASE WHEN @CurrentTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTotalAV, NULL) END,
                CASE WHEN @PriorTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PriorTotalAV, NULL) END,
                CASE WHEN @BurdenOnAssessor_Clear = 1 THEN NULL ELSE ISNULL(@BurdenOnAssessor, NULL) END,
                ISNULL(@AskPolicy, 'Lowest'),
                CASE WHEN @RequestedValue_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValue, NULL) END,
                CASE WHEN @RequestedValueApproach_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValueApproach, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @FloorApproach_Clear = 1 THEN NULL ELSE ISNULL(@FloorApproach, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @EstimatedTaxSavings_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedTaxSavings, NULL) END,
                CASE WHEN @SavingsRate_Clear = 1 THEN NULL ELSE ISNULL(@SavingsRate, NULL) END,
                CASE WHEN @Comments_Clear = 1 THEN NULL ELSE ISNULL(@Comments, NULL) END,
                CASE WHEN @ValuationAnalysisID_Clear = 1 THEN NULL ELSE ISNULL(@ValuationAnalysisID, NULL) END,
                CASE WHEN @ComparableAssessmentSetID_Clear = 1 THEN NULL ELSE ISNULL(@ComparableAssessmentSetID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealAnalysis]
            (
                [ParcelID],
                [AssessmentYear],
                [Name],
                [PropertyTypeGroup],
                [Status],
                [UnitOfComparison],
                [SubjectDenominator],
                [CurrentTotalAV],
                [PriorTotalAV],
                [BurdenOnAssessor],
                [AskPolicy],
                [RequestedValue],
                [RequestedValueApproach],
                [FloorValue],
                [FloorApproach],
                [Recommendation],
                [EstimatedTaxSavings],
                [SavingsRate],
                [Comments],
                [ValuationAnalysisID],
                [ComparableAssessmentSetID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ParcelID,
                @AssessmentYear,
                @Name,
                CASE WHEN @PropertyTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@PropertyTypeGroup, NULL) END,
                ISNULL(@Status, 'Draft'),
                ISNULL(@UnitOfComparison, '$/SF'),
                CASE WHEN @SubjectDenominator_Clear = 1 THEN NULL ELSE ISNULL(@SubjectDenominator, NULL) END,
                CASE WHEN @CurrentTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTotalAV, NULL) END,
                CASE WHEN @PriorTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PriorTotalAV, NULL) END,
                CASE WHEN @BurdenOnAssessor_Clear = 1 THEN NULL ELSE ISNULL(@BurdenOnAssessor, NULL) END,
                ISNULL(@AskPolicy, 'Lowest'),
                CASE WHEN @RequestedValue_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValue, NULL) END,
                CASE WHEN @RequestedValueApproach_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValueApproach, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @FloorApproach_Clear = 1 THEN NULL ELSE ISNULL(@FloorApproach, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @EstimatedTaxSavings_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedTaxSavings, NULL) END,
                CASE WHEN @SavingsRate_Clear = 1 THEN NULL ELSE ISNULL(@SavingsRate, NULL) END,
                CASE WHEN @Comments_Clear = 1 THEN NULL ELSE ISNULL(@Comments, NULL) END,
                CASE WHEN @ValuationAnalysisID_Clear = 1 THEN NULL ELSE ISNULL(@ValuationAnalysisID, NULL) END,
                CASE WHEN @ComparableAssessmentSetID_Clear = 1 THEN NULL ELSE ISNULL(@ComparableAssessmentSetID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealAnalysis] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysis] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Analysis */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealAnalysis] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Analysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: spUpdateAppealAnalysis
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealAnalysis
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealAnalysis]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealAnalysis];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealAnalysis]
    @ID uniqueidentifier,
    @ParcelID uniqueidentifier = NULL,
    @AssessmentYear smallint = NULL,
    @Name nvarchar(200) = NULL,
    @PropertyTypeGroup_Clear bit = 0,
    @PropertyTypeGroup nvarchar(30) = NULL,
    @Status nvarchar(10) = NULL,
    @UnitOfComparison nvarchar(10) = NULL,
    @SubjectDenominator_Clear bit = 0,
    @SubjectDenominator decimal(14, 2) = NULL,
    @CurrentTotalAV_Clear bit = 0,
    @CurrentTotalAV decimal(14, 2) = NULL,
    @PriorTotalAV_Clear bit = 0,
    @PriorTotalAV decimal(14, 2) = NULL,
    @BurdenOnAssessor_Clear bit = 0,
    @BurdenOnAssessor bit = NULL,
    @AskPolicy nvarchar(14) = NULL,
    @RequestedValue_Clear bit = 0,
    @RequestedValue decimal(14, 2) = NULL,
    @RequestedValueApproach_Clear bit = 0,
    @RequestedValueApproach nvarchar(20) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(14, 2) = NULL,
    @FloorApproach_Clear bit = 0,
    @FloorApproach nvarchar(20) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(12) = NULL,
    @EstimatedTaxSavings_Clear bit = 0,
    @EstimatedTaxSavings decimal(14, 2) = NULL,
    @SavingsRate_Clear bit = 0,
    @SavingsRate decimal(9, 6) = NULL,
    @Comments_Clear bit = 0,
    @Comments nvarchar(MAX) = NULL,
    @ValuationAnalysisID_Clear bit = 0,
    @ValuationAnalysisID uniqueidentifier = NULL,
    @ComparableAssessmentSetID_Clear bit = 0,
    @ComparableAssessmentSetID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysis]
    SET
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [Name] = ISNULL(@Name, [Name]),
        [PropertyTypeGroup] = CASE WHEN @PropertyTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@PropertyTypeGroup, [PropertyTypeGroup]) END,
        [Status] = ISNULL(@Status, [Status]),
        [UnitOfComparison] = ISNULL(@UnitOfComparison, [UnitOfComparison]),
        [SubjectDenominator] = CASE WHEN @SubjectDenominator_Clear = 1 THEN NULL ELSE ISNULL(@SubjectDenominator, [SubjectDenominator]) END,
        [CurrentTotalAV] = CASE WHEN @CurrentTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTotalAV, [CurrentTotalAV]) END,
        [PriorTotalAV] = CASE WHEN @PriorTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PriorTotalAV, [PriorTotalAV]) END,
        [BurdenOnAssessor] = CASE WHEN @BurdenOnAssessor_Clear = 1 THEN NULL ELSE ISNULL(@BurdenOnAssessor, [BurdenOnAssessor]) END,
        [AskPolicy] = ISNULL(@AskPolicy, [AskPolicy]),
        [RequestedValue] = CASE WHEN @RequestedValue_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValue, [RequestedValue]) END,
        [RequestedValueApproach] = CASE WHEN @RequestedValueApproach_Clear = 1 THEN NULL ELSE ISNULL(@RequestedValueApproach, [RequestedValueApproach]) END,
        [FloorValue] = CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, [FloorValue]) END,
        [FloorApproach] = CASE WHEN @FloorApproach_Clear = 1 THEN NULL ELSE ISNULL(@FloorApproach, [FloorApproach]) END,
        [Recommendation] = CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, [Recommendation]) END,
        [EstimatedTaxSavings] = CASE WHEN @EstimatedTaxSavings_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedTaxSavings, [EstimatedTaxSavings]) END,
        [SavingsRate] = CASE WHEN @SavingsRate_Clear = 1 THEN NULL ELSE ISNULL(@SavingsRate, [SavingsRate]) END,
        [Comments] = CASE WHEN @Comments_Clear = 1 THEN NULL ELSE ISNULL(@Comments, [Comments]) END,
        [ValuationAnalysisID] = CASE WHEN @ValuationAnalysisID_Clear = 1 THEN NULL ELSE ISNULL(@ValuationAnalysisID, [ValuationAnalysisID]) END,
        [ComparableAssessmentSetID] = CASE WHEN @ComparableAssessmentSetID_Clear = 1 THEN NULL ELSE ISNULL(@ComparableAssessmentSetID, [ComparableAssessmentSetID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealAnalysis] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealAnalysis]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysis] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealAnalysis table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealAnalysis]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealAnalysis];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealAnalysis
ON [indiana_tax].[AppealAnalysis]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealAnalysis]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealAnalysis] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Analysis */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealAnalysis] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Analysis */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Analysis
-- Item: spDeleteAppealAnalysis
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealAnalysis
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealAnalysis]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealAnalysis];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealAnalysis]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealAnalysis]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysis] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Analysis */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealAnalysis] TO [cdp_Developer], [cdp_Integration];


-- [excluded: Index for Foreign Keys, base view, and spCreate/spUpdate/spDelete procedures for APRA Request Events and APRA Response Files -- unrelated, see header note above]

/* SQL text to insert 3 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9db5ea3a-6638-4a40-a3fc-beac936d3c98' OR (EntityID = '517C9950-0669-4474-93A1-9EF12F348879' AND Name = 'Parcel')) BEGIN
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
            '9db5ea3a-6638-4a40-a3fc-beac936d3c98',
            '517C9950-0669-4474-93A1-9EF12F348879', -- Entity: Appeal Analysis
            100049,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '36aeecf4-5e38-49dd-b69a-5fcec81d4f0c' OR (EntityID = '365B6812-EF70-4D3B-9231-CA6515E2CC7F' AND Name = 'AppealAnalysis')) BEGIN
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
            '36aeecf4-5e38-49dd-b69a-5fcec81d4f0c',
            '365B6812-EF70-4D3B-9231-CA6515E2CC7F', -- Entity: Appeal Analysis Indications
            100027,
            'AppealAnalysis',
            'Appeal Analysis',
            NULL,
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8e2e8004-6be0-4d32-aebd-27ab5dacf78f' OR (EntityID = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7' AND Name = 'AppealAnalysis')) BEGIN
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
            '8e2e8004-6be0-4d32-aebd-27ab5dacf78f',
            'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', -- Entity: Appeal Analysis Assumptions
            100031,
            'AppealAnalysis',
            'Appeal Analysis',
            NULL,
            'nvarchar',
            400,
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


-- [excluded: field-property updates (DefaultInView/IsNameField/search predicates) for APRA Request Events -- unrelated, see header note above]

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '66C43DD9-E477-42B6-9BC3-AC7C80AF29B5'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '732A048B-D549-4322-BD9A-7B6BCF911849'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C83DADC1-08D4-4CA5-B8E3-7844E34FCB51'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '358DE65E-E7C2-4FD3-A8F5-66E824F002CF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4AB0F530-9AB7-40C4-93C0-786E291D5160'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '4AB0F530-9AB7-40C4-93C0-786E291D5160'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '4AB0F530-9AB7-40C4-93C0-786E291D5160'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7A1E3068-0D9A-442E-9316-DE9E1316BB45'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '28467B0F-31FA-481D-97AE-2E4DBDFC9D97'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C3148B61-3DDD-4653-8825-12A8B135F395'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '39663E77-3883-4782-AACB-EC85F4EA9072'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '39663E77-3883-4782-AACB-EC85F4EA9072'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941'
               AND AutoUpdateUserSearchPredicate = 1;


-- [excluded: field-property updates for APRA Response Files -- unrelated, see header note above]

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '895DDB7E-B2DD-4DCE-883E-E8F59CCF25C4'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '895DDB7E-B2DD-4DCE-883E-E8F59CCF25C4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'AB2AA4D2-8D5B-4617-B259-8BFF525536DC'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '163E11E7-EAF5-416A-AC91-F79ECDF22D03'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8D0F7E83-276A-49A8-8C44-FB2C37A1B9D3'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '95E014AA-3E44-4E02-9AB2-36EF672ADF39'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '895DDB7E-B2DD-4DCE-883E-E8F59CCF25C4'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '163E11E7-EAF5-416A-AC91-F79ECDF22D03'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '8D0F7E83-276A-49A8-8C44-FB2C37A1B9D3'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '8D0F7E83-276A-49A8-8C44-FB2C37A1B9D3'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '163E11E7-EAF5-416A-AC91-F79ECDF22D03'
               AND AutoUpdateUserSearchPredicate = 1;


-- [excluded: field categories + entity icon for APRA Request Events -- unrelated, see header note above]

/* Set categories for 14 fields */

-- UPDATE Entity Field Category Info Appeal Analysis Indications.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '90D77EC7-34EA-49A3-B6EF-367A2374EA49' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.AppealAnalysisID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Reference',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Analysis',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DDBB336D-20B8-4AFA-8702-D7EF27AC53D3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.Approach 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Approach',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '11D5D3BF-EEA8-4E5D-92B1-282F1253C90A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.IndicatedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '66C43DD9-E477-42B6-9BC3-AC7C80AF29B5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.PerUnit 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '47390156-1F70-47D4-A237-11B892D0F487' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.PctOfAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   DisplayName = 'Percent of AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '732A048B-D549-4322-BD9A-7B6BCF911849' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.Credible 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Credibility Assessment',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C83DADC1-08D4-4CA5-B8E3-7844E34FCB51' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.Supports 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Credibility Assessment',
   GeneratedFormSection = 'Category',
   DisplayName = 'Supports Appeal',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '358DE65E-E7C2-4FD3-A8F5-66E824F002CF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.Status 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Credibility Assessment',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4AB0F530-9AB7-40C4-93C0-786E291D5160' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.Rationale 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Notes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '080D17E3-A8A5-4D31-82DD-852587ABB74B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.ComputedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Notes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A47C1344-E052-4B66-BC1B-CE8122CF34BD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B3E7CED2-60F0-424E-A7C8-E43161305D54' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '12D32FFB-B1C8-418C-BDD0-EFA4C4C66E2A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Indications.AppealAnalysis 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Reference',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Analysis Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '36AEECF4-5E38-49DD-B69A-5FCEC81D4F0C' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-chart-line */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-chart-line', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '365B6812-EF70-4D3B-9231-CA6515E2CC7F';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2d3e6723-2041-4a12-9d2e-d8540bc6821d', '365B6812-EF70-4D3B-9231-CA6515E2CC7F', 'FieldCategoryInfo', '{"Analysis Reference":{"icon":"fa fa-link","description":"References to the parent Appeal Analysis record"},"Valuation Approach":{"icon":"fa fa-calculator","description":"The valuation methodology or approach used in this analysis"},"Valuation Results":{"icon":"fa fa-chart-bar","description":"Computed values and metrics from the valuation approach"},"Credibility Assessment":{"icon":"fa fa-check-circle","description":"Credibility evaluation and appeal support determination based on assessment value range"},"Analysis Notes":{"icon":"fa fa-align-left","description":"Rationale, notes, and computation timestamps for the analysis"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('53fdb81c-4371-4f34-ab20-13c97a01f3d4', '365B6812-EF70-4D3B-9231-CA6515E2CC7F', 'FieldCategoryIcons', '{"Analysis Reference":"fa fa-link","Valuation Approach":"fa fa-calculator","Valuation Results":"fa fa-chart-bar","Credibility Assessment":"fa fa-check-circle","Analysis Notes":"fa fa-align-left","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '365B6812-EF70-4D3B-9231-CA6515E2CC7F';

/* Set categories for 16 fields */

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6200E755-A6FB-4A7E-8CF4-9B16F7810460' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.AppealAnalysisID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Analysis',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9BF84437-D01F-4E0A-B20A-F590A2CD78E4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Section 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ABFCC7D3-40EE-4D0D-8718-EDACD572827C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.AssumptionKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F18EA70A-0A29-4491-BD58-8B39B5B67A0D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Label 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '523D8D82-A2E4-451D-9D9B-610B99F3DF48' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Value 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assumption Value',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A8E2CAA0-4327-4D2A-9E89-5248752C6BCA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Unit 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assumption Value',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8AE02934-D627-427C-B7E6-D67ACE3D7D25' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Mode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assumption Value',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9EFE5BDF-8E47-42F3-82B0-D2EEEDE24DE0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.Source 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Source Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '87303973-50AC-4967-8CBF-64FA0A2801DD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.SourceRef 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Source Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Source Reference',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7CD37B81-1047-4235-9DB3-7D9D6EFAB82D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.ProposedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Proposed Changes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D50212C2-B6F8-4F6F-8998-47C4D8A319EC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.ProposedSource 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Proposed Changes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C6558AC3-C0E2-4A90-85B2-81A312E2622B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.SortOrder 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AE2EA1E6-2496-4843-A310-98BD7DEB2F88' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9FDCC57E-8EF8-46BD-AD38-7C10133A99BB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '10D00125-A648-4EE6-BA3C-51067F2B8C93' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis Assumptions.AppealAnalysis 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Context',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8E2E8004-6BE0-4D32-AEBD-27AB5DACF78F' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-chart-line */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-chart-line', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8decd4e4-6011-457b-a1b7-6f543af9fb03', 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', 'FieldCategoryInfo', '{"Analysis Context":{"icon":"fa fa-file-alt","description":"Core assumption identification and organizational context within the appeal analysis"},"Assumption Value":{"icon":"fa fa-calculator","description":"Numeric value, unit, and calculation mode for the assumption"},"Source Information":{"icon":"fa fa-info-circle","description":"Origin and reference details for the assumption value"},"Proposed Changes":{"icon":"fa fa-lightbulb","description":"System-proposed alternative value and its source for analyst review"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('4f3c0d7a-89fe-4417-8ac2-9285591b3a38', 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7', 'FieldCategoryIcons', '{"Analysis Context":"fa fa-file-alt","Assumption Value":"fa fa-calculator","Source Information":"fa fa-info-circle","Proposed Changes":"fa fa-lightbulb","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'D1B77FB8-6E32-418B-AC03-DEE35EF0B3E7';


-- [excluded: field categories + entity icon for APRA Response Files -- unrelated, see header note above]

/* Set categories for 25 fields */

-- UPDATE Entity Field Category Info Appeal Analysis.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F7B8CA75-5B4C-41F5-9145-404FA2BD2B51' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C9D99658-0817-473E-8050-D39CE4A383EE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9DB5EA3A-6638-4A40-A3FC-BEAC936D3C98' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4211A467-964D-42BA-8676-261FFB797B2B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.Name 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   DisplayName = 'Analysis Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BD8301FE-410F-4E81-B04D-41E9DACB8A18' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.PropertyTypeGroup 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B34ADD81-4C47-476D-8130-181654A7F98F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.UnitOfComparison 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   DisplayName = 'Unit of Comparison',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4BEFBD92-E732-46CD-8F90-B8FF7320991C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.SubjectDenominator 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Property',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CC62B869-6BE2-4C20-B899-6C840360E8BE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.Status 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Analysis Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CB8B901D-2D7D-45FB-BA32-C058E1C6C04E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.CurrentTotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0F6BB5C5-1D45-479A-A1F7-6E563FC163DE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.PriorTotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A05EECDF-4596-44B2-A014-0FD4CCAD407B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.BurdenOnAssessor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Burden on Assessor',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4DB5AB5D-0136-4788-8E91-279CD38FC92F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.AskPolicy 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7DF84992-A187-4C0F-B422-E38168A788F8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.RequestedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0C29D554-8C86-4139-BFE2-8D855490D0B3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.RequestedValueApproach 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '773F8168-5954-4873-859E-335DA488A2C6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.FloorValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8996F3BA-5648-4396-9112-1135C03C0675' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.FloorApproach 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C70D3AB8-6FAB-48FF-BF85-692754662339' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.Recommendation 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E5155530-8803-4C53-9A18-1DE23514E42F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.Comments 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '678BAB0D-68CF-4142-B5E6-BBA9B18A41A5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.EstimatedTaxSavings 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Financial Impact',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2870323D-1B58-454D-81F0-C884B8074055' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.SavingsRate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Financial Impact',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0E693B5E-E953-4014-8D4B-D0E23130B131' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.ValuationAnalysisID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Related Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Valuation Analysis',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '675BC526-EB01-433E-8A8E-C5E0924C7BC6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.ComparableAssessmentSetID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Related Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Comparable Assessment Set',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7468ED6C-5FFA-4FA9-8F7A-35B495514F89' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '86DC1DBF-0977-49C8-89D7-EAD97F43BA27' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Analysis.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D382D96B-AC0B-4B7A-A50A-9B79C918020A' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '517C9950-0669-4474-93A1-9EF12F348879';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('a44bce15-9871-4ef9-a93a-47fcf69387c4', '517C9950-0669-4474-93A1-9EF12F348879', 'FieldCategoryInfo', '{"Subject Property":{"icon":"fa fa-home","description":"Property identification and classification information for the subject parcel"},"Property Valuation":{"icon":"fa fa-chart-line","description":"Current and prior assessed values used as comparison basis"},"Analysis Status":{"icon":"fa fa-flag","description":"Current workflow state of the analysis record"},"Appeal Analysis":{"icon":"fa fa-balance-scale","description":"Core appeal analysis data including requested value, policy rules, and recommendation"},"Financial Impact":{"icon":"fa fa-dollar-sign","description":"Tax savings projections and rates applied to the analysis"},"Related Analysis":{"icon":"fa fa-link","description":"References to supporting valuation analysis and comparable property data"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('ece2c33c-903b-4b81-87e3-9fcc391df7f2', '517C9950-0669-4474-93A1-9EF12F348879', 'FieldCategoryIcons', '{"Subject Property":"fa fa-home","Property Valuation":"fa fa-chart-line","Analysis Status":"fa fa-flag","Appeal Analysis":"fa fa-balance-scale","Financial Impact":"fa fa-dollar-sign","Related Analysis":"fa fa-link","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '517C9950-0669-4474-93A1-9EF12F348879';

