/* ============================================================================
   Indiana Property Tax Expert — PTABOA Appeal record kind + form type.
   v5.53.x

   Every PTABOA agenda page is headed "For Appeal <form> Year: <year>" or
   "For Exemption <form> Year: <year>" -- already parsed into the
   Indiana_Assessment_Database prototype's SQLite ptaboa_appeal table as
   record_kind ('Appeal'/'Exemption') and appeal_type ('130S'/'130O'/'136'/
   '136C') since the very first version of parse_ptaboa_agendas.py. Like
   CaseNumber/TaxRepresentative (V202608251451) and the Before/After AV
   figures (V202608251518) before it, this was silently dropped by the
   original bulk migration into indiana_tax.PTABOAAppeal -- no new parsing
   needed, only a reload from the same already-populated SQLite table.

   Confirmed 2026-08-26: the distinction matters for analytics, not just
   description. A Form 136/136C Exemption decision answers "is this property
   tax-exempt" (a binary charitable/nonprofit-status question) -- it is NOT
   informative about whether a sub class's ASSESSED VALUE is too high, and
   folding Exemption records into a valuation win-rate/reduction rollup
   skews those numbers (many Exemption cases are "Requested 100% Allowed
   100%", which reads as a huge "reduction" without meaning anything about
   assessed value accuracy). Form 130O (objective/mathematical error) and
   130S (subjective/market-value dispute) are the two REAL valuation-appeal
   types; 130S is specifically what most directly speaks to whether a sub
   class's typical assessed value holds up.
   ============================================================================ */

ALTER TABLE indiana_tax.PTABOAAppeal
ADD RecordKind NVARCHAR(20) NULL,
    AppealType NVARCHAR(20) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this record is a valuation Appeal or an Exemption request, per the agenda page''s own "For Appeal/Exemption <form> Year: <year>" header. NOT the same question as DecisionStatus (which appeal/exemption records can both carry, e.g. "Exemption-Approved" vs "Final Agreement") -- this is the request TYPE, DecisionStatus is the outcome.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'RecordKind';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Indiana form number this record was filed under, e.g. "130S" (subjective/market-value valuation appeal -- the most directly informative type for sub-class assessed-value analytics), "130O" (objective/mathematical-error valuation appeal), "136" or "136C" (charitable/nonprofit exemption request -- NOT a valuation dispute; exclude from win-rate/avg-reduction rollups meant to describe assessed-value accuracy).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'AppealType';
GO
