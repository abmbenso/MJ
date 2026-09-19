import { Component } from '@angular/core';
import { indianataxProspectTaskEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Prospect Tasks') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospecttask-form',
    templateUrl: './indianataxprospecttask.form.component.html'
})
export class indianataxProspectTaskFormComponent extends BaseFormComponent {
    public record!: indianataxProspectTaskEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'taskDetails', sectionName: 'Task Details', isExpanded: true },
            { sectionKey: 'taskTimeline', sectionName: 'Task Timeline', isExpanded: true },
            { sectionKey: 'taskAssignment', sectionName: 'Task Assignment', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

