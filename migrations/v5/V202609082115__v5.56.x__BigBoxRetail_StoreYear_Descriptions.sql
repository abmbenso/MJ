/* Column documentation for vwStoreYear (see V202609082100 for the view). */

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment year this row describes. This is the filter the view exists for — one row per store per year, instead of the same measure spelled into 8 columns per year as vwStoreAnalysis must.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The retail brand operating the store.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'Occupant';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Building area used as the denominator for every ratio here: the attribution-resolved figure where the stores parcel list was narrowed, otherwise the roster total.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'SquareFeet';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value for this store in this assessment year, rolled up from its attributed parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TotalAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Land component of the assessed value for this year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'LandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Improvement component of the assessed value for this year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'ImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which source supplied this years assessed value — the county record card, the treasurer, or the DLGF extract. 2021-2022 come from billing AV rather than a PRC, a related but not identical measure.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AVSource';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 when every attributed parcel reported a value for this year. A partial sum is not comparable with a complete one, and AVPerSF is suppressed when this is 0.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AVComplete';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed value per square foot — the number to read against the $50/SF Indiana big-box benchmark. Suppressed unless the year is complete AND the store is uniformity-eligible, so a shared or review-tier store never publishes a per-brand ratio it cannot support.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AVPerSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The pay year for this assessment year. Indiana bills in arrears: assessment year N is paid in year N+1.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TaxPayYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total tax billed for this assessment year, in its pay year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AnnualTax';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which source supplied the tax figure. The treasurers posted figure is preferred over DLGFs "as originally certified" where both exist.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TaxSource';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 when every attributed parcel reported tax for this pay year. TaxPerSF is suppressed when 0.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TaxComplete';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tax per square foot for this year, under the same completeness and uniformity gate as AVPerSF.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How many of this stores parcels had the burden of proof shifted to the assessor in this year under IC 6-1.1-15-17.2 — an increase over 5% not attributable to new construction, a use change or a split. Counts only the usable, actionable band. NULL means none.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftParcels';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessed-value increase across those parcels: what reverting to the prior year would remove, before any further market argument.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftAVIncrease';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The largest percentage increase among this stores burden-shifted parcels this year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftPctIncrease';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The prior years assessed value per square foot — the value a successful burden argument reverts to, and therefore the number that decides whether that argument alone is sufficient.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftPriorAVPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What winning the burden argument alone achieves this year. "revert-and-done" — the prior year is already at or below the $50/SF benchmark. "revert-then-argue" — it is not, so the shift is the opening and market evidence is still needed beneath it.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftPosture';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Recorded transfers of this stores parcels that OCCURRED in this year and carry a price. ⚠️ This is not a comparable-sales screen: Indiana imposes no statutory limit on comparable-sale recency, so a sale in another year remains usable evidence, adjusted for remoteness rather than excluded.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'SalesInYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest recorded price among this years transfers of this stores parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'HighestSalePrice';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest price per square foot among this years transfers that pass the comparable screen or are in-band but from a county publishing no instrument type.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'LowestSalePSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the most recent priced transfer in this year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'LatestSaleDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'⚠️ STORE-level, not year-level, and repeated on every year row. Prior appeal settlements read from this stores record cards. They are NOT joined by year because the notes they come from are not reliably year-stamped — they often carry only the notes own date and frequently state several years at once. Attaching one to a year with a regex would be a guess.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'SettlementCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest total assessed value the county has previously agreed to on this store. Store-level; see SettlementCount for why it is not year-keyed. An assessed value, never a sale price.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'HighestSettlementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest prior settlement expressed as a rate per square foot, where the assessors note stated one directly. Store-level; the most directly usable form, because it is already in benchmark units.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'LowestAgreedPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How confidently this stores parcel set was resolved.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AttributionTier';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this store may publish per-square-foot ratios; gates AVPerSF and TaxPerSF.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'UniformityEligible';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner-occupied vs leased/investor, derived by testing the deeded owner against the store brand. NOT an occupancy or dark-store signal.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'OwnershipStructure';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner of record on the assessment.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'AssessedOwner';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Taxpayer named on the DLGF record — often a landlord entity rather than the retailer.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'TaxpayerOfRecord';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Year the primary structure was built.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'Built';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deeded acreage of the store site.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear',
    @level2type = N'COLUMN', @level2name = N'Acres';

GO
