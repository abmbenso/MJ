/* ============================================================================
   Indiana Property Tax Expert — county-level resource directory
   v5.52.x

   A directory of county-level offices/resources relevant to property records
   (Assessor, Auditor, Treasurer, Recorder, GIS/Mapping), sourced from NETR
   Online's public records directory (publicrecords.netronline.com/state/IN).
   This is deliberately a separate table from SourceRegistry: SourceRegistry is
   "sources we actively scan on a cadence for new documents" (DLGF, IBTR, Tax
   Court); this is a reference directory of ~500+ county office links, not
   something re-scanned for new PDFs the same way.
   ============================================================================ */

CREATE TABLE indiana_tax.CountyResource (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyName        NVARCHAR(50)     NOT NULL,
    ResourceLabel     NVARCHAR(200)    NOT NULL,
    ResourceCategory  NVARCHAR(30)     NULL,
    ResourceURL       NVARCHAR(1000)   NOT NULL,
    Phone             NVARCHAR(30)     NULL,
    SourceRegistryID  UNIQUEIDENTIFIER NULL,
    DiscoveredAt      DATETIMEOFFSET   NOT NULL CONSTRAINT DF_CountyResource_DiscoveredAt DEFAULT (SYSDATETIMEOFFSET()),
    CONSTRAINT PK_CountyResource PRIMARY KEY (ID),
    CONSTRAINT FK_CountyResource_SourceRegistry FOREIGN KEY (SourceRegistryID) REFERENCES indiana_tax.SourceRegistry(ID),
    CONSTRAINT CK_CountyResource_ResourceCategory CHECK (ResourceCategory IS NULL OR ResourceCategory IN (
        N'Assessor', N'Auditor', N'Treasurer', N'Recorder', N'GIS', N'Other'))
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A county-level office/resource link relevant to property records (assessor, auditor, treasurer, recorder, GIS), sourced from NETR Online''s public records directory. Reference directory, not a periodically-rescanned document source like SourceRegistry.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Indiana county this resource belongs to (as named by the source directory).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'CountyName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The resource''s label as it appeared on the source page, e.g. "Marion Assessor" or "Recorder - Tapestry". Free text — county resource naming isn''t standardized across the state.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'ResourceLabel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Best-effort category inferred from the label (Assessor/Auditor/Treasurer/Recorder/GIS/Other) — a categorization convenience, not authoritative.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'ResourceCategory';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'URL of the resource.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'ResourceURL';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Phone number, if the source directory listed one.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'Phone';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceRegistry entry this was gathered from (the NETR Online county directory).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'SourceRegistryID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this resource link was gathered.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyResource',
    @level2type = N'COLUMN', @level2name = N'DiscoveredAt';
GO
