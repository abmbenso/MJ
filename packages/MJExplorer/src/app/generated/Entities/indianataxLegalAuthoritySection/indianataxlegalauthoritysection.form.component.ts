import { Component } from '@angular/core';
import { indianataxLegalAuthoritySectionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Legal Authority Sections') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxlegalauthoritysection-form',
    templateUrl: './indianataxlegalauthoritysection.form.component.html'
})
export class indianataxLegalAuthoritySectionFormComponent extends BaseFormComponent {
    public record!: indianataxLegalAuthoritySectionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'documentHierarchy', sectionName: 'Document Hierarchy', isExpanded: true },
            { sectionKey: 'sectionClassification', sectionName: 'Section Classification', isExpanded: true },
            { sectionKey: 'sectionContent', sectionName: 'Section Content', isExpanded: true },
            { sectionKey: 'sourceInformation', sectionName: 'Source Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'legalAuthorityChunks', sectionName: 'Legal Authority Chunks', isExpanded: false },
            { sectionKey: 'iBTRDecisionCitations', sectionName: 'IBTR Decision Citations', isExpanded: false },
            { sectionKey: 'legalAuthoritySections', sectionName: 'Legal Authority Sections', isExpanded: false }
        ]);
    }
}

