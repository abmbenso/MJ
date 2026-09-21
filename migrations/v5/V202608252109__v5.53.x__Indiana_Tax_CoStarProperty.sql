/* ============================================================================
   Indiana Property Tax Expert — CoStar property data import.
   v5.53.x

   The user supplied 8 CoStar export files (Hospitality, Industrial, 3
   Multi-Family size bands, Office, Retail, Student Housing -- 2,851
   properties, one shared 290-column schema) and asked for every imported
   field to be characterized as CoStar-sourced (CoStar{FieldName} naming,
   mirroring this project's existing Assessment.Source='MarionPRC'
   provenance-tagging convention) and matched back to indiana_tax.Parcel.

   Investigated live before writing this migration: CoStar's "Parcel Number
   1(Min)" / "Parcel Number 2(Max)" columns are full 18-digit Indiana state
   parcel numbers with punctuation -- stripping the punctuation and matching
   against Parcel.ParcelNumber (NOT GISParcelNumber, a different/shorter
   number) resolves 79.4% of rows exactly, +1.9% via a normalized-address
   fallback. CoStar's own PropertyID is a clean natural key (zero duplicates
   across all 2,851 rows).

   MULTI-PARCEL PROPERTIES: 18% of rows have Min != Max (CoStar's own signal
   that the property spans multiple parcels), but Min/Max is an OUTER BOUND,
   not a membership list -- of the multi-parcel rows, both ends resolve to a
   real Marion parcel for only ~66% of them, and the numeric distance between
   Min/Max varies too widely to assume every parcel "between" them belongs to
   the property. CoStarIsMultiParcel flags this explicitly so any per-unit-
   value analytics built on this table can show "partial match" rather than
   silently understating value the way a single matched parcel's AV divided
   by CoStar's whole-property unit count would. CoStar's own physical
   aggregates (Number of Units, RBA, Rooms) ARE already correct for the whole
   property -- the gap is only on the assessed-value side, where we can't
   currently enumerate every constituent parcel.

   Curated ~50-column subset of CoStar's 290 columns -- chosen for what this
   project's SF/Unit/Key/Acre comparison-analytics work needs, not an
   exhaustive import. Raw xlsx files are user-provided local exports (same
   precedent as the DLGF Gateway TaxBill/TaxAdjustment files already noted
   "not fetched by us" in RESEARCH_BEST_PRACTICES.md) -- no SourceDocument
   entry, no URL/content-hash story.
   ============================================================================ */

