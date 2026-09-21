import { Component } from '@angular/core';
import { indianataxParcelEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Parcels') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxparcel-form',
    templateUrl: './indianataxparcel.form.component.html'
})
export class indianataxParcelFormComponent extends BaseFormComponent {
    public record!: indianataxParcelEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'propertyLocation', sectionName: 'Property Location', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'propertyCharacteristics', sectionName: 'Property Characteristics', isExpanded: true },
            { sectionKey: 'dataProvenance', sectionName: 'Data Provenance', isExpanded: true },
            { sectionKey: 'taxDistrictInformation', sectionName: 'Tax District Information', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'pTABOAAppeals', sectionName: 'PTABOA Appeals', isExpanded: false },
            { sectionKey: 'assessments', sectionName: 'Assessments', isExpanded: false },
            { sectionKey: 'boardDecisions', sectionName: 'Board Decisions', isExpanded: false },
            { sectionKey: 'countyAssessorRecords', sectionName: 'County Assessor Records', isExpanded: false },
            { sectionKey: 'appealLeads', sectionName: 'Appeal Leads', isExpanded: false },
            { sectionKey: 'documentAcquisitions', sectionName: 'Document Acquisitions', isExpanded: false },
            { sectionKey: 'taxHistoryYears', sectionName: 'Tax History Years', isExpanded: false },
            { sectionKey: 'coStarPropertiesParcelID', sectionName: 'Co Star Properties (Parcel)', isExpanded: false },
            { sectionKey: 'coStarPropertiesCoStarSecondaryParcelID', sectionName: 'Co Star Properties (CoStar Secondary Parcel)', isExpanded: false },
            { sectionKey: 'saleTransactions', sectionName: 'Sale Transactions', isExpanded: false },
            { sectionKey: 'valuationAnalysis', sectionName: 'Valuation Analysis', isExpanded: false },
            { sectionKey: 'comparableAssessmentSets', sectionName: 'Comparable Assessment Sets', isExpanded: false },
            { sectionKey: 'comparableAssessmentMembers', sectionName: 'Comparable Assessment Members', isExpanded: false },
            { sectionKey: 'coStarIncomeInputs', sectionName: 'Co Star Income Inputs', isExpanded: false },
            { sectionKey: 'dLGFImprovements', sectionName: 'DLGF Improvements', isExpanded: false },
            { sectionKey: 'dLGFLands', sectionName: 'DLGF Lands', isExpanded: false },
            { sectionKey: 'dLGFBuildingDetails', sectionName: 'DLGF Building Details', isExpanded: false },
            { sectionKey: 'dLGFBuildings', sectionName: 'DLGF Buildings', isExpanded: false },
            { sectionKey: 'prospectParcels', sectionName: 'Prospect Parcels', isExpanded: false },
            { sectionKey: 'ownerPortfolioParcels', sectionName: 'Owner Portfolio Parcels', isExpanded: false },
            { sectionKey: 'taxBills', sectionName: 'Tax Bills', isExpanded: false },
            { sectionKey: 'cardValuationColumns', sectionName: 'Card Valuation Columns', isExpanded: false },
            { sectionKey: 'cardNotes', sectionName: 'Card Notes', isExpanded: false },
            { sectionKey: 'cardSummaries', sectionName: 'Card Summaries', isExpanded: false },
            { sectionKey: 'cardImprovements', sectionName: 'Card Improvements', isExpanded: false },
            { sectionKey: 'iBTRAppeals', sectionName: 'IBTR Appeals', isExpanded: false },
            { sectionKey: 'assessmentNotices', sectionName: 'Assessment Notices', isExpanded: false },
            { sectionKey: 'appealAnalysis', sectionName: 'Appeal Analysis', isExpanded: false }
        ]);
    }
}

