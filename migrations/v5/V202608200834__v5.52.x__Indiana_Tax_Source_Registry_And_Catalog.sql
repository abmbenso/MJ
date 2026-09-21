/* ============================================================================
   Indiana Property Tax Expert — source registry, document catalog, and
   document/decision date tracking
   v5.52.x

   Closes a real gap: indiana_tax.SourceDocument only records what we chose to
   fully ingest. There was no record of sources we've evaluated but decided not
   to pull from (out of scope), no per-source scan cadence/history, and no way
   to distinguish "when we fetched this" from "the date the document itself is
   dated" or "the last time we re-checked and confirmed nothing changed."

   Two new tables:
     SourceRegistry   — sources we monitor (a DLGF page, the IBTR site, a
                         statewide dataset), each with a SourceType (different
                         sources need different ingestion handling — a
                         geodatabase pull and a memo-index webpage are not the
                         same code path) and a scan cadence/history.
     DocumentCatalog   — one row per document we became AWARE of scanning a
                         registry entry, whether or not we ingested it. This is
                         the overall inventory: a skipped DLGF budget memo gets
                         a row here (IsPropertyTaxRelevant = 0, with a reason)
                         same as an ingested one — SourceDocumentID links to the
                         real row only once actually pulled in.

   Plus two date columns closing the "when" gap on documents we DO have:
     SourceDocument.DocumentDate    — the date the document itself carries
                                       (a memo's issue date, etc.), distinct
                                       from RetrievedAt (when we fetched it).
     SourceDocument.LastVerifiedAt  — updated on every re-check, even when the
                                       hash is unchanged, so "checked recently,
                                       no change" is visible and distinguishable
                                       from "haven't looked in months."
     BoardDecision.AssessmentYearsInvolved — a case can span multiple years/
                                       parcels; free text since the source data
                                       itself isn't normalized (e.g. "2019,
                                       2020, 2021").

   CodeGen convention (per migrations/CLAUDE.md): no __mj_CreatedAt/UpdatedAt
   columns (CodeGen adds + triggers them), no indexes (auto_index_foreign_keys
   handles FKs), sp_addextendedproperty on every non-PK column.
   ============================================================================ */

