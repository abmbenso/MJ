import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output } from '@angular/core';
import { estimateSavings, COMMERCIAL_CAP } from '../appeal-rules';
import { AnalysisRow, SubjectBundle } from '../analysis-store';

@Component({
  standalone: false,
  selector: 'mj-analysis-tax',
  templateUrl: './analysis-tax.component.html',
  styleUrls: ['./analysis-tax.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisTaxComponent {
  @Input() Analysis: AnalysisRow | null = null;
  @Input() Subject: SubjectBundle | null = null;
  @Input() Savings: { atAsk: ReturnType<typeof estimateSavings>; atFloor: ReturnType<typeof estimateSavings> } | null = null;
  @Output() OpenProjection = new EventEmitter<void>();
  /** This tab's one-click print button (Task 10) -- the shell alone holds what an export needs, so this only asks. */
  @Output() PrintRequested = new EventEmitter<void>();
  public readonly Cap = COMMERCIAL_CAP;
  public get Rate(): number | null { return this.Subject?.record?.TaxRate ?? null; }
}
