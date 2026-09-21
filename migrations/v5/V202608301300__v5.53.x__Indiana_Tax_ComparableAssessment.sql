/* ============================================================================
   Indiana Property Tax Expert — Comparable Assessments (uniformity / equity)
   v5.53.x

   Step 3 of Indiana_Tax_Expert/docs/proposals/comparable-assessments.md.

   Persists a "comparable assessments" workup for a subject parcel: the two
   ranked lists of physically similar properties (Neighborhood, County-wide),
   the analyst's include/exclude choices, and the headline per-unit comparison
   (subject vs comp mean/median, subject percentile).

   Feedstock is the read-only view indiana_tax.ParcelPhysicalProfile plus
   indiana_tax.PTABOAAppeal (for the appealed/effective value tracks). The
   builder is scripts/build-comparable-assessments.js; the persist step is
   scripts/save-comparable-assessment-set.js.

   Value tracks per year, per the proposal:
     Original  = Assessment.OriginalTotalAV (PRC, as-noticed) -- anchor
     Appealed  = PTABOAAppeal FinalDetermination (IBTR/Final) else After (PTABOA),
                 matched on PTABOAAppeal.AssessmentYear
     Effective = Appealed if present else Original            -- headline default

   One ComparableAssessmentSet per (SubjectParcelID, FocusYear,
   MethodologyVersion); ComparableAssessmentMember rows hang off it (managed by
   the loader -- no ON DELETE CASCADE, deletes are explicit).
   ============================================================================ */

CREATE TABLE indiana_tax.ComparableAssessmentSet (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    SubjectParcelID UNIQUEIDENTIFIER NOT NULL,
    FocusYear SMALLINT NOT NULL,
    MethodologyVersion NVARCHAR(30) NOT NULL,

    PropertyTypeGroup NVARCHAR(30) NULL,
    UnitOfComparison NVARCHAR(10) NOT NULL
        CONSTRAINT CK_ComparableAssessmentSet_UoC CHECK (UnitOfComparison IN ('$/SF', '$/unit', '$/acre')),
    HeadlineTrack NVARCHAR(10) NOT NULL
        CONSTRAINT DF_ComparableAssessmentSet_HeadlineTrack DEFAULT ('Effective')
        CONSTRAINT CK_ComparableAssessmentSet_HeadlineTrack CHECK (HeadlineTrack IN ('Original', 'Appealed', 'Effective')),

    SubjectDenomValue DECIMAL(14, 2) NULL,
    SubjectOriginalAV DECIMAL(14, 2) NULL,
    SubjectEffectiveAV DECIMAL(14, 2) NULL,
    SubjectPerUnitEffective DECIMAL(14, 2) NULL,

    NeighborhoodCode NVARCHAR(120) NULL,
    NeighborhoodCompCount INT NULL,
    NeighborhoodMeanPerUnit DECIMAL(14, 2) NULL,
    NeighborhoodMedianPerUnit DECIMAL(14, 2) NULL,

    CountyCompCount INT NULL,
    CountyMeanPerUnit DECIMAL(14, 2) NULL,
    CountyMedianPerUnit DECIMAL(14, 2) NULL,

    SubjectPercentile SMALLINT NULL,

    Status NVARCHAR(10) NOT NULL
        CONSTRAINT DF_ComparableAssessmentSet_Status DEFAULT ('Draft')
        CONSTRAINT CK_ComparableAssessmentSet_Status CHECK (Status IN ('Draft', 'Final')),
    AnalystNote NVARCHAR(MAX) NULL,
    GeneratedAt DATETIMEOFFSET NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ComparableAssessmentSet_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ComparableAssessmentSet_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ComparableAssessmentSet PRIMARY KEY (ID),
    CONSTRAINT UQ_ComparableAssessmentSet UNIQUE (SubjectParcelID, FocusYear, MethodologyVersion),
    CONSTRAINT FK_ComparableAssessmentSet_Parcel FOREIGN KEY (SubjectParcelID)
        REFERENCES indiana_tax.Parcel (ID)
);
GO

