import { Component } from '@angular/core';
import { indianataxProspectParcelEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Prospect Parcels') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospectparcel-form',
    templateUrl: './indianataxprospectparcel.form.component.html'
})
export class indianataxProspectParcelFormComponent extends BaseFormComponent {
    public record!: indianataxProspectParcelEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'prospectAssociation', sectionName: 'Prospect Association', isExpanded: true },
            { sectionKey: 'parcelStatus', sectionName: 'Parcel Status', isExpanded: true },
            { sectionKey: 'parcelDetails', sectionName: 'Parcel Details', isExpanded: true },
            { sectionKey: 'parcelValuation', sectionName: 'Parcel Valuation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

