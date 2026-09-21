/* ============================================================================
   Big Box Retail — surface settlement disposition on vwStoreYear
   v5.56.x

   Adds the Form 134 / Form 115 split from V202609090900, plus the year-keyed
   settled value for the few settlements whose year the note states.

   Two judgements encoded here rather than left to the reader:
     * Form 133 (correction of error) is excluded from HighestSettlementAV and
       LowestAgreedPSF. It is not a valuation dispute, and counting it as a
       concession would overstate what the county has conceded on value.
     * PriorConferenceSettlements is separated from PriorBoardDeterminations
       because they mean different things about a parcel's history: a
       preliminary conference settled before a hearing, a board determination
       went to one.

   ALTER VIEW drops column descriptions and CodeGen will not restore them on a
   virtual entity, so they are captured and re-applied as in V202609081930.
   ============================================================================ */

SELECT c.name AS ColumnName, CAST(ep.value AS NVARCHAR(4000)) AS Descr
INTO #sy_ep
FROM sys.extended_properties ep
JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
WHERE ep.major_id = OBJECT_ID('big_box_retail.vwStoreYear') AND ep.name = 'MS_Description';
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
    -- Store-level, NOT year-level. See limit 1 in the header. Form 133 is excluded from
    -- the conceded-value figures: a correction of error is not a valuation dispute and
    -- counting it as a concession on value would overstate what the county has given up.
    SELECT StoreID,
           COUNT(*) AS SettlementCount,
           MAX(CASE WHEN DispositionForm IS NULL OR DispositionForm <> N'133'
                    THEN SettlementAV END) AS HighestSettlementAV,
           MIN(CASE WHEN DispositionForm IS NULL OR DispositionForm <> N'133'
                    THEN AgreedPSF END)    AS LowestAgreedPSF,
           COUNT(CASE WHEN DispositionForm = N'134' THEN 1 END) AS PriorConferenceSettlements,
           COUNT(CASE WHEN DispositionForm = N'115' THEN 1 END) AS PriorBoardDeterminations
    FROM big_box_retail.ParcelSettlement WHERE StoreID IS NOT NULL GROUP BY StoreID
), settleyr AS (
    -- The few settlements whose assessment year the note states unambiguously.
    SELECT StoreID, AssessmentYear,
           MAX(SettlementAV) AS SettledAVThisYear,
           MAX(Disposition)  AS DispositionThisYear
    FROM big_box_retail.ParcelSettlement
    WHERE StoreID IS NOT NULL AND AssessmentYear IS NOT NULL
    GROUP BY StoreID, AssessmentYear
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

    st.SettlementCount, st.HighestSettlementAV, st.LowestAgreedPSF,
    st.PriorConferenceSettlements, st.PriorBoardDeterminations,
    sy.SettledAVThisYear, sy.DispositionThisYear
FROM grid g
JOIN big_box_retail.Store s ON s.ID = g.StoreID
CROSS APPLY (SELECT SqFt = COALESCE(s.AttributedBuildingSqFt, s.TotalBuildingSqFt)) sf
LEFT JOIN big_box_retail.StoreAssessment av
       ON av.StoreID = g.StoreID AND av.AssessmentYear = g.AssessmentYear
LEFT JOIN big_box_retail.StoreTax tx
       ON tx.StoreID = g.StoreID AND tx.PayYear = g.AssessmentYear + 1
LEFT JOIN bs ON bs.StoreID = g.StoreID AND bs.AssessmentYear = g.AssessmentYear
LEFT JOIN sales sl ON sl.StoreID = g.StoreID AND sl.SaleYear = g.AssessmentYear
LEFT JOIN settle st ON st.StoreID = g.StoreID
LEFT JOIN settleyr sy ON sy.StoreID = g.StoreID AND sy.AssessmentYear = g.AssessmentYear;
GO

DECLARE @col SYSNAME, @val NVARCHAR(4000);
DECLARE c2 CURSOR LOCAL FAST_FORWARD FOR
    SELECT e.ColumnName, e.Descr FROM #sy_ep e
    WHERE EXISTS (SELECT 1 FROM sys.columns c
                  WHERE c.object_id = OBJECT_ID('big_box_retail.vwStoreYear') AND c.name = e.ColumnName);
OPEN c2; FETCH NEXT FROM c2 INTO @col, @val;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.extended_properties ep
               JOIN sys.columns c ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
               WHERE ep.major_id = OBJECT_ID('big_box_retail.vwStoreYear')
                 AND ep.name = 'MS_Description' AND c.name = @col)
        EXEC sp_dropextendedproperty @name = N'MS_Description',
            @level0type = N'SCHEMA', @level0name = N'big_box_retail',
            @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = @col;
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = @val,
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = @col;
    FETCH NEXT FROM c2 INTO @col, @val;
END
CLOSE c2; DEALLOCATE c2; DROP TABLE #sy_ep;
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How many of this store''s prior settlements were reached at a PRELIMINARY INFORMAL CONFERENCE (Form 134) - before any hearing. Read this first: it is the stage that actually produces reductions, and a store with a history here has a county that has settled with it before rather than litigated. Store-level, repeated on every year row.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'PriorConferenceSettlements';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How many of this store''s prior appeals went to a PTABOA determination (Form 115) - the board ruled rather than the parties settling. Store-level, repeated on every year row.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'PriorBoardDeterminations';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value a settlement fixed for THIS assessment year, where the note stated the year unambiguously. Sparse by design - only 4 of 123 settlements survive the strictness required to date one safely, since a wrong year files a concession against an assessment it never touched. Where this is NULL the store may still have settlements: see SettlementCount, which is store-level.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'SettledAVThisYear';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How the settlement covering this specific assessment year was disposed of, in words. Same sparsity caveat as SettledAVThisYear.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW', @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'DispositionThisYear';
GO
