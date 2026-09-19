import { Component } from '@angular/core';
import { indianataxOwnerPortfolioRunEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Owner Portfolio Runs') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxownerportfoliorun-form',
    templateUrl: './indianataxownerportfoliorun.form.component.html'
})
export class indianataxOwnerPortfolioRunFormComponent extends BaseFormComponent {
    public record!: indianataxOwnerPortfolioRunEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'runIdentification', sectionName: 'Run Identification', isExpanded: true },
            { sectionKey: 'countyAssessmentRollup', sectionName: 'County Assessment Rollup', isExpanded: true },
            { sectionKey: 'countyParcelDistribution', sectionName: 'County Parcel Distribution', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'ownerPortfolios', sectionName: 'Owner Portfolios', isExpanded: false }
        ]);
    }
}

