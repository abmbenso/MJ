/********************************************************************************
* ALL ENTITIES - TypeGraphQL Type Class Definition - AUTO GENERATED FILE
* Generated Entities and Resolvers for Server
*
*   >>> DO NOT MODIFY THIS FILE!!!!!!!!!!!!
*   >>> YOUR CHANGES WILL BE OVERWRITTEN
*   >>> THE NEXT TIME THIS FILE IS GENERATED
*
**********************************************************************************/
import { Arg, Ctx, Int, Query, Resolver, Field, Float, ObjectType, FieldResolver, Root, InputType, Mutation,
            PubSub, PubSubEngine, ResolverBase, RunViewByIDInput, RunViewByNameInput, RunDynamicViewInput,
            AppContext, KeyValuePairInput, DeleteOptionsInput, GraphQLTimestamp as Timestamp,
            GetReadOnlyProvider, GetReadWriteProvider, RestoreContextInput } from '@memberjunction/server';
import { Metadata, EntityPermissionType, CompositeKey, UserInfo } from '@memberjunction/core'

import { MaxLength } from 'class-validator';
import * as mj_core_schema_server_object_types from '@memberjunction/server'


import { indianataxAppealLeadEntity, indianataxAppealStagePlaybookNoteEntity, indianataxAppealStageStatuteEntity, indianataxAppealStageEntity, indianataxAssessmentEntity, indianataxBoardDecisionEntity, indianataxCoStarIncomeInputEntity, indianataxCoStarPropertyEntity, indianataxComparableAssessmentMemberEntity, indianataxComparableAssessmentSetEntity, indianataxCountyAssessorImprovementSegmentEntity, indianataxCountyAssessorImprovementEntity, indianataxCountyAssessorRecordEntity, indianataxCountyAssessorSaleHistoryEntity, indianataxCountyResourceEntity, indianataxDLGFBuildingDetailEntity, indianataxDLGFBuildingEntity, indianataxDLGFImprovementEntity, indianataxDLGFLandEntity, indianataxDocumentAcquisitionEntity, indianataxDocumentCatalogEntity, indianataxFormCatalogEntity, indianataxJurisdictionDeadlineAnchorEntity, indianataxMarketAssumptionEntity, indianataxOwnerPortfolioParcelEntity, indianataxOwnerPortfolioRunEntity, indianataxOwnerPortfolioEntity, indianataxParcelEntity, indianataxPropertyClassMapEntity, indianataxProspectActivityEntity, indianataxProspectContactEntity, indianataxProspectParcelEntity, indianataxProspectSnapshotEntity, indianataxProspectTaskEntity, indianataxProspectEntity, indianataxPTABOAAppealEntity, indianataxResearchTaskEntity, indianataxSaleTransactionEntity, indianataxSourceDocumentEntity, indianataxSourceRegistryEntity, indianataxStatuteSectionEntity, indianataxTaxHistoryYearEntity, indianataxValuationAnalysisEntity, indianataxValuationCompEntity } from 'mj_generatedentities';
    

//****************************************************************************
// ENTITY CLASS for Appeal Leads
//****************************************************************************
@ObjectType({ description: `A scored appeal-candidate lead: a parcel flagged as likely over-assessed via peer-group improvement AV/sqft outlier detection, a year-over-year jump, and historical PTABOA win-rate by property class. Ranked by estimated dollar excess AV. Statistical screen, not a substitute for reviewing the flagged parcel. KNOWN GAP: current rows use total building sqft (including garage space) in the comparison -- see MethodologyVersion and the corresponding ResearchTask.` })
export class indianataxAppealLead_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel this lead concerns.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field(() => Int, {nullable: true, description: `Rank by EstimatedExcessAV within this scoring pass (1 = highest estimated excess). No minimum case-size floor -- rank order matters more than a cutoff.`}) 
    Rank?: number;
        
    @Field(() => Float, {nullable: true}) 
    CurrentLandAV?: number;
        
    @Field(() => Float, {nullable: true}) 
    CurrentImprovementAV?: number;
        
    @Field(() => Float, {nullable: true}) 
    CurrentTotalAV?: number;
        
    @Field(() => Float, {nullable: true}) 
    PriorTotalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Year-over-year percent change in total AV (current vs. prior source pull).`}) 
    YoyPctChange?: number;
        
    @Field(() => Boolean, {nullable: true, description: `Flagged when YoyPctChange met or exceeded the jump threshold (15% in the original methodology) -- a second, independent trigger from the peer-group comparison.`}) 
    YoyJumpFlag?: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    Grade?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    ConditionCode?: string;
        
    @Field(() => Int, {nullable: true}) 
    YearConstructed?: number;
        
    @Field(() => Int, {nullable: true}) 
    EffectiveConstructionYear?: number;
        
    @Field(() => Float, {nullable: true, description: `Total building square footage summed across all building rows for the parcel (source: building.total_square_foot_area). Includes garage space -- kept as a sanity-check total, not the basis for a corrected per-sqft comparison. See GarageSqFt.`}) 
    BuildingSqFt?: number;
        
    @Field(() => Float, {nullable: true, description: `Square footage identified as commercial garage space (source: building_detail rows where use_code = 'COMGAR'), so it can be excluded or separately weighted in a corrected improvement-AV-per-sqft comparison. NULL where not yet computed for this parcel, not necessarily zero.`}) 
    GarageSqFt?: number;
        
    @Field(() => Boolean, {nullable: true, description: `Whether any COMGAR (commercial garage) square footage was found for this parcel.`}) 
    HasGarage?: boolean;
        
    @Field(() => Float, {nullable: true, description: `This parcel's improvement AV divided by TOTAL building sqft (including garage space) -- the metric actually used to rank this scoring pass. See the table-level note on the known garage-weighting gap.`}) 
    ImprovementAVPerSqFt?: number;
        
    @Field(() => Float, {nullable: true, description: `Median ImprovementAVPerSqFt within this parcel's peer group (property class + grade, falling back to class alone when the group is too thin).`}) 
    PeerMedianImprovementAVPerSqFt?: number;
        
    @Field({nullable: true, description: `How the peer comparison group was defined for this parcel (e.g. "class+grade", or a coarser fallback like "class only (class+grade too thin)" when the class+grade bucket had too few peers). Widened to NVARCHAR(50) after the original NVARCHAR(20) proved too small for the fallback-description strings the methodology actually produces.`}) 
    @MaxLength(50)
    PeerGroupBasis?: string;
        
    @Field(() => Int, {nullable: true}) 
    PeerGroupSize?: number;
        
    @Field(() => Float, {nullable: true, description: `This parcel's ImprovementAVPerSqFt divided by its peer group's median -- the core outlier-detection ratio driving the rank.`}) 
    ExcessRatio?: number;
        
    @Field(() => Float, {nullable: true, description: `Estimated dollar excess assessed value implied by ExcessRatio -- what the ranking is sorted by.`}) 
    EstimatedExcessAV?: number;
        
    @Field(() => Int, {nullable: true, description: `Count of historical real-property (non-BPP) PTABOA appeals for this parcel's property class that resolve to a parcel in this database's scope -- a directional signal, not a precise win rate (covers a minority of all real-property appeals filed).`}) 
    PeerAppealCount?: number;
        
    @Field(() => Int, {nullable: true, description: `Of PeerAppealCount, how many resulted in a reduction.`}) 
    PeerAppealWins?: number;
        
    @Field(() => Float, {nullable: true, description: `PeerAppealWins / PeerAppealCount for this property class.`}) 
    PeerWinRate?: number;
        
    @Field(() => Float, {nullable: true, description: `Average percent reduction among winning appeals for this property class.`}) 
    PeerAvgPctReduction?: number;
        
    @Field(() => Boolean, {nullable: true, description: `Owner's mailing address differs from the property address -- a lead-qualification signal, not a data-quality flag.`}) 
    AbsenteeOwnerFlag?: boolean;
        
    @Field(() => Boolean, {nullable: true, description: `Owner's mailing address is outside the property's city.`}) 
    OutOfCityOwnerFlag?: boolean;
        
    @Field({description: `Which scoring methodology pass produced this row (e.g. "v1-total-sqft-2026"). Exists specifically so a future corrected pass (garage-adjusted comparison) is distinguishable from this one rather than silently overwriting/mixing with it.`}) 
    @MaxLength(30)
    MethodologyVersion: string;
        
    @Field({description: `When this scoring pass was run.`}) 
    GeneratedAt: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Appeal Leads
//****************************************************************************
@InputType()
export class CreateindianataxAppealLeadInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    Rank: number | null;

    @Field(() => Float, { nullable: true })
    CurrentLandAV: number | null;

    @Field(() => Float, { nullable: true })
    CurrentImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    CurrentTotalAV: number | null;

    @Field(() => Float, { nullable: true })
    PriorTotalAV: number | null;

    @Field(() => Float, { nullable: true })
    YoyPctChange: number | null;

    @Field(() => Boolean, { nullable: true })
    YoyJumpFlag: boolean | null;

    @Field({ nullable: true })
    Grade: string | null;

    @Field({ nullable: true })
    ConditionCode: string | null;

    @Field(() => Int, { nullable: true })
    YearConstructed: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveConstructionYear: number | null;

    @Field(() => Float, { nullable: true })
    BuildingSqFt: number | null;

    @Field(() => Float, { nullable: true })
    GarageSqFt: number | null;

    @Field(() => Boolean, { nullable: true })
    HasGarage: boolean | null;

    @Field(() => Float, { nullable: true })
    ImprovementAVPerSqFt: number | null;

    @Field(() => Float, { nullable: true })
    PeerMedianImprovementAVPerSqFt: number | null;

    @Field({ nullable: true })
    PeerGroupBasis: string | null;

    @Field(() => Int, { nullable: true })
    PeerGroupSize: number | null;

    @Field(() => Float, { nullable: true })
    ExcessRatio: number | null;

    @Field(() => Float, { nullable: true })
    EstimatedExcessAV: number | null;

    @Field(() => Int, { nullable: true })
    PeerAppealCount: number | null;

    @Field(() => Int, { nullable: true })
    PeerAppealWins: number | null;

    @Field(() => Float, { nullable: true })
    PeerWinRate: number | null;

    @Field(() => Float, { nullable: true })
    PeerAvgPctReduction: number | null;

    @Field(() => Boolean, { nullable: true })
    AbsenteeOwnerFlag: boolean | null;

    @Field(() => Boolean, { nullable: true })
    OutOfCityOwnerFlag: boolean | null;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    GeneratedAt?: Date;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Appeal Leads
//****************************************************************************
@InputType()
export class UpdateindianataxAppealLeadInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    Rank?: number | null;

    @Field(() => Float, { nullable: true })
    CurrentLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    CurrentImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    CurrentTotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    PriorTotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    YoyPctChange?: number | null;

    @Field(() => Boolean, { nullable: true })
    YoyJumpFlag?: boolean | null;

    @Field({ nullable: true })
    Grade?: string | null;

    @Field({ nullable: true })
    ConditionCode?: string | null;

    @Field(() => Int, { nullable: true })
    YearConstructed?: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveConstructionYear?: number | null;

    @Field(() => Float, { nullable: true })
    BuildingSqFt?: number | null;

    @Field(() => Float, { nullable: true })
    GarageSqFt?: number | null;

    @Field(() => Boolean, { nullable: true })
    HasGarage?: boolean | null;

    @Field(() => Float, { nullable: true })
    ImprovementAVPerSqFt?: number | null;

    @Field(() => Float, { nullable: true })
    PeerMedianImprovementAVPerSqFt?: number | null;

    @Field({ nullable: true })
    PeerGroupBasis?: string | null;

    @Field(() => Int, { nullable: true })
    PeerGroupSize?: number | null;

    @Field(() => Float, { nullable: true })
    ExcessRatio?: number | null;

    @Field(() => Float, { nullable: true })
    EstimatedExcessAV?: number | null;

    @Field(() => Int, { nullable: true })
    PeerAppealCount?: number | null;

    @Field(() => Int, { nullable: true })
    PeerAppealWins?: number | null;

    @Field(() => Float, { nullable: true })
    PeerWinRate?: number | null;

    @Field(() => Float, { nullable: true })
    PeerAvgPctReduction?: number | null;

    @Field(() => Boolean, { nullable: true })
    AbsenteeOwnerFlag?: boolean | null;

    @Field(() => Boolean, { nullable: true })
    OutOfCityOwnerFlag?: boolean | null;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    GeneratedAt?: Date;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Appeal Leads
//****************************************************************************
@ObjectType()
export class RunindianataxAppealLeadViewResult {
    @Field(() => [indianataxAppealLead_])
    Results: indianataxAppealLead_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxAppealLead_)
export class indianataxAppealLeadResolver extends ResolverBase {
    @Query(() => RunindianataxAppealLeadViewResult)
    async RunindianataxAppealLeadViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealLeadViewResult)
    async RunindianataxAppealLeadViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealLeadViewResult)
    async RunindianataxAppealLeadDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Appeal Leads';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxAppealLead_, { nullable: true })
    async indianataxAppealLead(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxAppealLead_ | null> {
        this.CheckUserReadPermissions('Appeal Leads', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealLeads')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Leads', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Appeal Leads', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxAppealLead_)
    async CreateindianataxAppealLead(
        @Arg('input', () => CreateindianataxAppealLeadInput) input: CreateindianataxAppealLeadInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Appeal Leads', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxAppealLead_)
    async UpdateindianataxAppealLead(
        @Arg('input', () => UpdateindianataxAppealLeadInput) input: UpdateindianataxAppealLeadInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Appeal Leads', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxAppealLead_)
    async DeleteindianataxAppealLead(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Appeal Leads', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Appeal Stage Playbook Notes
//****************************************************************************
@ObjectType({ description: `One tip / trap / deadline-nuance / strategy / local-practice item attached to an appeal stage. Replaces the single free-text AppealStage.Notes blob so each item is individually typed, cited, county-scopable and confidence-tagged. Design: Indiana_Tax_Expert/docs/proposals/appeal-playbook-structured.md.` })
export class indianataxAppealStagePlaybookNote_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The indiana_tax.AppealStage row this note belongs to.`}) 
    @MaxLength(36)
    AppealStageID: string;
        
    @Field({description: `Tip (use it to your advantage), Trap (a way to lose or forfeit), DeadlineNuance (a subtlety in when/how a clock runs), Strategy (a lever worth pulling), or LocalPractice (how a specific county actually operates, vs. the statewide rule).`}) 
    @MaxLength(20)
    NoteKind: string;
        
    @Field({description: `Short headline for the note.`}) 
    @MaxLength(200)
    Title: string;
        
    @Field({description: `The note itself.`}) 
    Body: string;
        
    @Field(() => Int, {nullable: true, description: `NULL = statewide note. A county number (49 = Marion) = the note applies only to that county, layered over the statewide stage.`}) 
    CountyNumber?: number;
        
    @Field({nullable: true, description: `Link to the indiana_tax.StatuteSection this note rests on, when one exists in the table.`}) 
    @MaxLength(36)
    StatuteSectionID?: string;
        
    @Field({nullable: true, description: `Free-text citation for when there is no StatuteSection row (e.g. "State Form 53958 instructions", "IC 6-1.1-15-1.2(k)").`}) 
    @MaxLength(100)
    CitationText?: string;
        
    @Field({nullable: true, description: `Optional supporting SourceDocument (a form, a memo, a decision).`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({description: `Verified (grounded in a primary source) or NeedsVerification (an inference from observed data -- e.g. Marion PTABOA cadence read off loaded PTABOAAppeal rows -- not yet checked against a primary source). Per the project data-integrity rule, local-practice notes sourced from data start as NeedsVerification.`}) 
    @MaxLength(20)
    Confidence: string;
        
    @Field(() => Int, {description: `Display order within a stage.`}) 
    SortOrder: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(200)
    AppealStage: string;
        
}

//****************************************************************************
// INPUT TYPE for Appeal Stage Playbook Notes
//****************************************************************************
@InputType()
export class CreateindianataxAppealStagePlaybookNoteInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    AppealStageID?: string;

    @Field({ nullable: true })
    NoteKind?: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    Body?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber: number | null;

    @Field({ nullable: true })
    StatuteSectionID: string | null;

    @Field({ nullable: true })
    CitationText: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    Confidence?: string;

    @Field(() => Int, { nullable: true })
    SortOrder?: number;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Appeal Stage Playbook Notes
//****************************************************************************
@InputType()
export class UpdateindianataxAppealStagePlaybookNoteInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    AppealStageID?: string;

    @Field({ nullable: true })
    NoteKind?: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    Body?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number | null;

    @Field({ nullable: true })
    StatuteSectionID?: string | null;

    @Field({ nullable: true })
    CitationText?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    Confidence?: string;

    @Field(() => Int, { nullable: true })
    SortOrder?: number;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Appeal Stage Playbook Notes
//****************************************************************************
@ObjectType()
export class RunindianataxAppealStagePlaybookNoteViewResult {
    @Field(() => [indianataxAppealStagePlaybookNote_])
    Results: indianataxAppealStagePlaybookNote_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxAppealStagePlaybookNote_)
export class indianataxAppealStagePlaybookNoteResolver extends ResolverBase {
    @Query(() => RunindianataxAppealStagePlaybookNoteViewResult)
    async RunindianataxAppealStagePlaybookNoteViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStagePlaybookNoteViewResult)
    async RunindianataxAppealStagePlaybookNoteViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStagePlaybookNoteViewResult)
    async RunindianataxAppealStagePlaybookNoteDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Appeal Stage Playbook Notes';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxAppealStagePlaybookNote_, { nullable: true })
    async indianataxAppealStagePlaybookNote(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxAppealStagePlaybookNote_ | null> {
        this.CheckUserReadPermissions('Appeal Stage Playbook Notes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStagePlaybookNotes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Playbook Notes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Appeal Stage Playbook Notes', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxAppealStagePlaybookNote_)
    async CreateindianataxAppealStagePlaybookNote(
        @Arg('input', () => CreateindianataxAppealStagePlaybookNoteInput) input: CreateindianataxAppealStagePlaybookNoteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Appeal Stage Playbook Notes', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxAppealStagePlaybookNote_)
    async UpdateindianataxAppealStagePlaybookNote(
        @Arg('input', () => UpdateindianataxAppealStagePlaybookNoteInput) input: UpdateindianataxAppealStagePlaybookNoteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Appeal Stage Playbook Notes', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxAppealStagePlaybookNote_)
    async DeleteindianataxAppealStagePlaybookNote(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Appeal Stage Playbook Notes', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Appeal Stage Statutes
//****************************************************************************
@ObjectType({ description: `A statute citation governing an AppealStage. StatuteSectionID resolves when we\'ve ingested that section (Title 6 Articles 1.1/1.5); NULL when the citation is outside that scope (e.g. IC 33-26-6-7, Title 33). CitationText is always populated regardless, so the raw citation is never lost to a missing join.` })
export class indianataxAppealStageStatute_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The stage this citation governs.`}) 
    @MaxLength(36)
    AppealStageID: string;
        
    @Field({nullable: true, description: `The matching StatuteSection row, if the cited section is one we've ingested (Title 6 Articles 1.1/1.5 only).`}) 
    @MaxLength(36)
    StatuteSectionID?: string;
        
    @Field({description: `The citation exactly as written on the source document, e.g. "IC 6-1.1-15-1.2(d)-(g), (l)".`}) 
    @MaxLength(100)
    CitationText: string;
        
    @Field({nullable: true, description: `The specific subsection(s) cited within the section, e.g. "(d)-(g), (l)" — StatuteSection is section-granular, not subsection-granular, so this carries the finer reference the flowchart actually makes.`}) 
    @MaxLength(50)
    SubsectionReference?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(200)
    AppealStage: string;
        
}

//****************************************************************************
// INPUT TYPE for Appeal Stage Statutes
//****************************************************************************
@InputType()
export class CreateindianataxAppealStageStatuteInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    AppealStageID?: string;

    @Field({ nullable: true })
    StatuteSectionID: string | null;

    @Field({ nullable: true })
    CitationText?: string;

    @Field({ nullable: true })
    SubsectionReference: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Appeal Stage Statutes
//****************************************************************************
@InputType()
export class UpdateindianataxAppealStageStatuteInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    AppealStageID?: string;

    @Field({ nullable: true })
    StatuteSectionID?: string | null;

    @Field({ nullable: true })
    CitationText?: string;

    @Field({ nullable: true })
    SubsectionReference?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Appeal Stage Statutes
//****************************************************************************
@ObjectType()
export class RunindianataxAppealStageStatuteViewResult {
    @Field(() => [indianataxAppealStageStatute_])
    Results: indianataxAppealStageStatute_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxAppealStageStatute_)
export class indianataxAppealStageStatuteResolver extends ResolverBase {
    @Query(() => RunindianataxAppealStageStatuteViewResult)
    async RunindianataxAppealStageStatuteViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStageStatuteViewResult)
    async RunindianataxAppealStageStatuteViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStageStatuteViewResult)
    async RunindianataxAppealStageStatuteDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Appeal Stage Statutes';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxAppealStageStatute_, { nullable: true })
    async indianataxAppealStageStatute(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxAppealStageStatute_ | null> {
        this.CheckUserReadPermissions('Appeal Stage Statutes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStageStatutes')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Statutes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Appeal Stage Statutes', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxAppealStageStatute_)
    async CreateindianataxAppealStageStatute(
        @Arg('input', () => CreateindianataxAppealStageStatuteInput) input: CreateindianataxAppealStageStatuteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Appeal Stage Statutes', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxAppealStageStatute_)
    async UpdateindianataxAppealStageStatute(
        @Arg('input', () => UpdateindianataxAppealStageStatuteInput) input: UpdateindianataxAppealStageStatuteInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Appeal Stage Statutes', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxAppealStageStatute_)
    async DeleteindianataxAppealStageStatute(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Appeal Stage Statutes', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Appeal Stages
//****************************************************************************
@ObjectType({ description: `One stage in the Indiana real property tax appeal lifecycle (statewide standard procedure). Normalized from Form 130\'s "Procedure for Appeal of Assessment" instructions so the sequence, deadlines, and governing statutes are queryable rather than embedded in document text.` })
export class indianataxAppealStage_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field(() => Int, {description: `Sequence position in the normal-path appeal lifecycle (1 = first stage). Conditional escalation paths (e.g. skipping ahead if PTABOA misses its hearing deadline) are captured in Notes on the relevant stage, not as separate branching rows.`}) 
    StageOrder: number;
        
    @Field({description: `Short name for the stage.`}) 
    @MaxLength(200)
    StageName: string;
        
    @Field({description: `Where in the appeal hierarchy this stage sits: County-PTABOA (the initial, county-level appeal), State-IBTR (state board, afforded deference to its factual determinations), State-TaxCourt (reviews IBTR determinations), or State-SupremeCourt (discretionary review of Tax Court determinations).`}) 
    @MaxLength(30)
    AppealLevel: string;
        
    @Field({nullable: true, description: `Who acts at this stage (e.g. Taxpayer, Assessing Official, PTABOA, IBTR, Tax Court, Supreme Court).`}) 
    @MaxLength(50)
    ResponsibleParty?: string;
        
    @Field({description: `What happens at this stage.`}) 
    Description: string;
        
    @Field({nullable: true, description: `The DLGF form required to act at this stage, if any (e.g. Form 130, Form 134, Form 131).`}) 
    @MaxLength(50)
    FormRequired?: string;
        
    @Field({nullable: true, description: `Full deadline rule in prose — often conditional (varies by mailing date, property type, etc.), which is why this is text rather than only a day count.`}) 
    DeadlineDescription?: string;
        
    @Field(() => Int, {nullable: true, description: `A single day-count figure when the deadline reduces to one cleanly (e.g. 45, 180, 90) — NULL when the real rule is conditional and a single number would be misleading; see DeadlineDescription for the full rule either way.`}) 
    DeadlineDays?: number;
        
    @Field(() => Int, {nullable: true, description: `NULL = statewide standard procedure (every row populated so far). Reserved for a future county-specific variant of this stage, since local practice can differ by county — a county override would be its own row with this set, not an edit to the statewide row.`}) 
    CountyNumber?: number;
        
    @Field({nullable: true, description: `The document this stage was extracted from (e.g. Form 130's instructions).`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true, description: `Free-text notes — standard of review, burden of proof, escalation conditions, or other context that doesn't fit a structured column.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The real-world date that starts this stage's clock: Form11MailDate, PersonalPropertyNoticeDate, AppealFilingDate (Form 130 filed), PTABOAOrderDate (PTABOA order given to the parties), IBTRFinalDeterminationDate, or TaxCourtDeterminationDate. NULL = no fixed statutory deadline runs to the taxpayer at this stage (the assessing official's / IBTR's own timeline governs).`}) 
    @MaxLength(40)
    DeadlineAnchorEvent?: string;
        
    @Field({nullable: true, description: `How the deadline derives from DeadlineAnchorEvent: RelativeDays = anchor + DeadlineDays (45 / 90 / 180 ...); CalendarRule = the named rule in DeadlineCalendarRule; Discretionary = no hard deadline (e.g. Supreme Court review).`}) 
    @MaxLength(20)
    DeadlineBasis?: string;
        
    @Field({nullable: true, description: `Stable token a rule engine switches on when DeadlineBasis = 'CalendarRule'. Stage 1 = 'IN-Form130-June15-split-May1': if Form11MailDate < May 1 of the assessment year the Form 130 is due June 15 of that year, else June 15 of the year tax statements are mailed (the pay year). One rule per token; the token is documented, the logic lives in code.`}) 
    @MaxLength(60)
    DeadlineCalendarRule?: string;
        
    @Field(() => Boolean, {description: `TRUE where, in addition to the primary deadline, the statute lets the taxpayer act "any time after the agency's own deadline lapses": Stage 3 (PTABOA misses its 180-day hearing window -> straight to IBTR) and Stage 6 (Tax Court petition may be filed once IBTR's own decision deadline passes).`}) 
    DeadlineHasAgencyLapseAlt: boolean;
        
    @Field({nullable: true, description: `Whether this stage's informal step is mandatory: Required / Optional / Recommended / NotOffered. Indiana Stage 2 (Preliminary Informal Meeting) = Required -- filing Form 130 obligates the assessing official to hold it. Other jurisdictions vary (the Faegre Appeal Deadline Tracking workbook tracks this per state).`}) 
    @MaxLength(20)
    InformalMeetingRequirement?: string;
        
    @Field(() => Boolean, {nullable: true, description: `TRUE only where the taxpayer must attach/submit substantive evidence AT filing to avoid rejection (e.g. AZ). Indiana Stage 1 = FALSE -- no evidence required at filing, but the exchange of available information IS required at the preliminary informal meeting (see the corresponding playbook note).`}) 
    EvidenceRequiredAtFiling?: boolean;
        
    @Field({nullable: true, description: `Free text for the informal step's own deadline where one exists separately from DeadlineDays / DeadlineCalendarRule (MO, CO). Indiana = NULL: the preliminary informal meeting is auto-triggered by the Form 130 filing with no separate taxpayer date to hit.`}) 
    @MaxLength(300)
    InformalDeadlineDescription?: string;
        
    @Field(() => [indianataxAppealStageStatute_])
    indianataxAppealStageStatutes_AppealStageIDArray: indianataxAppealStageStatute_[]; // Link to indianataxAppealStageStatutes
    
    @Field(() => [indianataxFormCatalog_])
    indianataxFormCatalogs_CorrespondingAppealStageIDArray: indianataxFormCatalog_[]; // Link to indianataxFormCatalogs
    
    @Field(() => [indianataxFormCatalog_])
    indianataxFormCatalogs_TriggersAppealStageIDArray: indianataxFormCatalog_[]; // Link to indianataxFormCatalogs
    
    @Field(() => [indianataxAppealStagePlaybookNote_])
    indianataxAppealStagePlaybookNotes_AppealStageIDArray: indianataxAppealStagePlaybookNote_[]; // Link to indianataxAppealStagePlaybookNotes
    
}

//****************************************************************************
// INPUT TYPE for Appeal Stages
//****************************************************************************
@InputType()
export class CreateindianataxAppealStageInput {
    @Field({ nullable: true })
    ID?: string;

    @Field(() => Int, { nullable: true })
    StageOrder?: number;

    @Field({ nullable: true })
    StageName?: string;

    @Field({ nullable: true })
    AppealLevel?: string;

    @Field({ nullable: true })
    ResponsibleParty: string | null;

    @Field({ nullable: true })
    Description?: string;

    @Field({ nullable: true })
    FormRequired: string | null;

    @Field({ nullable: true })
    DeadlineDescription: string | null;

    @Field(() => Int, { nullable: true })
    DeadlineDays: number | null;

    @Field(() => Int, { nullable: true })
    CountyNumber: number | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field({ nullable: true })
    DeadlineAnchorEvent: string | null;

    @Field({ nullable: true })
    DeadlineBasis: string | null;

    @Field({ nullable: true })
    DeadlineCalendarRule: string | null;

    @Field(() => Boolean, { nullable: true })
    DeadlineHasAgencyLapseAlt?: boolean;

    @Field({ nullable: true })
    InformalMeetingRequirement: string | null;

    @Field(() => Boolean, { nullable: true })
    EvidenceRequiredAtFiling: boolean | null;

    @Field({ nullable: true })
    InformalDeadlineDescription: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Appeal Stages
//****************************************************************************
@InputType()
export class UpdateindianataxAppealStageInput {
    @Field()
    ID: string;

    @Field(() => Int, { nullable: true })
    StageOrder?: number;

    @Field({ nullable: true })
    StageName?: string;

    @Field({ nullable: true })
    AppealLevel?: string;

    @Field({ nullable: true })
    ResponsibleParty?: string | null;

    @Field({ nullable: true })
    Description?: string;

    @Field({ nullable: true })
    FormRequired?: string | null;

    @Field({ nullable: true })
    DeadlineDescription?: string | null;

    @Field(() => Int, { nullable: true })
    DeadlineDays?: number | null;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field({ nullable: true })
    DeadlineAnchorEvent?: string | null;

    @Field({ nullable: true })
    DeadlineBasis?: string | null;

    @Field({ nullable: true })
    DeadlineCalendarRule?: string | null;

    @Field(() => Boolean, { nullable: true })
    DeadlineHasAgencyLapseAlt?: boolean;

    @Field({ nullable: true })
    InformalMeetingRequirement?: string | null;

    @Field(() => Boolean, { nullable: true })
    EvidenceRequiredAtFiling?: boolean | null;

    @Field({ nullable: true })
    InformalDeadlineDescription?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Appeal Stages
//****************************************************************************
@ObjectType()
export class RunindianataxAppealStageViewResult {
    @Field(() => [indianataxAppealStage_])
    Results: indianataxAppealStage_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxAppealStage_)
export class indianataxAppealStageResolver extends ResolverBase {
    @Query(() => RunindianataxAppealStageViewResult)
    async RunindianataxAppealStageViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStageViewResult)
    async RunindianataxAppealStageViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAppealStageViewResult)
    async RunindianataxAppealStageDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Appeal Stages';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxAppealStage_, { nullable: true })
    async indianataxAppealStage(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxAppealStage_ | null> {
        this.CheckUserReadPermissions('Appeal Stages', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStages')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stages', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Appeal Stages', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxAppealStageStatute_])
    async indianataxAppealStageStatutes_AppealStageIDArray(@Root() indianataxappealstage_: indianataxAppealStage_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stage Statutes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStageStatutes')} WHERE ${provider.QuoteIdentifier('AppealStageID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Statutes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxappealstage_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stage Statutes', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxFormCatalog_])
    async indianataxFormCatalogs_CorrespondingAppealStageIDArray(@Root() indianataxappealstage_: indianataxAppealStage_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Form Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwFormCatalogs')} WHERE ${provider.QuoteIdentifier('CorrespondingAppealStageID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Form Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxappealstage_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Form Catalogs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxFormCatalog_])
    async indianataxFormCatalogs_TriggersAppealStageIDArray(@Root() indianataxappealstage_: indianataxAppealStage_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Form Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwFormCatalogs')} WHERE ${provider.QuoteIdentifier('TriggersAppealStageID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Form Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxappealstage_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Form Catalogs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAppealStagePlaybookNote_])
    async indianataxAppealStagePlaybookNotes_AppealStageIDArray(@Root() indianataxappealstage_: indianataxAppealStage_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stage Playbook Notes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStagePlaybookNotes')} WHERE ${provider.QuoteIdentifier('AppealStageID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Playbook Notes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxappealstage_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stage Playbook Notes', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxAppealStage_)
    async CreateindianataxAppealStage(
        @Arg('input', () => CreateindianataxAppealStageInput) input: CreateindianataxAppealStageInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Appeal Stages', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxAppealStage_)
    async UpdateindianataxAppealStage(
        @Arg('input', () => UpdateindianataxAppealStageInput) input: UpdateindianataxAppealStageInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Appeal Stages', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxAppealStage_)
    async DeleteindianataxAppealStage(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Appeal Stages', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Assessments
//****************************************************************************
@ObjectType({ description: `One row per (Parcel, AssessmentYear, Source) — the assessment-history table. Carries both the original assessed value and, once a PTABOA appeal is decided, the post-appeal value, so a single year can show both an original and an appealed determination.` })
export class indianataxAssessment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel this assessment belongs to.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field(() => Int, {description: `The assessment/payable year this row represents (Indiana assessments are dated January 1 of the assessment year).`}) 
    AssessmentYear: number;
        
    @Field({description: `Where this assessment row came from, e.g. dlgf_gdb_2025, marion_foia_2026. Identifies the data pull/vintage.`}) 
    @MaxLength(50)
    Source: string;
        
    @Field({nullable: true, description: `DLGF property class code as recorded for this specific assessment year (may differ from the parcel's current PropertyClassCode).`}) 
    @MaxLength(10)
    PropertyClassCode?: string;
        
    @Field(() => Float, {nullable: true, description: `Originally assessed land value for the year, before any appeal.`}) 
    OriginalLandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Originally assessed improvement value for the year, before any appeal.`}) 
    OriginalImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Originally assessed total value for the year (land + improvement), before any appeal.`}) 
    OriginalTotalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Land value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`}) 
    PTABOALandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Improvement value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`}) 
    PTABOAImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Total value after a PTABOA appeal determination. NULL until an appeal on this parcel/year is decided.`}) 
    PTABOATotalAV?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The specific SourceDocument this assessment row was extracted from (the DLGF geodatabase pull, the Marion FOIA parcel-list CSV, or the parcel's Property Record Card). The free-text \`Source\` column is the short provenance label; this is the traceable document.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Assessments
//****************************************************************************
@InputType()
export class CreateindianataxAssessmentInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    PropertyClassCode: string | null;

    @Field(() => Float, { nullable: true })
    OriginalLandAV: number | null;

    @Field(() => Float, { nullable: true })
    OriginalImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    OriginalTotalAV: number | null;

    @Field(() => Float, { nullable: true })
    PTABOALandAV: number | null;

    @Field(() => Float, { nullable: true })
    PTABOAImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    PTABOATotalAV: number | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Assessments
//****************************************************************************
@InputType()
export class UpdateindianataxAssessmentInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    PropertyClassCode?: string | null;

    @Field(() => Float, { nullable: true })
    OriginalLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    OriginalImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    OriginalTotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    PTABOALandAV?: number | null;

    @Field(() => Float, { nullable: true })
    PTABOAImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    PTABOATotalAV?: number | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Assessments
//****************************************************************************
@ObjectType()
export class RunindianataxAssessmentViewResult {
    @Field(() => [indianataxAssessment_])
    Results: indianataxAssessment_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxAssessment_)
export class indianataxAssessmentResolver extends ResolverBase {
    @Query(() => RunindianataxAssessmentViewResult)
    async RunindianataxAssessmentViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAssessmentViewResult)
    async RunindianataxAssessmentViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxAssessmentViewResult)
    async RunindianataxAssessmentDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Assessments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxAssessment_, { nullable: true })
    async indianataxAssessment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxAssessment_ | null> {
        this.CheckUserReadPermissions('Assessments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAssessments')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Assessments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Assessments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxAssessment_)
    async CreateindianataxAssessment(
        @Arg('input', () => CreateindianataxAssessmentInput) input: CreateindianataxAssessmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Assessments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxAssessment_)
    async UpdateindianataxAssessment(
        @Arg('input', () => UpdateindianataxAssessmentInput) input: UpdateindianataxAssessmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Assessments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxAssessment_)
    async DeleteindianataxAssessment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Assessments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Board Decisions
//****************************************************************************
@ObjectType({ description: `A ruling from the Indiana Board of Tax Review (IBTR) — the state-level appeal that follows a county PTABOA determination. This is the precedent corpus the agent searches for similar prior appeals.` })
export class indianataxBoardDecision_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `IBTR case number.`}) 
    @MaxLength(50)
    CaseNumber: string;
        
    @Field({nullable: true, description: `Name of the petitioner (property owner who brought the appeal).`}) 
    @MaxLength(300)
    PetitionerName?: string;
        
    @Field(() => Int, {nullable: true, description: `County the case originated in.`}) 
    CountyNumber?: number;
        
    @Field({nullable: true, description: `The parcel this decision concerns, once matched. NULL until the case is reconciled to a known parcel.`}) 
    @MaxLength(36)
    ParcelID?: string;
        
    @Field({nullable: true, description: `Date the IBTR issued its final determination.`}) 
    DecisionDate?: Date;
        
    @Field({nullable: true, description: `Short summary of the case and outcome, for quick scanning without opening the full decision text.`}) 
    Summary?: string;
        
    @Field({nullable: true, description: `The decision PDF this row was extracted from.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `Free-text assessment year(s) this decision concerns, e.g. "2019, 2020, 2021" — a single IBTR case can span multiple years and even multiple parcels, so this isn't normalized to a single year column.`}) 
    @MaxLength(200)
    AssessmentYearsInvolved?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    Parcel?: string;
        
}

//****************************************************************************
// INPUT TYPE for Board Decisions
//****************************************************************************
@InputType()
export class CreateindianataxBoardDecisionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    CaseNumber?: string;

    @Field({ nullable: true })
    PetitionerName: string | null;

    @Field(() => Int, { nullable: true })
    CountyNumber: number | null;

    @Field({ nullable: true })
    ParcelID: string | null;

    @Field({ nullable: true })
    DecisionDate: Date | null;

    @Field({ nullable: true })
    Summary: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    AssessmentYearsInvolved: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Board Decisions
//****************************************************************************
@InputType()
export class UpdateindianataxBoardDecisionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    CaseNumber?: string;

    @Field({ nullable: true })
    PetitionerName?: string | null;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number | null;

    @Field({ nullable: true })
    ParcelID?: string | null;

    @Field({ nullable: true })
    DecisionDate?: Date | null;

    @Field({ nullable: true })
    Summary?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    AssessmentYearsInvolved?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Board Decisions
//****************************************************************************
@ObjectType()
export class RunindianataxBoardDecisionViewResult {
    @Field(() => [indianataxBoardDecision_])
    Results: indianataxBoardDecision_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxBoardDecision_)
export class indianataxBoardDecisionResolver extends ResolverBase {
    @Query(() => RunindianataxBoardDecisionViewResult)
    async RunindianataxBoardDecisionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxBoardDecisionViewResult)
    async RunindianataxBoardDecisionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxBoardDecisionViewResult)
    async RunindianataxBoardDecisionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Board Decisions';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxBoardDecision_, { nullable: true })
    async indianataxBoardDecision(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxBoardDecision_ | null> {
        this.CheckUserReadPermissions('Board Decisions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwBoardDecisions')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Board Decisions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Board Decisions', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxBoardDecision_)
    async CreateindianataxBoardDecision(
        @Arg('input', () => CreateindianataxBoardDecisionInput) input: CreateindianataxBoardDecisionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Board Decisions', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxBoardDecision_)
    async UpdateindianataxBoardDecision(
        @Arg('input', () => UpdateindianataxBoardDecisionInput) input: UpdateindianataxBoardDecisionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Board Decisions', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxBoardDecision_)
    async DeleteindianataxBoardDecision(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Board Decisions', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Co Star Income Inputs
//****************************************************************************
@ObjectType({ description: `One row per CoStar property-inventory record (from /Users/abebenson/Projects/CoStar_Data exports): direct rent / vacancy / concession / physical inputs for a pro-forma income approach. Distinct from CoStarProperty (CoStar *sales* exports). Design: Indiana_Tax_Expert/docs/proposals/income-approach-costar.md.` })
export class indianataxCoStarIncomeInput_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field(() => Int, {description: `CoStar's PropertyID for the record.`}) 
    CoStarPropertyID: number;
        
    @Field({nullable: true, description: `Resolved Parcel (matched on Parcel Number 1(Min)); NULL when off-book.`}) 
    @MaxLength(36)
    ParcelID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    ParcelNumberMin?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    ParcelNumberMax?: string;
        
    @Field(() => Boolean, {description: `Property spans more than one parcel (Min <> Max).`}) 
    MultiParcel: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    PropertyTypeGroup?: string;
        
    @Field({nullable: true}) 
    @MaxLength(60)
    CoStarPropertyType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(80)
    SecondaryType?: string;
        
    @Field({nullable: true}) 
    @MaxLength(80)
    Submarket?: string;
        
    @Field({nullable: true}) 
    @MaxLength(80)
    City?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    PropertyName?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    PropertyAddress?: string;
        
    @Field(() => Float, {nullable: true}) 
    StarRating?: number;
        
    @Field(() => Int, {nullable: true}) 
    YearBuilt?: number;
        
    @Field(() => Int, {nullable: true}) 
    YearRenovated?: number;
        
    @Field(() => Int, {nullable: true}) 
    Units?: number;
        
    @Field(() => Int, {nullable: true}) 
    RBA?: number;
        
    @Field(() => Int, {nullable: true}) 
    Rooms?: number;
        
    @Field(() => Int, {nullable: true}) 
    Beds?: number;
        
    @Field(() => Float, {nullable: true, description: `Average EFFECTIVE rent per unit, MONTHLY (net of concessions), as CoStar reports it. Annualise x 12 for the pro forma.`}) 
    AvgEffectiveRentPerUnit?: number;
        
    @Field(() => Float, {nullable: true}) 
    AvgAskingRentPerUnit?: number;
        
    @Field(() => Float, {nullable: true}) 
    AvgEffectiveRentPerSF?: number;
        
    @Field(() => Float, {nullable: true}) 
    AvgAskingRentPerSF?: number;
        
    @Field(() => Float, {nullable: true}) 
    ConcessionsPct?: number;
        
    @Field(() => Float, {nullable: true, description: `Vacancy percent (0-100) as reported by CoStar.`}) 
    VacancyPct?: number;
        
    @Field(() => Float, {nullable: true, description: `Percent leased (0-100); office/retail/industrial where vacancy is not reported.`}) 
    PercentLeased?: number;
        
    @Field(() => Float, {nullable: true}) 
    RentPerSFYrLow?: number;
        
    @Field(() => Float, {nullable: true}) 
    RentPerSFYrHigh?: number;
        
    @Field(() => Float, {nullable: true}) 
    AverageWeightedRent?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar cap rate where disclosed on the inventory record (rare -- usually NULL).`}) 
    CapRate?: number;
        
    @Field(() => Float, {nullable: true}) 
    TaxesTotal?: number;
        
    @Field(() => Float, {nullable: true}) 
    LastSalePrice?: number;
        
    @Field({nullable: true}) 
    LastSaleDate?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(120)
    SourceFile?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The CoStar export .xlsx this row was parsed from (SourceFile is the filename text). CoStar data is a labeled cross-check, not authority.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    Parcel?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
}

//****************************************************************************
// INPUT TYPE for Co Star Income Inputs
//****************************************************************************
@InputType()
export class CreateindianataxCoStarIncomeInputInput {
    @Field({ nullable: true })
    ID?: string;

    @Field(() => Int, { nullable: true })
    CoStarPropertyID?: number;

    @Field({ nullable: true })
    ParcelID: string | null;

    @Field({ nullable: true })
    ParcelNumberMin: string | null;

    @Field({ nullable: true })
    ParcelNumberMax: string | null;

    @Field(() => Boolean, { nullable: true })
    MultiParcel?: boolean;

    @Field({ nullable: true })
    PropertyTypeGroup: string | null;

    @Field({ nullable: true })
    CoStarPropertyType: string | null;

    @Field({ nullable: true })
    SecondaryType: string | null;

    @Field({ nullable: true })
    Submarket: string | null;

    @Field({ nullable: true })
    City: string | null;

    @Field({ nullable: true })
    PropertyName: string | null;

    @Field({ nullable: true })
    PropertyAddress: string | null;

    @Field(() => Float, { nullable: true })
    StarRating: number | null;

    @Field(() => Int, { nullable: true })
    YearBuilt: number | null;

    @Field(() => Int, { nullable: true })
    YearRenovated: number | null;

    @Field(() => Int, { nullable: true })
    Units: number | null;

    @Field(() => Int, { nullable: true })
    RBA: number | null;

    @Field(() => Int, { nullable: true })
    Rooms: number | null;

    @Field(() => Int, { nullable: true })
    Beds: number | null;

    @Field(() => Float, { nullable: true })
    AvgEffectiveRentPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    AvgAskingRentPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    AvgEffectiveRentPerSF: number | null;

    @Field(() => Float, { nullable: true })
    AvgAskingRentPerSF: number | null;

    @Field(() => Float, { nullable: true })
    ConcessionsPct: number | null;

    @Field(() => Float, { nullable: true })
    VacancyPct: number | null;

    @Field(() => Float, { nullable: true })
    PercentLeased: number | null;

    @Field(() => Float, { nullable: true })
    RentPerSFYrLow: number | null;

    @Field(() => Float, { nullable: true })
    RentPerSFYrHigh: number | null;

    @Field(() => Float, { nullable: true })
    AverageWeightedRent: number | null;

    @Field(() => Float, { nullable: true })
    CapRate: number | null;

    @Field(() => Float, { nullable: true })
    TaxesTotal: number | null;

    @Field(() => Float, { nullable: true })
    LastSalePrice: number | null;

    @Field({ nullable: true })
    LastSaleDate: Date | null;

    @Field({ nullable: true })
    SourceFile: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Co Star Income Inputs
//****************************************************************************
@InputType()
export class UpdateindianataxCoStarIncomeInputInput {
    @Field()
    ID: string;

    @Field(() => Int, { nullable: true })
    CoStarPropertyID?: number;

    @Field({ nullable: true })
    ParcelID?: string | null;

    @Field({ nullable: true })
    ParcelNumberMin?: string | null;

    @Field({ nullable: true })
    ParcelNumberMax?: string | null;

    @Field(() => Boolean, { nullable: true })
    MultiParcel?: boolean;

    @Field({ nullable: true })
    PropertyTypeGroup?: string | null;

    @Field({ nullable: true })
    CoStarPropertyType?: string | null;

    @Field({ nullable: true })
    SecondaryType?: string | null;

    @Field({ nullable: true })
    Submarket?: string | null;

    @Field({ nullable: true })
    City?: string | null;

    @Field({ nullable: true })
    PropertyName?: string | null;

    @Field({ nullable: true })
    PropertyAddress?: string | null;

    @Field(() => Float, { nullable: true })
    StarRating?: number | null;

    @Field(() => Int, { nullable: true })
    YearBuilt?: number | null;

    @Field(() => Int, { nullable: true })
    YearRenovated?: number | null;

    @Field(() => Int, { nullable: true })
    Units?: number | null;

    @Field(() => Int, { nullable: true })
    RBA?: number | null;

    @Field(() => Int, { nullable: true })
    Rooms?: number | null;

    @Field(() => Int, { nullable: true })
    Beds?: number | null;

    @Field(() => Float, { nullable: true })
    AvgEffectiveRentPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    AvgAskingRentPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    AvgEffectiveRentPerSF?: number | null;

    @Field(() => Float, { nullable: true })
    AvgAskingRentPerSF?: number | null;

    @Field(() => Float, { nullable: true })
    ConcessionsPct?: number | null;

    @Field(() => Float, { nullable: true })
    VacancyPct?: number | null;

    @Field(() => Float, { nullable: true })
    PercentLeased?: number | null;

    @Field(() => Float, { nullable: true })
    RentPerSFYrLow?: number | null;

    @Field(() => Float, { nullable: true })
    RentPerSFYrHigh?: number | null;

    @Field(() => Float, { nullable: true })
    AverageWeightedRent?: number | null;

    @Field(() => Float, { nullable: true })
    CapRate?: number | null;

    @Field(() => Float, { nullable: true })
    TaxesTotal?: number | null;

    @Field(() => Float, { nullable: true })
    LastSalePrice?: number | null;

    @Field({ nullable: true })
    LastSaleDate?: Date | null;

    @Field({ nullable: true })
    SourceFile?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Co Star Income Inputs
//****************************************************************************
@ObjectType()
export class RunindianataxCoStarIncomeInputViewResult {
    @Field(() => [indianataxCoStarIncomeInput_])
    Results: indianataxCoStarIncomeInput_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCoStarIncomeInput_)
export class indianataxCoStarIncomeInputResolver extends ResolverBase {
    @Query(() => RunindianataxCoStarIncomeInputViewResult)
    async RunindianataxCoStarIncomeInputViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCoStarIncomeInputViewResult)
    async RunindianataxCoStarIncomeInputViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCoStarIncomeInputViewResult)
    async RunindianataxCoStarIncomeInputDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Co Star Income Inputs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCoStarIncomeInput_, { nullable: true })
    async indianataxCoStarIncomeInput(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCoStarIncomeInput_ | null> {
        this.CheckUserReadPermissions('Co Star Income Inputs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarIncomeInputs')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Income Inputs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Co Star Income Inputs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCoStarIncomeInput_)
    async CreateindianataxCoStarIncomeInput(
        @Arg('input', () => CreateindianataxCoStarIncomeInputInput) input: CreateindianataxCoStarIncomeInputInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Co Star Income Inputs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCoStarIncomeInput_)
    async UpdateindianataxCoStarIncomeInput(
        @Arg('input', () => UpdateindianataxCoStarIncomeInputInput) input: UpdateindianataxCoStarIncomeInputInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Co Star Income Inputs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCoStarIncomeInput_)
    async DeleteindianataxCoStarIncomeInput(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Co Star Income Inputs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Co Star Properties
//****************************************************************************
@ObjectType()
export class indianataxCoStarProperty_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field(() => Int, {description: `CoStar's own stable property identifier (their own "PropertyID" field) -- the natural key for this table, unique across all 8 imported export files.`}) 
    CoStarPropertyID: number;
        
    @Field({description: `Which of the 8 CoStar export files/size bands this property came from (e.g. "Multi-Family (100+ Units)") -- CoStar splits exports at 500 rows, so this is provenance, not a property-type classification (see CoStarPropertyType/CoStarSecondaryType for that).`}) 
    @MaxLength(100)
    SourceExportFile: string;
        
    @Field({nullable: true, description: `The Marion County Parcel matched from CoStar's "Parcel Number 1(Min)" (or, failing that, address). NULL means no match was found -- the row is still kept, not dropped. For a multi-parcel property (see CoStarIsMultiParcel) this is only ONE of the constituent parcels -- do not treat its AV as representing the whole property.`}) 
    @MaxLength(36)
    ParcelID?: string;
        
    @Field({nullable: true, description: `The Marion County Parcel matched from CoStar's "Parcel Number 2(Max)", when it differs from ParcelID and itself resolves to a real parcel. NULL does not mean no second parcel exists -- CoStar's Min/Max is an outer bound, not a full membership list (see this migration's header comment); it means we could not resolve the Max end specifically.`}) 
    @MaxLength(36)
    CoStarSecondaryParcelID?: string;
        
    @Field(() => Boolean, {description: `True when CoStar's own "Parcel Number 1(Min)" and "Parcel Number 2(Max)" differ -- CoStar's signal that this property spans more than one parcel. Any per-unit/per-key/per-SF assessed-value figure derived from this row should be flagged as partial/incomplete when this is true, since we generally cannot enumerate every constituent parcel (see this migration's header comment) and CoStarNumberOfUnits/CoStarRBA/CoStarRooms are whole-property aggregates that a single matched parcel's AV does not fully cover.`}) 
    CoStarIsMultiParcel: boolean;
        
    @Field({nullable: true, description: `How ParcelID was resolved: ParcelNumberMin (exact match on the stripped "Parcel Number 1(Min)"), ParcelNumberMax (Min failed, Max matched), Address (both parcel-number attempts failed, a normalized-address match succeeded), or NULL (nothing matched).`}) 
    @MaxLength(20)
    MatchMethod?: string;
        
    @Field({nullable: true, description: `CoStar "Property Address".`}) 
    @MaxLength(200)
    CoStarAddress?: string;
        
    @Field({nullable: true, description: `CoStar "Property Name".`}) 
    @MaxLength(200)
    CoStarPropertyName?: string;
        
    @Field({nullable: true, description: `CoStar "Property Type" (e.g. Multifamily, Office, Retail, Industrial, Hospitality).`}) 
    @MaxLength(50)
    CoStarPropertyType?: string;
        
    @Field({nullable: true, description: `CoStar "Secondary Type" -- a finer-grained classification than CoStarPropertyType.`}) 
    @MaxLength(50)
    CoStarSecondaryType?: string;
        
    @Field({nullable: true, description: `CoStar "City".`}) 
    @MaxLength(100)
    CoStarCity?: string;
        
    @Field({nullable: true, description: `CoStar "State".`}) 
    @MaxLength(10)
    CoStarState?: string;
        
    @Field({nullable: true, description: `CoStar "Zip".`}) 
    @MaxLength(20)
    CoStarZip?: string;
        
    @Field({nullable: true, description: `CoStar "County Name".`}) 
    @MaxLength(50)
    CoStarCountyName?: string;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Latitude".`}) 
    CoStarLatitude?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Longitude".`}) 
    CoStarLongitude?: number;
        
    @Field({nullable: true, description: `CoStar "Parcel Number 1(Min)", raw as exported (with punctuation, e.g. "49-11-01-240-261.002-101") -- kept for audit; ParcelID is the resolved match after stripping punctuation.`}) 
    @MaxLength(40)
    CoStarParcelNumberMin?: string;
        
    @Field({nullable: true, description: `CoStar "Parcel Number 2(Max)", raw as exported. Equal to CoStarParcelNumberMin for a single-parcel property; different for a multi-parcel one (see CoStarIsMultiParcel).`}) 
    @MaxLength(40)
    CoStarParcelNumberMax?: string;
        
    @Field({nullable: true, description: `CoStar "Owner Name" -- CoStar carries three distinct owner fields (this one, RecordedOwnerName, TrueOwnerName) that routinely disagree (e.g. a management company name here vs. the actual holding LLC in RecordedOwnerName) -- do not assume they match each other or indiana_tax.CountyAssessorRecord.OwnerName.`}) 
    @MaxLength(300)
    CoStarOwnerName?: string;
        
    @Field({nullable: true, description: `CoStar "Recorded Owner Name" -- see CoStarOwnerName's comment on why this often differs from it.`}) 
    @MaxLength(300)
    CoStarRecordedOwnerName?: string;
        
    @Field({nullable: true, description: `CoStar "True Owner Name" -- see CoStarOwnerName's comment.`}) 
    @MaxLength(300)
    CoStarTrueOwnerName?: string;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Number of Units" -- whole-property unit count for multifamily/student housing, the correct denominator for a per-unit comparison (see CoStarIsMultiParcel for why the AV numerator may only be partial).`}) 
    CoStarNumberOfUnits?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Rooms" -- whole-property room/key count for hospitality properties.`}) 
    CoStarRooms?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "RBA" (Rentable Building Area, SF) -- whole-property building square footage for office/industrial/retail.`}) 
    CoStarRBA?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Total Buildings" -- number of distinct buildings on the property (independent of parcel count).`}) 
    CoStarTotalBuildings?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Land Area (AC)".`}) 
    CoStarLandAreaAcres?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Land Area (SF)".`}) 
    CoStarLandAreaSF?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Number of Stories".`}) 
    CoStarNumberOfStories?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Year Built".`}) 
    CoStarYearBuilt?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Year Renovated".`}) 
    CoStarYearRenovated?: number;
        
    @Field({nullable: true, description: `CoStar "Building Class" (A/B/C).`}) 
    @MaxLength(10)
    CoStarBuildingClass?: string;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Star Rating" (1-5).`}) 
    CoStarStarRating?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Last Sale Price".`}) 
    CoStarLastSalePrice?: number;
        
    @Field({nullable: true, description: `CoStar "Last Sale Date".`}) 
    CoStarLastSaleDate?: Date;
        
    @Field(() => Float, {nullable: true, description: `CoStar "For Sale Price" -- current asking price, if actively listed (see CoStarForSaleStatus).`}) 
    CoStarForSalePrice?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "For Sale Price Per Unit".`}) 
    CoStarForSalePricePerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "For Sale Price Per SF".`}) 
    CoStarForSalePricePerSF?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "For Sale Price Per Room" -- hospitality only.`}) 
    CoStarForSalePricePerRoom?: number;
        
    @Field({nullable: true, description: `CoStar "For Sale Status".`}) 
    @MaxLength(10)
    CoStarForSaleStatus?: string;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Cap Rate", already a plain decimal percentage (e.g. 6.12 means 6.12%), not a 0-1 fraction.`}) 
    CoStarCapRate?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Taxes Total" -- CoStar's own figure for this property's total tax bill, useful as an independent cross-check against indiana_tax.TaxHistoryYear/CountyAssessorRecord.NetAnnualTax for the matched parcel(s).`}) 
    CoStarTaxesTotal?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Taxes Per SF".`}) 
    CoStarTaxesPerSF?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Tax Year" -- the year CoStarTaxesTotal/CoStarTaxesPerSF apply to; compare against indiana_tax.Assessment.AssessmentYear before treating the two sources as describing the same year.`}) 
    CoStarTaxYear?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Avg Asking/SF".`}) 
    CoStarAvgAskingPerSF?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Avg Asking/Unit".`}) 
    CoStarAvgAskingPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Avg Effective/SF".`}) 
    CoStarAvgEffectivePerSF?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Avg Effective/Unit".`}) 
    CoStarAvgEffectivePerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Percent Leased", already a plain decimal percentage.`}) 
    CoStarPercentLeased?: number;
        
    @Field(() => Float, {nullable: true, description: `CoStar "Vacancy %", already a plain decimal percentage.`}) 
    CoStarVacancyPct?: number;
        
    @Field(() => Int, {nullable: true, description: `CoStar "Days On Market".`}) 
    CoStarDaysOnMarket?: number;
        
    @Field({nullable: true, description: `CoStar "Submarket Name".`}) 
    @MaxLength(100)
    CoStarSubmarketName?: string;
        
    @Field({nullable: true, description: `CoStar "Market Name".`}) 
    @MaxLength(100)
    CoStarMarketName?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The CoStar export .xlsx this row was parsed from (SourceExportFile is the short label). CoStar data is a labeled cross-check, not authority.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    Parcel?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    CoStarSecondaryParcel?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
}

//****************************************************************************
// INPUT TYPE for Co Star Properties
//****************************************************************************
@InputType()
export class CreateindianataxCoStarPropertyInput {
    @Field({ nullable: true })
    ID?: string;

    @Field(() => Int, { nullable: true })
    CoStarPropertyID?: number;

    @Field({ nullable: true })
    SourceExportFile?: string;

    @Field({ nullable: true })
    ParcelID: string | null;

    @Field({ nullable: true })
    CoStarSecondaryParcelID: string | null;

    @Field(() => Boolean, { nullable: true })
    CoStarIsMultiParcel?: boolean;

    @Field({ nullable: true })
    MatchMethod: string | null;

    @Field({ nullable: true })
    CoStarAddress: string | null;

    @Field({ nullable: true })
    CoStarPropertyName: string | null;

    @Field({ nullable: true })
    CoStarPropertyType: string | null;

    @Field({ nullable: true })
    CoStarSecondaryType: string | null;

    @Field({ nullable: true })
    CoStarCity: string | null;

    @Field({ nullable: true })
    CoStarState: string | null;

    @Field({ nullable: true })
    CoStarZip: string | null;

    @Field({ nullable: true })
    CoStarCountyName: string | null;

    @Field(() => Float, { nullable: true })
    CoStarLatitude: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLongitude: number | null;

    @Field({ nullable: true })
    CoStarParcelNumberMin: string | null;

    @Field({ nullable: true })
    CoStarParcelNumberMax: string | null;

    @Field({ nullable: true })
    CoStarOwnerName: string | null;

    @Field({ nullable: true })
    CoStarRecordedOwnerName: string | null;

    @Field({ nullable: true })
    CoStarTrueOwnerName: string | null;

    @Field(() => Int, { nullable: true })
    CoStarNumberOfUnits: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRooms: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRBA: number | null;

    @Field(() => Int, { nullable: true })
    CoStarTotalBuildings: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLandAreaAcres: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLandAreaSF: number | null;

    @Field(() => Int, { nullable: true })
    CoStarNumberOfStories: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearBuilt: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearRenovated: number | null;

    @Field({ nullable: true })
    CoStarBuildingClass: string | null;

    @Field(() => Int, { nullable: true })
    CoStarStarRating: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLastSalePrice: number | null;

    @Field({ nullable: true })
    CoStarLastSaleDate: Date | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePrice: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerUnit: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerSF: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerRoom: number | null;

    @Field({ nullable: true })
    CoStarForSaleStatus: string | null;

    @Field(() => Float, { nullable: true })
    CoStarCapRate: number | null;

    @Field(() => Float, { nullable: true })
    CoStarTaxesTotal: number | null;

    @Field(() => Float, { nullable: true })
    CoStarTaxesPerSF: number | null;

    @Field(() => Int, { nullable: true })
    CoStarTaxYear: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgAskingPerSF: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgAskingPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgEffectivePerSF: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgEffectivePerUnit: number | null;

    @Field(() => Float, { nullable: true })
    CoStarPercentLeased: number | null;

    @Field(() => Float, { nullable: true })
    CoStarVacancyPct: number | null;

    @Field(() => Int, { nullable: true })
    CoStarDaysOnMarket: number | null;

    @Field({ nullable: true })
    CoStarSubmarketName: string | null;

    @Field({ nullable: true })
    CoStarMarketName: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Co Star Properties
//****************************************************************************
@InputType()
export class UpdateindianataxCoStarPropertyInput {
    @Field()
    ID: string;

    @Field(() => Int, { nullable: true })
    CoStarPropertyID?: number;

    @Field({ nullable: true })
    SourceExportFile?: string;

    @Field({ nullable: true })
    ParcelID?: string | null;

    @Field({ nullable: true })
    CoStarSecondaryParcelID?: string | null;

    @Field(() => Boolean, { nullable: true })
    CoStarIsMultiParcel?: boolean;

    @Field({ nullable: true })
    MatchMethod?: string | null;

    @Field({ nullable: true })
    CoStarAddress?: string | null;

    @Field({ nullable: true })
    CoStarPropertyName?: string | null;

    @Field({ nullable: true })
    CoStarPropertyType?: string | null;

    @Field({ nullable: true })
    CoStarSecondaryType?: string | null;

    @Field({ nullable: true })
    CoStarCity?: string | null;

    @Field({ nullable: true })
    CoStarState?: string | null;

    @Field({ nullable: true })
    CoStarZip?: string | null;

    @Field({ nullable: true })
    CoStarCountyName?: string | null;

    @Field(() => Float, { nullable: true })
    CoStarLatitude?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLongitude?: number | null;

    @Field({ nullable: true })
    CoStarParcelNumberMin?: string | null;

    @Field({ nullable: true })
    CoStarParcelNumberMax?: string | null;

    @Field({ nullable: true })
    CoStarOwnerName?: string | null;

    @Field({ nullable: true })
    CoStarRecordedOwnerName?: string | null;

    @Field({ nullable: true })
    CoStarTrueOwnerName?: string | null;

    @Field(() => Int, { nullable: true })
    CoStarNumberOfUnits?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRooms?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRBA?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarTotalBuildings?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLandAreaAcres?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLandAreaSF?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarNumberOfStories?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearBuilt?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearRenovated?: number | null;

    @Field({ nullable: true })
    CoStarBuildingClass?: string | null;

    @Field(() => Int, { nullable: true })
    CoStarStarRating?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarLastSalePrice?: number | null;

    @Field({ nullable: true })
    CoStarLastSaleDate?: Date | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePrice?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerSF?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarForSalePricePerRoom?: number | null;

    @Field({ nullable: true })
    CoStarForSaleStatus?: string | null;

    @Field(() => Float, { nullable: true })
    CoStarCapRate?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarTaxesTotal?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarTaxesPerSF?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarTaxYear?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgAskingPerSF?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgAskingPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgEffectivePerSF?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarAvgEffectivePerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarPercentLeased?: number | null;

    @Field(() => Float, { nullable: true })
    CoStarVacancyPct?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarDaysOnMarket?: number | null;

    @Field({ nullable: true })
    CoStarSubmarketName?: string | null;

    @Field({ nullable: true })
    CoStarMarketName?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Co Star Properties
//****************************************************************************
@ObjectType()
export class RunindianataxCoStarPropertyViewResult {
    @Field(() => [indianataxCoStarProperty_])
    Results: indianataxCoStarProperty_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCoStarProperty_)
export class indianataxCoStarPropertyResolver extends ResolverBase {
    @Query(() => RunindianataxCoStarPropertyViewResult)
    async RunindianataxCoStarPropertyViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCoStarPropertyViewResult)
    async RunindianataxCoStarPropertyViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCoStarPropertyViewResult)
    async RunindianataxCoStarPropertyDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Co Star Properties';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCoStarProperty_, { nullable: true })
    async indianataxCoStarProperty(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCoStarProperty_ | null> {
        this.CheckUserReadPermissions('Co Star Properties', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarProperties')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Properties', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Co Star Properties', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCoStarProperty_)
    async CreateindianataxCoStarProperty(
        @Arg('input', () => CreateindianataxCoStarPropertyInput) input: CreateindianataxCoStarPropertyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Co Star Properties', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCoStarProperty_)
    async UpdateindianataxCoStarProperty(
        @Arg('input', () => UpdateindianataxCoStarPropertyInput) input: UpdateindianataxCoStarPropertyInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Co Star Properties', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCoStarProperty_)
    async DeleteindianataxCoStarProperty(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Co Star Properties', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Comparable Assessment Members
//****************************************************************************
@ObjectType({ description: `One comparable property within a ComparableAssessmentSet: its similarity score + component deltas, the analyst\'s include flag, and a snapshot of its physical attributes and value tracks (Original / Appealed / Effective) for the set\'s focus year.` })
export class indianataxComparableAssessmentMember_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The set this comp belongs to.`}) 
    @MaxLength(36)
    ComparableAssessmentSetID: string;
        
    @Field({description: `The comparable parcel.`}) 
    @MaxLength(36)
    ComparableParcelID: string;
        
    @Field({description: `Which list this comp came from: Neighborhood (same code, ungated) or County (county-wide, strict physical gate).`}) 
    @MaxLength(14)
    GeographyBucket: string;
        
    @Field(() => Float, {nullable: true, description: `Weighted physical-similarity distance (lower = more similar).`}) 
    SimilarityScore?: number;
        
    @Field(() => Float, {nullable: true, description: `abs(ln(subject building SF / comp building SF)) -- the size-match component, exposed for review.`}) 
    SizeLnRatio?: number;
        
    @Field(() => Int, {nullable: true, description: `abs(subject effective year - comp effective year).`}) 
    EffectiveYearDelta?: number;
        
    @Field(() => Float, {nullable: true, description: `abs difference of the mapped grade ordinal (C=3, C+=3.33, B=4, ...).`}) 
    GradeDelta?: number;
        
    @Field({nullable: true, description: `How closely the state class codes match: exact (5-digit), 3-digit, or group-only.`}) 
    @MaxLength(12)
    ClassMatchLevel?: string;
        
    @Field({nullable: true, description: `JSON: the full weighted-component breakdown behind SimilarityScore.`}) 
    SimilarityBreakdown?: string;
        
    @Field(() => Boolean, {description: `Analyst's choice: is this comp included in the headline mean/median? Builder seeds this (Neighborhood + gated County members start selected).`}) 
    IsSelected: boolean;
        
    @Field(() => Int, {nullable: true, description: `Display order within the bucket (1 = most similar).`}) 
    SortOrder?: number;
        
    @Field({nullable: true, description: `Free-text note on this comp (why kept / dropped).`}) 
    AnalystNote?: string;
        
    @Field(() => Int, {nullable: true, description: `Snapshot: comp building SF at generation time.`}) 
    ComparableBuildingSqFt?: number;
        
    @Field(() => Float, {nullable: true, description: `Snapshot: comp unit count (trustworthy-filtered) at generation time.`}) 
    ComparableUnitCount?: number;
        
    @Field(() => Int, {nullable: true, description: `Snapshot: comp effective year.`}) 
    ComparableEffectiveYear?: number;
        
    @Field({nullable: true, description: `Snapshot: comp grade code.`}) 
    @MaxLength(8)
    ComparableGradeCode?: string;
        
    @Field(() => Float, {nullable: true, description: `The comp's own denominator for the set's unit of comparison.`}) 
    DenomValue?: number;
        
    @Field(() => Float, {nullable: true, description: `Comp as-noticed Original total AV for the focus year.`}) 
    OriginalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Comp appealed total AV for the focus year (PTABOA After or IBTR/Final determination), NULL if the comp did not appeal that year.`}) 
    AppealedAV?: number;
        
    @Field({nullable: true, description: `Level the appealed value came from: PTABOA or IBTR/Final.`}) 
    @MaxLength(16)
    AppealLevel?: string;
        
    @Field(() => Float, {nullable: true, description: `Percent change of the appealed value vs the pre-appeal base (negative = reduction).`}) 
    AppealPctChange?: number;
        
    @Field({nullable: true, description: `Tax representative of record on the comp's appeal, if any.`}) 
    @MaxLength(200)
    AppealRepresentative?: string;
        
    @Field(() => Float, {nullable: true, description: `Comp Effective total AV for the focus year (Appealed if present else Original).`}) 
    EffectiveAV?: number;
        
    @Field(() => Float, {nullable: true, description: `OriginalAV / DenomValue.`}) 
    OriginalPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `EffectiveAV / DenomValue -- the value that flows into the headline mean/median when IsSelected.`}) 
    EffectivePerUnit?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    ComparableParcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Comparable Assessment Members
//****************************************************************************
@InputType()
export class CreateindianataxComparableAssessmentMemberInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ComparableAssessmentSetID?: string;

    @Field({ nullable: true })
    ComparableParcelID?: string;

    @Field({ nullable: true })
    GeographyBucket?: string;

    @Field(() => Float, { nullable: true })
    SimilarityScore: number | null;

    @Field(() => Float, { nullable: true })
    SizeLnRatio: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYearDelta: number | null;

    @Field(() => Float, { nullable: true })
    GradeDelta: number | null;

    @Field({ nullable: true })
    ClassMatchLevel: string | null;

    @Field({ nullable: true })
    SimilarityBreakdown: string | null;

    @Field(() => Boolean, { nullable: true })
    IsSelected?: boolean;

    @Field(() => Int, { nullable: true })
    SortOrder: number | null;

    @Field({ nullable: true })
    AnalystNote: string | null;

    @Field(() => Int, { nullable: true })
    ComparableBuildingSqFt: number | null;

    @Field(() => Float, { nullable: true })
    ComparableUnitCount: number | null;

    @Field(() => Int, { nullable: true })
    ComparableEffectiveYear: number | null;

    @Field({ nullable: true })
    ComparableGradeCode: string | null;

    @Field(() => Float, { nullable: true })
    DenomValue: number | null;

    @Field(() => Float, { nullable: true })
    OriginalAV: number | null;

    @Field(() => Float, { nullable: true })
    AppealedAV: number | null;

    @Field({ nullable: true })
    AppealLevel: string | null;

    @Field(() => Float, { nullable: true })
    AppealPctChange: number | null;

    @Field({ nullable: true })
    AppealRepresentative: string | null;

    @Field(() => Float, { nullable: true })
    EffectiveAV: number | null;

    @Field(() => Float, { nullable: true })
    OriginalPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    EffectivePerUnit: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Comparable Assessment Members
//****************************************************************************
@InputType()
export class UpdateindianataxComparableAssessmentMemberInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ComparableAssessmentSetID?: string;

    @Field({ nullable: true })
    ComparableParcelID?: string;

    @Field({ nullable: true })
    GeographyBucket?: string;

    @Field(() => Float, { nullable: true })
    SimilarityScore?: number | null;

    @Field(() => Float, { nullable: true })
    SizeLnRatio?: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYearDelta?: number | null;

    @Field(() => Float, { nullable: true })
    GradeDelta?: number | null;

    @Field({ nullable: true })
    ClassMatchLevel?: string | null;

    @Field({ nullable: true })
    SimilarityBreakdown?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsSelected?: boolean;

    @Field(() => Int, { nullable: true })
    SortOrder?: number | null;

    @Field({ nullable: true })
    AnalystNote?: string | null;

    @Field(() => Int, { nullable: true })
    ComparableBuildingSqFt?: number | null;

    @Field(() => Float, { nullable: true })
    ComparableUnitCount?: number | null;

    @Field(() => Int, { nullable: true })
    ComparableEffectiveYear?: number | null;

    @Field({ nullable: true })
    ComparableGradeCode?: string | null;

    @Field(() => Float, { nullable: true })
    DenomValue?: number | null;

    @Field(() => Float, { nullable: true })
    OriginalAV?: number | null;

    @Field(() => Float, { nullable: true })
    AppealedAV?: number | null;

    @Field({ nullable: true })
    AppealLevel?: string | null;

    @Field(() => Float, { nullable: true })
    AppealPctChange?: number | null;

    @Field({ nullable: true })
    AppealRepresentative?: string | null;

    @Field(() => Float, { nullable: true })
    EffectiveAV?: number | null;

    @Field(() => Float, { nullable: true })
    OriginalPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    EffectivePerUnit?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Comparable Assessment Members
//****************************************************************************
@ObjectType()
export class RunindianataxComparableAssessmentMemberViewResult {
    @Field(() => [indianataxComparableAssessmentMember_])
    Results: indianataxComparableAssessmentMember_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxComparableAssessmentMember_)
export class indianataxComparableAssessmentMemberResolver extends ResolverBase {
    @Query(() => RunindianataxComparableAssessmentMemberViewResult)
    async RunindianataxComparableAssessmentMemberViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxComparableAssessmentMemberViewResult)
    async RunindianataxComparableAssessmentMemberViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxComparableAssessmentMemberViewResult)
    async RunindianataxComparableAssessmentMemberDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Comparable Assessment Members';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxComparableAssessmentMember_, { nullable: true })
    async indianataxComparableAssessmentMember(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxComparableAssessmentMember_ | null> {
        this.CheckUserReadPermissions('Comparable Assessment Members', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwComparableAssessmentMembers')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Comparable Assessment Members', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Comparable Assessment Members', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxComparableAssessmentMember_)
    async CreateindianataxComparableAssessmentMember(
        @Arg('input', () => CreateindianataxComparableAssessmentMemberInput) input: CreateindianataxComparableAssessmentMemberInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Comparable Assessment Members', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxComparableAssessmentMember_)
    async UpdateindianataxComparableAssessmentMember(
        @Arg('input', () => UpdateindianataxComparableAssessmentMemberInput) input: UpdateindianataxComparableAssessmentMemberInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Comparable Assessment Members', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxComparableAssessmentMember_)
    async DeleteindianataxComparableAssessmentMember(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Comparable Assessment Members', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Comparable Assessment Sets
//****************************************************************************
@ObjectType({ description: `A comparable-assessments (uniformity / equity) workup for one subject parcel: the ranked Neighborhood and County-wide lists of physically similar properties, the analyst\'s include/exclude choices (ComparableAssessmentMember), and the headline per-unit comparison. Design: Indiana_Tax_Expert/docs/proposals/comparable-assessments.md.` })
export class indianataxComparableAssessmentSet_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The subject parcel being analysed.`}) 
    @MaxLength(36)
    SubjectParcelID: string;
        
    @Field(() => Int, {description: `The assessment year the per-unit comparison is struck for.`}) 
    FocusYear: number;
        
    @Field({description: `Version tag for the builder logic that produced this set (e.g. "comps-v1-2026-08-30"). Lets a re-run replace its own set without touching an earlier method's.`}) 
    @MaxLength(30)
    MethodologyVersion: string;
        
    @Field({nullable: true, description: `Rolled-up property category the comp pool was drawn from.`}) 
    @MaxLength(30)
    PropertyTypeGroup?: string;
        
    @Field({description: `Unit of comparison: $/SF (default), $/unit (multifamily with a trustworthy unit count), or $/acre (land).`}) 
    @MaxLength(10)
    UnitOfComparison: string;
        
    @Field({description: `Which value track drives the headline: Original (as-noticed), Appealed (post-PTABOA/IBTR), or Effective (Appealed if present else Original). Default Effective -- the hardest benchmark for the county to rebut.`}) 
    @MaxLength(10)
    HeadlineTrack: string;
        
    @Field(() => Float, {nullable: true, description: `The subject's denominator for the unit of comparison (building SF, unit count, or acres).`}) 
    SubjectDenomValue?: number;
        
    @Field(() => Float, {nullable: true, description: `Subject as-noticed Original total AV for the focus year.`}) 
    SubjectOriginalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Subject Effective total AV for the focus year (Appealed if the subject itself has a PTABOA/IBTR result, else Original).`}) 
    SubjectEffectiveAV?: number;
        
    @Field(() => Float, {nullable: true, description: `SubjectEffectiveAV / SubjectDenomValue -- the number the comp means/medians are measured against.`}) 
    SubjectPerUnitEffective?: number;
        
    @Field({nullable: true, description: `The subject's CountyAssessorRecord.Neighborhood code -- the pool for the Neighborhood list.`}) 
    @MaxLength(120)
    NeighborhoodCode?: string;
        
    @Field(() => Int, {nullable: true, description: `Count of Neighborhood-list members with a usable per-unit value (basis for the mean/median).`}) 
    NeighborhoodCompCount?: number;
        
    @Field(() => Float, {nullable: true, description: `Mean Effective per-unit value across the Neighborhood list (focus year). Can mislead when the neighborhood is thin and building sizes vary widely -- prefer the median.`}) 
    NeighborhoodMeanPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `Median Effective per-unit value across the Neighborhood list (focus year).`}) 
    NeighborhoodMedianPerUnit?: number;
        
    @Field(() => Int, {nullable: true, description: `Count of County-list members with a usable per-unit value.`}) 
    CountyCompCount?: number;
        
    @Field(() => Float, {nullable: true, description: `Mean Effective per-unit value across the County-wide list (focus year).`}) 
    CountyMeanPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `Median Effective per-unit value across the County-wide list (focus year).`}) 
    CountyMedianPerUnit?: number;
        
    @Field(() => Int, {nullable: true, description: `Percentile the subject's per-unit value sits at within the combined comp set (0-100; higher = more over-assessed relative to peers).`}) 
    SubjectPercentile?: number;
        
    @Field({description: `Draft (builder output, not yet reviewed) or Final (analyst has reviewed the selections).`}) 
    @MaxLength(10)
    Status: string;
        
    @Field({nullable: true, description: `Free-text analyst / agent notes on the set.`}) 
    AnalystNote?: string;
        
    @Field({nullable: true, description: `When the builder generated this set.`}) 
    GeneratedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    SubjectParcel: string;
        
    @Field(() => [indianataxComparableAssessmentMember_])
    indianataxComparableAssessmentMembers_ComparableAssessmentSetIDArray: indianataxComparableAssessmentMember_[]; // Link to indianataxComparableAssessmentMembers
    
}

//****************************************************************************
// INPUT TYPE for Comparable Assessment Sets
//****************************************************************************
@InputType()
export class CreateindianataxComparableAssessmentSetInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    SubjectParcelID?: string;

    @Field(() => Int, { nullable: true })
    FocusYear?: number;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    PropertyTypeGroup: string | null;

    @Field({ nullable: true })
    UnitOfComparison?: string;

    @Field({ nullable: true })
    HeadlineTrack?: string;

    @Field(() => Float, { nullable: true })
    SubjectDenomValue: number | null;

    @Field(() => Float, { nullable: true })
    SubjectOriginalAV: number | null;

    @Field(() => Float, { nullable: true })
    SubjectEffectiveAV: number | null;

    @Field(() => Float, { nullable: true })
    SubjectPerUnitEffective: number | null;

    @Field({ nullable: true })
    NeighborhoodCode: string | null;

    @Field(() => Int, { nullable: true })
    NeighborhoodCompCount: number | null;

    @Field(() => Float, { nullable: true })
    NeighborhoodMeanPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    NeighborhoodMedianPerUnit: number | null;

    @Field(() => Int, { nullable: true })
    CountyCompCount: number | null;

    @Field(() => Float, { nullable: true })
    CountyMeanPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    CountyMedianPerUnit: number | null;

    @Field(() => Int, { nullable: true })
    SubjectPercentile: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AnalystNote: string | null;

    @Field({ nullable: true })
    GeneratedAt: Date | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Comparable Assessment Sets
//****************************************************************************
@InputType()
export class UpdateindianataxComparableAssessmentSetInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    SubjectParcelID?: string;

    @Field(() => Int, { nullable: true })
    FocusYear?: number;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    PropertyTypeGroup?: string | null;

    @Field({ nullable: true })
    UnitOfComparison?: string;

    @Field({ nullable: true })
    HeadlineTrack?: string;

    @Field(() => Float, { nullable: true })
    SubjectDenomValue?: number | null;

    @Field(() => Float, { nullable: true })
    SubjectOriginalAV?: number | null;

    @Field(() => Float, { nullable: true })
    SubjectEffectiveAV?: number | null;

    @Field(() => Float, { nullable: true })
    SubjectPerUnitEffective?: number | null;

    @Field({ nullable: true })
    NeighborhoodCode?: string | null;

    @Field(() => Int, { nullable: true })
    NeighborhoodCompCount?: number | null;

    @Field(() => Float, { nullable: true })
    NeighborhoodMeanPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    NeighborhoodMedianPerUnit?: number | null;

    @Field(() => Int, { nullable: true })
    CountyCompCount?: number | null;

    @Field(() => Float, { nullable: true })
    CountyMeanPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    CountyMedianPerUnit?: number | null;

    @Field(() => Int, { nullable: true })
    SubjectPercentile?: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    AnalystNote?: string | null;

    @Field({ nullable: true })
    GeneratedAt?: Date | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Comparable Assessment Sets
//****************************************************************************
@ObjectType()
export class RunindianataxComparableAssessmentSetViewResult {
    @Field(() => [indianataxComparableAssessmentSet_])
    Results: indianataxComparableAssessmentSet_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxComparableAssessmentSet_)
export class indianataxComparableAssessmentSetResolver extends ResolverBase {
    @Query(() => RunindianataxComparableAssessmentSetViewResult)
    async RunindianataxComparableAssessmentSetViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxComparableAssessmentSetViewResult)
    async RunindianataxComparableAssessmentSetViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxComparableAssessmentSetViewResult)
    async RunindianataxComparableAssessmentSetDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Comparable Assessment Sets';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxComparableAssessmentSet_, { nullable: true })
    async indianataxComparableAssessmentSet(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxComparableAssessmentSet_ | null> {
        this.CheckUserReadPermissions('Comparable Assessment Sets', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwComparableAssessmentSets')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Comparable Assessment Sets', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Comparable Assessment Sets', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxComparableAssessmentMember_])
    async indianataxComparableAssessmentMembers_ComparableAssessmentSetIDArray(@Root() indianataxcomparableassessmentset_: indianataxComparableAssessmentSet_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Comparable Assessment Members', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwComparableAssessmentMembers')} WHERE ${provider.QuoteIdentifier('ComparableAssessmentSetID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Comparable Assessment Members', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxcomparableassessmentset_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Comparable Assessment Members', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxComparableAssessmentSet_)
    async CreateindianataxComparableAssessmentSet(
        @Arg('input', () => CreateindianataxComparableAssessmentSetInput) input: CreateindianataxComparableAssessmentSetInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Comparable Assessment Sets', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxComparableAssessmentSet_)
    async UpdateindianataxComparableAssessmentSet(
        @Arg('input', () => UpdateindianataxComparableAssessmentSetInput) input: UpdateindianataxComparableAssessmentSetInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Comparable Assessment Sets', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxComparableAssessmentSet_)
    async DeleteindianataxComparableAssessmentSet(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Comparable Assessment Sets', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for County Assessor Improvement Segments
//****************************************************************************
@ObjectType({ description: `One row per floor/use-segment column from a Property Record Card\'s dense per-card pricing table (the "Average Size / Units" grid). CRITICAL: a segment\'s printed size is PER FLOOR, not the segment total -- e.g. "21,263 / 10" means 21,263 sqft on each of 10 floors (212,630 sqft total). TotalSqFt is a computed column so this multiplication can never be silently skipped or dropped. Summing TotalSqFt across all of a parcel\'s segments should match the Building row\'s SizeOrArea in CountyAssessorImprovement -- root-caused against parcel 8050459 on 2026-08-23 (see the closed ResearchTask), where plain-text PDF extraction had previously dropped a leading digit and silently undercounted a segment by a factor of ~17.` })
export class indianataxCountyAssessorImprovementSegment_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel record this improvement segment belongs to. Segments are implicitly part of the "Building" structure line -- Paving/Skyway/etc. don't carry their own per-floor breakdown, so there is no direct link to a specific CountyAssessorImprovement row.`}) 
    @MaxLength(36)
    CountyAssessorRecordID: string;
        
    @Field({nullable: true, description: `The card page this segment was reported on (e.g. "1", "1A").`}) 
    @MaxLength(10)
    CardNumber?: string;
        
    @Field(() => Int, {nullable: true, description: `The segment's column position within its card (left to right), used to preserve the original ordering and as a stable identity within a card when re-parsing.`}) 
    SegmentIndex?: number;
        
    @Field({nullable: true, description: `The use classification for this segment, e.g. "Gen Office", "Utility".`}) 
    @MaxLength(50)
    Use?: string;
        
    @Field(() => Float, {nullable: true, description: `The "S.F. Area" / "Average Size" value for this segment -- the size of ONE floor of this type, not the segment total. See TotalSqFt.`}) 
    SqFtPerFloor?: number;
        
    @Field(() => Int, {nullable: true, description: `The "Units" value from "Average Size / Units" -- how many floors carry this segment's SqFtPerFloor. 1 for a single-floor segment.`}) 
    FloorCount?: number;
        
    @Field(() => Float, {nullable: true, description: `Computed as SqFtPerFloor * FloorCount -- the true total square footage this segment contributes to the building. Always use this, never SqFtPerFloor alone, for any building-size or per-square-foot analysis.`}) 
    TotalSqFt?: number;
        
    @Field(() => Float, {nullable: true, description: `The assessor's estimated replacement cost for this segment, per the card's cost-model computation.`}) 
    ReproductionCost?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Phys Dep" percentage from the "Phys Dep/ Yr Blt /Cond" field -- physical depreciation applied to this segment's reproduction cost.`}) 
    PhysicalDepreciationPct?: number;
        
    @Field(() => Int, {nullable: true, description: `The "Yr Blt" (year built) component of "Phys Dep/ Yr Blt /Cond" for this specific segment -- can differ segment-to-segment within the same structure (e.g. an addition).`}) 
    YearConstructed?: number;
        
    @Field(() => Int, {nullable: true, description: `The effective year used for this segment's depreciation calculation.`}) 
    EffectiveYear?: number;
        
    @Field({nullable: true, description: `The "Cond" (condition) component of "Phys Dep/ Yr Blt /Cond" -- a letter rating (e.g. "A") for this segment.`}) 
    @MaxLength(10)
    Condition?: string;
        
    @Field(() => Float, {nullable: true, description: `The "Obsolescence" figure for this segment -- a cost-model adjustment the county can apply to align reproduction-cost-based value with market value-in-use. NOTE (2026-08-23): the sample parcel used to design this table had Obsolescence=0 throughout, so the real-world format (percentage vs. dollar amount) of a non-zero value has not yet been directly confirmed -- verify against a parcel with an actual adjustment before relying on this column's units. A parcel receiving this adjustment while comparable parcels don't is a potential appeal-lead signal (see the related ResearchTask), but that scoring logic is not implemented by this column alone.`}) 
    ObsolescencePct?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Remainder Value" for this segment -- reproduction cost after physical depreciation and obsolescence.`}) 
    RemainderValue?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    CountyAssessorRecord?: string;
        
}

//****************************************************************************
// INPUT TYPE for County Assessor Improvement Segments
//****************************************************************************
@InputType()
export class CreateindianataxCountyAssessorImprovementSegmentInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    CardNumber: string | null;

    @Field(() => Int, { nullable: true })
    SegmentIndex: number | null;

    @Field({ nullable: true })
    Use: string | null;

    @Field(() => Float, { nullable: true })
    SqFtPerFloor: number | null;

    @Field(() => Int, { nullable: true })
    FloorCount: number | null;

    @Field(() => Float, { nullable: true })
    ReproductionCost: number | null;

    @Field(() => Float, { nullable: true })
    PhysicalDepreciationPct: number | null;

    @Field(() => Int, { nullable: true })
    YearConstructed: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYear: number | null;

    @Field({ nullable: true })
    Condition: string | null;

    @Field(() => Float, { nullable: true })
    ObsolescencePct: number | null;

    @Field(() => Float, { nullable: true })
    RemainderValue: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for County Assessor Improvement Segments
//****************************************************************************
@InputType()
export class UpdateindianataxCountyAssessorImprovementSegmentInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    CardNumber?: string | null;

    @Field(() => Int, { nullable: true })
    SegmentIndex?: number | null;

    @Field({ nullable: true })
    Use?: string | null;

    @Field(() => Float, { nullable: true })
    SqFtPerFloor?: number | null;

    @Field(() => Int, { nullable: true })
    FloorCount?: number | null;

    @Field(() => Float, { nullable: true })
    ReproductionCost?: number | null;

    @Field(() => Float, { nullable: true })
    PhysicalDepreciationPct?: number | null;

    @Field(() => Int, { nullable: true })
    YearConstructed?: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYear?: number | null;

    @Field({ nullable: true })
    Condition?: string | null;

    @Field(() => Float, { nullable: true })
    ObsolescencePct?: number | null;

    @Field(() => Float, { nullable: true })
    RemainderValue?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for County Assessor Improvement Segments
//****************************************************************************
@ObjectType()
export class RunindianataxCountyAssessorImprovementSegmentViewResult {
    @Field(() => [indianataxCountyAssessorImprovementSegment_])
    Results: indianataxCountyAssessorImprovementSegment_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCountyAssessorImprovementSegment_)
export class indianataxCountyAssessorImprovementSegmentResolver extends ResolverBase {
    @Query(() => RunindianataxCountyAssessorImprovementSegmentViewResult)
    async RunindianataxCountyAssessorImprovementSegmentViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorImprovementSegmentViewResult)
    async RunindianataxCountyAssessorImprovementSegmentViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorImprovementSegmentViewResult)
    async RunindianataxCountyAssessorImprovementSegmentDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'County Assessor Improvement Segments';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCountyAssessorImprovementSegment_, { nullable: true })
    async indianataxCountyAssessorImprovementSegment(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCountyAssessorImprovementSegment_ | null> {
        this.CheckUserReadPermissions('County Assessor Improvement Segments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorImprovementSegments')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Improvement Segments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('County Assessor Improvement Segments', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCountyAssessorImprovementSegment_)
    async CreateindianataxCountyAssessorImprovementSegment(
        @Arg('input', () => CreateindianataxCountyAssessorImprovementSegmentInput) input: CreateindianataxCountyAssessorImprovementSegmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('County Assessor Improvement Segments', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCountyAssessorImprovementSegment_)
    async UpdateindianataxCountyAssessorImprovementSegment(
        @Arg('input', () => UpdateindianataxCountyAssessorImprovementSegmentInput) input: UpdateindianataxCountyAssessorImprovementSegmentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('County Assessor Improvement Segments', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCountyAssessorImprovementSegment_)
    async DeleteindianataxCountyAssessorImprovementSegment(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('County Assessor Improvement Segments', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for County Assessor Improvements
//****************************************************************************
@ObjectType({ description: `One row per structure line from a Property Record Card\'s "Summary of Improvements" table (e.g. Building, Paving-Asph, Skyway enclosed). A parcel with multiple structures/cards has multiple rows. The Building row\'s SizeOrArea is the reliable, already-unit-multiplied total building square footage -- use it as a cross-check against the sum of this parcel\'s CountyAssessorImprovementSegment rows.` })
export class indianataxCountyAssessorImprovement_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel record this improvement belongs to.`}) 
    @MaxLength(36)
    CountyAssessorRecordID: string;
        
    @Field({nullable: true, description: `The card page this row was reported on (e.g. "1", "1A"). A parcel can have multiple cards for complex properties.`}) 
    @MaxLength(10)
    CardNumber?: string;
        
    @Field({nullable: true, description: `The structure type, e.g. "Building", "Paving -Asph", "Skyway enclosed walkway".`}) 
    @MaxLength(50)
    Use?: string;
        
    @Field({nullable: true, description: `Construction grade rating (e.g. "C", "B+"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.`}) 
    @MaxLength(50)
    Grade?: string;
        
    @Field(() => Int, {nullable: true, description: `The year this structure was originally constructed, per the card.`}) 
    YearConstructed?: number;
        
    @Field(() => Int, {nullable: true, description: `The effective year used for depreciation purposes (can differ from YearConstructed after a renovation).`}) 
    EffectiveYear?: number;
        
    @Field({nullable: true, description: `Condition rating letter (e.g. "A"). Widened to NVARCHAR(50) after the parser's row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.`}) 
    @MaxLength(50)
    Condition?: string;
        
    @Field(() => Float, {nullable: true, description: `The "Size or Area" figure on this structure's summary row. For the Building row, this is the true total building square footage (already accounts for multi-floor segments) -- more reliable than CountyAssessorRecord.EstimatedSqFt sourced any other way.`}) 
    SizeOrArea?: number;
        
    @Field(() => Float, {nullable: true, description: `The assessor's estimated replacement cost for this structure, per the card's cost-model computation.`}) 
    ReproductionCost?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Dep/Obs" figure on the summary row -- combined physical depreciation and obsolescence deduction from reproduction cost. See CountyAssessorImprovementSegment for the per-floor breakdown of physical depreciation and obsolescence separately.`}) 
    DepreciationObsolescence?: number;
        
    @Field(() => Float, {nullable: true, description: `The "REM Val" (remainder value) figure -- reproduction cost less depreciation/obsolescence, before the trend factor is applied.`}) 
    RemainderValue?: number;
        
    @Field(() => Float, {nullable: true, description: `The "% Cmp" (percent complete) figure, for structures under construction. 100 for a finished structure.`}) 
    PctComplete?: number;
        
    @Field(() => Float, {nullable: true, description: `The trend factor applied to remainder value to reach true tax value.`}) 
    TrendFactor?: number;
        
    @Field(() => Float, {nullable: true, description: `The "True Tax Value" figure -- this structure's contribution to the parcel's assessed improvement value.`}) 
    TrueTaxValue?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    CountyAssessorRecord?: string;
        
}

//****************************************************************************
// INPUT TYPE for County Assessor Improvements
//****************************************************************************
@InputType()
export class CreateindianataxCountyAssessorImprovementInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    CardNumber: string | null;

    @Field({ nullable: true })
    Use: string | null;

    @Field({ nullable: true })
    Grade: string | null;

    @Field(() => Int, { nullable: true })
    YearConstructed: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYear: number | null;

    @Field({ nullable: true })
    Condition: string | null;

    @Field(() => Float, { nullable: true })
    SizeOrArea: number | null;

    @Field(() => Float, { nullable: true })
    ReproductionCost: number | null;

    @Field(() => Float, { nullable: true })
    DepreciationObsolescence: number | null;

    @Field(() => Float, { nullable: true })
    RemainderValue: number | null;

    @Field(() => Float, { nullable: true })
    PctComplete: number | null;

    @Field(() => Float, { nullable: true })
    TrendFactor: number | null;

    @Field(() => Float, { nullable: true })
    TrueTaxValue: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for County Assessor Improvements
//****************************************************************************
@InputType()
export class UpdateindianataxCountyAssessorImprovementInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    CardNumber?: string | null;

    @Field({ nullable: true })
    Use?: string | null;

    @Field({ nullable: true })
    Grade?: string | null;

    @Field(() => Int, { nullable: true })
    YearConstructed?: number | null;

    @Field(() => Int, { nullable: true })
    EffectiveYear?: number | null;

    @Field({ nullable: true })
    Condition?: string | null;

    @Field(() => Float, { nullable: true })
    SizeOrArea?: number | null;

    @Field(() => Float, { nullable: true })
    ReproductionCost?: number | null;

    @Field(() => Float, { nullable: true })
    DepreciationObsolescence?: number | null;

    @Field(() => Float, { nullable: true })
    RemainderValue?: number | null;

    @Field(() => Float, { nullable: true })
    PctComplete?: number | null;

    @Field(() => Float, { nullable: true })
    TrendFactor?: number | null;

    @Field(() => Float, { nullable: true })
    TrueTaxValue?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for County Assessor Improvements
//****************************************************************************
@ObjectType()
export class RunindianataxCountyAssessorImprovementViewResult {
    @Field(() => [indianataxCountyAssessorImprovement_])
    Results: indianataxCountyAssessorImprovement_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCountyAssessorImprovement_)
export class indianataxCountyAssessorImprovementResolver extends ResolverBase {
    @Query(() => RunindianataxCountyAssessorImprovementViewResult)
    async RunindianataxCountyAssessorImprovementViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorImprovementViewResult)
    async RunindianataxCountyAssessorImprovementViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorImprovementViewResult)
    async RunindianataxCountyAssessorImprovementDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'County Assessor Improvements';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCountyAssessorImprovement_, { nullable: true })
    async indianataxCountyAssessorImprovement(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCountyAssessorImprovement_ | null> {
        this.CheckUserReadPermissions('County Assessor Improvements', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorImprovements')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Improvements', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('County Assessor Improvements', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCountyAssessorImprovement_)
    async CreateindianataxCountyAssessorImprovement(
        @Arg('input', () => CreateindianataxCountyAssessorImprovementInput) input: CreateindianataxCountyAssessorImprovementInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('County Assessor Improvements', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCountyAssessorImprovement_)
    async UpdateindianataxCountyAssessorImprovement(
        @Arg('input', () => UpdateindianataxCountyAssessorImprovementInput) input: UpdateindianataxCountyAssessorImprovementInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('County Assessor Improvements', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCountyAssessorImprovement_)
    async DeleteindianataxCountyAssessorImprovement(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('County Assessor Improvements', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for County Assessor Records
//****************************************************************************
@ObjectType({ description: `A parcel\'s record from its OWN county\'s live assessor GIS system (not the statewide DLGF/GIO pull Assessment is built from). Currently populated for Marion County only, from its ArcGIS-hosted assessor layer, but named generically since other counties may have their own equivalent systems worth the same treatment later.` })
export class indianataxCountyAssessorRecord_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel this record belongs to.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field(() => Int, {description: `Which county's own system this record came from.`}) 
    CountyNumber: number;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    OwnerName?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    OwnerAddress?: string;
        
    @Field({nullable: true}) 
    @MaxLength(100)
    OwnerCity?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    OwnerState?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    OwnerZip?: string;
        
    @Field({nullable: true}) 
    @MaxLength(32)
    PropertyClass?: string;
        
    @Field({nullable: true}) 
    @MaxLength(64)
    PropertySubClassDescription?: string;
        
    @Field(() => Float, {nullable: true, description: `Assessed land value per the county's own current system -- may be fresher than the statewide Assessment table for this parcel.`}) 
    AssessedLandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Assessed improvement value per the county's own current system.`}) 
    AssessedImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Assessed total value per the county's own current system.`}) 
    AssessedTotalAV?: number;
        
    @Field({nullable: true, description: `The county system's own internal parcel identifier (e.g. Marion's CAMAPARCELID), distinct from the statewide ParcelNumber.`}) 
    @MaxLength(50)
    CountyParcelID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(32)
    Neighborhood?: string;
        
    @Field({nullable: true}) 
    @MaxLength(5)
    TaxDistrictID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(1500)
    LegalDescription?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    Acreage?: string;
        
    @Field(() => Int, {nullable: true, description: `Estimated square footage. CAUTION: sourced from the Marion County ArcGIS layer's ESTSQFT field, which for a meaningful subset of rows (~29%, matches Parcel.Acreage * 43560) actually holds LAND square footage rather than building square footage -- confirmed 2026-08-23 against a real Property Record Card. Check SqFtSource: 'BuildingDetail' means this value was re-sourced from itemized per-floor data and is trustworthy for building-size analysis; NULL means it is either the original unverified ArcGIS value (use with caution, may be land area) or was cleared after being proven land-derived with no better source available.`}) 
    EstimatedSqFt?: number;
        
    @Field({nullable: true}) 
    @MaxLength(8)
    Status?: string;
        
    @Field({nullable: true, description: `When the county's OWN system last updated this record -- distinct from RetrievedAt, which is when WE fetched it.`}) 
    SourceModDate?: Date;
        
    @Field({description: `When we fetched this record.`}) 
    RetrievedAt: Date;
        
    @Field({nullable: true, description: `The SourceRegistry entry for the county system this came from.`}) 
    @MaxLength(36)
    SourceRegistryID?: string;
        
    @Field(() => Int, {nullable: true, description: `Year the primary structure was built, per the county's Tax History report.`}) 
    YearBuilt?: number;
        
    @Field({nullable: true, description: `Date of the last assessment change per the county's system.`}) 
    LastAssessmentChangeDate?: Date;
        
    @Field(() => Int, {nullable: true, description: `The tax year the tax-bill fields on this row (GrossAssessment through CurrentTaxDue) apply to.`}) 
    TaxYear?: number;
        
    @Field(() => Float, {nullable: true, description: `Gross assessment (land + improvements) for TaxYear, before deductions/exemptions.`}) 
    GrossAssessment?: number;
        
    @Field(() => Float, {nullable: true, description: `Total deductions/exemptions applied for TaxYear (e.g. homestead standard deduction, supplemental).`}) 
    DeductionsExemptionsTotal?: number;
        
    @Field(() => Float, {nullable: true, description: `Net assessment for TaxYear (gross minus deductions/exemptions) -- the actual tax base.`}) 
    NetAssessment?: number;
        
    @Field(() => Float, {nullable: true, description: `The tax rate applied for TaxYear, as a percentage (e.g. 2.729100 means 2.7291%).`}) 
    TaxRate?: number;
        
    @Field(() => Float, {nullable: true, description: `The actual computed net annual tax for TaxYear -- the real dollar tax amount, not just assessed value. This is data no other source in this schema provides.`}) 
    NetAnnualTax?: number;
        
    @Field(() => Float, {nullable: true, description: `Amount currently due, per the report at the time it was fetched (a snapshot, not necessarily current by the time this is read).`}) 
    CurrentTaxDue?: number;
        
    @Field({nullable: true, description: `Deed type for the most recent transfer (e.g. Warranty Deed), per the Tax History report.`}) 
    @MaxLength(50)
    DeedType?: string;
        
    @Field({nullable: true, description: `Deed execution date for the most recent transfer.`}) 
    DeedDate?: Date;
        
    @Field({nullable: true, description: `Date the deed was filed/recorded for the most recent transfer.`}) 
    FileDate?: Date;
        
    @Field({nullable: true, description: `When the Property Record Card / Tax History PDF reports were fetched for this parcel -- tracked separately from RetrievedAt (the GIS layer fetch) since these two sources are pulled at different times and paces (the reports have no bulk endpoint).`}) 
    ReportRetrievedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `How EstimatedSqFt was sourced/verified, in descending order of reliability: 'PropertyRecordCard' = computed from CountyAssessorImprovementSegment (SqFtPerFloor * FloorCount, summed and cross-checked against the card's own Building total) -- the most reliable source, correctly accounts for multi-floor segments. 'BuildingDetail' = summed from itemized per-floor building_detail data WITHOUT a floor-count multiplier -- confirmed 2026-08-23 to systematically undercount multi-floor buildings (e.g. a 10-floor segment counted as 1 floor), superseded by 'PropertyRecordCard' wherever available. NULL = original ArcGIS ESTSQFT value (unverified, may be land-area-derived) or cleared after being proven land-derived with no replacement source available.`}) 
    @MaxLength(20)
    SqFtSource?: string;
        
    @Field({nullable: true, description: `The SourceDocument row for this parcel's most recently fetched Property Record Card PDF. NULL until a PRC has been fetched for this parcel. Distinct from ReportRetrievedAt (a plain timestamp on this row) -- this links to the actual persisted PDF, its content hash, and its ExtractedText.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true, description: `The SourceDocument row for this parcel's most recently fetched Tax History Report PDF -- distinct from SourceDocumentID, which links the Property Record Card. NULL until a Tax History Report has been fetched for this parcel.`}) 
    @MaxLength(36)
    TaxHistorySourceDocumentID?: string;
        
    @Field({nullable: true, description: `The non-SF/non-acre unit of comparison this property should be valued per, when one applies: Unit (apartment dwelling units), Key (hotel/motel rooms), Bed (nursing home/hospital beds), or Door (self-storage doors). NULL means this property is compared per square foot (the default -- see EstimatedSqFt) or per acre (vacant land -- see Acreage), not per a unit count. Not populated by PRC parsing -- see ComparisonUnitCount.`}) 
    @MaxLength(20)
    ComparisonUnitType?: string;
        
    @Field(() => Float, {nullable: true, description: `The count of ComparisonUnitType for this property (e.g. number of apartment units, hotel keys, nursing beds, or storage doors). NULL until populated by a future CoStar-export import -- confirmed 2026-08-25 that Marion County's Property Record Card does not reliably expose this as a structured field (one large hotel's card had a free-text renovation note giving a room count; the rest of a small real sample had nothing usable).`}) 
    ComparisonUnitCount?: number;
        
    @Field(() => Int, {nullable: true, description: `Year built, sourced from a matched CoStarProperty row (CoStar "Year Built") -- ONLY populated when this parcel's own YearBuilt (Tax History Report-sourced) is null and exactly one unambiguous CoStar value exists for it (see backfill-costar-derived-fields.js). Kept separate from YearBuilt rather than merged into it -- the two sources must stay distinguishable per this project's CoStar-provenance convention. The Property Search grid's "Year Built" column shows YearBuilt when present, this as a marked fallback otherwise.`}) 
    CoStarYearBuilt?: number;
        
    @Field(() => Int, {nullable: true, description: `Rentable Building Area, sourced from a matched CoStarProperty row (CoStar "RBA") -- ONLY populated when exactly one unambiguous CoStar value exists for this parcel across its single-parcel-matched CoStarProperty rows (see backfill-costar-derived-fields.js). Distinct from EstimatedSqFt (total building SF from the PRC/ArcGIS layer) -- RBA is the rentable/leasable measure, a different physical quantity, not just a different source for the same number. Never merged into EstimatedSqFt.`}) 
    CoStarRBA?: number;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    SourceRegistry?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [indianataxCountyAssessorSaleHistory_])
    indianataxCountyAssessorSaleHistories_CountyAssessorRecordIDArray: indianataxCountyAssessorSaleHistory_[]; // Link to indianataxCountyAssessorSaleHistories
    
    @Field(() => [indianataxCountyAssessorImprovement_])
    indianataxCountyAssessorImprovements_CountyAssessorRecordIDArray: indianataxCountyAssessorImprovement_[]; // Link to indianataxCountyAssessorImprovements
    
    @Field(() => [indianataxCountyAssessorImprovementSegment_])
    indianataxCountyAssessorImprovementSegments_CountyAssessorRecordIDArray: indianataxCountyAssessorImprovementSegment_[]; // Link to indianataxCountyAssessorImprovementSegments
    
}

//****************************************************************************
// INPUT TYPE for County Assessor Records
//****************************************************************************
@InputType()
export class CreateindianataxCountyAssessorRecordInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    OwnerName: string | null;

    @Field({ nullable: true })
    OwnerAddress: string | null;

    @Field({ nullable: true })
    OwnerCity: string | null;

    @Field({ nullable: true })
    OwnerState: string | null;

    @Field({ nullable: true })
    OwnerZip: string | null;

    @Field({ nullable: true })
    PropertyClass: string | null;

    @Field({ nullable: true })
    PropertySubClassDescription: string | null;

    @Field(() => Float, { nullable: true })
    AssessedLandAV: number | null;

    @Field(() => Float, { nullable: true })
    AssessedImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    AssessedTotalAV: number | null;

    @Field({ nullable: true })
    CountyParcelID: string | null;

    @Field({ nullable: true })
    Neighborhood: string | null;

    @Field({ nullable: true })
    TaxDistrictID: string | null;

    @Field({ nullable: true })
    LegalDescription: string | null;

    @Field({ nullable: true })
    Acreage: string | null;

    @Field(() => Int, { nullable: true })
    EstimatedSqFt: number | null;

    @Field({ nullable: true })
    Status: string | null;

    @Field({ nullable: true })
    SourceModDate: Date | null;

    @Field({ nullable: true })
    RetrievedAt?: Date;

    @Field({ nullable: true })
    SourceRegistryID: string | null;

    @Field(() => Int, { nullable: true })
    YearBuilt: number | null;

    @Field({ nullable: true })
    LastAssessmentChangeDate: Date | null;

    @Field(() => Int, { nullable: true })
    TaxYear: number | null;

    @Field(() => Float, { nullable: true })
    GrossAssessment: number | null;

    @Field(() => Float, { nullable: true })
    DeductionsExemptionsTotal: number | null;

    @Field(() => Float, { nullable: true })
    NetAssessment: number | null;

    @Field(() => Float, { nullable: true })
    TaxRate: number | null;

    @Field(() => Float, { nullable: true })
    NetAnnualTax: number | null;

    @Field(() => Float, { nullable: true })
    CurrentTaxDue: number | null;

    @Field({ nullable: true })
    DeedType: string | null;

    @Field({ nullable: true })
    DeedDate: Date | null;

    @Field({ nullable: true })
    FileDate: Date | null;

    @Field({ nullable: true })
    ReportRetrievedAt: Date | null;

    @Field({ nullable: true })
    SqFtSource: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    TaxHistorySourceDocumentID: string | null;

    @Field({ nullable: true })
    ComparisonUnitType: string | null;

    @Field(() => Float, { nullable: true })
    ComparisonUnitCount: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearBuilt: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRBA: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for County Assessor Records
//****************************************************************************
@InputType()
export class UpdateindianataxCountyAssessorRecordInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    OwnerName?: string | null;

    @Field({ nullable: true })
    OwnerAddress?: string | null;

    @Field({ nullable: true })
    OwnerCity?: string | null;

    @Field({ nullable: true })
    OwnerState?: string | null;

    @Field({ nullable: true })
    OwnerZip?: string | null;

    @Field({ nullable: true })
    PropertyClass?: string | null;

    @Field({ nullable: true })
    PropertySubClassDescription?: string | null;

    @Field(() => Float, { nullable: true })
    AssessedLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    AssessedImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    AssessedTotalAV?: number | null;

    @Field({ nullable: true })
    CountyParcelID?: string | null;

    @Field({ nullable: true })
    Neighborhood?: string | null;

    @Field({ nullable: true })
    TaxDistrictID?: string | null;

    @Field({ nullable: true })
    LegalDescription?: string | null;

    @Field({ nullable: true })
    Acreage?: string | null;

    @Field(() => Int, { nullable: true })
    EstimatedSqFt?: number | null;

    @Field({ nullable: true })
    Status?: string | null;

    @Field({ nullable: true })
    SourceModDate?: Date | null;

    @Field({ nullable: true })
    RetrievedAt?: Date;

    @Field({ nullable: true })
    SourceRegistryID?: string | null;

    @Field(() => Int, { nullable: true })
    YearBuilt?: number | null;

    @Field({ nullable: true })
    LastAssessmentChangeDate?: Date | null;

    @Field(() => Int, { nullable: true })
    TaxYear?: number | null;

    @Field(() => Float, { nullable: true })
    GrossAssessment?: number | null;

    @Field(() => Float, { nullable: true })
    DeductionsExemptionsTotal?: number | null;

    @Field(() => Float, { nullable: true })
    NetAssessment?: number | null;

    @Field(() => Float, { nullable: true })
    TaxRate?: number | null;

    @Field(() => Float, { nullable: true })
    NetAnnualTax?: number | null;

    @Field(() => Float, { nullable: true })
    CurrentTaxDue?: number | null;

    @Field({ nullable: true })
    DeedType?: string | null;

    @Field({ nullable: true })
    DeedDate?: Date | null;

    @Field({ nullable: true })
    FileDate?: Date | null;

    @Field({ nullable: true })
    ReportRetrievedAt?: Date | null;

    @Field({ nullable: true })
    SqFtSource?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    TaxHistorySourceDocumentID?: string | null;

    @Field({ nullable: true })
    ComparisonUnitType?: string | null;

    @Field(() => Float, { nullable: true })
    ComparisonUnitCount?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarYearBuilt?: number | null;

    @Field(() => Int, { nullable: true })
    CoStarRBA?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for County Assessor Records
//****************************************************************************
@ObjectType()
export class RunindianataxCountyAssessorRecordViewResult {
    @Field(() => [indianataxCountyAssessorRecord_])
    Results: indianataxCountyAssessorRecord_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCountyAssessorRecord_)
export class indianataxCountyAssessorRecordResolver extends ResolverBase {
    @Query(() => RunindianataxCountyAssessorRecordViewResult)
    async RunindianataxCountyAssessorRecordViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorRecordViewResult)
    async RunindianataxCountyAssessorRecordViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorRecordViewResult)
    async RunindianataxCountyAssessorRecordDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'County Assessor Records';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCountyAssessorRecord_, { nullable: true })
    async indianataxCountyAssessorRecord(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCountyAssessorRecord_ | null> {
        this.CheckUserReadPermissions('County Assessor Records', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorRecords')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Records', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('County Assessor Records', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxCountyAssessorSaleHistory_])
    async indianataxCountyAssessorSaleHistories_CountyAssessorRecordIDArray(@Root() indianataxcountyassessorrecord_: indianataxCountyAssessorRecord_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Sale Histories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorSaleHistories')} WHERE ${provider.QuoteIdentifier('CountyAssessorRecordID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Sale Histories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxcountyassessorrecord_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Sale Histories', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorImprovement_])
    async indianataxCountyAssessorImprovements_CountyAssessorRecordIDArray(@Root() indianataxcountyassessorrecord_: indianataxCountyAssessorRecord_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Improvements', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorImprovements')} WHERE ${provider.QuoteIdentifier('CountyAssessorRecordID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Improvements', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxcountyassessorrecord_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Improvements', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorImprovementSegment_])
    async indianataxCountyAssessorImprovementSegments_CountyAssessorRecordIDArray(@Root() indianataxcountyassessorrecord_: indianataxCountyAssessorRecord_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Improvement Segments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorImprovementSegments')} WHERE ${provider.QuoteIdentifier('CountyAssessorRecordID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Improvement Segments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxcountyassessorrecord_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Improvement Segments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxCountyAssessorRecord_)
    async CreateindianataxCountyAssessorRecord(
        @Arg('input', () => CreateindianataxCountyAssessorRecordInput) input: CreateindianataxCountyAssessorRecordInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('County Assessor Records', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCountyAssessorRecord_)
    async UpdateindianataxCountyAssessorRecord(
        @Arg('input', () => UpdateindianataxCountyAssessorRecordInput) input: UpdateindianataxCountyAssessorRecordInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('County Assessor Records', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCountyAssessorRecord_)
    async DeleteindianataxCountyAssessorRecord(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('County Assessor Records', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for County Assessor Sale Histories
//****************************************************************************
@ObjectType({ description: `One ownership transfer/sale event from a parcel\'s Property Record Card sale history table.` })
export class indianataxCountyAssessorSaleHistory_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel record this sale belongs to.`}) 
    @MaxLength(36)
    CountyAssessorRecordID: string;
        
    @Field({nullable: true, description: `Date of the transfer/sale.`}) 
    SaleDate?: Date;
        
    @Field({nullable: true, description: `Grantor (seller) of record.`}) 
    @MaxLength(300)
    GrantorName?: string;
        
    @Field(() => Boolean, {nullable: true, description: `Whether the county flagged this as a valid (arms-length) sale, per the source report.`}) 
    IsValidSale?: boolean;
        
    @Field(() => Float, {nullable: true, description: `Sale/transfer amount.`}) 
    SaleAmount?: number;
        
    @Field({nullable: true, description: `Transfer type as recorded, e.g. Sale, Straight (non-sale transfer such as a trust conveyance).`}) 
    @MaxLength(50)
    SaleType?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    CountyAssessorRecord?: string;
        
}

//****************************************************************************
// INPUT TYPE for County Assessor Sale Histories
//****************************************************************************
@InputType()
export class CreateindianataxCountyAssessorSaleHistoryInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    SaleDate: Date | null;

    @Field({ nullable: true })
    GrantorName: string | null;

    @Field(() => Boolean, { nullable: true })
    IsValidSale: boolean | null;

    @Field(() => Float, { nullable: true })
    SaleAmount: number | null;

    @Field({ nullable: true })
    SaleType: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for County Assessor Sale Histories
//****************************************************************************
@InputType()
export class UpdateindianataxCountyAssessorSaleHistoryInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    CountyAssessorRecordID?: string;

    @Field({ nullable: true })
    SaleDate?: Date | null;

    @Field({ nullable: true })
    GrantorName?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsValidSale?: boolean | null;

    @Field(() => Float, { nullable: true })
    SaleAmount?: number | null;

    @Field({ nullable: true })
    SaleType?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for County Assessor Sale Histories
//****************************************************************************
@ObjectType()
export class RunindianataxCountyAssessorSaleHistoryViewResult {
    @Field(() => [indianataxCountyAssessorSaleHistory_])
    Results: indianataxCountyAssessorSaleHistory_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCountyAssessorSaleHistory_)
export class indianataxCountyAssessorSaleHistoryResolver extends ResolverBase {
    @Query(() => RunindianataxCountyAssessorSaleHistoryViewResult)
    async RunindianataxCountyAssessorSaleHistoryViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorSaleHistoryViewResult)
    async RunindianataxCountyAssessorSaleHistoryViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyAssessorSaleHistoryViewResult)
    async RunindianataxCountyAssessorSaleHistoryDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'County Assessor Sale Histories';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCountyAssessorSaleHistory_, { nullable: true })
    async indianataxCountyAssessorSaleHistory(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCountyAssessorSaleHistory_ | null> {
        this.CheckUserReadPermissions('County Assessor Sale Histories', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorSaleHistories')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Sale Histories', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('County Assessor Sale Histories', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCountyAssessorSaleHistory_)
    async CreateindianataxCountyAssessorSaleHistory(
        @Arg('input', () => CreateindianataxCountyAssessorSaleHistoryInput) input: CreateindianataxCountyAssessorSaleHistoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('County Assessor Sale Histories', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCountyAssessorSaleHistory_)
    async UpdateindianataxCountyAssessorSaleHistory(
        @Arg('input', () => UpdateindianataxCountyAssessorSaleHistoryInput) input: UpdateindianataxCountyAssessorSaleHistoryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('County Assessor Sale Histories', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCountyAssessorSaleHistory_)
    async DeleteindianataxCountyAssessorSaleHistory(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('County Assessor Sale Histories', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for County Resources
//****************************************************************************
@ObjectType({ description: `A county-level office/resource link relevant to property records (assessor, auditor, treasurer, recorder, GIS), sourced from NETR Online\'s public records directory. Reference directory, not a periodically-rescanned document source like SourceRegistry.` })
export class indianataxCountyResource_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The Indiana county this resource belongs to (as named by the source directory).`}) 
    @MaxLength(50)
    CountyName: string;
        
    @Field({description: `The resource's label as it appeared on the source page, e.g. "Marion Assessor" or "Recorder - Tapestry". Free text — county resource naming isn't standardized across the state.`}) 
    @MaxLength(200)
    ResourceLabel: string;
        
    @Field({nullable: true, description: `Best-effort category inferred from the label (Assessor/Auditor/Treasurer/Recorder/GIS/Other) — a categorization convenience, not authoritative.`}) 
    @MaxLength(30)
    ResourceCategory?: string;
        
    @Field({description: `URL of the resource.`}) 
    @MaxLength(1000)
    ResourceURL: string;
        
    @Field({nullable: true, description: `Phone number, if the source directory listed one.`}) 
    @MaxLength(30)
    Phone?: string;
        
    @Field({nullable: true, description: `The SourceRegistry entry this was gathered from (the NETR Online county directory).`}) 
    @MaxLength(36)
    SourceRegistryID?: string;
        
    @Field({description: `When this resource link was gathered.`}) 
    DiscoveredAt: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    SourceRegistry?: string;
        
}

//****************************************************************************
// INPUT TYPE for County Resources
//****************************************************************************
@InputType()
export class CreateindianataxCountyResourceInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    CountyName?: string;

    @Field({ nullable: true })
    ResourceLabel?: string;

    @Field({ nullable: true })
    ResourceCategory: string | null;

    @Field({ nullable: true })
    ResourceURL?: string;

    @Field({ nullable: true })
    Phone: string | null;

    @Field({ nullable: true })
    SourceRegistryID: string | null;

    @Field({ nullable: true })
    DiscoveredAt?: Date;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for County Resources
//****************************************************************************
@InputType()
export class UpdateindianataxCountyResourceInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    CountyName?: string;

    @Field({ nullable: true })
    ResourceLabel?: string;

    @Field({ nullable: true })
    ResourceCategory?: string | null;

    @Field({ nullable: true })
    ResourceURL?: string;

    @Field({ nullable: true })
    Phone?: string | null;

    @Field({ nullable: true })
    SourceRegistryID?: string | null;

    @Field({ nullable: true })
    DiscoveredAt?: Date;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for County Resources
//****************************************************************************
@ObjectType()
export class RunindianataxCountyResourceViewResult {
    @Field(() => [indianataxCountyResource_])
    Results: indianataxCountyResource_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxCountyResource_)
export class indianataxCountyResourceResolver extends ResolverBase {
    @Query(() => RunindianataxCountyResourceViewResult)
    async RunindianataxCountyResourceViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyResourceViewResult)
    async RunindianataxCountyResourceViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxCountyResourceViewResult)
    async RunindianataxCountyResourceDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'County Resources';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxCountyResource_, { nullable: true })
    async indianataxCountyResource(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxCountyResource_ | null> {
        this.CheckUserReadPermissions('County Resources', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyResources')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Resources', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('County Resources', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxCountyResource_)
    async CreateindianataxCountyResource(
        @Arg('input', () => CreateindianataxCountyResourceInput) input: CreateindianataxCountyResourceInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('County Resources', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxCountyResource_)
    async UpdateindianataxCountyResource(
        @Arg('input', () => UpdateindianataxCountyResourceInput) input: UpdateindianataxCountyResourceInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('County Resources', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxCountyResource_)
    async DeleteindianataxCountyResource(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('County Resources', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for DLGF Building Details
//****************************************************************************
@ObjectType({ description: `DLGF/GIO statewide geodatabase BUILDINGDETAIL table, C&I slice. Floor/section pricing rows within a building (use code, SF, SF rate, framing, sprinkler, unit config).` })
export class indianataxDLGFBuildingDetail_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ParcelID: string;
        
    @Field() 
    @MaxLength(36)
    SourceDocumentID: string;
        
    @Field(() => Int) 
    SourceYear: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    BuildingNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    FloorNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    SectionLetterOrNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    PricingKey?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    UseCode?: string;
        
    @Field(() => Float, {nullable: true}) 
    SquareFootArea?: number;
        
    @Field(() => Float, {nullable: true}) 
    SquareFootRate?: number;
        
    @Field(() => Float, {nullable: true}) 
    FramingType?: number;
        
    @Field(() => Float, {nullable: true}) 
    WallType?: number;
        
    @Field(() => Float, {nullable: true}) 
    WallHeight?: number;
        
    @Field(() => Float, {nullable: true}) 
    HeatingACValueAdjustment?: number;
        
    @Field(() => Float, {nullable: true}) 
    SprinklerValueAdjustment?: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    AverageDepthForStripRetail?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    IndividuallyOwnedUnit?: string;
        
    @Field(() => Float, {nullable: true}) 
    IndividuallyOwnedUnitSize?: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ConfigurationCode?: string;
        
    @Field(() => Float, {nullable: true}) 
    NumberOfUnits?: number;
        
    @Field(() => Float, {nullable: true}) 
    AverageUnitSize?: number;
        
    @Field(() => Int, {nullable: true}) 
    ImprovementInstanceNumber?: number;
        
    @Field(() => Int, {nullable: true}) 
    BuildingInstanceNumber?: number;
        
    @Field(() => Int, {nullable: true}) 
    BuildingDetailInstanceNumber?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for DLGF Building Details
//****************************************************************************
@InputType()
export class CreateindianataxDLGFBuildingDetailInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    BuildingNumber: string | null;

    @Field({ nullable: true })
    FloorNumber: string | null;

    @Field({ nullable: true })
    SectionLetterOrNumber: string | null;

    @Field({ nullable: true })
    PricingKey: string | null;

    @Field({ nullable: true })
    UseCode: string | null;

    @Field(() => Float, { nullable: true })
    SquareFootArea: number | null;

    @Field(() => Float, { nullable: true })
    SquareFootRate: number | null;

    @Field(() => Float, { nullable: true })
    FramingType: number | null;

    @Field(() => Float, { nullable: true })
    WallType: number | null;

    @Field(() => Float, { nullable: true })
    WallHeight: number | null;

    @Field(() => Float, { nullable: true })
    HeatingACValueAdjustment: number | null;

    @Field(() => Float, { nullable: true })
    SprinklerValueAdjustment: number | null;

    @Field({ nullable: true })
    AverageDepthForStripRetail: string | null;

    @Field({ nullable: true })
    IndividuallyOwnedUnit: string | null;

    @Field(() => Float, { nullable: true })
    IndividuallyOwnedUnitSize: number | null;

    @Field({ nullable: true })
    ConfigurationCode: string | null;

    @Field(() => Float, { nullable: true })
    NumberOfUnits: number | null;

    @Field(() => Float, { nullable: true })
    AverageUnitSize: number | null;

    @Field(() => Int, { nullable: true })
    ImprovementInstanceNumber: number | null;

    @Field(() => Int, { nullable: true })
    BuildingInstanceNumber: number | null;

    @Field(() => Int, { nullable: true })
    BuildingDetailInstanceNumber: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for DLGF Building Details
//****************************************************************************
@InputType()
export class UpdateindianataxDLGFBuildingDetailInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    BuildingNumber?: string | null;

    @Field({ nullable: true })
    FloorNumber?: string | null;

    @Field({ nullable: true })
    SectionLetterOrNumber?: string | null;

    @Field({ nullable: true })
    PricingKey?: string | null;

    @Field({ nullable: true })
    UseCode?: string | null;

    @Field(() => Float, { nullable: true })
    SquareFootArea?: number | null;

    @Field(() => Float, { nullable: true })
    SquareFootRate?: number | null;

    @Field(() => Float, { nullable: true })
    FramingType?: number | null;

    @Field(() => Float, { nullable: true })
    WallType?: number | null;

    @Field(() => Float, { nullable: true })
    WallHeight?: number | null;

    @Field(() => Float, { nullable: true })
    HeatingACValueAdjustment?: number | null;

    @Field(() => Float, { nullable: true })
    SprinklerValueAdjustment?: number | null;

    @Field({ nullable: true })
    AverageDepthForStripRetail?: string | null;

    @Field({ nullable: true })
    IndividuallyOwnedUnit?: string | null;

    @Field(() => Float, { nullable: true })
    IndividuallyOwnedUnitSize?: number | null;

    @Field({ nullable: true })
    ConfigurationCode?: string | null;

    @Field(() => Float, { nullable: true })
    NumberOfUnits?: number | null;

    @Field(() => Float, { nullable: true })
    AverageUnitSize?: number | null;

    @Field(() => Int, { nullable: true })
    ImprovementInstanceNumber?: number | null;

    @Field(() => Int, { nullable: true })
    BuildingInstanceNumber?: number | null;

    @Field(() => Int, { nullable: true })
    BuildingDetailInstanceNumber?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for DLGF Building Details
//****************************************************************************
@ObjectType()
export class RunindianataxDLGFBuildingDetailViewResult {
    @Field(() => [indianataxDLGFBuildingDetail_])
    Results: indianataxDLGFBuildingDetail_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDLGFBuildingDetail_)
export class indianataxDLGFBuildingDetailResolver extends ResolverBase {
    @Query(() => RunindianataxDLGFBuildingDetailViewResult)
    async RunindianataxDLGFBuildingDetailViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFBuildingDetailViewResult)
    async RunindianataxDLGFBuildingDetailViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFBuildingDetailViewResult)
    async RunindianataxDLGFBuildingDetailDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'DLGF Building Details';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDLGFBuildingDetail_, { nullable: true })
    async indianataxDLGFBuildingDetail(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDLGFBuildingDetail_ | null> {
        this.CheckUserReadPermissions('DLGF Building Details', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildingDetails')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Building Details', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('DLGF Building Details', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDLGFBuildingDetail_)
    async CreateindianataxDLGFBuildingDetail(
        @Arg('input', () => CreateindianataxDLGFBuildingDetailInput) input: CreateindianataxDLGFBuildingDetailInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('DLGF Building Details', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDLGFBuildingDetail_)
    async UpdateindianataxDLGFBuildingDetail(
        @Arg('input', () => UpdateindianataxDLGFBuildingDetailInput) input: UpdateindianataxDLGFBuildingDetailInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('DLGF Building Details', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDLGFBuildingDetail_)
    async DeleteindianataxDLGFBuildingDetail(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('DLGF Building Details', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for DLGF Buildings
//****************************************************************************
@ObjectType({ description: `DLGF/GIO statewide geodatabase BUILDING table, C&I slice (class 300-499, all 92 counties). One row per building. Independent of the PRC-sourced CountyAssessorImprovement -- kept separate as a cross-check source. Every row carries SourceDocumentID (the gdb, DocumentType StatewideParcelDataset).` })
export class indianataxDLGFBuilding_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ParcelID: string;
        
    @Field() 
    @MaxLength(36)
    SourceDocumentID: string;
        
    @Field(() => Int) 
    SourceYear: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    BuildingNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    PricingKeyPredominantUse?: string;
        
    @Field(() => Float, {nullable: true}) 
    NumberOfFloors?: number;
        
    @Field(() => Float, {nullable: true}) 
    TotalSquareFootArea?: number;
        
    @Field(() => Float, {nullable: true}) 
    TotalBaseValue?: number;
        
    @Field(() => Float, {nullable: true}) 
    PlumbingFixturesValue?: number;
        
    @Field(() => Float, {nullable: true}) 
    SpecialFeaturesValue?: number;
        
    @Field(() => Float, {nullable: true}) 
    ExteriorFeaturesValue?: number;
        
    @Field(() => Int, {nullable: true}) 
    ImprovementInstanceNumber?: number;
        
    @Field(() => Int, {nullable: true}) 
    BuildingInstanceNumber?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for DLGF Buildings
//****************************************************************************
@InputType()
export class CreateindianataxDLGFBuildingInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    BuildingNumber: string | null;

    @Field({ nullable: true })
    PricingKeyPredominantUse: string | null;

    @Field(() => Float, { nullable: true })
    NumberOfFloors: number | null;

    @Field(() => Float, { nullable: true })
    TotalSquareFootArea: number | null;

    @Field(() => Float, { nullable: true })
    TotalBaseValue: number | null;

    @Field(() => Float, { nullable: true })
    PlumbingFixturesValue: number | null;

    @Field(() => Float, { nullable: true })
    SpecialFeaturesValue: number | null;

    @Field(() => Float, { nullable: true })
    ExteriorFeaturesValue: number | null;

    @Field(() => Int, { nullable: true })
    ImprovementInstanceNumber: number | null;

    @Field(() => Int, { nullable: true })
    BuildingInstanceNumber: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for DLGF Buildings
//****************************************************************************
@InputType()
export class UpdateindianataxDLGFBuildingInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    BuildingNumber?: string | null;

    @Field({ nullable: true })
    PricingKeyPredominantUse?: string | null;

    @Field(() => Float, { nullable: true })
    NumberOfFloors?: number | null;

    @Field(() => Float, { nullable: true })
    TotalSquareFootArea?: number | null;

    @Field(() => Float, { nullable: true })
    TotalBaseValue?: number | null;

    @Field(() => Float, { nullable: true })
    PlumbingFixturesValue?: number | null;

    @Field(() => Float, { nullable: true })
    SpecialFeaturesValue?: number | null;

    @Field(() => Float, { nullable: true })
    ExteriorFeaturesValue?: number | null;

    @Field(() => Int, { nullable: true })
    ImprovementInstanceNumber?: number | null;

    @Field(() => Int, { nullable: true })
    BuildingInstanceNumber?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for DLGF Buildings
//****************************************************************************
@ObjectType()
export class RunindianataxDLGFBuildingViewResult {
    @Field(() => [indianataxDLGFBuilding_])
    Results: indianataxDLGFBuilding_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDLGFBuilding_)
export class indianataxDLGFBuildingResolver extends ResolverBase {
    @Query(() => RunindianataxDLGFBuildingViewResult)
    async RunindianataxDLGFBuildingViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFBuildingViewResult)
    async RunindianataxDLGFBuildingViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFBuildingViewResult)
    async RunindianataxDLGFBuildingDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'DLGF Buildings';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDLGFBuilding_, { nullable: true })
    async indianataxDLGFBuilding(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDLGFBuilding_ | null> {
        this.CheckUserReadPermissions('DLGF Buildings', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildings')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Buildings', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('DLGF Buildings', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDLGFBuilding_)
    async CreateindianataxDLGFBuilding(
        @Arg('input', () => CreateindianataxDLGFBuildingInput) input: CreateindianataxDLGFBuildingInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('DLGF Buildings', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDLGFBuilding_)
    async UpdateindianataxDLGFBuilding(
        @Arg('input', () => UpdateindianataxDLGFBuildingInput) input: UpdateindianataxDLGFBuildingInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('DLGF Buildings', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDLGFBuilding_)
    async DeleteindianataxDLGFBuilding(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('DLGF Buildings', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for DLGF Improvements
//****************************************************************************
@ObjectType({ description: `DLGF/GIO statewide geodatabase IMPROVE table, C&I slice. One row per improvement -- carries grade, year/effective-year built, condition, ReplacementCost and physical/obsolescence depreciation (the cost-approach RCN inputs, OPP-22) plus the AV cap-tier split.` })
export class indianataxDLGFImprovement_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ParcelID: string;
        
    @Field({description: `The SourceDocument for the DLGF geodatabase pull this row came from (DocumentType StatewideParcelDataset).`}) 
    @MaxLength(36)
    SourceDocumentID: string;
        
    @Field(() => Int) 
    SourceYear: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    DwellingOrBuildingNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    ImprovementInstanceNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ImprovementTypeCode?: string;
        
    @Field(() => Float, {nullable: true}) 
    StoryHeightOrHeight?: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    ConstructionTypeCode?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    YearConstructed?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    YearRemodeled?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    EffectiveConstructionYear?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    Grade?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    ConditionCode?: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    NeighborhoodCode?: string;
        
    @Field(() => Float, {nullable: true}) 
    ImprovementSize?: number;
        
    @Field(() => Float, {nullable: true, description: `Replacement cost new for this improvement (before depreciation). A cost-approach input.`}) 
    ReplacementCost?: number;
        
    @Field(() => Float, {nullable: true}) 
    AppraisedValue?: number;
        
    @Field(() => Float, {nullable: true}) 
    PhysicalDepreciationPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    ObsolescenceDepreciationPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    PercentComplete?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVImprovements1PercentCap?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVImprovements2PercentCap?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVImprovements3PercentCap?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for DLGF Improvements
//****************************************************************************
@InputType()
export class CreateindianataxDLGFImprovementInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    DwellingOrBuildingNumber: string | null;

    @Field({ nullable: true })
    ImprovementInstanceNumber: string | null;

    @Field({ nullable: true })
    ImprovementTypeCode: string | null;

    @Field(() => Float, { nullable: true })
    StoryHeightOrHeight: number | null;

    @Field({ nullable: true })
    ConstructionTypeCode: string | null;

    @Field({ nullable: true })
    YearConstructed: string | null;

    @Field({ nullable: true })
    YearRemodeled: string | null;

    @Field({ nullable: true })
    EffectiveConstructionYear: string | null;

    @Field({ nullable: true })
    Grade: string | null;

    @Field({ nullable: true })
    ConditionCode: string | null;

    @Field({ nullable: true })
    NeighborhoodCode: string | null;

    @Field(() => Float, { nullable: true })
    ImprovementSize: number | null;

    @Field(() => Float, { nullable: true })
    ReplacementCost: number | null;

    @Field(() => Float, { nullable: true })
    AppraisedValue: number | null;

    @Field(() => Float, { nullable: true })
    PhysicalDepreciationPct: number | null;

    @Field(() => Float, { nullable: true })
    ObsolescenceDepreciationPct: number | null;

    @Field(() => Float, { nullable: true })
    PercentComplete: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements1PercentCap: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements2PercentCap: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements3PercentCap: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for DLGF Improvements
//****************************************************************************
@InputType()
export class UpdateindianataxDLGFImprovementInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    DwellingOrBuildingNumber?: string | null;

    @Field({ nullable: true })
    ImprovementInstanceNumber?: string | null;

    @Field({ nullable: true })
    ImprovementTypeCode?: string | null;

    @Field(() => Float, { nullable: true })
    StoryHeightOrHeight?: number | null;

    @Field({ nullable: true })
    ConstructionTypeCode?: string | null;

    @Field({ nullable: true })
    YearConstructed?: string | null;

    @Field({ nullable: true })
    YearRemodeled?: string | null;

    @Field({ nullable: true })
    EffectiveConstructionYear?: string | null;

    @Field({ nullable: true })
    Grade?: string | null;

    @Field({ nullable: true })
    ConditionCode?: string | null;

    @Field({ nullable: true })
    NeighborhoodCode?: string | null;

    @Field(() => Float, { nullable: true })
    ImprovementSize?: number | null;

    @Field(() => Float, { nullable: true })
    ReplacementCost?: number | null;

    @Field(() => Float, { nullable: true })
    AppraisedValue?: number | null;

    @Field(() => Float, { nullable: true })
    PhysicalDepreciationPct?: number | null;

    @Field(() => Float, { nullable: true })
    ObsolescenceDepreciationPct?: number | null;

    @Field(() => Float, { nullable: true })
    PercentComplete?: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements1PercentCap?: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements2PercentCap?: number | null;

    @Field(() => Float, { nullable: true })
    AVImprovements3PercentCap?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for DLGF Improvements
//****************************************************************************
@ObjectType()
export class RunindianataxDLGFImprovementViewResult {
    @Field(() => [indianataxDLGFImprovement_])
    Results: indianataxDLGFImprovement_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDLGFImprovement_)
export class indianataxDLGFImprovementResolver extends ResolverBase {
    @Query(() => RunindianataxDLGFImprovementViewResult)
    async RunindianataxDLGFImprovementViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFImprovementViewResult)
    async RunindianataxDLGFImprovementViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFImprovementViewResult)
    async RunindianataxDLGFImprovementDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'DLGF Improvements';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDLGFImprovement_, { nullable: true })
    async indianataxDLGFImprovement(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDLGFImprovement_ | null> {
        this.CheckUserReadPermissions('DLGF Improvements', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFImprovements')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Improvements', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('DLGF Improvements', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDLGFImprovement_)
    async CreateindianataxDLGFImprovement(
        @Arg('input', () => CreateindianataxDLGFImprovementInput) input: CreateindianataxDLGFImprovementInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('DLGF Improvements', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDLGFImprovement_)
    async UpdateindianataxDLGFImprovement(
        @Arg('input', () => UpdateindianataxDLGFImprovementInput) input: UpdateindianataxDLGFImprovementInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('DLGF Improvements', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDLGFImprovement_)
    async DeleteindianataxDLGFImprovement(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('DLGF Improvements', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for DLGF Lands
//****************************************************************************
@ObjectType({ description: `DLGF/GIO statewide geodatabase LAND table, C&I slice. One row per land segment (frontage/depth, base rate, acreage, SF, soil, influence factors, AV cap-tier split).` })
export class indianataxDLGFLand_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ParcelID: string;
        
    @Field() 
    @MaxLength(36)
    SourceDocumentID: string;
        
    @Field(() => Int) 
    SourceYear: number;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    LandInstanceNumber?: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    LandLotTypeCode?: string;
        
    @Field(() => Float, {nullable: true}) 
    ActualFrontage?: number;
        
    @Field(() => Float, {nullable: true}) 
    EffectiveFrontage?: number;
        
    @Field(() => Float, {nullable: true}) 
    EffectiveDepth?: number;
        
    @Field(() => Float, {nullable: true}) 
    BaseRate?: number;
        
    @Field(() => Float, {nullable: true}) 
    AppraisedValue?: number;
        
    @Field(() => Float, {nullable: true}) 
    Acreage?: number;
        
    @Field(() => Float, {nullable: true}) 
    SquareFeet?: number;
        
    @Field({nullable: true}) 
    @MaxLength(20)
    SoilID?: string;
        
    @Field(() => Float, {nullable: true}) 
    SoilProductivityFactor?: number;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    InfluenceFactorCode1?: string;
        
    @Field(() => Float, {nullable: true}) 
    InfluenceFactor1?: number;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    InfluenceFactorCode2?: string;
        
    @Field(() => Float, {nullable: true}) 
    InfluenceFactor2?: number;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    InfluenceFactorCode3?: string;
        
    @Field(() => Float, {nullable: true}) 
    InfluenceFactor3?: number;
        
    @Field(() => Float, {nullable: true}) 
    DepthFactor?: number;
        
    @Field(() => Float, {nullable: true}) 
    AcreageFactor?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVLand1PercentCap?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVLand2PercentCap?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVLand3PercentCap?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for DLGF Lands
//****************************************************************************
@InputType()
export class CreateindianataxDLGFLandInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    LandInstanceNumber: string | null;

    @Field({ nullable: true })
    LandLotTypeCode: string | null;

    @Field(() => Float, { nullable: true })
    ActualFrontage: number | null;

    @Field(() => Float, { nullable: true })
    EffectiveFrontage: number | null;

    @Field(() => Float, { nullable: true })
    EffectiveDepth: number | null;

    @Field(() => Float, { nullable: true })
    BaseRate: number | null;

    @Field(() => Float, { nullable: true })
    AppraisedValue: number | null;

    @Field(() => Float, { nullable: true })
    Acreage: number | null;

    @Field(() => Float, { nullable: true })
    SquareFeet: number | null;

    @Field({ nullable: true })
    SoilID: string | null;

    @Field(() => Float, { nullable: true })
    SoilProductivityFactor: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode1: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor1: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode2: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor2: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode3: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor3: number | null;

    @Field(() => Float, { nullable: true })
    DepthFactor: number | null;

    @Field(() => Float, { nullable: true })
    AcreageFactor: number | null;

    @Field(() => Float, { nullable: true })
    AVLand1PercentCap: number | null;

    @Field(() => Float, { nullable: true })
    AVLand2PercentCap: number | null;

    @Field(() => Float, { nullable: true })
    AVLand3PercentCap: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for DLGF Lands
//****************************************************************************
@InputType()
export class UpdateindianataxDLGFLandInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    SourceYear?: number;

    @Field({ nullable: true })
    LandInstanceNumber?: string | null;

    @Field({ nullable: true })
    LandLotTypeCode?: string | null;

    @Field(() => Float, { nullable: true })
    ActualFrontage?: number | null;

    @Field(() => Float, { nullable: true })
    EffectiveFrontage?: number | null;

    @Field(() => Float, { nullable: true })
    EffectiveDepth?: number | null;

    @Field(() => Float, { nullable: true })
    BaseRate?: number | null;

    @Field(() => Float, { nullable: true })
    AppraisedValue?: number | null;

    @Field(() => Float, { nullable: true })
    Acreage?: number | null;

    @Field(() => Float, { nullable: true })
    SquareFeet?: number | null;

    @Field({ nullable: true })
    SoilID?: string | null;

    @Field(() => Float, { nullable: true })
    SoilProductivityFactor?: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode1?: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor1?: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode2?: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor2?: number | null;

    @Field({ nullable: true })
    InfluenceFactorCode3?: string | null;

    @Field(() => Float, { nullable: true })
    InfluenceFactor3?: number | null;

    @Field(() => Float, { nullable: true })
    DepthFactor?: number | null;

    @Field(() => Float, { nullable: true })
    AcreageFactor?: number | null;

    @Field(() => Float, { nullable: true })
    AVLand1PercentCap?: number | null;

    @Field(() => Float, { nullable: true })
    AVLand2PercentCap?: number | null;

    @Field(() => Float, { nullable: true })
    AVLand3PercentCap?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for DLGF Lands
//****************************************************************************
@ObjectType()
export class RunindianataxDLGFLandViewResult {
    @Field(() => [indianataxDLGFLand_])
    Results: indianataxDLGFLand_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDLGFLand_)
export class indianataxDLGFLandResolver extends ResolverBase {
    @Query(() => RunindianataxDLGFLandViewResult)
    async RunindianataxDLGFLandViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFLandViewResult)
    async RunindianataxDLGFLandViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDLGFLandViewResult)
    async RunindianataxDLGFLandDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'DLGF Lands';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDLGFLand_, { nullable: true })
    async indianataxDLGFLand(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDLGFLand_ | null> {
        this.CheckUserReadPermissions('DLGF Lands', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFLands')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Lands', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('DLGF Lands', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDLGFLand_)
    async CreateindianataxDLGFLand(
        @Arg('input', () => CreateindianataxDLGFLandInput) input: CreateindianataxDLGFLandInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('DLGF Lands', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDLGFLand_)
    async UpdateindianataxDLGFLand(
        @Arg('input', () => UpdateindianataxDLGFLandInput) input: UpdateindianataxDLGFLandInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('DLGF Lands', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDLGFLand_)
    async DeleteindianataxDLGFLand(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('DLGF Lands', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Document Acquisitions
//****************************************************************************
@ObjectType({ description: `The mechanical, high-volume, per-subject fetch-with-retry acquisition tracker: one row per (Parcel, DocumentType) being fetched from a source that requires HTTP retries and can fail. Tracks attempt count, last error, retry timing, and escalation to human review after repeated failure -- the "what has been / needs to be researched, when, was it successful, and until it is" ledger. Distinct from SourceRegistry/DocumentCatalog (editorial discovery of unstructured documents) and ResearchTask (deliberately deferred research decisions).` })
export class indianataxDocumentAcquisition_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel this acquisition tracks a document for.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field({description: `Which document type is being fetched for this parcel -- a deliberate subset of SourceDocument.DocumentType (only the mechanically-fetched, per-parcel types: PropertyRecordCard, TaxHistoryReport). Together with ParcelID, the real uniqueness key.`}) 
    @MaxLength(30)
    DocumentType: string;
        
    @Field({description: `Human-legible slug mirroring the on-disk file-naming grammar (e.g. "marion_prc_8050459_2026"), so a tracker row, a SourceDocument.RawFilePath, and a file on disk can be visually correlated. Informational/indexed only -- NOT the uniqueness key, since it legitimately changes once AssessmentYear becomes known from a successful fetch. See docs/NAMING_AND_RETENTION.md in the Indiana_Tax_Expert repo for the full grammar.`}) 
    @MaxLength(150)
    SubjectKey: string;
        
    @Field(() => Int, {nullable: true, description: `The assessment year of the most recently successfully fetched document for this (Parcel, DocumentType). NULL until first success -- not knowable before then, since these endpoints don't take a year parameter; you get whichever report is currently on file.`}) 
    AssessmentYear?: number;
        
    @Field({description: `InProgress (never yet resolved) / Succeeded (current SourceDocumentID is valid and current) / Failed (most recent attempt failed, eligible for retry at NextAttemptDueAt) / NeedsReview (failed AttemptCount times at or beyond the escalation ceiling -- excluded from automatic retry, needs deliberate follow-up).`}) 
    @MaxLength(20)
    Status: string;
        
    @Field(() => Int, {description: `Count of OUTER (script-run-level) acquisition attempts -- each of which already wraps up to 8 inner HTTP retries internally. Escalates Status to NeedsReview once this reaches 3.`}) 
    AttemptCount: number;
        
    @Field({description: `When this (Parcel, DocumentType) was first attempted.`}) 
    FirstAttemptedAt: Date;
        
    @Field({description: `When this (Parcel, DocumentType) was most recently attempted, successful or not.`}) 
    LastAttemptedAt: Date;
        
    @Field({nullable: true, description: `When this (Parcel, DocumentType) was most recently successfully fetched and parsed. NULL if never successful.`}) 
    LastSucceededAt?: Date;
        
    @Field({nullable: true, description: `Short machine-oriented error identifier from the most recent failed attempt (e.g. "bad XRef entry", "not a PDF", "HTTP 500"). Cleared on success.`}) 
    @MaxLength(100)
    LastErrorCode?: string;
        
    @Field({nullable: true, description: `Full error message from the most recent failed attempt. Cleared on success.`}) 
    @MaxLength(500)
    LastErrorMessage?: string;
        
    @Field({nullable: true, description: `Earliest time a bulk fetch run should retry this (Parcel, DocumentType) again, after a failure below the escalation ceiling. NULL once Succeeded or NeedsReview (nothing more to schedule).`}) 
    NextAttemptDueAt?: Date;
        
    @Field({nullable: true, description: `When Status flipped to NeedsReview (AttemptCount reached the escalation ceiling). NULL unless currently or previously escalated.`}) 
    EscalatedAt?: Date;
        
    @Field({nullable: true, description: `The SourceDocument produced by the most recent successful fetch. NULL until Succeeded at least once. Mirrors (does not replace) CountyAssessorRecord.SourceDocumentID/TaxHistorySourceDocumentID, which are set to the same value in the same transaction.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true, description: `Free-text notes -- e.g. a manual explanation of why a NeedsReview row was set back to Failed for another retry attempt.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Document Acquisitions
//****************************************************************************
@InputType()
export class CreateindianataxDocumentAcquisitionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    DocumentType?: string;

    @Field({ nullable: true })
    SubjectKey?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field(() => Int, { nullable: true })
    AttemptCount?: number;

    @Field({ nullable: true })
    FirstAttemptedAt?: Date;

    @Field({ nullable: true })
    LastAttemptedAt?: Date;

    @Field({ nullable: true })
    LastSucceededAt: Date | null;

    @Field({ nullable: true })
    LastErrorCode: string | null;

    @Field({ nullable: true })
    LastErrorMessage: string | null;

    @Field({ nullable: true })
    NextAttemptDueAt: Date | null;

    @Field({ nullable: true })
    EscalatedAt: Date | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Document Acquisitions
//****************************************************************************
@InputType()
export class UpdateindianataxDocumentAcquisitionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    DocumentType?: string;

    @Field({ nullable: true })
    SubjectKey?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field(() => Int, { nullable: true })
    AttemptCount?: number;

    @Field({ nullable: true })
    FirstAttemptedAt?: Date;

    @Field({ nullable: true })
    LastAttemptedAt?: Date;

    @Field({ nullable: true })
    LastSucceededAt?: Date | null;

    @Field({ nullable: true })
    LastErrorCode?: string | null;

    @Field({ nullable: true })
    LastErrorMessage?: string | null;

    @Field({ nullable: true })
    NextAttemptDueAt?: Date | null;

    @Field({ nullable: true })
    EscalatedAt?: Date | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Document Acquisitions
//****************************************************************************
@ObjectType()
export class RunindianataxDocumentAcquisitionViewResult {
    @Field(() => [indianataxDocumentAcquisition_])
    Results: indianataxDocumentAcquisition_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDocumentAcquisition_)
export class indianataxDocumentAcquisitionResolver extends ResolverBase {
    @Query(() => RunindianataxDocumentAcquisitionViewResult)
    async RunindianataxDocumentAcquisitionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDocumentAcquisitionViewResult)
    async RunindianataxDocumentAcquisitionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDocumentAcquisitionViewResult)
    async RunindianataxDocumentAcquisitionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Document Acquisitions';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDocumentAcquisition_, { nullable: true })
    async indianataxDocumentAcquisition(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDocumentAcquisition_ | null> {
        this.CheckUserReadPermissions('Document Acquisitions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentAcquisitions')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Acquisitions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Document Acquisitions', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDocumentAcquisition_)
    async CreateindianataxDocumentAcquisition(
        @Arg('input', () => CreateindianataxDocumentAcquisitionInput) input: CreateindianataxDocumentAcquisitionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Document Acquisitions', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDocumentAcquisition_)
    async UpdateindianataxDocumentAcquisition(
        @Arg('input', () => UpdateindianataxDocumentAcquisitionInput) input: UpdateindianataxDocumentAcquisitionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Document Acquisitions', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDocumentAcquisition_)
    async DeleteindianataxDocumentAcquisition(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Document Acquisitions', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Document Catalogs
//****************************************************************************
@ObjectType({ description: `One row per document discovered while scanning a SourceRegistry entry, whether or not it was fully ingested. This is the overall inventory of everything reviewed and considered — a document evaluated and excluded (e.g. a budget memo, not property-tax related) gets a row here same as one that was pulled in; SourceDocumentID links to the real stored document only once ingested.` })
export class indianataxDocumentCatalog_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Which source this document was discovered on.`}) 
    @MaxLength(36)
    SourceRegistryID: string;
        
    @Field({description: `The document's URL (or local file path for non-web sources). Unique — the catalog's identity key for a document.`}) 
    @MaxLength(1000)
    URL: string;
        
    @Field({nullable: true, description: `Title/description as it appeared on the source page at discovery time.`}) 
    @MaxLength(500)
    Title?: string;
        
    @Field({description: `When we first became aware of this document (found it listed on the source), independent of whether/when it was ingested.`}) 
    DiscoveredAt: Date;
        
    @Field({nullable: true, description: `The date the document itself is dated/effective, as best determined at cataloging time (e.g. a memo's stated issue date on the index page).`}) 
    DocumentDate?: Date;
        
    @Field(() => Boolean, {nullable: true, description: `Whether this document is relevant to real property taxation. NULL = not yet evaluated; 1/0 = evaluated and included/excluded.`}) 
    IsPropertyTaxRelevant?: boolean;
        
    @Field({nullable: true, description: `Why this document was included or excluded — e.g. "personal property, not real property" or "budget/TIF matter, out of scope".`}) 
    RelevanceNotes?: string;
        
    @Field({nullable: true, description: `The SourceDocument this catalog entry resolved to, once actually fetched and stored. NULL until ingested (or permanently, if excluded).`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(200)
    SourceRegistry: string;
        
}

//****************************************************************************
// INPUT TYPE for Document Catalogs
//****************************************************************************
@InputType()
export class CreateindianataxDocumentCatalogInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    SourceRegistryID?: string;

    @Field({ nullable: true })
    URL?: string;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    DiscoveredAt?: Date;

    @Field({ nullable: true })
    DocumentDate: Date | null;

    @Field(() => Boolean, { nullable: true })
    IsPropertyTaxRelevant: boolean | null;

    @Field({ nullable: true })
    RelevanceNotes: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Document Catalogs
//****************************************************************************
@InputType()
export class UpdateindianataxDocumentCatalogInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    SourceRegistryID?: string;

    @Field({ nullable: true })
    URL?: string;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    DiscoveredAt?: Date;

    @Field({ nullable: true })
    DocumentDate?: Date | null;

    @Field(() => Boolean, { nullable: true })
    IsPropertyTaxRelevant?: boolean | null;

    @Field({ nullable: true })
    RelevanceNotes?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Document Catalogs
//****************************************************************************
@ObjectType()
export class RunindianataxDocumentCatalogViewResult {
    @Field(() => [indianataxDocumentCatalog_])
    Results: indianataxDocumentCatalog_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxDocumentCatalog_)
export class indianataxDocumentCatalogResolver extends ResolverBase {
    @Query(() => RunindianataxDocumentCatalogViewResult)
    async RunindianataxDocumentCatalogViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDocumentCatalogViewResult)
    async RunindianataxDocumentCatalogViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxDocumentCatalogViewResult)
    async RunindianataxDocumentCatalogDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Document Catalogs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxDocumentCatalog_, { nullable: true })
    async indianataxDocumentCatalog(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxDocumentCatalog_ | null> {
        this.CheckUserReadPermissions('Document Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentCatalogs')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Document Catalogs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxDocumentCatalog_)
    async CreateindianataxDocumentCatalog(
        @Arg('input', () => CreateindianataxDocumentCatalogInput) input: CreateindianataxDocumentCatalogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Document Catalogs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxDocumentCatalog_)
    async UpdateindianataxDocumentCatalog(
        @Arg('input', () => UpdateindianataxDocumentCatalogInput) input: UpdateindianataxDocumentCatalogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Document Catalogs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxDocumentCatalog_)
    async DeleteindianataxDocumentCatalog(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Document Catalogs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Form Catalogs
//****************************************************************************
@ObjectType()
export class indianataxFormCatalog_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The number printed on every DLGF form itself (e.g. "21521", "53958", "21366") -- the reliable, near-deterministic way to identify which form a taxpayer uploaded, before any interpretive/LLM matching is needed.`}) 
    @MaxLength(20)
    StateFormNumber: string;
        
    @Field({description: `The colloquial form name (e.g. "Form 113/PP", "Form 130", "Form 11") -- deliberately matches AppealStage.FormRequired's own free-text convention exactly, so the two can be joined/compared as plain strings.`}) 
    @MaxLength(30)
    FormLabel: string;
        
    @Field({description: `The form's full official title as printed (e.g. "Notice of Assessment / Change by an Assessing Official").`}) 
    @MaxLength(300)
    FullTitle: string;
        
    @Field({nullable: true, description: `The revision code printed on the form (e.g. "R12 / 10-19") -- forms get revised periodically; this records which revision was actually verified against, so a later revision can be detected as needing re-verification.`}) 
    @MaxLength(30)
    RevisionCode?: string;
        
    @Field({description: `Plain-language description of what this form is for and when it's used.`}) 
    Purpose: string;
        
    @Field({description: `Who completes/files this form (e.g. "Assessing Official", "Taxpayer").`}) 
    @MaxLength(100)
    FiledBy: string;
        
    @Field({nullable: true, description: `Who receives this form (e.g. "Township Assessor or County Assessor"). Null for a form that is only issued outward (a notice), not filed with anyone.`}) 
    @MaxLength(200)
    FiledWith?: string;
        
    @Field({description: `Which kind of property this form applies to -- Real, Personal, Both, or PublicUtility.`}) 
    @MaxLength(20)
    PropertyTypeScope: string;
        
    @Field({nullable: true, description: `For a form that IS a step in the appeal process (Form 130, 131, 134): the indiana_tax.AppealStage row it corresponds to -- that row already carries the authoritative deadline/citation, not duplicated here. Null for a form that is not itself an appeal-process step.`}) 
    @MaxLength(36)
    CorrespondingAppealStageID?: string;
        
    @Field({nullable: true, description: `For a NOTICE form (e.g. Form 11, Form 113/PP) whose issuance is what starts the clock on a downstream appeal-process step: the indiana_tax.AppealStage row it triggers. Null for a form that is not a triggering notice. A form should generally have exactly one of CorrespondingAppealStageID or TriggersAppealStageID set, not both -- not enforced by a CHECK since the distinction isn't safety-critical, just documented here.`}) 
    @MaxLength(36)
    TriggersAppealStageID?: string;
        
    @Field({description: `The SourceDocument row for this form's own actual PDF (DocumentType = 'Form', same convention already used for AppealStage.SourceDocumentID's Form 130 row) -- every catalog row traces back to a real, hashed, retained document, not an assertion.`}) 
    @MaxLength(36)
    SourceDocumentID: string;
        
    @Field({description: `The forms.in.gov download URL this form was fetched from.`}) 
    @MaxLength(500)
    SourceURL: string;
        
    @Field({description: `When this row was last verified against the actual form text -- distinct from __mj_UpdatedAt, which would also change on a purely mechanical edit.`}) 
    LastVerifiedAt: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    CorrespondingAppealStage?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    TriggersAppealStage?: string;
        
}

//****************************************************************************
// INPUT TYPE for Form Catalogs
//****************************************************************************
@InputType()
export class CreateindianataxFormCatalogInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    StateFormNumber?: string;

    @Field({ nullable: true })
    FormLabel?: string;

    @Field({ nullable: true })
    FullTitle?: string;

    @Field({ nullable: true })
    RevisionCode: string | null;

    @Field({ nullable: true })
    Purpose?: string;

    @Field({ nullable: true })
    FiledBy?: string;

    @Field({ nullable: true })
    FiledWith: string | null;

    @Field({ nullable: true })
    PropertyTypeScope?: string;

    @Field({ nullable: true })
    CorrespondingAppealStageID: string | null;

    @Field({ nullable: true })
    TriggersAppealStageID: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field({ nullable: true })
    SourceURL?: string;

    @Field({ nullable: true })
    LastVerifiedAt?: Date;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Form Catalogs
//****************************************************************************
@InputType()
export class UpdateindianataxFormCatalogInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    StateFormNumber?: string;

    @Field({ nullable: true })
    FormLabel?: string;

    @Field({ nullable: true })
    FullTitle?: string;

    @Field({ nullable: true })
    RevisionCode?: string | null;

    @Field({ nullable: true })
    Purpose?: string;

    @Field({ nullable: true })
    FiledBy?: string;

    @Field({ nullable: true })
    FiledWith?: string | null;

    @Field({ nullable: true })
    PropertyTypeScope?: string;

    @Field({ nullable: true })
    CorrespondingAppealStageID?: string | null;

    @Field({ nullable: true })
    TriggersAppealStageID?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string;

    @Field({ nullable: true })
    SourceURL?: string;

    @Field({ nullable: true })
    LastVerifiedAt?: Date;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Form Catalogs
//****************************************************************************
@ObjectType()
export class RunindianataxFormCatalogViewResult {
    @Field(() => [indianataxFormCatalog_])
    Results: indianataxFormCatalog_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxFormCatalog_)
export class indianataxFormCatalogResolver extends ResolverBase {
    @Query(() => RunindianataxFormCatalogViewResult)
    async RunindianataxFormCatalogViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxFormCatalogViewResult)
    async RunindianataxFormCatalogViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxFormCatalogViewResult)
    async RunindianataxFormCatalogDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Form Catalogs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxFormCatalog_, { nullable: true })
    async indianataxFormCatalog(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxFormCatalog_ | null> {
        this.CheckUserReadPermissions('Form Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwFormCatalogs')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Form Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Form Catalogs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxFormCatalog_)
    async CreateindianataxFormCatalog(
        @Arg('input', () => CreateindianataxFormCatalogInput) input: CreateindianataxFormCatalogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Form Catalogs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxFormCatalog_)
    async UpdateindianataxFormCatalog(
        @Arg('input', () => UpdateindianataxFormCatalogInput) input: UpdateindianataxFormCatalogInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Form Catalogs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxFormCatalog_)
    async DeleteindianataxFormCatalog(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Form Catalogs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Jurisdiction Deadline Anchors
//****************************************************************************
@ObjectType({ description: `Per (county, township?, tax year, anchor event) the observed/published date that feeds a DeadlineBasis = \'RelativeDays\' deadline (or branches a \'CalendarRule\'). The "rolling deadline" shape from the Faegre Appeal Deadline Tracking workbook\'s WA/IL tabs. APPEND-ONLY BY YEAR: one row per key, never overwrite a prior year, so year-over-year history is just the older rows.` })
export class indianataxJurisdictionDeadlineAnchor_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field(() => Int, {description: `The jurisdiction (Indiana county number).`}) 
    CountyNumber: number;
        
    @Field({nullable: true, description: `Set only when the anchor is township-level (Indiana has township assessors, and IL/WA-style rolling deadlines vary by township). NULL = county-level anchor.`}) 
    @MaxLength(60)
    TownshipName?: string;
        
    @Field(() => Int, {description: `The assessment / tax year this anchor applies to.`}) 
    TaxYear: number;
        
    @Field({description: `Same vocabulary as AppealStage.DeadlineAnchorEvent (Form11MailDate, PTABOAOrderDate, ...).`}) 
    @MaxLength(40)
    AnchorEvent: string;
        
    @Field({nullable: true, description: `The observed / published date. NULL while Status = 'Pending'.`}) 
    AnchorDate?: Date;
        
    @Field({description: `Confirmed (from a primary source -- set SourceDocumentID), Estimated (projected from prior years), Pending (not yet known), or NotApplicable.`}) 
    @MaxLength(20)
    Status: string;
        
    @Field({nullable: true, description: `Convenience: AnchorDate resolved through the governing stage rule (anchor + offset, or the calendar-rule branch).`}) 
    DerivedDeadline?: Date;
        
    @Field({nullable: true, description: `The SourceDocument the date was taken from (a Form 11, an assessor calendar).`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true, description: `Free-text context.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
}

//****************************************************************************
// INPUT TYPE for Jurisdiction Deadline Anchors
//****************************************************************************
@InputType()
export class CreateindianataxJurisdictionDeadlineAnchorInput {
    @Field({ nullable: true })
    ID?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    TownshipName: string | null;

    @Field(() => Int, { nullable: true })
    TaxYear?: number;

    @Field({ nullable: true })
    AnchorEvent?: string;

    @Field({ nullable: true })
    AnchorDate: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DerivedDeadline: Date | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Jurisdiction Deadline Anchors
//****************************************************************************
@InputType()
export class UpdateindianataxJurisdictionDeadlineAnchorInput {
    @Field()
    ID: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    TownshipName?: string | null;

    @Field(() => Int, { nullable: true })
    TaxYear?: number;

    @Field({ nullable: true })
    AnchorEvent?: string;

    @Field({ nullable: true })
    AnchorDate?: Date | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DerivedDeadline?: Date | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Jurisdiction Deadline Anchors
//****************************************************************************
@ObjectType()
export class RunindianataxJurisdictionDeadlineAnchorViewResult {
    @Field(() => [indianataxJurisdictionDeadlineAnchor_])
    Results: indianataxJurisdictionDeadlineAnchor_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxJurisdictionDeadlineAnchor_)
export class indianataxJurisdictionDeadlineAnchorResolver extends ResolverBase {
    @Query(() => RunindianataxJurisdictionDeadlineAnchorViewResult)
    async RunindianataxJurisdictionDeadlineAnchorViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxJurisdictionDeadlineAnchorViewResult)
    async RunindianataxJurisdictionDeadlineAnchorViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxJurisdictionDeadlineAnchorViewResult)
    async RunindianataxJurisdictionDeadlineAnchorDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Jurisdiction Deadline Anchors';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxJurisdictionDeadlineAnchor_, { nullable: true })
    async indianataxJurisdictionDeadlineAnchor(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxJurisdictionDeadlineAnchor_ | null> {
        this.CheckUserReadPermissions('Jurisdiction Deadline Anchors', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwJurisdictionDeadlineAnchors')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Jurisdiction Deadline Anchors', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Jurisdiction Deadline Anchors', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxJurisdictionDeadlineAnchor_)
    async CreateindianataxJurisdictionDeadlineAnchor(
        @Arg('input', () => CreateindianataxJurisdictionDeadlineAnchorInput) input: CreateindianataxJurisdictionDeadlineAnchorInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Jurisdiction Deadline Anchors', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxJurisdictionDeadlineAnchor_)
    async UpdateindianataxJurisdictionDeadlineAnchor(
        @Arg('input', () => UpdateindianataxJurisdictionDeadlineAnchorInput) input: UpdateindianataxJurisdictionDeadlineAnchorInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Jurisdiction Deadline Anchors', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxJurisdictionDeadlineAnchor_)
    async DeleteindianataxJurisdictionDeadlineAnchor(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Jurisdiction Deadline Anchors', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Market Assumptions
//****************************************************************************
@ObjectType({ description: `A market parameter used by the income approach: a capitalization rate, an implied NOI per SqFt / per Unit, a vacancy rate, an expense ratio, or a market rent per SqFt / per Unit. One row per (type, property-type group, submarket?, period, method).` })
export class indianataxMarketAssumption_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Which parameter this row states: CapRate / NOIPerSqFt / NOIPerUnit / Vacancy / ExpenseRatio / MarketRentPerSqFt / MarketRentPerUnit. Rates (CapRate/Vacancy/ExpenseRatio) are decimal fractions; the others are dollars.`}) 
    @MaxLength(24)
    AssumptionType: string;
        
    @Field({description: `The property-type group this parameter applies to (Retail/Office/Industrial/Multifamily/Land/Special/Other), or 'All'.`}) 
    @MaxLength(30)
    PropertyTypeGroup: string;
        
    @Field({nullable: true, description: `Submarket the parameter is specific to; NULL = countywide.`}) 
    @MaxLength(80)
    Submarket?: string;
        
    @Field(() => Int, {nullable: true, description: `The year the parameter represents (e.g. the assessment/valuation year, or the year the extracted sales cluster around). NULL if PeriodLabel carries the period instead.`}) 
    PeriodYear?: number;
        
    @Field({nullable: true, description: `Free-text period when a single year does not fit (e.g. "2023-2025", "Q1 2024").`}) 
    @MaxLength(30)
    PeriodLabel?: string;
        
    @Field(() => Float, {description: `The concluded / central value (median for a SalesExtraction row). Decimal fraction for rate types, dollars otherwise.`}) 
    Value: number;
        
    @Field(() => Float, {nullable: true, description: `Low end of the supported range (e.g. 25th percentile of the extracted sample).`}) 
    LowValue?: number;
        
    @Field(() => Float, {nullable: true, description: `High end of the supported range (e.g. 75th percentile).`}) 
    HighValue?: number;
        
    @Field(() => Int, {nullable: true, description: `Number of observations behind a SalesExtraction row.`}) 
    SampleSize?: number;
        
    @Field({description: `How the value was derived: SalesExtraction (from CapRateAtSale / ImpliedNOIAtSale on indiana_tax.SaleTransaction), BrokerSurvey (RealtyRates / PwC / CBRE etc.), BandOfInvestment (mortgage-equity build-up), or Manual.`}) 
    @MaxLength(24)
    Method: string;
        
    @Field({nullable: true, description: `Citation / provenance for a non-extracted row (survey name, issue date, page).`}) 
    @MaxLength(300)
    SourceNote?: string;
        
    @Field({nullable: true, description: `Free-text notes.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
}

//****************************************************************************
// INPUT TYPE for Market Assumptions
//****************************************************************************
@InputType()
export class CreateindianataxMarketAssumptionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    AssumptionType?: string;

    @Field({ nullable: true })
    PropertyTypeGroup?: string;

    @Field({ nullable: true })
    Submarket: string | null;

    @Field(() => Int, { nullable: true })
    PeriodYear: number | null;

    @Field({ nullable: true })
    PeriodLabel: string | null;

    @Field(() => Float, { nullable: true })
    Value?: number;

    @Field(() => Float, { nullable: true })
    LowValue: number | null;

    @Field(() => Float, { nullable: true })
    HighValue: number | null;

    @Field(() => Int, { nullable: true })
    SampleSize: number | null;

    @Field({ nullable: true })
    Method?: string;

    @Field({ nullable: true })
    SourceNote: string | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Market Assumptions
//****************************************************************************
@InputType()
export class UpdateindianataxMarketAssumptionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    AssumptionType?: string;

    @Field({ nullable: true })
    PropertyTypeGroup?: string;

    @Field({ nullable: true })
    Submarket?: string | null;

    @Field(() => Int, { nullable: true })
    PeriodYear?: number | null;

    @Field({ nullable: true })
    PeriodLabel?: string | null;

    @Field(() => Float, { nullable: true })
    Value?: number;

    @Field(() => Float, { nullable: true })
    LowValue?: number | null;

    @Field(() => Float, { nullable: true })
    HighValue?: number | null;

    @Field(() => Int, { nullable: true })
    SampleSize?: number | null;

    @Field({ nullable: true })
    Method?: string;

    @Field({ nullable: true })
    SourceNote?: string | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Market Assumptions
//****************************************************************************
@ObjectType()
export class RunindianataxMarketAssumptionViewResult {
    @Field(() => [indianataxMarketAssumption_])
    Results: indianataxMarketAssumption_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxMarketAssumption_)
export class indianataxMarketAssumptionResolver extends ResolverBase {
    @Query(() => RunindianataxMarketAssumptionViewResult)
    async RunindianataxMarketAssumptionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxMarketAssumptionViewResult)
    async RunindianataxMarketAssumptionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxMarketAssumptionViewResult)
    async RunindianataxMarketAssumptionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Market Assumptions';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxMarketAssumption_, { nullable: true })
    async indianataxMarketAssumption(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxMarketAssumption_ | null> {
        this.CheckUserReadPermissions('Market Assumptions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwMarketAssumptions')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Market Assumptions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Market Assumptions', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxMarketAssumption_)
    async CreateindianataxMarketAssumption(
        @Arg('input', () => CreateindianataxMarketAssumptionInput) input: CreateindianataxMarketAssumptionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Market Assumptions', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxMarketAssumption_)
    async UpdateindianataxMarketAssumption(
        @Arg('input', () => UpdateindianataxMarketAssumptionInput) input: UpdateindianataxMarketAssumptionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Market Assumptions', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxMarketAssumption_)
    async DeleteindianataxMarketAssumption(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Market Assumptions', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Owner Portfolio Parcels
//****************************************************************************
@ObjectType({ description: `One parcel within an OwnerPortfolio owner group for a run: identity, 2025/2026 AV, the three ValuationAnalysis approach indications, the recommended floor/ask and estimated tax saving, and the appeal/rep status for that parcel.` })
export class indianataxOwnerPortfolioParcel_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    OwnerPortfolioID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ParcelID?: string;
        
    @Field({description: `parcel.parcel -- the 7-digit Marion County GIS parcel number, the always-present link key to the PRC and tax history even when ParcelID is null.`}) 
    @MaxLength(20)
    GISParcelNumber: string;
        
    @Field({nullable: true, description: `The parcel's situs (site) address as shown in the dashboard parcel list.`}) 
    @MaxLength(300)
    Address?: string;
        
    @Field({nullable: true, description: `The parcel's property-type group (e.g. Office, Retail, Industrial, Apartment, Hospitality) used for the by-type breakdowns.`}) 
    @MaxLength(60)
    TypeGroup?: string;
        
    @Field(() => Float, {nullable: true, description: `The parcel's current (most recent certified) total assessed value.`}) 
    CurrentAV?: number;
        
    @Field(() => Float, {nullable: true, description: `The parcel's 2025 total assessed value.`}) 
    AV2025?: number;
        
    @Field(() => Float, {nullable: true, description: `The parcel's 2026 total assessed value.`}) 
    AV2026?: number;
        
    @Field(() => Float, {nullable: true, description: `The parcel's year-over-year assessed-value change as a fraction (0.3000 = +30%).`}) 
    AVYoYPct?: number;
        
    @Field(() => Int, {nullable: true, description: `The parcel's improvement square footage where known.`}) 
    SqFt?: number;
        
    @Field(() => Int, {nullable: true, description: `The parcel's residential/lodging unit count where known.`}) 
    Units?: number;
        
    @Field(() => Float, {nullable: true, description: `parcel.salesInd -- the ValuationAnalysis sales-comparison indicated value for the parcel.`}) 
    SalesIndicatedValue?: number;
        
    @Field(() => Float, {nullable: true, description: `parcel.incomeInd -- the ValuationAnalysis income-approach indicated value for the parcel.`}) 
    IncomeIndicatedValue?: number;
        
    @Field(() => Float, {nullable: true, description: `parcel.floor -- the conservative low-end value the ValuationAnalysis would defend for the parcel.`}) 
    FloorValue?: number;
        
    @Field(() => Float, {nullable: true, description: `parcel.ask -- the value the ValuationAnalysis recommends asking for at appeal (the opening position).`}) 
    AskValue?: number;
        
    @Field(() => Float, {nullable: true, description: `Estimated annual property-tax saving for the parcel if the assessed value were reduced to AskValue. Coarse v1 estimate, a triage signal.`}) 
    EstSavingsAtAsk?: number;
        
    @Field(() => Float, {nullable: true, description: `Estimated annual property-tax saving for the parcel if the assessed value were reduced to FloorValue -- the conservative end of the range.`}) 
    EstSavingsAtFloor?: number;
        
    @Field({nullable: true, description: `parcel.rec -- the ValuationAnalysis recommendation for the parcel (Appeal | Monitor | ...).`}) 
    @MaxLength(20)
    Recommendation?: string;
        
    @Field({nullable: true, description: `parcel.conf -- the ValuationAnalysis confidence tier for the recommendation (High | Medium | Low).`}) 
    @MaxLength(20)
    ConfidenceTier?: string;
        
    @Field(() => Int, {nullable: true, description: `parcel.supCount -- how many of the three approaches to value (cost, sales, income) support a reduction for the parcel (0-3).`}) 
    SupportingApproachCount?: number;
        
    @Field(() => Boolean, {description: `BIT: the parcel has at least one recorded PTABOA/assessment appeal in its history.`}) 
    Appealed: boolean;
        
    @Field({nullable: true, description: `parcel.rep -- the tax representative on record for the parcel's prior appeals, if any.`}) 
    @MaxLength(200)
    ExistingRep?: string;
        
    @Field(() => Int, {nullable: true, description: `The most recent assessment year in which this parcel was appealed.`}) 
    LastAppealYear?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    OwnerPortfolio: string;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    Parcel?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
}

//****************************************************************************
// INPUT TYPE for Owner Portfolio Parcels
//****************************************************************************
@InputType()
export class CreateindianataxOwnerPortfolioParcelInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    OwnerPortfolioID?: string;

    @Field({ nullable: true })
    ParcelID: string | null;

    @Field({ nullable: true })
    GISParcelNumber?: string;

    @Field({ nullable: true })
    Address: string | null;

    @Field({ nullable: true })
    TypeGroup: string | null;

    @Field(() => Float, { nullable: true })
    CurrentAV: number | null;

    @Field(() => Float, { nullable: true })
    AV2025: number | null;

    @Field(() => Float, { nullable: true })
    AV2026: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct: number | null;

    @Field(() => Int, { nullable: true })
    SqFt: number | null;

    @Field(() => Int, { nullable: true })
    Units: number | null;

    @Field(() => Float, { nullable: true })
    SalesIndicatedValue: number | null;

    @Field(() => Float, { nullable: true })
    IncomeIndicatedValue: number | null;

    @Field(() => Float, { nullable: true })
    FloorValue: number | null;

    @Field(() => Float, { nullable: true })
    AskValue: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtAsk: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtFloor: number | null;

    @Field({ nullable: true })
    Recommendation: string | null;

    @Field({ nullable: true })
    ConfidenceTier: string | null;

    @Field(() => Int, { nullable: true })
    SupportingApproachCount: number | null;

    @Field(() => Boolean, { nullable: true })
    Appealed?: boolean;

    @Field({ nullable: true })
    ExistingRep: string | null;

    @Field(() => Int, { nullable: true })
    LastAppealYear: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Owner Portfolio Parcels
//****************************************************************************
@InputType()
export class UpdateindianataxOwnerPortfolioParcelInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    OwnerPortfolioID?: string;

    @Field({ nullable: true })
    ParcelID?: string | null;

    @Field({ nullable: true })
    GISParcelNumber?: string;

    @Field({ nullable: true })
    Address?: string | null;

    @Field({ nullable: true })
    TypeGroup?: string | null;

    @Field(() => Float, { nullable: true })
    CurrentAV?: number | null;

    @Field(() => Float, { nullable: true })
    AV2025?: number | null;

    @Field(() => Float, { nullable: true })
    AV2026?: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct?: number | null;

    @Field(() => Int, { nullable: true })
    SqFt?: number | null;

    @Field(() => Int, { nullable: true })
    Units?: number | null;

    @Field(() => Float, { nullable: true })
    SalesIndicatedValue?: number | null;

    @Field(() => Float, { nullable: true })
    IncomeIndicatedValue?: number | null;

    @Field(() => Float, { nullable: true })
    FloorValue?: number | null;

    @Field(() => Float, { nullable: true })
    AskValue?: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtAsk?: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtFloor?: number | null;

    @Field({ nullable: true })
    Recommendation?: string | null;

    @Field({ nullable: true })
    ConfidenceTier?: string | null;

    @Field(() => Int, { nullable: true })
    SupportingApproachCount?: number | null;

    @Field(() => Boolean, { nullable: true })
    Appealed?: boolean;

    @Field({ nullable: true })
    ExistingRep?: string | null;

    @Field(() => Int, { nullable: true })
    LastAppealYear?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Owner Portfolio Parcels
//****************************************************************************
@ObjectType()
export class RunindianataxOwnerPortfolioParcelViewResult {
    @Field(() => [indianataxOwnerPortfolioParcel_])
    Results: indianataxOwnerPortfolioParcel_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxOwnerPortfolioParcel_)
export class indianataxOwnerPortfolioParcelResolver extends ResolverBase {
    @Query(() => RunindianataxOwnerPortfolioParcelViewResult)
    async RunindianataxOwnerPortfolioParcelViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioParcelViewResult)
    async RunindianataxOwnerPortfolioParcelViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioParcelViewResult)
    async RunindianataxOwnerPortfolioParcelDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Owner Portfolio Parcels';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxOwnerPortfolioParcel_, { nullable: true })
    async indianataxOwnerPortfolioParcel(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxOwnerPortfolioParcel_ | null> {
        this.CheckUserReadPermissions('Owner Portfolio Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolioParcels')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolio Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Owner Portfolio Parcels', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxOwnerPortfolioParcel_)
    async CreateindianataxOwnerPortfolioParcel(
        @Arg('input', () => CreateindianataxOwnerPortfolioParcelInput) input: CreateindianataxOwnerPortfolioParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Owner Portfolio Parcels', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxOwnerPortfolioParcel_)
    async UpdateindianataxOwnerPortfolioParcel(
        @Arg('input', () => UpdateindianataxOwnerPortfolioParcelInput) input: UpdateindianataxOwnerPortfolioParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Owner Portfolio Parcels', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxOwnerPortfolioParcel_)
    async DeleteindianataxOwnerPortfolioParcel(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Owner Portfolio Parcels', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Owner Portfolio Runs
//****************************************************************************
@ObjectType({ description: `Persisted output of one scripts/build-owner-portfolios.js run: the county-wide commercial & industrial 2025->2026 assessed-value rollup plus a pointer (IsLatest) to the run the dashboard should show. Written by the portfolio job, read-only on the dashboard side.` })
export class indianataxOwnerPortfolioRun_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `When the portfolio job that produced this run executed, taken verbatim from owners.json generatedAt.`}) 
    RunDate: Date;
        
    @Field({description: `The build-owner-portfolios.js methodology label (owners.json method) so a run can be tied to the grouping and scoring rules that produced it.`}) 
    @MaxLength(60)
    MethodologyVersion: string;
        
    @Field(() => Boolean, {description: `Exactly one OwnerPortfolioRun row has IsLatest = 1 at a time; the loader clears the previous winner in the same transaction. The dashboard filters on it.`}) 
    IsLatest: boolean;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcels: the number of Marion commercial & industrial parcels in scope for this run.`}) 
    CountyParcelCount?: number;
        
    @Field(() => Float, {nullable: true, description: `countyRollup.totalAV2025: the summed 2025 assessed value across all in-scope county C&I parcels.`}) 
    CountyTotalAV2025?: number;
        
    @Field(() => Float, {nullable: true, description: `countyRollup.totalAV2026: the summed 2026 assessed value across all in-scope county C&I parcels.`}) 
    CountyTotalAV2026?: number;
        
    @Field(() => Float, {nullable: true, description: `countyRollup.yoyDollars: CountyTotalAV2026 minus CountyTotalAV2025, the county-wide dollar change in assessed value.`}) 
    CountyYoYDollars?: number;
        
    @Field(() => Float, {nullable: true, description: `countyRollup.yoyPct: the county-wide year-over-year assessed-value change as a fraction (0.0750 = +7.5%).`}) 
    CountyYoYPct?: number;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcelsUp5: count of county C&I parcels whose 2026 AV rose more than 5% over 2025.`}) 
    CountyParcelsUp5?: number;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcelsUp10: count of county C&I parcels whose 2026 AV rose more than 10% over 2025.`}) 
    CountyParcelsUp10?: number;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcelsUp25: count of county C&I parcels whose 2026 AV rose more than 25% over 2025.`}) 
    CountyParcelsUp25?: number;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcelsUp50: count of county C&I parcels whose 2026 AV rose more than 50% over 2025.`}) 
    CountyParcelsUp50?: number;
        
    @Field(() => Int, {nullable: true, description: `countyRollup.parcelsDown: count of county C&I parcels whose 2026 AV fell below 2025.`}) 
    CountyParcelsDown?: number;
        
    @Field({nullable: true, description: `JSON.stringify of countyRollup.byType from owners.json -- per-property-type 2025/2026 AV + YoY %, display-only for the banner chips. Not a queryable projection.`}) 
    CountyByTypeJSON?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [indianataxOwnerPortfolio_])
    indianataxOwnerPortfolios_RunIDArray: indianataxOwnerPortfolio_[]; // Link to indianataxOwnerPortfolios
    
}

//****************************************************************************
// INPUT TYPE for Owner Portfolio Runs
//****************************************************************************
@InputType()
export class CreateindianataxOwnerPortfolioRunInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    RunDate?: Date;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field(() => Boolean, { nullable: true })
    IsLatest?: boolean;

    @Field(() => Int, { nullable: true })
    CountyParcelCount: number | null;

    @Field(() => Float, { nullable: true })
    CountyTotalAV2025: number | null;

    @Field(() => Float, { nullable: true })
    CountyTotalAV2026: number | null;

    @Field(() => Float, { nullable: true })
    CountyYoYDollars: number | null;

    @Field(() => Float, { nullable: true })
    CountyYoYPct: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp5: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp10: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp25: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp50: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsDown: number | null;

    @Field({ nullable: true })
    CountyByTypeJSON: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Owner Portfolio Runs
//****************************************************************************
@InputType()
export class UpdateindianataxOwnerPortfolioRunInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    RunDate?: Date;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field(() => Boolean, { nullable: true })
    IsLatest?: boolean;

    @Field(() => Int, { nullable: true })
    CountyParcelCount?: number | null;

    @Field(() => Float, { nullable: true })
    CountyTotalAV2025?: number | null;

    @Field(() => Float, { nullable: true })
    CountyTotalAV2026?: number | null;

    @Field(() => Float, { nullable: true })
    CountyYoYDollars?: number | null;

    @Field(() => Float, { nullable: true })
    CountyYoYPct?: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp5?: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp10?: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp25?: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsUp50?: number | null;

    @Field(() => Int, { nullable: true })
    CountyParcelsDown?: number | null;

    @Field({ nullable: true })
    CountyByTypeJSON?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Owner Portfolio Runs
//****************************************************************************
@ObjectType()
export class RunindianataxOwnerPortfolioRunViewResult {
    @Field(() => [indianataxOwnerPortfolioRun_])
    Results: indianataxOwnerPortfolioRun_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxOwnerPortfolioRun_)
export class indianataxOwnerPortfolioRunResolver extends ResolverBase {
    @Query(() => RunindianataxOwnerPortfolioRunViewResult)
    async RunindianataxOwnerPortfolioRunViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioRunViewResult)
    async RunindianataxOwnerPortfolioRunViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioRunViewResult)
    async RunindianataxOwnerPortfolioRunDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Owner Portfolio Runs';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxOwnerPortfolioRun_, { nullable: true })
    async indianataxOwnerPortfolioRun(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxOwnerPortfolioRun_ | null> {
        this.CheckUserReadPermissions('Owner Portfolio Runs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolioRuns')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolio Runs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Owner Portfolio Runs', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxOwnerPortfolio_])
    async indianataxOwnerPortfolios_RunIDArray(@Root() indianataxownerportfoliorun_: indianataxOwnerPortfolioRun_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Owner Portfolios', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolios')} WHERE ${provider.QuoteIdentifier('RunID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolios', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxownerportfoliorun_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Owner Portfolios', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxOwnerPortfolioRun_)
    async CreateindianataxOwnerPortfolioRun(
        @Arg('input', () => CreateindianataxOwnerPortfolioRunInput) input: CreateindianataxOwnerPortfolioRunInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Owner Portfolio Runs', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxOwnerPortfolioRun_)
    async UpdateindianataxOwnerPortfolioRun(
        @Arg('input', () => UpdateindianataxOwnerPortfolioRunInput) input: UpdateindianataxOwnerPortfolioRunInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Owner Portfolio Runs', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxOwnerPortfolioRun_)
    async DeleteindianataxOwnerPortfolioRun(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Owner Portfolio Runs', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Owner Portfolios
//****************************************************************************
@ObjectType({ description: `One operating-company owner group in a run: Marion parcels rolled up to the operating company (CoStar true owner -> shared mailing address -> cleaned name), with aggregate AV, the ValuationAnalysis opportunity, appeal history, and the tax rep on record.` })
export class indianataxOwnerPortfolio_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    RunID: string;
        
    @Field({description: `Normalized owner key (scripts/lib/owner-key.js): CoStar true owner else cleaned label, lowercased, legal-form suffixes stripped. The stable join to indiana_tax.Prospect.OwnerKey across portfolio re-runs.`}) 
    @MaxLength(200)
    OwnerKey: string;
        
    @Field({description: `Human-readable owner name shown in the dashboard (owner.label) -- the CoStar true owner if known, otherwise the cleaned assessor name.`}) 
    @MaxLength(300)
    Label: string;
        
    @Field({description: `Company | Individual | Government | Institution -- classifier from build-owner-portfolios.js. Only Company owners get a prospect Tier.`}) 
    @MaxLength(20)
    Kind: string;
        
    @Field({nullable: true, description: `Prime (>= $500k/yr at ask) | Strong (>= $150k) | Moderate (>= $40k) | Watch | em dash for non-companies.`}) 
    @MaxLength(12)
    Tier?: string;
        
    @Field({nullable: true, description: `owner.groupKeyType -- which signal grouped these parcels: CO (CoStar true owner), MAIL (shared mailing address), NAME (cleaned assessor name), or PARCEL (single parcel, no group).`}) 
    @MaxLength(12)
    GroupKeyType?: string;
        
    @Field({nullable: true, description: `owner.coStarTrueOwner -- the CoStar-resolved ultimate owner name when available, the basis of the strongest grouping signal.`}) 
    @MaxLength(300)
    CoStarTrueOwner?: string;
        
    @Field(() => Int, {description: `Number of parcels rolled up into this owner group for the run (matches the count of OwnerPortfolioParcel rows).`}) 
    ParcelCount: number;
        
    @Field(() => Int, {nullable: true, description: `Count of distinct raw assessor owner-name strings folded into this group -- a rough measure of how many title-holding entities the operating company uses.`}) 
    DistinctEntities?: number;
        
    @Field(() => Float, {nullable: true, description: `Sum of the current (most recent certified) assessed value across the group's parcels.`}) 
    TotalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Sum of 2025 assessed value across the group's parcels.`}) 
    TotalAV2025?: number;
        
    @Field(() => Float, {nullable: true, description: `Sum of 2026 assessed value across the group's parcels.`}) 
    TotalAV2026?: number;
        
    @Field(() => Float, {nullable: true, description: `TotalAV2026 minus TotalAV2025 -- the group's year-over-year dollar change in assessed value.`}) 
    AVYoYDollars?: number;
        
    @Field(() => Float, {nullable: true, description: `The group's year-over-year assessed-value change as a fraction (0.1200 = +12%).`}) 
    AVYoYPct?: number;
        
    @Field(() => Int, {nullable: true, description: `Count of the group's parcels whose 2026 AV rose more than 10% over 2025.`}) 
    ParcelsUp10?: number;
        
    @Field(() => Int, {nullable: true, description: `Count of the group's parcels whose 2026 AV rose more than 25% over 2025.`}) 
    ParcelsUp25?: number;
        
    @Field(() => Int, {nullable: true, description: `Sum of residential/lodging unit counts across the group's parcels where a unit count is known.`}) 
    TotalUnits?: number;
        
    @Field(() => Int, {nullable: true, description: `Sum of improvement square footage across the group's parcels where square footage is known.`}) 
    TotalSqFt?: number;
        
    @Field(() => Int, {nullable: true, description: `owner.nAppealRec -- count of the group's parcels the ValuationAnalysis flags with an Appeal recommendation.`}) 
    NAppealRec?: number;
        
    @Field(() => Int, {nullable: true, description: `owner.nTwoSupport -- count of the group's parcels where at least two of the three approaches to value support a reduction.`}) 
    NTwoSupport?: number;
        
    @Field(() => Int, {nullable: true, description: `owner.nHighConfAppeal -- count of the group's Appeal-rec parcels whose confidence tier is High.`}) 
    NHighConfAppeal?: number;
        
    @Field(() => Float, {nullable: true, description: `Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the recommended ask across Appeal-rec parcels. v1 coarse comps -- a triage signal, not a quote.`}) 
    EstSavingsAtAsk?: number;
        
    @Field(() => Float, {nullable: true, description: `Sum of the per-parcel ValuationAnalysis estimated annual tax saving at the conservative floor value across Appeal-rec parcels -- the low end of the range.`}) 
    EstSavingsAtFloor?: number;
        
    @Field(() => Int, {nullable: true, description: `Count of the group's parcels with at least one recorded PTABOA/assessment appeal in the appeal history.`}) 
    AppealedParcels?: number;
        
    @Field(() => Float, {nullable: true, description: `Total assessed-value reduction the group has historically won across all its recorded appeals (sum of prior-year AV reductions).`}) 
    HistoricalReductionWon?: number;
        
    @Field({nullable: true, description: `Compact span of assessment years in which the group appealed, e.g. "2019-2023"; a single year if there is only one.`}) 
    @MaxLength(20)
    AppealYears?: string;
        
    @Field(() => Int, {nullable: true, description: `The most recent assessment year in which any of the group's parcels was appealed.`}) 
    MostRecentAppealYear?: number;
        
    @Field({nullable: true, description: `Best single guess at the tax representative acting for the owner -- the rep that secured the most (or most recent) PTABOA reductions across the group's parcels.`}) 
    @MaxLength(200)
    LikelyRep?: string;
        
    @Field({description: `No rep on record | Represented by X | Multiple reps -- X (+N). Tax-rep inference: a rep that secured a PTABOA reduction on any portfolio parcel is assumed to act for the owner.`}) 
    @MaxLength(120)
    RepStatus: string;
        
    @Field({nullable: true, description: `JSON.stringify of owner.repsOnReduction -- per-rep count and years of PTABOA reductions won on the group's parcels, display-only for the detail panel.`}) 
    RepsOnReductionJSON?: string;
        
    @Field(() => Boolean, {description: `BIT: Company AND no rep on record AND EstSavingsAtAsk > 0 -- the cold-prospect flag the dashboard highlights.`}) 
    IsFreshProspect: boolean;
        
    @Field({nullable: true, description: `The mailing address shared by the group's parcels (owner.mailAddress) -- the fallback grouping signal and a contact hint.`}) 
    @MaxLength(400)
    MailAddress?: string;
        
    @Field({nullable: true, description: `JSON.stringify of owner.byType -- per-property-type parcel count and AV within the group, display-only for the detail-panel breakdown.`}) 
    ByTypeJSON?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(60)
    Run: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [indianataxOwnerPortfolioParcel_])
    indianataxOwnerPortfolioParcels_OwnerPortfolioIDArray: indianataxOwnerPortfolioParcel_[]; // Link to indianataxOwnerPortfolioParcels
    
}

//****************************************************************************
// INPUT TYPE for Owner Portfolios
//****************************************************************************
@InputType()
export class CreateindianataxOwnerPortfolioInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    RunID?: string;

    @Field({ nullable: true })
    OwnerKey?: string;

    @Field({ nullable: true })
    Label?: string;

    @Field({ nullable: true })
    Kind?: string;

    @Field({ nullable: true })
    Tier: string | null;

    @Field({ nullable: true })
    GroupKeyType: string | null;

    @Field({ nullable: true })
    CoStarTrueOwner: string | null;

    @Field(() => Int, { nullable: true })
    ParcelCount?: number;

    @Field(() => Int, { nullable: true })
    DistinctEntities: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV2025: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV2026: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYDollars: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct: number | null;

    @Field(() => Int, { nullable: true })
    ParcelsUp10: number | null;

    @Field(() => Int, { nullable: true })
    ParcelsUp25: number | null;

    @Field(() => Int, { nullable: true })
    TotalUnits: number | null;

    @Field(() => Int, { nullable: true })
    TotalSqFt: number | null;

    @Field(() => Int, { nullable: true })
    NAppealRec: number | null;

    @Field(() => Int, { nullable: true })
    NTwoSupport: number | null;

    @Field(() => Int, { nullable: true })
    NHighConfAppeal: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtAsk: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtFloor: number | null;

    @Field(() => Int, { nullable: true })
    AppealedParcels: number | null;

    @Field(() => Float, { nullable: true })
    HistoricalReductionWon: number | null;

    @Field({ nullable: true })
    AppealYears: string | null;

    @Field(() => Int, { nullable: true })
    MostRecentAppealYear: number | null;

    @Field({ nullable: true })
    LikelyRep: string | null;

    @Field({ nullable: true })
    RepStatus?: string;

    @Field({ nullable: true })
    RepsOnReductionJSON: string | null;

    @Field(() => Boolean, { nullable: true })
    IsFreshProspect?: boolean;

    @Field({ nullable: true })
    MailAddress: string | null;

    @Field({ nullable: true })
    ByTypeJSON: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Owner Portfolios
//****************************************************************************
@InputType()
export class UpdateindianataxOwnerPortfolioInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    RunID?: string;

    @Field({ nullable: true })
    OwnerKey?: string;

    @Field({ nullable: true })
    Label?: string;

    @Field({ nullable: true })
    Kind?: string;

    @Field({ nullable: true })
    Tier?: string | null;

    @Field({ nullable: true })
    GroupKeyType?: string | null;

    @Field({ nullable: true })
    CoStarTrueOwner?: string | null;

    @Field(() => Int, { nullable: true })
    ParcelCount?: number;

    @Field(() => Int, { nullable: true })
    DistinctEntities?: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV2025?: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV2026?: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYDollars?: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct?: number | null;

    @Field(() => Int, { nullable: true })
    ParcelsUp10?: number | null;

    @Field(() => Int, { nullable: true })
    ParcelsUp25?: number | null;

    @Field(() => Int, { nullable: true })
    TotalUnits?: number | null;

    @Field(() => Int, { nullable: true })
    TotalSqFt?: number | null;

    @Field(() => Int, { nullable: true })
    NAppealRec?: number | null;

    @Field(() => Int, { nullable: true })
    NTwoSupport?: number | null;

    @Field(() => Int, { nullable: true })
    NHighConfAppeal?: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtAsk?: number | null;

    @Field(() => Float, { nullable: true })
    EstSavingsAtFloor?: number | null;

    @Field(() => Int, { nullable: true })
    AppealedParcels?: number | null;

    @Field(() => Float, { nullable: true })
    HistoricalReductionWon?: number | null;

    @Field({ nullable: true })
    AppealYears?: string | null;

    @Field(() => Int, { nullable: true })
    MostRecentAppealYear?: number | null;

    @Field({ nullable: true })
    LikelyRep?: string | null;

    @Field({ nullable: true })
    RepStatus?: string;

    @Field({ nullable: true })
    RepsOnReductionJSON?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsFreshProspect?: boolean;

    @Field({ nullable: true })
    MailAddress?: string | null;

    @Field({ nullable: true })
    ByTypeJSON?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Owner Portfolios
//****************************************************************************
@ObjectType()
export class RunindianataxOwnerPortfolioViewResult {
    @Field(() => [indianataxOwnerPortfolio_])
    Results: indianataxOwnerPortfolio_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxOwnerPortfolio_)
export class indianataxOwnerPortfolioResolver extends ResolverBase {
    @Query(() => RunindianataxOwnerPortfolioViewResult)
    async RunindianataxOwnerPortfolioViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioViewResult)
    async RunindianataxOwnerPortfolioViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxOwnerPortfolioViewResult)
    async RunindianataxOwnerPortfolioDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Owner Portfolios';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxOwnerPortfolio_, { nullable: true })
    async indianataxOwnerPortfolio(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxOwnerPortfolio_ | null> {
        this.CheckUserReadPermissions('Owner Portfolios', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolios')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolios', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Owner Portfolios', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxOwnerPortfolioParcel_])
    async indianataxOwnerPortfolioParcels_OwnerPortfolioIDArray(@Root() indianataxownerportfolio_: indianataxOwnerPortfolio_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Owner Portfolio Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolioParcels')} WHERE ${provider.QuoteIdentifier('OwnerPortfolioID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolio Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxownerportfolio_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Owner Portfolio Parcels', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxOwnerPortfolio_)
    async CreateindianataxOwnerPortfolio(
        @Arg('input', () => CreateindianataxOwnerPortfolioInput) input: CreateindianataxOwnerPortfolioInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Owner Portfolios', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxOwnerPortfolio_)
    async UpdateindianataxOwnerPortfolio(
        @Arg('input', () => UpdateindianataxOwnerPortfolioInput) input: UpdateindianataxOwnerPortfolioInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Owner Portfolios', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxOwnerPortfolio_)
    async DeleteindianataxOwnerPortfolio(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Owner Portfolios', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Parcels
//****************************************************************************
@ObjectType({ description: `One row per Indiana parcel, keyed on (CountyNumber, ParcelNumber) — the statewide 17-digit parcel number. Holds relatively stable characteristics; assessed values live in Assessment, one row per year.` })
export class indianataxParcel_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field(() => Int, {description: `Indiana county number (1-92) per the DLGF/GIO statewide numbering.`}) 
    CountyNumber: number;
        
    @Field({description: `The statewide 17-digit PARCEL_NUMBER from the DLGF/GIO Data Harvest geodatabase. Canonical identifier for the parcel.`}) 
    @MaxLength(30)
    ParcelNumber: string;
        
    @Field({nullable: true, description: `The county's own local parcel number (e.g. Marion County's 7-digit number). Different counties use different local schemes; this is the crosswalk between a county-sourced file and the statewide ParcelNumber.`}) 
    @MaxLength(30)
    GISParcelNumber?: string;
        
    @Field({nullable: true, description: `Site/property address.`}) 
    @MaxLength(300)
    Address?: string;
        
    @Field({nullable: true, description: `Owner of record name, as of the characteristics source year.`}) 
    @MaxLength(300)
    OwnerName?: string;
        
    @Field(() => Float, {nullable: true, description: `Parcel acreage.`}) 
    Acreage?: number;
        
    @Field({nullable: true, description: `Zoning designation, as recorded by the county.`}) 
    @MaxLength(50)
    Zoning?: string;
        
    @Field({nullable: true, description: `Most recently known DLGF property class code (e.g. 300-499 for commercial/industrial). A given assessment year may record a different class code on its own Assessment row.`}) 
    @MaxLength(10)
    PropertyClassCode?: string;
        
    @Field(() => Int, {nullable: true, description: `Which DLGF/source pull (assessment year) produced the characteristics currently stored on this row. Characteristics are overwritten on a later pull, not versioned.`}) 
    CharacteristicsSourceYear?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => Float, {nullable: true, description: `Parcel centroid latitude (WGS84), from the IndianaMap parcel boundaries Feature Service.`}) 
    Latitude?: number;
        
    @Field(() => Float, {nullable: true, description: `Parcel centroid longitude (WGS84), from the IndianaMap parcel boundaries Feature Service.`}) 
    Longitude?: number;
        
    @Field({nullable: true, description: `County FIPS code, from the IndianaMap Feature Service's county_fips field — a verifiable county identifier, distinct from CountyNumber (the DLGF/GIO statewide numbering used elsewhere in this schema).`}) 
    @MaxLength(10)
    CountyFIPS?: string;
        
    @Field({nullable: true, description: `Parcel boundary polygon as GeoJSON geometry (WGS84), from the IndianaMap Feature Service. NULL until fetched; not every parcel in our set necessarily resolves (a parcel here may not exist in that dataset, or vice versa).`}) 
    BoundaryGeoJSON?: string;
        
    @Field({nullable: true, description: `When the geometry/location fields on this row were last fetched from the source Feature Service.`}) 
    GeometryRetrievedAt?: Date;
        
    @Field({nullable: true, description: `The county's own tax district code for this parcel (source field: cnty_tax_dist_cd) — identifies the specific combination of overlapping taxing units (township + school + library + special districts) that applies.`}) 
    @MaxLength(200)
    TaxDistrictCode?: string;
        
    @Field({nullable: true, description: `Civil township this parcel is taxed under.`}) 
    @MaxLength(50)
    TaxTownship?: string;
        
    @Field({nullable: true, description: `School corporation this parcel is taxed under.`}) 
    @MaxLength(100)
    TaxSchoolCorp?: string;
        
    @Field({nullable: true, description: `Library taxing district this parcel falls in, if any.`}) 
    @MaxLength(50)
    TaxLibraryDistrict?: string;
        
    @Field({nullable: true, description: `Special taxing district(s) this parcel falls in (e.g. solid waste management), if any. Can be a combined/concatenated value per the source.`}) 
    @MaxLength(360)
    TaxSpecialDistrict?: string;
        
    @Field({nullable: true, description: `City/municipal taxing unit this parcel falls in, if any (NULL for unincorporated areas).`}) 
    @MaxLength(70)
    TaxCity?: string;
        
    @Field(() => Float, {nullable: true, description: `Parcel boundary area in decimal degrees squared (source: SHAPE__Area, confirmed unit esriDecimalDegrees) — NOT a real-world area (not square feet/meters/acres). Only useful as a cheap relative sanity-check against Acreage; a proper acreage figure would need a geodesic area calculation this field does not provide.`}) 
    ShapeAreaDecimalDegrees?: number;
        
    @Field({nullable: true, description: `The date the SOURCE (IndianaMap/IGIO Feature Service) last updated this record — distinct from GeometryRetrievedAt, which is when WE fetched it.`}) 
    SourceLoadDate?: Date;
        
    @Field({nullable: true, description: `The SourceRegistry entry for the Feature Service this parcel's geometry/location/taxing-district fields came from.`}) 
    @MaxLength(36)
    GeometrySourceRegistryID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    GeometrySourceRegistry?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [indianataxPTABOAAppeal_])
    indianataxPTABOAAppeals_ParcelIDArray: indianataxPTABOAAppeal_[]; // Link to indianataxPTABOAAppeals
    
    @Field(() => [indianataxAssessment_])
    indianataxAssessments_ParcelIDArray: indianataxAssessment_[]; // Link to indianataxAssessments
    
    @Field(() => [indianataxBoardDecision_])
    indianataxBoardDecisions_ParcelIDArray: indianataxBoardDecision_[]; // Link to indianataxBoardDecisions
    
    @Field(() => [indianataxCountyAssessorRecord_])
    indianataxCountyAssessorRecords_ParcelIDArray: indianataxCountyAssessorRecord_[]; // Link to indianataxCountyAssessorRecords
    
    @Field(() => [indianataxAppealLead_])
    indianataxAppealLeads_ParcelIDArray: indianataxAppealLead_[]; // Link to indianataxAppealLeads
    
    @Field(() => [indianataxDocumentAcquisition_])
    indianataxDocumentAcquisitions_ParcelIDArray: indianataxDocumentAcquisition_[]; // Link to indianataxDocumentAcquisitions
    
    @Field(() => [indianataxTaxHistoryYear_])
    indianataxTaxHistoryYears_ParcelIDArray: indianataxTaxHistoryYear_[]; // Link to indianataxTaxHistoryYears
    
    @Field(() => [indianataxCoStarProperty_])
    indianataxCoStarProperties_ParcelIDArray: indianataxCoStarProperty_[]; // Link to indianataxCoStarProperties
    
    @Field(() => [indianataxCoStarProperty_])
    indianataxCoStarProperties_CoStarSecondaryParcelIDArray: indianataxCoStarProperty_[]; // Link to indianataxCoStarProperties
    
    @Field(() => [indianataxSaleTransaction_])
    indianataxSaleTransactions_ParcelIDArray: indianataxSaleTransaction_[]; // Link to indianataxSaleTransactions
    
    @Field(() => [indianataxValuationAnalysis_])
    indianataxValuationAnalysis_ParcelIDArray: indianataxValuationAnalysis_[]; // Link to indianataxValuationAnalysis
    
    @Field(() => [indianataxComparableAssessmentSet_])
    indianataxComparableAssessmentSets_SubjectParcelIDArray: indianataxComparableAssessmentSet_[]; // Link to indianataxComparableAssessmentSets
    
    @Field(() => [indianataxComparableAssessmentMember_])
    indianataxComparableAssessmentMembers_ComparableParcelIDArray: indianataxComparableAssessmentMember_[]; // Link to indianataxComparableAssessmentMembers
    
    @Field(() => [indianataxCoStarIncomeInput_])
    indianataxCoStarIncomeInputs_ParcelIDArray: indianataxCoStarIncomeInput_[]; // Link to indianataxCoStarIncomeInputs
    
    @Field(() => [indianataxDLGFImprovement_])
    indianataxDLGFImprovements_ParcelIDArray: indianataxDLGFImprovement_[]; // Link to indianataxDLGFImprovements
    
    @Field(() => [indianataxDLGFLand_])
    indianataxDLGFLands_ParcelIDArray: indianataxDLGFLand_[]; // Link to indianataxDLGFLands
    
    @Field(() => [indianataxDLGFBuildingDetail_])
    indianataxDLGFBuildingDetails_ParcelIDArray: indianataxDLGFBuildingDetail_[]; // Link to indianataxDLGFBuildingDetails
    
    @Field(() => [indianataxDLGFBuilding_])
    indianataxDLGFBuildings_ParcelIDArray: indianataxDLGFBuilding_[]; // Link to indianataxDLGFBuildings
    
    @Field(() => [indianataxProspectParcel_])
    indianataxProspectParcels_ParcelIDArray: indianataxProspectParcel_[]; // Link to indianataxProspectParcels
    
    @Field(() => [indianataxOwnerPortfolioParcel_])
    indianataxOwnerPortfolioParcels_ParcelIDArray: indianataxOwnerPortfolioParcel_[]; // Link to indianataxOwnerPortfolioParcels
    
}

//****************************************************************************
// INPUT TYPE for Parcels
//****************************************************************************
@InputType()
export class CreateindianataxParcelInput {
    @Field({ nullable: true })
    ID?: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    ParcelNumber?: string;

    @Field({ nullable: true })
    GISParcelNumber: string | null;

    @Field({ nullable: true })
    Address: string | null;

    @Field({ nullable: true })
    OwnerName: string | null;

    @Field(() => Float, { nullable: true })
    Acreage: number | null;

    @Field({ nullable: true })
    Zoning: string | null;

    @Field({ nullable: true })
    PropertyClassCode: string | null;

    @Field(() => Int, { nullable: true })
    CharacteristicsSourceYear: number | null;

    @Field(() => Float, { nullable: true })
    Latitude: number | null;

    @Field(() => Float, { nullable: true })
    Longitude: number | null;

    @Field({ nullable: true })
    CountyFIPS: string | null;

    @Field({ nullable: true })
    BoundaryGeoJSON: string | null;

    @Field({ nullable: true })
    GeometryRetrievedAt: Date | null;

    @Field({ nullable: true })
    TaxDistrictCode: string | null;

    @Field({ nullable: true })
    TaxTownship: string | null;

    @Field({ nullable: true })
    TaxSchoolCorp: string | null;

    @Field({ nullable: true })
    TaxLibraryDistrict: string | null;

    @Field({ nullable: true })
    TaxSpecialDistrict: string | null;

    @Field({ nullable: true })
    TaxCity: string | null;

    @Field(() => Float, { nullable: true })
    ShapeAreaDecimalDegrees: number | null;

    @Field({ nullable: true })
    SourceLoadDate: Date | null;

    @Field({ nullable: true })
    GeometrySourceRegistryID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Parcels
//****************************************************************************
@InputType()
export class UpdateindianataxParcelInput {
    @Field()
    ID: string;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number;

    @Field({ nullable: true })
    ParcelNumber?: string;

    @Field({ nullable: true })
    GISParcelNumber?: string | null;

    @Field({ nullable: true })
    Address?: string | null;

    @Field({ nullable: true })
    OwnerName?: string | null;

    @Field(() => Float, { nullable: true })
    Acreage?: number | null;

    @Field({ nullable: true })
    Zoning?: string | null;

    @Field({ nullable: true })
    PropertyClassCode?: string | null;

    @Field(() => Int, { nullable: true })
    CharacteristicsSourceYear?: number | null;

    @Field(() => Float, { nullable: true })
    Latitude?: number | null;

    @Field(() => Float, { nullable: true })
    Longitude?: number | null;

    @Field({ nullable: true })
    CountyFIPS?: string | null;

    @Field({ nullable: true })
    BoundaryGeoJSON?: string | null;

    @Field({ nullable: true })
    GeometryRetrievedAt?: Date | null;

    @Field({ nullable: true })
    TaxDistrictCode?: string | null;

    @Field({ nullable: true })
    TaxTownship?: string | null;

    @Field({ nullable: true })
    TaxSchoolCorp?: string | null;

    @Field({ nullable: true })
    TaxLibraryDistrict?: string | null;

    @Field({ nullable: true })
    TaxSpecialDistrict?: string | null;

    @Field({ nullable: true })
    TaxCity?: string | null;

    @Field(() => Float, { nullable: true })
    ShapeAreaDecimalDegrees?: number | null;

    @Field({ nullable: true })
    SourceLoadDate?: Date | null;

    @Field({ nullable: true })
    GeometrySourceRegistryID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Parcels
//****************************************************************************
@ObjectType()
export class RunindianataxParcelViewResult {
    @Field(() => [indianataxParcel_])
    Results: indianataxParcel_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxParcel_)
export class indianataxParcelResolver extends ResolverBase {
    @Query(() => RunindianataxParcelViewResult)
    async RunindianataxParcelViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxParcelViewResult)
    async RunindianataxParcelViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxParcelViewResult)
    async RunindianataxParcelDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Parcels';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxParcel_, { nullable: true })
    async indianataxParcel(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxParcel_ | null> {
        this.CheckUserReadPermissions('Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwParcels')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Parcels', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxPTABOAAppeal_])
    async indianataxPTABOAAppeals_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('PTABOA Appeals', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwPTABOAAppeals')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'PTABOA Appeals', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('PTABOA Appeals', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAssessment_])
    async indianataxAssessments_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Assessments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAssessments')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Assessments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Assessments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxBoardDecision_])
    async indianataxBoardDecisions_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Board Decisions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwBoardDecisions')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Board Decisions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Board Decisions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorRecord_])
    async indianataxCountyAssessorRecords_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Records', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorRecords')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Records', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Records', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAppealLead_])
    async indianataxAppealLeads_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Leads', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealLeads')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Leads', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Leads', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDocumentAcquisition_])
    async indianataxDocumentAcquisitions_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Document Acquisitions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentAcquisitions')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Acquisitions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Document Acquisitions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxTaxHistoryYear_])
    async indianataxTaxHistoryYears_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Tax History Years', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwTaxHistoryYears')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Tax History Years', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Tax History Years', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCoStarProperty_])
    async indianataxCoStarProperties_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Co Star Properties', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarProperties')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Properties', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Co Star Properties', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCoStarProperty_])
    async indianataxCoStarProperties_CoStarSecondaryParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Co Star Properties', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarProperties')} WHERE ${provider.QuoteIdentifier('CoStarSecondaryParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Properties', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Co Star Properties', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxSaleTransaction_])
    async indianataxSaleTransactions_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Sale Transactions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwSaleTransactions')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Sale Transactions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Sale Transactions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxValuationAnalysis_])
    async indianataxValuationAnalysis_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Valuation Analysis', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationAnalysis')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Analysis', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Valuation Analysis', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxComparableAssessmentSet_])
    async indianataxComparableAssessmentSets_SubjectParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Comparable Assessment Sets', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwComparableAssessmentSets')} WHERE ${provider.QuoteIdentifier('SubjectParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Comparable Assessment Sets', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Comparable Assessment Sets', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxComparableAssessmentMember_])
    async indianataxComparableAssessmentMembers_ComparableParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Comparable Assessment Members', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwComparableAssessmentMembers')} WHERE ${provider.QuoteIdentifier('ComparableParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Comparable Assessment Members', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Comparable Assessment Members', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCoStarIncomeInput_])
    async indianataxCoStarIncomeInputs_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Co Star Income Inputs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarIncomeInputs')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Income Inputs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Co Star Income Inputs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFImprovement_])
    async indianataxDLGFImprovements_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Improvements', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFImprovements')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Improvements', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Improvements', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFLand_])
    async indianataxDLGFLands_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Lands', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFLands')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Lands', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Lands', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFBuildingDetail_])
    async indianataxDLGFBuildingDetails_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Building Details', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildingDetails')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Building Details', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Building Details', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFBuilding_])
    async indianataxDLGFBuildings_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Buildings', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildings')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Buildings', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Buildings', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxProspectParcel_])
    async indianataxProspectParcels_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectParcels')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Parcels', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxOwnerPortfolioParcel_])
    async indianataxOwnerPortfolioParcels_ParcelIDArray(@Root() indianataxparcel_: indianataxParcel_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Owner Portfolio Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwOwnerPortfolioParcels')} WHERE ${provider.QuoteIdentifier('ParcelID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Owner Portfolio Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxparcel_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Owner Portfolio Parcels', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxParcel_)
    async CreateindianataxParcel(
        @Arg('input', () => CreateindianataxParcelInput) input: CreateindianataxParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Parcels', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxParcel_)
    async UpdateindianataxParcel(
        @Arg('input', () => UpdateindianataxParcelInput) input: UpdateindianataxParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Parcels', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxParcel_)
    async DeleteindianataxParcel(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Parcels', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Property Class Maps
//****************************************************************************
@ObjectType({ description: `Maps an Indiana DLGF real-property class code (3 digits) to a coarse PropertyTypeGroup for comp grouping. The single source of truth for classification; consumed by the ParcelPhysicalProfile view and the SaleTransaction / ValuationAnalysis loaders. DLGF-only -- CoStar type is a separate, CoStar-labelled datapoint and never merged here. Design: Indiana_Tax_Expert/docs/proposals/property-type-classification.md.` })
export class indianataxPropertyClassMap_ {
    @Field({description: `The 3-digit DLGF real-property class code (e.g. "449").`}) 
    @MaxLength(3)
    Code: string;
        
    @Field({description: `The DLGF label for the code (from Marion's PropertySubClassDescription).`}) 
    @MaxLength(120)
    Label: string;
        
    @Field({description: `Coarse group: Retail / Office / Industrial / Multifamily / Hospitality / Land / Special / Parking / Other.`}) 
    @MaxLength(20)
    TypeGroup: string;
        
    @Field({nullable: true, description: `Rationale / borderline-call note for this mapping.`}) 
    @MaxLength(400)
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
}

//****************************************************************************
// INPUT TYPE for Property Class Maps
//****************************************************************************
@InputType()
export class CreateindianataxPropertyClassMapInput {
    @Field({ nullable: true })
    Code?: string;

    @Field({ nullable: true })
    Label?: string;

    @Field({ nullable: true })
    TypeGroup?: string;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Property Class Maps
//****************************************************************************
@InputType()
export class UpdateindianataxPropertyClassMapInput {
    @Field()
    Code: string;

    @Field({ nullable: true })
    Label?: string;

    @Field({ nullable: true })
    TypeGroup?: string;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Property Class Maps
//****************************************************************************
@ObjectType()
export class RunindianataxPropertyClassMapViewResult {
    @Field(() => [indianataxPropertyClassMap_])
    Results: indianataxPropertyClassMap_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxPropertyClassMap_)
export class indianataxPropertyClassMapResolver extends ResolverBase {
    @Query(() => RunindianataxPropertyClassMapViewResult)
    async RunindianataxPropertyClassMapViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxPropertyClassMapViewResult)
    async RunindianataxPropertyClassMapViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxPropertyClassMapViewResult)
    async RunindianataxPropertyClassMapDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Property Class Maps';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxPropertyClassMap_, { nullable: true })
    async indianataxPropertyClassMap(@Arg('Code', () => String) Code: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxPropertyClassMap_ | null> {
        this.CheckUserReadPermissions('Property Class Maps', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwPropertyClassMaps')} WHERE ${provider.QuoteIdentifier('Code')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Property Class Maps', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [Code], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Property Class Maps', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxPropertyClassMap_)
    async CreateindianataxPropertyClassMap(
        @Arg('input', () => CreateindianataxPropertyClassMapInput) input: CreateindianataxPropertyClassMapInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Property Class Maps', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxPropertyClassMap_)
    async UpdateindianataxPropertyClassMap(
        @Arg('input', () => UpdateindianataxPropertyClassMapInput) input: UpdateindianataxPropertyClassMapInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Property Class Maps', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxPropertyClassMap_)
    async DeleteindianataxPropertyClassMap(@Arg('Code', () => String) Code: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'Code', Value: Code}]);
        return this.DeleteRecord('Property Class Maps', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospect Activities
//****************************************************************************
@ObjectType({ description: `A dated touch on a Prospect -- email, call, meeting, referral, proposal, RFP, internal note, conflict-check step, or a stage change. The outreach log.` })
export class indianataxProspectActivity_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ProspectID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    ContactID?: string;
        
    @Field() 
    ActivityDate: Date;
        
    @Field() 
    @MaxLength(40)
    ActivityType: string;
        
    @Field({nullable: true}) 
    @MaxLength(10)
    Direction?: string;
        
    @Field() 
    @MaxLength(2000)
    Summary: string;
        
    @Field({nullable: true}) 
    @MaxLength(1000)
    Outcome?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    LoggedBy?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    Prospect: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    Contact?: string;
        
    @Field(() => [indianataxProspectTask_])
    indianataxProspectTasks_SourceActivityIDArray: indianataxProspectTask_[]; // Link to indianataxProspectTasks
    
}

//****************************************************************************
// INPUT TYPE for Prospect Activities
//****************************************************************************
@InputType()
export class CreateindianataxProspectActivityInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    ContactID: string | null;

    @Field({ nullable: true })
    ActivityDate?: Date;

    @Field({ nullable: true })
    ActivityType?: string;

    @Field({ nullable: true })
    Direction: string | null;

    @Field({ nullable: true })
    Summary?: string;

    @Field({ nullable: true })
    Outcome: string | null;

    @Field({ nullable: true })
    LoggedBy: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospect Activities
//****************************************************************************
@InputType()
export class UpdateindianataxProspectActivityInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    ContactID?: string | null;

    @Field({ nullable: true })
    ActivityDate?: Date;

    @Field({ nullable: true })
    ActivityType?: string;

    @Field({ nullable: true })
    Direction?: string | null;

    @Field({ nullable: true })
    Summary?: string;

    @Field({ nullable: true })
    Outcome?: string | null;

    @Field({ nullable: true })
    LoggedBy?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospect Activities
//****************************************************************************
@ObjectType()
export class RunindianataxProspectActivityViewResult {
    @Field(() => [indianataxProspectActivity_])
    Results: indianataxProspectActivity_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspectActivity_)
export class indianataxProspectActivityResolver extends ResolverBase {
    @Query(() => RunindianataxProspectActivityViewResult)
    async RunindianataxProspectActivityViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectActivityViewResult)
    async RunindianataxProspectActivityViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectActivityViewResult)
    async RunindianataxProspectActivityDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospect Activities';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspectActivity_, { nullable: true })
    async indianataxProspectActivity(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspectActivity_ | null> {
        this.CheckUserReadPermissions('Prospect Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectActivities')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospect Activities', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxProspectTask_])
    async indianataxProspectTasks_SourceActivityIDArray(@Root() indianataxprospectactivity_: indianataxProspectActivity_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectTasks')} WHERE ${provider.QuoteIdentifier('SourceActivityID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospectactivity_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxProspectActivity_)
    async CreateindianataxProspectActivity(
        @Arg('input', () => CreateindianataxProspectActivityInput) input: CreateindianataxProspectActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospect Activities', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspectActivity_)
    async UpdateindianataxProspectActivity(
        @Arg('input', () => UpdateindianataxProspectActivityInput) input: UpdateindianataxProspectActivityInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospect Activities', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspectActivity_)
    async DeleteindianataxProspectActivity(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospect Activities', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospect Contacts
//****************************************************************************
@ObjectType({ description: `A decision-maker or influencer at a Prospect company -- asset manager, CFO, GC, principal, or the outside tax rep. KnownToFirm flags an existing Faegre relationship with this individual.` })
export class indianataxProspectContact_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ProspectID: string;
        
    @Field() 
    @MaxLength(200)
    Name: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    Title?: string;
        
    @Field({nullable: true}) 
    @MaxLength(60)
    Role?: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    Email?: string;
        
    @Field({nullable: true}) 
    @MaxLength(50)
    Phone?: string;
        
    @Field({nullable: true}) 
    @MaxLength(400)
    LinkedInURL?: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    SourceNote?: string;
        
    @Field(() => Boolean) 
    KnownToFirm: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    FirmContactNote?: string;
        
    @Field(() => Boolean) 
    IsPrimary: boolean;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    Prospect: string;
        
    @Field(() => [indianataxProspectActivity_])
    indianataxProspectActivities_ContactIDArray: indianataxProspectActivity_[]; // Link to indianataxProspectActivities
    
}

//****************************************************************************
// INPUT TYPE for Prospect Contacts
//****************************************************************************
@InputType()
export class CreateindianataxProspectContactInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    Role: string | null;

    @Field({ nullable: true })
    Email: string | null;

    @Field({ nullable: true })
    Phone: string | null;

    @Field({ nullable: true })
    LinkedInURL: string | null;

    @Field({ nullable: true })
    SourceNote: string | null;

    @Field(() => Boolean, { nullable: true })
    KnownToFirm?: boolean;

    @Field({ nullable: true })
    FirmContactNote: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospect Contacts
//****************************************************************************
@InputType()
export class UpdateindianataxProspectContactInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    Role?: string | null;

    @Field({ nullable: true })
    Email?: string | null;

    @Field({ nullable: true })
    Phone?: string | null;

    @Field({ nullable: true })
    LinkedInURL?: string | null;

    @Field({ nullable: true })
    SourceNote?: string | null;

    @Field(() => Boolean, { nullable: true })
    KnownToFirm?: boolean;

    @Field({ nullable: true })
    FirmContactNote?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPrimary?: boolean;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospect Contacts
//****************************************************************************
@ObjectType()
export class RunindianataxProspectContactViewResult {
    @Field(() => [indianataxProspectContact_])
    Results: indianataxProspectContact_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspectContact_)
export class indianataxProspectContactResolver extends ResolverBase {
    @Query(() => RunindianataxProspectContactViewResult)
    async RunindianataxProspectContactViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectContactViewResult)
    async RunindianataxProspectContactViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectContactViewResult)
    async RunindianataxProspectContactDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospect Contacts';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspectContact_, { nullable: true })
    async indianataxProspectContact(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspectContact_ | null> {
        this.CheckUserReadPermissions('Prospect Contacts', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectContacts')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Contacts', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospect Contacts', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxProspectActivity_])
    async indianataxProspectActivities_ContactIDArray(@Root() indianataxprospectcontact_: indianataxProspectContact_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectActivities')} WHERE ${provider.QuoteIdentifier('ContactID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospectcontact_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Activities', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxProspectContact_)
    async CreateindianataxProspectContact(
        @Arg('input', () => CreateindianataxProspectContactInput) input: CreateindianataxProspectContactInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospect Contacts', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspectContact_)
    async UpdateindianataxProspectContact(
        @Arg('input', () => UpdateindianataxProspectContactInput) input: UpdateindianataxProspectContactInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospect Contacts', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspectContact_)
    async DeleteindianataxProspectContact(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospect Contacts', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospect Parcels
//****************************************************************************
@ObjectType({ description: `A parcel attached to a Prospect. Disposition scopes the pursuit to specific parcels rather than the owner\'s whole footprint (e.g. the Keystone reconciliation: only 3 of ~21 portfolio projects are actually owned -> the rest are Excluded with a note). IsTrigger marks the parcel/event that prompted identification.` })
export class indianataxProspectParcel_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ProspectID: string;
        
    @Field() 
    @MaxLength(36)
    ParcelID: string;
        
    @Field({description: `InScope | AlreadyRepresented | Excluded | Monitoring.`}) 
    @MaxLength(40)
    Disposition: string;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    DispositionNote?: string;
        
    @Field(() => Boolean) 
    IsTrigger: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    ExistingRep?: string;
        
    @Field(() => Float, {nullable: true}) 
    SnapshotAV?: number;
        
    @Field(() => Float, {nullable: true}) 
    SnapshotOpportunityAtAsk?: number;
        
    @Field(() => Float, {nullable: true}) 
    SnapshotOpportunityAtFloor?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    Prospect: string;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Prospect Parcels
//****************************************************************************
@InputType()
export class CreateindianataxProspectParcelInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    Disposition?: string;

    @Field({ nullable: true })
    DispositionNote: string | null;

    @Field(() => Boolean, { nullable: true })
    IsTrigger?: boolean;

    @Field({ nullable: true })
    ExistingRep: string | null;

    @Field(() => Float, { nullable: true })
    SnapshotAV: number | null;

    @Field(() => Float, { nullable: true })
    SnapshotOpportunityAtAsk: number | null;

    @Field(() => Float, { nullable: true })
    SnapshotOpportunityAtFloor: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospect Parcels
//****************************************************************************
@InputType()
export class UpdateindianataxProspectParcelInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    Disposition?: string;

    @Field({ nullable: true })
    DispositionNote?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsTrigger?: boolean;

    @Field({ nullable: true })
    ExistingRep?: string | null;

    @Field(() => Float, { nullable: true })
    SnapshotAV?: number | null;

    @Field(() => Float, { nullable: true })
    SnapshotOpportunityAtAsk?: number | null;

    @Field(() => Float, { nullable: true })
    SnapshotOpportunityAtFloor?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospect Parcels
//****************************************************************************
@ObjectType()
export class RunindianataxProspectParcelViewResult {
    @Field(() => [indianataxProspectParcel_])
    Results: indianataxProspectParcel_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspectParcel_)
export class indianataxProspectParcelResolver extends ResolverBase {
    @Query(() => RunindianataxProspectParcelViewResult)
    async RunindianataxProspectParcelViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectParcelViewResult)
    async RunindianataxProspectParcelViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectParcelViewResult)
    async RunindianataxProspectParcelDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospect Parcels';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspectParcel_, { nullable: true })
    async indianataxProspectParcel(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspectParcel_ | null> {
        this.CheckUserReadPermissions('Prospect Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectParcels')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospect Parcels', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxProspectParcel_)
    async CreateindianataxProspectParcel(
        @Arg('input', () => CreateindianataxProspectParcelInput) input: CreateindianataxProspectParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospect Parcels', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspectParcel_)
    async UpdateindianataxProspectParcel(
        @Arg('input', () => UpdateindianataxProspectParcelInput) input: UpdateindianataxProspectParcelInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospect Parcels', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspectParcel_)
    async DeleteindianataxProspectParcel(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospect Parcels', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospect Snapshots
//****************************************************************************
@ObjectType({ description: `Point-in-time deal metrics for a Prospect, written by the portfolio job (scripts/sync-prospect-snapshots.js) on each build-owner-portfolios.js run -- never edited by hand. The two newest rows drive the "Scope changed" view (parcel added/sold, AV moved >10%, a repped parcel went un-repped, opportunity crossed a threshold).` })
export class indianataxProspectSnapshot_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ProspectID: string;
        
    @Field() 
    SnapshotDate: Date;
        
    @Field({nullable: true}) 
    @MaxLength(60)
    PortfolioRunTag?: string;
        
    @Field(() => Int, {nullable: true}) 
    ParcelCount?: number;
        
    @Field(() => Float, {nullable: true}) 
    TotalAV?: number;
        
    @Field(() => Float, {nullable: true}) 
    TotalTaxLiability?: number;
        
    @Field(() => Float, {nullable: true}) 
    OpportunityAtAsk?: number;
        
    @Field(() => Float, {nullable: true}) 
    OpportunityAtFloor?: number;
        
    @Field(() => Int, {nullable: true}) 
    RepdParcelCount?: number;
        
    @Field(() => Int, {nullable: true}) 
    FreshParcelCount?: number;
        
    @Field(() => Float, {nullable: true}) 
    AVYoYPct?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    Prospect: string;
        
}

//****************************************************************************
// INPUT TYPE for Prospect Snapshots
//****************************************************************************
@InputType()
export class CreateindianataxProspectSnapshotInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    SnapshotDate?: Date;

    @Field({ nullable: true })
    PortfolioRunTag: string | null;

    @Field(() => Int, { nullable: true })
    ParcelCount: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV: number | null;

    @Field(() => Float, { nullable: true })
    TotalTaxLiability: number | null;

    @Field(() => Float, { nullable: true })
    OpportunityAtAsk: number | null;

    @Field(() => Float, { nullable: true })
    OpportunityAtFloor: number | null;

    @Field(() => Int, { nullable: true })
    RepdParcelCount: number | null;

    @Field(() => Int, { nullable: true })
    FreshParcelCount: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospect Snapshots
//****************************************************************************
@InputType()
export class UpdateindianataxProspectSnapshotInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    SnapshotDate?: Date;

    @Field({ nullable: true })
    PortfolioRunTag?: string | null;

    @Field(() => Int, { nullable: true })
    ParcelCount?: number | null;

    @Field(() => Float, { nullable: true })
    TotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    TotalTaxLiability?: number | null;

    @Field(() => Float, { nullable: true })
    OpportunityAtAsk?: number | null;

    @Field(() => Float, { nullable: true })
    OpportunityAtFloor?: number | null;

    @Field(() => Int, { nullable: true })
    RepdParcelCount?: number | null;

    @Field(() => Int, { nullable: true })
    FreshParcelCount?: number | null;

    @Field(() => Float, { nullable: true })
    AVYoYPct?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospect Snapshots
//****************************************************************************
@ObjectType()
export class RunindianataxProspectSnapshotViewResult {
    @Field(() => [indianataxProspectSnapshot_])
    Results: indianataxProspectSnapshot_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspectSnapshot_)
export class indianataxProspectSnapshotResolver extends ResolverBase {
    @Query(() => RunindianataxProspectSnapshotViewResult)
    async RunindianataxProspectSnapshotViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectSnapshotViewResult)
    async RunindianataxProspectSnapshotViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectSnapshotViewResult)
    async RunindianataxProspectSnapshotDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospect Snapshots';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspectSnapshot_, { nullable: true })
    async indianataxProspectSnapshot(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspectSnapshot_ | null> {
        this.CheckUserReadPermissions('Prospect Snapshots', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectSnapshots')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Snapshots', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospect Snapshots', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxProspectSnapshot_)
    async CreateindianataxProspectSnapshot(
        @Arg('input', () => CreateindianataxProspectSnapshotInput) input: CreateindianataxProspectSnapshotInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospect Snapshots', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspectSnapshot_)
    async UpdateindianataxProspectSnapshot(
        @Arg('input', () => UpdateindianataxProspectSnapshotInput) input: UpdateindianataxProspectSnapshotInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospect Snapshots', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspectSnapshot_)
    async DeleteindianataxProspectSnapshot(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospect Snapshots', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospect Tasks
//****************************************************************************
@ObjectType({ description: `The outreach queue -- one actionable item per row. A "next step" logged on a ProspectActivity spawns a ProspectTask via SourceActivityID. Drives the My Queue view.` })
export class indianataxProspectTask_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ProspectID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    SourceActivityID?: string;
        
    @Field() 
    @MaxLength(400)
    Title: string;
        
    @Field({nullable: true}) 
    DueDate?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    Assignee?: string;
        
    @Field() 
    @MaxLength(20)
    Status: string;
        
    @Field({nullable: true}) 
    CompletedDate?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(1000)
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(300)
    Prospect: string;
        
    @Field({nullable: true}) 
    @MaxLength(40)
    SourceActivity?: string;
        
}

//****************************************************************************
// INPUT TYPE for Prospect Tasks
//****************************************************************************
@InputType()
export class CreateindianataxProspectTaskInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    SourceActivityID: string | null;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    DueDate: Date | null;

    @Field({ nullable: true })
    Assignee: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    CompletedDate: Date | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospect Tasks
//****************************************************************************
@InputType()
export class UpdateindianataxProspectTaskInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ProspectID?: string;

    @Field({ nullable: true })
    SourceActivityID?: string | null;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    DueDate?: Date | null;

    @Field({ nullable: true })
    Assignee?: string | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    CompletedDate?: Date | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospect Tasks
//****************************************************************************
@ObjectType()
export class RunindianataxProspectTaskViewResult {
    @Field(() => [indianataxProspectTask_])
    Results: indianataxProspectTask_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspectTask_)
export class indianataxProspectTaskResolver extends ResolverBase {
    @Query(() => RunindianataxProspectTaskViewResult)
    async RunindianataxProspectTaskViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectTaskViewResult)
    async RunindianataxProspectTaskViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectTaskViewResult)
    async RunindianataxProspectTaskDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospect Tasks';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspectTask_, { nullable: true })
    async indianataxProspectTask(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspectTask_ | null> {
        this.CheckUserReadPermissions('Prospect Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectTasks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospect Tasks', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxProspectTask_)
    async CreateindianataxProspectTask(
        @Arg('input', () => CreateindianataxProspectTaskInput) input: CreateindianataxProspectTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospect Tasks', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspectTask_)
    async UpdateindianataxProspectTask(
        @Arg('input', () => UpdateindianataxProspectTaskInput) input: UpdateindianataxProspectTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospect Tasks', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspectTask_)
    async DeleteindianataxProspectTask(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospect Tasks', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Prospects
//****************************************************************************
@ObjectType({ description: `A flagged prospecting target -- one operating company we are pursuing for property tax representation. Built over the Owner Prospects screen (scripts/build-owner-portfolios.js). Human-entered pipeline / workflow state; NOT a system of record. See docs/proposals/prospecting-crm.md.` })
export class indianataxProspect_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Stable join key = normalized ParcelOwnerResolved.CoStarTrueOwner (fallback: MailKey + normalized RawOwnerName). This -- not a regenerated row id -- is what re-links a prospect to the portfolio screen across re-runs. Unique.`}) 
    @MaxLength(200)
    OwnerKey: string;
        
    @Field() 
    @MaxLength(300)
    DisplayName: string;
        
    @Field({description: `Cold | ExistingClientExpand | CompetitorRepped | FormerClient | Unknown. The routing signal: ExistingClientExpand (e.g. Keystone, Square Deal show "Represented by FAEGRE DRINKER" in the screen) goes to the relationship partner as cross-sell, not cold outreach.`}) 
    @MaxLength(30)
    RelationshipType: string;
        
    @Field({description: `Pipeline stage. May not advance past Qualified until ConflictCheckStatus is Cleared or Waived.`}) 
    @MaxLength(30)
    Stage: string;
        
    @Field({nullable: true}) 
    StageEnteredDate?: Date;
        
    @Field() 
    @MaxLength(10)
    Priority: string;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    AssignedTo?: string;
        
    @Field({nullable: true}) 
    IdentifiedDate?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(120)
    IdentificationSource?: string;
        
    @Field({nullable: true}) 
    NextActionDate?: Date;
        
    @Field() 
    @MaxLength(30)
    ConflictCheckStatus: string;
        
    @Field({nullable: true}) 
    @MaxLength(1000)
    ConflictCheckNote?: string;
        
    @Field({nullable: true, description: `Free text -- the reason this target was flagged, e.g. "bought the Sheraton (1097651) below the 2026 AV; 9 Marion parcels, $135M AV".`}) 
    @MaxLength(2000)
    Thesis?: string;
        
    @Field(() => Float, {nullable: true, description: `Convenience copy of the most recent ProspectSnapshot.OpportunityAtAsk, maintained by scripts/sync-prospect-snapshots.js, so the pipeline can be sorted by dollars without a join.`}) 
    EstimatedOpportunityAtAsk?: number;
        
    @Field() 
    @MaxLength(20)
    Status: string;
        
    @Field({nullable: true}) 
    ClosedDate?: Date;
        
    @Field({nullable: true}) 
    @MaxLength(500)
    ClosedReason?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [indianataxProspectActivity_])
    indianataxProspectActivities_ProspectIDArray: indianataxProspectActivity_[]; // Link to indianataxProspectActivities
    
    @Field(() => [indianataxProspectContact_])
    indianataxProspectContacts_ProspectIDArray: indianataxProspectContact_[]; // Link to indianataxProspectContacts
    
    @Field(() => [indianataxProspectSnapshot_])
    indianataxProspectSnapshots_ProspectIDArray: indianataxProspectSnapshot_[]; // Link to indianataxProspectSnapshots
    
    @Field(() => [indianataxProspectTask_])
    indianataxProspectTasks_ProspectIDArray: indianataxProspectTask_[]; // Link to indianataxProspectTasks
    
    @Field(() => [indianataxProspectParcel_])
    indianataxProspectParcels_ProspectIDArray: indianataxProspectParcel_[]; // Link to indianataxProspectParcels
    
}

//****************************************************************************
// INPUT TYPE for Prospects
//****************************************************************************
@InputType()
export class CreateindianataxProspectInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    OwnerKey?: string;

    @Field({ nullable: true })
    DisplayName?: string;

    @Field({ nullable: true })
    RelationshipType?: string;

    @Field({ nullable: true })
    Stage?: string;

    @Field({ nullable: true })
    StageEnteredDate: Date | null;

    @Field({ nullable: true })
    Priority?: string;

    @Field({ nullable: true })
    AssignedTo: string | null;

    @Field({ nullable: true })
    IdentifiedDate: Date | null;

    @Field({ nullable: true })
    IdentificationSource: string | null;

    @Field({ nullable: true })
    NextActionDate: Date | null;

    @Field({ nullable: true })
    ConflictCheckStatus?: string;

    @Field({ nullable: true })
    ConflictCheckNote: string | null;

    @Field({ nullable: true })
    Thesis: string | null;

    @Field(() => Float, { nullable: true })
    EstimatedOpportunityAtAsk: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    ClosedDate: Date | null;

    @Field({ nullable: true })
    ClosedReason: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Prospects
//****************************************************************************
@InputType()
export class UpdateindianataxProspectInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    OwnerKey?: string;

    @Field({ nullable: true })
    DisplayName?: string;

    @Field({ nullable: true })
    RelationshipType?: string;

    @Field({ nullable: true })
    Stage?: string;

    @Field({ nullable: true })
    StageEnteredDate?: Date | null;

    @Field({ nullable: true })
    Priority?: string;

    @Field({ nullable: true })
    AssignedTo?: string | null;

    @Field({ nullable: true })
    IdentifiedDate?: Date | null;

    @Field({ nullable: true })
    IdentificationSource?: string | null;

    @Field({ nullable: true })
    NextActionDate?: Date | null;

    @Field({ nullable: true })
    ConflictCheckStatus?: string;

    @Field({ nullable: true })
    ConflictCheckNote?: string | null;

    @Field({ nullable: true })
    Thesis?: string | null;

    @Field(() => Float, { nullable: true })
    EstimatedOpportunityAtAsk?: number | null;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    ClosedDate?: Date | null;

    @Field({ nullable: true })
    ClosedReason?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Prospects
//****************************************************************************
@ObjectType()
export class RunindianataxProspectViewResult {
    @Field(() => [indianataxProspect_])
    Results: indianataxProspect_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxProspect_)
export class indianataxProspectResolver extends ResolverBase {
    @Query(() => RunindianataxProspectViewResult)
    async RunindianataxProspectViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectViewResult)
    async RunindianataxProspectViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxProspectViewResult)
    async RunindianataxProspectDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Prospects';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxProspect_, { nullable: true })
    async indianataxProspect(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxProspect_ | null> {
        this.CheckUserReadPermissions('Prospects', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspects')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospects', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Prospects', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxProspectActivity_])
    async indianataxProspectActivities_ProspectIDArray(@Root() indianataxprospect_: indianataxProspect_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Activities', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectActivities')} WHERE ${provider.QuoteIdentifier('ProspectID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Activities', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospect_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Activities', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxProspectContact_])
    async indianataxProspectContacts_ProspectIDArray(@Root() indianataxprospect_: indianataxProspect_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Contacts', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectContacts')} WHERE ${provider.QuoteIdentifier('ProspectID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Contacts', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospect_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Contacts', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxProspectSnapshot_])
    async indianataxProspectSnapshots_ProspectIDArray(@Root() indianataxprospect_: indianataxProspect_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Snapshots', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectSnapshots')} WHERE ${provider.QuoteIdentifier('ProspectID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Snapshots', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospect_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Snapshots', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxProspectTask_])
    async indianataxProspectTasks_ProspectIDArray(@Root() indianataxprospect_: indianataxProspect_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectTasks')} WHERE ${provider.QuoteIdentifier('ProspectID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospect_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxProspectParcel_])
    async indianataxProspectParcels_ProspectIDArray(@Root() indianataxprospect_: indianataxProspect_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Prospect Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwProspectParcels')} WHERE ${provider.QuoteIdentifier('ProspectID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Prospect Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxprospect_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Prospect Parcels', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxProspect_)
    async CreateindianataxProspect(
        @Arg('input', () => CreateindianataxProspectInput) input: CreateindianataxProspectInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Prospects', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxProspect_)
    async UpdateindianataxProspect(
        @Arg('input', () => UpdateindianataxProspectInput) input: UpdateindianataxProspectInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Prospects', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxProspect_)
    async DeleteindianataxProspect(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Prospects', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for PTABOA Appeals
//****************************************************************************
@ObjectType({ description: `A county Property Tax Assessment Board of Appeals (PTABOA) case for a parcel — a row here means an appeal was filed. Distinct from BoardDecision, which is a state-level IBTR ruling.` })
export class indianataxPTABOAAppeal_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel under appeal.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field(() => Int, {nullable: true, description: `The assessment year being appealed.`}) 
    AssessmentYear?: number;
        
    @Field({nullable: true, description: `Date of the PTABOA hearing, per the agenda.`}) 
    HearingDate?: Date;
        
    @Field({nullable: true, description: `Outcome of the appeal (e.g. Pending, Reduced, Withdrawn, Denied), as best determined from the agenda/decision text.`}) 
    @MaxLength(50)
    DecisionStatus?: string;
        
    @Field({nullable: true, description: `Free-text circumstances/notes about the appeal, extracted from the agenda.`}) 
    Circumstances?: string;
        
    @Field({nullable: true, description: `The PTABOA agenda document this appeal was extracted from.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The PTABOA case number for this appeal/exemption record (e.g. "49-500-23-0-4-00045"), as printed on the agenda. Confirmed unique per source agenda PDF -- the natural key this table lacked before this migration.`}) 
    @MaxLength(50)
    CaseNumber?: string;
        
    @Field({nullable: true, description: `Who represented the taxpayer in this matter -- a law firm, tax-advocate firm, or individual name, exactly as printed on the PTABOA agenda (e.g. "LANDMAN BEATTY, LAWYERS Attn: KATHRYN M. MERRITT-THRASHER", "JM Tax Advocates Attn: Joshua J. Malancuk"). NULL means no representative is listed on the agenda for this record -- most commonly a self-represented petitioner, not a parsing gap (confirmed 2026-08-26: ~60% of records across the currently-loaded 2024-12 through 2025-12 agendas have one).`}) 
    @MaxLength(200)
    TaxRepresentative?: string;
        
    @Field(() => Float, {nullable: true, description: `Land assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.`}) 
    BeforeLandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Improvement assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.`}) 
    BeforeImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Total assessed value (Land + Improvement) BEFORE this appeal/exemption was decided.`}) 
    BeforeTotalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Land assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeLandAV when the appeal produced no land-value change.`}) 
    AfterLandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Improvement assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeImprovementAV when the appeal produced no improvement-value change.`}) 
    AfterImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Total assessed value (Land + Improvement) AFTER this appeal/exemption was decided. AfterTotalAV - BeforeTotalAV is this appeal's AV change (negative = a reduction) -- computed at query/display time rather than stored, to avoid drift.`}) 
    AfterTotalAV?: number;
        
    @Field({nullable: true, description: `Whether this record is a valuation Appeal or an Exemption request, per the agenda page's own "For Appeal/Exemption <form> Year: <year>" header. NOT the same question as DecisionStatus (which appeal/exemption records can both carry, e.g. "Exemption-Approved" vs "Final Agreement") -- this is the request TYPE, DecisionStatus is the outcome.`}) 
    @MaxLength(20)
    RecordKind?: string;
        
    @Field({nullable: true, description: `The Indiana form number this record was filed under, e.g. "130S" (subjective/market-value valuation appeal -- the most directly informative type for sub-class assessed-value analytics), "130O" (objective/mathematical-error valuation appeal), "136" or "136C" (charitable/nonprofit exemption request -- NOT a valuation dispute; exclude from win-rate/avg-reduction rollups meant to describe assessed-value accuracy).`}) 
    @MaxLength(20)
    AppealType?: string;
        
    @Field({nullable: true, description: `The SourceDocument row for the monthly Final Determination batch PDF that confirmed this appeal's outcome, matched by (parcel, assessment year) against a real Form 115 within that batch. NULL means this appeal's agenda-reported outcome has NOT yet been confirmed by an actual Final Determination -- do not treat DecisionStatus/AfterTotalAV as final while this is NULL; see the migration header for a real example of an agenda "Final Agreement" label that turned out to be premature.`}) 
    @MaxLength(36)
    FinalDeterminationSourceDocumentID?: string;
        
    @Field(() => Float, {nullable: true, description: `Land assessed value from the actual ratified Form 115 (SECTION III: FINAL DETERMINATION), once confirmed. Compare against BeforeLandAV (the agenda's own before-figure) -- do NOT assume this always equals AfterLandAV; the rare case where it differs is exactly the discrepancy this column exists to catch.`}) 
    FinalDeterminationLandAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Improvement assessed value from the actual ratified Form 115, once confirmed. See FinalDeterminationLandAV's comment.`}) 
    FinalDeterminationImprovementAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Total assessed value (Land + Improvement) from the actual ratified Form 115, once confirmed. Compare against AfterTotalAV (the agenda's own prediction) -- a mismatch here is a genuine "the board changed what the parties proposed" case, the specific scenario this table's Final Determination columns exist to catch. NULL (unconfirmed) is expected for most recent appeals -- Final Determination batches lag the agenda by weeks to months.`}) 
    FinalDeterminationTotalAV?: number;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for PTABOA Appeals
//****************************************************************************
@InputType()
export class CreateindianataxPTABOAAppealInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear: number | null;

    @Field({ nullable: true })
    HearingDate: Date | null;

    @Field({ nullable: true })
    DecisionStatus: string | null;

    @Field({ nullable: true })
    Circumstances: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    CaseNumber: string | null;

    @Field({ nullable: true })
    TaxRepresentative: string | null;

    @Field(() => Float, { nullable: true })
    BeforeLandAV: number | null;

    @Field(() => Float, { nullable: true })
    BeforeImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    BeforeTotalAV: number | null;

    @Field(() => Float, { nullable: true })
    AfterLandAV: number | null;

    @Field(() => Float, { nullable: true })
    AfterImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    AfterTotalAV: number | null;

    @Field({ nullable: true })
    RecordKind: string | null;

    @Field({ nullable: true })
    AppealType: string | null;

    @Field({ nullable: true })
    FinalDeterminationSourceDocumentID: string | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationLandAV: number | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationImprovementAV: number | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationTotalAV: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for PTABOA Appeals
//****************************************************************************
@InputType()
export class UpdateindianataxPTABOAAppealInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number | null;

    @Field({ nullable: true })
    HearingDate?: Date | null;

    @Field({ nullable: true })
    DecisionStatus?: string | null;

    @Field({ nullable: true })
    Circumstances?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    CaseNumber?: string | null;

    @Field({ nullable: true })
    TaxRepresentative?: string | null;

    @Field(() => Float, { nullable: true })
    BeforeLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    BeforeImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    BeforeTotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    AfterLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    AfterImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    AfterTotalAV?: number | null;

    @Field({ nullable: true })
    RecordKind?: string | null;

    @Field({ nullable: true })
    AppealType?: string | null;

    @Field({ nullable: true })
    FinalDeterminationSourceDocumentID?: string | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationLandAV?: number | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationImprovementAV?: number | null;

    @Field(() => Float, { nullable: true })
    FinalDeterminationTotalAV?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for PTABOA Appeals
//****************************************************************************
@ObjectType()
export class RunindianataxPTABOAAppealViewResult {
    @Field(() => [indianataxPTABOAAppeal_])
    Results: indianataxPTABOAAppeal_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxPTABOAAppeal_)
export class indianataxPTABOAAppealResolver extends ResolverBase {
    @Query(() => RunindianataxPTABOAAppealViewResult)
    async RunindianataxPTABOAAppealViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxPTABOAAppealViewResult)
    async RunindianataxPTABOAAppealViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxPTABOAAppealViewResult)
    async RunindianataxPTABOAAppealDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'PTABOA Appeals';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxPTABOAAppeal_, { nullable: true })
    async indianataxPTABOAAppeal(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxPTABOAAppeal_ | null> {
        this.CheckUserReadPermissions('PTABOA Appeals', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwPTABOAAppeals')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'PTABOA Appeals', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('PTABOA Appeals', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxPTABOAAppeal_)
    async CreateindianataxPTABOAAppeal(
        @Arg('input', () => CreateindianataxPTABOAAppealInput) input: CreateindianataxPTABOAAppealInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('PTABOA Appeals', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxPTABOAAppeal_)
    async UpdateindianataxPTABOAAppeal(
        @Arg('input', () => UpdateindianataxPTABOAAppealInput) input: UpdateindianataxPTABOAAppealInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('PTABOA Appeals', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxPTABOAAppeal_)
    async DeleteindianataxPTABOAAppeal(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('PTABOA Appeals', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Research Tasks
//****************************************************************************
@ObjectType({ description: `A research direction identified, evaluated, and tracked — most often deliberately deferred (too large to pursue immediately, or needing a scope decision) rather than silently dropped. The paper trail for "we looked into this and chose not to pursue it yet," distinct from SourceRegistry (sources monitored) and DocumentCatalog (documents reviewed).` })
export class indianataxResearchTask_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Short name for the task.`}) 
    @MaxLength(200)
    Title: string;
        
    @Field({description: `What this task is — what was found, what it would take to pursue it.`}) 
    Description: string;
        
    @Field({description: `Open (identified, not yet evaluated further) / Deferred (evaluated, deliberately held) / InProgress / Completed / Abandoned (evaluated and decided not worth pursuing at all, distinct from Deferred).`}) 
    @MaxLength(20)
    Status: string;
        
    @Field({nullable: true, description: `Why this is being held rather than pursued now — e.g. scale, needs a scope decision, needs tooling not yet built, needs a source spec not yet found.`}) 
    DeferralReason?: string;
        
    @Field({nullable: true, description: `The SourceRegistry entry this task concerns, if any.`}) 
    @MaxLength(36)
    RelatedSourceRegistryID?: string;
        
    @Field({nullable: true, description: `The SourceDocument this task concerns, if any (e.g. a spec document that unblocks the task once found).`}) 
    @MaxLength(36)
    RelatedSourceDocumentID?: string;
        
    @Field({description: `When this task was first identified.`}) 
    RaisedAt: Date;
        
    @Field({nullable: true, description: `A natural date to reconsider this task, if there is one (e.g. a next annual data cycle). NULL means "revisit whenever it becomes a priority," not "no need to revisit."`}) 
    RevisitAt?: Date;
        
    @Field({nullable: true, description: `Free-text running notes — updated as understanding of the task evolves.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    RelatedSourceRegistry?: string;
        
}

//****************************************************************************
// INPUT TYPE for Research Tasks
//****************************************************************************
@InputType()
export class CreateindianataxResearchTaskInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    Description?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DeferralReason: string | null;

    @Field({ nullable: true })
    RelatedSourceRegistryID: string | null;

    @Field({ nullable: true })
    RelatedSourceDocumentID: string | null;

    @Field({ nullable: true })
    RaisedAt?: Date;

    @Field({ nullable: true })
    RevisitAt: Date | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Research Tasks
//****************************************************************************
@InputType()
export class UpdateindianataxResearchTaskInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    Description?: string;

    @Field({ nullable: true })
    Status?: string;

    @Field({ nullable: true })
    DeferralReason?: string | null;

    @Field({ nullable: true })
    RelatedSourceRegistryID?: string | null;

    @Field({ nullable: true })
    RelatedSourceDocumentID?: string | null;

    @Field({ nullable: true })
    RaisedAt?: Date;

    @Field({ nullable: true })
    RevisitAt?: Date | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Research Tasks
//****************************************************************************
@ObjectType()
export class RunindianataxResearchTaskViewResult {
    @Field(() => [indianataxResearchTask_])
    Results: indianataxResearchTask_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxResearchTask_)
export class indianataxResearchTaskResolver extends ResolverBase {
    @Query(() => RunindianataxResearchTaskViewResult)
    async RunindianataxResearchTaskViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxResearchTaskViewResult)
    async RunindianataxResearchTaskViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxResearchTaskViewResult)
    async RunindianataxResearchTaskDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Research Tasks';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxResearchTask_, { nullable: true })
    async indianataxResearchTask(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxResearchTask_ | null> {
        this.CheckUserReadPermissions('Research Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwResearchTasks')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Research Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Research Tasks', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxResearchTask_)
    async CreateindianataxResearchTask(
        @Arg('input', () => CreateindianataxResearchTaskInput) input: CreateindianataxResearchTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Research Tasks', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxResearchTask_)
    async UpdateindianataxResearchTask(
        @Arg('input', () => UpdateindianataxResearchTaskInput) input: UpdateindianataxResearchTaskInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Research Tasks', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxResearchTask_)
    async DeleteindianataxResearchTask(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Research Tasks', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Sale Transactions
//****************************************************************************
@ObjectType({ description: `One observed real-estate sale -- the sales-comparison comp pool. Subject sales and off-portfolio comps both live here (ParcelID nullable). Populated from data already loaded (CountyAssessorSaleHistory + CoStarProperty), no new acquisition. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.` })
export class indianataxSaleTransaction_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Where this observation came from: MarionPRC (the PRC "Transfer of Ownership" section, via CountyAssessorSaleHistory), CoStar, SalesDisclosure, Recorder, or Manual.`}) 
    @MaxLength(20)
    Source: string;
        
    @Field({nullable: true, description: `The SourceDocument this sale was read from (e.g. the parcel's PRC). NULL for a manually-entered comp.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field({nullable: true, description: `The Parcel that transacted, when it is one of the project's parcels. NULL for an off-portfolio comp (address/attributes still recorded).`}) 
    @MaxLength(36)
    ParcelID?: string;
        
    @Field(() => Int, {nullable: true, description: `Indiana county number of the property that sold.`}) 
    CountyNumber?: number;
        
    @Field({nullable: true, description: `Street address of the property that sold, as recorded at load time.`}) 
    @MaxLength(200)
    SitusAddress?: string;
        
    @Field({nullable: true, description: `City of the property that sold.`}) 
    @MaxLength(80)
    City?: string;
        
    @Field({nullable: true, description: `Submarket label (from CoStar where available) -- used to group/adjust comps by location.`}) 
    @MaxLength(80)
    Submarket?: string;
        
    @Field({nullable: true, description: `The assessor property class code as of load (e.g. "447", "350", "400") -- the primary comp-grouping key.`}) 
    @MaxLength(10)
    PropertyClassCode?: string;
        
    @Field({nullable: true, description: `Rolled-up category derived from PropertyClassCode: Retail, Office, Industrial, Multifamily, Land, Special, or Other. Coarser grouping for comp selection when the exact class pool is thin.`}) 
    @MaxLength(30)
    PropertyTypeGroup?: string;
        
    @Field({description: `Date of the sale.`}) 
    SaleDate: Date;
        
    @Field(() => Float, {description: `Recorded sale price.`}) 
    SalePrice: number;
        
    @Field({nullable: true, description: `Seller. The PRC transfer section records the grantor only.`}) 
    @MaxLength(200)
    Grantor?: string;
        
    @Field({nullable: true, description: `Buyer, when available (CoStar / recorder). NULL from PRC transfer data.`}) 
    @MaxLength(200)
    Grantee?: string;
        
    @Field({nullable: true, description: `The county's sale-type label ("Straight" / "Sale" / "Split" in Marion) or deed type (warranty / quitclaim ...).`}) 
    @MaxLength(30)
    DeedOrSaleType?: string;
        
    @Field(() => Boolean, {nullable: true, description: `The county's own valid/invalid designation for this sale, recorded VERBATIM as metadata. It reflects the county's ratio-study / trending methodology (DLGF rules), NOT whether the sale is a good comparable for a subjective valuation argument -- many county-"invalid" sales are legitimate market evidence. DO NOT gate comp selection on this column.`}) 
    CountyValidForTrending?: boolean;
        
    @Field({nullable: true, description: `Any note the county attached to its validity determination.`}) 
    @MaxLength(200)
    CountyValidityNote?: string;
        
    @Field(() => Boolean, {nullable: true, description: `A separate, analyst-owned judgement about whether this transaction is usable as market evidence for an analysis. Starts NULL (unassessed); set deliberately during comp review with the reasoning in VerificationNote. NOT copied from CountyValidForTrending.`}) 
    IsArmsLength?: boolean;
        
    @Field({nullable: true, description: `Free text: why this sale was verified in or excluded as market evidence (conditions of sale, related parties, personal property included, portfolio allocation, etc.).`}) 
    @MaxLength(400)
    VerificationNote?: string;
        
    @Field(() => Int, {nullable: true, description: `Building area (sq ft) as of load -- from the PRC (SqFtSource = PropertyRecordCard) or CoStar RBA. Stored, not looked up live, so a comp stays reproducible.`}) 
    BuildingSqFt?: number;
        
    @Field(() => Int, {nullable: true, description: `Unit count (multifamily) as of load, where known.`}) 
    UnitCount?: number;
        
    @Field(() => Float, {nullable: true, description: `Land area (acres) as of load.`}) 
    Acres?: number;
        
    @Field(() => Int, {nullable: true, description: `Year built as of load.`}) 
    YearBuilt?: number;
        
    @Field({nullable: true, description: `Condition / grade descriptor as of load, where known.`}) 
    @MaxLength(20)
    ConditionGrade?: string;
        
    @Field(() => Float, {nullable: true, description: `SalePrice / BuildingSqFt, computed at load. NULL when BuildingSqFt is unknown.`}) 
    PricePerSqFt?: number;
        
    @Field(() => Float, {nullable: true, description: `SalePrice / UnitCount, computed at load. NULL when UnitCount is unknown.`}) 
    PricePerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `SalePrice / Acres, computed at load. NULL when Acres is unknown.`}) 
    PricePerAcre?: number;
        
    @Field({nullable: true, description: `Free-text notes about this transaction.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({description: `ClosedSale (a completed transaction -- the only kind that should enter comp selection), UnderContract (pending), or ActiveListing (currently for sale; SalePrice is the list/asking price). Listings are retained for lead generation -- a property listed below its assessed value is an appeal signal -- but must be filtered out of any comp analysis.`}) 
    @MaxLength(20)
    TransactionKind: string;
        
    @Field(() => Float, {nullable: true, description: `The county assessed (total) value applicable around the transaction date. From the CoStar export directly for CoStar rows; backfilled from indiana_tax.Assessment (nearest AssessmentYear within +/- 2 of the sale year) for PRC-sourced transfers. NULL when no contemporaneous AV is available (older transfers).`}) 
    AssessedValueAtSale?: number;
        
    @Field(() => Int, {nullable: true, description: `The assessment year of AssessedValueAtSale.`}) 
    AssessedYearAtSale?: number;
        
    @Field(() => Float, {nullable: true, description: `SalePrice / AssessedValueAtSale, computed at load. Below ~1.0 means the property sold for less than its assessment -- an over-assessment / appeal candidate. Interpret with the sale's IsArmsLength and any allocation/portfolio note: a per-parcel slice price of a portfolio deal against a whole-portfolio AV produces a misleadingly low ratio.`}) 
    SaleToAssessedRatio?: number;
        
    @Field(() => Float, {nullable: true, description: `The overall (going-in) capitalization rate reported for this transaction, as a DECIMAL FRACTION (0.0650 = 6.50%). From the CoStar "Actual Cap Rate" field; NULL when not reported (the majority of sales).`}) 
    CapRateAtSale?: number;
        
    @Field(() => Float, {nullable: true, description: `SalePrice x CapRateAtSale -- the market net operating income implied by the price and the reported cap rate. Computed at load. Used to derive NOI/SqFt and NOI/Unit comps for the income approach (CoStar reports no direct NOI).`}) 
    ImpliedNOIAtSale?: number;
        
    @Field(() => Float, {nullable: true, description: `Building square footage with structured parking removed -- the comp-side parallel of ParcelPhysicalProfile.BuildingSqFtExParking, so comp $/SF is computed on the same basis as the subject. For a MarionPRC row on a parcel with a Parking / Pkg Garage / Com Garage improvement segment: BuildingSqFt minus that segment SqFt (NULL when the result is <= 0, i.e. a standalone garage). Otherwise equals BuildingSqFt (no parking; CoStar RBA is already rentable area). Use this, not BuildingSqFt, for $/SF comp math.`}) 
    BuildingSqFtExParking?: number;
        
    @Field({nullable: true}) 
    @MaxLength(30)
    Parcel?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
    @Field(() => [indianataxValuationComp_])
    indianataxValuationComps_SaleTransactionIDArray: indianataxValuationComp_[]; // Link to indianataxValuationComps
    
}

//****************************************************************************
// INPUT TYPE for Sale Transactions
//****************************************************************************
@InputType()
export class CreateindianataxSaleTransactionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    ParcelID: string | null;

    @Field(() => Int, { nullable: true })
    CountyNumber: number | null;

    @Field({ nullable: true })
    SitusAddress: string | null;

    @Field({ nullable: true })
    City: string | null;

    @Field({ nullable: true })
    Submarket: string | null;

    @Field({ nullable: true })
    PropertyClassCode: string | null;

    @Field({ nullable: true })
    PropertyTypeGroup: string | null;

    @Field({ nullable: true })
    SaleDate?: Date;

    @Field(() => Float, { nullable: true })
    SalePrice?: number;

    @Field({ nullable: true })
    Grantor: string | null;

    @Field({ nullable: true })
    Grantee: string | null;

    @Field({ nullable: true })
    DeedOrSaleType: string | null;

    @Field(() => Boolean, { nullable: true })
    CountyValidForTrending: boolean | null;

    @Field({ nullable: true })
    CountyValidityNote: string | null;

    @Field(() => Boolean, { nullable: true })
    IsArmsLength: boolean | null;

    @Field({ nullable: true })
    VerificationNote: string | null;

    @Field(() => Int, { nullable: true })
    BuildingSqFt: number | null;

    @Field(() => Int, { nullable: true })
    UnitCount: number | null;

    @Field(() => Float, { nullable: true })
    Acres: number | null;

    @Field(() => Int, { nullable: true })
    YearBuilt: number | null;

    @Field({ nullable: true })
    ConditionGrade: string | null;

    @Field(() => Float, { nullable: true })
    PricePerSqFt: number | null;

    @Field(() => Float, { nullable: true })
    PricePerUnit: number | null;

    @Field(() => Float, { nullable: true })
    PricePerAcre: number | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field({ nullable: true })
    TransactionKind?: string;

    @Field(() => Float, { nullable: true })
    AssessedValueAtSale: number | null;

    @Field(() => Int, { nullable: true })
    AssessedYearAtSale: number | null;

    @Field(() => Float, { nullable: true })
    SaleToAssessedRatio: number | null;

    @Field(() => Float, { nullable: true })
    CapRateAtSale: number | null;

    @Field(() => Float, { nullable: true })
    ImpliedNOIAtSale: number | null;

    @Field(() => Float, { nullable: true })
    BuildingSqFtExParking: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Sale Transactions
//****************************************************************************
@InputType()
export class UpdateindianataxSaleTransactionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Source?: string;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    ParcelID?: string | null;

    @Field(() => Int, { nullable: true })
    CountyNumber?: number | null;

    @Field({ nullable: true })
    SitusAddress?: string | null;

    @Field({ nullable: true })
    City?: string | null;

    @Field({ nullable: true })
    Submarket?: string | null;

    @Field({ nullable: true })
    PropertyClassCode?: string | null;

    @Field({ nullable: true })
    PropertyTypeGroup?: string | null;

    @Field({ nullable: true })
    SaleDate?: Date;

    @Field(() => Float, { nullable: true })
    SalePrice?: number;

    @Field({ nullable: true })
    Grantor?: string | null;

    @Field({ nullable: true })
    Grantee?: string | null;

    @Field({ nullable: true })
    DeedOrSaleType?: string | null;

    @Field(() => Boolean, { nullable: true })
    CountyValidForTrending?: boolean | null;

    @Field({ nullable: true })
    CountyValidityNote?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsArmsLength?: boolean | null;

    @Field({ nullable: true })
    VerificationNote?: string | null;

    @Field(() => Int, { nullable: true })
    BuildingSqFt?: number | null;

    @Field(() => Int, { nullable: true })
    UnitCount?: number | null;

    @Field(() => Float, { nullable: true })
    Acres?: number | null;

    @Field(() => Int, { nullable: true })
    YearBuilt?: number | null;

    @Field({ nullable: true })
    ConditionGrade?: string | null;

    @Field(() => Float, { nullable: true })
    PricePerSqFt?: number | null;

    @Field(() => Float, { nullable: true })
    PricePerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    PricePerAcre?: number | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field({ nullable: true })
    TransactionKind?: string;

    @Field(() => Float, { nullable: true })
    AssessedValueAtSale?: number | null;

    @Field(() => Int, { nullable: true })
    AssessedYearAtSale?: number | null;

    @Field(() => Float, { nullable: true })
    SaleToAssessedRatio?: number | null;

    @Field(() => Float, { nullable: true })
    CapRateAtSale?: number | null;

    @Field(() => Float, { nullable: true })
    ImpliedNOIAtSale?: number | null;

    @Field(() => Float, { nullable: true })
    BuildingSqFtExParking?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Sale Transactions
//****************************************************************************
@ObjectType()
export class RunindianataxSaleTransactionViewResult {
    @Field(() => [indianataxSaleTransaction_])
    Results: indianataxSaleTransaction_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxSaleTransaction_)
export class indianataxSaleTransactionResolver extends ResolverBase {
    @Query(() => RunindianataxSaleTransactionViewResult)
    async RunindianataxSaleTransactionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSaleTransactionViewResult)
    async RunindianataxSaleTransactionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSaleTransactionViewResult)
    async RunindianataxSaleTransactionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Sale Transactions';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxSaleTransaction_, { nullable: true })
    async indianataxSaleTransaction(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxSaleTransaction_ | null> {
        this.CheckUserReadPermissions('Sale Transactions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwSaleTransactions')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Sale Transactions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Sale Transactions', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxValuationComp_])
    async indianataxValuationComps_SaleTransactionIDArray(@Root() indianataxsaletransaction_: indianataxSaleTransaction_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Valuation Comps', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationComps')} WHERE ${provider.QuoteIdentifier('SaleTransactionID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Comps', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsaletransaction_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Valuation Comps', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxSaleTransaction_)
    async CreateindianataxSaleTransaction(
        @Arg('input', () => CreateindianataxSaleTransactionInput) input: CreateindianataxSaleTransactionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Sale Transactions', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxSaleTransaction_)
    async UpdateindianataxSaleTransaction(
        @Arg('input', () => UpdateindianataxSaleTransactionInput) input: UpdateindianataxSaleTransactionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Sale Transactions', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxSaleTransaction_)
    async DeleteindianataxSaleTransaction(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Sale Transactions', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Source Documents
//****************************************************************************
@ObjectType({ description: `The fetch/verification trail for a document pulled from DLGF, IBTR, a county source, or a reference text. One row per unique document (deduplicated on ContentHash): where it came from, when it was retrieved, the original file on disk, and its extracted, queryable text. Every fact sourced from a document should trace back to one of these rows.` })
export class indianataxSourceDocument_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF), TaxHistoryReport (a county assessor Tax History Report PDF), PTABOAFinalDeterminationApproval (a monthly batch of ratified Form 115 Notifications of Final Assessment Determination, from indy.gov's "Preliminary Agreement Approvals" list -- Marion County only), PTABOAFinalDeterminationWithdrawal (the same, from indy.gov's "Approved Withdrawls" list), or Other.`}) 
    @MaxLength(50)
    DocumentType: string;
        
    @Field({description: `Human-readable title for the document (e.g. a case caption, a statute article name, a form name).`}) 
    @MaxLength(500)
    Title: string;
        
    @Field({nullable: true, description: `The URL the document was fetched from, if it came from the web. NULL for documents entered from a local/offline source.`}) 
    @MaxLength(1000)
    SourceURL?: string;
        
    @Field({nullable: true, description: `When this document was fetched/retrieved. Distinct from any date printed on the document itself — this is about verifying when WE pulled it.`}) 
    RetrievedAt?: Date;
        
    @Field({nullable: true, description: `SHA-256 hex digest of the raw file content. Used to detect an already-fetched document before re-downloading or re-extracting it (the dedup mechanism for the ingestion pipeline).`}) 
    @MaxLength(64)
    ContentHash?: string;
        
    @Field({nullable: true, description: `Local filesystem path to the original, unmodified file (PDF, HTML, etc.) as retrieved — the audit copy kept for future re-verification.`}) 
    @MaxLength(1000)
    RawFilePath?: string;
        
    @Field({nullable: true, description: `Full extracted plain text of the document, stored inline so it can be queried/searched/embedded directly without re-reading the original file.`}) 
    ExtractedText?: string;
        
    @Field({nullable: true, description: `Free-text notes about the extraction itself — e.g. a font-encoding problem that made the text unreliable, or that OCR was used as a fallback.`}) 
    ExtractionNotes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true, description: `The date the document itself is dated/effective (a memo's issue date, a decision's date) — distinct from RetrievedAt, which is when WE fetched it. NULL where the document has no single clear date (e.g. a multi-year-cycle reference text).`}) 
    DocumentDate?: Date;
        
    @Field({nullable: true, description: `The last time this exact document was re-checked, whether or not the content had changed (RetrievedAt only updates on a real change). Updated on every scan so "checked recently, unchanged" is distinguishable from "not looked at in months."`}) 
    LastVerifiedAt?: Date;
        
    @Field(() => [indianataxStatuteSection_])
    indianataxStatuteSections_SourceDocumentIDArray: indianataxStatuteSection_[]; // Link to indianataxStatuteSections
    
    @Field(() => [indianataxBoardDecision_])
    indianataxBoardDecisions_SourceDocumentIDArray: indianataxBoardDecision_[]; // Link to indianataxBoardDecisions
    
    @Field(() => [indianataxPTABOAAppeal_])
    indianataxPTABOAAppeals_SourceDocumentIDArray: indianataxPTABOAAppeal_[]; // Link to indianataxPTABOAAppeals
    
    @Field(() => [indianataxDocumentCatalog_])
    indianataxDocumentCatalogs_SourceDocumentIDArray: indianataxDocumentCatalog_[]; // Link to indianataxDocumentCatalogs
    
    @Field(() => [indianataxAppealStage_])
    indianataxAppealStages_SourceDocumentIDArray: indianataxAppealStage_[]; // Link to indianataxAppealStages
    
    @Field(() => [indianataxResearchTask_])
    indianataxResearchTasks_RelatedSourceDocumentIDArray: indianataxResearchTask_[]; // Link to indianataxResearchTasks
    
    @Field(() => [indianataxCountyAssessorRecord_])
    indianataxCountyAssessorRecords_SourceDocumentIDArray: indianataxCountyAssessorRecord_[]; // Link to indianataxCountyAssessorRecords
    
    @Field(() => [indianataxCountyAssessorRecord_])
    indianataxCountyAssessorRecords_TaxHistorySourceDocumentIDArray: indianataxCountyAssessorRecord_[]; // Link to indianataxCountyAssessorRecords
    
    @Field(() => [indianataxDocumentAcquisition_])
    indianataxDocumentAcquisitions_SourceDocumentIDArray: indianataxDocumentAcquisition_[]; // Link to indianataxDocumentAcquisitions
    
    @Field(() => [indianataxTaxHistoryYear_])
    indianataxTaxHistoryYears_TaxHistorySourceDocumentIDArray: indianataxTaxHistoryYear_[]; // Link to indianataxTaxHistoryYears
    
    @Field(() => [indianataxPTABOAAppeal_])
    indianataxPTABOAAppeals_FinalDeterminationSourceDocumentIDArray: indianataxPTABOAAppeal_[]; // Link to indianataxPTABOAAppeals
    
    @Field(() => [indianataxFormCatalog_])
    indianataxFormCatalogs_SourceDocumentIDArray: indianataxFormCatalog_[]; // Link to indianataxFormCatalogs
    
    @Field(() => [indianataxAppealStagePlaybookNote_])
    indianataxAppealStagePlaybookNotes_SourceDocumentIDArray: indianataxAppealStagePlaybookNote_[]; // Link to indianataxAppealStagePlaybookNotes
    
    @Field(() => [indianataxJurisdictionDeadlineAnchor_])
    indianataxJurisdictionDeadlineAnchors_SourceDocumentIDArray: indianataxJurisdictionDeadlineAnchor_[]; // Link to indianataxJurisdictionDeadlineAnchors
    
    @Field(() => [indianataxSaleTransaction_])
    indianataxSaleTransactions_SourceDocumentIDArray: indianataxSaleTransaction_[]; // Link to indianataxSaleTransactions
    
    @Field(() => [indianataxAssessment_])
    indianataxAssessments_SourceDocumentIDArray: indianataxAssessment_[]; // Link to indianataxAssessments
    
    @Field(() => [indianataxCoStarIncomeInput_])
    indianataxCoStarIncomeInputs_SourceDocumentIDArray: indianataxCoStarIncomeInput_[]; // Link to indianataxCoStarIncomeInputs
    
    @Field(() => [indianataxCoStarProperty_])
    indianataxCoStarProperties_SourceDocumentIDArray: indianataxCoStarProperty_[]; // Link to indianataxCoStarProperties
    
    @Field(() => [indianataxDLGFBuildingDetail_])
    indianataxDLGFBuildingDetails_SourceDocumentIDArray: indianataxDLGFBuildingDetail_[]; // Link to indianataxDLGFBuildingDetails
    
    @Field(() => [indianataxDLGFLand_])
    indianataxDLGFLands_SourceDocumentIDArray: indianataxDLGFLand_[]; // Link to indianataxDLGFLands
    
    @Field(() => [indianataxDLGFBuilding_])
    indianataxDLGFBuildings_SourceDocumentIDArray: indianataxDLGFBuilding_[]; // Link to indianataxDLGFBuildings
    
    @Field(() => [indianataxDLGFImprovement_])
    indianataxDLGFImprovements_SourceDocumentIDArray: indianataxDLGFImprovement_[]; // Link to indianataxDLGFImprovements
    
    @Field(() => [indianataxValuationComp_])
    indianataxValuationComps_SourceDocumentIDArray: indianataxValuationComp_[]; // Link to indianataxValuationComps
    
}

//****************************************************************************
// INPUT TYPE for Source Documents
//****************************************************************************
@InputType()
export class CreateindianataxSourceDocumentInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    DocumentType?: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    SourceURL: string | null;

    @Field({ nullable: true })
    RetrievedAt: Date | null;

    @Field({ nullable: true })
    ContentHash: string | null;

    @Field({ nullable: true })
    RawFilePath: string | null;

    @Field({ nullable: true })
    ExtractedText: string | null;

    @Field({ nullable: true })
    ExtractionNotes: string | null;

    @Field({ nullable: true })
    DocumentDate: Date | null;

    @Field({ nullable: true })
    LastVerifiedAt: Date | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Source Documents
//****************************************************************************
@InputType()
export class UpdateindianataxSourceDocumentInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    DocumentType?: string;

    @Field({ nullable: true })
    Title?: string;

    @Field({ nullable: true })
    SourceURL?: string | null;

    @Field({ nullable: true })
    RetrievedAt?: Date | null;

    @Field({ nullable: true })
    ContentHash?: string | null;

    @Field({ nullable: true })
    RawFilePath?: string | null;

    @Field({ nullable: true })
    ExtractedText?: string | null;

    @Field({ nullable: true })
    ExtractionNotes?: string | null;

    @Field({ nullable: true })
    DocumentDate?: Date | null;

    @Field({ nullable: true })
    LastVerifiedAt?: Date | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Source Documents
//****************************************************************************
@ObjectType()
export class RunindianataxSourceDocumentViewResult {
    @Field(() => [indianataxSourceDocument_])
    Results: indianataxSourceDocument_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxSourceDocument_)
export class indianataxSourceDocumentResolver extends ResolverBase {
    @Query(() => RunindianataxSourceDocumentViewResult)
    async RunindianataxSourceDocumentViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSourceDocumentViewResult)
    async RunindianataxSourceDocumentViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSourceDocumentViewResult)
    async RunindianataxSourceDocumentDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Source Documents';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxSourceDocument_, { nullable: true })
    async indianataxSourceDocument(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxSourceDocument_ | null> {
        this.CheckUserReadPermissions('Source Documents', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwSourceDocuments')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Source Documents', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Source Documents', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxStatuteSection_])
    async indianataxStatuteSections_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Statute Sections', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwStatuteSections')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Statute Sections', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Statute Sections', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxBoardDecision_])
    async indianataxBoardDecisions_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Board Decisions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwBoardDecisions')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Board Decisions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Board Decisions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxPTABOAAppeal_])
    async indianataxPTABOAAppeals_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('PTABOA Appeals', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwPTABOAAppeals')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'PTABOA Appeals', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('PTABOA Appeals', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDocumentCatalog_])
    async indianataxDocumentCatalogs_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Document Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentCatalogs')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Document Catalogs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAppealStage_])
    async indianataxAppealStages_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stages', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStages')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stages', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stages', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxResearchTask_])
    async indianataxResearchTasks_RelatedSourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Research Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwResearchTasks')} WHERE ${provider.QuoteIdentifier('RelatedSourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Research Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Research Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorRecord_])
    async indianataxCountyAssessorRecords_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Records', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorRecords')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Records', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Records', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorRecord_])
    async indianataxCountyAssessorRecords_TaxHistorySourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Records', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorRecords')} WHERE ${provider.QuoteIdentifier('TaxHistorySourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Records', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Records', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDocumentAcquisition_])
    async indianataxDocumentAcquisitions_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Document Acquisitions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentAcquisitions')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Acquisitions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Document Acquisitions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxTaxHistoryYear_])
    async indianataxTaxHistoryYears_TaxHistorySourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Tax History Years', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwTaxHistoryYears')} WHERE ${provider.QuoteIdentifier('TaxHistorySourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Tax History Years', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Tax History Years', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxPTABOAAppeal_])
    async indianataxPTABOAAppeals_FinalDeterminationSourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('PTABOA Appeals', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwPTABOAAppeals')} WHERE ${provider.QuoteIdentifier('FinalDeterminationSourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'PTABOA Appeals', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('PTABOA Appeals', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxFormCatalog_])
    async indianataxFormCatalogs_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Form Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwFormCatalogs')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Form Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Form Catalogs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAppealStagePlaybookNote_])
    async indianataxAppealStagePlaybookNotes_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stage Playbook Notes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStagePlaybookNotes')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Playbook Notes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stage Playbook Notes', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxJurisdictionDeadlineAnchor_])
    async indianataxJurisdictionDeadlineAnchors_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Jurisdiction Deadline Anchors', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwJurisdictionDeadlineAnchors')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Jurisdiction Deadline Anchors', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Jurisdiction Deadline Anchors', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxSaleTransaction_])
    async indianataxSaleTransactions_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Sale Transactions', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwSaleTransactions')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Sale Transactions', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Sale Transactions', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAssessment_])
    async indianataxAssessments_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Assessments', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAssessments')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Assessments', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Assessments', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCoStarIncomeInput_])
    async indianataxCoStarIncomeInputs_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Co Star Income Inputs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarIncomeInputs')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Income Inputs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Co Star Income Inputs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCoStarProperty_])
    async indianataxCoStarProperties_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Co Star Properties', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCoStarProperties')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Co Star Properties', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Co Star Properties', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFBuildingDetail_])
    async indianataxDLGFBuildingDetails_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Building Details', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildingDetails')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Building Details', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Building Details', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFLand_])
    async indianataxDLGFLands_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Lands', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFLands')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Lands', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Lands', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFBuilding_])
    async indianataxDLGFBuildings_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Buildings', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFBuildings')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Buildings', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Buildings', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxDLGFImprovement_])
    async indianataxDLGFImprovements_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('DLGF Improvements', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDLGFImprovements')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'DLGF Improvements', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('DLGF Improvements', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxValuationComp_])
    async indianataxValuationComps_SourceDocumentIDArray(@Root() indianataxsourcedocument_: indianataxSourceDocument_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Valuation Comps', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationComps')} WHERE ${provider.QuoteIdentifier('SourceDocumentID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Comps', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourcedocument_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Valuation Comps', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxSourceDocument_)
    async CreateindianataxSourceDocument(
        @Arg('input', () => CreateindianataxSourceDocumentInput) input: CreateindianataxSourceDocumentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Source Documents', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxSourceDocument_)
    async UpdateindianataxSourceDocument(
        @Arg('input', () => UpdateindianataxSourceDocumentInput) input: UpdateindianataxSourceDocumentInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Source Documents', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxSourceDocument_)
    async DeleteindianataxSourceDocument(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Source Documents', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Source Registries
//****************************************************************************
@ObjectType({ description: `A source we monitor for property-tax documents — a DLGF page, the IBTR site, a statewide dataset, a county FOIA feed. This is the "what exists and are we watching it" inventory; individual documents found by scanning a source are DocumentCatalog rows.` })
export class indianataxSourceRegistry_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Human-readable name for the source (unique), e.g. "DLGF Memos — 2026" or "IBTR Board Decisions".`}) 
    @MaxLength(200)
    Name: string;
        
    @Field({description: `What kind of source this is — drives which ingestion code path applies (a statewide geodatabase pull, a website to crawl, a local file set, etc.).`}) 
    @MaxLength(30)
    SourceType: string;
        
    @Field({nullable: true, description: `The base page/URL this registry entry monitors, if web-based. NULL for non-web sources (e.g. a locally-sourced dataset).`}) 
    @MaxLength(1000)
    RootURL?: string;
        
    @Field(() => Boolean, {description: `Whether this source itself is in scope for real property taxation. A source can be evaluated and marked 0 (e.g. DLGF Gateway — local government budget/TIF/debt data) so the decision to exclude it is recorded, not just absent.`}) 
    IsPropertyTaxRelevant: boolean;
        
    @Field({nullable: true, description: `How often this source should be re-scanned for new/updated documents: Monthly, Quarterly, Annual, OneTime (already fully captured, e.g. a fixed historical dataset), or AdHoc (rescanned manually as needed).`}) 
    @MaxLength(20)
    ScanFrequency?: string;
        
    @Field({nullable: true, description: `The last time this source was actually scanned for updates, regardless of whether anything new was found. This is the "last date researched" for the source as a whole.`}) 
    LastScannedAt?: Date;
        
    @Field({nullable: true, description: `When this source is next due for a scan, computed from LastScannedAt + ScanFrequency. Drives a "what needs attention" view without recomputing on every query.`}) 
    NextScanDueAt?: Date;
        
    @Field({nullable: true, description: `Free-text outcome of the most recent scan — e.g. "3 new memos found", "no changes", or an error if the source was unreachable.`}) 
    LastScanNotes?: string;
        
    @Field({nullable: true, description: `General notes about this source — why it is or isn't in scope, quirks of its structure, etc.`}) 
    Notes?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [indianataxDocumentCatalog_])
    indianataxDocumentCatalogs_SourceRegistryIDArray: indianataxDocumentCatalog_[]; // Link to indianataxDocumentCatalogs
    
    @Field(() => [indianataxCountyResource_])
    indianataxCountyResources_SourceRegistryIDArray: indianataxCountyResource_[]; // Link to indianataxCountyResources
    
    @Field(() => [indianataxParcel_])
    indianataxParcels_GeometrySourceRegistryIDArray: indianataxParcel_[]; // Link to indianataxParcels
    
    @Field(() => [indianataxResearchTask_])
    indianataxResearchTasks_RelatedSourceRegistryIDArray: indianataxResearchTask_[]; // Link to indianataxResearchTasks
    
    @Field(() => [indianataxCountyAssessorRecord_])
    indianataxCountyAssessorRecords_SourceRegistryIDArray: indianataxCountyAssessorRecord_[]; // Link to indianataxCountyAssessorRecords
    
}

//****************************************************************************
// INPUT TYPE for Source Registries
//****************************************************************************
@InputType()
export class CreateindianataxSourceRegistryInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    SourceType?: string;

    @Field({ nullable: true })
    RootURL: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPropertyTaxRelevant?: boolean;

    @Field({ nullable: true })
    ScanFrequency: string | null;

    @Field({ nullable: true })
    LastScannedAt: Date | null;

    @Field({ nullable: true })
    NextScanDueAt: Date | null;

    @Field({ nullable: true })
    LastScanNotes: string | null;

    @Field({ nullable: true })
    Notes: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Source Registries
//****************************************************************************
@InputType()
export class UpdateindianataxSourceRegistryInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Name?: string;

    @Field({ nullable: true })
    SourceType?: string;

    @Field({ nullable: true })
    RootURL?: string | null;

    @Field(() => Boolean, { nullable: true })
    IsPropertyTaxRelevant?: boolean;

    @Field({ nullable: true })
    ScanFrequency?: string | null;

    @Field({ nullable: true })
    LastScannedAt?: Date | null;

    @Field({ nullable: true })
    NextScanDueAt?: Date | null;

    @Field({ nullable: true })
    LastScanNotes?: string | null;

    @Field({ nullable: true })
    Notes?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Source Registries
//****************************************************************************
@ObjectType()
export class RunindianataxSourceRegistryViewResult {
    @Field(() => [indianataxSourceRegistry_])
    Results: indianataxSourceRegistry_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxSourceRegistry_)
export class indianataxSourceRegistryResolver extends ResolverBase {
    @Query(() => RunindianataxSourceRegistryViewResult)
    async RunindianataxSourceRegistryViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSourceRegistryViewResult)
    async RunindianataxSourceRegistryViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxSourceRegistryViewResult)
    async RunindianataxSourceRegistryDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Source Registries';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxSourceRegistry_, { nullable: true })
    async indianataxSourceRegistry(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxSourceRegistry_ | null> {
        this.CheckUserReadPermissions('Source Registries', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwSourceRegistries')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Source Registries', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Source Registries', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxDocumentCatalog_])
    async indianataxDocumentCatalogs_SourceRegistryIDArray(@Root() indianataxsourceregistry_: indianataxSourceRegistry_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Document Catalogs', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwDocumentCatalogs')} WHERE ${provider.QuoteIdentifier('SourceRegistryID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Document Catalogs', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourceregistry_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Document Catalogs', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyResource_])
    async indianataxCountyResources_SourceRegistryIDArray(@Root() indianataxsourceregistry_: indianataxSourceRegistry_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Resources', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyResources')} WHERE ${provider.QuoteIdentifier('SourceRegistryID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Resources', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourceregistry_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Resources', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxParcel_])
    async indianataxParcels_GeometrySourceRegistryIDArray(@Root() indianataxsourceregistry_: indianataxSourceRegistry_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Parcels', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwParcels')} WHERE ${provider.QuoteIdentifier('GeometrySourceRegistryID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Parcels', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourceregistry_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Parcels', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxResearchTask_])
    async indianataxResearchTasks_RelatedSourceRegistryIDArray(@Root() indianataxsourceregistry_: indianataxSourceRegistry_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Research Tasks', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwResearchTasks')} WHERE ${provider.QuoteIdentifier('RelatedSourceRegistryID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Research Tasks', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourceregistry_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Research Tasks', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxCountyAssessorRecord_])
    async indianataxCountyAssessorRecords_SourceRegistryIDArray(@Root() indianataxsourceregistry_: indianataxSourceRegistry_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('County Assessor Records', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwCountyAssessorRecords')} WHERE ${provider.QuoteIdentifier('SourceRegistryID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'County Assessor Records', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxsourceregistry_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('County Assessor Records', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxSourceRegistry_)
    async CreateindianataxSourceRegistry(
        @Arg('input', () => CreateindianataxSourceRegistryInput) input: CreateindianataxSourceRegistryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Source Registries', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxSourceRegistry_)
    async UpdateindianataxSourceRegistry(
        @Arg('input', () => UpdateindianataxSourceRegistryInput) input: UpdateindianataxSourceRegistryInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Source Registries', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxSourceRegistry_)
    async DeleteindianataxSourceRegistry(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Source Registries', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Statute Sections
//****************************************************************************
@ObjectType({ description: `One row per section of Indiana Code Title 6, Article 1.1 (property tax) or 1.5 (indiana board of tax review), chunked by section number so a citation resolves to exact text instead of a whole-article document.` })
export class indianataxStatuteSection_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `Indiana Code article number (e.g. 1.1, 1.5).`}) 
    @MaxLength(20)
    Article: string;
        
    @Field({description: `Full section citation (e.g. 6-1.1-15-1).`}) 
    @MaxLength(20)
    SectionNumber: string;
        
    @Field({nullable: true, description: `Section heading/title, if the source text has one.`}) 
    @MaxLength(500)
    Title?: string;
        
    @Field({nullable: true, description: `Full text of this section, for direct citation and RAG retrieval.`}) 
    SectionText?: string;
        
    @Field({nullable: true, description: `The full-article document (e.g. Article_1.1.pdf) this section was parsed out of.`}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => [indianataxAppealStageStatute_])
    indianataxAppealStageStatutes_StatuteSectionIDArray: indianataxAppealStageStatute_[]; // Link to indianataxAppealStageStatutes
    
    @Field(() => [indianataxAppealStagePlaybookNote_])
    indianataxAppealStagePlaybookNotes_StatuteSectionIDArray: indianataxAppealStagePlaybookNote_[]; // Link to indianataxAppealStagePlaybookNotes
    
}

//****************************************************************************
// INPUT TYPE for Statute Sections
//****************************************************************************
@InputType()
export class CreateindianataxStatuteSectionInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    Article?: string;

    @Field({ nullable: true })
    SectionNumber?: string;

    @Field({ nullable: true })
    Title: string | null;

    @Field({ nullable: true })
    SectionText: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Statute Sections
//****************************************************************************
@InputType()
export class UpdateindianataxStatuteSectionInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    Article?: string;

    @Field({ nullable: true })
    SectionNumber?: string;

    @Field({ nullable: true })
    Title?: string | null;

    @Field({ nullable: true })
    SectionText?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Statute Sections
//****************************************************************************
@ObjectType()
export class RunindianataxStatuteSectionViewResult {
    @Field(() => [indianataxStatuteSection_])
    Results: indianataxStatuteSection_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxStatuteSection_)
export class indianataxStatuteSectionResolver extends ResolverBase {
    @Query(() => RunindianataxStatuteSectionViewResult)
    async RunindianataxStatuteSectionViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxStatuteSectionViewResult)
    async RunindianataxStatuteSectionViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxStatuteSectionViewResult)
    async RunindianataxStatuteSectionDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Statute Sections';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxStatuteSection_, { nullable: true })
    async indianataxStatuteSection(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxStatuteSection_ | null> {
        this.CheckUserReadPermissions('Statute Sections', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwStatuteSections')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Statute Sections', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Statute Sections', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxAppealStageStatute_])
    async indianataxAppealStageStatutes_StatuteSectionIDArray(@Root() indianataxstatutesection_: indianataxStatuteSection_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stage Statutes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStageStatutes')} WHERE ${provider.QuoteIdentifier('StatuteSectionID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Statutes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxstatutesection_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stage Statutes', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @FieldResolver(() => [indianataxAppealStagePlaybookNote_])
    async indianataxAppealStagePlaybookNotes_StatuteSectionIDArray(@Root() indianataxstatutesection_: indianataxStatuteSection_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Appeal Stage Playbook Notes', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwAppealStagePlaybookNotes')} WHERE ${provider.QuoteIdentifier('StatuteSectionID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Appeal Stage Playbook Notes', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxstatutesection_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Appeal Stage Playbook Notes', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxStatuteSection_)
    async CreateindianataxStatuteSection(
        @Arg('input', () => CreateindianataxStatuteSectionInput) input: CreateindianataxStatuteSectionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Statute Sections', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxStatuteSection_)
    async UpdateindianataxStatuteSection(
        @Arg('input', () => UpdateindianataxStatuteSectionInput) input: UpdateindianataxStatuteSectionInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Statute Sections', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxStatuteSection_)
    async DeleteindianataxStatuteSection(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Statute Sections', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Tax History Years
//****************************************************************************
@ObjectType({ description: `One row per (parcel, document-position) entry from a Tax History Report\'s multi-year assessment/tax-liability history -- both the current-year snapshot (ColumnOrdinal=0) and every historical column found in the "PRIOR TAX PAYMENT INFORMATION" table (ColumnOrdinal>=1, oldest columns have the highest ordinal). Stores every year the document has, not limited to any fixed lookback window -- "10 years" is a query-time convention for consumers, not a storage cutoff. GrossTax is deliberately NOT stored here -- confirmed across every document checked to exactly duplicate TaxRate under a different label, not a real dollar figure.` })
export class indianataxTaxHistoryYear_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel this historical tax-year row belongs to.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field({description: `The SourceDocument row for the Tax History Report PDF this row was parsed from.`}) 
    @MaxLength(36)
    TaxHistorySourceDocumentID: string;
        
    @Field(() => Int, {description: `The tax year (payable year) this row reports on, per the document's own "Tax Year:" header for this column. NOT unique per parcel by itself -- see ColumnOrdinal.`}) 
    TaxYear: number;
        
    @Field(() => Int, {description: `This row's position within the document: 0 = the current-year snapshot from the report's first-page section, 1 = the most recent column of the "PRIOR TAX PAYMENT INFORMATION" table, increasing with age. NOT derivable from TaxYear alone -- the year 2007 genuinely appears twice (Marion County's real 2007 statewide-reassessment-cycle transition, confirmed across every document checked) at two different ordinals; this is the real uniqueness key together with TaxYear, not a synthetic workaround.`}) 
    ColumnOrdinal: number;
        
    @Field(() => Float, {nullable: true, description: `The "Land Assessment" figure for this tax year.`}) 
    LandAssessment?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Improvements" assessment figure for this tax year.`}) 
    Improvements?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Gross Assessment" figure for this tax year (Land + Improvements, before deductions/exemptions).`}) 
    GrossAssessment?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Deductions/Exemptions" total applied for this tax year.`}) 
    DeductionsExemptionsTotal?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Net Assessment" figure for this tax year (Gross Assessment less Deductions/Exemptions).`}) 
    NetAssessment?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Tax Rate" for this tax year, per $100 of assessed value.`}) 
    TaxRate?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Replacement Credit" applied for this tax year.`}) 
    ReplacementCredit?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Homestead Credit" applied for this tax year -- a single combined figure in the historical table (unlike the current-year section, which splits state/local homestead credit into separate fields).`}) 
    HomesteadCredit?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Net Annual Tax" liability for this tax year -- the reliable tax-liability figure for this row (see the table-level note on why GrossTax is not stored).`}) 
    NetAnnualTax?: number;
        
    @Field(() => Float, {nullable: true, description: `The "Half Year Tax" figure for this tax year (Net Annual Tax split across the two semi-annual installments).`}) 
    HalfYearTax?: number;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
}

//****************************************************************************
// INPUT TYPE for Tax History Years
//****************************************************************************
@InputType()
export class CreateindianataxTaxHistoryYearInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    TaxHistorySourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    TaxYear?: number;

    @Field(() => Int, { nullable: true })
    ColumnOrdinal?: number;

    @Field(() => Float, { nullable: true })
    LandAssessment: number | null;

    @Field(() => Float, { nullable: true })
    Improvements: number | null;

    @Field(() => Float, { nullable: true })
    GrossAssessment: number | null;

    @Field(() => Float, { nullable: true })
    DeductionsExemptionsTotal: number | null;

    @Field(() => Float, { nullable: true })
    NetAssessment: number | null;

    @Field(() => Float, { nullable: true })
    TaxRate: number | null;

    @Field(() => Float, { nullable: true })
    ReplacementCredit: number | null;

    @Field(() => Float, { nullable: true })
    HomesteadCredit: number | null;

    @Field(() => Float, { nullable: true })
    NetAnnualTax: number | null;

    @Field(() => Float, { nullable: true })
    HalfYearTax: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Tax History Years
//****************************************************************************
@InputType()
export class UpdateindianataxTaxHistoryYearInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field({ nullable: true })
    TaxHistorySourceDocumentID?: string;

    @Field(() => Int, { nullable: true })
    TaxYear?: number;

    @Field(() => Int, { nullable: true })
    ColumnOrdinal?: number;

    @Field(() => Float, { nullable: true })
    LandAssessment?: number | null;

    @Field(() => Float, { nullable: true })
    Improvements?: number | null;

    @Field(() => Float, { nullable: true })
    GrossAssessment?: number | null;

    @Field(() => Float, { nullable: true })
    DeductionsExemptionsTotal?: number | null;

    @Field(() => Float, { nullable: true })
    NetAssessment?: number | null;

    @Field(() => Float, { nullable: true })
    TaxRate?: number | null;

    @Field(() => Float, { nullable: true })
    ReplacementCredit?: number | null;

    @Field(() => Float, { nullable: true })
    HomesteadCredit?: number | null;

    @Field(() => Float, { nullable: true })
    NetAnnualTax?: number | null;

    @Field(() => Float, { nullable: true })
    HalfYearTax?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Tax History Years
//****************************************************************************
@ObjectType()
export class RunindianataxTaxHistoryYearViewResult {
    @Field(() => [indianataxTaxHistoryYear_])
    Results: indianataxTaxHistoryYear_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxTaxHistoryYear_)
export class indianataxTaxHistoryYearResolver extends ResolverBase {
    @Query(() => RunindianataxTaxHistoryYearViewResult)
    async RunindianataxTaxHistoryYearViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxTaxHistoryYearViewResult)
    async RunindianataxTaxHistoryYearViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxTaxHistoryYearViewResult)
    async RunindianataxTaxHistoryYearDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Tax History Years';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxTaxHistoryYear_, { nullable: true })
    async indianataxTaxHistoryYear(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxTaxHistoryYear_ | null> {
        this.CheckUserReadPermissions('Tax History Years', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwTaxHistoryYears')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Tax History Years', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Tax History Years', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxTaxHistoryYear_)
    async CreateindianataxTaxHistoryYear(
        @Arg('input', () => CreateindianataxTaxHistoryYearInput) input: CreateindianataxTaxHistoryYearInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Tax History Years', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxTaxHistoryYear_)
    async UpdateindianataxTaxHistoryYear(
        @Arg('input', () => UpdateindianataxTaxHistoryYearInput) input: UpdateindianataxTaxHistoryYearInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Tax History Years', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxTaxHistoryYear_)
    async DeleteindianataxTaxHistoryYear(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Tax History Years', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Valuation Analysis
//****************************************************************************
@ObjectType({ description: `The per-parcel, per-year valuation workup: an indicated value under each approach, a reconciled Target Value, and a "should this be appealed?" recommendation with an estimated tax saving. Appeal-screening output, NOT a USPAP appraisal. Design: Indiana_Tax_Expert/docs/proposals/valuation-target-value.md.` })
export class indianataxValuationAnalysis_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field({description: `The parcel analysed.`}) 
    @MaxLength(36)
    ParcelID: string;
        
    @Field(() => Int, {description: `The assessment year the analysis is for.`}) 
    AssessmentYear: number;
        
    @Field({description: `Version tag for the methodology that produced this row (e.g. "sales-p25-2026-08-30"). Lets a re-run replace its own rows without touching an earlier method's.`}) 
    @MaxLength(30)
    MethodologyVersion: string;
        
    @Field({nullable: true, description: `Rolled-up property category used for comp grouping.`}) 
    @MaxLength(30)
    PropertyTypeGroup?: string;
        
    @Field(() => Float, {nullable: true, description: `The county's current total assessed value the target is measured against.`}) 
    CurrentTotalAV?: number;
        
    @Field(() => Float, {nullable: true, description: `Value indicated by the sales comparison approach.`}) 
    SalesIndicatedValue?: number;
        
    @Field({nullable: true, description: `How the sales indication was derived (comp pool, unit metric, the point statistic used).`}) 
    @MaxLength(400)
    SalesMethodNote?: string;
        
    @Field(() => Float, {nullable: true, description: `Value indicated by the income capitalization approach (not yet populated).`}) 
    IncomeIndicatedValue?: number;
        
    @Field({nullable: true, description: `How the income indication was derived.`}) 
    @MaxLength(400)
    IncomeMethodNote?: string;
        
    @Field(() => Float, {nullable: true, description: `The county's own mass-appraisal cost figure, surfaced as a proxy / sanity anchor ONLY -- the DLGF cost tables cannot be relied on by either party in a subjective valuation argument. Not yet populated.`}) 
    CostProxyValue?: number;
        
    @Field({nullable: true, description: `Note on the cost proxy, including the caveat above.`}) 
    @MaxLength(400)
    CostProxyNote?: string;
        
    @Field(() => Float, {nullable: true, description: `The reconciled opinion of value -- the number an appeal would argue for.`}) 
    ReconciledTargetValue?: number;
        
    @Field(() => Float, {nullable: true, description: `ReconciledTargetValue / unit count.`}) 
    TargetValuePerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `ReconciledTargetValue / building sq ft.`}) 
    TargetValuePerSqFt?: number;
        
    @Field({nullable: true, description: `Which approach controlled the reconciliation: Sales / Income / CostProxy / Blended / None.`}) 
    @MaxLength(16)
    ControllingApproach?: string;
        
    @Field({nullable: true, description: `Narrative: why these approaches, why this weighting, why this point in the range.`}) 
    ReconciliationRationale?: string;
        
    @Field(() => Float, {nullable: true, description: `(CurrentTotalAV - ReconciledTargetValue) / CurrentTotalAV -- how far below the assessment the target sits.`}) 
    MaterialityPct?: number;
        
    @Field(() => Float, {description: `The reduction fraction below which an appeal is not worth pursuing (default 5%).`}) 
    MaterialityThreshold: number;
        
    @Field(() => Float, {nullable: true, description: `The tax rate applied to convert an AV reduction into a dollar saving (from CountyAssessorRecord.TaxRate as a percent, or a default). `}) 
    AppliedTaxRate?: number;
        
    @Field(() => Float, {nullable: true, description: `(CurrentTotalAV - ReconciledTargetValue) x AppliedTaxRate -- the estimated annual tax saving if the target is achieved.`}) 
    EstimatedTaxSavings?: number;
        
    @Field({nullable: true, description: `Appeal / No Appeal / Monitor. "Monitor" = a signal exists but the comp support is thin or the indication is implausibly far from the AV (needs a human look).`}) 
    @MaxLength(12)
    Recommendation?: string;
        
    @Field({nullable: true, description: `High / Medium / Low. High requires a solid comp cluster, a PRC-sourced size, and an indication within a sane band of the AV.`}) 
    @MaxLength(8)
    ConfidenceTier?: string;
        
    @Field(() => Int, {nullable: true, description: `Number of comparable sales behind the sales indication.`}) 
    CompCount?: number;
        
    @Field({nullable: true, description: `Free-text analyst / agent notes.`}) 
    AnalystNote?: string;
        
    @Field({nullable: true, description: `When this analysis row was generated.`}) 
    GeneratedAt?: Date;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field(() => Float, {nullable: true, description: `The aggressive floor -- MIN of the approach indications (Sales / Income / CostProxy) that fall within the sanity band [0.5, 1.2] x current AV. The lowest credible opinion of value.`}) 
    LowestSupportedValue?: number;
        
    @Field(() => Int, {nullable: true, description: `How many approaches independently indicate a value below the current AV (and in band). >= 2 means redundant support for a reduction -- the recommended ask is then pitched at the higher of the low values.`}) 
    SupportingApproachCount?: number;
        
    @Field(() => Float, {nullable: true, description: `Estimated annual tax saving if LowestSupportedValue is achieved. EstimatedTaxSavings is the saving at the recommended ask (ReconciledTargetValue); this is the saving at the floor.`}) 
    MaxEstimatedTaxSavings?: number;
        
    @Field() 
    @MaxLength(30)
    Parcel: string;
        
    @Field(() => [indianataxValuationComp_])
    indianataxValuationComps_ValuationAnalysisIDArray: indianataxValuationComp_[]; // Link to indianataxValuationComps
    
}

//****************************************************************************
// INPUT TYPE for Valuation Analysis
//****************************************************************************
@InputType()
export class CreateindianataxValuationAnalysisInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    PropertyTypeGroup: string | null;

    @Field(() => Float, { nullable: true })
    CurrentTotalAV: number | null;

    @Field(() => Float, { nullable: true })
    SalesIndicatedValue: number | null;

    @Field({ nullable: true })
    SalesMethodNote: string | null;

    @Field(() => Float, { nullable: true })
    IncomeIndicatedValue: number | null;

    @Field({ nullable: true })
    IncomeMethodNote: string | null;

    @Field(() => Float, { nullable: true })
    CostProxyValue: number | null;

    @Field({ nullable: true })
    CostProxyNote: string | null;

    @Field(() => Float, { nullable: true })
    ReconciledTargetValue: number | null;

    @Field(() => Float, { nullable: true })
    TargetValuePerUnit: number | null;

    @Field(() => Float, { nullable: true })
    TargetValuePerSqFt: number | null;

    @Field({ nullable: true })
    ControllingApproach: string | null;

    @Field({ nullable: true })
    ReconciliationRationale: string | null;

    @Field(() => Float, { nullable: true })
    MaterialityPct: number | null;

    @Field(() => Float, { nullable: true })
    MaterialityThreshold?: number;

    @Field(() => Float, { nullable: true })
    AppliedTaxRate: number | null;

    @Field(() => Float, { nullable: true })
    EstimatedTaxSavings: number | null;

    @Field({ nullable: true })
    Recommendation: string | null;

    @Field({ nullable: true })
    ConfidenceTier: string | null;

    @Field(() => Int, { nullable: true })
    CompCount: number | null;

    @Field({ nullable: true })
    AnalystNote: string | null;

    @Field({ nullable: true })
    GeneratedAt: Date | null;

    @Field(() => Float, { nullable: true })
    LowestSupportedValue: number | null;

    @Field(() => Int, { nullable: true })
    SupportingApproachCount: number | null;

    @Field(() => Float, { nullable: true })
    MaxEstimatedTaxSavings: number | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Valuation Analysis
//****************************************************************************
@InputType()
export class UpdateindianataxValuationAnalysisInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ParcelID?: string;

    @Field(() => Int, { nullable: true })
    AssessmentYear?: number;

    @Field({ nullable: true })
    MethodologyVersion?: string;

    @Field({ nullable: true })
    PropertyTypeGroup?: string | null;

    @Field(() => Float, { nullable: true })
    CurrentTotalAV?: number | null;

    @Field(() => Float, { nullable: true })
    SalesIndicatedValue?: number | null;

    @Field({ nullable: true })
    SalesMethodNote?: string | null;

    @Field(() => Float, { nullable: true })
    IncomeIndicatedValue?: number | null;

    @Field({ nullable: true })
    IncomeMethodNote?: string | null;

    @Field(() => Float, { nullable: true })
    CostProxyValue?: number | null;

    @Field({ nullable: true })
    CostProxyNote?: string | null;

    @Field(() => Float, { nullable: true })
    ReconciledTargetValue?: number | null;

    @Field(() => Float, { nullable: true })
    TargetValuePerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    TargetValuePerSqFt?: number | null;

    @Field({ nullable: true })
    ControllingApproach?: string | null;

    @Field({ nullable: true })
    ReconciliationRationale?: string | null;

    @Field(() => Float, { nullable: true })
    MaterialityPct?: number | null;

    @Field(() => Float, { nullable: true })
    MaterialityThreshold?: number;

    @Field(() => Float, { nullable: true })
    AppliedTaxRate?: number | null;

    @Field(() => Float, { nullable: true })
    EstimatedTaxSavings?: number | null;

    @Field({ nullable: true })
    Recommendation?: string | null;

    @Field({ nullable: true })
    ConfidenceTier?: string | null;

    @Field(() => Int, { nullable: true })
    CompCount?: number | null;

    @Field({ nullable: true })
    AnalystNote?: string | null;

    @Field({ nullable: true })
    GeneratedAt?: Date | null;

    @Field(() => Float, { nullable: true })
    LowestSupportedValue?: number | null;

    @Field(() => Int, { nullable: true })
    SupportingApproachCount?: number | null;

    @Field(() => Float, { nullable: true })
    MaxEstimatedTaxSavings?: number | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Valuation Analysis
//****************************************************************************
@ObjectType()
export class RunindianataxValuationAnalysisViewResult {
    @Field(() => [indianataxValuationAnalysis_])
    Results: indianataxValuationAnalysis_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxValuationAnalysis_)
export class indianataxValuationAnalysisResolver extends ResolverBase {
    @Query(() => RunindianataxValuationAnalysisViewResult)
    async RunindianataxValuationAnalysisViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxValuationAnalysisViewResult)
    async RunindianataxValuationAnalysisViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxValuationAnalysisViewResult)
    async RunindianataxValuationAnalysisDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Valuation Analysis';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxValuationAnalysis_, { nullable: true })
    async indianataxValuationAnalysis(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxValuationAnalysis_ | null> {
        this.CheckUserReadPermissions('Valuation Analysis', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationAnalysis')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Analysis', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Valuation Analysis', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @FieldResolver(() => [indianataxValuationComp_])
    async indianataxValuationComps_ValuationAnalysisIDArray(@Root() indianataxvaluationanalysis_: indianataxValuationAnalysis_, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine) {
        this.CheckUserReadPermissions('Valuation Comps', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationComps')} WHERE ${provider.QuoteIdentifier('ValuationAnalysisID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Comps', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [indianataxvaluationanalysis_.ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.ArrayMapFieldNamesToCodeNames('Valuation Comps', rows, this.GetUserFromPayload(userPayload));
        return result;
    }
        
    @Mutation(() => indianataxValuationAnalysis_)
    async CreateindianataxValuationAnalysis(
        @Arg('input', () => CreateindianataxValuationAnalysisInput) input: CreateindianataxValuationAnalysisInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Valuation Analysis', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxValuationAnalysis_)
    async UpdateindianataxValuationAnalysis(
        @Arg('input', () => UpdateindianataxValuationAnalysisInput) input: UpdateindianataxValuationAnalysisInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Valuation Analysis', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxValuationAnalysis_)
    async DeleteindianataxValuationAnalysis(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Valuation Analysis', key, options, provider, userPayload, pubSub);
    }
    
}

//****************************************************************************
// ENTITY CLASS for Valuation Comps
//****************************************************************************
@ObjectType({ description: `One row per sales comparable considered for a ValuationAnalysis subject (OPP-17 Stage 6). Each comp is adjusted to the subject on size (economies of scale), effective age, grade, and time-to-lien-date; caps net +/-25% / gross 50% (beyond -> DropReason). The median SubjectIndicatedValue over the selected cluster is the subject market-value (sales) indication; a P25-group fallback is used where < 3 comps survive. Built by scripts/build-valuation-comps.js.` })
export class indianataxValuationComp_ {
    @Field() 
    @MaxLength(36)
    ID: string;
        
    @Field() 
    @MaxLength(36)
    ValuationAnalysisID: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    SaleTransactionID?: string;
        
    @Field({nullable: true}) 
    @MaxLength(36)
    SourceDocumentID?: string;
        
    @Field() 
    @MaxLength(10)
    UnitOfComparison: string;
        
    @Field({nullable: true}) 
    @MaxLength(300)
    CompAddress?: string;
        
    @Field({nullable: true}) 
    @MaxLength(80)
    CompSubmarket?: string;
        
    @Field({nullable: true}) 
    SaleDate?: Date;
        
    @Field(() => Float, {nullable: true}) 
    SalePrice?: number;
        
    @Field(() => Float, {nullable: true}) 
    CompDenominator?: number;
        
    @Field(() => Int, {nullable: true}) 
    CompYearBuilt?: number;
        
    @Field(() => Float, {nullable: true}) 
    CompGradeOrdinal?: number;
        
    @Field(() => Float, {nullable: true}) 
    RawPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `Signed size adjustment (economies of scale): +0.10 x ln(compDenominator / subjectDenominator), clamped +/-15%. Positive raises the comp $/unit toward a smaller subject.`}) 
    SizeAdjPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    AgeAdjPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    GradeAdjPct?: number;
        
    @Field(() => Float, {nullable: true, description: `Signed time adjustment: annual CRE appreciation (3%) x years from sale date to the 1/1/2026 lien date, clamped [-5%, +30%].`}) 
    TimeAdjPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    NetAdjPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    GrossAdjPct?: number;
        
    @Field(() => Float, {nullable: true}) 
    AdjustedPerUnit?: number;
        
    @Field(() => Float, {nullable: true, description: `AdjustedPerUnit x the subject's denominator (SF or units) -- this comp's indication of the subject's total value.`}) 
    SubjectIndicatedValue?: number;
        
    @Field(() => Int, {nullable: true}) 
    SimilarityRank?: number;
        
    @Field(() => Boolean) 
    IsSelected: boolean;
        
    @Field({nullable: true}) 
    @MaxLength(40)
    DropReason?: string;
        
    @Field() 
    _mj__CreatedAt: Date;
        
    @Field() 
    _mj__UpdatedAt: Date;
        
    @Field({nullable: true}) 
    @MaxLength(200)
    SaleTransaction?: string;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Latitude?: number;
        
    @Field(() => Float, {nullable: true}) 
    _mj__Longitude?: number;
        
}

//****************************************************************************
// INPUT TYPE for Valuation Comps
//****************************************************************************
@InputType()
export class CreateindianataxValuationCompInput {
    @Field({ nullable: true })
    ID?: string;

    @Field({ nullable: true })
    ValuationAnalysisID?: string;

    @Field({ nullable: true })
    SaleTransactionID: string | null;

    @Field({ nullable: true })
    SourceDocumentID: string | null;

    @Field({ nullable: true })
    UnitOfComparison?: string;

    @Field({ nullable: true })
    CompAddress: string | null;

    @Field({ nullable: true })
    CompSubmarket: string | null;

    @Field({ nullable: true })
    SaleDate: Date | null;

    @Field(() => Float, { nullable: true })
    SalePrice: number | null;

    @Field(() => Float, { nullable: true })
    CompDenominator: number | null;

    @Field(() => Int, { nullable: true })
    CompYearBuilt: number | null;

    @Field(() => Float, { nullable: true })
    CompGradeOrdinal: number | null;

    @Field(() => Float, { nullable: true })
    RawPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    SizeAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    AgeAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    GradeAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    TimeAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    NetAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    GrossAdjPct: number | null;

    @Field(() => Float, { nullable: true })
    AdjustedPerUnit: number | null;

    @Field(() => Float, { nullable: true })
    SubjectIndicatedValue: number | null;

    @Field(() => Int, { nullable: true })
    SimilarityRank: number | null;

    @Field(() => Boolean, { nullable: true })
    IsSelected?: boolean;

    @Field({ nullable: true })
    DropReason: string | null;

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    

//****************************************************************************
// INPUT TYPE for Valuation Comps
//****************************************************************************
@InputType()
export class UpdateindianataxValuationCompInput {
    @Field()
    ID: string;

    @Field({ nullable: true })
    ValuationAnalysisID?: string;

    @Field({ nullable: true })
    SaleTransactionID?: string | null;

    @Field({ nullable: true })
    SourceDocumentID?: string | null;

    @Field({ nullable: true })
    UnitOfComparison?: string;

    @Field({ nullable: true })
    CompAddress?: string | null;

    @Field({ nullable: true })
    CompSubmarket?: string | null;

    @Field({ nullable: true })
    SaleDate?: Date | null;

    @Field(() => Float, { nullable: true })
    SalePrice?: number | null;

    @Field(() => Float, { nullable: true })
    CompDenominator?: number | null;

    @Field(() => Int, { nullable: true })
    CompYearBuilt?: number | null;

    @Field(() => Float, { nullable: true })
    CompGradeOrdinal?: number | null;

    @Field(() => Float, { nullable: true })
    RawPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    SizeAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    AgeAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    GradeAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    TimeAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    NetAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    GrossAdjPct?: number | null;

    @Field(() => Float, { nullable: true })
    AdjustedPerUnit?: number | null;

    @Field(() => Float, { nullable: true })
    SubjectIndicatedValue?: number | null;

    @Field(() => Int, { nullable: true })
    SimilarityRank?: number | null;

    @Field(() => Boolean, { nullable: true })
    IsSelected?: boolean;

    @Field({ nullable: true })
    DropReason?: string | null;

    @Field(() => [KeyValuePairInput], { nullable: true })
    OldValues___?: KeyValuePairInput[];

    @Field(() => RestoreContextInput, { nullable: true })
    RestoreContext___?: RestoreContextInput;
}
    
//****************************************************************************
// RESOLVER for Valuation Comps
//****************************************************************************
@ObjectType()
export class RunindianataxValuationCompViewResult {
    @Field(() => [indianataxValuationComp_])
    Results: indianataxValuationComp_[];

    @Field(() => String, {nullable: true})
    UserViewRunID?: string;

    @Field(() => Int, {nullable: true})
    RowCount: number;

    @Field(() => Int, {nullable: true})
    TotalRowCount: number;

    @Field(() => Int, {nullable: true})
    ExecutionTime: number;

    @Field({nullable: true})
    ErrorMessage?: string;

    @Field(() => Boolean, {nullable: false})
    Success: boolean;
}

@Resolver(indianataxValuationComp_)
export class indianataxValuationCompResolver extends ResolverBase {
    @Query(() => RunindianataxValuationCompViewResult)
    async RunindianataxValuationCompViewByID(@Arg('input', () => RunViewByIDInput) input: RunViewByIDInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByIDGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxValuationCompViewResult)
    async RunindianataxValuationCompViewByName(@Arg('input', () => RunViewByNameInput) input: RunViewByNameInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        return super.RunViewByNameGeneric(input, provider, userPayload, pubSub);
    }

    @Query(() => RunindianataxValuationCompViewResult)
    async RunindianataxValuationCompDynamicView(@Arg('input', () => RunDynamicViewInput) input: RunDynamicViewInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        input.EntityName = 'Valuation Comps';
        return super.RunDynamicViewGeneric(input, provider, userPayload, pubSub);
    }
    @Query(() => indianataxValuationComp_, { nullable: true })
    async indianataxValuationComp(@Arg('ID', () => String) ID: string, @Ctx() { userPayload, providers }: AppContext, @PubSub() pubSub: PubSubEngine): Promise<indianataxValuationComp_ | null> {
        this.CheckUserReadPermissions('Valuation Comps', userPayload);
        const provider = GetReadOnlyProvider(providers, { allowFallbackToReadWrite: true });
        const sSQL = `SELECT * FROM ${provider.QuoteSchemaAndView('indiana_tax', 'vwValuationComps')} WHERE ${provider.QuoteIdentifier('ID')}=${provider.BuildParameterPlaceholder(0)} ` + this.getRowLevelSecurityWhereClause(provider, 'Valuation Comps', userPayload, EntityPermissionType.Read, 'AND');
        const rows = await provider.ExecuteSQL(sSQL, [ID], undefined, this.GetUserFromPayload(userPayload));
        const result = await this.MapFieldNamesToCodeNames('Valuation Comps', rows && rows.length > 0 ? rows[0] : null, this.GetUserFromPayload(userPayload));
        return result;
    }
    
    @Mutation(() => indianataxValuationComp_)
    async CreateindianataxValuationComp(
        @Arg('input', () => CreateindianataxValuationCompInput) input: CreateindianataxValuationCompInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.CreateRecord('Valuation Comps', input, provider, userPayload, pubSub)
    }
        
    @Mutation(() => indianataxValuationComp_)
    async UpdateindianataxValuationComp(
        @Arg('input', () => UpdateindianataxValuationCompInput) input: UpdateindianataxValuationCompInput,
        @Ctx() { providers, userPayload }: AppContext,
        @PubSub() pubSub: PubSubEngine
    ) {
        const provider = GetReadWriteProvider(providers);
        return this.UpdateRecord('Valuation Comps', input, provider, userPayload, pubSub);
    }
    
    @Mutation(() => indianataxValuationComp_)
    async DeleteindianataxValuationComp(@Arg('ID', () => String) ID: string, @Arg('options___', () => DeleteOptionsInput) options: DeleteOptionsInput, @Ctx() { providers, userPayload }: AppContext, @PubSub() pubSub: PubSubEngine) {
        const provider = GetReadWriteProvider(providers);
        const key = new CompositeKey([{FieldName: 'ID', Value: ID}]);
        return this.DeleteRecord('Valuation Comps', key, options, provider, userPayload, pubSub);
    }
    
}