CREATE TABLE indiana_tax.CoStarProperty (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CoStarPropertyID INT NOT NULL,
    SourceExportFile NVARCHAR(100) NOT NULL,
    ParcelID UNIQUEIDENTIFIER NULL,
    CoStarSecondaryParcelID UNIQUEIDENTIFIER NULL,
    CoStarIsMultiParcel BIT NOT NULL DEFAULT 0,
    MatchMethod NVARCHAR(20) NULL
        CONSTRAINT CK_CoStarProperty_MatchMethod CHECK (MatchMethod IN ('ParcelNumberMin', 'ParcelNumberMax', 'Address')),
    CoStarAddress NVARCHAR(200) NULL,
    CoStarPropertyName NVARCHAR(200) NULL,
    CoStarPropertyType NVARCHAR(50) NULL,
    CoStarSecondaryType NVARCHAR(50) NULL,
    CoStarCity NVARCHAR(100) NULL,
    CoStarState NVARCHAR(10) NULL,
    CoStarZip NVARCHAR(20) NULL,
    CoStarCountyName NVARCHAR(50) NULL,
    CoStarLatitude DECIMAL(10, 6) NULL,
    CoStarLongitude DECIMAL(10, 6) NULL,
    CoStarParcelNumberMin NVARCHAR(40) NULL,
    CoStarParcelNumberMax NVARCHAR(40) NULL,
    CoStarOwnerName NVARCHAR(300) NULL,
    CoStarRecordedOwnerName NVARCHAR(300) NULL,
    CoStarTrueOwnerName NVARCHAR(300) NULL,
    CoStarNumberOfUnits INT NULL,
    CoStarRooms INT NULL,
    CoStarRBA INT NULL,
    CoStarTotalBuildings INT NULL,
    CoStarLandAreaAcres DECIMAL(10, 4) NULL,
    CoStarLandAreaSF DECIMAL(14, 2) NULL,
    CoStarNumberOfStories INT NULL,
    CoStarYearBuilt SMALLINT NULL,
    CoStarYearRenovated SMALLINT NULL,
    CoStarBuildingClass NVARCHAR(10) NULL,
    CoStarStarRating TINYINT NULL,
    CoStarLastSalePrice DECIMAL(14, 2) NULL,
    CoStarLastSaleDate DATE NULL,
    CoStarForSalePrice DECIMAL(14, 2) NULL,
    CoStarForSalePricePerUnit DECIMAL(14, 2) NULL,
    CoStarForSalePricePerSF DECIMAL(14, 2) NULL,
    CoStarForSalePricePerRoom DECIMAL(14, 2) NULL,
    CoStarForSaleStatus NVARCHAR(10) NULL,
    CoStarCapRate DECIMAL(9, 4) NULL,
    CoStarTaxesTotal DECIMAL(14, 2) NULL,
    CoStarTaxesPerSF DECIMAL(9, 4) NULL,
    CoStarTaxYear SMALLINT NULL,
    CoStarAvgAskingPerSF DECIMAL(9, 4) NULL,
    CoStarAvgAskingPerUnit DECIMAL(14, 2) NULL,
    CoStarAvgEffectivePerSF DECIMAL(9, 4) NULL,
    CoStarAvgEffectivePerUnit DECIMAL(14, 2) NULL,
    CoStarPercentLeased DECIMAL(6, 3) NULL,
    CoStarVacancyPct DECIMAL(6, 3) NULL,
    CoStarDaysOnMarket INT NULL,
    CoStarSubmarketName NVARCHAR(100) NULL,
    CoStarMarketName NVARCHAR(100) NULL,
    CONSTRAINT PK_CoStarProperty PRIMARY KEY (ID),
    CONSTRAINT UQ_CoStarProperty_CoStarPropertyID UNIQUE (CoStarPropertyID),
    CONSTRAINT FK_CoStarProperty_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_CoStarProperty_SecondaryParcel FOREIGN KEY (CoStarSecondaryParcelID) REFERENCES indiana_tax.Parcel(ID)
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar''s own stable property identifier (their own "PropertyID" field) -- the natural key for this table, unique across all 8 imported export files.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarPropertyID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Which of the 8 CoStar export files/size bands this property came from (e.g. "Multi-Family (100+ Units)") -- CoStar splits exports at 500 rows, so this is provenance, not a property-type classification (see CoStarPropertyType/CoStarSecondaryType for that).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'SourceExportFile';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Marion County Parcel matched from CoStar''s "Parcel Number 1(Min)" (or, failing that, address). NULL means no match was found -- the row is still kept, not dropped. For a multi-parcel property (see CoStarIsMultiParcel) this is only ONE of the constituent parcels -- do not treat its AV as representing the whole property.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'ParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Marion County Parcel matched from CoStar''s "Parcel Number 2(Max)", when it differs from ParcelID and itself resolves to a real parcel. NULL does not mean no second parcel exists -- CoStar''s Min/Max is an outer bound, not a full membership list (see this migration''s header comment); it means we could not resolve the Max end specifically.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarSecondaryParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'True when CoStar''s own "Parcel Number 1(Min)" and "Parcel Number 2(Max)" differ -- CoStar''s signal that this property spans more than one parcel. Any per-unit/per-key/per-SF assessed-value figure derived from this row should be flagged as partial/incomplete when this is true, since we generally cannot enumerate every constituent parcel (see this migration''s header comment) and CoStarNumberOfUnits/CoStarRBA/CoStarRooms are whole-property aggregates that a single matched parcel''s AV does not fully cover.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarIsMultiParcel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'How ParcelID was resolved: ParcelNumberMin (exact match on the stripped "Parcel Number 1(Min)"), ParcelNumberMax (Min failed, Max matched), Address (both parcel-number attempts failed, a normalized-address match succeeded), or NULL (nothing matched).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'MatchMethod';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Property Address".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarAddress';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Property Name".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarPropertyName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Property Type" (e.g. Multifamily, Office, Retail, Industrial, Hospitality).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarPropertyType';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Secondary Type" -- a finer-grained classification than CoStarPropertyType.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarSecondaryType';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "City".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarCity';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "State".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarState';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Zip".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarZip';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "County Name".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarCountyName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Latitude".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLatitude';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Longitude".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLongitude';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Parcel Number 1(Min)", raw as exported (with punctuation, e.g. "49-11-01-240-261.002-101") -- kept for audit; ParcelID is the resolved match after stripping punctuation.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarParcelNumberMin';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Parcel Number 2(Max)", raw as exported. Equal to CoStarParcelNumberMin for a single-parcel property; different for a multi-parcel one (see CoStarIsMultiParcel).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarParcelNumberMax';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Owner Name" -- CoStar carries three distinct owner fields (this one, RecordedOwnerName, TrueOwnerName) that routinely disagree (e.g. a management company name here vs. the actual holding LLC in RecordedOwnerName) -- do not assume they match each other or indiana_tax.CountyAssessorRecord.OwnerName.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarOwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Recorded Owner Name" -- see CoStarOwnerName''s comment on why this often differs from it.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarRecordedOwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "True Owner Name" -- see CoStarOwnerName''s comment.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarTrueOwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Number of Units" -- whole-property unit count for multifamily/student housing, the correct denominator for a per-unit comparison (see CoStarIsMultiParcel for why the AV numerator may only be partial).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarNumberOfUnits';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Rooms" -- whole-property room/key count for hospitality properties.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarRooms';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "RBA" (Rentable Building Area, SF) -- whole-property building square footage for office/industrial/retail.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarRBA';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Total Buildings" -- number of distinct buildings on the property (independent of parcel count).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarTotalBuildings';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Land Area (AC)".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLandAreaAcres';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Land Area (SF)".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLandAreaSF';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Number of Stories".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarNumberOfStories';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Year Built".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarYearBuilt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Year Renovated".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarYearRenovated';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Building Class" (A/B/C).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarBuildingClass';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Star Rating" (1-5).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarStarRating';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Last Sale Price".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLastSalePrice';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Last Sale Date".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarLastSaleDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "For Sale Price" -- current asking price, if actively listed (see CoStarForSaleStatus).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarForSalePrice';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "For Sale Price Per Unit".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarForSalePricePerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "For Sale Price Per SF".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarForSalePricePerSF';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "For Sale Price Per Room" -- hospitality only.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarForSalePricePerRoom';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "For Sale Status".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarForSaleStatus';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Cap Rate", already a plain decimal percentage (e.g. 6.12 means 6.12%), not a 0-1 fraction.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarCapRate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Taxes Total" -- CoStar''s own figure for this property''s total tax bill, useful as an independent cross-check against indiana_tax.TaxHistoryYear/CountyAssessorRecord.NetAnnualTax for the matched parcel(s).', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarTaxesTotal';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Taxes Per SF".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarTaxesPerSF';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Tax Year" -- the year CoStarTaxesTotal/CoStarTaxesPerSF apply to; compare against indiana_tax.Assessment.AssessmentYear before treating the two sources as describing the same year.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarTaxYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Avg Asking/SF".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarAvgAskingPerSF';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Avg Asking/Unit".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarAvgAskingPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Avg Effective/SF".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarAvgEffectivePerSF';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Avg Effective/Unit".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarAvgEffectivePerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Percent Leased", already a plain decimal percentage.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarPercentLeased';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Vacancy %", already a plain decimal percentage.', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarVacancyPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Days On Market".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarDaysOnMarket';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Submarket Name".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarSubmarketName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CoStar "Market Name".', @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CoStarProperty', @level2type = N'COLUMN', @level2name = N'CoStarMarketName';
GO
