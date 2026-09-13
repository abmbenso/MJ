/* ============================================================================
   Indiana Property Tax Expert — county record-card history
   v5.58.x

   A Standard property record card (xSoft Engage, WTH GIS, Beacon, Allen,
   Elkhart: ~73 Indiana counties) prints up to five years of Valuation Records
   -- original determinations, revisions (Rev. 134, Det/115) and, on some card
   years, an uncertified work-in-progress column -- and a Notes panel of
   appeals, permits and corrections. Assessment holds one value per parcel x
   year x source, so a card's other columns and its notes had nowhere to go.
   These two tables keep every column and every note of every card year, each
   tied to the card (SourceDocument) it was read from.

   Also:
     - CountyAssessorImprovement gains the Summary of Improvements fields it
       had no column for;
     - CountyAssessorSaleHistory gains the Standard card's transfer columns;
     - CK_Assessment_ComponentSum extends to the county-card source 'LakePRC'.

   Design: Indiana_Tax_Expert/docs/proposals/multi-county-ci-intake.md §11
   Plan:   Indiana_Tax_Expert/docs/plans/2026-09-12-lake-s2-s5-load.md
   ============================================================================ */

CREATE TABLE indiana_tax.CardValuationColumn (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    CardAssessmentYear SMALLINT NOT NULL,
    ColumnIndex SMALLINT NOT NULL,
    AssessmentYear SMALLINT NOT NULL,
    IsCertified BIT NOT NULL,
    ReasonForChange NVARCHAR(50) NULL,
    ReasonKind NVARCHAR(10) NOT NULL
        CONSTRAINT CK_CardValuationColumn_ReasonKind CHECK (ReasonKind IN ('appeal', 'reval', 'annual', 'other', 'blank', 'wip')),
    AsOfDate DATE NULL,
    ValuationMethod NVARCHAR(50) NULL,
    LandAV DECIMAL(14,2) NULL,
    ImprovementAV DECIMAL(14,2) NULL,
    TotalAV DECIMAL(14,2) NULL,
    LandRes1AV DECIMAL(14,2) NULL,
    LandNonRes2AV DECIMAL(14,2) NULL,
    LandNonRes3AV DECIMAL(14,2) NULL,
    ImprovementRes1AV DECIMAL(14,2) NULL,
    ImprovementNonRes2AV DECIMAL(14,2) NULL,
    ImprovementNonRes3AV DECIMAL(14,2) NULL,
    TotalRes1AV DECIMAL(14,2) NULL,
    TotalNonRes2AV DECIMAL(14,2) NULL,
    TotalNonRes3AV DECIMAL(14,2) NULL,

    CONSTRAINT PK_CardValuationColumn PRIMARY KEY (ID),
    CONSTRAINT FK_CardValuationColumn_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_CardValuationColumn_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_CardValuationColumn UNIQUE (SourceDocumentID, ColumnIndex)
);
GO

CREATE TABLE indiana_tax.CardNote (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    CardAssessmentYear SMALLINT NOT NULL,
    EntryIndex SMALLINT NOT NULL,
    NoteDate DATE NULL,
    NoteCode NVARCHAR(20) NULL,
    NoteKind NVARCHAR(10) NOT NULL
        CONSTRAINT CK_CardNote_NoteKind CHECK (NoteKind IN ('appeal', 'permit', 'other')),
    NoteText NVARCHAR(MAX) NOT NULL,
    NoteKey CHAR(64) NOT NULL,

    CONSTRAINT PK_CardNote PRIMARY KEY (ID),
    CONSTRAINT FK_CardNote_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_CardNote_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_CardNote UNIQUE (SourceDocumentID, EntryIndex)
);
GO

-- Groups the printings of one note across card years; not a foreign key.
CREATE INDEX IX_CardNote_NoteKey ON indiana_tax.CardNote (NoteKey);
GO

ALTER TABLE indiana_tax.CountyAssessorImprovement ADD
    Quantity SMALLINT NULL,
    SizeText NVARCHAR(30) NULL,
    AbnormalObsolescencePct DECIMAL(5,2) NULL,
    NeighborhoodFactor DECIMAL(9,4) NULL,
    Cap1Pct DECIMAL(5,2) NULL,
    Cap2Pct DECIMAL(5,2) NULL,
    Cap3Pct DECIMAL(5,2) NULL;
GO

ALTER TABLE indiana_tax.CountyAssessorSaleHistory ADD
    OwnerName NVARCHAR(300) NULL,
    DocID NVARCHAR(50) NULL,
    BookPage NVARCHAR(50) NULL,
    VacantOrImproved NVARCHAR(1) NULL
        CONSTRAINT CK_CountyAssessorSaleHistory_VacantOrImproved CHECK (VacantOrImproved IN ('V', 'I'));
GO

ALTER TABLE indiana_tax.Assessment DROP CONSTRAINT CK_Assessment_ComponentSum;
GO
ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
    Source NOT IN ('MarionPRC', 'marion_foia_2026', 'LakePRC')
    OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
    OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Every Valuation Records column of every county record card, one row per card year x printed column: original determinations, revisions (a year printed twice) and the uncertified work-in-progress column, with the Res (1) / Non Res (2) / Non Res (3) cap-tier split. Assessment takes one value per parcel-year from here (as determined on that year''s own card; a later revision in its PTABOA columns); this table keeps the complete record. Loaded by Indiana_Tax_Expert/scripts/load-county-prc.js.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Assessment Year printed on the card this column was read from (its newest year) -- the year that names the card.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'CardAssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Position on the card: 0 = the uncertified work-in-progress column printed left of the row labels; 1.. = certified columns left to right (newest first).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ColumnIndex';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The assessment year this column values. A year printed twice on one card is a revision, a split or a combination; the later As Of Date is final.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'AssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'0 for the work-in-progress column ("not certified values and subject to change"); 1 otherwise. A WIP column never becomes an Assessment row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'IsCertified';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Reason For Change cell verbatim (AA, GenReval, Rev. 134, Det/115, WIP). NULL where the card prints it blank.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ReasonForChange';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'A coarse bucket for ReasonForChange (prc_standard.reason_kind): appeal, reval, annual, other, blank, or wip. A hint; the verbatim cell is ReasonForChange.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ReasonKind';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The As Of Date cell: when this value was set. Orders two columns of the same year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'AsOfDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Valuation Method cell verbatim (Indiana Cost Mod, Other (external)).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ValuationMethod';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Land row. Always present on a certified column (the parser refuses a card missing one); may be NULL on a WIP column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'LandAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Improvement row. Always present on a certified column; may be NULL on a WIP column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ImprovementAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Total row. Always present on a certified column; may be NULL on a WIP column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'TotalAV';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Land Res (1): land value under the 1% circuit-breaker cap. The three Land tiers sum to LandAV.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'LandRes1AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Land Non Res (2): land value under the 2% cap -- apartments and residential care carry their value here.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'LandNonRes2AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Land Non Res (3): land value under the 3% cap (most commercial and industrial land).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'LandNonRes3AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Imp Res (1): improvement value under the 1% cap. The three Improvement tiers sum to ImprovementAV.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ImprovementRes1AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Imp Non Res (2): improvement value under the 2% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ImprovementNonRes2AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Imp Non Res (3): improvement value under the 3% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ImprovementNonRes3AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Total Res (1): total value under the 1% cap. The three Total tiers sum to TotalAV.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'TotalRes1AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Total Non Res (2): total value under the 2% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'TotalNonRes2AV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Total Non Res (3): total value under the 3% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'TotalNonRes3AV';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Every Notes-panel entry of every county record card, verbatim, one row per card-year printing: appeal notes (agreements, PTABOA and IBTR forms), building permits, corrections, combinations. The same note reprints on later cards; NoteKey groups the printings. Lake prints notes on AY2022/2023 cards only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Assessment Year printed on the card this note was read from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'CardAssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Position in the Notes panel, top to bottom, from 0.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'EntryIndex';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The date that opens the note (M/D/YYYY on the card); NULL where the entry has none.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The code after the date (BPER, BCHG, DBAS, 20ap, F134, RYR4-22, BPER/NRMP).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteCode';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'A hint from prc_standard.note_kind: appeal (an appeal, board, petition form 115/130/131/133/134, settlement), permit, or other. Read NoteText before relying on it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteKind';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The note''s text verbatim, wrapped lines joined; may be empty.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteText';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SHA-256 hex of date|code|text (whitespace collapsed, upper-cased): equal across the card years that reprint the same note.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteKey';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identical items on one Summary of Improvements row: the card prints "6x3:" for six items on row 3. SizeOrArea, ReproductionCost and RemainderValue are per item; TrueTaxValue is for all of them. 1 for an ordinary row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'Quantity';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Size cell as printed (122,628 sqft / 80'' x 17'' / 2 Units). SizeOrArea carries it only when printed in sqft.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'SizeText';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Abn Obs: abnormal obsolescence, percent. DepreciationObsolescence carries normal depreciation (Norm Dep).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'AbnormalObsolescencePct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Nbhd: the neighborhood factor on the improvement row (1.0000 on most). TrendFactor carries Mrkt x 100.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'NeighborhoodFactor';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 1: percent of this improvement''s value under the 1% circuit-breaker cap. Printed on AY2024+ Lake cards only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'Cap1Pct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 2: percent under the 2% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'Cap2Pct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 3: percent under the 3% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorImprovement', @level2type = N'COLUMN', @level2name = N'Cap3Pct';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Standard card''s Owner column: the owner AFTER this transfer (the grantee). The card prints no grantor, so GrantorName stays NULL on these rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorSaleHistory', @level2type = N'COLUMN', @level2name = N'OwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Doc ID cell: the recorder''s instrument reference (a number, or text such as PLAT TRACK).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorSaleHistory', @level2type = N'COLUMN', @level2name = N'DocID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Book/Page cell (PB108/90, 2023/528516); NULL where the card prints only the slash.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorSaleHistory', @level2type = N'COLUMN', @level2name = N'BookPage';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The V/I cell: V = vacant, I = improved at the time of the transfer.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorSaleHistory', @level2type = N'COLUMN', @level2name = N'VacantOrImproved';
