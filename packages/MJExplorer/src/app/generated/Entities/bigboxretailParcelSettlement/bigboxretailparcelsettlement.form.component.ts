import { Component } from '@angular/core';
import { bigboxretailParcelSettlementEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Parcel Settlements') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-bigboxretailparcelsettlement-form',
    templateUrl: './bigboxretailparcelsettlement.form.component.html'
})
export class bigboxretailParcelSettlementFormComponent extends BaseFormComponent {
    public record!: bigboxretailParcelSettlementEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'settlementIdentification', sectionName: 'Settlement Identification', isExpanded: true },
            { sectionKey: 'settlementValues', sectionName: 'Settlement Values', isExpanded: true },
            { sectionKey: 'settlementDocumentation', sectionName: 'Settlement Documentation', isExpanded: true },
            { sectionKey: 'settlementContext', sectionName: 'Settlement Context', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

