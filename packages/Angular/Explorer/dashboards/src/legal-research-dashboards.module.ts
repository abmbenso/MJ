import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  MJButtonDirective,
  MJPageHeaderComponent,
  MJPageLayoutComponent,
  MJPageBodyComponent,
  MJStatBadgeComponent,
  MJEmptyStateComponent,
  MJAlertComponent,
} from '@memberjunction/ng-ui-components';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';

import { LegalResearchDashboardComponent } from './LegalResearch/legal-research-dashboard.component';

/**
 * LegalResearchDashboardsModule — the Indiana Property Tax Expert's Legal Research
 * feature area: federated search (IBTR Decisions + Legal Authority Search Scopes) over
 * statute, 50 IAC, the Manual, Guidelines, and IBTR/Tax Court decisions, plus a cited AI
 * answer for question-shaped queries. `SearchService` (`@memberjunction/ng-search`) is
 * `providedIn: 'root'`, so it needs no module import here -- this module only needs the
 * page-chrome + form primitives the component's own template uses.
 */
@NgModule({
  declarations: [LegalResearchDashboardComponent],
  imports: [
    CommonModule,
    FormsModule,
    MJButtonDirective,
    MJPageHeaderComponent,
    MJPageLayoutComponent,
    MJPageBodyComponent,
    MJStatBadgeComponent,
    MJEmptyStateComponent,
    MJAlertComponent,
    SharedGenericModule,
  ],
  exports: [LegalResearchDashboardComponent],
})
export class LegalResearchDashboardsModule {}
