import { Component } from '@angular/core';
import { indianataxIBTRDecisionPartyEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'IBTR Decision Parties') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxibtrdecisionparty-form',
    templateUrl: './indianataxibtrdecisionparty.form.component.html'
})
export class indianataxIBTRDecisionPartyFormComponent extends BaseFormComponent {
    public record!: indianataxIBTRDecisionPartyEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true }
        ]);
    }
}

