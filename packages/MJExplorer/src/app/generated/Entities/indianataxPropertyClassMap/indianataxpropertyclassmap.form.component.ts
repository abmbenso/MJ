import { Component } from '@angular/core';
import { indianataxPropertyClassMapEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Property Class Maps') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxpropertyclassmap-form',
    templateUrl: './indianataxpropertyclassmap.form.component.html'
})
export class indianataxPropertyClassMapFormComponent extends BaseFormComponent {
    public record!: indianataxPropertyClassMapEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyClassification', sectionName: 'Property Classification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

