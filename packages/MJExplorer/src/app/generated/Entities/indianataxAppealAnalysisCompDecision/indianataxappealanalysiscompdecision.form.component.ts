import { Component } from '@angular/core';
import { indianataxAppealAnalysisCompDecisionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Analysis Comp Decisions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealanalysiscompdecision-form',
    templateUrl: './indianataxappealanalysiscompdecision.form.component.html'
})
export class indianataxAppealAnalysisCompDecisionFormComponent extends BaseFormComponent {
    public record!: indianataxAppealAnalysisCompDecisionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'analysisReference', sectionName: 'Analysis Reference', isExpanded: true },
            { sectionKey: 'decisionSettings', sectionName: 'Decision Settings', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

