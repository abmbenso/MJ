/* ============================================================================
   Indiana Property Tax Expert — Assessment: source-document provenance
   v5.53.x  (OPP-32)

   Standing rule (2026-08-31): every data point must name the specific source
   document it came from -- a SourceDocument FK, never a bare free-text label.

   indiana_tax.Assessment carried only a free-text `Source` string
   ('dlgf_gdb_2025' / 'MarionPRC' / 'marion_foia_2026') and no link to the
   actual document/file it was extracted from -- unlike CountyAssessorRecord
   (SourceDocumentID + TaxHistorySourceDocumentID) and SaleTransaction
   (Source + SourceDocumentID). This adds the FK; `Source` is kept as the
   short provenance label, mirroring SaleTransaction.

   Backfill is done by scripts/backfill-assessment-source-documents.js:
     dlgf_gdb_2025    -> one SourceDocument for the GIO Data Harvest
                         Indiana_Parcels_2025.gdb (downloaded 2026-07-13)
     marion_foia_2026 -> one SourceDocument for the Marion County 2026
                         Commercial/Industrial parcel list CSV
     MarionPRC        -> each row -> its parcel's CountyAssessorRecord
                         .SourceDocumentID (the per-parcel Property Record Card)
   ============================================================================ */

ALTER TABLE indiana_tax.Assessment ADD
    SourceDocumentID UNIQUEIDENTIFIER NULL;
GO

ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT FK_Assessment_SourceDocument
    FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The specific SourceDocument this assessment row was extracted from (the DLGF geodatabase pull, the Marion FOIA parcel-list CSV, or the parcel''s Property Record Card). The free-text `Source` column is the short provenance label; this is the traceable document.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Assessment', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO
