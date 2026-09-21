/* ============================================================================
   Indiana Property Tax Expert — county-own assessor data
   v5.52.x

   A county's own live assessor GIS layer, richer/fresher than the statewide
   DLGF pull for that county (Marion's own data reportedly runs ~1 year ahead
   of the statewide pull). Named generically (not "Marion...") since other
   counties may have their own equivalent systems worth pulling the same way
   later — CountyNumber scopes each row to which county's system it came from.

   Deliberately separate from Parcel/Assessment rather than merged into them:
   this is a different AUTHORITY (the county's own system, not the statewide
   DLGF/GIO pull those tables are built from) with its own freshness
   (SourceModDate, the county system's own last-updated stamp) — collapsing
   two different sources into one column would lose which one said what.

   The tax-bill/building/deed columns and CountyAssessorSaleHistory come from
   a SECOND, richer source on the same county system: per-parcel Property
   Record Card / Tax History PDF reports (fetched one parcel at a time, no
   bulk endpoint like the GIS layer above — hence ReportRetrievedAt tracked
   separately from RetrievedAt, since the two sources are fetched at
   different times/paces). This is where actual computed tax amounts live —
   something no other source in this schema has.
   ============================================================================ */

CREATE TABLE indiana_tax.CountyAssessorRecord (
    ID                            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID                      UNIQUEIDENTIFIER NOT NULL,
    CountyNumber                  SMALLINT         NOT NULL,
    OwnerName                     NVARCHAR(500)    NULL,
    OwnerAddress                  NVARCHAR(200)    NULL,
    OwnerCity                     NVARCHAR(100)    NULL,
    OwnerState                    NVARCHAR(10)     NULL,
    OwnerZip                      NVARCHAR(20)     NULL,
    PropertyClass                 NVARCHAR(32)     NULL,
    PropertySubClassDescription   NVARCHAR(64)     NULL,
    AssessedLandAV                 DECIMAL(14,2)    NULL,
    AssessedImprovementAV          DECIMAL(14,2)    NULL,
    AssessedTotalAV                 DECIMAL(14,2)    NULL,
    CountyParcelID                 NVARCHAR(50)     NULL,
    Neighborhood                  NVARCHAR(32)     NULL,
    TaxDistrictID                  NVARCHAR(5)      NULL,
    LegalDescription               NVARCHAR(1500)   NULL,
    Acreage                        NVARCHAR(10)     NULL,
    EstimatedSqFt                   INT              NULL,
    Status                         NVARCHAR(8)      NULL,
    SourceModDate                  DATETIMEOFFSET   NULL,
    RetrievedAt                    DATETIMEOFFSET   NOT NULL CONSTRAINT DF_CountyAssessorRecord_RetrievedAt DEFAULT (SYSDATETIMEOFFSET()),
    SourceRegistryID               UNIQUEIDENTIFIER NULL,
    YearBuilt                      SMALLINT         NULL,
    LastAssessmentChangeDate       DATE             NULL,
    TaxYear                        SMALLINT         NULL,
    GrossAssessment                DECIMAL(14,2)    NULL,
    DeductionsExemptionsTotal      DECIMAL(14,2)    NULL,
    NetAssessment                  DECIMAL(14,2)    NULL,
    TaxRate                        DECIMAL(9,6)     NULL,
    NetAnnualTax                   DECIMAL(14,2)    NULL,
    CurrentTaxDue                  DECIMAL(14,2)    NULL,
    DeedType                       NVARCHAR(50)     NULL,
    DeedDate                       DATE             NULL,
    FileDate                       DATE             NULL,
    ReportRetrievedAt              DATETIMEOFFSET   NULL,
    CONSTRAINT PK_CountyAssessorRecord PRIMARY KEY (ID),
    CONSTRAINT FK_CountyAssessorRecord_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_CountyAssessorRecord_SourceRegistry FOREIGN KEY (SourceRegistryID) REFERENCES indiana_tax.SourceRegistry(ID),
    CONSTRAINT UQ_CountyAssessorRecord_Parcel UNIQUE (ParcelID)
);
GO

