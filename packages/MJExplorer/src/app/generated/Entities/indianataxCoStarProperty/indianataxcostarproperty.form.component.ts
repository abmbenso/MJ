import { Component } from '@angular/core';
import { indianataxCoStarPropertyEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Co Star Properties') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcostarproperty-form',
    templateUrl: './indianataxcostarproperty.form.component.html'
})
export class indianataxCoStarPropertyFormComponent extends BaseFormComponent {
    public record!: indianataxCoStarPropertyEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyIdentification', sectionName: 'Property Identification', isExpanded: true },
            { sectionKey: 'locationAndGeography', sectionName: 'Location and Geography', isExpanded: true },
            { sectionKey: 'basicPropertyDetails', sectionName: 'Basic Property Details', isExpanded: true },
            { sectionKey: 'parcelInformation', sectionName: 'Parcel Information', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'physicalCharacteristics', sectionName: 'Physical Characteristics', isExpanded: true },
            { sectionKey: 'buildingHistory', sectionName: 'Building History', isExpanded: true },
            { sectionKey: 'transactionHistory', sectionName: 'Transaction History', isExpanded: true },
            { sectionKey: 'forSaleInformation', sectionName: 'For-Sale Information', isExpanded: true },
            { sectionKey: 'financialMetrics', sectionName: 'Financial Metrics', isExpanded: true },
            { sectionKey: 'marketMetrics', sectionName: 'Market Metrics', isExpanded: true },
            { sectionKey: 'occupancyMetrics', sectionName: 'Occupancy Metrics', isExpanded: true },
            { sectionKey: 'marketClassification', sectionName: 'Market Classification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