CREATE TABLE indiana_tax.ComparableAssessmentMember (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ComparableAssessmentSetID UNIQUEIDENTIFIER NOT NULL,
    ComparableParcelID UNIQUEIDENTIFIER NOT NULL,

    GeographyBucket NVARCHAR(14) NOT NULL
        CONSTRAINT CK_ComparableAssessmentMember_Bucket CHECK (GeographyBucket IN ('Neighborhood', 'County')),

    SimilarityScore DECIMAL(9, 4) NULL,
    SizeLnRatio DECIMAL(9, 4) NULL,
    EffectiveYearDelta SMALLINT NULL,
    GradeDelta DECIMAL(5, 2) NULL,
    ClassMatchLevel NVARCHAR(12) NULL
        CONSTRAINT CK_ComparableAssessmentMember_ClassMatch CHECK (ClassMatchLevel IN ('exact', '3-digit', 'group-only')),
    SimilarityBreakdown NVARCHAR(MAX) NULL,

    IsSelected BIT NOT NULL
        CONSTRAINT DF_ComparableAssessmentMember_IsSelected DEFAULT (0),
    SortOrder INT NULL,
    AnalystNote NVARCHAR(MAX) NULL,

    -- snapshot of the comp at generation time (physical + value tracks, focus year)
    ComparableBuildingSqFt INT NULL,
    ComparableUnitCount DECIMAL(12, 2) NULL,
    ComparableEffectiveYear SMALLINT NULL,
    ComparableGradeCode NVARCHAR(8) NULL,
    DenomValue DECIMAL(14, 2) NULL,
    OriginalAV DECIMAL(14, 2) NULL,
    AppealedAV DECIMAL(14, 2) NULL,
    AppealLevel NVARCHAR(16) NULL,
    AppealPctChange DECIMAL(7, 2) NULL,
    AppealRepresentative NVARCHAR(200) NULL,
    EffectiveAV DECIMAL(14, 2) NULL,
    OriginalPerUnit DECIMAL(14, 2) NULL,
    EffectivePerUnit DECIMAL(14, 2) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ComparableAssessmentMember_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ComparableAssessmentMember_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ComparableAssessmentMember PRIMARY KEY (ID),
    CONSTRAINT UQ_ComparableAssessmentMember UNIQUE (ComparableAssessmentSetID, ComparableParcelID),
    CONSTRAINT FK_ComparableAssessmentMember_Set FOREIGN KEY (ComparableAssessmentSetID)
        REFERENCES indiana_tax.ComparableAssessmentSet (ID),
    CONSTRAINT FK_ComparableAssessmentMember_Parcel FOREIGN KEY (ComparableParcelID)
        REFERENCES indiana_tax.Parcel (ID)
);
GO
CREATE INDEX IX_ComparableAssessmentMember_Set ON indiana_tax.ComparableAssessmentMember (ComparableAssessmentSetID, GeographyBucket, SortOrder);
GO

