import { Component } from '@angular/core';
import { bigboxretailParcelTransferEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Parcel Transfers') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailparceltransfer-form',
    templateUrl: './bigboxretailparceltransfer.form.component.html'
})
export class bigboxretailParcelTransferFormComponent extends BaseFormComponent {
    public record!: bigboxretailParcelTransferEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'transferIdentification', sectionName: 'Transfer Identification', isExpanded: true },
            { sectionKey: 'storeReference', sectionName: 'Store Reference', isExpanded: true },
            { sectionKey: 'transferDetails', sectionName: 'Transfer Details', isExpanded: true },
            { sectionKey: 'pricingAndValuation', sectionName: 'Pricing and Valuation', isExpanded: true },
            { sectionKey: 'comparabilityAssessment', sectionName: 'Comparability Assessment', isExpanded: true },
            { sectionKey: 'sourceDocumentation', sectionName: 'Source Documentation', isExpanded: true },
            { sectionKey: 'propertyCharacteristics', sectionName: 'Property Characteristics', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

