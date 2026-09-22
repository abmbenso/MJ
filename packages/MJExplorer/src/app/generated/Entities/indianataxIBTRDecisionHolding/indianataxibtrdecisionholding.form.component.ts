import { Component } from '@angular/core';
import { indianataxIBTRDecisionHoldingEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'IBTR Decision Holdings') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrdecisionholding-form',
    templateUrl: './indianataxibtrdecisionholding.form.component.html'
})
export class indianataxIBTRDecisionHoldingFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRDecisionHoldingEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'decisionReference', sectionName: 'Decision Reference', isExpanded: true },
            { sectionKey: 'decisionOutcome', sectionName: 'Decision Outcome', isExpanded: true },
            { sectionKey: 'assessedValue', sectionName: 'Assessed Value', isExpanded: true },
            { sectionKey: 'burdenOfProof', sectionName: 'Burden of Proof', isExpanded: true },
            { sectionKey: 'evidence', sectionName: 'Evidence', isExpanded: true },
            { sectionKey: 'dataQuality', sectionName: 'Data Quality', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

