/* ============================================================================
   Indiana Property Tax Expert — Document Acquisition tracker
   v5.53.x

   Closes a real gap surfaced while diagnosing Marion County Tax History
   Report fetch reliability: the only record of an acquisition attempt --
   how many times we tried, what failed, whether it eventually succeeded --
   lived in console output and in-memory script counters. A parcel that
   permanently failed was silently skipped on the next resumable run with no
   queryable trace anywhere that we'd ever tried.

   indiana_tax.DocumentAcquisition is the mechanical, high-volume, per-subject
   fetch-with-retry bookkeeping layer -- distinct from three tables that
   already exist in this space and are NOT being changed here:
     SourceRegistry / DocumentCatalog -- editorial discovery of unstructured
                                          documents (memos, decisions) found
                                          scanning an index page.
     ResearchTask                     -- a small number of deliberately
                                          deferred research DECISIONS ("we
                                          looked into this and chose not to
                                          pursue it"), not mechanical fetch
                                          state.
   One row per (Parcel, DocumentType) being mechanically fetched.

   KEY-SHAPE DECISION: the business key is (ParcelID, DocumentType), NOT
   (ParcelID, DocumentType, AssessmentYear). Marion's PRC/Tax History
   endpoints don't take a year parameter -- you get whichever report is
   currently on file, and the year is only known AFTER a successful parse.
   Keying on a value that doesn't exist yet at first-attempt time would break
   the upsert. AssessmentYear is still tracked, per the original ask, as an
   OBSERVED-RESULT column: NULL until first success, then reflects the most
   recently succeeded fetch -- the same "latest known good" model
   CountyAssessorRecord's own SourceDocumentID/TaxHistorySourceDocumentID
   pointers already use. This table is written ALONGSIDE those pointers in
   the same transaction (both get the same SourceDocument.ID on success); it
   does not replace or back-fill them.

   DocumentType's CHECK is a DELIBERATE SUBSET of SourceDocument.DocumentType
   -- only the two mechanically-fetched, per-parcel types that exist today
   (both require a ParcelID, which SourceDocument's other types like Memo/
   Statute/BoardDecision don't naturally have). Extending to a future
   mechanical source is a two-line CHECK swap.

   RETRY/ESCALATION POLICY (grounded in a live diagnostic 2026-08-24: 39/40
   parcels recovered a "bad XRef entry" corrupted Tax History PDF within 8
   inner HTTP retries, never later):
     - AttemptCount counts OUTER, script-run-level attempts (each of which
       already wraps up to 8 inner HTTP retries via the fetch script's
       withRetry) -- not inner retries.
     - Escalation ceiling: 3 outer attempts (worst case ~24 total HTTP
       attempts spread across up to 3 resumable runs) before flipping to
       Status='NeedsReview' + EscalatedAt -- deliberately generous given how
       much retrying was needed even for cases that did eventually succeed.
     - A failure below the ceiling sets Status='Failed',
       NextAttemptDueAt = now + 1 hour, a modest cooldown so a resumable run
       kicked off minutes later doesn't immediately re-hammer a struggling
       endpoint.
     - NeedsReview rows are excluded from the bulk fetch script's normal
       candidate query -- escalated parcels stop being silently retried
       forever and instead surface for deliberate follow-up ("until it is
       successful", without spinning indefinitely on a genuine anomaly).

   NAMING CONVENTION: SubjectKey mirrors the file-naming grammar already
   used by the fetch script's slugFromParcelC() -- e.g. "marion_prc_8050459"
   before first success, "marion_prc_8050459_2026" after -- so a person can
   eyeball a tracker row, a SourceDocument.RawFilePath, and a file on disk
   and see they're the same subject at a glance. It is informational/indexed,
   NOT the real uniqueness key (it legitimately changes once the year becomes
   known). Full grammar documented in
   /Users/abebenson/Projects/Indiana_Tax_Expert/docs/NAMING_AND_RETENTION.md.

   RETENTION POLICY (already exists via SourceDocument, stated explicitly
   here rather than left implicit): SourceDocument.ContentHash-based dedup
   keeps every distinct byte-content forever -- a new row per genuine content
   change, old rows and their files never touched or overwritten. An
   unchanged re-fetch only bumps LastVerifiedAt (zero row growth). A
   permanently-failing fetch produces ZERO new SourceDocument rows (nothing
   to store) until it eventually succeeds. Growth is bounded by genuine
   content changes, not by fetch/retry frequency.

   CodeGen convention (per migrations/CLAUDE.md): no __mj_CreatedAt/UpdatedAt
   columns (CodeGen adds + triggers them), no manual indexes (CodeGen's
   auto_index_foreign_keys handles FKs), sp_addextendedproperty on every
   non-PK/FK column, indiana_tax. hardcoded directly (not
   ${flyway:defaultSchema}, matching every prior migration in this project).
   ============================================================================ */

