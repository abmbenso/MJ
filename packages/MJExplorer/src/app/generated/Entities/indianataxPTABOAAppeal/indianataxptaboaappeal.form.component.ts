import { Component } from '@angular/core';
import { indianataxPTABOAAppealEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'PTABOA Appeals') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxptaboaappeal-form',
    templateUrl: './indianataxptaboaappeal.form.component.html'
})
export class indianataxPTABOAAppealFormComponent extends BaseFormComponent {
    public record!: indianataxPTABOAAppealEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'appealIdentification', sectionName: 'Appeal Identification', isExpanded: true },
            { sectionKey: 'appealDetails', sectionName: 'Appeal Details', isExpanded: true },
            { sectionKey: 'assessedValues', sectionName: 'Assessed Values', isExpanded: true },
            { sectionKey: 'appealOutcome', sectionName: 'Appeal Outcome', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

