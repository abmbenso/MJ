import { Component } from '@angular/core';
import { indianataxPropertyEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Properties') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxproperty-form',
    templateUrl: './indianataxproperty.form.component.html'
})
export class indianataxPropertyFormComponent extends BaseFormComponent {
    public record!: indianataxPropertyEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyIdentification', sectionName: 'Property Identification', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'confirmationAndAudit', sectionName: 'Confirmation and Audit', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'propertyParcels', sectionName: 'Property Parcels', isExpanded: false },
            { sectionKey: 'clientProperties', sectionName: 'Client Properties', isExpanded: false }
        ]);
    }
}

