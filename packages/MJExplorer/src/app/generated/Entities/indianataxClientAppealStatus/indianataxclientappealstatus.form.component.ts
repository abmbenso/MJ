import { Component } from '@angular/core';
import { indianataxClientAppealStatusEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Client Appeal Status') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclientappealstatus-form',
    templateUrl: './indianataxclientappealstatus.form.component.html'
})
export class indianataxClientAppealStatusFormComponent extends BaseFormComponent {
    public record!: indianataxClientAppealStatusEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'statusConfiguration', sectionName: 'Status Configuration', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

