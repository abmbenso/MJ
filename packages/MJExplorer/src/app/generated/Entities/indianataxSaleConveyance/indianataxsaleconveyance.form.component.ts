import { Component } from '@angular/core';
import { indianataxSaleConveyanceEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Sale Conveyances') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsaleconveyance-form',
    templateUrl: './indianataxsaleconveyance.form.component.html'
})
export class indianataxSaleConveyanceFormComponent extends BaseFormComponent {
    public record!: indianataxSaleConveyanceEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'conveyanceIdentification', sectionName: 'Conveyance Identification', isExpanded: true },
            { sectionKey: 'transactionDetails', sectionName: 'Transaction Details', isExpanded: true },
            { sectionKey: 'conveyanceParties', sectionName: 'Conveyance Parties', isExpanded: true },
            { sectionKey: 'propertyComposition', sectionName: 'Property Composition', isExpanded: true },
            { sectionKey: 'valuationMetrics', sectionName: 'Valuation Metrics', isExpanded: true },
            { sectionKey: 'assessmentComparison', sectionName: 'Assessment Comparison', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'saleConveyanceMembers', sectionName: 'Sale Conveyance Members', isExpanded: false }
        ]);
    }
}

