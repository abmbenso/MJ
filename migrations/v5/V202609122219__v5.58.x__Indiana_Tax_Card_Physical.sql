/* ============================================================================
   Indiana Property Tax Expert — county record-card physical detail, per card year
   v5.58.x (companion to V202609121958 Indiana_Tax_Card_History)

   CountyAssessorRecord and CountyAssessorImprovement hold ONE row per parcel,
   from the newest card. A property that was 10,000 sqft on its AY2024 card and
   110,000 sqft on its AY2025 card after an addition therefore showed 110,000
   for both years. These two tables keep each card year's own physical picture:
   the card's summary (class, area, units, year built, acreage) and every
   Summary of Improvements row, tied to the card (SourceDocument) it was read
   from, so a year-by-year view reads the year's own card.

   Design: Indiana_Tax_Expert/docs/proposals/multi-county-ci-intake.md §11 (addendum 2026-09-12)
   Plan:   Indiana_Tax_Expert/docs/plans/2026-09-12-lake-s2-s5-load.md Task 11
   ============================================================================ */

CREATE TABLE indiana_tax.CardSummary (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    CardAssessmentYear SMALLINT NOT NULL,
    PropertyClassCode NVARCHAR(10) NULL,
    PropertyClassDescription NVARCHAR(100) NULL,
    OwnerName NVARCHAR(500) NULL,
    SitusAddress NVARCHAR(200) NULL,
    Acreage DECIMAL(10,4) NULL,
    BuildingSqFt INT NULL,
    SiteImprovementSqFt INT NULL,
    AncillarySqFt INT NULL,
    OtherSqFt INT NULL,
    YearBuilt SMALLINT NULL,
    EffectiveYear SMALLINT NULL,
    OldestStructureYear SMALLINT NULL,
    Units INT NULL,
    ImprovementCount SMALLINT NULL,
    BuildingCount SMALLINT NULL,
    CardCount SMALLINT NULL,
    ImprovementRowsValue DECIMAL(14,2) NULL,
    PrintedDate DATE NULL,
    ParseNotes NVARCHAR(1000) NULL,

    CONSTRAINT PK_CardSummary PRIMARY KEY (ID),
    CONSTRAINT FK_CardSummary_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_CardSummary_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_CardSummary UNIQUE (SourceDocumentID)
);
GO

CREATE TABLE indiana_tax.CardImprovement (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    CardAssessmentYear SMALLINT NOT NULL,
    EntryIndex SMALLINT NOT NULL,
    CardNumber SMALLINT NULL,
    RowIndex NVARCHAR(10) NULL,
    Quantity SMALLINT NULL,
    Description NVARCHAR(100) NULL,
    Kind NVARCHAR(10) NOT NULL
        CONSTRAINT CK_CardImprovement_Kind CHECK (Kind IN ('building', 'site', 'ancillary', 'other')),
    Grade NVARCHAR(10) NULL,
    StoryHeight DECIMAL(5,2) NULL,
    Construction NVARCHAR(50) NULL,
    YearBuilt SMALLINT NULL,
    EffectiveYear SMALLINT NULL,
    EffectiveAge SMALLINT NULL,
    Condition NVARCHAR(5) NULL,
    SizeSqFt DECIMAL(14,2) NULL,
    SizeText NVARCHAR(30) NULL,
    Units INT NULL,
    BaseRate DECIMAL(12,2) NULL,
    LCM DECIMAL(6,3) NULL,
    AdjRate DECIMAL(12,2) NULL,
    RCN DECIMAL(14,2) NULL,
    NormDepPct DECIMAL(5,2) NULL,
    RemainingValue DECIMAL(14,2) NULL,
    AbnObsPct DECIMAL(5,2) NULL,
    PctComplete DECIMAL(5,2) NULL,
    NeighborhoodFactor DECIMAL(9,4) NULL,
    MarketFactor DECIMAL(9,4) NULL,
    Cap1Pct DECIMAL(5,2) NULL,
    Cap2Pct DECIMAL(5,2) NULL,
    Cap3Pct DECIMAL(5,2) NULL,
    ImprovementValue DECIMAL(14,2) NULL,
    IsFullRead BIT NOT NULL,

    CONSTRAINT PK_CardImprovement PRIMARY KEY (ID),
    CONSTRAINT FK_CardImprovement_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_CardImprovement_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_CardImprovement UNIQUE (SourceDocumentID, EntryIndex)
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One row per county record card (card year): the card''s own physical summary -- class, building and site area, units, year built, acreage -- so a year-by-year view shows what each year''s card said. CountyAssessorRecord keeps the newest card''s picture only. Loaded by Indiana_Tax_Expert/scripts/load-county-prc.js from the same parse as CardValuationColumn.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Assessment Year printed on this card (its newest year) -- the year that names the card.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'CardAssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The property class code printed on this card year (it can change between years: 5 of 20 Lake pilot parcels did).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'PropertyClassCode';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The class description printed beside the code on the header band.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'PropertyClassDescription';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Ownership block''s owner name as printed on this card year (the card truncates long names).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'OwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The situs address from the header band.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'SitusAddress';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Calculated Acreage from the Land Computations block (never Parcel Acreage, which prints 0.00 on some cards).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'Acreage';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Building floor area on this card year: the Summary of Improvements rows classified as buildings and sized in sqft, times their quantity. The figure that changes when an addition is built.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'BuildingSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Site improvements (paving, fencing, walls, canopies) sized in sqft on this card year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'SiteImprovementSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Ancillary structures (porches, booths, mezzanines, pools) sized in sqft on this card year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'AncillarySqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Improvement rows of no recognised kind sized in sqft; normally NULL.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'OtherSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Year built of the primary (largest) building on this card year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'YearBuilt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Effective year of the primary building on this card year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'EffectiveYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The oldest year built among the card''s buildings.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'OldestStructureYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Page 2 "# of Units", summed over the document''s cards; NULL where none prints.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'Units';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Number of Summary of Improvements rows on this card year (all cards of the document).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'ImprovementCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Number of those rows classified as buildings.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'BuildingCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Number of cards (Summary of Improvements blocks) in the document.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'CardCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of the improvement rows'' Improv Value cells; equals the card''s improvement AV when every row was read.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'ImprovementRowsValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The footer''s Printed date -- when the county produced this card.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'PrintedDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'What the parser flagged for review on this card (a list-year disagreement, a valuation-block problem, improvement rows not summing to the improvement AV); NULL when clean.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardSummary', @level2type = N'COLUMN', @level2name = N'ParseNotes';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Every Summary of Improvements row of every county record card, per card year: the structures and yard items the county priced that year, with size, depreciation, obsolescence, factors, the cap split and value. An addition appears as new or larger rows on the year it was assessed and not before. CountyAssessorImprovement holds the newest card''s rows only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Assessment Year printed on the card this row was read from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'CardAssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Position among the document''s improvement rows, from 0, across all its cards.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'EntryIndex';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Which card of a multi-card document the row is on (each card restarts its row numbers).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'CardNumber';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The row number printed before the colon ("3" in "6x3:").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'RowIndex';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identical items on the row ("6x3:" = six); SizeSqFt, RCN and RemainingValue are per item, ImprovementValue for all. 1 for an ordinary row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Quantity';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Description cell verbatim (C/I Building, Paving, Canopies - Commercial, Docking Facilities).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Description';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parser''s classification of the description: building (floor area), site (paving, fencing, walls, canopies), ancillary (porches, booths, pools), other. Only building rows sized in sqft count as floor area.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Kind';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Grade cell (C, C+1, D+1, B+2).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Grade';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Story Height cell.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'StoryHeight';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Constr Type cell (Concrete, Brick, Wood Frame, Asphalt); NULL where blank.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Construction';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Year Built cell.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'YearBuilt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Eff Year cell.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'EffectiveYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Eff Age cell, in years.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'EffectiveAge';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Cond cell (A, F, P).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Condition';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Size cell when printed in sqft (per item); NULL when the item is sized by dimensions or units -- see SizeText.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'SizeSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Size cell as printed (122,628 sqft / 80'' x 17'' / 2 Units).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'SizeText';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The unit count when the Size cell is printed in Units (a pool, a whirlpool).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Units';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Base Rate, printed for rate-priced items (paving, fencing, walls); NULL for buildings.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'BaseRate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'LCM: the location cost multiplier.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'LCM';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Adj Rate: the base rate after the multiplier; NULL for buildings.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'AdjRate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'RCN: replacement cost new, per item.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'RCN';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Norm Dep: normal depreciation, percent.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'NormDepPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Remain. Value: RCN after normal depreciation, per item.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'RemainingValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Abn Obs: abnormal obsolescence, percent.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'AbnObsPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PC: percent complete.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'PctComplete';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Nbhd: the neighborhood factor.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'NeighborhoodFactor';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Mrkt: the market (trending) factor, as printed (1.120 = +12%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'MarketFactor';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 1: percent of this row''s value under the 1% circuit-breaker cap; printed on AY2024+ Lake cards only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Cap1Pct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 2: percent under the 2% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Cap2Pct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cap 3: percent under the 3% cap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'Cap3Pct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Improv Value: the row''s assessed value (all items together).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'ImprovementValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'1 when the parser read the whole row; 0 when only description, years and size could be read (the other cells are then NULL).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardImprovement', @level2type = N'COLUMN', @level2name = N'IsFullRead';
GO


















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   EntityField inserts, regenerated views, spCreate/spUpdate/spDelete procedures,
   permission grants and extended properties for CardSummary and CardImprovement.
   DO NOT EDIT BY HAND. If the DDL above changes, re-run CodeGen and replace this section.
   ============================================================================ */

/* SQL generated to create new entity Card Summaries */

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
         '81ef2e46-b503-4703-9565-ed38208c85a3',
         'Card Summaries',
         NULL,
         'One row per county record card (card year): the card''s own physical summary -- class, building and site area, units, year built, acreage -- so a year-by-year view shows what each year''s card said. CountyAssessorRecord keeps the newest card''s picture only. Loaded by Indiana_Tax_Expert/scripts/load-county-prc.js from the same parse as CardValuationColumn.',
         NULL,
         'CardSummary',
         'vwCardSummaries',
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

/* SQL generated to add new entity Card Summaries to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '81ef2e46-b503-4703-9565-ed38208c85a3', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Summaries for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('81ef2e46-b503-4703-9565-ed38208c85a3', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Summaries for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('81ef2e46-b503-4703-9565-ed38208c85a3', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Summaries for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('81ef2e46-b503-4703-9565-ed38208c85a3', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Card Improvements */

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
         '5e919079-f0cc-4ddf-b409-986240471f52',
         'Card Improvements',
         NULL,
         'Every Summary of Improvements row of every county record card, per card year: the structures and yard items the county priced that year, with size, depreciation, obsolescence, factors, the cap split and value. An addition appears as new or larger rows on the year it was assessed and not before. CountyAssessorImprovement holds the newest card''s rows only.',
         NULL,
         'CardImprovement',
         'vwCardImprovements',
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

/* SQL generated to add new entity Card Improvements to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '5e919079-f0cc-4ddf-b409-986240471f52', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Improvements for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5e919079-f0cc-4ddf-b409-986240471f52', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Improvements for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5e919079-f0cc-4ddf-b409-986240471f52', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Card Improvements for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('5e919079-f0cc-4ddf-b409-986240471f52', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardImprovement */
UPDATE [indiana_tax].[CardImprovement] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ADD CONSTRAINT [DF_indiana_tax_CardImprovement___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardImprovement */
UPDATE [indiana_tax].[CardImprovement] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardImprovement */
ALTER TABLE [indiana_tax].[CardImprovement] ADD CONSTRAINT [DF_indiana_tax_CardImprovement___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardSummary */
UPDATE [indiana_tax].[CardSummary] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ADD CONSTRAINT [DF_indiana_tax_CardSummary___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardSummary */
UPDATE [indiana_tax].[CardSummary] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CardSummary */
ALTER TABLE [indiana_tax].[CardSummary] ADD CONSTRAINT [DF_indiana_tax_CardSummary___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 62 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f37309bf-3995-4485-bd15-32942a4894d8' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'ID')) BEGIN
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
            'f37309bf-3995-4485-bd15-32942a4894d8',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '403bda96-d357-42b0-b352-bea90099d416' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'SourceDocumentID')) BEGIN
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
            '403bda96-d357-42b0-b352-bea90099d416',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c8895540-4e03-4b37-b8b9-edb30b6e8adf' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'ParcelID')) BEGIN
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
            'c8895540-4e03-4b37-b8b9-edb30b6e8adf',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd9230841-b6a0-4f6d-81bd-dd1d088b22e0' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'CardAssessmentYear')) BEGIN
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
            'd9230841-b6a0-4f6d-81bd-dd1d088b22e0',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100004,
            'CardAssessmentYear',
            'Card Assessment Year',
            'The Assessment Year printed on the card this row was read from.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e501a3a2-0bfa-4f2f-bd77-851a00648a2b' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'EntryIndex')) BEGIN
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
            'e501a3a2-0bfa-4f2f-bd77-851a00648a2b',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100005,
            'EntryIndex',
            'Entry Index',
            'Position among the document''s improvement rows, from 0, across all its cards.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd1ff996c-ad34-425b-92ae-e930339f1750' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'CardNumber')) BEGIN
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
            'd1ff996c-ad34-425b-92ae-e930339f1750',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100006,
            'CardNumber',
            'Card Number',
            'Which card of a multi-card document the row is on (each card restarts its row numbers).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '106eb563-35e1-41fa-9452-07b3063fbe3b' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'RowIndex')) BEGIN
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
            '106eb563-35e1-41fa-9452-07b3063fbe3b',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100007,
            'RowIndex',
            'Row Index',
            'The row number printed before the colon ("3" in "6x3:").',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b88481ab-edc5-4660-8a2e-4d3b74f9e5ed' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Quantity')) BEGIN
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
            'b88481ab-edc5-4660-8a2e-4d3b74f9e5ed',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100008,
            'Quantity',
            'Quantity',
            'Identical items on the row ("6x3:" = six); SizeSqFt, RCN and RemainingValue are per item, ImprovementValue for all. 1 for an ordinary row.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '06d8f0fd-0a7f-4103-a846-e437b8db981c' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Description')) BEGIN
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
            '06d8f0fd-0a7f-4103-a846-e437b8db981c',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100009,
            'Description',
            'Description',
            'The Description cell verbatim (C/I Building, Paving, Canopies - Commercial, Docking Facilities).',
            'nvarchar',
            200,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '98876186-f6b0-4624-a267-75e6dc2f6b93' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Kind')) BEGIN
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
            '98876186-f6b0-4624-a267-75e6dc2f6b93',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100010,
            'Kind',
            'Kind',
            'The parser''s classification of the description: building (floor area), site (paving, fencing, walls, canopies), ancillary (porches, booths, pools), other. Only building rows sized in sqft count as floor area.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab146c48-bf22-4b1a-98d7-2e68f84302cf' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Grade')) BEGIN
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
            'ab146c48-bf22-4b1a-98d7-2e68f84302cf',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100011,
            'Grade',
            'Grade',
            'The Grade cell (C, C+1, D+1, B+2).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '46de89ed-521c-430b-8c56-ba641e75c44e' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'StoryHeight')) BEGIN
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
            '46de89ed-521c-430b-8c56-ba641e75c44e',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100012,
            'StoryHeight',
            'Story Height',
            'The Story Height cell.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'aba41596-86c5-4a40-8503-14b94f3895bc' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Construction')) BEGIN
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
            'aba41596-86c5-4a40-8503-14b94f3895bc',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100013,
            'Construction',
            'Construction',
            'The Constr Type cell (Concrete, Brick, Wood Frame, Asphalt); NULL where blank.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '14b92391-3e9b-4d6b-adb4-3d4250175c9f' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'YearBuilt')) BEGIN
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
            '14b92391-3e9b-4d6b-adb4-3d4250175c9f',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100014,
            'YearBuilt',
            'Year Built',
            'The Year Built cell.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2f2dd150-7988-46ad-bcab-ad2c5ea5533d' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'EffectiveYear')) BEGIN
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
            '2f2dd150-7988-46ad-bcab-ad2c5ea5533d',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100015,
            'EffectiveYear',
            'Effective Year',
            'The Eff Year cell.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2843cd4e-8027-476e-82ae-aeea04ca732f' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'EffectiveAge')) BEGIN
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
            '2843cd4e-8027-476e-82ae-aeea04ca732f',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100016,
            'EffectiveAge',
            'Effective Age',
            'The Eff Age cell, in years.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9b4d7de-e190-4388-af36-a01c82855eec' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Condition')) BEGIN
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
            'a9b4d7de-e190-4388-af36-a01c82855eec',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100017,
            'Condition',
            'Condition',
            'The Cond cell (A, F, P).',
            'nvarchar',
            10,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e5483492-5955-4e67-a905-5d594de1954d' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'SizeSqFt')) BEGIN
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
            'e5483492-5955-4e67-a905-5d594de1954d',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100018,
            'SizeSqFt',
            'Size Sq Ft',
            'The Size cell when printed in sqft (per item); NULL when the item is sized by dimensions or units -- see SizeText.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '45ff92f3-c5db-420c-bcf7-0430b2610003' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'SizeText')) BEGIN
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
            '45ff92f3-c5db-420c-bcf7-0430b2610003',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100019,
            'SizeText',
            'Size Text',
            'The Size cell as printed (122,628 sqft / 80'' x 17'' / 2 Units).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0da7bd91-5a1e-4e7d-92c6-598c159d8c74' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Units')) BEGIN
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
            '0da7bd91-5a1e-4e7d-92c6-598c159d8c74',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100020,
            'Units',
            'Units',
            'The unit count when the Size cell is printed in Units (a pool, a whirlpool).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '224855f1-c2de-496e-8940-e9d19450aa07' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'BaseRate')) BEGIN
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
            '224855f1-c2de-496e-8940-e9d19450aa07',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100021,
            'BaseRate',
            'Base Rate',
            'Base Rate, printed for rate-priced items (paving, fencing, walls); NULL for buildings.',
            'decimal',
            9,
            12,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7be529e1-3d82-41fa-bfd9-2176fedff9ef' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'LCM')) BEGIN
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
            '7be529e1-3d82-41fa-bfd9-2176fedff9ef',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100022,
            'LCM',
            'Lcm',
            'LCM: the location cost multiplier.',
            'decimal',
            5,
            6,
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '768aac2b-8417-43fc-b64f-f731fa30fa0e' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'AdjRate')) BEGIN
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
            '768aac2b-8417-43fc-b64f-f731fa30fa0e',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100023,
            'AdjRate',
            'Adj Rate',
            'Adj Rate: the base rate after the multiplier; NULL for buildings.',
            'decimal',
            9,
            12,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ffddfcb4-7686-471d-b903-7f17278e2416' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'RCN')) BEGIN
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
            'ffddfcb4-7686-471d-b903-7f17278e2416',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100024,
            'RCN',
            'Rcn',
            'RCN: replacement cost new, per item.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ac1a6779-d22e-49c8-8814-0e21b02ca818' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'NormDepPct')) BEGIN
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
            'ac1a6779-d22e-49c8-8814-0e21b02ca818',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100025,
            'NormDepPct',
            'Norm Dep Pct',
            'Norm Dep: normal depreciation, percent.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'decebc5d-c08f-48bb-99ac-a11c0b1a3111' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'RemainingValue')) BEGIN
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
            'decebc5d-c08f-48bb-99ac-a11c0b1a3111',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100026,
            'RemainingValue',
            'Remaining Value',
            'Remain. Value: RCN after normal depreciation, per item.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0a1afc4b-e8d8-4245-94a4-00481f41cbe4' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'AbnObsPct')) BEGIN
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
            '0a1afc4b-e8d8-4245-94a4-00481f41cbe4',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100027,
            'AbnObsPct',
            'Abn Obs Pct',
            'Abn Obs: abnormal obsolescence, percent.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b6d56818-00e4-4922-91ed-addfac91526a' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'PctComplete')) BEGIN
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
            'b6d56818-00e4-4922-91ed-addfac91526a',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100028,
            'PctComplete',
            'Pct Complete',
            'PC: percent complete.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2c045d92-42ac-486c-8f55-94f918a56a31' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'NeighborhoodFactor')) BEGIN
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
            '2c045d92-42ac-486c-8f55-94f918a56a31',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100029,
            'NeighborhoodFactor',
            'Neighborhood Factor',
            'Nbhd: the neighborhood factor.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fa56fc8c-816b-49fc-aade-6064c642a7ff' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'MarketFactor')) BEGIN
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
            'fa56fc8c-816b-49fc-aade-6064c642a7ff',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100030,
            'MarketFactor',
            'Market Factor',
            'Mrkt: the market (trending) factor, as printed (1.120 = +12%).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3d0d6577-eff2-44dd-af77-cbc9a212d721' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Cap1Pct')) BEGIN
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
            '3d0d6577-eff2-44dd-af77-cbc9a212d721',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100031,
            'Cap1Pct',
            'Cap 1 Pct',
            'Cap 1: percent of this row''s value under the 1% circuit-breaker cap; printed on AY2024+ Lake cards only.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '92cbb177-ed7d-4244-bcfa-8fa87271f601' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Cap2Pct')) BEGIN
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
            '92cbb177-ed7d-4244-bcfa-8fa87271f601',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100032,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '48385a9d-a9a7-491b-b7f3-18dfcd4d96f6' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Cap3Pct')) BEGIN
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
            '48385a9d-a9a7-491b-b7f3-18dfcd4d96f6',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100033,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '77c22dc6-139a-49fe-8078-457ce1b9db1f' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'ImprovementValue')) BEGIN
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
            '77c22dc6-139a-49fe-8078-457ce1b9db1f',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100034,
            'ImprovementValue',
            'Improvement Value',
            'Improv Value: the row''s assessed value (all items together).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '202423e5-cce7-4f63-a18a-095127896b25' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'IsFullRead')) BEGIN
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
            '202423e5-cce7-4f63-a18a-095127896b25',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100035,
            'IsFullRead',
            'Is Full Read',
            '1 when the parser read the whole row; 0 when only description, years and size could be read (the other cells are then NULL).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '521e8ff6-b998-478e-958c-55c72ebe50ee' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = '__mj_CreatedAt')) BEGIN
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
            '521e8ff6-b998-478e-958c-55c72ebe50ee',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100036,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '73c3c2cd-d173-4cb7-a6af-70f74590572a' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '73c3c2cd-d173-4cb7-a6af-70f74590572a',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100037,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '021561e4-f52f-47fb-9f9c-e7b6fdaa84f4' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'ID')) BEGIN
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
            '021561e4-f52f-47fb-9f9c-e7b6fdaa84f4',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '02952189-33fe-44cb-8982-757512648afa' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'SourceDocumentID')) BEGIN
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
            '02952189-33fe-44cb-8982-757512648afa',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '04557c42-d1e0-4b37-a874-7d1f4e759238' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'ParcelID')) BEGIN
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
            '04557c42-d1e0-4b37-a874-7d1f4e759238',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7f1330f9-f46e-4e4c-8bf1-15bb520952b4' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'CardAssessmentYear')) BEGIN
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
            '7f1330f9-f46e-4e4c-8bf1-15bb520952b4',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100004,
            'CardAssessmentYear',
            'Card Assessment Year',
            'The Assessment Year printed on this card (its newest year) -- the year that names the card.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b5da0dee-bafb-4bd1-bd87-5e334bccbb3d' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'PropertyClassCode')) BEGIN
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
            'b5da0dee-bafb-4bd1-bd87-5e334bccbb3d',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100005,
            'PropertyClassCode',
            'Property Class Code',
            'The property class code printed on this card year (it can change between years: 5 of 20 Lake pilot parcels did).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7afadcb7-fe06-4c41-8aa0-55bd7808e69d' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'PropertyClassDescription')) BEGIN
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
            '7afadcb7-fe06-4c41-8aa0-55bd7808e69d',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100006,
            'PropertyClassDescription',
            'Property Class Description',
            'The class description printed beside the code on the header band.',
            'nvarchar',
            200,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '27ccad70-f351-4050-93e7-090cb444e755' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'OwnerName')) BEGIN
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
            '27ccad70-f351-4050-93e7-090cb444e755',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100007,
            'OwnerName',
            'Owner Name',
            'The Ownership block''s owner name as printed on this card year (the card truncates long names).',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f682161b-1782-4c72-94b0-31f1c8159656' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'SitusAddress')) BEGIN
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
            'f682161b-1782-4c72-94b0-31f1c8159656',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100008,
            'SitusAddress',
            'Situs Address',
            'The situs address from the header band.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2d386953-c796-45b3-94d6-f48e27b33a0d' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'Acreage')) BEGIN
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
            '2d386953-c796-45b3-94d6-f48e27b33a0d',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100009,
            'Acreage',
            'Acreage',
            'Calculated Acreage from the Land Computations block (never Parcel Acreage, which prints 0.00 on some cards).',
            'decimal',
            9,
            10,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '72950fbf-a196-4dce-b873-a429442b1241' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'BuildingSqFt')) BEGIN
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
            '72950fbf-a196-4dce-b873-a429442b1241',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100010,
            'BuildingSqFt',
            'Building Sq Ft',
            'Building floor area on this card year: the Summary of Improvements rows classified as buildings and sized in sqft, times their quantity. The figure that changes when an addition is built.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0b1f2a8a-1775-457b-986b-d9a653bf2a39' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'SiteImprovementSqFt')) BEGIN
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
            '0b1f2a8a-1775-457b-986b-d9a653bf2a39',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100011,
            'SiteImprovementSqFt',
            'Site Improvement Sq Ft',
            'Site improvements (paving, fencing, walls, canopies) sized in sqft on this card year.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3adecc75-6b4f-4274-88a6-fa4f8764ffd3' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'AncillarySqFt')) BEGIN
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
            '3adecc75-6b4f-4274-88a6-fa4f8764ffd3',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100012,
            'AncillarySqFt',
            'Ancillary Sq Ft',
            'Ancillary structures (porches, booths, mezzanines, pools) sized in sqft on this card year.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c123ec38-df0f-4a54-b798-88b4dc544129' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'OtherSqFt')) BEGIN
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
            'c123ec38-df0f-4a54-b798-88b4dc544129',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100013,
            'OtherSqFt',
            'Other Sq Ft',
            'Improvement rows of no recognised kind sized in sqft; normally NULL.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3adabe3d-66e2-4bdf-a340-603dd523e538' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'YearBuilt')) BEGIN
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
            '3adabe3d-66e2-4bdf-a340-603dd523e538',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100014,
            'YearBuilt',
            'Year Built',
            'Year built of the primary (largest) building on this card year.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0029c2ae-0dc9-455c-a9e0-1406453ed2ac' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'EffectiveYear')) BEGIN
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
            '0029c2ae-0dc9-455c-a9e0-1406453ed2ac',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100015,
            'EffectiveYear',
            'Effective Year',
            'Effective year of the primary building on this card year.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7186eff1-99d0-4260-aaa9-1cce06993e99' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'OldestStructureYear')) BEGIN
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
            '7186eff1-99d0-4260-aaa9-1cce06993e99',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100016,
            'OldestStructureYear',
            'Oldest Structure Year',
            'The oldest year built among the card''s buildings.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2550faf1-9a19-4e4e-8458-9fd903d5f0ed' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'Units')) BEGIN
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
            '2550faf1-9a19-4e4e-8458-9fd903d5f0ed',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100017,
            'Units',
            'Units',
            'Page 2 "# of Units", summed over the document''s cards; NULL where none prints.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '660623cb-f893-4353-a988-1f3cd7b8522f' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'ImprovementCount')) BEGIN
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
            '660623cb-f893-4353-a988-1f3cd7b8522f',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100018,
            'ImprovementCount',
            'Improvement Count',
            'Number of Summary of Improvements rows on this card year (all cards of the document).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '65abc261-6cb6-4349-8e25-57e9f0ba1732' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'BuildingCount')) BEGIN
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
            '65abc261-6cb6-4349-8e25-57e9f0ba1732',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100019,
            'BuildingCount',
            'Building Count',
            'Number of those rows classified as buildings.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a53ef91c-994c-4eed-a00d-02afd6068c0c' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'CardCount')) BEGIN
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
            'a53ef91c-994c-4eed-a00d-02afd6068c0c',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100020,
            'CardCount',
            'Card Count',
            'Number of cards (Summary of Improvements blocks) in the document.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd074406e-38cc-401c-8c50-418f86b12c6a' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'ImprovementRowsValue')) BEGIN
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
            'd074406e-38cc-401c-8c50-418f86b12c6a',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100021,
            'ImprovementRowsValue',
            'Improvement Rows Value',
            'Sum of the improvement rows'' Improv Value cells; equals the card''s improvement AV when every row was read.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3f836e31-460f-4194-9e47-4950e29997d3' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'PrintedDate')) BEGIN
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
            '3f836e31-460f-4194-9e47-4950e29997d3',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100022,
            'PrintedDate',
            'Printed Date',
            'The footer''s Printed date -- when the county produced this card.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd6977610-aa25-4185-8c09-5188f7945cb2' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'ParseNotes')) BEGIN
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
            'd6977610-aa25-4185-8c09-5188f7945cb2',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100023,
            'ParseNotes',
            'Parse Notes',
            'What the parser flagged for review on this card (a list-year disagreement, a valuation-block problem, improvement rows not summing to the improvement AV); NULL when clean.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1e5de659-15a5-4059-ab48-d0285b7019e7' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = '__mj_CreatedAt')) BEGIN
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
            '1e5de659-15a5-4059-ab48-d0285b7019e7',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7aea8fcf-308e-47c4-a120-6d129da1ab3e' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '7aea8fcf-308e-47c4-a120-6d129da1ab3e',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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

/* SQL text to insert entity field value with ID 7a3d47b0-f00c-4305-a67d-7e78e1a120dc */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7a3d47b0-f00c-4305-a67d-7e78e1a120dc', '98876186-F6B0-4624-A267-75E6DC2F6B93', 1, 'ancillary', 'ancillary', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b0a6d3ca-5657-4d19-9b40-8f22047b197f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b0a6d3ca-5657-4d19-9b40-8f22047b197f', '98876186-F6B0-4624-A267-75E6DC2F6B93', 2, 'building', 'building', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b2af84cc-67eb-4812-b012-4aae7d34857a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b2af84cc-67eb-4812-b012-4aae7d34857a', '98876186-F6B0-4624-A267-75E6DC2F6B93', 3, 'other', 'other', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bc8a5f62-eda9-4471-a653-c9994a1eadb8 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bc8a5f62-eda9-4471-a653-c9994a1eadb8', '98876186-F6B0-4624-A267-75E6DC2F6B93', 4, 'site', 'site', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 98876186-F6B0-4624-A267-75E6DC2F6B93 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='98876186-F6B0-4624-A267-75E6DC2F6B93';


/* Create Entity Relationship: Source Documents -> Card Summaries (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '552373b1-7692-4cf1-9428-154964bd690b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('552373b1-7692-4cf1-9428-154964bd690b', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '81EF2E46-B503-4703-9565-ED38208C85A3', 'SourceDocumentID', 'One To Many', 1, 1, 28, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Source Documents -> Card Improvements (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '36918e58-dee8-42a0-810c-c648998ed3e5'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('36918e58-dee8-42a0-810c-c648998ed3e5', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '5E919079-F0CC-4DDF-B409-986240471F52', 'SourceDocumentID', 'One To Many', 1, 1, 29, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Card Summaries (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b061023e-94dc-49b5-b24b-8821c8d4ac93'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b061023e-94dc-49b5-b24b-8821c8d4ac93', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '81EF2E46-B503-4703-9565-ED38208C85A3', 'ParcelID', 'One To Many', 1, 1, 24, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Parcels -> Card Improvements (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '805f9073-ed8a-4dd9-9228-12e49bd43900'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('805f9073-ed8a-4dd9-9228-12e49bd43900', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '5E919079-F0CC-4DDF-B409-986240471F52', 'ParcelID', 'One To Many', 1, 1, 25, GETUTCDATE(), GETUTCDATE())
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

/* Index for Foreign Keys for CardImprovement */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardImprovement
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardImprovement_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardImprovement]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardImprovement_SourceDocumentID ON [indiana_tax].[CardImprovement] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardImprovement
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardImprovement_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardImprovement]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardImprovement_ParcelID ON [indiana_tax].[CardImprovement] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID C8895540-4E03-4B37-B8B9-EDB30B6E8ADF */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C8895540-4E03-4B37-B8B9-EDB30B6E8ADF', @RelatedEntityNameFieldMap='Parcel';

