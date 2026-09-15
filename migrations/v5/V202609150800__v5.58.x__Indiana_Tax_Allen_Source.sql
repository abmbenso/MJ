/* ============================================================================
   Indiana Property Tax Expert — Allen County record cards as a source
   v5.58.x (companion to V202609121958 Indiana_Tax_Card_History,
   V202609131415 Indiana_Tax_StJoseph_Source)

   The third county loaded from its own record cards (intake runbook,
   Indiana_Tax_Expert/docs/proposals/multi-county-ci-intake.md §7): every
   Allen C&I parcel loads as Assessment.Source = 'AllenPRC', the county-card
   pattern set by 'LakePRC'/'StJosephPRC'. CK_Assessment_ComponentSum --
   land + improvement = total, within $1, for the authoritative sources --
   is widened to it. No other change; no data change.

   Allen's own vendor (acimap.us) is genuinely different from the xSoft
   Engage counties: one static, year-less URL per parcel rather than a
   per-year document list, so there is no independent prior-year snapshot --
   only the current card's own multi-column Valuation Records table
   (scripts/lib/acimap.js). This migration does not change that; it is the
   same CHECK widening every prior county-card source got.
   ============================================================================ */

ALTER TABLE indiana_tax.Assessment DROP CONSTRAINT CK_Assessment_ComponentSum;
GO
ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
    Source NOT IN ('MarionPRC', 'marion_foia_2026', 'LakePRC', 'StJosephPRC', 'AllenPRC')
    OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
    OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1);
GO
