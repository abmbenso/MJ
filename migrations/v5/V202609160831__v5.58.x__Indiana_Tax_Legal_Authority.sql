-- V202609160831__v5.58.x__Indiana_Tax_Legal_Authority.sql
-- New LegalAuthority schema: statute, 50 IAC, the Real Property Assessment Manual,
-- DLGF Guidelines, IBTR/Tax Court procedural rules, DLGF Forms, DLGF memos, and county
-- ratio-study narratives. Parallel to the existing IBTRAppeal/IBTRDecision* tables --
-- untouched by this migration -- per docs/proposals/legal-research-tool-design.md.

CREATE TABLE indiana_tax.LegalAuthority (
    ID              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    SourceType      NVARCHAR(30)     NOT NULL,
    Forum           NVARCHAR(20)     NULL,
    Title           NVARCHAR(300)    NOT NULL,
    AsOfDate        DATE             NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    SourceURL       NVARCHAR(1000)   NULL,
    CONSTRAINT PK_LegalAuthority PRIMARY KEY (ID),
    CONSTRAINT FK_LegalAuthority_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_LegalAuthority_SourceType CHECK (SourceType IN (N'Statute', N'AdminRule', N'Manual', N'Guideline', N'ProceduralRule', N'Form', N'Memo', N'RatioStudyNarrative')),
    CONSTRAINT CK_LegalAuthority_Forum CHECK (Forum IS NULL OR Forum IN (N'IBTR', N'TaxCourt'))
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One titled legal-authority document or edition -- an Indiana Code article, a 50 IAC article, the Real Property Assessment Manual, a specific DLGF Guidelines edition, IBTR or Tax Court Rules of Procedure, a specific DLGF Form, a DLGF memo, or one county''s ratio-study narrative. Current text only; no historical versioning.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Statute | AdminRule | Manual | Guideline | ProceduralRule | Form | Memo | RatioStudyNarrative.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'SourceType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'IBTR or TaxCourt, set only when SourceType = ProceduralRule.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'Forum';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Human-readable title, e.g. "Indiana Code Title 6, Article 1.1 -- Property Taxation" or "Real Property Assessment Manual".', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'Title';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The edition/publication date this text is current as of; NULL when unknown.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'AsOfDate';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The fetched source file (PDF/HTML) this document was parsed from, for provenance.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'SourceDocumentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The authoritative URL this document was retrieved from, for direct citation linking.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthority', @level2type=N'COLUMN', @level2name=N'SourceURL';
GO

CREATE TABLE indiana_tax.LegalAuthoritySection (
    ID              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    LegalAuthorityID UNIQUEIDENTIFIER NOT NULL,
    ParentSectionID UNIQUEIDENTIFIER NULL,
    SectionLevel    NVARCHAR(20)     NOT NULL,
    SectionNumber   NVARCHAR(60)     NOT NULL,
    CitationKey     NVARCHAR(120)    NOT NULL,
    Heading         NVARCHAR(500)    NULL,
    FullText        NVARCHAR(MAX)    NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    SourceURL       NVARCHAR(1000)   NULL,
    CONSTRAINT PK_LegalAuthoritySection PRIMARY KEY (ID),
    CONSTRAINT FK_LegalAuthoritySection_LegalAuthority FOREIGN KEY (LegalAuthorityID) REFERENCES indiana_tax.LegalAuthority(ID),
    CONSTRAINT FK_LegalAuthoritySection_Parent FOREIGN KEY (ParentSectionID) REFERENCES indiana_tax.LegalAuthoritySection(ID),
    CONSTRAINT FK_LegalAuthoritySection_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_LegalAuthoritySection_Level CHECK (SectionLevel IN (N'Article', N'Chapter', N'Section', N'Part', N'Rule', N'Form'))
);
GO
CREATE INDEX IX_LegalAuthoritySection_CitationKey ON indiana_tax.LegalAuthoritySection(CitationKey);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One hierarchical unit within a LegalAuthority document -- an article, chapter, or leaf section/part/rule/form. Grouping rows (Article, Chapter) typically have NULL FullText; leaf rows carry the actual text.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The parent LegalAuthority document this section belongs to.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'LegalAuthorityID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The enclosing section (a Section''s parent is a Chapter, a Chapter''s parent is an Article); NULL for a top-level Article/Form/Rule.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'ParentSectionID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Article | Chapter | Section | Part | Rule | Form -- what kind of hierarchical unit this row is.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'SectionLevel';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The source''s own numbering, e.g. "1.1", "6-1.1-1", "6-1.1-1-1", "27-2-2", "Rule 3".', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'SectionNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Normalized full citation, e.g. "IC 6-1.1-15-17.2" or "50 IAC 26-2-2" -- matches IBTRDecisionCitation.CiteKey''s format so a decision''s citation resolves by string equality.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'CitationKey';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The section''s short title/caption, e.g. "Applicability".', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'Heading';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The section''s full text, verbatim. NULL for grouping-only rows (Article/Chapter).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'FullText';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The fetched source file this section was parsed from, for provenance.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'SourceDocumentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A deep link to this specific section at its source, where the source supports anchors.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthoritySection', @level2type=N'COLUMN', @level2name=N'SourceURL';
GO

CREATE TABLE indiana_tax.LegalAuthorityChunk (
    ID              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    LegalAuthoritySectionID UNIQUEIDENTIFIER NOT NULL,
    Ordinal         INT              NOT NULL,
    ChunkText       NVARCHAR(MAX)    NOT NULL,
    TokenCount      INT              NULL,
    CONSTRAINT PK_LegalAuthorityChunk PRIMARY KEY (ID),
    CONSTRAINT FK_LegalAuthorityChunk_Section FOREIGN KEY (LegalAuthoritySectionID) REFERENCES indiana_tax.LegalAuthoritySection(ID),
    CONSTRAINT CK_LegalAuthorityChunk_Ordinal CHECK (Ordinal >= 0)
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A passage of a LegalAuthoritySection''s text for retrieval. The Search Scope for legal-authority search points here.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthorityChunk';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The section this chunk was cut from.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthorityChunk', @level2type=N'COLUMN', @level2name=N'LegalAuthoritySectionID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'0-based order of this chunk within its section.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthorityChunk', @level2type=N'COLUMN', @level2name=N'Ordinal';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The chunk''s text.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthorityChunk', @level2type=N'COLUMN', @level2name=N'ChunkText';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Approximate token count (chars / 4), matching IBTRDecisionChunk''s convention.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'LegalAuthorityChunk', @level2type=N'COLUMN', @level2name=N'TokenCount';
GO

ALTER TABLE indiana_tax.IBTRDecisionCitation ADD ResolvedLegalAuthoritySectionID UNIQUEIDENTIFIER NULL;
GO
ALTER TABLE indiana_tax.IBTRDecisionCitation ADD CONSTRAINT FK_IBTRDecisionCitation_ResolvedLegalAuthoritySection FOREIGN KEY (ResolvedLegalAuthoritySectionID) REFERENCES indiana_tax.LegalAuthoritySection(ID);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The LegalAuthoritySection this citation''s CiteKey resolves to, where a match exists (statute/rule cites only -- case citations are out of scope for this column).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'ResolvedLegalAuthoritySectionID';
GO
