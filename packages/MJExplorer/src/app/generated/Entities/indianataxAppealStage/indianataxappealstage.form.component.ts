import { Component } from '@angular/core';
import { indianataxAppealStageEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Appeal Stages') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealstage-form',
    templateUrl: './indianataxappealstage.form.component.html'
})
export class indianataxAppealStageFormComponent extends BaseFormComponent {
    public record!: indianataxAppealStageEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'appealProcessDefinition', sectionName: 'Appeal Process Definition', isExpanded: true },
            { sectionKey: 'proceduralRequirements', sectionName: 'Procedural Requirements', isExpanded: true },
            { sectionKey: 'deadlineAndTiming', sectionName: 'Deadline and Timing', isExpanded: true },
            { sectionKey: 'jurisdictionalScope', sectionName: 'Jurisdictional Scope', isExpanded: true },
            { sectionKey: 'sourceAndContext', sectionName: 'Source and Context', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'appealStageStatutes', sectionName: 'Appeal Stage Statutes', isExpanded: false },
            { sectionKey: 'formCatalogsCorrespondingAppealStageID', sectionName: 'Form Catalogs (Corresponding Appeal Stage)', isExpanded: false },
            { sectionKey: 'formCatalogsTriggersAppealStageID', sectionName: 'Form Catalogs (Triggers Appeal Stage)', isExpanded: false },
            { sectionKey: 'appealStagePlaybookNotes', sectionName: 'Appeal Stage Playbook Notes', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

