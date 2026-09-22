import { Component } from '@angular/core';
import { indianataxDocumentCatalogEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Document Catalogs') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdocumentcatalog-form',
    templateUrl: './indianataxdocumentcatalog.form.component.html'
})
export class indianataxDocumentCatalogFormComponent extends BaseFormComponent {
    public record!: indianataxDocumentCatalogEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'documentIdentification', sectionName: 'Document Identification', isExpanded: true },
            { sectionKey: 'documentTimeline', sectionName: 'Document Timeline', isExpanded: true },
            { sectionKey: 'relevanceAssessment', sectionName: 'Relevance Assessment', isExpanded: true },
            { sectionKey: 'ingestionStatus', sectionName: 'Ingestion Status', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

