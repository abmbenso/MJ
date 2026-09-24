import { Component } from '@angular/core';
import { indianataxSourceDocumentEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Source Documents') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsourcedocument-form',
    templateUrl: './indianataxsourcedocument.form.component.html'
})
export class indianataxSourceDocumentFormComponent extends BaseFormComponent {
    public record!: indianataxSourceDocumentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'documentIdentity', sectionName: 'Document Identity', isExpanded: true },
            { sectionKey: 'sourceAndRetrieval', sectionName: 'Source and Retrieval', isExpanded: true },
            { sectionKey: 'contentManagement', sectionName: 'Content Management', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'statuteSections', sectionName: 'Statute Sections', isExpanded: false },
            { sectionKey: 'boardDecisions', sectionName: 'Board Decisions', isExpanded: false },
            { sectionKey: 'pTABOAAppealsSourceDocumentID', sectionName: 'PTABOA Appeals (Source Document)', isExpanded: false },
            { sectionKey: 'documentCatalogs', sectionName: 'Document Catalogs', isExpanded: false },
            { sectionKey: 'appealStages', sectionName: 'Appeal Stages', isExpanded: false },
            { sectionKey: 'researchTasks', sectionName: 'Research Tasks', isExpanded: false },
            { sectionKey: 'countyAssessorRecordsSourceDocumentID', sectionName: 'County Assessor Records (Source Document ID)', isExpanded: false },
            { sectionKey: 'countyAssessorRecordsTaxHistorySourceDocumentID', sectionName: 'County Assessor Records (Tax History Source Document ID)', isExpanded: false },
            { sectionKey: 'documentAcquisitions', sectionName: 'Document Acquisitions', isExpanded: false },
            { sectionKey: 'taxHistoryYears', sectionName: 'Tax History Years', isExpanded: false },
            { sectionKey: 'pTABOAAppealsFinalDeterminationSourceDocumentID', sectionName: 'PTABOA Appeals (Final Determination Document)', isExpanded: false },
            { sectionKey: 'formCatalogs', sectionName: 'Form Catalogs', isExpanded: false },
            { sectionKey: 'appealStagePlaybookNotes', sectionName: 'Appeal Stage Playbook Notes', isExpanded: false },
            { sectionKey: 'jurisdictionDeadlineAnchors', sectionName: 'Jurisdiction Deadline Anchors', isExpanded: false },
            { sectionKey: 'saleTransactions', sectionName: 'Sale Transactions', isExpanded: false },
            { sectionKey: 'assessments', sectionName: 'Assessments', isExpanded: false },
            { sectionKey: 'coStarIncomeInputs', sectionName: 'Co Star Income Inputs', isExpanded: false },
            { sectionKey: 'coStarProperties', sectionName: 'Co Star Properties', isExpanded: false },
            { sectionKey: 'dLGFBuildingDetails', sectionName: 'DLGF Building Details', isExpanded: false },
            { sectionKey: 'dLGFLands', sectionName: 'DLGF Lands', isExpanded: false },
            { sectionKey: 'dLGFBuildings', sectionName: 'DLGF Buildings', isExpanded: false },
            { sectionKey: 'dLGFImprovements', sectionName: 'DLGF Improvements', isExpanded: false },
            { sectionKey: 'valuationComps', sectionName: 'Valuation Comps', isExpanded: false },
            { sectionKey: 'taxAdjustments', sectionName: 'Tax Adjustments', isExpanded: false },
            { sectionKey: 'taxBills', sectionName: 'Tax Bills', isExpanded: false },
            { sectionKey: 'cardNotes', sectionName: 'Card Notes', isExpanded: false },
            { sectionKey: 'cardValuationColumns', sectionName: 'Card Valuation Columns', isExpanded: false },
            { sectionKey: 'cardSummaries', sectionName: 'Card Summaries', isExpanded: false },
            { sectionKey: 'cardImprovements', sectionName: 'Card Improvements', isExpanded: false },
            { sectionKey: 'iBTRAppeals', sectionName: 'IBTR Appeals', isExpanded: false },
            { sectionKey: 'iBTRDecisionChunks', sectionName: 'IBTR Decision Chunks', isExpanded: false },
            { sectionKey: 'aPRARequestEvents', sectionName: 'APRA Request Events', isExpanded: false },
            { sectionKey: 'aPRARequests', sectionName: 'APRA Requests', isExpanded: false },
            { sectionKey: 'countyContacts', sectionName: 'County Contacts', isExpanded: false },
            { sectionKey: 'aPRAResponseFiles', sectionName: 'APRA Response Files', isExpanded: false },
            { sectionKey: 'assessmentNotices', sectionName: 'Assessment Notices', isExpanded: false },
            { sectionKey: 'legalAuthorities', sectionName: 'Legal Authorities', isExpanded: false },
            { sectionKey: 'legalAuthoritySections', sectionName: 'Legal Authority Sections', isExpanded: false },
            { sectionKey: 'parcelYearHeadlinesHeadlineSourceDocumentID', sectionName: 'Parcel Year Headlines (Headline Source Document)', isExpanded: false },
            { sectionKey: 'parcelYearHeadlinesRevisedFromSourceDocumentID', sectionName: 'Parcel Year Headlines (Revised From Source Document)', isExpanded: false },
            { sectionKey: 'clientProperties', sectionName: 'Client Properties', isExpanded: false },
            { sectionKey: 'clientAuthorizations', sectionName: 'Client Authorizations', isExpanded: false },
            { sectionKey: 'clientImports', sectionName: 'Client Imports', isExpanded: false },
            { sectionKey: 'clientTasks', sectionName: 'Client Tasks', isExpanded: false },
            { sectionKey: 'appealOutcomes', sectionName: 'Appeal Outcomes', isExpanded: false }
        ]);
    }
}

