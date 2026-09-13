import { Component } from '@angular/core';
import { indianataxProspectContactEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Prospect Contacts') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospectcontact-form',
    templateUrl: './indianataxprospectcontact.form.component.html'
})
export class indianataxProspectContactFormComponent extends BaseFormComponent {
    public record!: indianataxProspectContactEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'contactDetails', sectionName: 'Contact Details', isExpanded: true },
            { sectionKey: 'contactInformation', sectionName: 'Contact Information', isExpanded: true },
            { sectionKey: 'relationshipInformation', sectionName: 'Relationship Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'prospectActivities', sectionName: 'Prospect Activities', isExpanded: false }
        ]);
    }
}

