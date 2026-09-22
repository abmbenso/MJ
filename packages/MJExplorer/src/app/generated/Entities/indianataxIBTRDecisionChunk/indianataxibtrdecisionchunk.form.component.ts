import { Component } from '@angular/core';
import { indianataxIBTRDecisionChunkEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'IBTR Decision Chunks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrdecisionchunk-form',
    templateUrl: './indianataxibtrdecisionchunk.form.component.html'
})
export class indianataxIBTRDecisionChunkFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRDecisionChunkEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'decisionReference', sectionName: 'Decision Reference', isExpanded: true },
            { sectionKey: 'chunkOrganization', sectionName: 'Chunk Organization', isExpanded: true },
            { sectionKey: 'chunkContent', sectionName: 'Chunk Content', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

