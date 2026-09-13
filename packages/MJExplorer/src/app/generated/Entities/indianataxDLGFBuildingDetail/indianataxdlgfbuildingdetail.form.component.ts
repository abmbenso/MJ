import { Component } from '@angular/core';
import { indianataxDLGFBuildingDetailEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'DLGF Building Details') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxdlgfbuildingdetail-form',
    templateUrl: './indianataxdlgfbuildingdetail.form.component.html'
})
export class indianataxDLGFBuildingDetailFormComponent extends BaseFormComponent {
    public record!: indianataxDLGFBuildingDetailEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'buildingIdentification', sectionName: 'Building Identification', isExpanded: true },
            { sectionKey: 'sectionAndFloorDetails', sectionName: 'Section and Floor Details', isExpanded: true },
            { sectionKey: 'pricingDetails', sectionName: 'Pricing Details', isExpanded: true },
            { sectionKey: 'buildingCharacteristics', sectionName: 'Building Characteristics', isExpanded: true },
            { sectionKey: 'valueAdjustments', sectionName: 'Value Adjustments', isExpanded: true },
            { sectionKey: 'unitConfiguration', sectionName: 'Unit Configuration', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

