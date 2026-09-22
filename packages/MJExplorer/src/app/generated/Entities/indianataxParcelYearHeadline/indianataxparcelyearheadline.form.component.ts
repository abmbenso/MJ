import { Component } from '@angular/core';
import { indianataxParcelYearHeadlineEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Parcel Year Headlines') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxparcelyearheadline-form',
    templateUrl: './indianataxparcelyearheadline.form.component.html'
})
export class indianataxParcelYearHeadlineFormComponent extends BaseFormComponent {
    public record!: indianataxParcelYearHeadlineEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'assessedValues', sectionName: 'Assessed Values', isExpanded: true },
            { sectionKey: 'sourceTracking', sectionName: 'Source Tracking', isExpanded: true },
            { sectionKey: 'dataQuality', sectionName: 'Data Quality', isExpanded: true },
            { sectionKey: 'taxInformation', sectionName: 'Tax Information', isExpanded: true },
            { sectionKey: 'processingMetadata', sectionName: 'Processing Metadata', isExpanded: false },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

