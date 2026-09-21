/* ============================================================================
   Indiana Property Tax Expert — TaxBill.StatutoryCapClass
   v5.57.x

   Adds the residential/commercial discriminator to TaxBill.

   WHY NOT PropertyClassMap: that table keys on the assessor's property class
   code, which lives on Parcel.PropertyClassCode. Only ~19,900 of Marion's
   382,022 tax bills have a Parcel row (the C&I working set); the rest --
   overwhelmingly residential, plus all personal property and mobile homes --
   cannot be classified that way at all.

   The circuit-breaker cap buckets CAN classify every bill, because they are
   carried on the bill itself (TAXDATA positions 485-652) and are the
   STATUTORY classification DLGF itself applies:

     1% bucket -> homestead residential
     2% bucket -> other residential, rental, apartment, farmland, mobile home land
     3% bucket -> commercial, industrial, and personal property

   Measured on pay 2026 Marion: 218,305 rows with 1% AV, 120,723 with 2%,
   41,441 with 3% (buckets overlap on mixed-use parcels; 21,197 rows have no
   bucket at all -- exempt, or fully abated).

   A row is classified by its DOMINANT bucket, and only when that bucket holds
   at least 90% of the bill's classified AV. Genuinely split parcels are
   'Mixed' rather than being forced into a class that would mislead -- a
   mixed-use building really is subject to two different caps.

   Filtering, once populated:
     residential  ->  StatutoryCapClass IN ('Homestead', 'OtherResidential')
     commercial   ->  StatutoryCapClass = 'NonResidential'

   Populated by scripts/load-dlgf-taxbills.js at load time and backfilled for
   already-loaded vintages by scripts/backfill-taxbill-capclass.js. Deliberately
   a plain column, not a PERSISTED computed column: MJ CodeGen generates full
   INSERT/UPDATE routines from the column list, and a computed column in that
   list fails at runtime.

   Design: docs/proposals/tax-bill-projection-design.md
   ============================================================================ */

ALTER TABLE indiana_tax.TaxBill
    ADD StatutoryCapClass NVARCHAR(20) NULL
        CONSTRAINT CK_TaxBill_StatutoryCapClass CHECK (StatutoryCapClass IN (
            'Homestead', 'OtherResidential', 'NonResidential', 'Mixed'));
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Residential/commercial discriminator derived from the circuit-breaker cap buckets (AVSubjectTo1Pct/2Pct/3Pct), which are the statutory classification DLGF applies on the bill itself. ''Homestead'' = 1% cap (owner-occupied residential); ''OtherResidential'' = 2% cap (rental, apartment, farmland, mobile home land); ''NonResidential'' = 3% cap (commercial, industrial, personal property); ''Mixed'' = no single bucket holds 90% of classified AV, which is a real condition for mixed-use, not a data problem. NULL when the bill has no classified AV at all (exempt or fully abated). Filter residential as IN (''Homestead'',''OtherResidential''). Preferred over joining PropertyClassMap, which needs Parcel.PropertyClassCode and so cannot classify the ~95% of Marion bills with no Parcel row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'StatutoryCapClass';
GO
