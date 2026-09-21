/* ============================================================================
   Indiana Property Tax Expert — parcel boundary geometry
   v5.52.x

   Adds boundary geometry and location fields to indiana_tax.Parcel, sourced
   from the IndianaMap/IGIO live Feature Service (Parcel Boundaries of Indiana
   Current, gisdata.in.gov, part of the same Data Harvest program that produced
   our statewide assessment gdb). Joined on state_parcel_id = Parcel.ParcelNumber.

   Geometry is stored as GeoJSON text (NVARCHAR(MAX)), not a native SQL Server
   spatial type (geography/geometry) — simpler to write/read reliably from
   Node, and GeoJSON is what web mapping libraries consume directly anyway, so
   no conversion is needed downstream. CountyFIPS is a byproduct worth keeping:
   a verifiable county crosswalk source, filling a gap left deliberately NULL
   elsewhere (e.g. BoardDecision.CountyNumber) for lack of one.
   ============================================================================ */

ALTER TABLE indiana_tax.Parcel ADD Latitude FLOAT NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD Longitude FLOAT NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD CountyFIPS NVARCHAR(10) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD BoundaryGeoJSON NVARCHAR(MAX) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD GeometryRetrievedAt DATETIMEOFFSET NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parcel centroid latitude (WGS84), from the IndianaMap parcel boundaries Feature Service.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'Latitude';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parcel centroid longitude (WGS84), from the IndianaMap parcel boundaries Feature Service.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'Longitude';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'County FIPS code, from the IndianaMap Feature Service''s county_fips field — a verifiable county identifier, distinct from CountyNumber (the DLGF/GIO statewide numbering used elsewhere in this schema).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'CountyFIPS';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parcel boundary polygon as GeoJSON geometry (WGS84), from the IndianaMap Feature Service. NULL until fetched; not every parcel in our set necessarily resolves (a parcel here may not exist in that dataset, or vice versa).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'BoundaryGeoJSON';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the geometry/location fields on this row were last fetched from the source Feature Service.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'GeometryRetrievedAt';
GO
