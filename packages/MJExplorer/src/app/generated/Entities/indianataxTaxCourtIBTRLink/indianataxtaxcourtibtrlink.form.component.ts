import { Component } from '@angular/core';
import { indianataxTaxCourtIBTRLinkEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Tax Court IBTR Links') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxtaxcourtibtrlink-form',
    templateUrl: './indianataxtaxcourtibtrlink.form.component.html'
})
export class indianataxTaxCourtIBTRLinkFormComponent extends BaseFormComponent {
    public record!: indianataxTaxCourtIBTRLinkEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'linkRelationships', sectionName: 'Link Relationships', isExpanded: true },
            { sectionKey: 'matchQuality', sectionName: 'Match Quality', isExpanded: true },
            { sectionKey: 'confirmationStatus', sectionName: 'Confirmation Status', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

