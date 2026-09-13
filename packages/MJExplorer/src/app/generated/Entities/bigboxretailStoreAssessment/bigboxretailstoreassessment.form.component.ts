import { Component } from '@angular/core';
import { bigboxretailStoreAssessmentEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Store Assessments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailstoreassessment-form',
    templateUrl: './bigboxretailstoreassessment.form.component.html'
})
export class bigboxretailStoreAssessmentFormComponent extends BaseFormComponent {
    public record!: bigboxretailStoreAssessmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentReference', sectionName: 'Assessment Reference', isExpanded: true },
            { sectionKey: 'assessmentPeriod', sectionName: 'Assessment Period', isExpanded: true },
            { sectionKey: 'assessedValues', sectionName: 'Assessed Values', isExpanded: true },
            { sectionKey: 'dataSource', sectionName: 'Data Source', isExpanded: true },
            { sectionKey: 'dataCompleteness', sectionName: 'Data Completeness', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

