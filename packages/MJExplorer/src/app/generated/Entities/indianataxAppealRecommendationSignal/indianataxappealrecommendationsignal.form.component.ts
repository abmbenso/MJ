import { Component } from '@angular/core';
import { indianataxAppealRecommendationSignalEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Recommendation Signals') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealrecommendationsignal-form',
    templateUrl: './indianataxappealrecommendationsignal.form.component.html'
})
export class indianataxAppealRecommendationSignalFormComponent extends BaseFormComponent {
    public record!: indianataxAppealRecommendationSignalEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'signalAssociation', sectionName: 'Signal Association', isExpanded: true },
            { sectionKey: 'signalDefinition', sectionName: 'Signal Definition', isExpanded: true },
            { sectionKey: 'signalEvaluation', sectionName: 'Signal Evaluation', isExpanded: true },
            { sectionKey: 'valuationResults', sectionName: 'Valuation Results', isExpanded: true },
            { sectionKey: 'evidenceDetails', sectionName: 'Evidence Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

