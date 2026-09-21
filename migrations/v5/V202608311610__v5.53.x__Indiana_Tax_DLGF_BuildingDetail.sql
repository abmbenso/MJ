/* ============================================================================
   Indiana Property Tax Expert — DLGF building / improvement / land detail
   v5.53.x  (OPP-31)

   The DLGF/GIO statewide geodatabase (Indiana_Parcels_2025.gdb) ships six
   attribute tables. migrate-parcels-assessments.js only brought PARCEL-level AV
   into indiana_tax.Assessment; the physical-detail tables were extracted only
   as far as Indiana_Assessment_Database/.../assessments.db.

   This adds four of them to indiana_tax (C&I slice, class 300-499, all 92
   counties) as an INDEPENDENT source to cross-check the Marion PRC's SqFt /
   year-built / grade (which every comp / uniformity / valuation output leans
   on via ParcelPhysicalProfile), and to supply the cost-approach RCN inputs
   the tool lacks (ReplacementCost + depreciation on DLGFImprovement).

   DLGF-sourced -- kept in their OWN tables, never merged with the PRC-sourced
   CountyAssessorImprovement / ...Segment. Every row carries ParcelID +
   SourceDocumentID (the gdb doc, DocumentType 'StatewideParcelDataset').

   NOT loaded here: DWELLING (residential dwelling detail, ~22.9k rows on
   mixed-use C&I parcels) -- out of scope for the C&I tool; load with the
   residential build (docs/proposals/residential-taxpayer-tool.md).

   Loaded by scripts/load-dlgf-building-detail.js from assessments.db.
   Column names/semantics: Indiana_Assessment_Database/source_data/statewide/
   DATA_DICTIONARY.md.
   ============================================================================ */

