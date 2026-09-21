/* ============================================================================
   Indiana Property Tax Expert — Tax History Report multi-year trend data.
   v5.53.x

   The Tax History Report PDF (already fetched for every parcel via the
   TaxHistoryReport document type -- see V202608232209) carries a current-year
   snapshot on its first page (already captured on CountyAssessorRecord) AND a
   "PRIOR TAX PAYMENT INFORMATION" table going back to 2000 that nothing reads
   yet. This migration adds storage for that historical assessment/tax-
   liability trend so it can be re-parsed from already-stored
   SourceDocument.ExtractedText -- no new PDF fetches required.

   Two real findings from the source documents (verified against 8 real,
   already-fetched Tax History Reports) shape this schema:

     1. The historical table's "Gross Tax" field is NOT a real dollar figure
        -- it exactly duplicates "Tax Rate"'s value under a different label in
        every document checked (e.g. both rows show "$2.57"). Deliberately
        EXCLUDED from this table rather than stored as if legitimate; the raw
        text remains in SourceDocument.ExtractedText if this needs revisiting.

     2. The year 2007 appears TWICE in every document checked -- not
        corruption, but Marion County's real 2007 statewide-reassessment-cycle
        transition: one column carries zeroed AV/rate fields with a real
        NetAnnualTax, the other carries real AV fields with a DIFFERENT
        NetAnnualTax. Both are real data. This means (ParcelID, TaxYear) is
        NOT a safe uniqueness key -- ColumnOrdinal (the column's position
        within the document, 0 = current year, 1 = most recent historical
        column, increasing with age) disambiguates the two 2007 rows, so
        neither is silently dropped.

   This is a NEW table rather than an extension of indiana_tax.Assessment:
   Assessment's own UNIQUE (ParcelID, AssessmentYear, Source) constraint would
   be directly violated by the duplicate-2007 case, and Assessment has no
   columns at all for tax-liability figures (rate, credits, net tax).
   ============================================================================ */

CREATE TABLE indiana_tax.TaxHistoryYear (
    ID                          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID                    UNIQUEIDENTIFIER NOT NULL,
    TaxHistorySourceDocumentID  UNIQUEIDENTIFIER NOT NULL,
    TaxYear                     SMALLINT         NOT NULL,
    ColumnOrdinal               SMALLINT         NOT NULL,
    LandAssessment               DECIMAL(14,2)   NULL,
    Improvements                 DECIMAL(14,2)   NULL,
    GrossAssessment              DECIMAL(14,2)   NULL,
    DeductionsExemptionsTotal    DECIMAL(14,2)   NULL,
    NetAssessment                DECIMAL(14,2)   NULL,
    TaxRate                      DECIMAL(9,6)    NULL,
    ReplacementCredit            DECIMAL(14,2)   NULL,
    HomesteadCredit               DECIMAL(14,2)  NULL,
    NetAnnualTax                  DECIMAL(14,2)  NULL,
    HalfYearTax                   DECIMAL(14,2)  NULL,
    CONSTRAINT PK_TaxHistoryYear PRIMARY KEY (ID),
    CONSTRAINT FK_TaxHistoryYear_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_TaxHistoryYear_SourceDocument FOREIGN KEY (TaxHistorySourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT UQ_TaxHistoryYear_Parcel_Year_Ordinal UNIQUE (ParcelID, TaxYear, ColumnOrdinal)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per (parcel, document-position) entry from a Tax History Report''s multi-year assessment/tax-liability history -- both the current-year snapshot (ColumnOrdinal=0) and every historical column found in the "PRIOR TAX PAYMENT INFORMATION" table (ColumnOrdinal>=1, oldest columns have the highest ordinal). Stores every year the document has, not limited to any fixed lookback window -- "10 years" is a query-time convention for consumers, not a storage cutoff. GrossTax is deliberately NOT stored here -- confirmed across every document checked to exactly duplicate TaxRate under a different label, not a real dollar figure.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this historical tax-year row belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument row for the Tax History Report PDF this row was parsed from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'TaxHistorySourceDocumentID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The tax year (payable year) this row reports on, per the document''s own "Tax Year:" header for this column. NOT unique per parcel by itself -- see ColumnOrdinal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'TaxYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'This row''s position within the document: 0 = the current-year snapshot from the report''s first-page section, 1 = the most recent column of the "PRIOR TAX PAYMENT INFORMATION" table, increasing with age. NOT derivable from TaxYear alone -- the year 2007 genuinely appears twice (Marion County''s real 2007 statewide-reassessment-cycle transition, confirmed across every document checked) at two different ordinals; this is the real uniqueness key together with TaxYear, not a synthetic workaround.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'ColumnOrdinal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Land Assessment" figure for this tax year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'LandAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Improvements" assessment figure for this tax year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'Improvements';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Gross Assessment" figure for this tax year (Land + Improvements, before deductions/exemptions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'GrossAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Deductions/Exemptions" total applied for this tax year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'DeductionsExemptionsTotal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Net Assessment" figure for this tax year (Gross Assessment less Deductions/Exemptions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'NetAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Tax Rate" for this tax year, per $100 of assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'TaxRate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Replacement Credit" applied for this tax year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'ReplacementCredit';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Homestead Credit" applied for this tax year -- a single combined figure in the historical table (unlike the current-year section, which splits state/local homestead credit into separate fields).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'HomesteadCredit';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Net Annual Tax" liability for this tax year -- the reliable tax-liability figure for this row (see the table-level note on why GrossTax is not stored).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'NetAnnualTax';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Half Year Tax" figure for this tax year (Net Annual Tax split across the two semi-annual installments).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'TaxHistoryYear',
    @level2type = N'COLUMN', @level2name = N'HalfYearTax';
GO
