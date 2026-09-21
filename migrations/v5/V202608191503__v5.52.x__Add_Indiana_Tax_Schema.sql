/* ============================================================================
   Indiana Property Tax Expert — domain schema
   v5.52.x

   Introduces the indiana_tax schema: the parcel/assessment/appeal/statute/
   document model backing the Indiana property tax expert agent. Six tables:

     SourceDocument  — the fetch/verification trail for every document pulled
                        from DLGF, IBTR, county sources, or reference texts.
                        Referenced by BoardDecision, StatuteSection, and
                        PTABOAAppeal so any fact traces back to its source.
     Parcel          — one row per (CountyNumber, ParcelNumber), relatively
                        stable characteristics (address, owner, acreage...).
     Assessment      — one row per (Parcel, AssessmentYear, Source). Carries
                        BOTH the original assessed value and the PTABOA
                        (appealed) value per year, since a single year can
                        have both an original and a post-appeal determination
                        — the distinction this tool is built around.
     PTABOAAppeal    — appeal case notes (hearing date, decision status,
                        circumstances) tied to a parcel and its source agenda.
     BoardDecision   — IBTR (Indiana Board of Tax Review) decisions.
     StatuteSection  — Indiana Code Article 6-1.1 sections, chunked by
                        section number so citations resolve to exact text.

   "Form" (DLGF forms, e.g. Form 11A) and appraisal reference texts (Appraisal
   of Real Estate, USPAP) are NOT separate tables — they're SourceDocument
   rows (DocumentType = 'Form' / 'ReferenceText'). Neither has the kind of
   internal structure (a stable numbering scheme) that would justify its own
   table the way statute sections and board decisions do; a form is just a
   document, and a reference text is read as a whole, not cited by section.

   CodeGen convention (per migrations/CLAUDE.md):
     * NO __mj_CreatedAt / __mj_UpdatedAt columns — CodeGen adds + triggers them.
     * NO indexes — CodeGen auto-indexes foreign keys (auto_index_foreign_keys
       is on in mj.config.cjs).
     * sp_addextendedproperty for every non-PK column so CodeGen surfaces
       descriptions on regen (and so the AI agent's field-level context is
       populated from day one).
   ============================================================================ */

CREATE SCHEMA indiana_tax;
GO

-- ============================================================================
-- SourceDocument — fetch/verification trail for every document
-- ============================================================================
CREATE TABLE indiana_tax.SourceDocument (
    ID                 UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    DocumentType       NVARCHAR(30)     NOT NULL,
    Title              NVARCHAR(500)    NOT NULL,
    SourceURL          NVARCHAR(1000)   NULL,
    RetrievedAt        DATETIMEOFFSET   NULL,
    ContentHash        CHAR(64)         NULL,
    RawFilePath        NVARCHAR(1000)   NULL,
    ExtractedText      NVARCHAR(MAX)    NULL,
    ExtractionNotes    NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_SourceDocument PRIMARY KEY (ID),
    CONSTRAINT UQ_SourceDocument_ContentHash UNIQUE (ContentHash),
    CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
        N'BoardDecision', N'Statute', N'Form', N'ReferenceText', N'PTABOAAgenda', N'Other'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The fetch/verification trail for a document pulled from DLGF, IBTR, a county source, or a reference text. One row per unique document (deduplicated on ContentHash): where it came from, when it was retrieved, the original file on disk, and its extracted, queryable text. Every fact sourced from a document should trace back to one of these rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 11A), ReferenceText (an appraisal/USPAP reference book), PTABOAAgenda (a county appeals-board meeting agenda), or Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentType';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-readable title for the document (e.g. a case caption, a statute article name, a form name).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'Title';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The URL the document was fetched from, if it came from the web. NULL for documents entered from a local/offline source.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'SourceURL';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this document was fetched/retrieved. Distinct from any date printed on the document itself — this is about verifying when WE pulled it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'RetrievedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'SHA-256 hex digest of the raw file content. Used to detect an already-fetched document before re-downloading or re-extracting it (the dedup mechanism for the ingestion pipeline).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'ContentHash';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Local filesystem path to the original, unmodified file (PDF, HTML, etc.) as retrieved — the audit copy kept for future re-verification.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'RawFilePath';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full extracted plain text of the document, stored inline so it can be queried/searched/embedded directly without re-reading the original file.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'ExtractedText';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text notes about the extraction itself — e.g. a font-encoding problem that made the text unreliable, or that OCR was used as a fallback.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'ExtractionNotes';
