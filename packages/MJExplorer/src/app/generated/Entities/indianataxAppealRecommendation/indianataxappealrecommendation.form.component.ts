import { Component } from '@angular/core';
import { indianataxAppealRecommendationEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Appeal Recommendations') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealrecommendation-form',
    templateUrl: './indianataxappealrecommendation.form.component.html'
})
export class indianataxAppealRecommendationFormComponent extends BaseFormComponent {
    public record!: indianataxAppealRecommendationEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'recommendationIdentity', sectionName: 'Recommendation Identity', isExpanded: true },
            { sectionKey: 'assessmentAndValuation', sectionName: 'Assessment and Valuation', isExpanded: true },
            { sectionKey: 'appealSignalsAndEvidence', sectionName: 'Appeal Signals and Evidence', isExpanded: true },
            { sectionKey: 'recommendationVerdict', sectionName: 'Recommendation Verdict', isExpanded: true },
            { sectionKey: 'askAndSavingsAnalysis', sectionName: 'Ask and Savings Analysis', isExpanded: true },
            { sectionKey: 'subjectGroupingAndStatus', sectionName: 'Subject Grouping and Status', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'appealRecommendationParcels', sectionName: 'Appeal Recommendation Parcels', isExpanded: false },
            { sectionKey: 'appealRecommendationSignals', sectionName: 'Appeal Recommendation Signals', isExpanded: false }
        ]);
    }
}

