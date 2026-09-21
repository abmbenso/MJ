/* ============================================================================
   Indiana Property Tax Expert — CoStar-sourced Rentable Building Area (RBA).
   v5.53.x

   Mirrors CoStarYearBuilt (migration V202608252206) exactly -- same
   provenance-separation reasoning (kept distinct from EstimatedSqFt, which
   is a DIFFERENT physical measurement: total building SF from the PRC/
   Marion ArcGIS layer, not the rentable/leasable area CoStar's own RBA field
   represents), same ambiguity-aware backfill approach.

   Investigated live before writing this: of 1,922 single-parcel CoStarProperty
   matches carrying RBA, 102 parcels are matched by more than one such row,
   and 95 of those disagree on the RBA value -- backfill-costar-derived-
   fields.js's existing per-parcel grouping + skip-if-ambiguous logic (already
   proven on Units/Key/Year Built) extends to this with a third pass, no new
   logic needed.
   ============================================================================ */

ALTER TABLE indiana_tax.CountyAssessorRecord ADD CoStarRBA INT NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Rentable Building Area, sourced from a matched CoStarProperty row (CoStar "RBA") -- ONLY populated when exactly one unambiguous CoStar value exists for this parcel across its single-parcel-matched CoStarProperty rows (see backfill-costar-derived-fields.js). Distinct from EstimatedSqFt (total building SF from the PRC/ArcGIS layer) -- RBA is the rentable/leasable measure, a different physical quantity, not just a different source for the same number. Never merged into EstimatedSqFt.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'CoStarRBA';
GO
