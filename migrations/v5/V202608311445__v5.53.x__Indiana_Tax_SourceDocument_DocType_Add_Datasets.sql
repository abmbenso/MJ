/* ============================================================================
   Indiana Property Tax Expert — SourceDocument.DocumentType: add dataset types
   v5.53.x  (OPP-32)

   The Assessment provenance backfill needs document types for two bulk data
   sources that aren't per-parcel PDFs:
     StatewideParcelDataset -- the DLGF/GIO statewide parcel geodatabase pull
     CountyParcelList        -- a county's bulk parcel-list export / FOIA CSV
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO

ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (
    DocumentType IN (
        'PropertyRecordCard', 'TaxHistoryReport', 'PTABOAAgenda',
        'PTABOAFinalDeterminationApproval', 'PTABOAFinalDeterminationWithdrawal',
        'BoardDecision', 'Form', 'Statute', 'Regulation', 'ReferenceText', 'Memo',
        'StatewideParcelDataset', 'CountyParcelList', 'Other'
    )
);
GO