/* Index for Foreign Keys for CardSummary */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardSummary
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardSummary_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardSummary]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardSummary_SourceDocumentID ON [indiana_tax].[CardSummary] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardSummary
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardSummary_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardSummary]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardSummary_ParcelID ON [indiana_tax].[CardSummary] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 04557C42-D1E0-4B37-A874-7D1F4E759238 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='04557C42-D1E0-4B37-A874-7D1F4E759238', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Card Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: vwCardImprovements
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Improvements
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardImprovement
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardImprovements]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardImprovements];
GO

CREATE VIEW [indiana_tax].[vwCardImprovements]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardImprovement] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardImprovements] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: Permissions for vwCardImprovements
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardImprovements] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: spCreateCardImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardImprovement]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @EntryIndex smallint,
    @CardNumber_Clear bit = 0,
    @CardNumber smallint = NULL,
    @RowIndex_Clear bit = 0,
    @RowIndex nvarchar(10) = NULL,
    @Quantity_Clear bit = 0,
    @Quantity smallint = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(100) = NULL,
    @Kind nvarchar(10),
    @Grade_Clear bit = 0,
    @Grade nvarchar(10) = NULL,
    @StoryHeight_Clear bit = 0,
    @StoryHeight decimal(5, 2) = NULL,
    @Construction_Clear bit = 0,
    @Construction nvarchar(50) = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @EffectiveAge_Clear bit = 0,
    @EffectiveAge smallint = NULL,
    @Condition_Clear bit = 0,
    @Condition nvarchar(5) = NULL,
    @SizeSqFt_Clear bit = 0,
    @SizeSqFt decimal(14, 2) = NULL,
    @SizeText_Clear bit = 0,
    @SizeText nvarchar(30) = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @BaseRate_Clear bit = 0,
    @BaseRate decimal(12, 2) = NULL,
    @LCM_Clear bit = 0,
    @LCM decimal(6, 3) = NULL,
    @AdjRate_Clear bit = 0,
    @AdjRate decimal(12, 2) = NULL,
    @RCN_Clear bit = 0,
    @RCN decimal(14, 2) = NULL,
    @NormDepPct_Clear bit = 0,
    @NormDepPct decimal(5, 2) = NULL,
    @RemainingValue_Clear bit = 0,
    @RemainingValue decimal(14, 2) = NULL,
    @AbnObsPct_Clear bit = 0,
    @AbnObsPct decimal(5, 2) = NULL,
    @PctComplete_Clear bit = 0,
    @PctComplete decimal(5, 2) = NULL,
    @NeighborhoodFactor_Clear bit = 0,
    @NeighborhoodFactor decimal(9, 4) = NULL,
    @MarketFactor_Clear bit = 0,
    @MarketFactor decimal(9, 4) = NULL,
    @Cap1Pct_Clear bit = 0,
    @Cap1Pct decimal(5, 2) = NULL,
    @Cap2Pct_Clear bit = 0,
    @Cap2Pct decimal(5, 2) = NULL,
    @Cap3Pct_Clear bit = 0,
    @Cap3Pct decimal(5, 2) = NULL,
    @ImprovementValue_Clear bit = 0,
    @ImprovementValue decimal(14, 2) = NULL,
    @IsFullRead bit
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardImprovement]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [CardNumber],
                [RowIndex],
                [Quantity],
                [Description],
                [Kind],
                [Grade],
                [StoryHeight],
                [Construction],
                [YearBuilt],
                [EffectiveYear],
                [EffectiveAge],
                [Condition],
                [SizeSqFt],
                [SizeText],
                [Units],
                [BaseRate],
                [LCM],
                [AdjRate],
                [RCN],
                [NormDepPct],
                [RemainingValue],
                [AbnObsPct],
                [PctComplete],
                [NeighborhoodFactor],
                [MarketFactor],
                [Cap1Pct],
                [Cap2Pct],
                [Cap3Pct],
                [ImprovementValue],
                [IsFullRead]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, NULL) END,
                CASE WHEN @RowIndex_Clear = 1 THEN NULL ELSE ISNULL(@RowIndex, NULL) END,
                CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @Kind,
                CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, NULL) END,
                CASE WHEN @StoryHeight_Clear = 1 THEN NULL ELSE ISNULL(@StoryHeight, NULL) END,
                CASE WHEN @Construction_Clear = 1 THEN NULL ELSE ISNULL(@Construction, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @EffectiveAge_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveAge, NULL) END,
                CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, NULL) END,
                CASE WHEN @SizeSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SizeSqFt, NULL) END,
                CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @BaseRate_Clear = 1 THEN NULL ELSE ISNULL(@BaseRate, NULL) END,
                CASE WHEN @LCM_Clear = 1 THEN NULL ELSE ISNULL(@LCM, NULL) END,
                CASE WHEN @AdjRate_Clear = 1 THEN NULL ELSE ISNULL(@AdjRate, NULL) END,
                CASE WHEN @RCN_Clear = 1 THEN NULL ELSE ISNULL(@RCN, NULL) END,
                CASE WHEN @NormDepPct_Clear = 1 THEN NULL ELSE ISNULL(@NormDepPct, NULL) END,
                CASE WHEN @RemainingValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainingValue, NULL) END,
                CASE WHEN @AbnObsPct_Clear = 1 THEN NULL ELSE ISNULL(@AbnObsPct, NULL) END,
                CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, NULL) END,
                CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, NULL) END,
                CASE WHEN @MarketFactor_Clear = 1 THEN NULL ELSE ISNULL(@MarketFactor, NULL) END,
                CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, NULL) END,
                CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, NULL) END,
                CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, NULL) END,
                CASE WHEN @ImprovementValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementValue, NULL) END,
                @IsFullRead
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardImprovement]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [CardNumber],
                [RowIndex],
                [Quantity],
                [Description],
                [Kind],
                [Grade],
                [StoryHeight],
                [Construction],
                [YearBuilt],
                [EffectiveYear],
                [EffectiveAge],
                [Condition],
                [SizeSqFt],
                [SizeText],
                [Units],
                [BaseRate],
                [LCM],
                [AdjRate],
                [RCN],
                [NormDepPct],
                [RemainingValue],
                [AbnObsPct],
                [PctComplete],
                [NeighborhoodFactor],
                [MarketFactor],
                [Cap1Pct],
                [Cap2Pct],
                [Cap3Pct],
                [ImprovementValue],
                [IsFullRead]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, NULL) END,
                CASE WHEN @RowIndex_Clear = 1 THEN NULL ELSE ISNULL(@RowIndex, NULL) END,
                CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, NULL) END,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @Kind,
                CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, NULL) END,
                CASE WHEN @StoryHeight_Clear = 1 THEN NULL ELSE ISNULL(@StoryHeight, NULL) END,
                CASE WHEN @Construction_Clear = 1 THEN NULL ELSE ISNULL(@Construction, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @EffectiveAge_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveAge, NULL) END,
                CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, NULL) END,
                CASE WHEN @SizeSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SizeSqFt, NULL) END,
                CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @BaseRate_Clear = 1 THEN NULL ELSE ISNULL(@BaseRate, NULL) END,
                CASE WHEN @LCM_Clear = 1 THEN NULL ELSE ISNULL(@LCM, NULL) END,
                CASE WHEN @AdjRate_Clear = 1 THEN NULL ELSE ISNULL(@AdjRate, NULL) END,
                CASE WHEN @RCN_Clear = 1 THEN NULL ELSE ISNULL(@RCN, NULL) END,
                CASE WHEN @NormDepPct_Clear = 1 THEN NULL ELSE ISNULL(@NormDepPct, NULL) END,
                CASE WHEN @RemainingValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainingValue, NULL) END,
                CASE WHEN @AbnObsPct_Clear = 1 THEN NULL ELSE ISNULL(@AbnObsPct, NULL) END,
                CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, NULL) END,
                CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, NULL) END,
                CASE WHEN @MarketFactor_Clear = 1 THEN NULL ELSE ISNULL(@MarketFactor, NULL) END,
                CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, NULL) END,
                CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, NULL) END,
                CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, NULL) END,
                CASE WHEN @ImprovementValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementValue, NULL) END,
                @IsFullRead
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardImprovements] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardImprovement] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Improvements */

