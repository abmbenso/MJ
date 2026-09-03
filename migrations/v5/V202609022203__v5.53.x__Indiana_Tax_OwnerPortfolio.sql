/* ============================================================================
   Indiana Property Tax Expert — Owner Portfolios  (Owner Prospects dashboard)
   v5.53.x

   Persisted form of scripts/build-owner-portfolios.js's owners.json so the MJ
   Explorer "Owner Prospects" dashboard reads live entities via RunView instead
   of a baked Artifact. Written FROM the portfolio job (delete + reinsert of the
   newest run, keyed by RunID); read-only on the dashboard side. NOT commingled
   with researched assessment facts — pure roll-up output.

   3 entities:
     OwnerPortfolioRun     -- one row per build-owner-portfolios.js run (+ county C&I rollup)
     OwnerPortfolio        -- one row per operating-company owner group in a run
     OwnerPortfolioParcel  -- one row per parcel in an owner group
   ============================================================================ */

/* -------------------------------------------------------------------------- */
/* OwnerPortfolioRun                                                          */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.OwnerPortfolioRun (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    RunDate DATETIMEOFFSET NOT NULL,
    MethodologyVersion NVARCHAR(60) NOT NULL,
    IsLatest BIT NOT NULL CONSTRAINT DF_OwnerPortfolioRun_IsLatest DEFAULT (0),

    CountyParcelCount INT NULL,
    CountyTotalAV2025 DECIMAL(18, 2) NULL,
    CountyTotalAV2026 DECIMAL(18, 2) NULL,
    CountyYoYDollars DECIMAL(18, 2) NULL,
    CountyYoYPct DECIMAL(9, 4) NULL,
    CountyParcelsUp5 INT NULL,
    CountyParcelsUp10 INT NULL,
    CountyParcelsUp25 INT NULL,
    CountyParcelsUp50 INT NULL,
    CountyParcelsDown INT NULL,
    CountyByTypeJSON NVARCHAR(MAX) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolioRun_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolioRun_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_OwnerPortfolioRun PRIMARY KEY (ID)
);
GO

/* -------------------------------------------------------------------------- */
/* OwnerPortfolio                                                             */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.OwnerPortfolio (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    RunID UNIQUEIDENTIFIER NOT NULL,

    OwnerKey NVARCHAR(200) NOT NULL,
    Label NVARCHAR(300) NOT NULL,
    Kind NVARCHAR(20) NOT NULL,
    Tier NVARCHAR(12) NULL,
    GroupKeyType NVARCHAR(12) NULL,
    CoStarTrueOwner NVARCHAR(300) NULL,

    ParcelCount INT NOT NULL,
    DistinctEntities INT NULL,
    TotalAV DECIMAL(18, 2) NULL,
    TotalAV2025 DECIMAL(18, 2) NULL,
    TotalAV2026 DECIMAL(18, 2) NULL,
    AVYoYDollars DECIMAL(18, 2) NULL,
    AVYoYPct DECIMAL(9, 4) NULL,
    ParcelsUp10 INT NULL,
    ParcelsUp25 INT NULL,
    TotalUnits INT NULL,
    TotalSqFt BIGINT NULL,

    NAppealRec INT NULL,
    NTwoSupport INT NULL,
    NHighConfAppeal INT NULL,
    EstSavingsAtAsk DECIMAL(18, 2) NULL,
    EstSavingsAtFloor DECIMAL(18, 2) NULL,
    AppealedParcels INT NULL,
    HistoricalReductionWon DECIMAL(18, 2) NULL,
    AppealYears NVARCHAR(20) NULL,
    MostRecentAppealYear INT NULL,
    LikelyRep NVARCHAR(200) NULL,
    RepStatus NVARCHAR(120) NOT NULL,
    RepsOnReductionJSON NVARCHAR(MAX) NULL,
    IsFreshProspect BIT NOT NULL CONSTRAINT DF_OwnerPortfolio_Fresh DEFAULT (0),
    MailAddress NVARCHAR(400) NULL,
    ByTypeJSON NVARCHAR(MAX) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolio_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolio_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_OwnerPortfolio PRIMARY KEY (ID),
    CONSTRAINT FK_OwnerPortfolio_Run FOREIGN KEY (RunID) REFERENCES indiana_tax.OwnerPortfolioRun (ID),
    CONSTRAINT CK_OwnerPortfolio_Kind CHECK (Kind IN ('Company','Individual','Government','Institution'))
);
GO
CREATE INDEX IX_OwnerPortfolio_Run ON indiana_tax.OwnerPortfolio (RunID);
CREATE INDEX IX_OwnerPortfolio_OwnerKey ON indiana_tax.OwnerPortfolio (OwnerKey);
GO

/* -------------------------------------------------------------------------- */
/* OwnerPortfolioParcel                                                       */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.OwnerPortfolioParcel (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    OwnerPortfolioID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NULL,

    GISParcelNumber NVARCHAR(20) NOT NULL,
    Address NVARCHAR(300) NULL,
    TypeGroup NVARCHAR(60) NULL,
    CurrentAV DECIMAL(18, 2) NULL,
    AV2025 DECIMAL(18, 2) NULL,
    AV2026 DECIMAL(18, 2) NULL,
    AVYoYPct DECIMAL(9, 4) NULL,
    SqFt INT NULL,
    Units INT NULL,
    SalesIndicatedValue DECIMAL(18, 2) NULL,
    IncomeIndicatedValue DECIMAL(18, 2) NULL,
    FloorValue DECIMAL(18, 2) NULL,
    AskValue DECIMAL(18, 2) NULL,
    EstSavingsAtAsk DECIMAL(18, 2) NULL,
    EstSavingsAtFloor DECIMAL(18, 2) NULL,
    Recommendation NVARCHAR(20) NULL,
    ConfidenceTier NVARCHAR(20) NULL,
    SupportingApproachCount INT NULL,
    Appealed BIT NOT NULL CONSTRAINT DF_OwnerPortfolioParcel_Appealed DEFAULT (0),
    ExistingRep NVARCHAR(200) NULL,
    LastAppealYear INT NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolioParcel_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_OwnerPortfolioParcel_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_OwnerPortfolioParcel PRIMARY KEY (ID),
    CONSTRAINT FK_OwnerPortfolioParcel_Owner FOREIGN KEY (OwnerPortfolioID) REFERENCES indiana_tax.OwnerPortfolio (ID),
    CONSTRAINT FK_OwnerPortfolioParcel_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID)
);
GO
CREATE INDEX IX_OwnerPortfolioParcel_Owner ON indiana_tax.OwnerPortfolioParcel (OwnerPortfolioID);
GO

/* ========================================================================== */
/* Extended properties — table + every non-PK/FK column                        */
/* ========================================================================== */

/* ---- OwnerPortfolioRun --------------------------------------------------- */
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Persisted output of one scripts/build-owner-portfolios.js run: the county-wide commercial & industrial 2025->2026 assessed-value rollup plus a pointer (IsLatest) to the run the dashboard should show. Written by the portfolio job, read-only on the dashboard side.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'When the portfolio job that produced this run executed, taken verbatim from owners.json generatedAt.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'RunDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The build-owner-portfolios.js methodology label (owners.json method) so a run can be tied to the grouping and scoring rules that produced it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'MethodologyVersion';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Exactly one OwnerPortfolioRun row has IsLatest = 1 at a time; the loader clears the previous winner in the same transaction. The dashboard filters on it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'IsLatest';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcels: the number of Marion commercial & industrial parcels in scope for this run.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.totalAV2025: the summed 2025 assessed value across all in-scope county C&I parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyTotalAV2025';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.totalAV2026: the summed 2026 assessed value across all in-scope county C&I parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyTotalAV2026';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.yoyDollars: CountyTotalAV2026 minus CountyTotalAV2025, the county-wide dollar change in assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyYoYDollars';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.yoyPct: the county-wide year-over-year assessed-value change as a fraction (0.0750 = +7.5%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyYoYPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcelsUp5: count of county C&I parcels whose 2026 AV rose more than 5% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelsUp5';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcelsUp10: count of county C&I parcels whose 2026 AV rose more than 10% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelsUp10';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcelsUp25: count of county C&I parcels whose 2026 AV rose more than 25% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelsUp25';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcelsUp50: count of county C&I parcels whose 2026 AV rose more than 50% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelsUp50';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'countyRollup.parcelsDown: count of county C&I parcels whose 2026 AV fell below 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyParcelsDown';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.stringify of countyRollup.byType from owners.json -- per-property-type 2025/2026 AV + YoY %, display-only for the banner chips. Not a queryable projection.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioRun', @level2type = N'COLUMN', @level2name = N'CountyByTypeJSON';
GO

