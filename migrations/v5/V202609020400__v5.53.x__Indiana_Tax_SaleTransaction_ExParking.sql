/* ============================================================================
   Indiana Property Tax Expert — SaleTransaction.BuildingSqFtExParking
   v5.53.x   (OPP-17 / OPP-18 — close the comp-side parking asymmetry)

   The subject side of every $/SF valuation carves structured parking out of
   building area (ParcelPhysicalProfile.BuildingSqFtExParking). The comp side
   did not: SaleTransaction.BuildingSqFt for a MarionPRC-sourced row is the
   county's EstimatedSqFt, which folds in parking decks coded as Building
   floor/use segments -- so a parking-heavy comp's $/SF was understated and
   dragged its property-type group's P25 down.

   This column is the comp-side parallel:
     - Source='MarionPRC' with a structured-parking segment  -> EstimatedSqFt
       minus the parking segment SqFt (NULL if that goes <= 0, i.e. a
       standalone garage -- correctly excluded from the $/SF comp pool).
     - everything else (no parking; Source='CoStar', whose BuildingSqFt is
       CoStar RBA and already rentable/ex-parking) -> = BuildingSqFt.

   Populated by scripts/backfill-saletransaction-exparking.js and, going
   forward, directly by load-sale-transactions.js / load-costar-sales.js.
   ============================================================================ */

ALTER TABLE indiana_tax.SaleTransaction ADD BuildingSqFtExParking DECIMAL(14, 2) NULL;
GO

ALTER TABLE indiana_tax.SaleTransaction WITH CHECK
  ADD CONSTRAINT CK_SaleTransaction_ExParking CHECK (
        BuildingSqFtExParking IS NULL
     OR (BuildingSqFtExParking >= 0
         AND (BuildingSqFt IS NULL OR BuildingSqFtExParking <= BuildingSqFt + 1))
  );
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
  @value = N'Building square footage with structured parking removed -- the comp-side parallel of ParcelPhysicalProfile.BuildingSqFtExParking, so comp $/SF is computed on the same basis as the subject. For a MarionPRC row on a parcel with a Parking / Pkg Garage / Com Garage improvement segment: BuildingSqFt minus that segment SqFt (NULL when the result is <= 0, i.e. a standalone garage). Otherwise equals BuildingSqFt (no parking; CoStar RBA is already rentable area). Use this, not BuildingSqFt, for $/SF comp math.',
  @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction',
  @level2type = N'COLUMN', @level2name = N'BuildingSqFtExParking';
GO
