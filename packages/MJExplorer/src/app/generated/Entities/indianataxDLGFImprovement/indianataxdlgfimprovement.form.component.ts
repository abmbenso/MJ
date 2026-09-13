import { Component } from '@angular/core';
import { indianataxDLGFImprovementEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'DLGF Improvements') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdlgfimprovement-form',
    templateUrl: './indianataxdlgfimprovement.form.component.html'
})
export class indianataxDLGFImprovementFormComponent extends BaseFormComponent {
    public record!: indianataxDLGFImprovementEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'improvementIdentification', sectionName: 'Improvement Identification', isExpanded: true },
            { sectionKey: 'physicalCharacteristics', sectionName: 'Physical Characteristics', isExpanded: true },
            { sectionKey: 'constructionHistory', sectionName: 'Construction History', isExpanded: true },
            { sectionKey: 'conditionAndQuality', sectionName: 'Condition and Quality', isExpanded: true },
            { sectionKey: 'locationContext', sectionName: 'Location Context', isExpanded: true },
            { sectionKey: 'valuationAndDepreciation', sectionName: 'Valuation and Depreciation', isExpanded: true },
            { sectionKey: 'assessmentCapAllocation', sectionName: 'Assessment Cap Allocation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