-- ============================================================================
-- SourceRegistry — sources we monitor
-- ============================================================================
CREATE TABLE indiana_tax.SourceRegistry (
    ID                   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Name                 NVARCHAR(200)    NOT NULL,
    SourceType           NVARCHAR(30)     NOT NULL,
    RootURL              NVARCHAR(1000)   NULL,
    IsPropertyTaxRelevant BIT             NOT NULL CONSTRAINT DF_SourceRegistry_IsPropertyTaxRelevant DEFAULT (1),
    ScanFrequency        NVARCHAR(20)     NULL,
    LastScannedAt        DATETIMEOFFSET   NULL,
    NextScanDueAt        DATETIMEOFFSET   NULL,
    LastScanNotes        NVARCHAR(MAX)    NULL,
    Notes                NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_SourceRegistry PRIMARY KEY (ID),
    CONSTRAINT UQ_SourceRegistry_Name UNIQUE (Name),
    CONSTRAINT CK_SourceRegistry_SourceType CHECK (SourceType IN (
        N'DLGF_Website', N'IBTR_Website', N'IndianaCode_Website', N'StatewideDataset',
        N'CountyDataset', N'LocalFile', N'Other')),
    CONSTRAINT CK_SourceRegistry_ScanFrequency CHECK (ScanFrequency IS NULL OR ScanFrequency IN (
        N'Monthly', N'Quarterly', N'Annual', N'OneTime', N'AdHoc'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A source we monitor for property-tax documents — a DLGF page, the IBTR site, a statewide dataset, a county FOIA feed. This is the "what exists and are we watching it" inventory; individual documents found by scanning a source are DocumentCatalog rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-readable name for the source (unique), e.g. "DLGF Memos — 2026" or "IBTR Board Decisions".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'Name';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of source this is — drives which ingestion code path applies (a statewide geodatabase pull, a website to crawl, a local file set, etc.).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'SourceType';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The base page/URL this registry entry monitors, if web-based. NULL for non-web sources (e.g. a locally-sourced dataset).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'RootURL';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this source itself is in scope for real property taxation. A source can be evaluated and marked 0 (e.g. DLGF Gateway — local government budget/TIF/debt data) so the decision to exclude it is recorded, not just absent.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'IsPropertyTaxRelevant';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How often this source should be re-scanned for new/updated documents: Monthly, Quarterly, Annual, OneTime (already fully captured, e.g. a fixed historical dataset), or AdHoc (rescanned manually as needed).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'ScanFrequency';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The last time this source was actually scanned for updates, regardless of whether anything new was found. This is the "last date researched" for the source as a whole.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'LastScannedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this source is next due for a scan, computed from LastScannedAt + ScanFrequency. Drives a "what needs attention" view without recomputing on every query.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'NextScanDueAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text outcome of the most recent scan — e.g. "3 new memos found", "no changes", or an error if the source was unreachable.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'LastScanNotes';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'General notes about this source — why it is or isn''t in scope, quirks of its structure, etc.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceRegistry',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

-- ============================================================================
-- DocumentCatalog — every document discovered scanning a SourceRegistry entry
-- ============================================================================
CREATE TABLE indiana_tax.DocumentCatalog (
    ID                    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    SourceRegistryID      UNIQUEIDENTIFIER NOT NULL,
    URL                   NVARCHAR(1000)   NOT NULL,
    Title                 NVARCHAR(500)    NULL,
    DiscoveredAt          DATETIMEOFFSET   NOT NULL CONSTRAINT DF_DocumentCatalog_DiscoveredAt DEFAULT (SYSDATETIMEOFFSET()),
    DocumentDate          DATE             NULL,
    IsPropertyTaxRelevant BIT              NULL,
    RelevanceNotes        NVARCHAR(MAX)    NULL,
    SourceDocumentID      UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_DocumentCatalog PRIMARY KEY (ID),
    CONSTRAINT UQ_DocumentCatalog_URL UNIQUE (URL),
    CONSTRAINT FK_DocumentCatalog_SourceRegistry FOREIGN KEY (SourceRegistryID) REFERENCES indiana_tax.SourceRegistry(ID),
    CONSTRAINT FK_DocumentCatalog_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per document discovered while scanning a SourceRegistry entry, whether or not it was fully ingested. This is the overall inventory of everything reviewed and considered — a document evaluated and excluded (e.g. a budget memo, not property-tax related) gets a row here same as one that was pulled in; SourceDocumentID links to the real stored document only once ingested.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which source this document was discovered on.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'SourceRegistryID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The document''s URL (or local file path for non-web sources). Unique — the catalog''s identity key for a document.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'URL';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Title/description as it appeared on the source page at discovery time.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'Title';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When we first became aware of this document (found it listed on the source), independent of whether/when it was ingested.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'DiscoveredAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The date the document itself is dated/effective, as best determined at cataloging time (e.g. a memo''s stated issue date on the index page).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'DocumentDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this document is relevant to real property taxation. NULL = not yet evaluated; 1/0 = evaluated and included/excluded.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'IsPropertyTaxRelevant';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Why this document was included or excluded — e.g. "personal property, not real property" or "budget/TIF matter, out of scope".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'RelevanceNotes';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument this catalog entry resolved to, once actually fetched and stored. NULL until ingested (or permanently, if excluded).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentCatalog',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO

-- ============================================================================
-- SourceDocument — document-date and last-verified tracking
-- ============================================================================
ALTER TABLE indiana_tax.SourceDocument ADD DocumentDate DATE NULL;
GO
ALTER TABLE indiana_tax.SourceDocument ADD LastVerifiedAt DATETIMEOFFSET NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The date the document itself is dated/effective (a memo''s issue date, a decision''s date) — distinct from RetrievedAt, which is when WE fetched it. NULL where the document has no single clear date (e.g. a multi-year-cycle reference text).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The last time this exact document was re-checked, whether or not the content had changed (RetrievedAt only updates on a real change). Updated on every scan so "checked recently, unchanged" is distinguishable from "not looked at in months."',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'LastVerifiedAt';
GO

-- ============================================================================
-- BoardDecision — which assessment year(s) a case concerns
-- ============================================================================
ALTER TABLE indiana_tax.BoardDecision ADD AssessmentYearsInvolved NVARCHAR(200) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text assessment year(s) this decision concerns, e.g. "2019, 2020, 2021" — a single IBTR case can span multiple years and even multiple parcels, so this isn''t normalized to a single year column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'BoardDecision',
    @level2type = N'COLUMN', @level2name = N'AssessmentYearsInvolved';
GO
