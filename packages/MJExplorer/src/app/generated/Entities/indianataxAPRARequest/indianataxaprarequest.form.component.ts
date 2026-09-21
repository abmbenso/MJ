import { Component } from '@angular/core';
import { indianataxAPRARequestEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'APRA Requests') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxaprarequest-form',
    templateUrl: './indianataxaprarequest.form.component.html'
})
export class indianataxAPRARequestFormComponent extends BaseFormComponent {
    public record!: indianataxAPRARequestEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'requestIdentification', sectionName: 'Request Identification', isExpanded: true },
            { sectionKey: 'requestStatus', sectionName: 'Request Status', isExpanded: true },
            { sectionKey: 'letterComposition', sectionName: 'Letter Composition', isExpanded: true },
            { sectionKey: 'submissionDetails', sectionName: 'Submission Details', isExpanded: true },
            { sectionKey: 'requestTimeline', sectionName: 'Request Timeline', isExpanded: true },
            { sectionKey: 'countyResponseTimeline', sectionName: 'County Response Timeline', isExpanded: true },
            { sectionKey: 'publicAccessCounselor', sectionName: 'Public Access Counselor', isExpanded: true },
            { sectionKey: 'communicationTracking', sectionName: 'Communication Tracking', isExpanded: true },
            { sectionKey: 'requestManagement', sectionName: 'Request Management', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'aPRAResponseFiles', sectionName: 'APRA Response Files', isExpanded: false },
            { sectionKey: 'aPRARequestEvents', sectionName: 'APRA Request Events', isExpanded: false }
        ]);
    }
}

