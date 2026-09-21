/* ============================================================================
   Big Box Retail — Analysis Dashboard schema (StoreAssessment, StoreTax,
   Store extensions, vwStoreAnalysis)
   v5.56.x

   Adds the year-series assessment and tax history tables that back the
   dashboard's per-store trend view, plus the roster-quality columns (owner
   attribution, uniformity eligibility, dedup/primary-row flags) produced by
   the Big Box Retail research project's county-record parsing pipeline
   (Big_Box_Retail/states/indiana/scripts/). Populated by Task 4 from
   Big_Box_Retail/states/indiana/data/county-records/parsed/
   store-assessment-years.csv and store-tax-years.csv.

   Deliberately isolated from indiana_tax -- no foreign keys either
   direction. Foreign keys within big_box_retail (StoreAssessment/StoreTax
   -> Store) are expected.

   CodeGen convention (per migrations/CLAUDE.md):
     * NO __mj_CreatedAt / __mj_UpdatedAt columns -- CodeGen adds + triggers them.
     * NO foreign key indexes -- CodeGen creates IDX_AUTO_MJ_FKEY_* automatically.
     * sp_addextendedproperty for every non-PK, non-FK column.
     * vwStoreAnalysis is hand-written here (not CodeGen's default per-table
       view) because it pivots two child tables into one wide per-store row;
       CodeGen registers it as an entity on top of the DDL below.
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- Store extensions: roster-quality / attribution columns
-- ----------------------------------------------------------------------------

ALTER TABLE big_box_retail.Store ADD
    Acres               DECIMAL(10,2)  NULL,
    YearBuilt           INT            NULL,
    EffectiveYear       INT            NULL,
    OwnerNameAssessed   NVARCHAR(200)  NULL,
    TaxpayerName        NVARCHAR(200)  NULL,
    AttributionTier     NVARCHAR(20)   NULL,
    UniformityEligible  BIT            NULL,
    EconomicUnitReview  BIT            NULL,
    SiblingVacantAcres  DECIMAL(10,2)  NULL,
    OccupancySignal     NVARCHAR(30)   NULL,
    IsPrimaryRow        BIT            NULL,
    DuplicateOf         NVARCHAR(200)  NULL;
GO

-- ----------------------------------------------------------------------------
-- StoreAssessment: one row per store per assessment year
-- ----------------------------------------------------------------------------

CREATE TABLE big_box_retail.StoreAssessment (
    ID              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StoreID         UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear  INT              NOT NULL,
    LandAV          MONEY            NULL,
    ImprovementAV   MONEY            NULL,
    TotalAV         MONEY            NULL,
    Source          NVARCHAR(100)    NULL,
    ParcelsCovered  INT              NULL,
    ParcelsTotal    INT              NULL,
    IsComplete      BIT              NOT NULL DEFAULT 0,
    CONSTRAINT PK_StoreAssessment PRIMARY KEY (ID),
    CONSTRAINT FK_StoreAssessment_Store FOREIGN KEY (StoreID)
        REFERENCES big_box_retail.Store(ID),
    CONSTRAINT UQ_StoreAssessment_Store_Year UNIQUE (StoreID, AssessmentYear)
);
GO

-- ----------------------------------------------------------------------------
-- StoreTax: one row per store per pay year
-- ----------------------------------------------------------------------------

CREATE TABLE big_box_retail.StoreTax (
    ID                 UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StoreID            UNIQUEIDENTIFIER NOT NULL,
    PayYear            INT              NOT NULL,
    AssessmentYear     INT              NULL,
    SpringInstallment  MONEY            NULL,
    FallInstallment    MONEY            NULL,
    AnnualTax          MONEY            NULL,
    TaxRate            DECIMAL(12,7)    NULL,
    GrossTaxDue        MONEY            NULL,
    NetAV              MONEY            NULL,
    Source             NVARCHAR(100)    NULL,
    ParcelsCovered     INT              NULL,
    ParcelsTotal       INT              NULL,
    IsComplete         BIT              NOT NULL DEFAULT 0,
    CONSTRAINT PK_StoreTax PRIMARY KEY (ID),
    CONSTRAINT FK_StoreTax_Store FOREIGN KEY (StoreID)
        REFERENCES big_box_retail.Store(ID),
    CONSTRAINT UQ_StoreTax_Store_PayYear UNIQUE (StoreID, PayYear)
);
GO

-- ----------------------------------------------------------------------------
-- vwStoreAnalysis: one wide row per primary Store, pivoting StoreAssessment
-- (AV 2021-2026) and StoreTax (Tax 2022-2026) with per-year AVPerSF/TaxPerSF
-- ratios and AVSource/TaxSource provenance columns.
--
-- Ratios divide only when the year is complete (IsComplete = 1) AND square
-- footage is positive, so a partial-year sum never produces a published
-- ratio. Filtered to IsPrimaryRow = 1 (populated by Task 4) so duplicate/
-- non-primary parcel rows from the roster don't double-count a store.
-- ----------------------------------------------------------------------------

CREATE VIEW big_box_retail.vwStoreAnalysis AS
WITH av AS (
    SELECT StoreID, AssessmentYear, TotalAV, IsComplete, Source
    FROM big_box_retail.StoreAssessment
), tx AS (
    SELECT StoreID, PayYear, AnnualTax, IsComplete, Source
    FROM big_box_retail.StoreTax
)
SELECT
    s.ID, s.Brand AS Occupant, s.OwnerNameAssessed AS AssessedOwner,
    s.TaxpayerName AS TaxpayerOfRecord, s.County, s.City, s.Address,
    s.Acres, s.YearBuilt AS Built, s.TotalBuildingSqFt AS SquareFeet,
    s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
    s.OccupancySignal,
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN av.TotalAV END) AS AV2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN av.TotalAV END) AS AV2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN av.TotalAV END) AS AV2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN av.TotalAV END) AS AV2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN av.TotalAV END) AS AV2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN av.TotalAV END) AS AV2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN tx.AnnualTax END) AS Tax2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN tx.AnnualTax END) AS Tax2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN tx.AnnualTax END) AS Tax2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN tx.AnnualTax END) AS Tax2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN tx.AnnualTax END) AS Tax2026,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2021 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2021,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2022 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2022,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2023 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2023,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2024 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2024,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2025 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2025,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN av.AssessmentYear = 2026 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2026,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN tx.PayYear = 2022 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2022,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN tx.PayYear = 2023 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2023,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN tx.PayYear = 2024 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2024,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN tx.PayYear = 2025 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2025,
    CASE WHEN s.TotalBuildingSqFt > 0 THEN
        MAX(CASE WHEN tx.PayYear = 2026 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2026,
    -- Provenance per year. 2021-2022 AV comes from TAXDATA's *billing* AV rather than
    -- a PRC -- a related but not identical measure -- so a cross-year comparison has to
    -- be readable as such. Default-hidden in the grid; available in the column chooser.
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN av.Source END) AS AVSource2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN av.Source END) AS AVSource2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN av.Source END) AS AVSource2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN av.Source END) AS AVSource2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN av.Source END) AS AVSource2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN av.Source END) AS AVSource2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN tx.Source END) AS TaxSource2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN tx.Source END) AS TaxSource2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN tx.Source END) AS TaxSource2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN tx.Source END) AS TaxSource2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN tx.Source END) AS TaxSource2026
FROM big_box_retail.Store s
LEFT JOIN av ON av.StoreID = s.ID
LEFT JOIN tx ON tx.StoreID = s.ID
WHERE s.IsPrimaryRow = 1
GROUP BY s.ID, s.Brand, s.OwnerNameAssessed, s.TaxpayerName, s.County, s.City,
         s.Address, s.Acres, s.YearBuilt, s.TotalBuildingSqFt, s.AttributionTier,
         s.UniformityEligible, s.EconomicUnitReview, s.OccupancySignal;
GO

-- ----------------------------------------------------------------------------
-- Extended properties: Store extensions
-- ----------------------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deeded acreage for the store site, first available of PRC, county API, treasurer record, DLGF crosswalk.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'Acres';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Year the primary improvement was originally constructed, per county assessment record.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'YearBuilt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Effective year used by the assessor for depreciation/condition purposes, distinct from actual YearBuilt when the improvement has been substantially renovated.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'EffectiveYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the party the county assessment record shows as owner, which may differ from TaxpayerName (e.g. a captive real estate subsidiary vs. the operating retailer).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'OwnerNameAssessed';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name the tax bill/treasurer record lists as the taxpayer of record for this parcel.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'TaxpayerName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Confidence tier of the owner/taxpayer attribution for this store, assigned by the county-record parsing pipeline (e.g. confirmed, probable, unconfirmed).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'AttributionTier';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'True when this store has a sufficient comparable pool to support a uniformity/equity appeal analysis, per the pipeline''s eligibility screen.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'UniformityEligible';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'True when this store''s parcel(s) require manual economic-unit review (e.g. shared parking, cross-easements, or split-parcel improvements) before its assessment figures can be trusted standalone.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'EconomicUnitReview';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Acreage of any vacant sibling parcel(s) associated with this store site (e.g. an outparcel or excess land parcel under common ownership), tracked separately from the store''s own Acres.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'SiblingVacantAcres';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Signal of whether the site currently appears occupied/operating vs. vacant/dark, derived by the parsing pipeline from available county and locator signals (e.g. occupied, dark, unknown).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'OccupancySignal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'True when this row is the primary, de-duplicated row for its store; false/null for rows superseded by a better-attributed duplicate. vwStoreAnalysis filters to IsPrimaryRow = 1 so a store with multiple roster rows (e.g. from re-runs of the matching pipeline) is not double-counted.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'IsPrimaryRow';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifies the primary Store row this row duplicates, when IsPrimaryRow is false (e.g. by that row''s ID or a stable natural key), for traceability of the dedup decision.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'DuplicateOf';
GO

-- ----------------------------------------------------------------------------
-- Extended properties: StoreAssessment
-- ----------------------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per Store per assessment year (2021-2026), holding that year''s land/improvement/total assessed value as parsed from county PRC or billing records. Populated by Task 4 from Big_Box_Retail/states/indiana/data/county-records/parsed/store-assessment-years.csv.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment year this row''s AV figures apply to.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed value of the land component for this assessment year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'LandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed value of the improvement component for this assessment year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'ImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value (land + improvement) for this assessment year, as reported by Source. Not guaranteed to equal LandAV + ImprovementAV when the source only publishes a total.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'TotalAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which upstream record type this year''s figures were parsed from (e.g. a PRC, a county assessor API, or -- for 2021-2022 -- TAXDATA''s billing AV, a related but not identical measure to a PRC-derived assessed value).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'Source';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of this store''s parcels for which this year''s AV was actually found/parsed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'ParcelsCovered';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total number of parcels belonging to this store, for comparison against ParcelsCovered.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'ParcelsTotal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'True when ParcelsCovered = ParcelsTotal for this year -- i.e. every one of the store''s parcels has a value for this year, so a per-year total or ratio built from it is not silently understated by a missing parcel. vwStoreAnalysis gates every AVPerSF ratio on this flag.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreAssessment',
    @level2type = N'COLUMN', @level2name = N'IsComplete';
GO

-- ----------------------------------------------------------------------------
-- Extended properties: StoreTax
-- ----------------------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per Store per pay year (2022-2026), holding that year''s installment, total tax, and rate figures as parsed from county treasurer/TAXDATA records. Populated by Task 4 from Big_Box_Retail/states/indiana/data/county-records/parsed/store-tax-years.csv.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The calendar year in which this row''s tax installments are billed/paid (Indiana taxes are billed in arrears -- PayYear N bills AssessmentYear N-1''s value).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'PayYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment year this tax bill is based on, when known from the source record.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Spring installment amount billed for this pay year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'SpringInstallment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Fall installment amount billed for this pay year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'FallInstallment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total tax billed for this pay year (typically SpringInstallment + FallInstallment, as reported by Source).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'AnnualTax';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Effective tax rate applied for this pay year, as reported by Source (dollars of tax per $100 of net assessed value, or the source''s equivalent).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'TaxRate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Gross tax due for this pay year before credits/deductions, as reported by Source.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'GrossTaxDue';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Net assessed value (after exemptions/deductions) used to compute this pay year''s tax bill, as reported by Source.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'NetAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which upstream record type this pay year''s figures were parsed from (e.g. county treasurer record or TAXDATA billing extract).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'Source';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of this store''s parcels for which this pay year''s tax was actually found/parsed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'ParcelsCovered';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total number of parcels belonging to this store, for comparison against ParcelsCovered.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'ParcelsTotal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'True when ParcelsCovered = ParcelsTotal for this pay year -- i.e. every one of the store''s parcels has a value for this year, so a per-year total or ratio built from it is not silently understated by a missing parcel. vwStoreAnalysis gates every TaxPerSF ratio on this flag.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'StoreTax',
    @level2type = N'COLUMN', @level2name = N'IsComplete';
GO
