/**********************************************************************************
* GENERATED FILE - This file is automatically managed by the MJ CodeGen tool, 
* 
* DO NOT MODIFY THIS FILE - any changes you make will be wiped out the next time the file is
* generated
* 
**********************************************************************************/
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

// MemberJunction Imports
import { BaseFormsModule } from '@memberjunction/ng-base-forms';
import { EntityViewerModule } from '@memberjunction/ng-entity-viewer';
import { LinkDirectivesModule } from '@memberjunction/ng-link-directives';

// Import Generated Components
import { indianataxAdjustmentCodeFormComponent } from "./Entities/indianataxAdjustmentCode/indianataxadjustmentcode.form.component";
import { indianataxAppealAnalysisFormComponent } from "./Entities/indianataxAppealAnalysis/indianataxappealanalysis.form.component";
import { indianataxAppealAnalysisAssumptionFormComponent } from "./Entities/indianataxAppealAnalysisAssumption/indianataxappealanalysisassumption.form.component";
import { indianataxAppealAnalysisCompDecisionFormComponent } from "./Entities/indianataxAppealAnalysisCompDecision/indianataxappealanalysiscompdecision.form.component";
import { indianataxAppealAnalysisIndicationFormComponent } from "./Entities/indianataxAppealAnalysisIndication/indianataxappealanalysisindication.form.component";
import { indianataxAppealLeadFormComponent } from "./Entities/indianataxAppealLead/indianataxappeallead.form.component";
import { indianataxAppealStagePlaybookNoteFormComponent } from "./Entities/indianataxAppealStagePlaybookNote/indianataxappealstageplaybooknote.form.component";
import { indianataxAppealStageStatuteFormComponent } from "./Entities/indianataxAppealStageStatute/indianataxappealstagestatute.form.component";
import { indianataxAppealStageFormComponent } from "./Entities/indianataxAppealStage/indianataxappealstage.form.component";
import { indianataxAPRARequestEventFormComponent } from "./Entities/indianataxAPRARequestEvent/indianataxaprarequestevent.form.component";
import { indianataxAPRARequestFormComponent } from "./Entities/indianataxAPRARequest/indianataxaprarequest.form.component";
import { indianataxAPRAResponseFileFormComponent } from "./Entities/indianataxAPRAResponseFile/indianataxapraresponsefile.form.component";
import { indianataxAssessmentNoticeFormComponent } from "./Entities/indianataxAssessmentNotice/indianataxassessmentnotice.form.component";
import { indianataxAssessmentFormComponent } from "./Entities/indianataxAssessment/indianataxassessment.form.component";
import { indianataxBoardDecisionFormComponent } from "./Entities/indianataxBoardDecision/indianataxboarddecision.form.component";
import { indianataxCardImprovementFormComponent } from "./Entities/indianataxCardImprovement/indianataxcardimprovement.form.component";
import { indianataxCardNoteFormComponent } from "./Entities/indianataxCardNote/indianataxcardnote.form.component";
import { indianataxCardSummaryFormComponent } from "./Entities/indianataxCardSummary/indianataxcardsummary.form.component";
import { indianataxCardValuationColumnFormComponent } from "./Entities/indianataxCardValuationColumn/indianataxcardvaluationcolumn.form.component";
import { indianataxClientAppealFormComponent } from "./Entities/indianataxClientAppeal/indianataxclientappeal.form.component";
import { indianataxClientContactFormComponent } from "./Entities/indianataxClientContact/indianataxclientcontact.form.component";
import { indianataxClientPropertyFormComponent } from "./Entities/indianataxClientProperty/indianataxclientproperty.form.component";
import { indianataxClientTaskFormComponent } from "./Entities/indianataxClientTask/indianataxclienttask.form.component";
import { indianataxClientFormComponent } from "./Entities/indianataxClient/indianataxclient.form.component";
import { indianataxCoStarIncomeInputFormComponent } from "./Entities/indianataxCoStarIncomeInput/indianataxcostarincomeinput.form.component";
import { indianataxCoStarPropertyFormComponent } from "./Entities/indianataxCoStarProperty/indianataxcostarproperty.form.component";
import { indianataxComparableAssessmentMemberFormComponent } from "./Entities/indianataxComparableAssessmentMember/indianataxcomparableassessmentmember.form.component";
import { indianataxComparableAssessmentSetFormComponent } from "./Entities/indianataxComparableAssessmentSet/indianataxcomparableassessmentset.form.component";
import { indianataxCountyFormComponent } from "./Entities/indianataxCounty/indianataxcounty.form.component";
import { indianataxCountyAssessorImprovementSegmentFormComponent } from "./Entities/indianataxCountyAssessorImprovementSegment/indianataxcountyassessorimprovementsegment.form.component";
import { indianataxCountyAssessorImprovementFormComponent } from "./Entities/indianataxCountyAssessorImprovement/indianataxcountyassessorimprovement.form.component";
import { indianataxCountyAssessorRecordFormComponent } from "./Entities/indianataxCountyAssessorRecord/indianataxcountyassessorrecord.form.component";
import { indianataxCountyAssessorSaleHistoryFormComponent } from "./Entities/indianataxCountyAssessorSaleHistory/indianataxcountyassessorsalehistory.form.component";
import { indianataxCountyContactFormComponent } from "./Entities/indianataxCountyContact/indianataxcountycontact.form.component";
import { indianataxCountyResourceFormComponent } from "./Entities/indianataxCountyResource/indianataxcountyresource.form.component";
import { indianataxDataSourceFormComponent } from "./Entities/indianataxDataSource/indianataxdatasource.form.component";
import { indianataxDLGFBuildingDetailFormComponent } from "./Entities/indianataxDLGFBuildingDetail/indianataxdlgfbuildingdetail.form.component";
import { indianataxDLGFBuildingFormComponent } from "./Entities/indianataxDLGFBuilding/indianataxdlgfbuilding.form.component";
import { indianataxDLGFImprovementFormComponent } from "./Entities/indianataxDLGFImprovement/indianataxdlgfimprovement.form.component";
import { indianataxDLGFLandFormComponent } from "./Entities/indianataxDLGFLand/indianataxdlgfland.form.component";
import { indianataxDocumentAcquisitionFormComponent } from "./Entities/indianataxDocumentAcquisition/indianataxdocumentacquisition.form.component";
import { indianataxDocumentCatalogFormComponent } from "./Entities/indianataxDocumentCatalog/indianataxdocumentcatalog.form.component";
import { indianataxFairAndAccurateLeadFormComponent } from "./Entities/indianataxFairAndAccurateLead/indianataxfairandaccuratelead.form.component";
import { indianataxFormCatalogFormComponent } from "./Entities/indianataxFormCatalog/indianataxformcatalog.form.component";
import { indianataxIBTRAppealFormComponent } from "./Entities/indianataxIBTRAppeal/indianataxibtrappeal.form.component";
import { indianataxIBTRDecisionChunkFormComponent } from "./Entities/indianataxIBTRDecisionChunk/indianataxibtrdecisionchunk.form.component";
import { indianataxIBTRDecisionCitationFormComponent } from "./Entities/indianataxIBTRDecisionCitation/indianataxibtrdecisioncitation.form.component";
import { indianataxIBTRDecisionHoldingFormComponent } from "./Entities/indianataxIBTRDecisionHolding/indianataxibtrdecisionholding.form.component";
import { indianataxIBTRDecisionIssueFormComponent } from "./Entities/indianataxIBTRDecisionIssue/indianataxibtrdecisionissue.form.component";
import { indianataxIBTRDecisionPartyFormComponent } from "./Entities/indianataxIBTRDecisionParty/indianataxibtrdecisionparty.form.component";
import { indianataxJurisdictionDeadlineAnchorFormComponent } from "./Entities/indianataxJurisdictionDeadlineAnchor/indianataxjurisdictiondeadlineanchor.form.component";
import { indianataxLegalAuthorityFormComponent } from "./Entities/indianataxLegalAuthority/indianataxlegalauthority.form.component";
import { indianataxLegalAuthorityChunkFormComponent } from "./Entities/indianataxLegalAuthorityChunk/indianataxlegalauthoritychunk.form.component";
import { indianataxLegalAuthoritySectionFormComponent } from "./Entities/indianataxLegalAuthoritySection/indianataxlegalauthoritysection.form.component";
import { indianataxMarketAssumptionFormComponent } from "./Entities/indianataxMarketAssumption/indianataxmarketassumption.form.component";
import { indianataxOwnerPortfolioParcelFormComponent } from "./Entities/indianataxOwnerPortfolioParcel/indianataxownerportfolioparcel.form.component";
import { indianataxOwnerPortfolioRunFormComponent } from "./Entities/indianataxOwnerPortfolioRun/indianataxownerportfoliorun.form.component";
import { indianataxOwnerPortfolioFormComponent } from "./Entities/indianataxOwnerPortfolio/indianataxownerportfolio.form.component";
import { bigboxretailParcelBurdenShiftFormComponent } from "./Entities/bigboxretailParcelBurdenShift/bigboxretailparcelburdenshift.form.component";
import { bigboxretailParcelSettlementFormComponent } from "./Entities/bigboxretailParcelSettlement/bigboxretailparcelsettlement.form.component";
import { bigboxretailParcelTransferFormComponent } from "./Entities/bigboxretailParcelTransfer/bigboxretailparceltransfer.form.component";
import { indianataxParcelYearHeadlineFormComponent } from "./Entities/indianataxParcelYearHeadline/indianataxparcelyearheadline.form.component";
import { indianataxParcelFormComponent } from "./Entities/indianataxParcel/indianataxparcel.form.component";
import { indianataxPropertyFormComponent } from "./Entities/indianataxProperty/indianataxproperty.form.component";
import { indianataxPropertyClassMapFormComponent } from "./Entities/indianataxPropertyClassMap/indianataxpropertyclassmap.form.component";
import { indianataxPropertyParcelFormComponent } from "./Entities/indianataxPropertyParcel/indianataxpropertyparcel.form.component";
import { indianataxProspectActivityFormComponent } from "./Entities/indianataxProspectActivity/indianataxprospectactivity.form.component";
import { indianataxProspectContactFormComponent } from "./Entities/indianataxProspectContact/indianataxprospectcontact.form.component";
import { indianataxProspectParcelFormComponent } from "./Entities/indianataxProspectParcel/indianataxprospectparcel.form.component";
import { indianataxProspectSnapshotFormComponent } from "./Entities/indianataxProspectSnapshot/indianataxprospectsnapshot.form.component";
import { indianataxProspectTaskFormComponent } from "./Entities/indianataxProspectTask/indianataxprospecttask.form.component";
import { indianataxProspectFormComponent } from "./Entities/indianataxProspect/indianataxprospect.form.component";
import { indianataxPTABOAAppealFormComponent } from "./Entities/indianataxPTABOAAppeal/indianataxptaboaappeal.form.component";
import { indianataxResearchTaskFormComponent } from "./Entities/indianataxResearchTask/indianataxresearchtask.form.component";
import { indianataxSaleReassessmentScenarioProbabilityFormComponent } from "./Entities/indianataxSaleReassessmentScenarioProbability/indianataxsalereassessmentscenarioprobability.form.component";
import { indianataxSaleTransactionFormComponent } from "./Entities/indianataxSaleTransaction/indianataxsaletransaction.form.component";
import { indianataxSourceDocumentFormComponent } from "./Entities/indianataxSourceDocument/indianataxsourcedocument.form.component";
import { indianataxSourceRegistryFormComponent } from "./Entities/indianataxSourceRegistry/indianataxsourceregistry.form.component";
import { indianataxStatuteSectionFormComponent } from "./Entities/indianataxStatuteSection/indianataxstatutesection.form.component";
import { bigboxretailvwStoreAnalysisFormComponent } from "./Entities/bigboxretailvwStoreAnalysis/bigboxretailvwstoreanalysis.form.component";
import { bigboxretailStoreAssessmentFormComponent } from "./Entities/bigboxretailStoreAssessment/bigboxretailstoreassessment.form.component";
import { bigboxretailStoreTaxFormComponent } from "./Entities/bigboxretailStoreTax/bigboxretailstoretax.form.component";
import { bigboxretailvwStoreYearFormComponent } from "./Entities/bigboxretailvwStoreYear/bigboxretailvwstoreyear.form.component";
import { bigboxretailStoreFormComponent } from "./Entities/bigboxretailStore/bigboxretailstore.form.component";
import { indianataxTaxAdjustmentFormComponent } from "./Entities/indianataxTaxAdjustment/indianataxtaxadjustment.form.component";
import { indianataxTaxBillFormComponent } from "./Entities/indianataxTaxBill/indianataxtaxbill.form.component";
import { indianataxTaxCourtCaseFormComponent } from "./Entities/indianataxTaxCourtCase/indianataxtaxcourtcase.form.component";
import { indianataxTaxCourtIBTRLinkFormComponent } from "./Entities/indianataxTaxCourtIBTRLink/indianataxtaxcourtibtrlink.form.component";
import { indianataxTaxHistoryYearFormComponent } from "./Entities/indianataxTaxHistoryYear/indianataxtaxhistoryyear.form.component";
import { indianataxValuationAnalysisFormComponent } from "./Entities/indianataxValuationAnalysis/indianataxvaluationanalysis.form.component";
import { indianataxValuationCompFormComponent } from "./Entities/indianataxValuationComp/indianataxvaluationcomp.form.component";
   

