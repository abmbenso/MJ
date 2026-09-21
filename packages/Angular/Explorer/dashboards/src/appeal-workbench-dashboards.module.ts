import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MJButtonDirective, MJPageHeaderComponent, MJPageLayoutComponent, MJPageBodyComponent, MJPageSearchComponent, MJStatBadgeComponent, MJEmptyStateComponent, MJAlertComponent, MJTabNavComponent, MJDialogComponent, MJDialogActionsComponent } from '@memberjunction/ng-ui-components';
import { SharedGenericModule } from '@memberjunction/ng-shared-generic';
import { AppealWorkbenchComponent } from './AppealWorkbench/appeal-workbench.component';
import { AnalysisCoverComponent } from './AppealWorkbench/sections/analysis-cover.component';
import { AnalysisIncomeComponent } from './AppealWorkbench/sections/analysis-income.component';
import { AnalysisSalesComponent } from './AppealWorkbench/sections/analysis-sales.component';
import { AnalysisAssessmentCompsComponent } from './AppealWorkbench/sections/analysis-assessment-comps.component';
import { AnalysisTaxComponent } from './AppealWorkbench/sections/analysis-tax.component';
import { AnalysisDecisionsComponent } from './AppealWorkbench/sections/analysis-decisions.component';

/** AppealWorkbenchDashboardsModule — the Indiana Property Tax Expert's Analyze a Property (Appeal Workbench Plan 1). */
@NgModule({
  declarations: [AppealWorkbenchComponent, AnalysisCoverComponent, AnalysisIncomeComponent, AnalysisSalesComponent, AnalysisAssessmentCompsComponent, AnalysisTaxComponent, AnalysisDecisionsComponent],
  imports: [CommonModule, FormsModule, MJButtonDirective, MJPageHeaderComponent, MJPageLayoutComponent, MJPageBodyComponent, MJPageSearchComponent, MJStatBadgeComponent, MJEmptyStateComponent, MJAlertComponent, MJTabNavComponent, MJDialogComponent, MJDialogActionsComponent, SharedGenericModule],
  exports: [AppealWorkbenchComponent, AnalysisCoverComponent, AnalysisIncomeComponent, AnalysisSalesComponent, AnalysisAssessmentCompsComponent, AnalysisTaxComponent, AnalysisDecisionsComponent],
})
export class AppealWorkbenchDashboardsModule {}
