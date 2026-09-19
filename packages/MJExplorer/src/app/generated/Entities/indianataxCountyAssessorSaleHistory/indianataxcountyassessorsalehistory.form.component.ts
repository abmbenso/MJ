import { Component } from '@angular/core';
import { indianataxCountyAssessorSaleHistoryEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'County Assessor Sale Histories') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcountyassessorsalehistory-form',
    templateUrl: './indianataxcountyassessorsalehistory.form.component.html'
})
export class indianataxCountyAssessorSaleHistoryFormComponent extends BaseFormComponent {
    public record!: indianataxCountyAssessorSaleHistoryEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'saleDetails', sectionName: 'Sale Details', isExpanded: true },
            { sectionKey: 'saleParticipants', sectionName: 'Sale Participants', isExpanded: true },
            { sectionKey: 'recordingInformation', sectionName: 'Recording Information', isExpanded: true },
            { sectionKey: 'propertyCondition', sectionName: 'Property Condition', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

