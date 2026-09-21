/* ============================================================================
   Big Box Retail — Hamilton and Marion transfer templates
   v5.56.x

   The first appeal-evidence migration (V202609081400) landed transfers read from
   the Standard PRC template only. Hamilton and Marion publish their own layouts,
   between them 137 of the 628 record cards held, and both have since been parsed
   (Big_Box_Retail/states/indiana/scripts/extract-sale-history.py). Two of their
   columns have nowhere to go in the existing table, and a third grade is now
   possible:

     * Marion prints Type (Sale / Straight / Split) instead of a deed code, and an
       explicit Valid Y/N flag. The flag is RECORDED AND NEVER USED TO SCREEN
       COMPARABLES -- it is an administrative marker, not a quality judgment, and
       this project's standing rule is to load all priced transfers and filter on
       none of them.

     * Hamilton publishes neither a deed code nor a transfer type. An in-band
       Hamilton sale is real evidence that merely lacks instrument confirmation,
       so it earns its own grade rather than being buried in 'review' alongside
       quit claims and outlot conveyances -- which would otherwise discard every
       comparable in the county (25 of 28 priced Hamilton transfers).

   Per migrations/CLAUDE.md, a CHECK-constrained field's allowed values are the
   source of truth for its EntityFieldValue rows and generated union, so the old
   constraint is dropped and the new one added in this single migration; CodeGen
   re-syncs the value list.
   ============================================================================ */

ALTER TABLE big_box_retail.ParcelTransfer
    DROP CONSTRAINT CK_ParcelTransfer_CompQuality;
GO

ALTER TABLE big_box_retail.ParcelTransfer ADD
    CONSTRAINT CK_ParcelTransfer_CompQuality
        CHECK (CompQuality IN (N'usable', N'unverified', N'review'));
GO

ALTER TABLE big_box_retail.ParcelTransfer ADD
    TransferType      NVARCHAR(20) NULL,
    CountyValidFlag   NCHAR(1)     NULL,
    SourceTemplate    NVARCHAR(20) NULL;
GO

ALTER TABLE big_box_retail.ParcelTransfer ADD
    CONSTRAINT CK_ParcelTransfer_CountyValidFlag CHECK (CountyValidFlag IN (N'Y', N'N')),
    CONSTRAINT CK_ParcelTransfer_SourceTemplate
        CHECK (SourceTemplate IN (N'standard', N'hamilton', N'marion', N'note'));
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How the county names the instrument when it does not print a deed code. Marion uses Sale / Straight / Split; Sale is the market conveyance. NULL where the county publishes a deed code instead, or publishes neither.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'TransferType';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Marion''s own Valid Y/N marker on the transfer. Recorded for completeness and DELIBERATELY NEVER USED TO SCREEN COMPARABLES: it is an administrative marker used for trending, not a judgment about whether a sale is a usable comparable. Use CompQuality for that.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'CountyValidFlag';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which card layout the row was read from: standard (the ~73-county Standard PRC), hamilton, marion, or note (a price quoted in assessor free text rather than a transfer table). Explains why some columns are empty -- Hamilton carries no deed code or V/I, Marion no deed code or book/page.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'SourceTemplate';
GO
