import { Component } from '@angular/core';
import { indianataxDLGFLandEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'DLGF Lands') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdlgfland-form',
    templateUrl: './indianataxdlgfland.form.component.html'
})
export class indianataxDLGFLandFormComponent extends BaseFormComponent {
    public record!: indianataxDLGFLandEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'landSegmentIdentification', sectionName: 'Land Segment Identification', isExpanded: true },
            { sectionKey: 'physicalDimensions', sectionName: 'Physical Dimensions', isExpanded: true },
            { sectionKey: 'valuationAndAssessment', sectionName: 'Valuation and Assessment', isExpanded: true },
            { sectionKey: 'soilAndLandQuality', sectionName: 'Soil and Land Quality', isExpanded: true },
            { sectionKey: 'valuationAdjustments', sectionName: 'Valuation Adjustments', isExpanded: true },
            { sectionKey: 'assessmentValueCaps', sectionName: 'Assessment Value Caps', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

