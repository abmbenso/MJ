import { Component } from '@angular/core';
import { indianataxCardNoteEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Card Notes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcardnote-form',
    templateUrl: './indianataxcardnote.form.component.html'
})
export class indianataxCardNoteFormComponent extends BaseFormComponent {
    public record!: indianataxCardNoteEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'cardReference', sectionName: 'Card Reference', isExpanded: true },
            { sectionKey: 'noteContent', sectionName: 'Note Content', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

