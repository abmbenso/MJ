/* ============================================================================
   Big Box Retail — rename the Built column to YearBuilt on both views
   v5.56.x

   docs/NUMBER_FORMATTING.md in the Indiana_Tax_Expert project is the standard
   for how a numeric column renders in MJ Explorer, and it is explicit:

     "A calendar year -> name must contain `Year` (`YearBuilt`, not
      `ConstructionYr`)."

   MJ Explorer infers display intent from SQL type family plus field NAME —
   there is no per-field currency/percent/year metadata. The year branch keys on
   /year/i. Both views aliased Store.YearBuilt down to `Built`, which does not
   match, so a construction year fell through to the whole-number default and
   rendered comma-grouped (1,995) instead of as a plain year (1995). The alias
   was the bug; the underlying column was always named correctly.

   The rename also restores the intent of the standard's own worked example —
   `YearBuilt` rendering as `1,995` is the exact bug that document was written
   after, in August 2026. It came back through an alias.

   Both view definitions are taken verbatim from sys.sql_modules and changed in
   the single aliasing spot, so nothing else can drift.
   ============================================================================ */

-- Capture the existing column descriptions before ALTER VIEW drops them.
SELECT v.name AS ViewName, c.name AS ColumnName, CAST(ep.value AS NVARCHAR(4000)) AS Descr
INTO #ep_backup
FROM sys.extended_properties ep
JOIN sys.views v ON v.object_id = ep.major_id
JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
WHERE ep.name = 'MS_Description'
  AND v.object_id IN (OBJECT_ID('big_box_retail.vwStoreAnalysis'),
                      OBJECT_ID('big_box_retail.vwStoreYear'));
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
    s.Acres, s.YearBuilt AS YearBuilt,
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

/* ============================================================================
   Big Box Retail — vwStoreYear, the long counterpart to vwStoreAnalysis
   v5.56.x

   vwStoreAnalysis is wide: 72 columns, of which 44 are year-suffixed (AV, Tax,
   AVPerSF, TaxPerSF and their source/completeness flags, once per year). That
   shape is right for one job — reading a store's whole trend on a single line,
   which was the dashboard's original requirement — and wrong for almost
   everything else:

     * Every new assessment year costs 8 more columns, a migration, a CodeGen
       run, a re-emission of all 72 column descriptions and an edit to two
       DefaultInView allowlists. Here a new year is simply new rows.
     * Evidence that is an EVENT rather than an annual measure does not fit at
       all. A sale happens on a date and a PTABOA settlement exists only in
       years that had an appeal; as SalePrice2021..2027 they would be ~95% NULL.
     * Year cannot be used as a filter when it is spelled into column names.

   So this is an addition, not a replacement. vwStoreAnalysis keeps the
   trend-on-one-line job; vwStoreYear is the per-year working surface, one row
   per store per assessment year, and Year is an ordinary filterable column.

   The year axis is derived from StoreAssessment itself rather than hard-coded,
   which is the point: load a 2027 roll and the view grows without any DDL.

   ## Grain, and what is aggregated to reach it

   One row per (Store, AssessmentYear). A store can hold several parcels, so
   parcel-level children are aggregated: burden-shift figures are summed or
   maxed across the store's parcels for that year, and sales are counted with
   their highest price and lowest $/SF. The per-parcel detail stays readable in
   Parcel Burden Shifts and Parcel Transfers.

   ## ⚠️ Two honest limits, stated in the column descriptions as well

   1. **PTABOA settlements are NOT joined by year, because they are not
      reliably year-stamped.** The card notes they were read from often carry
      only the note's own date stamp, and frequently state several years at
      once ("(21-22) total av= $5,841,300; (22-23) ... (23-24) ... (24-25)").
      Picking one with a regex is precisely the error this project has made
      before. SettlementCount/HighestSettlementAV are therefore STORE-level
      figures repeated on every year row, not that year's settlement.
   2. **Sales shown against a year are sales that OCCURRED in it, not the only
      comparables usable for it.** Indiana imposes no statutory limit on
      comparable-sale recency; remoteness is handled by adjusting, never by
      excluding. Filtering to one year is a way to see activity, not a comp
      screen.
   ============================================================================ */

