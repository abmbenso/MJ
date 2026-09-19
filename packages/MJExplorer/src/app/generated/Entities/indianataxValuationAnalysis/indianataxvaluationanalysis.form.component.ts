import { Component } from '@angular/core';
import { indianataxValuationAnalysisEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Valuation Analysis') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxvaluationanalysis-form',
    templateUrl: './indianataxvaluationanalysis.form.component.html'
})
export class indianataxValuationAnalysisFormComponent extends BaseFormComponent {
    public record!: indianataxValuationAnalysisEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'valuationSubject', sectionName: 'Valuation Subject', isExpanded: true },
            { sectionKey: 'currentAssessment', sectionName: 'Current Assessment', isExpanded: true },
            { sectionKey: 'valuationApproaches', sectionName: 'Valuation Approaches', isExpanded: true },
            { sectionKey: 'reconciliationAndTarget', sectionName: 'Reconciliation and Target', isExpanded: true },
            { sectionKey: 'appealAnalysis', sectionName: 'Appeal Analysis', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'valuationComps', sectionName: 'Valuation Comps', isExpanded: false },
            { sectionKey: 'appealAnalysis', sectionName: 'Appeal Analysis', isExpanded: false }
        ]);
    }
}

