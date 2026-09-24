import { Component } from '@angular/core';
import { indianataxAppealOutcomeEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Outcomes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealoutcome-form',
    templateUrl: './indianataxappealoutcome.form.component.html'
})
export class indianataxAppealOutcomeFormComponent extends BaseFormComponent {
    public record!: indianataxAppealOutcomeEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'appealReference', sectionName: 'Appeal Reference', isExpanded: true },
            { sectionKey: 'appealDetails', sectionName: 'Appeal Details', isExpanded: true },
            { sectionKey: 'valuationDetails', sectionName: 'Valuation Details', isExpanded: true },
            { sectionKey: 'appealTimeline', sectionName: 'Appeal Timeline', isExpanded: true },
            { sectionKey: 'sourceInformation', sectionName: 'Source Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

