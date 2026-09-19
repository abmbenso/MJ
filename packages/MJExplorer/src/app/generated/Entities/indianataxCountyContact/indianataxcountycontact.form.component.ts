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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'aPRARequests', sectionName: 'APRA Requests', isExpanded: false }
        ]);
    }
}

