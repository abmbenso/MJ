/* ============================================================================
   Indiana Property Tax Expert — appeal lead scoring
   v5.52.x

   Brings in the Marion County appeal-lead scoring output (originally a
   standalone script/CSV: score_appeal_leads.py) as queryable data. Peer-group
   outlier detection on improvement AV/sqft, a year-over-year jump flag, and a
   historical PTABOA win-rate signal by property class -- ranked by estimated
   dollar excess assessed value. Full methodology in the source script's own
   docstring; the short version: this is a statistical screen for appeal
   candidates, not a substitute for reviewing a flagged parcel.

   Only lead-specific analytical columns live here -- parcel/owner/address
   fields already exist on Parcel and are reached via ParcelID, not duplicated.

   KNOWN METHODOLOGY GAP (tracked in ResearchTask, not fixed by this
   migration): improvement_av_per_sqft divides improvement AV by TOTAL
   building square footage, which includes garage space. Garage improvements
   don't carry the same dollar-for-dollar value as enclosed building space, so
   a parcel with a large garage looks artificially cheap-per-sqft (or a parcel
   without one looks artificially expensive) in the peer comparison. GarageSqFt
   and HasGarage are included here (computed from building_detail.use_code =
   'COMGAR', confirmed available in the source data) so a corrected comparison
   can be built without re-deriving this from scratch -- but the Rank/
   ExcessRatio/EstimatedExcessAV columns on this pass still reflect the
   ORIGINAL uncorrected total-sqft methodology. MethodologyVersion marks which
   scoring pass produced a row so a future corrected pass doesn't get
   silently confused with this one.
   ============================================================================ */

CREATE TABLE indiana_tax.AppealLead (
    ID                              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ParcelID                        UNIQUEIDENTIFIER NOT NULL,
    Rank                            INT              NULL,
    CurrentLandAV                   DECIMAL(14,2)    NULL,
    CurrentImprovementAV            DECIMAL(14,2)    NULL,
    CurrentTotalAV                  DECIMAL(14,2)    NULL,
    PriorTotalAV                    DECIMAL(14,2)    NULL,
    YoyPctChange                    DECIMAL(9,6)     NULL,
    YoyJumpFlag                     BIT              NULL,
    Grade                           NVARCHAR(10)     NULL,
    ConditionCode                   NVARCHAR(10)     NULL,
    YearConstructed                 SMALLINT         NULL,
    EffectiveConstructionYear       SMALLINT         NULL,
    BuildingSqFt                    DECIMAL(14,2)    NULL,
    GarageSqFt                      DECIMAL(14,2)    NULL,
    HasGarage                       BIT              NULL,
    ImprovementAVPerSqFt            DECIMAL(14,4)    NULL,
    PeerMedianImprovementAVPerSqFt  DECIMAL(14,4)    NULL,
    PeerGroupBasis                  NVARCHAR(20)     NULL,
    PeerGroupSize                   INT              NULL,
    ExcessRatio                     DECIMAL(9,4)     NULL,
    EstimatedExcessAV               DECIMAL(14,2)    NULL,
    PeerAppealCount                 INT              NULL,
    PeerAppealWins                  INT              NULL,
    PeerWinRate                     DECIMAL(9,6)     NULL,
    PeerAvgPctReduction             DECIMAL(9,6)     NULL,
    AbsenteeOwnerFlag               BIT              NULL,
    OutOfCityOwnerFlag              BIT              NULL,
    MethodologyVersion              NVARCHAR(30)     NOT NULL,
    GeneratedAt                     DATETIMEOFFSET   NOT NULL CONSTRAINT DF_AppealLead_GeneratedAt DEFAULT (SYSDATETIMEOFFSET()),
    CONSTRAINT PK_AppealLead PRIMARY KEY (ID),
    CONSTRAINT FK_AppealLead_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A scored appeal-candidate lead: a parcel flagged as likely over-assessed via peer-group improvement AV/sqft outlier detection, a year-over-year jump, and historical PTABOA win-rate by property class. Ranked by estimated dollar excess AV. Statistical screen, not a substitute for reviewing the flagged parcel. KNOWN GAP: current rows use total building sqft (including garage space) in the comparison -- see MethodologyVersion and the corresponding ResearchTask.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel this lead concerns.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'ParcelID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Rank by EstimatedExcessAV within this scoring pass (1 = highest estimated excess). No minimum case-size floor -- rank order matters more than a cutoff.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'Rank';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Year-over-year percent change in total AV (current vs. prior source pull).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'YoyPctChange';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Flagged when YoyPctChange met or exceeded the jump threshold (15% in the original methodology) -- a second, independent trigger from the peer-group comparison.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'YoyJumpFlag';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total building square footage summed across all building rows for the parcel (source: building.total_square_foot_area). Includes garage space -- kept as a sanity-check total, not the basis for a corrected per-sqft comparison. See GarageSqFt.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'BuildingSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Square footage identified as commercial garage space (source: building_detail rows where use_code = ''COMGAR''), so it can be excluded or separately weighted in a corrected improvement-AV-per-sqft comparison. NULL where not yet computed for this parcel, not necessarily zero.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'GarageSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether any COMGAR (commercial garage) square footage was found for this parcel.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'HasGarage';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'This parcel''s improvement AV divided by TOTAL building sqft (including garage space) -- the metric actually used to rank this scoring pass. See the table-level note on the known garage-weighting gap.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'ImprovementAVPerSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Median ImprovementAVPerSqFt within this parcel''s peer group (property class + grade, falling back to class alone when the group is too thin).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerMedianImprovementAVPerSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which peer-group basis was used: "class+grade" or the class-only fallback (used when the class+grade group had fewer than the minimum peer-group size).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerGroupBasis';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'This parcel''s ImprovementAVPerSqFt divided by its peer group''s median -- the core outlier-detection ratio driving the rank.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'ExcessRatio';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Estimated dollar excess assessed value implied by ExcessRatio -- what the ranking is sorted by.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'EstimatedExcessAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Count of historical real-property (non-BPP) PTABOA appeals for this parcel''s property class that resolve to a parcel in this database''s scope -- a directional signal, not a precise win rate (covers a minority of all real-property appeals filed).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerAppealCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Of PeerAppealCount, how many resulted in a reduction.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerAppealWins';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'PeerAppealWins / PeerAppealCount for this property class.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerWinRate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Average percent reduction among winning appeals for this property class.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'PeerAvgPctReduction';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner''s mailing address differs from the property address -- a lead-qualification signal, not a data-quality flag.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'AbsenteeOwnerFlag';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Owner''s mailing address is outside the property''s city.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'OutOfCityOwnerFlag';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Which scoring methodology pass produced this row (e.g. "v1-total-sqft-2026"). Exists specifically so a future corrected pass (garage-adjusted comparison) is distinguishable from this one rather than silently overwriting/mixing with it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'MethodologyVersion';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When this scoring pass was run.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'AppealLead',
    @level2type = N'COLUMN', @level2name = N'GeneratedAt';
GO
