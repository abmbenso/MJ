/* ============================================================================
   Big Box Retail — two distortions at the top of the comparable-sales range
   v5.56.x

   Comparable sales are the primary approach to value for big box in Indiana,
   so the top of that range is the most consequential number in the project.
   Auditing it found two separate problems, and neither was what I first
   assumed. My initial diagnosis -- that a whole-parcel sale price was being
   divided by a partial building area -- was WRONG: the denominators are
   already the full parcel totals, and one parcel that appeared to hold four
   buildings holds one, re-stated on four successive card years.

   What is actually there:

   1. **Blended centre rates.** Nine parcels carry several buildings in the
      SAME card year. One Elkhart parcel holds a 101,578 sf Mixed Use building,
      a second at 34,070, a 10,530 sf leased retail unit and a Kay Jewelers;
      its $124.54/sf is arithmetically right and meaningless as a big-box
      comparable. 7 priced comps sit on such parcels and are now graded
      'review'. The test is a SHARE, not a count -- a store with a small
      detached garden centre is still a box -- so it fires only when the
      largest building is under 80% of the parcel's floor area.

   2. **Probable leased-fee sales.** A sale far above benchmark on a clean
      single-building parcel is usually not the real estate: a net-leased
      national credit tenant trades on its income stream. One St. Joseph
      parcel -- a single 50,000 sf building -- sold five times between 2003
      and 2024 at $140-193/sf. 10 comps are flagged. They are FLAGGED AND
      STILL COUNTED: leased-fee is an argument to make with evidence, not
      something to infer from a price and act on silently.

   Effect on the headline, stated because it moved: the usable comparable
   median falls from $44.84 to $38.86/sf once the blended rates are out, and
   to $35.33/sf if the leased-fee-flagged sales are set aside as well. Both
   figures are below the $50/SF benchmark and the $45 stretch.
   ============================================================================ */

ALTER TABLE big_box_retail.ParcelTransfer ADD
    BuildingsOnParcel  INT          NULL,
    PossibleLeasedFee  BIT          NOT NULL DEFAULT 0;
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How many separate buildings stand on this parcel, from the latest card year only. Counting across years double-counts: one Best Buy parcel shows four "building" rows that are the same 50,000 sf store re-stated on four successive cards. More than one building means the sale price covers more than one, so the $/SF is a blend.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer', @level2type = N'COLUMN', @level2name = N'BuildingsOnParcel';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Set where a sale on a clean single-building parcel priced above $100/SF - usually a net-leased credit tenant trading on its income stream rather than the real estate, which is the transaction type the dark-store argument exists to answer. DELIBERATELY A FLAG, NOT AN EXCLUSION: these rows still count toward the comparable set, because leased-fee is an argument to make with evidence rather than something to infer from a price. Setting the 10 flagged sales aside moves the usable median from $38.86 to $35.33/SF - which is why the decision belongs to the reader, not the parser.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer', @level2type = N'COLUMN', @level2name = N'PossibleLeasedFee';
GO
