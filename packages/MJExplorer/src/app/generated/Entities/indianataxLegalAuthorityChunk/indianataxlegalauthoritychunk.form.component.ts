import { Component } from '@angular/core';
import { indianataxLegalAuthorityChunkEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Legal Authority Chunks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxlegalauthoritychunk-form',
    templateUrl: './indianataxlegalauthoritychunk.form.component.html'
})
export class indianataxLegalAuthorityChunkFormComponent extends BaseFormComponent {
    public record!: indianataxLegalAuthorityChunkEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'chunkSource', sectionName: 'Chunk Source', isExpanded: true },
            { sectionKey: 'chunkContent', sectionName: 'Chunk Content', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

