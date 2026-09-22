import { Component } from '@angular/core';
import { indianataxClientPropertyEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Client Properties') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclientproperty-form',
    templateUrl: './indianataxclientproperty.form.component.html'
})
export class indianataxClientPropertyFormComponent extends BaseFormComponent {
    public record!: indianataxClientPropertyEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'relationships', sectionName: 'Relationships', isExpanded: true },
            { sectionKey: 'propertyAssociationDetails', sectionName: 'Property Association Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientTasks', sectionName: 'Client Tasks', isExpanded: false }
        ]);
    }
}

