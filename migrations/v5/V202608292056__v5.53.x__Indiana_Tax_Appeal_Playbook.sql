/* ============================================================================
   Indiana Property Tax Expert — Appeal playbook: computable deadlines +
   tips/traps + per-jurisdiction deadline anchors.
   v5.53.x

   indiana_tax.AppealStage already models the 7-stage IN assessment-appeal
   chain (File Form 130 -> Preliminary Meeting -> PTABOA Determination ->
   Appeal to IBTR -> IBTR Hearing -> Tax Court -> Supreme Court), each cited
   to a StatuteSection + SourceDocument (Form 130's own "Procedure for
   Appeal of Assessment" flowchart). What it lacks, and this migration adds:

   1. AppealStage: deadline-ANCHOR columns so a rule engine can actually
      COMPUTE each stage's due date. Today Stage 1's two-June-15 rule
      (year depends on whether the Form 11 was mailed before/after May 1)
      lives only in the free-text DeadlineDescription. DeadlineAnchorEvent
      names the date that starts the clock; DeadlineBasis says how the
      deadline derives from it (anchor + DeadlineDays, a named calendar
      rule, or discretionary); DeadlineHasAgencyLapseAlt flags the stages
      where the taxpayer may also act "any time after the agency blows its
      own deadline" (Stage 3 -> IBTR at 180 days; Stage 6 -> Tax Court).

   2. AppealStage: informal-meeting + filing fields the Faegre "Appeal
      Deadline Tracking" workbook carries as first-class per-jurisdiction
      data -- InformalMeetingRequirement (IN Stage 2 = 'Required'),
      EvidenceRequiredAtFiling (IN Stage 1 = 0; AZ, by contrast, rejects
      appeals filed without substantive info), and InformalDeadlineDescription
      for states (MO, CO) where the informal step has its own deadline
      distinct from the board deadline.

   3. indiana_tax.AppealStagePlaybookNote (NEW): one row per tip / trap /
      deadline-nuance / strategy / local-practice item, replacing the single
      free-text AppealStage.Notes blob so each item is typed, individually
      citation-linked, county-scopable (NULL = statewide; 49 = Marion), and
      confidence-tagged (observed-from-data local practice starts as
      'NeedsVerification' per this project's data-integrity rule).

   4. indiana_tax.JurisdictionDeadlineAnchor (NEW): per (county, township?,
      tax year, anchor event) the observed/published date that feeds a
      RelativeDays deadline -- the "rolling deadline" shape from the
      workbook's Washington / Illinois tabs. APPEND-ONLY BY YEAR (one row
      per key; never overwrite a prior year, so YoY history is just the
      older rows). Indiana needs it too: the June 15 rule branches on the
      Form 11 mail date, so Stage 1's deadline is only knowable once that
      date is recorded here.

   NO DATA in this migration. The backfill of the 7 existing AppealStage
   rows and the ~16 seed playbook notes ship in
   Indiana_Tax_Expert/scripts/load-appeal-playbook-notes.js (same pattern as
   load-appeal-stages.js / populate-form-catalog.js). Design notes:
   Indiana_Tax_Expert/docs/proposals/appeal-playbook-structured.md.
   ============================================================================ */


/* ---------------------------------------------------------------------------
   1 + 2.  AppealStage — deadline-anchor and informal-meeting columns
   --------------------------------------------------------------------------- */