GO


















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   EntityField inserts, regenerated views, spCreate/spUpdate/spDelete procedures,
   permission grants and extended properties for CardValuationColumn, CardNote,
   and the altered CountyAssessorImprovement and CountyAssessorSaleHistory.
   DO NOT EDIT BY HAND. If the DDL above changes, re-run CodeGen and replace this section.
   ============================================================================ */

/* SQL generated to create new entity Card Valuation Columns */

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
         '74ece0a0-cfc9-4850-ab7f-dcf3a3d9ddc7',
         'Card Valuation Columns',
         NULL,
         'Every Valuation Records column of every county record card, one row per card year x printed column: original determinations, revisions (a year printed twice) and the uncertified work-in-progress column, with the Res (1) / Non Res (2) / Non Res (3) cap-tier split. Assessment takes one value per parcel-year from here (as determined on that year''s own card; a later revision in its PTABOA columns); this table keeps the complete record. Loaded by Indiana_Tax_Expert/scripts/load-county-prc.js.',
         NULL,
         'CardValuationColumn',
         'vwCardValuationColumns',
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

/* SQL generated to add new entity Card Valuation Columns to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '74ece0a0-cfc9-4850-ab7f-dcf3a3d9ddc7', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Valuation Columns for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74ece0a0-cfc9-4850-ab7f-dcf3a3d9ddc7', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Valuation Columns for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74ece0a0-cfc9-4850-ab7f-dcf3a3d9ddc7', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Valuation Columns for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74ece0a0-cfc9-4850-ab7f-dcf3a3d9ddc7', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Card Notes */

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
         '2a7bd138-666d-4835-b591-256380f7775b',
         'Card Notes',
         NULL,
         'Every Notes-panel entry of every county record card, verbatim, one row per card-year printing: appeal notes (agreements, PTABOA and IBTR forms), building permits, corrections, combinations. The same note reprints on later cards; NoteKey groups the printings. Lake prints notes on AY2022/2023 cards only.',
         NULL,
         'CardNote',
         'vwCardNotes',
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