GRANT EXECUTE ON [indiana_tax].[spCreateCardImprovement] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: spUpdateCardImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardImprovement]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @EntryIndex smallint = NULL,
    @CardNumber_Clear bit = 0,
    @CardNumber smallint = NULL,
    @RowIndex_Clear bit = 0,
    @RowIndex nvarchar(10) = NULL,
    @Quantity_Clear bit = 0,
    @Quantity smallint = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(100) = NULL,
    @Kind nvarchar(10) = NULL,
    @Grade_Clear bit = 0,
    @Grade nvarchar(10) = NULL,
    @StoryHeight_Clear bit = 0,
    @StoryHeight decimal(5, 2) = NULL,
    @Construction_Clear bit = 0,
    @Construction nvarchar(50) = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @EffectiveAge_Clear bit = 0,
    @EffectiveAge smallint = NULL,
    @Condition_Clear bit = 0,
    @Condition nvarchar(5) = NULL,
    @SizeSqFt_Clear bit = 0,
    @SizeSqFt decimal(14, 2) = NULL,
    @SizeText_Clear bit = 0,
    @SizeText nvarchar(30) = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @BaseRate_Clear bit = 0,
    @BaseRate decimal(12, 2) = NULL,
    @LCM_Clear bit = 0,
    @LCM decimal(6, 3) = NULL,
    @AdjRate_Clear bit = 0,
    @AdjRate decimal(12, 2) = NULL,
    @RCN_Clear bit = 0,
    @RCN decimal(14, 2) = NULL,
    @NormDepPct_Clear bit = 0,
    @NormDepPct decimal(5, 2) = NULL,
    @RemainingValue_Clear bit = 0,
    @RemainingValue decimal(14, 2) = NULL,
    @AbnObsPct_Clear bit = 0,
    @AbnObsPct decimal(5, 2) = NULL,
    @PctComplete_Clear bit = 0,
    @PctComplete decimal(5, 2) = NULL,
    @NeighborhoodFactor_Clear bit = 0,
    @NeighborhoodFactor decimal(9, 4) = NULL,
    @MarketFactor_Clear bit = 0,
    @MarketFactor decimal(9, 4) = NULL,
    @Cap1Pct_Clear bit = 0,
    @Cap1Pct decimal(5, 2) = NULL,
    @Cap2Pct_Clear bit = 0,
    @Cap2Pct decimal(5, 2) = NULL,
    @Cap3Pct_Clear bit = 0,
    @Cap3Pct decimal(5, 2) = NULL,
    @ImprovementValue_Clear bit = 0,
    @ImprovementValue decimal(14, 2) = NULL,
    @IsFullRead bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardImprovement]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [EntryIndex] = ISNULL(@EntryIndex, [EntryIndex]),
        [CardNumber] = CASE WHEN @CardNumber_Clear = 1 THEN NULL ELSE ISNULL(@CardNumber, [CardNumber]) END,
        [RowIndex] = CASE WHEN @RowIndex_Clear = 1 THEN NULL ELSE ISNULL(@RowIndex, [RowIndex]) END,
        [Quantity] = CASE WHEN @Quantity_Clear = 1 THEN NULL ELSE ISNULL(@Quantity, [Quantity]) END,
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [Kind] = ISNULL(@Kind, [Kind]),
        [Grade] = CASE WHEN @Grade_Clear = 1 THEN NULL ELSE ISNULL(@Grade, [Grade]) END,
        [StoryHeight] = CASE WHEN @StoryHeight_Clear = 1 THEN NULL ELSE ISNULL(@StoryHeight, [StoryHeight]) END,
        [Construction] = CASE WHEN @Construction_Clear = 1 THEN NULL ELSE ISNULL(@Construction, [Construction]) END,
        [YearBuilt] = CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, [YearBuilt]) END,
        [EffectiveYear] = CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, [EffectiveYear]) END,
        [EffectiveAge] = CASE WHEN @EffectiveAge_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveAge, [EffectiveAge]) END,
        [Condition] = CASE WHEN @Condition_Clear = 1 THEN NULL ELSE ISNULL(@Condition, [Condition]) END,
        [SizeSqFt] = CASE WHEN @SizeSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SizeSqFt, [SizeSqFt]) END,
        [SizeText] = CASE WHEN @SizeText_Clear = 1 THEN NULL ELSE ISNULL(@SizeText, [SizeText]) END,
        [Units] = CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, [Units]) END,
        [BaseRate] = CASE WHEN @BaseRate_Clear = 1 THEN NULL ELSE ISNULL(@BaseRate, [BaseRate]) END,
        [LCM] = CASE WHEN @LCM_Clear = 1 THEN NULL ELSE ISNULL(@LCM, [LCM]) END,
        [AdjRate] = CASE WHEN @AdjRate_Clear = 1 THEN NULL ELSE ISNULL(@AdjRate, [AdjRate]) END,
        [RCN] = CASE WHEN @RCN_Clear = 1 THEN NULL ELSE ISNULL(@RCN, [RCN]) END,
        [NormDepPct] = CASE WHEN @NormDepPct_Clear = 1 THEN NULL ELSE ISNULL(@NormDepPct, [NormDepPct]) END,
        [RemainingValue] = CASE WHEN @RemainingValue_Clear = 1 THEN NULL ELSE ISNULL(@RemainingValue, [RemainingValue]) END,
        [AbnObsPct] = CASE WHEN @AbnObsPct_Clear = 1 THEN NULL ELSE ISNULL(@AbnObsPct, [AbnObsPct]) END,
        [PctComplete] = CASE WHEN @PctComplete_Clear = 1 THEN NULL ELSE ISNULL(@PctComplete, [PctComplete]) END,
        [NeighborhoodFactor] = CASE WHEN @NeighborhoodFactor_Clear = 1 THEN NULL ELSE ISNULL(@NeighborhoodFactor, [NeighborhoodFactor]) END,
        [MarketFactor] = CASE WHEN @MarketFactor_Clear = 1 THEN NULL ELSE ISNULL(@MarketFactor, [MarketFactor]) END,
        [Cap1Pct] = CASE WHEN @Cap1Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap1Pct, [Cap1Pct]) END,
        [Cap2Pct] = CASE WHEN @Cap2Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap2Pct, [Cap2Pct]) END,
        [Cap3Pct] = CASE WHEN @Cap3Pct_Clear = 1 THEN NULL ELSE ISNULL(@Cap3Pct, [Cap3Pct]) END,
        [ImprovementValue] = CASE WHEN @ImprovementValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementValue, [ImprovementValue]) END,
        [IsFullRead] = ISNULL(@IsFullRead, [IsFullRead])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardImprovements] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardImprovements]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardImprovement] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardImprovement table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardImprovement]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardImprovement];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardImprovement
