/* ============================================================================
   Indiana Property Tax Expert -- Washington County (88) as a record-card source
   v5.58.x (companion to V202609160800 XSoft_Wave2_Sources, V202609160830 Elkhart_Source)

   Washington was found on xSoft Engage's public card archive by the scripted S0
   route sweep of 2026-09-21 and passed its S1 pilot the same day (20 parcels /
   60 cards, AY2024-2026; docs/proposals/multi-county-ci-intake.md §7, §12.5;
   Indiana_Tax_Expert data/county_intake/washington/PILOT_FINDINGS.md). Same
   vendor and code as the 14 xSoft counties already loaded. CK_Assessment_ComponentSum
   -- land + improvement = total, within $1, for the authoritative sources -- is
   widened to 'WashingtonPRC'. No other change; no data change.
   ============================================================================ */

ALTER TABLE indiana_tax.Assessment DROP CONSTRAINT CK_Assessment_ComponentSum;
GO
ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
    Source NOT IN ('MarionPRC', 'marion_foia_2026', 'LakePRC', 'StJosephPRC', 'AllenPRC',
                   'VanderburghPRC', 'ClarkPRC', 'PorterPRC', 'HendricksPRC', 'DeKalbPRC',
                   'WarrickPRC', 'KnoxPRC', 'ShelbyPRC', 'DaviessPRC', 'RandolphPRC',
                   'PoseyPRC', 'FountainPRC', 'ElkhartPRC', 'WashingtonPRC')
    OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
    OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1);
GO
