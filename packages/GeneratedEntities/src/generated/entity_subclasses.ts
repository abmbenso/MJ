import { BaseEntity, EntitySaveOptions, EntityDeleteOptions, CompositeKey, ValidationResult, ValidationErrorInfo, ValidationErrorType, Metadata, ProviderType, DatabaseProviderBase } from "@memberjunction/core";
import { RegisterClass } from "@memberjunction/global";
import { z } from "zod";

export const loadModule = () => {
  // no-op, only used to ensure this file is a valid module and to allow easy loading
}

     
 
/**
 * zod schema definition for the entity Appeal Leads
 */
export const indianataxAppealLeadSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this lead concerns.`),
    Rank: z.number().nullable().describe(`
        * * Field Name: Rank
        * * Display Name: Rank
        * * SQL Data Type: int
        * * Description: Rank by EstimatedExcessAV within this scoring pass (1 = highest estimated excess). No minimum case-size floor -- rank order matters more than a cutoff.`),
    CurrentLandAV: z.number().nullable().describe(`
        * * Field Name: CurrentLandAV
        * * Display Name: Current Land AV
        * * SQL Data Type: decimal(14, 2)`),
    CurrentImprovementAV: z.number().nullable().describe(`
        * * Field Name: CurrentImprovementAV
        * * Display Name: Current Improvement AV
        * * SQL Data Type: decimal(14, 2)`),
    CurrentTotalAV: z.number().nullable().describe(`
        * * Field Name: CurrentTotalAV
        * * Display Name: Current Total AV
        * * SQL Data Type: decimal(14, 2)`),
    PriorTotalAV: z.number().nullable().describe(`
        * * Field Name: PriorTotalAV
        * * Display Name: Prior Total AV
        * * SQL Data Type: decimal(14, 2)`),
    YoyPctChange: z.number().nullable().describe(`
        * * Field Name: YoyPctChange
        * * Display Name: YoY Percent Change
        * * SQL Data Type: decimal(9, 6)
        * * Description: Year-over-year percent change in total AV (current vs. prior source pull).`),
    YoyJumpFlag: z.boolean().nullable().describe(`
        * * Field Name: YoyJumpFlag
        * * Display Name: YoY Jump Flag
        * * SQL Data Type: bit
        * * Description: Flagged when YoyPctChange met or exceeded the jump threshold (15% in the original methodology) -- a second, independent trigger from the peer-group comparison.`),
    Grade: z.string().nullable().describe(`
        * * Field Name: Grade
        * * Display Name: Grade
        * * SQL Data Type: nvarchar(10)`),
    ConditionCode: z.string().nullable().describe(`
        * * Field Name: ConditionCode
        * * Display Name: Condition Code
        * * SQL Data Type: nvarchar(10)`),
    YearConstructed: z.number().nullable().describe(`
        * * Field Name: YearConstructed
        * * Display Name: Year Constructed
        * * SQL Data Type: smallint`),
    EffectiveConstructionYear: z.number().nullable().describe(`
        * * Field Name: EffectiveConstructionYear
        * * Display Name: Effective Construction Year
        * * SQL Data Type: smallint`),
    BuildingSqFt: z.number().nullable().describe(`
        * * Field Name: BuildingSqFt
        * * Display Name: Building Sqft
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total building square footage summed across all building rows for the parcel (source: building.total_square_foot_area). Includes garage space -- kept as a sanity-check total, not the basis for a corrected per-sqft comparison. See GarageSqFt.`),
    GarageSqFt: z.number().nullable().describe(`
        * * Field Name: GarageSqFt
        * * Display Name: Garage Sqft
        * * SQL Data Type: decimal(14, 2)
        * * Description: Square footage identified as commercial garage space (source: building_detail rows where use_code = 'COMGAR'), so it can be excluded or separately weighted in a corrected improvement-AV-per-sqft comparison. NULL where not yet computed for this parcel, not necessarily zero.`),
    HasGarage: z.boolean().nullable().describe(`
        * * Field Name: HasGarage
        * * Display Name: Has Garage
        * * SQL Data Type: bit
        * * Description: Whether any COMGAR (commercial garage) square footage was found for this parcel.`),
    ImprovementAVPerSqFt: z.number().nullable().describe(`
        * * Field Name: ImprovementAVPerSqFt
        * * Display Name: Improvement AV Per Sqft
        * * SQL Data Type: decimal(14, 4)
        * * Description: This parcel's improvement AV divided by TOTAL building sqft (including garage space) -- the metric actually used to rank this scoring pass. See the table-level note on the known garage-weighting gap.`),
    PeerMedianImprovementAVPerSqFt: z.number().nullable().describe(`
        * * Field Name: PeerMedianImprovementAVPerSqFt
        * * Display Name: Peer Median Improvement AV Per Sqft
        * * SQL Data Type: decimal(14, 4)
        * * Description: Median ImprovementAVPerSqFt within this parcel's peer group (property class + grade, falling back to class alone when the group is too thin).`),
    PeerGroupBasis: z.string().nullable().describe(`
        * * Field Name: PeerGroupBasis
        * * Display Name: Peer Group Basis
        * * SQL Data Type: nvarchar(50)
        * * Description: How the peer comparison group was defined for this parcel (e.g. "class+grade", or a coarser fallback like "class only (class+grade too thin)" when the class+grade bucket had too few peers). Widened to NVARCHAR(50) after the original NVARCHAR(20) proved too small for the fallback-description strings the methodology actually produces.`),
    PeerGroupSize: z.number().nullable().describe(`
        * * Field Name: PeerGroupSize
        * * Display Name: Peer Group Size
        * * SQL Data Type: int`),
    ExcessRatio: z.number().nullable().describe(`
        * * Field Name: ExcessRatio
        * * Display Name: Excess Ratio
        * * SQL Data Type: decimal(9, 4)
        * * Description: This parcel's ImprovementAVPerSqFt divided by its peer group's median -- the core outlier-detection ratio driving the rank.`),
    EstimatedExcessAV: z.number().nullable().describe(`
        * * Field Name: EstimatedExcessAV
        * * Display Name: Estimated Excess AV
        * * SQL Data Type: decimal(14, 2)
        * * Description: Estimated dollar excess assessed value implied by ExcessRatio -- what the ranking is sorted by.`),
    PeerAppealCount: z.number().nullable().describe(`
        * * Field Name: PeerAppealCount
        * * Display Name: Peer Appeal Count
        * * SQL Data Type: int
        * * Description: Count of historical real-property (non-BPP) PTABOA appeals for this parcel's property class that resolve to a parcel in this database's scope -- a directional signal, not a precise win rate (covers a minority of all real-property appeals filed).`),
    PeerAppealWins: z.number().nullable().describe(`
        * * Field Name: PeerAppealWins
        * * Display Name: Peer Appeal Wins
        * * SQL Data Type: int
        * * Description: Of PeerAppealCount, how many resulted in a reduction.`),
    PeerWinRate: z.number().nullable().describe(`
        * * Field Name: PeerWinRate
        * * Display Name: Peer Win Rate
        * * SQL Data Type: decimal(9, 6)
        * * Description: PeerAppealWins / PeerAppealCount for this property class.`),
    PeerAvgPctReduction: z.number().nullable().describe(`
        * * Field Name: PeerAvgPctReduction
        * * Display Name: Peer Avg Pct Reduction
        * * SQL Data Type: decimal(9, 6)
        * * Description: Average percent reduction among winning appeals for this property class.`),
    AbsenteeOwnerFlag: z.boolean().nullable().describe(`
        * * Field Name: AbsenteeOwnerFlag
        * * Display Name: Absentee Owner Flag
        * * SQL Data Type: bit
        * * Description: Owner's mailing address differs from the property address -- a lead-qualification signal, not a data-quality flag.`),
    OutOfCityOwnerFlag: z.boolean().nullable().describe(`
        * * Field Name: OutOfCityOwnerFlag
        * * Display Name: Out of City Owner Flag
        * * SQL Data Type: bit
        * * Description: Owner's mailing address is outside the property's city.`),
    MethodologyVersion: z.string().describe(`
        * * Field Name: MethodologyVersion
        * * Display Name: Methodology Version
        * * SQL Data Type: nvarchar(30)
        * * Description: Which scoring methodology pass produced this row (e.g. "v1-total-sqft-2026"). Exists specifically so a future corrected pass (garage-adjusted comparison) is distinguishable from this one rather than silently overwriting/mixing with it.`),
    GeneratedAt: z.date().describe(`
        * * Field Name: GeneratedAt
        * * Display Name: Generated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When this scoring pass was run.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Number
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxAppealLeadEntityType = z.infer<typeof indianataxAppealLeadSchema>;

/**
 * zod schema definition for the entity Appeal Stage Playbook Notes
 */
export const indianataxAppealStagePlaybookNoteSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    AppealStageID: z.string().describe(`
        * * Field Name: AppealStageID
        * * Display Name: Appeal Stage
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
        * * Description: The indiana_tax.AppealStage row this note belongs to.`),
    NoteKind: z.union([z.literal('DeadlineNuance'), z.literal('LocalPractice'), z.literal('Strategy'), z.literal('Tip'), z.literal('Trap')]).describe(`
        * * Field Name: NoteKind
        * * Display Name: Note Kind
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * DeadlineNuance
    *   * LocalPractice
    *   * Strategy
    *   * Tip
    *   * Trap
        * * Description: Tip (use it to your advantage), Trap (a way to lose or forfeit), DeadlineNuance (a subtlety in when/how a clock runs), Strategy (a lever worth pulling), or LocalPractice (how a specific county actually operates, vs. the statewide rule).`),
    Title: z.string().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(200)
        * * Description: Short headline for the note.`),
    Body: z.string().describe(`
        * * Field Name: Body
        * * Display Name: Body
        * * SQL Data Type: nvarchar(MAX)
        * * Description: The note itself.`),
    CountyNumber: z.number().nullable().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: NULL = statewide note. A county number (49 = Marion) = the note applies only to that county, layered over the statewide stage.`),
    StatuteSectionID: z.string().nullable().describe(`
        * * Field Name: StatuteSectionID
        * * Display Name: Statute Section
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Statute Sections (vwStatuteSections.ID)
        * * Description: Link to the indiana_tax.StatuteSection this note rests on, when one exists in the table.`),
    CitationText: z.string().nullable().describe(`
        * * Field Name: CitationText
        * * Display Name: Citation Text
        * * SQL Data Type: nvarchar(100)
        * * Description: Free-text citation for when there is no StatuteSection row (e.g. "State Form 53958 instructions", "IC 6-1.1-15-1.2(k)").`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: Optional supporting SourceDocument (a form, a memo, a decision).`),
    Confidence: z.union([z.literal('NeedsVerification'), z.literal('Verified')]).describe(`
        * * Field Name: Confidence
        * * Display Name: Confidence
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Verified
    * * Value List Type: List
    * * Possible Values 
    *   * NeedsVerification
    *   * Verified
        * * Description: Verified (grounded in a primary source) or NeedsVerification (an inference from observed data -- e.g. Marion PTABOA cadence read off loaded PTABOAAppeal rows -- not yet checked against a primary source). Per the project data-integrity rule, local-practice notes sourced from data start as NeedsVerification.`),
    SortOrder: z.number().describe(`
        * * Field Name: SortOrder
        * * Display Name: Sort Order
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Display order within a stage.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    AppealStage: z.string().describe(`
        * * Field Name: AppealStage
        * * Display Name: Appeal Stage Name
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxAppealStagePlaybookNoteEntityType = z.infer<typeof indianataxAppealStagePlaybookNoteSchema>;

/**
 * zod schema definition for the entity Appeal Stage Statutes
 */
export const indianataxAppealStageStatuteSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    AppealStageID: z.string().describe(`
        * * Field Name: AppealStageID
        * * Display Name: Appeal Stage
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
        * * Description: The stage this citation governs.`),
    StatuteSectionID: z.string().nullable().describe(`
        * * Field Name: StatuteSectionID
        * * Display Name: Statute Section
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Statute Sections (vwStatuteSections.ID)
        * * Description: The matching StatuteSection row, if the cited section is one we've ingested (Title 6 Articles 1.1/1.5 only).`),
    CitationText: z.string().describe(`
        * * Field Name: CitationText
        * * Display Name: Citation Text
        * * SQL Data Type: nvarchar(100)
        * * Description: The citation exactly as written on the source document, e.g. "IC 6-1.1-15-1.2(d)-(g), (l)".`),
    SubsectionReference: z.string().nullable().describe(`
        * * Field Name: SubsectionReference
        * * Display Name: Subsection Reference
        * * SQL Data Type: nvarchar(50)
        * * Description: The specific subsection(s) cited within the section, e.g. "(d)-(g), (l)" — StatuteSection is section-granular, not subsection-granular, so this carries the finer reference the flowchart actually makes.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    AppealStage: z.string().describe(`
        * * Field Name: AppealStage
        * * Display Name: Appeal Stage Name
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxAppealStageStatuteEntityType = z.infer<typeof indianataxAppealStageStatuteSchema>;

/**
 * zod schema definition for the entity Appeal Stages
 */
export const indianataxAppealStageSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    StageOrder: z.number().describe(`
        * * Field Name: StageOrder
        * * Display Name: Stage Order
        * * SQL Data Type: int
        * * Description: Sequence position in the normal-path appeal lifecycle (1 = first stage). Conditional escalation paths (e.g. skipping ahead if PTABOA misses its hearing deadline) are captured in Notes on the relevant stage, not as separate branching rows.`),
    StageName: z.string().describe(`
        * * Field Name: StageName
        * * Display Name: Stage Name
        * * SQL Data Type: nvarchar(200)
        * * Description: Short name for the stage.`),
    AppealLevel: z.union([z.literal('County-PTABOA'), z.literal('State-IBTR'), z.literal('State-SupremeCourt'), z.literal('State-TaxCourt')]).describe(`
        * * Field Name: AppealLevel
        * * Display Name: Appeal Level
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * County-PTABOA
    *   * State-IBTR
    *   * State-SupremeCourt
    *   * State-TaxCourt
        * * Description: Where in the appeal hierarchy this stage sits: County-PTABOA (the initial, county-level appeal), State-IBTR (state board, afforded deference to its factual determinations), State-TaxCourt (reviews IBTR determinations), or State-SupremeCourt (discretionary review of Tax Court determinations).`),
    ResponsibleParty: z.string().nullable().describe(`
        * * Field Name: ResponsibleParty
        * * Display Name: Responsible Party
        * * SQL Data Type: nvarchar(50)
        * * Description: Who acts at this stage (e.g. Taxpayer, Assessing Official, PTABOA, IBTR, Tax Court, Supreme Court).`),
    Description: z.string().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What happens at this stage.`),
    FormRequired: z.string().nullable().describe(`
        * * Field Name: FormRequired
        * * Display Name: Form Required
        * * SQL Data Type: nvarchar(50)
        * * Description: The DLGF form required to act at this stage, if any (e.g. Form 130, Form 134, Form 131).`),
    DeadlineDescription: z.string().nullable().describe(`
        * * Field Name: DeadlineDescription
        * * Display Name: Deadline Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Full deadline rule in prose — often conditional (varies by mailing date, property type, etc.), which is why this is text rather than only a day count.`),
    DeadlineDays: z.number().nullable().describe(`
        * * Field Name: DeadlineDays
        * * Display Name: Deadline Days
        * * SQL Data Type: int
        * * Description: A single day-count figure when the deadline reduces to one cleanly (e.g. 45, 180, 90) — NULL when the real rule is conditional and a single number would be misleading; see DeadlineDescription for the full rule either way.`),
    CountyNumber: z.number().nullable().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: NULL = statewide standard procedure (every row populated so far). Reserved for a future county-specific variant of this stage, since local practice can differ by county — a county override would be its own row with this set, not an edit to the statewide row.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The document this stage was extracted from (e.g. Form 130's instructions).`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text notes — standard of review, burden of proof, escalation conditions, or other context that doesn't fit a structured column.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    DeadlineAnchorEvent: z.union([z.literal('AppealFilingDate'), z.literal('Form11MailDate'), z.literal('IBTRFinalDeterminationDate'), z.literal('PTABOAOrderDate'), z.literal('PersonalPropertyNoticeDate'), z.literal('TaxCourtDeterminationDate')]).nullable().describe(`
        * * Field Name: DeadlineAnchorEvent
        * * Display Name: Deadline Anchor Event
        * * SQL Data Type: nvarchar(40)
    * * Value List Type: List
    * * Possible Values 
    *   * AppealFilingDate
    *   * Form11MailDate
    *   * IBTRFinalDeterminationDate
    *   * PTABOAOrderDate
    *   * PersonalPropertyNoticeDate
    *   * TaxCourtDeterminationDate
        * * Description: The real-world date that starts this stage's clock: Form11MailDate, PersonalPropertyNoticeDate, AppealFilingDate (Form 130 filed), PTABOAOrderDate (PTABOA order given to the parties), IBTRFinalDeterminationDate, or TaxCourtDeterminationDate. NULL = no fixed statutory deadline runs to the taxpayer at this stage (the assessing official's / IBTR's own timeline governs).`),
    DeadlineBasis: z.union([z.literal('CalendarRule'), z.literal('Discretionary'), z.literal('RelativeDays')]).nullable().describe(`
        * * Field Name: DeadlineBasis
        * * Display Name: Deadline Basis
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * CalendarRule
    *   * Discretionary
    *   * RelativeDays
        * * Description: How the deadline derives from DeadlineAnchorEvent: RelativeDays = anchor + DeadlineDays (45 / 90 / 180 ...); CalendarRule = the named rule in DeadlineCalendarRule; Discretionary = no hard deadline (e.g. Supreme Court review).`),
    DeadlineCalendarRule: z.string().nullable().describe(`
        * * Field Name: DeadlineCalendarRule
        * * Display Name: Deadline Calendar Rule
        * * SQL Data Type: nvarchar(60)
        * * Description: Stable token a rule engine switches on when DeadlineBasis = 'CalendarRule'. Stage 1 = 'IN-Form130-June15-split-May1': if Form11MailDate < May 1 of the assessment year the Form 130 is due June 15 of that year, else June 15 of the year tax statements are mailed (the pay year). One rule per token; the token is documented, the logic lives in code.`),
    DeadlineHasAgencyLapseAlt: z.boolean().describe(`
        * * Field Name: DeadlineHasAgencyLapseAlt
        * * Display Name: Has Agency Lapse Alternative
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: TRUE where, in addition to the primary deadline, the statute lets the taxpayer act "any time after the agency's own deadline lapses": Stage 3 (PTABOA misses its 180-day hearing window -> straight to IBTR) and Stage 6 (Tax Court petition may be filed once IBTR's own decision deadline passes).`),
    InformalMeetingRequirement: z.union([z.literal('NotOffered'), z.literal('Optional'), z.literal('Recommended'), z.literal('Required')]).nullable().describe(`
        * * Field Name: InformalMeetingRequirement
        * * Display Name: Informal Meeting Requirement
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * NotOffered
    *   * Optional
    *   * Recommended
    *   * Required
        * * Description: Whether this stage's informal step is mandatory: Required / Optional / Recommended / NotOffered. Indiana Stage 2 (Preliminary Informal Meeting) = Required -- filing Form 130 obligates the assessing official to hold it. Other jurisdictions vary (the Faegre Appeal Deadline Tracking workbook tracks this per state).`),
    EvidenceRequiredAtFiling: z.boolean().nullable().describe(`
        * * Field Name: EvidenceRequiredAtFiling
        * * Display Name: Evidence Required at Filing
        * * SQL Data Type: bit
        * * Description: TRUE only where the taxpayer must attach/submit substantive evidence AT filing to avoid rejection (e.g. AZ). Indiana Stage 1 = FALSE -- no evidence required at filing, but the exchange of available information IS required at the preliminary informal meeting (see the corresponding playbook note).`),
    InformalDeadlineDescription: z.string().nullable().describe(`
        * * Field Name: InformalDeadlineDescription
        * * Display Name: Informal Deadline Description
        * * SQL Data Type: nvarchar(300)
        * * Description: Free text for the informal step's own deadline where one exists separately from DeadlineDays / DeadlineCalendarRule (MO, CO). Indiana = NULL: the preliminary informal meeting is auto-triggered by the Form 130 filing with no separate taxpayer date to hit.`),
});

export type indianataxAppealStageEntityType = z.infer<typeof indianataxAppealStageSchema>;

/**
 * zod schema definition for the entity Assessments
 */
export const indianataxAssessmentSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this assessment belongs to.`),
    AssessmentYear: z.number().describe(`
        * * Field Name: AssessmentYear
        * * Display Name: Assessment Year
        * * SQL Data Type: smallint
        * * Description: The assessment/payable year this row represents (Indiana assessments are dated January 1 of the assessment year).`),
    Source: z.string().describe(`
        * * Field Name: Source
        * * Display Name: Source
        * * SQL Data Type: nvarchar(50)
        * * Description: Where this assessment row came from, e.g. dlgf_gdb_2025, marion_foia_2026. Identifies the data pull/vintage.`),
    PropertyClassCode: z.string().nullable().describe(`
        * * Field Name: PropertyClassCode
        * * Display Name: Property Class Code
        * * SQL Data Type: nvarchar(10)
        * * Description: DLGF property class code as recorded for this specific assessment year (may differ from the parcel's current PropertyClassCode).`),
    OriginalLandAV: z.number().nullable().describe(`
        * * Field Name: OriginalLandAV
        * * Display Name: Original Land Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Originally assessed land value for the year, before any appeal.`),
    OriginalImprovementAV: z.number().nullable().describe(`
        * * Field Name: OriginalImprovementAV
        * * Display Name: Original Improvement Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Originally assessed improvement value for the year, before any appeal.`),
    OriginalTotalAV: z.number().nullable().describe(`
        * * Field Name: OriginalTotalAV
        * * Display Name: Original Total Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Originally assessed total value for the year (land + improvement), before any appeal.`),
    PTABOALandAV: z.number().nullable().describe(`
        * * Field Name: PTABOALandAV
        * * Display Name: PTABOA Land Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Land value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`),
    PTABOAImprovementAV: z.number().nullable().describe(`
        * * Field Name: PTABOAImprovementAV
        * * Display Name: PTABOA Improvement Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Improvement value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`),
    PTABOATotalAV: z.number().nullable().describe(`
        * * Field Name: PTABOATotalAV
        * * Display Name: PTABOA Total Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The specific SourceDocument this assessment row was extracted from (the DLGF geodatabase pull, the Marion FOIA parcel-list CSV, or the parcel's Property Record Card). The free-text \`Source\` column is the short provenance label; this is the traceable document.`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Reference
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxAssessmentEntityType = z.infer<typeof indianataxAssessmentSchema>;

/**
 * zod schema definition for the entity Board Decisions
 */
export const indianataxBoardDecisionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CaseNumber: z.string().describe(`
        * * Field Name: CaseNumber
        * * Display Name: Case Number
        * * SQL Data Type: nvarchar(50)
        * * Description: IBTR case number.`),
    PetitionerName: z.string().nullable().describe(`
        * * Field Name: PetitionerName
        * * Display Name: Petitioner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: Name of the petitioner (property owner who brought the appeal).`),
    CountyNumber: z.number().nullable().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: County the case originated in.`),
    ParcelID: z.string().nullable().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this decision concerns, once matched. NULL until the case is reconciled to a known parcel.`),
    DecisionDate: z.date().nullable().describe(`
        * * Field Name: DecisionDate
        * * Display Name: Decision Date
        * * SQL Data Type: date
        * * Description: Date the IBTR issued its final determination.`),
    Summary: z.string().nullable().describe(`
        * * Field Name: Summary
        * * Display Name: Summary
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Short summary of the case and outcome, for quick scanning without opening the full decision text.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The decision PDF this row was extracted from.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    AssessmentYearsInvolved: z.string().nullable().describe(`
        * * Field Name: AssessmentYearsInvolved
        * * Display Name: Assessment Years
        * * SQL Data Type: nvarchar(200)
        * * Description: Free-text assessment year(s) this decision concerns, e.g. "2019, 2020, 2021" — a single IBTR case can span multiple years and even multiple parcels, so this isn't normalized to a single year column.`),
    Parcel: z.string().nullable().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Reference
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxBoardDecisionEntityType = z.infer<typeof indianataxBoardDecisionSchema>;

/**
 * zod schema definition for the entity Co Star Income Inputs
 */
export const indianataxCoStarIncomeInputSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CoStarPropertyID: z.number().describe(`
        * * Field Name: CoStarPropertyID
        * * Display Name: CoStar Property ID
        * * SQL Data Type: bigint
        * * Description: CoStar's PropertyID for the record.`),
    ParcelID: z.string().nullable().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: Resolved Parcel (matched on Parcel Number 1(Min)); NULL when off-book.`),
    ParcelNumberMin: z.string().nullable().describe(`
        * * Field Name: ParcelNumberMin
        * * Display Name: Parcel Number Min
        * * SQL Data Type: nvarchar(30)`),
    ParcelNumberMax: z.string().nullable().describe(`
        * * Field Name: ParcelNumberMax
        * * Display Name: Parcel Number Max
        * * SQL Data Type: nvarchar(30)`),
    MultiParcel: z.boolean().describe(`
        * * Field Name: MultiParcel
        * * Display Name: Multi-Parcel
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Property spans more than one parcel (Min <> Max).`),
    PropertyTypeGroup: z.string().nullable().describe(`
        * * Field Name: PropertyTypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(20)`),
    CoStarPropertyType: z.string().nullable().describe(`
        * * Field Name: CoStarPropertyType
        * * Display Name: CoStar Property Type
        * * SQL Data Type: nvarchar(60)`),
    SecondaryType: z.string().nullable().describe(`
        * * Field Name: SecondaryType
        * * Display Name: Secondary Type
        * * SQL Data Type: nvarchar(80)`),
    Submarket: z.string().nullable().describe(`
        * * Field Name: Submarket
        * * Display Name: Submarket
        * * SQL Data Type: nvarchar(80)`),
    City: z.string().nullable().describe(`
        * * Field Name: City
        * * Display Name: City
        * * SQL Data Type: nvarchar(80)`),
    PropertyName: z.string().nullable().describe(`
        * * Field Name: PropertyName
        * * Display Name: Property Name
        * * SQL Data Type: nvarchar(200)`),
    PropertyAddress: z.string().nullable().describe(`
        * * Field Name: PropertyAddress
        * * Display Name: Property Address
        * * SQL Data Type: nvarchar(200)`),
    StarRating: z.number().nullable().describe(`
        * * Field Name: StarRating
        * * Display Name: Star Rating
        * * SQL Data Type: decimal(2, 1)`),
    YearBuilt: z.number().nullable().describe(`
        * * Field Name: YearBuilt
        * * Display Name: Year Built
        * * SQL Data Type: smallint`),
    YearRenovated: z.number().nullable().describe(`
        * * Field Name: YearRenovated
        * * Display Name: Year Renovated
        * * SQL Data Type: smallint`),
    Units: z.number().nullable().describe(`
        * * Field Name: Units
        * * Display Name: Units
        * * SQL Data Type: int`),
    RBA: z.number().nullable().describe(`
        * * Field Name: RBA
        * * Display Name: RBA
        * * SQL Data Type: int`),
    Rooms: z.number().nullable().describe(`
        * * Field Name: Rooms
        * * Display Name: Rooms
        * * SQL Data Type: int`),
    Beds: z.number().nullable().describe(`
        * * Field Name: Beds
        * * Display Name: Beds
        * * SQL Data Type: int`),
    AvgEffectiveRentPerUnit: z.number().nullable().describe(`
        * * Field Name: AvgEffectiveRentPerUnit
        * * Display Name: Avg Effective Rent Per Unit
        * * SQL Data Type: decimal(10, 2)
        * * Description: Average EFFECTIVE rent per unit, MONTHLY (net of concessions), as CoStar reports it. Annualise x 12 for the pro forma.`),
    AvgAskingRentPerUnit: z.number().nullable().describe(`
        * * Field Name: AvgAskingRentPerUnit
        * * Display Name: Avg Asking Rent Per Unit
        * * SQL Data Type: decimal(10, 2)`),
    AvgEffectiveRentPerSF: z.number().nullable().describe(`
        * * Field Name: AvgEffectiveRentPerSF
        * * Display Name: Avg Effective Rent Per SF
        * * SQL Data Type: decimal(8, 2)`),
    AvgAskingRentPerSF: z.number().nullable().describe(`
        * * Field Name: AvgAskingRentPerSF
        * * Display Name: Avg Asking Rent Per SF
        * * SQL Data Type: decimal(8, 2)`),
    ConcessionsPct: z.number().nullable().describe(`
        * * Field Name: ConcessionsPct
        * * Display Name: Concessions %
        * * SQL Data Type: decimal(6, 3)`),
    VacancyPct: z.number().nullable().describe(`
        * * Field Name: VacancyPct
        * * Display Name: Vacancy %
        * * SQL Data Type: decimal(6, 3)
        * * Description: Vacancy percent (0-100) as reported by CoStar.`),
    PercentLeased: z.number().nullable().describe(`
        * * Field Name: PercentLeased
        * * Display Name: Percent Leased
        * * SQL Data Type: decimal(6, 3)
        * * Description: Percent leased (0-100); office/retail/industrial where vacancy is not reported.`),
    RentPerSFYrLow: z.number().nullable().describe(`
        * * Field Name: RentPerSFYrLow
        * * Display Name: Rent Per SF Year Low
        * * SQL Data Type: decimal(8, 2)`),
    RentPerSFYrHigh: z.number().nullable().describe(`
        * * Field Name: RentPerSFYrHigh
        * * Display Name: Rent Per SF Year High
        * * SQL Data Type: decimal(8, 2)`),
    AverageWeightedRent: z.number().nullable().describe(`
        * * Field Name: AverageWeightedRent
        * * Display Name: Average Weighted Rent
        * * SQL Data Type: decimal(8, 2)`),
    CapRate: z.number().nullable().describe(`
        * * Field Name: CapRate
        * * Display Name: Cap Rate
        * * SQL Data Type: decimal(6, 4)
        * * Description: CoStar cap rate where disclosed on the inventory record (rare -- usually NULL).`),
    TaxesTotal: z.number().nullable().describe(`
        * * Field Name: TaxesTotal
        * * Display Name: Taxes Total
        * * SQL Data Type: decimal(14, 2)`),
    LastSalePrice: z.number().nullable().describe(`
        * * Field Name: LastSalePrice
        * * Display Name: Last Sale Price
        * * SQL Data Type: decimal(14, 2)`),
    LastSaleDate: z.date().nullable().describe(`
        * * Field Name: LastSaleDate
        * * Display Name: Last Sale Date
        * * SQL Data Type: date`),
    SourceFile: z.string().nullable().describe(`
        * * Field Name: SourceFile
        * * Display Name: Source File
        * * SQL Data Type: nvarchar(120)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The CoStar export .xlsx this row was parsed from (SourceFile is the filename text). CoStar data is a labeled cross-check, not authority.`),
    Parcel: z.string().nullable().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxCoStarIncomeInputEntityType = z.infer<typeof indianataxCoStarIncomeInputSchema>;

/**
 * zod schema definition for the entity Co Star Properties
 */
export const indianataxCoStarPropertySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CoStarPropertyID: z.number().describe(`
        * * Field Name: CoStarPropertyID
        * * Display Name: CoStar Property ID
        * * SQL Data Type: int
        * * Description: CoStar's own stable property identifier (their own "PropertyID" field) -- the natural key for this table, unique across all 8 imported export files.`),
    SourceExportFile: z.string().describe(`
        * * Field Name: SourceExportFile
        * * Display Name: Source Export File
        * * SQL Data Type: nvarchar(100)
        * * Description: Which of the 8 CoStar export files/size bands this property came from (e.g. "Multi-Family (100+ Units)") -- CoStar splits exports at 500 rows, so this is provenance, not a property-type classification (see CoStarPropertyType/CoStarSecondaryType for that).`),
    ParcelID: z.string().nullable().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The Marion County Parcel matched from CoStar's "Parcel Number 1(Min)" (or, failing that, address). NULL means no match was found -- the row is still kept, not dropped. For a multi-parcel property (see CoStarIsMultiParcel) this is only ONE of the constituent parcels -- do not treat its AV as representing the whole property.`),
    CoStarSecondaryParcelID: z.string().nullable().describe(`
        * * Field Name: CoStarSecondaryParcelID
        * * Display Name: CoStar Secondary Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The Marion County Parcel matched from CoStar's "Parcel Number 2(Max)", when it differs from ParcelID and itself resolves to a real parcel. NULL does not mean no second parcel exists -- CoStar's Min/Max is an outer bound, not a full membership list (see this migration's header comment); it means we could not resolve the Max end specifically.`),
    CoStarIsMultiParcel: z.boolean().describe(`
        * * Field Name: CoStarIsMultiParcel
        * * Display Name: Is Multi-Parcel
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: True when CoStar's own "Parcel Number 1(Min)" and "Parcel Number 2(Max)" differ -- CoStar's signal that this property spans more than one parcel. Any per-unit/per-key/per-SF assessed-value figure derived from this row should be flagged as partial/incomplete when this is true, since we generally cannot enumerate every constituent parcel (see this migration's header comment) and CoStarNumberOfUnits/CoStarRBA/CoStarRooms are whole-property aggregates that a single matched parcel's AV does not fully cover.`),
    MatchMethod: z.union([z.literal('Address'), z.literal('ParcelNumberMax'), z.literal('ParcelNumberMin')]).nullable().describe(`
        * * Field Name: MatchMethod
        * * Display Name: Match Method
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Address
    *   * ParcelNumberMax
    *   * ParcelNumberMin
        * * Description: How ParcelID was resolved: ParcelNumberMin (exact match on the stripped "Parcel Number 1(Min)"), ParcelNumberMax (Min failed, Max matched), Address (both parcel-number attempts failed, a normalized-address match succeeded), or NULL (nothing matched).`),
    CoStarAddress: z.string().nullable().describe(`
        * * Field Name: CoStarAddress
        * * Display Name: Address
        * * SQL Data Type: nvarchar(200)
        * * Description: CoStar "Property Address".`),
    CoStarPropertyName: z.string().nullable().describe(`
        * * Field Name: CoStarPropertyName
        * * Display Name: Property Name
        * * SQL Data Type: nvarchar(200)
        * * Description: CoStar "Property Name".`),
    CoStarPropertyType: z.string().nullable().describe(`
        * * Field Name: CoStarPropertyType
        * * Display Name: Property Type
        * * SQL Data Type: nvarchar(50)
        * * Description: CoStar "Property Type" (e.g. Multifamily, Office, Retail, Industrial, Hospitality).`),
    CoStarSecondaryType: z.string().nullable().describe(`
        * * Field Name: CoStarSecondaryType
        * * Display Name: Secondary Type
        * * SQL Data Type: nvarchar(50)
        * * Description: CoStar "Secondary Type" -- a finer-grained classification than CoStarPropertyType.`),
    CoStarCity: z.string().nullable().describe(`
        * * Field Name: CoStarCity
        * * Display Name: City
        * * SQL Data Type: nvarchar(100)
        * * Description: CoStar "City".`),
    CoStarState: z.string().nullable().describe(`
        * * Field Name: CoStarState
        * * Display Name: State
        * * SQL Data Type: nvarchar(10)
        * * Description: CoStar "State".`),
    CoStarZip: z.string().nullable().describe(`
        * * Field Name: CoStarZip
        * * Display Name: Zip Code
        * * SQL Data Type: nvarchar(20)
        * * Description: CoStar "Zip".`),
    CoStarCountyName: z.string().nullable().describe(`
        * * Field Name: CoStarCountyName
        * * Display Name: County Name
        * * SQL Data Type: nvarchar(50)
        * * Description: CoStar "County Name".`),
    CoStarLatitude: z.number().nullable().describe(`
        * * Field Name: CoStarLatitude
        * * Display Name: Latitude
        * * SQL Data Type: decimal(10, 6)
        * * Description: CoStar "Latitude".`),
    CoStarLongitude: z.number().nullable().describe(`
        * * Field Name: CoStarLongitude
        * * Display Name: Longitude
        * * SQL Data Type: decimal(10, 6)
        * * Description: CoStar "Longitude".`),
    CoStarParcelNumberMin: z.string().nullable().describe(`
        * * Field Name: CoStarParcelNumberMin
        * * Display Name: Parcel Number Min
        * * SQL Data Type: nvarchar(40)
        * * Description: CoStar "Parcel Number 1(Min)", raw as exported (with punctuation, e.g. "49-11-01-240-261.002-101") -- kept for audit; ParcelID is the resolved match after stripping punctuation.`),
    CoStarParcelNumberMax: z.string().nullable().describe(`
        * * Field Name: CoStarParcelNumberMax
        * * Display Name: Parcel Number Max
        * * SQL Data Type: nvarchar(40)
        * * Description: CoStar "Parcel Number 2(Max)", raw as exported. Equal to CoStarParcelNumberMin for a single-parcel property; different for a multi-parcel one (see CoStarIsMultiParcel).`),
    CoStarOwnerName: z.string().nullable().describe(`
        * * Field Name: CoStarOwnerName
        * * Display Name: Owner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: CoStar "Owner Name" -- CoStar carries three distinct owner fields (this one, RecordedOwnerName, TrueOwnerName) that routinely disagree (e.g. a management company name here vs. the actual holding LLC in RecordedOwnerName) -- do not assume they match each other or indiana_tax.CountyAssessorRecord.OwnerName.`),
    CoStarRecordedOwnerName: z.string().nullable().describe(`
        * * Field Name: CoStarRecordedOwnerName
        * * Display Name: Recorded Owner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: CoStar "Recorded Owner Name" -- see CoStarOwnerName's comment on why this often differs from it.`),
    CoStarTrueOwnerName: z.string().nullable().describe(`
        * * Field Name: CoStarTrueOwnerName
        * * Display Name: True Owner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: CoStar "True Owner Name" -- see CoStarOwnerName's comment.`),
    CoStarNumberOfUnits: z.number().nullable().describe(`
        * * Field Name: CoStarNumberOfUnits
        * * Display Name: Number of Units
        * * SQL Data Type: int
        * * Description: CoStar "Number of Units" -- whole-property unit count for multifamily/student housing, the correct denominator for a per-unit comparison (see CoStarIsMultiParcel for why the AV numerator may only be partial).`),
    CoStarRooms: z.number().nullable().describe(`
        * * Field Name: CoStarRooms
        * * Display Name: Rooms
        * * SQL Data Type: int
        * * Description: CoStar "Rooms" -- whole-property room/key count for hospitality properties.`),
    CoStarRBA: z.number().nullable().describe(`
        * * Field Name: CoStarRBA
        * * Display Name: RBA (Square Feet)
        * * SQL Data Type: int
        * * Description: CoStar "RBA" (Rentable Building Area, SF) -- whole-property building square footage for office/industrial/retail.`),
    CoStarTotalBuildings: z.number().nullable().describe(`
        * * Field Name: CoStarTotalBuildings
        * * Display Name: Total Buildings
        * * SQL Data Type: int
        * * Description: CoStar "Total Buildings" -- number of distinct buildings on the property (independent of parcel count).`),
    CoStarLandAreaAcres: z.number().nullable().describe(`
        * * Field Name: CoStarLandAreaAcres
        * * Display Name: Land Area (Acres)
        * * SQL Data Type: decimal(10, 4)
        * * Description: CoStar "Land Area (AC)".`),
    CoStarLandAreaSF: z.number().nullable().describe(`
        * * Field Name: CoStarLandAreaSF
        * * Display Name: Land Area (Square Feet)
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "Land Area (SF)".`),
    CoStarNumberOfStories: z.number().nullable().describe(`
        * * Field Name: CoStarNumberOfStories
        * * Display Name: Number of Stories
        * * SQL Data Type: int
        * * Description: CoStar "Number of Stories".`),
    CoStarYearBuilt: z.number().nullable().describe(`
        * * Field Name: CoStarYearBuilt
        * * Display Name: Year Built
        * * SQL Data Type: smallint
        * * Description: CoStar "Year Built".`),
    CoStarYearRenovated: z.number().nullable().describe(`
        * * Field Name: CoStarYearRenovated
        * * Display Name: Year Renovated
        * * SQL Data Type: smallint
        * * Description: CoStar "Year Renovated".`),
    CoStarBuildingClass: z.string().nullable().describe(`
        * * Field Name: CoStarBuildingClass
        * * Display Name: Building Class
        * * SQL Data Type: nvarchar(10)
        * * Description: CoStar "Building Class" (A/B/C).`),
    CoStarStarRating: z.number().nullable().describe(`
        * * Field Name: CoStarStarRating
        * * Display Name: Star Rating
        * * SQL Data Type: tinyint
        * * Description: CoStar "Star Rating" (1-5).`),
    CoStarLastSalePrice: z.number().nullable().describe(`
        * * Field Name: CoStarLastSalePrice
        * * Display Name: Last Sale Price
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "Last Sale Price".`),
    CoStarLastSaleDate: z.date().nullable().describe(`
        * * Field Name: CoStarLastSaleDate
        * * Display Name: Last Sale Date
        * * SQL Data Type: date
        * * Description: CoStar "Last Sale Date".`),
    CoStarForSalePrice: z.number().nullable().describe(`
        * * Field Name: CoStarForSalePrice
        * * Display Name: For Sale Price
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "For Sale Price" -- current asking price, if actively listed (see CoStarForSaleStatus).`),
    CoStarForSalePricePerUnit: z.number().nullable().describe(`
        * * Field Name: CoStarForSalePricePerUnit
        * * Display Name: For Sale Price Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "For Sale Price Per Unit".`),
    CoStarForSalePricePerSF: z.number().nullable().describe(`
        * * Field Name: CoStarForSalePricePerSF
        * * Display Name: For Sale Price Per SF
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "For Sale Price Per SF".`),
    CoStarForSalePricePerRoom: z.number().nullable().describe(`
        * * Field Name: CoStarForSalePricePerRoom
        * * Display Name: For Sale Price Per Room
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "For Sale Price Per Room" -- hospitality only.`),
    CoStarForSaleStatus: z.string().nullable().describe(`
        * * Field Name: CoStarForSaleStatus
        * * Display Name: For Sale Status
        * * SQL Data Type: nvarchar(10)
        * * Description: CoStar "For Sale Status".`),
    CoStarCapRate: z.number().nullable().describe(`
        * * Field Name: CoStarCapRate
        * * Display Name: Cap Rate (%)
        * * SQL Data Type: decimal(9, 4)
        * * Description: CoStar "Cap Rate", already a plain decimal percentage (e.g. 6.12 means 6.12%), not a 0-1 fraction.`),
    CoStarTaxesTotal: z.number().nullable().describe(`
        * * Field Name: CoStarTaxesTotal
        * * Display Name: Total Taxes
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "Taxes Total" -- CoStar's own figure for this property's total tax bill, useful as an independent cross-check against indiana_tax.TaxHistoryYear/CountyAssessorRecord.NetAnnualTax for the matched parcel(s).`),
    CoStarTaxesPerSF: z.number().nullable().describe(`
        * * Field Name: CoStarTaxesPerSF
        * * Display Name: Taxes Per SF
        * * SQL Data Type: decimal(9, 4)
        * * Description: CoStar "Taxes Per SF".`),
    CoStarTaxYear: z.number().nullable().describe(`
        * * Field Name: CoStarTaxYear
        * * Display Name: Tax Year
        * * SQL Data Type: smallint
        * * Description: CoStar "Tax Year" -- the year CoStarTaxesTotal/CoStarTaxesPerSF apply to; compare against indiana_tax.Assessment.AssessmentYear before treating the two sources as describing the same year.`),
    CoStarAvgAskingPerSF: z.number().nullable().describe(`
        * * Field Name: CoStarAvgAskingPerSF
        * * Display Name: Avg Asking Per SF
        * * SQL Data Type: decimal(9, 4)
        * * Description: CoStar "Avg Asking/SF".`),
    CoStarAvgAskingPerUnit: z.number().nullable().describe(`
        * * Field Name: CoStarAvgAskingPerUnit
        * * Display Name: Avg Asking Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "Avg Asking/Unit".`),
    CoStarAvgEffectivePerSF: z.number().nullable().describe(`
        * * Field Name: CoStarAvgEffectivePerSF
        * * Display Name: Avg Effective Per SF
        * * SQL Data Type: decimal(9, 4)
        * * Description: CoStar "Avg Effective/SF".`),
    CoStarAvgEffectivePerUnit: z.number().nullable().describe(`
        * * Field Name: CoStarAvgEffectivePerUnit
        * * Display Name: Avg Effective Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: CoStar "Avg Effective/Unit".`),
    CoStarPercentLeased: z.number().nullable().describe(`
        * * Field Name: CoStarPercentLeased
        * * Display Name: Percent Leased (%)
        * * SQL Data Type: decimal(6, 3)
        * * Description: CoStar "Percent Leased", already a plain decimal percentage.`),
    CoStarVacancyPct: z.number().nullable().describe(`
        * * Field Name: CoStarVacancyPct
        * * Display Name: Vacancy Rate (%)
        * * SQL Data Type: decimal(6, 3)
        * * Description: CoStar "Vacancy %", already a plain decimal percentage.`),
    CoStarDaysOnMarket: z.number().nullable().describe(`
        * * Field Name: CoStarDaysOnMarket
        * * Display Name: Days On Market
        * * SQL Data Type: int
        * * Description: CoStar "Days On Market".`),
    CoStarSubmarketName: z.string().nullable().describe(`
        * * Field Name: CoStarSubmarketName
        * * Display Name: Submarket Name
        * * SQL Data Type: nvarchar(100)
        * * Description: CoStar "Submarket Name".`),
    CoStarMarketName: z.string().nullable().describe(`
        * * Field Name: CoStarMarketName
        * * Display Name: Market Name
        * * SQL Data Type: nvarchar(100)
        * * Description: CoStar "Market Name".`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The CoStar export .xlsx this row was parsed from (SourceExportFile is the short label). CoStar data is a labeled cross-check, not authority.`),
    Parcel: z.string().nullable().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Display
        * * SQL Data Type: nvarchar(30)`),
    CoStarSecondaryParcel: z.string().nullable().describe(`
        * * Field Name: CoStarSecondaryParcel
        * * Display Name: Secondary Parcel Display
        * * SQL Data Type: nvarchar(30)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: System Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: System Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxCoStarPropertyEntityType = z.infer<typeof indianataxCoStarPropertySchema>;

/**
 * zod schema definition for the entity Comparable Assessment Members
 */
export const indianataxComparableAssessmentMemberSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ComparableAssessmentSetID: z.string().describe(`
        * * Field Name: ComparableAssessmentSetID
        * * Display Name: Assessment Set
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Comparable Assessment Sets (vwComparableAssessmentSets.ID)
        * * Description: The set this comp belongs to.`),
    ComparableParcelID: z.string().describe(`
        * * Field Name: ComparableParcelID
        * * Display Name: Comparable Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The comparable parcel.`),
    GeographyBucket: z.union([z.literal('County'), z.literal('Neighborhood')]).describe(`
        * * Field Name: GeographyBucket
        * * Display Name: Geography Bucket
        * * SQL Data Type: nvarchar(14)
    * * Value List Type: List
    * * Possible Values 
    *   * County
    *   * Neighborhood
        * * Description: Which list this comp came from: Neighborhood (same code, ungated) or County (county-wide, strict physical gate).`),
    SimilarityScore: z.number().nullable().describe(`
        * * Field Name: SimilarityScore
        * * Display Name: Similarity Score
        * * SQL Data Type: decimal(9, 4)
        * * Description: Weighted physical-similarity distance (lower = more similar).`),
    SizeLnRatio: z.number().nullable().describe(`
        * * Field Name: SizeLnRatio
        * * Display Name: Size Ln Ratio
        * * SQL Data Type: decimal(9, 4)
        * * Description: abs(ln(subject building SF / comp building SF)) -- the size-match component, exposed for review.`),
    EffectiveYearDelta: z.number().nullable().describe(`
        * * Field Name: EffectiveYearDelta
        * * Display Name: Effective Year Delta
        * * SQL Data Type: smallint
        * * Description: abs(subject effective year - comp effective year).`),
    GradeDelta: z.number().nullable().describe(`
        * * Field Name: GradeDelta
        * * Display Name: Grade Delta
        * * SQL Data Type: decimal(5, 2)
        * * Description: abs difference of the mapped grade ordinal (C=3, C+=3.33, B=4, ...).`),
    ClassMatchLevel: z.union([z.literal('3-digit'), z.literal('exact'), z.literal('group-only')]).nullable().describe(`
        * * Field Name: ClassMatchLevel
        * * Display Name: Class Match Level
        * * SQL Data Type: nvarchar(12)
    * * Value List Type: List
    * * Possible Values 
    *   * 3-digit
    *   * exact
    *   * group-only
        * * Description: How closely the state class codes match: exact (5-digit), 3-digit, or group-only.`),
    SimilarityBreakdown: z.string().nullable().describe(`
        * * Field Name: SimilarityBreakdown
        * * Display Name: Similarity Breakdown
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON: the full weighted-component breakdown behind SimilarityScore.`),
    IsSelected: z.boolean().describe(`
        * * Field Name: IsSelected
        * * Display Name: Selected
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Analyst's choice: is this comp included in the headline mean/median? Builder seeds this (Neighborhood + gated County members start selected).`),
    SortOrder: z.number().nullable().describe(`
        * * Field Name: SortOrder
        * * Display Name: Sort Order
        * * SQL Data Type: int
        * * Description: Display order within the bucket (1 = most similar).`),
    AnalystNote: z.string().nullable().describe(`
        * * Field Name: AnalystNote
        * * Display Name: Analyst Note
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text note on this comp (why kept / dropped).`),
    ComparableBuildingSqFt: z.number().nullable().describe(`
        * * Field Name: ComparableBuildingSqFt
        * * Display Name: Building Square Feet
        * * SQL Data Type: int
        * * Description: Snapshot: comp building SF at generation time.`),
    ComparableUnitCount: z.number().nullable().describe(`
        * * Field Name: ComparableUnitCount
        * * Display Name: Unit Count
        * * SQL Data Type: decimal(12, 2)
        * * Description: Snapshot: comp unit count (trustworthy-filtered) at generation time.`),
    ComparableEffectiveYear: z.number().nullable().describe(`
        * * Field Name: ComparableEffectiveYear
        * * Display Name: Effective Year
        * * SQL Data Type: smallint
        * * Description: Snapshot: comp effective year.`),
    ComparableGradeCode: z.string().nullable().describe(`
        * * Field Name: ComparableGradeCode
        * * Display Name: Grade Code
        * * SQL Data Type: nvarchar(8)
        * * Description: Snapshot: comp grade code.`),
    DenomValue: z.number().nullable().describe(`
        * * Field Name: DenomValue
        * * Display Name: Denominator Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The comp's own denominator for the set's unit of comparison.`),
    OriginalAV: z.number().nullable().describe(`
        * * Field Name: OriginalAV
        * * Display Name: Original Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Comp as-noticed Original total AV for the focus year.`),
    AppealedAV: z.number().nullable().describe(`
        * * Field Name: AppealedAV
        * * Display Name: Appealed Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Comp appealed total AV for the focus year (PTABOA After or IBTR/Final determination), NULL if the comp did not appeal that year.`),
    AppealLevel: z.string().nullable().describe(`
        * * Field Name: AppealLevel
        * * Display Name: Appeal Level
        * * SQL Data Type: nvarchar(16)
        * * Description: Level the appealed value came from: PTABOA or IBTR/Final.`),
    AppealPctChange: z.number().nullable().describe(`
        * * Field Name: AppealPctChange
        * * Display Name: Appeal Percent Change
        * * SQL Data Type: decimal(7, 2)
        * * Description: Percent change of the appealed value vs the pre-appeal base (negative = reduction).`),
    AppealRepresentative: z.string().nullable().describe(`
        * * Field Name: AppealRepresentative
        * * Display Name: Appeal Representative
        * * SQL Data Type: nvarchar(200)
        * * Description: Tax representative of record on the comp's appeal, if any.`),
    EffectiveAV: z.number().nullable().describe(`
        * * Field Name: EffectiveAV
        * * Display Name: Effective Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Comp Effective total AV for the focus year (Appealed if present else Original).`),
    OriginalPerUnit: z.number().nullable().describe(`
        * * Field Name: OriginalPerUnit
        * * Display Name: Original Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: OriginalAV / DenomValue.`),
    EffectivePerUnit: z.number().nullable().describe(`
        * * Field Name: EffectivePerUnit
        * * Display Name: Effective Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: EffectiveAV / DenomValue -- the value that flows into the headline mean/median when IsSelected.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    ComparableParcel: z.string().describe(`
        * * Field Name: ComparableParcel
        * * Display Name: Comparable Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxComparableAssessmentMemberEntityType = z.infer<typeof indianataxComparableAssessmentMemberSchema>;

/**
 * zod schema definition for the entity Comparable Assessment Sets
 */
export const indianataxComparableAssessmentSetSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    SubjectParcelID: z.string().describe(`
        * * Field Name: SubjectParcelID
        * * Display Name: Subject Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The subject parcel being analysed.`),
    FocusYear: z.number().describe(`
        * * Field Name: FocusYear
        * * Display Name: Focus Year
        * * SQL Data Type: smallint
        * * Description: The assessment year the per-unit comparison is struck for.`),
    MethodologyVersion: z.string().describe(`
        * * Field Name: MethodologyVersion
        * * Display Name: Methodology Version
        * * SQL Data Type: nvarchar(30)
        * * Description: Version tag for the builder logic that produced this set (e.g. "comps-v1-2026-08-30"). Lets a re-run replace its own set without touching an earlier method's.`),
    PropertyTypeGroup: z.string().nullable().describe(`
        * * Field Name: PropertyTypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(30)
        * * Description: Rolled-up property category the comp pool was drawn from.`),
    UnitOfComparison: z.union([z.literal('$/SF'), z.literal('$/acre'), z.literal('$/unit')]).describe(`
        * * Field Name: UnitOfComparison
        * * Display Name: Unit of Comparison
        * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * $/SF
    *   * $/acre
    *   * $/unit
        * * Description: Unit of comparison: $/SF (default), $/unit (multifamily with a trustworthy unit count), or $/acre (land).`),
    HeadlineTrack: z.union([z.literal('Appealed'), z.literal('Effective'), z.literal('Original')]).describe(`
        * * Field Name: HeadlineTrack
        * * Display Name: Headline Track
        * * SQL Data Type: nvarchar(10)
        * * Default Value: Effective
    * * Value List Type: List
    * * Possible Values 
    *   * Appealed
    *   * Effective
    *   * Original
        * * Description: Which value track drives the headline: Original (as-noticed), Appealed (post-PTABOA/IBTR), or Effective (Appealed if present else Original). Default Effective -- the hardest benchmark for the county to rebut.`),
    SubjectDenomValue: z.number().nullable().describe(`
        * * Field Name: SubjectDenomValue
        * * Display Name: Subject Denominator Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The subject's denominator for the unit of comparison (building SF, unit count, or acres).`),
    SubjectOriginalAV: z.number().nullable().describe(`
        * * Field Name: SubjectOriginalAV
        * * Display Name: Subject Original Assessed Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Subject as-noticed Original total AV for the focus year.`),
    SubjectEffectiveAV: z.number().nullable().describe(`
        * * Field Name: SubjectEffectiveAV
        * * Display Name: Subject Effective Assessed Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Subject Effective total AV for the focus year (Appealed if the subject itself has a PTABOA/IBTR result, else Original).`),
    SubjectPerUnitEffective: z.number().nullable().describe(`
        * * Field Name: SubjectPerUnitEffective
        * * Display Name: Subject Per-Unit Effective Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: SubjectEffectiveAV / SubjectDenomValue -- the number the comp means/medians are measured against.`),
    NeighborhoodCode: z.string().nullable().describe(`
        * * Field Name: NeighborhoodCode
        * * Display Name: Neighborhood Code
        * * SQL Data Type: nvarchar(120)
        * * Description: The subject's CountyAssessorRecord.Neighborhood code -- the pool for the Neighborhood list.`),
    NeighborhoodCompCount: z.number().nullable().describe(`
        * * Field Name: NeighborhoodCompCount
        * * Display Name: Neighborhood Comparable Count
        * * SQL Data Type: int
        * * Description: Count of Neighborhood-list members with a usable per-unit value (basis for the mean/median).`),
    NeighborhoodMeanPerUnit: z.number().nullable().describe(`
        * * Field Name: NeighborhoodMeanPerUnit
        * * Display Name: Neighborhood Mean Per-Unit Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Mean Effective per-unit value across the Neighborhood list (focus year). Can mislead when the neighborhood is thin and building sizes vary widely -- prefer the median.`),
    NeighborhoodMedianPerUnit: z.number().nullable().describe(`
        * * Field Name: NeighborhoodMedianPerUnit
        * * Display Name: Neighborhood Median Per-Unit Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Median Effective per-unit value across the Neighborhood list (focus year).`),
    CountyCompCount: z.number().nullable().describe(`
        * * Field Name: CountyCompCount
        * * Display Name: County Comparable Count
        * * SQL Data Type: int
        * * Description: Count of County-list members with a usable per-unit value.`),
    CountyMeanPerUnit: z.number().nullable().describe(`
        * * Field Name: CountyMeanPerUnit
        * * Display Name: County Mean Per-Unit Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Mean Effective per-unit value across the County-wide list (focus year).`),
    CountyMedianPerUnit: z.number().nullable().describe(`
        * * Field Name: CountyMedianPerUnit
        * * Display Name: County Median Per-Unit Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Median Effective per-unit value across the County-wide list (focus year).`),
    SubjectPercentile: z.number().nullable().describe(`
        * * Field Name: SubjectPercentile
        * * Display Name: Subject Percentile
        * * SQL Data Type: smallint
        * * Description: Percentile the subject's per-unit value sits at within the combined comp set (0-100; higher = more over-assessed relative to peers).`),
    Status: z.union([z.literal('Draft'), z.literal('Final')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(10)
        * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Draft
    *   * Final
        * * Description: Draft (builder output, not yet reviewed) or Final (analyst has reviewed the selections).`),
    AnalystNote: z.string().nullable().describe(`
        * * Field Name: AnalystNote
        * * Display Name: Analyst Note
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text analyst / agent notes on the set.`),
    GeneratedAt: z.date().nullable().describe(`
        * * Field Name: GeneratedAt
        * * Display Name: Generated At
        * * SQL Data Type: datetimeoffset
        * * Description: When the builder generated this set.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SubjectParcel: z.string().describe(`
        * * Field Name: SubjectParcel
        * * Display Name: Subject Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxComparableAssessmentSetEntityType = z.infer<typeof indianataxComparableAssessmentSetSchema>;

/**
 * zod schema definition for the entity County Assessor Improvement Segments
 */
export const indianataxCountyAssessorImprovementSegmentSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyAssessorRecordID: z.string().describe(`
        * * Field Name: CountyAssessorRecordID
        * * Display Name: County Assessor Record
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
        * * Description: The parcel record this improvement segment belongs to. Segments are implicitly part of the "Building" structure line -- Paving/Skyway/etc. don't carry their own per-floor breakdown, so there is no direct link to a specific CountyAssessorImprovement row.`),
    CardNumber: z.string().nullable().describe(`
        * * Field Name: CardNumber
        * * Display Name: Card Number
        * * SQL Data Type: nvarchar(10)
        * * Description: The card page this segment was reported on (e.g. "1", "1A").`),
    SegmentIndex: z.number().nullable().describe(`
        * * Field Name: SegmentIndex
        * * Display Name: Segment Index
        * * SQL Data Type: int
        * * Description: The segment's column position within its card (left to right), used to preserve the original ordering and as a stable identity within a card when re-parsing.`),
    Use: z.string().nullable().describe(`
        * * Field Name: Use
        * * Display Name: Use Classification
        * * SQL Data Type: nvarchar(50)
        * * Description: The use classification for this segment, e.g. "Gen Office", "Utility".`),
    SqFtPerFloor: z.number().nullable().describe(`
        * * Field Name: SqFtPerFloor
        * * Display Name: Square Feet Per Floor
        * * SQL Data Type: decimal(12, 2)
        * * Description: The "S.F. Area" / "Average Size" value for this segment -- the size of ONE floor of this type, not the segment total. See TotalSqFt.`),
    FloorCount: z.number().nullable().describe(`
        * * Field Name: FloorCount
        * * Display Name: Floor Count
        * * SQL Data Type: int
        * * Description: The "Units" value from "Average Size / Units" -- how many floors carry this segment's SqFtPerFloor. 1 for a single-floor segment.`),
    TotalSqFt: z.number().nullable().describe(`
        * * Field Name: TotalSqFt
        * * Display Name: Total Square Feet
        * * SQL Data Type: decimal(23, 2)
        * * Description: Computed as SqFtPerFloor * FloorCount -- the true total square footage this segment contributes to the building. Always use this, never SqFtPerFloor alone, for any building-size or per-square-foot analysis.`),
    ReproductionCost: z.number().nullable().describe(`
        * * Field Name: ReproductionCost
        * * Display Name: Reproduction Cost
        * * SQL Data Type: decimal(14, 2)
        * * Description: The assessor's estimated replacement cost for this segment, per the card's cost-model computation.`),
    PhysicalDepreciationPct: z.number().nullable().describe(`
        * * Field Name: PhysicalDepreciationPct
        * * Display Name: Physical Depreciation Percentage
        * * SQL Data Type: decimal(9, 4)
        * * Description: The "Phys Dep" percentage from the "Phys Dep/ Yr Blt /Cond" field -- physical depreciation applied to this segment's reproduction cost.`),
    YearConstructed: z.number().nullable().describe(`
        * * Field Name: YearConstructed
        * * Display Name: Year Constructed
        * * SQL Data Type: smallint
        * * Description: The "Yr Blt" (year built) component of "Phys Dep/ Yr Blt /Cond" for this specific segment -- can differ segment-to-segment within the same structure (e.g. an addition).`),
    EffectiveYear: z.number().nullable().describe(`
        * * Field Name: EffectiveYear
        * * Display Name: Effective Year
        * * SQL Data Type: smallint
        * * Description: The effective year used for this segment's depreciation calculation.`),
    Condition: z.string().nullable().describe(`
        * * Field Name: Condition
        * * Display Name: Condition
        * * SQL Data Type: nvarchar(10)
        * * Description: The "Cond" (condition) component of "Phys Dep/ Yr Blt /Cond" -- a letter rating (e.g. "A") for this segment.`),
    ObsolescencePct: z.number().nullable().describe(`
        * * Field Name: ObsolescencePct
        * * Display Name: Obsolescence Percentage
        * * SQL Data Type: decimal(9, 4)
        * * Description: The "Obsolescence" figure for this segment -- a cost-model adjustment the county can apply to align reproduction-cost-based value with market value-in-use. NOTE (2026-08-23): the sample parcel used to design this table had Obsolescence=0 throughout, so the real-world format (percentage vs. dollar amount) of a non-zero value has not yet been directly confirmed -- verify against a parcel with an actual adjustment before relying on this column's units. A parcel receiving this adjustment while comparable parcels don't is a potential appeal-lead signal (see the related ResearchTask), but that scoring logic is not implemented by this column alone.`),
    RemainderValue: z.number().nullable().describe(`
        * * Field Name: RemainderValue
        * * Display Name: Remainder Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Remainder Value" for this segment -- reproduction cost after physical depreciation and obsolescence.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    CountyAssessorRecord: z.string().nullable().describe(`
        * * Field Name: CountyAssessorRecord
        * * Display Name: County Assessor Record
        * * SQL Data Type: nvarchar(500)`),
});

export type indianataxCountyAssessorImprovementSegmentEntityType = z.infer<typeof indianataxCountyAssessorImprovementSegmentSchema>;

/**
 * zod schema definition for the entity County Assessor Improvements
 */
export const indianataxCountyAssessorImprovementSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyAssessorRecordID: z.string().describe(`
        * * Field Name: CountyAssessorRecordID
        * * Display Name: County Assessor Record
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
        * * Description: The parcel record this improvement belongs to.`),
    CardNumber: z.string().nullable().describe(`
        * * Field Name: CardNumber
        * * Display Name: Card Number
        * * SQL Data Type: nvarchar(10)
        * * Description: The card page this row was reported on (e.g. "1", "1A"). A parcel can have multiple cards for complex properties.`),
    Use: z.string().nullable().describe(`
        * * Field Name: Use
        * * Display Name: Structure Type
        * * SQL Data Type: nvarchar(50)
        * * Description: The structure type, e.g. "Building", "Paving -Asph", "Skyway enclosed walkway".`),
    Grade: z.string().nullable().describe(`
        * * Field Name: Grade
        * * Display Name: Construction Grade
        * * SQL Data Type: nvarchar(50)
        * * Description: Construction grade rating (e.g. "C", "B+"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.`),
    YearConstructed: z.number().nullable().describe(`
        * * Field Name: YearConstructed
        * * Display Name: Year Constructed
        * * SQL Data Type: smallint
        * * Description: The year this structure was originally constructed, per the card.`),
    EffectiveYear: z.number().nullable().describe(`
        * * Field Name: EffectiveYear
        * * Display Name: Effective Year
        * * SQL Data Type: smallint
        * * Description: The effective year used for depreciation purposes (can differ from YearConstructed after a renovation).`),
    Condition: z.string().nullable().describe(`
        * * Field Name: Condition
        * * Display Name: Condition Rating
        * * SQL Data Type: nvarchar(50)
        * * Description: Condition rating letter (e.g. "A"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.`),
    SizeOrArea: z.number().nullable().describe(`
        * * Field Name: SizeOrArea
        * * Display Name: Size or Area
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Size or Area" figure on this structure's summary row. For the Building row, this is the true total building square footage (already accounts for multi-floor segments) -- more reliable than CountyAssessorRecord.EstimatedSqFt sourced any other way.`),
    ReproductionCost: z.number().nullable().describe(`
        * * Field Name: ReproductionCost
        * * Display Name: Reproduction Cost
        * * SQL Data Type: decimal(14, 2)
        * * Description: The assessor's estimated replacement cost for this structure, per the card's cost-model computation.`),
    DepreciationObsolescence: z.number().nullable().describe(`
        * * Field Name: DepreciationObsolescence
        * * Display Name: Depreciation/Obsolescence
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Dep/Obs" figure on the summary row -- combined physical depreciation and obsolescence deduction from reproduction cost. See CountyAssessorImprovementSegment for the per-floor breakdown of physical depreciation and obsolescence separately.`),
    RemainderValue: z.number().nullable().describe(`
        * * Field Name: RemainderValue
        * * Display Name: Remainder Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "REM Val" (remainder value) figure -- reproduction cost less depreciation/obsolescence, before the trend factor is applied.`),
    PctComplete: z.number().nullable().describe(`
        * * Field Name: PctComplete
        * * Display Name: Percent Complete
        * * SQL Data Type: decimal(5, 2)
        * * Description: The "% Cmp" (percent complete) figure, for structures under construction. 100 for a finished structure.`),
    TrendFactor: z.number().nullable().describe(`
        * * Field Name: TrendFactor
        * * Display Name: Trend Factor
        * * SQL Data Type: decimal(9, 4)
        * * Description: The trend factor applied to remainder value to reach true tax value.`),
    TrueTaxValue: z.number().nullable().describe(`
        * * Field Name: TrueTaxValue
        * * Display Name: True Tax Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "True Tax Value" figure -- this structure's contribution to the parcel's assessed improvement value.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    CountyAssessorRecord: z.string().nullable().describe(`
        * * Field Name: CountyAssessorRecord
        * * Display Name: Parcel Record
        * * SQL Data Type: nvarchar(500)`),
});

export type indianataxCountyAssessorImprovementEntityType = z.infer<typeof indianataxCountyAssessorImprovementSchema>;

/**
 * zod schema definition for the entity County Assessor Records
 */
export const indianataxCountyAssessorRecordSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this record belongs to.`),
    CountyNumber: z.number().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: Which county's own system this record came from.`),
    OwnerName: z.string().nullable().describe(`
        * * Field Name: OwnerName
        * * Display Name: Owner Name
        * * SQL Data Type: nvarchar(500)`),
    OwnerAddress: z.string().nullable().describe(`
        * * Field Name: OwnerAddress
        * * Display Name: Owner Address
        * * SQL Data Type: nvarchar(200)`),
    OwnerCity: z.string().nullable().describe(`
        * * Field Name: OwnerCity
        * * Display Name: Owner City
        * * SQL Data Type: nvarchar(100)`),
    OwnerState: z.string().nullable().describe(`
        * * Field Name: OwnerState
        * * Display Name: Owner State
        * * SQL Data Type: nvarchar(10)`),
    OwnerZip: z.string().nullable().describe(`
        * * Field Name: OwnerZip
        * * Display Name: Owner Zip
        * * SQL Data Type: nvarchar(20)`),
    PropertyClass: z.string().nullable().describe(`
        * * Field Name: PropertyClass
        * * Display Name: Property Class
        * * SQL Data Type: nvarchar(32)`),
    PropertySubClassDescription: z.string().nullable().describe(`
        * * Field Name: PropertySubClassDescription
        * * Display Name: Property Subclass
        * * SQL Data Type: nvarchar(64)`),
    AssessedLandAV: z.number().nullable().describe(`
        * * Field Name: AssessedLandAV
        * * Display Name: Assessed Land Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Assessed land value per the county's own current system -- may be fresher than the statewide Assessment table for this parcel.`),
    AssessedImprovementAV: z.number().nullable().describe(`
        * * Field Name: AssessedImprovementAV
        * * Display Name: Assessed Improvement Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Assessed improvement value per the county's own current system.`),
    AssessedTotalAV: z.number().nullable().describe(`
        * * Field Name: AssessedTotalAV
        * * Display Name: Assessed Total Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Assessed total value per the county's own current system.`),
    CountyParcelID: z.string().nullable().describe(`
        * * Field Name: CountyParcelID
        * * Display Name: County Parcel ID
        * * SQL Data Type: nvarchar(50)
        * * Description: The county system's own internal parcel identifier (e.g. Marion's CAMAPARCELID), distinct from the statewide ParcelNumber.`),
    Neighborhood: z.string().nullable().describe(`
        * * Field Name: Neighborhood
        * * Display Name: Neighborhood
        * * SQL Data Type: nvarchar(32)`),
    TaxDistrictID: z.string().nullable().describe(`
        * * Field Name: TaxDistrictID
        * * Display Name: Tax District ID
        * * SQL Data Type: nvarchar(5)`),
    LegalDescription: z.string().nullable().describe(`
        * * Field Name: LegalDescription
        * * Display Name: Legal Description
        * * SQL Data Type: nvarchar(1500)`),
    Acreage: z.string().nullable().describe(`
        * * Field Name: Acreage
        * * Display Name: Acreage
        * * SQL Data Type: nvarchar(10)`),
    EstimatedSqFt: z.number().nullable().describe(`
        * * Field Name: EstimatedSqFt
        * * Display Name: Estimated Square Footage
        * * SQL Data Type: int
        * * Description: Estimated square footage. CAUTION: sourced from the Marion County ArcGIS layer's ESTSQFT field, which for a meaningful subset of rows (~29%, matches Parcel.Acreage * 43560) actually holds LAND square footage rather than building square footage -- confirmed 2026-08-23 against a real Property Record Card. Check SqFtSource: 'BuildingDetail' means this value was re-sourced from itemized per-floor data and is trustworthy for building-size analysis; NULL means it is either the original unverified ArcGIS value (use with caution, may be land area) or was cleared after being proven land-derived with no better source available.`),
    Status: z.string().nullable().describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(8)`),
    SourceModDate: z.date().nullable().describe(`
        * * Field Name: SourceModDate
        * * Display Name: Source Modified Date
        * * SQL Data Type: datetimeoffset
        * * Description: When the county's OWN system last updated this record -- distinct from RetrievedAt, which is when WE fetched it.`),
    RetrievedAt: z.date().describe(`
        * * Field Name: RetrievedAt
        * * Display Name: Retrieved At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When we fetched this record.`),
    SourceRegistryID: z.string().nullable().describe(`
        * * Field Name: SourceRegistryID
        * * Display Name: Source Registry
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
        * * Description: The SourceRegistry entry for the county system this came from.`),
    YearBuilt: z.number().nullable().describe(`
        * * Field Name: YearBuilt
        * * Display Name: Year Built
        * * SQL Data Type: smallint
        * * Description: Year the primary structure was built, per the county's Tax History report.`),
    LastAssessmentChangeDate: z.date().nullable().describe(`
        * * Field Name: LastAssessmentChangeDate
        * * Display Name: Last Assessment Change Date
        * * SQL Data Type: date
        * * Description: Date of the last assessment change per the county's system.`),
    TaxYear: z.number().nullable().describe(`
        * * Field Name: TaxYear
        * * Display Name: Tax Year
        * * SQL Data Type: smallint
        * * Description: The tax year the tax-bill fields on this row (GrossAssessment through CurrentTaxDue) apply to.`),
    GrossAssessment: z.number().nullable().describe(`
        * * Field Name: GrossAssessment
        * * Display Name: Gross Assessment
        * * SQL Data Type: decimal(14, 2)
        * * Description: Gross assessment (land + improvements) for TaxYear, before deductions/exemptions.`),
    DeductionsExemptionsTotal: z.number().nullable().describe(`
        * * Field Name: DeductionsExemptionsTotal
        * * Display Name: Deductions/Exemptions Total
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total deductions/exemptions applied for TaxYear (e.g. homestead standard deduction, supplemental).`),
    NetAssessment: z.number().nullable().describe(`
        * * Field Name: NetAssessment
        * * Display Name: Net Assessment
        * * SQL Data Type: decimal(14, 2)
        * * Description: Net assessment for TaxYear (gross minus deductions/exemptions) -- the actual tax base.`),
    TaxRate: z.number().nullable().describe(`
        * * Field Name: TaxRate
        * * Display Name: Tax Rate
        * * SQL Data Type: decimal(9, 6)
        * * Description: The tax rate applied for TaxYear, as a percentage (e.g. 2.729100 means 2.7291%).`),
    NetAnnualTax: z.number().nullable().describe(`
        * * Field Name: NetAnnualTax
        * * Display Name: Net Annual Tax
        * * SQL Data Type: decimal(14, 2)
        * * Description: The actual computed net annual tax for TaxYear -- the real dollar tax amount, not just assessed value. This is data no other source in this schema provides.`),
    CurrentTaxDue: z.number().nullable().describe(`
        * * Field Name: CurrentTaxDue
        * * Display Name: Current Tax Due
        * * SQL Data Type: decimal(14, 2)
        * * Description: Amount currently due, per the report at the time it was fetched (a snapshot, not necessarily current by the time this is read).`),
    DeedType: z.string().nullable().describe(`
        * * Field Name: DeedType
        * * Display Name: Deed Type
        * * SQL Data Type: nvarchar(50)
        * * Description: Deed type for the most recent transfer (e.g. Warranty Deed), per the Tax History report.`),
    DeedDate: z.date().nullable().describe(`
        * * Field Name: DeedDate
        * * Display Name: Deed Date
        * * SQL Data Type: date
        * * Description: Deed execution date for the most recent transfer.`),
    FileDate: z.date().nullable().describe(`
        * * Field Name: FileDate
        * * Display Name: File Date
        * * SQL Data Type: date
        * * Description: Date the deed was filed/recorded for the most recent transfer.`),
    ReportRetrievedAt: z.date().nullable().describe(`
        * * Field Name: ReportRetrievedAt
        * * Display Name: Report Retrieved At
        * * SQL Data Type: datetimeoffset
        * * Description: When the Property Record Card / Tax History PDF reports were fetched for this parcel -- tracked separately from RetrievedAt (the GIS layer fetch) since these two sources are pulled at different times and paces (the reports have no bulk endpoint).`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SqFtSource: z.string().nullable().describe(`
        * * Field Name: SqFtSource
        * * Display Name: Square Footage Source
        * * SQL Data Type: nvarchar(20)
        * * Description: How EstimatedSqFt was sourced/verified, in descending order of reliability: 'PropertyRecordCard' = computed from CountyAssessorImprovementSegment (SqFtPerFloor * FloorCount, summed and cross-checked against the card's own Building total) -- the most reliable source, correctly accounts for multi-floor segments. 'BuildingDetail' = summed from itemized per-floor building_detail data WITHOUT a floor-count multiplier -- confirmed 2026-08-23 to systematically undercount multi-floor buildings (e.g. a 10-floor segment counted as 1 floor), superseded by 'PropertyRecordCard' wherever available. NULL = original ArcGIS ESTSQFT value (unverified, may be land-area-derived) or cleared after being proven land-derived with no replacement source available.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument row for this parcel's most recently fetched Property Record Card PDF. NULL until a PRC has been fetched for this parcel. Distinct from ReportRetrievedAt (a plain timestamp on this row) -- this links to the actual persisted PDF, its content hash, and its ExtractedText.`),
    TaxHistorySourceDocumentID: z.string().nullable().describe(`
        * * Field Name: TaxHistorySourceDocumentID
        * * Display Name: Tax History Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument row for this parcel's most recently fetched Tax History Report PDF -- distinct from SourceDocumentID, which links the Property Record Card. NULL until a Tax History Report has been fetched for this parcel.`),
    ComparisonUnitType: z.union([z.literal('Bed'), z.literal('Door'), z.literal('Key'), z.literal('Unit')]).nullable().describe(`
        * * Field Name: ComparisonUnitType
        * * Display Name: Comparison Unit Type
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Bed
    *   * Door
    *   * Key
    *   * Unit
        * * Description: The non-SF/non-acre unit of comparison this property should be valued per, when one applies: Unit (apartment dwelling units), Key (hotel/motel rooms), Bed (nursing home/hospital beds), or Door (self-storage doors). NULL means this property is compared per square foot (the default -- see EstimatedSqFt) or per acre (vacant land -- see Acreage), not per a unit count. Not populated by PRC parsing -- see ComparisonUnitCount.`),
    ComparisonUnitCount: z.number().nullable().describe(`
        * * Field Name: ComparisonUnitCount
        * * Display Name: Comparison Unit Count
        * * SQL Data Type: decimal(10, 2)
        * * Description: The count of ComparisonUnitType for this property (e.g. number of apartment units, hotel keys, nursing beds, or storage doors). NULL until populated by a future CoStar-export import -- confirmed 2026-08-25 that Marion County's Property Record Card does not reliably expose this as a structured field (one large hotel's card had a free-text renovation note giving a room count; the rest of a small real sample had nothing usable).`),
    CoStarYearBuilt: z.number().nullable().describe(`
        * * Field Name: CoStarYearBuilt
        * * Display Name: CoStar Year Built
        * * SQL Data Type: smallint
        * * Description: Year built, sourced from a matched CoStarProperty row (CoStar "Year Built") -- ONLY populated when this parcel's own YearBuilt (Tax History Report-sourced) is null and exactly one unambiguous CoStar value exists for it (see backfill-costar-derived-fields.js). Kept separate from YearBuilt rather than merged into it -- the two sources must stay distinguishable per this project's CoStar-provenance convention. The Property Search grid's "Year Built" column shows YearBuilt when present, this as a marked fallback otherwise.`),
    CoStarRBA: z.number().nullable().describe(`
        * * Field Name: CoStarRBA
        * * Display Name: CoStar RBA
        * * SQL Data Type: int
        * * Description: Rentable Building Area, sourced from a matched CoStarProperty row (CoStar "RBA") -- ONLY populated when exactly one unambiguous CoStar value exists for this parcel across its single-parcel-matched CoStarProperty rows (see backfill-costar-derived-fields.js). Distinct from EstimatedSqFt (total building SF from the PRC/ArcGIS layer) -- RBA is the rentable/leasable measure, a different physical quantity, not just a different source for the same number. Never merged into EstimatedSqFt.`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
    SourceRegistry: z.string().nullable().describe(`
        * * Field Name: SourceRegistry
        * * Display Name: Source Registry
        * * SQL Data Type: nvarchar(200)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxCountyAssessorRecordEntityType = z.infer<typeof indianataxCountyAssessorRecordSchema>;

/**
 * zod schema definition for the entity County Assessor Sale Histories
 */
export const indianataxCountyAssessorSaleHistorySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyAssessorRecordID: z.string().describe(`
        * * Field Name: CountyAssessorRecordID
        * * Display Name: County Assessor Record
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
        * * Description: The parcel record this sale belongs to.`),
    SaleDate: z.date().nullable().describe(`
        * * Field Name: SaleDate
        * * Display Name: Sale Date
        * * SQL Data Type: date
        * * Description: Date of the transfer/sale.`),
    GrantorName: z.string().nullable().describe(`
        * * Field Name: GrantorName
        * * Display Name: Grantor Name
        * * SQL Data Type: nvarchar(300)
        * * Description: Grantor (seller) of record.`),
    IsValidSale: z.boolean().nullable().describe(`
        * * Field Name: IsValidSale
        * * Display Name: Valid Sale
        * * SQL Data Type: bit
        * * Description: Whether the county flagged this as a valid (arms-length) sale, per the source report.`),
    SaleAmount: z.number().nullable().describe(`
        * * Field Name: SaleAmount
        * * Display Name: Sale Amount
        * * SQL Data Type: decimal(14, 2)
        * * Description: Sale/transfer amount.`),
    SaleType: z.string().nullable().describe(`
        * * Field Name: SaleType
        * * Display Name: Sale Type
        * * SQL Data Type: nvarchar(50)
        * * Description: Transfer type as recorded, e.g. Sale, Straight (non-sale transfer such as a trust conveyance).`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    CountyAssessorRecord: z.string().nullable().describe(`
        * * Field Name: CountyAssessorRecord
        * * Display Name: County Assessor Record
        * * SQL Data Type: nvarchar(500)`),
});

export type indianataxCountyAssessorSaleHistoryEntityType = z.infer<typeof indianataxCountyAssessorSaleHistorySchema>;

/**
 * zod schema definition for the entity County Resources
 */
export const indianataxCountyResourceSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyName: z.string().describe(`
        * * Field Name: CountyName
        * * Display Name: County Name
        * * SQL Data Type: nvarchar(50)
        * * Description: The Indiana county this resource belongs to (as named by the source directory).`),
    ResourceLabel: z.string().describe(`
        * * Field Name: ResourceLabel
        * * Display Name: Resource Label
        * * SQL Data Type: nvarchar(200)
        * * Description: The resource's label as it appeared on the source page, e.g. "Marion Assessor" or "Recorder - Tapestry". Free text — county resource naming isn't standardized across the state.`),
    ResourceCategory: z.union([z.literal('Assessor'), z.literal('Auditor'), z.literal('GIS'), z.literal('Other'), z.literal('Recorder'), z.literal('Treasurer')]).nullable().describe(`
        * * Field Name: ResourceCategory
        * * Display Name: Resource Category
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * Assessor
    *   * Auditor
    *   * GIS
    *   * Other
    *   * Recorder
    *   * Treasurer
        * * Description: Best-effort category inferred from the label (Assessor/Auditor/Treasurer/Recorder/GIS/Other) — a categorization convenience, not authoritative.`),
    ResourceURL: z.string().describe(`
        * * Field Name: ResourceURL
        * * Display Name: Resource URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: URL of the resource.`),
    Phone: z.string().nullable().describe(`
        * * Field Name: Phone
        * * Display Name: Phone
        * * SQL Data Type: nvarchar(30)
        * * Description: Phone number, if the source directory listed one.`),
    SourceRegistryID: z.string().nullable().describe(`
        * * Field Name: SourceRegistryID
        * * Display Name: Source Registry
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
        * * Description: The SourceRegistry entry this was gathered from (the NETR Online county directory).`),
    DiscoveredAt: z.date().describe(`
        * * Field Name: DiscoveredAt
        * * Display Name: Discovered At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When this resource link was gathered.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SourceRegistry: z.string().nullable().describe(`
        * * Field Name: SourceRegistry
        * * Display Name: Source Registry Name
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxCountyResourceEntityType = z.infer<typeof indianataxCountyResourceSchema>;

/**
 * zod schema definition for the entity DLGF Building Details
 */
export const indianataxDLGFBuildingDetailSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    SourceDocumentID: z.string().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)`),
    SourceYear: z.number().describe(`
        * * Field Name: SourceYear
        * * Display Name: Source Year
        * * SQL Data Type: smallint`),
    BuildingNumber: z.string().nullable().describe(`
        * * Field Name: BuildingNumber
        * * Display Name: Building Number
        * * SQL Data Type: nvarchar(20)`),
    FloorNumber: z.string().nullable().describe(`
        * * Field Name: FloorNumber
        * * Display Name: Floor Number
        * * SQL Data Type: nvarchar(10)`),
    SectionLetterOrNumber: z.string().nullable().describe(`
        * * Field Name: SectionLetterOrNumber
        * * Display Name: Section Letter or Number
        * * SQL Data Type: nvarchar(10)`),
    PricingKey: z.string().nullable().describe(`
        * * Field Name: PricingKey
        * * Display Name: Pricing Key
        * * SQL Data Type: nvarchar(20)`),
    UseCode: z.string().nullable().describe(`
        * * Field Name: UseCode
        * * Display Name: Use Code
        * * SQL Data Type: nvarchar(20)`),
    SquareFootArea: z.number().nullable().describe(`
        * * Field Name: SquareFootArea
        * * Display Name: Square Foot Area
        * * SQL Data Type: decimal(14, 2)`),
    SquareFootRate: z.number().nullable().describe(`
        * * Field Name: SquareFootRate
        * * Display Name: Square Foot Rate
        * * SQL Data Type: decimal(14, 4)`),
    FramingType: z.number().nullable().describe(`
        * * Field Name: FramingType
        * * Display Name: Framing Type
        * * SQL Data Type: decimal(9, 2)`),
    WallType: z.number().nullable().describe(`
        * * Field Name: WallType
        * * Display Name: Wall Type
        * * SQL Data Type: decimal(9, 2)`),
    WallHeight: z.number().nullable().describe(`
        * * Field Name: WallHeight
        * * Display Name: Wall Height
        * * SQL Data Type: decimal(9, 2)`),
    HeatingACValueAdjustment: z.number().nullable().describe(`
        * * Field Name: HeatingACValueAdjustment
        * * Display Name: Heating/AC Value Adjustment
        * * SQL Data Type: decimal(14, 2)`),
    SprinklerValueAdjustment: z.number().nullable().describe(`
        * * Field Name: SprinklerValueAdjustment
        * * Display Name: Sprinkler Value Adjustment
        * * SQL Data Type: decimal(14, 2)`),
    AverageDepthForStripRetail: z.string().nullable().describe(`
        * * Field Name: AverageDepthForStripRetail
        * * Display Name: Average Depth for Strip Retail
        * * SQL Data Type: nvarchar(20)`),
    IndividuallyOwnedUnit: z.string().nullable().describe(`
        * * Field Name: IndividuallyOwnedUnit
        * * Display Name: Individually Owned Unit
        * * SQL Data Type: nvarchar(10)`),
    IndividuallyOwnedUnitSize: z.number().nullable().describe(`
        * * Field Name: IndividuallyOwnedUnitSize
        * * Display Name: Individually Owned Unit Size
        * * SQL Data Type: decimal(14, 2)`),
    ConfigurationCode: z.string().nullable().describe(`
        * * Field Name: ConfigurationCode
        * * Display Name: Configuration Code
        * * SQL Data Type: nvarchar(20)`),
    NumberOfUnits: z.number().nullable().describe(`
        * * Field Name: NumberOfUnits
        * * Display Name: Number of Units
        * * SQL Data Type: decimal(9, 2)`),
    AverageUnitSize: z.number().nullable().describe(`
        * * Field Name: AverageUnitSize
        * * Display Name: Average Unit Size
        * * SQL Data Type: decimal(14, 2)`),
    ImprovementInstanceNumber: z.number().nullable().describe(`
        * * Field Name: ImprovementInstanceNumber
        * * Display Name: Improvement Instance Number
        * * SQL Data Type: int`),
    BuildingInstanceNumber: z.number().nullable().describe(`
        * * Field Name: BuildingInstanceNumber
        * * Display Name: Building Instance Number
        * * SQL Data Type: int`),
    BuildingDetailInstanceNumber: z.number().nullable().describe(`
        * * Field Name: BuildingDetailInstanceNumber
        * * Display Name: Building Detail Instance Number
        * * SQL Data Type: int`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Reference
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxDLGFBuildingDetailEntityType = z.infer<typeof indianataxDLGFBuildingDetailSchema>;

/**
 * zod schema definition for the entity DLGF Buildings
 */
export const indianataxDLGFBuildingSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    SourceDocumentID: z.string().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)`),
    SourceYear: z.number().describe(`
        * * Field Name: SourceYear
        * * Display Name: Source Year
        * * SQL Data Type: smallint`),
    BuildingNumber: z.string().nullable().describe(`
        * * Field Name: BuildingNumber
        * * Display Name: Building Number
        * * SQL Data Type: nvarchar(20)`),
    PricingKeyPredominantUse: z.string().nullable().describe(`
        * * Field Name: PricingKeyPredominantUse
        * * Display Name: Pricing Key Predominant Use
        * * SQL Data Type: nvarchar(20)`),
    NumberOfFloors: z.number().nullable().describe(`
        * * Field Name: NumberOfFloors
        * * Display Name: Number of Floors
        * * SQL Data Type: decimal(6, 2)`),
    TotalSquareFootArea: z.number().nullable().describe(`
        * * Field Name: TotalSquareFootArea
        * * Display Name: Total Square Foot Area
        * * SQL Data Type: decimal(14, 2)`),
    TotalBaseValue: z.number().nullable().describe(`
        * * Field Name: TotalBaseValue
        * * Display Name: Total Base Value
        * * SQL Data Type: decimal(14, 2)`),
    PlumbingFixturesValue: z.number().nullable().describe(`
        * * Field Name: PlumbingFixturesValue
        * * Display Name: Plumbing Fixtures Value
        * * SQL Data Type: decimal(14, 2)`),
    SpecialFeaturesValue: z.number().nullable().describe(`
        * * Field Name: SpecialFeaturesValue
        * * Display Name: Special Features Value
        * * SQL Data Type: decimal(14, 2)`),
    ExteriorFeaturesValue: z.number().nullable().describe(`
        * * Field Name: ExteriorFeaturesValue
        * * Display Name: Exterior Features Value
        * * SQL Data Type: decimal(14, 2)`),
    ImprovementInstanceNumber: z.number().nullable().describe(`
        * * Field Name: ImprovementInstanceNumber
        * * Display Name: Improvement Instance Number
        * * SQL Data Type: int`),
    BuildingInstanceNumber: z.number().nullable().describe(`
        * * Field Name: BuildingInstanceNumber
        * * Display Name: Building Instance Number
        * * SQL Data Type: int`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxDLGFBuildingEntityType = z.infer<typeof indianataxDLGFBuildingSchema>;

/**
 * zod schema definition for the entity DLGF Improvements
 */
export const indianataxDLGFImprovementSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    SourceDocumentID: z.string().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument for the DLGF geodatabase pull this row came from (DocumentType StatewideParcelDataset).`),
    SourceYear: z.number().describe(`
        * * Field Name: SourceYear
        * * Display Name: Source Year
        * * SQL Data Type: smallint`),
    DwellingOrBuildingNumber: z.string().nullable().describe(`
        * * Field Name: DwellingOrBuildingNumber
        * * Display Name: Dwelling or Building Number
        * * SQL Data Type: nvarchar(20)`),
    ImprovementInstanceNumber: z.string().nullable().describe(`
        * * Field Name: ImprovementInstanceNumber
        * * Display Name: Improvement Instance Number
        * * SQL Data Type: nvarchar(10)`),
    ImprovementTypeCode: z.string().nullable().describe(`
        * * Field Name: ImprovementTypeCode
        * * Display Name: Improvement Type
        * * SQL Data Type: nvarchar(20)`),
    StoryHeightOrHeight: z.number().nullable().describe(`
        * * Field Name: StoryHeightOrHeight
        * * Display Name: Story Height or Height
        * * SQL Data Type: decimal(9, 2)`),
    ConstructionTypeCode: z.string().nullable().describe(`
        * * Field Name: ConstructionTypeCode
        * * Display Name: Construction Type
        * * SQL Data Type: nvarchar(20)`),
    YearConstructed: z.string().nullable().describe(`
        * * Field Name: YearConstructed
        * * Display Name: Year Constructed
        * * SQL Data Type: nvarchar(10)`),
    YearRemodeled: z.string().nullable().describe(`
        * * Field Name: YearRemodeled
        * * Display Name: Year Remodeled
        * * SQL Data Type: nvarchar(10)`),
    EffectiveConstructionYear: z.string().nullable().describe(`
        * * Field Name: EffectiveConstructionYear
        * * Display Name: Effective Construction Year
        * * SQL Data Type: nvarchar(10)`),
    Grade: z.string().nullable().describe(`
        * * Field Name: Grade
        * * Display Name: Grade
        * * SQL Data Type: nvarchar(10)`),
    ConditionCode: z.string().nullable().describe(`
        * * Field Name: ConditionCode
        * * Display Name: Condition
        * * SQL Data Type: nvarchar(10)`),
    NeighborhoodCode: z.string().nullable().describe(`
        * * Field Name: NeighborhoodCode
        * * Display Name: Neighborhood
        * * SQL Data Type: nvarchar(30)`),
    ImprovementSize: z.number().nullable().describe(`
        * * Field Name: ImprovementSize
        * * Display Name: Improvement Size
        * * SQL Data Type: decimal(14, 2)`),
    ReplacementCost: z.number().nullable().describe(`
        * * Field Name: ReplacementCost
        * * Display Name: Replacement Cost
        * * SQL Data Type: decimal(14, 2)
        * * Description: Replacement cost new for this improvement (before depreciation). A cost-approach input.`),
    AppraisedValue: z.number().nullable().describe(`
        * * Field Name: AppraisedValue
        * * Display Name: Appraised Value
        * * SQL Data Type: decimal(14, 2)`),
    PhysicalDepreciationPct: z.number().nullable().describe(`
        * * Field Name: PhysicalDepreciationPct
        * * Display Name: Physical Depreciation %
        * * SQL Data Type: decimal(9, 4)`),
    ObsolescenceDepreciationPct: z.number().nullable().describe(`
        * * Field Name: ObsolescenceDepreciationPct
        * * Display Name: Obsolescence Depreciation %
        * * SQL Data Type: decimal(9, 4)`),
    PercentComplete: z.number().nullable().describe(`
        * * Field Name: PercentComplete
        * * Display Name: Percent Complete
        * * SQL Data Type: decimal(9, 4)`),
    AVImprovements1PercentCap: z.number().nullable().describe(`
        * * Field Name: AVImprovements1PercentCap
        * * Display Name: AV Improvements Tier 1 % Cap
        * * SQL Data Type: decimal(14, 2)`),
    AVImprovements2PercentCap: z.number().nullable().describe(`
        * * Field Name: AVImprovements2PercentCap
        * * Display Name: AV Improvements Tier 2 % Cap
        * * SQL Data Type: decimal(14, 2)`),
    AVImprovements3PercentCap: z.number().nullable().describe(`
        * * Field Name: AVImprovements3PercentCap
        * * Display Name: AV Improvements Tier 3 % Cap
        * * SQL Data Type: decimal(14, 2)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxDLGFImprovementEntityType = z.infer<typeof indianataxDLGFImprovementSchema>;

/**
 * zod schema definition for the entity DLGF Lands
 */
export const indianataxDLGFLandSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    SourceDocumentID: z.string().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)`),
    SourceYear: z.number().describe(`
        * * Field Name: SourceYear
        * * Display Name: Source Year
        * * SQL Data Type: smallint`),
    LandInstanceNumber: z.string().nullable().describe(`
        * * Field Name: LandInstanceNumber
        * * Display Name: Land Instance Number
        * * SQL Data Type: nvarchar(10)`),
    LandLotTypeCode: z.string().nullable().describe(`
        * * Field Name: LandLotTypeCode
        * * Display Name: Land Lot Type Code
        * * SQL Data Type: nvarchar(10)`),
    ActualFrontage: z.number().nullable().describe(`
        * * Field Name: ActualFrontage
        * * Display Name: Actual Frontage
        * * SQL Data Type: decimal(12, 2)`),
    EffectiveFrontage: z.number().nullable().describe(`
        * * Field Name: EffectiveFrontage
        * * Display Name: Effective Frontage
        * * SQL Data Type: decimal(12, 2)`),
    EffectiveDepth: z.number().nullable().describe(`
        * * Field Name: EffectiveDepth
        * * Display Name: Effective Depth
        * * SQL Data Type: decimal(12, 2)`),
    BaseRate: z.number().nullable().describe(`
        * * Field Name: BaseRate
        * * Display Name: Base Rate
        * * SQL Data Type: decimal(14, 4)`),
    AppraisedValue: z.number().nullable().describe(`
        * * Field Name: AppraisedValue
        * * Display Name: Appraised Value
        * * SQL Data Type: decimal(14, 2)`),
    Acreage: z.number().nullable().describe(`
        * * Field Name: Acreage
        * * Display Name: Acreage
        * * SQL Data Type: decimal(14, 4)`),
    SquareFeet: z.number().nullable().describe(`
        * * Field Name: SquareFeet
        * * Display Name: Square Feet
        * * SQL Data Type: decimal(16, 2)`),
    SoilID: z.string().nullable().describe(`
        * * Field Name: SoilID
        * * Display Name: Soil ID
        * * SQL Data Type: nvarchar(20)`),
    SoilProductivityFactor: z.number().nullable().describe(`
        * * Field Name: SoilProductivityFactor
        * * Display Name: Soil Productivity Factor
        * * SQL Data Type: decimal(9, 4)`),
    InfluenceFactorCode1: z.string().nullable().describe(`
        * * Field Name: InfluenceFactorCode1
        * * Display Name: Influence Factor Code 1
        * * SQL Data Type: nvarchar(10)`),
    InfluenceFactor1: z.number().nullable().describe(`
        * * Field Name: InfluenceFactor1
        * * Display Name: Influence Factor 1
        * * SQL Data Type: decimal(9, 4)`),
    InfluenceFactorCode2: z.string().nullable().describe(`
        * * Field Name: InfluenceFactorCode2
        * * Display Name: Influence Factor Code 2
        * * SQL Data Type: nvarchar(10)`),
    InfluenceFactor2: z.number().nullable().describe(`
        * * Field Name: InfluenceFactor2
        * * Display Name: Influence Factor 2
        * * SQL Data Type: decimal(9, 4)`),
    InfluenceFactorCode3: z.string().nullable().describe(`
        * * Field Name: InfluenceFactorCode3
        * * Display Name: Influence Factor Code 3
        * * SQL Data Type: nvarchar(10)`),
    InfluenceFactor3: z.number().nullable().describe(`
        * * Field Name: InfluenceFactor3
        * * Display Name: Influence Factor 3
        * * SQL Data Type: decimal(9, 4)`),
    DepthFactor: z.number().nullable().describe(`
        * * Field Name: DepthFactor
        * * Display Name: Depth Factor
        * * SQL Data Type: decimal(9, 4)`),
    AcreageFactor: z.number().nullable().describe(`
        * * Field Name: AcreageFactor
        * * Display Name: Acreage Factor
        * * SQL Data Type: decimal(9, 4)`),
    AVLand1PercentCap: z.number().nullable().describe(`
        * * Field Name: AVLand1PercentCap
        * * Display Name: AV Land 1 Percent Cap
        * * SQL Data Type: decimal(14, 2)`),
    AVLand2PercentCap: z.number().nullable().describe(`
        * * Field Name: AVLand2PercentCap
        * * Display Name: AV Land 2 Percent Cap
        * * SQL Data Type: decimal(14, 2)`),
    AVLand3PercentCap: z.number().nullable().describe(`
        * * Field Name: AVLand3PercentCap
        * * Display Name: AV Land 3 Percent Cap
        * * SQL Data Type: decimal(14, 2)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Reference
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxDLGFLandEntityType = z.infer<typeof indianataxDLGFLandSchema>;

/**
 * zod schema definition for the entity Document Acquisitions
 */
export const indianataxDocumentAcquisitionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this acquisition tracks a document for.`),
    DocumentType: z.union([z.literal('PropertyRecordCard'), z.literal('TaxHistoryReport')]).describe(`
        * * Field Name: DocumentType
        * * Display Name: Document Type
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * PropertyRecordCard
    *   * TaxHistoryReport
        * * Description: Which document type is being fetched for this parcel -- a deliberate subset of SourceDocument.DocumentType (only the mechanically-fetched, per-parcel types: PropertyRecordCard, TaxHistoryReport). Together with ParcelID, the real uniqueness key.`),
    SubjectKey: z.string().describe(`
        * * Field Name: SubjectKey
        * * Display Name: Subject Key
        * * SQL Data Type: nvarchar(150)
        * * Description: Human-legible slug mirroring the on-disk file-naming grammar (e.g. "marion_prc_8050459_2026"), so a tracker row, a SourceDocument.RawFilePath, and a file on disk can be visually correlated. Informational/indexed only -- NOT the uniqueness key, since it legitimately changes once AssessmentYear becomes known from a successful fetch. See docs/NAMING_AND_RETENTION.md in the Indiana_Tax_Expert repo for the full grammar.`),
    AssessmentYear: z.number().nullable().describe(`
        * * Field Name: AssessmentYear
        * * Display Name: Assessment Year
        * * SQL Data Type: smallint
        * * Description: The assessment year of the most recently successfully fetched document for this (Parcel, DocumentType). NULL until first success -- not knowable before then, since these endpoints don't take a year parameter; you get whichever report is currently on file.`),
    Status: z.union([z.literal('Failed'), z.literal('InProgress'), z.literal('NeedsReview'), z.literal('Succeeded')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: InProgress
    * * Value List Type: List
    * * Possible Values 
    *   * Failed
    *   * InProgress
    *   * NeedsReview
    *   * Succeeded
        * * Description: InProgress (never yet resolved) / Succeeded (current SourceDocumentID is valid and current) / Failed (most recent attempt failed, eligible for retry at NextAttemptDueAt) / NeedsReview (failed AttemptCount times at or beyond the escalation ceiling -- excluded from automatic retry, needs deliberate follow-up).`),
    AttemptCount: z.number().describe(`
        * * Field Name: AttemptCount
        * * Display Name: Attempt Count
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Count of OUTER (script-run-level) acquisition attempts -- each of which already wraps up to 8 inner HTTP retries internally. Escalates Status to NeedsReview once this reaches 3.`),
    FirstAttemptedAt: z.date().describe(`
        * * Field Name: FirstAttemptedAt
        * * Display Name: First Attempted At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When this (Parcel, DocumentType) was first attempted.`),
    LastAttemptedAt: z.date().describe(`
        * * Field Name: LastAttemptedAt
        * * Display Name: Last Attempted At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When this (Parcel, DocumentType) was most recently attempted, successful or not.`),
    LastSucceededAt: z.date().nullable().describe(`
        * * Field Name: LastSucceededAt
        * * Display Name: Last Succeeded At
        * * SQL Data Type: datetimeoffset
        * * Description: When this (Parcel, DocumentType) was most recently successfully fetched and parsed. NULL if never successful.`),
    LastErrorCode: z.string().nullable().describe(`
        * * Field Name: LastErrorCode
        * * Display Name: Last Error Code
        * * SQL Data Type: nvarchar(100)
        * * Description: Short machine-oriented error identifier from the most recent failed attempt (e.g. "bad XRef entry", "not a PDF", "HTTP 500"). Cleared on success.`),
    LastErrorMessage: z.string().nullable().describe(`
        * * Field Name: LastErrorMessage
        * * Display Name: Last Error Message
        * * SQL Data Type: nvarchar(500)
        * * Description: Full error message from the most recent failed attempt. Cleared on success.`),
    NextAttemptDueAt: z.date().nullable().describe(`
        * * Field Name: NextAttemptDueAt
        * * Display Name: Next Attempt Due At
        * * SQL Data Type: datetimeoffset
        * * Description: Earliest time a bulk fetch run should retry this (Parcel, DocumentType) again, after a failure below the escalation ceiling. NULL once Succeeded or NeedsReview (nothing more to schedule).`),
    EscalatedAt: z.date().nullable().describe(`
        * * Field Name: EscalatedAt
        * * Display Name: Escalated At
        * * SQL Data Type: datetimeoffset
        * * Description: When Status flipped to NeedsReview (AttemptCount reached the escalation ceiling). NULL unless currently or previously escalated.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument produced by the most recent successful fetch. NULL until Succeeded at least once. Mirrors (does not replace) CountyAssessorRecord.SourceDocumentID/TaxHistorySourceDocumentID, which are set to the same value in the same transaction.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text notes -- e.g. a manual explanation of why a NeedsReview row was set back to Failed for another retry attempt.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxDocumentAcquisitionEntityType = z.infer<typeof indianataxDocumentAcquisitionSchema>;

/**
 * zod schema definition for the entity Document Catalogs
 */
export const indianataxDocumentCatalogSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    SourceRegistryID: z.string().describe(`
        * * Field Name: SourceRegistryID
        * * Display Name: Source Registry ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
        * * Description: Which source this document was discovered on.`),
    URL: z.string().describe(`
        * * Field Name: URL
        * * Display Name: URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: The document's URL (or local file path for non-web sources). Unique — the catalog's identity key for a document.`),
    Title: z.string().nullable().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(500)
        * * Description: Title/description as it appeared on the source page at discovery time.`),
    DiscoveredAt: z.date().describe(`
        * * Field Name: DiscoveredAt
        * * Display Name: Discovered At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When we first became aware of this document (found it listed on the source), independent of whether/when it was ingested.`),
    DocumentDate: z.date().nullable().describe(`
        * * Field Name: DocumentDate
        * * Display Name: Document Date
        * * SQL Data Type: date
        * * Description: The date the document itself is dated/effective, as best determined at cataloging time (e.g. a memo's stated issue date on the index page).`),
    IsPropertyTaxRelevant: z.boolean().nullable().describe(`
        * * Field Name: IsPropertyTaxRelevant
        * * Display Name: Is Property Tax Relevant
        * * SQL Data Type: bit
        * * Description: Whether this document is relevant to real property taxation. NULL = not yet evaluated; 1/0 = evaluated and included/excluded.`),
    RelevanceNotes: z.string().nullable().describe(`
        * * Field Name: RelevanceNotes
        * * Display Name: Relevance Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Why this document was included or excluded — e.g. "personal property, not real property" or "budget/TIF matter, out of scope".`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument this catalog entry resolved to, once actually fetched and stored. NULL until ingested (or permanently, if excluded).`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SourceRegistry: z.string().describe(`
        * * Field Name: SourceRegistry
        * * Display Name: Source Registry
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxDocumentCatalogEntityType = z.infer<typeof indianataxDocumentCatalogSchema>;

/**
 * zod schema definition for the entity Form Catalogs
 */
export const indianataxFormCatalogSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    StateFormNumber: z.string().describe(`
        * * Field Name: StateFormNumber
        * * Display Name: State Form Number
        * * SQL Data Type: nvarchar(20)
        * * Description: The number printed on every DLGF form itself (e.g. "21521", "53958", "21366") -- the reliable, near-deterministic way to identify which form a taxpayer uploaded, before any interpretive/LLM matching is needed.`),
    FormLabel: z.string().describe(`
        * * Field Name: FormLabel
        * * Display Name: Form Label
        * * SQL Data Type: nvarchar(30)
        * * Description: The colloquial form name (e.g. "Form 113/PP", "Form 130", "Form 11") -- deliberately matches AppealStage.FormRequired's own free-text convention exactly, so the two can be joined/compared as plain strings.`),
    FullTitle: z.string().describe(`
        * * Field Name: FullTitle
        * * Display Name: Full Title
        * * SQL Data Type: nvarchar(300)
        * * Description: The form's full official title as printed (e.g. "Notice of Assessment / Change by an Assessing Official").`),
    RevisionCode: z.string().nullable().describe(`
        * * Field Name: RevisionCode
        * * Display Name: Revision Code
        * * SQL Data Type: nvarchar(30)
        * * Description: The revision code printed on the form (e.g. "R12 / 10-19") -- forms get revised periodically; this records which revision was actually verified against, so a later revision can be detected as needing re-verification.`),
    Purpose: z.string().describe(`
        * * Field Name: Purpose
        * * Display Name: Purpose
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Plain-language description of what this form is for and when it's used.`),
    FiledBy: z.string().describe(`
        * * Field Name: FiledBy
        * * Display Name: Filed By
        * * SQL Data Type: nvarchar(100)
        * * Description: Who completes/files this form (e.g. "Assessing Official", "Taxpayer").`),
    FiledWith: z.string().nullable().describe(`
        * * Field Name: FiledWith
        * * Display Name: Filed With
        * * SQL Data Type: nvarchar(200)
        * * Description: Who receives this form (e.g. "Township Assessor or County Assessor"). Null for a form that is only issued outward (a notice), not filed with anyone.`),
    PropertyTypeScope: z.union([z.literal('Both'), z.literal('Personal'), z.literal('PublicUtility'), z.literal('Real')]).describe(`
        * * Field Name: PropertyTypeScope
        * * Display Name: Property Type Scope
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Both
    *   * Personal
    *   * PublicUtility
    *   * Real
        * * Description: Which kind of property this form applies to -- Real, Personal, Both, or PublicUtility.`),
    CorrespondingAppealStageID: z.string().nullable().describe(`
        * * Field Name: CorrespondingAppealStageID
        * * Display Name: Corresponding Appeal Stage
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
        * * Description: For a form that IS a step in the appeal process (Form 130, 131, 134): the indiana_tax.AppealStage row it corresponds to -- that row already carries the authoritative deadline/citation, not duplicated here. Null for a form that is not itself an appeal-process step.`),
    TriggersAppealStageID: z.string().nullable().describe(`
        * * Field Name: TriggersAppealStageID
        * * Display Name: Triggers Appeal Stage
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
        * * Description: For a NOTICE form (e.g. Form 11, Form 113/PP) whose issuance is what starts the clock on a downstream appeal-process step: the indiana_tax.AppealStage row it triggers. Null for a form that is not a triggering notice. A form should generally have exactly one of CorrespondingAppealStageID or TriggersAppealStageID set, not both -- not enforced by a CHECK since the distinction isn't safety-critical, just documented here.`),
    SourceDocumentID: z.string().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument row for this form's own actual PDF (DocumentType = 'Form', same convention already used for AppealStage.SourceDocumentID's Form 130 row) -- every catalog row traces back to a real, hashed, retained document, not an assertion.`),
    SourceURL: z.string().describe(`
        * * Field Name: SourceURL
        * * Display Name: Source URL
        * * SQL Data Type: nvarchar(500)
        * * Description: The forms.in.gov download URL this form was fetched from.`),
    LastVerifiedAt: z.date().describe(`
        * * Field Name: LastVerifiedAt
        * * Display Name: Last Verified At
        * * SQL Data Type: datetimeoffset
        * * Description: When this row was last verified against the actual form text -- distinct from __mj_UpdatedAt, which would also change on a purely mechanical edit.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    CorrespondingAppealStage: z.string().nullable().describe(`
        * * Field Name: CorrespondingAppealStage
        * * Display Name: Corresponding Appeal Stage Name
        * * SQL Data Type: nvarchar(200)`),
    TriggersAppealStage: z.string().nullable().describe(`
        * * Field Name: TriggersAppealStage
        * * Display Name: Triggers Appeal Stage Name
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxFormCatalogEntityType = z.infer<typeof indianataxFormCatalogSchema>;

/**
 * zod schema definition for the entity Jurisdiction Deadline Anchors
 */
export const indianataxJurisdictionDeadlineAnchorSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyNumber: z.number().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: The jurisdiction (Indiana county number).`),
    TownshipName: z.string().nullable().describe(`
        * * Field Name: TownshipName
        * * Display Name: Township Name
        * * SQL Data Type: nvarchar(60)
        * * Description: Set only when the anchor is township-level (Indiana has township assessors, and IL/WA-style rolling deadlines vary by township). NULL = county-level anchor.`),
    TaxYear: z.number().describe(`
        * * Field Name: TaxYear
        * * Display Name: Tax Year
        * * SQL Data Type: smallint
        * * Description: The assessment / tax year this anchor applies to.`),
    AnchorEvent: z.string().describe(`
        * * Field Name: AnchorEvent
        * * Display Name: Anchor Event
        * * SQL Data Type: nvarchar(40)
        * * Description: Same vocabulary as AppealStage.DeadlineAnchorEvent (Form11MailDate, PTABOAOrderDate, ...).`),
    AnchorDate: z.date().nullable().describe(`
        * * Field Name: AnchorDate
        * * Display Name: Anchor Date
        * * SQL Data Type: date
        * * Description: The observed / published date. NULL while Status = 'Pending'.`),
    Status: z.union([z.literal('Confirmed'), z.literal('Estimated'), z.literal('NotApplicable'), z.literal('Pending')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Confirmed
    *   * Estimated
    *   * NotApplicable
    *   * Pending
        * * Description: Confirmed (from a primary source -- set SourceDocumentID), Estimated (projected from prior years), Pending (not yet known), or NotApplicable.`),
    DerivedDeadline: z.date().nullable().describe(`
        * * Field Name: DerivedDeadline
        * * Display Name: Derived Deadline
        * * SQL Data Type: date
        * * Description: Convenience: AnchorDate resolved through the governing stage rule (anchor + offset, or the calendar-rule branch).`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument the date was taken from (a Form 11, an assessor calendar).`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text context.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxJurisdictionDeadlineAnchorEntityType = z.infer<typeof indianataxJurisdictionDeadlineAnchorSchema>;

/**
 * zod schema definition for the entity Market Assumptions
 */
export const indianataxMarketAssumptionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    AssumptionType: z.union([z.literal('CapRate'), z.literal('ExpenseRatio'), z.literal('MarketRentPerSqFt'), z.literal('MarketRentPerUnit'), z.literal('NOIPerSqFt'), z.literal('NOIPerUnit'), z.literal('Vacancy')]).describe(`
        * * Field Name: AssumptionType
        * * Display Name: Assumption Type
        * * SQL Data Type: nvarchar(24)
    * * Value List Type: List
    * * Possible Values 
    *   * CapRate
    *   * ExpenseRatio
    *   * MarketRentPerSqFt
    *   * MarketRentPerUnit
    *   * NOIPerSqFt
    *   * NOIPerUnit
    *   * Vacancy
        * * Description: Which parameter this row states: CapRate / NOIPerSqFt / NOIPerUnit / Vacancy / ExpenseRatio / MarketRentPerSqFt / MarketRentPerUnit. Rates (CapRate/Vacancy/ExpenseRatio) are decimal fractions; the others are dollars.`),
    PropertyTypeGroup: z.union([z.literal('All'), z.literal('Hospitality'), z.literal('Industrial'), z.literal('Land'), z.literal('Multifamily'), z.literal('Office'), z.literal('Other'), z.literal('Parking'), z.literal('Retail'), z.literal('Special')]).describe(`
        * * Field Name: PropertyTypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * All
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
        * * Description: The property-type group this parameter applies to (Retail/Office/Industrial/Multifamily/Land/Special/Other), or 'All'.`),
    Submarket: z.string().nullable().describe(`
        * * Field Name: Submarket
        * * Display Name: Submarket
        * * SQL Data Type: nvarchar(80)
        * * Description: Submarket the parameter is specific to; NULL = countywide.`),
    PeriodYear: z.number().nullable().describe(`
        * * Field Name: PeriodYear
        * * Display Name: Period Year
        * * SQL Data Type: smallint
        * * Description: The year the parameter represents (e.g. the assessment/valuation year, or the year the extracted sales cluster around). NULL if PeriodLabel carries the period instead.`),
    PeriodLabel: z.string().nullable().describe(`
        * * Field Name: PeriodLabel
        * * Display Name: Period Label
        * * SQL Data Type: nvarchar(30)
        * * Description: Free-text period when a single year does not fit (e.g. "2023-2025", "Q1 2024").`),
    Value: z.number().describe(`
        * * Field Name: Value
        * * Display Name: Value
        * * SQL Data Type: decimal(14, 4)
        * * Description: The concluded / central value (median for a SalesExtraction row). Decimal fraction for rate types, dollars otherwise.`),
    LowValue: z.number().nullable().describe(`
        * * Field Name: LowValue
        * * Display Name: Low Value
        * * SQL Data Type: decimal(14, 4)
        * * Description: Low end of the supported range (e.g. 25th percentile of the extracted sample).`),
    HighValue: z.number().nullable().describe(`
        * * Field Name: HighValue
        * * Display Name: High Value
        * * SQL Data Type: decimal(14, 4)
        * * Description: High end of the supported range (e.g. 75th percentile).`),
    SampleSize: z.number().nullable().describe(`
        * * Field Name: SampleSize
        * * Display Name: Sample Size
        * * SQL Data Type: int
        * * Description: Number of observations behind a SalesExtraction row.`),
    Method: z.union([z.literal('BandOfInvestment'), z.literal('BrokerSurvey'), z.literal('Manual'), z.literal('SalesExtraction')]).describe(`
        * * Field Name: Method
        * * Display Name: Method
        * * SQL Data Type: nvarchar(24)
    * * Value List Type: List
    * * Possible Values 
    *   * BandOfInvestment
    *   * BrokerSurvey
    *   * Manual
    *   * SalesExtraction
        * * Description: How the value was derived: SalesExtraction (from CapRateAtSale / ImpliedNOIAtSale on indiana_tax.SaleTransaction), BrokerSurvey (RealtyRates / PwC / CBRE etc.), BandOfInvestment (mortgage-equity build-up), or Manual.`),
    SourceNote: z.string().nullable().describe(`
        * * Field Name: SourceNote
        * * Display Name: Source Note
        * * SQL Data Type: nvarchar(300)
        * * Description: Citation / provenance for a non-extracted row (survey name, issue date, page).`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text notes.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxMarketAssumptionEntityType = z.infer<typeof indianataxMarketAssumptionSchema>;

/**
 * zod schema definition for the entity Owner Portfolio Parcels
 */
export const indianataxOwnerPortfolioParcelSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    OwnerPortfolioID: z.string().describe(`
        * * Field Name: OwnerPortfolioID
        * * Display Name: Owner Portfolio
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Owner Portfolios (vwOwnerPortfolios.ID)`),
    ParcelID: z.string().nullable().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    GISParcelNumber: z.string().describe(`
        * * Field Name: GISParcelNumber
        * * Display Name: GIS Parcel Number
        * * SQL Data Type: nvarchar(20)
        * * Description: parcel.parcel -- the 7-digit Marion County GIS parcel number, the always-present link key to the PRC and tax history even when ParcelID is null.`),
    Address: z.string().nullable().describe(`
        * * Field Name: Address
        * * Display Name: Address
        * * SQL Data Type: nvarchar(300)
        * * Description: The parcel's situs (site) address as shown in the dashboard parcel list.`),
    TypeGroup: z.string().nullable().describe(`
        * * Field Name: TypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(60)
        * * Description: The parcel's property-type group (e.g. Office, Retail, Industrial, Apartment, Hospitality) used for the by-type breakdowns.`),
    CurrentAV: z.number().nullable().describe(`
        * * Field Name: CurrentAV
        * * Display Name: Current Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: The parcel's current (most recent certified) total assessed value.`),
    AV2025: z.number().nullable().describe(`
        * * Field Name: AV2025
        * * Display Name: 2025 Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: The parcel's 2025 total assessed value.`),
    AV2026: z.number().nullable().describe(`
        * * Field Name: AV2026
        * * Display Name: 2026 Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: The parcel's 2026 total assessed value.`),
    AVYoYPct: z.number().nullable().describe(`
        * * Field Name: AVYoYPct
        * * Display Name: AV Year-over-Year Change %
        * * SQL Data Type: decimal(9, 4)
        * * Description: The parcel's year-over-year assessed-value change as a fraction (0.3000 = +30%).`),
    SqFt: z.number().nullable().describe(`
        * * Field Name: SqFt
        * * Display Name: Square Footage
        * * SQL Data Type: int
        * * Description: The parcel's improvement square footage where known.`),
    Units: z.number().nullable().describe(`
        * * Field Name: Units
        * * Display Name: Units
        * * SQL Data Type: int
        * * Description: The parcel's residential/lodging unit count where known.`),
    SalesIndicatedValue: z.number().nullable().describe(`
        * * Field Name: SalesIndicatedValue
        * * Display Name: Sales Indicated Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: parcel.salesInd -- the ValuationAnalysis sales-comparison indicated value for the parcel.`),
    IncomeIndicatedValue: z.number().nullable().describe(`
        * * Field Name: IncomeIndicatedValue
        * * Display Name: Income Indicated Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: parcel.incomeInd -- the ValuationAnalysis income-approach indicated value for the parcel.`),
    FloorValue: z.number().nullable().describe(`
        * * Field Name: FloorValue
        * * Display Name: Floor Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: parcel.floor -- the conservative low-end value the ValuationAnalysis would defend for the parcel.`),
    AskValue: z.number().nullable().describe(`
        * * Field Name: AskValue
        * * Display Name: Ask Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: parcel.ask -- the value the ValuationAnalysis recommends asking for at appeal (the opening position).`),
    EstSavingsAtAsk: z.number().nullable().describe(`
        * * Field Name: EstSavingsAtAsk
        * * Display Name: Est. Savings at Ask Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: Estimated annual property-tax saving for the parcel if the assessed value were reduced to AskValue. Coarse v1 estimate, a triage signal.`),
    EstSavingsAtFloor: z.number().nullable().describe(`
        * * Field Name: EstSavingsAtFloor
        * * Display Name: Est. Savings at Floor Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: Estimated annual property-tax saving for the parcel if the assessed value were reduced to FloorValue -- the conservative end of the range.`),
    Recommendation: z.string().nullable().describe(`
        * * Field Name: Recommendation
        * * Display Name: Recommendation
        * * SQL Data Type: nvarchar(20)
        * * Description: parcel.rec -- the ValuationAnalysis recommendation for the parcel (Appeal | Monitor | ...).`),
    ConfidenceTier: z.string().nullable().describe(`
        * * Field Name: ConfidenceTier
        * * Display Name: Confidence Tier
        * * SQL Data Type: nvarchar(20)
        * * Description: parcel.conf -- the ValuationAnalysis confidence tier for the recommendation (High | Medium | Low).`),
    SupportingApproachCount: z.number().nullable().describe(`
        * * Field Name: SupportingApproachCount
        * * Display Name: Supporting Approach Count
        * * SQL Data Type: int
        * * Description: parcel.supCount -- how many of the three approaches to value (cost, sales, income) support a reduction for the parcel (0-3).`),
    Appealed: z.boolean().describe(`
        * * Field Name: Appealed
        * * Display Name: Previously Appealed
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: BIT: the parcel has at least one recorded PTABOA/assessment appeal in its history.`),
    ExistingRep: z.string().nullable().describe(`
        * * Field Name: ExistingRep
        * * Display Name: Existing Representative
        * * SQL Data Type: nvarchar(200)
        * * Description: parcel.rep -- the tax representative on record for the parcel's prior appeals, if any.`),
    LastAppealYear: z.number().nullable().describe(`
        * * Field Name: LastAppealYear
        * * Display Name: Last Appeal Year
        * * SQL Data Type: int
        * * Description: The most recent assessment year in which this parcel was appealed.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    OwnerPortfolio: z.string().describe(`
        * * Field Name: OwnerPortfolio
        * * Display Name: Owner Portfolio
        * * SQL Data Type: nvarchar(300)`),
    Parcel: z.string().nullable().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Reference
        * * SQL Data Type: nvarchar(30)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Mj Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Mj Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxOwnerPortfolioParcelEntityType = z.infer<typeof indianataxOwnerPortfolioParcelSchema>;

/**
 * zod schema definition for the entity Owner Portfolio Runs
 */
export const indianataxOwnerPortfolioRunSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    RunDate: z.date().describe(`
        * * Field Name: RunDate
        * * Display Name: Run Date
        * * SQL Data Type: datetimeoffset
        * * Description: When the portfolio job that produced this run executed, taken verbatim from owners.json generatedAt.`),
    MethodologyVersion: z.string().describe(`
        * * Field Name: MethodologyVersion
        * * Display Name: Methodology Version
        * * SQL Data Type: nvarchar(60)
        * * Description: The build-owner-portfolios.js methodology label (owners.json method) so a run can be tied to the grouping and scoring rules that produced it.`),
    IsLatest: z.boolean().describe(`
        * * Field Name: IsLatest
        * * Display Name: Latest Run
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: Exactly one OwnerPortfolioRun row has IsLatest = 1 at a time; the loader clears the previous winner in the same transaction. The dashboard filters on it.`),
    CountyParcelCount: z.number().nullable().describe(`
        * * Field Name: CountyParcelCount
        * * Display Name: County Parcel Count
        * * SQL Data Type: int
        * * Description: countyRollup.parcels: the number of Marion commercial & industrial parcels in scope for this run.`),
    CountyTotalAV2025: z.number().nullable().describe(`
        * * Field Name: CountyTotalAV2025
        * * Display Name: County Total AV 2025
        * * SQL Data Type: decimal(18, 2)
        * * Description: countyRollup.totalAV2025: the summed 2025 assessed value across all in-scope county C&I parcels.`),
    CountyTotalAV2026: z.number().nullable().describe(`
        * * Field Name: CountyTotalAV2026
        * * Display Name: County Total AV 2026
        * * SQL Data Type: decimal(18, 2)
        * * Description: countyRollup.totalAV2026: the summed 2026 assessed value across all in-scope county C&I parcels.`),
    CountyYoYDollars: z.number().nullable().describe(`
        * * Field Name: CountyYoYDollars
        * * Display Name: County YoY Dollars
        * * SQL Data Type: decimal(18, 2)
        * * Description: countyRollup.yoyDollars: CountyTotalAV2026 minus CountyTotalAV2025, the county-wide dollar change in assessed value.`),
    CountyYoYPct: z.number().nullable().describe(`
        * * Field Name: CountyYoYPct
        * * Display Name: County YoY Percent
        * * SQL Data Type: decimal(9, 4)
        * * Description: countyRollup.yoyPct: the county-wide year-over-year assessed-value change as a fraction (0.0750 = +7.5%).`),
    CountyParcelsUp5: z.number().nullable().describe(`
        * * Field Name: CountyParcelsUp5
        * * Display Name: County Parcels Up 5%
        * * SQL Data Type: int
        * * Description: countyRollup.parcelsUp5: count of county C&I parcels whose 2026 AV rose more than 5% over 2025.`),
    CountyParcelsUp10: z.number().nullable().describe(`
        * * Field Name: CountyParcelsUp10
        * * Display Name: County Parcels Up 10%
        * * SQL Data Type: int
        * * Description: countyRollup.parcelsUp10: count of county C&I parcels whose 2026 AV rose more than 10% over 2025.`),
    CountyParcelsUp25: z.number().nullable().describe(`
        * * Field Name: CountyParcelsUp25
        * * Display Name: County Parcels Up 25%
        * * SQL Data Type: int
        * * Description: countyRollup.parcelsUp25: count of county C&I parcels whose 2026 AV rose more than 25% over 2025.`),
    CountyParcelsUp50: z.number().nullable().describe(`
        * * Field Name: CountyParcelsUp50
        * * Display Name: County Parcels Up 50%
        * * SQL Data Type: int
        * * Description: countyRollup.parcelsUp50: count of county C&I parcels whose 2026 AV rose more than 50% over 2025.`),
    CountyParcelsDown: z.number().nullable().describe(`
        * * Field Name: CountyParcelsDown
        * * Display Name: County Parcels Down
        * * SQL Data Type: int
        * * Description: countyRollup.parcelsDown: count of county C&I parcels whose 2026 AV fell below 2025.`),
    CountyByTypeJSON: z.string().nullable().describe(`
        * * Field Name: CountyByTypeJSON
        * * Display Name: County By Type
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON.stringify of countyRollup.byType from owners.json -- per-property-type 2025/2026 AV + YoY %, display-only for the banner chips. Not a queryable projection.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxOwnerPortfolioRunEntityType = z.infer<typeof indianataxOwnerPortfolioRunSchema>;

/**
 * zod schema definition for the entity Owner Portfolios
 */
export const indianataxOwnerPortfolioSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    RunID: z.string().describe(`
        * * Field Name: RunID
        * * Display Name: Run ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Owner Portfolio Runs (vwOwnerPortfolioRuns.ID)`),
    OwnerKey: z.string().describe(`
        * * Field Name: OwnerKey
        * * Display Name: Owner Key
        * * SQL Data Type: nvarchar(200)
        * * Description: Normalized owner key (scripts/lib/owner-key.js): CoStar true owner else cleaned label, lowercased, legal-form suffixes stripped. The stable join to indiana_tax.Prospect.OwnerKey across portfolio re-runs.`),
    Label: z.string().describe(`
        * * Field Name: Label
        * * Display Name: Owner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: Human-readable owner name shown in the dashboard (owner.label) -- the CoStar true owner if known, otherwise the cleaned assessor name.`),
    Kind: z.union([z.literal('Company'), z.literal('Government'), z.literal('Individual'), z.literal('Institution')]).describe(`
        * * Field Name: Kind
        * * Display Name: Owner Type
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Company
    *   * Government
    *   * Individual
    *   * Institution
        * * Description: Company | Individual | Government | Institution -- classifier from build-owner-portfolios.js. Only Company owners get a prospect Tier.`),
    Tier: z.string().nullable().describe(`
        * * Field Name: Tier
        * * Display Name: Prospect Tier
        * * SQL Data Type: nvarchar(12)
        * * Description: Prime (>= $500k/yr at ask) | Strong (>= $150k) | Moderate (>= $40k) | Watch | em dash for non-companies.`),
    GroupKeyType: z.string().nullable().describe(`
        * * Field Name: GroupKeyType
        * * Display Name: Grouping Method
        * * SQL Data Type: nvarchar(12)
        * * Description: owner.groupKeyType -- which signal grouped these parcels: CO (CoStar true owner), MAIL (shared mailing address), NAME (cleaned assessor name), or PARCEL (single parcel, no group).`),
    CoStarTrueOwner: z.string().nullable().describe(`
        * * Field Name: CoStarTrueOwner
        * * Display Name: CoStar True Owner
        * * SQL Data Type: nvarchar(300)
        * * Description: owner.coStarTrueOwner -- the CoStar-resolved ultimate owner name when available, the basis of the strongest grouping signal.`),
    ParcelCount: z.number().describe(`
        * * Field Name: ParcelCount
        * * Display Name: Parcel Count
        * * SQL Data Type: int
        * * Description: Number of parcels rolled up into this owner group for the run (matches the count of OwnerPortfolioParcel rows).`),
    DistinctEntities: z.number().nullable().describe(`
        * * Field Name: DistinctEntities
        * * Display Name: Distinct Entities
        * * SQL Data Type: int
        * * Description: Count of distinct raw assessor owner-name strings folded into this group -- a rough measure of how many title-holding entities the operating company uses.`),
    TotalAV: z.number().nullable().describe(`
        * * Field Name: TotalAV
        * * Display Name: Current Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: Sum of the current (most recent certified) assessed value across the group's parcels.`),
    TotalAV2025: z.number().nullable().describe(`
        * * Field Name: TotalAV2025
        * * Display Name: 2025 Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: Sum of 2025 assessed value across the group's parcels.`),
    TotalAV2026: z.number().nullable().describe(`
        * * Field Name: TotalAV2026
        * * Display Name: 2026 Assessed Value
        * * SQL Data Type: decimal(18, 2)
        * * Description: Sum of 2026 assessed value across the group's parcels.`),
    AVYoYDollars: z.number().nullable().describe(`
        * * Field Name: AVYoYDollars
        * * Display Name: AV Year-over-Year Change ($)
        * * SQL Data Type: decimal(18, 2)
        * * Description: TotalAV2026 minus TotalAV2025 -- the group's year-over-year dollar change in assessed value.`),
    AVYoYPct: z.number().nullable().describe(`
        * * Field Name: AVYoYPct
        * * Display Name: AV Year-over-Year Change (%)
        * * SQL Data Type: decimal(9, 4)
        * * Description: The group's year-over-year assessed-value change as a fraction (0.1200 = +12%).`),
    ParcelsUp10: z.number().nullable().describe(`
        * * Field Name: ParcelsUp10
        * * Display Name: Parcels Up 10%+
        * * SQL Data Type: int
        * * Description: Count of the group's parcels whose 2026 AV rose more than 10% over 2025.`),
    ParcelsUp25: z.number().nullable().describe(`
        * * Field Name: ParcelsUp25
        * * Display Name: Parcels Up 25%+
        * * SQL Data Type: int
        * * Description: Count of the group's parcels whose 2026 AV rose more than 25% over 2025.`),
    TotalUnits: z.number().nullable().describe(`
        * * Field Name: TotalUnits
        * * Display Name: Total Units
        * * SQL Data Type: int
        * * Description: Sum of residential/lodging unit counts across the group's parcels where a unit count is known.`),
    TotalSqFt: z.number().nullable().describe(`
        * * Field Name: TotalSqFt
        * * Display Name: Total Square Footage
        * * SQL Data Type: bigint
        * * Description: Sum of improvement square footage across the group's parcels where square footage is known.`),
    NAppealRec: z.number().nullable().describe(`
        * * Field Name: NAppealRec
        * * Display Name: Appeal Recommendations
        * * SQL Data Type: int
        * * Description: owner.nAppealRec -- count of the group's parcels the ValuationAnalysis flags with an Appeal recommendation.`),
    NTwoSupport: z.number().nullable().describe(`
        * * Field Name: NTwoSupport
        * * Display Name: Two-Approach Support Count
        * * SQL Data Type: int
        * * Description: owner.nTwoSupport -- count of the group's parcels where at least two of the three approaches to value support a reduction.`),
    NHighConfAppeal: z.number().nullable().describe(`
        * * Field Name: NHighConfAppeal
        * * Display Name: High Confidence Appeals
        * * SQL Data Type: int
        * * Description: owner.nHighConfAppeal -- count of the group's Appeal-rec parcels whose confidence tier is High.`),
    EstSavingsAtAsk: z.number().nullable().describe(`
        * * Field Name: EstSavingsAtAsk
        * * Display Name: Est. Savings at Ask
        * * SQL Data Type: decimal(18, 2)
        * * Description: Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the recommended ask across Appeal-rec parcels. v1 coarse comps -- a triage signal, not a quote.`),
    EstSavingsAtFloor: z.number().nullable().describe(`
        * * Field Name: EstSavingsAtFloor
        * * Display Name: Est. Savings at Floor
        * * SQL Data Type: decimal(18, 2)
        * * Description: Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the conservative floor value across Appeal-rec parcels -- the low end of the range.`),
    AppealedParcels: z.number().nullable().describe(`
        * * Field Name: AppealedParcels
        * * Display Name: Appealed Parcels
        * * SQL Data Type: int
        * * Description: Count of the group's parcels with at least one recorded PTABOA/assessment appeal in the appeal history.`),
    HistoricalReductionWon: z.number().nullable().describe(`
        * * Field Name: HistoricalReductionWon
        * * Display Name: Historical Reduction Won
        * * SQL Data Type: decimal(18, 2)
        * * Description: Total assessed-value reduction the group has historically won across all its recorded appeals (sum of prior-year AV reductions).`),
    AppealYears: z.string().nullable().describe(`
        * * Field Name: AppealYears
        * * Display Name: Appeal Years
        * * SQL Data Type: nvarchar(20)
        * * Description: Compact span of assessment years in which the group appealed, e.g. "2019-2023"; a single year if there is only one.`),
    MostRecentAppealYear: z.number().nullable().describe(`
        * * Field Name: MostRecentAppealYear
        * * Display Name: Most Recent Appeal Year
        * * SQL Data Type: int
        * * Description: The most recent assessment year in which any of the group's parcels was appealed.`),
    LikelyRep: z.string().nullable().describe(`
        * * Field Name: LikelyRep
        * * Display Name: Likely Tax Representative
        * * SQL Data Type: nvarchar(200)
        * * Description: Best single guess at the tax representative acting for the owner -- the rep that secured the most (or most recent) PTABOA reductions across the group's parcels.`),
    RepStatus: z.string().describe(`
        * * Field Name: RepStatus
        * * Display Name: Tax Rep Status
        * * SQL Data Type: nvarchar(120)
        * * Description: No rep on record | Represented by X | Multiple reps -- X (+N). Tax-rep inference: a rep that secured a PTABOA reduction on any portfolio parcel is assumed to act for the owner.`),
    RepsOnReductionJSON: z.string().nullable().describe(`
        * * Field Name: RepsOnReductionJSON
        * * Display Name: Representatives on Record
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON.stringify of owner.repsOnReduction -- per-rep count and years of PTABOA reductions won on the group's parcels, display-only for the detail panel.`),
    IsFreshProspect: z.boolean().describe(`
        * * Field Name: IsFreshProspect
        * * Display Name: Fresh Prospect
        * * SQL Data Type: bit
        * * Default Value: 0
        * * Description: BIT: Company AND no rep on record AND EstSavingsAtAsk > 0 -- the cold-prospect flag the dashboard highlights.`),
    MailAddress: z.string().nullable().describe(`
        * * Field Name: MailAddress
        * * Display Name: Mailing Address
        * * SQL Data Type: nvarchar(400)
        * * Description: The mailing address shared by the group's parcels (owner.mailAddress) -- the fallback grouping signal and a contact hint.`),
    ByTypeJSON: z.string().nullable().describe(`
        * * Field Name: ByTypeJSON
        * * Display Name: Breakdown by Property Type
        * * SQL Data Type: nvarchar(MAX)
        * * Description: JSON.stringify of owner.byType -- per-property-type parcel count and AV within the group, display-only for the detail-panel breakdown.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Run: z.string().describe(`
        * * Field Name: Run
        * * Display Name: Run
        * * SQL Data Type: nvarchar(60)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Mj Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Mj Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxOwnerPortfolioEntityType = z.infer<typeof indianataxOwnerPortfolioSchema>;

/**
 * zod schema definition for the entity Parcels
 */
export const indianataxParcelSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    CountyNumber: z.number().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: Indiana county number (1-92) per the DLGF/GIO statewide numbering.`),
    ParcelNumber: z.string().describe(`
        * * Field Name: ParcelNumber
        * * Display Name: Parcel Number
        * * SQL Data Type: nvarchar(30)
        * * Description: The statewide 17-digit PARCEL_NUMBER from the DLGF/GIO Data Harvest geodatabase. Canonical identifier for the parcel.`),
    GISParcelNumber: z.string().nullable().describe(`
        * * Field Name: GISParcelNumber
        * * Display Name: GIS Parcel Number
        * * SQL Data Type: nvarchar(30)
        * * Description: The county's own local parcel number (e.g. Marion County's 7-digit number). Different counties use different local schemes; this is the crosswalk between a county-sourced file and the statewide ParcelNumber.`),
    Address: z.string().nullable().describe(`
        * * Field Name: Address
        * * Display Name: Address
        * * SQL Data Type: nvarchar(300)
        * * Description: Site/property address.`),
    OwnerName: z.string().nullable().describe(`
        * * Field Name: OwnerName
        * * Display Name: Owner Name
        * * SQL Data Type: nvarchar(300)
        * * Description: Owner of record name, as of the characteristics source year.`),
    Acreage: z.number().nullable().describe(`
        * * Field Name: Acreage
        * * Display Name: Acreage
        * * SQL Data Type: decimal(12, 4)
        * * Description: Parcel acreage.`),
    Zoning: z.string().nullable().describe(`
        * * Field Name: Zoning
        * * Display Name: Zoning
        * * SQL Data Type: nvarchar(50)
        * * Description: Zoning designation, as recorded by the county.`),
    PropertyClassCode: z.string().nullable().describe(`
        * * Field Name: PropertyClassCode
        * * Display Name: Property Class Code
        * * SQL Data Type: nvarchar(10)
        * * Description: Most recently known DLGF property class code (e.g. 300-499 for commercial/industrial). A given assessment year may record a different class code on its own Assessment row.`),
    CharacteristicsSourceYear: z.number().nullable().describe(`
        * * Field Name: CharacteristicsSourceYear
        * * Display Name: Characteristics Source Year
        * * SQL Data Type: smallint
        * * Description: Which DLGF/source pull (assessment year) produced the characteristics currently stored on this row. Characteristics are overwritten on a later pull, not versioned.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Latitude: z.number().nullable().describe(`
        * * Field Name: Latitude
        * * Display Name: Latitude
        * * SQL Data Type: float(53)
        * * Description: Parcel centroid latitude (WGS84), from the IndianaMap parcel boundaries Feature Service.`),
    Longitude: z.number().nullable().describe(`
        * * Field Name: Longitude
        * * Display Name: Longitude
        * * SQL Data Type: float(53)
        * * Description: Parcel centroid longitude (WGS84), from the IndianaMap parcel boundaries Feature Service.`),
    CountyFIPS: z.string().nullable().describe(`
        * * Field Name: CountyFIPS
        * * Display Name: County FIPS Code
        * * SQL Data Type: nvarchar(10)
        * * Description: County FIPS code, from the IndianaMap Feature Service's county_fips field — a verifiable county identifier, distinct from CountyNumber (the DLGF/GIO statewide numbering used elsewhere in this schema).`),
    BoundaryGeoJSON: z.string().nullable().describe(`
        * * Field Name: BoundaryGeoJSON
        * * Display Name: Boundary GeoJSON
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Parcel boundary polygon as GeoJSON geometry (WGS84), from the IndianaMap Feature Service. NULL until fetched; not every parcel in our set necessarily resolves (a parcel here may not exist in that dataset, or vice versa).`),
    GeometryRetrievedAt: z.date().nullable().describe(`
        * * Field Name: GeometryRetrievedAt
        * * Display Name: Geometry Retrieved At
        * * SQL Data Type: datetimeoffset
        * * Description: When the geometry/location fields on this row were last fetched from the source Feature Service.`),
    TaxDistrictCode: z.string().nullable().describe(`
        * * Field Name: TaxDistrictCode
        * * Display Name: Tax District Code
        * * SQL Data Type: nvarchar(200)
        * * Description: The county's own tax district code for this parcel (source field: cnty_tax_dist_cd) — identifies the specific combination of overlapping taxing units (township + school + library + special districts) that applies.`),
    TaxTownship: z.string().nullable().describe(`
        * * Field Name: TaxTownship
        * * Display Name: Tax Township
        * * SQL Data Type: nvarchar(50)
        * * Description: Civil township this parcel is taxed under.`),
    TaxSchoolCorp: z.string().nullable().describe(`
        * * Field Name: TaxSchoolCorp
        * * Display Name: Tax School Corporation
        * * SQL Data Type: nvarchar(100)
        * * Description: School corporation this parcel is taxed under.`),
    TaxLibraryDistrict: z.string().nullable().describe(`
        * * Field Name: TaxLibraryDistrict
        * * Display Name: Tax Library District
        * * SQL Data Type: nvarchar(50)
        * * Description: Library taxing district this parcel falls in, if any.`),
    TaxSpecialDistrict: z.string().nullable().describe(`
        * * Field Name: TaxSpecialDistrict
        * * Display Name: Tax Special District
        * * SQL Data Type: nvarchar(360)
        * * Description: Special taxing district(s) this parcel falls in (e.g. solid waste management), if any. Can be a combined/concatenated value per the source.`),
    TaxCity: z.string().nullable().describe(`
        * * Field Name: TaxCity
        * * Display Name: Tax City
        * * SQL Data Type: nvarchar(70)
        * * Description: City/municipal taxing unit this parcel falls in, if any (NULL for unincorporated areas).`),
    ShapeAreaDecimalDegrees: z.number().nullable().describe(`
        * * Field Name: ShapeAreaDecimalDegrees
        * * Display Name: Shape Area (Decimal Degrees)
        * * SQL Data Type: float(53)
        * * Description: Parcel boundary area in decimal degrees squared (source: SHAPE__Area, confirmed unit esriDecimalDegrees) — NOT a real-world area (not square feet/meters/acres). Only useful as a cheap relative sanity-check against Acreage; a proper acreage figure would need a geodesic area calculation this field does not provide.`),
    SourceLoadDate: z.date().nullable().describe(`
        * * Field Name: SourceLoadDate
        * * Display Name: Source Load Date
        * * SQL Data Type: date
        * * Description: The date the SOURCE (IndianaMap/IGIO Feature Service) last updated this record — distinct from GeometryRetrievedAt, which is when WE fetched it.`),
    GeometrySourceRegistryID: z.string().nullable().describe(`
        * * Field Name: GeometrySourceRegistryID
        * * Display Name: Geometry Source Registry ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
        * * Description: The SourceRegistry entry for the Feature Service this parcel's geometry/location/taxing-district fields came from.`),
    GeometrySourceRegistry: z.string().nullable().describe(`
        * * Field Name: GeometrySourceRegistry
        * * Display Name: Geometry Source Registry
        * * SQL Data Type: nvarchar(200)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Mj Latitude
        * * SQL Data Type: float(53)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Mj Longitude
        * * SQL Data Type: float(53)`),
});

export type indianataxParcelEntityType = z.infer<typeof indianataxParcelSchema>;

/**
 * zod schema definition for the entity Property Class Maps
 */
export const indianataxPropertyClassMapSchema = z.object({
    Code: z.string().describe(`
        * * Field Name: Code
        * * Display Name: DLGF Code
        * * SQL Data Type: char(3)
        * * Description: The 3-digit DLGF real-property class code (e.g. "449").`),
    Label: z.string().describe(`
        * * Field Name: Label
        * * Display Name: DLGF Label
        * * SQL Data Type: nvarchar(120)
        * * Description: The DLGF label for the code (from Marion's PropertySubClassDescription).`),
    TypeGroup: z.union([z.literal('Hospitality'), z.literal('Industrial'), z.literal('Land'), z.literal('Multifamily'), z.literal('Office'), z.literal('Other'), z.literal('Parking'), z.literal('Retail'), z.literal('Special')]).describe(`
        * * Field Name: TypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
        * * Description: Coarse group: Retail / Office / Industrial / Multifamily / Hospitality / Land / Special / Parking / Other.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Classification Notes
        * * SQL Data Type: nvarchar(400)
        * * Description: Rationale / borderline-call note for this mapping.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxPropertyClassMapEntityType = z.infer<typeof indianataxPropertyClassMapSchema>;

/**
 * zod schema definition for the entity Prospect Activities
 */
export const indianataxProspectActivitySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ProspectID: z.string().describe(`
        * * Field Name: ProspectID
        * * Display Name: Prospect
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospects (vwProspects.ID)`),
    ContactID: z.string().nullable().describe(`
        * * Field Name: ContactID
        * * Display Name: Contact
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospect Contacts (vwProspectContacts.ID)`),
    ActivityDate: z.date().describe(`
        * * Field Name: ActivityDate
        * * Display Name: Activity Date
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()`),
    ActivityType: z.union([z.literal('Call'), z.literal('ConflictCheck'), z.literal('Email'), z.literal('Meeting'), z.literal('Note'), z.literal('ProposalSent'), z.literal('RFP'), z.literal('Referral'), z.literal('StageChange')]).describe(`
        * * Field Name: ActivityType
        * * Display Name: Activity Type
        * * SQL Data Type: nvarchar(40)
    * * Value List Type: List
    * * Possible Values 
    *   * Call
    *   * ConflictCheck
    *   * Email
    *   * Meeting
    *   * Note
    *   * ProposalSent
    *   * RFP
    *   * Referral
    *   * StageChange`),
    Direction: z.union([z.literal('Inbound'), z.literal('Internal'), z.literal('Outbound')]).nullable().describe(`
        * * Field Name: Direction
        * * Display Name: Direction
        * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * Inbound
    *   * Internal
    *   * Outbound`),
    Summary: z.string().describe(`
        * * Field Name: Summary
        * * Display Name: Summary
        * * SQL Data Type: nvarchar(2000)`),
    Outcome: z.string().nullable().describe(`
        * * Field Name: Outcome
        * * Display Name: Outcome
        * * SQL Data Type: nvarchar(1000)`),
    LoggedBy: z.string().nullable().describe(`
        * * Field Name: LoggedBy
        * * Display Name: Logged By
        * * SQL Data Type: nvarchar(200)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Prospect: z.string().describe(`
        * * Field Name: Prospect
        * * Display Name: Prospect
        * * SQL Data Type: nvarchar(300)`),
    Contact: z.string().nullable().describe(`
        * * Field Name: Contact
        * * Display Name: Contact Name
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxProspectActivityEntityType = z.infer<typeof indianataxProspectActivitySchema>;

/**
 * zod schema definition for the entity Prospect Contacts
 */
export const indianataxProspectContactSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ProspectID: z.string().describe(`
        * * Field Name: ProspectID
        * * Display Name: Prospect
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospects (vwProspects.ID)`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(200)`),
    Title: z.string().nullable().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(200)`),
    Role: z.union([z.literal('AssetManager'), z.literal('CFO'), z.literal('GeneralCounsel'), z.literal('Other'), z.literal('OutsideRep'), z.literal('Principal')]).nullable().describe(`
        * * Field Name: Role
        * * Display Name: Role
        * * SQL Data Type: nvarchar(60)
    * * Value List Type: List
    * * Possible Values 
    *   * AssetManager
    *   * CFO
    *   * GeneralCounsel
    *   * Other
    *   * OutsideRep
    *   * Principal`),
    Email: z.string().nullable().describe(`
        * * Field Name: Email
        * * Display Name: Email
        * * SQL Data Type: nvarchar(200)`),
    Phone: z.string().nullable().describe(`
        * * Field Name: Phone
        * * Display Name: Phone
        * * SQL Data Type: nvarchar(50)`),
    LinkedInURL: z.string().nullable().describe(`
        * * Field Name: LinkedInURL
        * * Display Name: LinkedIn URL
        * * SQL Data Type: nvarchar(400)`),
    SourceNote: z.string().nullable().describe(`
        * * Field Name: SourceNote
        * * Display Name: Source Note
        * * SQL Data Type: nvarchar(500)`),
    KnownToFirm: z.boolean().describe(`
        * * Field Name: KnownToFirm
        * * Display Name: Known to Firm
        * * SQL Data Type: bit
        * * Default Value: 0`),
    FirmContactNote: z.string().nullable().describe(`
        * * Field Name: FirmContactNote
        * * Display Name: Firm Contact Note
        * * SQL Data Type: nvarchar(500)`),
    IsPrimary: z.boolean().describe(`
        * * Field Name: IsPrimary
        * * Display Name: Primary Contact
        * * SQL Data Type: bit
        * * Default Value: 0`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Prospect: z.string().describe(`
        * * Field Name: Prospect
        * * Display Name: Prospect Name
        * * SQL Data Type: nvarchar(300)`),
});

export type indianataxProspectContactEntityType = z.infer<typeof indianataxProspectContactSchema>;

/**
 * zod schema definition for the entity Prospect Parcels
 */
export const indianataxProspectParcelSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ProspectID: z.string().describe(`
        * * Field Name: ProspectID
        * * Display Name: Prospect
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospects (vwProspects.ID)`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)`),
    Disposition: z.union([z.literal('AlreadyRepresented'), z.literal('Excluded'), z.literal('InScope'), z.literal('Monitoring')]).describe(`
        * * Field Name: Disposition
        * * Display Name: Disposition
        * * SQL Data Type: nvarchar(40)
        * * Default Value: InScope
    * * Value List Type: List
    * * Possible Values 
    *   * AlreadyRepresented
    *   * Excluded
    *   * InScope
    *   * Monitoring
        * * Description: InScope | AlreadyRepresented | Excluded | Monitoring.`),
    DispositionNote: z.string().nullable().describe(`
        * * Field Name: DispositionNote
        * * Display Name: Disposition Note
        * * SQL Data Type: nvarchar(500)`),
    IsTrigger: z.boolean().describe(`
        * * Field Name: IsTrigger
        * * Display Name: Is Trigger
        * * SQL Data Type: bit
        * * Default Value: 0`),
    ExistingRep: z.string().nullable().describe(`
        * * Field Name: ExistingRep
        * * Display Name: Existing Rep
        * * SQL Data Type: nvarchar(200)`),
    SnapshotAV: z.number().nullable().describe(`
        * * Field Name: SnapshotAV
        * * Display Name: Snapshot AV
        * * SQL Data Type: decimal(18, 2)`),
    SnapshotOpportunityAtAsk: z.number().nullable().describe(`
        * * Field Name: SnapshotOpportunityAtAsk
        * * Display Name: Snapshot Opportunity At Ask
        * * SQL Data Type: decimal(18, 2)`),
    SnapshotOpportunityAtFloor: z.number().nullable().describe(`
        * * Field Name: SnapshotOpportunityAtFloor
        * * Display Name: Snapshot Opportunity At Floor
        * * SQL Data Type: decimal(18, 2)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Prospect: z.string().describe(`
        * * Field Name: Prospect
        * * Display Name: Prospect Name
        * * SQL Data Type: nvarchar(300)`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel Identifier
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxProspectParcelEntityType = z.infer<typeof indianataxProspectParcelSchema>;

/**
 * zod schema definition for the entity Prospect Snapshots
 */
export const indianataxProspectSnapshotSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ProspectID: z.string().describe(`
        * * Field Name: ProspectID
        * * Display Name: Prospect
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospects (vwProspects.ID)`),
    SnapshotDate: z.date().describe(`
        * * Field Name: SnapshotDate
        * * Display Name: Snapshot Date
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()`),
    PortfolioRunTag: z.string().nullable().describe(`
        * * Field Name: PortfolioRunTag
        * * Display Name: Portfolio Run Tag
        * * SQL Data Type: nvarchar(60)`),
    ParcelCount: z.number().nullable().describe(`
        * * Field Name: ParcelCount
        * * Display Name: Parcel Count
        * * SQL Data Type: int`),
    TotalAV: z.number().nullable().describe(`
        * * Field Name: TotalAV
        * * Display Name: Total Assessed Value
        * * SQL Data Type: decimal(18, 2)`),
    TotalTaxLiability: z.number().nullable().describe(`
        * * Field Name: TotalTaxLiability
        * * Display Name: Total Tax Liability
        * * SQL Data Type: decimal(18, 2)`),
    OpportunityAtAsk: z.number().nullable().describe(`
        * * Field Name: OpportunityAtAsk
        * * Display Name: Opportunity at Ask
        * * SQL Data Type: decimal(18, 2)`),
    OpportunityAtFloor: z.number().nullable().describe(`
        * * Field Name: OpportunityAtFloor
        * * Display Name: Opportunity at Floor
        * * SQL Data Type: decimal(18, 2)`),
    RepdParcelCount: z.number().nullable().describe(`
        * * Field Name: RepdParcelCount
        * * Display Name: Represented Parcel Count
        * * SQL Data Type: int`),
    FreshParcelCount: z.number().nullable().describe(`
        * * Field Name: FreshParcelCount
        * * Display Name: Fresh Parcel Count
        * * SQL Data Type: int`),
    AVYoYPct: z.number().nullable().describe(`
        * * Field Name: AVYoYPct
        * * Display Name: AV Year-over-Year %
        * * SQL Data Type: decimal(9, 4)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Prospect: z.string().describe(`
        * * Field Name: Prospect
        * * Display Name: Prospect Name
        * * SQL Data Type: nvarchar(300)`),
});

export type indianataxProspectSnapshotEntityType = z.infer<typeof indianataxProspectSnapshotSchema>;

/**
 * zod schema definition for the entity Prospect Tasks
 */
export const indianataxProspectTaskSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ProspectID: z.string().describe(`
        * * Field Name: ProspectID
        * * Display Name: Prospect
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospects (vwProspects.ID)`),
    SourceActivityID: z.string().nullable().describe(`
        * * Field Name: SourceActivityID
        * * Display Name: Source Activity
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Prospect Activities (vwProspectActivities.ID)`),
    Title: z.string().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(400)`),
    DueDate: z.date().nullable().describe(`
        * * Field Name: DueDate
        * * Display Name: Due Date
        * * SQL Data Type: date`),
    Assignee: z.string().nullable().describe(`
        * * Field Name: Assignee
        * * Display Name: Assignee
        * * SQL Data Type: nvarchar(200)`),
    Status: z.union([z.literal('Cancelled'), z.literal('Done'), z.literal('InProgress'), z.literal('Open')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Cancelled
    *   * Done
    *   * InProgress
    *   * Open`),
    CompletedDate: z.date().nullable().describe(`
        * * Field Name: CompletedDate
        * * Display Name: Completed Date
        * * SQL Data Type: date`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(1000)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Prospect: z.string().describe(`
        * * Field Name: Prospect
        * * Display Name: Prospect Name
        * * SQL Data Type: nvarchar(300)`),
    SourceActivity: z.string().nullable().describe(`
        * * Field Name: SourceActivity
        * * Display Name: Source Activity Name
        * * SQL Data Type: nvarchar(40)`),
});

export type indianataxProspectTaskEntityType = z.infer<typeof indianataxProspectTaskSchema>;

/**
 * zod schema definition for the entity Prospects
 */
export const indianataxProspectSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    OwnerKey: z.string().describe(`
        * * Field Name: OwnerKey
        * * Display Name: Owner Key
        * * SQL Data Type: nvarchar(200)
        * * Description: Stable join key = normalized ParcelOwnerResolved.CoStarTrueOwner (fallback: MailKey + normalized RawOwnerName). This -- not a regenerated row id -- is what re-links a prospect to the portfolio screen across re-runs. Unique.`),
    DisplayName: z.string().describe(`
        * * Field Name: DisplayName
        * * Display Name: Display Name
        * * SQL Data Type: nvarchar(300)`),
    RelationshipType: z.union([z.literal('Cold'), z.literal('CompetitorRepped'), z.literal('ExistingClientExpand'), z.literal('FormerClient'), z.literal('Unknown')]).describe(`
        * * Field Name: RelationshipType
        * * Display Name: Relationship Type
        * * SQL Data Type: nvarchar(30)
        * * Default Value: Unknown
    * * Value List Type: List
    * * Possible Values 
    *   * Cold
    *   * CompetitorRepped
    *   * ExistingClientExpand
    *   * FormerClient
    *   * Unknown
        * * Description: Cold | ExistingClientExpand | CompetitorRepped | FormerClient | Unknown. The routing signal: ExistingClientExpand (e.g. Keystone, Square Deal show "Represented by FAEGRE DRINKER" in the screen) goes to the relationship partner as cross-sell, not cold outreach.`),
    Stage: z.union([z.literal('Active'), z.literal('ClosedLost'), z.literal('Contacted'), z.literal('Dormant'), z.literal('Engaged'), z.literal('Identified'), z.literal('Pitched'), z.literal('Qualified'), z.literal('Retained')]).describe(`
        * * Field Name: Stage
        * * Display Name: Stage
        * * SQL Data Type: nvarchar(30)
        * * Default Value: Identified
    * * Value List Type: List
    * * Possible Values 
    *   * Active
    *   * ClosedLost
    *   * Contacted
    *   * Dormant
    *   * Engaged
    *   * Identified
    *   * Pitched
    *   * Qualified
    *   * Retained
        * * Description: Pipeline stage. May not advance past Qualified until ConflictCheckStatus is Cleared or Waived.`),
    StageEnteredDate: z.date().nullable().describe(`
        * * Field Name: StageEnteredDate
        * * Display Name: Stage Entered Date
        * * SQL Data Type: date`),
    Priority: z.union([z.literal('High'), z.literal('Low'), z.literal('Medium')]).describe(`
        * * Field Name: Priority
        * * Display Name: Priority
        * * SQL Data Type: nvarchar(10)
        * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * High
    *   * Low
    *   * Medium`),
    AssignedTo: z.string().nullable().describe(`
        * * Field Name: AssignedTo
        * * Display Name: Assigned To
        * * SQL Data Type: nvarchar(200)`),
    IdentifiedDate: z.date().nullable().describe(`
        * * Field Name: IdentifiedDate
        * * Display Name: Identified Date
        * * SQL Data Type: date`),
    IdentificationSource: z.string().nullable().describe(`
        * * Field Name: IdentificationSource
        * * Display Name: Identification Source
        * * SQL Data Type: nvarchar(120)`),
    NextActionDate: z.date().nullable().describe(`
        * * Field Name: NextActionDate
        * * Display Name: Next Action Date
        * * SQL Data Type: date`),
    ConflictCheckStatus: z.union([z.literal('Blocked'), z.literal('Cleared'), z.literal('NotStarted'), z.literal('Requested'), z.literal('Waived')]).describe(`
        * * Field Name: ConflictCheckStatus
        * * Display Name: Conflict Check Status
        * * SQL Data Type: nvarchar(30)
        * * Default Value: NotStarted
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cleared
    *   * NotStarted
    *   * Requested
    *   * Waived`),
    ConflictCheckNote: z.string().nullable().describe(`
        * * Field Name: ConflictCheckNote
        * * Display Name: Conflict Check Note
        * * SQL Data Type: nvarchar(1000)`),
    Thesis: z.string().nullable().describe(`
        * * Field Name: Thesis
        * * Display Name: Thesis
        * * SQL Data Type: nvarchar(2000)
        * * Description: Free text -- the reason this target was flagged, e.g. "bought the Sheraton (1097651) below the 2026 AV; 9 Marion parcels, $135M AV".`),
    EstimatedOpportunityAtAsk: z.number().nullable().describe(`
        * * Field Name: EstimatedOpportunityAtAsk
        * * Display Name: Estimated Opportunity at Ask
        * * SQL Data Type: decimal(18, 2)
        * * Description: Convenience copy of the most recent ProspectSnapshot.OpportunityAtAsk, maintained by scripts/sync-prospect-snapshots.js, so the pipeline can be sorted by dollars without a join.`),
    Status: z.union([z.literal('Dormant'), z.literal('Lost'), z.literal('Open'), z.literal('Won')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Dormant
    *   * Lost
    *   * Open
    *   * Won`),
    ClosedDate: z.date().nullable().describe(`
        * * Field Name: ClosedDate
        * * Display Name: Closed Date
        * * SQL Data Type: date`),
    ClosedReason: z.string().nullable().describe(`
        * * Field Name: ClosedReason
        * * Display Name: Closed Reason
        * * SQL Data Type: nvarchar(500)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxProspectEntityType = z.infer<typeof indianataxProspectSchema>;

/**
 * zod schema definition for the entity PTABOA Appeals
 */
export const indianataxPTABOAAppealSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel under appeal.`),
    AssessmentYear: z.number().nullable().describe(`
        * * Field Name: AssessmentYear
        * * Display Name: Assessment Year
        * * SQL Data Type: smallint
        * * Description: The assessment year being appealed.`),
    HearingDate: z.date().nullable().describe(`
        * * Field Name: HearingDate
        * * Display Name: Hearing Date
        * * SQL Data Type: date
        * * Description: Date of the PTABOA hearing, per the agenda.`),
    DecisionStatus: z.string().nullable().describe(`
        * * Field Name: DecisionStatus
        * * Display Name: Decision Status
        * * SQL Data Type: nvarchar(50)
        * * Description: Outcome of the appeal (e.g. Pending, Reduced, Withdrawn, Denied), as best determined from the agenda/decision text.`),
    Circumstances: z.string().nullable().describe(`
        * * Field Name: Circumstances
        * * Display Name: Circumstances
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text circumstances/notes about the appeal, extracted from the agenda.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The PTABOA agenda document this appeal was extracted from.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    CaseNumber: z.string().nullable().describe(`
        * * Field Name: CaseNumber
        * * Display Name: Case Number
        * * SQL Data Type: nvarchar(50)
        * * Description: The PTABOA case number for this appeal/exemption record (e.g. "49-500-23-0-4-00045"), as printed on the agenda. Confirmed unique per source agenda PDF -- the natural key this table lacked before this migration.`),
    TaxRepresentative: z.string().nullable().describe(`
        * * Field Name: TaxRepresentative
        * * Display Name: Tax Representative
        * * SQL Data Type: nvarchar(200)
        * * Description: Who represented the taxpayer in this matter -- a law firm, tax-advocate firm, or individual name, exactly as printed on the PTABOA agenda (e.g. "LANDMAN BEATTY, LAWYERS Attn: KATHRYN M. MERRITT-THRASHER", "JM Tax Advocates Attn: Joshua J. Malancuk"). NULL means no representative is listed on the agenda for this record -- most commonly a self-represented petitioner, not a parsing gap (confirmed 2026-08-26: ~60% of records across the currently-loaded 2024-12 through 2025-12 agendas have one).`),
    BeforeLandAV: z.number().nullable().describe(`
        * * Field Name: BeforeLandAV
        * * Display Name: Before Land Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Land assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.`),
    BeforeImprovementAV: z.number().nullable().describe(`
        * * Field Name: BeforeImprovementAV
        * * Display Name: Before Improvement Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Improvement assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.`),
    BeforeTotalAV: z.number().nullable().describe(`
        * * Field Name: BeforeTotalAV
        * * Display Name: Before Total Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total assessed value (Land + Improvement) BEFORE this appeal/exemption was decided.`),
    AfterLandAV: z.number().nullable().describe(`
        * * Field Name: AfterLandAV
        * * Display Name: After Land Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Land assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeLandAV when the appeal produced no land-value change.`),
    AfterImprovementAV: z.number().nullable().describe(`
        * * Field Name: AfterImprovementAV
        * * Display Name: After Improvement Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Improvement assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeImprovementAV when the appeal produced no improvement-value change.`),
    AfterTotalAV: z.number().nullable().describe(`
        * * Field Name: AfterTotalAV
        * * Display Name: After Total Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total assessed value (Land + Improvement) AFTER this appeal/exemption was decided. AfterTotalAV - BeforeTotalAV is this appeal's AV change (negative = a reduction) -- computed at query/display time rather than stored, to avoid drift.`),
    RecordKind: z.string().nullable().describe(`
        * * Field Name: RecordKind
        * * Display Name: Record Kind
        * * SQL Data Type: nvarchar(20)
        * * Description: Whether this record is a valuation Appeal or an Exemption request, per the agenda page's own "For Appeal/Exemption <form> Year: <year>" header. NOT the same question as DecisionStatus (which appeal/exemption records can both carry, e.g. "Exemption-Approved" vs "Final Agreement") -- this is the request TYPE, DecisionStatus is the outcome.`),
    AppealType: z.string().nullable().describe(`
        * * Field Name: AppealType
        * * Display Name: Appeal Type
        * * SQL Data Type: nvarchar(20)
        * * Description: The Indiana form number this record was filed under, e.g. "130S" (subjective/market-value valuation appeal -- the most directly informative type for sub-class assessed-value analytics), "130O" (objective/mathematical-error valuation appeal), "136" or "136C" (charitable/nonprofit exemption request -- NOT a valuation dispute; exclude from win-rate/avg-reduction rollups meant to describe assessed-value accuracy).`),
    FinalDeterminationSourceDocumentID: z.string().nullable().describe(`
        * * Field Name: FinalDeterminationSourceDocumentID
        * * Display Name: Final Determination Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument row for the monthly Final Determination batch PDF that confirmed this appeal's outcome, matched by (parcel, assessment year) against a real Form 115 within that batch. NULL means this appeal's agenda-reported outcome has NOT yet been confirmed by an actual Final Determination -- do not treat DecisionStatus/AfterTotalAV as final while this is NULL; see the migration header for a real example of an agenda "Final Agreement" label that turned out to be premature.`),
    FinalDeterminationLandAV: z.number().nullable().describe(`
        * * Field Name: FinalDeterminationLandAV
        * * Display Name: Final Determination Land Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Land assessed value from the actual ratified Form 115 (SECTION III: FINAL DETERMINATION), once confirmed. Compare against BeforeLandAV (the agenda's own before-figure) -- do NOT assume this always equals AfterLandAV; the rare case where it differs is exactly the discrepancy this column exists to catch.`),
    FinalDeterminationImprovementAV: z.number().nullable().describe(`
        * * Field Name: FinalDeterminationImprovementAV
        * * Display Name: Final Determination Improvement Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Improvement assessed value from the actual ratified Form 115, once confirmed. See FinalDeterminationLandAV's comment.`),
    FinalDeterminationTotalAV: z.number().nullable().describe(`
        * * Field Name: FinalDeterminationTotalAV
        * * Display Name: Final Determination Total Assessment Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Total assessed value (Land + Improvement) from the actual ratified Form 115, once confirmed. Compare against AfterTotalAV (the agenda's own prediction) -- a mismatch here is a genuine "the board changed what the parties proposed" case, the specific scenario this table's Final Determination columns exist to catch. NULL (unconfirmed) is expected for most recent appeals -- Final Determination batches lag the agenda by weeks to months.`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxPTABOAAppealEntityType = z.infer<typeof indianataxPTABOAAppealSchema>;

/**
 * zod schema definition for the entity Research Tasks
 */
export const indianataxResearchTaskSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Title: z.string().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(200)
        * * Description: Short name for the task.`),
    Description: z.string().describe(`
        * * Field Name: Description
        * * Display Name: Description
        * * SQL Data Type: nvarchar(MAX)
        * * Description: What this task is — what was found, what it would take to pursue it.`),
    Status: z.union([z.literal('Abandoned'), z.literal('Completed'), z.literal('Deferred'), z.literal('InProgress'), z.literal('Open')]).describe(`
        * * Field Name: Status
        * * Display Name: Status
        * * SQL Data Type: nvarchar(20)
        * * Default Value: Deferred
    * * Value List Type: List
    * * Possible Values 
    *   * Abandoned
    *   * Completed
    *   * Deferred
    *   * InProgress
    *   * Open
        * * Description: Open (identified, not yet evaluated further) / Deferred (evaluated, deliberately held) / InProgress / Completed / Abandoned (evaluated and decided not worth pursuing at all, distinct from Deferred).`),
    DeferralReason: z.string().nullable().describe(`
        * * Field Name: DeferralReason
        * * Display Name: Deferral Reason
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Why this is being held rather than pursued now — e.g. scale, needs a scope decision, needs tooling not yet built, needs a source spec not yet found.`),
    RelatedSourceRegistryID: z.string().nullable().describe(`
        * * Field Name: RelatedSourceRegistryID
        * * Display Name: Related Source Registry
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
        * * Description: The SourceRegistry entry this task concerns, if any.`),
    RelatedSourceDocumentID: z.string().nullable().describe(`
        * * Field Name: RelatedSourceDocumentID
        * * Display Name: Related Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument this task concerns, if any (e.g. a spec document that unblocks the task once found).`),
    RaisedAt: z.date().describe(`
        * * Field Name: RaisedAt
        * * Display Name: Raised At
        * * SQL Data Type: datetimeoffset
        * * Default Value: sysdatetimeoffset()
        * * Description: When this task was first identified.`),
    RevisitAt: z.date().nullable().describe(`
        * * Field Name: RevisitAt
        * * Display Name: Revisit At
        * * SQL Data Type: date
        * * Description: A natural date to reconsider this task, if there is one (e.g. a next annual data cycle). NULL means "revisit whenever it becomes a priority," not "no need to revisit."`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text running notes — updated as understanding of the task evolves.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    RelatedSourceRegistry: z.string().nullable().describe(`
        * * Field Name: RelatedSourceRegistry
        * * Display Name: Related Source Registry
        * * SQL Data Type: nvarchar(200)`),
});

export type indianataxResearchTaskEntityType = z.infer<typeof indianataxResearchTaskSchema>;

/**
 * zod schema definition for the entity Sale Transactions
 */
export const indianataxSaleTransactionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Source: z.union([z.literal('CoStar'), z.literal('Manual'), z.literal('MarionPRC'), z.literal('Recorder'), z.literal('SalesDisclosure')]).describe(`
        * * Field Name: Source
        * * Display Name: Source
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * CoStar
    *   * Manual
    *   * MarionPRC
    *   * Recorder
    *   * SalesDisclosure
        * * Description: Where this observation came from: MarionPRC (the PRC "Transfer of Ownership" section, via CountyAssessorSaleHistory), CoStar, SalesDisclosure, Recorder, or Manual.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument this sale was read from (e.g. the parcel's PRC). NULL for a manually-entered comp.`),
    ParcelID: z.string().nullable().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The Parcel that transacted, when it is one of the project's parcels. NULL for an off-portfolio comp (address/attributes still recorded).`),
    CountyNumber: z.number().nullable().describe(`
        * * Field Name: CountyNumber
        * * Display Name: County Number
        * * SQL Data Type: smallint
        * * Description: Indiana county number of the property that sold.`),
    SitusAddress: z.string().nullable().describe(`
        * * Field Name: SitusAddress
        * * Display Name: Situs Address
        * * SQL Data Type: nvarchar(200)
        * * Description: Street address of the property that sold, as recorded at load time.`),
    City: z.string().nullable().describe(`
        * * Field Name: City
        * * Display Name: City
        * * SQL Data Type: nvarchar(80)
        * * Description: City of the property that sold.`),
    Submarket: z.string().nullable().describe(`
        * * Field Name: Submarket
        * * Display Name: Submarket
        * * SQL Data Type: nvarchar(80)
        * * Description: Submarket label (from CoStar where available) -- used to group/adjust comps by location.`),
    PropertyClassCode: z.string().nullable().describe(`
        * * Field Name: PropertyClassCode
        * * Display Name: Property Class Code
        * * SQL Data Type: nvarchar(10)
        * * Description: The assessor property class code as of load (e.g. "447", "350", "400") -- the primary comp-grouping key.`),
    PropertyTypeGroup: z.union([z.literal('Hospitality'), z.literal('Industrial'), z.literal('Land'), z.literal('Multifamily'), z.literal('Office'), z.literal('Other'), z.literal('Parking'), z.literal('Retail'), z.literal('Special')]).nullable().describe(`
        * * Field Name: PropertyTypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
        * * Description: Rolled-up category derived from PropertyClassCode: Retail, Office, Industrial, Multifamily, Land, Special, or Other. Coarser grouping for comp selection when the exact class pool is thin.`),
    SaleDate: z.date().describe(`
        * * Field Name: SaleDate
        * * Display Name: Sale Date
        * * SQL Data Type: date
        * * Description: Date of the sale.`),
    SalePrice: z.number().describe(`
        * * Field Name: SalePrice
        * * Display Name: Sale Price
        * * SQL Data Type: decimal(14, 2)
        * * Description: Recorded sale price.`),
    Grantor: z.string().nullable().describe(`
        * * Field Name: Grantor
        * * Display Name: Grantor
        * * SQL Data Type: nvarchar(200)
        * * Description: Seller. The PRC transfer section records the grantor only.`),
    Grantee: z.string().nullable().describe(`
        * * Field Name: Grantee
        * * Display Name: Grantee
        * * SQL Data Type: nvarchar(200)
        * * Description: Buyer, when available (CoStar / recorder). NULL from PRC transfer data.`),
    DeedOrSaleType: z.string().nullable().describe(`
        * * Field Name: DeedOrSaleType
        * * Display Name: Deed or Sale Type
        * * SQL Data Type: nvarchar(30)
        * * Description: The county's sale-type label ("Straight" / "Sale" / "Split" in Marion) or deed type (warranty / quitclaim ...).`),
    CountyValidForTrending: z.boolean().nullable().describe(`
        * * Field Name: CountyValidForTrending
        * * Display Name: County Valid for Trending
        * * SQL Data Type: bit
        * * Description: The county's own valid/invalid designation for this sale, recorded VERBATIM as metadata. It reflects the county's ratio-study / trending methodology (DLGF rules), NOT whether the sale is a good comparable for a subjective valuation argument -- many county-"invalid" sales are legitimate market evidence. DO NOT gate comp selection on this column.`),
    CountyValidityNote: z.string().nullable().describe(`
        * * Field Name: CountyValidityNote
        * * Display Name: County Validity Note
        * * SQL Data Type: nvarchar(200)
        * * Description: Any note the county attached to its validity determination.`),
    IsArmsLength: z.boolean().nullable().describe(`
        * * Field Name: IsArmsLength
        * * Display Name: Is Arms Length
        * * SQL Data Type: bit
        * * Description: A separate, analyst-owned judgement about whether this transaction is usable as market evidence for an analysis. Starts NULL (unassessed); set deliberately during comp review with the reasoning in VerificationNote. NOT copied from CountyValidForTrending.`),
    VerificationNote: z.string().nullable().describe(`
        * * Field Name: VerificationNote
        * * Display Name: Verification Note
        * * SQL Data Type: nvarchar(400)
        * * Description: Free text: why this sale was verified in or excluded as market evidence (conditions of sale, related parties, personal property included, portfolio allocation, etc.).`),
    BuildingSqFt: z.number().nullable().describe(`
        * * Field Name: BuildingSqFt
        * * Display Name: Building Sq Ft
        * * SQL Data Type: int
        * * Description: Building area (sq ft) as of load -- from the PRC (SqFtSource = PropertyRecordCard) or CoStar RBA. Stored, not looked up live, so a comp stays reproducible.`),
    UnitCount: z.number().nullable().describe(`
        * * Field Name: UnitCount
        * * Display Name: Unit Count
        * * SQL Data Type: int
        * * Description: Unit count (multifamily) as of load, where known.`),
    Acres: z.number().nullable().describe(`
        * * Field Name: Acres
        * * Display Name: Acres
        * * SQL Data Type: decimal(10, 4)
        * * Description: Land area (acres) as of load.`),
    YearBuilt: z.number().nullable().describe(`
        * * Field Name: YearBuilt
        * * Display Name: Year Built
        * * SQL Data Type: smallint
        * * Description: Year built as of load.`),
    ConditionGrade: z.string().nullable().describe(`
        * * Field Name: ConditionGrade
        * * Display Name: Condition Grade
        * * SQL Data Type: nvarchar(20)
        * * Description: Condition / grade descriptor as of load, where known.`),
    PricePerSqFt: z.number().nullable().describe(`
        * * Field Name: PricePerSqFt
        * * Display Name: Price Per Sq Ft
        * * SQL Data Type: decimal(12, 2)
        * * Description: SalePrice / BuildingSqFt, computed at load. NULL when BuildingSqFt is unknown.`),
    PricePerUnit: z.number().nullable().describe(`
        * * Field Name: PricePerUnit
        * * Display Name: Price Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: SalePrice / UnitCount, computed at load. NULL when UnitCount is unknown.`),
    PricePerAcre: z.number().nullable().describe(`
        * * Field Name: PricePerAcre
        * * Display Name: Price Per Acre
        * * SQL Data Type: decimal(14, 2)
        * * Description: SalePrice / Acres, computed at load. NULL when Acres is unknown.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text notes about this transaction.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    TransactionKind: z.union([z.literal('ActiveListing'), z.literal('ClosedSale'), z.literal('UnderContract')]).describe(`
        * * Field Name: TransactionKind
        * * Display Name: Transaction Kind
        * * SQL Data Type: nvarchar(20)
        * * Default Value: ClosedSale
    * * Value List Type: List
    * * Possible Values 
    *   * ActiveListing
    *   * ClosedSale
    *   * UnderContract
        * * Description: ClosedSale (a completed transaction -- the only kind that should enter comp selection), UnderContract (pending), or ActiveListing (currently for sale; SalePrice is the list/asking price). Listings are retained for lead generation -- a property listed below its assessed value is an appeal signal -- but must be filtered out of any comp analysis.`),
    AssessedValueAtSale: z.number().nullable().describe(`
        * * Field Name: AssessedValueAtSale
        * * Display Name: Assessed Value at Sale
        * * SQL Data Type: decimal(14, 2)
        * * Description: The county assessed (total) value applicable around the transaction date. From the CoStar export directly for CoStar rows; backfilled from indiana_tax.Assessment (nearest AssessmentYear within +/- 2 of the sale year) for PRC-sourced transfers. NULL when no contemporaneous AV is available (older transfers).`),
    AssessedYearAtSale: z.number().nullable().describe(`
        * * Field Name: AssessedYearAtSale
        * * Display Name: Assessed Year at Sale
        * * SQL Data Type: smallint
        * * Description: The assessment year of AssessedValueAtSale.`),
    SaleToAssessedRatio: z.number().nullable().describe(`
        * * Field Name: SaleToAssessedRatio
        * * Display Name: Sale to Assessed Ratio
        * * SQL Data Type: decimal(9, 4)
        * * Description: SalePrice / AssessedValueAtSale, computed at load. Below ~1.0 means the property sold for less than its assessment -- an over-assessment / appeal candidate. Interpret with the sale's IsArmsLength and any allocation/portfolio note: a per-parcel slice price of a portfolio deal against a whole-portfolio AV produces a misleadingly low ratio.`),
    CapRateAtSale: z.number().nullable().describe(`
        * * Field Name: CapRateAtSale
        * * Display Name: Cap Rate at Sale
        * * SQL Data Type: decimal(6, 4)
        * * Description: The overall (going-in) capitalization rate reported for this transaction, as a DECIMAL FRACTION (0.0650 = 6.50%). From the CoStar "Actual Cap Rate" field; NULL when not reported (the majority of sales).`),
    ImpliedNOIAtSale: z.number().nullable().describe(`
        * * Field Name: ImpliedNOIAtSale
        * * Display Name: Implied NOI at Sale
        * * SQL Data Type: decimal(14, 2)
        * * Description: SalePrice x CapRateAtSale -- the market net operating income implied by the price and the reported cap rate. Computed at load. Used to derive NOI/SqFt and NOI/Unit comps for the income approach (CoStar reports no direct NOI).`),
    BuildingSqFtExParking: z.number().nullable().describe(`
        * * Field Name: BuildingSqFtExParking
        * * Display Name: Building Sq Ft (Ex Parking)
        * * SQL Data Type: decimal(14, 2)
        * * Description: Building square footage with structured parking removed -- the comp-side parallel of ParcelPhysicalProfile.BuildingSqFtExParking, so comp $/SF is computed on the same basis as the subject. For a MarionPRC row on a parcel with a Parking / Pkg Garage / Com Garage improvement segment: BuildingSqFt minus that segment SqFt (NULL when the result is <= 0, i.e. a standalone garage). Otherwise equals BuildingSqFt (no parking; CoStar RBA is already rentable area). Use this, not BuildingSqFt, for $/SF comp math.`),
    Parcel: z.string().nullable().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxSaleTransactionEntityType = z.infer<typeof indianataxSaleTransactionSchema>;

/**
 * zod schema definition for the entity Source Documents
 */
export const indianataxSourceDocumentSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    DocumentType: z.union([z.literal('BoardDecision'), z.literal('CountyParcelList'), z.literal('Form'), z.literal('MarketDataExport'), z.literal('Memo'), z.literal('Other'), z.literal('PTABOAAgenda'), z.literal('PTABOAFinalDeterminationApproval'), z.literal('PTABOAFinalDeterminationWithdrawal'), z.literal('PropertyRecordCard'), z.literal('ReferenceText'), z.literal('Regulation'), z.literal('StatewideParcelDataset'), z.literal('Statute'), z.literal('TaxHistoryReport')]).describe(`
        * * Field Name: DocumentType
        * * Display Name: Document Type
        * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * BoardDecision
    *   * CountyParcelList
    *   * Form
    *   * MarketDataExport
    *   * Memo
    *   * Other
    *   * PTABOAAgenda
    *   * PTABOAFinalDeterminationApproval
    *   * PTABOAFinalDeterminationWithdrawal
    *   * PropertyRecordCard
    *   * ReferenceText
    *   * Regulation
    *   * StatewideParcelDataset
    *   * Statute
    *   * TaxHistoryReport
        * * Description: What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF), TaxHistoryReport (a county assessor Tax History Report PDF), PTABOAFinalDeterminationApproval (a monthly batch of ratified Form 115 Notifications of Final Assessment Determination, from indy.gov's "Preliminary Agreement Approvals" list -- Marion County only), PTABOAFinalDeterminationWithdrawal (the same, from indy.gov's "Approved Withdrawls" list), or Other.`),
    Title: z.string().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(500)
        * * Description: Human-readable title for the document (e.g. a case caption, a statute article name, a form name).`),
    SourceURL: z.string().nullable().describe(`
        * * Field Name: SourceURL
        * * Display Name: Source URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: The URL the document was fetched from, if it came from the web. NULL for documents entered from a local/offline source.`),
    RetrievedAt: z.date().nullable().describe(`
        * * Field Name: RetrievedAt
        * * Display Name: Retrieved At
        * * SQL Data Type: datetimeoffset
        * * Description: When this document was fetched/retrieved. Distinct from any date printed on the document itself — this is about verifying when WE pulled it.`),
    ContentHash: z.string().nullable().describe(`
        * * Field Name: ContentHash
        * * Display Name: Content Hash
        * * SQL Data Type: char(64)
        * * Description: SHA-256 hex digest of the raw file content. Used to detect an already-fetched document before re-downloading or re-extracting it (the dedup mechanism for the ingestion pipeline).`),
    RawFilePath: z.string().nullable().describe(`
        * * Field Name: RawFilePath
        * * Display Name: Raw File Path
        * * SQL Data Type: nvarchar(1000)
        * * Description: Local filesystem path to the original, unmodified file (PDF, HTML, etc.) as retrieved — the audit copy kept for future re-verification.`),
    ExtractedText: z.string().nullable().describe(`
        * * Field Name: ExtractedText
        * * Display Name: Extracted Text
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Full extracted plain text of the document, stored inline so it can be queried/searched/embedded directly without re-reading the original file.`),
    ExtractionNotes: z.string().nullable().describe(`
        * * Field Name: ExtractionNotes
        * * Display Name: Extraction Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text notes about the extraction itself — e.g. a font-encoding problem that made the text unreliable, or that OCR was used as a fallback.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    DocumentDate: z.date().nullable().describe(`
        * * Field Name: DocumentDate
        * * Display Name: Document Date
        * * SQL Data Type: date
        * * Description: The date the document itself is dated/effective (a memo's issue date, a decision's date) — distinct from RetrievedAt, which is when WE fetched it. NULL where the document has no single clear date (e.g. a multi-year-cycle reference text).`),
    LastVerifiedAt: z.date().nullable().describe(`
        * * Field Name: LastVerifiedAt
        * * Display Name: Last Verified At
        * * SQL Data Type: datetimeoffset
        * * Description: The last time this exact document was re-checked, whether or not the content had changed (RetrievedAt only updates on a real change). Updated on every scan so "checked recently, unchanged" is distinguishable from "not looked at in months."`),
});

export type indianataxSourceDocumentEntityType = z.infer<typeof indianataxSourceDocumentSchema>;

/**
 * zod schema definition for the entity Source Registries
 */
export const indianataxSourceRegistrySchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Name: z.string().describe(`
        * * Field Name: Name
        * * Display Name: Name
        * * SQL Data Type: nvarchar(200)
        * * Description: Human-readable name for the source (unique), e.g. "DLGF Memos — 2026" or "IBTR Board Decisions".`),
    SourceType: z.union([z.literal('CountyDataset'), z.literal('DLGF_Website'), z.literal('IBTR_Website'), z.literal('IndianaCode_Website'), z.literal('LocalFile'), z.literal('Other'), z.literal('StatewideDataset')]).describe(`
        * * Field Name: SourceType
        * * Display Name: Source Type
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * CountyDataset
    *   * DLGF_Website
    *   * IBTR_Website
    *   * IndianaCode_Website
    *   * LocalFile
    *   * Other
    *   * StatewideDataset
        * * Description: What kind of source this is — drives which ingestion code path applies (a statewide geodatabase pull, a website to crawl, a local file set, etc.).`),
    RootURL: z.string().nullable().describe(`
        * * Field Name: RootURL
        * * Display Name: Root URL
        * * SQL Data Type: nvarchar(1000)
        * * Description: The base page/URL this registry entry monitors, if web-based. NULL for non-web sources (e.g. a locally-sourced dataset).`),
    IsPropertyTaxRelevant: z.boolean().describe(`
        * * Field Name: IsPropertyTaxRelevant
        * * Display Name: Is Property Tax Relevant
        * * SQL Data Type: bit
        * * Default Value: 1
        * * Description: Whether this source itself is in scope for real property taxation. A source can be evaluated and marked 0 (e.g. DLGF Gateway — local government budget/TIF/debt data) so the decision to exclude it is recorded, not just absent.`),
    ScanFrequency: z.union([z.literal('AdHoc'), z.literal('Annual'), z.literal('Monthly'), z.literal('OneTime'), z.literal('Quarterly')]).nullable().describe(`
        * * Field Name: ScanFrequency
        * * Display Name: Scan Frequency
        * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * AdHoc
    *   * Annual
    *   * Monthly
    *   * OneTime
    *   * Quarterly
        * * Description: How often this source should be re-scanned for new/updated documents: Monthly, Quarterly, Annual, OneTime (already fully captured, e.g. a fixed historical dataset), or AdHoc (rescanned manually as needed).`),
    LastScannedAt: z.date().nullable().describe(`
        * * Field Name: LastScannedAt
        * * Display Name: Last Scanned At
        * * SQL Data Type: datetimeoffset
        * * Description: The last time this source was actually scanned for updates, regardless of whether anything new was found. This is the "last date researched" for the source as a whole.`),
    NextScanDueAt: z.date().nullable().describe(`
        * * Field Name: NextScanDueAt
        * * Display Name: Next Scan Due At
        * * SQL Data Type: datetimeoffset
        * * Description: When this source is next due for a scan, computed from LastScannedAt + ScanFrequency. Drives a "what needs attention" view without recomputing on every query.`),
    LastScanNotes: z.string().nullable().describe(`
        * * Field Name: LastScanNotes
        * * Display Name: Last Scan Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text outcome of the most recent scan — e.g. "3 new memos found", "no changes", or an error if the source was unreachable.`),
    Notes: z.string().nullable().describe(`
        * * Field Name: Notes
        * * Display Name: Notes
        * * SQL Data Type: nvarchar(MAX)
        * * Description: General notes about this source — why it is or isn't in scope, quirks of its structure, etc.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxSourceRegistryEntityType = z.infer<typeof indianataxSourceRegistrySchema>;

/**
 * zod schema definition for the entity Statute Sections
 */
export const indianataxStatuteSectionSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Article: z.string().describe(`
        * * Field Name: Article
        * * Display Name: Article
        * * SQL Data Type: nvarchar(20)
        * * Description: Indiana Code article number (e.g. 1.1, 1.5).`),
    SectionNumber: z.string().describe(`
        * * Field Name: SectionNumber
        * * Display Name: Section Number
        * * SQL Data Type: nvarchar(20)
        * * Description: Full section citation (e.g. 6-1.1-15-1).`),
    Title: z.string().nullable().describe(`
        * * Field Name: Title
        * * Display Name: Title
        * * SQL Data Type: nvarchar(500)
        * * Description: Section heading/title, if the source text has one.`),
    SectionText: z.string().nullable().describe(`
        * * Field Name: SectionText
        * * Display Name: Section Text
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Full text of this section, for direct citation and RAG retrieval.`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The full-article document (e.g. Article_1.1.pdf) this section was parsed out of.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
});

export type indianataxStatuteSectionEntityType = z.infer<typeof indianataxStatuteSectionSchema>;

/**
 * zod schema definition for the entity Stores
 */
export const bigboxretailStoreSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    Brand: z.string().describe(`
        * * Field Name: Brand
        * * Display Name: Brand
        * * SQL Data Type: nvarchar(100)
        * * Description: The tenant/retailer brand name (e.g. Walmart, Kohl's, Menards). One row per confirmed store, not per parcel -- a multi-parcel site is one Store row with multiple parcels listed in Parcels.`),
    StoreName: z.string().nullable().describe(`
        * * Field Name: StoreName
        * * Display Name: Store Name
        * * SQL Data Type: nvarchar(200)
        * * Description: The store's display name as returned by the locator source, when it differs from Brand (e.g. "Walmart Supercenter", "Meijer Express").`),
    Address: z.string().describe(`
        * * Field Name: Address
        * * Display Name: Street Address
        * * SQL Data Type: nvarchar(200)
        * * Description: Street address of the store.`),
    City: z.string().describe(`
        * * Field Name: City
        * * Display Name: City
        * * SQL Data Type: nvarchar(100)
        * * Description: City.`),
    State: z.string().describe(`
        * * Field Name: State
        * * Display Name: State
        * * SQL Data Type: nchar(2)
        * * Default Value: IN
        * * Description: Two-letter state code. Indiana-only for now ('IN') -- a placeholder for future states, not yet used for any multi-state logic.`),
    ZIP: z.string().nullable().describe(`
        * * Field Name: ZIP
        * * Display Name: ZIP Code
        * * SQL Data Type: nvarchar(10)
        * * Description: ZIP code, as returned by the locator source.`),
    County: z.string().nullable().describe(`
        * * Field Name: County
        * * Display Name: County
        * * SQL Data Type: nvarchar(50)
        * * Description: Indiana county name (DLGF numbering -- see Big_Box_Retail/states/indiana/data/COUNTY_CODES.md), derived from the matched parcel's county code.`),
    Latitude: z.number().nullable().describe(`
        * * Field Name: Latitude
        * * Display Name: Latitude
        * * SQL Data Type: decimal(9, 6)
        * * Description: Latitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).`),
    Longitude: z.number().nullable().describe(`
        * * Field Name: Longitude
        * * Display Name: Longitude
        * * SQL Data Type: decimal(9, 6)
        * * Description: Longitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).`),
    LocatorSource: z.union([z.literal('nominatim'), z.literal('nominatim+overpass'), z.literal('overpass')]).nullable().describe(`
        * * Field Name: LocatorSource
        * * Display Name: Locator Source
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * nominatim
    *   * nominatim+overpass
    *   * overpass
        * * Description: Which store-locator source(s) found this store: overpass, nominatim, or both (nominatim+overpass).`),
    MatchMethod: z.union([z.literal('exact addr'), z.literal('owner + city'), z.literal('street + near #'), z.literal('subset street + #')]).nullable().describe(`
        * * Field Name: MatchMethod
        * * Display Name: Match Method
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * exact addr
    *   * owner + city
    *   * street + near #
    *   * subset street + #
        * * Description: Which address-matching tier confirmed this store against a county assessor parcel -- see Big_Box_Retail/states/indiana/data/README.md for the methodology and how each tier was verified.`),
    ParcelCount: z.number().describe(`
        * * Field Name: ParcelCount
        * * Display Name: Parcel Count
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Number of assessor parcels this store's building spans (a store is often 2-4 parcels: pad, parking, outlots).`),
    Parcels: z.string().nullable().describe(`
        * * Field Name: Parcels
        * * Display Name: Parcels
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Delimited county:parcel;county:parcel... list of every matched assessor parcel, using DLGF county numbers.`),
    TotalBuildingSqFt: z.number().nullable().describe(`
        * * Field Name: TotalBuildingSqFt
        * * Display Name: Total Building Square Feet
        * * SQL Data Type: int
        * * Description: Sum of building square footage across this store's matched parcels.`),
    MaxBuildingSqFt: z.number().nullable().describe(`
        * * Field Name: MaxBuildingSqFt
        * * Display Name: Max Building Square Feet
        * * SQL Data Type: int
        * * Description: Max building square footage across this store's matched parcels.`),
    TotalAssessedValue: z.number().nullable().describe(`
        * * Field Name: TotalAssessedValue
        * * Display Name: Total Assessed Value
        * * SQL Data Type: money
        * * Description: Sum of total assessed value (land + improvement) across this store's matched parcels, in dollars.`),
    Tenure: z.union([z.literal('leased / investor'), z.literal('retailer-owned')]).nullable().describe(`
        * * Field Name: Tenure
        * * Display Name: Tenure
        * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * leased / investor
    *   * retailer-owned
        * * Description: Whether the matched parcel's owner is the retailer itself (retailer-owned) or a separate landlord/investor (leased / investor).`),
    OwnerName: z.string().nullable().describe(`
        * * Field Name: OwnerName
        * * Display Name: Owner Name
        * * SQL Data Type: nvarchar(200)
        * * Description: County assessor's owner-of-record name for the matched parcel(s).`),
    AppealCount: z.number().describe(`
        * * Field Name: AppealCount
        * * Display Name: Appeal Count
        * * SQL Data Type: int
        * * Default Value: 0
        * * Description: Number of PTABOA appeals on record for this store's matched parcel(s).`),
    LastAppealYear: z.number().nullable().describe(`
        * * Field Name: LastAppealYear
        * * Display Name: Last Appeal Year
        * * SQL Data Type: smallint
        * * Description: Most recent assessment year with an appeal on record, if any.`),
    TaxReps: z.string().nullable().describe(`
        * * Field Name: TaxReps
        * * Display Name: Tax Representatives
        * * SQL Data Type: nvarchar(300)
        * * Description: Tax representative(s) of record from the most recent appeal, if any.`),
    SourceFile: z.string().describe(`
        * * Field Name: SourceFile
        * * Display Name: Source File
        * * SQL Data Type: nvarchar(300)
        * * Description: Path/name of the CSV file this row was last imported from -- provenance for every row, per this project's documentation standard.`),
    ImportedAt: z.date().describe(`
        * * Field Name: ImportedAt
        * * Display Name: Imported At
        * * SQL Data Type: datetimeoffset
        * * Description: When this row was last written by the importer script.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Mj Latitude
        * * SQL Data Type: decimal(9, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Mj Longitude
        * * SQL Data Type: decimal(9, 6)`),
});

export type bigboxretailStoreEntityType = z.infer<typeof bigboxretailStoreSchema>;

/**
 * zod schema definition for the entity Tax History Years
 */
export const indianataxTaxHistoryYearSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel this historical tax-year row belongs to.`),
    TaxHistorySourceDocumentID: z.string().describe(`
        * * Field Name: TaxHistorySourceDocumentID
        * * Display Name: Tax History Source Document ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
        * * Description: The SourceDocument row for the Tax History Report PDF this row was parsed from.`),
    TaxYear: z.number().describe(`
        * * Field Name: TaxYear
        * * Display Name: Tax Year
        * * SQL Data Type: smallint
        * * Description: The tax year (payable year) this row reports on, per the document's own "Tax Year:" header for this column. NOT unique per parcel by itself -- see ColumnOrdinal.`),
    ColumnOrdinal: z.number().describe(`
        * * Field Name: ColumnOrdinal
        * * Display Name: Column Ordinal
        * * SQL Data Type: smallint
        * * Description: This row's position within the document: 0 = the current-year snapshot from the report's first-page section, 1 = the most recent column of the "PRIOR TAX PAYMENT INFORMATION" table, increasing with age. NOT derivable from TaxYear alone -- the year 2007 genuinely appears twice (Marion County's real 2007 statewide-reassessment-cycle transition, confirmed across every document checked) at two different ordinals; this is the real uniqueness key together with TaxYear, not a synthetic workaround.`),
    LandAssessment: z.number().nullable().describe(`
        * * Field Name: LandAssessment
        * * Display Name: Land Assessment
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Land Assessment" figure for this tax year.`),
    Improvements: z.number().nullable().describe(`
        * * Field Name: Improvements
        * * Display Name: Improvements
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Improvements" assessment figure for this tax year.`),
    GrossAssessment: z.number().nullable().describe(`
        * * Field Name: GrossAssessment
        * * Display Name: Gross Assessment
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Gross Assessment" figure for this tax year (Land + Improvements, before deductions/exemptions).`),
    DeductionsExemptionsTotal: z.number().nullable().describe(`
        * * Field Name: DeductionsExemptionsTotal
        * * Display Name: Deductions Exemptions Total
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Deductions/Exemptions" total applied for this tax year.`),
    NetAssessment: z.number().nullable().describe(`
        * * Field Name: NetAssessment
        * * Display Name: Net Assessment
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Net Assessment" figure for this tax year (Gross Assessment less Deductions/Exemptions).`),
    TaxRate: z.number().nullable().describe(`
        * * Field Name: TaxRate
        * * Display Name: Tax Rate
        * * SQL Data Type: decimal(9, 6)
        * * Description: The "Tax Rate" for this tax year, per $100 of assessed value.`),
    ReplacementCredit: z.number().nullable().describe(`
        * * Field Name: ReplacementCredit
        * * Display Name: Replacement Credit
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Replacement Credit" applied for this tax year.`),
    HomesteadCredit: z.number().nullable().describe(`
        * * Field Name: HomesteadCredit
        * * Display Name: Homestead Credit
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Homestead Credit" applied for this tax year -- a single combined figure in the historical table (unlike the current-year section, which splits state/local homestead credit into separate fields).`),
    NetAnnualTax: z.number().nullable().describe(`
        * * Field Name: NetAnnualTax
        * * Display Name: Net Annual Tax
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Net Annual Tax" liability for this tax year -- the reliable tax-liability figure for this row (see the table-level note on why GrossTax is not stored).`),
    HalfYearTax: z.number().nullable().describe(`
        * * Field Name: HalfYearTax
        * * Display Name: Half Year Tax
        * * SQL Data Type: decimal(14, 2)
        * * Description: The "Half Year Tax" figure for this tax year (Net Annual Tax split across the two semi-annual installments).`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxTaxHistoryYearEntityType = z.infer<typeof indianataxTaxHistoryYearSchema>;

/**
 * zod schema definition for the entity Valuation Analysis
 */
export const indianataxValuationAnalysisSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ParcelID: z.string().describe(`
        * * Field Name: ParcelID
        * * Display Name: Parcel ID
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
        * * Description: The parcel analysed.`),
    AssessmentYear: z.number().describe(`
        * * Field Name: AssessmentYear
        * * Display Name: Assessment Year
        * * SQL Data Type: smallint
        * * Description: The assessment year the analysis is for.`),
    MethodologyVersion: z.string().describe(`
        * * Field Name: MethodologyVersion
        * * Display Name: Methodology Version
        * * SQL Data Type: nvarchar(30)
        * * Description: Version tag for the methodology that produced this row (e.g. "sales-p25-2026-08-30"). Lets a re-run replace its own rows without touching an earlier method's.`),
    PropertyTypeGroup: z.string().nullable().describe(`
        * * Field Name: PropertyTypeGroup
        * * Display Name: Property Type Group
        * * SQL Data Type: nvarchar(30)
        * * Description: Rolled-up property category used for comp grouping.`),
    CurrentTotalAV: z.number().nullable().describe(`
        * * Field Name: CurrentTotalAV
        * * Display Name: Current Total Assessed Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The county's current total assessed value the target is measured against.`),
    SalesIndicatedValue: z.number().nullable().describe(`
        * * Field Name: SalesIndicatedValue
        * * Display Name: Sales Indicated Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Value indicated by the sales comparison approach.`),
    SalesMethodNote: z.string().nullable().describe(`
        * * Field Name: SalesMethodNote
        * * Display Name: Sales Method Note
        * * SQL Data Type: nvarchar(400)
        * * Description: How the sales indication was derived (comp pool, unit metric, the point statistic used).`),
    IncomeIndicatedValue: z.number().nullable().describe(`
        * * Field Name: IncomeIndicatedValue
        * * Display Name: Income Indicated Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: Value indicated by the income capitalization approach (not yet populated).`),
    IncomeMethodNote: z.string().nullable().describe(`
        * * Field Name: IncomeMethodNote
        * * Display Name: Income Method Note
        * * SQL Data Type: nvarchar(400)
        * * Description: How the income indication was derived.`),
    CostProxyValue: z.number().nullable().describe(`
        * * Field Name: CostProxyValue
        * * Display Name: Cost Proxy Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The county's own mass-appraisal cost figure, surfaced as a proxy / sanity anchor ONLY -- the DLGF cost tables cannot be relied on by either party in a subjective valuation argument. Not yet populated.`),
    CostProxyNote: z.string().nullable().describe(`
        * * Field Name: CostProxyNote
        * * Display Name: Cost Proxy Note
        * * SQL Data Type: nvarchar(400)
        * * Description: Note on the cost proxy, including the caveat above.`),
    ReconciledTargetValue: z.number().nullable().describe(`
        * * Field Name: ReconciledTargetValue
        * * Display Name: Reconciled Target Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The reconciled opinion of value -- the number an appeal would argue for.`),
    TargetValuePerUnit: z.number().nullable().describe(`
        * * Field Name: TargetValuePerUnit
        * * Display Name: Target Value Per Unit
        * * SQL Data Type: decimal(14, 2)
        * * Description: ReconciledTargetValue / unit count.`),
    TargetValuePerSqFt: z.number().nullable().describe(`
        * * Field Name: TargetValuePerSqFt
        * * Display Name: Target Value Per Square Foot
        * * SQL Data Type: decimal(12, 2)
        * * Description: ReconciledTargetValue / building sq ft.`),
    ControllingApproach: z.union([z.literal('CostProxy'), z.literal('Income'), z.literal('None'), z.literal('Sales')]).nullable().describe(`
        * * Field Name: ControllingApproach
        * * Display Name: Controlling Approach
        * * SQL Data Type: nvarchar(16)
    * * Value List Type: List
    * * Possible Values 
    *   * CostProxy
    *   * Income
    *   * None
    *   * Sales
        * * Description: Which approach controlled the reconciliation: Sales / Income / CostProxy / Blended / None.`),
    ReconciliationRationale: z.string().nullable().describe(`
        * * Field Name: ReconciliationRationale
        * * Display Name: Reconciliation Rationale
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Narrative: why these approaches, why this weighting, why this point in the range.`),
    MaterialityPct: z.number().nullable().describe(`
        * * Field Name: MaterialityPct
        * * Display Name: Materiality Percentage
        * * SQL Data Type: decimal(7, 4)
        * * Description: (CurrentTotalAV - ReconciledTargetValue) / CurrentTotalAV -- how far below the assessment the target sits.`),
    MaterialityThreshold: z.number().describe(`
        * * Field Name: MaterialityThreshold
        * * Display Name: Materiality Threshold
        * * SQL Data Type: decimal(7, 4)
        * * Default Value: 0.05
        * * Description: The reduction fraction below which an appeal is not worth pursuing (default 5%).`),
    AppliedTaxRate: z.number().nullable().describe(`
        * * Field Name: AppliedTaxRate
        * * Display Name: Applied Tax Rate
        * * SQL Data Type: decimal(8, 6)
        * * Description: The tax rate applied to convert an AV reduction into a dollar saving (from CountyAssessorRecord.TaxRate as a percent, or a default). `),
    EstimatedTaxSavings: z.number().nullable().describe(`
        * * Field Name: EstimatedTaxSavings
        * * Display Name: Estimated Tax Savings
        * * SQL Data Type: decimal(14, 2)
        * * Description: (CurrentTotalAV - ReconciledTargetValue) x AppliedTaxRate -- the estimated annual tax saving if the target is achieved.`),
    Recommendation: z.union([z.literal('Appeal'), z.literal('Monitor'), z.literal('No Appeal')]).nullable().describe(`
        * * Field Name: Recommendation
        * * Display Name: Recommendation
        * * SQL Data Type: nvarchar(12)
    * * Value List Type: List
    * * Possible Values 
    *   * Appeal
    *   * Monitor
    *   * No Appeal
        * * Description: Appeal / No Appeal / Monitor. "Monitor" = a signal exists but the comp support is thin or the indication is implausibly far from the AV (needs a human look).`),
    ConfidenceTier: z.union([z.literal('High'), z.literal('Low'), z.literal('Medium')]).nullable().describe(`
        * * Field Name: ConfidenceTier
        * * Display Name: Confidence Tier
        * * SQL Data Type: nvarchar(8)
    * * Value List Type: List
    * * Possible Values 
    *   * High
    *   * Low
    *   * Medium
        * * Description: High / Medium / Low. High requires a solid comp cluster, a PRC-sourced size, and an indication within a sane band of the AV.`),
    CompCount: z.number().nullable().describe(`
        * * Field Name: CompCount
        * * Display Name: Comparable Count
        * * SQL Data Type: int
        * * Description: Number of comparable sales behind the sales indication.`),
    AnalystNote: z.string().nullable().describe(`
        * * Field Name: AnalystNote
        * * Display Name: Analyst Note
        * * SQL Data Type: nvarchar(MAX)
        * * Description: Free-text analyst / agent notes.`),
    GeneratedAt: z.date().nullable().describe(`
        * * Field Name: GeneratedAt
        * * Display Name: Generated At
        * * SQL Data Type: datetimeoffset
        * * Description: When this analysis row was generated.`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    LowestSupportedValue: z.number().nullable().describe(`
        * * Field Name: LowestSupportedValue
        * * Display Name: Lowest Supported Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: The aggressive floor -- MIN of the approach indications (Sales / Income / CostProxy) that fall within the sanity band [0.5, 1.2] x current AV. The lowest credible opinion of value.`),
    SupportingApproachCount: z.number().nullable().describe(`
        * * Field Name: SupportingApproachCount
        * * Display Name: Supporting Approach Count
        * * SQL Data Type: tinyint
        * * Description: How many approaches independently indicate a value below the current AV (and in band). >= 2 means redundant support for a reduction -- the recommended ask is then pitched at the higher of the low values.`),
    MaxEstimatedTaxSavings: z.number().nullable().describe(`
        * * Field Name: MaxEstimatedTaxSavings
        * * Display Name: Max Estimated Tax Savings
        * * SQL Data Type: decimal(14, 2)
        * * Description: Estimated annual tax saving if LowestSupportedValue is achieved. EstimatedTaxSavings is the saving at the recommended ask (ReconciledTargetValue); this is the saving at the floor.`),
    Parcel: z.string().describe(`
        * * Field Name: Parcel
        * * Display Name: Parcel
        * * SQL Data Type: nvarchar(30)`),
});

export type indianataxValuationAnalysisEntityType = z.infer<typeof indianataxValuationAnalysisSchema>;

/**
 * zod schema definition for the entity Valuation Comps
 */
export const indianataxValuationCompSchema = z.object({
    ID: z.string().describe(`
        * * Field Name: ID
        * * Display Name: ID
        * * SQL Data Type: uniqueidentifier
        * * Default Value: newsequentialid()`),
    ValuationAnalysisID: z.string().describe(`
        * * Field Name: ValuationAnalysisID
        * * Display Name: Valuation Analysis
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Valuation Analysis (vwValuationAnalysis.ID)`),
    SaleTransactionID: z.string().nullable().describe(`
        * * Field Name: SaleTransactionID
        * * Display Name: Sale Transaction
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Sale Transactions (vwSaleTransactions.ID)`),
    SourceDocumentID: z.string().nullable().describe(`
        * * Field Name: SourceDocumentID
        * * Display Name: Source Document
        * * SQL Data Type: uniqueidentifier
        * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)`),
    UnitOfComparison: z.union([z.literal('$/SF'), z.literal('$/unit')]).describe(`
        * * Field Name: UnitOfComparison
        * * Display Name: Unit of Comparison
        * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * $/SF
    *   * $/unit`),
    CompAddress: z.string().nullable().describe(`
        * * Field Name: CompAddress
        * * Display Name: Comparable Address
        * * SQL Data Type: nvarchar(300)`),
    CompSubmarket: z.string().nullable().describe(`
        * * Field Name: CompSubmarket
        * * Display Name: Comparable Submarket
        * * SQL Data Type: nvarchar(80)`),
    SaleDate: z.date().nullable().describe(`
        * * Field Name: SaleDate
        * * Display Name: Sale Date
        * * SQL Data Type: date`),
    SalePrice: z.number().nullable().describe(`
        * * Field Name: SalePrice
        * * Display Name: Sale Price
        * * SQL Data Type: decimal(14, 2)`),
    CompDenominator: z.number().nullable().describe(`
        * * Field Name: CompDenominator
        * * Display Name: Comparable Denominator
        * * SQL Data Type: decimal(14, 2)`),
    CompYearBuilt: z.number().nullable().describe(`
        * * Field Name: CompYearBuilt
        * * Display Name: Year Built
        * * SQL Data Type: smallint`),
    CompGradeOrdinal: z.number().nullable().describe(`
        * * Field Name: CompGradeOrdinal
        * * Display Name: Grade
        * * SQL Data Type: decimal(4, 2)`),
    RawPerUnit: z.number().nullable().describe(`
        * * Field Name: RawPerUnit
        * * Display Name: Raw Price Per Unit
        * * SQL Data Type: decimal(14, 2)`),
    SizeAdjPct: z.number().nullable().describe(`
        * * Field Name: SizeAdjPct
        * * Display Name: Size Adjustment %
        * * SQL Data Type: decimal(6, 4)
        * * Description: Signed size adjustment (economies of scale): +0.10 x ln(compDenominator / subjectDenominator), clamped +/-15%. Positive raises the comp $/unit toward a smaller subject.`),
    AgeAdjPct: z.number().nullable().describe(`
        * * Field Name: AgeAdjPct
        * * Display Name: Age Adjustment %
        * * SQL Data Type: decimal(6, 4)`),
    GradeAdjPct: z.number().nullable().describe(`
        * * Field Name: GradeAdjPct
        * * Display Name: Grade Adjustment %
        * * SQL Data Type: decimal(6, 4)`),
    TimeAdjPct: z.number().nullable().describe(`
        * * Field Name: TimeAdjPct
        * * Display Name: Time Adjustment %
        * * SQL Data Type: decimal(6, 4)
        * * Description: Signed time adjustment: annual CRE appreciation (3%) x years from sale date to the 1/1/2026 lien date, clamped [-5%, +30%].`),
    NetAdjPct: z.number().nullable().describe(`
        * * Field Name: NetAdjPct
        * * Display Name: Net Adjustment %
        * * SQL Data Type: decimal(6, 4)`),
    GrossAdjPct: z.number().nullable().describe(`
        * * Field Name: GrossAdjPct
        * * Display Name: Gross Adjustment %
        * * SQL Data Type: decimal(6, 4)`),
    AdjustedPerUnit: z.number().nullable().describe(`
        * * Field Name: AdjustedPerUnit
        * * Display Name: Adjusted Price Per Unit
        * * SQL Data Type: decimal(14, 2)`),
    SubjectIndicatedValue: z.number().nullable().describe(`
        * * Field Name: SubjectIndicatedValue
        * * Display Name: Subject Indicated Value
        * * SQL Data Type: decimal(14, 2)
        * * Description: AdjustedPerUnit x the subject's denominator (SF or units) -- this comp's indication of the subject's total value.`),
    SimilarityRank: z.number().nullable().describe(`
        * * Field Name: SimilarityRank
        * * Display Name: Similarity Rank
        * * SQL Data Type: int`),
    IsSelected: z.boolean().describe(`
        * * Field Name: IsSelected
        * * Display Name: Selected
        * * SQL Data Type: bit
        * * Default Value: 0`),
    DropReason: z.string().nullable().describe(`
        * * Field Name: DropReason
        * * Display Name: Drop Reason
        * * SQL Data Type: nvarchar(40)`),
    __mj_CreatedAt: z.date().describe(`
        * * Field Name: __mj_CreatedAt
        * * Display Name: Created At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    __mj_UpdatedAt: z.date().describe(`
        * * Field Name: __mj_UpdatedAt
        * * Display Name: Updated At
        * * SQL Data Type: datetimeoffset
        * * Default Value: getutcdate()`),
    SaleTransaction: z.string().nullable().describe(`
        * * Field Name: SaleTransaction
        * * Display Name: Sale Transaction
        * * SQL Data Type: nvarchar(200)`),
    __mj_Latitude: z.number().nullable().describe(`
        * * Field Name: __mj_Latitude
        * * Display Name: Mj Latitude
        * * SQL Data Type: decimal(10, 6)`),
    __mj_Longitude: z.number().nullable().describe(`
        * * Field Name: __mj_Longitude
        * * Display Name: Mj Longitude
        * * SQL Data Type: decimal(10, 6)`),
});

export type indianataxValuationCompEntityType = z.infer<typeof indianataxValuationCompSchema>;
 
 

/**
 * Appeal Leads - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: AppealLead
 * * Base View: vwAppealLeads
 * * @description A scored appeal-candidate lead: a parcel flagged as likely over-assessed via peer-group improvement AV/sqft outlier detection, a year-over-year jump, and historical PTABOA win-rate by property class. Ranked by estimated dollar excess AV. Statistical screen, not a substitute for reviewing the flagged parcel. KNOWN GAP: current rows use total building sqft (including garage space) in the comparison -- see MethodologyVersion and the corresponding ResearchTask.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Appeal Leads')
export class indianataxAppealLeadEntity extends BaseEntity<indianataxAppealLeadEntityType> {
    /**
    * Loads the Appeal Leads record from the database
    * @param ID: string - primary key value to load the Appeal Leads record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxAppealLeadEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this lead concerns.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: Rank
    * * Display Name: Rank
    * * SQL Data Type: int
    * * Description: Rank by EstimatedExcessAV within this scoring pass (1 = highest estimated excess). No minimum case-size floor -- rank order matters more than a cutoff.
    */
    get Rank(): number | null {
        return this.Get('Rank');
    }
    set Rank(value: number | null) {
        this.Set('Rank', value);
    }

    /**
    * * Field Name: CurrentLandAV
    * * Display Name: Current Land AV
    * * SQL Data Type: decimal(14, 2)
    */
    get CurrentLandAV(): number | null {
        return this.Get('CurrentLandAV');
    }
    set CurrentLandAV(value: number | null) {
        this.Set('CurrentLandAV', value);
    }

    /**
    * * Field Name: CurrentImprovementAV
    * * Display Name: Current Improvement AV
    * * SQL Data Type: decimal(14, 2)
    */
    get CurrentImprovementAV(): number | null {
        return this.Get('CurrentImprovementAV');
    }
    set CurrentImprovementAV(value: number | null) {
        this.Set('CurrentImprovementAV', value);
    }

    /**
    * * Field Name: CurrentTotalAV
    * * Display Name: Current Total AV
    * * SQL Data Type: decimal(14, 2)
    */
    get CurrentTotalAV(): number | null {
        return this.Get('CurrentTotalAV');
    }
    set CurrentTotalAV(value: number | null) {
        this.Set('CurrentTotalAV', value);
    }

    /**
    * * Field Name: PriorTotalAV
    * * Display Name: Prior Total AV
    * * SQL Data Type: decimal(14, 2)
    */
    get PriorTotalAV(): number | null {
        return this.Get('PriorTotalAV');
    }
    set PriorTotalAV(value: number | null) {
        this.Set('PriorTotalAV', value);
    }

    /**
    * * Field Name: YoyPctChange
    * * Display Name: YoY Percent Change
    * * SQL Data Type: decimal(9, 6)
    * * Description: Year-over-year percent change in total AV (current vs. prior source pull).
    */
    get YoyPctChange(): number | null {
        return this.Get('YoyPctChange');
    }
    set YoyPctChange(value: number | null) {
        this.Set('YoyPctChange', value);
    }

    /**
    * * Field Name: YoyJumpFlag
    * * Display Name: YoY Jump Flag
    * * SQL Data Type: bit
    * * Description: Flagged when YoyPctChange met or exceeded the jump threshold (15% in the original methodology) -- a second, independent trigger from the peer-group comparison.
    */
    get YoyJumpFlag(): boolean | null {
        return this.Get('YoyJumpFlag');
    }
    set YoyJumpFlag(value: boolean | null) {
        this.Set('YoyJumpFlag', value);
    }

    /**
    * * Field Name: Grade
    * * Display Name: Grade
    * * SQL Data Type: nvarchar(10)
    */
    get Grade(): string | null {
        return this.Get('Grade');
    }
    set Grade(value: string | null) {
        this.Set('Grade', value);
    }

    /**
    * * Field Name: ConditionCode
    * * Display Name: Condition Code
    * * SQL Data Type: nvarchar(10)
    */
    get ConditionCode(): string | null {
        return this.Get('ConditionCode');
    }
    set ConditionCode(value: string | null) {
        this.Set('ConditionCode', value);
    }

    /**
    * * Field Name: YearConstructed
    * * Display Name: Year Constructed
    * * SQL Data Type: smallint
    */
    get YearConstructed(): number | null {
        return this.Get('YearConstructed');
    }
    set YearConstructed(value: number | null) {
        this.Set('YearConstructed', value);
    }

    /**
    * * Field Name: EffectiveConstructionYear
    * * Display Name: Effective Construction Year
    * * SQL Data Type: smallint
    */
    get EffectiveConstructionYear(): number | null {
        return this.Get('EffectiveConstructionYear');
    }
    set EffectiveConstructionYear(value: number | null) {
        this.Set('EffectiveConstructionYear', value);
    }

    /**
    * * Field Name: BuildingSqFt
    * * Display Name: Building Sqft
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total building square footage summed across all building rows for the parcel (source: building.total_square_foot_area). Includes garage space -- kept as a sanity-check total, not the basis for a corrected per-sqft comparison. See GarageSqFt.
    */
    get BuildingSqFt(): number | null {
        return this.Get('BuildingSqFt');
    }
    set BuildingSqFt(value: number | null) {
        this.Set('BuildingSqFt', value);
    }

    /**
    * * Field Name: GarageSqFt
    * * Display Name: Garage Sqft
    * * SQL Data Type: decimal(14, 2)
    * * Description: Square footage identified as commercial garage space (source: building_detail rows where use_code = 'COMGAR'), so it can be excluded or separately weighted in a corrected improvement-AV-per-sqft comparison. NULL where not yet computed for this parcel, not necessarily zero.
    */
    get GarageSqFt(): number | null {
        return this.Get('GarageSqFt');
    }
    set GarageSqFt(value: number | null) {
        this.Set('GarageSqFt', value);
    }

    /**
    * * Field Name: HasGarage
    * * Display Name: Has Garage
    * * SQL Data Type: bit
    * * Description: Whether any COMGAR (commercial garage) square footage was found for this parcel.
    */
    get HasGarage(): boolean | null {
        return this.Get('HasGarage');
    }
    set HasGarage(value: boolean | null) {
        this.Set('HasGarage', value);
    }

    /**
    * * Field Name: ImprovementAVPerSqFt
    * * Display Name: Improvement AV Per Sqft
    * * SQL Data Type: decimal(14, 4)
    * * Description: This parcel's improvement AV divided by TOTAL building sqft (including garage space) -- the metric actually used to rank this scoring pass. See the table-level note on the known garage-weighting gap.
    */
    get ImprovementAVPerSqFt(): number | null {
        return this.Get('ImprovementAVPerSqFt');
    }
    set ImprovementAVPerSqFt(value: number | null) {
        this.Set('ImprovementAVPerSqFt', value);
    }

    /**
    * * Field Name: PeerMedianImprovementAVPerSqFt
    * * Display Name: Peer Median Improvement AV Per Sqft
    * * SQL Data Type: decimal(14, 4)
    * * Description: Median ImprovementAVPerSqFt within this parcel's peer group (property class + grade, falling back to class alone when the group is too thin).
    */
    get PeerMedianImprovementAVPerSqFt(): number | null {
        return this.Get('PeerMedianImprovementAVPerSqFt');
    }
    set PeerMedianImprovementAVPerSqFt(value: number | null) {
        this.Set('PeerMedianImprovementAVPerSqFt', value);
    }

    /**
    * * Field Name: PeerGroupBasis
    * * Display Name: Peer Group Basis
    * * SQL Data Type: nvarchar(50)
    * * Description: How the peer comparison group was defined for this parcel (e.g. "class+grade", or a coarser fallback like "class only (class+grade too thin)" when the class+grade bucket had too few peers). Widened to NVARCHAR(50) after the original NVARCHAR(20) proved too small for the fallback-description strings the methodology actually produces.
    */
    get PeerGroupBasis(): string | null {
        return this.Get('PeerGroupBasis');
    }
    set PeerGroupBasis(value: string | null) {
        this.Set('PeerGroupBasis', value);
    }

    /**
    * * Field Name: PeerGroupSize
    * * Display Name: Peer Group Size
    * * SQL Data Type: int
    */
    get PeerGroupSize(): number | null {
        return this.Get('PeerGroupSize');
    }
    set PeerGroupSize(value: number | null) {
        this.Set('PeerGroupSize', value);
    }

    /**
    * * Field Name: ExcessRatio
    * * Display Name: Excess Ratio
    * * SQL Data Type: decimal(9, 4)
    * * Description: This parcel's ImprovementAVPerSqFt divided by its peer group's median -- the core outlier-detection ratio driving the rank.
    */
    get ExcessRatio(): number | null {
        return this.Get('ExcessRatio');
    }
    set ExcessRatio(value: number | null) {
        this.Set('ExcessRatio', value);
    }

    /**
    * * Field Name: EstimatedExcessAV
    * * Display Name: Estimated Excess AV
    * * SQL Data Type: decimal(14, 2)
    * * Description: Estimated dollar excess assessed value implied by ExcessRatio -- what the ranking is sorted by.
    */
    get EstimatedExcessAV(): number | null {
        return this.Get('EstimatedExcessAV');
    }
    set EstimatedExcessAV(value: number | null) {
        this.Set('EstimatedExcessAV', value);
    }

    /**
    * * Field Name: PeerAppealCount
    * * Display Name: Peer Appeal Count
    * * SQL Data Type: int
    * * Description: Count of historical real-property (non-BPP) PTABOA appeals for this parcel's property class that resolve to a parcel in this database's scope -- a directional signal, not a precise win rate (covers a minority of all real-property appeals filed).
    */
    get PeerAppealCount(): number | null {
        return this.Get('PeerAppealCount');
    }
    set PeerAppealCount(value: number | null) {
        this.Set('PeerAppealCount', value);
    }

    /**
    * * Field Name: PeerAppealWins
    * * Display Name: Peer Appeal Wins
    * * SQL Data Type: int
    * * Description: Of PeerAppealCount, how many resulted in a reduction.
    */
    get PeerAppealWins(): number | null {
        return this.Get('PeerAppealWins');
    }
    set PeerAppealWins(value: number | null) {
        this.Set('PeerAppealWins', value);
    }

    /**
    * * Field Name: PeerWinRate
    * * Display Name: Peer Win Rate
    * * SQL Data Type: decimal(9, 6)
    * * Description: PeerAppealWins / PeerAppealCount for this property class.
    */
    get PeerWinRate(): number | null {
        return this.Get('PeerWinRate');
    }
    set PeerWinRate(value: number | null) {
        this.Set('PeerWinRate', value);
    }

    /**
    * * Field Name: PeerAvgPctReduction
    * * Display Name: Peer Avg Pct Reduction
    * * SQL Data Type: decimal(9, 6)
    * * Description: Average percent reduction among winning appeals for this property class.
    */
    get PeerAvgPctReduction(): number | null {
        return this.Get('PeerAvgPctReduction');
    }
    set PeerAvgPctReduction(value: number | null) {
        this.Set('PeerAvgPctReduction', value);
    }

    /**
    * * Field Name: AbsenteeOwnerFlag
    * * Display Name: Absentee Owner Flag
    * * SQL Data Type: bit
    * * Description: Owner's mailing address differs from the property address -- a lead-qualification signal, not a data-quality flag.
    */
    get AbsenteeOwnerFlag(): boolean | null {
        return this.Get('AbsenteeOwnerFlag');
    }
    set AbsenteeOwnerFlag(value: boolean | null) {
        this.Set('AbsenteeOwnerFlag', value);
    }

    /**
    * * Field Name: OutOfCityOwnerFlag
    * * Display Name: Out of City Owner Flag
    * * SQL Data Type: bit
    * * Description: Owner's mailing address is outside the property's city.
    */
    get OutOfCityOwnerFlag(): boolean | null {
        return this.Get('OutOfCityOwnerFlag');
    }
    set OutOfCityOwnerFlag(value: boolean | null) {
        this.Set('OutOfCityOwnerFlag', value);
    }

    /**
    * * Field Name: MethodologyVersion
    * * Display Name: Methodology Version
    * * SQL Data Type: nvarchar(30)
    * * Description: Which scoring methodology pass produced this row (e.g. "v1-total-sqft-2026"). Exists specifically so a future corrected pass (garage-adjusted comparison) is distinguishable from this one rather than silently overwriting/mixing with it.
    */
    get MethodologyVersion(): string {
        return this.Get('MethodologyVersion');
    }
    set MethodologyVersion(value: string) {
        this.Set('MethodologyVersion', value);
    }

    /**
    * * Field Name: GeneratedAt
    * * Display Name: Generated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When this scoring pass was run.
    */
    get GeneratedAt(): Date {
        return this.Get('GeneratedAt');
    }
    set GeneratedAt(value: Date) {
        this.Set('GeneratedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Number
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Appeal Stage Playbook Notes - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: AppealStagePlaybookNote
 * * Base View: vwAppealStagePlaybookNotes
 * * @description One tip / trap / deadline-nuance / strategy / local-practice item attached to an appeal stage. Replaces the single free-text AppealStage.Notes blob so each item is individually typed, cited, county-scopable and confidence-tagged. Design: Indiana_Tax_Expert/docs/proposals/appeal-playbook-structured.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Appeal Stage Playbook Notes')
export class indianataxAppealStagePlaybookNoteEntity extends BaseEntity<indianataxAppealStagePlaybookNoteEntityType> {
    /**
    * Loads the Appeal Stage Playbook Notes record from the database
    * @param ID: string - primary key value to load the Appeal Stage Playbook Notes record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxAppealStagePlaybookNoteEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: AppealStageID
    * * Display Name: Appeal Stage
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
    * * Description: The indiana_tax.AppealStage row this note belongs to.
    */
    get AppealStageID(): string {
        return this.Get('AppealStageID');
    }
    set AppealStageID(value: string) {
        this.Set('AppealStageID', value);
    }

    /**
    * * Field Name: NoteKind
    * * Display Name: Note Kind
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * DeadlineNuance
    *   * LocalPractice
    *   * Strategy
    *   * Tip
    *   * Trap
    * * Description: Tip (use it to your advantage), Trap (a way to lose or forfeit), DeadlineNuance (a subtlety in when/how a clock runs), Strategy (a lever worth pulling), or LocalPractice (how a specific county actually operates, vs. the statewide rule).
    */
    get NoteKind(): 'DeadlineNuance' | 'LocalPractice' | 'Strategy' | 'Tip' | 'Trap' {
        return this.Get('NoteKind');
    }
    set NoteKind(value: 'DeadlineNuance' | 'LocalPractice' | 'Strategy' | 'Tip' | 'Trap') {
        this.Set('NoteKind', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(200)
    * * Description: Short headline for the note.
    */
    get Title(): string {
        return this.Get('Title');
    }
    set Title(value: string) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: Body
    * * Display Name: Body
    * * SQL Data Type: nvarchar(MAX)
    * * Description: The note itself.
    */
    get Body(): string {
        return this.Get('Body');
    }
    set Body(value: string) {
        this.Set('Body', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: NULL = statewide note. A county number (49 = Marion) = the note applies only to that county, layered over the statewide stage.
    */
    get CountyNumber(): number | null {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number | null) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: StatuteSectionID
    * * Display Name: Statute Section
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Statute Sections (vwStatuteSections.ID)
    * * Description: Link to the indiana_tax.StatuteSection this note rests on, when one exists in the table.
    */
    get StatuteSectionID(): string | null {
        return this.Get('StatuteSectionID');
    }
    set StatuteSectionID(value: string | null) {
        this.Set('StatuteSectionID', value);
    }

    /**
    * * Field Name: CitationText
    * * Display Name: Citation Text
    * * SQL Data Type: nvarchar(100)
    * * Description: Free-text citation for when there is no StatuteSection row (e.g. "State Form 53958 instructions", "IC 6-1.1-15-1.2(k)").
    */
    get CitationText(): string | null {
        return this.Get('CitationText');
    }
    set CitationText(value: string | null) {
        this.Set('CitationText', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: Optional supporting SourceDocument (a form, a memo, a decision).
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Confidence
    * * Display Name: Confidence
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Verified
    * * Value List Type: List
    * * Possible Values 
    *   * NeedsVerification
    *   * Verified
    * * Description: Verified (grounded in a primary source) or NeedsVerification (an inference from observed data -- e.g. Marion PTABOA cadence read off loaded PTABOAAppeal rows -- not yet checked against a primary source). Per the project data-integrity rule, local-practice notes sourced from data start as NeedsVerification.
    */
    get Confidence(): 'NeedsVerification' | 'Verified' {
        return this.Get('Confidence');
    }
    set Confidence(value: 'NeedsVerification' | 'Verified') {
        this.Set('Confidence', value);
    }

    /**
    * * Field Name: SortOrder
    * * Display Name: Sort Order
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Display order within a stage.
    */
    get SortOrder(): number {
        return this.Get('SortOrder');
    }
    set SortOrder(value: number) {
        this.Set('SortOrder', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: AppealStage
    * * Display Name: Appeal Stage Name
    * * SQL Data Type: nvarchar(200)
    */
    get AppealStage(): string {
        return this.Get('AppealStage');
    }
}


/**
 * Appeal Stage Statutes - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: AppealStageStatute
 * * Base View: vwAppealStageStatutes
 * * @description A statute citation governing an AppealStage. StatuteSectionID resolves when we've ingested that section (Title 6 Articles 1.1/1.5); NULL when the citation is outside that scope (e.g. IC 33-26-6-7, Title 33). CitationText is always populated regardless, so the raw citation is never lost to a missing join.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Appeal Stage Statutes')
export class indianataxAppealStageStatuteEntity extends BaseEntity<indianataxAppealStageStatuteEntityType> {
    /**
    * Loads the Appeal Stage Statutes record from the database
    * @param ID: string - primary key value to load the Appeal Stage Statutes record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxAppealStageStatuteEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: AppealStageID
    * * Display Name: Appeal Stage
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
    * * Description: The stage this citation governs.
    */
    get AppealStageID(): string {
        return this.Get('AppealStageID');
    }
    set AppealStageID(value: string) {
        this.Set('AppealStageID', value);
    }

    /**
    * * Field Name: StatuteSectionID
    * * Display Name: Statute Section
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Statute Sections (vwStatuteSections.ID)
    * * Description: The matching StatuteSection row, if the cited section is one we've ingested (Title 6 Articles 1.1/1.5 only).
    */
    get StatuteSectionID(): string | null {
        return this.Get('StatuteSectionID');
    }
    set StatuteSectionID(value: string | null) {
        this.Set('StatuteSectionID', value);
    }

    /**
    * * Field Name: CitationText
    * * Display Name: Citation Text
    * * SQL Data Type: nvarchar(100)
    * * Description: The citation exactly as written on the source document, e.g. "IC 6-1.1-15-1.2(d)-(g), (l)".
    */
    get CitationText(): string {
        return this.Get('CitationText');
    }
    set CitationText(value: string) {
        this.Set('CitationText', value);
    }

    /**
    * * Field Name: SubsectionReference
    * * Display Name: Subsection Reference
    * * SQL Data Type: nvarchar(50)
    * * Description: The specific subsection(s) cited within the section, e.g. "(d)-(g), (l)" — StatuteSection is section-granular, not subsection-granular, so this carries the finer reference the flowchart actually makes.
    */
    get SubsectionReference(): string | null {
        return this.Get('SubsectionReference');
    }
    set SubsectionReference(value: string | null) {
        this.Set('SubsectionReference', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: AppealStage
    * * Display Name: Appeal Stage Name
    * * SQL Data Type: nvarchar(200)
    */
    get AppealStage(): string {
        return this.Get('AppealStage');
    }
}


/**
 * Appeal Stages - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: AppealStage
 * * Base View: vwAppealStages
 * * @description One stage in the Indiana real property tax appeal lifecycle (statewide standard procedure). Normalized from Form 130's "Procedure for Appeal of Assessment" instructions so the sequence, deadlines, and governing statutes are queryable rather than embedded in document text.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Appeal Stages')
export class indianataxAppealStageEntity extends BaseEntity<indianataxAppealStageEntityType> {
    /**
    * Loads the Appeal Stages record from the database
    * @param ID: string - primary key value to load the Appeal Stages record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxAppealStageEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: StageOrder
    * * Display Name: Stage Order
    * * SQL Data Type: int
    * * Description: Sequence position in the normal-path appeal lifecycle (1 = first stage). Conditional escalation paths (e.g. skipping ahead if PTABOA misses its hearing deadline) are captured in Notes on the relevant stage, not as separate branching rows.
    */
    get StageOrder(): number {
        return this.Get('StageOrder');
    }
    set StageOrder(value: number) {
        this.Set('StageOrder', value);
    }

    /**
    * * Field Name: StageName
    * * Display Name: Stage Name
    * * SQL Data Type: nvarchar(200)
    * * Description: Short name for the stage.
    */
    get StageName(): string {
        return this.Get('StageName');
    }
    set StageName(value: string) {
        this.Set('StageName', value);
    }

    /**
    * * Field Name: AppealLevel
    * * Display Name: Appeal Level
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * County-PTABOA
    *   * State-IBTR
    *   * State-SupremeCourt
    *   * State-TaxCourt
    * * Description: Where in the appeal hierarchy this stage sits: County-PTABOA (the initial, county-level appeal), State-IBTR (state board, afforded deference to its factual determinations), State-TaxCourt (reviews IBTR determinations), or State-SupremeCourt (discretionary review of Tax Court determinations).
    */
    get AppealLevel(): 'County-PTABOA' | 'State-IBTR' | 'State-SupremeCourt' | 'State-TaxCourt' {
        return this.Get('AppealLevel');
    }
    set AppealLevel(value: 'County-PTABOA' | 'State-IBTR' | 'State-SupremeCourt' | 'State-TaxCourt') {
        this.Set('AppealLevel', value);
    }

    /**
    * * Field Name: ResponsibleParty
    * * Display Name: Responsible Party
    * * SQL Data Type: nvarchar(50)
    * * Description: Who acts at this stage (e.g. Taxpayer, Assessing Official, PTABOA, IBTR, Tax Court, Supreme Court).
    */
    get ResponsibleParty(): string | null {
        return this.Get('ResponsibleParty');
    }
    set ResponsibleParty(value: string | null) {
        this.Set('ResponsibleParty', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    * * Description: What happens at this stage.
    */
    get Description(): string {
        return this.Get('Description');
    }
    set Description(value: string) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: FormRequired
    * * Display Name: Form Required
    * * SQL Data Type: nvarchar(50)
    * * Description: The DLGF form required to act at this stage, if any (e.g. Form 130, Form 134, Form 131).
    */
    get FormRequired(): string | null {
        return this.Get('FormRequired');
    }
    set FormRequired(value: string | null) {
        this.Set('FormRequired', value);
    }

    /**
    * * Field Name: DeadlineDescription
    * * Display Name: Deadline Description
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Full deadline rule in prose — often conditional (varies by mailing date, property type, etc.), which is why this is text rather than only a day count.
    */
    get DeadlineDescription(): string | null {
        return this.Get('DeadlineDescription');
    }
    set DeadlineDescription(value: string | null) {
        this.Set('DeadlineDescription', value);
    }

    /**
    * * Field Name: DeadlineDays
    * * Display Name: Deadline Days
    * * SQL Data Type: int
    * * Description: A single day-count figure when the deadline reduces to one cleanly (e.g. 45, 180, 90) — NULL when the real rule is conditional and a single number would be misleading; see DeadlineDescription for the full rule either way.
    */
    get DeadlineDays(): number | null {
        return this.Get('DeadlineDays');
    }
    set DeadlineDays(value: number | null) {
        this.Set('DeadlineDays', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: NULL = statewide standard procedure (every row populated so far). Reserved for a future county-specific variant of this stage, since local practice can differ by county — a county override would be its own row with this set, not an edit to the statewide row.
    */
    get CountyNumber(): number | null {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number | null) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The document this stage was extracted from (e.g. Form 130's instructions).
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text notes — standard of review, burden of proof, escalation conditions, or other context that doesn't fit a structured column.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: DeadlineAnchorEvent
    * * Display Name: Deadline Anchor Event
    * * SQL Data Type: nvarchar(40)
    * * Value List Type: List
    * * Possible Values 
    *   * AppealFilingDate
    *   * Form11MailDate
    *   * IBTRFinalDeterminationDate
    *   * PTABOAOrderDate
    *   * PersonalPropertyNoticeDate
    *   * TaxCourtDeterminationDate
    * * Description: The real-world date that starts this stage's clock: Form11MailDate, PersonalPropertyNoticeDate, AppealFilingDate (Form 130 filed), PTABOAOrderDate (PTABOA order given to the parties), IBTRFinalDeterminationDate, or TaxCourtDeterminationDate. NULL = no fixed statutory deadline runs to the taxpayer at this stage (the assessing official's / IBTR's own timeline governs).
    */
    get DeadlineAnchorEvent(): 'AppealFilingDate' | 'Form11MailDate' | 'IBTRFinalDeterminationDate' | 'PTABOAOrderDate' | 'PersonalPropertyNoticeDate' | 'TaxCourtDeterminationDate' | null {
        return this.Get('DeadlineAnchorEvent');
    }
    set DeadlineAnchorEvent(value: 'AppealFilingDate' | 'Form11MailDate' | 'IBTRFinalDeterminationDate' | 'PTABOAOrderDate' | 'PersonalPropertyNoticeDate' | 'TaxCourtDeterminationDate' | null) {
        this.Set('DeadlineAnchorEvent', value);
    }

    /**
    * * Field Name: DeadlineBasis
    * * Display Name: Deadline Basis
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * CalendarRule
    *   * Discretionary
    *   * RelativeDays
    * * Description: How the deadline derives from DeadlineAnchorEvent: RelativeDays = anchor + DeadlineDays (45 / 90 / 180 ...); CalendarRule = the named rule in DeadlineCalendarRule; Discretionary = no hard deadline (e.g. Supreme Court review).
    */
    get DeadlineBasis(): 'CalendarRule' | 'Discretionary' | 'RelativeDays' | null {
        return this.Get('DeadlineBasis');
    }
    set DeadlineBasis(value: 'CalendarRule' | 'Discretionary' | 'RelativeDays' | null) {
        this.Set('DeadlineBasis', value);
    }

    /**
    * * Field Name: DeadlineCalendarRule
    * * Display Name: Deadline Calendar Rule
    * * SQL Data Type: nvarchar(60)
    * * Description: Stable token a rule engine switches on when DeadlineBasis = 'CalendarRule'. Stage 1 = 'IN-Form130-June15-split-May1': if Form11MailDate < May 1 of the assessment year the Form 130 is due June 15 of that year, else June 15 of the year tax statements are mailed (the pay year). One rule per token; the token is documented, the logic lives in code.
    */
    get DeadlineCalendarRule(): string | null {
        return this.Get('DeadlineCalendarRule');
    }
    set DeadlineCalendarRule(value: string | null) {
        this.Set('DeadlineCalendarRule', value);
    }

    /**
    * * Field Name: DeadlineHasAgencyLapseAlt
    * * Display Name: Has Agency Lapse Alternative
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: TRUE where, in addition to the primary deadline, the statute lets the taxpayer act "any time after the agency's own deadline lapses": Stage 3 (PTABOA misses its 180-day hearing window -> straight to IBTR) and Stage 6 (Tax Court petition may be filed once IBTR's own decision deadline passes).
    */
    get DeadlineHasAgencyLapseAlt(): boolean {
        return this.Get('DeadlineHasAgencyLapseAlt');
    }
    set DeadlineHasAgencyLapseAlt(value: boolean) {
        this.Set('DeadlineHasAgencyLapseAlt', value);
    }

    /**
    * * Field Name: InformalMeetingRequirement
    * * Display Name: Informal Meeting Requirement
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * NotOffered
    *   * Optional
    *   * Recommended
    *   * Required
    * * Description: Whether this stage's informal step is mandatory: Required / Optional / Recommended / NotOffered. Indiana Stage 2 (Preliminary Informal Meeting) = Required -- filing Form 130 obligates the assessing official to hold it. Other jurisdictions vary (the Faegre Appeal Deadline Tracking workbook tracks this per state).
    */
    get InformalMeetingRequirement(): 'NotOffered' | 'Optional' | 'Recommended' | 'Required' | null {
        return this.Get('InformalMeetingRequirement');
    }
    set InformalMeetingRequirement(value: 'NotOffered' | 'Optional' | 'Recommended' | 'Required' | null) {
        this.Set('InformalMeetingRequirement', value);
    }

    /**
    * * Field Name: EvidenceRequiredAtFiling
    * * Display Name: Evidence Required at Filing
    * * SQL Data Type: bit
    * * Description: TRUE only where the taxpayer must attach/submit substantive evidence AT filing to avoid rejection (e.g. AZ). Indiana Stage 1 = FALSE -- no evidence required at filing, but the exchange of available information IS required at the preliminary informal meeting (see the corresponding playbook note).
    */
    get EvidenceRequiredAtFiling(): boolean | null {
        return this.Get('EvidenceRequiredAtFiling');
    }
    set EvidenceRequiredAtFiling(value: boolean | null) {
        this.Set('EvidenceRequiredAtFiling', value);
    }

    /**
    * * Field Name: InformalDeadlineDescription
    * * Display Name: Informal Deadline Description
    * * SQL Data Type: nvarchar(300)
    * * Description: Free text for the informal step's own deadline where one exists separately from DeadlineDays / DeadlineCalendarRule (MO, CO). Indiana = NULL: the preliminary informal meeting is auto-triggered by the Form 130 filing with no separate taxpayer date to hit.
    */
    get InformalDeadlineDescription(): string | null {
        return this.Get('InformalDeadlineDescription');
    }
    set InformalDeadlineDescription(value: string | null) {
        this.Set('InformalDeadlineDescription', value);
    }
}


/**
 * Assessments - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: Assessment
 * * Base View: vwAssessments
 * * @description One row per (Parcel, AssessmentYear, Source) — the assessment-history table. Carries both the original assessed value and, once a PTABOA appeal is decided, the post-appeal value, so a single year can show both an original and an appealed determination.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Assessments')
export class indianataxAssessmentEntity extends BaseEntity<indianataxAssessmentEntityType> {
    /**
    * Loads the Assessments record from the database
    * @param ID: string - primary key value to load the Assessments record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxAssessmentEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for Assessments entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: All assessed property values (total, land, and improvement assessments) must be zero or positive amounts. Negative values are not permitted for any of these assessment fields, as they represent financial amounts that cannot be less than zero.
    * * Table-Level: For Marion FOIA 2026 and Marion PRC data sources, the sum of Original Land Assessment Value and Original Improvement Assessment Value must equal the Original Total Assessment Value within a tolerance of $1. This ensures data integrity for Marion County assessment records where component values must reconcile to the total.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateAssessmentValuesNonNegative(result);
        this.ValidateOriginalAssessmentValuesReconciliation(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * All assessed property values (total, land, and improvement assessments) must be zero or positive amounts. Negative values are not permitted for any of these assessment fields, as they represent financial amounts that cannot be less than zero.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateAssessmentValuesNonNegative(result: ValidationResult) {
    	if (this.OriginalTotalAV != null && this.OriginalTotalAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"OriginalTotalAV",
    			"Original total assessed value cannot be negative",
    			this.OriginalTotalAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.OriginalLandAV != null && this.OriginalLandAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"OriginalLandAV",
    			"Original land assessed value cannot be negative",
    			this.OriginalLandAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.OriginalImprovementAV != null && this.OriginalImprovementAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"OriginalImprovementAV",
    			"Original improvement assessed value cannot be negative",
    			this.OriginalImprovementAV,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * For Marion FOIA 2026 and Marion PRC data sources, the sum of Original Land Assessment Value and Original Improvement Assessment Value must equal the Original Total Assessment Value within a tolerance of $1. This ensures data integrity for Marion County assessment records where component values must reconcile to the total.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateOriginalAssessmentValuesReconciliation(result: ValidationResult) {
    	const isMarionSource = this.Source === 'marion_foia_2026' || this.Source === 'MarionPRC';
    	
    	if (isMarionSource && this.OriginalLandAV != null && this.OriginalImprovementAV != null && this.OriginalTotalAV != null) {
    		const componentSum = this.OriginalLandAV + this.OriginalImprovementAV;
    		const difference = Math.abs(componentSum - this.OriginalTotalAV);
    		
    		if (difference > 1) {
    			result.Errors.push(new ValidationErrorInfo(
    				"OriginalTotalAV",
    				"For Marion data sources, the Original Total Assessment Value must equal the sum of Original Land and Improvement values (within $1 tolerance). The difference is " + difference.toFixed(2) + ".",
    				this.OriginalTotalAV,
    				ValidationErrorType.Failure
    			));
    		}
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this assessment belongs to.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: AssessmentYear
    * * Display Name: Assessment Year
    * * SQL Data Type: smallint
    * * Description: The assessment/payable year this row represents (Indiana assessments are dated January 1 of the assessment year).
    */
    get AssessmentYear(): number {
        return this.Get('AssessmentYear');
    }
    set AssessmentYear(value: number) {
        this.Set('AssessmentYear', value);
    }

    /**
    * * Field Name: Source
    * * Display Name: Source
    * * SQL Data Type: nvarchar(50)
    * * Description: Where this assessment row came from, e.g. dlgf_gdb_2025, marion_foia_2026. Identifies the data pull/vintage.
    */
    get Source(): string {
        return this.Get('Source');
    }
    set Source(value: string) {
        this.Set('Source', value);
    }

    /**
    * * Field Name: PropertyClassCode
    * * Display Name: Property Class Code
    * * SQL Data Type: nvarchar(10)
    * * Description: DLGF property class code as recorded for this specific assessment year (may differ from the parcel's current PropertyClassCode).
    */
    get PropertyClassCode(): string | null {
        return this.Get('PropertyClassCode');
    }
    set PropertyClassCode(value: string | null) {
        this.Set('PropertyClassCode', value);
    }

    /**
    * * Field Name: OriginalLandAV
    * * Display Name: Original Land Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Originally assessed land value for the year, before any appeal.
    */
    get OriginalLandAV(): number | null {
        return this.Get('OriginalLandAV');
    }
    set OriginalLandAV(value: number | null) {
        this.Set('OriginalLandAV', value);
    }

    /**
    * * Field Name: OriginalImprovementAV
    * * Display Name: Original Improvement Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Originally assessed improvement value for the year, before any appeal.
    */
    get OriginalImprovementAV(): number | null {
        return this.Get('OriginalImprovementAV');
    }
    set OriginalImprovementAV(value: number | null) {
        this.Set('OriginalImprovementAV', value);
    }

    /**
    * * Field Name: OriginalTotalAV
    * * Display Name: Original Total Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Originally assessed total value for the year (land + improvement), before any appeal.
    */
    get OriginalTotalAV(): number | null {
        return this.Get('OriginalTotalAV');
    }
    set OriginalTotalAV(value: number | null) {
        this.Set('OriginalTotalAV', value);
    }

    /**
    * * Field Name: PTABOALandAV
    * * Display Name: PTABOA Land Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Land value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.
    */
    get PTABOALandAV(): number | null {
        return this.Get('PTABOALandAV');
    }
    set PTABOALandAV(value: number | null) {
        this.Set('PTABOALandAV', value);
    }

    /**
    * * Field Name: PTABOAImprovementAV
    * * Display Name: PTABOA Improvement Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Improvement value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.
    */
    get PTABOAImprovementAV(): number | null {
        return this.Get('PTABOAImprovementAV');
    }
    set PTABOAImprovementAV(value: number | null) {
        this.Set('PTABOAImprovementAV', value);
    }

    /**
    * * Field Name: PTABOATotalAV
    * * Display Name: PTABOA Total Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.
    */
    get PTABOATotalAV(): number | null {
        return this.Get('PTABOATotalAV');
    }
    set PTABOATotalAV(value: number | null) {
        this.Set('PTABOATotalAV', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The specific SourceDocument this assessment row was extracted from (the DLGF geodatabase pull, the Marion FOIA parcel-list CSV, or the parcel's Property Record Card). The free-text \`Source\` column is the short provenance label; this is the traceable document.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Reference
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Board Decisions - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: BoardDecision
 * * Base View: vwBoardDecisions
 * * @description A ruling from the Indiana Board of Tax Review (IBTR) — the state-level appeal that follows a county PTABOA determination. This is the precedent corpus the agent searches for similar prior appeals.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Board Decisions')
export class indianataxBoardDecisionEntity extends BaseEntity<indianataxBoardDecisionEntityType> {
    /**
    * Loads the Board Decisions record from the database
    * @param ID: string - primary key value to load the Board Decisions record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxBoardDecisionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CaseNumber
    * * Display Name: Case Number
    * * SQL Data Type: nvarchar(50)
    * * Description: IBTR case number.
    */
    get CaseNumber(): string {
        return this.Get('CaseNumber');
    }
    set CaseNumber(value: string) {
        this.Set('CaseNumber', value);
    }

    /**
    * * Field Name: PetitionerName
    * * Display Name: Petitioner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: Name of the petitioner (property owner who brought the appeal).
    */
    get PetitionerName(): string | null {
        return this.Get('PetitionerName');
    }
    set PetitionerName(value: string | null) {
        this.Set('PetitionerName', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: County the case originated in.
    */
    get CountyNumber(): number | null {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number | null) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this decision concerns, once matched. NULL until the case is reconciled to a known parcel.
    */
    get ParcelID(): string | null {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string | null) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: DecisionDate
    * * Display Name: Decision Date
    * * SQL Data Type: date
    * * Description: Date the IBTR issued its final determination.
    */
    get DecisionDate(): Date | null {
        return this.Get('DecisionDate');
    }
    set DecisionDate(value: Date | null) {
        this.Set('DecisionDate', value);
    }

    /**
    * * Field Name: Summary
    * * Display Name: Summary
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Short summary of the case and outcome, for quick scanning without opening the full decision text.
    */
    get Summary(): string | null {
        return this.Get('Summary');
    }
    set Summary(value: string | null) {
        this.Set('Summary', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The decision PDF this row was extracted from.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: AssessmentYearsInvolved
    * * Display Name: Assessment Years
    * * SQL Data Type: nvarchar(200)
    * * Description: Free-text assessment year(s) this decision concerns, e.g. "2019, 2020, 2021" — a single IBTR case can span multiple years and even multiple parcels, so this isn't normalized to a single year column.
    */
    get AssessmentYearsInvolved(): string | null {
        return this.Get('AssessmentYearsInvolved');
    }
    set AssessmentYearsInvolved(value: string | null) {
        this.Set('AssessmentYearsInvolved', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Reference
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string | null {
        return this.Get('Parcel');
    }
}


/**
 * Co Star Income Inputs - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CoStarIncomeInput
 * * Base View: vwCoStarIncomeInputs
 * * @description One row per CoStar property-inventory record (from /Users/abebenson/Projects/CoStar_Data exports): direct rent / vacancy / concession / physical inputs for a pro-forma income approach. Distinct from CoStarProperty (CoStar *sales* exports). Design: Indiana_Tax_Expert/docs/proposals/income-approach-costar.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Co Star Income Inputs')
export class indianataxCoStarIncomeInputEntity extends BaseEntity<indianataxCoStarIncomeInputEntityType> {
    /**
    * Loads the Co Star Income Inputs record from the database
    * @param ID: string - primary key value to load the Co Star Income Inputs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCoStarIncomeInputEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CoStarPropertyID
    * * Display Name: CoStar Property ID
    * * SQL Data Type: bigint
    * * Description: CoStar's PropertyID for the record.
    */
    get CoStarPropertyID(): number {
        return this.Get('CoStarPropertyID');
    }
    set CoStarPropertyID(value: number) {
        this.Set('CoStarPropertyID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: Resolved Parcel (matched on Parcel Number 1(Min)); NULL when off-book.
    */
    get ParcelID(): string | null {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string | null) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: ParcelNumberMin
    * * Display Name: Parcel Number Min
    * * SQL Data Type: nvarchar(30)
    */
    get ParcelNumberMin(): string | null {
        return this.Get('ParcelNumberMin');
    }
    set ParcelNumberMin(value: string | null) {
        this.Set('ParcelNumberMin', value);
    }

    /**
    * * Field Name: ParcelNumberMax
    * * Display Name: Parcel Number Max
    * * SQL Data Type: nvarchar(30)
    */
    get ParcelNumberMax(): string | null {
        return this.Get('ParcelNumberMax');
    }
    set ParcelNumberMax(value: string | null) {
        this.Set('ParcelNumberMax', value);
    }

    /**
    * * Field Name: MultiParcel
    * * Display Name: Multi-Parcel
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Property spans more than one parcel (Min <> Max).
    */
    get MultiParcel(): boolean {
        return this.Get('MultiParcel');
    }
    set MultiParcel(value: boolean) {
        this.Set('MultiParcel', value);
    }

    /**
    * * Field Name: PropertyTypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(20)
    */
    get PropertyTypeGroup(): string | null {
        return this.Get('PropertyTypeGroup');
    }
    set PropertyTypeGroup(value: string | null) {
        this.Set('PropertyTypeGroup', value);
    }

    /**
    * * Field Name: CoStarPropertyType
    * * Display Name: CoStar Property Type
    * * SQL Data Type: nvarchar(60)
    */
    get CoStarPropertyType(): string | null {
        return this.Get('CoStarPropertyType');
    }
    set CoStarPropertyType(value: string | null) {
        this.Set('CoStarPropertyType', value);
    }

    /**
    * * Field Name: SecondaryType
    * * Display Name: Secondary Type
    * * SQL Data Type: nvarchar(80)
    */
    get SecondaryType(): string | null {
        return this.Get('SecondaryType');
    }
    set SecondaryType(value: string | null) {
        this.Set('SecondaryType', value);
    }

    /**
    * * Field Name: Submarket
    * * Display Name: Submarket
    * * SQL Data Type: nvarchar(80)
    */
    get Submarket(): string | null {
        return this.Get('Submarket');
    }
    set Submarket(value: string | null) {
        this.Set('Submarket', value);
    }

    /**
    * * Field Name: City
    * * Display Name: City
    * * SQL Data Type: nvarchar(80)
    */
    get City(): string | null {
        return this.Get('City');
    }
    set City(value: string | null) {
        this.Set('City', value);
    }

    /**
    * * Field Name: PropertyName
    * * Display Name: Property Name
    * * SQL Data Type: nvarchar(200)
    */
    get PropertyName(): string | null {
        return this.Get('PropertyName');
    }
    set PropertyName(value: string | null) {
        this.Set('PropertyName', value);
    }

    /**
    * * Field Name: PropertyAddress
    * * Display Name: Property Address
    * * SQL Data Type: nvarchar(200)
    */
    get PropertyAddress(): string | null {
        return this.Get('PropertyAddress');
    }
    set PropertyAddress(value: string | null) {
        this.Set('PropertyAddress', value);
    }

    /**
    * * Field Name: StarRating
    * * Display Name: Star Rating
    * * SQL Data Type: decimal(2, 1)
    */
    get StarRating(): number | null {
        return this.Get('StarRating');
    }
    set StarRating(value: number | null) {
        this.Set('StarRating', value);
    }

    /**
    * * Field Name: YearBuilt
    * * Display Name: Year Built
    * * SQL Data Type: smallint
    */
    get YearBuilt(): number | null {
        return this.Get('YearBuilt');
    }
    set YearBuilt(value: number | null) {
        this.Set('YearBuilt', value);
    }

    /**
    * * Field Name: YearRenovated
    * * Display Name: Year Renovated
    * * SQL Data Type: smallint
    */
    get YearRenovated(): number | null {
        return this.Get('YearRenovated');
    }
    set YearRenovated(value: number | null) {
        this.Set('YearRenovated', value);
    }

    /**
    * * Field Name: Units
    * * Display Name: Units
    * * SQL Data Type: int
    */
    get Units(): number | null {
        return this.Get('Units');
    }
    set Units(value: number | null) {
        this.Set('Units', value);
    }

    /**
    * * Field Name: RBA
    * * Display Name: RBA
    * * SQL Data Type: int
    */
    get RBA(): number | null {
        return this.Get('RBA');
    }
    set RBA(value: number | null) {
        this.Set('RBA', value);
    }

    /**
    * * Field Name: Rooms
    * * Display Name: Rooms
    * * SQL Data Type: int
    */
    get Rooms(): number | null {
        return this.Get('Rooms');
    }
    set Rooms(value: number | null) {
        this.Set('Rooms', value);
    }

    /**
    * * Field Name: Beds
    * * Display Name: Beds
    * * SQL Data Type: int
    */
    get Beds(): number | null {
        return this.Get('Beds');
    }
    set Beds(value: number | null) {
        this.Set('Beds', value);
    }

    /**
    * * Field Name: AvgEffectiveRentPerUnit
    * * Display Name: Avg Effective Rent Per Unit
    * * SQL Data Type: decimal(10, 2)
    * * Description: Average EFFECTIVE rent per unit, MONTHLY (net of concessions), as CoStar reports it. Annualise x 12 for the pro forma.
    */
    get AvgEffectiveRentPerUnit(): number | null {
        return this.Get('AvgEffectiveRentPerUnit');
    }
    set AvgEffectiveRentPerUnit(value: number | null) {
        this.Set('AvgEffectiveRentPerUnit', value);
    }

    /**
    * * Field Name: AvgAskingRentPerUnit
    * * Display Name: Avg Asking Rent Per Unit
    * * SQL Data Type: decimal(10, 2)
    */
    get AvgAskingRentPerUnit(): number | null {
        return this.Get('AvgAskingRentPerUnit');
    }
    set AvgAskingRentPerUnit(value: number | null) {
        this.Set('AvgAskingRentPerUnit', value);
    }

    /**
    * * Field Name: AvgEffectiveRentPerSF
    * * Display Name: Avg Effective Rent Per SF
    * * SQL Data Type: decimal(8, 2)
    */
    get AvgEffectiveRentPerSF(): number | null {
        return this.Get('AvgEffectiveRentPerSF');
    }
    set AvgEffectiveRentPerSF(value: number | null) {
        this.Set('AvgEffectiveRentPerSF', value);
    }

    /**
    * * Field Name: AvgAskingRentPerSF
    * * Display Name: Avg Asking Rent Per SF
    * * SQL Data Type: decimal(8, 2)
    */
    get AvgAskingRentPerSF(): number | null {
        return this.Get('AvgAskingRentPerSF');
    }
    set AvgAskingRentPerSF(value: number | null) {
        this.Set('AvgAskingRentPerSF', value);
    }

    /**
    * * Field Name: ConcessionsPct
    * * Display Name: Concessions %
    * * SQL Data Type: decimal(6, 3)
    */
    get ConcessionsPct(): number | null {
        return this.Get('ConcessionsPct');
    }
    set ConcessionsPct(value: number | null) {
        this.Set('ConcessionsPct', value);
    }

    /**
    * * Field Name: VacancyPct
    * * Display Name: Vacancy %
    * * SQL Data Type: decimal(6, 3)
    * * Description: Vacancy percent (0-100) as reported by CoStar.
    */
    get VacancyPct(): number | null {
        return this.Get('VacancyPct');
    }
    set VacancyPct(value: number | null) {
        this.Set('VacancyPct', value);
    }

    /**
    * * Field Name: PercentLeased
    * * Display Name: Percent Leased
    * * SQL Data Type: decimal(6, 3)
    * * Description: Percent leased (0-100); office/retail/industrial where vacancy is not reported.
    */
    get PercentLeased(): number | null {
        return this.Get('PercentLeased');
    }
    set PercentLeased(value: number | null) {
        this.Set('PercentLeased', value);
    }

    /**
    * * Field Name: RentPerSFYrLow
    * * Display Name: Rent Per SF Year Low
    * * SQL Data Type: decimal(8, 2)
    */
    get RentPerSFYrLow(): number | null {
        return this.Get('RentPerSFYrLow');
    }
    set RentPerSFYrLow(value: number | null) {
        this.Set('RentPerSFYrLow', value);
    }

    /**
    * * Field Name: RentPerSFYrHigh
    * * Display Name: Rent Per SF Year High
    * * SQL Data Type: decimal(8, 2)
    */
    get RentPerSFYrHigh(): number | null {
        return this.Get('RentPerSFYrHigh');
    }
    set RentPerSFYrHigh(value: number | null) {
        this.Set('RentPerSFYrHigh', value);
    }

    /**
    * * Field Name: AverageWeightedRent
    * * Display Name: Average Weighted Rent
    * * SQL Data Type: decimal(8, 2)
    */
    get AverageWeightedRent(): number | null {
        return this.Get('AverageWeightedRent');
    }
    set AverageWeightedRent(value: number | null) {
        this.Set('AverageWeightedRent', value);
    }

    /**
    * * Field Name: CapRate
    * * Display Name: Cap Rate
    * * SQL Data Type: decimal(6, 4)
    * * Description: CoStar cap rate where disclosed on the inventory record (rare -- usually NULL).
    */
    get CapRate(): number | null {
        return this.Get('CapRate');
    }
    set CapRate(value: number | null) {
        this.Set('CapRate', value);
    }

    /**
    * * Field Name: TaxesTotal
    * * Display Name: Taxes Total
    * * SQL Data Type: decimal(14, 2)
    */
    get TaxesTotal(): number | null {
        return this.Get('TaxesTotal');
    }
    set TaxesTotal(value: number | null) {
        this.Set('TaxesTotal', value);
    }

    /**
    * * Field Name: LastSalePrice
    * * Display Name: Last Sale Price
    * * SQL Data Type: decimal(14, 2)
    */
    get LastSalePrice(): number | null {
        return this.Get('LastSalePrice');
    }
    set LastSalePrice(value: number | null) {
        this.Set('LastSalePrice', value);
    }

    /**
    * * Field Name: LastSaleDate
    * * Display Name: Last Sale Date
    * * SQL Data Type: date
    */
    get LastSaleDate(): Date | null {
        return this.Get('LastSaleDate');
    }
    set LastSaleDate(value: Date | null) {
        this.Set('LastSaleDate', value);
    }

    /**
    * * Field Name: SourceFile
    * * Display Name: Source File
    * * SQL Data Type: nvarchar(120)
    */
    get SourceFile(): string | null {
        return this.Get('SourceFile');
    }
    set SourceFile(value: string | null) {
        this.Set('SourceFile', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The CoStar export .xlsx this row was parsed from (SourceFile is the filename text). CoStar data is a labeled cross-check, not authority.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string | null {
        return this.Get('Parcel');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Co Star Properties - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CoStarProperty
 * * Base View: vwCoStarProperties
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Co Star Properties')
export class indianataxCoStarPropertyEntity extends BaseEntity<indianataxCoStarPropertyEntityType> {
    /**
    * Loads the Co Star Properties record from the database
    * @param ID: string - primary key value to load the Co Star Properties record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCoStarPropertyEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CoStarPropertyID
    * * Display Name: CoStar Property ID
    * * SQL Data Type: int
    * * Description: CoStar's own stable property identifier (their own "PropertyID" field) -- the natural key for this table, unique across all 8 imported export files.
    */
    get CoStarPropertyID(): number {
        return this.Get('CoStarPropertyID');
    }
    set CoStarPropertyID(value: number) {
        this.Set('CoStarPropertyID', value);
    }

    /**
    * * Field Name: SourceExportFile
    * * Display Name: Source Export File
    * * SQL Data Type: nvarchar(100)
    * * Description: Which of the 8 CoStar export files/size bands this property came from (e.g. "Multi-Family (100+ Units)") -- CoStar splits exports at 500 rows, so this is provenance, not a property-type classification (see CoStarPropertyType/CoStarSecondaryType for that).
    */
    get SourceExportFile(): string {
        return this.Get('SourceExportFile');
    }
    set SourceExportFile(value: string) {
        this.Set('SourceExportFile', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The Marion County Parcel matched from CoStar's "Parcel Number 1(Min)" (or, failing that, address). NULL means no match was found -- the row is still kept, not dropped. For a multi-parcel property (see CoStarIsMultiParcel) this is only ONE of the constituent parcels -- do not treat its AV as representing the whole property.
    */
    get ParcelID(): string | null {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string | null) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: CoStarSecondaryParcelID
    * * Display Name: CoStar Secondary Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The Marion County Parcel matched from CoStar's "Parcel Number 2(Max)", when it differs from ParcelID and itself resolves to a real parcel. NULL does not mean no second parcel exists -- CoStar's Min/Max is an outer bound, not a full membership list (see this migration's header comment); it means we could not resolve the Max end specifically.
    */
    get CoStarSecondaryParcelID(): string | null {
        return this.Get('CoStarSecondaryParcelID');
    }
    set CoStarSecondaryParcelID(value: string | null) {
        this.Set('CoStarSecondaryParcelID', value);
    }

    /**
    * * Field Name: CoStarIsMultiParcel
    * * Display Name: Is Multi-Parcel
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: True when CoStar's own "Parcel Number 1(Min)" and "Parcel Number 2(Max)" differ -- CoStar's signal that this property spans more than one parcel. Any per-unit/per-key/per-SF assessed-value figure derived from this row should be flagged as partial/incomplete when this is true, since we generally cannot enumerate every constituent parcel (see this migration's header comment) and CoStarNumberOfUnits/CoStarRBA/CoStarRooms are whole-property aggregates that a single matched parcel's AV does not fully cover.
    */
    get CoStarIsMultiParcel(): boolean {
        return this.Get('CoStarIsMultiParcel');
    }
    set CoStarIsMultiParcel(value: boolean) {
        this.Set('CoStarIsMultiParcel', value);
    }

    /**
    * * Field Name: MatchMethod
    * * Display Name: Match Method
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Address
    *   * ParcelNumberMax
    *   * ParcelNumberMin
    * * Description: How ParcelID was resolved: ParcelNumberMin (exact match on the stripped "Parcel Number 1(Min)"), ParcelNumberMax (Min failed, Max matched), Address (both parcel-number attempts failed, a normalized-address match succeeded), or NULL (nothing matched).
    */
    get MatchMethod(): 'Address' | 'ParcelNumberMax' | 'ParcelNumberMin' | null {
        return this.Get('MatchMethod');
    }
    set MatchMethod(value: 'Address' | 'ParcelNumberMax' | 'ParcelNumberMin' | null) {
        this.Set('MatchMethod', value);
    }

    /**
    * * Field Name: CoStarAddress
    * * Display Name: Address
    * * SQL Data Type: nvarchar(200)
    * * Description: CoStar "Property Address".
    */
    get CoStarAddress(): string | null {
        return this.Get('CoStarAddress');
    }
    set CoStarAddress(value: string | null) {
        this.Set('CoStarAddress', value);
    }

    /**
    * * Field Name: CoStarPropertyName
    * * Display Name: Property Name
    * * SQL Data Type: nvarchar(200)
    * * Description: CoStar "Property Name".
    */
    get CoStarPropertyName(): string | null {
        return this.Get('CoStarPropertyName');
    }
    set CoStarPropertyName(value: string | null) {
        this.Set('CoStarPropertyName', value);
    }

    /**
    * * Field Name: CoStarPropertyType
    * * Display Name: Property Type
    * * SQL Data Type: nvarchar(50)
    * * Description: CoStar "Property Type" (e.g. Multifamily, Office, Retail, Industrial, Hospitality).
    */
    get CoStarPropertyType(): string | null {
        return this.Get('CoStarPropertyType');
    }
    set CoStarPropertyType(value: string | null) {
        this.Set('CoStarPropertyType', value);
    }

    /**
    * * Field Name: CoStarSecondaryType
    * * Display Name: Secondary Type
    * * SQL Data Type: nvarchar(50)
    * * Description: CoStar "Secondary Type" -- a finer-grained classification than CoStarPropertyType.
    */
    get CoStarSecondaryType(): string | null {
        return this.Get('CoStarSecondaryType');
    }
    set CoStarSecondaryType(value: string | null) {
        this.Set('CoStarSecondaryType', value);
    }

    /**
    * * Field Name: CoStarCity
    * * Display Name: City
    * * SQL Data Type: nvarchar(100)
    * * Description: CoStar "City".
    */
    get CoStarCity(): string | null {
        return this.Get('CoStarCity');
    }
    set CoStarCity(value: string | null) {
        this.Set('CoStarCity', value);
    }

    /**
    * * Field Name: CoStarState
    * * Display Name: State
    * * SQL Data Type: nvarchar(10)
    * * Description: CoStar "State".
    */
    get CoStarState(): string | null {
        return this.Get('CoStarState');
    }
    set CoStarState(value: string | null) {
        this.Set('CoStarState', value);
    }

    /**
    * * Field Name: CoStarZip
    * * Display Name: Zip Code
    * * SQL Data Type: nvarchar(20)
    * * Description: CoStar "Zip".
    */
    get CoStarZip(): string | null {
        return this.Get('CoStarZip');
    }
    set CoStarZip(value: string | null) {
        this.Set('CoStarZip', value);
    }

    /**
    * * Field Name: CoStarCountyName
    * * Display Name: County Name
    * * SQL Data Type: nvarchar(50)
    * * Description: CoStar "County Name".
    */
    get CoStarCountyName(): string | null {
        return this.Get('CoStarCountyName');
    }
    set CoStarCountyName(value: string | null) {
        this.Set('CoStarCountyName', value);
    }

    /**
    * * Field Name: CoStarLatitude
    * * Display Name: Latitude
    * * SQL Data Type: decimal(10, 6)
    * * Description: CoStar "Latitude".
    */
    get CoStarLatitude(): number | null {
        return this.Get('CoStarLatitude');
    }
    set CoStarLatitude(value: number | null) {
        this.Set('CoStarLatitude', value);
    }

    /**
    * * Field Name: CoStarLongitude
    * * Display Name: Longitude
    * * SQL Data Type: decimal(10, 6)
    * * Description: CoStar "Longitude".
    */
    get CoStarLongitude(): number | null {
        return this.Get('CoStarLongitude');
    }
    set CoStarLongitude(value: number | null) {
        this.Set('CoStarLongitude', value);
    }

    /**
    * * Field Name: CoStarParcelNumberMin
    * * Display Name: Parcel Number Min
    * * SQL Data Type: nvarchar(40)
    * * Description: CoStar "Parcel Number 1(Min)", raw as exported (with punctuation, e.g. "49-11-01-240-261.002-101") -- kept for audit; ParcelID is the resolved match after stripping punctuation.
    */
    get CoStarParcelNumberMin(): string | null {
        return this.Get('CoStarParcelNumberMin');
    }
    set CoStarParcelNumberMin(value: string | null) {
        this.Set('CoStarParcelNumberMin', value);
    }

    /**
    * * Field Name: CoStarParcelNumberMax
    * * Display Name: Parcel Number Max
    * * SQL Data Type: nvarchar(40)
    * * Description: CoStar "Parcel Number 2(Max)", raw as exported. Equal to CoStarParcelNumberMin for a single-parcel property; different for a multi-parcel one (see CoStarIsMultiParcel).
    */
    get CoStarParcelNumberMax(): string | null {
        return this.Get('CoStarParcelNumberMax');
    }
    set CoStarParcelNumberMax(value: string | null) {
        this.Set('CoStarParcelNumberMax', value);
    }

    /**
    * * Field Name: CoStarOwnerName
    * * Display Name: Owner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: CoStar "Owner Name" -- CoStar carries three distinct owner fields (this one, RecordedOwnerName, TrueOwnerName) that routinely disagree (e.g. a management company name here vs. the actual holding LLC in RecordedOwnerName) -- do not assume they match each other or indiana_tax.CountyAssessorRecord.OwnerName.
    */
    get CoStarOwnerName(): string | null {
        return this.Get('CoStarOwnerName');
    }
    set CoStarOwnerName(value: string | null) {
        this.Set('CoStarOwnerName', value);
    }

    /**
    * * Field Name: CoStarRecordedOwnerName
    * * Display Name: Recorded Owner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: CoStar "Recorded Owner Name" -- see CoStarOwnerName's comment on why this often differs from it.
    */
    get CoStarRecordedOwnerName(): string | null {
        return this.Get('CoStarRecordedOwnerName');
    }
    set CoStarRecordedOwnerName(value: string | null) {
        this.Set('CoStarRecordedOwnerName', value);
    }

    /**
    * * Field Name: CoStarTrueOwnerName
    * * Display Name: True Owner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: CoStar "True Owner Name" -- see CoStarOwnerName's comment.
    */
    get CoStarTrueOwnerName(): string | null {
        return this.Get('CoStarTrueOwnerName');
    }
    set CoStarTrueOwnerName(value: string | null) {
        this.Set('CoStarTrueOwnerName', value);
    }

    /**
    * * Field Name: CoStarNumberOfUnits
    * * Display Name: Number of Units
    * * SQL Data Type: int
    * * Description: CoStar "Number of Units" -- whole-property unit count for multifamily/student housing, the correct denominator for a per-unit comparison (see CoStarIsMultiParcel for why the AV numerator may only be partial).
    */
    get CoStarNumberOfUnits(): number | null {
        return this.Get('CoStarNumberOfUnits');
    }
    set CoStarNumberOfUnits(value: number | null) {
        this.Set('CoStarNumberOfUnits', value);
    }

    /**
    * * Field Name: CoStarRooms
    * * Display Name: Rooms
    * * SQL Data Type: int
    * * Description: CoStar "Rooms" -- whole-property room/key count for hospitality properties.
    */
    get CoStarRooms(): number | null {
        return this.Get('CoStarRooms');
    }
    set CoStarRooms(value: number | null) {
        this.Set('CoStarRooms', value);
    }

    /**
    * * Field Name: CoStarRBA
    * * Display Name: RBA (Square Feet)
    * * SQL Data Type: int
    * * Description: CoStar "RBA" (Rentable Building Area, SF) -- whole-property building square footage for office/industrial/retail.
    */
    get CoStarRBA(): number | null {
        return this.Get('CoStarRBA');
    }
    set CoStarRBA(value: number | null) {
        this.Set('CoStarRBA', value);
    }

    /**
    * * Field Name: CoStarTotalBuildings
    * * Display Name: Total Buildings
    * * SQL Data Type: int
    * * Description: CoStar "Total Buildings" -- number of distinct buildings on the property (independent of parcel count).
    */
    get CoStarTotalBuildings(): number | null {
        return this.Get('CoStarTotalBuildings');
    }
    set CoStarTotalBuildings(value: number | null) {
        this.Set('CoStarTotalBuildings', value);
    }

    /**
    * * Field Name: CoStarLandAreaAcres
    * * Display Name: Land Area (Acres)
    * * SQL Data Type: decimal(10, 4)
    * * Description: CoStar "Land Area (AC)".
    */
    get CoStarLandAreaAcres(): number | null {
        return this.Get('CoStarLandAreaAcres');
    }
    set CoStarLandAreaAcres(value: number | null) {
        this.Set('CoStarLandAreaAcres', value);
    }

    /**
    * * Field Name: CoStarLandAreaSF
    * * Display Name: Land Area (Square Feet)
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "Land Area (SF)".
    */
    get CoStarLandAreaSF(): number | null {
        return this.Get('CoStarLandAreaSF');
    }
    set CoStarLandAreaSF(value: number | null) {
        this.Set('CoStarLandAreaSF', value);
    }

    /**
    * * Field Name: CoStarNumberOfStories
    * * Display Name: Number of Stories
    * * SQL Data Type: int
    * * Description: CoStar "Number of Stories".
    */
    get CoStarNumberOfStories(): number | null {
        return this.Get('CoStarNumberOfStories');
    }
    set CoStarNumberOfStories(value: number | null) {
        this.Set('CoStarNumberOfStories', value);
    }

    /**
    * * Field Name: CoStarYearBuilt
    * * Display Name: Year Built
    * * SQL Data Type: smallint
    * * Description: CoStar "Year Built".
    */
    get CoStarYearBuilt(): number | null {
        return this.Get('CoStarYearBuilt');
    }
    set CoStarYearBuilt(value: number | null) {
        this.Set('CoStarYearBuilt', value);
    }

    /**
    * * Field Name: CoStarYearRenovated
    * * Display Name: Year Renovated
    * * SQL Data Type: smallint
    * * Description: CoStar "Year Renovated".
    */
    get CoStarYearRenovated(): number | null {
        return this.Get('CoStarYearRenovated');
    }
    set CoStarYearRenovated(value: number | null) {
        this.Set('CoStarYearRenovated', value);
    }

    /**
    * * Field Name: CoStarBuildingClass
    * * Display Name: Building Class
    * * SQL Data Type: nvarchar(10)
    * * Description: CoStar "Building Class" (A/B/C).
    */
    get CoStarBuildingClass(): string | null {
        return this.Get('CoStarBuildingClass');
    }
    set CoStarBuildingClass(value: string | null) {
        this.Set('CoStarBuildingClass', value);
    }

    /**
    * * Field Name: CoStarStarRating
    * * Display Name: Star Rating
    * * SQL Data Type: tinyint
    * * Description: CoStar "Star Rating" (1-5).
    */
    get CoStarStarRating(): number | null {
        return this.Get('CoStarStarRating');
    }
    set CoStarStarRating(value: number | null) {
        this.Set('CoStarStarRating', value);
    }

    /**
    * * Field Name: CoStarLastSalePrice
    * * Display Name: Last Sale Price
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "Last Sale Price".
    */
    get CoStarLastSalePrice(): number | null {
        return this.Get('CoStarLastSalePrice');
    }
    set CoStarLastSalePrice(value: number | null) {
        this.Set('CoStarLastSalePrice', value);
    }

    /**
    * * Field Name: CoStarLastSaleDate
    * * Display Name: Last Sale Date
    * * SQL Data Type: date
    * * Description: CoStar "Last Sale Date".
    */
    get CoStarLastSaleDate(): Date | null {
        return this.Get('CoStarLastSaleDate');
    }
    set CoStarLastSaleDate(value: Date | null) {
        this.Set('CoStarLastSaleDate', value);
    }

    /**
    * * Field Name: CoStarForSalePrice
    * * Display Name: For Sale Price
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "For Sale Price" -- current asking price, if actively listed (see CoStarForSaleStatus).
    */
    get CoStarForSalePrice(): number | null {
        return this.Get('CoStarForSalePrice');
    }
    set CoStarForSalePrice(value: number | null) {
        this.Set('CoStarForSalePrice', value);
    }

    /**
    * * Field Name: CoStarForSalePricePerUnit
    * * Display Name: For Sale Price Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "For Sale Price Per Unit".
    */
    get CoStarForSalePricePerUnit(): number | null {
        return this.Get('CoStarForSalePricePerUnit');
    }
    set CoStarForSalePricePerUnit(value: number | null) {
        this.Set('CoStarForSalePricePerUnit', value);
    }

    /**
    * * Field Name: CoStarForSalePricePerSF
    * * Display Name: For Sale Price Per SF
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "For Sale Price Per SF".
    */
    get CoStarForSalePricePerSF(): number | null {
        return this.Get('CoStarForSalePricePerSF');
    }
    set CoStarForSalePricePerSF(value: number | null) {
        this.Set('CoStarForSalePricePerSF', value);
    }

    /**
    * * Field Name: CoStarForSalePricePerRoom
    * * Display Name: For Sale Price Per Room
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "For Sale Price Per Room" -- hospitality only.
    */
    get CoStarForSalePricePerRoom(): number | null {
        return this.Get('CoStarForSalePricePerRoom');
    }
    set CoStarForSalePricePerRoom(value: number | null) {
        this.Set('CoStarForSalePricePerRoom', value);
    }

    /**
    * * Field Name: CoStarForSaleStatus
    * * Display Name: For Sale Status
    * * SQL Data Type: nvarchar(10)
    * * Description: CoStar "For Sale Status".
    */
    get CoStarForSaleStatus(): string | null {
        return this.Get('CoStarForSaleStatus');
    }
    set CoStarForSaleStatus(value: string | null) {
        this.Set('CoStarForSaleStatus', value);
    }

    /**
    * * Field Name: CoStarCapRate
    * * Display Name: Cap Rate (%)
    * * SQL Data Type: decimal(9, 4)
    * * Description: CoStar "Cap Rate", already a plain decimal percentage (e.g. 6.12 means 6.12%), not a 0-1 fraction.
    */
    get CoStarCapRate(): number | null {
        return this.Get('CoStarCapRate');
    }
    set CoStarCapRate(value: number | null) {
        this.Set('CoStarCapRate', value);
    }

    /**
    * * Field Name: CoStarTaxesTotal
    * * Display Name: Total Taxes
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "Taxes Total" -- CoStar's own figure for this property's total tax bill, useful as an independent cross-check against indiana_tax.TaxHistoryYear/CountyAssessorRecord.NetAnnualTax for the matched parcel(s).
    */
    get CoStarTaxesTotal(): number | null {
        return this.Get('CoStarTaxesTotal');
    }
    set CoStarTaxesTotal(value: number | null) {
        this.Set('CoStarTaxesTotal', value);
    }

    /**
    * * Field Name: CoStarTaxesPerSF
    * * Display Name: Taxes Per SF
    * * SQL Data Type: decimal(9, 4)
    * * Description: CoStar "Taxes Per SF".
    */
    get CoStarTaxesPerSF(): number | null {
        return this.Get('CoStarTaxesPerSF');
    }
    set CoStarTaxesPerSF(value: number | null) {
        this.Set('CoStarTaxesPerSF', value);
    }

    /**
    * * Field Name: CoStarTaxYear
    * * Display Name: Tax Year
    * * SQL Data Type: smallint
    * * Description: CoStar "Tax Year" -- the year CoStarTaxesTotal/CoStarTaxesPerSF apply to; compare against indiana_tax.Assessment.AssessmentYear before treating the two sources as describing the same year.
    */
    get CoStarTaxYear(): number | null {
        return this.Get('CoStarTaxYear');
    }
    set CoStarTaxYear(value: number | null) {
        this.Set('CoStarTaxYear', value);
    }

    /**
    * * Field Name: CoStarAvgAskingPerSF
    * * Display Name: Avg Asking Per SF
    * * SQL Data Type: decimal(9, 4)
    * * Description: CoStar "Avg Asking/SF".
    */
    get CoStarAvgAskingPerSF(): number | null {
        return this.Get('CoStarAvgAskingPerSF');
    }
    set CoStarAvgAskingPerSF(value: number | null) {
        this.Set('CoStarAvgAskingPerSF', value);
    }

    /**
    * * Field Name: CoStarAvgAskingPerUnit
    * * Display Name: Avg Asking Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "Avg Asking/Unit".
    */
    get CoStarAvgAskingPerUnit(): number | null {
        return this.Get('CoStarAvgAskingPerUnit');
    }
    set CoStarAvgAskingPerUnit(value: number | null) {
        this.Set('CoStarAvgAskingPerUnit', value);
    }

    /**
    * * Field Name: CoStarAvgEffectivePerSF
    * * Display Name: Avg Effective Per SF
    * * SQL Data Type: decimal(9, 4)
    * * Description: CoStar "Avg Effective/SF".
    */
    get CoStarAvgEffectivePerSF(): number | null {
        return this.Get('CoStarAvgEffectivePerSF');
    }
    set CoStarAvgEffectivePerSF(value: number | null) {
        this.Set('CoStarAvgEffectivePerSF', value);
    }

    /**
    * * Field Name: CoStarAvgEffectivePerUnit
    * * Display Name: Avg Effective Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: CoStar "Avg Effective/Unit".
    */
    get CoStarAvgEffectivePerUnit(): number | null {
        return this.Get('CoStarAvgEffectivePerUnit');
    }
    set CoStarAvgEffectivePerUnit(value: number | null) {
        this.Set('CoStarAvgEffectivePerUnit', value);
    }

    /**
    * * Field Name: CoStarPercentLeased
    * * Display Name: Percent Leased (%)
    * * SQL Data Type: decimal(6, 3)
    * * Description: CoStar "Percent Leased", already a plain decimal percentage.
    */
    get CoStarPercentLeased(): number | null {
        return this.Get('CoStarPercentLeased');
    }
    set CoStarPercentLeased(value: number | null) {
        this.Set('CoStarPercentLeased', value);
    }

    /**
    * * Field Name: CoStarVacancyPct
    * * Display Name: Vacancy Rate (%)
    * * SQL Data Type: decimal(6, 3)
    * * Description: CoStar "Vacancy %", already a plain decimal percentage.
    */
    get CoStarVacancyPct(): number | null {
        return this.Get('CoStarVacancyPct');
    }
    set CoStarVacancyPct(value: number | null) {
        this.Set('CoStarVacancyPct', value);
    }

    /**
    * * Field Name: CoStarDaysOnMarket
    * * Display Name: Days On Market
    * * SQL Data Type: int
    * * Description: CoStar "Days On Market".
    */
    get CoStarDaysOnMarket(): number | null {
        return this.Get('CoStarDaysOnMarket');
    }
    set CoStarDaysOnMarket(value: number | null) {
        this.Set('CoStarDaysOnMarket', value);
    }

    /**
    * * Field Name: CoStarSubmarketName
    * * Display Name: Submarket Name
    * * SQL Data Type: nvarchar(100)
    * * Description: CoStar "Submarket Name".
    */
    get CoStarSubmarketName(): string | null {
        return this.Get('CoStarSubmarketName');
    }
    set CoStarSubmarketName(value: string | null) {
        this.Set('CoStarSubmarketName', value);
    }

    /**
    * * Field Name: CoStarMarketName
    * * Display Name: Market Name
    * * SQL Data Type: nvarchar(100)
    * * Description: CoStar "Market Name".
    */
    get CoStarMarketName(): string | null {
        return this.Get('CoStarMarketName');
    }
    set CoStarMarketName(value: string | null) {
        this.Set('CoStarMarketName', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The CoStar export .xlsx this row was parsed from (SourceExportFile is the short label). CoStar data is a labeled cross-check, not authority.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Display
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string | null {
        return this.Get('Parcel');
    }

    /**
    * * Field Name: CoStarSecondaryParcel
    * * Display Name: Secondary Parcel Display
    * * SQL Data Type: nvarchar(30)
    */
    get CoStarSecondaryParcel(): string | null {
        return this.Get('CoStarSecondaryParcel');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: System Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: System Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Comparable Assessment Members - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ComparableAssessmentMember
 * * Base View: vwComparableAssessmentMembers
 * * @description One comparable property within a ComparableAssessmentSet: its similarity score + component deltas, the analyst's include flag, and a snapshot of its physical attributes and value tracks (Original / Appealed / Effective) for the set's focus year.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Comparable Assessment Members')
export class indianataxComparableAssessmentMemberEntity extends BaseEntity<indianataxComparableAssessmentMemberEntityType> {
    /**
    * Loads the Comparable Assessment Members record from the database
    * @param ID: string - primary key value to load the Comparable Assessment Members record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxComparableAssessmentMemberEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ComparableAssessmentSetID
    * * Display Name: Assessment Set
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Comparable Assessment Sets (vwComparableAssessmentSets.ID)
    * * Description: The set this comp belongs to.
    */
    get ComparableAssessmentSetID(): string {
        return this.Get('ComparableAssessmentSetID');
    }
    set ComparableAssessmentSetID(value: string) {
        this.Set('ComparableAssessmentSetID', value);
    }

    /**
    * * Field Name: ComparableParcelID
    * * Display Name: Comparable Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The comparable parcel.
    */
    get ComparableParcelID(): string {
        return this.Get('ComparableParcelID');
    }
    set ComparableParcelID(value: string) {
        this.Set('ComparableParcelID', value);
    }

    /**
    * * Field Name: GeographyBucket
    * * Display Name: Geography Bucket
    * * SQL Data Type: nvarchar(14)
    * * Value List Type: List
    * * Possible Values 
    *   * County
    *   * Neighborhood
    * * Description: Which list this comp came from: Neighborhood (same code, ungated) or County (county-wide, strict physical gate).
    */
    get GeographyBucket(): 'County' | 'Neighborhood' {
        return this.Get('GeographyBucket');
    }
    set GeographyBucket(value: 'County' | 'Neighborhood') {
        this.Set('GeographyBucket', value);
    }

    /**
    * * Field Name: SimilarityScore
    * * Display Name: Similarity Score
    * * SQL Data Type: decimal(9, 4)
    * * Description: Weighted physical-similarity distance (lower = more similar).
    */
    get SimilarityScore(): number | null {
        return this.Get('SimilarityScore');
    }
    set SimilarityScore(value: number | null) {
        this.Set('SimilarityScore', value);
    }

    /**
    * * Field Name: SizeLnRatio
    * * Display Name: Size Ln Ratio
    * * SQL Data Type: decimal(9, 4)
    * * Description: abs(ln(subject building SF / comp building SF)) -- the size-match component, exposed for review.
    */
    get SizeLnRatio(): number | null {
        return this.Get('SizeLnRatio');
    }
    set SizeLnRatio(value: number | null) {
        this.Set('SizeLnRatio', value);
    }

    /**
    * * Field Name: EffectiveYearDelta
    * * Display Name: Effective Year Delta
    * * SQL Data Type: smallint
    * * Description: abs(subject effective year - comp effective year).
    */
    get EffectiveYearDelta(): number | null {
        return this.Get('EffectiveYearDelta');
    }
    set EffectiveYearDelta(value: number | null) {
        this.Set('EffectiveYearDelta', value);
    }

    /**
    * * Field Name: GradeDelta
    * * Display Name: Grade Delta
    * * SQL Data Type: decimal(5, 2)
    * * Description: abs difference of the mapped grade ordinal (C=3, C+=3.33, B=4, ...).
    */
    get GradeDelta(): number | null {
        return this.Get('GradeDelta');
    }
    set GradeDelta(value: number | null) {
        this.Set('GradeDelta', value);
    }

    /**
    * * Field Name: ClassMatchLevel
    * * Display Name: Class Match Level
    * * SQL Data Type: nvarchar(12)
    * * Value List Type: List
    * * Possible Values 
    *   * 3-digit
    *   * exact
    *   * group-only
    * * Description: How closely the state class codes match: exact (5-digit), 3-digit, or group-only.
    */
    get ClassMatchLevel(): '3-digit' | 'exact' | 'group-only' | null {
        return this.Get('ClassMatchLevel');
    }
    set ClassMatchLevel(value: '3-digit' | 'exact' | 'group-only' | null) {
        this.Set('ClassMatchLevel', value);
    }

    /**
    * * Field Name: SimilarityBreakdown
    * * Display Name: Similarity Breakdown
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON: the full weighted-component breakdown behind SimilarityScore.
    */
    get SimilarityBreakdown(): string | null {
        return this.Get('SimilarityBreakdown');
    }
    set SimilarityBreakdown(value: string | null) {
        this.Set('SimilarityBreakdown', value);
    }

    /**
    * * Field Name: IsSelected
    * * Display Name: Selected
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Analyst's choice: is this comp included in the headline mean/median? Builder seeds this (Neighborhood + gated County members start selected).
    */
    get IsSelected(): boolean {
        return this.Get('IsSelected');
    }
    set IsSelected(value: boolean) {
        this.Set('IsSelected', value);
    }

    /**
    * * Field Name: SortOrder
    * * Display Name: Sort Order
    * * SQL Data Type: int
    * * Description: Display order within the bucket (1 = most similar).
    */
    get SortOrder(): number | null {
        return this.Get('SortOrder');
    }
    set SortOrder(value: number | null) {
        this.Set('SortOrder', value);
    }

    /**
    * * Field Name: AnalystNote
    * * Display Name: Analyst Note
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text note on this comp (why kept / dropped).
    */
    get AnalystNote(): string | null {
        return this.Get('AnalystNote');
    }
    set AnalystNote(value: string | null) {
        this.Set('AnalystNote', value);
    }

    /**
    * * Field Name: ComparableBuildingSqFt
    * * Display Name: Building Square Feet
    * * SQL Data Type: int
    * * Description: Snapshot: comp building SF at generation time.
    */
    get ComparableBuildingSqFt(): number | null {
        return this.Get('ComparableBuildingSqFt');
    }
    set ComparableBuildingSqFt(value: number | null) {
        this.Set('ComparableBuildingSqFt', value);
    }

    /**
    * * Field Name: ComparableUnitCount
    * * Display Name: Unit Count
    * * SQL Data Type: decimal(12, 2)
    * * Description: Snapshot: comp unit count (trustworthy-filtered) at generation time.
    */
    get ComparableUnitCount(): number | null {
        return this.Get('ComparableUnitCount');
    }
    set ComparableUnitCount(value: number | null) {
        this.Set('ComparableUnitCount', value);
    }

    /**
    * * Field Name: ComparableEffectiveYear
    * * Display Name: Effective Year
    * * SQL Data Type: smallint
    * * Description: Snapshot: comp effective year.
    */
    get ComparableEffectiveYear(): number | null {
        return this.Get('ComparableEffectiveYear');
    }
    set ComparableEffectiveYear(value: number | null) {
        this.Set('ComparableEffectiveYear', value);
    }

    /**
    * * Field Name: ComparableGradeCode
    * * Display Name: Grade Code
    * * SQL Data Type: nvarchar(8)
    * * Description: Snapshot: comp grade code.
    */
    get ComparableGradeCode(): string | null {
        return this.Get('ComparableGradeCode');
    }
    set ComparableGradeCode(value: string | null) {
        this.Set('ComparableGradeCode', value);
    }

    /**
    * * Field Name: DenomValue
    * * Display Name: Denominator Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The comp's own denominator for the set's unit of comparison.
    */
    get DenomValue(): number | null {
        return this.Get('DenomValue');
    }
    set DenomValue(value: number | null) {
        this.Set('DenomValue', value);
    }

    /**
    * * Field Name: OriginalAV
    * * Display Name: Original Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Comp as-noticed Original total AV for the focus year.
    */
    get OriginalAV(): number | null {
        return this.Get('OriginalAV');
    }
    set OriginalAV(value: number | null) {
        this.Set('OriginalAV', value);
    }

    /**
    * * Field Name: AppealedAV
    * * Display Name: Appealed Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Comp appealed total AV for the focus year (PTABOA After or IBTR/Final determination), NULL if the comp did not appeal that year.
    */
    get AppealedAV(): number | null {
        return this.Get('AppealedAV');
    }
    set AppealedAV(value: number | null) {
        this.Set('AppealedAV', value);
    }

    /**
    * * Field Name: AppealLevel
    * * Display Name: Appeal Level
    * * SQL Data Type: nvarchar(16)
    * * Description: Level the appealed value came from: PTABOA or IBTR/Final.
    */
    get AppealLevel(): string | null {
        return this.Get('AppealLevel');
    }
    set AppealLevel(value: string | null) {
        this.Set('AppealLevel', value);
    }

    /**
    * * Field Name: AppealPctChange
    * * Display Name: Appeal Percent Change
    * * SQL Data Type: decimal(7, 2)
    * * Description: Percent change of the appealed value vs the pre-appeal base (negative = reduction).
    */
    get AppealPctChange(): number | null {
        return this.Get('AppealPctChange');
    }
    set AppealPctChange(value: number | null) {
        this.Set('AppealPctChange', value);
    }

    /**
    * * Field Name: AppealRepresentative
    * * Display Name: Appeal Representative
    * * SQL Data Type: nvarchar(200)
    * * Description: Tax representative of record on the comp's appeal, if any.
    */
    get AppealRepresentative(): string | null {
        return this.Get('AppealRepresentative');
    }
    set AppealRepresentative(value: string | null) {
        this.Set('AppealRepresentative', value);
    }

    /**
    * * Field Name: EffectiveAV
    * * Display Name: Effective Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Comp Effective total AV for the focus year (Appealed if present else Original).
    */
    get EffectiveAV(): number | null {
        return this.Get('EffectiveAV');
    }
    set EffectiveAV(value: number | null) {
        this.Set('EffectiveAV', value);
    }

    /**
    * * Field Name: OriginalPerUnit
    * * Display Name: Original Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: OriginalAV / DenomValue.
    */
    get OriginalPerUnit(): number | null {
        return this.Get('OriginalPerUnit');
    }
    set OriginalPerUnit(value: number | null) {
        this.Set('OriginalPerUnit', value);
    }

    /**
    * * Field Name: EffectivePerUnit
    * * Display Name: Effective Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: EffectiveAV / DenomValue -- the value that flows into the headline mean/median when IsSelected.
    */
    get EffectivePerUnit(): number | null {
        return this.Get('EffectivePerUnit');
    }
    set EffectivePerUnit(value: number | null) {
        this.Set('EffectivePerUnit', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: ComparableParcel
    * * Display Name: Comparable Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get ComparableParcel(): string {
        return this.Get('ComparableParcel');
    }
}


/**
 * Comparable Assessment Sets - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ComparableAssessmentSet
 * * Base View: vwComparableAssessmentSets
 * * @description A comparable-assessments (uniformity / equity) workup for one subject parcel: the ranked Neighborhood and County-wide lists of physically similar properties, the analyst's include/exclude choices (ComparableAssessmentMember), and the headline per-unit comparison. Design: Indiana_Tax_Expert/docs/proposals/comparable-assessments.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Comparable Assessment Sets')
export class indianataxComparableAssessmentSetEntity extends BaseEntity<indianataxComparableAssessmentSetEntityType> {
    /**
    * Loads the Comparable Assessment Sets record from the database
    * @param ID: string - primary key value to load the Comparable Assessment Sets record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxComparableAssessmentSetEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: SubjectParcelID
    * * Display Name: Subject Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The subject parcel being analysed.
    */
    get SubjectParcelID(): string {
        return this.Get('SubjectParcelID');
    }
    set SubjectParcelID(value: string) {
        this.Set('SubjectParcelID', value);
    }

    /**
    * * Field Name: FocusYear
    * * Display Name: Focus Year
    * * SQL Data Type: smallint
    * * Description: The assessment year the per-unit comparison is struck for.
    */
    get FocusYear(): number {
        return this.Get('FocusYear');
    }
    set FocusYear(value: number) {
        this.Set('FocusYear', value);
    }

    /**
    * * Field Name: MethodologyVersion
    * * Display Name: Methodology Version
    * * SQL Data Type: nvarchar(30)
    * * Description: Version tag for the builder logic that produced this set (e.g. "comps-v1-2026-08-30"). Lets a re-run replace its own set without touching an earlier method's.
    */
    get MethodologyVersion(): string {
        return this.Get('MethodologyVersion');
    }
    set MethodologyVersion(value: string) {
        this.Set('MethodologyVersion', value);
    }

    /**
    * * Field Name: PropertyTypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(30)
    * * Description: Rolled-up property category the comp pool was drawn from.
    */
    get PropertyTypeGroup(): string | null {
        return this.Get('PropertyTypeGroup');
    }
    set PropertyTypeGroup(value: string | null) {
        this.Set('PropertyTypeGroup', value);
    }

    /**
    * * Field Name: UnitOfComparison
    * * Display Name: Unit of Comparison
    * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * $/SF
    *   * $/acre
    *   * $/unit
    * * Description: Unit of comparison: $/SF (default), $/unit (multifamily with a trustworthy unit count), or $/acre (land).
    */
    get UnitOfComparison(): '$/SF' | '$/acre' | '$/unit' {
        return this.Get('UnitOfComparison');
    }
    set UnitOfComparison(value: '$/SF' | '$/acre' | '$/unit') {
        this.Set('UnitOfComparison', value);
    }

    /**
    * * Field Name: HeadlineTrack
    * * Display Name: Headline Track
    * * SQL Data Type: nvarchar(10)
    * * Default Value: Effective
    * * Value List Type: List
    * * Possible Values 
    *   * Appealed
    *   * Effective
    *   * Original
    * * Description: Which value track drives the headline: Original (as-noticed), Appealed (post-PTABOA/IBTR), or Effective (Appealed if present else Original). Default Effective -- the hardest benchmark for the county to rebut.
    */
    get HeadlineTrack(): 'Appealed' | 'Effective' | 'Original' {
        return this.Get('HeadlineTrack');
    }
    set HeadlineTrack(value: 'Appealed' | 'Effective' | 'Original') {
        this.Set('HeadlineTrack', value);
    }

    /**
    * * Field Name: SubjectDenomValue
    * * Display Name: Subject Denominator Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The subject's denominator for the unit of comparison (building SF, unit count, or acres).
    */
    get SubjectDenomValue(): number | null {
        return this.Get('SubjectDenomValue');
    }
    set SubjectDenomValue(value: number | null) {
        this.Set('SubjectDenomValue', value);
    }

    /**
    * * Field Name: SubjectOriginalAV
    * * Display Name: Subject Original Assessed Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Subject as-noticed Original total AV for the focus year.
    */
    get SubjectOriginalAV(): number | null {
        return this.Get('SubjectOriginalAV');
    }
    set SubjectOriginalAV(value: number | null) {
        this.Set('SubjectOriginalAV', value);
    }

    /**
    * * Field Name: SubjectEffectiveAV
    * * Display Name: Subject Effective Assessed Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Subject Effective total AV for the focus year (Appealed if the subject itself has a PTABOA/IBTR result, else Original).
    */
    get SubjectEffectiveAV(): number | null {
        return this.Get('SubjectEffectiveAV');
    }
    set SubjectEffectiveAV(value: number | null) {
        this.Set('SubjectEffectiveAV', value);
    }

    /**
    * * Field Name: SubjectPerUnitEffective
    * * Display Name: Subject Per-Unit Effective Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: SubjectEffectiveAV / SubjectDenomValue -- the number the comp means/medians are measured against.
    */
    get SubjectPerUnitEffective(): number | null {
        return this.Get('SubjectPerUnitEffective');
    }
    set SubjectPerUnitEffective(value: number | null) {
        this.Set('SubjectPerUnitEffective', value);
    }

    /**
    * * Field Name: NeighborhoodCode
    * * Display Name: Neighborhood Code
    * * SQL Data Type: nvarchar(120)
    * * Description: The subject's CountyAssessorRecord.Neighborhood code -- the pool for the Neighborhood list.
    */
    get NeighborhoodCode(): string | null {
        return this.Get('NeighborhoodCode');
    }
    set NeighborhoodCode(value: string | null) {
        this.Set('NeighborhoodCode', value);
    }

    /**
    * * Field Name: NeighborhoodCompCount
    * * Display Name: Neighborhood Comparable Count
    * * SQL Data Type: int
    * * Description: Count of Neighborhood-list members with a usable per-unit value (basis for the mean/median).
    */
    get NeighborhoodCompCount(): number | null {
        return this.Get('NeighborhoodCompCount');
    }
    set NeighborhoodCompCount(value: number | null) {
        this.Set('NeighborhoodCompCount', value);
    }

    /**
    * * Field Name: NeighborhoodMeanPerUnit
    * * Display Name: Neighborhood Mean Per-Unit Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Mean Effective per-unit value across the Neighborhood list (focus year). Can mislead when the neighborhood is thin and building sizes vary widely -- prefer the median.
    */
    get NeighborhoodMeanPerUnit(): number | null {
        return this.Get('NeighborhoodMeanPerUnit');
    }
    set NeighborhoodMeanPerUnit(value: number | null) {
        this.Set('NeighborhoodMeanPerUnit', value);
    }

    /**
    * * Field Name: NeighborhoodMedianPerUnit
    * * Display Name: Neighborhood Median Per-Unit Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Median Effective per-unit value across the Neighborhood list (focus year).
    */
    get NeighborhoodMedianPerUnit(): number | null {
        return this.Get('NeighborhoodMedianPerUnit');
    }
    set NeighborhoodMedianPerUnit(value: number | null) {
        this.Set('NeighborhoodMedianPerUnit', value);
    }

    /**
    * * Field Name: CountyCompCount
    * * Display Name: County Comparable Count
    * * SQL Data Type: int
    * * Description: Count of County-list members with a usable per-unit value.
    */
    get CountyCompCount(): number | null {
        return this.Get('CountyCompCount');
    }
    set CountyCompCount(value: number | null) {
        this.Set('CountyCompCount', value);
    }

    /**
    * * Field Name: CountyMeanPerUnit
    * * Display Name: County Mean Per-Unit Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Mean Effective per-unit value across the County-wide list (focus year).
    */
    get CountyMeanPerUnit(): number | null {
        return this.Get('CountyMeanPerUnit');
    }
    set CountyMeanPerUnit(value: number | null) {
        this.Set('CountyMeanPerUnit', value);
    }

    /**
    * * Field Name: CountyMedianPerUnit
    * * Display Name: County Median Per-Unit Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Median Effective per-unit value across the County-wide list (focus year).
    */
    get CountyMedianPerUnit(): number | null {
        return this.Get('CountyMedianPerUnit');
    }
    set CountyMedianPerUnit(value: number | null) {
        this.Set('CountyMedianPerUnit', value);
    }

    /**
    * * Field Name: SubjectPercentile
    * * Display Name: Subject Percentile
    * * SQL Data Type: smallint
    * * Description: Percentile the subject's per-unit value sits at within the combined comp set (0-100; higher = more over-assessed relative to peers).
    */
    get SubjectPercentile(): number | null {
        return this.Get('SubjectPercentile');
    }
    set SubjectPercentile(value: number | null) {
        this.Set('SubjectPercentile', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(10)
    * * Default Value: Draft
    * * Value List Type: List
    * * Possible Values 
    *   * Draft
    *   * Final
    * * Description: Draft (builder output, not yet reviewed) or Final (analyst has reviewed the selections).
    */
    get Status(): 'Draft' | 'Final' {
        return this.Get('Status');
    }
    set Status(value: 'Draft' | 'Final') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: AnalystNote
    * * Display Name: Analyst Note
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text analyst / agent notes on the set.
    */
    get AnalystNote(): string | null {
        return this.Get('AnalystNote');
    }
    set AnalystNote(value: string | null) {
        this.Set('AnalystNote', value);
    }

    /**
    * * Field Name: GeneratedAt
    * * Display Name: Generated At
    * * SQL Data Type: datetimeoffset
    * * Description: When the builder generated this set.
    */
    get GeneratedAt(): Date | null {
        return this.Get('GeneratedAt');
    }
    set GeneratedAt(value: Date | null) {
        this.Set('GeneratedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SubjectParcel
    * * Display Name: Subject Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get SubjectParcel(): string {
        return this.Get('SubjectParcel');
    }
}


/**
 * County Assessor Improvement Segments - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CountyAssessorImprovementSegment
 * * Base View: vwCountyAssessorImprovementSegments
 * * @description One row per floor/use-segment column from a Property Record Card's dense per-card pricing table (the "Average Size / Units" grid). CRITICAL: a segment's printed size is PER FLOOR, not the segment total -- e.g. "21,263 / 10" means 21,263 sqft on each of 10 floors (212,630 sqft total). TotalSqFt is a computed column so this multiplication can never be silently skipped or dropped. Summing TotalSqFt across all of a parcel's segments should match the Building row's SizeOrArea in CountyAssessorImprovement -- root-caused against parcel 8050459 on 2026-08-23 (see the closed ResearchTask), where plain-text PDF extraction had previously dropped a leading digit and silently undercounted a segment by a factor of ~17.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'County Assessor Improvement Segments')
export class indianataxCountyAssessorImprovementSegmentEntity extends BaseEntity<indianataxCountyAssessorImprovementSegmentEntityType> {
    /**
    * Loads the County Assessor Improvement Segments record from the database
    * @param ID: string - primary key value to load the County Assessor Improvement Segments record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCountyAssessorImprovementSegmentEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyAssessorRecordID
    * * Display Name: County Assessor Record
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
    * * Description: The parcel record this improvement segment belongs to. Segments are implicitly part of the "Building" structure line -- Paving/Skyway/etc. don't carry their own per-floor breakdown, so there is no direct link to a specific CountyAssessorImprovement row.
    */
    get CountyAssessorRecordID(): string {
        return this.Get('CountyAssessorRecordID');
    }
    set CountyAssessorRecordID(value: string) {
        this.Set('CountyAssessorRecordID', value);
    }

    /**
    * * Field Name: CardNumber
    * * Display Name: Card Number
    * * SQL Data Type: nvarchar(10)
    * * Description: The card page this segment was reported on (e.g. "1", "1A").
    */
    get CardNumber(): string | null {
        return this.Get('CardNumber');
    }
    set CardNumber(value: string | null) {
        this.Set('CardNumber', value);
    }

    /**
    * * Field Name: SegmentIndex
    * * Display Name: Segment Index
    * * SQL Data Type: int
    * * Description: The segment's column position within its card (left to right), used to preserve the original ordering and as a stable identity within a card when re-parsing.
    */
    get SegmentIndex(): number | null {
        return this.Get('SegmentIndex');
    }
    set SegmentIndex(value: number | null) {
        this.Set('SegmentIndex', value);
    }

    /**
    * * Field Name: Use
    * * Display Name: Use Classification
    * * SQL Data Type: nvarchar(50)
    * * Description: The use classification for this segment, e.g. "Gen Office", "Utility".
    */
    get Use(): string | null {
        return this.Get('Use');
    }
    set Use(value: string | null) {
        this.Set('Use', value);
    }

    /**
    * * Field Name: SqFtPerFloor
    * * Display Name: Square Feet Per Floor
    * * SQL Data Type: decimal(12, 2)
    * * Description: The "S.F. Area" / "Average Size" value for this segment -- the size of ONE floor of this type, not the segment total. See TotalSqFt.
    */
    get SqFtPerFloor(): number | null {
        return this.Get('SqFtPerFloor');
    }
    set SqFtPerFloor(value: number | null) {
        this.Set('SqFtPerFloor', value);
    }

    /**
    * * Field Name: FloorCount
    * * Display Name: Floor Count
    * * SQL Data Type: int
    * * Description: The "Units" value from "Average Size / Units" -- how many floors carry this segment's SqFtPerFloor. 1 for a single-floor segment.
    */
    get FloorCount(): number | null {
        return this.Get('FloorCount');
    }
    set FloorCount(value: number | null) {
        this.Set('FloorCount', value);
    }

    /**
    * * Field Name: TotalSqFt
    * * Display Name: Total Square Feet
    * * SQL Data Type: decimal(23, 2)
    * * Description: Computed as SqFtPerFloor * FloorCount -- the true total square footage this segment contributes to the building. Always use this, never SqFtPerFloor alone, for any building-size or per-square-foot analysis.
    */
    get TotalSqFt(): number | null {
        return this.Get('TotalSqFt');
    }

    /**
    * * Field Name: ReproductionCost
    * * Display Name: Reproduction Cost
    * * SQL Data Type: decimal(14, 2)
    * * Description: The assessor's estimated replacement cost for this segment, per the card's cost-model computation.
    */
    get ReproductionCost(): number | null {
        return this.Get('ReproductionCost');
    }
    set ReproductionCost(value: number | null) {
        this.Set('ReproductionCost', value);
    }

    /**
    * * Field Name: PhysicalDepreciationPct
    * * Display Name: Physical Depreciation Percentage
    * * SQL Data Type: decimal(9, 4)
    * * Description: The "Phys Dep" percentage from the "Phys Dep/ Yr Blt /Cond" field -- physical depreciation applied to this segment's reproduction cost.
    */
    get PhysicalDepreciationPct(): number | null {
        return this.Get('PhysicalDepreciationPct');
    }
    set PhysicalDepreciationPct(value: number | null) {
        this.Set('PhysicalDepreciationPct', value);
    }

    /**
    * * Field Name: YearConstructed
    * * Display Name: Year Constructed
    * * SQL Data Type: smallint
    * * Description: The "Yr Blt" (year built) component of "Phys Dep/ Yr Blt /Cond" for this specific segment -- can differ segment-to-segment within the same structure (e.g. an addition).
    */
    get YearConstructed(): number | null {
        return this.Get('YearConstructed');
    }
    set YearConstructed(value: number | null) {
        this.Set('YearConstructed', value);
    }

    /**
    * * Field Name: EffectiveYear
    * * Display Name: Effective Year
    * * SQL Data Type: smallint
    * * Description: The effective year used for this segment's depreciation calculation.
    */
    get EffectiveYear(): number | null {
        return this.Get('EffectiveYear');
    }
    set EffectiveYear(value: number | null) {
        this.Set('EffectiveYear', value);
    }

    /**
    * * Field Name: Condition
    * * Display Name: Condition
    * * SQL Data Type: nvarchar(10)
    * * Description: The "Cond" (condition) component of "Phys Dep/ Yr Blt /Cond" -- a letter rating (e.g. "A") for this segment.
    */
    get Condition(): string | null {
        return this.Get('Condition');
    }
    set Condition(value: string | null) {
        this.Set('Condition', value);
    }

    /**
    * * Field Name: ObsolescencePct
    * * Display Name: Obsolescence Percentage
    * * SQL Data Type: decimal(9, 4)
    * * Description: The "Obsolescence" figure for this segment -- a cost-model adjustment the county can apply to align reproduction-cost-based value with market value-in-use. NOTE (2026-08-23): the sample parcel used to design this table had Obsolescence=0 throughout, so the real-world format (percentage vs. dollar amount) of a non-zero value has not yet been directly confirmed -- verify against a parcel with an actual adjustment before relying on this column's units. A parcel receiving this adjustment while comparable parcels don't is a potential appeal-lead signal (see the related ResearchTask), but that scoring logic is not implemented by this column alone.
    */
    get ObsolescencePct(): number | null {
        return this.Get('ObsolescencePct');
    }
    set ObsolescencePct(value: number | null) {
        this.Set('ObsolescencePct', value);
    }

    /**
    * * Field Name: RemainderValue
    * * Display Name: Remainder Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Remainder Value" for this segment -- reproduction cost after physical depreciation and obsolescence.
    */
    get RemainderValue(): number | null {
        return this.Get('RemainderValue');
    }
    set RemainderValue(value: number | null) {
        this.Set('RemainderValue', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: CountyAssessorRecord
    * * Display Name: County Assessor Record
    * * SQL Data Type: nvarchar(500)
    */
    get CountyAssessorRecord(): string | null {
        return this.Get('CountyAssessorRecord');
    }
}


/**
 * County Assessor Improvements - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CountyAssessorImprovement
 * * Base View: vwCountyAssessorImprovements
 * * @description One row per structure line from a Property Record Card's "Summary of Improvements" table (e.g. Building, Paving-Asph, Skyway enclosed). A parcel with multiple structures/cards has multiple rows. The Building row's SizeOrArea is the reliable, already-unit-multiplied total building square footage -- use it as a cross-check against the sum of this parcel's CountyAssessorImprovementSegment rows.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'County Assessor Improvements')
export class indianataxCountyAssessorImprovementEntity extends BaseEntity<indianataxCountyAssessorImprovementEntityType> {
    /**
    * Loads the County Assessor Improvements record from the database
    * @param ID: string - primary key value to load the County Assessor Improvements record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCountyAssessorImprovementEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyAssessorRecordID
    * * Display Name: County Assessor Record
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
    * * Description: The parcel record this improvement belongs to.
    */
    get CountyAssessorRecordID(): string {
        return this.Get('CountyAssessorRecordID');
    }
    set CountyAssessorRecordID(value: string) {
        this.Set('CountyAssessorRecordID', value);
    }

    /**
    * * Field Name: CardNumber
    * * Display Name: Card Number
    * * SQL Data Type: nvarchar(10)
    * * Description: The card page this row was reported on (e.g. "1", "1A"). A parcel can have multiple cards for complex properties.
    */
    get CardNumber(): string | null {
        return this.Get('CardNumber');
    }
    set CardNumber(value: string | null) {
        this.Set('CardNumber', value);
    }

    /**
    * * Field Name: Use
    * * Display Name: Structure Type
    * * SQL Data Type: nvarchar(50)
    * * Description: The structure type, e.g. "Building", "Paving -Asph", "Skyway enclosed walkway".
    */
    get Use(): string | null {
        return this.Get('Use');
    }
    set Use(value: string | null) {
        this.Set('Use', value);
    }

    /**
    * * Field Name: Grade
    * * Display Name: Construction Grade
    * * SQL Data Type: nvarchar(50)
    * * Description: Construction grade rating (e.g. "C", "B+"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.
    */
    get Grade(): string | null {
        return this.Get('Grade');
    }
    set Grade(value: string | null) {
        this.Set('Grade', value);
    }

    /**
    * * Field Name: YearConstructed
    * * Display Name: Year Constructed
    * * SQL Data Type: smallint
    * * Description: The year this structure was originally constructed, per the card.
    */
    get YearConstructed(): number | null {
        return this.Get('YearConstructed');
    }
    set YearConstructed(value: number | null) {
        this.Set('YearConstructed', value);
    }

    /**
    * * Field Name: EffectiveYear
    * * Display Name: Effective Year
    * * SQL Data Type: smallint
    * * Description: The effective year used for depreciation purposes (can differ from YearConstructed after a renovation).
    */
    get EffectiveYear(): number | null {
        return this.Get('EffectiveYear');
    }
    set EffectiveYear(value: number | null) {
        this.Set('EffectiveYear', value);
    }

    /**
    * * Field Name: Condition
    * * Display Name: Condition Rating
    * * SQL Data Type: nvarchar(50)
    * * Description: Condition rating letter (e.g. "A"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.
    */
    get Condition(): string | null {
        return this.Get('Condition');
    }
    set Condition(value: string | null) {
        this.Set('Condition', value);
    }

    /**
    * * Field Name: SizeOrArea
    * * Display Name: Size or Area
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Size or Area" figure on this structure's summary row. For the Building row, this is the true total building square footage (already accounts for multi-floor segments) -- more reliable than CountyAssessorRecord.EstimatedSqFt sourced any other way.
    */
    get SizeOrArea(): number | null {
        return this.Get('SizeOrArea');
    }
    set SizeOrArea(value: number | null) {
        this.Set('SizeOrArea', value);
    }

    /**
    * * Field Name: ReproductionCost
    * * Display Name: Reproduction Cost
    * * SQL Data Type: decimal(14, 2)
    * * Description: The assessor's estimated replacement cost for this structure, per the card's cost-model computation.
    */
    get ReproductionCost(): number | null {
        return this.Get('ReproductionCost');
    }
    set ReproductionCost(value: number | null) {
        this.Set('ReproductionCost', value);
    }

    /**
    * * Field Name: DepreciationObsolescence
    * * Display Name: Depreciation/Obsolescence
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Dep/Obs" figure on the summary row -- combined physical depreciation and obsolescence deduction from reproduction cost. See CountyAssessorImprovementSegment for the per-floor breakdown of physical depreciation and obsolescence separately.
    */
    get DepreciationObsolescence(): number | null {
        return this.Get('DepreciationObsolescence');
    }
    set DepreciationObsolescence(value: number | null) {
        this.Set('DepreciationObsolescence', value);
    }

    /**
    * * Field Name: RemainderValue
    * * Display Name: Remainder Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "REM Val" (remainder value) figure -- reproduction cost less depreciation/obsolescence, before the trend factor is applied.
    */
    get RemainderValue(): number | null {
        return this.Get('RemainderValue');
    }
    set RemainderValue(value: number | null) {
        this.Set('RemainderValue', value);
    }

    /**
    * * Field Name: PctComplete
    * * Display Name: Percent Complete
    * * SQL Data Type: decimal(5, 2)
    * * Description: The "% Cmp" (percent complete) figure, for structures under construction. 100 for a finished structure.
    */
    get PctComplete(): number | null {
        return this.Get('PctComplete');
    }
    set PctComplete(value: number | null) {
        this.Set('PctComplete', value);
    }

    /**
    * * Field Name: TrendFactor
    * * Display Name: Trend Factor
    * * SQL Data Type: decimal(9, 4)
    * * Description: The trend factor applied to remainder value to reach true tax value.
    */
    get TrendFactor(): number | null {
        return this.Get('TrendFactor');
    }
    set TrendFactor(value: number | null) {
        this.Set('TrendFactor', value);
    }

    /**
    * * Field Name: TrueTaxValue
    * * Display Name: True Tax Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "True Tax Value" figure -- this structure's contribution to the parcel's assessed improvement value.
    */
    get TrueTaxValue(): number | null {
        return this.Get('TrueTaxValue');
    }
    set TrueTaxValue(value: number | null) {
        this.Set('TrueTaxValue', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: CountyAssessorRecord
    * * Display Name: Parcel Record
    * * SQL Data Type: nvarchar(500)
    */
    get CountyAssessorRecord(): string | null {
        return this.Get('CountyAssessorRecord');
    }
}


/**
 * County Assessor Records - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CountyAssessorRecord
 * * Base View: vwCountyAssessorRecords
 * * @description A parcel's record from its OWN county's live assessor GIS system (not the statewide DLGF/GIO pull Assessment is built from). Currently populated for Marion County only, from its ArcGIS-hosted assessor layer, but named generically since other counties may have their own equivalent systems worth the same treatment later.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'County Assessor Records')
export class indianataxCountyAssessorRecordEntity extends BaseEntity<indianataxCountyAssessorRecordEntityType> {
    /**
    * Loads the County Assessor Records record from the database
    * @param ID: string - primary key value to load the County Assessor Records record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCountyAssessorRecordEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for County Assessor Records entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: All assessed property values, assessment totals, and square footage measurements must be non-negative. This ensures data integrity by preventing negative values for land assessments, improvement assessments, total assessments, gross assessments, net assessments, and estimated square footage, which would indicate data entry errors or corrupted records.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateAssessmentValuesNonNegative(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * All assessed property values, assessment totals, and square footage measurements must be non-negative. This ensures data integrity by preventing negative values for land assessments, improvement assessments, total assessments, gross assessments, net assessments, and estimated square footage, which would indicate data entry errors or corrupted records.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateAssessmentValuesNonNegative(result: ValidationResult) {
    	if (this.AssessedTotalAV != null && this.AssessedTotalAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"AssessedTotalAV",
    			"Assessed total value cannot be negative",
    			this.AssessedTotalAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.AssessedLandAV != null && this.AssessedLandAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"AssessedLandAV",
    			"Assessed land value cannot be negative",
    			this.AssessedLandAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.AssessedImprovementAV != null && this.AssessedImprovementAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"AssessedImprovementAV",
    			"Assessed improvement value cannot be negative",
    			this.AssessedImprovementAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.GrossAssessment != null && this.GrossAssessment < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"GrossAssessment",
    			"Gross assessment cannot be negative",
    			this.GrossAssessment,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.NetAssessment != null && this.NetAssessment < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"NetAssessment",
    			"Net assessment cannot be negative",
    			this.NetAssessment,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.EstimatedSqFt != null && this.EstimatedSqFt < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EstimatedSqFt",
    			"Estimated square footage cannot be negative",
    			this.EstimatedSqFt,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this record belongs to.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: Which county's own system this record came from.
    */
    get CountyNumber(): number {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: OwnerName
    * * Display Name: Owner Name
    * * SQL Data Type: nvarchar(500)
    */
    get OwnerName(): string | null {
        return this.Get('OwnerName');
    }
    set OwnerName(value: string | null) {
        this.Set('OwnerName', value);
    }

    /**
    * * Field Name: OwnerAddress
    * * Display Name: Owner Address
    * * SQL Data Type: nvarchar(200)
    */
    get OwnerAddress(): string | null {
        return this.Get('OwnerAddress');
    }
    set OwnerAddress(value: string | null) {
        this.Set('OwnerAddress', value);
    }

    /**
    * * Field Name: OwnerCity
    * * Display Name: Owner City
    * * SQL Data Type: nvarchar(100)
    */
    get OwnerCity(): string | null {
        return this.Get('OwnerCity');
    }
    set OwnerCity(value: string | null) {
        this.Set('OwnerCity', value);
    }

    /**
    * * Field Name: OwnerState
    * * Display Name: Owner State
    * * SQL Data Type: nvarchar(10)
    */
    get OwnerState(): string | null {
        return this.Get('OwnerState');
    }
    set OwnerState(value: string | null) {
        this.Set('OwnerState', value);
    }

    /**
    * * Field Name: OwnerZip
    * * Display Name: Owner Zip
    * * SQL Data Type: nvarchar(20)
    */
    get OwnerZip(): string | null {
        return this.Get('OwnerZip');
    }
    set OwnerZip(value: string | null) {
        this.Set('OwnerZip', value);
    }

    /**
    * * Field Name: PropertyClass
    * * Display Name: Property Class
    * * SQL Data Type: nvarchar(32)
    */
    get PropertyClass(): string | null {
        return this.Get('PropertyClass');
    }
    set PropertyClass(value: string | null) {
        this.Set('PropertyClass', value);
    }

    /**
    * * Field Name: PropertySubClassDescription
    * * Display Name: Property Subclass
    * * SQL Data Type: nvarchar(64)
    */
    get PropertySubClassDescription(): string | null {
        return this.Get('PropertySubClassDescription');
    }
    set PropertySubClassDescription(value: string | null) {
        this.Set('PropertySubClassDescription', value);
    }

    /**
    * * Field Name: AssessedLandAV
    * * Display Name: Assessed Land Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Assessed land value per the county's own current system -- may be fresher than the statewide Assessment table for this parcel.
    */
    get AssessedLandAV(): number | null {
        return this.Get('AssessedLandAV');
    }
    set AssessedLandAV(value: number | null) {
        this.Set('AssessedLandAV', value);
    }

    /**
    * * Field Name: AssessedImprovementAV
    * * Display Name: Assessed Improvement Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Assessed improvement value per the county's own current system.
    */
    get AssessedImprovementAV(): number | null {
        return this.Get('AssessedImprovementAV');
    }
    set AssessedImprovementAV(value: number | null) {
        this.Set('AssessedImprovementAV', value);
    }

    /**
    * * Field Name: AssessedTotalAV
    * * Display Name: Assessed Total Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Assessed total value per the county's own current system.
    */
    get AssessedTotalAV(): number | null {
        return this.Get('AssessedTotalAV');
    }
    set AssessedTotalAV(value: number | null) {
        this.Set('AssessedTotalAV', value);
    }

    /**
    * * Field Name: CountyParcelID
    * * Display Name: County Parcel ID
    * * SQL Data Type: nvarchar(50)
    * * Description: The county system's own internal parcel identifier (e.g. Marion's CAMAPARCELID), distinct from the statewide ParcelNumber.
    */
    get CountyParcelID(): string | null {
        return this.Get('CountyParcelID');
    }
    set CountyParcelID(value: string | null) {
        this.Set('CountyParcelID', value);
    }

    /**
    * * Field Name: Neighborhood
    * * Display Name: Neighborhood
    * * SQL Data Type: nvarchar(32)
    */
    get Neighborhood(): string | null {
        return this.Get('Neighborhood');
    }
    set Neighborhood(value: string | null) {
        this.Set('Neighborhood', value);
    }

    /**
    * * Field Name: TaxDistrictID
    * * Display Name: Tax District ID
    * * SQL Data Type: nvarchar(5)
    */
    get TaxDistrictID(): string | null {
        return this.Get('TaxDistrictID');
    }
    set TaxDistrictID(value: string | null) {
        this.Set('TaxDistrictID', value);
    }

    /**
    * * Field Name: LegalDescription
    * * Display Name: Legal Description
    * * SQL Data Type: nvarchar(1500)
    */
    get LegalDescription(): string | null {
        return this.Get('LegalDescription');
    }
    set LegalDescription(value: string | null) {
        this.Set('LegalDescription', value);
    }

    /**
    * * Field Name: Acreage
    * * Display Name: Acreage
    * * SQL Data Type: nvarchar(10)
    */
    get Acreage(): string | null {
        return this.Get('Acreage');
    }
    set Acreage(value: string | null) {
        this.Set('Acreage', value);
    }

    /**
    * * Field Name: EstimatedSqFt
    * * Display Name: Estimated Square Footage
    * * SQL Data Type: int
    * * Description: Estimated square footage. CAUTION: sourced from the Marion County ArcGIS layer's ESTSQFT field, which for a meaningful subset of rows (~29%, matches Parcel.Acreage * 43560) actually holds LAND square footage rather than building square footage -- confirmed 2026-08-23 against a real Property Record Card. Check SqFtSource: 'BuildingDetail' means this value was re-sourced from itemized per-floor data and is trustworthy for building-size analysis; NULL means it is either the original unverified ArcGIS value (use with caution, may be land area) or was cleared after being proven land-derived with no better source available.
    */
    get EstimatedSqFt(): number | null {
        return this.Get('EstimatedSqFt');
    }
    set EstimatedSqFt(value: number | null) {
        this.Set('EstimatedSqFt', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(8)
    */
    get Status(): string | null {
        return this.Get('Status');
    }
    set Status(value: string | null) {
        this.Set('Status', value);
    }

    /**
    * * Field Name: SourceModDate
    * * Display Name: Source Modified Date
    * * SQL Data Type: datetimeoffset
    * * Description: When the county's OWN system last updated this record -- distinct from RetrievedAt, which is when WE fetched it.
    */
    get SourceModDate(): Date | null {
        return this.Get('SourceModDate');
    }
    set SourceModDate(value: Date | null) {
        this.Set('SourceModDate', value);
    }

    /**
    * * Field Name: RetrievedAt
    * * Display Name: Retrieved At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When we fetched this record.
    */
    get RetrievedAt(): Date {
        return this.Get('RetrievedAt');
    }
    set RetrievedAt(value: Date) {
        this.Set('RetrievedAt', value);
    }

    /**
    * * Field Name: SourceRegistryID
    * * Display Name: Source Registry
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
    * * Description: The SourceRegistry entry for the county system this came from.
    */
    get SourceRegistryID(): string | null {
        return this.Get('SourceRegistryID');
    }
    set SourceRegistryID(value: string | null) {
        this.Set('SourceRegistryID', value);
    }

    /**
    * * Field Name: YearBuilt
    * * Display Name: Year Built
    * * SQL Data Type: smallint
    * * Description: Year the primary structure was built, per the county's Tax History report.
    */
    get YearBuilt(): number | null {
        return this.Get('YearBuilt');
    }
    set YearBuilt(value: number | null) {
        this.Set('YearBuilt', value);
    }

    /**
    * * Field Name: LastAssessmentChangeDate
    * * Display Name: Last Assessment Change Date
    * * SQL Data Type: date
    * * Description: Date of the last assessment change per the county's system.
    */
    get LastAssessmentChangeDate(): Date | null {
        return this.Get('LastAssessmentChangeDate');
    }
    set LastAssessmentChangeDate(value: Date | null) {
        this.Set('LastAssessmentChangeDate', value);
    }

    /**
    * * Field Name: TaxYear
    * * Display Name: Tax Year
    * * SQL Data Type: smallint
    * * Description: The tax year the tax-bill fields on this row (GrossAssessment through CurrentTaxDue) apply to.
    */
    get TaxYear(): number | null {
        return this.Get('TaxYear');
    }
    set TaxYear(value: number | null) {
        this.Set('TaxYear', value);
    }

    /**
    * * Field Name: GrossAssessment
    * * Display Name: Gross Assessment
    * * SQL Data Type: decimal(14, 2)
    * * Description: Gross assessment (land + improvements) for TaxYear, before deductions/exemptions.
    */
    get GrossAssessment(): number | null {
        return this.Get('GrossAssessment');
    }
    set GrossAssessment(value: number | null) {
        this.Set('GrossAssessment', value);
    }

    /**
    * * Field Name: DeductionsExemptionsTotal
    * * Display Name: Deductions/Exemptions Total
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total deductions/exemptions applied for TaxYear (e.g. homestead standard deduction, supplemental).
    */
    get DeductionsExemptionsTotal(): number | null {
        return this.Get('DeductionsExemptionsTotal');
    }
    set DeductionsExemptionsTotal(value: number | null) {
        this.Set('DeductionsExemptionsTotal', value);
    }

    /**
    * * Field Name: NetAssessment
    * * Display Name: Net Assessment
    * * SQL Data Type: decimal(14, 2)
    * * Description: Net assessment for TaxYear (gross minus deductions/exemptions) -- the actual tax base.
    */
    get NetAssessment(): number | null {
        return this.Get('NetAssessment');
    }
    set NetAssessment(value: number | null) {
        this.Set('NetAssessment', value);
    }

    /**
    * * Field Name: TaxRate
    * * Display Name: Tax Rate
    * * SQL Data Type: decimal(9, 6)
    * * Description: The tax rate applied for TaxYear, as a percentage (e.g. 2.729100 means 2.7291%).
    */
    get TaxRate(): number | null {
        return this.Get('TaxRate');
    }
    set TaxRate(value: number | null) {
        this.Set('TaxRate', value);
    }

    /**
    * * Field Name: NetAnnualTax
    * * Display Name: Net Annual Tax
    * * SQL Data Type: decimal(14, 2)
    * * Description: The actual computed net annual tax for TaxYear -- the real dollar tax amount, not just assessed value. This is data no other source in this schema provides.
    */
    get NetAnnualTax(): number | null {
        return this.Get('NetAnnualTax');
    }
    set NetAnnualTax(value: number | null) {
        this.Set('NetAnnualTax', value);
    }

    /**
    * * Field Name: CurrentTaxDue
    * * Display Name: Current Tax Due
    * * SQL Data Type: decimal(14, 2)
    * * Description: Amount currently due, per the report at the time it was fetched (a snapshot, not necessarily current by the time this is read).
    */
    get CurrentTaxDue(): number | null {
        return this.Get('CurrentTaxDue');
    }
    set CurrentTaxDue(value: number | null) {
        this.Set('CurrentTaxDue', value);
    }

    /**
    * * Field Name: DeedType
    * * Display Name: Deed Type
    * * SQL Data Type: nvarchar(50)
    * * Description: Deed type for the most recent transfer (e.g. Warranty Deed), per the Tax History report.
    */
    get DeedType(): string | null {
        return this.Get('DeedType');
    }
    set DeedType(value: string | null) {
        this.Set('DeedType', value);
    }

    /**
    * * Field Name: DeedDate
    * * Display Name: Deed Date
    * * SQL Data Type: date
    * * Description: Deed execution date for the most recent transfer.
    */
    get DeedDate(): Date | null {
        return this.Get('DeedDate');
    }
    set DeedDate(value: Date | null) {
        this.Set('DeedDate', value);
    }

    /**
    * * Field Name: FileDate
    * * Display Name: File Date
    * * SQL Data Type: date
    * * Description: Date the deed was filed/recorded for the most recent transfer.
    */
    get FileDate(): Date | null {
        return this.Get('FileDate');
    }
    set FileDate(value: Date | null) {
        this.Set('FileDate', value);
    }

    /**
    * * Field Name: ReportRetrievedAt
    * * Display Name: Report Retrieved At
    * * SQL Data Type: datetimeoffset
    * * Description: When the Property Record Card / Tax History PDF reports were fetched for this parcel -- tracked separately from RetrievedAt (the GIS layer fetch) since these two sources are pulled at different times and paces (the reports have no bulk endpoint).
    */
    get ReportRetrievedAt(): Date | null {
        return this.Get('ReportRetrievedAt');
    }
    set ReportRetrievedAt(value: Date | null) {
        this.Set('ReportRetrievedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SqFtSource
    * * Display Name: Square Footage Source
    * * SQL Data Type: nvarchar(20)
    * * Description: How EstimatedSqFt was sourced/verified, in descending order of reliability: 'PropertyRecordCard' = computed from CountyAssessorImprovementSegment (SqFtPerFloor * FloorCount, summed and cross-checked against the card's own Building total) -- the most reliable source, correctly accounts for multi-floor segments. 'BuildingDetail' = summed from itemized per-floor building_detail data WITHOUT a floor-count multiplier -- confirmed 2026-08-23 to systematically undercount multi-floor buildings (e.g. a 10-floor segment counted as 1 floor), superseded by 'PropertyRecordCard' wherever available. NULL = original ArcGIS ESTSQFT value (unverified, may be land-area-derived) or cleared after being proven land-derived with no replacement source available.
    */
    get SqFtSource(): string | null {
        return this.Get('SqFtSource');
    }
    set SqFtSource(value: string | null) {
        this.Set('SqFtSource', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument row for this parcel's most recently fetched Property Record Card PDF. NULL until a PRC has been fetched for this parcel. Distinct from ReportRetrievedAt (a plain timestamp on this row) -- this links to the actual persisted PDF, its content hash, and its ExtractedText.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: TaxHistorySourceDocumentID
    * * Display Name: Tax History Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument row for this parcel's most recently fetched Tax History Report PDF -- distinct from SourceDocumentID, which links the Property Record Card. NULL until a Tax History Report has been fetched for this parcel.
    */
    get TaxHistorySourceDocumentID(): string | null {
        return this.Get('TaxHistorySourceDocumentID');
    }
    set TaxHistorySourceDocumentID(value: string | null) {
        this.Set('TaxHistorySourceDocumentID', value);
    }

    /**
    * * Field Name: ComparisonUnitType
    * * Display Name: Comparison Unit Type
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Bed
    *   * Door
    *   * Key
    *   * Unit
    * * Description: The non-SF/non-acre unit of comparison this property should be valued per, when one applies: Unit (apartment dwelling units), Key (hotel/motel rooms), Bed (nursing home/hospital beds), or Door (self-storage doors). NULL means this property is compared per square foot (the default -- see EstimatedSqFt) or per acre (vacant land -- see Acreage), not per a unit count. Not populated by PRC parsing -- see ComparisonUnitCount.
    */
    get ComparisonUnitType(): 'Bed' | 'Door' | 'Key' | 'Unit' | null {
        return this.Get('ComparisonUnitType');
    }
    set ComparisonUnitType(value: 'Bed' | 'Door' | 'Key' | 'Unit' | null) {
        this.Set('ComparisonUnitType', value);
    }

    /**
    * * Field Name: ComparisonUnitCount
    * * Display Name: Comparison Unit Count
    * * SQL Data Type: decimal(10, 2)
    * * Description: The count of ComparisonUnitType for this property (e.g. number of apartment units, hotel keys, nursing beds, or storage doors). NULL until populated by a future CoStar-export import -- confirmed 2026-08-25 that Marion County's Property Record Card does not reliably expose this as a structured field (one large hotel's card had a free-text renovation note giving a room count; the rest of a small real sample had nothing usable).
    */
    get ComparisonUnitCount(): number | null {
        return this.Get('ComparisonUnitCount');
    }
    set ComparisonUnitCount(value: number | null) {
        this.Set('ComparisonUnitCount', value);
    }

    /**
    * * Field Name: CoStarYearBuilt
    * * Display Name: CoStar Year Built
    * * SQL Data Type: smallint
    * * Description: Year built, sourced from a matched CoStarProperty row (CoStar "Year Built") -- ONLY populated when this parcel's own YearBuilt (Tax History Report-sourced) is null and exactly one unambiguous CoStar value exists for it (see backfill-costar-derived-fields.js). Kept separate from YearBuilt rather than merged into it -- the two sources must stay distinguishable per this project's CoStar-provenance convention. The Property Search grid's "Year Built" column shows YearBuilt when present, this as a marked fallback otherwise.
    */
    get CoStarYearBuilt(): number | null {
        return this.Get('CoStarYearBuilt');
    }
    set CoStarYearBuilt(value: number | null) {
        this.Set('CoStarYearBuilt', value);
    }

    /**
    * * Field Name: CoStarRBA
    * * Display Name: CoStar RBA
    * * SQL Data Type: int
    * * Description: Rentable Building Area, sourced from a matched CoStarProperty row (CoStar "RBA") -- ONLY populated when exactly one unambiguous CoStar value exists for this parcel across its single-parcel-matched CoStarProperty rows (see backfill-costar-derived-fields.js). Distinct from EstimatedSqFt (total building SF from the PRC/ArcGIS layer) -- RBA is the rentable/leasable measure, a different physical quantity, not just a different source for the same number. Never merged into EstimatedSqFt.
    */
    get CoStarRBA(): number | null {
        return this.Get('CoStarRBA');
    }
    set CoStarRBA(value: number | null) {
        this.Set('CoStarRBA', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }

    /**
    * * Field Name: SourceRegistry
    * * Display Name: Source Registry
    * * SQL Data Type: nvarchar(200)
    */
    get SourceRegistry(): string | null {
        return this.Get('SourceRegistry');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * County Assessor Sale Histories - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CountyAssessorSaleHistory
 * * Base View: vwCountyAssessorSaleHistories
 * * @description One ownership transfer/sale event from a parcel's Property Record Card sale history table.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'County Assessor Sale Histories')
export class indianataxCountyAssessorSaleHistoryEntity extends BaseEntity<indianataxCountyAssessorSaleHistoryEntityType> {
    /**
    * Loads the County Assessor Sale Histories record from the database
    * @param ID: string - primary key value to load the County Assessor Sale Histories record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCountyAssessorSaleHistoryEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyAssessorRecordID
    * * Display Name: County Assessor Record
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: County Assessor Records (vwCountyAssessorRecords.ID)
    * * Description: The parcel record this sale belongs to.
    */
    get CountyAssessorRecordID(): string {
        return this.Get('CountyAssessorRecordID');
    }
    set CountyAssessorRecordID(value: string) {
        this.Set('CountyAssessorRecordID', value);
    }

    /**
    * * Field Name: SaleDate
    * * Display Name: Sale Date
    * * SQL Data Type: date
    * * Description: Date of the transfer/sale.
    */
    get SaleDate(): Date | null {
        return this.Get('SaleDate');
    }
    set SaleDate(value: Date | null) {
        this.Set('SaleDate', value);
    }

    /**
    * * Field Name: GrantorName
    * * Display Name: Grantor Name
    * * SQL Data Type: nvarchar(300)
    * * Description: Grantor (seller) of record.
    */
    get GrantorName(): string | null {
        return this.Get('GrantorName');
    }
    set GrantorName(value: string | null) {
        this.Set('GrantorName', value);
    }

    /**
    * * Field Name: IsValidSale
    * * Display Name: Valid Sale
    * * SQL Data Type: bit
    * * Description: Whether the county flagged this as a valid (arms-length) sale, per the source report.
    */
    get IsValidSale(): boolean | null {
        return this.Get('IsValidSale');
    }
    set IsValidSale(value: boolean | null) {
        this.Set('IsValidSale', value);
    }

    /**
    * * Field Name: SaleAmount
    * * Display Name: Sale Amount
    * * SQL Data Type: decimal(14, 2)
    * * Description: Sale/transfer amount.
    */
    get SaleAmount(): number | null {
        return this.Get('SaleAmount');
    }
    set SaleAmount(value: number | null) {
        this.Set('SaleAmount', value);
    }

    /**
    * * Field Name: SaleType
    * * Display Name: Sale Type
    * * SQL Data Type: nvarchar(50)
    * * Description: Transfer type as recorded, e.g. Sale, Straight (non-sale transfer such as a trust conveyance).
    */
    get SaleType(): string | null {
        return this.Get('SaleType');
    }
    set SaleType(value: string | null) {
        this.Set('SaleType', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: CountyAssessorRecord
    * * Display Name: County Assessor Record
    * * SQL Data Type: nvarchar(500)
    */
    get CountyAssessorRecord(): string | null {
        return this.Get('CountyAssessorRecord');
    }
}


/**
 * County Resources - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: CountyResource
 * * Base View: vwCountyResources
 * * @description A county-level office/resource link relevant to property records (assessor, auditor, treasurer, recorder, GIS), sourced from NETR Online's public records directory. Reference directory, not a periodically-rescanned document source like SourceRegistry.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'County Resources')
export class indianataxCountyResourceEntity extends BaseEntity<indianataxCountyResourceEntityType> {
    /**
    * Loads the County Resources record from the database
    * @param ID: string - primary key value to load the County Resources record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxCountyResourceEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyName
    * * Display Name: County Name
    * * SQL Data Type: nvarchar(50)
    * * Description: The Indiana county this resource belongs to (as named by the source directory).
    */
    get CountyName(): string {
        return this.Get('CountyName');
    }
    set CountyName(value: string) {
        this.Set('CountyName', value);
    }

    /**
    * * Field Name: ResourceLabel
    * * Display Name: Resource Label
    * * SQL Data Type: nvarchar(200)
    * * Description: The resource's label as it appeared on the source page, e.g. "Marion Assessor" or "Recorder - Tapestry". Free text — county resource naming isn't standardized across the state.
    */
    get ResourceLabel(): string {
        return this.Get('ResourceLabel');
    }
    set ResourceLabel(value: string) {
        this.Set('ResourceLabel', value);
    }

    /**
    * * Field Name: ResourceCategory
    * * Display Name: Resource Category
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * Assessor
    *   * Auditor
    *   * GIS
    *   * Other
    *   * Recorder
    *   * Treasurer
    * * Description: Best-effort category inferred from the label (Assessor/Auditor/Treasurer/Recorder/GIS/Other) — a categorization convenience, not authoritative.
    */
    get ResourceCategory(): 'Assessor' | 'Auditor' | 'GIS' | 'Other' | 'Recorder' | 'Treasurer' | null {
        return this.Get('ResourceCategory');
    }
    set ResourceCategory(value: 'Assessor' | 'Auditor' | 'GIS' | 'Other' | 'Recorder' | 'Treasurer' | null) {
        this.Set('ResourceCategory', value);
    }

    /**
    * * Field Name: ResourceURL
    * * Display Name: Resource URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: URL of the resource.
    */
    get ResourceURL(): string {
        return this.Get('ResourceURL');
    }
    set ResourceURL(value: string) {
        this.Set('ResourceURL', value);
    }

    /**
    * * Field Name: Phone
    * * Display Name: Phone
    * * SQL Data Type: nvarchar(30)
    * * Description: Phone number, if the source directory listed one.
    */
    get Phone(): string | null {
        return this.Get('Phone');
    }
    set Phone(value: string | null) {
        this.Set('Phone', value);
    }

    /**
    * * Field Name: SourceRegistryID
    * * Display Name: Source Registry
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
    * * Description: The SourceRegistry entry this was gathered from (the NETR Online county directory).
    */
    get SourceRegistryID(): string | null {
        return this.Get('SourceRegistryID');
    }
    set SourceRegistryID(value: string | null) {
        this.Set('SourceRegistryID', value);
    }

    /**
    * * Field Name: DiscoveredAt
    * * Display Name: Discovered At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When this resource link was gathered.
    */
    get DiscoveredAt(): Date {
        return this.Get('DiscoveredAt');
    }
    set DiscoveredAt(value: Date) {
        this.Set('DiscoveredAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SourceRegistry
    * * Display Name: Source Registry Name
    * * SQL Data Type: nvarchar(200)
    */
    get SourceRegistry(): string | null {
        return this.Get('SourceRegistry');
    }
}


/**
 * DLGF Building Details - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DLGFBuildingDetail
 * * Base View: vwDLGFBuildingDetails
 * * @description DLGF/GIO statewide geodatabase BUILDINGDETAIL table, C&I slice. Floor/section pricing rows within a building (use code, SF, SF rate, framing, sprinkler, unit config).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'DLGF Building Details')
export class indianataxDLGFBuildingDetailEntity extends BaseEntity<indianataxDLGFBuildingDetailEntityType> {
    /**
    * Loads the DLGF Building Details record from the database
    * @param ID: string - primary key value to load the DLGF Building Details record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDLGFBuildingDetailEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    */
    get SourceDocumentID(): string {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: SourceYear
    * * Display Name: Source Year
    * * SQL Data Type: smallint
    */
    get SourceYear(): number {
        return this.Get('SourceYear');
    }
    set SourceYear(value: number) {
        this.Set('SourceYear', value);
    }

    /**
    * * Field Name: BuildingNumber
    * * Display Name: Building Number
    * * SQL Data Type: nvarchar(20)
    */
    get BuildingNumber(): string | null {
        return this.Get('BuildingNumber');
    }
    set BuildingNumber(value: string | null) {
        this.Set('BuildingNumber', value);
    }

    /**
    * * Field Name: FloorNumber
    * * Display Name: Floor Number
    * * SQL Data Type: nvarchar(10)
    */
    get FloorNumber(): string | null {
        return this.Get('FloorNumber');
    }
    set FloorNumber(value: string | null) {
        this.Set('FloorNumber', value);
    }

    /**
    * * Field Name: SectionLetterOrNumber
    * * Display Name: Section Letter or Number
    * * SQL Data Type: nvarchar(10)
    */
    get SectionLetterOrNumber(): string | null {
        return this.Get('SectionLetterOrNumber');
    }
    set SectionLetterOrNumber(value: string | null) {
        this.Set('SectionLetterOrNumber', value);
    }

    /**
    * * Field Name: PricingKey
    * * Display Name: Pricing Key
    * * SQL Data Type: nvarchar(20)
    */
    get PricingKey(): string | null {
        return this.Get('PricingKey');
    }
    set PricingKey(value: string | null) {
        this.Set('PricingKey', value);
    }

    /**
    * * Field Name: UseCode
    * * Display Name: Use Code
    * * SQL Data Type: nvarchar(20)
    */
    get UseCode(): string | null {
        return this.Get('UseCode');
    }
    set UseCode(value: string | null) {
        this.Set('UseCode', value);
    }

    /**
    * * Field Name: SquareFootArea
    * * Display Name: Square Foot Area
    * * SQL Data Type: decimal(14, 2)
    */
    get SquareFootArea(): number | null {
        return this.Get('SquareFootArea');
    }
    set SquareFootArea(value: number | null) {
        this.Set('SquareFootArea', value);
    }

    /**
    * * Field Name: SquareFootRate
    * * Display Name: Square Foot Rate
    * * SQL Data Type: decimal(14, 4)
    */
    get SquareFootRate(): number | null {
        return this.Get('SquareFootRate');
    }
    set SquareFootRate(value: number | null) {
        this.Set('SquareFootRate', value);
    }

    /**
    * * Field Name: FramingType
    * * Display Name: Framing Type
    * * SQL Data Type: decimal(9, 2)
    */
    get FramingType(): number | null {
        return this.Get('FramingType');
    }
    set FramingType(value: number | null) {
        this.Set('FramingType', value);
    }

    /**
    * * Field Name: WallType
    * * Display Name: Wall Type
    * * SQL Data Type: decimal(9, 2)
    */
    get WallType(): number | null {
        return this.Get('WallType');
    }
    set WallType(value: number | null) {
        this.Set('WallType', value);
    }

    /**
    * * Field Name: WallHeight
    * * Display Name: Wall Height
    * * SQL Data Type: decimal(9, 2)
    */
    get WallHeight(): number | null {
        return this.Get('WallHeight');
    }
    set WallHeight(value: number | null) {
        this.Set('WallHeight', value);
    }

    /**
    * * Field Name: HeatingACValueAdjustment
    * * Display Name: Heating/AC Value Adjustment
    * * SQL Data Type: decimal(14, 2)
    */
    get HeatingACValueAdjustment(): number | null {
        return this.Get('HeatingACValueAdjustment');
    }
    set HeatingACValueAdjustment(value: number | null) {
        this.Set('HeatingACValueAdjustment', value);
    }

    /**
    * * Field Name: SprinklerValueAdjustment
    * * Display Name: Sprinkler Value Adjustment
    * * SQL Data Type: decimal(14, 2)
    */
    get SprinklerValueAdjustment(): number | null {
        return this.Get('SprinklerValueAdjustment');
    }
    set SprinklerValueAdjustment(value: number | null) {
        this.Set('SprinklerValueAdjustment', value);
    }

    /**
    * * Field Name: AverageDepthForStripRetail
    * * Display Name: Average Depth for Strip Retail
    * * SQL Data Type: nvarchar(20)
    */
    get AverageDepthForStripRetail(): string | null {
        return this.Get('AverageDepthForStripRetail');
    }
    set AverageDepthForStripRetail(value: string | null) {
        this.Set('AverageDepthForStripRetail', value);
    }

    /**
    * * Field Name: IndividuallyOwnedUnit
    * * Display Name: Individually Owned Unit
    * * SQL Data Type: nvarchar(10)
    */
    get IndividuallyOwnedUnit(): string | null {
        return this.Get('IndividuallyOwnedUnit');
    }
    set IndividuallyOwnedUnit(value: string | null) {
        this.Set('IndividuallyOwnedUnit', value);
    }

    /**
    * * Field Name: IndividuallyOwnedUnitSize
    * * Display Name: Individually Owned Unit Size
    * * SQL Data Type: decimal(14, 2)
    */
    get IndividuallyOwnedUnitSize(): number | null {
        return this.Get('IndividuallyOwnedUnitSize');
    }
    set IndividuallyOwnedUnitSize(value: number | null) {
        this.Set('IndividuallyOwnedUnitSize', value);
    }

    /**
    * * Field Name: ConfigurationCode
    * * Display Name: Configuration Code
    * * SQL Data Type: nvarchar(20)
    */
    get ConfigurationCode(): string | null {
        return this.Get('ConfigurationCode');
    }
    set ConfigurationCode(value: string | null) {
        this.Set('ConfigurationCode', value);
    }

    /**
    * * Field Name: NumberOfUnits
    * * Display Name: Number of Units
    * * SQL Data Type: decimal(9, 2)
    */
    get NumberOfUnits(): number | null {
        return this.Get('NumberOfUnits');
    }
    set NumberOfUnits(value: number | null) {
        this.Set('NumberOfUnits', value);
    }

    /**
    * * Field Name: AverageUnitSize
    * * Display Name: Average Unit Size
    * * SQL Data Type: decimal(14, 2)
    */
    get AverageUnitSize(): number | null {
        return this.Get('AverageUnitSize');
    }
    set AverageUnitSize(value: number | null) {
        this.Set('AverageUnitSize', value);
    }

    /**
    * * Field Name: ImprovementInstanceNumber
    * * Display Name: Improvement Instance Number
    * * SQL Data Type: int
    */
    get ImprovementInstanceNumber(): number | null {
        return this.Get('ImprovementInstanceNumber');
    }
    set ImprovementInstanceNumber(value: number | null) {
        this.Set('ImprovementInstanceNumber', value);
    }

    /**
    * * Field Name: BuildingInstanceNumber
    * * Display Name: Building Instance Number
    * * SQL Data Type: int
    */
    get BuildingInstanceNumber(): number | null {
        return this.Get('BuildingInstanceNumber');
    }
    set BuildingInstanceNumber(value: number | null) {
        this.Set('BuildingInstanceNumber', value);
    }

    /**
    * * Field Name: BuildingDetailInstanceNumber
    * * Display Name: Building Detail Instance Number
    * * SQL Data Type: int
    */
    get BuildingDetailInstanceNumber(): number | null {
        return this.Get('BuildingDetailInstanceNumber');
    }
    set BuildingDetailInstanceNumber(value: number | null) {
        this.Set('BuildingDetailInstanceNumber', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Reference
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * DLGF Buildings - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DLGFBuilding
 * * Base View: vwDLGFBuildings
 * * @description DLGF/GIO statewide geodatabase BUILDING table, C&I slice (class 300-499, all 92 counties). One row per building. Independent of the PRC-sourced CountyAssessorImprovement -- kept separate as a cross-check source. Every row carries SourceDocumentID (the gdb, DocumentType StatewideParcelDataset).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'DLGF Buildings')
export class indianataxDLGFBuildingEntity extends BaseEntity<indianataxDLGFBuildingEntityType> {
    /**
    * Loads the DLGF Buildings record from the database
    * @param ID: string - primary key value to load the DLGF Buildings record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDLGFBuildingEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    */
    get SourceDocumentID(): string {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: SourceYear
    * * Display Name: Source Year
    * * SQL Data Type: smallint
    */
    get SourceYear(): number {
        return this.Get('SourceYear');
    }
    set SourceYear(value: number) {
        this.Set('SourceYear', value);
    }

    /**
    * * Field Name: BuildingNumber
    * * Display Name: Building Number
    * * SQL Data Type: nvarchar(20)
    */
    get BuildingNumber(): string | null {
        return this.Get('BuildingNumber');
    }
    set BuildingNumber(value: string | null) {
        this.Set('BuildingNumber', value);
    }

    /**
    * * Field Name: PricingKeyPredominantUse
    * * Display Name: Pricing Key Predominant Use
    * * SQL Data Type: nvarchar(20)
    */
    get PricingKeyPredominantUse(): string | null {
        return this.Get('PricingKeyPredominantUse');
    }
    set PricingKeyPredominantUse(value: string | null) {
        this.Set('PricingKeyPredominantUse', value);
    }

    /**
    * * Field Name: NumberOfFloors
    * * Display Name: Number of Floors
    * * SQL Data Type: decimal(6, 2)
    */
    get NumberOfFloors(): number | null {
        return this.Get('NumberOfFloors');
    }
    set NumberOfFloors(value: number | null) {
        this.Set('NumberOfFloors', value);
    }

    /**
    * * Field Name: TotalSquareFootArea
    * * Display Name: Total Square Foot Area
    * * SQL Data Type: decimal(14, 2)
    */
    get TotalSquareFootArea(): number | null {
        return this.Get('TotalSquareFootArea');
    }
    set TotalSquareFootArea(value: number | null) {
        this.Set('TotalSquareFootArea', value);
    }

    /**
    * * Field Name: TotalBaseValue
    * * Display Name: Total Base Value
    * * SQL Data Type: decimal(14, 2)
    */
    get TotalBaseValue(): number | null {
        return this.Get('TotalBaseValue');
    }
    set TotalBaseValue(value: number | null) {
        this.Set('TotalBaseValue', value);
    }

    /**
    * * Field Name: PlumbingFixturesValue
    * * Display Name: Plumbing Fixtures Value
    * * SQL Data Type: decimal(14, 2)
    */
    get PlumbingFixturesValue(): number | null {
        return this.Get('PlumbingFixturesValue');
    }
    set PlumbingFixturesValue(value: number | null) {
        this.Set('PlumbingFixturesValue', value);
    }

    /**
    * * Field Name: SpecialFeaturesValue
    * * Display Name: Special Features Value
    * * SQL Data Type: decimal(14, 2)
    */
    get SpecialFeaturesValue(): number | null {
        return this.Get('SpecialFeaturesValue');
    }
    set SpecialFeaturesValue(value: number | null) {
        this.Set('SpecialFeaturesValue', value);
    }

    /**
    * * Field Name: ExteriorFeaturesValue
    * * Display Name: Exterior Features Value
    * * SQL Data Type: decimal(14, 2)
    */
    get ExteriorFeaturesValue(): number | null {
        return this.Get('ExteriorFeaturesValue');
    }
    set ExteriorFeaturesValue(value: number | null) {
        this.Set('ExteriorFeaturesValue', value);
    }

    /**
    * * Field Name: ImprovementInstanceNumber
    * * Display Name: Improvement Instance Number
    * * SQL Data Type: int
    */
    get ImprovementInstanceNumber(): number | null {
        return this.Get('ImprovementInstanceNumber');
    }
    set ImprovementInstanceNumber(value: number | null) {
        this.Set('ImprovementInstanceNumber', value);
    }

    /**
    * * Field Name: BuildingInstanceNumber
    * * Display Name: Building Instance Number
    * * SQL Data Type: int
    */
    get BuildingInstanceNumber(): number | null {
        return this.Get('BuildingInstanceNumber');
    }
    set BuildingInstanceNumber(value: number | null) {
        this.Set('BuildingInstanceNumber', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * DLGF Improvements - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DLGFImprovement
 * * Base View: vwDLGFImprovements
 * * @description DLGF/GIO statewide geodatabase IMPROVE table, C&I slice. One row per improvement -- carries grade, year/effective-year built, condition, ReplacementCost and physical/obsolescence depreciation (the cost-approach RCN inputs, OPP-22) plus the AV cap-tier split.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'DLGF Improvements')
export class indianataxDLGFImprovementEntity extends BaseEntity<indianataxDLGFImprovementEntityType> {
    /**
    * Loads the DLGF Improvements record from the database
    * @param ID: string - primary key value to load the DLGF Improvements record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDLGFImprovementEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument for the DLGF geodatabase pull this row came from (DocumentType StatewideParcelDataset).
    */
    get SourceDocumentID(): string {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: SourceYear
    * * Display Name: Source Year
    * * SQL Data Type: smallint
    */
    get SourceYear(): number {
        return this.Get('SourceYear');
    }
    set SourceYear(value: number) {
        this.Set('SourceYear', value);
    }

    /**
    * * Field Name: DwellingOrBuildingNumber
    * * Display Name: Dwelling or Building Number
    * * SQL Data Type: nvarchar(20)
    */
    get DwellingOrBuildingNumber(): string | null {
        return this.Get('DwellingOrBuildingNumber');
    }
    set DwellingOrBuildingNumber(value: string | null) {
        this.Set('DwellingOrBuildingNumber', value);
    }

    /**
    * * Field Name: ImprovementInstanceNumber
    * * Display Name: Improvement Instance Number
    * * SQL Data Type: nvarchar(10)
    */
    get ImprovementInstanceNumber(): string | null {
        return this.Get('ImprovementInstanceNumber');
    }
    set ImprovementInstanceNumber(value: string | null) {
        this.Set('ImprovementInstanceNumber', value);
    }

    /**
    * * Field Name: ImprovementTypeCode
    * * Display Name: Improvement Type
    * * SQL Data Type: nvarchar(20)
    */
    get ImprovementTypeCode(): string | null {
        return this.Get('ImprovementTypeCode');
    }
    set ImprovementTypeCode(value: string | null) {
        this.Set('ImprovementTypeCode', value);
    }

    /**
    * * Field Name: StoryHeightOrHeight
    * * Display Name: Story Height or Height
    * * SQL Data Type: decimal(9, 2)
    */
    get StoryHeightOrHeight(): number | null {
        return this.Get('StoryHeightOrHeight');
    }
    set StoryHeightOrHeight(value: number | null) {
        this.Set('StoryHeightOrHeight', value);
    }

    /**
    * * Field Name: ConstructionTypeCode
    * * Display Name: Construction Type
    * * SQL Data Type: nvarchar(20)
    */
    get ConstructionTypeCode(): string | null {
        return this.Get('ConstructionTypeCode');
    }
    set ConstructionTypeCode(value: string | null) {
        this.Set('ConstructionTypeCode', value);
    }

    /**
    * * Field Name: YearConstructed
    * * Display Name: Year Constructed
    * * SQL Data Type: nvarchar(10)
    */
    get YearConstructed(): string | null {
        return this.Get('YearConstructed');
    }
    set YearConstructed(value: string | null) {
        this.Set('YearConstructed', value);
    }

    /**
    * * Field Name: YearRemodeled
    * * Display Name: Year Remodeled
    * * SQL Data Type: nvarchar(10)
    */
    get YearRemodeled(): string | null {
        return this.Get('YearRemodeled');
    }
    set YearRemodeled(value: string | null) {
        this.Set('YearRemodeled', value);
    }

    /**
    * * Field Name: EffectiveConstructionYear
    * * Display Name: Effective Construction Year
    * * SQL Data Type: nvarchar(10)
    */
    get EffectiveConstructionYear(): string | null {
        return this.Get('EffectiveConstructionYear');
    }
    set EffectiveConstructionYear(value: string | null) {
        this.Set('EffectiveConstructionYear', value);
    }

    /**
    * * Field Name: Grade
    * * Display Name: Grade
    * * SQL Data Type: nvarchar(10)
    */
    get Grade(): string | null {
        return this.Get('Grade');
    }
    set Grade(value: string | null) {
        this.Set('Grade', value);
    }

    /**
    * * Field Name: ConditionCode
    * * Display Name: Condition
    * * SQL Data Type: nvarchar(10)
    */
    get ConditionCode(): string | null {
        return this.Get('ConditionCode');
    }
    set ConditionCode(value: string | null) {
        this.Set('ConditionCode', value);
    }

    /**
    * * Field Name: NeighborhoodCode
    * * Display Name: Neighborhood
    * * SQL Data Type: nvarchar(30)
    */
    get NeighborhoodCode(): string | null {
        return this.Get('NeighborhoodCode');
    }
    set NeighborhoodCode(value: string | null) {
        this.Set('NeighborhoodCode', value);
    }

    /**
    * * Field Name: ImprovementSize
    * * Display Name: Improvement Size
    * * SQL Data Type: decimal(14, 2)
    */
    get ImprovementSize(): number | null {
        return this.Get('ImprovementSize');
    }
    set ImprovementSize(value: number | null) {
        this.Set('ImprovementSize', value);
    }

    /**
    * * Field Name: ReplacementCost
    * * Display Name: Replacement Cost
    * * SQL Data Type: decimal(14, 2)
    * * Description: Replacement cost new for this improvement (before depreciation). A cost-approach input.
    */
    get ReplacementCost(): number | null {
        return this.Get('ReplacementCost');
    }
    set ReplacementCost(value: number | null) {
        this.Set('ReplacementCost', value);
    }

    /**
    * * Field Name: AppraisedValue
    * * Display Name: Appraised Value
    * * SQL Data Type: decimal(14, 2)
    */
    get AppraisedValue(): number | null {
        return this.Get('AppraisedValue');
    }
    set AppraisedValue(value: number | null) {
        this.Set('AppraisedValue', value);
    }

    /**
    * * Field Name: PhysicalDepreciationPct
    * * Display Name: Physical Depreciation %
    * * SQL Data Type: decimal(9, 4)
    */
    get PhysicalDepreciationPct(): number | null {
        return this.Get('PhysicalDepreciationPct');
    }
    set PhysicalDepreciationPct(value: number | null) {
        this.Set('PhysicalDepreciationPct', value);
    }

    /**
    * * Field Name: ObsolescenceDepreciationPct
    * * Display Name: Obsolescence Depreciation %
    * * SQL Data Type: decimal(9, 4)
    */
    get ObsolescenceDepreciationPct(): number | null {
        return this.Get('ObsolescenceDepreciationPct');
    }
    set ObsolescenceDepreciationPct(value: number | null) {
        this.Set('ObsolescenceDepreciationPct', value);
    }

    /**
    * * Field Name: PercentComplete
    * * Display Name: Percent Complete
    * * SQL Data Type: decimal(9, 4)
    */
    get PercentComplete(): number | null {
        return this.Get('PercentComplete');
    }
    set PercentComplete(value: number | null) {
        this.Set('PercentComplete', value);
    }

    /**
    * * Field Name: AVImprovements1PercentCap
    * * Display Name: AV Improvements Tier 1 % Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVImprovements1PercentCap(): number | null {
        return this.Get('AVImprovements1PercentCap');
    }
    set AVImprovements1PercentCap(value: number | null) {
        this.Set('AVImprovements1PercentCap', value);
    }

    /**
    * * Field Name: AVImprovements2PercentCap
    * * Display Name: AV Improvements Tier 2 % Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVImprovements2PercentCap(): number | null {
        return this.Get('AVImprovements2PercentCap');
    }
    set AVImprovements2PercentCap(value: number | null) {
        this.Set('AVImprovements2PercentCap', value);
    }

    /**
    * * Field Name: AVImprovements3PercentCap
    * * Display Name: AV Improvements Tier 3 % Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVImprovements3PercentCap(): number | null {
        return this.Get('AVImprovements3PercentCap');
    }
    set AVImprovements3PercentCap(value: number | null) {
        this.Set('AVImprovements3PercentCap', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * DLGF Lands - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DLGFLand
 * * Base View: vwDLGFLands
 * * @description DLGF/GIO statewide geodatabase LAND table, C&I slice. One row per land segment (frontage/depth, base rate, acreage, SF, soil, influence factors, AV cap-tier split).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'DLGF Lands')
export class indianataxDLGFLandEntity extends BaseEntity<indianataxDLGFLandEntityType> {
    /**
    * Loads the DLGF Lands record from the database
    * @param ID: string - primary key value to load the DLGF Lands record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDLGFLandEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    */
    get SourceDocumentID(): string {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: SourceYear
    * * Display Name: Source Year
    * * SQL Data Type: smallint
    */
    get SourceYear(): number {
        return this.Get('SourceYear');
    }
    set SourceYear(value: number) {
        this.Set('SourceYear', value);
    }

    /**
    * * Field Name: LandInstanceNumber
    * * Display Name: Land Instance Number
    * * SQL Data Type: nvarchar(10)
    */
    get LandInstanceNumber(): string | null {
        return this.Get('LandInstanceNumber');
    }
    set LandInstanceNumber(value: string | null) {
        this.Set('LandInstanceNumber', value);
    }

    /**
    * * Field Name: LandLotTypeCode
    * * Display Name: Land Lot Type Code
    * * SQL Data Type: nvarchar(10)
    */
    get LandLotTypeCode(): string | null {
        return this.Get('LandLotTypeCode');
    }
    set LandLotTypeCode(value: string | null) {
        this.Set('LandLotTypeCode', value);
    }

    /**
    * * Field Name: ActualFrontage
    * * Display Name: Actual Frontage
    * * SQL Data Type: decimal(12, 2)
    */
    get ActualFrontage(): number | null {
        return this.Get('ActualFrontage');
    }
    set ActualFrontage(value: number | null) {
        this.Set('ActualFrontage', value);
    }

    /**
    * * Field Name: EffectiveFrontage
    * * Display Name: Effective Frontage
    * * SQL Data Type: decimal(12, 2)
    */
    get EffectiveFrontage(): number | null {
        return this.Get('EffectiveFrontage');
    }
    set EffectiveFrontage(value: number | null) {
        this.Set('EffectiveFrontage', value);
    }

    /**
    * * Field Name: EffectiveDepth
    * * Display Name: Effective Depth
    * * SQL Data Type: decimal(12, 2)
    */
    get EffectiveDepth(): number | null {
        return this.Get('EffectiveDepth');
    }
    set EffectiveDepth(value: number | null) {
        this.Set('EffectiveDepth', value);
    }

    /**
    * * Field Name: BaseRate
    * * Display Name: Base Rate
    * * SQL Data Type: decimal(14, 4)
    */
    get BaseRate(): number | null {
        return this.Get('BaseRate');
    }
    set BaseRate(value: number | null) {
        this.Set('BaseRate', value);
    }

    /**
    * * Field Name: AppraisedValue
    * * Display Name: Appraised Value
    * * SQL Data Type: decimal(14, 2)
    */
    get AppraisedValue(): number | null {
        return this.Get('AppraisedValue');
    }
    set AppraisedValue(value: number | null) {
        this.Set('AppraisedValue', value);
    }

    /**
    * * Field Name: Acreage
    * * Display Name: Acreage
    * * SQL Data Type: decimal(14, 4)
    */
    get Acreage(): number | null {
        return this.Get('Acreage');
    }
    set Acreage(value: number | null) {
        this.Set('Acreage', value);
    }

    /**
    * * Field Name: SquareFeet
    * * Display Name: Square Feet
    * * SQL Data Type: decimal(16, 2)
    */
    get SquareFeet(): number | null {
        return this.Get('SquareFeet');
    }
    set SquareFeet(value: number | null) {
        this.Set('SquareFeet', value);
    }

    /**
    * * Field Name: SoilID
    * * Display Name: Soil ID
    * * SQL Data Type: nvarchar(20)
    */
    get SoilID(): string | null {
        return this.Get('SoilID');
    }
    set SoilID(value: string | null) {
        this.Set('SoilID', value);
    }

    /**
    * * Field Name: SoilProductivityFactor
    * * Display Name: Soil Productivity Factor
    * * SQL Data Type: decimal(9, 4)
    */
    get SoilProductivityFactor(): number | null {
        return this.Get('SoilProductivityFactor');
    }
    set SoilProductivityFactor(value: number | null) {
        this.Set('SoilProductivityFactor', value);
    }

    /**
    * * Field Name: InfluenceFactorCode1
    * * Display Name: Influence Factor Code 1
    * * SQL Data Type: nvarchar(10)
    */
    get InfluenceFactorCode1(): string | null {
        return this.Get('InfluenceFactorCode1');
    }
    set InfluenceFactorCode1(value: string | null) {
        this.Set('InfluenceFactorCode1', value);
    }

    /**
    * * Field Name: InfluenceFactor1
    * * Display Name: Influence Factor 1
    * * SQL Data Type: decimal(9, 4)
    */
    get InfluenceFactor1(): number | null {
        return this.Get('InfluenceFactor1');
    }
    set InfluenceFactor1(value: number | null) {
        this.Set('InfluenceFactor1', value);
    }

    /**
    * * Field Name: InfluenceFactorCode2
    * * Display Name: Influence Factor Code 2
    * * SQL Data Type: nvarchar(10)
    */
    get InfluenceFactorCode2(): string | null {
        return this.Get('InfluenceFactorCode2');
    }
    set InfluenceFactorCode2(value: string | null) {
        this.Set('InfluenceFactorCode2', value);
    }

    /**
    * * Field Name: InfluenceFactor2
    * * Display Name: Influence Factor 2
    * * SQL Data Type: decimal(9, 4)
    */
    get InfluenceFactor2(): number | null {
        return this.Get('InfluenceFactor2');
    }
    set InfluenceFactor2(value: number | null) {
        this.Set('InfluenceFactor2', value);
    }

    /**
    * * Field Name: InfluenceFactorCode3
    * * Display Name: Influence Factor Code 3
    * * SQL Data Type: nvarchar(10)
    */
    get InfluenceFactorCode3(): string | null {
        return this.Get('InfluenceFactorCode3');
    }
    set InfluenceFactorCode3(value: string | null) {
        this.Set('InfluenceFactorCode3', value);
    }

    /**
    * * Field Name: InfluenceFactor3
    * * Display Name: Influence Factor 3
    * * SQL Data Type: decimal(9, 4)
    */
    get InfluenceFactor3(): number | null {
        return this.Get('InfluenceFactor3');
    }
    set InfluenceFactor3(value: number | null) {
        this.Set('InfluenceFactor3', value);
    }

    /**
    * * Field Name: DepthFactor
    * * Display Name: Depth Factor
    * * SQL Data Type: decimal(9, 4)
    */
    get DepthFactor(): number | null {
        return this.Get('DepthFactor');
    }
    set DepthFactor(value: number | null) {
        this.Set('DepthFactor', value);
    }

    /**
    * * Field Name: AcreageFactor
    * * Display Name: Acreage Factor
    * * SQL Data Type: decimal(9, 4)
    */
    get AcreageFactor(): number | null {
        return this.Get('AcreageFactor');
    }
    set AcreageFactor(value: number | null) {
        this.Set('AcreageFactor', value);
    }

    /**
    * * Field Name: AVLand1PercentCap
    * * Display Name: AV Land 1 Percent Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVLand1PercentCap(): number | null {
        return this.Get('AVLand1PercentCap');
    }
    set AVLand1PercentCap(value: number | null) {
        this.Set('AVLand1PercentCap', value);
    }

    /**
    * * Field Name: AVLand2PercentCap
    * * Display Name: AV Land 2 Percent Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVLand2PercentCap(): number | null {
        return this.Get('AVLand2PercentCap');
    }
    set AVLand2PercentCap(value: number | null) {
        this.Set('AVLand2PercentCap', value);
    }

    /**
    * * Field Name: AVLand3PercentCap
    * * Display Name: AV Land 3 Percent Cap
    * * SQL Data Type: decimal(14, 2)
    */
    get AVLand3PercentCap(): number | null {
        return this.Get('AVLand3PercentCap');
    }
    set AVLand3PercentCap(value: number | null) {
        this.Set('AVLand3PercentCap', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Reference
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Document Acquisitions - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DocumentAcquisition
 * * Base View: vwDocumentAcquisitions
 * * @description The mechanical, high-volume, per-subject fetch-with-retry acquisition tracker: one row per (Parcel, DocumentType) being fetched from a source that requires HTTP retries and can fail. Tracks attempt count, last error, retry timing, and escalation to human review after repeated failure -- the "what has been / needs to be researched, when, was it successful, and until it is" ledger. Distinct from SourceRegistry/DocumentCatalog (editorial discovery of unstructured documents) and ResearchTask (deliberately deferred research decisions).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Document Acquisitions')
export class indianataxDocumentAcquisitionEntity extends BaseEntity<indianataxDocumentAcquisitionEntityType> {
    /**
    * Loads the Document Acquisitions record from the database
    * @param ID: string - primary key value to load the Document Acquisitions record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDocumentAcquisitionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this acquisition tracks a document for.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: DocumentType
    * * Display Name: Document Type
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * PropertyRecordCard
    *   * TaxHistoryReport
    * * Description: Which document type is being fetched for this parcel -- a deliberate subset of SourceDocument.DocumentType (only the mechanically-fetched, per-parcel types: PropertyRecordCard, TaxHistoryReport). Together with ParcelID, the real uniqueness key.
    */
    get DocumentType(): 'PropertyRecordCard' | 'TaxHistoryReport' {
        return this.Get('DocumentType');
    }
    set DocumentType(value: 'PropertyRecordCard' | 'TaxHistoryReport') {
        this.Set('DocumentType', value);
    }

    /**
    * * Field Name: SubjectKey
    * * Display Name: Subject Key
    * * SQL Data Type: nvarchar(150)
    * * Description: Human-legible slug mirroring the on-disk file-naming grammar (e.g. "marion_prc_8050459_2026"), so a tracker row, a SourceDocument.RawFilePath, and a file on disk can be visually correlated. Informational/indexed only -- NOT the uniqueness key, since it legitimately changes once AssessmentYear becomes known from a successful fetch. See docs/NAMING_AND_RETENTION.md in the Indiana_Tax_Expert repo for the full grammar.
    */
    get SubjectKey(): string {
        return this.Get('SubjectKey');
    }
    set SubjectKey(value: string) {
        this.Set('SubjectKey', value);
    }

    /**
    * * Field Name: AssessmentYear
    * * Display Name: Assessment Year
    * * SQL Data Type: smallint
    * * Description: The assessment year of the most recently successfully fetched document for this (Parcel, DocumentType). NULL until first success -- not knowable before then, since these endpoints don't take a year parameter; you get whichever report is currently on file.
    */
    get AssessmentYear(): number | null {
        return this.Get('AssessmentYear');
    }
    set AssessmentYear(value: number | null) {
        this.Set('AssessmentYear', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: InProgress
    * * Value List Type: List
    * * Possible Values 
    *   * Failed
    *   * InProgress
    *   * NeedsReview
    *   * Succeeded
    * * Description: InProgress (never yet resolved) / Succeeded (current SourceDocumentID is valid and current) / Failed (most recent attempt failed, eligible for retry at NextAttemptDueAt) / NeedsReview (failed AttemptCount times at or beyond the escalation ceiling -- excluded from automatic retry, needs deliberate follow-up).
    */
    get Status(): 'Failed' | 'InProgress' | 'NeedsReview' | 'Succeeded' {
        return this.Get('Status');
    }
    set Status(value: 'Failed' | 'InProgress' | 'NeedsReview' | 'Succeeded') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: AttemptCount
    * * Display Name: Attempt Count
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Count of OUTER (script-run-level) acquisition attempts -- each of which already wraps up to 8 inner HTTP retries internally. Escalates Status to NeedsReview once this reaches 3.
    */
    get AttemptCount(): number {
        return this.Get('AttemptCount');
    }
    set AttemptCount(value: number) {
        this.Set('AttemptCount', value);
    }

    /**
    * * Field Name: FirstAttemptedAt
    * * Display Name: First Attempted At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When this (Parcel, DocumentType) was first attempted.
    */
    get FirstAttemptedAt(): Date {
        return this.Get('FirstAttemptedAt');
    }
    set FirstAttemptedAt(value: Date) {
        this.Set('FirstAttemptedAt', value);
    }

    /**
    * * Field Name: LastAttemptedAt
    * * Display Name: Last Attempted At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When this (Parcel, DocumentType) was most recently attempted, successful or not.
    */
    get LastAttemptedAt(): Date {
        return this.Get('LastAttemptedAt');
    }
    set LastAttemptedAt(value: Date) {
        this.Set('LastAttemptedAt', value);
    }

    /**
    * * Field Name: LastSucceededAt
    * * Display Name: Last Succeeded At
    * * SQL Data Type: datetimeoffset
    * * Description: When this (Parcel, DocumentType) was most recently successfully fetched and parsed. NULL if never successful.
    */
    get LastSucceededAt(): Date | null {
        return this.Get('LastSucceededAt');
    }
    set LastSucceededAt(value: Date | null) {
        this.Set('LastSucceededAt', value);
    }

    /**
    * * Field Name: LastErrorCode
    * * Display Name: Last Error Code
    * * SQL Data Type: nvarchar(100)
    * * Description: Short machine-oriented error identifier from the most recent failed attempt (e.g. "bad XRef entry", "not a PDF", "HTTP 500"). Cleared on success.
    */
    get LastErrorCode(): string | null {
        return this.Get('LastErrorCode');
    }
    set LastErrorCode(value: string | null) {
        this.Set('LastErrorCode', value);
    }

    /**
    * * Field Name: LastErrorMessage
    * * Display Name: Last Error Message
    * * SQL Data Type: nvarchar(500)
    * * Description: Full error message from the most recent failed attempt. Cleared on success.
    */
    get LastErrorMessage(): string | null {
        return this.Get('LastErrorMessage');
    }
    set LastErrorMessage(value: string | null) {
        this.Set('LastErrorMessage', value);
    }

    /**
    * * Field Name: NextAttemptDueAt
    * * Display Name: Next Attempt Due At
    * * SQL Data Type: datetimeoffset
    * * Description: Earliest time a bulk fetch run should retry this (Parcel, DocumentType) again, after a failure below the escalation ceiling. NULL once Succeeded or NeedsReview (nothing more to schedule).
    */
    get NextAttemptDueAt(): Date | null {
        return this.Get('NextAttemptDueAt');
    }
    set NextAttemptDueAt(value: Date | null) {
        this.Set('NextAttemptDueAt', value);
    }

    /**
    * * Field Name: EscalatedAt
    * * Display Name: Escalated At
    * * SQL Data Type: datetimeoffset
    * * Description: When Status flipped to NeedsReview (AttemptCount reached the escalation ceiling). NULL unless currently or previously escalated.
    */
    get EscalatedAt(): Date | null {
        return this.Get('EscalatedAt');
    }
    set EscalatedAt(value: Date | null) {
        this.Set('EscalatedAt', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument produced by the most recent successful fetch. NULL until Succeeded at least once. Mirrors (does not replace) CountyAssessorRecord.SourceDocumentID/TaxHistorySourceDocumentID, which are set to the same value in the same transaction.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text notes -- e.g. a manual explanation of why a NeedsReview row was set back to Failed for another retry attempt.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Document Catalogs - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: DocumentCatalog
 * * Base View: vwDocumentCatalogs
 * * @description One row per document discovered while scanning a SourceRegistry entry, whether or not it was fully ingested. This is the overall inventory of everything reviewed and considered — a document evaluated and excluded (e.g. a budget memo, not property-tax related) gets a row here same as one that was pulled in; SourceDocumentID links to the real stored document only once ingested.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Document Catalogs')
export class indianataxDocumentCatalogEntity extends BaseEntity<indianataxDocumentCatalogEntityType> {
    /**
    * Loads the Document Catalogs record from the database
    * @param ID: string - primary key value to load the Document Catalogs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxDocumentCatalogEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: SourceRegistryID
    * * Display Name: Source Registry ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
    * * Description: Which source this document was discovered on.
    */
    get SourceRegistryID(): string {
        return this.Get('SourceRegistryID');
    }
    set SourceRegistryID(value: string) {
        this.Set('SourceRegistryID', value);
    }

    /**
    * * Field Name: URL
    * * Display Name: URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: The document's URL (or local file path for non-web sources). Unique — the catalog's identity key for a document.
    */
    get URL(): string {
        return this.Get('URL');
    }
    set URL(value: string) {
        this.Set('URL', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(500)
    * * Description: Title/description as it appeared on the source page at discovery time.
    */
    get Title(): string | null {
        return this.Get('Title');
    }
    set Title(value: string | null) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: DiscoveredAt
    * * Display Name: Discovered At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When we first became aware of this document (found it listed on the source), independent of whether/when it was ingested.
    */
    get DiscoveredAt(): Date {
        return this.Get('DiscoveredAt');
    }
    set DiscoveredAt(value: Date) {
        this.Set('DiscoveredAt', value);
    }

    /**
    * * Field Name: DocumentDate
    * * Display Name: Document Date
    * * SQL Data Type: date
    * * Description: The date the document itself is dated/effective, as best determined at cataloging time (e.g. a memo's stated issue date on the index page).
    */
    get DocumentDate(): Date | null {
        return this.Get('DocumentDate');
    }
    set DocumentDate(value: Date | null) {
        this.Set('DocumentDate', value);
    }

    /**
    * * Field Name: IsPropertyTaxRelevant
    * * Display Name: Is Property Tax Relevant
    * * SQL Data Type: bit
    * * Description: Whether this document is relevant to real property taxation. NULL = not yet evaluated; 1/0 = evaluated and included/excluded.
    */
    get IsPropertyTaxRelevant(): boolean | null {
        return this.Get('IsPropertyTaxRelevant');
    }
    set IsPropertyTaxRelevant(value: boolean | null) {
        this.Set('IsPropertyTaxRelevant', value);
    }

    /**
    * * Field Name: RelevanceNotes
    * * Display Name: Relevance Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Why this document was included or excluded — e.g. "personal property, not real property" or "budget/TIF matter, out of scope".
    */
    get RelevanceNotes(): string | null {
        return this.Get('RelevanceNotes');
    }
    set RelevanceNotes(value: string | null) {
        this.Set('RelevanceNotes', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument this catalog entry resolved to, once actually fetched and stored. NULL until ingested (or permanently, if excluded).
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SourceRegistry
    * * Display Name: Source Registry
    * * SQL Data Type: nvarchar(200)
    */
    get SourceRegistry(): string {
        return this.Get('SourceRegistry');
    }
}


/**
 * Form Catalogs - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: FormCatalog
 * * Base View: vwFormCatalogs
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Form Catalogs')
export class indianataxFormCatalogEntity extends BaseEntity<indianataxFormCatalogEntityType> {
    /**
    * Loads the Form Catalogs record from the database
    * @param ID: string - primary key value to load the Form Catalogs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxFormCatalogEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: StateFormNumber
    * * Display Name: State Form Number
    * * SQL Data Type: nvarchar(20)
    * * Description: The number printed on every DLGF form itself (e.g. "21521", "53958", "21366") -- the reliable, near-deterministic way to identify which form a taxpayer uploaded, before any interpretive/LLM matching is needed.
    */
    get StateFormNumber(): string {
        return this.Get('StateFormNumber');
    }
    set StateFormNumber(value: string) {
        this.Set('StateFormNumber', value);
    }

    /**
    * * Field Name: FormLabel
    * * Display Name: Form Label
    * * SQL Data Type: nvarchar(30)
    * * Description: The colloquial form name (e.g. "Form 113/PP", "Form 130", "Form 11") -- deliberately matches AppealStage.FormRequired's own free-text convention exactly, so the two can be joined/compared as plain strings.
    */
    get FormLabel(): string {
        return this.Get('FormLabel');
    }
    set FormLabel(value: string) {
        this.Set('FormLabel', value);
    }

    /**
    * * Field Name: FullTitle
    * * Display Name: Full Title
    * * SQL Data Type: nvarchar(300)
    * * Description: The form's full official title as printed (e.g. "Notice of Assessment / Change by an Assessing Official").
    */
    get FullTitle(): string {
        return this.Get('FullTitle');
    }
    set FullTitle(value: string) {
        this.Set('FullTitle', value);
    }

    /**
    * * Field Name: RevisionCode
    * * Display Name: Revision Code
    * * SQL Data Type: nvarchar(30)
    * * Description: The revision code printed on the form (e.g. "R12 / 10-19") -- forms get revised periodically; this records which revision was actually verified against, so a later revision can be detected as needing re-verification.
    */
    get RevisionCode(): string | null {
        return this.Get('RevisionCode');
    }
    set RevisionCode(value: string | null) {
        this.Set('RevisionCode', value);
    }

    /**
    * * Field Name: Purpose
    * * Display Name: Purpose
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Plain-language description of what this form is for and when it's used.
    */
    get Purpose(): string {
        return this.Get('Purpose');
    }
    set Purpose(value: string) {
        this.Set('Purpose', value);
    }

    /**
    * * Field Name: FiledBy
    * * Display Name: Filed By
    * * SQL Data Type: nvarchar(100)
    * * Description: Who completes/files this form (e.g. "Assessing Official", "Taxpayer").
    */
    get FiledBy(): string {
        return this.Get('FiledBy');
    }
    set FiledBy(value: string) {
        this.Set('FiledBy', value);
    }

    /**
    * * Field Name: FiledWith
    * * Display Name: Filed With
    * * SQL Data Type: nvarchar(200)
    * * Description: Who receives this form (e.g. "Township Assessor or County Assessor"). Null for a form that is only issued outward (a notice), not filed with anyone.
    */
    get FiledWith(): string | null {
        return this.Get('FiledWith');
    }
    set FiledWith(value: string | null) {
        this.Set('FiledWith', value);
    }

    /**
    * * Field Name: PropertyTypeScope
    * * Display Name: Property Type Scope
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Both
    *   * Personal
    *   * PublicUtility
    *   * Real
    * * Description: Which kind of property this form applies to -- Real, Personal, Both, or PublicUtility.
    */
    get PropertyTypeScope(): 'Both' | 'Personal' | 'PublicUtility' | 'Real' {
        return this.Get('PropertyTypeScope');
    }
    set PropertyTypeScope(value: 'Both' | 'Personal' | 'PublicUtility' | 'Real') {
        this.Set('PropertyTypeScope', value);
    }

    /**
    * * Field Name: CorrespondingAppealStageID
    * * Display Name: Corresponding Appeal Stage
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
    * * Description: For a form that IS a step in the appeal process (Form 130, 131, 134): the indiana_tax.AppealStage row it corresponds to -- that row already carries the authoritative deadline/citation, not duplicated here. Null for a form that is not itself an appeal-process step.
    */
    get CorrespondingAppealStageID(): string | null {
        return this.Get('CorrespondingAppealStageID');
    }
    set CorrespondingAppealStageID(value: string | null) {
        this.Set('CorrespondingAppealStageID', value);
    }

    /**
    * * Field Name: TriggersAppealStageID
    * * Display Name: Triggers Appeal Stage
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Appeal Stages (vwAppealStages.ID)
    * * Description: For a NOTICE form (e.g. Form 11, Form 113/PP) whose issuance is what starts the clock on a downstream appeal-process step: the indiana_tax.AppealStage row it triggers. Null for a form that is not a triggering notice. A form should generally have exactly one of CorrespondingAppealStageID or TriggersAppealStageID set, not both -- not enforced by a CHECK since the distinction isn't safety-critical, just documented here.
    */
    get TriggersAppealStageID(): string | null {
        return this.Get('TriggersAppealStageID');
    }
    set TriggersAppealStageID(value: string | null) {
        this.Set('TriggersAppealStageID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument row for this form's own actual PDF (DocumentType = 'Form', same convention already used for AppealStage.SourceDocumentID's Form 130 row) -- every catalog row traces back to a real, hashed, retained document, not an assertion.
    */
    get SourceDocumentID(): string {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: SourceURL
    * * Display Name: Source URL
    * * SQL Data Type: nvarchar(500)
    * * Description: The forms.in.gov download URL this form was fetched from.
    */
    get SourceURL(): string {
        return this.Get('SourceURL');
    }
    set SourceURL(value: string) {
        this.Set('SourceURL', value);
    }

    /**
    * * Field Name: LastVerifiedAt
    * * Display Name: Last Verified At
    * * SQL Data Type: datetimeoffset
    * * Description: When this row was last verified against the actual form text -- distinct from __mj_UpdatedAt, which would also change on a purely mechanical edit.
    */
    get LastVerifiedAt(): Date {
        return this.Get('LastVerifiedAt');
    }
    set LastVerifiedAt(value: Date) {
        this.Set('LastVerifiedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: CorrespondingAppealStage
    * * Display Name: Corresponding Appeal Stage Name
    * * SQL Data Type: nvarchar(200)
    */
    get CorrespondingAppealStage(): string | null {
        return this.Get('CorrespondingAppealStage');
    }

    /**
    * * Field Name: TriggersAppealStage
    * * Display Name: Triggers Appeal Stage Name
    * * SQL Data Type: nvarchar(200)
    */
    get TriggersAppealStage(): string | null {
        return this.Get('TriggersAppealStage');
    }
}


/**
 * Jurisdiction Deadline Anchors - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: JurisdictionDeadlineAnchor
 * * Base View: vwJurisdictionDeadlineAnchors
 * * @description Per (county, township?, tax year, anchor event) the observed/published date that feeds a DeadlineBasis = 'RelativeDays' deadline (or branches a 'CalendarRule'). The "rolling deadline" shape from the Faegre Appeal Deadline Tracking workbook's WA/IL tabs. APPEND-ONLY BY YEAR: one row per key, never overwrite a prior year, so year-over-year history is just the older rows.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Jurisdiction Deadline Anchors')
export class indianataxJurisdictionDeadlineAnchorEntity extends BaseEntity<indianataxJurisdictionDeadlineAnchorEntityType> {
    /**
    * Loads the Jurisdiction Deadline Anchors record from the database
    * @param ID: string - primary key value to load the Jurisdiction Deadline Anchors record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxJurisdictionDeadlineAnchorEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: The jurisdiction (Indiana county number).
    */
    get CountyNumber(): number {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: TownshipName
    * * Display Name: Township Name
    * * SQL Data Type: nvarchar(60)
    * * Description: Set only when the anchor is township-level (Indiana has township assessors, and IL/WA-style rolling deadlines vary by township). NULL = county-level anchor.
    */
    get TownshipName(): string | null {
        return this.Get('TownshipName');
    }
    set TownshipName(value: string | null) {
        this.Set('TownshipName', value);
    }

    /**
    * * Field Name: TaxYear
    * * Display Name: Tax Year
    * * SQL Data Type: smallint
    * * Description: The assessment / tax year this anchor applies to.
    */
    get TaxYear(): number {
        return this.Get('TaxYear');
    }
    set TaxYear(value: number) {
        this.Set('TaxYear', value);
    }

    /**
    * * Field Name: AnchorEvent
    * * Display Name: Anchor Event
    * * SQL Data Type: nvarchar(40)
    * * Description: Same vocabulary as AppealStage.DeadlineAnchorEvent (Form11MailDate, PTABOAOrderDate, ...).
    */
    get AnchorEvent(): string {
        return this.Get('AnchorEvent');
    }
    set AnchorEvent(value: string) {
        this.Set('AnchorEvent', value);
    }

    /**
    * * Field Name: AnchorDate
    * * Display Name: Anchor Date
    * * SQL Data Type: date
    * * Description: The observed / published date. NULL while Status = 'Pending'.
    */
    get AnchorDate(): Date | null {
        return this.Get('AnchorDate');
    }
    set AnchorDate(value: Date | null) {
        this.Set('AnchorDate', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Pending
    * * Value List Type: List
    * * Possible Values 
    *   * Confirmed
    *   * Estimated
    *   * NotApplicable
    *   * Pending
    * * Description: Confirmed (from a primary source -- set SourceDocumentID), Estimated (projected from prior years), Pending (not yet known), or NotApplicable.
    */
    get Status(): 'Confirmed' | 'Estimated' | 'NotApplicable' | 'Pending' {
        return this.Get('Status');
    }
    set Status(value: 'Confirmed' | 'Estimated' | 'NotApplicable' | 'Pending') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: DerivedDeadline
    * * Display Name: Derived Deadline
    * * SQL Data Type: date
    * * Description: Convenience: AnchorDate resolved through the governing stage rule (anchor + offset, or the calendar-rule branch).
    */
    get DerivedDeadline(): Date | null {
        return this.Get('DerivedDeadline');
    }
    set DerivedDeadline(value: Date | null) {
        this.Set('DerivedDeadline', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument the date was taken from (a Form 11, an assessor calendar).
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text context.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Market Assumptions - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: MarketAssumption
 * * Base View: vwMarketAssumptions
 * * @description A market parameter used by the income approach: a capitalization rate, an implied NOI per SqFt / per Unit, a vacancy rate, an expense ratio, or a market rent per SqFt / per Unit. One row per (type, property-type group, submarket?, period, method).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Market Assumptions')
export class indianataxMarketAssumptionEntity extends BaseEntity<indianataxMarketAssumptionEntityType> {
    /**
    * Loads the Market Assumptions record from the database
    * @param ID: string - primary key value to load the Market Assumptions record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxMarketAssumptionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: AssumptionType
    * * Display Name: Assumption Type
    * * SQL Data Type: nvarchar(24)
    * * Value List Type: List
    * * Possible Values 
    *   * CapRate
    *   * ExpenseRatio
    *   * MarketRentPerSqFt
    *   * MarketRentPerUnit
    *   * NOIPerSqFt
    *   * NOIPerUnit
    *   * Vacancy
    * * Description: Which parameter this row states: CapRate / NOIPerSqFt / NOIPerUnit / Vacancy / ExpenseRatio / MarketRentPerSqFt / MarketRentPerUnit. Rates (CapRate/Vacancy/ExpenseRatio) are decimal fractions; the others are dollars.
    */
    get AssumptionType(): 'CapRate' | 'ExpenseRatio' | 'MarketRentPerSqFt' | 'MarketRentPerUnit' | 'NOIPerSqFt' | 'NOIPerUnit' | 'Vacancy' {
        return this.Get('AssumptionType');
    }
    set AssumptionType(value: 'CapRate' | 'ExpenseRatio' | 'MarketRentPerSqFt' | 'MarketRentPerUnit' | 'NOIPerSqFt' | 'NOIPerUnit' | 'Vacancy') {
        this.Set('AssumptionType', value);
    }

    /**
    * * Field Name: PropertyTypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * All
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
    * * Description: The property-type group this parameter applies to (Retail/Office/Industrial/Multifamily/Land/Special/Other), or 'All'.
    */
    get PropertyTypeGroup(): 'All' | 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special' {
        return this.Get('PropertyTypeGroup');
    }
    set PropertyTypeGroup(value: 'All' | 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special') {
        this.Set('PropertyTypeGroup', value);
    }

    /**
    * * Field Name: Submarket
    * * Display Name: Submarket
    * * SQL Data Type: nvarchar(80)
    * * Description: Submarket the parameter is specific to; NULL = countywide.
    */
    get Submarket(): string | null {
        return this.Get('Submarket');
    }
    set Submarket(value: string | null) {
        this.Set('Submarket', value);
    }

    /**
    * * Field Name: PeriodYear
    * * Display Name: Period Year
    * * SQL Data Type: smallint
    * * Description: The year the parameter represents (e.g. the assessment/valuation year, or the year the extracted sales cluster around). NULL if PeriodLabel carries the period instead.
    */
    get PeriodYear(): number | null {
        return this.Get('PeriodYear');
    }
    set PeriodYear(value: number | null) {
        this.Set('PeriodYear', value);
    }

    /**
    * * Field Name: PeriodLabel
    * * Display Name: Period Label
    * * SQL Data Type: nvarchar(30)
    * * Description: Free-text period when a single year does not fit (e.g. "2023-2025", "Q1 2024").
    */
    get PeriodLabel(): string | null {
        return this.Get('PeriodLabel');
    }
    set PeriodLabel(value: string | null) {
        this.Set('PeriodLabel', value);
    }

    /**
    * * Field Name: Value
    * * Display Name: Value
    * * SQL Data Type: decimal(14, 4)
    * * Description: The concluded / central value (median for a SalesExtraction row). Decimal fraction for rate types, dollars otherwise.
    */
    get Value(): number {
        return this.Get('Value');
    }
    set Value(value: number) {
        this.Set('Value', value);
    }

    /**
    * * Field Name: LowValue
    * * Display Name: Low Value
    * * SQL Data Type: decimal(14, 4)
    * * Description: Low end of the supported range (e.g. 25th percentile of the extracted sample).
    */
    get LowValue(): number | null {
        return this.Get('LowValue');
    }
    set LowValue(value: number | null) {
        this.Set('LowValue', value);
    }

    /**
    * * Field Name: HighValue
    * * Display Name: High Value
    * * SQL Data Type: decimal(14, 4)
    * * Description: High end of the supported range (e.g. 75th percentile).
    */
    get HighValue(): number | null {
        return this.Get('HighValue');
    }
    set HighValue(value: number | null) {
        this.Set('HighValue', value);
    }

    /**
    * * Field Name: SampleSize
    * * Display Name: Sample Size
    * * SQL Data Type: int
    * * Description: Number of observations behind a SalesExtraction row.
    */
    get SampleSize(): number | null {
        return this.Get('SampleSize');
    }
    set SampleSize(value: number | null) {
        this.Set('SampleSize', value);
    }

    /**
    * * Field Name: Method
    * * Display Name: Method
    * * SQL Data Type: nvarchar(24)
    * * Value List Type: List
    * * Possible Values 
    *   * BandOfInvestment
    *   * BrokerSurvey
    *   * Manual
    *   * SalesExtraction
    * * Description: How the value was derived: SalesExtraction (from CapRateAtSale / ImpliedNOIAtSale on indiana_tax.SaleTransaction), BrokerSurvey (RealtyRates / PwC / CBRE etc.), BandOfInvestment (mortgage-equity build-up), or Manual.
    */
    get Method(): 'BandOfInvestment' | 'BrokerSurvey' | 'Manual' | 'SalesExtraction' {
        return this.Get('Method');
    }
    set Method(value: 'BandOfInvestment' | 'BrokerSurvey' | 'Manual' | 'SalesExtraction') {
        this.Set('Method', value);
    }

    /**
    * * Field Name: SourceNote
    * * Display Name: Source Note
    * * SQL Data Type: nvarchar(300)
    * * Description: Citation / provenance for a non-extracted row (survey name, issue date, page).
    */
    get SourceNote(): string | null {
        return this.Get('SourceNote');
    }
    set SourceNote(value: string | null) {
        this.Set('SourceNote', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text notes.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Owner Portfolio Parcels - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: OwnerPortfolioParcel
 * * Base View: vwOwnerPortfolioParcels
 * * @description One parcel within an OwnerPortfolio owner group for a run: identity, 2025/2026 AV, the three ValuationAnalysis approach indications, the recommended floor/ask and estimated tax saving, and the appeal/rep status for that parcel.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Owner Portfolio Parcels')
export class indianataxOwnerPortfolioParcelEntity extends BaseEntity<indianataxOwnerPortfolioParcelEntityType> {
    /**
    * Loads the Owner Portfolio Parcels record from the database
    * @param ID: string - primary key value to load the Owner Portfolio Parcels record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxOwnerPortfolioParcelEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: OwnerPortfolioID
    * * Display Name: Owner Portfolio
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Owner Portfolios (vwOwnerPortfolios.ID)
    */
    get OwnerPortfolioID(): string {
        return this.Get('OwnerPortfolioID');
    }
    set OwnerPortfolioID(value: string) {
        this.Set('OwnerPortfolioID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string | null {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string | null) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: GISParcelNumber
    * * Display Name: GIS Parcel Number
    * * SQL Data Type: nvarchar(20)
    * * Description: parcel.parcel -- the 7-digit Marion County GIS parcel number, the always-present link key to the PRC and tax history even when ParcelID is null.
    */
    get GISParcelNumber(): string {
        return this.Get('GISParcelNumber');
    }
    set GISParcelNumber(value: string) {
        this.Set('GISParcelNumber', value);
    }

    /**
    * * Field Name: Address
    * * Display Name: Address
    * * SQL Data Type: nvarchar(300)
    * * Description: The parcel's situs (site) address as shown in the dashboard parcel list.
    */
    get Address(): string | null {
        return this.Get('Address');
    }
    set Address(value: string | null) {
        this.Set('Address', value);
    }

    /**
    * * Field Name: TypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(60)
    * * Description: The parcel's property-type group (e.g. Office, Retail, Industrial, Apartment, Hospitality) used for the by-type breakdowns.
    */
    get TypeGroup(): string | null {
        return this.Get('TypeGroup');
    }
    set TypeGroup(value: string | null) {
        this.Set('TypeGroup', value);
    }

    /**
    * * Field Name: CurrentAV
    * * Display Name: Current Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: The parcel's current (most recent certified) total assessed value.
    */
    get CurrentAV(): number | null {
        return this.Get('CurrentAV');
    }
    set CurrentAV(value: number | null) {
        this.Set('CurrentAV', value);
    }

    /**
    * * Field Name: AV2025
    * * Display Name: 2025 Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: The parcel's 2025 total assessed value.
    */
    get AV2025(): number | null {
        return this.Get('AV2025');
    }
    set AV2025(value: number | null) {
        this.Set('AV2025', value);
    }

    /**
    * * Field Name: AV2026
    * * Display Name: 2026 Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: The parcel's 2026 total assessed value.
    */
    get AV2026(): number | null {
        return this.Get('AV2026');
    }
    set AV2026(value: number | null) {
        this.Set('AV2026', value);
    }

    /**
    * * Field Name: AVYoYPct
    * * Display Name: AV Year-over-Year Change %
    * * SQL Data Type: decimal(9, 4)
    * * Description: The parcel's year-over-year assessed-value change as a fraction (0.3000 = +30%).
    */
    get AVYoYPct(): number | null {
        return this.Get('AVYoYPct');
    }
    set AVYoYPct(value: number | null) {
        this.Set('AVYoYPct', value);
    }

    /**
    * * Field Name: SqFt
    * * Display Name: Square Footage
    * * SQL Data Type: int
    * * Description: The parcel's improvement square footage where known.
    */
    get SqFt(): number | null {
        return this.Get('SqFt');
    }
    set SqFt(value: number | null) {
        this.Set('SqFt', value);
    }

    /**
    * * Field Name: Units
    * * Display Name: Units
    * * SQL Data Type: int
    * * Description: The parcel's residential/lodging unit count where known.
    */
    get Units(): number | null {
        return this.Get('Units');
    }
    set Units(value: number | null) {
        this.Set('Units', value);
    }

    /**
    * * Field Name: SalesIndicatedValue
    * * Display Name: Sales Indicated Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: parcel.salesInd -- the ValuationAnalysis sales-comparison indicated value for the parcel.
    */
    get SalesIndicatedValue(): number | null {
        return this.Get('SalesIndicatedValue');
    }
    set SalesIndicatedValue(value: number | null) {
        this.Set('SalesIndicatedValue', value);
    }

    /**
    * * Field Name: IncomeIndicatedValue
    * * Display Name: Income Indicated Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: parcel.incomeInd -- the ValuationAnalysis income-approach indicated value for the parcel.
    */
    get IncomeIndicatedValue(): number | null {
        return this.Get('IncomeIndicatedValue');
    }
    set IncomeIndicatedValue(value: number | null) {
        this.Set('IncomeIndicatedValue', value);
    }

    /**
    * * Field Name: FloorValue
    * * Display Name: Floor Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: parcel.floor -- the conservative low-end value the ValuationAnalysis would defend for the parcel.
    */
    get FloorValue(): number | null {
        return this.Get('FloorValue');
    }
    set FloorValue(value: number | null) {
        this.Set('FloorValue', value);
    }

    /**
    * * Field Name: AskValue
    * * Display Name: Ask Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: parcel.ask -- the value the ValuationAnalysis recommends asking for at appeal (the opening position).
    */
    get AskValue(): number | null {
        return this.Get('AskValue');
    }
    set AskValue(value: number | null) {
        this.Set('AskValue', value);
    }

    /**
    * * Field Name: EstSavingsAtAsk
    * * Display Name: Est. Savings at Ask Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: Estimated annual property-tax saving for the parcel if the assessed value were reduced to AskValue. Coarse v1 estimate, a triage signal.
    */
    get EstSavingsAtAsk(): number | null {
        return this.Get('EstSavingsAtAsk');
    }
    set EstSavingsAtAsk(value: number | null) {
        this.Set('EstSavingsAtAsk', value);
    }

    /**
    * * Field Name: EstSavingsAtFloor
    * * Display Name: Est. Savings at Floor Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: Estimated annual property-tax saving for the parcel if the assessed value were reduced to FloorValue -- the conservative end of the range.
    */
    get EstSavingsAtFloor(): number | null {
        return this.Get('EstSavingsAtFloor');
    }
    set EstSavingsAtFloor(value: number | null) {
        this.Set('EstSavingsAtFloor', value);
    }

    /**
    * * Field Name: Recommendation
    * * Display Name: Recommendation
    * * SQL Data Type: nvarchar(20)
    * * Description: parcel.rec -- the ValuationAnalysis recommendation for the parcel (Appeal | Monitor | ...).
    */
    get Recommendation(): string | null {
        return this.Get('Recommendation');
    }
    set Recommendation(value: string | null) {
        this.Set('Recommendation', value);
    }

    /**
    * * Field Name: ConfidenceTier
    * * Display Name: Confidence Tier
    * * SQL Data Type: nvarchar(20)
    * * Description: parcel.conf -- the ValuationAnalysis confidence tier for the recommendation (High | Medium | Low).
    */
    get ConfidenceTier(): string | null {
        return this.Get('ConfidenceTier');
    }
    set ConfidenceTier(value: string | null) {
        this.Set('ConfidenceTier', value);
    }

    /**
    * * Field Name: SupportingApproachCount
    * * Display Name: Supporting Approach Count
    * * SQL Data Type: int
    * * Description: parcel.supCount -- how many of the three approaches to value (cost, sales, income) support a reduction for the parcel (0-3).
    */
    get SupportingApproachCount(): number | null {
        return this.Get('SupportingApproachCount');
    }
    set SupportingApproachCount(value: number | null) {
        this.Set('SupportingApproachCount', value);
    }

    /**
    * * Field Name: Appealed
    * * Display Name: Previously Appealed
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: BIT: the parcel has at least one recorded PTABOA/assessment appeal in its history.
    */
    get Appealed(): boolean {
        return this.Get('Appealed');
    }
    set Appealed(value: boolean) {
        this.Set('Appealed', value);
    }

    /**
    * * Field Name: ExistingRep
    * * Display Name: Existing Representative
    * * SQL Data Type: nvarchar(200)
    * * Description: parcel.rep -- the tax representative on record for the parcel's prior appeals, if any.
    */
    get ExistingRep(): string | null {
        return this.Get('ExistingRep');
    }
    set ExistingRep(value: string | null) {
        this.Set('ExistingRep', value);
    }

    /**
    * * Field Name: LastAppealYear
    * * Display Name: Last Appeal Year
    * * SQL Data Type: int
    * * Description: The most recent assessment year in which this parcel was appealed.
    */
    get LastAppealYear(): number | null {
        return this.Get('LastAppealYear');
    }
    set LastAppealYear(value: number | null) {
        this.Set('LastAppealYear', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: OwnerPortfolio
    * * Display Name: Owner Portfolio
    * * SQL Data Type: nvarchar(300)
    */
    get OwnerPortfolio(): string {
        return this.Get('OwnerPortfolio');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Reference
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string | null {
        return this.Get('Parcel');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Mj Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Mj Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Owner Portfolio Runs - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: OwnerPortfolioRun
 * * Base View: vwOwnerPortfolioRuns
 * * @description Persisted output of one scripts/build-owner-portfolios.js run: the county-wide commercial & industrial 2025->2026 assessed-value rollup plus a pointer (IsLatest) to the run the dashboard should show. Written by the portfolio job, read-only on the dashboard side.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Owner Portfolio Runs')
export class indianataxOwnerPortfolioRunEntity extends BaseEntity<indianataxOwnerPortfolioRunEntityType> {
    /**
    * Loads the Owner Portfolio Runs record from the database
    * @param ID: string - primary key value to load the Owner Portfolio Runs record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxOwnerPortfolioRunEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: RunDate
    * * Display Name: Run Date
    * * SQL Data Type: datetimeoffset
    * * Description: When the portfolio job that produced this run executed, taken verbatim from owners.json generatedAt.
    */
    get RunDate(): Date {
        return this.Get('RunDate');
    }
    set RunDate(value: Date) {
        this.Set('RunDate', value);
    }

    /**
    * * Field Name: MethodologyVersion
    * * Display Name: Methodology Version
    * * SQL Data Type: nvarchar(60)
    * * Description: The build-owner-portfolios.js methodology label (owners.json method) so a run can be tied to the grouping and scoring rules that produced it.
    */
    get MethodologyVersion(): string {
        return this.Get('MethodologyVersion');
    }
    set MethodologyVersion(value: string) {
        this.Set('MethodologyVersion', value);
    }

    /**
    * * Field Name: IsLatest
    * * Display Name: Latest Run
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: Exactly one OwnerPortfolioRun row has IsLatest = 1 at a time; the loader clears the previous winner in the same transaction. The dashboard filters on it.
    */
    get IsLatest(): boolean {
        return this.Get('IsLatest');
    }
    set IsLatest(value: boolean) {
        this.Set('IsLatest', value);
    }

    /**
    * * Field Name: CountyParcelCount
    * * Display Name: County Parcel Count
    * * SQL Data Type: int
    * * Description: countyRollup.parcels: the number of Marion commercial & industrial parcels in scope for this run.
    */
    get CountyParcelCount(): number | null {
        return this.Get('CountyParcelCount');
    }
    set CountyParcelCount(value: number | null) {
        this.Set('CountyParcelCount', value);
    }

    /**
    * * Field Name: CountyTotalAV2025
    * * Display Name: County Total AV 2025
    * * SQL Data Type: decimal(18, 2)
    * * Description: countyRollup.totalAV2025: the summed 2025 assessed value across all in-scope county C&I parcels.
    */
    get CountyTotalAV2025(): number | null {
        return this.Get('CountyTotalAV2025');
    }
    set CountyTotalAV2025(value: number | null) {
        this.Set('CountyTotalAV2025', value);
    }

    /**
    * * Field Name: CountyTotalAV2026
    * * Display Name: County Total AV 2026
    * * SQL Data Type: decimal(18, 2)
    * * Description: countyRollup.totalAV2026: the summed 2026 assessed value across all in-scope county C&I parcels.
    */
    get CountyTotalAV2026(): number | null {
        return this.Get('CountyTotalAV2026');
    }
    set CountyTotalAV2026(value: number | null) {
        this.Set('CountyTotalAV2026', value);
    }

    /**
    * * Field Name: CountyYoYDollars
    * * Display Name: County YoY Dollars
    * * SQL Data Type: decimal(18, 2)
    * * Description: countyRollup.yoyDollars: CountyTotalAV2026 minus CountyTotalAV2025, the county-wide dollar change in assessed value.
    */
    get CountyYoYDollars(): number | null {
        return this.Get('CountyYoYDollars');
    }
    set CountyYoYDollars(value: number | null) {
        this.Set('CountyYoYDollars', value);
    }

    /**
    * * Field Name: CountyYoYPct
    * * Display Name: County YoY Percent
    * * SQL Data Type: decimal(9, 4)
    * * Description: countyRollup.yoyPct: the county-wide year-over-year assessed-value change as a fraction (0.0750 = +7.5%).
    */
    get CountyYoYPct(): number | null {
        return this.Get('CountyYoYPct');
    }
    set CountyYoYPct(value: number | null) {
        this.Set('CountyYoYPct', value);
    }

    /**
    * * Field Name: CountyParcelsUp5
    * * Display Name: County Parcels Up 5%
    * * SQL Data Type: int
    * * Description: countyRollup.parcelsUp5: count of county C&I parcels whose 2026 AV rose more than 5% over 2025.
    */
    get CountyParcelsUp5(): number | null {
        return this.Get('CountyParcelsUp5');
    }
    set CountyParcelsUp5(value: number | null) {
        this.Set('CountyParcelsUp5', value);
    }

    /**
    * * Field Name: CountyParcelsUp10
    * * Display Name: County Parcels Up 10%
    * * SQL Data Type: int
    * * Description: countyRollup.parcelsUp10: count of county C&I parcels whose 2026 AV rose more than 10% over 2025.
    */
    get CountyParcelsUp10(): number | null {
        return this.Get('CountyParcelsUp10');
    }
    set CountyParcelsUp10(value: number | null) {
        this.Set('CountyParcelsUp10', value);
    }

    /**
    * * Field Name: CountyParcelsUp25
    * * Display Name: County Parcels Up 25%
    * * SQL Data Type: int
    * * Description: countyRollup.parcelsUp25: count of county C&I parcels whose 2026 AV rose more than 25% over 2025.
    */
    get CountyParcelsUp25(): number | null {
        return this.Get('CountyParcelsUp25');
    }
    set CountyParcelsUp25(value: number | null) {
        this.Set('CountyParcelsUp25', value);
    }

    /**
    * * Field Name: CountyParcelsUp50
    * * Display Name: County Parcels Up 50%
    * * SQL Data Type: int
    * * Description: countyRollup.parcelsUp50: count of county C&I parcels whose 2026 AV rose more than 50% over 2025.
    */
    get CountyParcelsUp50(): number | null {
        return this.Get('CountyParcelsUp50');
    }
    set CountyParcelsUp50(value: number | null) {
        this.Set('CountyParcelsUp50', value);
    }

    /**
    * * Field Name: CountyParcelsDown
    * * Display Name: County Parcels Down
    * * SQL Data Type: int
    * * Description: countyRollup.parcelsDown: count of county C&I parcels whose 2026 AV fell below 2025.
    */
    get CountyParcelsDown(): number | null {
        return this.Get('CountyParcelsDown');
    }
    set CountyParcelsDown(value: number | null) {
        this.Set('CountyParcelsDown', value);
    }

    /**
    * * Field Name: CountyByTypeJSON
    * * Display Name: County By Type
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON.stringify of countyRollup.byType from owners.json -- per-property-type 2025/2026 AV + YoY %, display-only for the banner chips. Not a queryable projection.
    */
    get CountyByTypeJSON(): string | null {
        return this.Get('CountyByTypeJSON');
    }
    set CountyByTypeJSON(value: string | null) {
        this.Set('CountyByTypeJSON', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Owner Portfolios - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: OwnerPortfolio
 * * Base View: vwOwnerPortfolios
 * * @description One operating-company owner group in a run: Marion parcels rolled up to the operating company (CoStar true owner -> shared mailing address -> cleaned name), with aggregate AV, the ValuationAnalysis opportunity, appeal history, and the tax rep on record.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Owner Portfolios')
export class indianataxOwnerPortfolioEntity extends BaseEntity<indianataxOwnerPortfolioEntityType> {
    /**
    * Loads the Owner Portfolios record from the database
    * @param ID: string - primary key value to load the Owner Portfolios record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxOwnerPortfolioEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: RunID
    * * Display Name: Run ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Owner Portfolio Runs (vwOwnerPortfolioRuns.ID)
    */
    get RunID(): string {
        return this.Get('RunID');
    }
    set RunID(value: string) {
        this.Set('RunID', value);
    }

    /**
    * * Field Name: OwnerKey
    * * Display Name: Owner Key
    * * SQL Data Type: nvarchar(200)
    * * Description: Normalized owner key (scripts/lib/owner-key.js): CoStar true owner else cleaned label, lowercased, legal-form suffixes stripped. The stable join to indiana_tax.Prospect.OwnerKey across portfolio re-runs.
    */
    get OwnerKey(): string {
        return this.Get('OwnerKey');
    }
    set OwnerKey(value: string) {
        this.Set('OwnerKey', value);
    }

    /**
    * * Field Name: Label
    * * Display Name: Owner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: Human-readable owner name shown in the dashboard (owner.label) -- the CoStar true owner if known, otherwise the cleaned assessor name.
    */
    get Label(): string {
        return this.Get('Label');
    }
    set Label(value: string) {
        this.Set('Label', value);
    }

    /**
    * * Field Name: Kind
    * * Display Name: Owner Type
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Company
    *   * Government
    *   * Individual
    *   * Institution
    * * Description: Company | Individual | Government | Institution -- classifier from build-owner-portfolios.js. Only Company owners get a prospect Tier.
    */
    get Kind(): 'Company' | 'Government' | 'Individual' | 'Institution' {
        return this.Get('Kind');
    }
    set Kind(value: 'Company' | 'Government' | 'Individual' | 'Institution') {
        this.Set('Kind', value);
    }

    /**
    * * Field Name: Tier
    * * Display Name: Prospect Tier
    * * SQL Data Type: nvarchar(12)
    * * Description: Prime (>= $500k/yr at ask) | Strong (>= $150k) | Moderate (>= $40k) | Watch | em dash for non-companies.
    */
    get Tier(): string | null {
        return this.Get('Tier');
    }
    set Tier(value: string | null) {
        this.Set('Tier', value);
    }

    /**
    * * Field Name: GroupKeyType
    * * Display Name: Grouping Method
    * * SQL Data Type: nvarchar(12)
    * * Description: owner.groupKeyType -- which signal grouped these parcels: CO (CoStar true owner), MAIL (shared mailing address), NAME (cleaned assessor name), or PARCEL (single parcel, no group).
    */
    get GroupKeyType(): string | null {
        return this.Get('GroupKeyType');
    }
    set GroupKeyType(value: string | null) {
        this.Set('GroupKeyType', value);
    }

    /**
    * * Field Name: CoStarTrueOwner
    * * Display Name: CoStar True Owner
    * * SQL Data Type: nvarchar(300)
    * * Description: owner.coStarTrueOwner -- the CoStar-resolved ultimate owner name when available, the basis of the strongest grouping signal.
    */
    get CoStarTrueOwner(): string | null {
        return this.Get('CoStarTrueOwner');
    }
    set CoStarTrueOwner(value: string | null) {
        this.Set('CoStarTrueOwner', value);
    }

    /**
    * * Field Name: ParcelCount
    * * Display Name: Parcel Count
    * * SQL Data Type: int
    * * Description: Number of parcels rolled up into this owner group for the run (matches the count of OwnerPortfolioParcel rows).
    */
    get ParcelCount(): number {
        return this.Get('ParcelCount');
    }
    set ParcelCount(value: number) {
        this.Set('ParcelCount', value);
    }

    /**
    * * Field Name: DistinctEntities
    * * Display Name: Distinct Entities
    * * SQL Data Type: int
    * * Description: Count of distinct raw assessor owner-name strings folded into this group -- a rough measure of how many title-holding entities the operating company uses.
    */
    get DistinctEntities(): number | null {
        return this.Get('DistinctEntities');
    }
    set DistinctEntities(value: number | null) {
        this.Set('DistinctEntities', value);
    }

    /**
    * * Field Name: TotalAV
    * * Display Name: Current Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: Sum of the current (most recent certified) assessed value across the group's parcels.
    */
    get TotalAV(): number | null {
        return this.Get('TotalAV');
    }
    set TotalAV(value: number | null) {
        this.Set('TotalAV', value);
    }

    /**
    * * Field Name: TotalAV2025
    * * Display Name: 2025 Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: Sum of 2025 assessed value across the group's parcels.
    */
    get TotalAV2025(): number | null {
        return this.Get('TotalAV2025');
    }
    set TotalAV2025(value: number | null) {
        this.Set('TotalAV2025', value);
    }

    /**
    * * Field Name: TotalAV2026
    * * Display Name: 2026 Assessed Value
    * * SQL Data Type: decimal(18, 2)
    * * Description: Sum of 2026 assessed value across the group's parcels.
    */
    get TotalAV2026(): number | null {
        return this.Get('TotalAV2026');
    }
    set TotalAV2026(value: number | null) {
        this.Set('TotalAV2026', value);
    }

    /**
    * * Field Name: AVYoYDollars
    * * Display Name: AV Year-over-Year Change ($)
    * * SQL Data Type: decimal(18, 2)
    * * Description: TotalAV2026 minus TotalAV2025 -- the group's year-over-year dollar change in assessed value.
    */
    get AVYoYDollars(): number | null {
        return this.Get('AVYoYDollars');
    }
    set AVYoYDollars(value: number | null) {
        this.Set('AVYoYDollars', value);
    }

    /**
    * * Field Name: AVYoYPct
    * * Display Name: AV Year-over-Year Change (%)
    * * SQL Data Type: decimal(9, 4)
    * * Description: The group's year-over-year assessed-value change as a fraction (0.1200 = +12%).
    */
    get AVYoYPct(): number | null {
        return this.Get('AVYoYPct');
    }
    set AVYoYPct(value: number | null) {
        this.Set('AVYoYPct', value);
    }

    /**
    * * Field Name: ParcelsUp10
    * * Display Name: Parcels Up 10%+
    * * SQL Data Type: int
    * * Description: Count of the group's parcels whose 2026 AV rose more than 10% over 2025.
    */
    get ParcelsUp10(): number | null {
        return this.Get('ParcelsUp10');
    }
    set ParcelsUp10(value: number | null) {
        this.Set('ParcelsUp10', value);
    }

    /**
    * * Field Name: ParcelsUp25
    * * Display Name: Parcels Up 25%+
    * * SQL Data Type: int
    * * Description: Count of the group's parcels whose 2026 AV rose more than 25% over 2025.
    */
    get ParcelsUp25(): number | null {
        return this.Get('ParcelsUp25');
    }
    set ParcelsUp25(value: number | null) {
        this.Set('ParcelsUp25', value);
    }

    /**
    * * Field Name: TotalUnits
    * * Display Name: Total Units
    * * SQL Data Type: int
    * * Description: Sum of residential/lodging unit counts across the group's parcels where a unit count is known.
    */
    get TotalUnits(): number | null {
        return this.Get('TotalUnits');
    }
    set TotalUnits(value: number | null) {
        this.Set('TotalUnits', value);
    }

    /**
    * * Field Name: TotalSqFt
    * * Display Name: Total Square Footage
    * * SQL Data Type: bigint
    * * Description: Sum of improvement square footage across the group's parcels where square footage is known.
    */
    get TotalSqFt(): number | null {
        return this.Get('TotalSqFt');
    }
    set TotalSqFt(value: number | null) {
        this.Set('TotalSqFt', value);
    }

    /**
    * * Field Name: NAppealRec
    * * Display Name: Appeal Recommendations
    * * SQL Data Type: int
    * * Description: owner.nAppealRec -- count of the group's parcels the ValuationAnalysis flags with an Appeal recommendation.
    */
    get NAppealRec(): number | null {
        return this.Get('NAppealRec');
    }
    set NAppealRec(value: number | null) {
        this.Set('NAppealRec', value);
    }

    /**
    * * Field Name: NTwoSupport
    * * Display Name: Two-Approach Support Count
    * * SQL Data Type: int
    * * Description: owner.nTwoSupport -- count of the group's parcels where at least two of the three approaches to value support a reduction.
    */
    get NTwoSupport(): number | null {
        return this.Get('NTwoSupport');
    }
    set NTwoSupport(value: number | null) {
        this.Set('NTwoSupport', value);
    }

    /**
    * * Field Name: NHighConfAppeal
    * * Display Name: High Confidence Appeals
    * * SQL Data Type: int
    * * Description: owner.nHighConfAppeal -- count of the group's Appeal-rec parcels whose confidence tier is High.
    */
    get NHighConfAppeal(): number | null {
        return this.Get('NHighConfAppeal');
    }
    set NHighConfAppeal(value: number | null) {
        this.Set('NHighConfAppeal', value);
    }

    /**
    * * Field Name: EstSavingsAtAsk
    * * Display Name: Est. Savings at Ask
    * * SQL Data Type: decimal(18, 2)
    * * Description: Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the recommended ask across Appeal-rec parcels. v1 coarse comps -- a triage signal, not a quote.
    */
    get EstSavingsAtAsk(): number | null {
        return this.Get('EstSavingsAtAsk');
    }
    set EstSavingsAtAsk(value: number | null) {
        this.Set('EstSavingsAtAsk', value);
    }

    /**
    * * Field Name: EstSavingsAtFloor
    * * Display Name: Est. Savings at Floor
    * * SQL Data Type: decimal(18, 2)
    * * Description: Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the conservative floor value across Appeal-rec parcels -- the low end of the range.
    */
    get EstSavingsAtFloor(): number | null {
        return this.Get('EstSavingsAtFloor');
    }
    set EstSavingsAtFloor(value: number | null) {
        this.Set('EstSavingsAtFloor', value);
    }

    /**
    * * Field Name: AppealedParcels
    * * Display Name: Appealed Parcels
    * * SQL Data Type: int
    * * Description: Count of the group's parcels with at least one recorded PTABOA/assessment appeal in the appeal history.
    */
    get AppealedParcels(): number | null {
        return this.Get('AppealedParcels');
    }
    set AppealedParcels(value: number | null) {
        this.Set('AppealedParcels', value);
    }

    /**
    * * Field Name: HistoricalReductionWon
    * * Display Name: Historical Reduction Won
    * * SQL Data Type: decimal(18, 2)
    * * Description: Total assessed-value reduction the group has historically won across all its recorded appeals (sum of prior-year AV reductions).
    */
    get HistoricalReductionWon(): number | null {
        return this.Get('HistoricalReductionWon');
    }
    set HistoricalReductionWon(value: number | null) {
        this.Set('HistoricalReductionWon', value);
    }

    /**
    * * Field Name: AppealYears
    * * Display Name: Appeal Years
    * * SQL Data Type: nvarchar(20)
    * * Description: Compact span of assessment years in which the group appealed, e.g. "2019-2023"; a single year if there is only one.
    */
    get AppealYears(): string | null {
        return this.Get('AppealYears');
    }
    set AppealYears(value: string | null) {
        this.Set('AppealYears', value);
    }

    /**
    * * Field Name: MostRecentAppealYear
    * * Display Name: Most Recent Appeal Year
    * * SQL Data Type: int
    * * Description: The most recent assessment year in which any of the group's parcels was appealed.
    */
    get MostRecentAppealYear(): number | null {
        return this.Get('MostRecentAppealYear');
    }
    set MostRecentAppealYear(value: number | null) {
        this.Set('MostRecentAppealYear', value);
    }

    /**
    * * Field Name: LikelyRep
    * * Display Name: Likely Tax Representative
    * * SQL Data Type: nvarchar(200)
    * * Description: Best single guess at the tax representative acting for the owner -- the rep that secured the most (or most recent) PTABOA reductions across the group's parcels.
    */
    get LikelyRep(): string | null {
        return this.Get('LikelyRep');
    }
    set LikelyRep(value: string | null) {
        this.Set('LikelyRep', value);
    }

    /**
    * * Field Name: RepStatus
    * * Display Name: Tax Rep Status
    * * SQL Data Type: nvarchar(120)
    * * Description: No rep on record | Represented by X | Multiple reps -- X (+N). Tax-rep inference: a rep that secured a PTABOA reduction on any portfolio parcel is assumed to act for the owner.
    */
    get RepStatus(): string {
        return this.Get('RepStatus');
    }
    set RepStatus(value: string) {
        this.Set('RepStatus', value);
    }

    /**
    * * Field Name: RepsOnReductionJSON
    * * Display Name: Representatives on Record
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON.stringify of owner.repsOnReduction -- per-rep count and years of PTABOA reductions won on the group's parcels, display-only for the detail panel.
    */
    get RepsOnReductionJSON(): string | null {
        return this.Get('RepsOnReductionJSON');
    }
    set RepsOnReductionJSON(value: string | null) {
        this.Set('RepsOnReductionJSON', value);
    }

    /**
    * * Field Name: IsFreshProspect
    * * Display Name: Fresh Prospect
    * * SQL Data Type: bit
    * * Default Value: 0
    * * Description: BIT: Company AND no rep on record AND EstSavingsAtAsk > 0 -- the cold-prospect flag the dashboard highlights.
    */
    get IsFreshProspect(): boolean {
        return this.Get('IsFreshProspect');
    }
    set IsFreshProspect(value: boolean) {
        this.Set('IsFreshProspect', value);
    }

    /**
    * * Field Name: MailAddress
    * * Display Name: Mailing Address
    * * SQL Data Type: nvarchar(400)
    * * Description: The mailing address shared by the group's parcels (owner.mailAddress) -- the fallback grouping signal and a contact hint.
    */
    get MailAddress(): string | null {
        return this.Get('MailAddress');
    }
    set MailAddress(value: string | null) {
        this.Set('MailAddress', value);
    }

    /**
    * * Field Name: ByTypeJSON
    * * Display Name: Breakdown by Property Type
    * * SQL Data Type: nvarchar(MAX)
    * * Description: JSON.stringify of owner.byType -- per-property-type parcel count and AV within the group, display-only for the detail-panel breakdown.
    */
    get ByTypeJSON(): string | null {
        return this.Get('ByTypeJSON');
    }
    set ByTypeJSON(value: string | null) {
        this.Set('ByTypeJSON', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Run
    * * Display Name: Run
    * * SQL Data Type: nvarchar(60)
    */
    get Run(): string {
        return this.Get('Run');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Mj Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Mj Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Parcels - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: Parcel
 * * Base View: vwParcels
 * * @description One row per Indiana parcel, keyed on (CountyNumber, ParcelNumber) — the statewide 17-digit parcel number. Holds relatively stable characteristics; assessed values live in Assessment, one row per year.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Parcels')
export class indianataxParcelEntity extends BaseEntity<indianataxParcelEntityType> {
    /**
    * Loads the Parcels record from the database
    * @param ID: string - primary key value to load the Parcels record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxParcelEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: Indiana county number (1-92) per the DLGF/GIO statewide numbering.
    */
    get CountyNumber(): number {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: ParcelNumber
    * * Display Name: Parcel Number
    * * SQL Data Type: nvarchar(30)
    * * Description: The statewide 17-digit PARCEL_NUMBER from the DLGF/GIO Data Harvest geodatabase. Canonical identifier for the parcel.
    */
    get ParcelNumber(): string {
        return this.Get('ParcelNumber');
    }
    set ParcelNumber(value: string) {
        this.Set('ParcelNumber', value);
    }

    /**
    * * Field Name: GISParcelNumber
    * * Display Name: GIS Parcel Number
    * * SQL Data Type: nvarchar(30)
    * * Description: The county's own local parcel number (e.g. Marion County's 7-digit number). Different counties use different local schemes; this is the crosswalk between a county-sourced file and the statewide ParcelNumber.
    */
    get GISParcelNumber(): string | null {
        return this.Get('GISParcelNumber');
    }
    set GISParcelNumber(value: string | null) {
        this.Set('GISParcelNumber', value);
    }

    /**
    * * Field Name: Address
    * * Display Name: Address
    * * SQL Data Type: nvarchar(300)
    * * Description: Site/property address.
    */
    get Address(): string | null {
        return this.Get('Address');
    }
    set Address(value: string | null) {
        this.Set('Address', value);
    }

    /**
    * * Field Name: OwnerName
    * * Display Name: Owner Name
    * * SQL Data Type: nvarchar(300)
    * * Description: Owner of record name, as of the characteristics source year.
    */
    get OwnerName(): string | null {
        return this.Get('OwnerName');
    }
    set OwnerName(value: string | null) {
        this.Set('OwnerName', value);
    }

    /**
    * * Field Name: Acreage
    * * Display Name: Acreage
    * * SQL Data Type: decimal(12, 4)
    * * Description: Parcel acreage.
    */
    get Acreage(): number | null {
        return this.Get('Acreage');
    }
    set Acreage(value: number | null) {
        this.Set('Acreage', value);
    }

    /**
    * * Field Name: Zoning
    * * Display Name: Zoning
    * * SQL Data Type: nvarchar(50)
    * * Description: Zoning designation, as recorded by the county.
    */
    get Zoning(): string | null {
        return this.Get('Zoning');
    }
    set Zoning(value: string | null) {
        this.Set('Zoning', value);
    }

    /**
    * * Field Name: PropertyClassCode
    * * Display Name: Property Class Code
    * * SQL Data Type: nvarchar(10)
    * * Description: Most recently known DLGF property class code (e.g. 300-499 for commercial/industrial). A given assessment year may record a different class code on its own Assessment row.
    */
    get PropertyClassCode(): string | null {
        return this.Get('PropertyClassCode');
    }
    set PropertyClassCode(value: string | null) {
        this.Set('PropertyClassCode', value);
    }

    /**
    * * Field Name: CharacteristicsSourceYear
    * * Display Name: Characteristics Source Year
    * * SQL Data Type: smallint
    * * Description: Which DLGF/source pull (assessment year) produced the characteristics currently stored on this row. Characteristics are overwritten on a later pull, not versioned.
    */
    get CharacteristicsSourceYear(): number | null {
        return this.Get('CharacteristicsSourceYear');
    }
    set CharacteristicsSourceYear(value: number | null) {
        this.Set('CharacteristicsSourceYear', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Latitude
    * * Display Name: Latitude
    * * SQL Data Type: float(53)
    * * Description: Parcel centroid latitude (WGS84), from the IndianaMap parcel boundaries Feature Service.
    */
    get Latitude(): number | null {
        return this.Get('Latitude');
    }
    set Latitude(value: number | null) {
        this.Set('Latitude', value);
    }

    /**
    * * Field Name: Longitude
    * * Display Name: Longitude
    * * SQL Data Type: float(53)
    * * Description: Parcel centroid longitude (WGS84), from the IndianaMap parcel boundaries Feature Service.
    */
    get Longitude(): number | null {
        return this.Get('Longitude');
    }
    set Longitude(value: number | null) {
        this.Set('Longitude', value);
    }

    /**
    * * Field Name: CountyFIPS
    * * Display Name: County FIPS Code
    * * SQL Data Type: nvarchar(10)
    * * Description: County FIPS code, from the IndianaMap Feature Service's county_fips field — a verifiable county identifier, distinct from CountyNumber (the DLGF/GIO statewide numbering used elsewhere in this schema).
    */
    get CountyFIPS(): string | null {
        return this.Get('CountyFIPS');
    }
    set CountyFIPS(value: string | null) {
        this.Set('CountyFIPS', value);
    }

    /**
    * * Field Name: BoundaryGeoJSON
    * * Display Name: Boundary GeoJSON
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Parcel boundary polygon as GeoJSON geometry (WGS84), from the IndianaMap Feature Service. NULL until fetched; not every parcel in our set necessarily resolves (a parcel here may not exist in that dataset, or vice versa).
    */
    get BoundaryGeoJSON(): string | null {
        return this.Get('BoundaryGeoJSON');
    }
    set BoundaryGeoJSON(value: string | null) {
        this.Set('BoundaryGeoJSON', value);
    }

    /**
    * * Field Name: GeometryRetrievedAt
    * * Display Name: Geometry Retrieved At
    * * SQL Data Type: datetimeoffset
    * * Description: When the geometry/location fields on this row were last fetched from the source Feature Service.
    */
    get GeometryRetrievedAt(): Date | null {
        return this.Get('GeometryRetrievedAt');
    }
    set GeometryRetrievedAt(value: Date | null) {
        this.Set('GeometryRetrievedAt', value);
    }

    /**
    * * Field Name: TaxDistrictCode
    * * Display Name: Tax District Code
    * * SQL Data Type: nvarchar(200)
    * * Description: The county's own tax district code for this parcel (source field: cnty_tax_dist_cd) — identifies the specific combination of overlapping taxing units (township + school + library + special districts) that applies.
    */
    get TaxDistrictCode(): string | null {
        return this.Get('TaxDistrictCode');
    }
    set TaxDistrictCode(value: string | null) {
        this.Set('TaxDistrictCode', value);
    }

    /**
    * * Field Name: TaxTownship
    * * Display Name: Tax Township
    * * SQL Data Type: nvarchar(50)
    * * Description: Civil township this parcel is taxed under.
    */
    get TaxTownship(): string | null {
        return this.Get('TaxTownship');
    }
    set TaxTownship(value: string | null) {
        this.Set('TaxTownship', value);
    }

    /**
    * * Field Name: TaxSchoolCorp
    * * Display Name: Tax School Corporation
    * * SQL Data Type: nvarchar(100)
    * * Description: School corporation this parcel is taxed under.
    */
    get TaxSchoolCorp(): string | null {
        return this.Get('TaxSchoolCorp');
    }
    set TaxSchoolCorp(value: string | null) {
        this.Set('TaxSchoolCorp', value);
    }

    /**
    * * Field Name: TaxLibraryDistrict
    * * Display Name: Tax Library District
    * * SQL Data Type: nvarchar(50)
    * * Description: Library taxing district this parcel falls in, if any.
    */
    get TaxLibraryDistrict(): string | null {
        return this.Get('TaxLibraryDistrict');
    }
    set TaxLibraryDistrict(value: string | null) {
        this.Set('TaxLibraryDistrict', value);
    }

    /**
    * * Field Name: TaxSpecialDistrict
    * * Display Name: Tax Special District
    * * SQL Data Type: nvarchar(360)
    * * Description: Special taxing district(s) this parcel falls in (e.g. solid waste management), if any. Can be a combined/concatenated value per the source.
    */
    get TaxSpecialDistrict(): string | null {
        return this.Get('TaxSpecialDistrict');
    }
    set TaxSpecialDistrict(value: string | null) {
        this.Set('TaxSpecialDistrict', value);
    }

    /**
    * * Field Name: TaxCity
    * * Display Name: Tax City
    * * SQL Data Type: nvarchar(70)
    * * Description: City/municipal taxing unit this parcel falls in, if any (NULL for unincorporated areas).
    */
    get TaxCity(): string | null {
        return this.Get('TaxCity');
    }
    set TaxCity(value: string | null) {
        this.Set('TaxCity', value);
    }

    /**
    * * Field Name: ShapeAreaDecimalDegrees
    * * Display Name: Shape Area (Decimal Degrees)
    * * SQL Data Type: float(53)
    * * Description: Parcel boundary area in decimal degrees squared (source: SHAPE__Area, confirmed unit esriDecimalDegrees) — NOT a real-world area (not square feet/meters/acres). Only useful as a cheap relative sanity-check against Acreage; a proper acreage figure would need a geodesic area calculation this field does not provide.
    */
    get ShapeAreaDecimalDegrees(): number | null {
        return this.Get('ShapeAreaDecimalDegrees');
    }
    set ShapeAreaDecimalDegrees(value: number | null) {
        this.Set('ShapeAreaDecimalDegrees', value);
    }

    /**
    * * Field Name: SourceLoadDate
    * * Display Name: Source Load Date
    * * SQL Data Type: date
    * * Description: The date the SOURCE (IndianaMap/IGIO Feature Service) last updated this record — distinct from GeometryRetrievedAt, which is when WE fetched it.
    */
    get SourceLoadDate(): Date | null {
        return this.Get('SourceLoadDate');
    }
    set SourceLoadDate(value: Date | null) {
        this.Set('SourceLoadDate', value);
    }

    /**
    * * Field Name: GeometrySourceRegistryID
    * * Display Name: Geometry Source Registry ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
    * * Description: The SourceRegistry entry for the Feature Service this parcel's geometry/location/taxing-district fields came from.
    */
    get GeometrySourceRegistryID(): string | null {
        return this.Get('GeometrySourceRegistryID');
    }
    set GeometrySourceRegistryID(value: string | null) {
        this.Set('GeometrySourceRegistryID', value);
    }

    /**
    * * Field Name: GeometrySourceRegistry
    * * Display Name: Geometry Source Registry
    * * SQL Data Type: nvarchar(200)
    */
    get GeometrySourceRegistry(): string | null {
        return this.Get('GeometrySourceRegistry');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Mj Latitude
    * * SQL Data Type: float(53)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Mj Longitude
    * * SQL Data Type: float(53)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Property Class Maps - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: PropertyClassMap
 * * Base View: vwPropertyClassMaps
 * * @description Maps an Indiana DLGF real-property class code (3 digits) to a coarse PropertyTypeGroup for comp grouping. The single source of truth for classification; consumed by the ParcelPhysicalProfile view and the SaleTransaction / ValuationAnalysis loaders. DLGF-only -- CoStar type is a separate, CoStar-labelled datapoint and never merged here. Design: Indiana_Tax_Expert/docs/proposals/property-type-classification.md.
 * * Primary Key: Code
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Property Class Maps')
export class indianataxPropertyClassMapEntity extends BaseEntity<indianataxPropertyClassMapEntityType> {
    /**
    * Loads the Property Class Maps record from the database
    * @param Code: string - primary key value to load the Property Class Maps record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxPropertyClassMapEntity
    * @method
    * @override
    */
    public async Load(Code: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'Code', Value: Code });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: Code
    * * Display Name: DLGF Code
    * * SQL Data Type: char(3)
    * * Description: The 3-digit DLGF real-property class code (e.g. "449").
    */
    get Code(): string {
        return this.Get('Code');
    }
    set Code(value: string) {
        this.Set('Code', value);
    }

    /**
    * * Field Name: Label
    * * Display Name: DLGF Label
    * * SQL Data Type: nvarchar(120)
    * * Description: The DLGF label for the code (from Marion's PropertySubClassDescription).
    */
    get Label(): string {
        return this.Get('Label');
    }
    set Label(value: string) {
        this.Set('Label', value);
    }

    /**
    * * Field Name: TypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
    * * Description: Coarse group: Retail / Office / Industrial / Multifamily / Hospitality / Land / Special / Parking / Other.
    */
    get TypeGroup(): 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special' {
        return this.Get('TypeGroup');
    }
    set TypeGroup(value: 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special') {
        this.Set('TypeGroup', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Classification Notes
    * * SQL Data Type: nvarchar(400)
    * * Description: Rationale / borderline-call note for this mapping.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Prospect Activities - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ProspectActivity
 * * Base View: vwProspectActivities
 * * @description A dated touch on a Prospect -- email, call, meeting, referral, proposal, RFP, internal note, conflict-check step, or a stage change. The outreach log.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospect Activities')
export class indianataxProspectActivityEntity extends BaseEntity<indianataxProspectActivityEntityType> {
    /**
    * Loads the Prospect Activities record from the database
    * @param ID: string - primary key value to load the Prospect Activities record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectActivityEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ProspectID
    * * Display Name: Prospect
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospects (vwProspects.ID)
    */
    get ProspectID(): string {
        return this.Get('ProspectID');
    }
    set ProspectID(value: string) {
        this.Set('ProspectID', value);
    }

    /**
    * * Field Name: ContactID
    * * Display Name: Contact
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospect Contacts (vwProspectContacts.ID)
    */
    get ContactID(): string | null {
        return this.Get('ContactID');
    }
    set ContactID(value: string | null) {
        this.Set('ContactID', value);
    }

    /**
    * * Field Name: ActivityDate
    * * Display Name: Activity Date
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    */
    get ActivityDate(): Date {
        return this.Get('ActivityDate');
    }
    set ActivityDate(value: Date) {
        this.Set('ActivityDate', value);
    }

    /**
    * * Field Name: ActivityType
    * * Display Name: Activity Type
    * * SQL Data Type: nvarchar(40)
    * * Value List Type: List
    * * Possible Values 
    *   * Call
    *   * ConflictCheck
    *   * Email
    *   * Meeting
    *   * Note
    *   * ProposalSent
    *   * RFP
    *   * Referral
    *   * StageChange
    */
    get ActivityType(): 'Call' | 'ConflictCheck' | 'Email' | 'Meeting' | 'Note' | 'ProposalSent' | 'RFP' | 'Referral' | 'StageChange' {
        return this.Get('ActivityType');
    }
    set ActivityType(value: 'Call' | 'ConflictCheck' | 'Email' | 'Meeting' | 'Note' | 'ProposalSent' | 'RFP' | 'Referral' | 'StageChange') {
        this.Set('ActivityType', value);
    }

    /**
    * * Field Name: Direction
    * * Display Name: Direction
    * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * Inbound
    *   * Internal
    *   * Outbound
    */
    get Direction(): 'Inbound' | 'Internal' | 'Outbound' | null {
        return this.Get('Direction');
    }
    set Direction(value: 'Inbound' | 'Internal' | 'Outbound' | null) {
        this.Set('Direction', value);
    }

    /**
    * * Field Name: Summary
    * * Display Name: Summary
    * * SQL Data Type: nvarchar(2000)
    */
    get Summary(): string {
        return this.Get('Summary');
    }
    set Summary(value: string) {
        this.Set('Summary', value);
    }

    /**
    * * Field Name: Outcome
    * * Display Name: Outcome
    * * SQL Data Type: nvarchar(1000)
    */
    get Outcome(): string | null {
        return this.Get('Outcome');
    }
    set Outcome(value: string | null) {
        this.Set('Outcome', value);
    }

    /**
    * * Field Name: LoggedBy
    * * Display Name: Logged By
    * * SQL Data Type: nvarchar(200)
    */
    get LoggedBy(): string | null {
        return this.Get('LoggedBy');
    }
    set LoggedBy(value: string | null) {
        this.Set('LoggedBy', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Prospect
    * * Display Name: Prospect
    * * SQL Data Type: nvarchar(300)
    */
    get Prospect(): string {
        return this.Get('Prospect');
    }

    /**
    * * Field Name: Contact
    * * Display Name: Contact Name
    * * SQL Data Type: nvarchar(200)
    */
    get Contact(): string | null {
        return this.Get('Contact');
    }
}


/**
 * Prospect Contacts - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ProspectContact
 * * Base View: vwProspectContacts
 * * @description A decision-maker or influencer at a Prospect company -- asset manager, CFO, GC, principal, or the outside tax rep. KnownToFirm flags an existing Faegre relationship with this individual.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospect Contacts')
export class indianataxProspectContactEntity extends BaseEntity<indianataxProspectContactEntityType> {
    /**
    * Loads the Prospect Contacts record from the database
    * @param ID: string - primary key value to load the Prospect Contacts record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectContactEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ProspectID
    * * Display Name: Prospect
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospects (vwProspects.ID)
    */
    get ProspectID(): string {
        return this.Get('ProspectID');
    }
    set ProspectID(value: string) {
        this.Set('ProspectID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(200)
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(200)
    */
    get Title(): string | null {
        return this.Get('Title');
    }
    set Title(value: string | null) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: Role
    * * Display Name: Role
    * * SQL Data Type: nvarchar(60)
    * * Value List Type: List
    * * Possible Values 
    *   * AssetManager
    *   * CFO
    *   * GeneralCounsel
    *   * Other
    *   * OutsideRep
    *   * Principal
    */
    get Role(): 'AssetManager' | 'CFO' | 'GeneralCounsel' | 'Other' | 'OutsideRep' | 'Principal' | null {
        return this.Get('Role');
    }
    set Role(value: 'AssetManager' | 'CFO' | 'GeneralCounsel' | 'Other' | 'OutsideRep' | 'Principal' | null) {
        this.Set('Role', value);
    }

    /**
    * * Field Name: Email
    * * Display Name: Email
    * * SQL Data Type: nvarchar(200)
    */
    get Email(): string | null {
        return this.Get('Email');
    }
    set Email(value: string | null) {
        this.Set('Email', value);
    }

    /**
    * * Field Name: Phone
    * * Display Name: Phone
    * * SQL Data Type: nvarchar(50)
    */
    get Phone(): string | null {
        return this.Get('Phone');
    }
    set Phone(value: string | null) {
        this.Set('Phone', value);
    }

    /**
    * * Field Name: LinkedInURL
    * * Display Name: LinkedIn URL
    * * SQL Data Type: nvarchar(400)
    */
    get LinkedInURL(): string | null {
        return this.Get('LinkedInURL');
    }
    set LinkedInURL(value: string | null) {
        this.Set('LinkedInURL', value);
    }

    /**
    * * Field Name: SourceNote
    * * Display Name: Source Note
    * * SQL Data Type: nvarchar(500)
    */
    get SourceNote(): string | null {
        return this.Get('SourceNote');
    }
    set SourceNote(value: string | null) {
        this.Set('SourceNote', value);
    }

    /**
    * * Field Name: KnownToFirm
    * * Display Name: Known to Firm
    * * SQL Data Type: bit
    * * Default Value: 0
    */
    get KnownToFirm(): boolean {
        return this.Get('KnownToFirm');
    }
    set KnownToFirm(value: boolean) {
        this.Set('KnownToFirm', value);
    }

    /**
    * * Field Name: FirmContactNote
    * * Display Name: Firm Contact Note
    * * SQL Data Type: nvarchar(500)
    */
    get FirmContactNote(): string | null {
        return this.Get('FirmContactNote');
    }
    set FirmContactNote(value: string | null) {
        this.Set('FirmContactNote', value);
    }

    /**
    * * Field Name: IsPrimary
    * * Display Name: Primary Contact
    * * SQL Data Type: bit
    * * Default Value: 0
    */
    get IsPrimary(): boolean {
        return this.Get('IsPrimary');
    }
    set IsPrimary(value: boolean) {
        this.Set('IsPrimary', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Prospect
    * * Display Name: Prospect Name
    * * SQL Data Type: nvarchar(300)
    */
    get Prospect(): string {
        return this.Get('Prospect');
    }
}


/**
 * Prospect Parcels - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ProspectParcel
 * * Base View: vwProspectParcels
 * * @description A parcel attached to a Prospect. Disposition scopes the pursuit to specific parcels rather than the owner's whole footprint (e.g. the Keystone reconciliation: only 3 of ~21 portfolio projects are actually owned -> the rest are Excluded with a note). IsTrigger marks the parcel/event that prompted identification.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospect Parcels')
export class indianataxProspectParcelEntity extends BaseEntity<indianataxProspectParcelEntityType> {
    /**
    * Loads the Prospect Parcels record from the database
    * @param ID: string - primary key value to load the Prospect Parcels record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectParcelEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for Prospect Parcels entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: All snapshot financial values (Assessed Value, Opportunity at Ask, and Opportunity at Floor) must be non-negative numbers. These fields track property valuations and should never contain negative amounts, as they represent real financial data.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateSnapshotValuesNonNegative(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * All snapshot financial values (Assessed Value, Opportunity at Ask, and Opportunity at Floor) must be non-negative numbers. These fields track property valuations and should never contain negative amounts, as they represent real financial data.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateSnapshotValuesNonNegative(result: ValidationResult) {
    	if (this.SnapshotAV != null && this.SnapshotAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"SnapshotAV",
    			"Snapshot Assessed Value cannot be negative.",
    			this.SnapshotAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.SnapshotOpportunityAtAsk != null && this.SnapshotOpportunityAtAsk < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"SnapshotOpportunityAtAsk",
    			"Snapshot Opportunity at Ask cannot be negative.",
    			this.SnapshotOpportunityAtAsk,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.SnapshotOpportunityAtFloor != null && this.SnapshotOpportunityAtFloor < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"SnapshotOpportunityAtFloor",
    			"Snapshot Opportunity at Floor cannot be negative.",
    			this.SnapshotOpportunityAtFloor,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ProspectID
    * * Display Name: Prospect
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospects (vwProspects.ID)
    */
    get ProspectID(): string {
        return this.Get('ProspectID');
    }
    set ProspectID(value: string) {
        this.Set('ProspectID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: Disposition
    * * Display Name: Disposition
    * * SQL Data Type: nvarchar(40)
    * * Default Value: InScope
    * * Value List Type: List
    * * Possible Values 
    *   * AlreadyRepresented
    *   * Excluded
    *   * InScope
    *   * Monitoring
    * * Description: InScope | AlreadyRepresented | Excluded | Monitoring.
    */
    get Disposition(): 'AlreadyRepresented' | 'Excluded' | 'InScope' | 'Monitoring' {
        return this.Get('Disposition');
    }
    set Disposition(value: 'AlreadyRepresented' | 'Excluded' | 'InScope' | 'Monitoring') {
        this.Set('Disposition', value);
    }

    /**
    * * Field Name: DispositionNote
    * * Display Name: Disposition Note
    * * SQL Data Type: nvarchar(500)
    */
    get DispositionNote(): string | null {
        return this.Get('DispositionNote');
    }
    set DispositionNote(value: string | null) {
        this.Set('DispositionNote', value);
    }

    /**
    * * Field Name: IsTrigger
    * * Display Name: Is Trigger
    * * SQL Data Type: bit
    * * Default Value: 0
    */
    get IsTrigger(): boolean {
        return this.Get('IsTrigger');
    }
    set IsTrigger(value: boolean) {
        this.Set('IsTrigger', value);
    }

    /**
    * * Field Name: ExistingRep
    * * Display Name: Existing Rep
    * * SQL Data Type: nvarchar(200)
    */
    get ExistingRep(): string | null {
        return this.Get('ExistingRep');
    }
    set ExistingRep(value: string | null) {
        this.Set('ExistingRep', value);
    }

    /**
    * * Field Name: SnapshotAV
    * * Display Name: Snapshot AV
    * * SQL Data Type: decimal(18, 2)
    */
    get SnapshotAV(): number | null {
        return this.Get('SnapshotAV');
    }
    set SnapshotAV(value: number | null) {
        this.Set('SnapshotAV', value);
    }

    /**
    * * Field Name: SnapshotOpportunityAtAsk
    * * Display Name: Snapshot Opportunity At Ask
    * * SQL Data Type: decimal(18, 2)
    */
    get SnapshotOpportunityAtAsk(): number | null {
        return this.Get('SnapshotOpportunityAtAsk');
    }
    set SnapshotOpportunityAtAsk(value: number | null) {
        this.Set('SnapshotOpportunityAtAsk', value);
    }

    /**
    * * Field Name: SnapshotOpportunityAtFloor
    * * Display Name: Snapshot Opportunity At Floor
    * * SQL Data Type: decimal(18, 2)
    */
    get SnapshotOpportunityAtFloor(): number | null {
        return this.Get('SnapshotOpportunityAtFloor');
    }
    set SnapshotOpportunityAtFloor(value: number | null) {
        this.Set('SnapshotOpportunityAtFloor', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Prospect
    * * Display Name: Prospect Name
    * * SQL Data Type: nvarchar(300)
    */
    get Prospect(): string {
        return this.Get('Prospect');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel Identifier
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Prospect Snapshots - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ProspectSnapshot
 * * Base View: vwProspectSnapshots
 * * @description Point-in-time deal metrics for a Prospect, written by the portfolio job (scripts/sync-prospect-snapshots.js) on each build-owner-portfolios.js run -- never edited by hand. The two newest rows drive the "Scope changed" view (parcel added/sold, AV moved >10%, a repped parcel went un-repped, opportunity crossed a threshold).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospect Snapshots')
export class indianataxProspectSnapshotEntity extends BaseEntity<indianataxProspectSnapshotEntityType> {
    /**
    * Loads the Prospect Snapshots record from the database
    * @param ID: string - primary key value to load the Prospect Snapshots record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectSnapshotEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for Prospect Snapshots entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: All financial and parcel metrics must be non-negative values. Total assessed value, opportunity at ask price, and parcel count cannot be negative numbers, ensuring data integrity for portfolio financial calculations.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateFinancialMetricsNonNegative(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * All financial and parcel metrics must be non-negative values. Total assessed value, opportunity at ask price, and parcel count cannot be negative numbers, ensuring data integrity for portfolio financial calculations.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateFinancialMetricsNonNegative(result: ValidationResult) {
    	if (this.TotalAV != null && this.TotalAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"TotalAV",
    			"Total assessed value cannot be negative.",
    			this.TotalAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.OpportunityAtAsk != null && this.OpportunityAtAsk < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"OpportunityAtAsk",
    			"Opportunity at ask cannot be negative.",
    			this.OpportunityAtAsk,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.ParcelCount != null && this.ParcelCount < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"ParcelCount",
    			"Parcel count cannot be negative.",
    			this.ParcelCount,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ProspectID
    * * Display Name: Prospect
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospects (vwProspects.ID)
    */
    get ProspectID(): string {
        return this.Get('ProspectID');
    }
    set ProspectID(value: string) {
        this.Set('ProspectID', value);
    }

    /**
    * * Field Name: SnapshotDate
    * * Display Name: Snapshot Date
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    */
    get SnapshotDate(): Date {
        return this.Get('SnapshotDate');
    }
    set SnapshotDate(value: Date) {
        this.Set('SnapshotDate', value);
    }

    /**
    * * Field Name: PortfolioRunTag
    * * Display Name: Portfolio Run Tag
    * * SQL Data Type: nvarchar(60)
    */
    get PortfolioRunTag(): string | null {
        return this.Get('PortfolioRunTag');
    }
    set PortfolioRunTag(value: string | null) {
        this.Set('PortfolioRunTag', value);
    }

    /**
    * * Field Name: ParcelCount
    * * Display Name: Parcel Count
    * * SQL Data Type: int
    */
    get ParcelCount(): number | null {
        return this.Get('ParcelCount');
    }
    set ParcelCount(value: number | null) {
        this.Set('ParcelCount', value);
    }

    /**
    * * Field Name: TotalAV
    * * Display Name: Total Assessed Value
    * * SQL Data Type: decimal(18, 2)
    */
    get TotalAV(): number | null {
        return this.Get('TotalAV');
    }
    set TotalAV(value: number | null) {
        this.Set('TotalAV', value);
    }

    /**
    * * Field Name: TotalTaxLiability
    * * Display Name: Total Tax Liability
    * * SQL Data Type: decimal(18, 2)
    */
    get TotalTaxLiability(): number | null {
        return this.Get('TotalTaxLiability');
    }
    set TotalTaxLiability(value: number | null) {
        this.Set('TotalTaxLiability', value);
    }

    /**
    * * Field Name: OpportunityAtAsk
    * * Display Name: Opportunity at Ask
    * * SQL Data Type: decimal(18, 2)
    */
    get OpportunityAtAsk(): number | null {
        return this.Get('OpportunityAtAsk');
    }
    set OpportunityAtAsk(value: number | null) {
        this.Set('OpportunityAtAsk', value);
    }

    /**
    * * Field Name: OpportunityAtFloor
    * * Display Name: Opportunity at Floor
    * * SQL Data Type: decimal(18, 2)
    */
    get OpportunityAtFloor(): number | null {
        return this.Get('OpportunityAtFloor');
    }
    set OpportunityAtFloor(value: number | null) {
        this.Set('OpportunityAtFloor', value);
    }

    /**
    * * Field Name: RepdParcelCount
    * * Display Name: Represented Parcel Count
    * * SQL Data Type: int
    */
    get RepdParcelCount(): number | null {
        return this.Get('RepdParcelCount');
    }
    set RepdParcelCount(value: number | null) {
        this.Set('RepdParcelCount', value);
    }

    /**
    * * Field Name: FreshParcelCount
    * * Display Name: Fresh Parcel Count
    * * SQL Data Type: int
    */
    get FreshParcelCount(): number | null {
        return this.Get('FreshParcelCount');
    }
    set FreshParcelCount(value: number | null) {
        this.Set('FreshParcelCount', value);
    }

    /**
    * * Field Name: AVYoYPct
    * * Display Name: AV Year-over-Year %
    * * SQL Data Type: decimal(9, 4)
    */
    get AVYoYPct(): number | null {
        return this.Get('AVYoYPct');
    }
    set AVYoYPct(value: number | null) {
        this.Set('AVYoYPct', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Prospect
    * * Display Name: Prospect Name
    * * SQL Data Type: nvarchar(300)
    */
    get Prospect(): string {
        return this.Get('Prospect');
    }
}


/**
 * Prospect Tasks - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ProspectTask
 * * Base View: vwProspectTasks
 * * @description The outreach queue -- one actionable item per row. A "next step" logged on a ProspectActivity spawns a ProspectTask via SourceActivityID. Drives the My Queue view.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospect Tasks')
export class indianataxProspectTaskEntity extends BaseEntity<indianataxProspectTaskEntityType> {
    /**
    * Loads the Prospect Tasks record from the database
    * @param ID: string - primary key value to load the Prospect Tasks record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectTaskEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ProspectID
    * * Display Name: Prospect
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospects (vwProspects.ID)
    */
    get ProspectID(): string {
        return this.Get('ProspectID');
    }
    set ProspectID(value: string) {
        this.Set('ProspectID', value);
    }

    /**
    * * Field Name: SourceActivityID
    * * Display Name: Source Activity
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Prospect Activities (vwProspectActivities.ID)
    */
    get SourceActivityID(): string | null {
        return this.Get('SourceActivityID');
    }
    set SourceActivityID(value: string | null) {
        this.Set('SourceActivityID', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(400)
    */
    get Title(): string {
        return this.Get('Title');
    }
    set Title(value: string) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: DueDate
    * * Display Name: Due Date
    * * SQL Data Type: date
    */
    get DueDate(): Date | null {
        return this.Get('DueDate');
    }
    set DueDate(value: Date | null) {
        this.Set('DueDate', value);
    }

    /**
    * * Field Name: Assignee
    * * Display Name: Assignee
    * * SQL Data Type: nvarchar(200)
    */
    get Assignee(): string | null {
        return this.Get('Assignee');
    }
    set Assignee(value: string | null) {
        this.Set('Assignee', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Cancelled
    *   * Done
    *   * InProgress
    *   * Open
    */
    get Status(): 'Cancelled' | 'Done' | 'InProgress' | 'Open' {
        return this.Get('Status');
    }
    set Status(value: 'Cancelled' | 'Done' | 'InProgress' | 'Open') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: CompletedDate
    * * Display Name: Completed Date
    * * SQL Data Type: date
    */
    get CompletedDate(): Date | null {
        return this.Get('CompletedDate');
    }
    set CompletedDate(value: Date | null) {
        this.Set('CompletedDate', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(1000)
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Prospect
    * * Display Name: Prospect Name
    * * SQL Data Type: nvarchar(300)
    */
    get Prospect(): string {
        return this.Get('Prospect');
    }

    /**
    * * Field Name: SourceActivity
    * * Display Name: Source Activity Name
    * * SQL Data Type: nvarchar(40)
    */
    get SourceActivity(): string | null {
        return this.Get('SourceActivity');
    }
}


/**
 * Prospects - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: Prospect
 * * Base View: vwProspects
 * * @description A flagged prospecting target -- one operating company we are pursuing for property tax representation. Built over the Owner Prospects screen (scripts/build-owner-portfolios.js). Human-entered pipeline / workflow state; NOT a system of record. See docs/proposals/prospecting-crm.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Prospects')
export class indianataxProspectEntity extends BaseEntity<indianataxProspectEntityType> {
    /**
    * Loads the Prospects record from the database
    * @param ID: string - primary key value to load the Prospects record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxProspectEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: OwnerKey
    * * Display Name: Owner Key
    * * SQL Data Type: nvarchar(200)
    * * Description: Stable join key = normalized ParcelOwnerResolved.CoStarTrueOwner (fallback: MailKey + normalized RawOwnerName). This -- not a regenerated row id -- is what re-links a prospect to the portfolio screen across re-runs. Unique.
    */
    get OwnerKey(): string {
        return this.Get('OwnerKey');
    }
    set OwnerKey(value: string) {
        this.Set('OwnerKey', value);
    }

    /**
    * * Field Name: DisplayName
    * * Display Name: Display Name
    * * SQL Data Type: nvarchar(300)
    */
    get DisplayName(): string {
        return this.Get('DisplayName');
    }
    set DisplayName(value: string) {
        this.Set('DisplayName', value);
    }

    /**
    * * Field Name: RelationshipType
    * * Display Name: Relationship Type
    * * SQL Data Type: nvarchar(30)
    * * Default Value: Unknown
    * * Value List Type: List
    * * Possible Values 
    *   * Cold
    *   * CompetitorRepped
    *   * ExistingClientExpand
    *   * FormerClient
    *   * Unknown
    * * Description: Cold | ExistingClientExpand | CompetitorRepped | FormerClient | Unknown. The routing signal: ExistingClientExpand (e.g. Keystone, Square Deal show "Represented by FAEGRE DRINKER" in the screen) goes to the relationship partner as cross-sell, not cold outreach.
    */
    get RelationshipType(): 'Cold' | 'CompetitorRepped' | 'ExistingClientExpand' | 'FormerClient' | 'Unknown' {
        return this.Get('RelationshipType');
    }
    set RelationshipType(value: 'Cold' | 'CompetitorRepped' | 'ExistingClientExpand' | 'FormerClient' | 'Unknown') {
        this.Set('RelationshipType', value);
    }

    /**
    * * Field Name: Stage
    * * Display Name: Stage
    * * SQL Data Type: nvarchar(30)
    * * Default Value: Identified
    * * Value List Type: List
    * * Possible Values 
    *   * Active
    *   * ClosedLost
    *   * Contacted
    *   * Dormant
    *   * Engaged
    *   * Identified
    *   * Pitched
    *   * Qualified
    *   * Retained
    * * Description: Pipeline stage. May not advance past Qualified until ConflictCheckStatus is Cleared or Waived.
    */
    get Stage(): 'Active' | 'ClosedLost' | 'Contacted' | 'Dormant' | 'Engaged' | 'Identified' | 'Pitched' | 'Qualified' | 'Retained' {
        return this.Get('Stage');
    }
    set Stage(value: 'Active' | 'ClosedLost' | 'Contacted' | 'Dormant' | 'Engaged' | 'Identified' | 'Pitched' | 'Qualified' | 'Retained') {
        this.Set('Stage', value);
    }

    /**
    * * Field Name: StageEnteredDate
    * * Display Name: Stage Entered Date
    * * SQL Data Type: date
    */
    get StageEnteredDate(): Date | null {
        return this.Get('StageEnteredDate');
    }
    set StageEnteredDate(value: Date | null) {
        this.Set('StageEnteredDate', value);
    }

    /**
    * * Field Name: Priority
    * * Display Name: Priority
    * * SQL Data Type: nvarchar(10)
    * * Default Value: Medium
    * * Value List Type: List
    * * Possible Values 
    *   * High
    *   * Low
    *   * Medium
    */
    get Priority(): 'High' | 'Low' | 'Medium' {
        return this.Get('Priority');
    }
    set Priority(value: 'High' | 'Low' | 'Medium') {
        this.Set('Priority', value);
    }

    /**
    * * Field Name: AssignedTo
    * * Display Name: Assigned To
    * * SQL Data Type: nvarchar(200)
    */
    get AssignedTo(): string | null {
        return this.Get('AssignedTo');
    }
    set AssignedTo(value: string | null) {
        this.Set('AssignedTo', value);
    }

    /**
    * * Field Name: IdentifiedDate
    * * Display Name: Identified Date
    * * SQL Data Type: date
    */
    get IdentifiedDate(): Date | null {
        return this.Get('IdentifiedDate');
    }
    set IdentifiedDate(value: Date | null) {
        this.Set('IdentifiedDate', value);
    }

    /**
    * * Field Name: IdentificationSource
    * * Display Name: Identification Source
    * * SQL Data Type: nvarchar(120)
    */
    get IdentificationSource(): string | null {
        return this.Get('IdentificationSource');
    }
    set IdentificationSource(value: string | null) {
        this.Set('IdentificationSource', value);
    }

    /**
    * * Field Name: NextActionDate
    * * Display Name: Next Action Date
    * * SQL Data Type: date
    */
    get NextActionDate(): Date | null {
        return this.Get('NextActionDate');
    }
    set NextActionDate(value: Date | null) {
        this.Set('NextActionDate', value);
    }

    /**
    * * Field Name: ConflictCheckStatus
    * * Display Name: Conflict Check Status
    * * SQL Data Type: nvarchar(30)
    * * Default Value: NotStarted
    * * Value List Type: List
    * * Possible Values 
    *   * Blocked
    *   * Cleared
    *   * NotStarted
    *   * Requested
    *   * Waived
    */
    get ConflictCheckStatus(): 'Blocked' | 'Cleared' | 'NotStarted' | 'Requested' | 'Waived' {
        return this.Get('ConflictCheckStatus');
    }
    set ConflictCheckStatus(value: 'Blocked' | 'Cleared' | 'NotStarted' | 'Requested' | 'Waived') {
        this.Set('ConflictCheckStatus', value);
    }

    /**
    * * Field Name: ConflictCheckNote
    * * Display Name: Conflict Check Note
    * * SQL Data Type: nvarchar(1000)
    */
    get ConflictCheckNote(): string | null {
        return this.Get('ConflictCheckNote');
    }
    set ConflictCheckNote(value: string | null) {
        this.Set('ConflictCheckNote', value);
    }

    /**
    * * Field Name: Thesis
    * * Display Name: Thesis
    * * SQL Data Type: nvarchar(2000)
    * * Description: Free text -- the reason this target was flagged, e.g. "bought the Sheraton (1097651) below the 2026 AV; 9 Marion parcels, $135M AV".
    */
    get Thesis(): string | null {
        return this.Get('Thesis');
    }
    set Thesis(value: string | null) {
        this.Set('Thesis', value);
    }

    /**
    * * Field Name: EstimatedOpportunityAtAsk
    * * Display Name: Estimated Opportunity at Ask
    * * SQL Data Type: decimal(18, 2)
    * * Description: Convenience copy of the most recent ProspectSnapshot.OpportunityAtAsk, maintained by scripts/sync-prospect-snapshots.js, so the pipeline can be sorted by dollars without a join.
    */
    get EstimatedOpportunityAtAsk(): number | null {
        return this.Get('EstimatedOpportunityAtAsk');
    }
    set EstimatedOpportunityAtAsk(value: number | null) {
        this.Set('EstimatedOpportunityAtAsk', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Open
    * * Value List Type: List
    * * Possible Values 
    *   * Dormant
    *   * Lost
    *   * Open
    *   * Won
    */
    get Status(): 'Dormant' | 'Lost' | 'Open' | 'Won' {
        return this.Get('Status');
    }
    set Status(value: 'Dormant' | 'Lost' | 'Open' | 'Won') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: ClosedDate
    * * Display Name: Closed Date
    * * SQL Data Type: date
    */
    get ClosedDate(): Date | null {
        return this.Get('ClosedDate');
    }
    set ClosedDate(value: Date | null) {
        this.Set('ClosedDate', value);
    }

    /**
    * * Field Name: ClosedReason
    * * Display Name: Closed Reason
    * * SQL Data Type: nvarchar(500)
    */
    get ClosedReason(): string | null {
        return this.Get('ClosedReason');
    }
    set ClosedReason(value: string | null) {
        this.Set('ClosedReason', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * PTABOA Appeals - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: PTABOAAppeal
 * * Base View: vwPTABOAAppeals
 * * @description A county Property Tax Assessment Board of Appeals (PTABOA) case for a parcel — a row here means an appeal was filed. Distinct from BoardDecision, which is a state-level IBTR ruling.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'PTABOA Appeals')
export class indianataxPTABOAAppealEntity extends BaseEntity<indianataxPTABOAAppealEntityType> {
    /**
    * Loads the PTABOA Appeals record from the database
    * @param ID: string - primary key value to load the PTABOA Appeals record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxPTABOAAppealEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel under appeal.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: AssessmentYear
    * * Display Name: Assessment Year
    * * SQL Data Type: smallint
    * * Description: The assessment year being appealed.
    */
    get AssessmentYear(): number | null {
        return this.Get('AssessmentYear');
    }
    set AssessmentYear(value: number | null) {
        this.Set('AssessmentYear', value);
    }

    /**
    * * Field Name: HearingDate
    * * Display Name: Hearing Date
    * * SQL Data Type: date
    * * Description: Date of the PTABOA hearing, per the agenda.
    */
    get HearingDate(): Date | null {
        return this.Get('HearingDate');
    }
    set HearingDate(value: Date | null) {
        this.Set('HearingDate', value);
    }

    /**
    * * Field Name: DecisionStatus
    * * Display Name: Decision Status
    * * SQL Data Type: nvarchar(50)
    * * Description: Outcome of the appeal (e.g. Pending, Reduced, Withdrawn, Denied), as best determined from the agenda/decision text.
    */
    get DecisionStatus(): string | null {
        return this.Get('DecisionStatus');
    }
    set DecisionStatus(value: string | null) {
        this.Set('DecisionStatus', value);
    }

    /**
    * * Field Name: Circumstances
    * * Display Name: Circumstances
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text circumstances/notes about the appeal, extracted from the agenda.
    */
    get Circumstances(): string | null {
        return this.Get('Circumstances');
    }
    set Circumstances(value: string | null) {
        this.Set('Circumstances', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The PTABOA agenda document this appeal was extracted from.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: CaseNumber
    * * Display Name: Case Number
    * * SQL Data Type: nvarchar(50)
    * * Description: The PTABOA case number for this appeal/exemption record (e.g. "49-500-23-0-4-00045"), as printed on the agenda. Confirmed unique per source agenda PDF -- the natural key this table lacked before this migration.
    */
    get CaseNumber(): string | null {
        return this.Get('CaseNumber');
    }
    set CaseNumber(value: string | null) {
        this.Set('CaseNumber', value);
    }

    /**
    * * Field Name: TaxRepresentative
    * * Display Name: Tax Representative
    * * SQL Data Type: nvarchar(200)
    * * Description: Who represented the taxpayer in this matter -- a law firm, tax-advocate firm, or individual name, exactly as printed on the PTABOA agenda (e.g. "LANDMAN BEATTY, LAWYERS Attn: KATHRYN M. MERRITT-THRASHER", "JM Tax Advocates Attn: Joshua J. Malancuk"). NULL means no representative is listed on the agenda for this record -- most commonly a self-represented petitioner, not a parsing gap (confirmed 2026-08-26: ~60% of records across the currently-loaded 2024-12 through 2025-12 agendas have one).
    */
    get TaxRepresentative(): string | null {
        return this.Get('TaxRepresentative');
    }
    set TaxRepresentative(value: string | null) {
        this.Set('TaxRepresentative', value);
    }

    /**
    * * Field Name: BeforeLandAV
    * * Display Name: Before Land Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Land assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.
    */
    get BeforeLandAV(): number | null {
        return this.Get('BeforeLandAV');
    }
    set BeforeLandAV(value: number | null) {
        this.Set('BeforeLandAV', value);
    }

    /**
    * * Field Name: BeforeImprovementAV
    * * Display Name: Before Improvement Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Improvement assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.
    */
    get BeforeImprovementAV(): number | null {
        return this.Get('BeforeImprovementAV');
    }
    set BeforeImprovementAV(value: number | null) {
        this.Set('BeforeImprovementAV', value);
    }

    /**
    * * Field Name: BeforeTotalAV
    * * Display Name: Before Total Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total assessed value (Land + Improvement) BEFORE this appeal/exemption was decided.
    */
    get BeforeTotalAV(): number | null {
        return this.Get('BeforeTotalAV');
    }
    set BeforeTotalAV(value: number | null) {
        this.Set('BeforeTotalAV', value);
    }

    /**
    * * Field Name: AfterLandAV
    * * Display Name: After Land Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Land assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeLandAV when the appeal produced no land-value change.
    */
    get AfterLandAV(): number | null {
        return this.Get('AfterLandAV');
    }
    set AfterLandAV(value: number | null) {
        this.Set('AfterLandAV', value);
    }

    /**
    * * Field Name: AfterImprovementAV
    * * Display Name: After Improvement Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Improvement assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeImprovementAV when the appeal produced no improvement-value change.
    */
    get AfterImprovementAV(): number | null {
        return this.Get('AfterImprovementAV');
    }
    set AfterImprovementAV(value: number | null) {
        this.Set('AfterImprovementAV', value);
    }

    /**
    * * Field Name: AfterTotalAV
    * * Display Name: After Total Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total assessed value (Land + Improvement) AFTER this appeal/exemption was decided. AfterTotalAV - BeforeTotalAV is this appeal's AV change (negative = a reduction) -- computed at query/display time rather than stored, to avoid drift.
    */
    get AfterTotalAV(): number | null {
        return this.Get('AfterTotalAV');
    }
    set AfterTotalAV(value: number | null) {
        this.Set('AfterTotalAV', value);
    }

    /**
    * * Field Name: RecordKind
    * * Display Name: Record Kind
    * * SQL Data Type: nvarchar(20)
    * * Description: Whether this record is a valuation Appeal or an Exemption request, per the agenda page's own "For Appeal/Exemption <form> Year: <year>" header. NOT the same question as DecisionStatus (which appeal/exemption records can both carry, e.g. "Exemption-Approved" vs "Final Agreement") -- this is the request TYPE, DecisionStatus is the outcome.
    */
    get RecordKind(): string | null {
        return this.Get('RecordKind');
    }
    set RecordKind(value: string | null) {
        this.Set('RecordKind', value);
    }

    /**
    * * Field Name: AppealType
    * * Display Name: Appeal Type
    * * SQL Data Type: nvarchar(20)
    * * Description: The Indiana form number this record was filed under, e.g. "130S" (subjective/market-value valuation appeal -- the most directly informative type for sub-class assessed-value analytics), "130O" (objective/mathematical-error valuation appeal), "136" or "136C" (charitable/nonprofit exemption request -- NOT a valuation dispute; exclude from win-rate/avg-reduction rollups meant to describe assessed-value accuracy).
    */
    get AppealType(): string | null {
        return this.Get('AppealType');
    }
    set AppealType(value: string | null) {
        this.Set('AppealType', value);
    }

    /**
    * * Field Name: FinalDeterminationSourceDocumentID
    * * Display Name: Final Determination Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument row for the monthly Final Determination batch PDF that confirmed this appeal's outcome, matched by (parcel, assessment year) against a real Form 115 within that batch. NULL means this appeal's agenda-reported outcome has NOT yet been confirmed by an actual Final Determination -- do not treat DecisionStatus/AfterTotalAV as final while this is NULL; see the migration header for a real example of an agenda "Final Agreement" label that turned out to be premature.
    */
    get FinalDeterminationSourceDocumentID(): string | null {
        return this.Get('FinalDeterminationSourceDocumentID');
    }
    set FinalDeterminationSourceDocumentID(value: string | null) {
        this.Set('FinalDeterminationSourceDocumentID', value);
    }

    /**
    * * Field Name: FinalDeterminationLandAV
    * * Display Name: Final Determination Land Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Land assessed value from the actual ratified Form 115 (SECTION III: FINAL DETERMINATION), once confirmed. Compare against BeforeLandAV (the agenda's own before-figure) -- do NOT assume this always equals AfterLandAV; the rare case where it differs is exactly the discrepancy this column exists to catch.
    */
    get FinalDeterminationLandAV(): number | null {
        return this.Get('FinalDeterminationLandAV');
    }
    set FinalDeterminationLandAV(value: number | null) {
        this.Set('FinalDeterminationLandAV', value);
    }

    /**
    * * Field Name: FinalDeterminationImprovementAV
    * * Display Name: Final Determination Improvement Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Improvement assessed value from the actual ratified Form 115, once confirmed. See FinalDeterminationLandAV's comment.
    */
    get FinalDeterminationImprovementAV(): number | null {
        return this.Get('FinalDeterminationImprovementAV');
    }
    set FinalDeterminationImprovementAV(value: number | null) {
        this.Set('FinalDeterminationImprovementAV', value);
    }

    /**
    * * Field Name: FinalDeterminationTotalAV
    * * Display Name: Final Determination Total Assessment Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Total assessed value (Land + Improvement) from the actual ratified Form 115, once confirmed. Compare against AfterTotalAV (the agenda's own prediction) -- a mismatch here is a genuine "the board changed what the parties proposed" case, the specific scenario this table's Final Determination columns exist to catch. NULL (unconfirmed) is expected for most recent appeals -- Final Determination batches lag the agenda by weeks to months.
    */
    get FinalDeterminationTotalAV(): number | null {
        return this.Get('FinalDeterminationTotalAV');
    }
    set FinalDeterminationTotalAV(value: number | null) {
        this.Set('FinalDeterminationTotalAV', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Research Tasks - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ResearchTask
 * * Base View: vwResearchTasks
 * * @description A research direction identified, evaluated, and tracked — most often deliberately deferred (too large to pursue immediately, or needing a scope decision) rather than silently dropped. The paper trail for "we looked into this and chose not to pursue it yet," distinct from SourceRegistry (sources monitored) and DocumentCatalog (documents reviewed).
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Research Tasks')
export class indianataxResearchTaskEntity extends BaseEntity<indianataxResearchTaskEntityType> {
    /**
    * Loads the Research Tasks record from the database
    * @param ID: string - primary key value to load the Research Tasks record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxResearchTaskEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(200)
    * * Description: Short name for the task.
    */
    get Title(): string {
        return this.Get('Title');
    }
    set Title(value: string) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: Description
    * * Display Name: Description
    * * SQL Data Type: nvarchar(MAX)
    * * Description: What this task is — what was found, what it would take to pursue it.
    */
    get Description(): string {
        return this.Get('Description');
    }
    set Description(value: string) {
        this.Set('Description', value);
    }

    /**
    * * Field Name: Status
    * * Display Name: Status
    * * SQL Data Type: nvarchar(20)
    * * Default Value: Deferred
    * * Value List Type: List
    * * Possible Values 
    *   * Abandoned
    *   * Completed
    *   * Deferred
    *   * InProgress
    *   * Open
    * * Description: Open (identified, not yet evaluated further) / Deferred (evaluated, deliberately held) / InProgress / Completed / Abandoned (evaluated and decided not worth pursuing at all, distinct from Deferred).
    */
    get Status(): 'Abandoned' | 'Completed' | 'Deferred' | 'InProgress' | 'Open' {
        return this.Get('Status');
    }
    set Status(value: 'Abandoned' | 'Completed' | 'Deferred' | 'InProgress' | 'Open') {
        this.Set('Status', value);
    }

    /**
    * * Field Name: DeferralReason
    * * Display Name: Deferral Reason
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Why this is being held rather than pursued now — e.g. scale, needs a scope decision, needs tooling not yet built, needs a source spec not yet found.
    */
    get DeferralReason(): string | null {
        return this.Get('DeferralReason');
    }
    set DeferralReason(value: string | null) {
        this.Set('DeferralReason', value);
    }

    /**
    * * Field Name: RelatedSourceRegistryID
    * * Display Name: Related Source Registry
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Registries (vwSourceRegistries.ID)
    * * Description: The SourceRegistry entry this task concerns, if any.
    */
    get RelatedSourceRegistryID(): string | null {
        return this.Get('RelatedSourceRegistryID');
    }
    set RelatedSourceRegistryID(value: string | null) {
        this.Set('RelatedSourceRegistryID', value);
    }

    /**
    * * Field Name: RelatedSourceDocumentID
    * * Display Name: Related Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument this task concerns, if any (e.g. a spec document that unblocks the task once found).
    */
    get RelatedSourceDocumentID(): string | null {
        return this.Get('RelatedSourceDocumentID');
    }
    set RelatedSourceDocumentID(value: string | null) {
        this.Set('RelatedSourceDocumentID', value);
    }

    /**
    * * Field Name: RaisedAt
    * * Display Name: Raised At
    * * SQL Data Type: datetimeoffset
    * * Default Value: sysdatetimeoffset()
    * * Description: When this task was first identified.
    */
    get RaisedAt(): Date {
        return this.Get('RaisedAt');
    }
    set RaisedAt(value: Date) {
        this.Set('RaisedAt', value);
    }

    /**
    * * Field Name: RevisitAt
    * * Display Name: Revisit At
    * * SQL Data Type: date
    * * Description: A natural date to reconsider this task, if there is one (e.g. a next annual data cycle). NULL means "revisit whenever it becomes a priority," not "no need to revisit."
    */
    get RevisitAt(): Date | null {
        return this.Get('RevisitAt');
    }
    set RevisitAt(value: Date | null) {
        this.Set('RevisitAt', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text running notes — updated as understanding of the task evolves.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: RelatedSourceRegistry
    * * Display Name: Related Source Registry
    * * SQL Data Type: nvarchar(200)
    */
    get RelatedSourceRegistry(): string | null {
        return this.Get('RelatedSourceRegistry');
    }
}


/**
 * Sale Transactions - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: SaleTransaction
 * * Base View: vwSaleTransactions
 * * @description One observed real-estate sale -- the sales-comparison comp pool. Subject sales and off-portfolio comps both live here (ParcelID nullable). Populated from data already loaded (CountyAssessorSaleHistory + CoStarProperty), no new acquisition. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Sale Transactions')
export class indianataxSaleTransactionEntity extends BaseEntity<indianataxSaleTransactionEntityType> {
    /**
    * Loads the Sale Transactions record from the database
    * @param ID: string - primary key value to load the Sale Transactions record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxSaleTransactionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for Sale Transactions entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: Building square footage excluding parking must be either empty or a non-negative value that does not exceed the total building square footage by more than 1 square foot. This ensures that the square footage excluding parking is a reasonable subset of the total building square footage.
    * * Table-Level: Sale price, building square footage, unit count, and acres must all be non-negative values. These financial and property measurement fields cannot be negative, ensuring data integrity for pricing analysis and property metrics.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateBuildingSqFtExParkingAgainstBuildingSqFt(result);
        this.ValidateNonNegativePropertyMetrics(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * Building square footage excluding parking must be either empty or a non-negative value that does not exceed the total building square footage by more than 1 square foot. This ensures that the square footage excluding parking is a reasonable subset of the total building square footage.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateBuildingSqFtExParkingAgainstBuildingSqFt(result: ValidationResult) {
    	if (this.BuildingSqFtExParking != null) {
    		if (this.BuildingSqFtExParking < 0) {
    			result.Errors.push(new ValidationErrorInfo(
    				"BuildingSqFtExParking",
    				"Building square footage excluding parking must be a non-negative value.",
    				this.BuildingSqFtExParking,
    				ValidationErrorType.Failure
    			));
    		}
    		if (this.BuildingSqFt != null && this.BuildingSqFtExParking > (this.BuildingSqFt + 1)) {
    			result.Errors.push(new ValidationErrorInfo(
    				"BuildingSqFtExParking",
    				"Building square footage excluding parking cannot exceed total building square footage by more than 1 square foot.",
    				this.BuildingSqFtExParking,
    				ValidationErrorType.Failure
    			));
    		}
    	}
    }

    /**
    * Sale price, building square footage, unit count, and acres must all be non-negative values. These financial and property measurement fields cannot be negative, ensuring data integrity for pricing analysis and property metrics.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateNonNegativePropertyMetrics(result: ValidationResult) {
    	if (this.SalePrice != null && this.SalePrice < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"SalePrice",
    			"Sale price must be greater than or equal to zero.",
    			this.SalePrice,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.BuildingSqFt != null && this.BuildingSqFt < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"BuildingSqFt",
    			"Building square footage must be greater than or equal to zero.",
    			this.BuildingSqFt,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.UnitCount != null && this.UnitCount < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"UnitCount",
    			"Unit count must be greater than or equal to zero.",
    			this.UnitCount,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.Acres != null && this.Acres < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"Acres",
    			"Acreage must be greater than or equal to zero.",
    			this.Acres,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Source
    * * Display Name: Source
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * CoStar
    *   * Manual
    *   * MarionPRC
    *   * Recorder
    *   * SalesDisclosure
    * * Description: Where this observation came from: MarionPRC (the PRC "Transfer of Ownership" section, via CountyAssessorSaleHistory), CoStar, SalesDisclosure, Recorder, or Manual.
    */
    get Source(): 'CoStar' | 'Manual' | 'MarionPRC' | 'Recorder' | 'SalesDisclosure' {
        return this.Get('Source');
    }
    set Source(value: 'CoStar' | 'Manual' | 'MarionPRC' | 'Recorder' | 'SalesDisclosure') {
        this.Set('Source', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument this sale was read from (e.g. the parcel's PRC). NULL for a manually-entered comp.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The Parcel that transacted, when it is one of the project's parcels. NULL for an off-portfolio comp (address/attributes still recorded).
    */
    get ParcelID(): string | null {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string | null) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: CountyNumber
    * * Display Name: County Number
    * * SQL Data Type: smallint
    * * Description: Indiana county number of the property that sold.
    */
    get CountyNumber(): number | null {
        return this.Get('CountyNumber');
    }
    set CountyNumber(value: number | null) {
        this.Set('CountyNumber', value);
    }

    /**
    * * Field Name: SitusAddress
    * * Display Name: Situs Address
    * * SQL Data Type: nvarchar(200)
    * * Description: Street address of the property that sold, as recorded at load time.
    */
    get SitusAddress(): string | null {
        return this.Get('SitusAddress');
    }
    set SitusAddress(value: string | null) {
        this.Set('SitusAddress', value);
    }

    /**
    * * Field Name: City
    * * Display Name: City
    * * SQL Data Type: nvarchar(80)
    * * Description: City of the property that sold.
    */
    get City(): string | null {
        return this.Get('City');
    }
    set City(value: string | null) {
        this.Set('City', value);
    }

    /**
    * * Field Name: Submarket
    * * Display Name: Submarket
    * * SQL Data Type: nvarchar(80)
    * * Description: Submarket label (from CoStar where available) -- used to group/adjust comps by location.
    */
    get Submarket(): string | null {
        return this.Get('Submarket');
    }
    set Submarket(value: string | null) {
        this.Set('Submarket', value);
    }

    /**
    * * Field Name: PropertyClassCode
    * * Display Name: Property Class Code
    * * SQL Data Type: nvarchar(10)
    * * Description: The assessor property class code as of load (e.g. "447", "350", "400") -- the primary comp-grouping key.
    */
    get PropertyClassCode(): string | null {
        return this.Get('PropertyClassCode');
    }
    set PropertyClassCode(value: string | null) {
        this.Set('PropertyClassCode', value);
    }

    /**
    * * Field Name: PropertyTypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * Hospitality
    *   * Industrial
    *   * Land
    *   * Multifamily
    *   * Office
    *   * Other
    *   * Parking
    *   * Retail
    *   * Special
    * * Description: Rolled-up category derived from PropertyClassCode: Retail, Office, Industrial, Multifamily, Land, Special, or Other. Coarser grouping for comp selection when the exact class pool is thin.
    */
    get PropertyTypeGroup(): 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special' | null {
        return this.Get('PropertyTypeGroup');
    }
    set PropertyTypeGroup(value: 'Hospitality' | 'Industrial' | 'Land' | 'Multifamily' | 'Office' | 'Other' | 'Parking' | 'Retail' | 'Special' | null) {
        this.Set('PropertyTypeGroup', value);
    }

    /**
    * * Field Name: SaleDate
    * * Display Name: Sale Date
    * * SQL Data Type: date
    * * Description: Date of the sale.
    */
    get SaleDate(): Date {
        return this.Get('SaleDate');
    }
    set SaleDate(value: Date) {
        this.Set('SaleDate', value);
    }

    /**
    * * Field Name: SalePrice
    * * Display Name: Sale Price
    * * SQL Data Type: decimal(14, 2)
    * * Description: Recorded sale price.
    */
    get SalePrice(): number {
        return this.Get('SalePrice');
    }
    set SalePrice(value: number) {
        this.Set('SalePrice', value);
    }

    /**
    * * Field Name: Grantor
    * * Display Name: Grantor
    * * SQL Data Type: nvarchar(200)
    * * Description: Seller. The PRC transfer section records the grantor only.
    */
    get Grantor(): string | null {
        return this.Get('Grantor');
    }
    set Grantor(value: string | null) {
        this.Set('Grantor', value);
    }

    /**
    * * Field Name: Grantee
    * * Display Name: Grantee
    * * SQL Data Type: nvarchar(200)
    * * Description: Buyer, when available (CoStar / recorder). NULL from PRC transfer data.
    */
    get Grantee(): string | null {
        return this.Get('Grantee');
    }
    set Grantee(value: string | null) {
        this.Set('Grantee', value);
    }

    /**
    * * Field Name: DeedOrSaleType
    * * Display Name: Deed or Sale Type
    * * SQL Data Type: nvarchar(30)
    * * Description: The county's sale-type label ("Straight" / "Sale" / "Split" in Marion) or deed type (warranty / quitclaim ...).
    */
    get DeedOrSaleType(): string | null {
        return this.Get('DeedOrSaleType');
    }
    set DeedOrSaleType(value: string | null) {
        this.Set('DeedOrSaleType', value);
    }

    /**
    * * Field Name: CountyValidForTrending
    * * Display Name: County Valid for Trending
    * * SQL Data Type: bit
    * * Description: The county's own valid/invalid designation for this sale, recorded VERBATIM as metadata. It reflects the county's ratio-study / trending methodology (DLGF rules), NOT whether the sale is a good comparable for a subjective valuation argument -- many county-"invalid" sales are legitimate market evidence. DO NOT gate comp selection on this column.
    */
    get CountyValidForTrending(): boolean | null {
        return this.Get('CountyValidForTrending');
    }
    set CountyValidForTrending(value: boolean | null) {
        this.Set('CountyValidForTrending', value);
    }

    /**
    * * Field Name: CountyValidityNote
    * * Display Name: County Validity Note
    * * SQL Data Type: nvarchar(200)
    * * Description: Any note the county attached to its validity determination.
    */
    get CountyValidityNote(): string | null {
        return this.Get('CountyValidityNote');
    }
    set CountyValidityNote(value: string | null) {
        this.Set('CountyValidityNote', value);
    }

    /**
    * * Field Name: IsArmsLength
    * * Display Name: Is Arms Length
    * * SQL Data Type: bit
    * * Description: A separate, analyst-owned judgement about whether this transaction is usable as market evidence for an analysis. Starts NULL (unassessed); set deliberately during comp review with the reasoning in VerificationNote. NOT copied from CountyValidForTrending.
    */
    get IsArmsLength(): boolean | null {
        return this.Get('IsArmsLength');
    }
    set IsArmsLength(value: boolean | null) {
        this.Set('IsArmsLength', value);
    }

    /**
    * * Field Name: VerificationNote
    * * Display Name: Verification Note
    * * SQL Data Type: nvarchar(400)
    * * Description: Free text: why this sale was verified in or excluded as market evidence (conditions of sale, related parties, personal property included, portfolio allocation, etc.).
    */
    get VerificationNote(): string | null {
        return this.Get('VerificationNote');
    }
    set VerificationNote(value: string | null) {
        this.Set('VerificationNote', value);
    }

    /**
    * * Field Name: BuildingSqFt
    * * Display Name: Building Sq Ft
    * * SQL Data Type: int
    * * Description: Building area (sq ft) as of load -- from the PRC (SqFtSource = PropertyRecordCard) or CoStar RBA. Stored, not looked up live, so a comp stays reproducible.
    */
    get BuildingSqFt(): number | null {
        return this.Get('BuildingSqFt');
    }
    set BuildingSqFt(value: number | null) {
        this.Set('BuildingSqFt', value);
    }

    /**
    * * Field Name: UnitCount
    * * Display Name: Unit Count
    * * SQL Data Type: int
    * * Description: Unit count (multifamily) as of load, where known.
    */
    get UnitCount(): number | null {
        return this.Get('UnitCount');
    }
    set UnitCount(value: number | null) {
        this.Set('UnitCount', value);
    }

    /**
    * * Field Name: Acres
    * * Display Name: Acres
    * * SQL Data Type: decimal(10, 4)
    * * Description: Land area (acres) as of load.
    */
    get Acres(): number | null {
        return this.Get('Acres');
    }
    set Acres(value: number | null) {
        this.Set('Acres', value);
    }

    /**
    * * Field Name: YearBuilt
    * * Display Name: Year Built
    * * SQL Data Type: smallint
    * * Description: Year built as of load.
    */
    get YearBuilt(): number | null {
        return this.Get('YearBuilt');
    }
    set YearBuilt(value: number | null) {
        this.Set('YearBuilt', value);
    }

    /**
    * * Field Name: ConditionGrade
    * * Display Name: Condition Grade
    * * SQL Data Type: nvarchar(20)
    * * Description: Condition / grade descriptor as of load, where known.
    */
    get ConditionGrade(): string | null {
        return this.Get('ConditionGrade');
    }
    set ConditionGrade(value: string | null) {
        this.Set('ConditionGrade', value);
    }

    /**
    * * Field Name: PricePerSqFt
    * * Display Name: Price Per Sq Ft
    * * SQL Data Type: decimal(12, 2)
    * * Description: SalePrice / BuildingSqFt, computed at load. NULL when BuildingSqFt is unknown.
    */
    get PricePerSqFt(): number | null {
        return this.Get('PricePerSqFt');
    }
    set PricePerSqFt(value: number | null) {
        this.Set('PricePerSqFt', value);
    }

    /**
    * * Field Name: PricePerUnit
    * * Display Name: Price Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: SalePrice / UnitCount, computed at load. NULL when UnitCount is unknown.
    */
    get PricePerUnit(): number | null {
        return this.Get('PricePerUnit');
    }
    set PricePerUnit(value: number | null) {
        this.Set('PricePerUnit', value);
    }

    /**
    * * Field Name: PricePerAcre
    * * Display Name: Price Per Acre
    * * SQL Data Type: decimal(14, 2)
    * * Description: SalePrice / Acres, computed at load. NULL when Acres is unknown.
    */
    get PricePerAcre(): number | null {
        return this.Get('PricePerAcre');
    }
    set PricePerAcre(value: number | null) {
        this.Set('PricePerAcre', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text notes about this transaction.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: TransactionKind
    * * Display Name: Transaction Kind
    * * SQL Data Type: nvarchar(20)
    * * Default Value: ClosedSale
    * * Value List Type: List
    * * Possible Values 
    *   * ActiveListing
    *   * ClosedSale
    *   * UnderContract
    * * Description: ClosedSale (a completed transaction -- the only kind that should enter comp selection), UnderContract (pending), or ActiveListing (currently for sale; SalePrice is the list/asking price). Listings are retained for lead generation -- a property listed below its assessed value is an appeal signal -- but must be filtered out of any comp analysis.
    */
    get TransactionKind(): 'ActiveListing' | 'ClosedSale' | 'UnderContract' {
        return this.Get('TransactionKind');
    }
    set TransactionKind(value: 'ActiveListing' | 'ClosedSale' | 'UnderContract') {
        this.Set('TransactionKind', value);
    }

    /**
    * * Field Name: AssessedValueAtSale
    * * Display Name: Assessed Value at Sale
    * * SQL Data Type: decimal(14, 2)
    * * Description: The county assessed (total) value applicable around the transaction date. From the CoStar export directly for CoStar rows; backfilled from indiana_tax.Assessment (nearest AssessmentYear within +/- 2 of the sale year) for PRC-sourced transfers. NULL when no contemporaneous AV is available (older transfers).
    */
    get AssessedValueAtSale(): number | null {
        return this.Get('AssessedValueAtSale');
    }
    set AssessedValueAtSale(value: number | null) {
        this.Set('AssessedValueAtSale', value);
    }

    /**
    * * Field Name: AssessedYearAtSale
    * * Display Name: Assessed Year at Sale
    * * SQL Data Type: smallint
    * * Description: The assessment year of AssessedValueAtSale.
    */
    get AssessedYearAtSale(): number | null {
        return this.Get('AssessedYearAtSale');
    }
    set AssessedYearAtSale(value: number | null) {
        this.Set('AssessedYearAtSale', value);
    }

    /**
    * * Field Name: SaleToAssessedRatio
    * * Display Name: Sale to Assessed Ratio
    * * SQL Data Type: decimal(9, 4)
    * * Description: SalePrice / AssessedValueAtSale, computed at load. Below ~1.0 means the property sold for less than its assessment -- an over-assessment / appeal candidate. Interpret with the sale's IsArmsLength and any allocation/portfolio note: a per-parcel slice price of a portfolio deal against a whole-portfolio AV produces a misleadingly low ratio.
    */
    get SaleToAssessedRatio(): number | null {
        return this.Get('SaleToAssessedRatio');
    }
    set SaleToAssessedRatio(value: number | null) {
        this.Set('SaleToAssessedRatio', value);
    }

    /**
    * * Field Name: CapRateAtSale
    * * Display Name: Cap Rate at Sale
    * * SQL Data Type: decimal(6, 4)
    * * Description: The overall (going-in) capitalization rate reported for this transaction, as a DECIMAL FRACTION (0.0650 = 6.50%). From the CoStar "Actual Cap Rate" field; NULL when not reported (the majority of sales).
    */
    get CapRateAtSale(): number | null {
        return this.Get('CapRateAtSale');
    }
    set CapRateAtSale(value: number | null) {
        this.Set('CapRateAtSale', value);
    }

    /**
    * * Field Name: ImpliedNOIAtSale
    * * Display Name: Implied NOI at Sale
    * * SQL Data Type: decimal(14, 2)
    * * Description: SalePrice x CapRateAtSale -- the market net operating income implied by the price and the reported cap rate. Computed at load. Used to derive NOI/SqFt and NOI/Unit comps for the income approach (CoStar reports no direct NOI).
    */
    get ImpliedNOIAtSale(): number | null {
        return this.Get('ImpliedNOIAtSale');
    }
    set ImpliedNOIAtSale(value: number | null) {
        this.Set('ImpliedNOIAtSale', value);
    }

    /**
    * * Field Name: BuildingSqFtExParking
    * * Display Name: Building Sq Ft (Ex Parking)
    * * SQL Data Type: decimal(14, 2)
    * * Description: Building square footage with structured parking removed -- the comp-side parallel of ParcelPhysicalProfile.BuildingSqFtExParking, so comp $/SF is computed on the same basis as the subject. For a MarionPRC row on a parcel with a Parking / Pkg Garage / Com Garage improvement segment: BuildingSqFt minus that segment SqFt (NULL when the result is <= 0, i.e. a standalone garage). Otherwise equals BuildingSqFt (no parking; CoStar RBA is already rentable area). Use this, not BuildingSqFt, for $/SF comp math.
    */
    get BuildingSqFtExParking(): number | null {
        return this.Get('BuildingSqFtExParking');
    }
    set BuildingSqFtExParking(value: number | null) {
        this.Set('BuildingSqFtExParking', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string | null {
        return this.Get('Parcel');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Source Documents - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: SourceDocument
 * * Base View: vwSourceDocuments
 * * @description The fetch/verification trail for a document pulled from DLGF, IBTR, a county source, or a reference text. One row per unique document (deduplicated on ContentHash): where it came from, when it was retrieved, the original file on disk, and its extracted, queryable text. Every fact sourced from a document should trace back to one of these rows.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Source Documents')
export class indianataxSourceDocumentEntity extends BaseEntity<indianataxSourceDocumentEntityType> {
    /**
    * Loads the Source Documents record from the database
    * @param ID: string - primary key value to load the Source Documents record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxSourceDocumentEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: DocumentType
    * * Display Name: Document Type
    * * SQL Data Type: nvarchar(50)
    * * Value List Type: List
    * * Possible Values 
    *   * BoardDecision
    *   * CountyParcelList
    *   * Form
    *   * MarketDataExport
    *   * Memo
    *   * Other
    *   * PTABOAAgenda
    *   * PTABOAFinalDeterminationApproval
    *   * PTABOAFinalDeterminationWithdrawal
    *   * PropertyRecordCard
    *   * ReferenceText
    *   * Regulation
    *   * StatewideParcelDataset
    *   * Statute
    *   * TaxHistoryReport
    * * Description: What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF), TaxHistoryReport (a county assessor Tax History Report PDF), PTABOAFinalDeterminationApproval (a monthly batch of ratified Form 115 Notifications of Final Assessment Determination, from indy.gov's "Preliminary Agreement Approvals" list -- Marion County only), PTABOAFinalDeterminationWithdrawal (the same, from indy.gov's "Approved Withdrawls" list), or Other.
    */
    get DocumentType(): 'BoardDecision' | 'CountyParcelList' | 'Form' | 'MarketDataExport' | 'Memo' | 'Other' | 'PTABOAAgenda' | 'PTABOAFinalDeterminationApproval' | 'PTABOAFinalDeterminationWithdrawal' | 'PropertyRecordCard' | 'ReferenceText' | 'Regulation' | 'StatewideParcelDataset' | 'Statute' | 'TaxHistoryReport' {
        return this.Get('DocumentType');
    }
    set DocumentType(value: 'BoardDecision' | 'CountyParcelList' | 'Form' | 'MarketDataExport' | 'Memo' | 'Other' | 'PTABOAAgenda' | 'PTABOAFinalDeterminationApproval' | 'PTABOAFinalDeterminationWithdrawal' | 'PropertyRecordCard' | 'ReferenceText' | 'Regulation' | 'StatewideParcelDataset' | 'Statute' | 'TaxHistoryReport') {
        this.Set('DocumentType', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(500)
    * * Description: Human-readable title for the document (e.g. a case caption, a statute article name, a form name).
    */
    get Title(): string {
        return this.Get('Title');
    }
    set Title(value: string) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: SourceURL
    * * Display Name: Source URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: The URL the document was fetched from, if it came from the web. NULL for documents entered from a local/offline source.
    */
    get SourceURL(): string | null {
        return this.Get('SourceURL');
    }
    set SourceURL(value: string | null) {
        this.Set('SourceURL', value);
    }

    /**
    * * Field Name: RetrievedAt
    * * Display Name: Retrieved At
    * * SQL Data Type: datetimeoffset
    * * Description: When this document was fetched/retrieved. Distinct from any date printed on the document itself — this is about verifying when WE pulled it.
    */
    get RetrievedAt(): Date | null {
        return this.Get('RetrievedAt');
    }
    set RetrievedAt(value: Date | null) {
        this.Set('RetrievedAt', value);
    }

    /**
    * * Field Name: ContentHash
    * * Display Name: Content Hash
    * * SQL Data Type: char(64)
    * * Description: SHA-256 hex digest of the raw file content. Used to detect an already-fetched document before re-downloading or re-extracting it (the dedup mechanism for the ingestion pipeline).
    */
    get ContentHash(): string | null {
        return this.Get('ContentHash');
    }
    set ContentHash(value: string | null) {
        this.Set('ContentHash', value);
    }

    /**
    * * Field Name: RawFilePath
    * * Display Name: Raw File Path
    * * SQL Data Type: nvarchar(1000)
    * * Description: Local filesystem path to the original, unmodified file (PDF, HTML, etc.) as retrieved — the audit copy kept for future re-verification.
    */
    get RawFilePath(): string | null {
        return this.Get('RawFilePath');
    }
    set RawFilePath(value: string | null) {
        this.Set('RawFilePath', value);
    }

    /**
    * * Field Name: ExtractedText
    * * Display Name: Extracted Text
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Full extracted plain text of the document, stored inline so it can be queried/searched/embedded directly without re-reading the original file.
    */
    get ExtractedText(): string | null {
        return this.Get('ExtractedText');
    }
    set ExtractedText(value: string | null) {
        this.Set('ExtractedText', value);
    }

    /**
    * * Field Name: ExtractionNotes
    * * Display Name: Extraction Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text notes about the extraction itself — e.g. a font-encoding problem that made the text unreliable, or that OCR was used as a fallback.
    */
    get ExtractionNotes(): string | null {
        return this.Get('ExtractionNotes');
    }
    set ExtractionNotes(value: string | null) {
        this.Set('ExtractionNotes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: DocumentDate
    * * Display Name: Document Date
    * * SQL Data Type: date
    * * Description: The date the document itself is dated/effective (a memo's issue date, a decision's date) — distinct from RetrievedAt, which is when WE fetched it. NULL where the document has no single clear date (e.g. a multi-year-cycle reference text).
    */
    get DocumentDate(): Date | null {
        return this.Get('DocumentDate');
    }
    set DocumentDate(value: Date | null) {
        this.Set('DocumentDate', value);
    }

    /**
    * * Field Name: LastVerifiedAt
    * * Display Name: Last Verified At
    * * SQL Data Type: datetimeoffset
    * * Description: The last time this exact document was re-checked, whether or not the content had changed (RetrievedAt only updates on a real change). Updated on every scan so "checked recently, unchanged" is distinguishable from "not looked at in months."
    */
    get LastVerifiedAt(): Date | null {
        return this.Get('LastVerifiedAt');
    }
    set LastVerifiedAt(value: Date | null) {
        this.Set('LastVerifiedAt', value);
    }
}


/**
 * Source Registries - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: SourceRegistry
 * * Base View: vwSourceRegistries
 * * @description A source we monitor for property-tax documents — a DLGF page, the IBTR site, a statewide dataset, a county FOIA feed. This is the "what exists and are we watching it" inventory; individual documents found by scanning a source are DocumentCatalog rows.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Source Registries')
export class indianataxSourceRegistryEntity extends BaseEntity<indianataxSourceRegistryEntityType> {
    /**
    * Loads the Source Registries record from the database
    * @param ID: string - primary key value to load the Source Registries record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxSourceRegistryEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Name
    * * Display Name: Name
    * * SQL Data Type: nvarchar(200)
    * * Description: Human-readable name for the source (unique), e.g. "DLGF Memos — 2026" or "IBTR Board Decisions".
    */
    get Name(): string {
        return this.Get('Name');
    }
    set Name(value: string) {
        this.Set('Name', value);
    }

    /**
    * * Field Name: SourceType
    * * Display Name: Source Type
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * CountyDataset
    *   * DLGF_Website
    *   * IBTR_Website
    *   * IndianaCode_Website
    *   * LocalFile
    *   * Other
    *   * StatewideDataset
    * * Description: What kind of source this is — drives which ingestion code path applies (a statewide geodatabase pull, a website to crawl, a local file set, etc.).
    */
    get SourceType(): 'CountyDataset' | 'DLGF_Website' | 'IBTR_Website' | 'IndianaCode_Website' | 'LocalFile' | 'Other' | 'StatewideDataset' {
        return this.Get('SourceType');
    }
    set SourceType(value: 'CountyDataset' | 'DLGF_Website' | 'IBTR_Website' | 'IndianaCode_Website' | 'LocalFile' | 'Other' | 'StatewideDataset') {
        this.Set('SourceType', value);
    }

    /**
    * * Field Name: RootURL
    * * Display Name: Root URL
    * * SQL Data Type: nvarchar(1000)
    * * Description: The base page/URL this registry entry monitors, if web-based. NULL for non-web sources (e.g. a locally-sourced dataset).
    */
    get RootURL(): string | null {
        return this.Get('RootURL');
    }
    set RootURL(value: string | null) {
        this.Set('RootURL', value);
    }

    /**
    * * Field Name: IsPropertyTaxRelevant
    * * Display Name: Is Property Tax Relevant
    * * SQL Data Type: bit
    * * Default Value: 1
    * * Description: Whether this source itself is in scope for real property taxation. A source can be evaluated and marked 0 (e.g. DLGF Gateway — local government budget/TIF/debt data) so the decision to exclude it is recorded, not just absent.
    */
    get IsPropertyTaxRelevant(): boolean {
        return this.Get('IsPropertyTaxRelevant');
    }
    set IsPropertyTaxRelevant(value: boolean) {
        this.Set('IsPropertyTaxRelevant', value);
    }

    /**
    * * Field Name: ScanFrequency
    * * Display Name: Scan Frequency
    * * SQL Data Type: nvarchar(20)
    * * Value List Type: List
    * * Possible Values 
    *   * AdHoc
    *   * Annual
    *   * Monthly
    *   * OneTime
    *   * Quarterly
    * * Description: How often this source should be re-scanned for new/updated documents: Monthly, Quarterly, Annual, OneTime (already fully captured, e.g. a fixed historical dataset), or AdHoc (rescanned manually as needed).
    */
    get ScanFrequency(): 'AdHoc' | 'Annual' | 'Monthly' | 'OneTime' | 'Quarterly' | null {
        return this.Get('ScanFrequency');
    }
    set ScanFrequency(value: 'AdHoc' | 'Annual' | 'Monthly' | 'OneTime' | 'Quarterly' | null) {
        this.Set('ScanFrequency', value);
    }

    /**
    * * Field Name: LastScannedAt
    * * Display Name: Last Scanned At
    * * SQL Data Type: datetimeoffset
    * * Description: The last time this source was actually scanned for updates, regardless of whether anything new was found. This is the "last date researched" for the source as a whole.
    */
    get LastScannedAt(): Date | null {
        return this.Get('LastScannedAt');
    }
    set LastScannedAt(value: Date | null) {
        this.Set('LastScannedAt', value);
    }

    /**
    * * Field Name: NextScanDueAt
    * * Display Name: Next Scan Due At
    * * SQL Data Type: datetimeoffset
    * * Description: When this source is next due for a scan, computed from LastScannedAt + ScanFrequency. Drives a "what needs attention" view without recomputing on every query.
    */
    get NextScanDueAt(): Date | null {
        return this.Get('NextScanDueAt');
    }
    set NextScanDueAt(value: Date | null) {
        this.Set('NextScanDueAt', value);
    }

    /**
    * * Field Name: LastScanNotes
    * * Display Name: Last Scan Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text outcome of the most recent scan — e.g. "3 new memos found", "no changes", or an error if the source was unreachable.
    */
    get LastScanNotes(): string | null {
        return this.Get('LastScanNotes');
    }
    set LastScanNotes(value: string | null) {
        this.Set('LastScanNotes', value);
    }

    /**
    * * Field Name: Notes
    * * Display Name: Notes
    * * SQL Data Type: nvarchar(MAX)
    * * Description: General notes about this source — why it is or isn't in scope, quirks of its structure, etc.
    */
    get Notes(): string | null {
        return this.Get('Notes');
    }
    set Notes(value: string | null) {
        this.Set('Notes', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Statute Sections - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: StatuteSection
 * * Base View: vwStatuteSections
 * * @description One row per section of Indiana Code Title 6, Article 1.1 (property tax) or 1.5 (indiana board of tax review), chunked by section number so a citation resolves to exact text instead of a whole-article document.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Statute Sections')
export class indianataxStatuteSectionEntity extends BaseEntity<indianataxStatuteSectionEntityType> {
    /**
    * Loads the Statute Sections record from the database
    * @param ID: string - primary key value to load the Statute Sections record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxStatuteSectionEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Article
    * * Display Name: Article
    * * SQL Data Type: nvarchar(20)
    * * Description: Indiana Code article number (e.g. 1.1, 1.5).
    */
    get Article(): string {
        return this.Get('Article');
    }
    set Article(value: string) {
        this.Set('Article', value);
    }

    /**
    * * Field Name: SectionNumber
    * * Display Name: Section Number
    * * SQL Data Type: nvarchar(20)
    * * Description: Full section citation (e.g. 6-1.1-15-1).
    */
    get SectionNumber(): string {
        return this.Get('SectionNumber');
    }
    set SectionNumber(value: string) {
        this.Set('SectionNumber', value);
    }

    /**
    * * Field Name: Title
    * * Display Name: Title
    * * SQL Data Type: nvarchar(500)
    * * Description: Section heading/title, if the source text has one.
    */
    get Title(): string | null {
        return this.Get('Title');
    }
    set Title(value: string | null) {
        this.Set('Title', value);
    }

    /**
    * * Field Name: SectionText
    * * Display Name: Section Text
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Full text of this section, for direct citation and RAG retrieval.
    */
    get SectionText(): string | null {
        return this.Get('SectionText');
    }
    set SectionText(value: string | null) {
        this.Set('SectionText', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The full-article document (e.g. Article_1.1.pdf) this section was parsed out of.
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }
}


/**
 * Stores - strongly typed entity sub-class
 * * Schema: big_box_retail
 * * Base Table: Store
 * * Base View: vwStores
 * * @description One row per address/owner-confirmed big-box retail store, imported from the separate Big Box Retail research project's Indiana roster (Big_Box_Retail/states/indiana/data/indiana-bigbox-roster.csv). Deliberately isolated from indiana_tax -- no foreign keys either direction. See docs/superpowers/specs/2026-09-04-big-box-retail-mj-import-design.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Stores')
export class bigboxretailStoreEntity extends BaseEntity<bigboxretailStoreEntityType> {
    /**
    * Loads the Stores record from the database
    * @param ID: string - primary key value to load the Stores record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof bigboxretailStoreEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: Brand
    * * Display Name: Brand
    * * SQL Data Type: nvarchar(100)
    * * Description: The tenant/retailer brand name (e.g. Walmart, Kohl's, Menards). One row per confirmed store, not per parcel -- a multi-parcel site is one Store row with multiple parcels listed in Parcels.
    */
    get Brand(): string {
        return this.Get('Brand');
    }
    set Brand(value: string) {
        this.Set('Brand', value);
    }

    /**
    * * Field Name: StoreName
    * * Display Name: Store Name
    * * SQL Data Type: nvarchar(200)
    * * Description: The store's display name as returned by the locator source, when it differs from Brand (e.g. "Walmart Supercenter", "Meijer Express").
    */
    get StoreName(): string | null {
        return this.Get('StoreName');
    }
    set StoreName(value: string | null) {
        this.Set('StoreName', value);
    }

    /**
    * * Field Name: Address
    * * Display Name: Street Address
    * * SQL Data Type: nvarchar(200)
    * * Description: Street address of the store.
    */
    get Address(): string {
        return this.Get('Address');
    }
    set Address(value: string) {
        this.Set('Address', value);
    }

    /**
    * * Field Name: City
    * * Display Name: City
    * * SQL Data Type: nvarchar(100)
    * * Description: City.
    */
    get City(): string {
        return this.Get('City');
    }
    set City(value: string) {
        this.Set('City', value);
    }

    /**
    * * Field Name: State
    * * Display Name: State
    * * SQL Data Type: nchar(2)
    * * Default Value: IN
    * * Description: Two-letter state code. Indiana-only for now ('IN') -- a placeholder for future states, not yet used for any multi-state logic.
    */
    get State(): string {
        return this.Get('State');
    }
    set State(value: string) {
        this.Set('State', value);
    }

    /**
    * * Field Name: ZIP
    * * Display Name: ZIP Code
    * * SQL Data Type: nvarchar(10)
    * * Description: ZIP code, as returned by the locator source.
    */
    get ZIP(): string | null {
        return this.Get('ZIP');
    }
    set ZIP(value: string | null) {
        this.Set('ZIP', value);
    }

    /**
    * * Field Name: County
    * * Display Name: County
    * * SQL Data Type: nvarchar(50)
    * * Description: Indiana county name (DLGF numbering -- see Big_Box_Retail/states/indiana/data/COUNTY_CODES.md), derived from the matched parcel's county code.
    */
    get County(): string | null {
        return this.Get('County');
    }
    set County(value: string | null) {
        this.Set('County', value);
    }

    /**
    * * Field Name: Latitude
    * * Display Name: Latitude
    * * SQL Data Type: decimal(9, 6)
    * * Description: Latitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).
    */
    get Latitude(): number | null {
        return this.Get('Latitude');
    }
    set Latitude(value: number | null) {
        this.Set('Latitude', value);
    }

    /**
    * * Field Name: Longitude
    * * Display Name: Longitude
    * * SQL Data Type: decimal(9, 6)
    * * Description: Longitude in decimal degrees, from the locator source (OpenStreetMap Overpass or Nominatim).
    */
    get Longitude(): number | null {
        return this.Get('Longitude');
    }
    set Longitude(value: number | null) {
        this.Set('Longitude', value);
    }

    /**
    * * Field Name: LocatorSource
    * * Display Name: Locator Source
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * nominatim
    *   * nominatim+overpass
    *   * overpass
    * * Description: Which store-locator source(s) found this store: overpass, nominatim, or both (nominatim+overpass).
    */
    get LocatorSource(): 'nominatim' | 'nominatim+overpass' | 'overpass' | null {
        return this.Get('LocatorSource');
    }
    set LocatorSource(value: 'nominatim' | 'nominatim+overpass' | 'overpass' | null) {
        this.Set('LocatorSource', value);
    }

    /**
    * * Field Name: MatchMethod
    * * Display Name: Match Method
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * exact addr
    *   * owner + city
    *   * street + near #
    *   * subset street + #
    * * Description: Which address-matching tier confirmed this store against a county assessor parcel -- see Big_Box_Retail/states/indiana/data/README.md for the methodology and how each tier was verified.
    */
    get MatchMethod(): 'exact addr' | 'owner + city' | 'street + near #' | 'subset street + #' | null {
        return this.Get('MatchMethod');
    }
    set MatchMethod(value: 'exact addr' | 'owner + city' | 'street + near #' | 'subset street + #' | null) {
        this.Set('MatchMethod', value);
    }

    /**
    * * Field Name: ParcelCount
    * * Display Name: Parcel Count
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Number of assessor parcels this store's building spans (a store is often 2-4 parcels: pad, parking, outlots).
    */
    get ParcelCount(): number {
        return this.Get('ParcelCount');
    }
    set ParcelCount(value: number) {
        this.Set('ParcelCount', value);
    }

    /**
    * * Field Name: Parcels
    * * Display Name: Parcels
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Delimited county:parcel;county:parcel... list of every matched assessor parcel, using DLGF county numbers.
    */
    get Parcels(): string | null {
        return this.Get('Parcels');
    }
    set Parcels(value: string | null) {
        this.Set('Parcels', value);
    }

    /**
    * * Field Name: TotalBuildingSqFt
    * * Display Name: Total Building Square Feet
    * * SQL Data Type: int
    * * Description: Sum of building square footage across this store's matched parcels.
    */
    get TotalBuildingSqFt(): number | null {
        return this.Get('TotalBuildingSqFt');
    }
    set TotalBuildingSqFt(value: number | null) {
        this.Set('TotalBuildingSqFt', value);
    }

    /**
    * * Field Name: MaxBuildingSqFt
    * * Display Name: Max Building Square Feet
    * * SQL Data Type: int
    * * Description: Max building square footage across this store's matched parcels.
    */
    get MaxBuildingSqFt(): number | null {
        return this.Get('MaxBuildingSqFt');
    }
    set MaxBuildingSqFt(value: number | null) {
        this.Set('MaxBuildingSqFt', value);
    }

    /**
    * * Field Name: TotalAssessedValue
    * * Display Name: Total Assessed Value
    * * SQL Data Type: money
    * * Description: Sum of total assessed value (land + improvement) across this store's matched parcels, in dollars.
    */
    get TotalAssessedValue(): number | null {
        return this.Get('TotalAssessedValue');
    }
    set TotalAssessedValue(value: number | null) {
        this.Set('TotalAssessedValue', value);
    }

    /**
    * * Field Name: Tenure
    * * Display Name: Tenure
    * * SQL Data Type: nvarchar(30)
    * * Value List Type: List
    * * Possible Values 
    *   * leased / investor
    *   * retailer-owned
    * * Description: Whether the matched parcel's owner is the retailer itself (retailer-owned) or a separate landlord/investor (leased / investor).
    */
    get Tenure(): 'leased / investor' | 'retailer-owned' | null {
        return this.Get('Tenure');
    }
    set Tenure(value: 'leased / investor' | 'retailer-owned' | null) {
        this.Set('Tenure', value);
    }

    /**
    * * Field Name: OwnerName
    * * Display Name: Owner Name
    * * SQL Data Type: nvarchar(200)
    * * Description: County assessor's owner-of-record name for the matched parcel(s).
    */
    get OwnerName(): string | null {
        return this.Get('OwnerName');
    }
    set OwnerName(value: string | null) {
        this.Set('OwnerName', value);
    }

    /**
    * * Field Name: AppealCount
    * * Display Name: Appeal Count
    * * SQL Data Type: int
    * * Default Value: 0
    * * Description: Number of PTABOA appeals on record for this store's matched parcel(s).
    */
    get AppealCount(): number {
        return this.Get('AppealCount');
    }
    set AppealCount(value: number) {
        this.Set('AppealCount', value);
    }

    /**
    * * Field Name: LastAppealYear
    * * Display Name: Last Appeal Year
    * * SQL Data Type: smallint
    * * Description: Most recent assessment year with an appeal on record, if any.
    */
    get LastAppealYear(): number | null {
        return this.Get('LastAppealYear');
    }
    set LastAppealYear(value: number | null) {
        this.Set('LastAppealYear', value);
    }

    /**
    * * Field Name: TaxReps
    * * Display Name: Tax Representatives
    * * SQL Data Type: nvarchar(300)
    * * Description: Tax representative(s) of record from the most recent appeal, if any.
    */
    get TaxReps(): string | null {
        return this.Get('TaxReps');
    }
    set TaxReps(value: string | null) {
        this.Set('TaxReps', value);
    }

    /**
    * * Field Name: SourceFile
    * * Display Name: Source File
    * * SQL Data Type: nvarchar(300)
    * * Description: Path/name of the CSV file this row was last imported from -- provenance for every row, per this project's documentation standard.
    */
    get SourceFile(): string {
        return this.Get('SourceFile');
    }
    set SourceFile(value: string) {
        this.Set('SourceFile', value);
    }

    /**
    * * Field Name: ImportedAt
    * * Display Name: Imported At
    * * SQL Data Type: datetimeoffset
    * * Description: When this row was last written by the importer script.
    */
    get ImportedAt(): Date {
        return this.Get('ImportedAt');
    }
    set ImportedAt(value: Date) {
        this.Set('ImportedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Mj Latitude
    * * SQL Data Type: decimal(9, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Mj Longitude
    * * SQL Data Type: decimal(9, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}


/**
 * Tax History Years - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: TaxHistoryYear
 * * Base View: vwTaxHistoryYears
 * * @description One row per (parcel, document-position) entry from a Tax History Report's multi-year assessment/tax-liability history -- both the current-year snapshot (ColumnOrdinal=0) and every historical column found in the "PRIOR TAX PAYMENT INFORMATION" table (ColumnOrdinal>=1, oldest columns have the highest ordinal). Stores every year the document has, not limited to any fixed lookback window -- "10 years" is a query-time convention for consumers, not a storage cutoff. GrossTax is deliberately NOT stored here -- confirmed across every document checked to exactly duplicate TaxRate under a different label, not a real dollar figure.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Tax History Years')
export class indianataxTaxHistoryYearEntity extends BaseEntity<indianataxTaxHistoryYearEntityType> {
    /**
    * Loads the Tax History Years record from the database
    * @param ID: string - primary key value to load the Tax History Years record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxTaxHistoryYearEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel this historical tax-year row belongs to.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: TaxHistorySourceDocumentID
    * * Display Name: Tax History Source Document ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    * * Description: The SourceDocument row for the Tax History Report PDF this row was parsed from.
    */
    get TaxHistorySourceDocumentID(): string {
        return this.Get('TaxHistorySourceDocumentID');
    }
    set TaxHistorySourceDocumentID(value: string) {
        this.Set('TaxHistorySourceDocumentID', value);
    }

    /**
    * * Field Name: TaxYear
    * * Display Name: Tax Year
    * * SQL Data Type: smallint
    * * Description: The tax year (payable year) this row reports on, per the document's own "Tax Year:" header for this column. NOT unique per parcel by itself -- see ColumnOrdinal.
    */
    get TaxYear(): number {
        return this.Get('TaxYear');
    }
    set TaxYear(value: number) {
        this.Set('TaxYear', value);
    }

    /**
    * * Field Name: ColumnOrdinal
    * * Display Name: Column Ordinal
    * * SQL Data Type: smallint
    * * Description: This row's position within the document: 0 = the current-year snapshot from the report's first-page section, 1 = the most recent column of the "PRIOR TAX PAYMENT INFORMATION" table, increasing with age. NOT derivable from TaxYear alone -- the year 2007 genuinely appears twice (Marion County's real 2007 statewide-reassessment-cycle transition, confirmed across every document checked) at two different ordinals; this is the real uniqueness key together with TaxYear, not a synthetic workaround.
    */
    get ColumnOrdinal(): number {
        return this.Get('ColumnOrdinal');
    }
    set ColumnOrdinal(value: number) {
        this.Set('ColumnOrdinal', value);
    }

    /**
    * * Field Name: LandAssessment
    * * Display Name: Land Assessment
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Land Assessment" figure for this tax year.
    */
    get LandAssessment(): number | null {
        return this.Get('LandAssessment');
    }
    set LandAssessment(value: number | null) {
        this.Set('LandAssessment', value);
    }

    /**
    * * Field Name: Improvements
    * * Display Name: Improvements
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Improvements" assessment figure for this tax year.
    */
    get Improvements(): number | null {
        return this.Get('Improvements');
    }
    set Improvements(value: number | null) {
        this.Set('Improvements', value);
    }

    /**
    * * Field Name: GrossAssessment
    * * Display Name: Gross Assessment
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Gross Assessment" figure for this tax year (Land + Improvements, before deductions/exemptions).
    */
    get GrossAssessment(): number | null {
        return this.Get('GrossAssessment');
    }
    set GrossAssessment(value: number | null) {
        this.Set('GrossAssessment', value);
    }

    /**
    * * Field Name: DeductionsExemptionsTotal
    * * Display Name: Deductions Exemptions Total
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Deductions/Exemptions" total applied for this tax year.
    */
    get DeductionsExemptionsTotal(): number | null {
        return this.Get('DeductionsExemptionsTotal');
    }
    set DeductionsExemptionsTotal(value: number | null) {
        this.Set('DeductionsExemptionsTotal', value);
    }

    /**
    * * Field Name: NetAssessment
    * * Display Name: Net Assessment
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Net Assessment" figure for this tax year (Gross Assessment less Deductions/Exemptions).
    */
    get NetAssessment(): number | null {
        return this.Get('NetAssessment');
    }
    set NetAssessment(value: number | null) {
        this.Set('NetAssessment', value);
    }

    /**
    * * Field Name: TaxRate
    * * Display Name: Tax Rate
    * * SQL Data Type: decimal(9, 6)
    * * Description: The "Tax Rate" for this tax year, per $100 of assessed value.
    */
    get TaxRate(): number | null {
        return this.Get('TaxRate');
    }
    set TaxRate(value: number | null) {
        this.Set('TaxRate', value);
    }

    /**
    * * Field Name: ReplacementCredit
    * * Display Name: Replacement Credit
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Replacement Credit" applied for this tax year.
    */
    get ReplacementCredit(): number | null {
        return this.Get('ReplacementCredit');
    }
    set ReplacementCredit(value: number | null) {
        this.Set('ReplacementCredit', value);
    }

    /**
    * * Field Name: HomesteadCredit
    * * Display Name: Homestead Credit
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Homestead Credit" applied for this tax year -- a single combined figure in the historical table (unlike the current-year section, which splits state/local homestead credit into separate fields).
    */
    get HomesteadCredit(): number | null {
        return this.Get('HomesteadCredit');
    }
    set HomesteadCredit(value: number | null) {
        this.Set('HomesteadCredit', value);
    }

    /**
    * * Field Name: NetAnnualTax
    * * Display Name: Net Annual Tax
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Net Annual Tax" liability for this tax year -- the reliable tax-liability figure for this row (see the table-level note on why GrossTax is not stored).
    */
    get NetAnnualTax(): number | null {
        return this.Get('NetAnnualTax');
    }
    set NetAnnualTax(value: number | null) {
        this.Set('NetAnnualTax', value);
    }

    /**
    * * Field Name: HalfYearTax
    * * Display Name: Half Year Tax
    * * SQL Data Type: decimal(14, 2)
    * * Description: The "Half Year Tax" figure for this tax year (Net Annual Tax split across the two semi-annual installments).
    */
    get HalfYearTax(): number | null {
        return this.Get('HalfYearTax');
    }
    set HalfYearTax(value: number | null) {
        this.Set('HalfYearTax', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Valuation Analysis - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ValuationAnalysis
 * * Base View: vwValuationAnalysis
 * * @description The per-parcel, per-year valuation workup: an indicated value under each approach, a reconciled Target Value, and a "should this be appealed?" recommendation with an estimated tax saving. Appeal-screening output, NOT a USPAP appraisal. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Valuation Analysis')
export class indianataxValuationAnalysisEntity extends BaseEntity<indianataxValuationAnalysisEntityType> {
    /**
    * Loads the Valuation Analysis record from the database
    * @param ID: string - primary key value to load the Valuation Analysis record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxValuationAnalysisEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * Validate() method override for Valuation Analysis entity. This is an auto-generated method that invokes the generated validators for this entity for the following fields:
    * * Table-Level: All financial valuation fields must contain non-negative values. Current Total Assessed Value, Reconciled Target Value, Estimated Tax Savings, and Lowest Supported Value cannot be negative, ensuring data integrity for property valuation calculations.
    * @public
    * @method
    * @override
    */
    public override Validate(): ValidationResult {
        const result = super.Validate();
        this.ValidateFinancialValuationsNonNegative(result);
        result.Success = result.Success && (result.Errors.length === 0);

        return result;
    }

    /**
    * All financial valuation fields must contain non-negative values. Current Total Assessed Value, Reconciled Target Value, Estimated Tax Savings, and Lowest Supported Value cannot be negative, ensuring data integrity for property valuation calculations.
    * @param result - the ValidationResult object to add any errors or warnings to
    * @public
    * @method
    */
    public ValidateFinancialValuationsNonNegative(result: ValidationResult) {
    	if (this.CurrentTotalAV != null && this.CurrentTotalAV < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"CurrentTotalAV",
    			"Current Total Assessed Value must be greater than or equal to zero.",
    			this.CurrentTotalAV,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.ReconciledTargetValue != null && this.ReconciledTargetValue < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"ReconciledTargetValue",
    			"Reconciled Target Value must be greater than or equal to zero.",
    			this.ReconciledTargetValue,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.EstimatedTaxSavings != null && this.EstimatedTaxSavings < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"EstimatedTaxSavings",
    			"Estimated Tax Savings must be greater than or equal to zero.",
    			this.EstimatedTaxSavings,
    			ValidationErrorType.Failure
    		));
    	}
    	if (this.LowestSupportedValue != null && this.LowestSupportedValue < 0) {
    		result.Errors.push(new ValidationErrorInfo(
    			"LowestSupportedValue",
    			"Lowest Supported Value must be greater than or equal to zero.",
    			this.LowestSupportedValue,
    			ValidationErrorType.Failure
    		));
    	}
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ParcelID
    * * Display Name: Parcel ID
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Parcels (vwParcels.ID)
    * * Description: The parcel analysed.
    */
    get ParcelID(): string {
        return this.Get('ParcelID');
    }
    set ParcelID(value: string) {
        this.Set('ParcelID', value);
    }

    /**
    * * Field Name: AssessmentYear
    * * Display Name: Assessment Year
    * * SQL Data Type: smallint
    * * Description: The assessment year the analysis is for.
    */
    get AssessmentYear(): number {
        return this.Get('AssessmentYear');
    }
    set AssessmentYear(value: number) {
        this.Set('AssessmentYear', value);
    }

    /**
    * * Field Name: MethodologyVersion
    * * Display Name: Methodology Version
    * * SQL Data Type: nvarchar(30)
    * * Description: Version tag for the methodology that produced this row (e.g. "sales-p25-2026-08-30"). Lets a re-run replace its own rows without touching an earlier method's.
    */
    get MethodologyVersion(): string {
        return this.Get('MethodologyVersion');
    }
    set MethodologyVersion(value: string) {
        this.Set('MethodologyVersion', value);
    }

    /**
    * * Field Name: PropertyTypeGroup
    * * Display Name: Property Type Group
    * * SQL Data Type: nvarchar(30)
    * * Description: Rolled-up property category used for comp grouping.
    */
    get PropertyTypeGroup(): string | null {
        return this.Get('PropertyTypeGroup');
    }
    set PropertyTypeGroup(value: string | null) {
        this.Set('PropertyTypeGroup', value);
    }

    /**
    * * Field Name: CurrentTotalAV
    * * Display Name: Current Total Assessed Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The county's current total assessed value the target is measured against.
    */
    get CurrentTotalAV(): number | null {
        return this.Get('CurrentTotalAV');
    }
    set CurrentTotalAV(value: number | null) {
        this.Set('CurrentTotalAV', value);
    }

    /**
    * * Field Name: SalesIndicatedValue
    * * Display Name: Sales Indicated Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Value indicated by the sales comparison approach.
    */
    get SalesIndicatedValue(): number | null {
        return this.Get('SalesIndicatedValue');
    }
    set SalesIndicatedValue(value: number | null) {
        this.Set('SalesIndicatedValue', value);
    }

    /**
    * * Field Name: SalesMethodNote
    * * Display Name: Sales Method Note
    * * SQL Data Type: nvarchar(400)
    * * Description: How the sales indication was derived (comp pool, unit metric, the point statistic used).
    */
    get SalesMethodNote(): string | null {
        return this.Get('SalesMethodNote');
    }
    set SalesMethodNote(value: string | null) {
        this.Set('SalesMethodNote', value);
    }

    /**
    * * Field Name: IncomeIndicatedValue
    * * Display Name: Income Indicated Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: Value indicated by the income capitalization approach (not yet populated).
    */
    get IncomeIndicatedValue(): number | null {
        return this.Get('IncomeIndicatedValue');
    }
    set IncomeIndicatedValue(value: number | null) {
        this.Set('IncomeIndicatedValue', value);
    }

    /**
    * * Field Name: IncomeMethodNote
    * * Display Name: Income Method Note
    * * SQL Data Type: nvarchar(400)
    * * Description: How the income indication was derived.
    */
    get IncomeMethodNote(): string | null {
        return this.Get('IncomeMethodNote');
    }
    set IncomeMethodNote(value: string | null) {
        this.Set('IncomeMethodNote', value);
    }

    /**
    * * Field Name: CostProxyValue
    * * Display Name: Cost Proxy Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The county's own mass-appraisal cost figure, surfaced as a proxy / sanity anchor ONLY -- the DLGF cost tables cannot be relied on by either party in a subjective valuation argument. Not yet populated.
    */
    get CostProxyValue(): number | null {
        return this.Get('CostProxyValue');
    }
    set CostProxyValue(value: number | null) {
        this.Set('CostProxyValue', value);
    }

    /**
    * * Field Name: CostProxyNote
    * * Display Name: Cost Proxy Note
    * * SQL Data Type: nvarchar(400)
    * * Description: Note on the cost proxy, including the caveat above.
    */
    get CostProxyNote(): string | null {
        return this.Get('CostProxyNote');
    }
    set CostProxyNote(value: string | null) {
        this.Set('CostProxyNote', value);
    }

    /**
    * * Field Name: ReconciledTargetValue
    * * Display Name: Reconciled Target Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The reconciled opinion of value -- the number an appeal would argue for.
    */
    get ReconciledTargetValue(): number | null {
        return this.Get('ReconciledTargetValue');
    }
    set ReconciledTargetValue(value: number | null) {
        this.Set('ReconciledTargetValue', value);
    }

    /**
    * * Field Name: TargetValuePerUnit
    * * Display Name: Target Value Per Unit
    * * SQL Data Type: decimal(14, 2)
    * * Description: ReconciledTargetValue / unit count.
    */
    get TargetValuePerUnit(): number | null {
        return this.Get('TargetValuePerUnit');
    }
    set TargetValuePerUnit(value: number | null) {
        this.Set('TargetValuePerUnit', value);
    }

    /**
    * * Field Name: TargetValuePerSqFt
    * * Display Name: Target Value Per Square Foot
    * * SQL Data Type: decimal(12, 2)
    * * Description: ReconciledTargetValue / building sq ft.
    */
    get TargetValuePerSqFt(): number | null {
        return this.Get('TargetValuePerSqFt');
    }
    set TargetValuePerSqFt(value: number | null) {
        this.Set('TargetValuePerSqFt', value);
    }

    /**
    * * Field Name: ControllingApproach
    * * Display Name: Controlling Approach
    * * SQL Data Type: nvarchar(16)
    * * Value List Type: List
    * * Possible Values 
    *   * CostProxy
    *   * Income
    *   * None
    *   * Sales
    * * Description: Which approach controlled the reconciliation: Sales / Income / CostProxy / Blended / None.
    */
    get ControllingApproach(): 'CostProxy' | 'Income' | 'None' | 'Sales' | null {
        return this.Get('ControllingApproach');
    }
    set ControllingApproach(value: 'CostProxy' | 'Income' | 'None' | 'Sales' | null) {
        this.Set('ControllingApproach', value);
    }

    /**
    * * Field Name: ReconciliationRationale
    * * Display Name: Reconciliation Rationale
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Narrative: why these approaches, why this weighting, why this point in the range.
    */
    get ReconciliationRationale(): string | null {
        return this.Get('ReconciliationRationale');
    }
    set ReconciliationRationale(value: string | null) {
        this.Set('ReconciliationRationale', value);
    }

    /**
    * * Field Name: MaterialityPct
    * * Display Name: Materiality Percentage
    * * SQL Data Type: decimal(7, 4)
    * * Description: (CurrentTotalAV - ReconciledTargetValue) / CurrentTotalAV -- how far below the assessment the target sits.
    */
    get MaterialityPct(): number | null {
        return this.Get('MaterialityPct');
    }
    set MaterialityPct(value: number | null) {
        this.Set('MaterialityPct', value);
    }

    /**
    * * Field Name: MaterialityThreshold
    * * Display Name: Materiality Threshold
    * * SQL Data Type: decimal(7, 4)
    * * Default Value: 0.05
    * * Description: The reduction fraction below which an appeal is not worth pursuing (default 5%).
    */
    get MaterialityThreshold(): number {
        return this.Get('MaterialityThreshold');
    }
    set MaterialityThreshold(value: number) {
        this.Set('MaterialityThreshold', value);
    }

    /**
    * * Field Name: AppliedTaxRate
    * * Display Name: Applied Tax Rate
    * * SQL Data Type: decimal(8, 6)
    * * Description: The tax rate applied to convert an AV reduction into a dollar saving (from CountyAssessorRecord.TaxRate as a percent, or a default). 
    */
    get AppliedTaxRate(): number | null {
        return this.Get('AppliedTaxRate');
    }
    set AppliedTaxRate(value: number | null) {
        this.Set('AppliedTaxRate', value);
    }

    /**
    * * Field Name: EstimatedTaxSavings
    * * Display Name: Estimated Tax Savings
    * * SQL Data Type: decimal(14, 2)
    * * Description: (CurrentTotalAV - ReconciledTargetValue) x AppliedTaxRate -- the estimated annual tax saving if the target is achieved.
    */
    get EstimatedTaxSavings(): number | null {
        return this.Get('EstimatedTaxSavings');
    }
    set EstimatedTaxSavings(value: number | null) {
        this.Set('EstimatedTaxSavings', value);
    }

    /**
    * * Field Name: Recommendation
    * * Display Name: Recommendation
    * * SQL Data Type: nvarchar(12)
    * * Value List Type: List
    * * Possible Values 
    *   * Appeal
    *   * Monitor
    *   * No Appeal
    * * Description: Appeal / No Appeal / Monitor. "Monitor" = a signal exists but the comp support is thin or the indication is implausibly far from the AV (needs a human look).
    */
    get Recommendation(): 'Appeal' | 'Monitor' | 'No Appeal' | null {
        return this.Get('Recommendation');
    }
    set Recommendation(value: 'Appeal' | 'Monitor' | 'No Appeal' | null) {
        this.Set('Recommendation', value);
    }

    /**
    * * Field Name: ConfidenceTier
    * * Display Name: Confidence Tier
    * * SQL Data Type: nvarchar(8)
    * * Value List Type: List
    * * Possible Values 
    *   * High
    *   * Low
    *   * Medium
    * * Description: High / Medium / Low. High requires a solid comp cluster, a PRC-sourced size, and an indication within a sane band of the AV.
    */
    get ConfidenceTier(): 'High' | 'Low' | 'Medium' | null {
        return this.Get('ConfidenceTier');
    }
    set ConfidenceTier(value: 'High' | 'Low' | 'Medium' | null) {
        this.Set('ConfidenceTier', value);
    }

    /**
    * * Field Name: CompCount
    * * Display Name: Comparable Count
    * * SQL Data Type: int
    * * Description: Number of comparable sales behind the sales indication.
    */
    get CompCount(): number | null {
        return this.Get('CompCount');
    }
    set CompCount(value: number | null) {
        this.Set('CompCount', value);
    }

    /**
    * * Field Name: AnalystNote
    * * Display Name: Analyst Note
    * * SQL Data Type: nvarchar(MAX)
    * * Description: Free-text analyst / agent notes.
    */
    get AnalystNote(): string | null {
        return this.Get('AnalystNote');
    }
    set AnalystNote(value: string | null) {
        this.Set('AnalystNote', value);
    }

    /**
    * * Field Name: GeneratedAt
    * * Display Name: Generated At
    * * SQL Data Type: datetimeoffset
    * * Description: When this analysis row was generated.
    */
    get GeneratedAt(): Date | null {
        return this.Get('GeneratedAt');
    }
    set GeneratedAt(value: Date | null) {
        this.Set('GeneratedAt', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: LowestSupportedValue
    * * Display Name: Lowest Supported Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: The aggressive floor -- MIN of the approach indications (Sales / Income / CostProxy) that fall within the sanity band [0.5, 1.2] x current AV. The lowest credible opinion of value.
    */
    get LowestSupportedValue(): number | null {
        return this.Get('LowestSupportedValue');
    }
    set LowestSupportedValue(value: number | null) {
        this.Set('LowestSupportedValue', value);
    }

    /**
    * * Field Name: SupportingApproachCount
    * * Display Name: Supporting Approach Count
    * * SQL Data Type: tinyint
    * * Description: How many approaches independently indicate a value below the current AV (and in band). >= 2 means redundant support for a reduction -- the recommended ask is then pitched at the higher of the low values.
    */
    get SupportingApproachCount(): number | null {
        return this.Get('SupportingApproachCount');
    }
    set SupportingApproachCount(value: number | null) {
        this.Set('SupportingApproachCount', value);
    }

    /**
    * * Field Name: MaxEstimatedTaxSavings
    * * Display Name: Max Estimated Tax Savings
    * * SQL Data Type: decimal(14, 2)
    * * Description: Estimated annual tax saving if LowestSupportedValue is achieved. EstimatedTaxSavings is the saving at the recommended ask (ReconciledTargetValue); this is the saving at the floor.
    */
    get MaxEstimatedTaxSavings(): number | null {
        return this.Get('MaxEstimatedTaxSavings');
    }
    set MaxEstimatedTaxSavings(value: number | null) {
        this.Set('MaxEstimatedTaxSavings', value);
    }

    /**
    * * Field Name: Parcel
    * * Display Name: Parcel
    * * SQL Data Type: nvarchar(30)
    */
    get Parcel(): string {
        return this.Get('Parcel');
    }
}


/**
 * Valuation Comps - strongly typed entity sub-class
 * * Schema: indiana_tax
 * * Base Table: ValuationComp
 * * Base View: vwValuationComps
 * * @description One row per sales comparable considered for a ValuationAnalysis subject (OPP-17 Stage 6). Each comp is adjusted to the subject on size (economies of scale), effective age, grade, and time-to-lien-date; caps net +/-25% / gross 50% (beyond -> DropReason). The median SubjectIndicatedValue over the selected cluster is the subject market-value (sales) indication; a P25-group fallback is used where < 3 comps survive. Built by scripts/build-valuation-comps.js.
 * * Primary Key: ID
 * @extends {BaseEntity}
 * @class
 * @public
 */
@RegisterClass(BaseEntity, 'Valuation Comps')
export class indianataxValuationCompEntity extends BaseEntity<indianataxValuationCompEntityType> {
    /**
    * Loads the Valuation Comps record from the database
    * @param ID: string - primary key value to load the Valuation Comps record.
    * @param EntityRelationshipsToLoad - (optional) the relationships to load
    * @returns {Promise<boolean>} - true if successful, false otherwise
    * @public
    * @async
    * @memberof indianataxValuationCompEntity
    * @method
    * @override
    */
    public async Load(ID: string, EntityRelationshipsToLoad?: string[]) : Promise<boolean> {
        const compositeKey: CompositeKey = new CompositeKey();
        compositeKey.KeyValuePairs.push({ FieldName: 'ID', Value: ID });
        return await super.InnerLoad(compositeKey, EntityRelationshipsToLoad);
    }

    /**
    * * Field Name: ID
    * * Display Name: ID
    * * SQL Data Type: uniqueidentifier
    * * Default Value: newsequentialid()
    */
    get ID(): string {
        return this.Get('ID');
    }
    set ID(value: string) {
        this.Set('ID', value);
    }

    /**
    * * Field Name: ValuationAnalysisID
    * * Display Name: Valuation Analysis
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Valuation Analysis (vwValuationAnalysis.ID)
    */
    get ValuationAnalysisID(): string {
        return this.Get('ValuationAnalysisID');
    }
    set ValuationAnalysisID(value: string) {
        this.Set('ValuationAnalysisID', value);
    }

    /**
    * * Field Name: SaleTransactionID
    * * Display Name: Sale Transaction
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Sale Transactions (vwSaleTransactions.ID)
    */
    get SaleTransactionID(): string | null {
        return this.Get('SaleTransactionID');
    }
    set SaleTransactionID(value: string | null) {
        this.Set('SaleTransactionID', value);
    }

    /**
    * * Field Name: SourceDocumentID
    * * Display Name: Source Document
    * * SQL Data Type: uniqueidentifier
    * * Related Entity/Foreign Key: Source Documents (vwSourceDocuments.ID)
    */
    get SourceDocumentID(): string | null {
        return this.Get('SourceDocumentID');
    }
    set SourceDocumentID(value: string | null) {
        this.Set('SourceDocumentID', value);
    }

    /**
    * * Field Name: UnitOfComparison
    * * Display Name: Unit of Comparison
    * * SQL Data Type: nvarchar(10)
    * * Value List Type: List
    * * Possible Values 
    *   * $/SF
    *   * $/unit
    */
    get UnitOfComparison(): '$/SF' | '$/unit' {
        return this.Get('UnitOfComparison');
    }
    set UnitOfComparison(value: '$/SF' | '$/unit') {
        this.Set('UnitOfComparison', value);
    }

    /**
    * * Field Name: CompAddress
    * * Display Name: Comparable Address
    * * SQL Data Type: nvarchar(300)
    */
    get CompAddress(): string | null {
        return this.Get('CompAddress');
    }
    set CompAddress(value: string | null) {
        this.Set('CompAddress', value);
    }

    /**
    * * Field Name: CompSubmarket
    * * Display Name: Comparable Submarket
    * * SQL Data Type: nvarchar(80)
    */
    get CompSubmarket(): string | null {
        return this.Get('CompSubmarket');
    }
    set CompSubmarket(value: string | null) {
        this.Set('CompSubmarket', value);
    }

    /**
    * * Field Name: SaleDate
    * * Display Name: Sale Date
    * * SQL Data Type: date
    */
    get SaleDate(): Date | null {
        return this.Get('SaleDate');
    }
    set SaleDate(value: Date | null) {
        this.Set('SaleDate', value);
    }

    /**
    * * Field Name: SalePrice
    * * Display Name: Sale Price
    * * SQL Data Type: decimal(14, 2)
    */
    get SalePrice(): number | null {
        return this.Get('SalePrice');
    }
    set SalePrice(value: number | null) {
        this.Set('SalePrice', value);
    }

    /**
    * * Field Name: CompDenominator
    * * Display Name: Comparable Denominator
    * * SQL Data Type: decimal(14, 2)
    */
    get CompDenominator(): number | null {
        return this.Get('CompDenominator');
    }
    set CompDenominator(value: number | null) {
        this.Set('CompDenominator', value);
    }

    /**
    * * Field Name: CompYearBuilt
    * * Display Name: Year Built
    * * SQL Data Type: smallint
    */
    get CompYearBuilt(): number | null {
        return this.Get('CompYearBuilt');
    }
    set CompYearBuilt(value: number | null) {
        this.Set('CompYearBuilt', value);
    }

    /**
    * * Field Name: CompGradeOrdinal
    * * Display Name: Grade
    * * SQL Data Type: decimal(4, 2)
    */
    get CompGradeOrdinal(): number | null {
        return this.Get('CompGradeOrdinal');
    }
    set CompGradeOrdinal(value: number | null) {
        this.Set('CompGradeOrdinal', value);
    }

    /**
    * * Field Name: RawPerUnit
    * * Display Name: Raw Price Per Unit
    * * SQL Data Type: decimal(14, 2)
    */
    get RawPerUnit(): number | null {
        return this.Get('RawPerUnit');
    }
    set RawPerUnit(value: number | null) {
        this.Set('RawPerUnit', value);
    }

    /**
    * * Field Name: SizeAdjPct
    * * Display Name: Size Adjustment %
    * * SQL Data Type: decimal(6, 4)
    * * Description: Signed size adjustment (economies of scale): +0.10 x ln(compDenominator / subjectDenominator), clamped +/-15%. Positive raises the comp $/unit toward a smaller subject.
    */
    get SizeAdjPct(): number | null {
        return this.Get('SizeAdjPct');
    }
    set SizeAdjPct(value: number | null) {
        this.Set('SizeAdjPct', value);
    }

    /**
    * * Field Name: AgeAdjPct
    * * Display Name: Age Adjustment %
    * * SQL Data Type: decimal(6, 4)
    */
    get AgeAdjPct(): number | null {
        return this.Get('AgeAdjPct');
    }
    set AgeAdjPct(value: number | null) {
        this.Set('AgeAdjPct', value);
    }

    /**
    * * Field Name: GradeAdjPct
    * * Display Name: Grade Adjustment %
    * * SQL Data Type: decimal(6, 4)
    */
    get GradeAdjPct(): number | null {
        return this.Get('GradeAdjPct');
    }
    set GradeAdjPct(value: number | null) {
        this.Set('GradeAdjPct', value);
    }

    /**
    * * Field Name: TimeAdjPct
    * * Display Name: Time Adjustment %
    * * SQL Data Type: decimal(6, 4)
    * * Description: Signed time adjustment: annual CRE appreciation (3%) x years from sale date to the 1/1/2026 lien date, clamped [-5%, +30%].
    */
    get TimeAdjPct(): number | null {
        return this.Get('TimeAdjPct');
    }
    set TimeAdjPct(value: number | null) {
        this.Set('TimeAdjPct', value);
    }

    /**
    * * Field Name: NetAdjPct
    * * Display Name: Net Adjustment %
    * * SQL Data Type: decimal(6, 4)
    */
    get NetAdjPct(): number | null {
        return this.Get('NetAdjPct');
    }
    set NetAdjPct(value: number | null) {
        this.Set('NetAdjPct', value);
    }

    /**
    * * Field Name: GrossAdjPct
    * * Display Name: Gross Adjustment %
    * * SQL Data Type: decimal(6, 4)
    */
    get GrossAdjPct(): number | null {
        return this.Get('GrossAdjPct');
    }
    set GrossAdjPct(value: number | null) {
        this.Set('GrossAdjPct', value);
    }

    /**
    * * Field Name: AdjustedPerUnit
    * * Display Name: Adjusted Price Per Unit
    * * SQL Data Type: decimal(14, 2)
    */
    get AdjustedPerUnit(): number | null {
        return this.Get('AdjustedPerUnit');
    }
    set AdjustedPerUnit(value: number | null) {
        this.Set('AdjustedPerUnit', value);
    }

    /**
    * * Field Name: SubjectIndicatedValue
    * * Display Name: Subject Indicated Value
    * * SQL Data Type: decimal(14, 2)
    * * Description: AdjustedPerUnit x the subject's denominator (SF or units) -- this comp's indication of the subject's total value.
    */
    get SubjectIndicatedValue(): number | null {
        return this.Get('SubjectIndicatedValue');
    }
    set SubjectIndicatedValue(value: number | null) {
        this.Set('SubjectIndicatedValue', value);
    }

    /**
    * * Field Name: SimilarityRank
    * * Display Name: Similarity Rank
    * * SQL Data Type: int
    */
    get SimilarityRank(): number | null {
        return this.Get('SimilarityRank');
    }
    set SimilarityRank(value: number | null) {
        this.Set('SimilarityRank', value);
    }

    /**
    * * Field Name: IsSelected
    * * Display Name: Selected
    * * SQL Data Type: bit
    * * Default Value: 0
    */
    get IsSelected(): boolean {
        return this.Get('IsSelected');
    }
    set IsSelected(value: boolean) {
        this.Set('IsSelected', value);
    }

    /**
    * * Field Name: DropReason
    * * Display Name: Drop Reason
    * * SQL Data Type: nvarchar(40)
    */
    get DropReason(): string | null {
        return this.Get('DropReason');
    }
    set DropReason(value: string | null) {
        this.Set('DropReason', value);
    }

    /**
    * * Field Name: __mj_CreatedAt
    * * Display Name: Created At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_CreatedAt(): Date {
        return this.Get('__mj_CreatedAt');
    }

    /**
    * * Field Name: __mj_UpdatedAt
    * * Display Name: Updated At
    * * SQL Data Type: datetimeoffset
    * * Default Value: getutcdate()
    */
    get __mj_UpdatedAt(): Date {
        return this.Get('__mj_UpdatedAt');
    }

    /**
    * * Field Name: SaleTransaction
    * * Display Name: Sale Transaction
    * * SQL Data Type: nvarchar(200)
    */
    get SaleTransaction(): string | null {
        return this.Get('SaleTransaction');
    }

    /**
    * * Field Name: __mj_Latitude
    * * Display Name: Mj Latitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Latitude(): number | null {
        return this.Get('__mj_Latitude');
    }

    /**
    * * Field Name: __mj_Longitude
    * * Display Name: Mj Longitude
    * * SQL Data Type: decimal(10, 6)
    */
    get __mj_Longitude(): number | null {
        return this.Get('__mj_Longitude');
    }
}
