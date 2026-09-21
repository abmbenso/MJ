-- Adds SqFtSource to indiana_tax.CountyAssessorRecord and corrects the documentation on
-- EstimatedSqFt after discovering it was populated from the Marion County ArcGIS layer's
-- ESTSQFT field -- which, for a meaningful subset of rows (~29%, verified by comparing against
-- Parcel.Acreage * 43560), actually holds LAND square footage, not building square footage.
-- Root-caused against a real parcel (8050459 / 49-02-18-112-019.000-800): stored EstimatedSqFt
-- was 122,243, matching the parcel's own 2.806-acre land area (122,229) almost exactly, while
-- the Property Record Card's itemized building floor areas summed to 117,212.
--
-- SqFtSource lets consumers (including the AI agent) distinguish a verified building-level
-- figure from the original, sometimes-land-derived ArcGIS value:
--   'BuildingDetail' -- re-sourced from the itemized per-floor building_detail data (the same
--                        source indiana_tax.AppealLead.BuildingSqFt already correctly uses),
--                        summed across all use codes for the parcel. High confidence.
--   NULL             -- original ArcGIS ESTSQFT value (or cleared to NULL where it was proven
--                        to be land-derived and no better source was available). Do not treat
--                        as building square footage without independent verification.

ALTER TABLE indiana_tax.CountyAssessorRecord
ADD SqFtSource NVARCHAR(20) NULL;

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('indiana_tax.CountyAssessorRecord')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('indiana_tax.CountyAssessorRecord')
                          AND name = 'EstimatedSqFt')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = 'indiana_tax',
        @level1type = N'TABLE', @level1name = 'CountyAssessorRecord',
        @level2type = N'COLUMN', @level2name = 'EstimatedSqFt';
END

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Estimated square footage. CAUTION: sourced from the Marion County ArcGIS layer''s ESTSQFT field, which for a meaningful subset of rows (~29%, matches Parcel.Acreage * 43560) actually holds LAND square footage rather than building square footage -- confirmed 2026-08-23 against a real Property Record Card. Check SqFtSource: ''BuildingDetail'' means this value was re-sourced from itemized per-floor data and is trustworthy for building-size analysis; NULL means it is either the original unverified ArcGIS value (use with caution, may be land area) or was cleared after being proven land-derived with no better source available.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = 'EstimatedSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How EstimatedSqFt was sourced/verified. ''BuildingDetail'' = re-summed from itemized per-floor building_detail data (all use codes for the parcel) -- the same reliable source indiana_tax.AppealLead.BuildingSqFt uses. NULL = original ArcGIS ESTSQFT value (unverified, may be land-area-derived) or cleared after being proven land-derived with no replacement source available.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = 'SqFtSource';
