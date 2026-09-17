-- V202609162102__v5.58.x__Legal_Authority_Citation_Key_Unique.sql
-- Enforces at the database level what the loader (load-legal-authority-statute.js)
-- already enforces in application code: no two LegalAuthoritySection rows may share a
-- CitationKey. Replaces the plain, non-unique IX_LegalAuthoritySection_CitationKey
-- index (created by the original migration) with a UNIQUE constraint of the same
-- shape -- a future script bypassing the loader's own dedup logic now fails loudly
-- instead of silently duplicating a citation key.

DROP INDEX IX_LegalAuthoritySection_CitationKey ON indiana_tax.LegalAuthoritySection;
GO
ALTER TABLE indiana_tax.LegalAuthoritySection ADD CONSTRAINT UQ_LegalAuthoritySection_CitationKey UNIQUE (CitationKey);
GO
