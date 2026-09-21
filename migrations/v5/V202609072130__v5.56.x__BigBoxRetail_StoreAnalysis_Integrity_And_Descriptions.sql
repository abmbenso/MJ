-- =============================================================================
-- Big Box Retail — Store Analysis: attributed square footage, zero-AV ratio
-- gate, completeness exposure, and column documentation
-- v5.56.x
--
-- Forward-only. Neither V202609071500 (tables + first view) nor V202609071850
-- (uniformity gate) nor V202609071905 (OwnershipStructure rename) is edited --
-- Flyway checksums applied migrations. The view is replaced wholesale with
-- CREATE OR ALTER VIEW, same pattern as its two predecessors.
--
-- Four changes, from the final whole-branch review:
--
-- 1. Store.AttributedBuildingSqFt (new). build-store-facts.py resolves a
--    multi-parcel store down to the parcels the brand actually owns (or its
--    unshared parcels) before computing AV and building area -- that mechanism
--    exists because a Target at a dead mall was being valued on Washington
--    Square Mall's parcels. Store.TotalBuildingSqFt, however, comes from the
--    ROSTER and is the un-narrowed figure, so the view was dividing the
--    attribution-resolved AV by the un-resolved area. Target, 10202 East
--    Washington Street, Indianapolis published $17.69/sf -- a dead-mall blend --
--    instead of $50.44/sf. This column carries the resolved area for the 9
--    stores whose parcel set was narrowed, and is NULL for every other store,
--    so SquareFeet is unchanged for the other 380.
--
-- 2. Every ratio now requires a POSITIVE numerator. The old gate checked
--    TotalBuildingSqFt > 0 but never the assessed value, so a $0 assessed value
--    published as a $0.00/sf uniformity-eligible ratio -- 40 of 389 stores did
--    exactly that for AV2023. The upstream cause (a blank PRC year parsed as
--    0.0 and outranking a real DLGF value) is fixed in build-store-year-series.py;
--    this is the second, independent line of defence, so a zero can never
--    publish a ratio even if one reaches the table.
--
-- 3. Completeness is now visible. A store-year is complete only when every one
--    of the store's parcels reported it; the ratio was already suppressed for an
--    incomplete year, but the raw AV{year} / Tax{year} cell still showed the
--    partial sum, indistinguishable from a whole one. Anyone dividing AV by
--    SquareFeet in an exported sheet reproduced exactly the number the guard
--    exists to prevent. ParcelsTotal plus a per-year completeness flag make the
--    partial sums identifiable. Default-hidden in the grid.
--
-- 4. Column descriptions. sys.extended_properties on this view returned zero
--    rows: all 46 non-ID EntityField.Description values were blank. The earlier
--    migrations documented the TABLES only, and CodeGen reads a view-backed
--    entity's field descriptions from the VIEW's extended properties
--    (__mj.vwSQLColumnsAndEntityFields COALESCEs EP_View over EP_Table). Two
--    traps in particular needed saying out loud:
--      * Tax{N} is a PAY year, AV{N} is an ASSESSMENT year. They sit in adjacent
--        columns implying the same year and they do not describe the same year:
--        Tax2026 is the bill for assessment year 2025.
--      * AVSource2021/2022 is DLGF *billing* net assessed value, not a PRC
--        figure -- a related but not identical measure.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Store.AttributedBuildingSqFt
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('big_box_retail.Store')
                 AND name = 'AttributedBuildingSqFt')
BEGIN
    ALTER TABLE big_box_retail.Store ADD AttributedBuildingSqFt INT NULL;
END
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.Store')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.Store')
                               AND name = 'AttributedBuildingSqFt')
             AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'TABLE',  @level1name = N'Store',
        @level2type = N'COLUMN', @level2name = N'AttributedBuildingSqFt';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total building area, in square feet, of ONLY the parcels attribution resolved to this store -- populated for the stores whose roster parcel list was narrowed (e.g. a brand-owned box separated from the surrounding mall or a neighbouring tenant''s ground), and NULL for every store where the roster list already described the store. NULL means "use TotalBuildingSqFt". vwStoreAnalysis.SquareFeet is COALESCE(AttributedBuildingSqFt, TotalBuildingSqFt), so every per-square-foot ratio divides the attribution-resolved assessed value by the matching attribution-resolved area.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'AttributedBuildingSqFt';
