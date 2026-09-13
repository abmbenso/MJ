import { Component } from '@angular/core';
import { indianataxFormCatalogEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Form Catalogs') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxformcatalog-form',
    templateUrl: './indianataxformcatalog.form.component.html'
})
export class indianataxFormCatalogFormComponent extends BaseFormComponent {
    public record!: indianataxFormCatalogEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'formIdentification', sectionName: 'Form Identification', isExpanded: true },
            { sectionKey: 'formDescription', sectionName: 'Form Description', isExpanded: true },
            { sectionKey: 'appealProcessLinks', sectionName: 'Appeal Process Links', isExpanded: true },
            { sectionKey: 'sourceAndVerification', sectionName: 'Source and Verification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