ON [indiana_tax].[CardImprovement]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardImprovement]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardImprovement] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Improvements */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardImprovement] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Improvements */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Improvements
-- Item: spDeleteCardImprovement
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardImprovement
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardImprovement]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardImprovement];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardImprovement]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardImprovement]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardImprovement] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Improvements */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardImprovement] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: vwCardSummaries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Summaries
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardSummary
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardSummaries]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardSummaries];
GO

CREATE VIEW [indiana_tax].[vwCardSummaries]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardSummary] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardSummaries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: Permissions for vwCardSummaries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardSummaries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spCreateCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardSummary]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @PropertyClassDescription_Clear bit = 0,
    @PropertyClassDescription nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @SitusAddress_Clear bit = 0,
    @SitusAddress nvarchar(200) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage decimal(10, 4) = NULL,
    @BuildingSqFt_Clear bit = 0,
    @BuildingSqFt int = NULL,
    @SiteImprovementSqFt_Clear bit = 0,
    @SiteImprovementSqFt int = NULL,
    @AncillarySqFt_Clear bit = 0,
    @AncillarySqFt int = NULL,
    @OtherSqFt_Clear bit = 0,
    @OtherSqFt int = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @OldestStructureYear_Clear bit = 0,
    @OldestStructureYear smallint = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @ImprovementCount_Clear bit = 0,
    @ImprovementCount smallint = NULL,
    @BuildingCount_Clear bit = 0,
    @BuildingCount smallint = NULL,
    @CardCount_Clear bit = 0,
    @CardCount smallint = NULL,
    @ImprovementRowsValue_Clear bit = 0,
    @ImprovementRowsValue decimal(14, 2) = NULL,
    @PrintedDate_Clear bit = 0,
    @PrintedDate date = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardSummary]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [PropertyClassCode],
                [PropertyClassDescription],
                [OwnerName],
                [SitusAddress],
                [Acreage],
                [BuildingSqFt],
                [SiteImprovementSqFt],
                [AncillarySqFt],
                [OtherSqFt],
                [YearBuilt],
                [EffectiveYear],
                [OldestStructureYear],
                [Units],
                [ImprovementCount],
                [BuildingCount],
                [CardCount],
                [ImprovementRowsValue],
                [PrintedDate],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, NULL) END,
                CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, NULL) END,
                CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, NULL) END,
                CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, NULL) END,
                CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, NULL) END,
                CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, NULL) END,
                CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, NULL) END,
                CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardSummary]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [PropertyClassCode],
                [PropertyClassDescription],
                [OwnerName],
                [SitusAddress],
                [Acreage],
                [BuildingSqFt],
                [SiteImprovementSqFt],
                [AncillarySqFt],
                [OtherSqFt],
                [YearBuilt],
                [EffectiveYear],
                [OldestStructureYear],
                [Units],
                [ImprovementCount],
                [BuildingCount],
                [CardCount],
                [ImprovementRowsValue],
                [PrintedDate],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, NULL) END,
                CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, NULL) END,
                CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, NULL) END,
                CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, NULL) END,
                CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, NULL) END,
                CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, NULL) END,
                CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, NULL) END,
                CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardSummaries] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spCreateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spUpdateCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardSummary]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @PropertyClassDescription_Clear bit = 0,
    @PropertyClassDescription nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @SitusAddress_Clear bit = 0,
    @SitusAddress nvarchar(200) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage decimal(10, 4) = NULL,
    @BuildingSqFt_Clear bit = 0,
    @BuildingSqFt int = NULL,
    @SiteImprovementSqFt_Clear bit = 0,
    @SiteImprovementSqFt int = NULL,
    @AncillarySqFt_Clear bit = 0,
    @AncillarySqFt int = NULL,
    @OtherSqFt_Clear bit = 0,
    @OtherSqFt int = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @OldestStructureYear_Clear bit = 0,
    @OldestStructureYear smallint = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @ImprovementCount_Clear bit = 0,
    @ImprovementCount smallint = NULL,
    @BuildingCount_Clear bit = 0,
    @BuildingCount smallint = NULL,
    @CardCount_Clear bit = 0,
    @CardCount smallint = NULL,
    @ImprovementRowsValue_Clear bit = 0,
    @ImprovementRowsValue decimal(14, 2) = NULL,
    @PrintedDate_Clear bit = 0,
    @PrintedDate date = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardSummary]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [PropertyClassCode] = CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, [PropertyClassCode]) END,
        [PropertyClassDescription] = CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, [PropertyClassDescription]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [SitusAddress] = CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, [SitusAddress]) END,
        [Acreage] = CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, [Acreage]) END,
        [BuildingSqFt] = CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, [BuildingSqFt]) END,
        [SiteImprovementSqFt] = CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, [SiteImprovementSqFt]) END,
        [AncillarySqFt] = CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, [AncillarySqFt]) END,
        [OtherSqFt] = CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, [OtherSqFt]) END,
        [YearBuilt] = CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, [YearBuilt]) END,
        [EffectiveYear] = CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, [EffectiveYear]) END,
        [OldestStructureYear] = CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, [OldestStructureYear]) END,
        [Units] = CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, [Units]) END,
        [ImprovementCount] = CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, [ImprovementCount]) END,
        [BuildingCount] = CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, [BuildingCount]) END,
        [CardCount] = CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, [CardCount]) END,
        [ImprovementRowsValue] = CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, [ImprovementRowsValue]) END,
        [PrintedDate] = CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, [PrintedDate]) END,
        [ParseNotes] = CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, [ParseNotes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardSummaries] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardSummaries]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardSummary] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardSummary table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardSummary]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardSummary];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardSummary
ON [indiana_tax].[CardSummary]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardSummary]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardSummary] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spDeleteCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardSummary]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardSummary]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardSummary] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5b54942f-b2ff-4079-9b7b-2b08075f68c9' OR (EntityID = '5E919079-F0CC-4DDF-B409-986240471F52' AND Name = 'Parcel')) BEGIN
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
            '5b54942f-b2ff-4079-9b7b-2b08075f68c9',
            '5E919079-F0CC-4DDF-B409-986240471F52', -- Entity: Card Improvements
            100075,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '29dd337b-7476-4ed3-902c-fe87b4cbc646' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = 'Parcel')) BEGIN
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
            '29dd337b-7476-4ed3-902c-fe87b4cbc646',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
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
               SET IsNameField = 1
               WHERE ID = 'F682161B-1782-4C72-94B0-31F1C8159656'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7F1330F9-F46E-4E4C-8BF1-15BB520952B4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B5DA0DEE-BAFB-4BD1-BD87-5E334BCCBB3D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7AFADCB7-FE06-4C41-8AA0-55BD7808E69D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '27CCAD70-F351-4050-93E7-090CB444E755'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F682161B-1782-4C72-94B0-31F1C8159656'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '2D386953-C796-45B3-94D6-F48E27B33A0D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '72950FBF-A196-4DCE-B873-A429442B1241'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3ADABE3D-66E2-4BDF-A340-603DD523E538'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'B5DA0DEE-BAFB-4BD1-BD87-5E334BCCBB3D'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '7AFADCB7-FE06-4C41-8AA0-55BD7808E69D'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '27CCAD70-F351-4050-93E7-090CB444E755'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'F682161B-1782-4C72-94B0-31F1C8159656'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'B5DA0DEE-BAFB-4BD1-BD87-5E334BCCBB3D'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '06D8F0FD-0A7F-4103-A846-E437B8DB981C'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D9230841-B6A0-4F6D-81BD-DD1D088B22E0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '06D8F0FD-0A7F-4103-A846-E437B8DB981C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '98876186-F6B0-4624-A267-75E6DC2F6B93'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A9B4D7DE-E190-4388-AF36-A01C82855EEC'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '45FF92F3-C5DB-420C-BCF7-0430B2610003'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '77C22DC6-139A-49FE-8078-457CE1B9DB1F'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '06D8F0FD-0A7F-4103-A846-E437B8DB981C'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '98876186-F6B0-4624-A267-75E6DC2F6B93'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'ABA41596-86C5-4A40-8503-14B94F3895BC'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '98876186-F6B0-4624-A267-75E6DC2F6B93'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'ABA41596-86C5-4A40-8503-14B94F3895BC'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 26 fields */

