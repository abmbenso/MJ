import { Component } from '@angular/core';
import { indianataxCardSummaryEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Card Summaries') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcardsummary-form',
    templateUrl: './indianataxcardsummary.form.component.html'
})
export class indianataxCardSummaryFormComponent extends BaseFormComponent {
    public record!: indianataxCardSummaryEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'cardIdentification', sectionName: 'Card Identification', isExpanded: true },
            { sectionKey: 'propertyClassification', sectionName: 'Property Classification', isExpanded: true },
            { sectionKey: 'ownershipInformation', sectionName: 'Ownership Information', isExpanded: true },
            { sectionKey: 'landDetails', sectionName: 'Land Details', isExpanded: true },
            { sectionKey: 'improvementMeasurements', sectionName: 'Improvement Measurements', isExpanded: true },
            { sectionKey: 'buildingHistory', sectionName: 'Building History', isExpanded: true },
            { sectionKey: 'improvementSummaries', sectionName: 'Improvement Summaries', isExpanded: true },
            { sectionKey: 'valuationDetails', sectionName: 'Valuation Details', isExpanded: true },
            { sectionKey: 'cardAdministration', sectionName: 'Card Administration', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