/* ---- OwnerPortfolio ---------------------------------------------------- */
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One operating-company owner group in a run: Marion parcels rolled up to the operating company (CoStar true owner -> shared mailing address -> cleaned name), with aggregate AV, the ValuationAnalysis opportunity, appeal history, and the tax rep on record.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Normalized owner key (scripts/lib/owner-key.js): CoStar true owner else cleaned label, lowercased, legal-form suffixes stripped. The stable join to indiana_tax.Prospect.OwnerKey across portfolio re-runs.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'OwnerKey';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Human-readable owner name shown in the dashboard (owner.label) -- the CoStar true owner if known, otherwise the cleaned assessor name.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'Label';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Company | Individual | Government | Institution -- classifier from build-owner-portfolios.js. Only Company owners get a prospect Tier.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'Kind';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Prime (>= $500k/yr at ask) | Strong (>= $150k) | Moderate (>= $40k) | Watch | em dash for non-companies.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'Tier';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner.groupKeyType -- which signal grouped these parcels: CO (CoStar true owner), MAIL (shared mailing address), NAME (cleaned assessor name), or PARCEL (single parcel, no group).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'GroupKeyType';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner.coStarTrueOwner -- the CoStar-resolved ultimate owner name when available, the basis of the strongest grouping signal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'CoStarTrueOwner';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Number of parcels rolled up into this owner group for the run (matches the count of OwnerPortfolioParcel rows).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'ParcelCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of distinct raw assessor owner-name strings folded into this group -- a rough measure of how many title-holding entities the operating company uses.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'DistinctEntities';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of the current (most recent certified) assessed value across the group''s parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'TotalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of 2025 assessed value across the group''s parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'TotalAV2025';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of 2026 assessed value across the group''s parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'TotalAV2026';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'TotalAV2026 minus TotalAV2025 -- the group''s year-over-year dollar change in assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'AVYoYDollars';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The group''s year-over-year assessed-value change as a fraction (0.1200 = +12%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'AVYoYPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of the group''s parcels whose 2026 AV rose more than 10% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'ParcelsUp10';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of the group''s parcels whose 2026 AV rose more than 25% over 2025.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'ParcelsUp25';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of residential/lodging unit counts across the group''s parcels where a unit count is known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'TotalUnits';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of improvement square footage across the group''s parcels where square footage is known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'TotalSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner.nAppealRec -- count of the group''s parcels the ValuationAnalysis flags with an Appeal recommendation.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'NAppealRec';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner.nTwoSupport -- count of the group''s parcels where at least two of the three approaches to value support a reduction.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'NTwoSupport';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'owner.nHighConfAppeal -- count of the group''s Appeal-rec parcels whose confidence tier is High.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'NHighConfAppeal';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the recommended ask across Appeal-rec parcels. v1 coarse comps -- a triage signal, not a quote.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'EstSavingsAtAsk';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the conservative floor value across Appeal-rec parcels -- the low end of the range.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'EstSavingsAtFloor';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of the group''s parcels with at least one recorded PTABOA/assessment appeal in the appeal history.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'AppealedParcels';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Total assessed-value reduction the group has historically won across all its recorded appeals (sum of prior-year AV reductions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'HistoricalReductionWon';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Compact span of assessment years in which the group appealed, e.g. "2019-2023"; a single year if there is only one.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'AppealYears';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The most recent assessment year in which any of the group''s parcels was appealed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'MostRecentAppealYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Best single guess at the tax representative acting for the owner -- the rep that secured the most (or most recent) PTABOA reductions across the group''s parcels.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'LikelyRep';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'No rep on record | Represented by X | Multiple reps -- X (+N). Tax-rep inference: a rep that secured a PTABOA reduction on any portfolio parcel is assumed to act for the owner.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'RepStatus';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.stringify of owner.repsOnReduction -- per-rep count and years of PTABOA reductions won on the group''s parcels, display-only for the detail panel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'RepsOnReductionJSON';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'BIT: Company AND no rep on record AND EstSavingsAtAsk > 0 -- the cold-prospect flag the dashboard highlights.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'IsFreshProspect';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The mailing address shared by the group''s parcels (owner.mailAddress) -- the fallback grouping signal and a contact hint.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'MailAddress';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.stringify of owner.byType -- per-property-type parcel count and AV within the group, display-only for the detail-panel breakdown.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolio', @level2type = N'COLUMN', @level2name = N'ByTypeJSON';
GO

/* ---- OwnerPortfolioParcel -------------------------------------------------- */
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One parcel within an OwnerPortfolio owner group for a run: identity, 2025/2026 AV, the three ValuationAnalysis approach indications, the recommended floor/ask and estimated tax saving, and the appeal/rep status for that parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.parcel -- the 7-digit Marion County GIS parcel number, the always-present link key to the PRC and tax history even when ParcelID is null.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'GISParcelNumber';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s situs (site) address as shown in the dashboard parcel list.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'Address';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s property-type group (e.g. Office, Retail, Industrial, Apartment, Hospitality) used for the by-type breakdowns.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'TypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s current (most recent certified) total assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'CurrentAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s 2025 total assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'AV2025';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s 2026 total assessed value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'AV2026';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s year-over-year assessed-value change as a fraction (0.3000 = +30%).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'AVYoYPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s improvement square footage where known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'SqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The parcel''s residential/lodging unit count where known.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'Units';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.salesInd -- the ValuationAnalysis sales-comparison indicated value for the parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'SalesIndicatedValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.incomeInd -- the ValuationAnalysis income-approach indicated value for the parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'IncomeIndicatedValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.floor -- the conservative low-end value the ValuationAnalysis would defend for the parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'FloorValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.ask -- the value the ValuationAnalysis recommends asking for at appeal (the opening position).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'AskValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estimated annual property-tax saving for the parcel if the assessed value were reduced to AskValue. Coarse v1 estimate, a triage signal.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'EstSavingsAtAsk';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estimated annual property-tax saving for the parcel if the assessed value were reduced to FloorValue -- the conservative end of the range.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'EstSavingsAtFloor';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.rec -- the ValuationAnalysis recommendation for the parcel (Appeal | Monitor | ...).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'Recommendation';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.conf -- the ValuationAnalysis confidence tier for the recommendation (High | Medium | Low).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'ConfidenceTier';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.supCount -- how many of the three approaches to value (cost, sales, income) support a reduction for the parcel (0-3).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'SupportingApproachCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'BIT: the parcel has at least one recorded PTABOA/assessment appeal in its history.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'Appealed';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'parcel.rep -- the tax representative on record for the parcel''s prior appeals, if any.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'ExistingRep';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The most recent assessment year in which this parcel was appealed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'OwnerPortfolioParcel', @level2type = N'COLUMN', @level2name = N'LastAppealYear';
GO




























































-- =============================================================================
-- =============================================================================
-- =============================================================================
--
--                    ⚙️  CODEGEN OUTPUT BELOW THIS LINE  ⚙️
--
-- Everything below this block was generated by the MemberJunction CodeGen tool
-- after the hand-written DDL above was applied to the development database
-- (the Indiana Tax Expert dev DB, well past the last released MJ version and
-- carrying the full indiana_tax schema). It contains the framework plumbing for
-- the three new entities: Entity + EntityField metadata inserts, EntityFieldValue
-- rows derived from the CK_OwnerPortfolio_Kind CHECK constraint, the generated
-- base views (vwOwnerPortfolioRuns / vwOwnerPortfolios / vwOwnerPortfolioParcels),
-- spCreate/spUpdate/spDelete procedures, permission grants, related-entity
-- name-field maps, and sp_addextendedproperty calls.
--
-- DO NOT EDIT BY HAND. If the hand-written DDL above changes, re-run CodeGen
-- and replace this entire section with the fresh output.
--
-- =============================================================================
-- =============================================================================
-- =============================================================================

/* SQL generated to create new entity Owner Portfolio Runs */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '949049ee-eaf1-49a3-a18e-861f7e7e56a9',
         'Owner Portfolio Runs',
         NULL,
         'Persisted output of one scripts/build-owner-portfolios.js run: the county-wide commercial & industrial 2025->2026 assessed-value rollup plus a pointer (IsLatest) to the run the dashboard should show. Written by the portfolio job, read-only on the dashboard side.',
         NULL,
         'OwnerPortfolioRun',
         'vwOwnerPortfolioRuns',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity Owner Portfolio Runs to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '949049ee-eaf1-49a3-a18e-861f7e7e56a9', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Runs for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('949049ee-eaf1-49a3-a18e-861f7e7e56a9', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Runs for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('949049ee-eaf1-49a3-a18e-861f7e7e56a9', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Runs for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('949049ee-eaf1-49a3-a18e-861f7e7e56a9', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Owner Portfolios */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '3a5c3501-7a0c-4c7c-a80c-dd7033cf2da4',
         'Owner Portfolios',
         NULL,
         'One operating-company owner group in a run: Marion parcels rolled up to the operating company (CoStar true owner -> shared mailing address -> cleaned name), with aggregate AV, the ValuationAnalysis opportunity, appeal history, and the tax rep on record.',
         NULL,
         'OwnerPortfolio',
         'vwOwnerPortfolios',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity Owner Portfolios to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '3a5c3501-7a0c-4c7c-a80c-dd7033cf2da4', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolios for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a5c3501-7a0c-4c7c-a80c-dd7033cf2da4', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolios for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a5c3501-7a0c-4c7c-a80c-dd7033cf2da4', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolios for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a5c3501-7a0c-4c7c-a80c-dd7033cf2da4', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Owner Portfolio Parcels */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '8d8f38a4-5f7c-4a22-9021-9c81ba3484e5',
         'Owner Portfolio Parcels',
         NULL,
         'One parcel within an OwnerPortfolio owner group for a run: identity, 2025/2026 AV, the three ValuationAnalysis approach indications, the recommended floor/ask and estimated tax saving, and the appeal/rep status for that parcel.',
         NULL,
         'OwnerPortfolioParcel',
         'vwOwnerPortfolioParcels',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity Owner Portfolio Parcels to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '8d8f38a4-5f7c-4a22-9021-9c81ba3484e5', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Parcels for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8d8f38a4-5f7c-4a22-9021-9c81ba3484e5', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Parcels for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8d8f38a4-5f7c-4a22-9021-9c81ba3484e5', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Owner Portfolio Parcels for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('8d8f38a4-5f7c-4a22-9021-9c81ba3484e5', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolioRun */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolioRun'
AND c.name = '__mj_CreatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolioRun] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_CreatedAt in entity indiana_tax.OwnerPortfolioRun */
ALTER TABLE [indiana_tax].[OwnerPortfolioRun] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolioRun___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolioRun */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolioRun'
AND c.name = '__mj_UpdatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolioRun] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_UpdatedAt in entity indiana_tax.OwnerPortfolioRun */
ALTER TABLE [indiana_tax].[OwnerPortfolioRun] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolioRun___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolioParcel */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolioParcel'
AND c.name = '__mj_CreatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolioParcel] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_CreatedAt in entity indiana_tax.OwnerPortfolioParcel */
ALTER TABLE [indiana_tax].[OwnerPortfolioParcel] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolioParcel___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolioParcel */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolioParcel'
AND c.name = '__mj_UpdatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolioParcel] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_UpdatedAt in entity indiana_tax.OwnerPortfolioParcel */
ALTER TABLE [indiana_tax].[OwnerPortfolioParcel] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolioParcel___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolio */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolio'
AND c.name = '__mj_CreatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolio] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_CreatedAt in entity indiana_tax.OwnerPortfolio */
ALTER TABLE [indiana_tax].[OwnerPortfolio] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolio___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];

/* SQL text to drop default existing default constraints in entity indiana_tax.OwnerPortfolio */
DECLARE @constraintName NVARCHAR(255);

SELECT @constraintName = d.name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.default_constraints d ON c.default_object_id = d.object_id
WHERE s.name = 'indiana_tax'
AND t.name = 'OwnerPortfolio'
AND c.name = '__mj_UpdatedAt';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [indiana_tax].[OwnerPortfolio] DROP CONSTRAINT ' + @constraintName);
END;

/* SQL text to add default constraint for special date field __mj_UpdatedAt in entity indiana_tax.OwnerPortfolio */
ALTER TABLE [indiana_tax].[OwnerPortfolio] ADD CONSTRAINT [DF_indiana_tax_OwnerPortfolio___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];

/* SQL text to insert 79 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'df6a3e5b-da30-4d47-ba8a-1ec3fc0a0250' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'df6a3e5b-da30-4d47-ba8a-1ec3fc0a0250',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f6f41d15-8f56-4a7c-aa33-cd61c2ac251e' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'RunDate')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f6f41d15-8f56-4a7c-aa33-cd61c2ac251e',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100002,
            'RunDate',
            'Run Date',
            'When the portfolio job that produced this run executed, taken verbatim from owners.json generatedAt.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b561c795-e7db-4450-84ca-1da8d3b84392' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'MethodologyVersion')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b561c795-e7db-4450-84ca-1da8d3b84392',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100003,
            'MethodologyVersion',
            'Methodology Version',
            'The build-owner-portfolios.js methodology label (owners.json method) so a run can be tied to the grouping and scoring rules that produced it.',
            'nvarchar',
            120,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '691a0c89-f1d8-4ac6-a815-6fc6be420333' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'IsLatest')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '691a0c89-f1d8-4ac6-a815-6fc6be420333',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100004,
            'IsLatest',
            'Is Latest',
            'Exactly one OwnerPortfolioRun row has IsLatest = 1 at a time; the loader clears the previous winner in the same transaction. The dashboard filters on it.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f3e6f457-b357-4373-9086-cc4a68112904' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelCount')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f3e6f457-b357-4373-9086-cc4a68112904',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100005,
            'CountyParcelCount',
            'County Parcel Count',
            'countyRollup.parcels: the number of Marion commercial & industrial parcels in scope for this run.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f162bc7c-8810-4d29-9afd-8728784ea5a0' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyTotalAV2025')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f162bc7c-8810-4d29-9afd-8728784ea5a0',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100006,
            'CountyTotalAV2025',
            'County Total AV2025',
            'countyRollup.totalAV2025: the summed 2025 assessed value across all in-scope county C&I parcels.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '81a553a7-a44f-439f-9854-30cbb2d2c28a' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyTotalAV2026')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '81a553a7-a44f-439f-9854-30cbb2d2c28a',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100007,
            'CountyTotalAV2026',
            'County Total AV2026',
            'countyRollup.totalAV2026: the summed 2026 assessed value across all in-scope county C&I parcels.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8d60ebed-53e9-432c-8094-e1d4ee9f603d' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyYoYDollars')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8d60ebed-53e9-432c-8094-e1d4ee9f603d',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100008,
            'CountyYoYDollars',
            'County Yo Y Dollars',
            'countyRollup.yoyDollars: CountyTotalAV2026 minus CountyTotalAV2025, the county-wide dollar change in assessed value.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '76434f21-a6ac-4d13-860c-890b1c74af73' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyYoYPct')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '76434f21-a6ac-4d13-860c-890b1c74af73',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100009,
            'CountyYoYPct',
            'County Yo Y Pct',
            'countyRollup.yoyPct: the county-wide year-over-year assessed-value change as a fraction (0.0750 = +7.5%).',
            'decimal',
            5,
            9,
            4,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'da4babc9-8e82-4cb1-9b06-826e728c730f' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelsUp5')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'da4babc9-8e82-4cb1-9b06-826e728c730f',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100010,
            'CountyParcelsUp5',
            'County Parcels Up 5',
            'countyRollup.parcelsUp5: count of county C&I parcels whose 2026 AV rose more than 5% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9ea75dd4-5f1d-4d22-9097-63665be2ae31' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelsUp10')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9ea75dd4-5f1d-4d22-9097-63665be2ae31',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100011,
            'CountyParcelsUp10',
            'County Parcels Up 10',
            'countyRollup.parcelsUp10: count of county C&I parcels whose 2026 AV rose more than 10% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '53bbcbe6-f494-4267-9783-b4631edf3fd3' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelsUp25')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '53bbcbe6-f494-4267-9783-b4631edf3fd3',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100012,
            'CountyParcelsUp25',
            'County Parcels Up 25',
            'countyRollup.parcelsUp25: count of county C&I parcels whose 2026 AV rose more than 25% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '10186622-ab50-44f9-becc-f00a010fc6f1' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelsUp50')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '10186622-ab50-44f9-becc-f00a010fc6f1',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100013,
            'CountyParcelsUp50',
            'County Parcels Up 50',
            'countyRollup.parcelsUp50: count of county C&I parcels whose 2026 AV rose more than 50% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '48f9d8b9-f91c-430a-83b6-3b327979ac8a' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyParcelsDown')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '48f9d8b9-f91c-430a-83b6-3b327979ac8a',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100014,
            'CountyParcelsDown',
            'County Parcels Down',
            'countyRollup.parcelsDown: count of county C&I parcels whose 2026 AV fell below 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1c2afcab-b768-48a4-a597-0627d6e2e32b' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = 'CountyByTypeJSON')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1c2afcab-b768-48a4-a597-0627d6e2e32b',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100015,
            'CountyByTypeJSON',
            'County By Type JSON',
            'JSON.stringify of countyRollup.byType from owners.json -- per-property-type 2025/2026 AV + YoY %, display-only for the banner chips. Not a queryable projection.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'abbaf0a3-6e73-4f68-b5d3-6dd57db125b8' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'abbaf0a3-6e73-4f68-b5d3-6dd57db125b8',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100016,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'aab90dac-463a-4389-a06d-8671337f8b51' OR (EntityID = '949049EE-EAF1-49A3-A18E-861F7E7E56A9' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'aab90dac-463a-4389-a06d-8671337f8b51',
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9', -- Entity: Owner Portfolio Runs
            100017,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5219f605-1517-416f-a053-8a28257fa2a7' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5219f605-1517-416f-a053-8a28257fa2a7',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0b8485b6-88e7-4fc7-b8f4-0ecf7bea0735' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'OwnerPortfolioID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0b8485b6-88e7-4fc7-b8f4-0ecf7bea0735',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100002,
            'OwnerPortfolioID',
            'Owner Portfolio ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6eb3b03b-8c66-43b2-a160-9e9e6c0add26' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'ParcelID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6eb3b03b-8c66-43b2-a160-9e9e6c0add26',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100003,
            'ParcelID',
            'Parcel ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '51447165-011f-4019-b4fa-685e84d61f5c' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'GISParcelNumber')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '51447165-011f-4019-b4fa-685e84d61f5c',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100004,
            'GISParcelNumber',
            'GIS Parcel Number',
            'parcel.parcel -- the 7-digit Marion County GIS parcel number, the always-present link key to the PRC and tax history even when ParcelID is null.',
            'nvarchar',
            40,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dd91dde7-260f-4b7d-b52f-574723576516' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'Address')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dd91dde7-260f-4b7d-b52f-574723576516',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100005,
            'Address',
            'Address',
            'The parcel''s situs (site) address as shown in the dashboard parcel list.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a12373a7-c884-4ad4-b3ab-6a1a1d8e13ae' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'TypeGroup')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a12373a7-c884-4ad4-b3ab-6a1a1d8e13ae',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100006,
            'TypeGroup',
            'Type Group',
            'The parcel''s property-type group (e.g. Office, Retail, Industrial, Apartment, Hospitality) used for the by-type breakdowns.',
            'nvarchar',
            120,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a45fc552-afee-4061-98c2-bfd88ddfc599' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'CurrentAV')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a45fc552-afee-4061-98c2-bfd88ddfc599',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100007,
            'CurrentAV',
            'Current AV',
            'The parcel''s current (most recent certified) total assessed value.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4061eaae-c455-4cce-bb27-57b4a4d1a1de' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'AV2025')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4061eaae-c455-4cce-bb27-57b4a4d1a1de',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100008,
            'AV2025',
            'Av 2025',
            'The parcel''s 2025 total assessed value.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7b67ec78-26a0-4f91-82e7-eda10d5ce9af' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'AV2026')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7b67ec78-26a0-4f91-82e7-eda10d5ce9af',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100009,
            'AV2026',
            'Av 2026',
            'The parcel''s 2026 total assessed value.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2937da82-ad89-4ebe-acd0-4241d48fb6ff' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'AVYoYPct')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2937da82-ad89-4ebe-acd0-4241d48fb6ff',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100010,
            'AVYoYPct',
            'AV Yo Y Pct',
            'The parcel''s year-over-year assessed-value change as a fraction (0.3000 = +30%).',
            'decimal',
            5,
            9,
            4,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bd0c55d0-868b-45d3-9929-eb286f75bf13' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'SqFt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bd0c55d0-868b-45d3-9929-eb286f75bf13',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100011,
            'SqFt',
            'Sq Ft',
            'The parcel''s improvement square footage where known.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd86930f0-2fb0-48b6-b903-3d90bd5cf1ff' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'Units')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd86930f0-2fb0-48b6-b903-3d90bd5cf1ff',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100012,
            'Units',
            'Units',
            'The parcel''s residential/lodging unit count where known.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0f490f63-fa56-4d0c-a757-039fbe142fcd' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'SalesIndicatedValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0f490f63-fa56-4d0c-a757-039fbe142fcd',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100013,
            'SalesIndicatedValue',
            'Sales Indicated Value',
            'parcel.salesInd -- the ValuationAnalysis sales-comparison indicated value for the parcel.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '891cd9b3-228c-4fa1-8d3f-d171f2a7fd66' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'IncomeIndicatedValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '891cd9b3-228c-4fa1-8d3f-d171f2a7fd66',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100014,
            'IncomeIndicatedValue',
            'Income Indicated Value',
            'parcel.incomeInd -- the ValuationAnalysis income-approach indicated value for the parcel.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e7866995-bb70-428e-94f3-9af71b0356a1' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'FloorValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e7866995-bb70-428e-94f3-9af71b0356a1',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100015,
            'FloorValue',
            'Floor Value',
            'parcel.floor -- the conservative low-end value the ValuationAnalysis would defend for the parcel.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0a5fae3a-4470-4b39-8908-172a5aa136c4' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'AskValue')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0a5fae3a-4470-4b39-8908-172a5aa136c4',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100016,
            'AskValue',
            'Ask Value',
            'parcel.ask -- the value the ValuationAnalysis recommends asking for at appeal (the opening position).',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f0bae088-f518-4609-aae0-13cbe5006a0a' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'EstSavingsAtAsk')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f0bae088-f518-4609-aae0-13cbe5006a0a',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100017,
            'EstSavingsAtAsk',
            'Est Savings At Ask',
            'Estimated annual property-tax saving for the parcel if the assessed value were reduced to AskValue. Coarse v1 estimate, a triage signal.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '25bd8a3b-9dd9-41da-b5b5-25fb61e3375a' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'EstSavingsAtFloor')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '25bd8a3b-9dd9-41da-b5b5-25fb61e3375a',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100018,
            'EstSavingsAtFloor',
            'Est Savings At Floor',
            'Estimated annual property-tax saving for the parcel if the assessed value were reduced to FloorValue -- the conservative end of the range.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4ce26113-e581-4037-93c0-26253c601e18' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'Recommendation')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4ce26113-e581-4037-93c0-26253c601e18',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100019,
            'Recommendation',
            'Recommendation',
            'parcel.rec -- the ValuationAnalysis recommendation for the parcel (Appeal | Monitor | ...).',
            'nvarchar',
            40,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'decf350e-fbf5-4cd3-823b-5cc85588e14f' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'ConfidenceTier')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'decf350e-fbf5-4cd3-823b-5cc85588e14f',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100020,
            'ConfidenceTier',
            'Confidence Tier',
            'parcel.conf -- the ValuationAnalysis confidence tier for the recommendation (High | Medium | Low).',
            'nvarchar',
            40,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '21e793ec-52ae-4566-83de-745fc93d86a3' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'SupportingApproachCount')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '21e793ec-52ae-4566-83de-745fc93d86a3',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100021,
            'SupportingApproachCount',
            'Supporting Approach Count',
            'parcel.supCount -- how many of the three approaches to value (cost, sales, income) support a reduction for the parcel (0-3).',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '64359068-66ec-4897-817b-c28178441ad1' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'Appealed')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '64359068-66ec-4897-817b-c28178441ad1',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100022,
            'Appealed',
            'Appealed',
            'BIT: the parcel has at least one recorded PTABOA/assessment appeal in its history.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a4f70c46-92a0-400a-93c6-b7324275d5a3' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'ExistingRep')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a4f70c46-92a0-400a-93c6-b7324275d5a3',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100023,
            'ExistingRep',
            'Existing Rep',
            'parcel.rep -- the tax representative on record for the parcel''s prior appeals, if any.',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '864fa015-1710-4ef3-82d6-7968f876d071' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'LastAppealYear')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '864fa015-1710-4ef3-82d6-7968f876d071',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100024,
            'LastAppealYear',
            'Last Appeal Year',
            'The most recent assessment year in which this parcel was appealed.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '340f5d6b-5aab-4eee-a0ea-39eca3c1a2f0' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '340f5d6b-5aab-4eee-a0ea-39eca3c1a2f0',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100025,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '71dc2ae4-10a5-4da6-a64b-a49e86e8485d' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '71dc2ae4-10a5-4da6-a64b-a49e86e8485d',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100026,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4f34ca86-0bcd-4eb9-924b-3f4cd02a4fb6' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4f34ca86-0bcd-4eb9-924b-3f4cd02a4fb6',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '58285950-1dcd-4ed4-864a-dbc2fb4901b0' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'RunID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '58285950-1dcd-4ed4-864a-dbc2fb4901b0',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100002,
            'RunID',
            'Run ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '949049EE-EAF1-49A3-A18E-861F7E7E56A9',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1f0bbe0b-06ad-4ea5-ac7e-dc6e8096410b' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'OwnerKey')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1f0bbe0b-06ad-4ea5-ac7e-dc6e8096410b',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100003,
            'OwnerKey',
            'Owner Key',
            'Normalized owner key (scripts/lib/owner-key.js): CoStar true owner else cleaned label, lowercased, legal-form suffixes stripped. The stable join to indiana_tax.Prospect.OwnerKey across portfolio re-runs.',
            'nvarchar',
            400,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a6dff796-f170-4179-98c8-003d0859b08a' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'Label')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a6dff796-f170-4179-98c8-003d0859b08a',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100004,
            'Label',
            'Label',
            'Human-readable owner name shown in the dashboard (owner.label) -- the CoStar true owner if known, otherwise the cleaned assessor name.',
            'nvarchar',
            600,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8f069444-e566-4bd6-bb1e-9178e7c705d9' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'Kind')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8f069444-e566-4bd6-bb1e-9178e7c705d9',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100005,
            'Kind',
            'Kind',
            'Company | Individual | Government | Institution -- classifier from build-owner-portfolios.js. Only Company owners get a prospect Tier.',
            'nvarchar',
            40,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cc8e9cb9-d42c-4fa8-939b-b40202435815' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'Tier')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cc8e9cb9-d42c-4fa8-939b-b40202435815',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100006,
            'Tier',
            'Tier',
            'Prime (>= $500k/yr at ask) | Strong (>= $150k) | Moderate (>= $40k) | Watch | em dash for non-companies.',
            'nvarchar',
            24,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'becdb05e-2cb0-40dd-a7bc-67eaf77fe2bb' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'GroupKeyType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'becdb05e-2cb0-40dd-a7bc-67eaf77fe2bb',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100007,
            'GroupKeyType',
            'Group Key Type',
            'owner.groupKeyType -- which signal grouped these parcels: CO (CoStar true owner), MAIL (shared mailing address), NAME (cleaned assessor name), or PARCEL (single parcel, no group).',
            'nvarchar',
            24,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e3176003-795b-4ab8-973f-ef44c1c7f449' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'CoStarTrueOwner')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e3176003-795b-4ab8-973f-ef44c1c7f449',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100008,
            'CoStarTrueOwner',
            'Co Star True Owner',
            'owner.coStarTrueOwner -- the CoStar-resolved ultimate owner name when available, the basis of the strongest grouping signal.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4201ae5e-5ee2-4e79-967a-6dab160150d1' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'ParcelCount')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4201ae5e-5ee2-4e79-967a-6dab160150d1',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100009,
            'ParcelCount',
            'Parcel Count',
            'Number of parcels rolled up into this owner group for the run (matches the count of OwnerPortfolioParcel rows).',
            'int',
            4,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '594af888-a87e-44e3-b57f-9d664f1c81c3' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'DistinctEntities')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '594af888-a87e-44e3-b57f-9d664f1c81c3',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100010,
            'DistinctEntities',
            'Distinct Entities',
            'Count of distinct raw assessor owner-name strings folded into this group -- a rough measure of how many title-holding entities the operating company uses.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '967493c2-8a41-4609-a390-5107febc50c1' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'TotalAV')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '967493c2-8a41-4609-a390-5107febc50c1',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100011,
            'TotalAV',
            'Total AV',
            'Sum of the current (most recent certified) assessed value across the group''s parcels.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0e635546-c1f9-4533-b650-efdd7fa64268' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'TotalAV2025')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0e635546-c1f9-4533-b650-efdd7fa64268',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100012,
            'TotalAV2025',
            'Total AV2025',
            'Sum of 2025 assessed value across the group''s parcels.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5d4b3f5b-2824-4a4b-8e65-99c13dbff3f0' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'TotalAV2026')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5d4b3f5b-2824-4a4b-8e65-99c13dbff3f0',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100013,
            'TotalAV2026',
            'Total AV2026',
            'Sum of 2026 assessed value across the group''s parcels.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '28926c7b-f96a-4517-9272-256dfde4bcab' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'AVYoYDollars')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '28926c7b-f96a-4517-9272-256dfde4bcab',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100014,
            'AVYoYDollars',
            'AV Yo Y Dollars',
            'TotalAV2026 minus TotalAV2025 -- the group''s year-over-year dollar change in assessed value.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e9f595bb-31fc-4516-9569-b02076c1cc1f' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'AVYoYPct')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e9f595bb-31fc-4516-9569-b02076c1cc1f',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100015,
            'AVYoYPct',
            'AV Yo Y Pct',
            'The group''s year-over-year assessed-value change as a fraction (0.1200 = +12%).',
            'decimal',
            5,
            9,
            4,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1e4667f6-64dd-4aea-b016-a93cb8596837' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'ParcelsUp10')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1e4667f6-64dd-4aea-b016-a93cb8596837',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100016,
            'ParcelsUp10',
            'Parcels Up 10',
            'Count of the group''s parcels whose 2026 AV rose more than 10% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '62d512a2-12b6-4fac-8433-1bee3d04de97' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'ParcelsUp25')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '62d512a2-12b6-4fac-8433-1bee3d04de97',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100017,
            'ParcelsUp25',
            'Parcels Up 25',
            'Count of the group''s parcels whose 2026 AV rose more than 25% over 2025.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6c0ca534-35e3-44fc-9367-aee2451b6a7c' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'TotalUnits')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6c0ca534-35e3-44fc-9367-aee2451b6a7c',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100018,
            'TotalUnits',
            'Total Units',
            'Sum of residential/lodging unit counts across the group''s parcels where a unit count is known.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '84f0966f-f937-4238-b7b9-b3f41d414513' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'TotalSqFt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '84f0966f-f937-4238-b7b9-b3f41d414513',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100019,
            'TotalSqFt',
            'Total Sq Ft',
            'Sum of improvement square footage across the group''s parcels where square footage is known.',
            'bigint',
            8,
            19,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab0539bb-fd46-4984-9279-5dcbc880cfdb' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'NAppealRec')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ab0539bb-fd46-4984-9279-5dcbc880cfdb',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100020,
            'NAppealRec',
            'N Appeal Rec',
            'owner.nAppealRec -- count of the group''s parcels the ValuationAnalysis flags with an Appeal recommendation.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '990292b6-abca-4eb5-a24b-d9ebc1c7d511' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'NTwoSupport')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '990292b6-abca-4eb5-a24b-d9ebc1c7d511',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100021,
            'NTwoSupport',
            'N Two Support',
            'owner.nTwoSupport -- count of the group''s parcels where at least two of the three approaches to value support a reduction.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2d5147a6-2de7-4d16-8f8c-386c2a43027c' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'NHighConfAppeal')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2d5147a6-2de7-4d16-8f8c-386c2a43027c',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100022,
            'NHighConfAppeal',
            'N High Conf Appeal',
            'owner.nHighConfAppeal -- count of the group''s Appeal-rec parcels whose confidence tier is High.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '50fad769-754d-478b-a49f-c1f8d1e11d13' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'EstSavingsAtAsk')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '50fad769-754d-478b-a49f-c1f8d1e11d13',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100023,
            'EstSavingsAtAsk',
            'Est Savings At Ask',
            'Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the recommended ask across Appeal-rec parcels. v1 coarse comps -- a triage signal, not a quote.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0a42cc98-2b28-4dd0-bd37-da41c522b591' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'EstSavingsAtFloor')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0a42cc98-2b28-4dd0-bd37-da41c522b591',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100024,
            'EstSavingsAtFloor',
            'Est Savings At Floor',
            'Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the conservative floor value across Appeal-rec parcels -- the low end of the range.',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '96e7e4d6-5fc4-4603-8d9b-1ea41282a9f6' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'AppealedParcels')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '96e7e4d6-5fc4-4603-8d9b-1ea41282a9f6',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100025,
            'AppealedParcels',
            'Appealed Parcels',
            'Count of the group''s parcels with at least one recorded PTABOA/assessment appeal in the appeal history.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3d94581d-55bb-4ae5-abd8-163aad1eff50' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'HistoricalReductionWon')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3d94581d-55bb-4ae5-abd8-163aad1eff50',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100026,
            'HistoricalReductionWon',
            'Historical Reduction Won',
            'Total assessed-value reduction the group has historically won across all its recorded appeals (sum of prior-year AV reductions).',
            'decimal',
            9,
            18,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1c41ab07-22d9-4931-8b15-8f1f6318fdc5' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'AppealYears')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1c41ab07-22d9-4931-8b15-8f1f6318fdc5',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100027,
            'AppealYears',
            'Appeal Years',
            'Compact span of assessment years in which the group appealed, e.g. "2019-2023"; a single year if there is only one.',
            'nvarchar',
            40,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'de6543d7-71be-4c58-a809-9af72034fa88' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'MostRecentAppealYear')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'de6543d7-71be-4c58-a809-9af72034fa88',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100028,
            'MostRecentAppealYear',
            'Most Recent Appeal Year',
            'The most recent assessment year in which any of the group''s parcels was appealed.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a9b7ae3e-10d7-48a9-8b1c-abf4e48dbd16' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'LikelyRep')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a9b7ae3e-10d7-48a9-8b1c-abf4e48dbd16',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100029,
            'LikelyRep',
            'Likely Rep',
            'Best single guess at the tax representative acting for the owner -- the rep that secured the most (or most recent) PTABOA reductions across the group''s parcels.',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1514f4d5-ba2d-475b-9e2d-d95d29babed2' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'RepStatus')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1514f4d5-ba2d-475b-9e2d-d95d29babed2',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100030,
            'RepStatus',
            'Rep Status',
            'No rep on record | Represented by X | Multiple reps -- X (+N). Tax-rep inference: a rep that secured a PTABOA reduction on any portfolio parcel is assumed to act for the owner.',
            'nvarchar',
            240,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b5ea56c6-d7fb-4754-9b8e-97969e05d293' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'RepsOnReductionJSON')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b5ea56c6-d7fb-4754-9b8e-97969e05d293',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100031,
            'RepsOnReductionJSON',
            'Reps On Reduction JSON',
            'JSON.stringify of owner.repsOnReduction -- per-rep count and years of PTABOA reductions won on the group''s parcels, display-only for the detail panel.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dea55c11-5d9d-4f87-bdb5-b7ac746b6bbf' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'IsFreshProspect')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dea55c11-5d9d-4f87-bdb5-b7ac746b6bbf',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100032,
            'IsFreshProspect',
            'Is Fresh Prospect',
            'BIT: Company AND no rep on record AND EstSavingsAtAsk > 0 -- the cold-prospect flag the dashboard highlights.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b410000b-75b8-47b9-90d8-6359dd4f17e6' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'MailAddress')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b410000b-75b8-47b9-90d8-6359dd4f17e6',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100033,
            'MailAddress',
            'Mail Address',
            'The mailing address shared by the group''s parcels (owner.mailAddress) -- the fallback grouping signal and a contact hint.',
            'nvarchar',
            800,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '70e46efb-a67f-465b-9439-375ad3156d07' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'ByTypeJSON')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '70e46efb-a67f-465b-9439-375ad3156d07',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100034,
            'ByTypeJSON',
            'By Type JSON',
            'JSON.stringify of owner.byType -- per-property-type parcel count and AV within the group, display-only for the detail-panel breakdown.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a71ffbcc-db44-487f-9519-a85683cc2512' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a71ffbcc-db44-487f-9519-a85683cc2512',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100035,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c8bdbd27-0e12-470c-9758-06f493bd4407' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c8bdbd27-0e12-470c-9758-06f493bd4407',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100036,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert entity field value with ID 1d6c7f33-10a6-443f-85f0-cdb7f6a37661 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1d6c7f33-10a6-443f-85f0-cdb7f6a37661', '8F069444-E566-4BD6-BB1E-9178E7C705D9', 1, 'Company', 'Company', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1782b5e0-be30-465c-bcde-5ed65af99e6f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1782b5e0-be30-465c-bcde-5ed65af99e6f', '8F069444-E566-4BD6-BB1E-9178E7C705D9', 2, 'Government', 'Government', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2244621a-9ffe-4336-98af-e6188334fb6f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2244621a-9ffe-4336-98af-e6188334fb6f', '8F069444-E566-4BD6-BB1E-9178E7C705D9', 3, 'Individual', 'Individual', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6a4fe6da-9bf1-4673-98bd-9c8b73fac657 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6a4fe6da-9bf1-4673-98bd-9c8b73fac657', '8F069444-E566-4BD6-BB1E-9178E7C705D9', 4, 'Institution', 'Institution', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 8F069444-E566-4BD6-BB1E-9178E7C705D9 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='8F069444-E566-4BD6-BB1E-9178E7C705D9';


/* Create Entity Relationship: Owner Portfolio Runs -> Owner Portfolios (One To Many via RunID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e83919a9-1b71-45f7-ac79-2ff62b0bc4f4'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e83919a9-1b71-45f7-ac79-2ff62b0bc4f4', '949049EE-EAF1-49A3-A18E-861F7E7E56A9', '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', 'RunID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Owner Portfolio Parcels (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '3cd7c994-6758-472a-a5d7-d0086bd6b3c6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3cd7c994-6758-472a-a5d7-d0086bd6b3c6', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', 'ParcelID', 'One To Many', 1, 1, 20, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Owner Portfolios -> Owner Portfolio Parcels (One To Many via OwnerPortfolioID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '66a47906-e1cc-4687-9777-1ed0b7a51212'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('66a47906-e1cc-4687-9777-1ed0b7a51212', '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', 'OwnerPortfolioID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;

/* Index for Foreign Keys for OwnerPortfolioParcel */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OwnerPortfolioID in table OwnerPortfolioParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_OwnerPortfolioID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolioParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_OwnerPortfolioID ON [indiana_tax].[OwnerPortfolioParcel] ([OwnerPortfolioID]);

-- Index for foreign key ParcelID in table OwnerPortfolioParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolioParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_ParcelID ON [indiana_tax].[OwnerPortfolioParcel] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 6EB3B03B-8C66-43B2-A160-9E9E6C0ADD26 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='6EB3B03B-8C66-43B2-A160-9E9E6C0ADD26', @RelatedEntityNameFieldMap='Parcel';

/* Index for Foreign Keys for OwnerPortfolioRun */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for OwnerPortfolio */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key RunID in table OwnerPortfolio
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolio_RunID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolio]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolio_RunID ON [indiana_tax].[OwnerPortfolio] ([RunID]);

/* Base View SQL for Owner Portfolio Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: vwOwnerPortfolioRuns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Owner Portfolio Runs
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  OwnerPortfolioRun
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwOwnerPortfolioRuns]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwOwnerPortfolioRuns];
GO

CREATE VIEW [indiana_tax].[vwOwnerPortfolioRuns]
AS
SELECT
    o.*
FROM
    [indiana_tax].[OwnerPortfolioRun] AS o
GO
GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioRuns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Owner Portfolio Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: Permissions for vwOwnerPortfolioRuns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioRuns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Owner Portfolio Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: spCreateOwnerPortfolioRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OwnerPortfolioRun
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateOwnerPortfolioRun]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateOwnerPortfolioRun];
GO

CREATE PROCEDURE [indiana_tax].[spCreateOwnerPortfolioRun]
    @ID uniqueidentifier = NULL,
    @RunDate datetimeoffset,
    @MethodologyVersion nvarchar(60),
    @IsLatest bit = NULL,
    @CountyParcelCount_Clear bit = 0,
    @CountyParcelCount int = NULL,
    @CountyTotalAV2025_Clear bit = 0,
    @CountyTotalAV2025 decimal(18, 2) = NULL,
    @CountyTotalAV2026_Clear bit = 0,
    @CountyTotalAV2026 decimal(18, 2) = NULL,
    @CountyYoYDollars_Clear bit = 0,
    @CountyYoYDollars decimal(18, 2) = NULL,
    @CountyYoYPct_Clear bit = 0,
    @CountyYoYPct decimal(9, 4) = NULL,
    @CountyParcelsUp5_Clear bit = 0,
    @CountyParcelsUp5 int = NULL,
    @CountyParcelsUp10_Clear bit = 0,
    @CountyParcelsUp10 int = NULL,
    @CountyParcelsUp25_Clear bit = 0,
    @CountyParcelsUp25 int = NULL,
    @CountyParcelsUp50_Clear bit = 0,
    @CountyParcelsUp50 int = NULL,
    @CountyParcelsDown_Clear bit = 0,
    @CountyParcelsDown int = NULL,
    @CountyByTypeJSON_Clear bit = 0,
    @CountyByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[OwnerPortfolioRun]
            (
                [ID],
                [RunDate],
                [MethodologyVersion],
                [IsLatest],
                [CountyParcelCount],
                [CountyTotalAV2025],
                [CountyTotalAV2026],
                [CountyYoYDollars],
                [CountyYoYPct],
                [CountyParcelsUp5],
                [CountyParcelsUp10],
                [CountyParcelsUp25],
                [CountyParcelsUp50],
                [CountyParcelsDown],
                [CountyByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @RunDate,
                @MethodologyVersion,
                ISNULL(@IsLatest, 0),
                CASE WHEN @CountyParcelCount_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelCount, NULL) END,
                CASE WHEN @CountyTotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2025, NULL) END,
                CASE WHEN @CountyTotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2026, NULL) END,
                CASE WHEN @CountyYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYDollars, NULL) END,
                CASE WHEN @CountyYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYPct, NULL) END,
                CASE WHEN @CountyParcelsUp5_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp5, NULL) END,
                CASE WHEN @CountyParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp10, NULL) END,
                CASE WHEN @CountyParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp25, NULL) END,
                CASE WHEN @CountyParcelsUp50_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp50, NULL) END,
                CASE WHEN @CountyParcelsDown_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsDown, NULL) END,
                CASE WHEN @CountyByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@CountyByTypeJSON, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[OwnerPortfolioRun]
            (
                [RunDate],
                [MethodologyVersion],
                [IsLatest],
                [CountyParcelCount],
                [CountyTotalAV2025],
                [CountyTotalAV2026],
                [CountyYoYDollars],
                [CountyYoYPct],
                [CountyParcelsUp5],
                [CountyParcelsUp10],
                [CountyParcelsUp25],
                [CountyParcelsUp50],
                [CountyParcelsDown],
                [CountyByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @RunDate,
                @MethodologyVersion,
                ISNULL(@IsLatest, 0),
                CASE WHEN @CountyParcelCount_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelCount, NULL) END,
                CASE WHEN @CountyTotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2025, NULL) END,
                CASE WHEN @CountyTotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2026, NULL) END,
                CASE WHEN @CountyYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYDollars, NULL) END,
                CASE WHEN @CountyYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYPct, NULL) END,
                CASE WHEN @CountyParcelsUp5_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp5, NULL) END,
                CASE WHEN @CountyParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp10, NULL) END,
                CASE WHEN @CountyParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp25, NULL) END,
                CASE WHEN @CountyParcelsUp50_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp50, NULL) END,
                CASE WHEN @CountyParcelsDown_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsDown, NULL) END,
                CASE WHEN @CountyByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@CountyByTypeJSON, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwOwnerPortfolioRuns] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Owner Portfolio Runs */

GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Owner Portfolio Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: spUpdateOwnerPortfolioRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OwnerPortfolioRun
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateOwnerPortfolioRun]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioRun];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioRun]
    @ID uniqueidentifier,
    @RunDate datetimeoffset = NULL,
    @MethodologyVersion nvarchar(60) = NULL,
    @IsLatest bit = NULL,
    @CountyParcelCount_Clear bit = 0,
    @CountyParcelCount int = NULL,
    @CountyTotalAV2025_Clear bit = 0,
    @CountyTotalAV2025 decimal(18, 2) = NULL,
    @CountyTotalAV2026_Clear bit = 0,
    @CountyTotalAV2026 decimal(18, 2) = NULL,
    @CountyYoYDollars_Clear bit = 0,
    @CountyYoYDollars decimal(18, 2) = NULL,
    @CountyYoYPct_Clear bit = 0,
    @CountyYoYPct decimal(9, 4) = NULL,
    @CountyParcelsUp5_Clear bit = 0,
    @CountyParcelsUp5 int = NULL,
    @CountyParcelsUp10_Clear bit = 0,
    @CountyParcelsUp10 int = NULL,
    @CountyParcelsUp25_Clear bit = 0,
    @CountyParcelsUp25 int = NULL,
    @CountyParcelsUp50_Clear bit = 0,
    @CountyParcelsUp50 int = NULL,
    @CountyParcelsDown_Clear bit = 0,
    @CountyParcelsDown int = NULL,
    @CountyByTypeJSON_Clear bit = 0,
    @CountyByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioRun]
    SET
        [RunDate] = ISNULL(@RunDate, [RunDate]),
        [MethodologyVersion] = ISNULL(@MethodologyVersion, [MethodologyVersion]),
        [IsLatest] = ISNULL(@IsLatest, [IsLatest]),
        [CountyParcelCount] = CASE WHEN @CountyParcelCount_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelCount, [CountyParcelCount]) END,
        [CountyTotalAV2025] = CASE WHEN @CountyTotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2025, [CountyTotalAV2025]) END,
        [CountyTotalAV2026] = CASE WHEN @CountyTotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@CountyTotalAV2026, [CountyTotalAV2026]) END,
        [CountyYoYDollars] = CASE WHEN @CountyYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYDollars, [CountyYoYDollars]) END,
        [CountyYoYPct] = CASE WHEN @CountyYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@CountyYoYPct, [CountyYoYPct]) END,
        [CountyParcelsUp5] = CASE WHEN @CountyParcelsUp5_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp5, [CountyParcelsUp5]) END,
        [CountyParcelsUp10] = CASE WHEN @CountyParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp10, [CountyParcelsUp10]) END,
        [CountyParcelsUp25] = CASE WHEN @CountyParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp25, [CountyParcelsUp25]) END,
        [CountyParcelsUp50] = CASE WHEN @CountyParcelsUp50_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsUp50, [CountyParcelsUp50]) END,
        [CountyParcelsDown] = CASE WHEN @CountyParcelsDown_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelsDown, [CountyParcelsDown]) END,
        [CountyByTypeJSON] = CASE WHEN @CountyByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@CountyByTypeJSON, [CountyByTypeJSON]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwOwnerPortfolioRuns] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwOwnerPortfolioRuns]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OwnerPortfolioRun table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateOwnerPortfolioRun]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateOwnerPortfolioRun];
