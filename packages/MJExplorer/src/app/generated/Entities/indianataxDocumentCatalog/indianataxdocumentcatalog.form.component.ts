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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

