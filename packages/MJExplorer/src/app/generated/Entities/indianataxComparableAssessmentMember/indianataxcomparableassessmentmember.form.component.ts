import { Component } from '@angular/core';
import { indianataxComparableAssessmentMemberEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Comparable Assessment Members') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcomparableassessmentmember-form',
    templateUrl: './indianataxcomparableassessmentmember.form.component.html'
})
export class indianataxComparableAssessmentMemberFormComponent extends BaseFormComponent {
    public record!: indianataxComparableAssessmentMemberEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentSetAssociation', sectionName: 'Assessment Set Association', isExpanded: true },
            { sectionKey: 'similarityAnalysis', sectionName: 'Similarity Analysis', isExpanded: true },
            { sectionKey: 'analystReview', sectionName: 'Analyst Review', isExpanded: true },
            { sectionKey: 'propertyAttributes', sectionName: 'Property Attributes', isExpanded: true },
            { sectionKey: 'valuationMetrics', sectionName: 'Valuation Metrics', isExpanded: true },
            { sectionKey: 'appealInformation', sectionName: 'Appeal Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