GO
CREATE TRIGGER [indiana_tax].trgUpdateOwnerPortfolioRun
ON [indiana_tax].[OwnerPortfolioRun]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioRun]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[OwnerPortfolioRun] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Owner Portfolio Runs */

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: vwOwnerPortfolios
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Owner Portfolios
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  OwnerPortfolio
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwOwnerPortfolios]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwOwnerPortfolios];
GO

CREATE VIEW [indiana_tax].[vwOwnerPortfolios]
AS
SELECT
    o.*
FROM
    [indiana_tax].[OwnerPortfolio] AS o
GO
GRANT SELECT ON [indiana_tax].[vwOwnerPortfolios] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: Permissions for vwOwnerPortfolios
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwOwnerPortfolios] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spCreateOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spCreateOwnerPortfolio]
    @ID uniqueidentifier = NULL,
    @RunID uniqueidentifier,
    @OwnerKey nvarchar(200),
    @Label nvarchar(300),
    @Kind nvarchar(20),
    @Tier_Clear bit = 0,
    @Tier nvarchar(12) = NULL,
    @GroupKeyType_Clear bit = 0,
    @GroupKeyType nvarchar(12) = NULL,
    @CoStarTrueOwner_Clear bit = 0,
    @CoStarTrueOwner nvarchar(300) = NULL,
    @ParcelCount int,
    @DistinctEntities_Clear bit = 0,
    @DistinctEntities int = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(18, 2) = NULL,
    @TotalAV2025_Clear bit = 0,
    @TotalAV2025 decimal(18, 2) = NULL,
    @TotalAV2026_Clear bit = 0,
    @TotalAV2026 decimal(18, 2) = NULL,
    @AVYoYDollars_Clear bit = 0,
    @AVYoYDollars decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @ParcelsUp10_Clear bit = 0,
    @ParcelsUp10 int = NULL,
    @ParcelsUp25_Clear bit = 0,
    @ParcelsUp25 int = NULL,
    @TotalUnits_Clear bit = 0,
    @TotalUnits int = NULL,
    @TotalSqFt_Clear bit = 0,
    @TotalSqFt bigint = NULL,
    @NAppealRec_Clear bit = 0,
    @NAppealRec int = NULL,
    @NTwoSupport_Clear bit = 0,
    @NTwoSupport int = NULL,
    @NHighConfAppeal_Clear bit = 0,
    @NHighConfAppeal int = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @AppealedParcels_Clear bit = 0,
    @AppealedParcels int = NULL,
    @HistoricalReductionWon_Clear bit = 0,
    @HistoricalReductionWon decimal(18, 2) = NULL,
    @AppealYears_Clear bit = 0,
    @AppealYears nvarchar(20) = NULL,
    @MostRecentAppealYear_Clear bit = 0,
    @MostRecentAppealYear int = NULL,
    @LikelyRep_Clear bit = 0,
    @LikelyRep nvarchar(200) = NULL,
    @RepStatus nvarchar(120),
    @RepsOnReductionJSON_Clear bit = 0,
    @RepsOnReductionJSON nvarchar(MAX) = NULL,
    @IsFreshProspect bit = NULL,
    @MailAddress_Clear bit = 0,
    @MailAddress nvarchar(400) = NULL,
    @ByTypeJSON_Clear bit = 0,
    @ByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[OwnerPortfolio]
            (
                [ID],
                [RunID],
                [OwnerKey],
                [Label],
                [Kind],
                [Tier],
                [GroupKeyType],
                [CoStarTrueOwner],
                [ParcelCount],
                [DistinctEntities],
                [TotalAV],
                [TotalAV2025],
                [TotalAV2026],
                [AVYoYDollars],
                [AVYoYPct],
                [ParcelsUp10],
                [ParcelsUp25],
                [TotalUnits],
                [TotalSqFt],
                [NAppealRec],
                [NTwoSupport],
                [NHighConfAppeal],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [AppealedParcels],
                [HistoricalReductionWon],
                [AppealYears],
                [MostRecentAppealYear],
                [LikelyRep],
                [RepStatus],
                [RepsOnReductionJSON],
                [IsFreshProspect],
                [MailAddress],
                [ByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @RunID,
                @OwnerKey,
                @Label,
                @Kind,
                CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, NULL) END,
                CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, NULL) END,
                CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, NULL) END,
                @ParcelCount,
                CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, NULL) END,
                CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, NULL) END,
                CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, NULL) END,
                CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, NULL) END,
                CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, NULL) END,
                CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, NULL) END,
                CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, NULL) END,
                CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, NULL) END,
                CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, NULL) END,
                CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, NULL) END,
                CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, NULL) END,
                CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, NULL) END,
                CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, NULL) END,
                @RepStatus,
                CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, NULL) END,
                ISNULL(@IsFreshProspect, 0),
                CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, NULL) END,
                CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[OwnerPortfolio]
            (
                [RunID],
                [OwnerKey],
                [Label],
                [Kind],
                [Tier],
                [GroupKeyType],
                [CoStarTrueOwner],
                [ParcelCount],
                [DistinctEntities],
                [TotalAV],
                [TotalAV2025],
                [TotalAV2026],
                [AVYoYDollars],
                [AVYoYPct],
                [ParcelsUp10],
                [ParcelsUp25],
                [TotalUnits],
                [TotalSqFt],
                [NAppealRec],
                [NTwoSupport],
                [NHighConfAppeal],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [AppealedParcels],
                [HistoricalReductionWon],
                [AppealYears],
                [MostRecentAppealYear],
                [LikelyRep],
                [RepStatus],
                [RepsOnReductionJSON],
                [IsFreshProspect],
                [MailAddress],
                [ByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @RunID,
                @OwnerKey,
                @Label,
                @Kind,
                CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, NULL) END,
                CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, NULL) END,
                CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, NULL) END,
                @ParcelCount,
                CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, NULL) END,
                CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, NULL) END,
                CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, NULL) END,
                CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, NULL) END,
                CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, NULL) END,
                CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, NULL) END,
                CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, NULL) END,
                CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, NULL) END,
                CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, NULL) END,
                CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, NULL) END,
                CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, NULL) END,
                CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, NULL) END,
                CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, NULL) END,
                @RepStatus,
                CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, NULL) END,
                ISNULL(@IsFreshProspect, 0),
                CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, NULL) END,
                CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwOwnerPortfolios] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spUpdateOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateOwnerPortfolio]
    @ID uniqueidentifier,
    @RunID uniqueidentifier = NULL,
    @OwnerKey nvarchar(200) = NULL,
    @Label nvarchar(300) = NULL,
    @Kind nvarchar(20) = NULL,
    @Tier_Clear bit = 0,
    @Tier nvarchar(12) = NULL,
    @GroupKeyType_Clear bit = 0,
    @GroupKeyType nvarchar(12) = NULL,
    @CoStarTrueOwner_Clear bit = 0,
    @CoStarTrueOwner nvarchar(300) = NULL,
    @ParcelCount int = NULL,
    @DistinctEntities_Clear bit = 0,
    @DistinctEntities int = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(18, 2) = NULL,
    @TotalAV2025_Clear bit = 0,
    @TotalAV2025 decimal(18, 2) = NULL,
    @TotalAV2026_Clear bit = 0,
    @TotalAV2026 decimal(18, 2) = NULL,
    @AVYoYDollars_Clear bit = 0,
    @AVYoYDollars decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @ParcelsUp10_Clear bit = 0,
    @ParcelsUp10 int = NULL,
    @ParcelsUp25_Clear bit = 0,
    @ParcelsUp25 int = NULL,
    @TotalUnits_Clear bit = 0,
    @TotalUnits int = NULL,
    @TotalSqFt_Clear bit = 0,
    @TotalSqFt bigint = NULL,
    @NAppealRec_Clear bit = 0,
    @NAppealRec int = NULL,
    @NTwoSupport_Clear bit = 0,
    @NTwoSupport int = NULL,
    @NHighConfAppeal_Clear bit = 0,
    @NHighConfAppeal int = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @AppealedParcels_Clear bit = 0,
    @AppealedParcels int = NULL,
    @HistoricalReductionWon_Clear bit = 0,
    @HistoricalReductionWon decimal(18, 2) = NULL,
    @AppealYears_Clear bit = 0,
    @AppealYears nvarchar(20) = NULL,
    @MostRecentAppealYear_Clear bit = 0,
    @MostRecentAppealYear int = NULL,
    @LikelyRep_Clear bit = 0,
    @LikelyRep nvarchar(200) = NULL,
    @RepStatus nvarchar(120) = NULL,
    @RepsOnReductionJSON_Clear bit = 0,
    @RepsOnReductionJSON nvarchar(MAX) = NULL,
    @IsFreshProspect bit = NULL,
    @MailAddress_Clear bit = 0,
    @MailAddress nvarchar(400) = NULL,
    @ByTypeJSON_Clear bit = 0,
    @ByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolio]
    SET
        [RunID] = ISNULL(@RunID, [RunID]),
        [OwnerKey] = ISNULL(@OwnerKey, [OwnerKey]),
        [Label] = ISNULL(@Label, [Label]),
        [Kind] = ISNULL(@Kind, [Kind]),
        [Tier] = CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, [Tier]) END,
        [GroupKeyType] = CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, [GroupKeyType]) END,
        [CoStarTrueOwner] = CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, [CoStarTrueOwner]) END,
        [ParcelCount] = ISNULL(@ParcelCount, [ParcelCount]),
        [DistinctEntities] = CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, [DistinctEntities]) END,
        [TotalAV] = CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, [TotalAV]) END,
        [TotalAV2025] = CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, [TotalAV2025]) END,
        [TotalAV2026] = CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, [TotalAV2026]) END,
        [AVYoYDollars] = CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, [AVYoYDollars]) END,
        [AVYoYPct] = CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, [AVYoYPct]) END,
        [ParcelsUp10] = CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, [ParcelsUp10]) END,
        [ParcelsUp25] = CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, [ParcelsUp25]) END,
        [TotalUnits] = CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, [TotalUnits]) END,
        [TotalSqFt] = CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, [TotalSqFt]) END,
        [NAppealRec] = CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, [NAppealRec]) END,
        [NTwoSupport] = CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, [NTwoSupport]) END,
        [NHighConfAppeal] = CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, [NHighConfAppeal]) END,
        [EstSavingsAtAsk] = CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, [EstSavingsAtAsk]) END,
        [EstSavingsAtFloor] = CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, [EstSavingsAtFloor]) END,
        [AppealedParcels] = CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, [AppealedParcels]) END,
        [HistoricalReductionWon] = CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, [HistoricalReductionWon]) END,
        [AppealYears] = CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, [AppealYears]) END,
        [MostRecentAppealYear] = CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, [MostRecentAppealYear]) END,
        [LikelyRep] = CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, [LikelyRep]) END,
        [RepStatus] = ISNULL(@RepStatus, [RepStatus]),
        [RepsOnReductionJSON] = CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, [RepsOnReductionJSON]) END,
        [IsFreshProspect] = ISNULL(@IsFreshProspect, [IsFreshProspect]),
        [MailAddress] = CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, [MailAddress]) END,
        [ByTypeJSON] = CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, [ByTypeJSON]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwOwnerPortfolios] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwOwnerPortfolios]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OwnerPortfolio table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateOwnerPortfolio]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateOwnerPortfolio];
