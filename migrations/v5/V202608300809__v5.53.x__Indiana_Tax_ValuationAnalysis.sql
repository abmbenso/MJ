/* ============================================================================
   Indiana Property Tax Expert — ValuationAnalysis (the appeal-decision output)
   v5.53.x

   Stage 5 of Indiana_Tax_Expert/docs/proposals/valuation-target-value.md -- the
   per-parcel, per-year workup that turns the market data (SaleTransaction,
   MarketAssumption, and later LeaseTransaction) into a Target Value and a
   "should this be appealed?" recommendation with an estimated tax saving.

   One row per (ParcelID, AssessmentYear, MethodologyVersion). Each valuation
   lens writes its own indicated value; ReconciledTargetValue + Controlling-
   Approach + ReconciliationRationale record how they were reconciled.
   Recommendation / ConfidenceTier / EstimatedTaxSavings are the actionable
   output.

   Posture (see the proposal + the valuation-posture note): this is advocacy
   screening, aimed at the LOWEST DEFENSIBLE value -- a >= 3-comp cluster, a
   conservative point in that cluster (not the single low outlier), guardrails
   against errors of magnitude (sanity band vs the county AV, confidence tier
   on every row, human review before anything becomes an appeal position).
   Outputs are appeal-screening estimates, NOT USPAP appraisals.

   First loader (scripts/load-valuation-analysis-sales.js) fills the SALES lane
   only. Income / cost-proxy lanes and per-subject comp selection + adjustment
   (CompSelection, Stage 6) come next.
   ============================================================================ */

CREATE TABLE indiana_tax.ValuationAnalysis (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear SMALLINT NOT NULL,
    MethodologyVersion NVARCHAR(30) NOT NULL,

    PropertyTypeGroup NVARCHAR(30) NULL,
    CurrentTotalAV DECIMAL(14, 2) NULL,

    -- per-approach indicated values
    SalesIndicatedValue DECIMAL(14, 2) NULL,
    SalesMethodNote NVARCHAR(400) NULL,
    IncomeIndicatedValue DECIMAL(14, 2) NULL,
    IncomeMethodNote NVARCHAR(400) NULL,
    CostProxyValue DECIMAL(14, 2) NULL,
    CostProxyNote NVARCHAR(400) NULL,

    -- reconciliation
    ReconciledTargetValue DECIMAL(14, 2) NULL,
    TargetValuePerUnit DECIMAL(14, 2) NULL,
    TargetValuePerSqFt DECIMAL(12, 2) NULL,
    ControllingApproach NVARCHAR(16) NULL
        CONSTRAINT CK_ValuationAnalysis_ControllingApproach CHECK (ControllingApproach IN (
            'Sales', 'Income', 'CostProxy', 'Blended', 'None')),
    ReconciliationRationale NVARCHAR(MAX) NULL,

    -- decision
    MaterialityPct DECIMAL(7, 4) NULL,
    MaterialityThreshold DECIMAL(7, 4) NOT NULL
        CONSTRAINT DF_ValuationAnalysis_MaterialityThreshold DEFAULT (0.05),
    AppliedTaxRate DECIMAL(8, 6) NULL,
    EstimatedTaxSavings DECIMAL(14, 2) NULL,
    Recommendation NVARCHAR(12) NULL
        CONSTRAINT CK_ValuationAnalysis_Recommendation CHECK (Recommendation IN (
            'Appeal', 'No Appeal', 'Monitor')),
    ConfidenceTier NVARCHAR(8) NULL
        CONSTRAINT CK_ValuationAnalysis_ConfidenceTier CHECK (ConfidenceTier IN (
            'High', 'Medium', 'Low')),

    CompCount INT NULL,
    AnalystNote NVARCHAR(MAX) NULL,
    GeneratedAt DATETIMEOFFSET NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ValuationAnalysis_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ValuationAnalysis_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ValuationAnalysis PRIMARY KEY (ID),
    CONSTRAINT UQ_ValuationAnalysis UNIQUE (ParcelID, AssessmentYear, MethodologyVersion),
    CONSTRAINT FK_ValuationAnalysis_Parcel FOREIGN KEY (ParcelID)
        REFERENCES indiana_tax.Parcel (ID)
);
GO
CREATE INDEX IX_ValuationAnalysis_Reco ON indiana_tax.ValuationAnalysis (Recommendation, ConfidenceTier);
CREATE INDEX IX_ValuationAnalysis_Parcel ON indiana_tax.ValuationAnalysis (ParcelID, AssessmentYear);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The per-parcel, per-year valuation workup: an indicated value under each approach, a reconciled Target Value, and a "should this be appealed?" recommendation with an estimated tax saving. Appeal-screening output, NOT a USPAP appraisal. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel analysed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'ParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The assessment year the analysis is for.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'AssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Version tag for the methodology that produced this row (e.g. "sales-p25-2026-08-30"). Lets a re-run replace its own rows without touching an earlier method''s.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'MethodologyVersion';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Rolled-up property category used for comp grouping.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'PropertyTypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The county''s current total assessed value the target is measured against.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'CurrentTotalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Value indicated by the sales comparison approach.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'SalesIndicatedValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'How the sales indication was derived (comp pool, unit metric, the point statistic used).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'SalesMethodNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Value indicated by the income capitalization approach (not yet populated).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'IncomeIndicatedValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'How the income indication was derived.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'IncomeMethodNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The county''s own mass-appraisal cost figure, surfaced as a proxy / sanity anchor ONLY -- the DLGF cost tables cannot be relied on by either party in a subjective valuation argument. Not yet populated.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'CostProxyValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Note on the cost proxy, including the caveat above.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'CostProxyNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The reconciled opinion of value -- the number an appeal would argue for.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'ReconciledTargetValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ReconciledTargetValue / unit count.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'TargetValuePerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ReconciledTargetValue / building sq ft.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'TargetValuePerSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Which approach controlled the reconciliation: Sales / Income / CostProxy / Blended / None.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'ControllingApproach';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Narrative: why these approaches, why this weighting, why this point in the range.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'ReconciliationRationale';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'(CurrentTotalAV - ReconciledTargetValue) / CurrentTotalAV -- how far below the assessment the target sits.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'MaterialityPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The reduction fraction below which an appeal is not worth pursuing (default 5%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'MaterialityThreshold';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The tax rate applied to convert an AV reduction into a dollar saving (from CountyAssessorRecord.TaxRate as a percent, or a default). ',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'AppliedTaxRate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'(CurrentTotalAV - ReconciledTargetValue) x AppliedTaxRate -- the estimated annual tax saving if the target is achieved.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'EstimatedTaxSavings';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Appeal / No Appeal / Monitor. "Monitor" = a signal exists but the comp support is thin or the indication is implausibly far from the AV (needs a human look).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'Recommendation';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'High / Medium / Low. High requires a solid comp cluster, a PRC-sourced size, and an indication within a sane band of the AV.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'ConfidenceTier';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Number of comparable sales behind the sales indication.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'CompCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Free-text analyst / agent notes.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'AnalystNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'When this analysis row was generated.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'GeneratedAt';
GO