CREATE TABLE indiana_tax.DocumentAcquisition (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID          UNIQUEIDENTIFIER NOT NULL,
    DocumentType      NVARCHAR(30)     NOT NULL,
    SubjectKey        NVARCHAR(150)    NOT NULL,
    AssessmentYear    SMALLINT         NULL,
    Status            NVARCHAR(20)     NOT NULL CONSTRAINT DF_DocumentAcquisition_Status DEFAULT (N'InProgress'),
    AttemptCount      INT              NOT NULL CONSTRAINT DF_DocumentAcquisition_AttemptCount DEFAULT (0),
    FirstAttemptedAt  DATETIMEOFFSET   NOT NULL CONSTRAINT DF_DocumentAcquisition_FirstAttemptedAt DEFAULT (SYSDATETIMEOFFSET()),
    LastAttemptedAt   DATETIMEOFFSET   NOT NULL CONSTRAINT DF_DocumentAcquisition_LastAttemptedAt DEFAULT (SYSDATETIMEOFFSET()),
    LastSucceededAt   DATETIMEOFFSET   NULL,
    LastErrorCode     NVARCHAR(100)    NULL,
    LastErrorMessage  NVARCHAR(500)    NULL,
    NextAttemptDueAt  DATETIMEOFFSET   NULL,
    EscalatedAt       DATETIMEOFFSET   NULL,
    SourceDocumentID  UNIQUEIDENTIFIER NULL,
    Notes             NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_DocumentAcquisition PRIMARY KEY (ID),
    CONSTRAINT UQ_DocumentAcquisition_Parcel_DocumentType UNIQUE (ParcelID, DocumentType),
    CONSTRAINT FK_DocumentAcquisition_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_DocumentAcquisition_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_DocumentAcquisition_DocumentType CHECK (DocumentType IN (
        N'PropertyRecordCard', N'TaxHistoryReport')),
    CONSTRAINT CK_DocumentAcquisition_Status CHECK (Status IN (
        N'InProgress', N'Succeeded', N'Failed', N'NeedsReview'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The mechanical, high-volume, per-subject fetch-with-retry acquisition tracker: one row per (Parcel, DocumentType) being fetched from a source that requires HTTP retries and can fail. Tracks attempt count, last error, retry timing, and escalation to human review after repeated failure -- the "what has been / needs to be researched, when, was it successful, and until it is" ledger. Distinct from SourceRegistry/DocumentCatalog (editorial discovery of unstructured documents) and ResearchTask (deliberately deferred research decisions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this acquisition tracks a document for.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which document type is being fetched for this parcel -- a deliberate subset of SourceDocument.DocumentType (only the mechanically-fetched, per-parcel types: PropertyRecordCard, TaxHistoryReport). Together with ParcelID, the real uniqueness key.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'DocumentType';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-legible slug mirroring the on-disk file-naming grammar (e.g. "marion_prc_8050459_2026"), so a tracker row, a SourceDocument.RawFilePath, and a file on disk can be visually correlated. Informational/indexed only -- NOT the uniqueness key, since it legitimately changes once AssessmentYear becomes known from a successful fetch. See docs/NAMING_AND_RETENTION.md in the Indiana_Tax_Expert repo for the full grammar.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'SubjectKey';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessment year of the most recently successfully fetched document for this (Parcel, DocumentType). NULL until first success -- not knowable before then, since these endpoints don''t take a year parameter; you get whichever report is currently on file.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'InProgress (never yet resolved) / Succeeded (current SourceDocumentID is valid and current) / Failed (most recent attempt failed, eligible for retry at NextAttemptDueAt) / NeedsReview (failed AttemptCount times at or beyond the escalation ceiling -- excluded from automatic retry, needs deliberate follow-up).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'Status';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Count of OUTER (script-run-level) acquisition attempts -- each of which already wraps up to 8 inner HTTP retries internally. Escalates Status to NeedsReview once this reaches 3.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'AttemptCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this (Parcel, DocumentType) was first attempted.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'FirstAttemptedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this (Parcel, DocumentType) was most recently attempted, successful or not.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'LastAttemptedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this (Parcel, DocumentType) was most recently successfully fetched and parsed. NULL if never successful.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'LastSucceededAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Short machine-oriented error identifier from the most recent failed attempt (e.g. "bad XRef entry", "not a PDF", "HTTP 500"). Cleared on success.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'LastErrorCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full error message from the most recent failed attempt. Cleared on success.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'LastErrorMessage';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Earliest time a bulk fetch run should retry this (Parcel, DocumentType) again, after a failure below the escalation ceiling. NULL once Succeeded or NeedsReview (nothing more to schedule).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'NextAttemptDueAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When Status flipped to NeedsReview (AttemptCount reached the escalation ceiling). NULL unless currently or previously escalated.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'EscalatedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument produced by the most recent successful fetch. NULL until Succeeded at least once. Mirrors (does not replace) CountyAssessorRecord.SourceDocumentID/TaxHistorySourceDocumentID, which are set to the same value in the same transaction.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text notes -- e.g. a manual explanation of why a NeedsReview row was set back to Failed for another retry attempt.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'DocumentAcquisition',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO
