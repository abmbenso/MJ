import { Component } from '@angular/core';
import { indianataxAPRARequestEventEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'APRA Request Events') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxaprarequestevent-form',
    templateUrl: './indianataxaprarequestevent.form.component.html'
})
export class indianataxAPRARequestEventFormComponent extends BaseFormComponent {
    public record!: indianataxAPRARequestEventEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'requestReference', sectionName: 'Request Reference', isExpanded: true },
            { sectionKey: 'eventTimeline', sectionName: 'Event Timeline', isExpanded: true },
            { sectionKey: 'eventDetails', sectionName: 'Event Details', isExpanded: true },
            { sectionKey: 'sourceDocument', sectionName: 'Source Document', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

