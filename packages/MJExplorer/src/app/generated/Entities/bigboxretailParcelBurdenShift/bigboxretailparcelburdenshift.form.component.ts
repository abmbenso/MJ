import { Component } from '@angular/core';
import { bigboxretailParcelBurdenShiftEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Parcel Burden Shifts') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailparcelburdenshift-form',
    templateUrl: './bigboxretailparcelburdenshift.form.component.html'
})
export class bigboxretailParcelBurdenShiftFormComponent extends BaseFormComponent {
    public record!: bigboxretailParcelBurdenShiftEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelAssessmentOverview', sectionName: 'Parcel Assessment Overview', isExpanded: true },
            { sectionKey: 'assessedValueAnalysis', sectionName: 'Assessed Value Analysis', isExpanded: true },
            { sectionKey: 'burdenShiftAssessment', sectionName: 'Burden Shift Assessment', isExpanded: true },
            { sectionKey: 'perSquareFootAnalysis', sectionName: 'Per-Square-Foot Analysis', isExpanded: true },
            { sectionKey: 'settlementHistory', sectionName: 'Settlement History', isExpanded: true },
            { sectionKey: 'caseDocumentation', sectionName: 'Case Documentation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

