import { Component } from '@angular/core';
import { indianataxBoardDecisionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Board Decisions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxboarddecision-form',
    templateUrl: './indianataxboarddecision.form.component.html'
})
export class indianataxBoardDecisionFormComponent extends BaseFormComponent {
    public record!: indianataxBoardDecisionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'caseIdentification', sectionName: 'Case Identification', isExpanded: true },
            { sectionKey: 'caseParties', sectionName: 'Case Parties', isExpanded: true },
            { sectionKey: 'caseLocation', sectionName: 'Case Location', isExpanded: true },
            { sectionKey: 'caseSubject', sectionName: 'Case Subject', isExpanded: true },
            { sectionKey: 'decisionTimeline', sectionName: 'Decision Timeline', isExpanded: true },
            { sectionKey: 'decisionDetails', sectionName: 'Decision Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'iBTRAppeals', sectionName: 'IBTR Appeals', isExpanded: false }
        ]);
    }
}

