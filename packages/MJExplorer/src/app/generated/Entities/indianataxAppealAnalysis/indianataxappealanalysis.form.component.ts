import { Component } from '@angular/core';
import { indianataxAppealAnalysisEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Appeal Analysis') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealanalysis-form',
    templateUrl: './indianataxappealanalysis.form.component.html'
})
export class indianataxAppealAnalysisFormComponent extends BaseFormComponent {
    public record!: indianataxAppealAnalysisEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'subjectProperty', sectionName: 'Subject Property', isExpanded: true },
            { sectionKey: 'analysisStatus', sectionName: 'Analysis Status', isExpanded: true },
            { sectionKey: 'propertyValuation', sectionName: 'Property Valuation', isExpanded: true },
            { sectionKey: 'appealAnalysis', sectionName: 'Appeal Analysis', isExpanded: true },
            { sectionKey: 'financialImpact', sectionName: 'Financial Impact', isExpanded: true },
            { sectionKey: 'relatedAnalysis', sectionName: 'Related Analysis', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'appealAnalysisAssumptions', sectionName: 'Appeal Analysis Assumptions', isExpanded: false },
            { sectionKey: 'appealAnalysisIndications', sectionName: 'Appeal Analysis Indications', isExpanded: false },
            { sectionKey: 'appealAnalysisCompDecisions', sectionName: 'Appeal Analysis Comp Decisions', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false }
        ]);
    }
}

