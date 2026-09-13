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
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

