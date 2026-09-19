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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'iBTRDecisionCitations', sectionName: 'IBTR Decision Citations', isExpanded: false },
            { sectionKey: 'iBTRDecisionHoldings', sectionName: 'IBTR Decision Holdings', isExpanded: false },
            { sectionKey: 'iBTRDecisionIssues', sectionName: 'IBTR Decision Issues', isExpanded: false },
            { sectionKey: 'iBTRDecisionParties', sectionName: 'IBTR Decision Parties', isExpanded: false },
            { sectionKey: 'iBTRDecisionChunks', sectionName: 'IBTR Decision Chunks', isExpanded: false }
        ]);
    }
}