/* SQL generated to add new entity Card Notes to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '2a7bd138-666d-4835-b591-256380f7775b', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Notes for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2a7bd138-666d-4835-b591-256380f7775b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Notes for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2a7bd138-666d-4835-b591-256380f7775b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Notes for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2a7bd138-666d-4835-b591-256380f7775b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardNote */
UPDATE [indiana_tax].[CardNote] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ADD CONSTRAINT [DF_indiana_tax_CardNote___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardNote */
UPDATE [indiana_tax].[CardNote] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardNote */
ALTER TABLE [indiana_tax].[CardNote] ADD CONSTRAINT [DF_indiana_tax_CardNote___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardValuationColumn */
UPDATE [indiana_tax].[CardValuationColumn] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ADD CONSTRAINT [DF_indiana_tax_CardValuationColumn___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardValuationColumn */
UPDATE [indiana_tax].[CardValuationColumn] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardValuationColumn */
ALTER TABLE [indiana_tax].[CardValuationColumn] ADD CONSTRAINT [DF_indiana_tax_CardValuationColumn___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 48 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '05079a7b-8aef-4ec6-8751-975763aa280a' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'ID')) BEGIN
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
            '05079a7b-8aef-4ec6-8751-975763aa280a',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0fd11ab2-f6d4-4940-8037-3e8a88c1386e' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'SourceDocumentID')) BEGIN
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
            '0fd11ab2-f6d4-4940-8037-3e8a88c1386e',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100002,
            'SourceDocumentID',
            'Source Document ID',
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
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd6d5c679-c93c-492a-ba98-9b9dad50b7c3' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'ParcelID')) BEGIN
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
            'd6d5c679-c93c-492a-ba98-9b9dad50b7c3',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100003,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fce9a16e-8252-496b-ab45-fd001ba93b91' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'CardAssessmentYear')) BEGIN
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
            'fce9a16e-8252-496b-ab45-fd001ba93b91',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100004,
            'CardAssessmentYear',
            'Card Assessment Year',
            'The Assessment Year printed on the card this note was read from.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd7467401-3359-4e82-aacf-dbf7043df75b' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'EntryIndex')) BEGIN
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
            'd7467401-3359-4e82-aacf-dbf7043df75b',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100005,
            'EntryIndex',
            'Entry Index',
            'Position in the Notes panel, top to bottom, from 0.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8b9c49f1-fc25-4ead-ab63-64165f38a557' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteDate')) BEGIN
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
            '8b9c49f1-fc25-4ead-ab63-64165f38a557',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100006,
            'NoteDate',
            'Note Date',
            'The date that opens the note (M/D/YYYY on the card); NULL where the entry has none.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '623e8ca7-c500-4516-a3b2-910f9065b163' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteCode')) BEGIN
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
            '623e8ca7-c500-4516-a3b2-910f9065b163',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100007,
            'NoteCode',
            'Note Code',
            'The code after the date (BPER, BCHG, DBAS, 20ap, F134, RYR4-22, BPER/NRMP).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4afe50c1-cd14-4bfb-897c-8076b5cf3f85' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteKind')) BEGIN
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
            '4afe50c1-cd14-4bfb-897c-8076b5cf3f85',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100008,
            'NoteKind',
            'Note Kind',
            'A hint from prc_standard.note_kind: appeal (an appeal, board, petition form 115/130/131/133/134, settlement), permit, or other. Read NoteText before relying on it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '58578383-699c-4259-908a-6857c59bd146' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteText')) BEGIN
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
            '58578383-699c-4259-908a-6857c59bd146',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100009,
            'NoteText',
            'Note Text',
            'The note''s text verbatim, wrapped lines joined; may be empty.',
            'nvarchar',
            -1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a6ff0d12-6e4d-4ef5-ab40-dfb4fb9c7b24' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteKey')) BEGIN
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
            'a6ff0d12-6e4d-4ef5-ab40-dfb4fb9c7b24',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100010,
            'NoteKey',
            'Note Key',
            'SHA-256 hex of date|code|text (whitespace collapsed, upper-cased): equal across the card years that reprint the same note.',
            'char',
            64,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7a27b4d3-432a-4fbc-8031-be19dc42a6c0' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = '__mj_CreatedAt')) BEGIN
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
            '7a27b4d3-432a-4fbc-8031-be19dc42a6c0',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3b62db10-fa52-41bc-a386-53de6d511584' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '3b62db10-fa52-41bc-a386-53de6d511584',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3994a36e-003b-4211-b9fd-31c2c473bdec' OR (EntityID = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND Name = 'OwnerName')) BEGIN
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
            '3994a36e-003b-4211-b9fd-31c2c473bdec',
            '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13', -- Entity: County Assessor Sale Histories
            100024,
            'OwnerName',
            'Owner Name',
            'The Standard card''s Owner column: the owner AFTER this transfer (the grantee). The card prints no grantor, so GrantorName stays NULL on these rows.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ee0bd1f2-32d2-4ab6-92ea-e297d816dbd9' OR (EntityID = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND Name = 'DocID')) BEGIN
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
            'ee0bd1f2-32d2-4ab6-92ea-e297d816dbd9',
            '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13', -- Entity: County Assessor Sale Histories
            100025,
            'DocID',
            'Doc ID',
            'The Doc ID cell: the recorder''s instrument reference (a number, or text such as PLAT TRACK).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b198abb3-29f8-4a9e-b40a-7470792a3208' OR (EntityID = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND Name = 'BookPage')) BEGIN
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
            'b198abb3-29f8-4a9e-b40a-7470792a3208',
            '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13', -- Entity: County Assessor Sale Histories
            100026,
            'BookPage',
            'Book Page',
            'The Book/Page cell (PB108/90, 2023/528516); NULL where the card prints only the slash.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '15a446c2-25a1-4348-934b-c5fc8130a757' OR (EntityID = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND Name = 'VacantOrImproved')) BEGIN
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
            '15a446c2-25a1-4348-934b-c5fc8130a757',
            '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13', -- Entity: County Assessor Sale Histories
            100027,
            'VacantOrImproved',
            'Vacant Or Improved',
            'The V/I cell: V = vacant, I = improved at the time of the transfer.',
            'nvarchar',
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e11d1544-d548-48fc-8906-47cfa2ffec3d' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'Quantity')) BEGIN
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
            'e11d1544-d548-48fc-8906-47cfa2ffec3d',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100043,
            'Quantity',
            'Quantity',
            'Identical items on one Summary of Improvements row: the card prints "6x3:" for six items on row 3. SizeOrArea, ReproductionCost and RemainderValue are per item; TrueTaxValue is for all of them. 1 for an ordinary row.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9029fe57-3d0d-4cdd-b1ac-e580be9b6732' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'SizeText')) BEGIN
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
            '9029fe57-3d0d-4cdd-b1ac-e580be9b6732',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100044,
            'SizeText',
            'Size Text',
            'The Size cell as printed (122,628 sqft / 80'' x 17'' / 2 Units). SizeOrArea carries it only when printed in sqft.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '74a5dfbd-5061-4714-9a75-258ce6db29ae' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'AbnormalObsolescencePct')) BEGIN
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
            '74a5dfbd-5061-4714-9a75-258ce6db29ae',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100045,
            'AbnormalObsolescencePct',
            'Abnormal Obsolescence Pct',
            'Abn Obs: abnormal obsolescence, percent. DepreciationObsolescence carries normal depreciation (Norm Dep).',
            'decimal',
            5,
            5,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd944ff31-2bc1-4fe1-812a-747bc33a8e7b' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'NeighborhoodFactor')) BEGIN
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
            'd944ff31-2bc1-4fe1-812a-747bc33a8e7b',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100046,
            'NeighborhoodFactor',
            'Neighborhood Factor',
            'Nbhd: the neighborhood factor on the improvement row (1.0000 on most). TrendFactor carries Mrkt x 100.',
            'decimal',
            5,
            9,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ffc0c9d5-94c4-44fa-8333-6c63205e3d9d' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'Cap1Pct')) BEGIN
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
            'ffc0c9d5-94c4-44fa-8333-6c63205e3d9d',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100047,
            'Cap1Pct',
            'Cap 1 Pct',
            'Cap 1: percent of this improvement''s value under the 1% circuit-breaker cap. Printed on AY2024+ Lake cards only.',
            'decimal',
            5,
            5,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b34199a8-97bb-4be5-96a9-6f97709a94da' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'Cap2Pct')) BEGIN
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
            'b34199a8-97bb-4be5-96a9-6f97709a94da',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100048,
            'Cap2Pct',
            'Cap 2 Pct',
            'Cap 2: percent under the 2% cap.',
            'decimal',
            5,
            5,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '93cd20ab-a273-483e-8bf3-ae46736d45c1' OR (EntityID = '28C26F32-D3D2-47D6-A066-7A12C9EFC62B' AND Name = 'Cap3Pct')) BEGIN
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
            '93cd20ab-a273-483e-8bf3-ae46736d45c1',
            '28C26F32-D3D2-47D6-A066-7A12C9EFC62B', -- Entity: County Assessor Improvements
            100049,
            'Cap3Pct',
            'Cap 3 Pct',
            'Cap 3: percent under the 3% cap.',
            'decimal',
            5,
            5,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7b56e5b2-7e28-4b70-8a35-85da9ee85c0f' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ID')) BEGIN
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
            '7b56e5b2-7e28-4b70-8a35-85da9ee85c0f',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2861ebd4-57c4-4c8d-b289-6a11f438e714' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'SourceDocumentID')) BEGIN
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
            '2861ebd4-57c4-4c8d-b289-6a11f438e714',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100002,
            'SourceDocumentID',
            'Source Document ID',
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
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0a3f512d-169b-4b7f-912a-2e9fa2f8c356' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ParcelID')) BEGIN
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
            '0a3f512d-169b-4b7f-912a-2e9fa2f8c356',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100003,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '430dc138-34ff-44d8-b896-e858e3c249e9' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'CardAssessmentYear')) BEGIN
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
            '430dc138-34ff-44d8-b896-e858e3c249e9',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100004,
            'CardAssessmentYear',
            'Card Assessment Year',
            'The Assessment Year printed on the card this column was read from (its newest year) -- the year that names the card.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f4f23fd4-04a3-4c38-937d-ea51e5595b7a' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ColumnIndex')) BEGIN
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
            'f4f23fd4-04a3-4c38-937d-ea51e5595b7a',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100005,
            'ColumnIndex',
            'Column Index',
            'Position on the card: 0 = the uncertified work-in-progress column printed left of the row labels; 1.. = certified columns left to right (newest first).',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b8dbbe0b-0f67-42c1-9e17-849b92d479bd' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'AssessmentYear')) BEGIN
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
            'b8dbbe0b-0f67-42c1-9e17-849b92d479bd',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100006,
            'AssessmentYear',
            'Assessment Year',
            'The assessment year this column values. A year printed twice on one card is a revision, a split or a combination; the later As Of Date is final.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '70e4a8e8-5a30-4172-8774-81dbcae4384b' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'IsCertified')) BEGIN
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
            '70e4a8e8-5a30-4172-8774-81dbcae4384b',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100007,
            'IsCertified',
            'Is Certified',
            '0 for the work-in-progress column ("not certified values and subject to change"); 1 otherwise. A WIP column never becomes an Assessment row.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2a35024d-ea9c-4755-814d-7d6c59538464' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ReasonForChange')) BEGIN
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
            '2a35024d-ea9c-4755-814d-7d6c59538464',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100008,
            'ReasonForChange',
            'Reason For Change',
            'The Reason For Change cell verbatim (AA, GenReval, Rev. 134, Det/115, WIP). NULL where the card prints it blank.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b4e841aa-ef47-46f8-8601-32e789dcec45' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ReasonKind')) BEGIN
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
            'b4e841aa-ef47-46f8-8601-32e789dcec45',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100009,
            'ReasonKind',
            'Reason Kind',
            'A coarse bucket for ReasonForChange (prc_standard.reason_kind): appeal, reval, annual, other, blank, or wip. A hint; the verbatim cell is ReasonForChange.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ae5e1636-3d66-4f13-847e-4006ebee5df0' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'AsOfDate')) BEGIN
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
            'ae5e1636-3d66-4f13-847e-4006ebee5df0',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100010,
            'AsOfDate',
            'As Of Date',
            'The As Of Date cell: when this value was set. Orders two columns of the same year.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '73926fc0-9f95-4bff-8b48-534240956c96' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ValuationMethod')) BEGIN
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
            '73926fc0-9f95-4bff-8b48-534240956c96',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100011,
            'ValuationMethod',
            'Valuation Method',
            'The Valuation Method cell verbatim (Indiana Cost Mod, Other (external)).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2e17e63a-92ed-4fd7-b1c9-3f323c8e8246' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'LandAV')) BEGIN
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
            '2e17e63a-92ed-4fd7-b1c9-3f323c8e8246',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100012,
            'LandAV',
            'Land AV',
            'The Land row. Always present on a certified column (the parser refuses a card missing one); may be NULL on a WIP column.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d48dd89-dd16-482b-9e6a-7707365ee133' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ImprovementAV')) BEGIN
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
            '9d48dd89-dd16-482b-9e6a-7707365ee133',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100013,
            'ImprovementAV',
            'Improvement AV',
            'The Improvement row. Always present on a certified column; may be NULL on a WIP column.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fc948138-af9a-45f9-9d38-8000f7f30ba7' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'TotalAV')) BEGIN
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
            'fc948138-af9a-45f9-9d38-8000f7f30ba7',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100014,
            'TotalAV',
            'Total AV',
            'The Total row. Always present on a certified column; may be NULL on a WIP column.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5d3cf08b-3716-4210-a421-7a9826f2e5fa' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'LandRes1AV')) BEGIN
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
            '5d3cf08b-3716-4210-a421-7a9826f2e5fa',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100015,
            'LandRes1AV',
            'Land Res 1AV',
            'Land Res (1): land value under the 1% circuit-breaker cap. The three Land tiers sum to LandAV.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f43ef7fb-ccfa-46c9-8bfa-823421a363da' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'LandNonRes2AV')) BEGIN
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
            'f43ef7fb-ccfa-46c9-8bfa-823421a363da',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100016,
            'LandNonRes2AV',
            'Land Non Res 2AV',
            'Land Non Res (2): land value under the 2% cap -- apartments and residential care carry their value here.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '59da306a-8cc6-49e1-85e9-ed1ef2047ff7' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'LandNonRes3AV')) BEGIN
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
            '59da306a-8cc6-49e1-85e9-ed1ef2047ff7',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100017,
            'LandNonRes3AV',
            'Land Non Res 3AV',
            'Land Non Res (3): land value under the 3% cap (most commercial and industrial land).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3f0aa5d3-ee74-40bc-ba45-7d3cfcc84938' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ImprovementRes1AV')) BEGIN
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
            '3f0aa5d3-ee74-40bc-ba45-7d3cfcc84938',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100018,
            'ImprovementRes1AV',
            'Improvement Res 1AV',
            'Imp Res (1): improvement value under the 1% cap. The three Improvement tiers sum to ImprovementAV.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '04b7eab2-7972-4d15-8cd8-930bd9d48087' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ImprovementNonRes2AV')) BEGIN
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
            '04b7eab2-7972-4d15-8cd8-930bd9d48087',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100019,
            'ImprovementNonRes2AV',
            'Improvement Non Res 2AV',
            'Imp Non Res (2): improvement value under the 2% cap.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e9ea8f1a-dc8b-415b-b35e-ef9be39f9b53' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ImprovementNonRes3AV')) BEGIN
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
            'e9ea8f1a-dc8b-415b-b35e-ef9be39f9b53',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100020,
            'ImprovementNonRes3AV',
            'Improvement Non Res 3AV',
            'Imp Non Res (3): improvement value under the 3% cap.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a68cf354-dcc5-492e-9351-5e2c6eb8c437' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'TotalRes1AV')) BEGIN
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
            'a68cf354-dcc5-492e-9351-5e2c6eb8c437',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100021,
            'TotalRes1AV',
            'Total Res 1AV',
            'Total Res (1): total value under the 1% cap. The three Total tiers sum to TotalAV.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3a0b0650-da05-40cf-bf35-2e05289e74d9' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'TotalNonRes2AV')) BEGIN
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
            '3a0b0650-da05-40cf-bf35-2e05289e74d9',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100022,
            'TotalNonRes2AV',
            'Total Non Res 2AV',
            'Total Non Res (2): total value under the 2% cap.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3832c55b-5869-4d13-8c01-1d3e432075c5' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'TotalNonRes3AV')) BEGIN
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
            '3832c55b-5869-4d13-8c01-1d3e432075c5',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100023,
            'TotalNonRes3AV',
            'Total Non Res 3AV',
            'Total Non Res (3): total value under the 3% cap.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '49184452-1ece-4b0a-a024-fcb21f37515e' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = '__mj_CreatedAt')) BEGIN
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
            '49184452-1ece-4b0a-a024-fcb21f37515e',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100024,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '62025de0-1057-47e4-a9a1-9b35855cba17' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '62025de0-1057-47e4-a9a1-9b35855cba17',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100025,
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

/* SQL text to insert entity field value with ID eea89b65-fc21-48cd-80f7-a87a2176ba2a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('eea89b65-fc21-48cd-80f7-a87a2176ba2a', '15A446C2-25A1-4348-934B-C5FC8130A757', 1, 'I', 'I', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f8103a5f-4477-4e39-a107-d86944005df7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f8103a5f-4477-4e39-a107-d86944005df7', '15A446C2-25A1-4348-934B-C5FC8130A757', 2, 'V', 'V', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 15A446C2-25A1-4348-934B-C5FC8130A757 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='15A446C2-25A1-4348-934B-C5FC8130A757';

/* SQL text to insert entity field value with ID 4b089af4-26ae-4804-946d-56470c35f072 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4b089af4-26ae-4804-946d-56470c35f072', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 1, 'annual', 'annual', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 63a696ec-17d2-4fe7-a125-6c0955eb4ea4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('63a696ec-17d2-4fe7-a125-6c0955eb4ea4', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 2, 'appeal', 'appeal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID fac7d873-7ba0-4f39-be4e-2a024a707af9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fac7d873-7ba0-4f39-be4e-2a024a707af9', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 3, 'blank', 'blank', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 57510e6a-a6f0-4c7d-9767-cd6d5b74dd08 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('57510e6a-a6f0-4c7d-9767-cd6d5b74dd08', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 4, 'other', 'other', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 069c7a3d-3c70-465e-b349-a0583b9f3da6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('069c7a3d-3c70-465e-b349-a0583b9f3da6', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 5, 'reval', 'reval', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 14e2525b-c8b4-4221-8c81-743d0ebbad02 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('14e2525b-c8b4-4221-8c81-743d0ebbad02', 'B4E841AA-EF47-46F8-8601-32E789DCEC45', 6, 'wip', 'wip', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID B4E841AA-EF47-46F8-8601-32E789DCEC45 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='B4E841AA-EF47-46F8-8601-32E789DCEC45';

/* SQL text to insert entity field value with ID db926b1c-d1b0-4dfe-9f59-51962b0bdab3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('db926b1c-d1b0-4dfe-9f59-51962b0bdab3', '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85', 1, 'appeal', 'appeal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 11a69b25-44bd-4006-82db-48d263afad86 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('11a69b25-44bd-4006-82db-48d263afad86', '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85', 2, 'other', 'other', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a201ec6a-b9ae-4d34-942d-575d6e123ef6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a201ec6a-b9ae-4d34-942d-575d6e123ef6', '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85', 3, 'permit', 'permit', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 4AFE50C1-CD14-4BFB-897C-8076B5CF3F85 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='4AFE50C1-CD14-4BFB-897C-8076B5CF3F85';


/* Create Entity Relationship: Source Documents -> Card Notes (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'fb828b41-cd7d-4e67-b50d-4edf0b685b6b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('fb828b41-cd7d-4e67-b50d-4edf0b685b6b', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '2A7BD138-666D-4835-B591-256380F7775B', 'SourceDocumentID', 'One To Many', 1, 1, 26, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Source Documents -> Card Valuation Columns (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '6c2c0901-9635-4078-85cd-34b634471736'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6c2c0901-9635-4078-85cd-34b634471736', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', 'SourceDocumentID', 'One To Many', 1, 1, 27, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Card Valuation Columns (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'fe961632-0de2-4e34-8556-52d520d5aa4e'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('fe961632-0de2-4e34-8556-52d520d5aa4e', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', 'ParcelID', 'One To Many', 1, 1, 22, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Card Notes (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a0fc3a75-599a-4794-8959-9044b3af6837'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a0fc3a75-599a-4794-8959-9044b3af6837', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '2A7BD138-666D-4835-B591-256380F7775B', 'ParcelID', 'One To Many', 1, 1, 23, GETUTCDATE(), GETUTCDATE())
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

/* Index for Foreign Keys for CardNote */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardNote_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardNote_SourceDocumentID ON [indiana_tax].[CardNote] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardNote_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardNote_ParcelID ON [indiana_tax].[CardNote] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID D6D5C679-C93C-492A-BA98-9B9DAD50B7C3 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D6D5C679-C93C-492A-BA98-9B9DAD50B7C3', @RelatedEntityNameFieldMap='Parcel';

/* Index for Foreign Keys for CardValuationColumn */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardValuationColumn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardValuationColumn_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardValuationColumn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardValuationColumn_SourceDocumentID ON [indiana_tax].[CardValuationColumn] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardValuationColumn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardValuationColumn_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardValuationColumn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardValuationColumn_ParcelID ON [indiana_tax].[CardValuationColumn] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 0A3F512D-169B-4B7F-912A-2E9FA2F8C356 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0A3F512D-169B-4B7F-912A-2E9FA2F8C356', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: vwCardValuationColumns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Valuation Columns
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardValuationColumn
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardValuationColumns]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardValuationColumns];
GO

CREATE VIEW [indiana_tax].[vwCardValuationColumns]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardValuationColumn] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardValuationColumns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: Permissions for vwCardValuationColumns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardValuationColumns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spCreateCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardValuationColumn]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @ColumnIndex smallint,
    @AssessmentYear smallint,
    @IsCertified bit,
    @ReasonForChange_Clear bit = 0,
    @ReasonForChange nvarchar(50) = NULL,
    @ReasonKind nvarchar(10),
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @ValuationMethod_Clear bit = 0,
    @ValuationMethod nvarchar(50) = NULL,
    @LandAV_Clear bit = 0,
    @LandAV decimal(14, 2) = NULL,
    @ImprovementAV_Clear bit = 0,
    @ImprovementAV decimal(14, 2) = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(14, 2) = NULL,
    @LandRes1AV_Clear bit = 0,
    @LandRes1AV decimal(14, 2) = NULL,
    @LandNonRes2AV_Clear bit = 0,
    @LandNonRes2AV decimal(14, 2) = NULL,
    @LandNonRes3AV_Clear bit = 0,
    @LandNonRes3AV decimal(14, 2) = NULL,
    @ImprovementRes1AV_Clear bit = 0,
    @ImprovementRes1AV decimal(14, 2) = NULL,
    @ImprovementNonRes2AV_Clear bit = 0,
    @ImprovementNonRes2AV decimal(14, 2) = NULL,
    @ImprovementNonRes3AV_Clear bit = 0,
    @ImprovementNonRes3AV decimal(14, 2) = NULL,
    @TotalRes1AV_Clear bit = 0,
    @TotalRes1AV decimal(14, 2) = NULL,
    @TotalNonRes2AV_Clear bit = 0,
    @TotalNonRes2AV decimal(14, 2) = NULL,
    @TotalNonRes3AV_Clear bit = 0,
    @TotalNonRes3AV decimal(14, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardValuationColumn]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [ColumnIndex],
                [AssessmentYear],
                [IsCertified],
                [ReasonForChange],
                [ReasonKind],
                [AsOfDate],
                [ValuationMethod],
                [LandAV],
                [ImprovementAV],
                [TotalAV],
                [LandRes1AV],
                [LandNonRes2AV],
                [LandNonRes3AV],
                [ImprovementRes1AV],
                [ImprovementNonRes2AV],
                [ImprovementNonRes3AV],
                [TotalRes1AV],
                [TotalNonRes2AV],
                [TotalNonRes3AV]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @ColumnIndex,
                @AssessmentYear,
                @IsCertified,
                CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, NULL) END,
                @ReasonKind,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, NULL) END,
                CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, NULL) END,
                CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, NULL) END,
                CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, NULL) END,
                CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, NULL) END,
                CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, NULL) END,
                CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, NULL) END,
                CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, NULL) END,
                CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, NULL) END,
                CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, NULL) END,
                CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardValuationColumn]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [ColumnIndex],
                [AssessmentYear],
                [IsCertified],
                [ReasonForChange],
                [ReasonKind],
                [AsOfDate],
                [ValuationMethod],
                [LandAV],
                [ImprovementAV],
                [TotalAV],
                [LandRes1AV],
                [LandNonRes2AV],
                [LandNonRes3AV],
                [ImprovementRes1AV],
                [ImprovementNonRes2AV],
                [ImprovementNonRes3AV],
                [TotalRes1AV],
                [TotalNonRes2AV],
                [TotalNonRes3AV]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @ColumnIndex,
                @AssessmentYear,
                @IsCertified,
                CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, NULL) END,
                @ReasonKind,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, NULL) END,
                CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, NULL) END,
                CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, NULL) END,
                CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, NULL) END,
                CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, NULL) END,
                CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, NULL) END,
                CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, NULL) END,
                CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, NULL) END,
                CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, NULL) END,
                CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, NULL) END,
                CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardValuationColumns] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spCreateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spUpdateCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardValuationColumn]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @ColumnIndex smallint = NULL,
    @AssessmentYear smallint = NULL,
    @IsCertified bit = NULL,
    @ReasonForChange_Clear bit = 0,
    @ReasonForChange nvarchar(50) = NULL,
    @ReasonKind nvarchar(10) = NULL,
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @ValuationMethod_Clear bit = 0,
    @ValuationMethod nvarchar(50) = NULL,
    @LandAV_Clear bit = 0,
    @LandAV decimal(14, 2) = NULL,
    @ImprovementAV_Clear bit = 0,
    @ImprovementAV decimal(14, 2) = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(14, 2) = NULL,
    @LandRes1AV_Clear bit = 0,
    @LandRes1AV decimal(14, 2) = NULL,
    @LandNonRes2AV_Clear bit = 0,
    @LandNonRes2AV decimal(14, 2) = NULL,
    @LandNonRes3AV_Clear bit = 0,
    @LandNonRes3AV decimal(14, 2) = NULL,
    @ImprovementRes1AV_Clear bit = 0,
    @ImprovementRes1AV decimal(14, 2) = NULL,
    @ImprovementNonRes2AV_Clear bit = 0,
    @ImprovementNonRes2AV decimal(14, 2) = NULL,
    @ImprovementNonRes3AV_Clear bit = 0,
    @ImprovementNonRes3AV decimal(14, 2) = NULL,
    @TotalRes1AV_Clear bit = 0,
    @TotalRes1AV decimal(14, 2) = NULL,
    @TotalNonRes2AV_Clear bit = 0,
    @TotalNonRes2AV decimal(14, 2) = NULL,
    @TotalNonRes3AV_Clear bit = 0,
    @TotalNonRes3AV decimal(14, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardValuationColumn]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [ColumnIndex] = ISNULL(@ColumnIndex, [ColumnIndex]),
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [IsCertified] = ISNULL(@IsCertified, [IsCertified]),
        [ReasonForChange] = CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, [ReasonForChange]) END,
        [ReasonKind] = ISNULL(@ReasonKind, [ReasonKind]),
        [AsOfDate] = CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, [AsOfDate]) END,
        [ValuationMethod] = CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, [ValuationMethod]) END,
        [LandAV] = CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, [LandAV]) END,
        [ImprovementAV] = CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, [ImprovementAV]) END,
        [TotalAV] = CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, [TotalAV]) END,
        [LandRes1AV] = CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, [LandRes1AV]) END,
        [LandNonRes2AV] = CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, [LandNonRes2AV]) END,
        [LandNonRes3AV] = CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, [LandNonRes3AV]) END,
        [ImprovementRes1AV] = CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, [ImprovementRes1AV]) END,
        [ImprovementNonRes2AV] = CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, [ImprovementNonRes2AV]) END,
        [ImprovementNonRes3AV] = CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, [ImprovementNonRes3AV]) END,
        [TotalRes1AV] = CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, [TotalRes1AV]) END,
        [TotalNonRes2AV] = CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, [TotalNonRes2AV]) END,
        [TotalNonRes3AV] = CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, [TotalNonRes3AV]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardValuationColumns] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardValuationColumns]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardValuationColumn] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardValuationColumn table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardValuationColumn]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardValuationColumn];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardValuationColumn
ON [indiana_tax].[CardValuationColumn]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardValuationColumn]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardValuationColumn] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spDeleteCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardValuationColumn]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardValuationColumn]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: vwCardNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Notes
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardNote
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardNotes]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardNotes];
GO

CREATE VIEW [indiana_tax].[vwCardNotes]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardNote] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: Permissions for vwCardNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spCreateCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardNote]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @EntryIndex smallint,
    @NoteDate_Clear bit = 0,
    @NoteDate date = NULL,
    @NoteCode_Clear bit = 0,
    @NoteCode nvarchar(20) = NULL,
    @NoteKind nvarchar(10),
    @NoteText nvarchar(MAX),
    @NoteKey char(64)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardNote]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [NoteDate],
                [NoteCode],
                [NoteKind],
                [NoteText],
                [NoteKey]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, NULL) END,
                CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, NULL) END,
                @NoteKind,
                @NoteText,
                @NoteKey
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardNote]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [NoteDate],
                [NoteCode],
                [NoteKind],
                [NoteText],
                [NoteKey]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, NULL) END,
                CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, NULL) END,
                @NoteKind,
                @NoteText,
                @NoteKey
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardNotes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spCreateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spUpdateCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardNote]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @EntryIndex smallint = NULL,
    @NoteDate_Clear bit = 0,
    @NoteDate date = NULL,
    @NoteCode_Clear bit = 0,
    @NoteCode nvarchar(20) = NULL,
    @NoteKind nvarchar(10) = NULL,
    @NoteText nvarchar(MAX) = NULL,
    @NoteKey char(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardNote]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [EntryIndex] = ISNULL(@EntryIndex, [EntryIndex]),
        [NoteDate] = CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, [NoteDate]) END,
        [NoteCode] = CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, [NoteCode]) END,
        [NoteKind] = ISNULL(@NoteKind, [NoteKind]),
        [NoteText] = ISNULL(@NoteText, [NoteText]),
        [NoteKey] = ISNULL(@NoteKey, [NoteKey])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardNotes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardNotes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardNote] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardNote table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardNote]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardNote];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardNote
ON [indiana_tax].[CardNote]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardNote]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardNote] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spDeleteCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardNote]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardNote]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardNote] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for CountyAssessorImprovement */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyAssessorRecordID in table CountyAssessorImprovement
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorImprovement_CountyAssessorRecordID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorImprovement]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorImprovement_CountyAssessorRecordID ON [indiana_tax].[CountyAssessorImprovement] ([CountyAssessorRecordID]);

/* Base View SQL for County Assessor Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: vwCountyAssessorImprovements
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      County Assessor Improvements
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CountyAssessorImprovement
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCountyAssessorImprovements]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCountyAssessorImprovements];
GO

CREATE VIEW [indiana_tax].[vwCountyAssessorImprovements]
AS
SELECT
    c.*,
    indianataxCountyAssessorRecord_CountyAssessorRecordID.[OwnerName] AS [CountyAssessorRecord]
FROM
    [indiana_tax].[CountyAssessorImprovement] AS c
INNER JOIN
    [indiana_tax].[CountyAssessorRecord] AS indianataxCountyAssessorRecord_CountyAssessorRecordID
  ON
    [c].[CountyAssessorRecordID] = indianataxCountyAssessorRecord_CountyAssessorRecordID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCountyAssessorImprovements] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for County Assessor Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: Permissions for vwCountyAssessorImprovements
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCountyAssessorImprovements] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for County Assessor Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: spCreateCountyAssessorImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CountyAssessorImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCountyAssessorImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCountyAssessorImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCountyAssessorImprovement]
    @ID uniqueidentifier = NULL,
    @CountyAssessorRecordID uniqueidentifier,
    @CardNumber_Clear bit = 0,
    @CardNumber nvarchar(10) = NULL,
    @Use_Clear bit = 0,
    @Use nvarchar(50) = NULL,
    @Grade_Clear bit = 0,
    @Grade nvarchar(50) = NULL,
    @YearConstructed_Clear bit = 0,
    @YearConstructed smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @Condition_Clear bit = 0,
    @Condition nvarchar(50) = NULL,
    @SizeOrArea_Clear bit = 0,
    @SizeOrArea decimal(14, 2) = NULL,
    @ReproductionCost_Clear bit = 0,
    @ReproductionCost decimal(14, 2) = NULL,
    @DepreciationObsolescence_Clear bit = 0,
    @DepreciationObsolescence decimal(14, 2) = NULL,
    @RemainderValue_Clear bit = 0,
    @RemainderValue decimal(14, 2) = NULL,
    @PctComplete_Clear bit = 0,
    @PctComplete decimal(5, 2) = NULL,
    @TrendFactor_Clear bit = 0,
    @TrendFactor decimal(9, 4) = NULL,
    @TrueTaxValue_Clear bit = 0,
    @TrueTaxValue decimal(14, 2) = NULL,
    @Quantity_Clear bit = 0,
    @Quantity smallint = NULL,
    @SizeText_Clear bit = 0,
    @SizeText nvarchar(30) = NULL,
    @AbnormalObsolescencePct_Clear bit = 0,
    @AbnormalObsolescencePct decimal(5, 2) = NULL,
    @NeighborhoodFactor_Clear bit = 0,
    @NeighborhoodFactor decimal(9, 4) = NULL,
    @Cap1Pct_Clear bit = 0,
    @Cap1Pct decimal(5, 2) = NULL,
    @Cap2Pct_Clear bit = 0,
    @Cap2Pct decimal(5, 2) = NULL,
    @Cap3Pct_Clear bit = 0,
    @Cap3Pct decimal(5, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CountyAssessorImprovement]
            (
                [ID],
                [CountyAssessorRecordID],
                [CardNumber],
                [Use],
                [Grade],
                [YearConstructed],
                [EffectiveYear],
                [Condition],
                [SizeOrArea],
                [ReproductionCost],
                [DepreciationObsolescence],
                [RemainderValue],
                [PctComplete],
                [TrendFactor],
                [TrueTaxValue],
                [Quantity],
                [SizeText],
                [AbnormalObsolescencePct],
                [NeighborhoodFactor],
                [Cap1Pct],
                [Cap2Pct],
                [Cap3Pct]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyAssessorRecordID,
                CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, NULL) END,
                CASE WHEN @Use_Clear = 1 THEN NULL ELSE ISNULL(@Use, NULL) END,
                CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, NULL) END,
                CASE WHEN @YearConstructed_Clear = 1 THEN NULL ELSE ISNULL(@YearConstructed, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, NULL) END,
                CASE WHEN @SizeOrArea_Clear = 1 THEN NULL ELSE ISNULL(@SizeOrArea, NULL) END,
                CASE WHEN @ReproductionCost_Clear = 1 THEN NULL ELSE ISNULL(@ReproductionCost, NULL) END,
                CASE WHEN @DepreciationObsolescence_Clear = 1 THEN NULL ELSE ISNULL(@DepreciationObsolescence, NULL) END,
                CASE WHEN @RemainderValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainderValue, NULL) END,
                CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, NULL) END,
                CASE WHEN @TrendFactor_Clear = 1 THEN NULL ELSE ISNULL(@TrendFactor, NULL) END,
                CASE WHEN @TrueTaxValue_Clear = 1 THEN NULL ELSE ISNULL(@TrueTaxValue, NULL) END,
                CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, NULL) END,
                CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, NULL) END,
                CASE WHEN @AbnormalObsolescencePct_Clear = 1 THEN NULL ELSE ISNULL(@AbnormalObsolescencePct, NULL) END,
                CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, NULL) END,
                CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, NULL) END,
                CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, NULL) END,
                CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CountyAssessorImprovement]
            (
                [CountyAssessorRecordID],
                [CardNumber],
                [Use],
                [Grade],
                [YearConstructed],
                [EffectiveYear],
                [Condition],
                [SizeOrArea],
                [ReproductionCost],
                [DepreciationObsolescence],
                [RemainderValue],
                [PctComplete],
                [TrendFactor],
                [TrueTaxValue],
                [Quantity],
                [SizeText],
                [AbnormalObsolescencePct],
                [NeighborhoodFactor],
                [Cap1Pct],
                [Cap2Pct],
                [Cap3Pct]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyAssessorRecordID,
                CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, NULL) END,
                CASE WHEN @Use_Clear = 1 THEN NULL ELSE ISNULL(@Use, NULL) END,
                CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, NULL) END,
                CASE WHEN @YearConstructed_Clear = 1 THEN NULL ELSE ISNULL(@YearConstructed, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, NULL) END,
                CASE WHEN @SizeOrArea_Clear = 1 THEN NULL ELSE ISNULL(@SizeOrArea, NULL) END,
                CASE WHEN @ReproductionCost_Clear = 1 THEN NULL ELSE ISNULL(@ReproductionCost, NULL) END,
                CASE WHEN @DepreciationObsolescence_Clear = 1 THEN NULL ELSE ISNULL(@DepreciationObsolescence, NULL) END,
                CASE WHEN @RemainderValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainderValue, NULL) END,
                CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, NULL) END,
                CASE WHEN @TrendFactor_Clear = 1 THEN NULL ELSE ISNULL(@TrendFactor, NULL) END,
                CASE WHEN @TrueTaxValue_Clear = 1 THEN NULL ELSE ISNULL(@TrueTaxValue, NULL) END,
                CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, NULL) END,
                CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, NULL) END,
                CASE WHEN @AbnormalObsolescencePct_Clear = 1 THEN NULL ELSE ISNULL(@AbnormalObsolescencePct, NULL) END,
                CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, NULL) END,
                CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, NULL) END,
                CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, NULL) END,
                CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCountyAssessorImprovements] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for County Assessor Improvements */

GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for County Assessor Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: spUpdateCountyAssessorImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CountyAssessorImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCountyAssessorImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCountyAssessorImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCountyAssessorImprovement]
    @ID uniqueidentifier,
    @CountyAssessorRecordID uniqueidentifier = NULL,
    @CardNumber_Clear bit = 0,
    @CardNumber nvarchar(10) = NULL,
    @Use_Clear bit = 0,
    @Use nvarchar(50) = NULL,
    @Grade_Clear bit = 0,
    @Grade nvarchar(50) = NULL,
    @YearConstructed_Clear bit = 0,
    @YearConstructed smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @Condition_Clear bit = 0,
    @Condition nvarchar(50) = NULL,
    @SizeOrArea_Clear bit = 0,
    @SizeOrArea decimal(14, 2) = NULL,
    @ReproductionCost_Clear bit = 0,
    @ReproductionCost decimal(14, 2) = NULL,
    @DepreciationObsolescence_Clear bit = 0,
    @DepreciationObsolescence decimal(14, 2) = NULL,
    @RemainderValue_Clear bit = 0,
    @RemainderValue decimal(14, 2) = NULL,
    @PctComplete_Clear bit = 0,
    @PctComplete decimal(5, 2) = NULL,
    @TrendFactor_Clear bit = 0,
    @TrendFactor decimal(9, 4) = NULL,
    @TrueTaxValue_Clear bit = 0,
    @TrueTaxValue decimal(14, 2) = NULL,
    @Quantity_Clear bit = 0,
    @Quantity smallint = NULL,
    @SizeText_Clear bit = 0,
    @SizeText nvarchar(30) = NULL,
    @AbnormalObsolescencePct_Clear bit = 0,
    @AbnormalObsolescencePct decimal(5, 2) = NULL,
    @NeighborhoodFactor_Clear bit = 0,
    @NeighborhoodFactor decimal(9, 4) = NULL,
    @Cap1Pct_Clear bit = 0,
    @Cap1Pct decimal(5, 2) = NULL,
    @Cap2Pct_Clear bit = 0,
    @Cap2Pct decimal(5, 2) = NULL,
    @Cap3Pct_Clear bit = 0,
    @Cap3Pct decimal(5, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorImprovement]
    SET
        [CountyAssessorRecordID] = ISNULL(@CountyAssessorRecordID, [CountyAssessorRecordID]),
        [CardNumber] = CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, [CardNumber]) END,
        [Use] = CASE WHEN @Use_Clear = 1 THEN NULL ELSE ISNULL(@Use, [Use]) END,
        [Grade] = CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, [Grade]) END,
        [YearConstructed] = CASE WHEN @YearConstructed_Clear = 1 THEN NULL ELSE ISNULL(@YearConstructed, [YearConstructed]) END,
        [EffectiveYear] = CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, [EffectiveYear]) END,
        [Condition] = CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, [Condition]) END,
        [SizeOrArea] = CASE WHEN @SizeOrArea_Clear = 1 THEN NULL ELSE ISNULL(@SizeOrArea, [SizeOrArea]) END,
        [ReproductionCost] = CASE WHEN @ReproductionCost_Clear = 1 THEN NULL ELSE ISNULL(@ReproductionCost, [ReproductionCost]) END,
        [DepreciationObsolescence] = CASE WHEN @DepreciationObsolescence_Clear = 1 THEN NULL ELSE ISNULL(@DepreciationObsolescence, [DepreciationObsolescence]) END,
        [RemainderValue] = CASE WHEN @RemainderValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainderValue, [RemainderValue]) END,
        [PctComplete] = CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, [PctComplete]) END,
        [TrendFactor] = CASE WHEN @TrendFactor_Clear = 1 THEN NULL ELSE ISNULL(@TrendFactor, [TrendFactor]) END,
        [TrueTaxValue] = CASE WHEN @TrueTaxValue_Clear = 1 THEN NULL ELSE ISNULL(@TrueTaxValue, [TrueTaxValue]) END,
        [Quantity] = CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, [Quantity]) END,
        [SizeText] = CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, [SizeText]) END,
        [AbnormalObsolescencePct] = CASE WHEN @AbnormalObsolescencePct_Clear = 1 THEN NULL ELSE ISNULL(@AbnormalObsolescencePct, [AbnormalObsolescencePct]) END,
        [NeighborhoodFactor] = CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, [NeighborhoodFactor]) END,
        [Cap1Pct] = CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, [Cap1Pct]) END,
        [Cap2Pct] = CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, [Cap2Pct]) END,
        [Cap3Pct] = CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, [Cap3Pct]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCountyAssessorImprovements] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCountyAssessorImprovements]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CountyAssessorImprovement table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCountyAssessorImprovement]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCountyAssessorImprovement];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCountyAssessorImprovement
ON [indiana_tax].[CountyAssessorImprovement]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorImprovement]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CountyAssessorImprovement] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for County Assessor Improvements */

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for County Assessor Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Improvements
-- Item: spDeleteCountyAssessorImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CountyAssessorImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCountyAssessorImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCountyAssessorImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCountyAssessorImprovement]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CountyAssessorImprovement]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for County Assessor Improvements */

GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorImprovement] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for CountyAssessorSaleHistory */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyAssessorRecordID in table CountyAssessorSaleHistory
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorSaleHistory_CountyAssessorRecordID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorSaleHistory]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorSaleHistory_CountyAssessorRecordID ON [indiana_tax].[CountyAssessorSaleHistory] ([CountyAssessorRecordID]);

/* Base View SQL for County Assessor Sale Histories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: vwCountyAssessorSaleHistories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      County Assessor Sale Histories
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CountyAssessorSaleHistory
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCountyAssessorSaleHistories]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCountyAssessorSaleHistories];
GO

CREATE VIEW [indiana_tax].[vwCountyAssessorSaleHistories]
AS
SELECT
    c.*,
    indianataxCountyAssessorRecord_CountyAssessorRecordID.[OwnerName] AS [CountyAssessorRecord]
FROM
    [indiana_tax].[CountyAssessorSaleHistory] AS c
INNER JOIN
    [indiana_tax].[CountyAssessorRecord] AS indianataxCountyAssessorRecord_CountyAssessorRecordID
  ON
    [c].[CountyAssessorRecordID] = indianataxCountyAssessorRecord_CountyAssessorRecordID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCountyAssessorSaleHistories] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for County Assessor Sale Histories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: Permissions for vwCountyAssessorSaleHistories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCountyAssessorSaleHistories] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for County Assessor Sale Histories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: spCreateCountyAssessorSaleHistory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CountyAssessorSaleHistory
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCountyAssessorSaleHistory]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCountyAssessorSaleHistory];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCountyAssessorSaleHistory]
    @ID uniqueidentifier = NULL,
    @CountyAssessorRecordID uniqueidentifier,
    @SaleDate_Clear bit = 0,
    @SaleDate date = NULL,
    @GrantorName_Clear bit = 0,
    @GrantorName nvarchar(300) = NULL,
    @IsValidSale_Clear bit = 0,
    @IsValidSale bit = NULL,
    @SaleAmount_Clear bit = 0,
    @SaleAmount decimal(14, 2) = NULL,
    @SaleType_Clear bit = 0,
    @SaleType nvarchar(50) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(300) = NULL,
    @DocID_Clear bit = 0,
    @DocID nvarchar(50) = NULL,
    @BookPage_Clear bit = 0,
    @BookPage nvarchar(50) = NULL,
    @VacantOrImproved_Clear bit = 0,
    @VacantOrImproved nvarchar(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CountyAssessorSaleHistory]
            (
                [ID],
                [CountyAssessorRecordID],
                [SaleDate],
                [GrantorName],
                [IsValidSale],
                [SaleAmount],
                [SaleType],
                [OwnerName],
                [DocID],
                [BookPage],
                [VacantOrImproved]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyAssessorRecordID,
                CASE WHEN @SaleDate_Clear = 1 THEN NULL ELSE ISNULL(@SaleDate, NULL) END,
                CASE WHEN @GrantorName_Clear = 1 THEN NULL ELSE ISNULL(@GrantorName, NULL) END,
                CASE WHEN @IsValidSale_Clear = 1 THEN NULL ELSE ISNULL(@IsValidSale, NULL) END,
                CASE WHEN @SaleAmount_Clear = 1 THEN NULL ELSE ISNULL(@SaleAmount, NULL) END,
                CASE WHEN @SaleType_Clear = 1 THEN NULL ELSE ISNULL(@SaleType, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @DocID_Clear = 1 THEN NULL ELSE ISNULL(@DocID, NULL) END,
                CASE WHEN @BookPage_Clear = 1 THEN NULL ELSE ISNULL(@BookPage, NULL) END,
                CASE WHEN @VacantOrImproved_Clear = 1 THEN NULL ELSE ISNULL(@VacantOrImproved, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CountyAssessorSaleHistory]
            (
                [CountyAssessorRecordID],
                [SaleDate],
                [GrantorName],
                [IsValidSale],
                [SaleAmount],
                [SaleType],
                [OwnerName],
                [DocID],
                [BookPage],
                [VacantOrImproved]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyAssessorRecordID,
                CASE WHEN @SaleDate_Clear = 1 THEN NULL ELSE ISNULL(@SaleDate, NULL) END,
                CASE WHEN @GrantorName_Clear = 1 THEN NULL ELSE ISNULL(@GrantorName, NULL) END,
                CASE WHEN @IsValidSale_Clear = 1 THEN NULL ELSE ISNULL(@IsValidSale, NULL) END,
                CASE WHEN @SaleAmount_Clear = 1 THEN NULL ELSE ISNULL(@SaleAmount, NULL) END,
                CASE WHEN @SaleType_Clear = 1 THEN NULL ELSE ISNULL(@SaleType, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @DocID_Clear = 1 THEN NULL ELSE ISNULL(@DocID, NULL) END,
                CASE WHEN @BookPage_Clear = 1 THEN NULL ELSE ISNULL(@BookPage, NULL) END,
                CASE WHEN @VacantOrImproved_Clear = 1 THEN NULL ELSE ISNULL(@VacantOrImproved, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCountyAssessorSaleHistories] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for County Assessor Sale Histories */

GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for County Assessor Sale Histories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: spUpdateCountyAssessorSaleHistory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CountyAssessorSaleHistory
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCountyAssessorSaleHistory]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCountyAssessorSaleHistory];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCountyAssessorSaleHistory]
    @ID uniqueidentifier,
    @CountyAssessorRecordID uniqueidentifier = NULL,
    @SaleDate_Clear bit = 0,
    @SaleDate date = NULL,
    @GrantorName_Clear bit = 0,
    @GrantorName nvarchar(300) = NULL,
    @IsValidSale_Clear bit = 0,
    @IsValidSale bit = NULL,
    @SaleAmount_Clear bit = 0,
    @SaleAmount decimal(14, 2) = NULL,
    @SaleType_Clear bit = 0,
    @SaleType nvarchar(50) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(300) = NULL,
    @DocID_Clear bit = 0,
    @DocID nvarchar(50) = NULL,
    @BookPage_Clear bit = 0,
    @BookPage nvarchar(50) = NULL,
    @VacantOrImproved_Clear bit = 0,
    @VacantOrImproved nvarchar(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorSaleHistory]
    SET
        [CountyAssessorRecordID] = ISNULL(@CountyAssessorRecordID, [CountyAssessorRecordID]),
        [SaleDate] = CASE WHEN @SaleDate_Clear = 1 THEN NULL ELSE ISNULL(@SaleDate, [SaleDate]) END,
        [GrantorName] = CASE WHEN @GrantorName_Clear = 1 THEN NULL ELSE ISNULL(@GrantorName, [GrantorName]) END,
        [IsValidSale] = CASE WHEN @IsValidSale_Clear = 1 THEN NULL ELSE ISNULL(@IsValidSale, [IsValidSale]) END,
        [SaleAmount] = CASE WHEN @SaleAmount_Clear = 1 THEN NULL ELSE ISNULL(@SaleAmount, [SaleAmount]) END,
        [SaleType] = CASE WHEN @SaleType_Clear = 1 THEN NULL ELSE ISNULL(@SaleType, [SaleType]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [DocID] = CASE WHEN @DocID_Clear = 1 THEN NULL ELSE ISNULL(@DocID, [DocID]) END,
        [BookPage] = CASE WHEN @BookPage_Clear = 1 THEN NULL ELSE ISNULL(@BookPage, [BookPage]) END,
        [VacantOrImproved] = CASE WHEN @VacantOrImproved_Clear = 1 THEN NULL ELSE ISNULL(@VacantOrImproved, [VacantOrImproved]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCountyAssessorSaleHistories] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCountyAssessorSaleHistories]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CountyAssessorSaleHistory table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCountyAssessorSaleHistory]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCountyAssessorSaleHistory];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCountyAssessorSaleHistory
ON [indiana_tax].[CountyAssessorSaleHistory]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorSaleHistory]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CountyAssessorSaleHistory] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for County Assessor Sale Histories */

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for County Assessor Sale Histories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Sale Histories
-- Item: spDeleteCountyAssessorSaleHistory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CountyAssessorSaleHistory
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCountyAssessorSaleHistory]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCountyAssessorSaleHistory];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCountyAssessorSaleHistory]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CountyAssessorSaleHistory]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for County Assessor Sale Histories */

GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorSaleHistory] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '17b0ea6d-bcb1-4329-9492-6e2792c7ac82' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'Parcel')) BEGIN
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
            '17b0ea6d-bcb1-4329-9492-6e2792c7ac82',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100025,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d46942d-0c28-4596-a605-b733e422271a' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'Parcel')) BEGIN
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
            '9d46942d-0c28-4596-a605-b733e422271a',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100051,
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
               SET DefaultInView = 1
               WHERE ID = '3994A36E-003B-4211-B9FD-31C2C473BDEC'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '3994A36E-003B-4211-B9FD-31C2C473BDEC'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'EE0BD1F2-32D2-4AB6-92EA-E297D816DBD9'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '3994A36E-003B-4211-B9FD-31C2C473BDEC'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'EE0BD1F2-32D2-4AB6-92EA-E297D816DBD9'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '623E8CA7-C500-4516-A3B2-910F9065B163'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FCE9A16E-8252-496B-AB45-FD001BA93B91'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D7467401-3359-4E82-AACF-DBF7043DF75B'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8B9C49F1-FC25-4EAD-AB63-64165F38A557'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '623E8CA7-C500-4516-A3B2-910F9065B163'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '623E8CA7-C500-4516-A3B2-910F9065B163'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '58578383-699C-4259-908A-6857C59BD146'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '623E8CA7-C500-4516-A3B2-910F9065B163'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '430DC138-34FF-44D8-B896-E858E3C249E9'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F4F23FD4-04A3-4C38-937D-EA51E5595B7A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B8DBBE0B-0F67-42C1-9E17-849B92D479BD'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '70E4A8E8-5A30-4172-8774-81DBCAE4384B'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B4E841AA-EF47-46F8-8601-32E789DCEC45'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'AE5E1636-3D66-4F13-847E-4006EBEE5DF0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FC948138-AF9A-45F9-9D38-8000F7F30BA7'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '2A35024D-EA9C-4755-814D-7D6C59538464'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'B4E841AA-EF47-46F8-8601-32E789DCEC45'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '73926FC0-9F95-4BFF-8B48-534240956C96'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'B4E841AA-EF47-46F8-8601-32E789DCEC45'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 13 fields */

-- UPDATE Entity Field Category Info Card Notes.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '05079A7B-8AEF-4EC6-8751-975763AA280A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0FD11AB2-F6D4-4940-8037-3E8A88C1386E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Reference',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D6D5C679-C93C-492A-BA98-9B9DAD50B7C3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Reference',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Number',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '17B0EA6D-BCB1-4329-9492-6E2792C7AC82' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Reference',
   GeneratedFormSection = 'Category',
   DisplayName = 'Assessment Year',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FCE9A16E-8252-496B-AB45-FD001BA93B91' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.EntryIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D7467401-3359-4E82-AACF-DBF7043DF75B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8B9C49F1-FC25-4EAD-AB63-64165F38A557' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '623E8CA7-C500-4516-A3B2-910F9065B163' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '58578383-699C-4259-908A-6857C59BD146' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'A6FF0D12-6E4D-4EF5-AB40-DFB4FB9C7B24' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7A27B4D3-432A-4FBC-8031-BE19DC42A6C0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B62DB10-FA52-41BC-A386-53DE6D511584' AND AutoUpdateCategory = 1;

/* Set categories for 14 fields */

-- UPDATE Entity Field Category Info County Assessor Sale Histories.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '93780E99-D427-4CB7-8EDF-6D86B7D59A32' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.CountyAssessorRecordID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E7531735-FF8A-4EDE-8473-EEDC78757539' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.SaleDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C59515B7-83A0-4F82-AF13-6B53D0D45337' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.GrantorName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DD2A9CE2-C5E9-4C25-AB7D-F6D10B541D9A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.OwnerName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Sale Participants',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3994A36E-003B-4211-B9FD-31C2C473BDEC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.IsValidSale 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6738FCE9-5227-41C6-86CC-9C19C900156D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.SaleAmount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DD388901-7AC6-4FB9-A60D-3115AD167FB5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.SaleType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F58E39CA-78FB-4033-8295-12ECFF87CB29' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.DocID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recording Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Document ID',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'EE0BD1F2-32D2-4AB6-92EA-E297D816DBD9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.BookPage 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recording Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Book/Page',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B198ABB3-29F8-4A9E-B40A-7470792A3208' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.VacantOrImproved 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Condition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Vacant or Improved',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '15A446C2-25A1-4348-934B-C5FC8130A757' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.CountyAssessorRecord 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5B5A6BCB-513D-4694-9612-D2FE1DFD0C7A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CD03E485-DA74-4A61-99AA-9B63FEE59DC4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Sale Histories.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '08C9ECA2-E6EF-4ACB-BBE7-298258D8E8ED' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-sticky-note */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-sticky-note', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '2A7BD138-666D-4835-B591-256380F7775B';

