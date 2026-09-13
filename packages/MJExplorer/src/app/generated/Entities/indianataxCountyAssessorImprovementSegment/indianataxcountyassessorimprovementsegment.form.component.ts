import { Component } from '@angular/core';
import { indianataxCountyAssessorImprovementSegmentEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'County Assessor Improvement Segments') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyassessorimprovementsegment-form',
    templateUrl: './indianataxcountyassessorimprovementsegment.form.component.html'
})
export class indianataxCountyAssessorImprovementSegmentFormComponent extends BaseFormComponent {
    public record!: indianataxCountyAssessorImprovementSegmentEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'segmentIdentification', sectionName: 'Segment Identification', isExpanded: true },
            { sectionKey: 'sizeAndAreaCalculation', sectionName: 'Size and Area Calculation', isExpanded: true },
            { sectionKey: 'costAndValuation', sectionName: 'Cost and Valuation', isExpanded: true },
            { sectionKey: 'constructionAndCondition', sectionName: 'Construction and Condition', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

