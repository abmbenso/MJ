import { Component } from '@angular/core';
import { indianataxClientAuthorizationEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Client Authorizations') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxclientauthorization-form',
    templateUrl: './indianataxclientauthorization.form.component.html'
})
export class indianataxClientAuthorizationFormComponent extends BaseFormComponent {
    public record!: indianataxClientAuthorizationEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'authorizationDetails', sectionName: 'Authorization Details', isExpanded: true },
            { sectionKey: 'authorizationTimeline', sectionName: 'Authorization Timeline', isExpanded: true },
            { sectionKey: 'relatedInformation', sectionName: 'Related Information', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

