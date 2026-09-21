/* ============================================================================
   Indiana Property Tax Expert — PropertyClassMap.StatutoryGroup
   v5.56.x

   Adds the DLGF *statutory* class alongside the existing valuation TypeGroup.
   Design + rationale: docs/proposals/property-class-map-statewide.md.

   Why a second column rather than widening TypeGroup:

   TypeGroup is a VALUATION taxonomy (Retail / Office / Industrial / Multifamily
   / Hospitality / Land / Special / Parking / Other). It exists to build
   comparable pools for C&I appeal work and it deliberately files single-family
   under 'Other' -- "outside the commercial book". That is correct for its job
   and wrong for a statewide roll view, where residential is the largest thing
   on the page.

   StatutoryGroup is the DLGF class from the property class code's leading digit,
   per the Property Tax Management System Code List Manual (Code List 1). It is
   the frame DLGF reports in and the frame its ratio study is published in.

   Both taxonomies are correct for their own question; the failure mode this
   column removes is letting either one answer the other's. Grouping by leading
   digit inside valuation code is what filed a 27-story Class A office tower
   under Retail (see property-type-classification.md) -- that stays fixed;
   this column simply stops statewide work from having to re-derive the
   statutory grouping in every query and page that needs it.

   Purely additive: no existing TypeGroup value changes, and no existing
   consumer of PropertyClassMap is affected.

   The row data (extending the map from 80 to 180 codes -- the full manual code
   set, not just Marion's commercial and industrial book) is loaded separately
   and idempotently by scripts/load-property-class-map.js, per the migrations
   rule that migrations are DDL + documentation only.
   ============================================================================ */

ALTER TABLE indiana_tax.PropertyClassMap
    ADD StatutoryGroup NVARCHAR(20) NULL
        CONSTRAINT CK_PropertyClassMap_StatutoryGroup CHECK (StatutoryGroup IN (
            'Agricultural', 'Mineral', 'Industrial', 'Commercial',
            'Residential', 'Exempt', 'Utility'));
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'DLGF statutory class for this property class code, from the code''s leading digit per the Property Tax Management System Code List Manual (Code List 1): 100s Agricultural, 200s Mineral, 300s Industrial, 400s Commercial, 500s Residential, 600s/700s Exempt, 800s Utility. This is the statewide-roll taxonomy and the frame DLGF''s own ratio study is published in. Distinct from TypeGroup, which is the valuation taxonomy used to build comparable pools for C&I appeal work -- see docs/proposals/property-class-map-statewide.md. Use StatutoryGroup for statewide/roll reporting and TypeGroup for comp selection; never substitute one for the other.',
    @level0type = N'SCHEMA',  @level0name = N'indiana_tax',
    @level1type = N'TABLE',   @level1name = N'PropertyClassMap',
    @level2type = N'COLUMN',  @level2name = N'StatutoryGroup';
GO
