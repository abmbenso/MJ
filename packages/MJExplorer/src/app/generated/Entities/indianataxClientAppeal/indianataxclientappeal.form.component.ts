import { Component } from '@angular/core';
import { indianataxClientAppealEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Client Appeals') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclientappeal-form',
    templateUrl: './indianataxclientappeal.form.component.html'
})
export class indianataxClientAppealFormComponent extends BaseFormComponent {
    public record!: indianataxClientAppealEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'appealIdentification', sectionName: 'Appeal Identification', isExpanded: true },
            { sectionKey: 'appealProcess', sectionName: 'Appeal Process', isExpanded: true },
            { sectionKey: 'appealTimeline', sectionName: 'Appeal Timeline', isExpanded: true },
            { sectionKey: 'assessmentValues', sectionName: 'Assessment Values', isExpanded: true },
            { sectionKey: 'taxSavings', sectionName: 'Tax Savings', isExpanded: true },
            { sectionKey: 'appealDetails', sectionName: 'Appeal Details', isExpanded: true },
            { sectionKey: 'clientCommunication', sectionName: 'Client Communication', isExpanded: true },
            { sectionKey: 'relatedEntityData', sectionName: 'Related Entity Data', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'clientTasks', sectionName: 'Client Tasks', isExpanded: false }
        ]);
    }
}

