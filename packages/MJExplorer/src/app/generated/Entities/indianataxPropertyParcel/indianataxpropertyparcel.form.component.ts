import { Component } from '@angular/core';
import { indianataxPropertyParcelEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Property Parcels') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxpropertyparcel-form',
    templateUrl: './indianataxpropertyparcel.form.component.html'
})
export class indianataxPropertyParcelFormComponent extends BaseFormComponent {
    public record!: indianataxPropertyParcelEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelAssociation', sectionName: 'Parcel Association', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

