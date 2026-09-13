import { Component } from '@angular/core';
import { indianataxCountyResourceEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'County Resources') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyresource-form',
    templateUrl: './indianataxcountyresource.form.component.html'
})
export class indianataxCountyResourceFormComponent extends BaseFormComponent {
    public record!: indianataxCountyResourceEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'resourceIdentification', sectionName: 'Resource Identification', isExpanded: true },
            { sectionKey: 'resourceContact', sectionName: 'Resource Contact', isExpanded: true },
            { sectionKey: 'sourceInformation', sectionName: 'Source Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

