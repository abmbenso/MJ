/* ============================================================================
   Indiana Property Tax Expert — CoStarIncomeInput
   v5.53.x

   One row per CoStar property-inventory record (from the exports in
   /Users/abebenson/Projects/CoStar_Data). Carries the direct rent / vacancy /
   concession / physical inputs that feed a pro-forma income approach --
   distinct from CoStarProperty (which is loaded from the CoStar *sales*
   exports and is keyed to transactions).

   Seeded by scripts/parse-costar-property.py -> scripts/load-costar-property.js.
   Design: Indiana_Tax_Expert/docs/proposals/income-approach-costar.md.
   ============================================================================ */

CREATE TABLE indiana_tax.CoStarIncomeInput (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CoStarPropertyID BIGINT NOT NULL,
    ParcelID UNIQUEIDENTIFIER NULL,
    ParcelNumberMin NVARCHAR(30) NULL,
    ParcelNumberMax NVARCHAR(30) NULL,
    MultiParcel BIT NOT NULL CONSTRAINT DF_CoStarIncomeInput_MultiParcel DEFAULT (0),

    PropertyTypeGroup NVARCHAR(20) NULL,
    CoStarPropertyType NVARCHAR(60) NULL,
    SecondaryType NVARCHAR(80) NULL,
    Submarket NVARCHAR(80) NULL,
    City NVARCHAR(80) NULL,
    PropertyName NVARCHAR(200) NULL,
    PropertyAddress NVARCHAR(200) NULL,

    StarRating DECIMAL(2, 1) NULL,
    YearBuilt SMALLINT NULL,
    YearRenovated SMALLINT NULL,
    Units INT NULL,
    RBA INT NULL,
    Rooms INT NULL,
    Beds INT NULL,

    -- income primitives (rents are MONTHLY as CoStar reports them)
    AvgEffectiveRentPerUnit DECIMAL(10, 2) NULL,
    AvgAskingRentPerUnit DECIMAL(10, 2) NULL,
    AvgEffectiveRentPerSF DECIMAL(8, 2) NULL,
    AvgAskingRentPerSF DECIMAL(8, 2) NULL,
    ConcessionsPct DECIMAL(6, 3) NULL,
    VacancyPct DECIMAL(6, 3) NULL,
    PercentLeased DECIMAL(6, 3) NULL,
    RentPerSFYrLow DECIMAL(8, 2) NULL,
    RentPerSFYrHigh DECIMAL(8, 2) NULL,
    AverageWeightedRent DECIMAL(8, 2) NULL,

    CapRate DECIMAL(6, 4) NULL,
    TaxesTotal DECIMAL(14, 2) NULL,
    LastSalePrice DECIMAL(14, 2) NULL,
    LastSaleDate DATE NULL,

    SourceFile NVARCHAR(120) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_CoStarIncomeInput_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_CoStarIncomeInput_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_CoStarIncomeInput PRIMARY KEY (ID),
    CONSTRAINT UQ_CoStarIncomeInput UNIQUE (CoStarPropertyID),
    CONSTRAINT FK_CoStarIncomeInput_Parcel FOREIGN KEY (ParcelID)
        REFERENCES indiana_tax.Parcel (ID)
);
GO
CREATE INDEX IX_CoStarIncomeInput_Parcel ON indiana_tax.CoStarIncomeInput (ParcelID);
CREATE INDEX IX_CoStarIncomeInput_Group ON indiana_tax.CoStarIncomeInput (PropertyTypeGroup, Submarket);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One row per CoStar property-inventory record (from /Users/abebenson/Projects/CoStar_Data exports): direct rent / vacancy / concession / physical inputs for a pro-forma income approach. Distinct from CoStarProperty (CoStar *sales* exports). Design: Indiana_Tax_Expert/docs/proposals/income-approach-costar.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar''s PropertyID for the record.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'CoStarPropertyID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Resolved Parcel (matched on Parcel Number 1(Min)); NULL when off-book.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'ParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Property spans more than one parcel (Min <> Max).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'MultiParcel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Average EFFECTIVE rent per unit, MONTHLY (net of concessions), as CoStar reports it. Annualise x 12 for the pro forma.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'AvgEffectiveRentPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Vacancy percent (0-100) as reported by CoStar.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'VacancyPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Percent leased (0-100); office/retail/industrial where vacancy is not reported.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'PercentLeased';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar cap rate where disclosed on the inventory record (rare -- usually NULL).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarIncomeInput', @level2type = N'COLUMN', @level2name = N'CapRate';
GO
