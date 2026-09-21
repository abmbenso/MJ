/* ============================================================================
   Indiana Property Tax Expert — SaleTransaction (market-data: the sales-comp
   pool).  v5.53.x

   Stage 1 of the Target-Value build (Indiana_Tax_Expert/docs/proposals/
   valuation-target-value.md).  One row per observed real-estate sale --
   both the project's own parcels and off-portfolio comps (ParcelID
   nullable).  Feeds the sales-comparison lens of the eventual
   ValuationAnalysis, and the Appraiser Agent's comp selection.

   Populated (post-migration, by Indiana_Tax_Expert/scripts/load-sale-
   transactions.js) from data already loaded -- NO new acquisition:
     - CountyAssessorSaleHistory (the PRC "Transfer of Ownership" section):
       ALL priced transfers, ~24.5k rows / ~15.4k parcels.
     - CoStarProperty last-sale fields (~1k), richer attributes.

   KEY DECISION -- the county's valid/invalid flag is NOT a comp filter.
   CountyAssessorSaleHistory.IsValidSale reflects the county's ratio-study /
   trending methodology under DLGF rules; it excludes many legitimate
   arm's-length transactions that are perfectly good evidence for a
   subjective valuation argument.  It is recorded here verbatim as
   CountyValidForTrending (metadata only).  IsArmsLength is a SEPARATE,
   analyst-owned judgement, left NULL at load and set deliberately during
   comp review.  Comp selection filters on recency, property type/class,
   price floor and analyst judgement -- never on CountyValidForTrending.

   Standard of work: values derived downstream from these comps are
   appeal-screening estimates, not USPAP-compliant appraisals.
   ============================================================================ */

CREATE TABLE indiana_tax.SaleTransaction (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    Source NVARCHAR(20) NOT NULL
        CONSTRAINT CK_SaleTransaction_Source CHECK (Source IN (
            'MarionPRC', 'CoStar', 'SalesDisclosure', 'Recorder', 'Manual')),
    SourceDocumentID UNIQUEIDENTIFIER NULL,

    ParcelID UNIQUEIDENTIFIER NULL,
    CountyNumber SMALLINT NULL,
    SitusAddress NVARCHAR(200) NULL,
    City NVARCHAR(80) NULL,
    Submarket NVARCHAR(80) NULL,
    PropertyClassCode NVARCHAR(10) NULL,
    PropertyTypeGroup NVARCHAR(30) NULL
        CONSTRAINT CK_SaleTransaction_PropertyTypeGroup CHECK (PropertyTypeGroup IN (
            'Retail', 'Office', 'Industrial', 'Multifamily', 'Land', 'Special', 'Other')),

    SaleDate DATE NOT NULL,
    SalePrice DECIMAL(14, 2) NOT NULL,
    Grantor NVARCHAR(200) NULL,
    Grantee NVARCHAR(200) NULL,
    DeedOrSaleType NVARCHAR(30) NULL,

    CountyValidForTrending BIT NULL,
    CountyValidityNote NVARCHAR(200) NULL,

    IsArmsLength BIT NULL,
    VerificationNote NVARCHAR(400) NULL,

    BuildingSqFt INT NULL,
    UnitCount INT NULL,
    Acres DECIMAL(10, 4) NULL,
    YearBuilt SMALLINT NULL,
    ConditionGrade NVARCHAR(20) NULL,

    PricePerSqFt DECIMAL(12, 2) NULL,
    PricePerUnit DECIMAL(14, 2) NULL,
    PricePerAcre DECIMAL(14, 2) NULL,

    Notes NVARCHAR(MAX) NULL,

    CONSTRAINT PK_SaleTransaction PRIMARY KEY (ID),
    CONSTRAINT FK_SaleTransaction_SourceDocument FOREIGN KEY (SourceDocumentID)
        REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_SaleTransaction_Parcel FOREIGN KEY (ParcelID)
        REFERENCES indiana_tax.Parcel (ID)
);
GO
CREATE INDEX IX_SaleTransaction_Parcel ON indiana_tax.SaleTransaction (ParcelID);
CREATE INDEX IX_SaleTransaction_Date   ON indiana_tax.SaleTransaction (SaleDate);
CREATE INDEX IX_SaleTransaction_Class  ON indiana_tax.SaleTransaction (PropertyClassCode, SaleDate);
CREATE INDEX IX_SaleTransaction_Type   ON indiana_tax.SaleTransaction (PropertyTypeGroup, SaleDate);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One observed real-estate sale -- the sales-comparison comp pool. Subject sales and off-portfolio comps both live here (ParcelID nullable). Populated from data already loaded (CountyAssessorSaleHistory + CoStarProperty), no new acquisition. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Where this observation came from: MarionPRC (the PRC "Transfer of Ownership" section, via CountyAssessorSaleHistory), CoStar, SalesDisclosure, Recorder, or Manual.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Source';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The SourceDocument this sale was read from (e.g. the parcel''s PRC). NULL for a manually-entered comp.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The Parcel that transacted, when it is one of the project''s parcels. NULL for an off-portfolio comp (address/attributes still recorded).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'ParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indiana county number of the property that sold.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'CountyNumber';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Street address of the property that sold, as recorded at load time.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'SitusAddress';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City of the property that sold.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'City';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Submarket label (from CoStar where available) -- used to group/adjust comps by location.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Submarket';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The assessor property class code as of load (e.g. "447", "350", "400") -- the primary comp-grouping key.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'PropertyClassCode';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rolled-up category derived from PropertyClassCode: Retail, Office, Industrial, Multifamily, Land, Special, or Other. Coarser grouping for comp selection when the exact class pool is thin.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'PropertyTypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date of the sale.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'SaleDate';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recorded sale price.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'SalePrice';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Seller. The PRC transfer section records the grantor only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Grantor';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Buyer, when available (CoStar / recorder). NULL from PRC transfer data.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Grantee';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The county''s sale-type label ("Straight" / "Sale" / "Split" in Marion) or deed type (warranty / quitclaim ...).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'DeedOrSaleType';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The county''s own valid/invalid designation for this sale, recorded VERBATIM as metadata. It reflects the county''s ratio-study / trending methodology (DLGF rules), NOT whether the sale is a good comparable for a subjective valuation argument -- many county-"invalid" sales are legitimate market evidence. DO NOT gate comp selection on this column.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'CountyValidForTrending';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Any note the county attached to its validity determination.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'CountyValidityNote';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A separate, analyst-owned judgement about whether this transaction is usable as market evidence for an analysis. Starts NULL (unassessed); set deliberately during comp review with the reasoning in VerificationNote. NOT copied from CountyValidForTrending.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'IsArmsLength';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free text: why this sale was verified in or excluded as market evidence (conditions of sale, related parties, personal property included, portfolio allocation, etc.).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'VerificationNote';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area (sq ft) as of load -- from the PRC (SqFtSource = PropertyRecordCard) or CoStar RBA. Stored, not looked up live, so a comp stays reproducible.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'BuildingSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit count (multifamily) as of load, where known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'UnitCount';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Land area (acres) as of load.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Acres';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Year built as of load.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'YearBuilt';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Condition / grade descriptor as of load, where known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'ConditionGrade';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SalePrice / BuildingSqFt, computed at load. NULL when BuildingSqFt is unknown.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'PricePerSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SalePrice / UnitCount, computed at load. NULL when UnitCount is unknown.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'PricePerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SalePrice / Acres, computed at load. NULL when Acres is unknown.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'PricePerAcre';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free-text notes about this transaction.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'SaleTransaction', @level2type = N'COLUMN', @level2name = N'Notes';
GO
