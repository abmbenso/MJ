import { Component } from '@angular/core';
import { bigboxretailStoreTaxEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Store Taxes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailstoretax-form',
    templateUrl: './bigboxretailstoretax.form.component.html'
})
export class bigboxretailStoreTaxFormComponent extends BaseFormComponent {
    public record!: bigboxretailStoreTaxEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'storeAndAssessmentInformation', sectionName: 'Store and Assessment Information', isExpanded: true },
            { sectionKey: 'taxInstallmentsAndAmounts', sectionName: 'Tax Installments and Amounts', isExpanded: true },
            { sectionKey: 'taxRatesAndAssessment', sectionName: 'Tax Rates and Assessment', isExpanded: true },
            { sectionKey: 'dataSourceAndTracking', sectionName: 'Data Source and Tracking', isExpanded: true },
            { sectionKey: 'parcelCoverageAndCompleteness', sectionName: 'Parcel Coverage and Completeness', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

