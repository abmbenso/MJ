import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output } from '@angular/core';
import { AskPolicy, Reconciliation } from '../appeal-rules';
import { estimateSavings } from '../appeal-rules';
import { AnalysisRow, IndicationRow, SubjectBundle } from '../analysis-store';
import { AssessmentSummaryRow, buildAssessmentSummary } from './assessment-summary';

const APPROACH_LABEL: Record<string, string> = { Income: 'Income (market)', Sales: 'Sales comparison', AssessmentComps: 'Assessment comps', Cost: 'Cost', ActualIE: 'Actual income & expenses' };

@Component({
  standalone: false,
  selector: 'mj-analysis-cover',
  templateUrl: './analysis-cover.component.html',
  styleUrls: ['./analysis-cover.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisCoverComponent {
  @Input() Subject: SubjectBundle | null = null;
  @Input() Analysis: AnalysisRow | null = null;
  @Input() Indications: IndicationRow[] = [];
  @Input() Reconciled: Reconciliation | null = null;
  @Input() Savings: { atAsk: ReturnType<typeof estimateSavings>; atFloor: ReturnType<typeof estimateSavings> } | null = null;
  @Input() Busy = false;
  @Output() AskPolicyChange = new EventEmitter<AskPolicy>();
  @Output() CommentsChange = new EventEmitter<string>();
  @Output() StatusChange = new EventEmitter<'Draft' | 'Final'>();
  /** The Print Package button -- same one-way hand-off pattern as AskPolicyChange/CommentsChange/StatusChange: this component only asks, the shell (which alone holds the state an export needs) builds the model and opens the dialog. */
  @Output() PrintPackageRequested = new EventEmitter<void>();

  public get Summary(): AssessmentSummaryRow[] {
    const y = this.Analysis?.AssessmentYear ?? 2026;
    return this.Subject ? buildAssessmentSummary(this.Subject.assessments, [y - 2, y - 1, y]) : [];
  }
  public get Ladder(): Array<{ label: string; row: IndicationRow; pct: number | null; credible: boolean; supports: boolean; isAsk: boolean; isFloor: boolean }> {
    const order = ['Income', 'Sales', 'AssessmentComps', 'Cost', 'ActualIE'];
    return [...this.Indications].sort((a, b) => order.indexOf(a.Approach) - order.indexOf(b.Approach)).map((row) => ({
      label: APPROACH_LABEL[row.Approach] ?? row.Approach, row, pct: row.PctOfAV, credible: row.Credible, supports: row.Supports,
      isAsk: this.Reconciled?.askApproach === row.Approach, isFloor: this.Reconciled?.floorApproach === row.Approach,
    }));
  }
  public get AskPctBelow(): number | null {
    const a = this.Analysis; return a?.RequestedValue != null && a.CurrentTotalAV ? 1 - a.RequestedValue / a.CurrentTotalAV : null;
  }
  public OnPolicy(v: string): void { if (v === 'Lowest' || v === 'SecondLowest') this.AskPolicyChange.emit(v); }
  public OnComments(v: string): void { this.CommentsChange.emit(v); }
  public OnStatus(v: string): void { if (v === 'Draft' || v === 'Final') this.StatusChange.emit(v); }
}
