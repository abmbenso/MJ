import { Component } from '@angular/core';
import { indianataxSaleReassessmentScenarioProbabilityEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Sale Reassessment Scenario Probabilities') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsalereassessmentscenarioprobability-form',
    templateUrl: './indianataxsalereassessmentscenarioprobability.form.component.html'
})
export class indianataxSaleReassessmentScenarioProbabilityFormComponent extends BaseFormComponent {
    public record!: indianataxSaleReassessmentScenarioProbabilityEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentScenarioParameters', sectionName: 'Assessment Scenario Parameters', isExpanded: true },
            { sectionKey: 'sampleStatistics', sectionName: 'Sample Statistics', isExpanded: true },
            { sectionKey: 'worstCaseScenarioProbabilities', sectionName: 'Worst Case Scenario Probabilities', isExpanded: true },
            { sectionKey: 'mostLikelyScenarioProbabilities', sectionName: 'Most Likely Scenario Probabilities', isExpanded: true },
            { sectionKey: 'bestCaseScenarioProbabilities', sectionName: 'Best Case Scenario Probabilities', isExpanded: true },
            { sectionKey: 'modelMetadata', sectionName: 'Model Metadata', isExpanded: false },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