ALTER TABLE indiana_tax.AppealStage
ADD DeadlineAnchorEvent NVARCHAR(40) NULL
        CONSTRAINT CK_AppealStage_DeadlineAnchorEvent CHECK (DeadlineAnchorEvent IN (
            'Form11MailDate', 'PersonalPropertyNoticeDate', 'AppealFilingDate',
            'PTABOAOrderDate', 'IBTRFinalDeterminationDate', 'TaxCourtDeterminationDate')),
    DeadlineBasis NVARCHAR(20) NULL
        CONSTRAINT CK_AppealStage_DeadlineBasis CHECK (DeadlineBasis IN (
            'RelativeDays', 'CalendarRule', 'Discretionary')),
    DeadlineCalendarRule NVARCHAR(60) NULL,
    DeadlineHasAgencyLapseAlt BIT NOT NULL
        CONSTRAINT DF_AppealStage_DeadlineHasAgencyLapseAlt DEFAULT (0),
    InformalMeetingRequirement NVARCHAR(20) NULL
        CONSTRAINT CK_AppealStage_InformalMeetingRequirement CHECK (InformalMeetingRequirement IN (
            'Required', 'Optional', 'Recommended', 'NotOffered')),
    EvidenceRequiredAtFiling BIT NULL,
    InformalDeadlineDescription NVARCHAR(300) NULL;
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The real-world date that starts this stage''s clock: Form11MailDate, PersonalPropertyNoticeDate, AppealFilingDate (Form 130 filed), PTABOAOrderDate (PTABOA order given to the parties), IBTRFinalDeterminationDate, or TaxCourtDeterminationDate. NULL = no fixed statutory deadline runs to the taxpayer at this stage (the assessing official''s / IBTR''s own timeline governs).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'DeadlineAnchorEvent';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How the deadline derives from DeadlineAnchorEvent: RelativeDays = anchor + DeadlineDays (45 / 90 / 180 ...); CalendarRule = the named rule in DeadlineCalendarRule; Discretionary = no hard deadline (e.g. Supreme Court review).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'DeadlineBasis';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stable token a rule engine switches on when DeadlineBasis = ''CalendarRule''. Stage 1 = ''IN-Form130-June15-split-May1'': if Form11MailDate < May 1 of the assessment year the Form 130 is due June 15 of that year, else June 15 of the year tax statements are mailed (the pay year). One rule per token; the token is documented, the logic lives in code.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'DeadlineCalendarRule';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'TRUE where, in addition to the primary deadline, the statute lets the taxpayer act "any time after the agency''s own deadline lapses": Stage 3 (PTABOA misses its 180-day hearing window -> straight to IBTR) and Stage 6 (Tax Court petition may be filed once IBTR''s own decision deadline passes).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'DeadlineHasAgencyLapseAlt';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Whether this stage''s informal step is mandatory: Required / Optional / Recommended / NotOffered. Indiana Stage 2 (Preliminary Informal Meeting) = Required -- filing Form 130 obligates the assessing official to hold it. Other jurisdictions vary; this is tracked per state.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'InformalMeetingRequirement';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'TRUE only where the taxpayer must attach/submit substantive evidence AT filing to avoid rejection (e.g. AZ). Indiana Stage 1 = FALSE -- no evidence required at filing, but the exchange of available information IS required at the preliminary informal meeting (see the corresponding playbook note).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'EvidenceRequiredAtFiling';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free text for the informal step''s own deadline where one exists separately from DeadlineDays / DeadlineCalendarRule (MO, CO). Indiana = NULL: the preliminary informal meeting is auto-triggered by the Form 130 filing with no separate taxpayer date to hit.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStage', @level2type = N'COLUMN', @level2name = N'InformalDeadlineDescription';
GO


