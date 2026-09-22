import { Component } from '@angular/core';
import { indianataxClientTaskEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Client Tasks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclienttask-form',
    templateUrl: './indianataxclienttask.form.component.html'
})
export class indianataxClientTaskFormComponent extends BaseFormComponent {
    public record!: indianataxClientTaskEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'taskAssignment', sectionName: 'Task Assignment', isExpanded: true },
            { sectionKey: 'taskContext', sectionName: 'Task Context', isExpanded: true },
            { sectionKey: 'taskDetails', sectionName: 'Task Details', isExpanded: true },
            { sectionKey: 'taskTimeline', sectionName: 'Task Timeline', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

