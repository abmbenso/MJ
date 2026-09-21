/* ============================================================================
   Indiana Property Tax Expert — CoStar-sourced Year Built.
   v5.53.x

   CountyAssessorRecord.YearBuilt (from the Tax History Report parser) covers
   3,955 Marion parcels. CoStarProperty.CoStarYearBuilt covers 1,518
   ADDITIONAL parcels where our own is null -- a real coverage boost, same
   shape as the ComparisonUnitType/Count backfill from migration
   V202608252036. Kept as its own column, never merged into YearBuilt itself
   -- same provenance-separation rule as every other CoStar{FieldName} column
   in this project (see the CoStarProperty migration, V202608252109): the two
   sources must stay distinguishable, even though the Property Search grid
   blends them for DISPLAY (own value preferred, CoStar shown as a marked
   fallback).

   Same ambiguity risk as the unit-count backfill: of 118 Marion parcels
   matched by more than one CoStarProperty row that both carry a Year Built,
   86 disagree (plausibly an original-construction year vs. a later
   addition's year, tracked as separate CoStar listings on the same parcel)
   -- backfill-costar-derived-fields.js skips those rather than guessing,
   same as it already does for ComparisonUnitType/Count.
   ============================================================================ */

ALTER TABLE indiana_tax.CountyAssessorRecord ADD CoStarYearBuilt SMALLINT NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Year built, sourced from a matched CoStarProperty row (CoStar "Year Built") -- ONLY populated when this parcel''s own YearBuilt (Tax History Report-sourced) is null and exactly one unambiguous CoStar value exists for it (see backfill-costar-derived-fields.js). Kept separate from YearBuilt rather than merged into it -- the two sources must stay distinguishable per this project''s CoStar-provenance convention. The Property Search grid''s "Year Built" column shows YearBuilt when present, this as a marked fallback otherwise.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'CoStarYearBuilt';
GO