-------------------------------------------------------------------------------
-- DLGFBuilding  (one row per building on a parcel)
-------------------------------------------------------------------------------
CREATE TABLE indiana_tax.DLGFBuilding (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    SourceYear SMALLINT NOT NULL,

    BuildingNumber NVARCHAR(20) NULL,
    PricingKeyPredominantUse NVARCHAR(20) NULL,
    NumberOfFloors DECIMAL(6, 2) NULL,
    TotalSquareFootArea DECIMAL(14, 2) NULL,
    TotalBaseValue DECIMAL(14, 2) NULL,
    PlumbingFixturesValue DECIMAL(14, 2) NULL,
    SpecialFeaturesValue DECIMAL(14, 2) NULL,
    ExteriorFeaturesValue DECIMAL(14, 2) NULL,
    ImprovementInstanceNumber INT NULL,
    BuildingInstanceNumber INT NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFBuilding_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFBuilding_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_DLGFBuilding PRIMARY KEY (ID),
    CONSTRAINT FK_DLGFBuilding_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_DLGFBuilding_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_DLGFBuilding_Parcel ON indiana_tax.DLGFBuilding (ParcelID);
GO

-------------------------------------------------------------------------------
-- DLGFBuildingDetail  (floor/section pricing rows within a building)
-------------------------------------------------------------------------------
CREATE TABLE indiana_tax.DLGFBuildingDetail (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    SourceYear SMALLINT NOT NULL,

    BuildingNumber NVARCHAR(20) NULL,
    FloorNumber NVARCHAR(10) NULL,
    SectionLetterOrNumber NVARCHAR(10) NULL,
    PricingKey NVARCHAR(20) NULL,
    UseCode NVARCHAR(20) NULL,
    SquareFootArea DECIMAL(14, 2) NULL,
    SquareFootRate DECIMAL(14, 4) NULL,
    FramingType DECIMAL(9, 2) NULL,
    WallType DECIMAL(9, 2) NULL,
    WallHeight DECIMAL(9, 2) NULL,
    HeatingACValueAdjustment DECIMAL(14, 2) NULL,
    SprinklerValueAdjustment DECIMAL(14, 2) NULL,
    AverageDepthForStripRetail NVARCHAR(20) NULL,
    IndividuallyOwnedUnit NVARCHAR(10) NULL,
    IndividuallyOwnedUnitSize DECIMAL(14, 2) NULL,
    ConfigurationCode NVARCHAR(20) NULL,
    NumberOfUnits DECIMAL(9, 2) NULL,
    AverageUnitSize DECIMAL(14, 2) NULL,
    ImprovementInstanceNumber INT NULL,
    BuildingInstanceNumber INT NULL,
    BuildingDetailInstanceNumber INT NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFBuildingDetail_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFBuildingDetail_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_DLGFBuildingDetail PRIMARY KEY (ID),
    CONSTRAINT FK_DLGFBuildingDetail_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_DLGFBuildingDetail_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_DLGFBuildingDetail_Parcel ON indiana_tax.DLGFBuildingDetail (ParcelID);
GO

-------------------------------------------------------------------------------
-- DLGFImprovement  (one row per improvement; carries grade / age / RCN)
-------------------------------------------------------------------------------
CREATE TABLE indiana_tax.DLGFImprovement (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    SourceYear SMALLINT NOT NULL,

    DwellingOrBuildingNumber NVARCHAR(20) NULL,
    ImprovementInstanceNumber NVARCHAR(10) NULL,
    ImprovementTypeCode NVARCHAR(20) NULL,
    StoryHeightOrHeight DECIMAL(9, 2) NULL,
    ConstructionTypeCode NVARCHAR(20) NULL,
    YearConstructed NVARCHAR(10) NULL,
    YearRemodeled NVARCHAR(10) NULL,
    EffectiveConstructionYear NVARCHAR(10) NULL,
    Grade NVARCHAR(10) NULL,
    ConditionCode NVARCHAR(10) NULL,
    NeighborhoodCode NVARCHAR(30) NULL,
    ImprovementSize DECIMAL(14, 2) NULL,
    ReplacementCost DECIMAL(14, 2) NULL,
    AppraisedValue DECIMAL(14, 2) NULL,
    PhysicalDepreciationPct DECIMAL(9, 4) NULL,
    ObsolescenceDepreciationPct DECIMAL(9, 4) NULL,
    PercentComplete DECIMAL(9, 4) NULL,
    AVImprovements1PercentCap DECIMAL(14, 2) NULL,
    AVImprovements2PercentCap DECIMAL(14, 2) NULL,
    AVImprovements3PercentCap DECIMAL(14, 2) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFImprovement_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFImprovement_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_DLGFImprovement PRIMARY KEY (ID),
    CONSTRAINT FK_DLGFImprovement_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_DLGFImprovement_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_DLGFImprovement_Parcel ON indiana_tax.DLGFImprovement (ParcelID);
GO

-------------------------------------------------------------------------------
-- DLGFLand  (one row per land segment)
-------------------------------------------------------------------------------
CREATE TABLE indiana_tax.DLGFLand (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    SourceYear SMALLINT NOT NULL,

    LandInstanceNumber NVARCHAR(10) NULL,
    LandLotTypeCode NVARCHAR(10) NULL,
    ActualFrontage DECIMAL(12, 2) NULL,
    EffectiveFrontage DECIMAL(12, 2) NULL,
    EffectiveDepth DECIMAL(12, 2) NULL,
    BaseRate DECIMAL(14, 4) NULL,
    AppraisedValue DECIMAL(14, 2) NULL,
    Acreage DECIMAL(14, 4) NULL,
    SquareFeet DECIMAL(16, 2) NULL,
    SoilID NVARCHAR(20) NULL,
    SoilProductivityFactor DECIMAL(9, 4) NULL,
    InfluenceFactorCode1 NVARCHAR(10) NULL,
    InfluenceFactor1 DECIMAL(9, 4) NULL,
    InfluenceFactorCode2 NVARCHAR(10) NULL,
    InfluenceFactor2 DECIMAL(9, 4) NULL,
    InfluenceFactorCode3 NVARCHAR(10) NULL,
    InfluenceFactor3 DECIMAL(9, 4) NULL,
    DepthFactor DECIMAL(9, 4) NULL,
    AcreageFactor DECIMAL(9, 4) NULL,
    AVLand1PercentCap DECIMAL(14, 2) NULL,
    AVLand2PercentCap DECIMAL(14, 2) NULL,
    AVLand3PercentCap DECIMAL(14, 2) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFLand_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_DLGFLand_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_DLGFLand PRIMARY KEY (ID),
    CONSTRAINT FK_DLGFLand_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_DLGFLand_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_DLGFLand_Parcel ON indiana_tax.DLGFLand (ParcelID);
GO

-------------------------------------------------------------------------------
-- descriptions
-------------------------------------------------------------------------------
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF/GIO statewide geodatabase BUILDING table, C&I slice (class 300-499, all 92 counties). One row per building. Independent of the PRC-sourced CountyAssessorImprovement -- kept separate as a cross-check source. Every row carries SourceDocumentID (the gdb, DocumentType StatewideParcelDataset).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFBuilding';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF/GIO statewide geodatabase BUILDINGDETAIL table, C&I slice. Floor/section pricing rows within a building (use code, SF, SF rate, framing, sprinkler, unit config).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFBuildingDetail';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF/GIO statewide geodatabase IMPROVE table, C&I slice. One row per improvement -- carries grade, year/effective-year built, condition, ReplacementCost and physical/obsolescence depreciation (the cost-approach RCN inputs, OPP-22) plus the AV cap-tier split.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFImprovement';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF/GIO statewide geodatabase LAND table, C&I slice. One row per land segment (frontage/depth, base rate, acreage, SF, soil, influence factors, AV cap-tier split).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFLand';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The SourceDocument for the DLGF geodatabase pull this row came from (DocumentType StatewideParcelDataset).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFImprovement', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Replacement cost new for this improvement (before depreciation). A cost-approach input.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'DLGFImprovement', @level2type = N'COLUMN', @level2name = N'ReplacementCost';
GO
