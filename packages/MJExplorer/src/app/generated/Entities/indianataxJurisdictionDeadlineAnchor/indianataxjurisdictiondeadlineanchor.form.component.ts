import { Component } from '@angular/core';
import { indianataxJurisdictionDeadlineAnchorEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Jurisdiction Deadline Anchors') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxjurisdictiondeadlineanchor-form',
    templateUrl: './indianataxjurisdictiondeadlineanchor.form.component.html'
})
export class indianataxJurisdictionDeadlineAnchorFormComponent extends BaseFormComponent {
    public record!: indianataxJurisdictionDeadlineAnchorEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'jurisdictionAndTimeline', sectionName: 'Jurisdiction and Timeline', isExpanded: true },
            { sectionKey: 'anchorDetails', sectionName: 'Anchor Details', isExpanded: true },
            { sectionKey: 'sourceAndNotes', sectionName: 'Source and Notes', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

