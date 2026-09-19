import { Component } from '@angular/core';
import { indianataxAppealAnalysisAssumptionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Analysis Assumptions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealanalysisassumption-form',
    templateUrl: './indianataxappealanalysisassumption.form.component.html'
})
export class indianataxAppealAnalysisAssumptionFormComponent extends BaseFormComponent {
    public record!: indianataxAppealAnalysisAssumptionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'analysisContext', sectionName: 'Analysis Context', isExpanded: true },
            { sectionKey: 'assumptionValue', sectionName: 'Assumption Value', isExpanded: true },
            { sectionKey: 'sourceInformation', sectionName: 'Source Information', isExpanded: true },
            { sectionKey: 'proposedChanges', sectionName: 'Proposed Changes', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