@NgModule({
declarations: [
    indianataxAdjustmentCodeFormComponent,
    indianataxAppealAnalysisFormComponent,
    indianataxAppealAnalysisAssumptionFormComponent,
    indianataxAppealAnalysisCompDecisionFormComponent,
    indianataxAppealAnalysisIndicationFormComponent,
    indianataxAppealLeadFormComponent,
    indianataxAppealStagePlaybookNoteFormComponent,
    indianataxAppealStageStatuteFormComponent,
    indianataxAppealStageFormComponent,
    indianataxAPRARequestEventFormComponent,
    indianataxAPRARequestFormComponent,
    indianataxAPRAResponseFileFormComponent,
    indianataxAssessmentNoticeFormComponent,
    indianataxAssessmentFormComponent,
    indianataxBoardDecisionFormComponent,
    indianataxCardImprovementFormComponent,
    indianataxCardNoteFormComponent,
    indianataxCardSummaryFormComponent,
    indianataxCardValuationColumnFormComponent,
    indianataxClientAppealFormComponent],
imports: [
    CommonModule,
    FormsModule,
    BaseFormsModule,
    EntityViewerModule,
    LinkDirectivesModule
],
exports: [
]
})
export class GeneratedForms_SubModule_0 { }
    


@NgModule({
declarations: [
    indianataxClientContactFormComponent,
    indianataxClientPropertyFormComponent,
    indianataxClientTaskFormComponent,
    indianataxClientFormComponent,
    indianataxCoStarIncomeInputFormComponent,
    indianataxCoStarPropertyFormComponent,
    indianataxComparableAssessmentMemberFormComponent,
    indianataxComparableAssessmentSetFormComponent,
    indianataxCountyFormComponent,
    indianataxCountyAssessorImprovementSegmentFormComponent,
    indianataxCountyAssessorImprovementFormComponent,
    indianataxCountyAssessorRecordFormComponent,
    indianataxCountyAssessorSaleHistoryFormComponent,
    indianataxCountyContactFormComponent,
    indianataxCountyResourceFormComponent,
    indianataxDataSourceFormComponent,
    indianataxDLGFBuildingDetailFormComponent,
    indianataxDLGFBuildingFormComponent,
    indianataxDLGFImprovementFormComponent,
    indianataxDLGFLandFormComponent],
imports: [
    CommonModule,
    FormsModule,
    BaseFormsModule,
    EntityViewerModule,
    LinkDirectivesModule
],
exports: [
]
})
export class GeneratedForms_SubModule_1 { }
    


