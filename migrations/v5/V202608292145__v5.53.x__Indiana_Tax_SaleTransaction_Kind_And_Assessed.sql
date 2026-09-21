/* ============================================================================
   Indiana Property Tax Expert — SaleTransaction: transaction kind +
   assessed-value-at-sale.  v5.53.x

   Follow-on to V202608292128 (SaleTransaction). Two additions surfaced while
   loading the CoStar Marion County sales exports:

   1. TransactionKind -- the exports mix closed sales with ACTIVE LISTINGS and
      UNDER-CONTRACT rows (Sale Status = 'Active' / 'Under Contract'). Those
      are not comps and must never enter comp selection, but a property
      *listed* below its assessed value is still an appeal lead. Keep them in
      the same table, tagged, so comp queries filter to
      TransactionKind = 'ClosedSale' and the lead-generation queries can
      include listings deliberately.

   2. AssessedValueAtSale / AssessedYearAtSale / SaleToAssessedRatio -- to
      support the standing "flag properties that transact for less than their
      assessment" screen. The CoStar export carries the county AV directly;
      for PRC-sourced transfers the loader backfills it from
      indiana_tax.Assessment (nearest year within +/- 2). Ratio is computed
      at load: SalePrice / AssessedValueAtSale (< 1.0 => sold below the
      assessment => over-assessment candidate).
   ============================================================================ */

ALTER TABLE indiana_tax.SaleTransaction
ADD TransactionKind NVARCHAR(20) NOT NULL
        CONSTRAINT DF_SaleTransaction_TransactionKind DEFAULT ('ClosedSale')
        CONSTRAINT CK_SaleTransaction_TransactionKind CHECK (TransactionKind IN (
            'ClosedSale', 'UnderContract', 'ActiveListing')),
    AssessedValueAtSale DECIMAL(14, 2) NULL,
    AssessedYearAtSale SMALLINT NULL,
    SaleToAssessedRatio DECIMAL(9, 4) NULL;
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ClosedSale (a completed transaction -- the only kind that should enter comp selection), UnderContract (pending), or ActiveListing (currently for sale; SalePrice is the list/asking price). Listings are retained for lead generation -- a property listed below its assessed value is an appeal signal -- but must be filtered out of any comp analysis.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'TransactionKind';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The county assessed (total) value applicable around the transaction date. From the CoStar export directly for CoStar rows; backfilled from indiana_tax.Assessment (nearest AssessmentYear within +/- 2 of the sale year) for PRC-sourced transfers. NULL when no contemporaneous AV is available (older transfers).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'AssessedValueAtSale';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The assessment year of AssessedValueAtSale.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'AssessedYearAtSale';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SalePrice / AssessedValueAtSale, computed at load. Below ~1.0 means the property sold for less than its assessment -- an over-assessment / appeal candidate. Interpret with the sale''s IsArmsLength and any allocation/portfolio note: a per-parcel slice price of a portfolio deal against a whole-portfolio AV produces a misleadingly low ratio.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'SaleToAssessedRatio';
GO
