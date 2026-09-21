/* ============================================================================
   Indiana Property Tax Expert — Marion County Tax History Report support.
   v5.52.x

   The Tax History Report (maps.indy.gov, sibling to the Property Record Card,
   same reporting backend, no CAPTCHA) turned out to be clean "Label: Value"
   text -- confirmed against a real parcel this session -- and independently
   confirmed the Gross-AV/Net-AV and Gross-Tax/Net-Tax field semantics that had
   only been hypothesized while reverse-engineering the statewide TAXBILL file
   (see ResearchTask 92DB7E5C-...). It's a second, high-confidence per-parcel
   document alongside the PRC.

   CountyAssessorRecord already carries every field this report populates
   (GrossAssessment, NetAssessment, TaxRate, NetAnnualTax, CurrentTaxDue,
   DeedType/Date, YearBuilt, LastAssessmentChangeDate, TaxYear -- added in the
   original County_Assessor_Record migration with exactly this report in mind).
   This migration only adds the DocumentType value and the SourceDocument link
   -- a separate column from PRC's SourceDocumentID, since these are two
   independently-fetched documents with their own hash/retrieval history.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO

ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    N'BoardDecision', N'Statute', N'Form', N'ReferenceText', N'PTABOAAgenda', N'Memo', N'Regulation', N'PropertyRecordCard', N'TaxHistoryReport', N'Other'));
GO

EXEC sp_updateextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF, e.g. Marion County''s maps.indy.gov report), TaxHistoryReport (a county assessor Tax History Report PDF, the same maps.indy.gov system''s sibling report to the PRC), or Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentType';
GO

ALTER TABLE indiana_tax.CountyAssessorRecord
ADD TaxHistorySourceDocumentID UNIQUEIDENTIFIER NULL
    CONSTRAINT FK_CountyAssessorRecord_TaxHistorySourceDocument FOREIGN KEY REFERENCES indiana_tax.SourceDocument(ID);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument row for this parcel''s most recently fetched Tax History Report PDF -- distinct from SourceDocumentID, which links the Property Record Card. NULL until a Tax History Report has been fetched for this parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'TaxHistorySourceDocumentID';
GO