@NgModule({
declarations: [
    indianataxDocumentAcquisitionFormComponent,
    indianataxDocumentCatalogFormComponent,
    indianataxFairAndAccurateLeadFormComponent,
    indianataxFormCatalogFormComponent,
    indianataxIBTRAppealFormComponent,
    indianataxIBTRDecisionChunkFormComponent,
    indianataxIBTRDecisionCitationFormComponent,
    indianataxIBTRDecisionHoldingFormComponent,
    indianataxIBTRDecisionIssueFormComponent,
    indianataxIBTRDecisionPartyFormComponent,
    indianataxJurisdictionDeadlineAnchorFormComponent,
    indianataxLegalAuthorityFormComponent,
    indianataxLegalAuthorityChunkFormComponent,
    indianataxLegalAuthoritySectionFormComponent,
    indianataxMarketAssumptionFormComponent,
    indianataxOwnerPortfolioParcelFormComponent,
    indianataxOwnerPortfolioRunFormComponent,
    indianataxOwnerPortfolioFormComponent,
    bigboxretailParcelBurdenShiftFormComponent,
    bigboxretailParcelSettlementFormComponent],
imports: [
    CommonModule,
    FormsModule,
    BaseFormsModule,
    EntityViewerModule,
    LinkDirectivesModule
],
exports: [
]
})
export class GeneratedForms_SubModule_2 { }
    


