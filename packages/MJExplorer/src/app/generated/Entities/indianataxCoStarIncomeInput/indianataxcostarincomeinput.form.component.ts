import { Component } from '@angular/core';
import { indianataxCoStarIncomeInputEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Co Star Income Inputs') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcostarincomeinput-form',
    templateUrl: './indianataxcostarincomeinput.form.component.html'
})
export class indianataxCoStarIncomeInputFormComponent extends BaseFormComponent {
    public record!: indianataxCoStarIncomeInputEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyIdentification', sectionName: 'Property Identification', isExpanded: true },
            { sectionKey: 'propertyDetails', sectionName: 'Property Details', isExpanded: true },
            { sectionKey: 'physicalCharacteristics', sectionName: 'Physical Characteristics', isExpanded: true },
            { sectionKey: 'incomeMetrics', sectionName: 'Income Metrics', isExpanded: true },
            { sectionKey: 'occupancyAndConcessions', sectionName: 'Occupancy and Concessions', isExpanded: true },
            { sectionKey: 'financialInformation', sectionName: 'Financial Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

