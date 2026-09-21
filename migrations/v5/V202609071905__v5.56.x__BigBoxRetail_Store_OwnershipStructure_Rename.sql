-- =============================================================================
-- Big Box Retail — rename Store.OccupancySignal -> Store.OwnershipStructure
-- v5.56.x
--
-- V202609071500__v5.56.x__BigBoxRetail_Analysis_Dashboard.sql (applied, not
-- edited here) added Store.OccupancySignal with an MS_Description promising
-- "whether the site currently appears occupied/operating vs. vacant/dark ...
-- (e.g. occupied, dark, unknown)". The column never carried that. Its actual
-- source (parcel-facts-consolidated.csv's occupancy_signal, computed by
-- reconcile-parcel-facts.py by comparing the assessed owner name against the
-- store's brand) is an OWNERSHIP-STRUCTURE heuristic: 'likely owner-occupied'
-- (237 stores) / 'likely leased/investor' (151) / 'mixed' (1, where a
-- multi-parcel store's parcels disagree). There is no vacancy/dark-store data
-- anywhere in this pipeline.
--
-- This is not a documentation-only fix. This dashboard is for an Indiana
-- property-tax attorney, and "dark store" is a term of art naming the
-- central valuation argument in big-box assessment appeals -- a grid column
-- headed OccupancySignal will be read as a dark-store flag at a glance, and
-- a correct description underneath does not undo a misleading header. So the
-- column itself is renamed, not just re-described.
--
-- sp_rename does not change the column's object_id/column_id, so the
-- existing MS_Description extended property automatically follows the
-- rename -- it's dropped and re-added here only to correct its *text*,
-- per migrations/CLAUDE.md's "modifying existing fields" pattern.
--
-- vwStoreAnalysis (hand-written, same rationale as its own migrations) is
-- updated in the same file via CREATE OR ALTER VIEW to expose the column
-- under its new name. No other part of the view changes.
-- =============================================================================

EXEC sp_rename 'big_box_retail.Store.OccupancySignal', 'OwnershipStructure', 'COLUMN';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.Store')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('big_box_retail.Store')
                          AND name = 'OwnershipStructure')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'TABLE',  @level1name = N'Store',
        @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
END
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Heuristic inference of whether this store appears owner-occupied or leased/investor-held, derived by comparing the county''s assessed owner name against the store''s brand name (''likely owner-occupied'' / ''likely leased/investor''), or ''mixed'' when a multi-parcel store''s parcels disagree. This is an ownership-structure heuristic only -- it is NOT an occupancy or dark-store (vacant/operating) indicator, and no vacancy data feeds it.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'Store',
    @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
GO

-- ----------------------------------------------------------------------------
-- vwStoreAnalysis: expose the renamed column. Nothing else in the view
-- changes from V202609071850 (which added the UniformityEligible gate).
-- ----------------------------------------------------------------------------

CREATE OR ALTER VIEW big_box_retail.vwStoreAnalysis AS
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
    -- Every ratio below is gated on s.UniformityEligible = 1 (added in
    -- V202609071850) so a shared/review-tier store never publishes a
    -- per-brand AV-or-tax-per-square-foot figure that cannot be honestly
    -- attributed to it.
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2021 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2021,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2022 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2022,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2023 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2023,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2024 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2024,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2025 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2025,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2026 AND av.IsComplete = 1
                 THEN av.TotalAV END) / s.TotalBuildingSqFt END AS AVPerSF2026,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2022 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2022,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2023 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2023,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2024 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2024,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2025 AND tx.IsComplete = 1
                 THEN tx.AnnualTax END) / s.TotalBuildingSqFt END AS TaxPerSF2025,
    CASE WHEN s.TotalBuildingSqFt > 0 AND s.UniformityEligible = 1 THEN
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
         s.UniformityEligible, s.EconomicUnitReview, s.OwnershipStructure;
GO
