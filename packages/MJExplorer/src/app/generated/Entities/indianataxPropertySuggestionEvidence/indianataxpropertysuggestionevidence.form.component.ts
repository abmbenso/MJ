import { Component } from '@angular/core';
import { indianataxPropertySuggestionEvidenceEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';

@RegisterClass(BaseFormComponent, 'Property Suggestion Evidences') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxpropertysuggestionevidence-form',
    templateUrl: './indianataxpropertysuggestionevidence.form.component.html'
})
export class indianataxPropertySuggestionEvidenceFormComponent extends BaseFormComponent {
    public record!: indianataxPropertySuggestionEvidenceEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'suggestionDetails', sectionName: 'Suggestion Details', isExpanded: true },
            { sectionKey: 'suggestionTiming', sectionName: 'Suggestion Timing', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false }
        ]);
    }
}