GO

-- ============================================================================
-- Parcel — one row per (CountyNumber, ParcelNumber)
-- ============================================================================
CREATE TABLE indiana_tax.Parcel (
    ID                         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyNumber               SMALLINT         NOT NULL,
    ParcelNumber                NVARCHAR(30)     NOT NULL,
    GISParcelNumber            NVARCHAR(30)     NULL,
    Address                    NVARCHAR(300)    NULL,
    OwnerName                  NVARCHAR(300)    NULL,
    Acreage                    DECIMAL(12,4)    NULL,
    Zoning                     NVARCHAR(50)     NULL,
    PropertyClassCode          NVARCHAR(10)     NULL,
    CharacteristicsSourceYear  SMALLINT         NULL,
    CONSTRAINT PK_Parcel PRIMARY KEY (ID),
    CONSTRAINT UQ_Parcel_County_ParcelNumber UNIQUE (CountyNumber, ParcelNumber)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per Indiana parcel, keyed on (CountyNumber, ParcelNumber) — the statewide 17-digit parcel number. Holds relatively stable characteristics; assessed values live in Assessment, one row per year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana county number (1-92) per the DLGF/GIO statewide numbering.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'CountyNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The statewide 17-digit PARCEL_NUMBER from the DLGF/GIO Data Harvest geodatabase. Canonical identifier for the parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'ParcelNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The county''s own local parcel number (e.g. Marion County''s 7-digit number). Different counties use different local schemes; this is the crosswalk between a county-sourced file and the statewide ParcelNumber.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'GISParcelNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Site/property address.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'Address';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner of record name, as of the characteristics source year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'OwnerName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parcel acreage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'Acreage';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Zoning designation, as recorded by the county.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'Zoning';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Most recently known DLGF property class code (e.g. 300-499 for commercial/industrial). A given assessment year may record a different class code on its own Assessment row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'PropertyClassCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which DLGF/source pull (assessment year) produced the characteristics currently stored on this row. Characteristics are overwritten on a later pull, not versioned.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'CharacteristicsSourceYear';
GO

-- ============================================================================
-- Assessment — one row per (Parcel, AssessmentYear, Source)
-- ============================================================================
CREATE TABLE indiana_tax.Assessment (
    ID                      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID                UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear          SMALLINT         NOT NULL,
    Source                  NVARCHAR(50)     NOT NULL,
    PropertyClassCode       NVARCHAR(10)     NULL,
    OriginalLandAV          DECIMAL(14,2)    NULL,
    OriginalImprovementAV   DECIMAL(14,2)    NULL,
    OriginalTotalAV         DECIMAL(14,2)    NULL,
    PTABOALandAV            DECIMAL(14,2)    NULL,
    PTABOAImprovementAV     DECIMAL(14,2)    NULL,
    PTABOATotalAV           DECIMAL(14,2)    NULL,
    CONSTRAINT PK_Assessment PRIMARY KEY (ID),
    CONSTRAINT FK_Assessment_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT UQ_Assessment_Parcel_Year_Source UNIQUE (ParcelID, AssessmentYear, Source)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per (Parcel, AssessmentYear, Source) — the assessment-history table. Carries both the original assessed value and, once a PTABOA appeal is decided, the post-appeal value, so a single year can show both an original and an appealed determination.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this assessment belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment/payable year this row represents (Indiana assessments are dated January 1 of the assessment year).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Where this assessment row came from, e.g. dlgf_gdb_2025, marion_foia_2026. Identifies the data pull/vintage.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'Source';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'DLGF property class code as recorded for this specific assessment year (may differ from the parcel''s current PropertyClassCode).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'PropertyClassCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Originally assessed land value for the year, before any appeal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'OriginalLandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Originally assessed improvement value for the year, before any appeal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'OriginalImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Originally assessed total value for the year (land + improvement), before any appeal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'OriginalTotalAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Land value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'PTABOALandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Improvement value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'PTABOAImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Assessment',
    @level2type = N'COLUMN', @level2name = N'PTABOATotalAV';
GO

-- ============================================================================
-- PTABOAAppeal — appeal case notes tied to a parcel
-- ============================================================================
CREATE TABLE indiana_tax.PTABOAAppeal (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID          UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear    SMALLINT         NULL,
    HearingDate       DATE             NULL,
    DecisionStatus    NVARCHAR(50)     NULL,
    Circumstances     NVARCHAR(MAX)    NULL,
    SourceDocumentID  UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_PTABOAAppeal PRIMARY KEY (ID),
    CONSTRAINT FK_PTABOAAppeal_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_PTABOAAppeal_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A county Property Tax Assessment Board of Appeals (PTABOA) case for a parcel — a row here means an appeal was filed. Distinct from BoardDecision, which is a state-level IBTR ruling.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel under appeal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment year being appealed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the PTABOA hearing, per the agenda.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'HearingDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Outcome of the appeal (e.g. Pending, Reduced, Withdrawn, Denied), as best determined from the agenda/decision text.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'DecisionStatus';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text circumstances/notes about the appeal, extracted from the agenda.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'Circumstances';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The PTABOA agenda document this appeal was extracted from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO

-- ============================================================================
-- BoardDecision — IBTR (Indiana Board of Tax Review) decisions
-- ============================================================================
CREATE TABLE indiana_tax.BoardDecision (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CaseNumber        NVARCHAR(50)     NOT NULL,
    PetitionerName    NVARCHAR(300)    NULL,
    CountyNumber      SMALLINT         NULL,
    ParcelID          UNIQUEIDENTIFIER NULL,
    DecisionDate      DATE             NULL,
    Summary           NVARCHAR(MAX)    NULL,
    SourceDocumentID  UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_BoardDecision PRIMARY KEY (ID),
    CONSTRAINT UQ_BoardDecision_CaseNumber UNIQUE (CaseNumber),
    CONSTRAINT FK_BoardDecision_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_BoardDecision_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A ruling from the Indiana Board of Tax Review (IBTR) — the state-level appeal that follows a county PTABOA determination. This is the precedent corpus the agent searches for similar prior appeals.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'IBTR case number.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'CaseNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the petitioner (property owner who brought the appeal).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'PetitionerName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'County the case originated in.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'CountyNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this decision concerns, once matched. NULL until the case is reconciled to a known parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the IBTR issued its final determination.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'DecisionDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Short summary of the case and outcome, for quick scanning without opening the full decision text.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'Summary';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The decision PDF this row was extracted from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO

-- ============================================================================
-- StatuteSection — Indiana Code Article 6-1.1 sections
-- ============================================================================
CREATE TABLE indiana_tax.StatuteSection (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Article           NVARCHAR(20)     NOT NULL,
    SectionNumber     NVARCHAR(20)     NOT NULL,
    Title             NVARCHAR(500)    NULL,
    SectionText       NVARCHAR(MAX)    NULL,
    SourceDocumentID  UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_StatuteSection PRIMARY KEY (ID),
    CONSTRAINT UQ_StatuteSection_Article_Section UNIQUE (Article, SectionNumber),
    CONSTRAINT FK_StatuteSection_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per section of Indiana Code Title 6, Article 1.1 (property tax) or 1.5 (indiana board of tax review), chunked by section number so a citation resolves to exact text instead of a whole-article document.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana Code article number (e.g. 1.1, 1.5).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection',
    @level2type = N'COLUMN', @level2name = N'Article';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full section citation (e.g. 6-1.1-15-1).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection',
    @level2type = N'COLUMN', @level2name = N'SectionNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Section heading/title, if the source text has one.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection',
    @level2type = N'COLUMN', @level2name = N'Title';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full text of this section, for direct citation and RAG retrieval.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection',
    @level2type = N'COLUMN', @level2name = N'SectionText';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The full-article document (e.g. Article_1.1.pdf) this section was parsed out of.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'StatuteSection',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO
