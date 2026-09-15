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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