/* -------------------------- extended properties --------------------------- */

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A comparable-assessments (uniformity / equity) workup for one subject parcel: the ranked Neighborhood and County-wide lists of physically similar properties, the analyst''s include/exclude choices (ComparableAssessmentMember), and the headline per-unit comparison. Design: Indiana_Tax_Expert/docs/proposals/comparable-assessments.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The subject parcel being analysed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The assessment year the per-unit comparison is struck for.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'FocusYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Version tag for the builder logic that produced this set (e.g. "comps-v1-2026-08-30"). Lets a re-run replace its own set without touching an earlier method''s.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'MethodologyVersion';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Rolled-up property category the comp pool was drawn from.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'PropertyTypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Unit of comparison: $/SF (default), $/unit (multifamily with a trustworthy unit count), or $/acre (land).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'UnitOfComparison';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Which value track drives the headline: Original (as-noticed), Appealed (post-PTABOA/IBTR), or Effective (Appealed if present else Original). Default Effective -- the hardest benchmark for the county to rebut.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'HeadlineTrack';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The subject''s denominator for the unit of comparison (building SF, unit count, or acres).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectDenomValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Subject as-noticed Original total AV for the focus year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectOriginalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Subject Effective total AV for the focus year (Appealed if the subject itself has a PTABOA/IBTR result, else Original).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectEffectiveAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'SubjectEffectiveAV / SubjectDenomValue -- the number the comp means/medians are measured against.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectPerUnitEffective';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The subject''s CountyAssessorRecord.Neighborhood code -- the pool for the Neighborhood list.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'NeighborhoodCode';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of Neighborhood-list members with a usable per-unit value (basis for the mean/median).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'NeighborhoodCompCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Mean Effective per-unit value across the Neighborhood list (focus year). Can mislead when the neighborhood is thin and building sizes vary widely -- prefer the median.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'NeighborhoodMeanPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Median Effective per-unit value across the Neighborhood list (focus year).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'NeighborhoodMedianPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Count of County-list members with a usable per-unit value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'CountyCompCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Mean Effective per-unit value across the County-wide list (focus year).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'CountyMeanPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Median Effective per-unit value across the County-wide list (focus year).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'CountyMedianPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Percentile the subject''s per-unit value sits at within the combined comp set (0-100; higher = more over-assessed relative to peers).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'SubjectPercentile';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Draft (builder output, not yet reviewed) or Final (analyst has reviewed the selections).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'Status';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Free-text analyst / agent notes on the set.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'AnalystNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'When the builder generated this set.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentSet', @level2type = N'COLUMN', @level2name = N'GeneratedAt';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One comparable property within a ComparableAssessmentSet: its similarity score + component deltas, the analyst''s include flag, and a snapshot of its physical attributes and value tracks (Original / Appealed / Effective) for the set''s focus year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The set this comp belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableAssessmentSetID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The comparable parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableParcelID';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Which list this comp came from: Neighborhood (same code, ungated) or County (county-wide, strict physical gate).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'GeographyBucket';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Weighted physical-similarity distance (lower = more similar).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'SimilarityScore';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'abs(ln(subject building SF / comp building SF)) -- the size-match component, exposed for review.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'SizeLnRatio';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'abs(subject effective year - comp effective year).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'EffectiveYearDelta';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'abs difference of the mapped grade ordinal (C=3, C+=3.33, B=4, ...).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'GradeDelta';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'How closely the state class codes match: exact (5-digit), 3-digit, or group-only.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ClassMatchLevel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'JSON: the full weighted-component breakdown behind SimilarityScore.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'SimilarityBreakdown';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Analyst''s choice: is this comp included in the headline mean/median? Builder seeds this (Neighborhood + gated County members start selected).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'IsSelected';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Display order within the bucket (1 = most similar).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'SortOrder';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Free-text note on this comp (why kept / dropped).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'AnalystNote';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Snapshot: comp building SF at generation time.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableBuildingSqFt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Snapshot: comp unit count (trustworthy-filtered) at generation time.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableUnitCount';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Snapshot: comp effective year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableEffectiveYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Snapshot: comp grade code.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'ComparableGradeCode';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The comp''s own denominator for the set''s unit of comparison.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'DenomValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Comp as-noticed Original total AV for the focus year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'OriginalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Comp appealed total AV for the focus year (PTABOA After or IBTR/Final determination), NULL if the comp did not appeal that year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'AppealedAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Level the appealed value came from: PTABOA or IBTR/Final.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'AppealLevel';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Percent change of the appealed value vs the pre-appeal base (negative = reduction).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'AppealPctChange';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tax representative of record on the comp''s appeal, if any.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'AppealRepresentative';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Comp Effective total AV for the focus year (Appealed if present else Original).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'EffectiveAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'OriginalAV / DenomValue.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'OriginalPerUnit';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'EffectiveAV / DenomValue -- the value that flows into the headline mean/median when IsSelected.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ComparableAssessmentMember', @level2type = N'COLUMN', @level2name = N'EffectivePerUnit';
GO
