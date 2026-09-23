import { Component } from '@angular/core';
import { indianataxClientImportEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Client Imports') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclientimport-form',
    templateUrl: './indianataxclientimport.form.component.html'
})
export class indianataxClientImportFormComponent extends BaseFormComponent {
    public record!: indianataxClientImportEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'importSource', sectionName: 'Import Source', isExpanded: true },
            { sectionKey: 'importTimeline', sectionName: 'Import Timeline', isExpanded: true },
            { sectionKey: 'importResults', sectionName: 'Import Results', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

