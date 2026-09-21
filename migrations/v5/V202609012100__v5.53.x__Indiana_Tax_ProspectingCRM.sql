/* ============================================================================
   Indiana Property Tax Expert — Prospecting CRM  (docs/proposals/prospecting-crm.md)
   v5.53.x   Phase 1: entities

   An "analytical CRM" layer over the Owner Prospects screen
   (scripts/build-owner-portfolios.js): flag a target operating company, scope
   the potential representation to specific parcels, capture the
   decision-makers, and drive an outreach queue -- with deal metrics refreshed
   from the assessment data on every portfolio re-run.

   NOT a system of record (the firm has InterAction for relationships /
   conflicts of record / billing). Everything here is human-entered opinion +
   workflow state, kept in its own tables, never commingled with researched
   assessment facts. The only bridge is ProspectSnapshot, written FROM the
   portfolio job and read-only on the pipeline side.

   6 entities:
     Prospect          -- the account (one per operating company; OwnerKey unique)
     ProspectContact   -- decision-makers
     ProspectParcel    -- scoped parcels, with per-parcel disposition
     ProspectActivity  -- dated outreach log
     ProspectTask      -- the queue
     ProspectSnapshot  -- metric history (written by the portfolio job)
   ============================================================================ */

/* -------------------------------------------------------------------------- */
/* Prospect                                                                   */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.Prospect (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    OwnerKey NVARCHAR(200) NOT NULL,             -- normalized CoStarTrueOwner (fallback MailKey + norm name); stable across portfolio re-runs
    DisplayName NVARCHAR(300) NOT NULL,
    RelationshipType NVARCHAR(30) NOT NULL CONSTRAINT DF_Prospect_RelType DEFAULT ('Unknown'),
    Stage NVARCHAR(30) NOT NULL CONSTRAINT DF_Prospect_Stage DEFAULT ('Identified'),
    StageEnteredDate DATE NULL,
    Priority NVARCHAR(10) NOT NULL CONSTRAINT DF_Prospect_Priority DEFAULT ('Medium'),
    AssignedTo NVARCHAR(200) NULL,

    IdentifiedDate DATE NULL,
    IdentificationSource NVARCHAR(120) NULL,
    NextActionDate DATE NULL,

    ConflictCheckStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Prospect_Conflict DEFAULT ('NotStarted'),
    ConflictCheckNote NVARCHAR(1000) NULL,

    Thesis NVARCHAR(2000) NULL,                  -- "the hook"
    EstimatedOpportunityAtAsk DECIMAL(18, 2) NULL,   -- convenience copy of the latest snapshot, for sorting

    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Prospect_Status DEFAULT ('Open'),
    ClosedDate DATE NULL,
    ClosedReason NVARCHAR(500) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_Prospect_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_Prospect_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_Prospect PRIMARY KEY (ID),
    CONSTRAINT UQ_Prospect_OwnerKey UNIQUE (OwnerKey),
    CONSTRAINT CK_Prospect_RelType CHECK (RelationshipType IN ('Cold','ExistingClientExpand','CompetitorRepped','FormerClient','Unknown')),
    CONSTRAINT CK_Prospect_Stage CHECK (Stage IN ('Identified','Qualified','Contacted','Engaged','Pitched','Retained','Active','ClosedLost','Dormant')),
    CONSTRAINT CK_Prospect_Priority CHECK (Priority IN ('High','Medium','Low')),
    CONSTRAINT CK_Prospect_Conflict CHECK (ConflictCheckStatus IN ('NotStarted','Requested','Cleared','Blocked','Waived')),
    CONSTRAINT CK_Prospect_Status CHECK (Status IN ('Open','Won','Lost','Dormant'))
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A flagged prospecting target -- one operating company we are pursuing for property tax representation. Built over the Owner Prospects screen (scripts/build-owner-portfolios.js). Human-entered pipeline / workflow state; NOT a system of record. See docs/proposals/prospecting-crm.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Stable join key = normalized ParcelOwnerResolved.CoStarTrueOwner (fallback: MailKey + normalized RawOwnerName). This -- not a regenerated row id -- is what re-links a prospect to the portfolio screen across re-runs. Unique.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect', @level2type = N'COLUMN', @level2name = N'OwnerKey';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cold | ExistingClientExpand | CompetitorRepped | FormerClient | Unknown. The routing signal: ExistingClientExpand (e.g. Keystone, Square Deal show "Represented by FAEGRE DRINKER" in the screen) goes to the relationship partner as cross-sell, not cold outreach.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect', @level2type = N'COLUMN', @level2name = N'RelationshipType';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Pipeline stage. May not advance past Qualified until ConflictCheckStatus is Cleared or Waived.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect', @level2type = N'COLUMN', @level2name = N'Stage';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Free text -- the reason this target was flagged, e.g. "bought the Sheraton (1097651) below the 2026 AV; 9 Marion parcels, $135M AV".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect', @level2type = N'COLUMN', @level2name = N'Thesis';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Convenience copy of the most recent ProspectSnapshot.OpportunityAtAsk, maintained by scripts/sync-prospect-snapshots.js, so the pipeline can be sorted by dollars without a join.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Prospect', @level2type = N'COLUMN', @level2name = N'EstimatedOpportunityAtAsk';
GO

/* -------------------------------------------------------------------------- */
/* ProspectContact                                                            */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.ProspectContact (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ProspectID UNIQUEIDENTIFIER NOT NULL,

    Name NVARCHAR(200) NOT NULL,
    Title NVARCHAR(200) NULL,
    Role NVARCHAR(60) NULL,                      -- AssetManager | CFO | GeneralCounsel | Principal | OutsideRep | Other
    Email NVARCHAR(200) NULL,
    Phone NVARCHAR(50) NULL,
    LinkedInURL NVARCHAR(400) NULL,
    SourceNote NVARCHAR(500) NULL,               -- how we know this person
    KnownToFirm BIT NOT NULL CONSTRAINT DF_ProspectContact_Known DEFAULT (0),
    FirmContactNote NVARCHAR(500) NULL,
    IsPrimary BIT NOT NULL CONSTRAINT DF_ProspectContact_Primary DEFAULT (0),

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectContact_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectContact_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ProspectContact PRIMARY KEY (ID),
    CONSTRAINT FK_ProspectContact_Prospect FOREIGN KEY (ProspectID) REFERENCES indiana_tax.Prospect (ID),
    CONSTRAINT CK_ProspectContact_Role CHECK (Role IS NULL OR Role IN ('AssetManager','CFO','GeneralCounsel','Principal','OutsideRep','Other'))
);
GO
CREATE INDEX IX_ProspectContact_Prospect ON indiana_tax.ProspectContact (ProspectID);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A decision-maker or influencer at a Prospect company -- asset manager, CFO, GC, principal, or the outside tax rep. KnownToFirm flags an existing Faegre relationship with this individual.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectContact';
GO

/* -------------------------------------------------------------------------- */
/* ProspectParcel                                                             */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.ProspectParcel (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ProspectID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,

    Disposition NVARCHAR(40) NOT NULL CONSTRAINT DF_ProspectParcel_Disp DEFAULT ('InScope'),
    DispositionNote NVARCHAR(500) NULL,
    IsTrigger BIT NOT NULL CONSTRAINT DF_ProspectParcel_Trigger DEFAULT (0),
    ExistingRep NVARCHAR(200) NULL,

    SnapshotAV DECIMAL(18, 2) NULL,
    SnapshotOpportunityAtAsk DECIMAL(18, 2) NULL,
    SnapshotOpportunityAtFloor DECIMAL(18, 2) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectParcel_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectParcel_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ProspectParcel PRIMARY KEY (ID),
    CONSTRAINT FK_ProspectParcel_Prospect FOREIGN KEY (ProspectID) REFERENCES indiana_tax.Prospect (ID),
    CONSTRAINT FK_ProspectParcel_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_ProspectParcel UNIQUE (ProspectID, ParcelID),
    CONSTRAINT CK_ProspectParcel_Disp CHECK (Disposition IN ('InScope','AlreadyRepresented','Excluded','Monitoring'))
);
GO
CREATE INDEX IX_ProspectParcel_Prospect ON indiana_tax.ProspectParcel (ProspectID);
CREATE INDEX IX_ProspectParcel_Parcel ON indiana_tax.ProspectParcel (ParcelID);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A parcel attached to a Prospect. Disposition scopes the pursuit to specific parcels rather than the owner''s whole footprint (e.g. the Keystone reconciliation: only 3 of ~21 portfolio projects are actually owned -> the rest are Excluded with a note). IsTrigger marks the parcel/event that prompted identification.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectParcel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'InScope | AlreadyRepresented | Excluded | Monitoring.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectParcel', @level2type = N'COLUMN', @level2name = N'Disposition';
GO

/* -------------------------------------------------------------------------- */
/* ProspectActivity                                                           */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.ProspectActivity (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ProspectID UNIQUEIDENTIFIER NOT NULL,
    ContactID UNIQUEIDENTIFIER NULL,

    ActivityDate DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectActivity_Date DEFAULT (SYSDATETIMEOFFSET()),
    ActivityType NVARCHAR(40) NOT NULL,          -- Email | Call | Meeting | Referral | ProposalSent | RFP | Note | ConflictCheck | StageChange
    Direction NVARCHAR(10) NULL,                 -- Outbound | Inbound | Internal
    Summary NVARCHAR(2000) NOT NULL,
    Outcome NVARCHAR(1000) NULL,
    LoggedBy NVARCHAR(200) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectActivity_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectActivity_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ProspectActivity PRIMARY KEY (ID),
    CONSTRAINT FK_ProspectActivity_Prospect FOREIGN KEY (ProspectID) REFERENCES indiana_tax.Prospect (ID),
    CONSTRAINT FK_ProspectActivity_Contact FOREIGN KEY (ContactID) REFERENCES indiana_tax.ProspectContact (ID),
    CONSTRAINT CK_ProspectActivity_Type CHECK (ActivityType IN ('Email','Call','Meeting','Referral','ProposalSent','RFP','Note','ConflictCheck','StageChange')),
    CONSTRAINT CK_ProspectActivity_Dir CHECK (Direction IS NULL OR Direction IN ('Outbound','Inbound','Internal'))
);
GO
CREATE INDEX IX_ProspectActivity_Prospect ON indiana_tax.ProspectActivity (ProspectID, ActivityDate DESC);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A dated touch on a Prospect -- email, call, meeting, referral, proposal, RFP, internal note, conflict-check step, or a stage change. The outreach log.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectActivity';
GO

/* -------------------------------------------------------------------------- */
/* ProspectTask                                                               */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.ProspectTask (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ProspectID UNIQUEIDENTIFIER NOT NULL,
    SourceActivityID UNIQUEIDENTIFIER NULL,

    Title NVARCHAR(400) NOT NULL,
    DueDate DATE NULL,
    Assignee NVARCHAR(200) NULL,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_ProspectTask_Status DEFAULT ('Open'),
    CompletedDate DATE NULL,
    Notes NVARCHAR(1000) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectTask_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectTask_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ProspectTask PRIMARY KEY (ID),
    CONSTRAINT FK_ProspectTask_Prospect FOREIGN KEY (ProspectID) REFERENCES indiana_tax.Prospect (ID),
    CONSTRAINT FK_ProspectTask_Activity FOREIGN KEY (SourceActivityID) REFERENCES indiana_tax.ProspectActivity (ID),
    CONSTRAINT CK_ProspectTask_Status CHECK (Status IN ('Open','InProgress','Done','Cancelled'))
);
GO
CREATE INDEX IX_ProspectTask_Queue ON indiana_tax.ProspectTask (Assignee, Status, DueDate);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The outreach queue -- one actionable item per row. A "next step" logged on a ProspectActivity spawns a ProspectTask via SourceActivityID. Drives the My Queue view.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectTask';
GO

/* -------------------------------------------------------------------------- */
/* ProspectSnapshot                                                           */
/* -------------------------------------------------------------------------- */
CREATE TABLE indiana_tax.ProspectSnapshot (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ProspectID UNIQUEIDENTIFIER NOT NULL,

    SnapshotDate DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectSnapshot_Date DEFAULT (SYSDATETIMEOFFSET()),
    PortfolioRunTag NVARCHAR(60) NULL,           -- e.g. the build-owner-portfolios.js run date

    ParcelCount INT NULL,
    TotalAV DECIMAL(18, 2) NULL,
    TotalTaxLiability DECIMAL(18, 2) NULL,
    OpportunityAtAsk DECIMAL(18, 2) NULL,
    OpportunityAtFloor DECIMAL(18, 2) NULL,
    RepdParcelCount INT NULL,
    FreshParcelCount INT NULL,
    AVYoYPct DECIMAL(9, 4) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectSnapshot_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ProspectSnapshot_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ProspectSnapshot PRIMARY KEY (ID),
    CONSTRAINT FK_ProspectSnapshot_Prospect FOREIGN KEY (ProspectID) REFERENCES indiana_tax.Prospect (ID)
);
GO
CREATE INDEX IX_ProspectSnapshot_Prospect ON indiana_tax.ProspectSnapshot (ProspectID, SnapshotDate DESC);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Point-in-time deal metrics for a Prospect, written by the portfolio job (scripts/sync-prospect-snapshots.js) on each build-owner-portfolios.js run -- never edited by hand. The two newest rows drive the "Scope changed" view (parcel added/sold, AV moved >10%, a repped parcel went un-repped, opportunity crossed a threshold).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ProspectSnapshot';
GO
