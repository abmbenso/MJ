import { Component } from '@angular/core';
import { indianataxProspectEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Prospects') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospect-form',
    templateUrl: './indianataxprospect.form.component.html'
})
export class indianataxProspectFormComponent extends BaseFormComponent {
    public record!: indianataxProspectEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'prospectIdentification', sectionName: 'Prospect Identification', isExpanded: true },
            { sectionKey: 'pipelineManagement', sectionName: 'Pipeline Management', isExpanded: true },
            { sectionKey: 'prospectTimeline', sectionName: 'Prospect Timeline', isExpanded: true },
            { sectionKey: 'prospectActivity', sectionName: 'Prospect Activity', isExpanded: true },
            { sectionKey: 'prospectAnalysis', sectionName: 'Prospect Analysis', isExpanded: true },
            { sectionKey: 'prospectClosure', sectionName: 'Prospect Closure', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'prospectActivities', sectionName: 'Prospect Activities', isExpanded: false },
            { sectionKey: 'prospectContacts', sectionName: 'Prospect Contacts', isExpanded: false },
            { sectionKey: 'prospectSnapshots', sectionName: 'Prospect Snapshots', isExpanded: false },
            { sectionKey: 'prospectTasks', sectionName: 'Prospect Tasks', isExpanded: false },
            { sectionKey: 'prospectParcels', sectionName: 'Prospect Parcels', isExpanded: false }
        ]);
    }
}

