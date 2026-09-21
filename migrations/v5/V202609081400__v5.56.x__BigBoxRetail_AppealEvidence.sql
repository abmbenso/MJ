/* ============================================================================
   Big Box Retail — Appeal evidence (ParcelTransfer, ParcelSettlement,
   ParcelBurdenShift, vwStoreAnalysis extension)
   v5.56.x

   Adds the parcel-level evidence produced by the Big Box Retail research
   project's record-card parsing and statutory screening
   (Big_Box_Retail/states/indiana/scripts/extract-sale-history.py and
   screen-burden-shift.py), and surfaces a per-store rollup of it on the
   existing analysis list view.

   Three kinds of evidence, deliberately kept in separate tables because
   conflating them would be a substantive error, not merely an untidy one:

     * ParcelTransfer    -- recorded conveyances. MARKET evidence.
     * ParcelSettlement  -- assessed values a county already conceded on
                            appeal. NOT market evidence; an assessment.
     * ParcelBurdenShift -- parcel-years where IC 6-1.1-15-17.2 puts the
                            burden of proof on the assessor.

   These are parcel-level while Store is store-level, and a store may cover
   several parcels. There is no Parcel table in this schema (Store.Parcels is
   a delimited list), so each row carries its own StateParcel key and a
   nullable StoreID resolved by the loader. StoreID is nullable on purpose:
   evidence for a parcel that is not attributed to a store is still worth
   holding, and must not be silently dropped.

   Deliberately isolated from indiana_tax -- no foreign keys either direction.

   CodeGen convention (per migrations/CLAUDE.md):
     * NO __mj_CreatedAt / __mj_UpdatedAt columns -- CodeGen adds + triggers them.
     * NO foreign key indexes -- CodeGen creates IDX_AUTO_MJ_FKEY_* automatically.
     * sp_addextendedproperty for every non-PK, non-FK column.
     * vwStoreAnalysis is hand-written (it pivots child tables into one wide
       per-store row), so it is dropped and recreated here rather than left
       to CodeGen.
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- ParcelTransfer: recorded conveyances read from the record card's
-- "Transfer of Ownership" table, plus the rare price quoted in a note.
-- ----------------------------------------------------------------------------

CREATE TABLE big_box_retail.ParcelTransfer (
    ID                UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StoreID           UNIQUEIDENTIFIER NULL,
    StateParcel       NVARCHAR(30)     NOT NULL,
    County            NVARCHAR(50)     NOT NULL,
    SaleDate          DATE             NULL,
    GranteeOrOwner    NVARCHAR(200)    NULL,
    DocID             NVARCHAR(50)     NULL,
    DeedCode          NVARCHAR(10)     NULL,
    BookPage          NVARCHAR(40)     NULL,
    SalePrice         MONEY            NULL,
    SalePSF           DECIMAL(10,2)    NULL,
    VacantOrImproved  NCHAR(1)         NULL,
    CompQuality       NVARCHAR(10)     NULL,
    CompNote          NVARCHAR(300)    NULL,
    PriceSource       NVARCHAR(30)     NULL,
    MultiParcel       BIT              NOT NULL DEFAULT 0,
    SourceFile        NVARCHAR(300)    NOT NULL,
    ImportedAt        DATETIMEOFFSET   NOT NULL,
    CONSTRAINT PK_ParcelTransfer PRIMARY KEY (ID),
    CONSTRAINT FK_ParcelTransfer_Store FOREIGN KEY (StoreID)
        REFERENCES big_box_retail.Store(ID),
    CONSTRAINT CK_ParcelTransfer_VacantOrImproved CHECK (VacantOrImproved IN (N'V', N'I')),
    CONSTRAINT CK_ParcelTransfer_CompQuality CHECK (CompQuality IN (N'usable', N'review'))
);
GO

-- ----------------------------------------------------------------------------
-- ParcelSettlement: what a county already conceded on a prior appeal.
-- ----------------------------------------------------------------------------

CREATE TABLE big_box_retail.ParcelSettlement (
    ID                    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StoreID               UNIQUEIDENTIFIER NULL,
    StateParcel           NVARCHAR(30)     NOT NULL,
    County                NVARCHAR(50)     NOT NULL,
    SettlementAV          MONEY            NULL,
    AgreedPSF             DECIMAL(10,2)    NULL,
    SettlementStatement   NVARCHAR(300)    NULL,
    Note                  NVARCHAR(500)    NULL,
    SourceFile            NVARCHAR(300)    NOT NULL,
    ImportedAt            DATETIMEOFFSET   NOT NULL,
    CONSTRAINT PK_ParcelSettlement PRIMARY KEY (ID),
    CONSTRAINT FK_ParcelSettlement_Store FOREIGN KEY (StoreID)
        REFERENCES big_box_retail.Store(ID)
);
GO

-- ----------------------------------------------------------------------------
-- ParcelBurdenShift: IC 6-1.1-15-17.2 screen, one row per parcel-year.
-- ----------------------------------------------------------------------------

CREATE TABLE big_box_retail.ParcelBurdenShift (
    ID                       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    StoreID                  UNIQUEIDENTIFIER NULL,
    StateParcel              NVARCHAR(30)     NOT NULL,
    County                   NVARCHAR(50)     NOT NULL,
    AssessmentYear           INT              NOT NULL,
    PropertyClass            NVARCHAR(10)     NULL,
    PriorAV                  MONEY            NOT NULL,
    CurrentAV                MONEY            NOT NULL,
    CertifiedAV              MONEY            NULL,
    AVIncrease               MONEY            NOT NULL,
    PctIncrease              DECIMAL(8,2)     NOT NULL,
    InRowPriorAV             MONEY            NULL,
    BaselineAgreement        NVARCHAR(30)     NOT NULL,
    ReasonCode               NVARCHAR(5)      NULL,
    Band                     NVARCHAR(60)     NOT NULL,
    Usability                NVARCHAR(10)     NOT NULL,
    AVStatus                 NVARCHAR(40)     NOT NULL,
    Actionable               BIT              NOT NULL DEFAULT 1,
    BuildingSqFt             INT              NULL,
    PriorAVPSF               DECIMAL(10,2)    NULL,
    CurrentAVPSF             DECIMAL(10,2)    NULL,
    Posture                  NVARCHAR(30)     NOT NULL,
    PriorSettlementAtOrBelow MONEY            NULL,
    ZoningExceptionUntested  BIT              NOT NULL DEFAULT 1,
    SourceFile               NVARCHAR(300)    NOT NULL,
    ImportedAt               DATETIMEOFFSET   NOT NULL,
    CONSTRAINT PK_ParcelBurdenShift PRIMARY KEY (ID),
    CONSTRAINT FK_ParcelBurdenShift_Store FOREIGN KEY (StoreID)
        REFERENCES big_box_retail.Store(ID),
    CONSTRAINT UQ_ParcelBurdenShift_Parcel_Year UNIQUE (StateParcel, AssessmentYear),
    CONSTRAINT CK_ParcelBurdenShift_Usability CHECK (Usability IN (N'usable', N'verify', N'reject')),
    CONSTRAINT CK_ParcelBurdenShift_Posture CHECK (Posture IN
        (N'revert-and-done', N'revert-then-argue', N'unknown - no building size')),
    CONSTRAINT CK_ParcelBurdenShift_BaselineAgreement CHECK (BaselineAgreement IN
        (N'corroborated', N'disputed', N'baseline unconfirmed')),
    CONSTRAINT CK_ParcelBurdenShift_AVStatus CHECK (AVStatus IN
        (N'stands', N'reduced after determination', N'already at or below prior year',
         N'no bill data'))
);
GO

-- ----------------------------------------------------------------------------
-- vwStoreAnalysis: carry the appeal evidence onto the list view.
--
-- Recreated in full from V202609072130 (its most recent definition) with the
-- rollup CTEs and columns added. Earlier migrations are not edited.
-- ----------------------------------------------------------------------------

CREATE OR ALTER VIEW big_box_retail.vwStoreAnalysis AS
WITH av AS (
    SELECT StoreID, AssessmentYear, TotalAV, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreAssessment
), tx AS (
    SELECT StoreID, PayYear, AnnualTax, IsComplete, Source, ParcelsCovered, ParcelsTotal
    FROM big_box_retail.StoreTax
), bs AS (
    -- Burden-shift rollup. Only the actionable, usable band: bands d-f are unverified
    -- or miscoded construction, and a parcel-year already reduced to at or below the
    -- prior year has no live increase left to argue.
    SELECT StoreID,
           COUNT(*)            AS ShiftYears,
           MAX(AssessmentYear) AS LatestShiftYear,
           SUM(AVIncrease)     AS ShiftAVAtStake,
           MAX(CASE WHEN Posture = N'revert-then-argue' THEN 1 ELSE 0 END) AS AnyArgue
    FROM big_box_retail.ParcelBurdenShift
    WHERE Usability = N'usable' AND Actionable = 1 AND StoreID IS NOT NULL
    GROUP BY StoreID
), st AS (
    SELECT StoreID,
           COUNT(*)          AS SettlementCount,
           MAX(SettlementAV) AS HighestSettlementAV,
           MIN(AgreedPSF)    AS LowestAgreedPSF
    FROM big_box_retail.ParcelSettlement
    WHERE StoreID IS NOT NULL
    GROUP BY StoreID
), cp AS (
    -- Comparable sales only. CompQuality = 'review' means the deed is not a market
    -- instrument or the $/SF falls outside the plausible band, so it must not feed a
    -- headline comp figure -- the row is still readable in ParcelTransfer.
    SELECT StoreID,
           COUNT(*)     AS UsableCompCount,
           MIN(SalePSF) AS LowestCompPSF,
           MAX(SaleDate) AS LatestCompDate
    FROM big_box_retail.ParcelTransfer
    WHERE CompQuality = N'usable' AND SalePSF IS NOT NULL AND StoreID IS NOT NULL
    GROUP BY StoreID
)
SELECT
    s.ID, s.Brand AS Occupant, s.OwnerNameAssessed AS AssessedOwner,
    s.TaxpayerName AS TaxpayerOfRecord, s.County, s.City, s.Address,
    s.Acres, s.YearBuilt AS Built,
    sf.SqFt AS SquareFeet,
    s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
    s.OwnershipStructure,
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN av.TotalAV END) AS AV2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN av.TotalAV END) AS AV2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN av.TotalAV END) AS AV2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN av.TotalAV END) AS AV2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN av.TotalAV END) AS AV2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN av.TotalAV END) AS AV2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN tx.AnnualTax END) AS Tax2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN tx.AnnualTax END) AS Tax2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN tx.AnnualTax END) AS Tax2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN tx.AnnualTax END) AS Tax2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN tx.AnnualTax END) AS Tax2026,
    -- Every ratio is gated three ways: s.UniformityEligible = 1 (added in
    -- V202609071850) so a shared/review-tier store never publishes a per-brand
    -- figure it cannot honestly claim; IsComplete = 1 so a partial sum of a
    -- multi-parcel store never becomes a ratio; and a strictly positive
    -- numerator and denominator, so neither a $0 assessed value nor a missing
    -- building area can produce a $0.00/sf "comparable".
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2021 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2021,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2022 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2022,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2023 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2023,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2024 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2024,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2025 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2025,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN av.AssessmentYear = 2026 AND av.IsComplete = 1 AND av.TotalAV > 0
                 THEN av.TotalAV END) / sf.SqFt END AS AVPerSF2026,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2022 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2022,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2023 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2023,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2024 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2024,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2025 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2025,
    CASE WHEN sf.SqFt > 0 AND s.UniformityEligible = 1 THEN
        MAX(CASE WHEN tx.PayYear = 2026 AND tx.IsComplete = 1 AND tx.AnnualTax > 0
                 THEN tx.AnnualTax END) / sf.SqFt END AS TaxPerSF2026,
    -- Provenance per year. 2021-2022 AV comes from TAXDATA's *billing* AV rather than
    -- a PRC -- a related but not identical measure -- so a cross-year comparison has to
    -- be readable as such. Default-hidden in the grid; available in the column chooser.
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN av.Source END) AS AVSource2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN av.Source END) AS AVSource2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN av.Source END) AS AVSource2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN av.Source END) AS AVSource2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN av.Source END) AS AVSource2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN av.Source END) AS AVSource2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN tx.Source END) AS TaxSource2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN tx.Source END) AS TaxSource2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN tx.Source END) AS TaxSource2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN tx.Source END) AS TaxSource2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN tx.Source END) AS TaxSource2026,
    -- Square-footage provenance and completeness. Aggregates here are all MAX()
    -- deliberately: av and tx are joined independently, so the two produce a
    -- cartesian product per store and any SUM/COUNT/STRING_AGG would multiply.
    -- MAX over a per-year CASE is immune to that; every one of these is constant
    -- within its year, so MAX is the value itself.
    s.TotalBuildingSqFt AS RosterSquareFeet,
    s.AttributedBuildingSqFt AS AttributedSquareFeet,
    MAX(av.ParcelsTotal) AS ParcelsTotal,
    MAX(CASE WHEN av.AssessmentYear = 2021 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2021,
    MAX(CASE WHEN av.AssessmentYear = 2022 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2022,
    MAX(CASE WHEN av.AssessmentYear = 2023 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2023,
    MAX(CASE WHEN av.AssessmentYear = 2024 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2024,
    MAX(CASE WHEN av.AssessmentYear = 2025 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2025,
    MAX(CASE WHEN av.AssessmentYear = 2026 THEN CAST(av.IsComplete AS INT) END) AS AVComplete2026,
    MAX(CASE WHEN tx.PayYear = 2022 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2022,
    MAX(CASE WHEN tx.PayYear = 2023 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2023,
    MAX(CASE WHEN tx.PayYear = 2024 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2024,
    MAX(CASE WHEN tx.PayYear = 2025 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2025,
    MAX(CASE WHEN tx.PayYear = 2026 THEN CAST(tx.IsComplete AS INT) END) AS TaxComplete2026,
    -- Appeal evidence, rolled up from the parcel-level tables. Aggregates are wrapped
    -- so the GROUP BY above is unaffected.
    MAX(bs.ShiftYears)          AS BurdenShiftYears,
    MAX(bs.LatestShiftYear)     AS LatestBurdenShiftYear,
    MAX(bs.ShiftAVAtStake)      AS BurdenShiftAVAtStake,
    CASE WHEN MAX(bs.AnyArgue) = 1  THEN N'revert-then-argue'
         WHEN MAX(bs.ShiftYears) > 0 THEN N'revert-and-done' END AS BurdenShiftPosture,
    MAX(st.SettlementCount)     AS SettlementCount,
    MAX(st.HighestSettlementAV) AS HighestSettlementAV,
    MIN(st.LowestAgreedPSF)     AS LowestAgreedPSF,
    MAX(cp.UsableCompCount)     AS UsableCompCount,
    MIN(cp.LowestCompPSF)       AS LowestCompPSF,
    MAX(cp.LatestCompDate)      AS LatestCompDate
FROM big_box_retail.Store s
CROSS APPLY (SELECT SqFt = COALESCE(s.AttributedBuildingSqFt, s.TotalBuildingSqFt)) sf
LEFT JOIN av ON av.StoreID = s.ID
LEFT JOIN tx ON tx.StoreID = s.ID
LEFT JOIN bs ON bs.StoreID = s.ID
LEFT JOIN st ON st.StoreID = s.ID
LEFT JOIN cp ON cp.StoreID = s.ID
WHERE s.IsPrimaryRow = 1
GROUP BY s.ID, s.Brand, s.OwnerNameAssessed, s.TaxpayerName, s.County, s.City,
         s.Address, s.Acres, s.YearBuilt, s.TotalBuildingSqFt, s.AttributedBuildingSqFt,
         sf.SqFt, s.AttributionTier, s.UniformityEligible, s.EconomicUnitReview,
         s.OwnershipStructure;
GO

-- ----------------------------------------------------------------------------
-- Column documentation for vwStoreAnalysis
--
-- Re-emitted verbatim from V202609072130 because ALTER VIEW drops a view's
-- column extended properties: recreating the view above would otherwise
-- silently erase 61 field descriptions from the entity. The ten new
-- appeal-evidence columns are documented at the end of this block.
--
-- CodeGen resolves a view-backed entity's field descriptions from the VIEW's
-- extended properties (__mj.vwSQLColumnsAndEntityFields COALESCEs EP_View over
-- EP_Table), so these must be attached at @level1type = N'VIEW'. Each is dropped
-- first so this migration is safe to re-run against a partially-documented view.
-- Run `npx mj sync push` then `npx mj codegen` afterwards to land them on
-- EntityField.Description.
-- -----------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'ID')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'ID';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store primary key (big_box_retail.Store.ID). One row per PRIMARY roster row: the view is filtered to Store.IsPrimaryRow = 1, so the 37 duplicate roster rows (the same store carried under a second address) are excluded and each store''s figures count exactly once.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Occupant')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Occupant';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Retail brand operating at this address (Store.Brand). Called Occupant rather than Owner because the operator and the assessed owner are frequently different parties -- see AssessedOwner and TaxpayerOfRecord.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Occupant';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AssessedOwner')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AssessedOwner';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Owner name as carried on the county''s assessment record for this store''s parcels (Store.OwnerNameAssessed), pipe-joined when a multi-parcel store''s parcels carry different owners. County assessment records lag conveyances, so this is the owner of record for assessment purposes, not necessarily the current titleholder.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AssessedOwner';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxpayerOfRecord')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxpayerOfRecord';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxpayer of record from the DLGF tax-bill extract for the most recent pay year available, joined across this store''s attribution-resolved parcels. This is the party the bill is actually sent to, and can differ from AssessedOwner (a net-leased tenant billed directly, for example).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxpayerOfRecord';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'County')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'County';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indiana county the store sits in. Determines the assessing and taxing jurisdiction, and which county source supplied the figures in this row.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'County';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'City')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'City';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City or town of the store''s situs address.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'City';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Address')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Address';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Situs street address of the store as carried on the roster. It is the roster address, not necessarily the address printed on the county''s tax bill for the same parcel.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Address';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Acres')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Acres';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total land area, in acres, across this store''s attribution-resolved parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Acres';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Built')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Built';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earliest year_built across this store''s parcels (Store.YearBuilt). For effective age -- the figure a cost-approach argument turns on -- see Store.EffectiveYear, which follows the largest building on the store''s parcels rather than the oldest structure on any of them.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Built';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'SquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'SquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area used as the denominator of EVERY per-square-foot ratio in this view: COALESCE(Store.AttributedBuildingSqFt, Store.TotalBuildingSqFt). For the stores whose roster parcel list was narrowed by attribution it is the area of the resolved parcels only; for every other store it is the roster figure. See RosterSquareFeet and AttributedSquareFeet for which one is in play.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'SquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AttributionTier')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AttributionTier';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'How confidently this store''s assessed value can be attributed to this brand''s building. clean = one parcel, one brand. brand-parcel = several parcels, narrowed to the ground the brand owns or to its unshared parcels. summed = several parcels, one owner, none shared. review = several owners, none of them the brand -- the brand''s building cannot be isolated from a landlord''s outlot or a neighbour''s. shared = a parcel carries more than one roster brand, so one assessment covers several stores. Only clean, brand-parcel and summed are uniformity-eligible.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AttributionTier';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'UniformityEligible')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'UniformityEligible';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when this store''s assessed value and building area describe the same thing well enough to use the store as a uniformity comparable (AttributionTier in clean, brand-parcel, summed). Every per-square-foot ratio in this view is blank when this is 0: a shared-parcel anchor''s AV/SF cannot be honestly computed, so it is withheld rather than shown wrong.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'UniformityEligible';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'EconomicUnitReview')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'EconomicUnitReview';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when this store''s parcels look like part of a larger economic unit -- typically adjoining vacant acreage under common ownership that an assessor or an appeal may treat as one property. A flag for human review, not a conclusion.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'EconomicUnitReview';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'OwnershipStructure')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Heuristic inference of whether the store appears owner-occupied or leased/investor-held, from comparing the county''s assessed owner name against the brand name (''likely owner-occupied'' / ''likely leased/investor'', or ''mixed'' when a multi-parcel store''s parcels disagree). This is an ownership-structure heuristic only -- it is NOT an occupancy or dark-store (vacant/operating) indicator, and no vacancy data feeds it.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'OwnershipStructure';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2021 (assessment date in 2021), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2021 is Tax2022, not Tax2021. Check AVComplete2021 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2022 (assessment date in 2022), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2022 is Tax2023, not Tax2022. Check AVComplete2022 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2023 (assessment date in 2023), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2023 is Tax2024, not Tax2023. Check AVComplete2023 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2024 (assessment date in 2024), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2024 is Tax2025, not Tax2024. Check AVComplete2024 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2025 (assessment date in 2025), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2025 is Tax2026, not Tax2025. Check AVComplete2025 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AV2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AV2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total assessed value for ASSESSMENT year 2026 (assessment date in 2026), summed across this store''s attribution-resolved parcels. Mind the year convention: the AV columns are ASSESSMENT years and the adjacent Tax columns are PAY years -- the bill for assessment year 2026 is Tax2027, not Tax2026. Check AVComplete2026 before using this figure: an incomplete multi-parcel year still shows its PARTIAL sum here, and only the ratio is suppressed.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AV2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2022 -- which is the bill for ASSESSMENT year 2021 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2022 and AV2022 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2022. Check TaxComplete2022: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2023 -- which is the bill for ASSESSMENT year 2022 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2023 and AV2023 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2023. Check TaxComplete2023: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2024 -- which is the bill for ASSESSMENT year 2023 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2024 and AV2024 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2024. Check TaxComplete2024: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2025 -- which is the bill for ASSESSMENT year 2024 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2025 and AV2025 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2025. Check TaxComplete2025: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'Tax2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'Tax2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total annual property tax billed in PAY year 2026 -- which is the bill for ASSESSMENT year 2025 -- summed across this store''s attribution-resolved parcels. Do NOT read Tax2026 and AV2026 as the same year: they sit in adjacent columns and describe different years. Precedence prefers the county treasurer''s currently billed figure over DLGF''s as-originally-certified figure; see TaxSource2026. Check TaxComplete2026: an incomplete multi-parcel year still shows its PARTIAL sum here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'Tax2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2021: AV2021 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2021 = 1, and both AV2021 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2022: AV2022 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2022 = 1, and both AV2022 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2023: AV2023 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2023 = 1, and both AV2023 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2024: AV2024 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2024 = 1, and both AV2024 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2025: AV2025 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2025 = 1, and both AV2025 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVPerSF2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVPerSF2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assessed value per square foot for ASSESSMENT year 2026: AV2026 / SquareFeet. Blank unless UniformityEligible = 1, AVComplete2026 = 1, and both AV2026 and SquareFeet are strictly positive -- the ratio is omitted rather than published wrong. The positive check matters: a county form that carried no assessed value for a year parses as $0, and $0.00/sf must never appear as a comparable.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVPerSF2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2022 (the bill for ASSESSMENT year 2021): Tax2022 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2022 = 1, and both Tax2022 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2022 and AVPerSF2022 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2023 (the bill for ASSESSMENT year 2022): Tax2023 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2023 = 1, and both Tax2023 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2023 and AVPerSF2023 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2024 (the bill for ASSESSMENT year 2023): Tax2024 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2024 = 1, and both Tax2024 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2024 and AVPerSF2024 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2025 (the bill for ASSESSMENT year 2024): Tax2025 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2025 = 1, and both Tax2025 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2025 and AVPerSF2025 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxPerSF2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxPerSF2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Property tax per square foot for PAY year 2026 (the bill for ASSESSMENT year 2025): Tax2026 / SquareFeet. Blank unless UniformityEligible = 1, TaxComplete2026 = 1, and both Tax2026 and SquareFeet are strictly positive. Note this column is keyed on a PAY year while the AVPerSF columns are keyed on ASSESSMENT years, so TaxPerSF2026 and AVPerSF2026 are one year apart.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxPerSF2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2021. For 2021 this is overwhelmingly dlgf_taxdata -- the DLGF tax bill''s BILLING net assessed value, NOT a county property record card figure. It is a related but not identical measure to the PRC-sourced 2023+ values, so a 2021-to-2025 trend crosses a source seam and should be read as such. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2022. For 2022 this is overwhelmingly dlgf_taxdata -- the DLGF tax bill''s BILLING net assessed value, NOT a county property record card figure. It is a related but not identical measure to the PRC-sourced 2023+ values, so a 2021-to-2025 trend crosses a source seam and should be read as such. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2023: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2024: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2025: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVSource2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVSource2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied AV2026: county_prc (county property record card, the preferred source), hamilton_api, dlgf_crosswalk_2025, or dlgf_taxdata (DLGF BILLING net assessed value, the fallback -- a related but not identical measure to a PRC figure). Sources are '';''-joined when a multi-parcel store''s parcels were satisfied differently. A [caveat:dlgf_net_av_may_overstate] suffix marks the 17 parcels whose DLGF net AV runs 7-43% above the treasurer''s taxable AV.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVSource2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2022: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2023: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2024: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2025: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxSource2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxSource2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Which source supplied Tax2026: treasurer_scraped (the county treasurer''s currently billed figure, preferred because counties post corrections after certification), marion_taxhist, hamilton_statement, or dlgf_taxdata (as originally certified -- the fallback, and the only source for pay years 2022 and 2023, which predate the scraping). A bracketed suffix records how a scraped bill''s installments were reconciled against the bill''s own stated annual total: [installments_repeat_annual] means the treasurer''s page printed the annual figure in BOTH installment boxes, so the bill''s stated total was used instead of their sum; [installments_disagree_with_bill_total] means the two installments summed to more or less than the stated annual (typically a fee or a delinquent prior-year balance riding on an installment) and the stated annual was used.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxSource2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'RosterSquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'RosterSquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area from the roster across ALL parcels originally mapped to this address, including any that attribution later excluded. Provenance only -- never used in a ratio. Where this differs from SquareFeet, AttributedSquareFeet is why.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'RosterSquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AttributedSquareFeet')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AttributedSquareFeet';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Building area of ONLY the attribution-resolved parcels. Populated for the stores whose parcel list was narrowed (a brand-owned box separated from the surrounding mall, say) and NULL for every store where the roster list already described the store. When non-NULL this is what SquareFeet uses.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AttributedSquareFeet';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'ParcelsTotal')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'ParcelsTotal';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of parcels making up this store after attribution resolution -- the denominator behind the AVComplete/TaxComplete flags. A store-year is complete only when all ParcelsTotal parcels reported a figure for that year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'ParcelsTotal';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2021')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2021';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2021; 0 when only some did. AV2021 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2021 is suppressed whenever this is 0. NULL means the store has no 2021 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2021';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2022; 0 when only some did. AV2022 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2022 is suppressed whenever this is 0. NULL means the store has no 2022 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2023; 0 when only some did. AV2023 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2023 is suppressed whenever this is 0. NULL means the store has no 2023 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2024; 0 when only some did. AV2024 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2024 is suppressed whenever this is 0. NULL means the store has no 2024 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2025; 0 when only some did. AV2025 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2025 is suppressed whenever this is 0. NULL means the store has no 2025 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'AVComplete2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'AVComplete2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported an assessed value for ASSESSMENT year 2026; 0 when only some did. AV2026 still shows the PARTIAL sum when this is 0 -- making that visible is exactly what this flag is for, because a partial sum is indistinguishable from a whole one in an exported sheet. AVPerSF2026 is suppressed whenever this is 0. NULL means the store has no 2026 assessment row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'AVComplete2026';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2022')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2022';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2022; 0 when only some did. Tax2022 still shows the PARTIAL sum when this is 0, and TaxPerSF2022 is suppressed. NULL means the store has no 2022 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2022';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2023')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2023';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2023; 0 when only some did. Tax2023 still shows the PARTIAL sum when this is 0, and TaxPerSF2023 is suppressed. NULL means the store has no 2023 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2023';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2024')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2024';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2024; 0 when only some did. Tax2024 still shows the PARTIAL sum when this is 0, and TaxPerSF2024 is suppressed. NULL means the store has no 2024 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2024';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2025')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2025';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2025; 0 when only some did. Tax2025 still shows the PARTIAL sum when this is 0, and TaxPerSF2025 is suppressed. NULL means the store has no 2025 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2025';
GO

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'TaxComplete2026')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'TaxComplete2026';
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 when every one of this store''s ParcelsTotal parcels reported a tax figure for PAY year 2026; 0 when only some did. Tax2026 still shows the PARTIAL sum when this is 0, and TaxPerSF2026 is suppressed. NULL means the store has no 2026 tax row at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'TaxComplete2026';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'BurdenShiftYears')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'BurdenShiftYears';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Count of assessment years in which IC 6-1.1-15-17.2 puts the burden of proof on the assessor for this store: an increase over 5% not attributable to new construction, a use change, or a parcel split/combination. Counts only the actionable, usable band -- unverified and miscoded-construction bands are excluded, as are years already reduced to at or below the prior year. NULL means no such year was found.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftYears';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'LatestBurdenShiftYear')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'LatestBurdenShiftYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Most recent assessment year carrying a burden shift. The appeal cycle this store is live for.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'LatestBurdenShiftYear';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'BurdenShiftAVAtStake')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'BurdenShiftAVAtStake';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sum of the assessed-value increases across this stores burden-shifted years. What reverting to the prior year would remove from the assessment, before any further market argument.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftAVAtStake';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'BurdenShiftPosture')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'BurdenShiftPosture';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What winning the burden argument alone would achieve. "revert-and-done" -- the prior year is already at or below the $50/SF Indiana big-box benchmark, so reverting lands an acceptable value. "revert-then-argue" -- the prior year is still above benchmark, so the burden shift is the opening and market evidence is still needed underneath it.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'BurdenShiftPosture';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'SettlementCount')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'SettlementCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of prior appeal settlements read from this stores record cards -- values the county has already conceded. NOT sale evidence: a settlement is an assessed value, and citing one as a comparable sale would be wrong.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'SettlementCount';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'HighestSettlementAV')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'HighestSettlementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest total assessed value the county has previously agreed to on this store, from an assessor note recording an agreement, stipulation, PTABOA reduction or Form 115 determination.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'HighestSettlementAV';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'LowestAgreedPSF')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'LowestAgreedPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest settlement this store has on record expressed as a rate per square foot, where the assessors note stated one directly (e.g. "APPEAL ADJUSTED TO $44.00 SQ. FT."). The most directly usable form of a settlement, because it speaks in the same units as the benchmark.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'LowestAgreedPSF';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'UsableCompCount')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'UsableCompCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of this stores own recorded transfers that pass the comparable screen -- a market deed instrument and a $/SF inside the plausible band. Transfers failing the screen (quit claims, sheriffs deeds, outlot conveyances, portfolio sales) are held in ParcelTransfer but excluded here.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'UsableCompCount';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'LowestCompPSF')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'LowestCompPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest price per square foot among this stores usable recorded sales. Indiana imposes no statutory limit on comparable-sale recency, so an older sale is adjusted for market conditions rather than excluded.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'LowestCompPSF';

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
             AND minor_id = (SELECT column_id FROM sys.columns
                             WHERE object_id = OBJECT_ID('big_box_retail.vwStoreAnalysis')
                               AND name = 'LatestCompDate')
             AND name = 'MS_Description')
    EXEC sp_dropextendedproperty @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'big_box_retail',
        @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
        @level2type = N'COLUMN', @level2name = N'LatestCompDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the most recent usable recorded sale on this stores parcels.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreAnalysis',
    @level2type = N'COLUMN', @level2name = N'LatestCompDate';

GO


-- ----------------------------------------------------------------------------
-- Column documentation for the new tables
-- ----------------------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The 18-digit Indiana state parcel number this transfer was recorded against, as printed on the record card.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'StateParcel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana county whose record card this transfer was read from.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'County';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the recorded conveyance. NULL where the card carries the county null date 01/01/1900, which marks a transfer with no recorded date rather than a 1900 sale -- the row is retained so the conveyance is still visible.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'SaleDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Grantee, or the owner name the card records against the transfer. Truncated by the card itself in most counties.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'GranteeOrOwner';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Instrument reference as printed in the cards Doc ID column. Some counties print text here (e.g. "PLAT TRACK") rather than a number.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'DocID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deed instrument code exactly as the card prints it, including the truncations narrow columns force -- "Qu" for quit claim, "Sh" for sheriff, "Li" for limited warranty. Not normalised, because the truncation is what the source says.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'DeedCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Recording book and page, or the countys instrument number.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'BookPage';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Adjusted sale price as recorded. NULL where the card shows no price -- most notably Hamilton, whose transfer table has no price column at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'SalePrice';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Sale price divided by the building area attributed to the parcel. Meaningful only alongside CompQuality: an outlot conveyance recorded against a parcel whose square footage is the whole store produces a misleadingly low figure.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'SalePSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The V/I column: whether the property was Vacant or Improved at the time of sale. This is NOT a sale validity flag, and per this projects standing rule a county validity marker is never used to screen comparables.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'VacantOrImproved';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this transfer is usable as a comparable sale: "usable", or "review" where the deed is not a market instrument or the $/SF falls outside the plausible band. Advisory -- it flags, it never excludes, and CompNote gives the reason.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'CompQuality';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Why a transfer was marked for review -- non-market instrument, unclassified deed code, missing building size, or a $/SF above or below the plausible band.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'CompNote';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Where the price was read from: the cards transfer table, or a free-text assessor note.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'PriceSource';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Set where the source note says the price covers more than this parcel (e.g. "MULTI PARCEL SALE ($4,450,000) INCLUDES 020.000"). Such a price does not belong to this parcel alone.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'MultiParcel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Record card the transfer was parsed from, relative to the projects county-records directory.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'SourceFile';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this row was loaded from the parsing pipeline.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelTransfer',
    @level2type = N'COLUMN', @level2name = N'ImportedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The 18-digit Indiana state parcel number this settlement was recorded against.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'StateParcel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana county whose record card the settlement note was read from.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'County';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value a prior appeal settled at, read from an assessor note recording an agreement, stipulation, PTABOA reduction or Form 115 determination. This is an ASSESSED VALUE, not a sale price -- treating it as market evidence would be a substantive error.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'SettlementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A settlement the assessor stated directly as a rate per square foot (e.g. "APPEAL ADJUSTED TO $44.00 SQ. FT."). The most directly usable form, because it is already in benchmark units.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'AgreedPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The matched phrase and figure alone -- the trigger word through the amount. Used to de-duplicate, because the same settlement is reprinted on every later card with different surrounding text.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'SettlementStatement';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The surrounding note text, kept so the finding stays auditable against the card.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'Note';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Record card the settlement was parsed from, relative to the projects county-records directory.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'SourceFile';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this row was loaded from the parsing pipeline.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement',
    @level2type = N'COLUMN', @level2name = N'ImportedAt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The 18-digit Indiana state parcel number screened.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'StateParcel';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indiana county the parcel sits in.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'County';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessment year whose increase is being tested against the prior year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'DLGF property class code for the parcel in this year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'PropertyClass';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The prior years assessed value, taken from that years own statewide harvest file rather than the current rows PRIOR_AV field. The file value is independently observed and reconciled 92.5% exact against this projects DLGF extraction; in-row PRIOR_AV is sometimes self-copied from the current year (hiding a real increase) and sometimes sits below the prior years certified value (manufacturing one).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'PriorAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed value as initially determined for this year -- the figure a Form 11 notice carries, and the one that triggers the appeal.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'CurrentAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Assessed value as finally certified for billing, from this projects own DLGF Gateway extraction. Lower than CurrentAV where an appeal already obtained a reduction. NULL where no bill row exists for the parcel-year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'CertifiedAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'CurrentAV less PriorAV: the increase the assessor would have to justify.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'AVIncrease';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The increase as a percentage. Held to two decimals so a case just over the statutory 5% does not display as exactly 5.0.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'PctIncrease';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The prior years value as recorded in this rows own PRIOR_AV fields, kept for corroboration. NULL where it was self-copied from the current year and therefore carries no information.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'InRowPriorAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the two readings of the prior year agree that the 5% threshold is crossed: "corroborated", "disputed" (forced to Usability = verify), or "baseline unconfirmed" where no in-row value survives.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'BaselineAgreement';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'DLGF Code List 5 reason for change. Rows carrying a statutory exception (new construction, addition, reclassification of use) or a split/combination are not emitted at all.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'ReasonCode';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Magnitude band. The reason code is not trustworthy at the extremes -- counties routinely code new construction as 17 Miscellaneous or 19 Annual Adjustment -- so every parcel-year is additionally banded by how far it moved.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'Band';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'"usable" for bands a-c; "verify" for band d or a disputed baseline, meaning check the record card first; "reject" for bands e-f, which are construction whatever the reason code says.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'Usability';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'What became of the determined value: "stands" (no reduction obtained), "reduced after determination" (an appeal cut it, CertifiedAV says by how much), "already at or below prior year" (the increase was fully given back), or "no bill data".',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'AVStatus';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Cleared where the increase was already given back in full, so the burden shift has no live value on this parcel-year.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'Actionable';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Building area used for the per-square-foot figures below.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'BuildingSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The prior years assessed value per square foot -- the value reverting would land, and therefore the number that decides whether the burden argument alone is enough.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'PriorAVPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The current determined assessed value per square foot.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'CurrentAVPSF';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'"revert-and-done" where PriorAVPSF is already at or below the $50/SF Indiana big-box benchmark, so the burden argument alone lands an acceptable value; "revert-then-argue" where it is not, and market evidence is still needed underneath the shift.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'Posture';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest prior settlement on this parcel at or below the prior year AV, where one exists. The county has already conceded a value it now exceeds -- the strongest form of this case.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'PriorSettlementAtOrBelow';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Always set. A zoning change is a statutory exception to the burden shift, but zoning has no DLGF code, so this exception cannot be tested from data and must be checked per parcel before filing.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'ZoningExceptionUntested';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Screen output the row was loaded from.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'SourceFile';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this row was loaded from the screening pipeline.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelBurdenShift',
    @level2type = N'COLUMN', @level2name = N'ImportedAt';

GO
