import { Component } from '@angular/core';
import { indianataxAppealStageStatuteEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Stage Statutes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealstagestatute-form',
    templateUrl: './indianataxappealstagestatute.form.component.html'
})
export class indianataxAppealStageStatuteFormComponent extends BaseFormComponent {
    public record!: indianataxAppealStageStatuteEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'statuteCitationDetails', sectionName: 'Statute Citation Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

