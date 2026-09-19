import { Component } from '@angular/core';
import { indianataxStatuteSectionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Statute Sections') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxstatutesection-form',
    templateUrl: './indianataxstatutesection.form.component.html'
})
export class indianataxStatuteSectionFormComponent extends BaseFormComponent {
    public record!: indianataxStatuteSectionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'appealStageStatutes', sectionName: 'Appeal Stage Statutes', isExpanded: false },
            { sectionKey: 'appealStagePlaybookNotes', sectionName: 'Appeal Stage Playbook Notes', isExpanded: false }
        ]);
    }
}

