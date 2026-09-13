import { Component } from '@angular/core';
import { indianataxMarketAssumptionEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Market Assumptions') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxmarketassumption-form',
    templateUrl: './indianataxmarketassumption.form.component.html'
})
export class indianataxMarketAssumptionFormComponent extends BaseFormComponent {
    public record!: indianataxMarketAssumptionEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'assumptionDetails', sectionName: 'Assumption Details', isExpanded: true },
            { sectionKey: 'timePeriod', sectionName: 'Time Period', isExpanded: true },
            { sectionKey: 'assumptionValues', sectionName: 'Assumption Values', isExpanded: true },
            { sectionKey: 'sourceAndDerivation', sectionName: 'Source and Derivation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

