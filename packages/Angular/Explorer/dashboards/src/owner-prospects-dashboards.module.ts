import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  MJButtonDirective, MJPageHeaderComponent, MJPageLayoutComponent, MJPageBodyComponent,
  MJPageSearchComponent, MJFilterPopoverComponent, MJFilterPanelComponent, MJFilterFieldComponent,
  MJNumericInputComponent, MJViewToggleComponent, MJStatBadgeComponent, MJRefreshButtonComponent,
  MJEmptyStateComponent, MJAlertComponent,
} from '@memberjunction/ng-ui-components';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import { OwnerProspectsDashboardComponent } from './OwnerProspects/owner-prospects-dashboard.component';
import { OwnerDetailPanelComponent } from './OwnerProspects/owner-detail-panel.component';

/**
 * OwnerProspectsDashboardsModule — the Indiana Property Tax Expert's owner-level
 * prospecting screen: parcels rolled up to the operating company, the
 * ValuationAnalysis opportunity per owner, appeal history, tax rep on record,
 * and a "Flag as prospect" action into the Prospecting CRM.
 */
@NgModule({
  declarations: [OwnerProspectsDashboardComponent, OwnerDetailPanelComponent],
  imports: [
    CommonModule, FormsModule, MJButtonDirective, MJPageHeaderComponent, MJPageLayoutComponent,
    MJPageBodyComponent, MJPageSearchComponent, MJFilterPopoverComponent, MJFilterPanelComponent,
    MJFilterFieldComponent, MJNumericInputComponent, MJViewToggleComponent, MJStatBadgeComponent,
    MJRefreshButtonComponent, MJEmptyStateComponent, MJAlertComponent, SharedGenericModule,
  ],
  exports: [OwnerProspectsDashboardComponent, OwnerDetailPanelComponent],
})
export class OwnerProspectsDashboardsModule {}
