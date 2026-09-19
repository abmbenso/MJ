import { Component } from '@angular/core';
import { indianataxOwnerPortfolioEntity } from 'mj_generatedentities';
import { RegisterClass } from '@memberjunction/global';
import { BaseFormComponent } from '@memberjunction/ng-base-forms';
import {  } from "@memberjunction/ng-entity-viewer"

@RegisterClass(BaseFormComponent, 'Owner Portfolios') // Tell MemberJunction about this class
@Component({
    standalone: false,
    selector: 'gen-indianataxownerportfolio-form',
    templateUrl: './indianataxownerportfolio.form.component.html'
})
export class indianataxOwnerPortfolioFormComponent extends BaseFormComponent {
    public record!: indianataxOwnerPortfolioEntity;

    override async ngOnInit() {
        await super.ngOnInit();
        this.initSections([
            { sectionKey: 'ownerIdentification', sectionName: 'Owner Identification', isExpanded: true },
            { sectionKey: 'portfolioComposition', sectionName: 'Portfolio Composition', isExpanded: true },
            { sectionKey: 'assessedValueAnalysis', sectionName: 'Assessed Value Analysis', isExpanded: true },
            { sectionKey: 'valuationAnalysisOpportunity', sectionName: 'Valuation Analysis Opportunity', isExpanded: true },
            { sectionKey: 'appealHistory', sectionName: 'Appeal History', isExpanded: true },
            { sectionKey: 'taxRepresentation', sectionName: 'Tax Representation', isExpanded: true },
            { sectionKey: 'details', sectionName: 'Details', isExpanded: true },
            { sectionKey: 'systemMetadata', sectionName: 'System Metadata', isExpanded: false },
            { sectionKey: 'ownerPortfolioParcels', sectionName: 'Owner Portfolio Parcels', isExpanded: false }
        ]);
    }
}

