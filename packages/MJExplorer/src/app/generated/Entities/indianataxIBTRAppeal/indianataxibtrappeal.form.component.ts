import { Component } from '@angular/core';
import { indianataxIBTRAppealEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'IBTR Appeals') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrappeal-form',
    templateUrl: './indianataxibtrappeal.form.component.html'
})
export class indianataxIBTRAppealFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRAppealEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'appealDocketInformation', sectionName: 'Appeal Docket Information', isExpanded: true },
            { sectionKey: 'petitionerInformation', sectionName: 'Petitioner Information', isExpanded: true },
            { sectionKey: 'propertyLocation', sectionName: 'Property Location', isExpanded: true },
            { sectionKey: 'propertyInformation', sectionName: 'Property Information', isExpanded: true },
            { sectionKey: 'appealDetails', sectionName: 'Appeal Details', isExpanded: true },
            { sectionKey: 'appealTimeline', sectionName: 'Appeal Timeline', isExpanded: true },
            { sectionKey: 'appealOutcome', sectionName: 'Appeal Outcome', isExpanded: true },
            { sectionKey: 'hearingInformation', sectionName: 'Hearing Information', isExpanded: true },
            { sectionKey: 'decisionContent', sectionName: 'Decision Content', isExpanded: true },
            { sectionKey: 'decisionDocument', sectionName: 'Decision Document', isExpanded: true },
            { sectionKey: 'decisionProcessing', sectionName: 'Decision Processing', isExpanded: true },
            { sectionKey: 'propertyClassification', sectionName: 'Property Classification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'iBTRDecisionCitations', sectionName: 'IBTR Decision Citations', isExpanded: false },
            { sectionKey: 'iBTRDecisionHoldings', sectionName: 'IBTR Decision Holdings', isExpanded: false },
            { sectionKey: 'iBTRDecisionIssues', sectionName: 'IBTR Decision Issues', isExpanded: false },
            { sectionKey: 'iBTRDecisionParties', sectionName: 'IBTR Decision Parties', isExpanded: false },
            { sectionKey: 'iBTRDecisionChunks', sectionName: 'IBTR Decision Chunks', isExpanded: false },
            { sectionKey: 'taxCourtIBTRLinks', sectionName: 'Tax Court IBTR Links', isExpanded: false },
            { sectionKey: 'clientAppeals', sectionName: 'Client Appeals', isExpanded: false },
            { sectionKey: 'appealOutcomes', sectionName: 'Appeal Outcomes', isExpanded: false }
        ]);
    }
}

