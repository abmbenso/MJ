/* ============================================================================
   Big Box Retail — widen Store uniqueness to (Brand, Address, City, ZIP)
   v5.55.x

   The original UQ_Store_Address_City_ZIP constraint (Address, City, ZIP)
   assumed one retail brand per physical parcel. Real Indiana data disproves
   that assumption: a small number of mall/shopping-center anchor parcels are
   legitimately shared by more than one brand -- e.g. an Indianapolis parcel
   matched to Home Depot, Kohl's, and Target alike in the source roster. That
   is a genuine, known ambiguity in the upstream research (multiple named
   tenants at one address), not a data-entry bug to silently collapse -- and
   under the old constraint, re-importing such a parcel caused one brand's
   row to silently overwrite another's.

   Widen the key to include Brand so each brand at a shared address gets its
   own row, while still preventing true duplicate rows (same brand, same
   address) on re-import.
   ============================================================================ */

ALTER TABLE big_box_retail.Store DROP CONSTRAINT UQ_Store_Address_City_ZIP;
GO

ALTER TABLE big_box_retail.Store ADD CONSTRAINT UQ_Store_Brand_Address_City_ZIP UNIQUE (Brand, Address, City, ZIP);
GO