GO
CREATE TRIGGER [indiana_tax].trgUpdateOwnerPortfolio
ON [indiana_tax].[OwnerPortfolio]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolio]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[OwnerPortfolio] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Owner Portfolio Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Runs
-- Item: spDeleteOwnerPortfolioRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OwnerPortfolioRun
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteOwnerPortfolioRun]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioRun];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioRun]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[OwnerPortfolioRun]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Owner Portfolio Runs */

GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioRun] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spDeleteOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteOwnerPortfolio]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[OwnerPortfolio]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: vwOwnerPortfolioParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Owner Portfolio Parcels
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  OwnerPortfolioParcel
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwOwnerPortfolioParcels]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwOwnerPortfolioParcels];
GO

CREATE VIEW [indiana_tax].[vwOwnerPortfolioParcels]
AS
SELECT
    o.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[OwnerPortfolioParcel] AS o
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [o].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: Permissions for vwOwnerPortfolioParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spCreateOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spCreateOwnerPortfolioParcel]
    @ID uniqueidentifier = NULL,
    @OwnerPortfolioID uniqueidentifier,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @GISParcelNumber nvarchar(20),
    @Address_Clear bit = 0,
    @Address nvarchar(300) = NULL,
    @TypeGroup_Clear bit = 0,
    @TypeGroup nvarchar(60) = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @AV2025_Clear bit = 0,
    @AV2025 decimal(18, 2) = NULL,
    @AV2026_Clear bit = 0,
    @AV2026 decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @SqFt_Clear bit = 0,
    @SqFt int = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @SalesIndicatedValue_Clear bit = 0,
    @SalesIndicatedValue decimal(18, 2) = NULL,
    @IncomeIndicatedValue_Clear bit = 0,
    @IncomeIndicatedValue decimal(18, 2) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(20) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(20) = NULL,
    @SupportingApproachCount_Clear bit = 0,
    @SupportingApproachCount int = NULL,
    @Appealed bit = NULL,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[OwnerPortfolioParcel]
            (
                [ID],
                [OwnerPortfolioID],
                [ParcelID],
                [GISParcelNumber],
                [Address],
                [TypeGroup],
                [CurrentAV],
                [AV2025],
                [AV2026],
                [AVYoYPct],
                [SqFt],
                [Units],
                [SalesIndicatedValue],
                [IncomeIndicatedValue],
                [FloorValue],
                [AskValue],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [Recommendation],
                [ConfidenceTier],
                [SupportingApproachCount],
                [Appealed],
                [ExistingRep],
                [LastAppealYear]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @OwnerPortfolioID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                @GISParcelNumber,
                CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, NULL) END,
                CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, NULL) END,
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, NULL) END,
                CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, NULL) END,
                CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, NULL) END,
                ISNULL(@Appealed, 0),
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[OwnerPortfolioParcel]
            (
                [OwnerPortfolioID],
                [ParcelID],
                [GISParcelNumber],
                [Address],
                [TypeGroup],
                [CurrentAV],
                [AV2025],
                [AV2026],
                [AVYoYPct],
                [SqFt],
                [Units],
                [SalesIndicatedValue],
                [IncomeIndicatedValue],
                [FloorValue],
                [AskValue],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [Recommendation],
                [ConfidenceTier],
                [SupportingApproachCount],
                [Appealed],
                [ExistingRep],
                [LastAppealYear]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @OwnerPortfolioID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                @GISParcelNumber,
                CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, NULL) END,
                CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, NULL) END,
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, NULL) END,
                CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, NULL) END,
                CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, NULL) END,
                ISNULL(@Appealed, 0),
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwOwnerPortfolioParcels] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spUpdateOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioParcel]
    @ID uniqueidentifier,
    @OwnerPortfolioID uniqueidentifier = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @GISParcelNumber nvarchar(20) = NULL,
    @Address_Clear bit = 0,
    @Address nvarchar(300) = NULL,
    @TypeGroup_Clear bit = 0,
    @TypeGroup nvarchar(60) = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @AV2025_Clear bit = 0,
    @AV2025 decimal(18, 2) = NULL,
    @AV2026_Clear bit = 0,
    @AV2026 decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @SqFt_Clear bit = 0,
    @SqFt int = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @SalesIndicatedValue_Clear bit = 0,
    @SalesIndicatedValue decimal(18, 2) = NULL,
    @IncomeIndicatedValue_Clear bit = 0,
    @IncomeIndicatedValue decimal(18, 2) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(20) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(20) = NULL,
    @SupportingApproachCount_Clear bit = 0,
    @SupportingApproachCount int = NULL,
    @Appealed bit = NULL,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioParcel]
    SET
        [OwnerPortfolioID] = ISNULL(@OwnerPortfolioID, [OwnerPortfolioID]),
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [GISParcelNumber] = ISNULL(@GISParcelNumber, [GISParcelNumber]),
        [Address] = CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, [Address]) END,
        [TypeGroup] = CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, [TypeGroup]) END,
        [CurrentAV] = CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, [CurrentAV]) END,
        [AV2025] = CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, [AV2025]) END,
        [AV2026] = CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, [AV2026]) END,
        [AVYoYPct] = CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, [AVYoYPct]) END,
        [SqFt] = CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, [SqFt]) END,
        [Units] = CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, [Units]) END,
        [SalesIndicatedValue] = CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, [SalesIndicatedValue]) END,
        [IncomeIndicatedValue] = CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, [IncomeIndicatedValue]) END,
        [FloorValue] = CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, [FloorValue]) END,
        [AskValue] = CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, [AskValue]) END,
        [EstSavingsAtAsk] = CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, [EstSavingsAtAsk]) END,
        [EstSavingsAtFloor] = CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, [EstSavingsAtFloor]) END,
        [Recommendation] = CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, [Recommendation]) END,
        [ConfidenceTier] = CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, [ConfidenceTier]) END,
        [SupportingApproachCount] = CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, [SupportingApproachCount]) END,
        [Appealed] = ISNULL(@Appealed, [Appealed]),
        [ExistingRep] = CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, [ExistingRep]) END,
        [LastAppealYear] = CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, [LastAppealYear]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwOwnerPortfolioParcels] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwOwnerPortfolioParcels]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OwnerPortfolioParcel table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateOwnerPortfolioParcel]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateOwnerPortfolioParcel];
