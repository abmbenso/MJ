import { Component } from '@angular/core';
import { indianataxFairAndAccurateLeadEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Fair And Accurate Leads') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxfairandaccuratelead-form',
    templateUrl: './indianataxfairandaccuratelead.form.component.html'
})
export class indianataxFairAndAccurateLeadFormComponent extends BaseFormComponent {
    public record!: indianataxFairAndAccurateLeadEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'propertyInformation', sectionName: 'Property Information', isExpanded: true },
            { sectionKey: 'visitorContactInformation', sectionName: 'Visitor Contact Information', isExpanded: true },
            { sectionKey: 'leadDetails', sectionName: 'Lead Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

