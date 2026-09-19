import { Component } from '@angular/core';
import { indianataxCardImprovementEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Card Improvements') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcardimprovement-form',
    templateUrl: './indianataxcardimprovement.form.component.html'
})
export class indianataxCardImprovementFormComponent extends BaseFormComponent {
    public record!: indianataxCardImprovementEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assessmentInformation', sectionName: 'Assessment Information', isExpanded: true },
            { sectionKey: 'improvementDetails', sectionName: 'Improvement Details', isExpanded: true },
            { sectionKey: 'constructionAndCondition', sectionName: 'Construction and Condition', isExpanded: true },
            { sectionKey: 'ageAndDepreciation', sectionName: 'Age and Depreciation', isExpanded: true },
            { sectionKey: 'sizeAndDimensions', sectionName: 'Size and Dimensions', isExpanded: true },
            { sectionKey: 'valuationFactors', sectionName: 'Valuation Factors', isExpanded: true },
            { sectionKey: 'depreciationAndAdjustments', sectionName: 'Depreciation and Adjustments', isExpanded: true },
            { sectionKey: 'marketAdjustments', sectionName: 'Market Adjustments', isExpanded: true },
            { sectionKey: 'assessedValueCaps', sectionName: 'Assessed Value Caps', isExpanded: true },
            { sectionKey: 'finalAssessmentValue', sectionName: 'Final Assessment Value', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

