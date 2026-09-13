import { Component } from '@angular/core';
import { bigboxretailStoreEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Stores') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailstore-form',
    templateUrl: './bigboxretailstore.form.component.html'
})
export class bigboxretailStoreFormComponent extends BaseFormComponent {
    public record!: bigboxretailStoreEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'storeIdentification', sectionName: 'Store Identification', isExpanded: true },
            { sectionKey: 'storeLocation', sectionName: 'Store Location', isExpanded: true },
            { sectionKey: 'dataSourceAndMatching', sectionName: 'Data Source and Matching', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'taxAssessmentAppeals', sectionName: 'Tax Assessment Appeals', isExpanded: true },
            { sectionKey: 'propertyCharacteristics', sectionName: 'Property Characteristics', isExpanded: true },
            { sectionKey: 'assessmentAnalysis', sectionName: 'Assessment Analysis', isExpanded: true },
            { sectionKey: 'recordManagement', sectionName: 'Record Management', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'storeAssessments', sectionName: 'Store Assessments', isExpanded: false },
            { sectionKey: 'storeTaxes', sectionName: 'Store Taxes', isExpanded: false },
            { sectionKey: 'parcelSettlements', sectionName: 'Parcel Settlements', isExpanded: false },
            { sectionKey: 'parcelTransfers', sectionName: 'Parcel Transfers', isExpanded: false },
            { sectionKey: 'parcelBurdenShifts', sectionName: 'Parcel Burden Shifts', isExpanded: false },
            { sectionKey: 'storeYear', sectionName: 'Store Year', isExpanded: false }
        ]);
    }
}

