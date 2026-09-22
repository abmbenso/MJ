import { Component } from '@angular/core';
import { indianataxTaxHistoryYearEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Tax History Years') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxtaxhistoryyear-form',
    templateUrl: './indianataxtaxhistoryyear.form.component.html'
})
export class indianataxTaxHistoryYearFormComponent extends BaseFormComponent {
    public record!: indianataxTaxHistoryYearEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'taxHistoryReference', sectionName: 'Tax History Reference', isExpanded: true },
            { sectionKey: 'taxYearInformation', sectionName: 'Tax Year Information', isExpanded: true },
            { sectionKey: 'assessmentValues', sectionName: 'Assessment Values', isExpanded: true },
            { sectionKey: 'deductionsAndCredits', sectionName: 'Deductions and Credits', isExpanded: true },
            { sectionKey: 'taxCalculation', sectionName: 'Tax Calculation', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

