/* ============================================================================
   Indiana Property Tax Expert — add Memo and Regulation document types
   v5.52.x

   DLGF publishes two document categories the original indiana_tax.SourceDocument
   CHECK constraint didn't anticipate: guidance memos (DLGF Memos & Presentations)
   and administrative rules (e.g. 50 IAC 2.4, the rule implementing the Real
   Property Assessment Manual). Neither is a "Statute" (that's Indiana Code) or a
   generic "Other" — both are cited/referenced enough in practice to deserve their
   own type rather than being lumped together.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO

ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    N'BoardDecision', N'Statute', N'Form', N'ReferenceText', N'PTABOAAgenda', N'Memo', N'Regulation', N'Other'));
GO

EXEC sp_updateextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), or Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentType';
GO
