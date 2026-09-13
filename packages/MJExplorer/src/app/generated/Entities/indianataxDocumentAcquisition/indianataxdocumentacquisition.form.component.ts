import { Component } from '@angular/core';
import { indianataxDocumentAcquisitionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Document Acquisitions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdocumentacquisition-form',
    templateUrl: './indianataxdocumentacquisition.form.component.html'
})
export class indianataxDocumentAcquisitionFormComponent extends BaseFormComponent {
    public record!: indianataxDocumentAcquisitionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'acquisitionTarget', sectionName: 'Acquisition Target', isExpanded: true },
            { sectionKey: 'acquisitionStatus', sectionName: 'Acquisition Status', isExpanded: true },
            { sectionKey: 'acquisitionTimeline', sectionName: 'Acquisition Timeline', isExpanded: true },
            { sectionKey: 'errorInformation', sectionName: 'Error Information', isExpanded: true },
            { sectionKey: 'acquisitionResult', sectionName: 'Acquisition Result', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

