import { Component } from '@angular/core';
import { indianataxAppealAnalysisIndicationEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Analysis Indications') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealanalysisindication-form',
    templateUrl: './indianataxappealanalysisindication.form.component.html'
})
export class indianataxAppealAnalysisIndicationFormComponent extends BaseFormComponent {
    public record!: indianataxAppealAnalysisIndicationEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'analysisReference', sectionName: 'Analysis Reference', isExpanded: true },
            { sectionKey: 'valuationApproach', sectionName: 'Valuation Approach', isExpanded: true },
            { sectionKey: 'valuationResults', sectionName: 'Valuation Results', isExpanded: true },
            { sectionKey: 'credibilityAssessment', sectionName: 'Credibility Assessment', isExpanded: true },
            { sectionKey: 'analysisNotes', sectionName: 'Analysis Notes', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