GO
CREATE TRIGGER [indiana_tax].trgUpdateOwnerPortfolioParcel
ON [indiana_tax].[OwnerPortfolioParcel]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioParcel]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[OwnerPortfolioParcel] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spDeleteOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioParcel]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[OwnerPortfolioParcel]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 1 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3a3a962f-6897-4fbf-937a-b8f4b9379d01' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'Parcel')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3a3a962f-6897-4fbf-937a-b8f4b9379d01',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100053,
            'Parcel',
            'Parcel',
            NULL,
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'B561C795-E7DB-4450-84CA-1DA8D3B84392'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F6F41D15-8F56-4A7C-AA33-CD61C2AC251E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B561C795-E7DB-4450-84CA-1DA8D3B84392'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '691A0C89-F1D8-4AC6-A815-6FC6BE420333'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'F162BC7C-8810-4D29-9AFD-8728784EA5A0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '81A553A7-A44F-439F-9854-30CBB2D2C28A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '76434F21-A6AC-4D13-860C-890B1C74AF73'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'B561C795-E7DB-4450-84CA-1DA8D3B84392'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'B561C795-E7DB-4450-84CA-1DA8D3B84392'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'A6DFF796-F170-4179-98C8-003D0859B08A'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A6DFF796-F170-4179-98C8-003D0859B08A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8F069444-E566-4BD6-BB1E-9178E7C705D9'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'CC8E9CB9-D42C-4FA8-939B-B40202435815'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4201AE5E-5EE2-4E79-967A-6DAB160150D1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '967493C2-8A41-4609-A390-5107FEBC50C1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '50FAD769-754D-478B-A49F-C1F8D1E11D13'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '1514F4D5-BA2D-475B-9E2D-D95D29BABED2'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '1F0BBE0B-06AD-4EA5-AC7E-DC6E8096410B'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A6DFF796-F170-4179-98C8-003D0859B08A'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'E3176003-795B-4AB8-973F-EF44C1C7F449'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A9B7AE3E-10D7-48A9-8B1C-ABF4E48DBD16'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'B410000B-75B8-47B9-90D8-6359DD4F17E6'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A6DFF796-F170-4179-98C8-003D0859B08A'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'E3176003-795B-4AB8-973F-EF44C1C7F449'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A9B7AE3E-10D7-48A9-8B1C-ABF4E48DBD16'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '51447165-011F-4019-B4FA-685E84D61F5C'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '51447165-011F-4019-B4FA-685E84D61F5C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DD91DDE7-260F-4B7D-B52F-574723576516'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A12373A7-C884-4AD4-B3AB-6A1A1D8E13AE'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4061EAAE-C455-4CCE-BB27-57B4A4D1A1DE'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7B67EC78-26A0-4F91-82E7-EDA10D5CE9AF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '2937DA82-AD89-4EBE-ACD0-4241D48FB6FF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '4CE26113-E581-4037-93C0-26253C601E18'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DECF350E-FBF5-4CD3-823B-5CC85588E14F'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '51447165-011F-4019-B4FA-685E84D61F5C'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'DD91DDE7-260F-4B7D-B52F-574723576516'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A12373A7-C884-4AD4-B3AB-6A1A1D8E13AE'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '4CE26113-E581-4037-93C0-26253C601E18'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A4F70C46-92A0-400A-93C6-B7324275D5A3'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '51447165-011F-4019-B4FA-685E84D61F5C'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'DD91DDE7-260F-4B7D-B52F-574723576516'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A12373A7-C884-4AD4-B3AB-6A1A1D8E13AE'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '4CE26113-E581-4037-93C0-26253C601E18'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A4F70C46-92A0-400A-93C6-B7324275D5A3'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 17 fields */

