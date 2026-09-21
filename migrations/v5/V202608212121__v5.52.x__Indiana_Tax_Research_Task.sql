/* ============================================================================
   Indiana Property Tax Expert — open research task tracking
   v5.52.x

   A running paper trail of research directions that were identified,
   evaluated, and deliberately deferred — too large to pursue immediately, or
   needing a scope decision before starting. Distinct from SourceRegistry
   (sources we monitor) and DocumentCatalog (documents reviewed, in or out of
   scope): this tracks TASKS/DECISIONS, not sources or documents, though a
   task commonly references one of each. The point is that "we looked into
   this and chose not to pursue it yet" is recorded with a reason, the same
   way DocumentCatalog records a deliberate exclusion rather than a silent
   gap — so nothing gets rediscovered from scratch, and nothing gets lost.
   ============================================================================ */

CREATE TABLE indiana_tax.ResearchTask (
    ID                       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Title                    NVARCHAR(200)    NOT NULL,
    Description              NVARCHAR(MAX)    NOT NULL,
    Status                   NVARCHAR(20)     NOT NULL CONSTRAINT DF_ResearchTask_Status DEFAULT (N'Deferred'),
    DeferralReason           NVARCHAR(MAX)    NULL,
    RelatedSourceRegistryID  UNIQUEIDENTIFIER NULL,
    RelatedSourceDocumentID  UNIQUEIDENTIFIER NULL,
    RaisedAt                 DATETIMEOFFSET   NOT NULL CONSTRAINT DF_ResearchTask_RaisedAt DEFAULT (SYSDATETIMEOFFSET()),
    RevisitAt                DATE             NULL,
    Notes                    NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_ResearchTask PRIMARY KEY (ID),
    CONSTRAINT FK_ResearchTask_SourceRegistry FOREIGN KEY (RelatedSourceRegistryID) REFERENCES indiana_tax.SourceRegistry(ID),
    CONSTRAINT FK_ResearchTask_SourceDocument FOREIGN KEY (RelatedSourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_ResearchTask_Status CHECK (Status IN (
        N'Open', N'Deferred', N'InProgress', N'Completed', N'Abandoned'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A research direction identified, evaluated, and tracked — most often deliberately deferred (too large to pursue immediately, or needing a scope decision) rather than silently dropped. The paper trail for "we looked into this and chose not to pursue it yet," distinct from SourceRegistry (sources monitored) and DocumentCatalog (documents reviewed).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Short name for the task.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'Title';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What this task is — what was found, what it would take to pursue it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'Description';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Open (identified, not yet evaluated further) / Deferred (evaluated, deliberately held) / InProgress / Completed / Abandoned (evaluated and decided not worth pursuing at all, distinct from Deferred).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'Status';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Why this is being held rather than pursued now — e.g. scale, needs a scope decision, needs tooling not yet built, needs a source spec not yet found.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'DeferralReason';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceRegistry entry this task concerns, if any.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'RelatedSourceRegistryID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument this task concerns, if any (e.g. a spec document that unblocks the task once found).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'RelatedSourceDocumentID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this task was first identified.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'RaisedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A natural date to reconsider this task, if there is one (e.g. a next annual data cycle). NULL means "revisit whenever it becomes a priority," not "no need to revisit."',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'RevisitAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text running notes — updated as understanding of the task evolves.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'ResearchTask',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO
