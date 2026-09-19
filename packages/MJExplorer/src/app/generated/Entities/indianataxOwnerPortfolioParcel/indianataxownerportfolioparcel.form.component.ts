import { Component } from '@angular/core';
import { indianataxOwnerPortfolioParcelEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Owner Portfolio Parcels') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxownerportfolioparcel-form',
    templateUrl: './indianataxownerportfolioparcel.form.component.html'
})
export class indianataxOwnerPortfolioParcelFormComponent extends BaseFormComponent {
    public record!: indianataxOwnerPortfolioParcelEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'parcelLocation', sectionName: 'Parcel Location', isExpanded: true },
            { sectionKey: 'assessedValues', sectionName: 'Assessed Values', isExpanded: true },
            { sectionKey: 'valuationAnalysis', sectionName: 'Valuation Analysis', isExpanded: true },
            { sectionKey: 'appealRecommendation', sectionName: 'Appeal Recommendation', isExpanded: true },
            { sectionKey: 'appealHistory', sectionName: 'Appeal History', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

