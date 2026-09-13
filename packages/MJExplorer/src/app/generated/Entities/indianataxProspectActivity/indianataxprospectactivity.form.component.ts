import { Component } from '@angular/core';
import { indianataxProspectActivityEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Prospect Activities') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospectactivity-form',
    templateUrl: './indianataxprospectactivity.form.component.html'
})
export class indianataxProspectActivityFormComponent extends BaseFormComponent {
    public record!: indianataxProspectActivityEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'activityDetails', sectionName: 'Activity Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'prospectTasks', sectionName: 'Prospect Tasks', isExpanded: false }
        ]);
    }
}

