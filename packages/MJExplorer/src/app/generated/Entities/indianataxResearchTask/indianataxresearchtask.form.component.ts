import { Component } from '@angular/core';
import { indianataxResearchTaskEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Research Tasks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxresearchtask-form',
    templateUrl: './indianataxresearchtask.form.component.html'
})
export class indianataxResearchTaskFormComponent extends BaseFormComponent {
    public record!: indianataxResearchTaskEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'taskIdentity', sectionName: 'Task Identity', isExpanded: true },
            { sectionKey: 'taskLifecycle', sectionName: 'Task Lifecycle', isExpanded: true },
            { sectionKey: 'relatedEntities', sectionName: 'Related Entities', isExpanded: true },
            { sectionKey: 'taskDocumentation', sectionName: 'Task Documentation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

