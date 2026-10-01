import { Component } from '@angular/core';
import { indianataxSaleConveyanceMemberEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Sale Conveyance Members') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxsaleconveyancemember-form',
    templateUrl: './indianataxsaleconveyancemember.form.component.html'
})
export class indianataxSaleConveyanceMemberFormComponent extends BaseFormComponent {
    public record!: indianataxSaleConveyanceMemberEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'conveyanceMembership', sectionName: 'Conveyance Membership', isExpanded: true },
            { sectionKey: 'memberPropertyMetrics', sectionName: 'Member Property Metrics', isExpanded: true },
            { sectionKey: 'memberContributionStatus', sectionName: 'Member Contribution Status', isExpanded: true },
            { sectionKey: 'relatedData', sectionName: 'Related Data', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

