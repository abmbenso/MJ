import { Component } from '@angular/core';
import { indianataxComparableAssessmentSetEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Comparable Assessment Sets') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcomparableassessmentset-form',
    templateUrl: './indianataxcomparableassessmentset.form.component.html'
})
export class indianataxComparableAssessmentSetFormComponent extends BaseFormComponent {
    public record!: indianataxComparableAssessmentSetEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentSubject', sectionName: 'Assessment Subject', isExpanded: true },
            { sectionKey: 'assessmentConfiguration', sectionName: 'Assessment Configuration', isExpanded: true },
            { sectionKey: 'subjectPropertyValuation', sectionName: 'Subject Property Valuation', isExpanded: true },
            { sectionKey: 'neighborhoodComparables', sectionName: 'Neighborhood Comparables', isExpanded: true },
            { sectionKey: 'countyWideComparables', sectionName: 'County-wide Comparables', isExpanded: true },
            { sectionKey: 'comparativeAnalysis', sectionName: 'Comparative Analysis', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'comparableAssessmentMembers', sectionName: 'Comparable Assessment Members', isExpanded: false }
        ]);
    }
}

