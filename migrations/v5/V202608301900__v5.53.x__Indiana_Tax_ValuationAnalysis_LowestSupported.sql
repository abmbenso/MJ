/* ============================================================================
   Indiana Property Tax Expert — ValuationAnalysis: lowest-credible-value model
   v5.53.x

   Direction change (2026-08-30): drop "Blended" reconciliation. The target is
   always the LOWEST CREDIBLE opinion of value. When two (or more) approaches
   independently land below the assessment, that redundancy is itself
   persuasive -- and the recommended ASK can be pitched at the higher of those
   low values for optics, while the lowest stays on record as the floor.

   New columns:
     LowestSupportedValue    -- the aggressive floor: MIN of the in-band approach
                                indications (Sales / Income / CostProxy)
     SupportingApproachCount -- how many approaches independently indicate a value
                                below the current AV (and within the sanity band)
     MaxEstimatedTaxSavings  -- estimated annual saving if LowestSupportedValue is
                                achieved (EstimatedTaxSavings is the saving at the
                                recommended ask = ReconciledTargetValue)

   ControllingApproach CHECK: 'Blended' removed.
   ============================================================================ */

ALTER TABLE indiana_tax.ValuationAnalysis ADD
    LowestSupportedValue DECIMAL(14, 2) NULL,
    SupportingApproachCount TINYINT NULL,
    MaxEstimatedTaxSavings DECIMAL(14, 2) NULL;
GO

ALTER TABLE indiana_tax.ValuationAnalysis DROP CONSTRAINT CK_ValuationAnalysis_ControllingApproach;
GO
-- retire any existing 'Blended' rows before tightening the enum; the income
-- loader re-run reconciles every row fresh under the new rules.
UPDATE indiana_tax.ValuationAnalysis SET ControllingApproach = 'None' WHERE ControllingApproach = 'Blended';
GO
ALTER TABLE indiana_tax.ValuationAnalysis ADD CONSTRAINT CK_ValuationAnalysis_ControllingApproach
    CHECK (ControllingApproach IN ('Sales', 'Income', 'CostProxy', 'None'));
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The aggressive floor -- MIN of the approach indications (Sales / Income / CostProxy) that fall within the sanity band [0.5, 1.2] x current AV. The lowest credible opinion of value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'LowestSupportedValue';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How many approaches independently indicate a value below the current AV (and in band). >= 2 means redundant support for a reduction -- the recommended ask is then pitched at the higher of the low values.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'SupportingApproachCount';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated annual tax saving if LowestSupportedValue is achieved. EstimatedTaxSavings is the saving at the recommended ask (ReconciledTargetValue); this is the saving at the floor.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationAnalysis', @level2type = N'COLUMN', @level2name = N'MaxEstimatedTaxSavings';
GO
