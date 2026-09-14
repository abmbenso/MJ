import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  MJButtonDirective,
  MJPageHeaderComponent,
  MJPageLayoutComponent,
  MJPageBodyComponent,
  MJPageSearchComponent,
  MJFilterChipComponent,
  MJFilterPopoverComponent,
  MJFilterPanelComponent,
  MJFilterFieldComponent,
  MJNumericInputComponent,
  MJViewToggleComponent,
  MJStatBadgeComponent,
  MJRefreshButtonComponent,
  MJEmptyStateComponent,
  MJAlertComponent,
  MjSlidePanelComponent,
  MJComboboxComponent,
} from '@memberjunction/ng-ui-components';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import { MapViewModule } from '@memberjunction/ng-map-view';
import { AgGridModule } from 'ag-grid-angular';
import { ExportServiceModule } from '@memberjunction/ng-export-service';

import { PropertySearchDashboardComponent } from './PropertySearch/property-search-dashboard.component';
import { PropertyDetailPanelComponent } from './PropertySearch/property-detail-panel.component';
import { PropertySearchGridComponent } from './PropertySearch/property-search-grid.component';
import { PropertySubclassAnalyticsComponent } from './PropertySearch/property-subclass-analytics.component';
import { PropertySearchAnalyticsPanelComponent } from './PropertySearch/property-search-analytics-panel.component';

/**
 * PropertySearchDashboardsModule — the Indiana Property Tax Expert's
 * Property Search feature area: a single map-and-filter dashboard over
 * indiana_tax.Parcel / indiana_tax.CountyAssessorRecord, with a sortable/
 * exportable list-view alternative to the map, and a cross-sub-class
 * analytics view (assessment profile + PTABOA appeal outcomes).
 */
@NgModule({
  declarations: [
    PropertySearchDashboardComponent,
    PropertyDetailPanelComponent,
    PropertySearchGridComponent,
    PropertySubclassAnalyticsComponent,
    PropertySearchAnalyticsPanelComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    MJButtonDirective,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageBodyComponent,
    MJPageSearchComponent,
    MJFilterChipComponent,
    MJFilterPopoverComponent,
    MJFilterPanelComponent,
    MJFilterFieldComponent,
    MJNumericInputComponent,
    MJViewToggleComponent,
    MJStatBadgeComponent,
    MJRefreshButtonComponent,
    MJEmptyStateComponent,
    MJAlertComponent,
    MjSlidePanelComponent,
    MJComboboxComponent,
    SharedGenericModule,
    MapViewModule,
    AgGridModule,
    ExportServiceModule,
  ],
  exports: [
    PropertySearchDashboardComponent,
    PropertyDetailPanelComponent,
    PropertySearchGridComponent,
    PropertySubclassAnalyticsComponent,
    PropertySearchAnalyticsPanelComponent,
  ],
})
export class PropertySearchDashboardsModule {}
