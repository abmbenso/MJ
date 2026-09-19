import { Component } from '@angular/core';
import { indianataxCountyAssessorRecordEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'County Assessor Records') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyassessorrecord-form',
    templateUrl: './indianataxcountyassessorrecord.form.component.html'
})
export class indianataxCountyAssessorRecordFormComponent extends BaseFormComponent {
    public record!: indianataxCountyAssessorRecordEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'ownerInformation', sectionName: 'Owner Information', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'assessmentValues', sectionName: 'Assessment Values', isExpanded: true },
            { sectionKey: 'assessmentTimeline', sectionName: 'Assessment Timeline', isExpanded: true },
            { sectionKey: 'taxCalculation', sectionName: 'Tax Calculation', isExpanded: true },
            { sectionKey: 'deedInformation', sectionName: 'Deed Information', isExpanded: true },
            { sectionKey: 'sourceDocuments', sectionName: 'Source Documents', isExpanded: true },
            { sectionKey: 'valuationApproach', sectionName: 'Valuation Approach', isExpanded: true },
            { sectionKey: 'assessmentRevision', sectionName: 'Assessment Revision', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'countyAssessorSaleHistories', sectionName: 'County Assessor Sale Histories', isExpanded: false },
            { sectionKey: 'countyAssessorImprovements', sectionName: 'County Assessor Improvements', isExpanded: false },
            { sectionKey: 'countyAssessorImprovementSegments', sectionName: 'County Assessor Improvement Segments', isExpanded: false }
        ]);
    }
}

