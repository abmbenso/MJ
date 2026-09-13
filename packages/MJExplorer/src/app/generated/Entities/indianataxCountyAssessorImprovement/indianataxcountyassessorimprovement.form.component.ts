import { Component } from '@angular/core';
import { indianataxCountyAssessorImprovementEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'County Assessor Improvements') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyassessorimprovement-form',
    templateUrl: './indianataxcountyassessorimprovement.form.component.html'
})
export class indianataxCountyAssessorImprovementFormComponent extends BaseFormComponent {
    public record!: indianataxCountyAssessorImprovementEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyReference', sectionName: 'Property Reference', isExpanded: true },
            { sectionKey: 'structureCharacteristics', sectionName: 'Structure Characteristics', isExpanded: true },
            { sectionKey: 'structureMeasurements', sectionName: 'Structure Measurements', isExpanded: true },
            { sectionKey: 'assessmentValuation', sectionName: 'Assessment Valuation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

