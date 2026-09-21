import { Component } from '@angular/core';
import { indianataxCountyEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Counties') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcounty-form',
    templateUrl: './indianataxcounty.form.component.html'
})
export class indianataxCountyFormComponent extends BaseFormComponent {
    public record!: indianataxCountyEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'countyIdentification', sectionName: 'County Identification', isExpanded: true },
            { sectionKey: 'assessorOfficeInformation', sectionName: 'Assessor Office Information', isExpanded: true },
            { sectionKey: 'publicRecordsRequestMethod', sectionName: 'Public Records Request Method', isExpanded: true },
            { sectionKey: 'researchAndContactStatus', sectionName: 'Research and Contact Status', isExpanded: true },
            { sectionKey: 'requestScheduling', sectionName: 'Request Scheduling', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'aPRARequests', sectionName: 'APRA Requests', isExpanded: false },
            { sectionKey: 'countyResources', sectionName: 'County Resources', isExpanded: false },
            { sectionKey: 'countyContacts', sectionName: 'County Contacts', isExpanded: false }
        ]);
    }
}

