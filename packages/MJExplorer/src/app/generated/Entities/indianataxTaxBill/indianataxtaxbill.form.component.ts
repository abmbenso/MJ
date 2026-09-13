import { Component } from '@angular/core';
import { indianataxTaxBillEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Tax Bills') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxtaxbill-form',
    templateUrl: './indianataxtaxbill.form.component.html'
})
export class indianataxTaxBillFormComponent extends BaseFormComponent {
    public record!: indianataxTaxBillEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyIdentification', sectionName: 'Property Identification', isExpanded: true },
            { sectionKey: 'jurisdictionInformation', sectionName: 'Jurisdiction Information', isExpanded: true },
            { sectionKey: 'assessmentAndValuation', sectionName: 'Assessment and Valuation', isExpanded: true },
            { sectionKey: 'taxCalculation', sectionName: 'Tax Calculation', isExpanded: true },
            { sectionKey: 'taxAdjustments', sectionName: 'Tax Adjustments', isExpanded: true },
            { sectionKey: 'billTotal', sectionName: 'Bill Total', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'taxAdjustments', sectionName: 'Tax Adjustments', isExpanded: false }
        ]);
    }
}

