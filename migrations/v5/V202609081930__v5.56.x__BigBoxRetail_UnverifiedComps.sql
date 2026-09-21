/* ============================================================================
   Big Box Retail — surface unverified comparables on the analysis view
   v5.56.x

   Hamilton publishes neither a deed code nor a transfer type, so 25 of its 28
   priced transfers can be graded only on the $/SF band. They are real evidence
   without instrument confirmation, and V202609081900 gave them their own
   CompQuality of 'unverified'. Counting them here keeps Hamilton stores from
   reading as having no comparable evidence at all, while leaving
   UsableCompCount and LowestCompPSF strictly to instrument-confirmed sales so
   neither column quietly changes meaning.

   ⚠️ ALTER VIEW DROPS A VIEW'S COLUMN EXTENDED PROPERTIES, and CodeGen resolves
   a view-backed entity's field descriptions from them. Rather than restate all
   71 blocks a third time (and risk them drifting from the previous migration),
   this captures what is attached, alters the view, and re-applies. Descriptions
   for columns that still exist survive verbatim; the new column is documented
   explicitly afterwards.
   ============================================================================ */

-- 1. Capture the current descriptions.
SELECT c.name AS ColumnName, CAST(ep.value AS NVARCHAR(4000)) AS Descr
INTO #vwStoreAnalysis_EP
FROM sys.extended_properties ep
JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
WHERE ep.major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
  AND ep.name = 'MS_Description';
GO

-- 2. Recreate the view.
CREATE OR ALTER VIEW big_box_retail.vwStoreAnalysis AS
WITH av AS (
    SELECT StoreID, AssessmentYear, TotalAV, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreAssessment
), tx AS (
    SELECT StoreID, PayYear, AnnualTax, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreTax
), bs AS (
    -- Burden-shift rollup. Only the actionable, usable band: bands d-f are unverified
    -- or miscoded construction, and a parcel-year already reduced to at or below the
    -- prior year has no live increase left to argue.
    SELECT StoreID,
           COUNT(*)            AS ShiftYears,
           MAX(AssessmentYear) AS LatestShiftYear,
           SUM(AVIncrease)     AS ShiftAVAtStake,
           MAX(CASE WHEN Posture = N'revert-then-argue' THEN 1 ELSE 0 END) AS AnyArgue
    FROM big_box_retail.ParcelBurdenShift
    WHERE Usability = N'usable' AND Actionable = 1 AND StoreID IS NOT NULL
    GROUP BY StoreID
), st AS (
    SELECT StoreID,
           COUNT(*)          AS SettlementCount,
           MAX(SettlementAV) AS HighestSettlementAV,
           MIN(AgreedPSF)    AS LowestAgreedPSF
    FROM big_box_retail.ParcelSettlement
    WHERE StoreID IS NOT NULL
    GROUP BY StoreID
), cp AS (
    -- Comparable sales only. CompQuality = 'review' means the deed is not a market
    -- instrument or the $/SF falls outside the plausible band, so it must not feed a
    -- headline comp figure -- the row is still readable in ParcelTransfer.
    SELECT StoreID,
           COUNT(CASE WHEN CompQuality = N'usable' THEN 1 END)     AS UsableCompCount,
           COUNT(CASE WHEN CompQuality = N'unverified' THEN 1 END) AS UnverifiedCompCount,
           MIN(CASE WHEN CompQuality = N'usable' THEN SalePSF END) AS LowestCompPSF,
           MAX(SaleDate)                                          AS LatestCompDate
    FROM big_box_retail.ParcelTransfer
    WHERE CompQuality IN (N'usable', N'unverified')
      AND SalePSF IS NOT NULL AND StoreID IS NOT NULL
    GROUP BY StoreID
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
    MAX(CASE WHEN tx.PayYear = 2026 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2026,
    -- Appeal evidence, rolled up from the parcel-level tables. Aggregates are wrapped
    -- so the GROUP BY above is unaffected.
    MAX(bs.ShiftYears)          AS BurdenShiftYears,
    MAX(bs.LatestShiftYear)     AS LatestBurdenShiftYear,
    MAX(bs.ShiftAVAtStake)      AS BurdenShiftAVAtStake,
    CASE WHEN MAX(bs.AnyArgue) = 1  THEN N'revert-then-argue'
         WHEN MAX(bs.ShiftYears) > 0 THEN N'revert-and-done' END AS BurdenShiftPosture,
    MAX(st.SettlementCount)     AS SettlementCount,
    MAX(st.HighestSettlementAV) AS HighestSettlementAV,
    MIN(st.LowestAgreedPSF)     AS LowestAgreedPSF,
    MAX(cp.UsableCompCount)      AS UsableCompCount,
    MAX(cp.UnverifiedCompCount)  AS UnverifiedCompCount,
    MIN(cp.LowestCompPSF)       AS LowestCompPSF,
    MAX(cp.LatestCompDate)      AS LatestCompDate
FROM big_box_retail.Store s
CROSS APPLY (SELECT SqFt = COALESCE(s.AttributedBuildingSqFt, s.TotalBuildingSqFt)) sf
LEFT JOIN av ON av.StoreID = s.ID
LEFT JOIN tx ON tx.StoreID = s.ID
LEFT JOIN bs ON bs.StoreID = s.ID
LEFT JOIN st ON st.StoreID = s.ID
LEFT JOIN cp ON cp.StoreID = s.ID
WHERE s.IsPrimaryRow = 1
GROUP BY s.ID, s.Brand, s.OwnerNameAssessed, s.TaxpayerName, s.County, s.City,
         s.Address, s.Acres, s.YearBuilt, s.TotalBuildingSqFt, s.AttributedBuildingSqFt,
         sf.SqFt, s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
         s.OwnershipStructure;
GO
-- 3. Re-apply every captured description that still names a live column.
-- sql_variant (sp_addextendedpropertys @value type) tops out at 8000 bytes, so the
-- variable must be NVARCHAR(4000), not NVARCHAR(MAX) -- the latter clashes outright.
DECLARE @col SYSNAME, @val NVARCHAR(4000);
DECLARE ep_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT e.ColumnName, e.Descr
    FROM #vwStoreAnalysis_EP e
    WHERE EXISTS (SELECT 1 FROM sys.columns c
                  WHERE c.object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                    AND c.name = e.ColumnName);
OPEN ep_cur;
FETCH NEXT FROM ep_cur INTO @col, @val;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.extended_properties ep
               JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
               WHERE ep.major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                 AND ep.name = 'MS_Description' AND c.name = @col)
        EXEC sp_dropextendedproperty @name = N'MS_Description',
            @level0type = N'SCHEMA', @level0name = N'big_box_retail',
            @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
            @level2type = N'COLUMN', @level2name = @col;

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = @val,
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = @col;

    FETCH NEXT FROM ep_cur INTO @col, @val;
END
CLOSE ep_cur;
DEALLOCATE ep_cur;
DROP TABLE #vwStoreAnalysis_EP;
GO

-- 4. Document the new column.
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Recorded sales on this store''s parcels whose price per square foot falls inside the plausible band but whose instrument the county does not publish -- Hamilton prints neither a deed code nor a transfer type. Real evidence without deed confirmation: worth reading before citing, and deliberately not counted in UsableCompCount or LowestCompPSF.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'UnverifiedCompCount';
GO