-- ============================================================================
-- CountyAssessorSaleHistory — transfer/sale history from the property record card
-- ============================================================================
CREATE TABLE indiana_tax.CountyAssessorSaleHistory (
    ID                      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyAssessorRecordID  UNIQUEIDENTIFIER NOT NULL,
    SaleDate                DATE             NULL,
    GrantorName             NVARCHAR(300)    NULL,
    IsValidSale             BIT              NULL,
    SaleAmount               DECIMAL(14,2)    NULL,
    SaleType                 NVARCHAR(50)     NULL,
    CONSTRAINT PK_CountyAssessorSaleHistory PRIMARY KEY (ID),
    CONSTRAINT FK_CountyAssessorSaleHistory_CountyAssessorRecord FOREIGN KEY (CountyAssessorRecordID) REFERENCES indiana_tax.CountyAssessorRecord(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One ownership transfer/sale event from a parcel''s Property Record Card sale history table.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel record this sale belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'CountyAssessorRecordID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the transfer/sale.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'SaleDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Grantor (seller) of record.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'GrantorName';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the county flagged this as a valid (arms-length) sale, per the source report.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'IsValidSale';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sale/transfer amount.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'SaleAmount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Transfer type as recorded, e.g. Sale, Straight (non-sale transfer such as a trust conveyance).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorSaleHistory',
    @level2type = N'COLUMN', @level2name = N'SaleType';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A parcel''s record from its OWN county''s live assessor GIS system (not the statewide DLGF/GIO pull Assessment is built from). Currently populated for Marion County only, from its ArcGIS-hosted assessor layer, but named generically since other counties may have their own equivalent systems worth the same treatment later.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this record belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which county''s own system this record came from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'CountyNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed land value per the county''s own current system -- may be fresher than the statewide Assessment table for this parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'AssessedLandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed improvement value per the county''s own current system.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'AssessedImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed total value per the county''s own current system.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'AssessedTotalAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The county system''s own internal parcel identifier (e.g. Marion''s CAMAPARCELID), distinct from the statewide ParcelNumber.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'CountyParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the county''s OWN system last updated this record -- distinct from RetrievedAt, which is when WE fetched it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'SourceModDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When we fetched this record.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'RetrievedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceRegistry entry for the county system this came from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'SourceRegistryID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Year the primary structure was built, per the county''s Tax History report.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'YearBuilt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the last assessment change per the county''s system.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'LastAssessmentChangeDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The tax year the tax-bill fields on this row (GrossAssessment through CurrentTaxDue) apply to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'TaxYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Gross assessment (land + improvements) for TaxYear, before deductions/exemptions.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'GrossAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total deductions/exemptions applied for TaxYear (e.g. homestead standard deduction, supplemental).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'DeductionsExemptionsTotal';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Net assessment for TaxYear (gross minus deductions/exemptions) -- the actual tax base.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'NetAssessment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The tax rate applied for TaxYear, as a percentage (e.g. 2.729100 means 2.7291%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'TaxRate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The actual computed net annual tax for TaxYear -- the real dollar tax amount, not just assessed value. This is data no other source in this schema provides.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'NetAnnualTax';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Amount currently due, per the report at the time it was fetched (a snapshot, not necessarily current by the time this is read).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'CurrentTaxDue';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deed type for the most recent transfer (e.g. Warranty Deed), per the Tax History report.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'DeedType';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deed execution date for the most recent transfer.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'DeedDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the deed was filed/recorded for the most recent transfer.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'FileDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the Property Record Card / Tax History PDF reports were fetched for this parcel -- tracked separately from RetrievedAt (the GIS layer fetch) since these two sources are pulled at different times and paces (the reports have no bulk endpoint).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'ReportRetrievedAt';
GO
