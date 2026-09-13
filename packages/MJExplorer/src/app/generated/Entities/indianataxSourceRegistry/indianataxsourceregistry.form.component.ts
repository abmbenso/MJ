import { Component } from '@angular/core';
import { indianataxSourceRegistryEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Source Registries') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsourceregistry-form',
    templateUrl: './indianataxsourceregistry.form.component.html'
})
export class indianataxSourceRegistryFormComponent extends BaseFormComponent {
    public record!: indianataxSourceRegistryEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'documentCatalogs', sectionName: 'Document Catalogs', isExpanded: false },
            { sectionKey: 'countyResources', sectionName: 'County Resources', isExpanded: false },
            { sectionKey: 'parcels', sectionName: 'Parcels', isExpanded: false },
            { sectionKey: 'researchTasks', sectionName: 'Research Tasks', isExpanded: false },
            { sectionKey: 'countyAssessorRecords', sectionName: 'County Assessor Records', isExpanded: false }
        ]);
    }
}

