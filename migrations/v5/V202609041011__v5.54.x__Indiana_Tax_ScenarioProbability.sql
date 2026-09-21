/* ============================================================================
   Indiana Property Tax Expert — post-sale reassessment scenario probabilities
   v5.54.x

   Promotes OPP-2's (docs/OPPORTUNITIES.md) empirical Component A output from
   flat CSV (data/post_sale_reassessment/scenario_probabilities_*.csv) into a
   real, RunView-queryable table -- the piece OPP-1 Component B's Worst Case /
   Most Likely / Best Case probability-weighted tax-budget projection needs to
   run live in an Explorer dashboard rather than only from a Node script.

   Background (see scripts/model-post-sale-reassessment.js for the full
   methodology + caveats): for Marion County sales that landed meaningfully
   above their pre-sale assessed value, ChaseFraction measures how much of
   the price-vs-AV gap the Assessor closed by year N. A flat "sold >10% above
   AV" population was found to be confounded by ordinary trend closing small
   gaps on its own (P(full chase) fell from 39% at a 10-20% gap to 9% at a
   100%+ gap, with nothing to do with real assessor behavior) -- so rows are
   banded by the sale's own gap size, not blended. Each row answers: for a
   sale of this property type that landed this far above its pre-sale AV, what
   fraction of comparable Marion sales got fully chased to price (Worst Case),
   partially reacted to (Most Likely), or saw no reaction (Best Case) within
   3 years.

   Populated (and re-populated on a periodic refresh -- this is a computed
   aggregate, not a live view, hence ComputedAt) by
   scripts/model-post-sale-reassessment.js. One row per (county, property
   type, gap band, methodology version); 'All' PropertyTypeGroup rows are the
   county-wide fallback used when a specific type's sample is too thin.
   ============================================================================ */

CREATE TABLE indiana_tax.SaleReassessmentScenarioProbability (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    CountyNumber INT NOT NULL,
    PropertyTypeGroup NVARCHAR(30) NOT NULL
        CONSTRAINT CK_SaleReassessmentScenarioProbability_PropertyTypeGroup CHECK (PropertyTypeGroup IN (
            'Retail', 'Office', 'Industrial', 'Multifamily', 'Hospitality',
            'Land', 'Special', 'Parking', 'Other', 'All')),
    GapBand NVARCHAR(10) NOT NULL
        CONSTRAINT CK_SaleReassessmentScenarioProbability_GapBand CHECK (GapBand IN (
            '10-25%', '25-50%', '50-100%', '100%+')),

    SampleSize INT NOT NULL,

    PWorstCaseFullChase DECIMAL(6, 4) NOT NULL,
    WorstCaseMedianChaseFraction DECIMAL(8, 4) NULL,
    PMostLikelyPartial DECIMAL(6, 4) NOT NULL,
    MostLikelyMedianChaseFraction DECIMAL(8, 4) NULL,
    PBestCaseNoReaction DECIMAL(6, 4) NOT NULL,
    BestCaseMedianChaseFraction DECIMAL(8, 4) NULL,
    LowSample BIT NOT NULL DEFAULT 0,

    MethodologyVersion NVARCHAR(40) NOT NULL,
    ComputedAt DATETIMEOFFSET NOT NULL,

    CONSTRAINT PK_SaleReassessmentScenarioProbability PRIMARY KEY (ID),
    CONSTRAINT UQ_SaleReassessmentScenarioProbability UNIQUE (CountyNumber, PropertyTypeGroup, GapBand, MethodologyVersion)
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Empirical post-sale reassessment scenario probabilities (OPP-2 Component A), one row per (county, property type, gap-to-price band, methodology version): what fraction of comparable arm''s-length sales landing this far above their pre-sale AV got fully chased to price within 3 years (Worst Case) vs. partially reacted to (Most Likely) vs. saw no reaction (Best Case). Feeds OPP-1 Component B''s probability-weighted tax-budget projection. Recomputed periodically by scripts/model-post-sale-reassessment.js -- not a live view.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF county number the sample was drawn from (49 = Marion).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'CountyNumber';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The property type this row applies to, or ''All'' for the county-wide (all types combined) fallback row used when a specific type''s sample in this gap band is too thin.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'PropertyTypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How far the sale price landed above the parcel''s pre-sale assessed value (e.g. ''25-50%'' = sale price was 25-50% above pre-sale AV). Banding by gap size (rather than a flat >10% threshold) removes a confound: ordinary trend alone closes a small gap over 3 years with no real assessor reaction involved, so a flat population overstates the full-chase probability for small gaps.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'GapBand';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of qualifying sale x post-sale-assessment-year observations behind this row (with a meaningful gap to classify). Rows below the model''s sample-size floor are flagged via LowSample, not excluded.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'SampleSize';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fraction (0.0-1.0) of the sample where the Assessor closed >=85% of the price-vs-AV gap within 3 years -- treated as a "full chase to price" Worst Case outcome.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'PWorstCaseFullChase';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Median ChaseFraction among the Worst Case (>=85% closed) subset -- the representative magnitude to use for that bucket, not just the >=85% threshold itself.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'WorstCaseMedianChaseFraction';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fraction (0.0-1.0) of the sample landing between the Worst Case and Best Case thresholds (a real but partial reaction) -- the Most Likely outcome.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'PMostLikelyPartial';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Median ChaseFraction among the Most Likely (partial-reaction) subset.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'MostLikelyMedianChaseFraction';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fraction (0.0-1.0) of the sample where the Assessor closed <=10% of the gap -- essentially no reaction to the sale. Best Case outcome.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'PBestCaseNoReaction';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Median ChaseFraction among the Best Case (no-reaction) subset.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'BestCaseMedianChaseFraction';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'True when SampleSize is below the model''s minimum sample-size floor -- shown for transparency, not filtered out; a consumer should prefer the ''All'' PropertyTypeGroup row for this gap band when this is set.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'LowSample';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Version tag for the methodology that produced this row (e.g. "scenario-prob-v1-2026-09-04") -- lets the threshold/bucketing logic change over time without silently reinterpreting old rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'MethodologyVersion';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was last (re)computed. Not a live-updating view -- refreshed by re-running scripts/model-post-sale-reassessment.js.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleReassessmentScenarioProbability', @level2type = N'COLUMN', @level2name = N'ComputedAt';
GO
