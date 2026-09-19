import { Component } from '@angular/core';
import { indianataxAssessmentEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Assessments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxassessment-form',
    templateUrl: './indianataxassessment.form.component.html'
})
export class indianataxAssessmentFormComponent extends BaseFormComponent {
    public record!: indianataxAssessmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentIdentification', sectionName: 'Assessment Identification', isExpanded: true },
            { sectionKey: 'originalAssessmentValues', sectionName: 'Original Assessment Values', isExpanded: true },
            { sectionKey: 'pTABOAAppealValues', sectionName: 'PTABOA Appeal Values', isExpanded: true },
            { sectionKey: 'appealRevisionDetails', sectionName: 'Appeal Revision Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

