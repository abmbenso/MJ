/* ============================================================================
   Indiana Property Tax Expert — appeal lifecycle (stage-by-stage) tracking
   v5.52.x

   Normalizes the appeal lifecycle map from Form 130's instructions (page 3,
   "Procedure for Appeal of Assessment") into queryable stages instead of
   leaving it embedded in SourceDocument.ExtractedText. Each stage carries its
   level in the appeal hierarchy, who acts, what form is required, the
   deadline, and links to the exact statute sections that govern it.

   The hierarchy matters and is captured explicitly via AppealLevel: the
   initial appeal is at the COUNTY level (PTABOA); if pursued further it goes
   to the STATE level (IBTR), whose determinations are afforded deference and
   are what the Indiana Tax Court reviews; the Tax Court's own determination
   can, discretionarily, go to the Indiana Supreme Court.

   This is deliberately the STATEWIDE standard procedure — CountyNumber is
   included but left NULL on every row populated now (NULL = statewide
   default). Local practice can vary by county; the column exists so a future
   county-specific variant/note can be added as its own row without another
   migration, not because we're populating any yet.

   AppealStageStatute is a separate junction (not a single citation column)
   because a stage commonly cites multiple sections, and because
   StatuteSectionID resolves at the SECTION level while flowchart citations
   are often to specific SUBSECTIONS within a section (e.g. "(d)-(g), (l)") —
   SubsectionReference carries that without requiring StatuteSection to be
   subsection-granular. CitationText is always populated (the raw citation as
   written) even when StatuteSectionID can't resolve — e.g. IC 33-26-6-7,
   Title 33 (courts), outside the Title 6 statutes this schema has ingested.
   ============================================================================ */

CREATE TABLE indiana_tax.AppealStage (
    ID                   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StageOrder           INT              NOT NULL,
    StageName            NVARCHAR(200)    NOT NULL,
    AppealLevel          NVARCHAR(30)     NOT NULL,
    ResponsibleParty     NVARCHAR(50)     NULL,
    Description          NVARCHAR(MAX)    NOT NULL,
    FormRequired         NVARCHAR(50)     NULL,
    DeadlineDescription  NVARCHAR(MAX)    NULL,
    DeadlineDays         INT              NULL,
    CountyNumber         SMALLINT         NULL,
    SourceDocumentID     UNIQUEIDENTIFIER NULL,
    Notes                NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_AppealStage PRIMARY KEY (ID),
    CONSTRAINT FK_AppealStage_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_AppealStage_AppealLevel CHECK (AppealLevel IN (
        N'County-PTABOA', N'State-IBTR', N'State-TaxCourt', N'State-SupremeCourt'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One stage in the Indiana real property tax appeal lifecycle (statewide standard procedure). Normalized from Form 130''s "Procedure for Appeal of Assessment" instructions so the sequence, deadlines, and governing statutes are queryable rather than embedded in document text.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sequence position in the normal-path appeal lifecycle (1 = first stage). Conditional escalation paths (e.g. skipping ahead if PTABOA misses its hearing deadline) are captured in Notes on the relevant stage, not as separate branching rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'StageOrder';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Short name for the stage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'StageName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Where in the appeal hierarchy this stage sits: County-PTABOA (the initial, county-level appeal), State-IBTR (state board, afforded deference to its factual determinations), State-TaxCourt (reviews IBTR determinations), or State-SupremeCourt (discretionary review of Tax Court determinations).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'AppealLevel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Who acts at this stage (e.g. Taxpayer, Assessing Official, PTABOA, IBTR, Tax Court, Supreme Court).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'ResponsibleParty';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What happens at this stage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'Description';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The DLGF form required to act at this stage, if any (e.g. Form 130, Form 134, Form 131).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'FormRequired';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full deadline rule in prose — often conditional (varies by mailing date, property type, etc.), which is why this is text rather than only a day count.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'DeadlineDescription';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A single day-count figure when the deadline reduces to one cleanly (e.g. 45, 180, 90) — NULL when the real rule is conditional and a single number would be misleading; see DeadlineDescription for the full rule either way.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'DeadlineDays';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'NULL = statewide standard procedure (every row populated so far). Reserved for a future county-specific variant of this stage, since local practice can differ by county — a county override would be its own row with this set, not an edit to the statewide row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'CountyNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The document this stage was extracted from (e.g. Form 130''s instructions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text notes — standard of review, burden of proof, escalation conditions, or other context that doesn''t fit a structured column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStage',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

-- ============================================================================
-- AppealStageStatute — statutes governing each stage
-- ============================================================================
CREATE TABLE indiana_tax.AppealStageStatute (
    ID                   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    AppealStageID        UNIQUEIDENTIFIER NOT NULL,
    StatuteSectionID     UNIQUEIDENTIFIER NULL,
    CitationText         NVARCHAR(100)    NOT NULL,
    SubsectionReference  NVARCHAR(50)     NULL,
    CONSTRAINT PK_AppealStageStatute PRIMARY KEY (ID),
    CONSTRAINT FK_AppealStageStatute_AppealStage FOREIGN KEY (AppealStageID) REFERENCES indiana_tax.AppealStage(ID),
    CONSTRAINT FK_AppealStageStatute_StatuteSection FOREIGN KEY (StatuteSectionID) REFERENCES indiana_tax.StatuteSection(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A statute citation governing an AppealStage. StatuteSectionID resolves when we''ve ingested that section (Title 6 Articles 1.1/1.5); NULL when the citation is outside that scope (e.g. IC 33-26-6-7, Title 33). CitationText is always populated regardless, so the raw citation is never lost to a missing join.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStageStatute';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The stage this citation governs.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStageStatute',
    @level2type = N'COLUMN', @level2name = N'AppealStageID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The matching StatuteSection row, if the cited section is one we''ve ingested (Title 6 Articles 1.1/1.5 only).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStageStatute',
    @level2type = N'COLUMN', @level2name = N'StatuteSectionID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The citation exactly as written on the source document, e.g. "IC 6-1.1-15-1.2(d)-(g), (l)".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStageStatute',
    @level2type = N'COLUMN', @level2name = N'CitationText';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The specific subsection(s) cited within the section, e.g. "(d)-(g), (l)" — StatuteSection is section-granular, not subsection-granular, so this carries the finer reference the flowchart actually makes.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealStageStatute',
    @level2type = N'COLUMN', @level2name = N'SubsectionReference';
GO
