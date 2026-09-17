/* ============================================================================
   Indiana Property Tax Expert — Elkhart County record cards as a source
   v5.58.x (companion to V202609150800 Allen_Source, the other single-static-URL
   vendor county)

   A second single-static-URL vendor (Elevate Maps' open S3 bucket, docs/
   RESEARCH_LOG.md "Elevate Maps' public S3 bucket" row in Big_Box_Retail) --
   confirmed working 2026-09-16 S0/S1 (0 fetch/parse errors on 3+20 real cards,
   every owner matching the DLGF crosswalk). Genuinely different timing from
   every county loaded so far: Elkhart's card is dated **AY2024**, one year
   BEHIND the DLGF AY2025 roster this project fetches against -- not a defect,
   a fact about the county's own publication cadence. Because Assessment rows
   are keyed per (parcel, year), this creates no conflict: AY2024/2023/2022/
   2021/2020 read 'ElkhartPRC' (County record card), AY2025 still reads
   dlgf_gdb_2025 (DLGF statewide file) because no card row exists for that
   year -- exactly the same shape Lake's AY2022-2025 vs. St. Joseph's AY2024-
   2026 windows already established. CK_Assessment_ComponentSum widened to
   'ElkhartPRC'. No other change; no data change.
   ============================================================================ */

ALTER TABLE indiana_tax.Assessment DROP CONSTRAINT CK_Assessment_ComponentSum;
GO
ALTER TABLE indiana_tax.Assessment ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
    Source NOT IN ('MarionPRC', 'marion_foia_2026', 'LakePRC', 'StJosephPRC', 'AllenPRC',
                   'VanderburghPRC', 'ClarkPRC', 'PorterPRC', 'HendricksPRC', 'DeKalbPRC',
                   'WarrickPRC', 'KnoxPRC', 'ShelbyPRC', 'DaviessPRC', 'RandolphPRC',
                   'PoseyPRC', 'FountainPRC', 'ElkhartPRC')
    OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
    OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1);
GO