-- UPDATE Entity Field Category Info Owner Portfolio Runs.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Run Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DF6A3E5B-DA30-4D47-BA8A-1EC3FC0A0250' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.RunDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Run Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F6F41D15-8F56-4A7C-AA33-CD61C2AC251E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.MethodologyVersion 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Run Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B561C795-E7DB-4450-84CA-1DA8D3B84392' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.IsLatest 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Run Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Latest Run',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '691A0C89-F1D8-4AC6-A815-6FC6BE420333' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F3E6F457-B357-4373-9086-CC4A68112904' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyTotalAV2025 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Total AV 2025',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F162BC7C-8810-4D29-9AFD-8728784EA5A0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyTotalAV2026 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Total AV 2026',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '81A553A7-A44F-439F-9854-30CBB2D2C28A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyYoYDollars 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   DisplayName = 'County YoY Dollars',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8D60EBED-53E9-432C-8094-E1D4EE9F603D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyYoYPct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   DisplayName = 'County YoY Percent',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '76434F21-A6AC-4D13-860C-890B1C74AF73' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelsUp5 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Parcel Distribution',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Parcels Up 5%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DA4BABC9-8E82-4CB1-9B06-826E728C730F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelsUp10 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Parcel Distribution',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Parcels Up 10%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9EA75DD4-5F1D-4D22-9097-63665BE2AE31' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelsUp25 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Parcel Distribution',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Parcels Up 25%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53BBCBE6-F494-4267-9783-B4631EDF3FD3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelsUp50 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Parcel Distribution',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Parcels Up 50%',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '10186622-AB50-44F9-BECC-F00A010FC6F1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyParcelsDown 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Parcel Distribution',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '48F9D8B9-F91C-430A-83B6-3B327979AC8A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.CountyByTypeJSON 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Assessment Rollup',
   GeneratedFormSection = 'Category',
   DisplayName = 'County By Type',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '1C2AFCAB-B768-48A4-A597-0627D6E2E32B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ABBAF0A3-6E73-4F68-B5D3-6DD57DB125B8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Runs.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AAB90DAC-463A-4389-A06D-8671337F8B51' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-chart-line */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-chart-line', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '949049EE-EAF1-49A3-A18E-861F7E7E56A9';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2ffb1ea7-4dc7-4da0-bbca-b0c28dc35a65', '949049EE-EAF1-49A3-A18E-861F7E7E56A9', 'FieldCategoryInfo', '{"Run Identification":{"icon":"fa fa-tag","description":"Portfolio run metadata including unique identifier, execution date, methodology version, and dashboard flag"},"County Assessment Rollup":{"icon":"fa fa-calculator","description":"County-wide aggregated assessed values for 2025 and 2026 including totals, year-over-year change, and property-type breakdown"},"County Parcel Distribution":{"icon":"fa fa-chart-bar","description":"Distribution of county parcels segmented by assessed value change thresholds"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e20e5c6f-f21b-42d7-b8b9-041b365e3b67', '949049EE-EAF1-49A3-A18E-861F7E7E56A9', 'FieldCategoryIcons', '{"Run Identification":"fa fa-tag","County Assessment Rollup":"fa fa-calculator","County Parcel Distribution":"fa fa-chart-bar","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '949049EE-EAF1-49A3-A18E-861F7E7E56A9';

/* Set categories for 36 fields */

-- UPDATE Entity Field Category Info Owner Portfolios.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4F34CA86-0BCD-4EB9-924B-3F4CD02A4FB6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.RunID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '58285950-1DCD-4ED4-864A-DBC2FB4901B0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A71FFBCC-DB44-487F-9519-A85683CC2512' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C8BDBD27-0E12-470C-9758-06F493BD4407' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.OwnerKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '1F0BBE0B-06AD-4EA5-AC7E-DC6E8096410B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.Label 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Owner Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A6DFF796-F170-4179-98C8-003D0859B08A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.Kind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Owner Type',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8F069444-E566-4BD6-BB1E-9178E7C705D9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.CoStarTrueOwner 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'CoStar True Owner',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E3176003-795B-4AB8-973F-EF44C1C7F449' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.Tier 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Prospect Tier',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CC8E9CB9-D42C-4FA8-939B-B40202435815' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.GroupKeyType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Grouping Method',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BECDB05E-2CB0-40DD-A7BC-67EAF77FE2BB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.MailAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Owner Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Mailing Address',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = 'B410000B-75B8-47B9-90D8-6359DD4F17E6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.ParcelCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Portfolio Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4201AE5E-5EE2-4E79-967A-6DAB160150D1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.DistinctEntities 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Portfolio Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '594AF888-A87E-44E3-B57F-9D664F1C81C3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.TotalUnits 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Portfolio Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6C0CA534-35E3-44FC-9367-AEE2451B6A7C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.TotalSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Portfolio Composition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Square Footage',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '84F0966F-F937-4238-B7B9-B3F41D414513' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.ByTypeJSON 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Portfolio Composition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Breakdown by Property Type',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '70E46EFB-A67F-465B-9439-375AD3156D07' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.TotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Current Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '967493C2-8A41-4609-A390-5107FEBC50C1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.TotalAV2025 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = '2025 Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0E635546-C1F9-4533-B650-EFDD7FA64268' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.TotalAV2026 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = '2026 Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5D4B3F5B-2824-4A4B-8E65-99C13DBFF3F0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.AVYoYDollars 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'AV Year-over-Year Change ($)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '28926C7B-F96A-4517-9272-256DFDE4BCAB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.AVYoYPct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'AV Year-over-Year Change (%)',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E9F595BB-31FC-4516-9569-B02076C1CC1F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.ParcelsUp10 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcels Up 10%+',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1E4667F6-64DD-4AEA-B016-A93CB8596837' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.ParcelsUp25 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Value Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcels Up 25%+',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '62D512A2-12B6-4FAC-8433-1BEE3D04DE97' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.NAppealRec 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis Opportunity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Recommendations',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AB0539BB-FD46-4984-9279-5DCBC880CFDB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.NTwoSupport 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis Opportunity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Two-Approach Support Count',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '990292B6-ABCA-4EB5-A24B-D9EBC1C7D511' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.NHighConfAppeal 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis Opportunity',
   GeneratedFormSection = 'Category',
   DisplayName = 'High Confidence Appeals',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2D5147A6-2DE7-4D16-8F8C-386C2A43027C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.EstSavingsAtAsk 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis Opportunity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est. Savings at Ask',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '50FAD769-754D-478B-A49F-C1F8D1E11D13' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.EstSavingsAtFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis Opportunity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est. Savings at Floor',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A42CC98-2B28-4DD0-BD37-DA41C522B591' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.AppealedParcels 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '96E7E4D6-5FC4-4603-8D9B-1EA41282A9F6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.HistoricalReductionWon 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3D94581D-55BB-4AE5-ABD8-163AAD1EFF50' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.AppealYears 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1C41AB07-22D9-4931-8B15-8F1F6318FDC5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.MostRecentAppealYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DE6543D7-71BE-4C58-A809-9AF72034FA88' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.LikelyRep 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Representation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Likely Tax Representative',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A9B7AE3E-10D7-48A9-8B1C-ABF4E48DBD16' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.RepStatus 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Representation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Tax Rep Status',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1514F4D5-BA2D-475B-9E2D-D95D29BABED2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.RepsOnReductionJSON 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Representation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Representatives on Record',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'B5EA56C6-D7FB-4754-9B8E-97969E05D293' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolios.IsFreshProspect 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Tax Representation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Fresh Prospect',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DEA55C11-5D9D-4F87-BDB5-B7AC746B6BBF' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for Owner Portfolios */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-building */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-building', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e8387311-a445-4da1-916f-c055b6cad967', '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', 'FieldCategoryInfo', '{"Owner Identification":{"icon":"fa fa-user-tie","description":"Owner identity, name normalization, classification, and contact information"},"Portfolio Composition":{"icon":"fa fa-th","description":"Aggregate portfolio structure including parcel count, property types, units, and square footage"},"Assessed Value Analysis":{"icon":"fa fa-chart-line","description":"Current and year-over-year assessed value metrics and trends"},"Valuation Analysis Opportunity":{"icon":"fa fa-search-dollar","description":"ValuationAnalysis appeal opportunities and estimated tax savings potential"},"Appeal History":{"icon":"fa fa-history","description":"Recorded appeals, reductions won, and historical appeal activity"},"Tax Representation":{"icon":"fa fa-briefcase","description":"Tax representative on record and representation status"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2fce9889-b64c-42a2-8366-c095030e3605', '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', 'FieldCategoryIcons', '{"Owner Identification":"fa fa-user-tie","Portfolio Composition":"fa fa-th","Assessed Value Analysis":"fa fa-chart-line","Valuation Analysis Opportunity":"fa fa-search-dollar","Appeal History":"fa fa-history","Tax Representation":"fa fa-briefcase","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4';

