import { Component } from '@angular/core';
import { indianataxTaxAdjustmentEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Tax Adjustments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxtaxadjustment-form',
    templateUrl: './indianataxtaxadjustment.form.component.html'
})
export class indianataxTaxAdjustmentFormComponent extends BaseFormComponent {
    public record!: indianataxTaxAdjustmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'adjustmentDetails', sectionName: 'Adjustment Details', isExpanded: true },
            { sectionKey: 'adjustmentAmount', sectionName: 'Adjustment Amount', isExpanded: true },
            { sectionKey: 'adjustmentTerm', sectionName: 'Adjustment Term', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

