import { Component } from '@angular/core';
import { indianataxAssessmentNoticeEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Assessment Notices') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxassessmentnotice-form',
    templateUrl: './indianataxassessmentnotice.form.component.html'
})
export class indianataxAssessmentNoticeFormComponent extends BaseFormComponent {
    public record!: indianataxAssessmentNoticeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentNoticeDetails', sectionName: 'Assessment Notice Details', isExpanded: true },
            { sectionKey: 'noticeTimeline', sectionName: 'Notice Timeline', isExpanded: true },
            { sectionKey: 'previousAssessmentValues', sectionName: 'Previous Assessment Values', isExpanded: true },
            { sectionKey: 'newAssessmentValues', sectionName: 'New Assessment Values', isExpanded: true },
            { sectionKey: 'apartmentValuationApproaches', sectionName: 'Apartment Valuation Approaches', isExpanded: true },
            { sectionKey: 'propertyOwnerAndLocation', sectionName: 'Property Owner and Location', isExpanded: true },
            { sectionKey: 'assessmentAuthority', sectionName: 'Assessment Authority', isExpanded: true },
            { sectionKey: 'dataQuality', sectionName: 'Data Quality', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

