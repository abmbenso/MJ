import { Component } from '@angular/core';
import { indianataxClientEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Clients') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclient-form',
    templateUrl: './indianataxclient.form.component.html'
})
export class indianataxClientFormComponent extends BaseFormComponent {
    public record!: indianataxClientEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'clientInformation', sectionName: 'Client Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false },
            { sectionKey: 'clientProperties', sectionName: 'Client Properties', isExpanded: false },
            { sectionKey: 'clientContacts', sectionName: 'Client Contacts', isExpanded: false },
            { sectionKey: 'clientTasks', sectionName: 'Client Tasks', isExpanded: false },
            { sectionKey: 'clientAuthorizations', sectionName: 'Client Authorizations', isExpanded: false },
            { sectionKey: 'clientImports', sectionName: 'Client Imports', isExpanded: false }
        ]);
    }
}

