import { Component } from '@angular/core';
import { indianataxAppealStagePlaybookNoteEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Stage Playbook Notes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealstageplaybooknote-form',
    templateUrl: './indianataxappealstageplaybooknote.form.component.html'
})
export class indianataxAppealStagePlaybookNoteFormComponent extends BaseFormComponent {
    public record!: indianataxAppealStagePlaybookNoteEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'noteAssociation', sectionName: 'Note Association', isExpanded: true },
            { sectionKey: 'noteContent', sectionName: 'Note Content', isExpanded: true },
            { sectionKey: 'scopeAndApplicability', sectionName: 'Scope and Applicability', isExpanded: true },
            { sectionKey: 'citationAndAuthority', sectionName: 'Citation and Authority', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

