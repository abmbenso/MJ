import { Component } from '@angular/core';
import { indianataxTaxCourtCaseEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Tax Court Cases') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxtaxcourtcase-form',
    templateUrl: './indianataxtaxcourtcase.form.component.html'
})
export class indianataxTaxCourtCaseFormComponent extends BaseFormComponent {
    public record!: indianataxTaxCourtCaseEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'caseIdentification', sectionName: 'Case Identification', isExpanded: true },
            { sectionKey: 'caseTimeline', sectionName: 'Case Timeline', isExpanded: true },
            { sectionKey: 'caseClassification', sectionName: 'Case Classification', isExpanded: true },
            { sectionKey: 'caseDecisions', sectionName: 'Case Decisions', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'taxCourtIBTRLinks', sectionName: 'Tax Court IBTR Links', isExpanded: false }
        ]);
    }
}

