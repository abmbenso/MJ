import { Component } from '@angular/core';
import { indianataxIBTRDecisionIssueEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'IBTR Decision Issues') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrdecisionissue-form',
    templateUrl: './indianataxibtrdecisionissue.form.component.html'
})
export class indianataxIBTRDecisionIssueFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRDecisionIssueEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'decisionReference', sectionName: 'Decision Reference', isExpanded: true },
            { sectionKey: 'issueClassification', sectionName: 'Issue Classification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

