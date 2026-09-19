import { Component } from '@angular/core';
import { bigboxretailvwStoreAnalysisEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Store Analysis') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailvwstoreanalysis-form',
    templateUrl: './bigboxretailvwstoreanalysis.form.component.html'
})
export class bigboxretailvwStoreAnalysisFormComponent extends BaseFormComponent {
    public record!: bigboxretailvwStoreAnalysisEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'storeIdentification', sectionName: 'Store Identification', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'storeLocation', sectionName: 'Store Location', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'assessmentAnalysis', sectionName: 'Assessment Analysis', isExpanded: true },
            { sectionKey: 'assessedValuesByYear', sectionName: 'Assessed Values by Year', isExpanded: true },
            { sectionKey: 'taxAmountsByYear', sectionName: 'Tax Amounts by Year', isExpanded: true },
            { sectionKey: 'valuationRatiosByYear', sectionName: 'Valuation Ratios by Year', isExpanded: true },
            { sectionKey: 'taxRatiosByYear', sectionName: 'Tax Ratios by Year', isExpanded: true },
            { sectionKey: 'dataProvenance', sectionName: 'Data Provenance', isExpanded: true }
        ]);
    }
}