-- UPDATE Entity Field Category Info Card Summaries.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '021561E4-F52F-47FB-9F9C-E7B6FDAA84F4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '02952189-33FE-44CB-8982-757512648AFA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04557C42-D1E0-4B37-A874-7D1F4E759238' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '29DD337B-7476-4ED3-902C-FE87B4CBC646' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Assessment Year',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7F1330F9-F46E-4E4C-8BF1-15BB520952B4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.PropertyClassCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = NULL
WHERE 
   ID = 'B5DA0DEE-BAFB-4BD1-BD87-5E334BCCBB3D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.PropertyClassDescription 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7AFADCB7-FE06-4C41-8AA0-55BD7808E69D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.OwnerName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ownership Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '27CCAD70-F351-4050-93E7-090CB444E755' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.SitusAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ownership Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = 'F682161B-1782-4C72-94B0-31F1C8159656' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.Acreage 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Land Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2D386953-C796-45B3-94D6-F48E27B33A0D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.BuildingSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Measurements',
   GeneratedFormSection = 'Category',
   DisplayName = 'Building Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '72950FBF-A196-4DCE-B873-A429442B1241' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.SiteImprovementSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Measurements',
   GeneratedFormSection = 'Category',
   DisplayName = 'Site Improvement Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0B1F2A8A-1775-457B-986B-D9A653BF2A39' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.AncillarySqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Measurements',
   GeneratedFormSection = 'Category',
   DisplayName = 'Ancillary Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3ADECC75-6B4F-4274-88A6-FA4F8764FFD3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.OtherSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Measurements',
   GeneratedFormSection = 'Category',
   DisplayName = 'Other Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C123EC38-DF0F-4A54-B798-88B4DC544129' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.YearBuilt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Building History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3ADABE3D-66E2-4BDF-A340-603DD523E538' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.EffectiveYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Building History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0029C2AE-0DC9-455C-A9E0-1406453ED2AC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.OldestStructureYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Building History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7186EFF1-99D0-4260-AAA9-1CCE06993E99' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.Units 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Measurements',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2550FAF1-9A19-4E4E-8458-9FD903D5F0ED' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.ImprovementCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Summaries',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '660623CB-F893-4353-A988-1F3CD7B8522F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.BuildingCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Summaries',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '65ABC261-6CB6-4349-8E25-57E9F0BA1732' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.CardCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Summaries',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A53EF91C-994C-4EED-A00D-02AFD6068C0C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.ImprovementRowsValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D074406E-38CC-401C-8C50-418F86B12C6A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.PrintedDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Administration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3F836E31-460F-4194-9E47-4950E29997D3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.ParseNotes 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Card Administration',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D6977610-AA25-4185-8C09-5188F7945CB2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1E5DE659-15A5-4059-AB48-D0285B7019E7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Summaries.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7AEA8FCF-308E-47C4-A120-6D129DA1AB3E' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for Card Summaries */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '81EF2E46-B503-4703-9565-ED38208C85A3' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-file-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '81EF2E46-B503-4703-9565-ED38208C85A3';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('68c50a7e-cb55-4141-a018-b121ad87904a', '81EF2E46-B503-4703-9565-ED38208C85A3', 'FieldCategoryInfo', '{"Card Identification":{"icon":"fa fa-id-card","description":"Unique identifiers for the card, parcel, and assessment year"},"Property Classification":{"icon":"fa fa-tag","description":"Property class code and description categorizing the property type"},"Ownership Information":{"icon":"fa fa-user-circle","description":"Owner name and property physical address"},"Land Details":{"icon":"fa fa-map","description":"Land measurement and acreage calculations"},"Improvement Measurements":{"icon":"fa fa-ruler-combined","description":"Square footage measurements for all improvement types including buildings, site features, and ancillary structures"},"Building History":{"icon":"fa fa-calendar-alt","description":"Construction and effective valuation years for buildings on the property"},"Improvement Summaries":{"icon":"fa fa-list-ol","description":"Count summaries of improvements and cards in the assessment record"},"Valuation Details":{"icon":"fa fa-dollar-sign","description":"Assessed improvement values"},"Card Administration":{"icon":"fa fa-clipboard","description":"Card production date and data quality notes from parsing"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e074881d-4003-4b0d-9e01-3220e8b42b87', '81EF2E46-B503-4703-9565-ED38208C85A3', 'FieldCategoryIcons', '{"Card Identification":"fa fa-id-card","Property Classification":"fa fa-tag","Ownership Information":"fa fa-user-circle","Land Details":"fa fa-map","Improvement Measurements":"fa fa-ruler-combined","Building History":"fa fa-calendar-alt","Improvement Summaries":"fa fa-list-ol","Valuation Details":"fa fa-dollar-sign","Card Administration":"fa fa-clipboard","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '81EF2E46-B503-4703-9565-ED38208C85A3';

/* Set categories for 38 fields */

-- UPDATE Entity Field Category Info Card Improvements.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F37309BF-3995-4485-BD15-32942A4894D8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '403BDA96-D357-42B0-B352-BEA90099D416' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C8895540-4E03-4B37-B8B9-EDB30B6E8ADF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5B54942F-B2FF-4079-9B7B-2B08075F68C9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '521E8FF6-B998-478E-958C-55C72EBE50EE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '73C3C2CD-D173-4CB7-A6AF-70F74590572A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D9230841-B6A0-4F6D-81BD-DD1D088B22E0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.CardNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D1FF996C-AD34-425B-92AE-E930339F1750' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.EntryIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E501A3A2-0BFA-4F2F-BD77-851A00648A2B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.RowIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '106EB563-35E1-41FA-9452-07B3063FBE3B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.IsFullRead 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Full Read',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '202423E5-CCE7-4F63-A18A-095127896B25' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Description 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '06D8F0FD-0A7F-4103-A846-E437B8DB981C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Kind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '98876186-F6B0-4624-A267-75E6DC2F6B93' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Quantity 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Improvement Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B88481AB-EDC5-4660-8A2E-4D3B74F9E5ED' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.SizeSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Size and Dimensions',
   GeneratedFormSection = 'Category',
   DisplayName = 'Size (Sq Ft)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E5483492-5955-4E67-A905-5D594DE1954D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.SizeText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Size and Dimensions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '45FF92F3-C5DB-420C-BCF7-0430B2610003' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Units 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Size and Dimensions',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0DA7BD91-5A1E-4E7D-92C6-598C159D8C74' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Grade 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Construction and Condition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AB146C48-BF22-4B1A-98D7-2E68F84302CF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Construction 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Construction and Condition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Construction Type',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ABA41596-86C5-4A40-8503-14B94F3895BC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Condition 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Construction and Condition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A9B4D7DE-E190-4388-AF36-A01C82855EEC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.StoryHeight 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Construction and Condition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '46DE89ED-521C-430B-8C56-BA641E75C44E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.YearBuilt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Age and Depreciation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '14B92391-3E9B-4D6B-ADB4-3D4250175C9F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.EffectiveYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Age and Depreciation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2F2DD150-7988-46AD-BCAB-AD2C5EA5533D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.EffectiveAge 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Age and Depreciation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2843CD4E-8027-476E-82AE-AEEA04CA732F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.BaseRate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Factors',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '224855F1-C2DE-496E-8940-E9D19450AA07' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.LCM 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Factors',
   GeneratedFormSection = 'Category',
   DisplayName = 'Location Cost Multiplier',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7BE529E1-3D82-41FA-BFD9-2176FEDFF9EF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.AdjRate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Factors',
   GeneratedFormSection = 'Category',
   DisplayName = 'Adjusted Rate',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '768AAC2B-8417-43FC-B64F-F731FA30FA0E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.RCN 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Factors',
   GeneratedFormSection = 'Category',
   DisplayName = 'Replacement Cost New',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FFDDFCB4-7686-471D-B903-7F17278E2416' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.NormDepPct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Depreciation and Adjustments',
   GeneratedFormSection = 'Category',
   DisplayName = 'Normal Depreciation %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AC1A6779-D22E-49C8-8814-0E21B02CA818' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.RemainingValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Depreciation and Adjustments',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DECEBC5D-C08F-48BB-99AC-A11C0B1A3111' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.AbnObsPct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Depreciation and Adjustments',
   GeneratedFormSection = 'Category',
   DisplayName = 'Abnormal Obsolescence %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A1AFC4B-E8D8-4245-94A4-00481F41CBE4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.PctComplete 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Depreciation and Adjustments',
   GeneratedFormSection = 'Category',
   DisplayName = 'Percent Complete',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B6D56818-00E4-4922-91ED-ADDFAC91526A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.NeighborhoodFactor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Market Adjustments',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2C045D92-42AC-486C-8F55-94F918A56A31' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.MarketFactor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Market Adjustments',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FA56FC8C-816B-49FC-AADE-6064C642A7FF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Cap1Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Caps',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 1%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3D0D6577-EFF2-44DD-AF77-CBC9A212D721' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Cap2Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Caps',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 2%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '92CBB177-ED7D-4244-BCFA-8FA87271F601' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.Cap3Pct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Caps',
   GeneratedFormSection = 'Category',
   DisplayName = 'Cap 3%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '48385A9D-A9A7-491B-B7F3-18DFCD4D96F6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Improvements.ImprovementValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Final Assessment Value',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '77C22DC6-139A-49FE-8078-457CE1B9DB1F' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-home */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-home', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '5E919079-F0CC-4DDF-B409-986240471F52';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('38cf29fa-d0d5-4058-b177-04cab6fdafe5', '5E919079-F0CC-4DDF-B409-986240471F52', 'FieldCategoryInfo', '{"Assessment Information":{"icon":"fa fa-clipboard-list","description":"County assessment card and row tracking information"},"Improvement Details":{"icon":"fa fa-home","description":"Classification and identification of the structure or yard item being priced"},"Size and Dimensions":{"icon":"fa fa-ruler-combined","description":"Physical size measurements in various formats (square footage, dimensions, units)"},"Construction and Condition":{"icon":"fa fa-hammer","description":"Building materials, construction type, grade rating, and physical condition"},"Age and Depreciation":{"icon":"fa fa-calendar-alt","description":"Year built, effective year, and effective age for calculating depreciation"},"Valuation Factors":{"icon":"fa fa-calculator","description":"Rates, multipliers, and replacement cost calculations used in valuation"},"Depreciation and Adjustments":{"icon":"fa fa-chart-line","description":"Normal and abnormal depreciation, completion percentage, and value after depreciation"},"Market Adjustments":{"icon":"fa fa-trending-up","description":"Neighborhood and market trending factors applied to value"},"Assessed Value Caps":{"icon":"fa fa-percentage","description":"Circuit-breaker cap split percentages applied to assessed value"},"Final Assessment Value":{"icon":"fa fa-dollar-sign","description":"The final assessed improvement value for tax purposes"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit, tracking, and reference fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('7f91901b-503f-42e2-b357-f746ce100b48', '5E919079-F0CC-4DDF-B409-986240471F52', 'FieldCategoryIcons', '{"Assessment Information":"fa fa-clipboard-list","Improvement Details":"fa fa-home","Size and Dimensions":"fa fa-ruler-combined","Construction and Condition":"fa fa-hammer","Age and Depreciation":"fa fa-calendar-alt","Valuation Factors":"fa fa-calculator","Depreciation and Adjustments":"fa fa-chart-line","Market Adjustments":"fa fa-trending-up","Assessed Value Caps":"fa fa-percentage","Final Assessment Value":"fa fa-dollar-sign","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '5E919079-F0CC-4DDF-B409-986240471F52';

/* Index for Foreign Keys for CardSummary */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardSummary
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardSummary_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardSummary]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardSummary_SourceDocumentID ON [indiana_tax].[CardSummary] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardSummary
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardSummary_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardSummary]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardSummary_ParcelID ON [indiana_tax].[CardSummary] ([ParcelID]);

/* Base View SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: vwCardSummaries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Summaries
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardSummary
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardSummaries]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardSummaries];
GO

CREATE VIEW [indiana_tax].[vwCardSummaries]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[CardSummary] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '81EF2E46-B503-4703-9565-ED38208C85A3'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([c].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwCardSummaries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: Permissions for vwCardSummaries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardSummaries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spCreateCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardSummary]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @PropertyClassDescription_Clear bit = 0,
    @PropertyClassDescription nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @SitusAddress_Clear bit = 0,
    @SitusAddress nvarchar(200) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage decimal(10, 4) = NULL,
    @BuildingSqFt_Clear bit = 0,
    @BuildingSqFt int = NULL,
    @SiteImprovementSqFt_Clear bit = 0,
    @SiteImprovementSqFt int = NULL,
    @AncillarySqFt_Clear bit = 0,
    @AncillarySqFt int = NULL,
    @OtherSqFt_Clear bit = 0,
    @OtherSqFt int = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @OldestStructureYear_Clear bit = 0,
    @OldestStructureYear smallint = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @ImprovementCount_Clear bit = 0,
    @ImprovementCount smallint = NULL,
    @BuildingCount_Clear bit = 0,
    @BuildingCount smallint = NULL,
    @CardCount_Clear bit = 0,
    @CardCount smallint = NULL,
    @ImprovementRowsValue_Clear bit = 0,
    @ImprovementRowsValue decimal(14, 2) = NULL,
    @PrintedDate_Clear bit = 0,
    @PrintedDate date = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardSummary]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [PropertyClassCode],
                [PropertyClassDescription],
                [OwnerName],
                [SitusAddress],
                [Acreage],
                [BuildingSqFt],
                [SiteImprovementSqFt],
                [AncillarySqFt],
                [OtherSqFt],
                [YearBuilt],
                [EffectiveYear],
                [OldestStructureYear],
                [Units],
                [ImprovementCount],
                [BuildingCount],
                [CardCount],
                [ImprovementRowsValue],
                [PrintedDate],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, NULL) END,
                CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, NULL) END,
                CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, NULL) END,
                CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, NULL) END,
                CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, NULL) END,
                CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, NULL) END,
                CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, NULL) END,
                CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardSummary]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [PropertyClassCode],
                [PropertyClassDescription],
                [OwnerName],
                [SitusAddress],
                [Acreage],
                [BuildingSqFt],
                [SiteImprovementSqFt],
                [AncillarySqFt],
                [OtherSqFt],
                [YearBuilt],
                [EffectiveYear],
                [OldestStructureYear],
                [Units],
                [ImprovementCount],
                [BuildingCount],
                [CardCount],
                [ImprovementRowsValue],
                [PrintedDate],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, NULL) END,
                CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, NULL) END,
                CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, NULL) END,
                CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, NULL) END,
                CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, NULL) END,
                CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, NULL) END,
                CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, NULL) END,
                CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, NULL) END,
                CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardSummaries] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spCreateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spUpdateCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardSummary]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @PropertyClassDescription_Clear bit = 0,
    @PropertyClassDescription nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @SitusAddress_Clear bit = 0,
    @SitusAddress nvarchar(200) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage decimal(10, 4) = NULL,
    @BuildingSqFt_Clear bit = 0,
    @BuildingSqFt int = NULL,
    @SiteImprovementSqFt_Clear bit = 0,
    @SiteImprovementSqFt int = NULL,
    @AncillarySqFt_Clear bit = 0,
    @AncillarySqFt int = NULL,
    @OtherSqFt_Clear bit = 0,
    @OtherSqFt int = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @EffectiveYear_Clear bit = 0,
    @EffectiveYear smallint = NULL,
    @OldestStructureYear_Clear bit = 0,
    @OldestStructureYear smallint = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @ImprovementCount_Clear bit = 0,
    @ImprovementCount smallint = NULL,
    @BuildingCount_Clear bit = 0,
    @BuildingCount smallint = NULL,
    @CardCount_Clear bit = 0,
    @CardCount smallint = NULL,
    @ImprovementRowsValue_Clear bit = 0,
    @ImprovementRowsValue decimal(14, 2) = NULL,
    @PrintedDate_Clear bit = 0,
    @PrintedDate date = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardSummary]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [PropertyClassCode] = CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, [PropertyClassCode]) END,
        [PropertyClassDescription] = CASE WHEN @PropertyClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassDescription, [PropertyClassDescription]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [SitusAddress] = CASE WHEN @SitusAddress_Clear = 1 THEN NULL ELSE ISNULL(@SitusAddress, [SitusAddress]) END,
        [Acreage] = CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, [Acreage]) END,
        [BuildingSqFt] = CASE WHEN @BuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFt, [BuildingSqFt]) END,
        [SiteImprovementSqFt] = CASE WHEN @SiteImprovementSqFt_Clear = 1 THEN NULL ELSE ISNULL(@SiteImprovementSqFt, [SiteImprovementSqFt]) END,
        [AncillarySqFt] = CASE WHEN @AncillarySqFt_Clear = 1 THEN NULL ELSE ISNULL(@AncillarySqFt, [AncillarySqFt]) END,
        [OtherSqFt] = CASE WHEN @OtherSqFt_Clear = 1 THEN NULL ELSE ISNULL(@OtherSqFt, [OtherSqFt]) END,
        [YearBuilt] = CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, [YearBuilt]) END,
        [EffectiveYear] = CASE WHEN @EffectiveYear_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveYear, [EffectiveYear]) END,
        [OldestStructureYear] = CASE WHEN @OldestStructureYear_Clear = 1 THEN NULL ELSE ISNULL(@OldestStructureYear, [OldestStructureYear]) END,
        [Units] = CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, [Units]) END,
        [ImprovementCount] = CASE WHEN @ImprovementCount_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementCount, [ImprovementCount]) END,
        [BuildingCount] = CASE WHEN @BuildingCount_Clear = 1 THEN NULL ELSE ISNULL(@BuildingCount, [BuildingCount]) END,
        [CardCount] = CASE WHEN @CardCount_Clear = 1 THEN NULL ELSE ISNULL(@CardCount, [CardCount]) END,
        [ImprovementRowsValue] = CASE WHEN @ImprovementRowsValue_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRowsValue, [ImprovementRowsValue]) END,
        [PrintedDate] = CASE WHEN @PrintedDate_Clear = 1 THEN NULL ELSE ISNULL(@PrintedDate, [PrintedDate]) END,
        [ParseNotes] = CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, [ParseNotes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardSummaries] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardSummaries]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardSummary] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardSummary table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardSummary]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardSummary];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardSummary
ON [indiana_tax].[CardSummary]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardSummary]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardSummary] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Summaries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Summaries
-- Item: spDeleteCardSummary
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardSummary
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardSummary]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardSummary];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardSummary]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardSummary]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardSummary] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Summaries */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardSummary] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9f71ec7-0b78-4246-8f44-7e1a201384fc' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
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
            'a9f71ec7-0b78-4246-8f44-7e1a201384fc',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100053,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b38fa617-e047-4b67-b00a-23d4a893aad7' OR (EntityID = '81EF2E46-B503-4703-9565-ED38208C85A3' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
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
            'b38fa617-e047-4b67-b00a-23d4a893aad7',
            '81EF2E46-B503-4703-9565-ED38208C85A3', -- Entity: Card Summaries
            100054,
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
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${flyway:defaultSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('81EF2E46-B503-4703-9565-ED38208C85A3');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${flyway:defaultSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('81EF2E46-B503-4703-9565-ED38208C85A3');

