import { Component } from '@angular/core';
import { indianataxAppealLeadEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Appeal Leads') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxappeallead-form',
    templateUrl: './indianataxappeallead.form.component.html'
})
export class indianataxAppealLeadFormComponent extends BaseFormComponent {
    public record!: indianataxAppealLeadEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'parcelIdentification', sectionName: 'Parcel Identification', isExpanded: true },
            { sectionKey: 'leadScoring', sectionName: 'Lead Scoring', isExpanded: true },
            { sectionKey: 'propertyValuation', sectionName: 'Property Valuation', isExpanded: true },
            { sectionKey: 'yearOverYearAnalysis', sectionName: 'Year-Over-Year Analysis', isExpanded: true },
            { sectionKey: 'propertyCharacteristics', sectionName: 'Property Characteristics', isExpanded: true },
            { sectionKey: 'buildingDimensions', sectionName: 'Building Dimensions', isExpanded: true },
            { sectionKey: 'improvementComparison', sectionName: 'Improvement Comparison', isExpanded: true },
            { sectionKey: 'peerGroupAnalysis', sectionName: 'Peer Group Analysis', isExpanded: true },
            { sectionKey: 'appealHistory', sectionName: 'Appeal History', isExpanded: true },
            { sectionKey: 'ownerQualification', sectionName: 'Owner Qualification', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

