import { Component } from '@angular/core';
import { indianataxLegalAuthorityEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Legal Authorities') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxlegalauthority-form',
    templateUrl: './indianataxlegalauthority.form.component.html'
})
export class indianataxLegalAuthorityFormComponent extends BaseFormComponent {
    public record!: indianataxLegalAuthorityEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'documentIdentity', sectionName: 'Document Identity', isExpanded: true },
            { sectionKey: 'documentClassification', sectionName: 'Document Classification', isExpanded: true },
            { sectionKey: 'documentVersion', sectionName: 'Document Version', isExpanded: true },
            { sectionKey: 'documentSource', sectionName: 'Document Source', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'legalAuthoritySections', sectionName: 'Legal Authority Sections', isExpanded: false }
        ]);
    }
}

