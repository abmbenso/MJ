import { Component } from '@angular/core';
import { indianataxCountyContactEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'County Contacts') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountycontact-form',
    templateUrl: './indianataxcountycontact.form.component.html'
})
export class indianataxCountyContactFormComponent extends BaseFormComponent {
    public record!: indianataxCountyContactEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'contactAssignment', sectionName: 'Contact Assignment', isExpanded: true },
            { sectionKey: 'contactInformation', sectionName: 'Contact Information', isExpanded: true },
            { sectionKey: 'sourceDocumentation', sectionName: 'Source Documentation', isExpanded: true },
            { sectionKey: 'verificationAndQuality', sectionName: 'Verification and Quality', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'aPRARequests', sectionName: 'APRA Requests', isExpanded: false }
        ]);
    }
}