/* ---------------------------------------------------------------------------
   3.  indiana_tax.AppealStagePlaybookNote  (NEW)
   --------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.AppealStagePlaybookNote (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    AppealStageID UNIQUEIDENTIFIER NOT NULL,
    NoteKind NVARCHAR(20) NOT NULL
        CONSTRAINT CK_AppealStagePlaybookNote_NoteKind CHECK (NoteKind IN (
            'Tip', 'Trap', 'DeadlineNuance', 'Strategy', 'LocalPractice')),
    Title NVARCHAR(200) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL,
    CountyNumber SMALLINT NULL,
    StatuteSectionID UNIQUEIDENTIFIER NULL,
    CitationText NVARCHAR(100) NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    Confidence NVARCHAR(20) NOT NULL
        CONSTRAINT DF_AppealStagePlaybookNote_Confidence DEFAULT ('Verified')
        CONSTRAINT CK_AppealStagePlaybookNote_Confidence CHECK (Confidence IN ('Verified', 'NeedsVerification')),
    SortOrder INT NOT NULL CONSTRAINT DF_AppealStagePlaybookNote_SortOrder DEFAULT (0),
    CONSTRAINT PK_AppealStagePlaybookNote PRIMARY KEY (ID),
    CONSTRAINT FK_AppealStagePlaybookNote_AppealStage FOREIGN KEY (AppealStageID)
        REFERENCES indiana_tax.AppealStage (ID),
    CONSTRAINT FK_AppealStagePlaybookNote_StatuteSection FOREIGN KEY (StatuteSectionID)
        REFERENCES indiana_tax.StatuteSection (ID),
    CONSTRAINT FK_AppealStagePlaybookNote_SourceDocument FOREIGN KEY (SourceDocumentID)
        REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_AppealStagePlaybookNote_Stage  ON indiana_tax.AppealStagePlaybookNote (AppealStageID, SortOrder);
CREATE INDEX IX_AppealStagePlaybookNote_County ON indiana_tax.AppealStagePlaybookNote (CountyNumber);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One tip / trap / deadline-nuance / strategy / local-practice item attached to an appeal stage. Replaces the single free-text AppealStage.Notes blob so each item is individually typed, cited, county-scopable and confidence-tagged. Design: Indiana_Tax_Expert/docs/proposals/appeal-playbook-structured.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The indiana_tax.AppealStage row this note belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'AppealStageID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tip (use it to your advantage), Trap (a way to lose or forfeit), DeadlineNuance (a subtlety in when/how a clock runs), Strategy (a lever worth pulling), or LocalPractice (how a specific county actually operates, vs. the statewide rule).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'NoteKind';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Short headline for the note.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'Title';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The note itself.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'Body';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NULL = statewide note. A county number (49 = Marion) = the note applies only to that county, layered over the statewide stage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'CountyNumber';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Link to the indiana_tax.StatuteSection this note rests on, when one exists in the table.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'StatuteSectionID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free-text citation for when there is no StatuteSection row (e.g. "State Form 53958 instructions", "IC 6-1.1-15-1.2(k)").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'CitationText';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Optional supporting SourceDocument (a form, a memo, a decision).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Verified (grounded in a primary source) or NeedsVerification (an inference from observed data -- e.g. Marion PTABOA cadence read off loaded PTABOAAppeal rows -- not yet checked against a primary source). Per the project data-integrity rule, local-practice notes sourced from data start as NeedsVerification.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'Confidence';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Display order within a stage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AppealStagePlaybookNote', @level2type = N'COLUMN', @level2name = N'SortOrder';
GO


/* ---------------------------------------------------------------------------
   4.  indiana_tax.JurisdictionDeadlineAnchor  (NEW)
   --------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.JurisdictionDeadlineAnchor (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyNumber SMALLINT NOT NULL,
    TownshipName NVARCHAR(60) NULL,
    TaxYear SMALLINT NOT NULL,
    AnchorEvent NVARCHAR(40) NOT NULL,
    AnchorDate DATE NULL,
    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_JurisdictionDeadlineAnchor_Status DEFAULT ('Pending')
        CONSTRAINT CK_JurisdictionDeadlineAnchor_Status CHECK (Status IN (
            'Confirmed', 'Estimated', 'Pending', 'NotApplicable')),
    DerivedDeadline DATE NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_JurisdictionDeadlineAnchor PRIMARY KEY (ID),
    CONSTRAINT UQ_JurisdictionDeadlineAnchor UNIQUE (CountyNumber, TownshipName, TaxYear, AnchorEvent),
    CONSTRAINT FK_JurisdictionDeadlineAnchor_SourceDocument FOREIGN KEY (SourceDocumentID)
        REFERENCES indiana_tax.SourceDocument (ID)
);
GO
CREATE INDEX IX_JurisdictionDeadlineAnchor_Lookup
    ON indiana_tax.JurisdictionDeadlineAnchor (CountyNumber, TaxYear, AnchorEvent);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per (county, township?, tax year, anchor event) the observed/published date that feeds a DeadlineBasis = ''RelativeDays'' deadline (or branches a ''CalendarRule''). The "rolling deadline" shape used by WA and IL. APPEND-ONLY BY YEAR: one row per key, never overwrite a prior year, so year-over-year history is just the older rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The jurisdiction (Indiana county number).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'CountyNumber';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Set only when the anchor is township-level (Indiana has township assessors, and IL/WA-style rolling deadlines vary by township). NULL = county-level anchor.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'TownshipName';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The assessment / tax year this anchor applies to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'TaxYear';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Same vocabulary as AppealStage.DeadlineAnchorEvent (Form11MailDate, PTABOAOrderDate, ...).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'AnchorEvent';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The observed / published date. NULL while Status = ''Pending''.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'AnchorDate';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Confirmed (from a primary source -- set SourceDocumentID), Estimated (projected from prior years), Pending (not yet known), or NotApplicable.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'Status';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Convenience: AnchorDate resolved through the governing stage rule (anchor + offset, or the calendar-rule branch).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'DerivedDeadline';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The SourceDocument the date was taken from (a Form 11, an assessor calendar).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free-text context.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'JurisdictionDeadlineAnchor', @level2type = N'COLUMN', @level2name = N'Notes';
GO
