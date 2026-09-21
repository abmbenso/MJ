/* ============================================================================
   Indiana Property Tax Expert — market assumptions (income-approach inputs)
   + per-sale cap rate.  v5.53.x

   Stage 2 (partial) of Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.
   The CoStar Marion County sales exports carry an Actual Cap Rate on ~378 of
   the ~3,160 closed sales -- a real, market-derived sample by property type
   (apartments median ~6.5%, office ~9%, warehouse ~7%, retail ~7.5-8%).

   Two additions:

   1. SaleTransaction.CapRateAtSale + ImpliedNOIAtSale -- promote the cap rate
      out of the Notes blob into real columns, and store SalePrice x CapRate
      as the implied market NOI for that transaction (CoStar gives no direct
      NOI). ImpliedNOI / SqFt and / Unit then become income-approach comps.

   2. indiana_tax.MarketAssumption (NEW) -- a curated / extracted parameter
      per (assumption type, property type group, submarket?, period). Seeded
      by scripts/load-market-assumptions.js from the SalesExtraction of the
      cap rates above (Method = 'SalesExtraction'); broker-survey / band-of-
      investment / manual rows are added the same way over time. This is the
      input the market-rent income approach (Stage 3) capitalizes with.
   ============================================================================ */

ALTER TABLE indiana_tax.SaleTransaction
ADD CapRateAtSale DECIMAL(6, 4) NULL,
    ImpliedNOIAtSale DECIMAL(14, 2) NULL;
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The overall (going-in) capitalization rate reported for this transaction, as a DECIMAL FRACTION (0.0650 = 6.50%). From the CoStar "Actual Cap Rate" field; NULL when not reported (the majority of sales).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'CapRateAtSale';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SalePrice x CapRateAtSale -- the market net operating income implied by the price and the reported cap rate. Computed at load. Used to derive NOI/SqFt and NOI/Unit comps for the income approach (CoStar reports no direct NOI).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'ImpliedNOIAtSale';
GO

CREATE TABLE indiana_tax.MarketAssumption (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    AssumptionType NVARCHAR(24) NOT NULL
        CONSTRAINT CK_MarketAssumption_AssumptionType CHECK (AssumptionType IN (
            'CapRate', 'NOIPerSqFt', 'NOIPerUnit',
            'Vacancy', 'ExpenseRatio', 'MarketRentPerSqFt', 'MarketRentPerUnit')),
    PropertyTypeGroup NVARCHAR(30) NOT NULL
        CONSTRAINT CK_MarketAssumption_PropertyTypeGroup CHECK (PropertyTypeGroup IN (
            'Retail', 'Office', 'Industrial', 'Multifamily', 'Land', 'Special', 'Other', 'All')),
    Submarket NVARCHAR(80) NULL,
    PeriodYear SMALLINT NULL,
    PeriodLabel NVARCHAR(30) NULL,

    Value DECIMAL(14, 4) NOT NULL,
    LowValue DECIMAL(14, 4) NULL,
    HighValue DECIMAL(14, 4) NULL,
    SampleSize INT NULL,

    Method NVARCHAR(24) NOT NULL
        CONSTRAINT CK_MarketAssumption_Method CHECK (Method IN (
            'SalesExtraction', 'BrokerSurvey', 'BandOfInvestment', 'Manual')),
    SourceNote NVARCHAR(300) NULL,
    Notes NVARCHAR(MAX) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_MarketAssumption_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_MarketAssumption_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_MarketAssumption PRIMARY KEY (ID)
);
GO
CREATE INDEX IX_MarketAssumption_Lookup
    ON indiana_tax.MarketAssumption (AssumptionType, PropertyTypeGroup, PeriodYear);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A market parameter used by the income approach: a capitalization rate, an implied NOI per SqFt / per Unit, a vacancy rate, an expense ratio, or a market rent per SqFt / per Unit. One row per (type, property-type group, submarket?, period, method).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which parameter this row states: CapRate / NOIPerSqFt / NOIPerUnit / Vacancy / ExpenseRatio / MarketRentPerSqFt / MarketRentPerUnit. Rates (CapRate/Vacancy/ExpenseRatio) are decimal fractions; the others are dollars.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'AssumptionType';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The property-type group this parameter applies to (Retail/Office/Industrial/Multifamily/Land/Special/Other), or ''All''.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'PropertyTypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Submarket the parameter is specific to; NULL = countywide.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'Submarket';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The year the parameter represents (e.g. the assessment/valuation year, or the year the extracted sales cluster around). NULL if PeriodLabel carries the period instead.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'PeriodYear';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free-text period when a single year does not fit (e.g. "2023-2025", "Q1 2024").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'PeriodLabel';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The concluded / central value (median for a SalesExtraction row). Decimal fraction for rate types, dollars otherwise.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'Value';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Low end of the supported range (e.g. 25th percentile of the extracted sample).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'LowValue';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'High end of the supported range (e.g. 75th percentile).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'HighValue';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of observations behind a SalesExtraction row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'SampleSize';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How the value was derived: SalesExtraction (from CapRateAtSale / ImpliedNOIAtSale on indiana_tax.SaleTransaction), BrokerSurvey (RealtyRates / PwC / CBRE etc.), BandOfInvestment (mortgage-equity build-up), or Manual.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'Method';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Citation / provenance for a non-extracted row (survey name, issue date, page).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'SourceNote';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free-text notes.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'MarketAssumption', @level2type = N'COLUMN', @level2name = N'Notes';
GO
