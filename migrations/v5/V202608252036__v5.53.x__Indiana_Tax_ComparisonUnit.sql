/* ============================================================================
   Indiana Property Tax Expert — per-property-type unit of comparison.
   v5.53.x

   $/SF is the wrong comparison unit for some property types: multifamily is
   properly compared per apartment unit, hospitality per key/room, nursing/
   hospital per bed, and self-storage per door -- confirmed with the user
   this session, who also asked for a toggle in Property Search to switch
   between these. Building SqFt/$-per-SF (CountyAssessorRecord.EstimatedSqFt/
   SqFtSource) and Acreage (already present) cover the SF- and acre-based
   cases; this migration adds the remaining unit-count concept.

   One generic type+count pair, not four separate nullable columns -- exactly
   one applies per property (mutually exclusive by PropertySubClassDescription:
   apartments get 'Unit', hotels/motels get 'Key', nursing/hospital gets
   'Bed', mini-warehouse gets 'Door'), and it's extensible if a fifth type
   comes up later (e.g. mobile home parks by pad) without another migration.
   Acres is deliberately NOT one of these values -- it already exists via
   Acreage, no duplication.

   NOT populated by this migration -- investigated this session and confirmed
   Marion County's Property Record Card does not reliably expose unit/room/
   key counts as a structured field (checked a large hotel, two smaller
   hotels, and a 40+-unit apartment building: one hotel had a lucky free-text
   renovation note, nothing else did). Real values are expected to come from
   a future CoStar-export import, not from PRC parsing.
   ============================================================================ */

ALTER TABLE indiana_tax.CountyAssessorRecord ADD
    ComparisonUnitType  NVARCHAR(20) NULL
        CONSTRAINT CK_CountyAssessorRecord_ComparisonUnitType CHECK (ComparisonUnitType IN ('Unit', 'Key', 'Bed', 'Door')),
    ComparisonUnitCount DECIMAL(10, 2) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The non-SF/non-acre unit of comparison this property should be valued per, when one applies: Unit (apartment dwelling units), Key (hotel/motel rooms), Bed (nursing home/hospital beds), or Door (self-storage doors). NULL means this property is compared per square foot (the default -- see EstimatedSqFt) or per acre (vacant land -- see Acreage), not per a unit count. Not populated by PRC parsing -- see ComparisonUnitCount.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'ComparisonUnitType';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The count of ComparisonUnitType for this property (e.g. number of apartment units, hotel keys, nursing beds, or storage doors). NULL until populated by a future CoStar-export import -- confirmed 2026-08-25 that Marion County''s Property Record Card does not reliably expose this as a structured field (one large hotel''s card had a free-text renovation note giving a room count; the rest of a small real sample had nothing usable).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'ComparisonUnitCount';
GO