CREATE OR ALTER VIEW big_box_retail.vwStoreYear AS
WITH yrs AS (
    -- The year axis, taken from the data so a new roll needs no schema change.
    SELECT DISTINCT AssessmentYear FROM big_box_retail.StoreAssessment
), grid AS (
    SELECT s.ID AS StoreID, y.AssessmentYear
    FROM big_box_retail.Store s
    CROSS JOIN yrs y
    WHERE s.IsPrimaryRow = 1
), bs AS (
    SELECT StoreID, AssessmentYear,
           COUNT(*)                                          AS BurdenShiftParcels,
           SUM(AVIncrease)                                   AS BurdenShiftAVIncrease,
           MAX(PctIncrease)                                  AS BurdenShiftPctIncrease,
           MIN(PriorAVPSF)                                   AS BurdenShiftPriorAVPSF,
           MAX(CASE WHEN Posture = N'revert-then-argue' THEN 1 ELSE 0 END) AS AnyArgue
    FROM big_box_retail.ParcelBurdenShift
    WHERE Usability = N'usable' AND Actionable = 1 AND StoreID IS NOT NULL
    GROUP BY StoreID, AssessmentYear
), sales AS (
    SELECT StoreID, YEAR(SaleDate) AS SaleYear,
           COUNT(*)     AS SalesInYear,
           MAX(SalePrice) AS HighestSalePrice,
           MIN(CASE WHEN CompQuality IN (N'usable', N'unverified') THEN SalePSF END) AS LowestSalePSF,
           MAX(SaleDate) AS LatestSaleDate
    FROM big_box_retail.ParcelTransfer
    WHERE SaleDate IS NOT NULL AND SalePrice IS NOT NULL AND StoreID IS NOT NULL
    GROUP BY StoreID, YEAR(SaleDate)
), settle AS (
    -- Store-level, NOT year-level. See limit 1 in the header.
    SELECT StoreID, COUNT(*) AS SettlementCount, MAX(SettlementAV) AS HighestSettlementAV,
           MIN(AgreedPSF) AS LowestAgreedPSF
    FROM big_box_retail.ParcelSettlement WHERE StoreID IS NOT NULL GROUP BY StoreID
)
SELECT
    g.StoreID, g.AssessmentYear,
    s.Brand AS Occupant, s.County, s.City, s.Address,
    s.OwnerNameAssessed AS AssessedOwner, s.TaxpayerName AS TaxpayerOfRecord,
    sf.SqFt AS SquareFeet, s.YearBuilt AS YearBuilt, s.Acres,
    s.AttributionTier, s.UniformityEligible, s.OwnershipStructure,

    av.LandAV, av.ImprovementAV, av.TotalAV,
    av.Source AS AVSource, CAST(av.IsComplete AS INT) AS AVComplete,
    -- Same uniformity gate as vwStoreAnalysis: a shared or review-tier store must never
    -- publish a per-brand ratio that cannot honestly be attributed to it.
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 AND av.IsComplete = 1
         THEN av.TotalAV / sf.SqFt END AS AVPerSF,

    g.AssessmentYear + 1 AS TaxPayYear,
    tx.AnnualTax, tx.Source AS TaxSource, CAST(tx.IsComplete AS INT) AS TaxComplete,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 AND tx.IsComplete = 1
         THEN tx.AnnualTax / sf.SqFt END AS TaxPerSF,

    bs.BurdenShiftParcels, bs.BurdenShiftAVIncrease, bs.BurdenShiftPctIncrease,
    bs.BurdenShiftPriorAVPSF,
    CASE WHEN bs.AnyArgue = 1 THEN N'revert-then-argue'
         WHEN bs.BurdenShiftParcels > 0 THEN N'revert-and-done' END AS BurdenShiftPosture,

    sl.SalesInYear, sl.HighestSalePrice, sl.LowestSalePSF, sl.LatestSaleDate,

    st.SettlementCount, st.HighestSettlementAV, st.LowestAgreedPSF
FROM grid g
JOIN big_box_retail.Store s ON s.ID = g.StoreID
CROSS APPLY (SELECT SqFt = COALESCE(s.AttributedBuildingSqFt, s.TotalBuildingSqFt)) sf
LEFT JOIN big_box_retail.StoreAssessment av
       ON av.StoreID = g.StoreID AND av.AssessmentYear = g.AssessmentYear
LEFT JOIN big_box_retail.StoreTax tx
       ON tx.StoreID = g.StoreID AND tx.PayYear = g.AssessmentYear + 1
LEFT JOIN bs ON bs.StoreID = g.StoreID AND bs.AssessmentYear = g.AssessmentYear
LEFT JOIN sales sl ON sl.StoreID = g.StoreID AND sl.SaleYear = g.AssessmentYear
LEFT JOIN settle st ON st.StoreID = g.StoreID;
GO

-- Restore every captured description whose column still exists under the same name.
DECLARE @v SYSNAME, @col SYSNAME, @val NVARCHAR(4000);
DECLARE ep_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT b.ViewName, b.ColumnName, b.Descr FROM #ep_backup b
    WHERE EXISTS (SELECT 1 FROM sys.columns c
                  WHERE c.object_id = OBJECT_ID('big_box_retail.' + b.ViewName)
                    AND c.name = b.ColumnName);
OPEN ep_cur;
FETCH NEXT FROM ep_cur INTO @v, @col, @val;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.extended_properties ep
               JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
               WHERE ep.major_id = OBJECT_ID('big_box_retail.' + @v)
                 AND ep.name = 'MS_Description' AND c.name = @col)
        EXEC sp_dropextendedproperty @name = N'MS_Description',
            @level0type = N'SCHEMA', @level0name = N'big_box_retail',
            @level1type = N'VIEW',   @level1name = @v, @level2type = N'COLUMN', @level2name = @col;
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = @val,
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = @v, @level2type = N'COLUMN', @level2name = @col;
    FETCH NEXT FROM ep_cur INTO @v, @col, @val;
END
CLOSE ep_cur; DEALLOCATE ep_cur;
DROP TABLE #ep_backup;
GO

-- The renamed column cannot inherit the old name's description, so set it explicitly.
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Year the primary structure was originally constructed. Named with "Year" deliberately: MJ Explorer decides how a number renders from its SQL type plus its field name, and only a name matching /year/i is rendered as a plain year rather than a comma-grouped integer. See Indiana_Tax_Expert/docs/NUMBER_FORMATTING.md.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis', @level2type = N'COLUMN', @level2name = N'YearBuilt';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Year the primary structure was originally constructed. Named with "Year" deliberately — see the note on vwStoreAnalysis.YearBuilt and Indiana_Tax_Expert/docs/NUMBER_FORMATTING.md.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'YearBuilt';
GO
