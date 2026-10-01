import { Component } from '@angular/core';
import { indianataxAppealRecommendationParcelEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Recommendation Parcels') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappealrecommendationparcel-form',
    templateUrl: './indianataxappealrecommendationparcel.form.component.html'
})
export class indianataxAppealRecommendationParcelFormComponent extends BaseFormComponent {
    public record!: indianataxAppealRecommendationParcelEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'allocationDetails', sectionName: 'Allocation Details', isExpanded: true },
            { sectionKey: 'allocationBasis', sectionName: 'Allocation Basis', isExpanded: true },
            { sectionKey: 'allocatedValues', sectionName: 'Allocated Values', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

