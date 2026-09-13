import { Component } from '@angular/core';
import { indianataxProspectSnapshotEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Prospect Snapshots') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxprospectsnapshot-form',
    templateUrl: './indianataxprospectsnapshot.form.component.html'
})
export class indianataxProspectSnapshotFormComponent extends BaseFormComponent {
    public record!: indianataxProspectSnapshotEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'snapshotIdentification', sectionName: 'Snapshot Identification', isExpanded: true },
            { sectionKey: 'parcelMetrics', sectionName: 'Parcel Metrics', isExpanded: true },
            { sectionKey: 'financialMetrics', sectionName: 'Financial Metrics', isExpanded: true },
            { sectionKey: 'opportunityMetrics', sectionName: 'Opportunity Metrics', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