GO

-- -----------------------------------------------------------------------------
-- 2. vwStoreAnalysis
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW big_box_retail.vwStoreAnalysis AS
WITH av AS (
    SELECT StoreID, AssessmentYear, TotalAV, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreAssessment
), tx AS (
    SELECT StoreID, PayYear, AnnualTax, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreTax
)
SELECT
    s.ID, s.Brand AS Occupant, s.OwnerNameAssessed AS AssessedOwner,
    s.TaxpayerName AS TaxpayerOfRecord, s.County, s.City, s.Address,
    s.Acres, s.YearBuilt AS Built,
    sf.SqFt AS SquareFeet,
    s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
    s.OwnershipStructure,
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
    -- Every ratio is gated three ways: s.UniformityEligible = 1 (added in
    -- V202609071850) so a shared/review-tier store never publishes a per-brand
    -- figure it cannot honestly claim; IsComplete = 1 so a partial sum of a
    -- multi-parcel store never becomes a ratio; and a strictly positive
    -- numerator and denominator, so neither a $0 assessed value nor a missing
    -- building area can produce a $0.00/sf "comparable".
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2021 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2021,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2022 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2022,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2023 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2023,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2024 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2024,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2025 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2025,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2026 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2026,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2022 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2022,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2023 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2023,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2024 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2024,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2025 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2025,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2026 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2026,
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
    MAX(CASE WHEN tx.PayYear = 2026 THEN tx.Source END) AS TaxSource2026,
    -- Square-footage provenance and completeness. Aggregates here are all MAX()
    -- deliberately: av and tx are joined independently, so the two produce a
    -- cartesian product per store and any SUM/COUNT/STRING_AGG would multiply.
    -- MAX over a per-year CASE is immune to that; every one of these is constant
    -- within its year, so MAX is the value itself.
    s.TotalBuildingSqFt AS RosterSquareFeet,
    s.AttributedBuildingSqFt AS AttributedSquareFeet,
    MAX(av.ParcelsTotal) AS ParcelsTotal,
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2026
FROM big_box_retail.Store s
CROSS APPLY (SELECT SqFt = COALESCE(s.AttributedBuildingSqFt, s.TotalBuildingSqFt)) sf
LEFT JOIN av ON av.StoreID = s.ID
LEFT JOIN tx ON tx.StoreID = s.ID
WHERE s.IsPrimaryRow = 1
GROUP BY s.ID, s.Brand, s.OwnerNameAssessed, s.TaxpayerName, s.County, s.City,
         s.Address, s.Acres, s.YearBuilt, s.TotalBuildingSqFt, s.AttributedBuildingSqFt,
         sf.SqFt, s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
         s.OwnershipStructure;
GO

