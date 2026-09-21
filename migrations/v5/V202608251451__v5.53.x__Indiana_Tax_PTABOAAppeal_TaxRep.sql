/* ============================================================================
   Indiana Property Tax Expert — PTABOA Appeal representative + case number.
   v5.53.x

   The PTABOA agenda PDFs' "Name, Parcel, Case, Tax Rep & Status" table column
   carries the taxpayer's representative (a law firm, tax-advocate firm, or an
   individual) directly under the case number -- confirmed against a real
   agenda page this session. The original PTABOAAppeal migration (bulk-loaded
   from the Indiana_Assessment_Database prototype's parse_ptaboa_agendas.py /
   ptaboa_appeal table) never extracted this zone of the source text, nor did
   it retain the case number itself -- both were silently dropped, not
   genuinely absent from the source. Both are re-parsed from the SAME
   already-downloaded PDFs (zero new fetches) and the prototype's SQLite table
   + Python parser were fixed and backfilled first; this migration adds the
   two columns indiana_tax needs to receive that backfilled data via a full
   re-load of PTABOAAppeal (see scripts/reload-ptaboa-appeals.js).

   CaseNumber is added alongside TaxRepresentative because the original
   migration's lack of ANY stable per-appeal natural key is exactly what forces
   that reload to be a full wipe-and-reinsert rather than a targeted UPDATE --
   worth fixing now so a future enrichment pass doesn't hit the same problem.
   ============================================================================ */

ALTER TABLE indiana_tax.PTABOAAppeal
ADD CaseNumber NVARCHAR(50) NULL,
    TaxRepresentative NVARCHAR(200) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The PTABOA case number for this appeal/exemption record (e.g. "49-500-23-0-4-00045"), as printed on the agenda. Confirmed unique per source agenda PDF -- the natural key this table lacked before this migration.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'CaseNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Who represented the taxpayer in this matter -- a law firm, tax-advocate firm, or individual name, exactly as printed on the PTABOA agenda (e.g. "LANDMAN BEATTY, LAWYERS Attn: KATHRYN M. MERRITT-THRASHER", "JM Tax Advocates Attn: Joshua J. Malancuk"). NULL means no representative is listed on the agenda for this record -- most commonly a self-represented petitioner, not a parsing gap (confirmed 2026-08-26: ~60% of records across the currently-loaded 2024-12 through 2025-12 agendas have one).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'TaxRepresentative';
GO