/* Set categories for 27 fields */

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5219F605-1517-416F-A053-8A28257FA2A7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.OwnerPortfolioID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Owner Portfolio',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0B8485B6-88E7-4FC7-B8F4-0ECF7BEA0735' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6EB3B03B-8C66-43B2-A160-9E9E6C0ADD26' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.GISParcelNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = NULL
WHERE 
   ID = '51447165-011F-4019-B4FA-685E84D61F5C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.Address 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Location',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = 'DD91DDE7-260F-4B7D-B52F-574723576516' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.TypeGroup 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Location',
   GeneratedFormSection = 'Category',
   DisplayName = 'Property Type Group',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A12373A7-C884-4AD4-B3AB-6A1A1D8E13AE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.SqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Location',
   GeneratedFormSection = 'Category',
   DisplayName = 'Square Footage',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BD0C55D0-868B-45D3-9929-EB286F75BF13' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.Units 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Location',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D86930F0-2FB0-48B6-B903-3D90BD5CF1FF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.CurrentAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Values',
   GeneratedFormSection = 'Category',
   DisplayName = 'Current Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A45FC552-AFEE-4061-98C2-BFD88DDFC599' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.AV2025 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Values',
   GeneratedFormSection = 'Category',
   DisplayName = '2025 Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4061EAAE-C455-4CCE-BB27-57B4A4D1A1DE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.AV2026 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Values',
   GeneratedFormSection = 'Category',
   DisplayName = '2026 Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7B67EC78-26A0-4F91-82E7-EDA10D5CE9AF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.AVYoYPct 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessed Values',
   GeneratedFormSection = 'Category',
   DisplayName = 'AV Year-over-Year Change %',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2937DA82-AD89-4EBE-ACD0-4241D48FB6FF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.SalesIndicatedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0F490F63-FA56-4D0C-A757-039FBE142FCD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.IncomeIndicatedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '891CD9B3-228C-4FA1-8D3F-D171F2A7FD66' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.FloorValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E7866995-BB70-428E-94F3-9AF71B0356A1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.AskValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A5FAE3A-4470-4B39-8908-172A5AA136C4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.SupportingApproachCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '21E793EC-52AE-4566-83DE-745FC93D86A3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.Recommendation 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Recommendation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4CE26113-E581-4037-93C0-26253C601E18' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.ConfidenceTier 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Recommendation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DECF350E-FBF5-4CD3-823B-5CC85588E14F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.EstSavingsAtAsk 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Recommendation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est. Savings at Ask Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F0BAE088-F518-4609-AAE0-13CBE5006A0A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.EstSavingsAtFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Recommendation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est. Savings at Floor Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '25BD8A3B-9DD9-41DA-B5B5-25FB61E3375A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.Appealed 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   DisplayName = 'Previously Appealed',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '64359068-66EC-4897-817B-C28178441AD1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.LastAppealYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '864FA015-1710-4EF3-82D6-7968F876D071' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.ExistingRep 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal History',
   GeneratedFormSection = 'Category',
   DisplayName = 'Existing Representative',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A4F70C46-92A0-400A-93C6-B7324275D5A3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Reference',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3A3A962F-6897-4FBF-937A-B8F4B9379D01' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '340F5D6B-5AAB-4EEE-A0EA-39ECA3C1A2F0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Owner Portfolio Parcels.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '71DC2AE4-10A5-4DA6-A64B-A49E86E8485D' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for Owner Portfolio Parcels */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-map-pin */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-map-pin', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('49da5252-1946-45df-8319-02d5ea979383', '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', 'FieldCategoryInfo', '{"Parcel Identification":{"icon":"fa fa-id-card","description":"Parcel identifiers and portfolio linkage including GIS parcel number"},"Parcel Location":{"icon":"fa fa-map-marker-alt","description":"Physical location, property type, and size characteristics"},"Assessed Values":{"icon":"fa fa-dollar-sign","description":"Current and projected assessed values with year-over-year trends"},"Valuation Analysis":{"icon":"fa fa-chart-line","description":"Three-approach valuation indications, recommended range, and supporting analysis count"},"Appeal Recommendation":{"icon":"fa fa-gavel","description":"Appeal action recommendation, confidence level, and estimated tax savings"},"Appeal History":{"icon":"fa fa-history","description":"Prior appeal status, year, and existing tax representative information"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('757b1a74-0675-4f06-a82b-016f52a917bb', '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', 'FieldCategoryIcons', '{"Parcel Identification":"fa fa-id-card","Parcel Location":"fa fa-map-marker-alt","Assessed Values":"fa fa-dollar-sign","Valuation Analysis":"fa fa-chart-line","Appeal Recommendation":"fa fa-gavel","Appeal History":"fa fa-history","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5';

/* Index for Foreign Keys for OwnerPortfolio */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key RunID in table OwnerPortfolio
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolio_RunID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolio]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolio_RunID ON [indiana_tax].[OwnerPortfolio] ([RunID]);

/* SQL text to update entity field related entity name field map for entity field ID 58285950-1DCD-4ED4-864A-DBC2FB4901B0 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='58285950-1DCD-4ED4-864A-DBC2FB4901B0', @RelatedEntityNameFieldMap='Run';

/* Base View SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: vwOwnerPortfolios
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Owner Portfolios
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  OwnerPortfolio
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwOwnerPortfolios]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwOwnerPortfolios];
GO

CREATE VIEW [indiana_tax].[vwOwnerPortfolios]
AS
SELECT
    o.*,
    indianataxOwnerPortfolioRun_RunID.[MethodologyVersion] AS [Run],
    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[OwnerPortfolio] AS o
INNER JOIN
    [indiana_tax].[OwnerPortfolioRun] AS indianataxOwnerPortfolioRun_RunID
  ON
    [o].[RunID] = indianataxOwnerPortfolioRun_RunID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([o].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwOwnerPortfolios] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: Permissions for vwOwnerPortfolios
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwOwnerPortfolios] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spCreateOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spCreateOwnerPortfolio]
    @ID uniqueidentifier = NULL,
    @RunID uniqueidentifier,
    @OwnerKey nvarchar(200),
    @Label nvarchar(300),
    @Kind nvarchar(20),
    @Tier_Clear bit = 0,
    @Tier nvarchar(12) = NULL,
    @GroupKeyType_Clear bit = 0,
    @GroupKeyType nvarchar(12) = NULL,
    @CoStarTrueOwner_Clear bit = 0,
    @CoStarTrueOwner nvarchar(300) = NULL,
    @ParcelCount int,
    @DistinctEntities_Clear bit = 0,
    @DistinctEntities int = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(18, 2) = NULL,
    @TotalAV2025_Clear bit = 0,
    @TotalAV2025 decimal(18, 2) = NULL,
    @TotalAV2026_Clear bit = 0,
    @TotalAV2026 decimal(18, 2) = NULL,
    @AVYoYDollars_Clear bit = 0,
    @AVYoYDollars decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @ParcelsUp10_Clear bit = 0,
    @ParcelsUp10 int = NULL,
    @ParcelsUp25_Clear bit = 0,
    @ParcelsUp25 int = NULL,
    @TotalUnits_Clear bit = 0,
    @TotalUnits int = NULL,
    @TotalSqFt_Clear bit = 0,
    @TotalSqFt bigint = NULL,
    @NAppealRec_Clear bit = 0,
    @NAppealRec int = NULL,
    @NTwoSupport_Clear bit = 0,
    @NTwoSupport int = NULL,
    @NHighConfAppeal_Clear bit = 0,
    @NHighConfAppeal int = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @AppealedParcels_Clear bit = 0,
    @AppealedParcels int = NULL,
    @HistoricalReductionWon_Clear bit = 0,
    @HistoricalReductionWon decimal(18, 2) = NULL,
    @AppealYears_Clear bit = 0,
    @AppealYears nvarchar(20) = NULL,
    @MostRecentAppealYear_Clear bit = 0,
    @MostRecentAppealYear int = NULL,
    @LikelyRep_Clear bit = 0,
    @LikelyRep nvarchar(200) = NULL,
    @RepStatus nvarchar(120),
    @RepsOnReductionJSON_Clear bit = 0,
    @RepsOnReductionJSON nvarchar(MAX) = NULL,
    @IsFreshProspect bit = NULL,
    @MailAddress_Clear bit = 0,
    @MailAddress nvarchar(400) = NULL,
    @ByTypeJSON_Clear bit = 0,
    @ByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[OwnerPortfolio]
            (
                [ID],
                [RunID],
                [OwnerKey],
                [Label],
                [Kind],
                [Tier],
                [GroupKeyType],
                [CoStarTrueOwner],
                [ParcelCount],
                [DistinctEntities],
                [TotalAV],
                [TotalAV2025],
                [TotalAV2026],
                [AVYoYDollars],
                [AVYoYPct],
                [ParcelsUp10],
                [ParcelsUp25],
                [TotalUnits],
                [TotalSqFt],
                [NAppealRec],
                [NTwoSupport],
                [NHighConfAppeal],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [AppealedParcels],
                [HistoricalReductionWon],
                [AppealYears],
                [MostRecentAppealYear],
                [LikelyRep],
                [RepStatus],
                [RepsOnReductionJSON],
                [IsFreshProspect],
                [MailAddress],
                [ByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @RunID,
                @OwnerKey,
                @Label,
                @Kind,
                CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, NULL) END,
                CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, NULL) END,
                CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, NULL) END,
                @ParcelCount,
                CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, NULL) END,
                CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, NULL) END,
                CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, NULL) END,
                CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, NULL) END,
                CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, NULL) END,
                CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, NULL) END,
                CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, NULL) END,
                CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, NULL) END,
                CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, NULL) END,
                CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, NULL) END,
                CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, NULL) END,
                CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, NULL) END,
                CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, NULL) END,
                @RepStatus,
                CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, NULL) END,
                ISNULL(@IsFreshProspect, 0),
                CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, NULL) END,
                CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[OwnerPortfolio]
            (
                [RunID],
                [OwnerKey],
                [Label],
                [Kind],
                [Tier],
                [GroupKeyType],
                [CoStarTrueOwner],
                [ParcelCount],
                [DistinctEntities],
                [TotalAV],
                [TotalAV2025],
                [TotalAV2026],
                [AVYoYDollars],
                [AVYoYPct],
                [ParcelsUp10],
                [ParcelsUp25],
                [TotalUnits],
                [TotalSqFt],
                [NAppealRec],
                [NTwoSupport],
                [NHighConfAppeal],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [AppealedParcels],
                [HistoricalReductionWon],
                [AppealYears],
                [MostRecentAppealYear],
                [LikelyRep],
                [RepStatus],
                [RepsOnReductionJSON],
                [IsFreshProspect],
                [MailAddress],
                [ByTypeJSON]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @RunID,
                @OwnerKey,
                @Label,
                @Kind,
                CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, NULL) END,
                CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, NULL) END,
                CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, NULL) END,
                @ParcelCount,
                CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, NULL) END,
                CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, NULL) END,
                CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, NULL) END,
                CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, NULL) END,
                CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, NULL) END,
                CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, NULL) END,
                CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, NULL) END,
                CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, NULL) END,
                CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, NULL) END,
                CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, NULL) END,
                CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, NULL) END,
                CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, NULL) END,
                CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, NULL) END,
                @RepStatus,
                CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, NULL) END,
                ISNULL(@IsFreshProspect, 0),
                CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, NULL) END,
                CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwOwnerPortfolios] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spUpdateOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateOwnerPortfolio]
    @ID uniqueidentifier,
    @RunID uniqueidentifier = NULL,
    @OwnerKey nvarchar(200) = NULL,
    @Label nvarchar(300) = NULL,
    @Kind nvarchar(20) = NULL,
    @Tier_Clear bit = 0,
    @Tier nvarchar(12) = NULL,
    @GroupKeyType_Clear bit = 0,
    @GroupKeyType nvarchar(12) = NULL,
    @CoStarTrueOwner_Clear bit = 0,
    @CoStarTrueOwner nvarchar(300) = NULL,
    @ParcelCount int = NULL,
    @DistinctEntities_Clear bit = 0,
    @DistinctEntities int = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(18, 2) = NULL,
    @TotalAV2025_Clear bit = 0,
    @TotalAV2025 decimal(18, 2) = NULL,
    @TotalAV2026_Clear bit = 0,
    @TotalAV2026 decimal(18, 2) = NULL,
    @AVYoYDollars_Clear bit = 0,
    @AVYoYDollars decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @ParcelsUp10_Clear bit = 0,
    @ParcelsUp10 int = NULL,
    @ParcelsUp25_Clear bit = 0,
    @ParcelsUp25 int = NULL,
    @TotalUnits_Clear bit = 0,
    @TotalUnits int = NULL,
    @TotalSqFt_Clear bit = 0,
    @TotalSqFt bigint = NULL,
    @NAppealRec_Clear bit = 0,
    @NAppealRec int = NULL,
    @NTwoSupport_Clear bit = 0,
    @NTwoSupport int = NULL,
    @NHighConfAppeal_Clear bit = 0,
    @NHighConfAppeal int = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @AppealedParcels_Clear bit = 0,
    @AppealedParcels int = NULL,
    @HistoricalReductionWon_Clear bit = 0,
    @HistoricalReductionWon decimal(18, 2) = NULL,
    @AppealYears_Clear bit = 0,
    @AppealYears nvarchar(20) = NULL,
    @MostRecentAppealYear_Clear bit = 0,
    @MostRecentAppealYear int = NULL,
    @LikelyRep_Clear bit = 0,
    @LikelyRep nvarchar(200) = NULL,
    @RepStatus nvarchar(120) = NULL,
    @RepsOnReductionJSON_Clear bit = 0,
    @RepsOnReductionJSON nvarchar(MAX) = NULL,
    @IsFreshProspect bit = NULL,
    @MailAddress_Clear bit = 0,
    @MailAddress nvarchar(400) = NULL,
    @ByTypeJSON_Clear bit = 0,
    @ByTypeJSON nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolio]
    SET
        [RunID] = ISNULL(@RunID, [RunID]),
        [OwnerKey] = ISNULL(@OwnerKey, [OwnerKey]),
        [Label] = ISNULL(@Label, [Label]),
        [Kind] = ISNULL(@Kind, [Kind]),
        [Tier] = CASE WHEN @Tier_Clear = 1 THEN NULL ELSE ISNULL(@Tier, [Tier]) END,
        [GroupKeyType] = CASE WHEN @GroupKeyType_Clear = 1 THEN NULL ELSE ISNULL(@GroupKeyType, [GroupKeyType]) END,
        [CoStarTrueOwner] = CASE WHEN @CoStarTrueOwner_Clear = 1 THEN NULL ELSE ISNULL(@CoStarTrueOwner, [CoStarTrueOwner]) END,
        [ParcelCount] = ISNULL(@ParcelCount, [ParcelCount]),
        [DistinctEntities] = CASE WHEN @DistinctEntities_Clear = 1 THEN NULL ELSE ISNULL(@DistinctEntities, [DistinctEntities]) END,
        [TotalAV] = CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, [TotalAV]) END,
        [TotalAV2025] = CASE WHEN @TotalAV2025_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2025, [TotalAV2025]) END,
        [TotalAV2026] = CASE WHEN @TotalAV2026_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV2026, [TotalAV2026]) END,
        [AVYoYDollars] = CASE WHEN @AVYoYDollars_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYDollars, [AVYoYDollars]) END,
        [AVYoYPct] = CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, [AVYoYPct]) END,
        [ParcelsUp10] = CASE WHEN @ParcelsUp10_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp10, [ParcelsUp10]) END,
        [ParcelsUp25] = CASE WHEN @ParcelsUp25_Clear = 1 THEN NULL ELSE ISNULL(@ParcelsUp25, [ParcelsUp25]) END,
        [TotalUnits] = CASE WHEN @TotalUnits_Clear = 1 THEN NULL ELSE ISNULL(@TotalUnits, [TotalUnits]) END,
        [TotalSqFt] = CASE WHEN @TotalSqFt_Clear = 1 THEN NULL ELSE ISNULL(@TotalSqFt, [TotalSqFt]) END,
        [NAppealRec] = CASE WHEN @NAppealRec_Clear = 1 THEN NULL ELSE ISNULL(@NAppealRec, [NAppealRec]) END,
        [NTwoSupport] = CASE WHEN @NTwoSupport_Clear = 1 THEN NULL ELSE ISNULL(@NTwoSupport, [NTwoSupport]) END,
        [NHighConfAppeal] = CASE WHEN @NHighConfAppeal_Clear = 1 THEN NULL ELSE ISNULL(@NHighConfAppeal, [NHighConfAppeal]) END,
        [EstSavingsAtAsk] = CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, [EstSavingsAtAsk]) END,
        [EstSavingsAtFloor] = CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, [EstSavingsAtFloor]) END,
        [AppealedParcels] = CASE WHEN @AppealedParcels_Clear = 1 THEN NULL ELSE ISNULL(@AppealedParcels, [AppealedParcels]) END,
        [HistoricalReductionWon] = CASE WHEN @HistoricalReductionWon_Clear = 1 THEN NULL ELSE ISNULL(@HistoricalReductionWon, [HistoricalReductionWon]) END,
        [AppealYears] = CASE WHEN @AppealYears_Clear = 1 THEN NULL ELSE ISNULL(@AppealYears, [AppealYears]) END,
        [MostRecentAppealYear] = CASE WHEN @MostRecentAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@MostRecentAppealYear, [MostRecentAppealYear]) END,
        [LikelyRep] = CASE WHEN @LikelyRep_Clear = 1 THEN NULL ELSE ISNULL(@LikelyRep, [LikelyRep]) END,
        [RepStatus] = ISNULL(@RepStatus, [RepStatus]),
        [RepsOnReductionJSON] = CASE WHEN @RepsOnReductionJSON_Clear = 1 THEN NULL ELSE ISNULL(@RepsOnReductionJSON, [RepsOnReductionJSON]) END,
        [IsFreshProspect] = ISNULL(@IsFreshProspect, [IsFreshProspect]),
        [MailAddress] = CASE WHEN @MailAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailAddress, [MailAddress]) END,
        [ByTypeJSON] = CASE WHEN @ByTypeJSON_Clear = 1 THEN NULL ELSE ISNULL(@ByTypeJSON, [ByTypeJSON]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwOwnerPortfolios] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwOwnerPortfolios]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OwnerPortfolio table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateOwnerPortfolio]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateOwnerPortfolio];
GO
CREATE TRIGGER [indiana_tax].trgUpdateOwnerPortfolio
ON [indiana_tax].[OwnerPortfolio]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolio]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[OwnerPortfolio] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Owner Portfolios */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolios
-- Item: spDeleteOwnerPortfolio
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OwnerPortfolio
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteOwnerPortfolio]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteOwnerPortfolio];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteOwnerPortfolio]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[OwnerPortfolio]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Owner Portfolios */

GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolio] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for OwnerPortfolioParcel */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OwnerPortfolioID in table OwnerPortfolioParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_OwnerPortfolioID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolioParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_OwnerPortfolioID ON [indiana_tax].[OwnerPortfolioParcel] ([OwnerPortfolioID]);

-- Index for foreign key ParcelID in table OwnerPortfolioParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[OwnerPortfolioParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_OwnerPortfolioParcel_ParcelID ON [indiana_tax].[OwnerPortfolioParcel] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 0B8485B6-88E7-4FC7-B8F4-0ECF7BEA0735 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0B8485B6-88E7-4FC7-B8F4-0ECF7BEA0735', @RelatedEntityNameFieldMap='OwnerPortfolio';

/* Base View SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: vwOwnerPortfolioParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Owner Portfolio Parcels
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  OwnerPortfolioParcel
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwOwnerPortfolioParcels]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwOwnerPortfolioParcels];
GO

CREATE VIEW [indiana_tax].[vwOwnerPortfolioParcels]
AS
SELECT
    o.*,
    indianataxOwnerPortfolio_OwnerPortfolioID.[Label] AS [OwnerPortfolio],
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[OwnerPortfolioParcel] AS o
INNER JOIN
    [indiana_tax].[OwnerPortfolio] AS indianataxOwnerPortfolio_OwnerPortfolioID
  ON
    [o].[OwnerPortfolioID] = indianataxOwnerPortfolio_OwnerPortfolioID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [o].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([o].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: Permissions for vwOwnerPortfolioParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwOwnerPortfolioParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spCreateOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spCreateOwnerPortfolioParcel]
    @ID uniqueidentifier = NULL,
    @OwnerPortfolioID uniqueidentifier,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @GISParcelNumber nvarchar(20),
    @Address_Clear bit = 0,
    @Address nvarchar(300) = NULL,
    @TypeGroup_Clear bit = 0,
    @TypeGroup nvarchar(60) = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @AV2025_Clear bit = 0,
    @AV2025 decimal(18, 2) = NULL,
    @AV2026_Clear bit = 0,
    @AV2026 decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @SqFt_Clear bit = 0,
    @SqFt int = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @SalesIndicatedValue_Clear bit = 0,
    @SalesIndicatedValue decimal(18, 2) = NULL,
    @IncomeIndicatedValue_Clear bit = 0,
    @IncomeIndicatedValue decimal(18, 2) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(20) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(20) = NULL,
    @SupportingApproachCount_Clear bit = 0,
    @SupportingApproachCount int = NULL,
    @Appealed bit = NULL,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[OwnerPortfolioParcel]
            (
                [ID],
                [OwnerPortfolioID],
                [ParcelID],
                [GISParcelNumber],
                [Address],
                [TypeGroup],
                [CurrentAV],
                [AV2025],
                [AV2026],
                [AVYoYPct],
                [SqFt],
                [Units],
                [SalesIndicatedValue],
                [IncomeIndicatedValue],
                [FloorValue],
                [AskValue],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [Recommendation],
                [ConfidenceTier],
                [SupportingApproachCount],
                [Appealed],
                [ExistingRep],
                [LastAppealYear]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @OwnerPortfolioID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                @GISParcelNumber,
                CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, NULL) END,
                CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, NULL) END,
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, NULL) END,
                CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, NULL) END,
                CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, NULL) END,
                ISNULL(@Appealed, 0),
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[OwnerPortfolioParcel]
            (
                [OwnerPortfolioID],
                [ParcelID],
                [GISParcelNumber],
                [Address],
                [TypeGroup],
                [CurrentAV],
                [AV2025],
                [AV2026],
                [AVYoYPct],
                [SqFt],
                [Units],
                [SalesIndicatedValue],
                [IncomeIndicatedValue],
                [FloorValue],
                [AskValue],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [Recommendation],
                [ConfidenceTier],
                [SupportingApproachCount],
                [Appealed],
                [ExistingRep],
                [LastAppealYear]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @OwnerPortfolioID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                @GISParcelNumber,
                CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, NULL) END,
                CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, NULL) END,
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, NULL) END,
                CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, NULL) END,
                CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, NULL) END,
                CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, NULL) END,
                CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, NULL) END,
                CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, NULL) END,
                CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, NULL) END,
                ISNULL(@Appealed, 0),
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwOwnerPortfolioParcels] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spCreateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spUpdateOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateOwnerPortfolioParcel]
    @ID uniqueidentifier,
    @OwnerPortfolioID uniqueidentifier = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @GISParcelNumber nvarchar(20) = NULL,
    @Address_Clear bit = 0,
    @Address nvarchar(300) = NULL,
    @TypeGroup_Clear bit = 0,
    @TypeGroup nvarchar(60) = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @AV2025_Clear bit = 0,
    @AV2025 decimal(18, 2) = NULL,
    @AV2026_Clear bit = 0,
    @AV2026 decimal(18, 2) = NULL,
    @AVYoYPct_Clear bit = 0,
    @AVYoYPct decimal(9, 4) = NULL,
    @SqFt_Clear bit = 0,
    @SqFt int = NULL,
    @Units_Clear bit = 0,
    @Units int = NULL,
    @SalesIndicatedValue_Clear bit = 0,
    @SalesIndicatedValue decimal(18, 2) = NULL,
    @IncomeIndicatedValue_Clear bit = 0,
    @IncomeIndicatedValue decimal(18, 2) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(18, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(18, 2) = NULL,
    @Recommendation_Clear bit = 0,
    @Recommendation nvarchar(20) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(20) = NULL,
    @SupportingApproachCount_Clear bit = 0,
    @SupportingApproachCount int = NULL,
    @Appealed bit = NULL,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @LastAppealYear_Clear bit = 0,
    @LastAppealYear int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioParcel]
    SET
        [OwnerPortfolioID] = ISNULL(@OwnerPortfolioID, [OwnerPortfolioID]),
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [GISParcelNumber] = ISNULL(@GISParcelNumber, [GISParcelNumber]),
        [Address] = CASE WHEN @Address_Clear = 1 THEN NULL ELSE ISNULL(@Address, [Address]) END,
        [TypeGroup] = CASE WHEN @TypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@TypeGroup, [TypeGroup]) END,
        [CurrentAV] = CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, [CurrentAV]) END,
        [AV2025] = CASE WHEN @AV2025_Clear = 1 THEN NULL ELSE ISNULL(@AV2025, [AV2025]) END,
        [AV2026] = CASE WHEN @AV2026_Clear = 1 THEN NULL ELSE ISNULL(@AV2026, [AV2026]) END,
        [AVYoYPct] = CASE WHEN @AVYoYPct_Clear = 1 THEN NULL ELSE ISNULL(@AVYoYPct, [AVYoYPct]) END,
        [SqFt] = CASE WHEN @SqFt_Clear = 1 THEN NULL ELSE ISNULL(@SqFt, [SqFt]) END,
        [Units] = CASE WHEN @Units_Clear = 1 THEN NULL ELSE ISNULL(@Units, [Units]) END,
        [SalesIndicatedValue] = CASE WHEN @SalesIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesIndicatedValue, [SalesIndicatedValue]) END,
        [IncomeIndicatedValue] = CASE WHEN @IncomeIndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeIndicatedValue, [IncomeIndicatedValue]) END,
        [FloorValue] = CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, [FloorValue]) END,
        [AskValue] = CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, [AskValue]) END,
        [EstSavingsAtAsk] = CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, [EstSavingsAtAsk]) END,
        [EstSavingsAtFloor] = CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, [EstSavingsAtFloor]) END,
        [Recommendation] = CASE WHEN @Recommendation_Clear = 1 THEN NULL ELSE ISNULL(@Recommendation, [Recommendation]) END,
        [ConfidenceTier] = CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, [ConfidenceTier]) END,
        [SupportingApproachCount] = CASE WHEN @SupportingApproachCount_Clear = 1 THEN NULL ELSE ISNULL(@SupportingApproachCount, [SupportingApproachCount]) END,
        [Appealed] = ISNULL(@Appealed, [Appealed]),
        [ExistingRep] = CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, [ExistingRep]) END,
        [LastAppealYear] = CASE WHEN @LastAppealYear_Clear = 1 THEN NULL ELSE ISNULL(@LastAppealYear, [LastAppealYear]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwOwnerPortfolioParcels] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwOwnerPortfolioParcels]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the OwnerPortfolioParcel table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateOwnerPortfolioParcel]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateOwnerPortfolioParcel];
GO
CREATE TRIGGER [indiana_tax].trgUpdateOwnerPortfolioParcel
ON [indiana_tax].[OwnerPortfolioParcel]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[OwnerPortfolioParcel]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[OwnerPortfolioParcel] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spUpdateOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Owner Portfolio Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Owner Portfolio Parcels
-- Item: spDeleteOwnerPortfolioParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR OwnerPortfolioParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteOwnerPortfolioParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioParcel];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteOwnerPortfolioParcel]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[OwnerPortfolioParcel]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Owner Portfolio Parcels */

GRANT EXECUTE ON [indiana_tax].[spDeleteOwnerPortfolioParcel] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 6 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '82914b23-fcf3-4a05-afc2-5c1effa236f1' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = 'OwnerPortfolio')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '82914b23-fcf3-4a05-afc2-5c1effa236f1',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100054,
            'OwnerPortfolio',
            'Owner Portfolio',
            NULL,
            'nvarchar',
            600,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b530fd88-b909-4d38-8422-93e04a6ce562' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b530fd88-b909-4d38-8422-93e04a6ce562',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100056,
            '${flyway:defaultSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3223ad5c-573b-4cb1-ad39-3fc0e788fce1' OR (EntityID = '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3223ad5c-573b-4cb1-ad39-3fc0e788fce1',
            '8D8F38A4-5F7C-4A22-9021-9C81BA3484E5', -- Entity: Owner Portfolio Parcels
            100057,
            '${flyway:defaultSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3fc438ef-ef9a-4361-a615-e79ced6c64fd' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = 'Run')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3fc438ef-ef9a-4361-a615-e79ced6c64fd',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100073,
            'Run',
            'Run',
            NULL,
            'nvarchar',
            120,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dfb7dd29-ce43-4207-8e05-839819ae04f5' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dfb7dd29-ce43-4207-8e05-839819ae04f5',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100074,
            '${flyway:defaultSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '25d30982-61cb-4637-a16d-3e53b86aca89' OR (EntityID = '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '25d30982-61cb-4637-a16d-3e53b86aca89',
            '3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4', -- Entity: Owner Portfolios
            100075,
            '${flyway:defaultSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
            6,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* Set ExtendedType=GeoLatitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${flyway:defaultSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4','8D8F38A4-5F7C-4A22-9021-9C81BA3484E5');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${flyway:defaultSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('3A5C3501-7A0C-4C7C-A80C-DD7033CF2DA4','8D8F38A4-5F7C-4A22-9021-9C81BA3484E5');

