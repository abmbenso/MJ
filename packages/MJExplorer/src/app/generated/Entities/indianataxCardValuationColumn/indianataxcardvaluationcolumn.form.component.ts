import { Component } from '@angular/core';
import { indianataxCardValuationColumnEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Card Valuation Columns') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxcardvaluationcolumn-form',
    templateUrl: './indianataxcardvaluationcolumn.form.component.html'
})
export class indianataxCardValuationColumnFormComponent extends BaseFormComponent {
    public record!: indianataxCardValuationColumnEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'recordIdentification', sectionName: 'Record Identification', isExpanded: true },
            { sectionKey: 'cardInformation', sectionName: 'Card Information', isExpanded: true },
            { sectionKey: 'valuationTimeline', sectionName: 'Valuation Timeline', isExpanded: true },
            { sectionKey: 'valuationChanges', sectionName: 'Valuation Changes', isExpanded: true },
            { sectionKey: 'landValuation', sectionName: 'Land Valuation', isExpanded: true },
            { sectionKey: 'improvementValuation', sectionName: 'Improvement Valuation', isExpanded: true },
            { sectionKey: 'totalValuation', sectionName: 'Total Valuation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

