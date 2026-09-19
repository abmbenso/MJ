import { Component } from '@angular/core';
import { indianataxSaleTransactionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Sale Transactions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsaletransaction-form',
    templateUrl: './indianataxsaletransaction.form.component.html'
})
export class indianataxSaleTransactionFormComponent extends BaseFormComponent {
    public record!: indianataxSaleTransactionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'transactionDetails', sectionName: 'Transaction Details', isExpanded: true },
            { sectionKey: 'propertyLocation', sectionName: 'Property Location', isExpanded: true },
            { sectionKey: 'propertyClassification', sectionName: 'Property Classification', isExpanded: true },
            { sectionKey: 'transactionParties', sectionName: 'Transaction Parties', isExpanded: true },
            { sectionKey: 'validationAndAnalysis', sectionName: 'Validation and Analysis', isExpanded: true },
            { sectionKey: 'propertyCharacteristics', sectionName: 'Property Characteristics', isExpanded: true },
            { sectionKey: 'valuationMetrics', sectionName: 'Valuation Metrics', isExpanded: true },
            { sectionKey: 'valuationAndAssessment', sectionName: 'Valuation and Assessment', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'valuationComps', sectionName: 'Valuation Comps', isExpanded: false },
            { sectionKey: 'appealAnalysisCompDecisions', sectionName: 'Appeal Analysis Comp Decisions', isExpanded: false }
        ]);
    }
}

