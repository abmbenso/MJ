/* ============================================================================
   Indiana Property Tax Expert — CoStar tables: source-document provenance
   v5.53.x  (OPP-32 follow-up)

   CoStarProperty.SourceExportFile and CoStarIncomeInput.SourceFile were
   free-text spreadsheet names with no link to a registered document. Add a
   SourceDocumentID FK on both (keeping the text label alongside, per the
   SaleTransaction pattern), and add a 'MarketDataExport' document type for the
   CoStar .xlsx exports.

   Backfilled by scripts/backfill-costar-source-documents.js:
     - one SourceDocument per CoStar export file in /Users/abebenson/Projects/
       CoStar_Data/ (real SHA-256), linked to CoStarProperty + CoStarIncomeInput
     - one SourceDocument for the 2026-08-29 CoStar *sales* export batch
       (source dir ~/Sales_Data/IN - Marion Co/ no longer on disk; per-file
       attribution was not captured at load) linked to SaleTransaction
       WHERE Source = 'CoStar'
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO
ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (
    DocumentType IN (
        'PropertyRecordCard', 'TaxHistoryReport', 'PTABOAAgenda',
        'PTABOAFinalDeterminationApproval', 'PTABOAFinalDeterminationWithdrawal',
        'BoardDecision', 'Form', 'Statute', 'Regulation', 'ReferenceText', 'Memo',
        'StatewideParcelDataset', 'CountyParcelList', 'MarketDataExport', 'Other'
    )
);
GO

ALTER TABLE indiana_tax.CoStarProperty ADD SourceDocumentID UNIQUEIDENTIFIER NULL;
GO
ALTER TABLE indiana_tax.CoStarProperty ADD CONSTRAINT FK_CoStarProperty_SourceDocument
    FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID);
GO

ALTER TABLE indiana_tax.CoStarIncomeInput ADD SourceDocumentID UNIQUEIDENTIFIER NULL;
GO
ALTER TABLE indiana_tax.CoStarIncomeInput ADD CONSTRAINT FK_CoStarIncomeInput_SourceDocument
    FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The CoStar export .xlsx this row was parsed from (SourceExportFile is the short label). CoStar data is a labeled cross-check, not authority.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The CoStar export .xlsx this row was parsed from (SourceFile is the filename text). CoStar data is a labeled cross-check, not authority.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO
