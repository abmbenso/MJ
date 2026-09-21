import { Component } from '@angular/core';
import { indianataxAPRAResponseFileEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'APRA Response Files') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxapraresponsefile-form',
    templateUrl: './indianataxapraresponsefile.form.component.html'
})
export class indianataxAPRAResponseFileFormComponent extends BaseFormComponent {
    public record!: indianataxAPRAResponseFileEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'fileIdentification', sectionName: 'File Identification', isExpanded: true },
            { sectionKey: 'fileDetails', sectionName: 'File Details', isExpanded: true },
            { sectionKey: 'processingStatus', sectionName: 'Processing Status', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

