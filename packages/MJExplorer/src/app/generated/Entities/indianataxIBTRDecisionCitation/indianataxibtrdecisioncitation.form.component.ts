import { Component } from '@angular/core';
import { indianataxIBTRDecisionCitationEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'IBTR Decision Citations') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrdecisioncitation-form',
    templateUrl: './indianataxibtrdecisioncitation.form.component.html'
})
export class indianataxIBTRDecisionCitationFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRDecisionCitationEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'citationIdentification', sectionName: 'Citation Identification', isExpanded: true },
            { sectionKey: 'authorityDetails', sectionName: 'Authority Details', isExpanded: true },
            { sectionKey: 'citationMetrics', sectionName: 'Citation Metrics', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

