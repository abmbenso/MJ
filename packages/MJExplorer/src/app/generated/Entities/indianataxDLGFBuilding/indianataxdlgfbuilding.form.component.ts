import { Component } from '@angular/core';
import { indianataxDLGFBuildingEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'DLGF Buildings') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdlgfbuilding-form',
    templateUrl: './indianataxdlgfbuilding.form.component.html'
})
export class indianataxDLGFBuildingFormComponent extends BaseFormComponent {
    public record!: indianataxDLGFBuildingEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'buildingIdentification', sectionName: 'Building Identification', isExpanded: true },
            { sectionKey: 'dataSource', sectionName: 'Data Source', isExpanded: true },
            { sectionKey: 'buildingClassification', sectionName: 'Building Classification', isExpanded: true },
            { sectionKey: 'buildingCharacteristics', sectionName: 'Building Characteristics', isExpanded: true },
            { sectionKey: 'valuationComponents', sectionName: 'Valuation Components', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

