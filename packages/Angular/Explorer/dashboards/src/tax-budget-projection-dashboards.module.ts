import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  MJButtonDirective,
  MJPageHeaderComponent,
  MJPageLayoutComponent,
  MJPageBodyComponent,
  MJStatBadgeComponent,
  MJRefreshButtonComponent,
  MJEmptyStateComponent,
  MJAlertComponent,
} from '@memberjunction/ng-ui-components';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';

import { TaxBudgetProjectionDashboardComponent } from './TaxBudgetProjection/tax-budget-projection-dashboard.component';
import { TaxBillProjectionComponent } from './TaxBillProjection/tax-bill-projection.component';

/**
 * TaxBudgetProjectionDashboardsModule — the Indiana Property Tax Expert's
 * per-parcel tax budget tool (OPP-1/2/3): 5 years of actual history + 5
 * years of projection across three probability-weighted scenarios (Worst
 * Case / Most Likely / Best Case), every assumption editable. Worst Case's
 * probability is sourced live from indiana_tax.SaleReassessmentScenarioProbability
 * (OPP-2's Component A empirical model), not a fixed guess.
 *
 * Also declares the V2 bill-shaped view (TaxBillProjectionResource), which renders the
 * SAME engine's output in the shape of the taxpayer's TS-1 bill. The two are separate nav
 * items on purpose, so the same parcel can be opened in both and compared.
 */
@NgModule({
  declarations: [TaxBudgetProjectionDashboardComponent, TaxBillProjectionComponent],
  imports: [
    CommonModule,
    FormsModule,
    MJButtonDirective,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageBodyComponent,
    MJStatBadgeComponent,
    MJRefreshButtonComponent,
    MJEmptyStateComponent,
    MJAlertComponent,
    SharedGenericModule,
  ],
  exports: [TaxBudgetProjectionDashboardComponent, TaxBillProjectionComponent],
})
export class TaxBudgetProjectionDashboardsModule {}