/* Update FieldCategoryInfo setting for entity */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Sale Participants":{"icon":"fa fa-handshake","description":"Grantor (seller) and owner (buyer) information for the transfer"},"Recording Information":{"icon":"fa fa-book","description":"Public record references including document ID and book/page location"},"Property Condition":{"icon":"fa fa-home","description":"Property status and characteristics at time of transfer"}}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND [Name] = 'FieldCategoryInfo';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8f460f69-20e2-4415-86e9-97e30b8e370c', '2A7BD138-666D-4835-B591-256380F7775B', 'FieldCategoryInfo', '{"Card Reference":{"icon":"fa fa-id-card","description":"Links note to parcel and identifies the assessment year and card printing"},"Note Content":{"icon":"fa fa-align-left","description":"The note''s content including date, code, classification type, text, and position"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed identifiers, audit timestamps, and technical deduplication fields"}}', GETUTCDATE(), GETUTCDATE());

/* Update FieldCategoryIcons setting (legacy) */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Sale Participants":"fa fa-handshake","Recording Information":"fa fa-book","Property Condition":"fa fa-home"}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '6EC9862B-F538-4E9E-9CB3-3C6A2C8C9A13' AND [Name] = 'FieldCategoryIcons';

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('d73ba92d-9aa8-4b20-b9ea-13e9eccdaf62', '2A7BD138-666D-4835-B591-256380F7775B', 'FieldCategoryIcons', '{"Card Reference":"fa fa-id-card","Note Content":"fa fa-align-left","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=false for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '2A7BD138-666D-4835-B591-256380F7775B';

/* Set categories for 25 fields */

-- UPDATE Entity Field Category Info County Assessor Improvements.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D96C6965-650D-41B1-BE0A-D46EB3FF075D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.CountyAssessorRecordID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9085CF52-71FD-4A01-B7CE-1C1448DEE1E5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.CardNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FDBE9708-600D-4DF6-93F5-9F071437A9C2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.CountyAssessorRecord 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'County Assessor Record Reference',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5492DFA5-254F-403D-BFF0-24240A327A21' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Use 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8653EB7C-4B20-441D-81FC-42A59F2058EA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Grade 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B8000225-D875-4ECF-AF67-556432AA6111' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.YearConstructed 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '82C4C4C8-EFF2-483B-A54F-EB73A1063D1E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.EffectiveYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4D4B10A3-984B-471E-BC31-88786528DB32' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Condition 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9E419905-9509-4E2B-AA52-98012EDC2602' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.SizeOrArea 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7D4CEC6E-BC2E-424E-83BD-21AA53F7AADC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.SizeText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Structure Measurements',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9029FE57-3D0D-4CDD-B1AC-E580BE9B6732' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Quantity 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Structure Measurements',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E11D1544-D548-48FC-8906-47CFA2FFEC3D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.PctComplete 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ACA970D2-F813-4821-BE70-B24AA9775BA6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.ReproductionCost 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '433814E1-6DA7-4B24-858A-17BA70E6EF1C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.DepreciationObsolescence 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Depreciation & Obsolescence',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A6848516-2059-48C6-BD73-0CA2CFBFFA2A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.AbnormalObsolescencePct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Abnormal Obsolescence %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '74A5DFBD-5061-4714-9A75-258CE6DB29AE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.RemainderValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BBB49A4F-48F5-47E2-AEEE-74FB0EA605BF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.NeighborhoodFactor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D944FF31-2BC1-4FE1-812A-747BC33A8E7B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.TrendFactor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A3B7EA50-DF8C-45B9-A82B-661172CEB284' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.TrueTaxValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C2E04FB1-A58A-4649-8C8B-49A5527D4887' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Cap1Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 1 %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FFC0C9D5-94C4-44FA-8333-6C63205E3D9D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Cap2Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 2 %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B34199A8-97BB-4BE5-96A9-6F97709A94DA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.Cap3Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 3 %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '93CD20AB-A273-483E-8BF3-AE46736D45C1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A97B0150-5813-4B04-BEA7-FF3ADDD41475' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Improvements.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8D74BCFA-7C44-4369-B5CB-4FDEFF338105' AND AutoUpdateCategory = 1;

/* Set categories for 26 fields */

-- UPDATE Entity Field Category Info Card Valuation Columns.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Record Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7B56E5B2-7E28-4B70-8A35-85DA9EE85C0F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Record Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Source Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2861EBD4-57C4-4C8D-B289-6A11F438E714' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Record Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A3F512D-169B-4B7F-912A-2E9FA2F8C356' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Record Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel ID',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9D46942D-0C28-4596-A605-B733E422271A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '430DC138-34FF-44D8-B896-E858E3C249E9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ColumnIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F4F23FD4-04A3-4C38-937D-EA51E5595B7A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B8DBBE0B-0F67-42C1-9E17-849B92D479BD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.IsCertified 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '70E4A8E8-5A30-4172-8774-81DBCAE4384B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.AsOfDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AE5E1636-3D66-4F13-847E-4006EBEE5DF0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ReasonForChange 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Changes',
   GeneratedFormSection = 'Category',
   DisplayName = 'Reason for Change',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2A35024D-EA9C-4755-814D-7D6C59538464' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ReasonKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Changes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B4E841AA-EF47-46F8-8601-32E789DCEC45' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ValuationMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Changes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '73926FC0-9F95-4BFF-8B48-534240956C96' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Land Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2E17E63A-92ED-4FD7-B1C9-3F323C8E8246' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Land Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Residential (1%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5D3CF08B-3716-4210-A421-7A9826F2E5FA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Land Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Non-Residential (2%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F43EF7FB-CCFA-46C9-8BFA-823421A363DA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Land Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Non-Residential (3%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '59DA306A-8CC6-49E1-85E9-ED1EF2047FF7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9D48DD89-DD16-482B-9E6A-7707365EE133' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Residential (1%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3F0AA5D3-EE74-40BC-BA45-7D3CFCC84938' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Non-Residential (2%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04B7EAB2-7972-4D15-8CD8-930BD9D48087' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Non-Residential (3%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E9EA8F1A-DC8B-415B-B35E-EF9BE39F9B53' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Total Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FC948138-AF9A-45F9-9D38-8000F7F30BA7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Total Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Residential (1%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A68CF354-DCC5-492E-9351-5E2C6EB8C437' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Total Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Non-Residential (2%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3A0B0650-DA05-40CF-BF35-2E05289E74D9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Total Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Non-Residential (3%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3832C55B-5869-4D13-8C01-1D3E432075C5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '49184452-1ECE-4B0A-A024-FCB21F37515E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '62025DE0-1057-47E4-A9A1-9B35855CBA17' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-invoice */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-invoice', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('3b676221-0b99-4bfd-82da-d10f1a1a4efb', '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', 'FieldCategoryInfo', '{"Record Identification":{"icon":"fa fa-key","description":"Unique identifiers and references linking to source documents and parcels"},"Card Information":{"icon":"fa fa-id-card","description":"Physical card details including assessment year and column position"},"Valuation Timeline":{"icon":"fa fa-calendar","description":"Assessment years, certification status, and effective dates"},"Valuation Changes":{"icon":"fa fa-exchange-alt","description":"Reasons for changes, valuation methods, and modification history"},"Land Valuation":{"icon":"fa fa-map","description":"Land assessed values split by cap tier (1%, 2%, 3%)"},"Improvement Valuation":{"icon":"fa fa-building","description":"Improvement assessed values split by cap tier (1%, 2%, 3%)"},"Total Valuation":{"icon":"fa fa-dollar-sign","description":"Combined total assessed values split by cap tier (1%, 2%, 3%)"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('582c5bc4-79ef-41b8-aa40-2363c00751cb', '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', 'FieldCategoryIcons', '{"Record Identification":"fa fa-key","Card Information":"fa fa-id-card","Valuation Timeline":"fa fa-calendar","Valuation Changes":"fa fa-exchange-alt","Land Valuation":"fa fa-map","Improvement Valuation":"fa fa-building","Total Valuation":"fa fa-dollar-sign","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7';

/* Generated Validation Functions for Assessments */
-- CHECK constraint for Assessments @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '(NOT ([Source]=''LakePRC'' OR [Source]=''marion_foia_2026'' OR [Source]=''MarionPRC'') OR [OriginalLandAV] IS NULL OR [OriginalImprovementAV] IS NULL OR [OriginalTotalAV] IS NULL OR abs(([OriginalLandAV]+[OriginalImprovementAV])-[OriginalTotalAV])<=(1))', 'public ValidateOriginalAssessmentValuesCompletenessAndBalance(result: ValidationResult) {
	const restrictedSources = [''LakePRC'', ''marion_foia_2026'', ''MarionPRC''];
	const isRestrictedSource = restrictedSources.indexOf(this.Source) >= 0;
	
	if (isRestrictedSource) {
		if (this.OriginalLandAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalLandAV",
				"Original land value is required for source " + this.Source + ".",
				this.OriginalLandAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalImprovementAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalImprovementAV",
				"Original improvement value is required for source " + this.Source + ".",
				this.OriginalImprovementAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalTotalAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalTotalAV",
				"Original total value is required for source " + this.Source + ".",
				this.OriginalTotalAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalLandAV != null && this.OriginalImprovementAV != null && this.OriginalTotalAV != null) {
			const calculatedSum = this.OriginalLandAV + this.OriginalImprovementAV;
			const difference = Math.abs(calculatedSum - this.OriginalTotalAV);
			
			if (difference > 1) {
				result.Errors.push(new ValidationErrorInfo(
					"OriginalTotalAV",
					"Original total value must equal the sum of land and improvement values within $1 tolerance. Land (" + this.OriginalLandAV + ") + Improvement (" + this.OriginalImprovementAV + ") should equal Total (" + this.OriginalTotalAV + ").",
					this.OriginalTotalAV,
					ValidationErrorType.Failure
				));
			}
		}
	}
}', 'For assessments from specific sources (LakePRC, marion_foia_2026, or MarionPRC), the original land value, original improvement value, and original total value must all be provided. Additionally, the sum of land and improvement values must equal the total value within a tolerance of $1 to account for rounding differences. For all other sources, these values are optional.', 'ValidateOriginalAssessmentValuesCompletenessAndBalance', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '4AB7D5DF-8D95-4897-BC26-1FEA542669EF');

