import { Component } from '@angular/core';
import { indianataxCountyAssessmentCycleEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'County Assessment Cycles') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyassessmentcycle-form',
    templateUrl: './indianataxcountyassessmentcycle.form.component.html'
})
export class indianataxCountyAssessmentCycleFormComponent extends BaseFormComponent {
    public record!: indianataxCountyAssessmentCycleEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentCycleDetails', sectionName: 'Assessment Cycle Details', isExpanded: true },
            { sectionKey: 'noticeAndDeadlineDetails', sectionName: 'Notice and Deadline Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

