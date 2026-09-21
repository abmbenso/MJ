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
    sf.SqFt AS SquareFeet, s.YearBuilt AS Built, s.Acres,
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
