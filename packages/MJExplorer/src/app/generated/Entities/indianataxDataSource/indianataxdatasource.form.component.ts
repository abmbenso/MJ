import { Component } from '@angular/core';
import { indianataxDataSourceEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Data Sources') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdatasource-form',
    templateUrl: './indianataxdatasource.form.component.html'
})
export class indianataxDataSourceFormComponent extends BaseFormComponent {
    public record!: indianataxDataSourceEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'sourceIdentification', sectionName: 'Source Identification', isExpanded: true },
            { sectionKey: 'sourceClassification', sectionName: 'Source Classification', isExpanded: true },
            { sectionKey: 'sourceAuthority', sectionName: 'Source Authority', isExpanded: true },
            { sectionKey: 'sourceScope', sectionName: 'Source Scope', isExpanded: true },
            { sectionKey: 'sourceDetails', sectionName: 'Source Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'sourceDocuments', sectionName: 'Source Documents', isExpanded: false },
            { sectionKey: 'parcelYearHeadlinesTaxDataSourceID', sectionName: 'Parcel Year Headlines (Tax Data Source)', isExpanded: false },
            { sectionKey: 'parcelYearHeadlinesHeadlineDataSourceID', sectionName: 'Parcel Year Headlines (Headline Data Source)', isExpanded: false }
        ]);
    }
}

