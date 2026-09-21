/* ============================================================================
   Indiana Property Tax Expert — widen PropertyTypeGroup vocabulary
   v5.53.x

   The DLGF class-code classification (PropertyClassMap, V202608301700) adds two
   groups the earlier CHECK constraints don't allow:
     - 'Hospitality'  (DLGF 410 motels, 411 hotels) -- its own group per the
        classification proposal
     - 'Parking'      (DLGF 455 garages, 456 parking lot/structure) -- so parking
        structures are excluded from every other comp pool by construction

   Widen the two CHECK constraints that enumerate the vocabulary. (ValuationAnalysis
   and ComparableAssessmentSet use an unconstrained NVARCHAR and need no change.)

   Design: Indiana_Tax_Expert/docs/proposals/property-type-classification.md.
   ============================================================================ */

ALTER TABLE indiana_tax.SaleTransaction DROP CONSTRAINT CK_SaleTransaction_PropertyTypeGroup;
GO
ALTER TABLE indiana_tax.SaleTransaction ADD CONSTRAINT CK_SaleTransaction_PropertyTypeGroup
    CHECK (PropertyTypeGroup IN (
        'Retail', 'Office', 'Industrial', 'Multifamily', 'Hospitality',
        'Land', 'Special', 'Parking', 'Other'));
GO

ALTER TABLE indiana_tax.MarketAssumption DROP CONSTRAINT CK_MarketAssumption_PropertyTypeGroup;
GO
ALTER TABLE indiana_tax.MarketAssumption ADD CONSTRAINT CK_MarketAssumption_PropertyTypeGroup
    CHECK (PropertyTypeGroup IN (
        'Retail', 'Office', 'Industrial', 'Multifamily', 'Hospitality',
        'Land', 'Special', 'Parking', 'Other', 'All'));
GO