-- -----------------------------------------------------------------------------
-- 3. Column documentation for vwStoreAnalysis
--
-- CodeGen resolves a view-backed entity's field descriptions from the VIEW's
-- extended properties (__mj.vwSQLColumnsAndEntityFields COALESCEs EP_View over
-- EP_Table), so these must be attached at @level1type = N'VIEW'. Each is dropped
-- first so this migration is safe to re-run against a partially-documented view.
-- Run `npx mj sync push` then `npx mj codegen` afterwards to land them on
-- EntityField.Description.
-- -----------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'ID')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'ID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store primary key (big_box_retail.Store.ID). One row per PRIMARY roster row: the view is filtered to Store.IsPrimaryRow = 1, so the 37 duplicate roster rows (the same store carried under a second address) are excluded and each store''s figures count exactly once.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Occupant')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Occupant';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Retail brand operating at this address (Store.Brand). Called Occupant rather than Owner because the operator and the assessed owner are frequently different parties -- see AssessedOwner and TaxpayerOfRecord.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Occupant';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AssessedOwner')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AssessedOwner';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Owner name as carried on the county''s assessment record for this store''s parcels (Store.OwnerNameAssessed), pipe-joined when a multi-parcel store''s parcels carry different owners. County assessment records lag conveyances, so this is the owner of record for assessment purposes, not necessarily the current titleholder.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AssessedOwner';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxpayerOfRecord')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxpayerOfRecord';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxpayer of record from the DLGF tax-bill extract for the most recent pay year available, joined across this store''s attribution-resolved parcels. This is the party the bill is actually sent to, and can differ from AssessedOwner (a net-leased tenant billed directly, for example).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxpayerOfRecord';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'County')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'County';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indiana county the store sits in. Determines the assessing and taxing jurisdiction, and which county source supplied the figures in this row.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'County';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'City')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'City';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City or town of the store''s situs address.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'City';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Address')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Address';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Situs street address of the store as carried on the roster. It is the roster address, not necessarily the address printed on the county''s tax bill for the same parcel.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Address';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Acres')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Acres';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total land area, in acres, across this store''s attribution-resolved parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Acres';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Built')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Built';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earliest year_built across this store''s parcels (Store.YearBuilt). For effective age -- the figure a cost-approach argument turns on -- see Store.EffectiveYear, which follows the largest building on the store''s parcels rather than the oldest structure on any of them.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Built';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'SquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'SquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area used as the denominator of EVERY per-square-foot ratio in this view: COALESCE(Store.AttributedBuildingSqFt, Store.TotalBuildingSqFt). For the stores whose roster parcel list was narrowed by attribution it is the area of the resolved parcels only; for every other store it is the roster figure. See RosterSquareFeet and AttributedSquareFeet for which one is in play.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'SquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AttributionTier')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AttributionTier';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How confidently this store''s assessed value can be attributed to this brand''s building. clean = one parcel, one brand. brand-parcel = several parcels, narrowed to the ground the brand owns or to its unshared parcels. summed = several parcels, one owner, none shared. review = several owners, none of them the brand -- the brand''s building cannot be isolated from a landlord''s outlot or a neighbour''s. shared = a parcel carries more than one roster brand, so one assessment covers several stores. Only clean, brand-parcel and summed are uniformity-eligible.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AttributionTier';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'UniformityEligible')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'UniformityEligible';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when this store''s assessed value and building area describe the same thing well enough to use the store as a uniformity comparable (AttributionTier in clean, brand-parcel, summed). Every per-square-foot ratio in this view is blank when this is 0: a shared-parcel anchor''s AV/SF cannot be honestly computed, so it is withheld rather than shown wrong.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'UniformityEligible';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'EconomicUnitReview')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'EconomicUnitReview';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when this store''s parcels look like part of a larger economic unit -- typically adjoining vacant acreage under common ownership that an assessor or an appeal may treat as one property. A flag for human review, not a conclusion.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'EconomicUnitReview';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'OwnershipStructure')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Heuristic inference of whether the store appears owner-occupied or leased/investor-held, from comparing the county''s assessed owner name against the brand name (''likely owner-occupied'' / ''likely leased/investor'', or ''mixed'' when a multi-parcel store''s parcels disagree). This is an ownership-structure heuristic only -- it is NOT an occupancy or dark-store (vacant/operating) indicator, and no vacancy data feeds it.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2021 (assessment date in 2021), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2021 is Tax2022, not Tax2021. Check AVComplete2021 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2022 (assessment date in 2022), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2022 is Tax2023, not Tax2022. Check AVComplete2022 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2023 (assessment date in 2023), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2023 is Tax2024, not Tax2023. Check AVComplete2023 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2024 (assessment date in 2024), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2024 is Tax2025, not Tax2024. Check AVComplete2024 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2025 (assessment date in 2025), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2025 is Tax2026, not Tax2025. Check AVComplete2025 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2026 (assessment date in 2026), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2026 is Tax2027, not Tax2026. Check AVComplete2026 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2022 -- which is the bill for ASSESSMENT year 2021 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2022 and AV2022 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2022. Check TaxComplete2022: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2023 -- which is the bill for ASSESSMENT year 2022 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2023 and AV2023 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2023. Check TaxComplete2023: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2024 -- which is the bill for ASSESSMENT year 2023 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2024 and AV2024 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2024. Check TaxComplete2024: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2025 -- which is the bill for ASSESSMENT year 2024 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2025 and AV2025 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2025. Check TaxComplete2025: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2026 -- which is the bill for ASSESSMENT year 2025 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2026 and AV2026 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2026. Check TaxComplete2026: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2021: AV2021 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2021 = 1, and both AV2021 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2022: AV2022 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2022 = 1, and both AV2022 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2023: AV2023 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2023 = 1, and both AV2023 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2024: AV2024 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2024 = 1, and both AV2024 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2025: AV2025 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2025 = 1, and both AV2025 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2026: AV2026 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2026 = 1, and both AV2026 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2022 (the bill for ASSESSMENT year 2021): Tax2022 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2022 = 1, and both Tax2022 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2022 and AVPerSF2022 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2023 (the bill for ASSESSMENT year 2022): Tax2023 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2023 = 1, and both Tax2023 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2023 and AVPerSF2023 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2024 (the bill for ASSESSMENT year 2023): Tax2024 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2024 = 1, and both Tax2024 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2024 and AVPerSF2024 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2025 (the bill for ASSESSMENT year 2024): Tax2025 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2025 = 1, and both Tax2025 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2025 and AVPerSF2025 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2026 (the bill for ASSESSMENT year 2025): Tax2026 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2026 = 1, and both Tax2026 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2026 and AVPerSF2026 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2021. For 2021 this is overwhelmingly dlgf_taxdata -- the DLGF tax bill''s BILLING net assessed value, NOT a county property record card figure. It is a related but not identical measure to the PRC-sourced 2023+ values, so a 2021-to-2025 trend crosses a source seam and should be read as such. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2022. For 2022 this is overwhelmingly dlgf_taxdata -- the DLGF tax bill''s BILLING net assessed value, NOT a county property record card figure. It is a related but not identical measure to the PRC-sourced 2023+ values, so a 2021-to-2025 trend crosses a source seam and should be read as such. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2023: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2024: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2025: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2026: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2022: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2023: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2024: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2025: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2026: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'RosterSquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'RosterSquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area from the roster across ALL parcels originally mapped to this address, including any that attribution later excluded. Provenance only -- never used in a ratio. Where this differs from SquareFeet, AttributedSquareFeet is why.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'RosterSquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AttributedSquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AttributedSquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area of ONLY the attribution-resolved parcels. Populated for the stores whose parcel list was narrowed (a brand-owned box separated from the surrounding mall, say) and NULL for every store where the roster list already described the store. When non-NULL this is what SquareFeet uses.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AttributedSquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'ParcelsTotal')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'ParcelsTotal';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of parcels making up this store after attribution resolution -- the denominator behind the AVComplete/TaxComplete flags. A store-year is complete only when all ParcelsTotal parcels reported a figure for that year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'ParcelsTotal';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2021; 0 when only some did. AV2021 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2021 is suppressed whenever this is 0. NULL means the store has no 2021 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2022; 0 when only some did. AV2022 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2022 is suppressed whenever this is 0. NULL means the store has no 2022 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2023; 0 when only some did. AV2023 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2023 is suppressed whenever this is 0. NULL means the store has no 2023 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2024; 0 when only some did. AV2024 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2024 is suppressed whenever this is 0. NULL means the store has no 2024 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2025; 0 when only some did. AV2025 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2025 is suppressed whenever this is 0. NULL means the store has no 2025 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2026; 0 when only some did. AV2026 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2026 is suppressed whenever this is 0. NULL means the store has no 2026 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2022; 0 when only some did. Tax2022 still shows the PARTIAL sum when this is 0, and TaxPerSF2022 is suppressed. NULL means the store has no 2022 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2023; 0 when only some did. Tax2023 still shows the PARTIAL sum when this is 0, and TaxPerSF2023 is suppressed. NULL means the store has no 2023 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2024; 0 when only some did. Tax2024 still shows the PARTIAL sum when this is 0, and TaxPerSF2024 is suppressed. NULL means the store has no 2024 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2025; 0 when only some did. Tax2025 still shows the PARTIAL sum when this is 0, and TaxPerSF2025 is suppressed. NULL means the store has no 2025 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2026; 0 when only some did. Tax2026 still shows the PARTIAL sum when this is 0, and TaxPerSF2026 is suppressed. NULL means the store has no 2026 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2026';
GO
