/* ============================================================================
   Indiana Property Tax Expert — parcel taxing-district fields + source tracking
   v5.52.x

   Second pass on the same IndianaMap/IGIO Feature Service used for parcel
   geometry (see V202608212025). Adds the taxing-district breakdown — which
   township, school corporation, library district, and special district a
   parcel falls in, plus the county's own tax district code — real information
   this schema didn't have anywhere else; it's part of what actually determines
   a parcel's tax rate, not just its assessed value.

   Also adds explicit source tracking, consistent with the DocumentDate/
   RetrievedAt pattern already used on SourceDocument:
     SourceLoadDate            — the date the SOURCE last updated this record
                                  (their "loaddate" field), distinct from...
     GeometryRetrievedAt        — ...when WE fetched it (already exists).
     GeometrySourceRegistryID   — links back to the SourceRegistry entry for
                                  this Feature Service, so "where did this
                                  come from" is a join, not tribal knowledge.

   ShapeAreaDecimalDegrees is intentionally named with its actual unit
   (esriDecimalDegrees, confirmed from the service's own geometryProperties
   response) rather than implying square feet/meters — it is NOT a usable
   real-world area without a geodesic conversion this pass doesn't do. Kept
   only as a cheap relative sanity-check against Parcel.Acreage.
   ============================================================================ */

ALTER TABLE indiana_tax.Parcel ADD TaxDistrictCode NVARCHAR(200) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD TaxTownship NVARCHAR(50) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD TaxSchoolCorp NVARCHAR(100) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD TaxLibraryDistrict NVARCHAR(50) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD TaxSpecialDistrict NVARCHAR(360) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD TaxCity NVARCHAR(70) NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD ShapeAreaDecimalDegrees FLOAT NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD SourceLoadDate DATE NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD GeometrySourceRegistryID UNIQUEIDENTIFIER NULL;
GO
ALTER TABLE indiana_tax.Parcel ADD CONSTRAINT FK_Parcel_GeometrySourceRegistry
    FOREIGN KEY (GeometrySourceRegistryID) REFERENCES indiana_tax.SourceRegistry(ID);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The county''s own tax district code for this parcel (source field: cnty_tax_dist_cd) — identifies the specific combination of overlapping taxing units (township + school + library + special districts) that applies.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxDistrictCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Civil township this parcel is taxed under.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxTownship';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'School corporation this parcel is taxed under.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxSchoolCorp';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Library taxing district this parcel falls in, if any.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxLibraryDistrict';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Special taxing district(s) this parcel falls in (e.g. solid waste management), if any. Can be a combined/concatenated value per the source.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxSpecialDistrict';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'City/municipal taxing unit this parcel falls in, if any (NULL for unincorporated areas).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'TaxCity';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Parcel boundary area in decimal degrees squared (source: SHAPE__Area, confirmed unit esriDecimalDegrees) — NOT a real-world area (not square feet/meters/acres). Only useful as a cheap relative sanity-check against Acreage; a proper acreage figure would need a geodesic area calculation this field does not provide.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'ShapeAreaDecimalDegrees';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The date the SOURCE (IndianaMap/IGIO Feature Service) last updated this record — distinct from GeometryRetrievedAt, which is when WE fetched it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'SourceLoadDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceRegistry entry for the Feature Service this parcel''s geometry/location/taxing-district fields came from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'Parcel',
    @level2type = N'COLUMN', @level2name = N'GeometrySourceRegistryID';
GO
