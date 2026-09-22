import { Component } from '@angular/core';
import { indianataxValuationCompEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Valuation Comps') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxvaluationcomp-form',
    templateUrl: './indianataxvaluationcomp.form.component.html'
})
export class indianataxValuationCompFormComponent extends BaseFormComponent {
    public record!: indianataxValuationCompEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'valuationReference', sectionName: 'Valuation Reference', isExpanded: true },
            { sectionKey: 'comparablePropertyDetails', sectionName: 'Comparable Property Details', isExpanded: true },
            { sectionKey: 'saleInformation', sectionName: 'Sale Information', isExpanded: true },
            { sectionKey: 'adjustmentFactors', sectionName: 'Adjustment Factors', isExpanded: true },
            { sectionKey: 'adjustmentResults', sectionName: 'Adjustment Results', isExpanded: true },
            { sectionKey: 'valuationResults', sectionName: 'Valuation Results', isExpanded: true },
            { sectionKey: 'selectionCriteria', sectionName: 'Selection Criteria', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

