import { Component } from '@angular/core';
import { bigboxretailvwStoreYearEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Store Year') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailvwstoreyear-form',
    templateUrl: './bigboxretailvwstoreyear.form.component.html'
})
export class bigboxretailvwStoreYearFormComponent extends BaseFormComponent {
    public record!: bigboxretailvwStoreYearEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'storeIdentification', sectionName: 'Store Identification', isExpanded: true },
            { sectionKey: 'assessmentPeriod', sectionName: 'Assessment Period', isExpanded: true },
            { sectionKey: 'storeLocation', sectionName: 'Store Location', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'dataQuality', sectionName: 'Data Quality', isExpanded: true },
            { sectionKey: 'assessmentAnalysis', sectionName: 'Assessment Analysis', isExpanded: true },
            { sectionKey: 'assessedValues', sectionName: 'Assessed Values', isExpanded: true },
            { sectionKey: 'dataSource', sectionName: 'Data Source', isExpanded: true },
            { sectionKey: 'financialAnalysis', sectionName: 'Financial Analysis', isExpanded: true },
            { sectionKey: 'financialData', sectionName: 'Financial Data', isExpanded: true },
            { sectionKey: 'burdenShiftAnalysis', sectionName: 'Burden Shift Analysis', isExpanded: true },
            { sectionKey: 'salesData', sectionName: 'Sales Data', isExpanded: true },
            { sectionKey: 'settlementData', sectionName: 'Settlement Data', isExpanded: true }
        ]);
    }
}

