-- =============================================================================
-- Big Box Retail — vwStoreAnalysis: gate AV/SF and Tax/SF ratios on
-- UniformityEligible
-- v5.56.x
--
-- Fix for a gap in V202609071500__v5.56.x__BigBoxRetail_Analysis_Dashboard.sql
-- (this file's own predecessor): every AVPerSF*/TaxPerSF* column there was
-- gated only on TotalBuildingSqFt > 0 AND IsComplete = 1, never on
-- attribution quality. A parcel shared by several brands (AttributionTier =
-- 'shared') or one whose parcels could not be attributed to the brand at all
-- (AttributionTier = 'review') would still publish a per-brand ratio whenever
-- its assessment/tax data happened to be complete -- e.g. Home Depot/Kohl's/
-- Target at 4850 East Southport Road, Indianapolis all computing the
-- identical $61.40/sqft from one shared parcel's assessment. Verified before
-- this migration: 16 of 29 'shared' rows and 2 of 4 'review' rows were
-- publishing a 2026 ratio.
--
-- Gate on s.UniformityEligible = 1 rather than enumerating tiers --
-- UniformityEligible already exists on Store, is already populated by Task 4
-- as tier in ('clean', 'brand-parcel', 'summed'), and is the spec's own
-- concept for exactly this eligibility question, so the gate stays correct
-- if a tier is ever added or reclassified.
--
-- CREATE OR ALTER VIEW so this is re-runnable and does not require dropping
-- the CodeGen-registered virtual entity ("Store Analysis") first. Every
-- other part of the view (columns, joins, WHERE, GROUP BY, the non-ratio
-- AV/Tax/Source columns) is unchanged from V202609071500 -- only the 11
-- ratio CASE expressions (AVPerSF2021-2026, TaxPerSF2022-2026) gained the
-- added condition.
-- =============================================================================

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
    -- Every ratio below is additionally gated on s.UniformityEligible = 1 (new in
    -- this migration) so a shared/review-tier store never publishes a per-brand
    -- AV-or-tax-per-square-foot figure that cannot be honestly attributed to it.
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
         s.UniformityEligible, s.EconomicUnitReview, s.OccupancySignal;
GO
