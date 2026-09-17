/* ============================================================================
   Indiana Property Tax Expert — 12 more xSoft Engage counties as sources
   v5.58.x (companion to V202609121958 Card_History, V202609131415 StJoseph_Source,
   V202609150800 Allen_Source)

   The next wave of the intake runbook (docs/proposals/multi-county-ci-intake.md §7):
   Vanderburgh, Clark, Porter, Hendricks, DeKalb, Warrick, Knox, Shelby, Daviess,
   Randolph, Posey and Fountain -- the remaining 12 of xSoft Engage's 14 confirmed-
   working counties (Lake and St. Joseph already loaded). Same vendor, same code
   (scripts/fetch-county-prc.js / settle-county-prc.js / load-county-prc.js), a pure
   runbook re-run with no new parsing logic. CK_Assessment_ComponentSum -- land +
   improvement = total, within $1, for the authoritative sources -- is widened to
   all twelve. No other change; no data change.
   ============================================================================ */

ALTER TABLE indiana_tax.Assessment DROP CONSTRAINT CK_Assessment_ComponentSum;
GO
ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
    Source NOT IN ('MarionPRC', 'marion_foia_2026', 'LakePRC', 'StJosephPRC', 'AllenPRC',
                   'VanderburghPRC', 'ClarkPRC', 'PorterPRC', 'HendricksPRC', 'DeKalbPRC',
                   'WarrickPRC', 'KnoxPRC', 'ShelbyPRC', 'DaviessPRC', 'RandolphPRC',
                   'PoseyPRC', 'FountainPRC')
    OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
    OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1);
GO
