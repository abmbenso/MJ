/* ============================================================================
   Indiana Property Tax Expert — PTABOA Final Determination confirmation.
   v5.53.x

   Everything indiana_tax.PTABOAAppeal knows today comes from PTABOA AGENDA
   PDFs -- which show what's being PROPOSED to the board, not necessarily
   what it actually ratified. Cross-checking three real months (July/August/
   September 2025) against indy.gov's actual Final Determination documents
   (Form 115 -- https://www.indy.gov/activity/property-tax-assessment-board-
   of-appeals) surfaced a real, concrete example: case 49-101-24-0-4-00083
   was labeled "Final Agreement" on its July agenda appearance, but its own
   August agenda re-appearance revealed the true status was "Recommended...
   submitted to the PTABOA at the next hearing for final approval" -- the
   July label was premature, and as of September it's still not confirmed.
   The one month checked exhaustively (Aug 22, 2025, 64 cases) matched the
   true Form 115 dollar figures 100% exactly, so agenda data isn't unreliable
   in general -- it's just UNCONFIRMED until ratified, and nothing previously
   distinguished the two states.

   MARION COUNTY-SPECIFIC: this Final Determination page/format is not known
   to exist (or be this transparent) for other Indiana counties -- same
   scoping caveat as the rest of this project's PTABOA/PRC/Tax History work.

   No separate "Confirmed" boolean -- FinalDeterminationSourceDocumentID IS
   NOT NULL already means confirmed (matches this project's practice of not
   storing derivable state). BeforeTotalAV/AfterTotalAV (agenda-predicted)
   are left untouched -- the whole point is comparing the two, not
   overwriting one with the other.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO

ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    N'BoardDecision', N'Statute', N'Form', N'ReferenceText', N'PTABOAAgenda', N'Memo', N'Regulation',
    N'PropertyRecordCard', N'TaxHistoryReport', N'PTABOAFinalDeterminationApproval', N'PTABOAFinalDeterminationWithdrawal', N'Other'));
GO

EXEC sp_updateextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF), TaxHistoryReport (a county assessor Tax History Report PDF), PTABOAFinalDeterminationApproval (a monthly batch of ratified Form 115 Notifications of Final Assessment Determination, from indy.gov''s "Preliminary Agreement Approvals" list -- Marion County only), PTABOAFinalDeterminationWithdrawal (the same, from indy.gov''s "Approved Withdrawls" list), or Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentType';
GO

ALTER TABLE indiana_tax.PTABOAAppeal
ADD FinalDeterminationSourceDocumentID UNIQUEIDENTIFIER NULL
        CONSTRAINT FK_PTABOAAppeal_FinalDeterminationSourceDocument FOREIGN KEY REFERENCES indiana_tax.SourceDocument(ID),
    FinalDeterminationLandAV        DECIMAL(14,2) NULL,
    FinalDeterminationImprovementAV DECIMAL(14,2) NULL,
    FinalDeterminationTotalAV       DECIMAL(14,2) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument row for the monthly Final Determination batch PDF that confirmed this appeal''s outcome, matched by (parcel, assessment year) against a real Form 115 within that batch. NULL means this appeal''s agenda-reported outcome has NOT yet been confirmed by an actual Final Determination -- do not treat DecisionStatus/AfterTotalAV as final while this is NULL; see the migration header for a real example of an agenda "Final Agreement" label that turned out to be premature.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'FinalDeterminationSourceDocumentID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Land assessed value from the actual ratified Form 115 (SECTION III: FINAL DETERMINATION), once confirmed. Compare against BeforeLandAV (the agenda''s own before-figure) -- do NOT assume this always equals AfterLandAV; the rare case where it differs is exactly the discrepancy this column exists to catch.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'FinalDeterminationLandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Improvement assessed value from the actual ratified Form 115, once confirmed. See FinalDeterminationLandAV''s comment.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'FinalDeterminationImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value (Land + Improvement) from the actual ratified Form 115, once confirmed. Compare against AfterTotalAV (the agenda''s own prediction) -- a mismatch here is a genuine "the board changed what the parties proposed" case, the specific scenario this table''s Final Determination columns exist to catch. NULL (unconfirmed) is expected for most recent appeals -- Final Determination batches lag the agenda by weeks to months.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'FinalDeterminationTotalAV';
GO
