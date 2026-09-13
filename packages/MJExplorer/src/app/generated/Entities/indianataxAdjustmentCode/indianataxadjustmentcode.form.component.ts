import { Component } from '@angular/core';
import { indianataxAdjustmentCodeEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Adjustment Codes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxadjustmentcode-form',
    templateUrl: './indianataxadjustmentcode.form.component.html'
})
export class indianataxAdjustmentCodeFormComponent extends BaseFormComponent {
    public record!: indianataxAdjustmentCodeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'adjustmentCodeDetails', sectionName: 'Adjustment Code Details', isExpanded: true },
            { sectionKey: 'statutoryInformation', sectionName: 'Statutory Information', isExpanded: true },
            { sectionKey: 'circuitBreakerClassification', sectionName: 'Circuit Breaker Classification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

