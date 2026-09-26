import { Component } from '@angular/core';
import { indianataxParcelIndexEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Parcel Indexes') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxparcelindex-form',
    templateUrl: './indianataxparcelindex.form.component.html'
})
export class indianataxParcelIndexFormComponent extends BaseFormComponent {
    public record!: indianataxParcelIndexEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'propertyLocation', sectionName: 'Property Location', isExpanded: true },
            { sectionKey: 'propertyClassification', sectionName: 'Property Classification', isExpanded: true },
            { sectionKey: 'taxpayerInformation', sectionName: 'Taxpayer Information', isExpanded: true },
            { sectionKey: 'assessmentValues', sectionName: 'Assessment Values', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

