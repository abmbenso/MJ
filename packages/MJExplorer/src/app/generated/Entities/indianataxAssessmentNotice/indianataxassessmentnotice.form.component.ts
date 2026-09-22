import { Component } from '@angular/core';
import { indianataxAssessmentNoticeEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Assessment Notices') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxassessmentnotice-form',
    templateUrl: './indianataxassessmentnotice.form.component.html'
})
export class indianataxAssessmentNoticeFormComponent extends BaseFormComponent {
    public record!: indianataxAssessmentNoticeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