@NgModule({
declarations: [
    bigboxretailParcelTransferFormComponent,
    indianataxParcelYearHeadlineFormComponent,
    indianataxParcelFormComponent,
    indianataxPropertyFormComponent,
    indianataxPropertyClassMapFormComponent,
    indianataxPropertyParcelFormComponent,
    indianataxProspectActivityFormComponent,
    indianataxProspectContactFormComponent,
    indianataxProspectParcelFormComponent,
    indianataxProspectSnapshotFormComponent,
    indianataxProspectTaskFormComponent,
    indianataxProspectFormComponent,
    indianataxPTABOAAppealFormComponent,
    indianataxResearchTaskFormComponent,
    indianataxSaleReassessmentScenarioProbabilityFormComponent,
    indianataxSaleTransactionFormComponent,
    indianataxSourceDocumentFormComponent,
    indianataxSourceRegistryFormComponent,
    indianataxStatuteSectionFormComponent,
    bigboxretailvwStoreAnalysisFormComponent],
imports: [
    CommonModule,
    FormsModule,
    BaseFormsModule,
    EntityViewerModule,
    LinkDirectivesModule
],
exports: [
]
})
export class GeneratedForms_SubModule_3 { }
    


@NgModule({
declarations: [
    bigboxretailStoreAssessmentFormComponent,
    bigboxretailStoreTaxFormComponent,
    bigboxretailvwStoreYearFormComponent,
    bigboxretailStoreFormComponent,
    indianataxTaxAdjustmentFormComponent,
    indianataxTaxBillFormComponent,
    indianataxTaxCourtCaseFormComponent,
    indianataxTaxCourtIBTRLinkFormComponent,
    indianataxTaxHistoryYearFormComponent,
    indianataxValuationAnalysisFormComponent,
    indianataxValuationCompFormComponent],
imports: [
    CommonModule,
    FormsModule,
    BaseFormsModule,
    EntityViewerModule,
    LinkDirectivesModule
],
exports: [
]
})
export class GeneratedForms_SubModule_4 { }
    


@NgModule({
declarations: [
],
imports: [
    GeneratedForms_SubModule_0,
    GeneratedForms_SubModule_1,
    GeneratedForms_SubModule_2,
    GeneratedForms_SubModule_3,
    GeneratedForms_SubModule_4
]
})
export class GeneratedFormsModule { }
    
// Note: LoadXXXGeneratedForms() functions have been removed. Tree-shaking prevention
// is now handled by the pre-built class registration manifest system.
// See packages/CodeGenLib/CLASS_MANIFEST_GUIDE.md for details.
    