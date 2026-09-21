import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output, OnChanges, SimpleChanges } from '@angular/core';
import { computeIncomeApproach, bandOfInvestment, IncomeResult } from '../income-approach';
import { assumptionsToIncomeInputs } from '../analysis-defaults';
import { AssumptionRow, SubjectBundle, MarketAssumptionRow } from '../analysis-store';
import { applyEdit, displayValue } from './income-edit';

/**
 * The editable pro forma: every Income-section assumption row is an input. Editing a value
 * flips its chip to Analyst and recomputes the pro forma live via Task 3's income-approach
 * engine (computeIncomeApproach); Save emits only the changed rows (each already stamped
 * Source: 'Analyst' by applyEdit) and the shell persists them and recomputes.
 */
@Component({
  standalone: false,
  selector: 'mj-analysis-income',
  templateUrl: './analysis-income.component.html',
  styleUrls: ['./analysis-income.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisIncomeComponent implements OnChanges {
  @Input() Assumptions: AssumptionRow[] = [];
  @Input() Subject: SubjectBundle | null = null;
  @Input() Busy = false;
  @Output() Save = new EventEmitter<AssumptionRow[]>();
  @Output() DirtyChange = new EventEmitter<number>();
  /** This tab's one-click print button (Task 10) -- the shell alone holds what an export needs, so this only asks. */
  @Output() PrintRequested = new EventEmitter<void>();

  public Rows: AssumptionRow[] = [];
  public Result: IncomeResult | null = null;
  public Dirty = new Map<string, AssumptionRow>();
  public Boi = { ltv: 0.6, rate: 0.0625, years: 25, edr: 0.08 };

  /** I4: only an actual Assumptions change resets the pro forma — a Busy-only change (the shell's IsSaving flag) is a no-op, so in-progress edits survive Recompute's re-render. */
  ngOnChanges(changes: SimpleChanges): void {
    if (!changes['Assumptions']) return;
    this.resetRows();
  }
  private resetRows(): void {
    this.Rows = this.Assumptions.filter((r) => r.Section === 'Income').sort((a, b) => a.SortOrder - b.SortOrder);
    this.Dirty.clear();
    this.recalc();
    this.DirtyChange.emit(this.Dirty.size);
  }
  public display(row: AssumptionRow): string { return displayValue(row); }
  public OnEdit(key: string, raw: string): void {
    const { rows, changed } = applyEdit(this.Rows, key, raw);
    if (!changed) return;
    this.Rows = rows;
    this.Dirty.set(key, changed);
    this.recalc();
    this.DirtyChange.emit(this.Dirty.size);
  }
  public OnSave(): void { this.Save.emit([...this.Dirty.values()]); this.DirtyChange.emit(this.Dirty.size); }
  public OnRevert(): void { this.resetRows(); }
  private recalc(): void {
    this.Result = computeIncomeApproach(assumptionsToIncomeInputs(this.Rows.map((r) => ({ key: r.AssumptionKey, label: r.Label, mode: r.Mode, value: r.Value }))));
  }

  public get CapSupport(): MarketAssumptionRow[] { return (this.Subject?.marketAssumptions ?? []).filter((m) => m.AssumptionType === 'CapRate').slice(0, 8); }
  public get BandOfInvestment(): { mortgageConstant: number; capRate: number } { return bandOfInvestment(this.Boi.ltv, this.Boi.rate, this.Boi.years, this.Boi.edr); }
  public get RentSupport(): string {
    const c = this.Subject?.costar;
    return c
      ? `CoStar: ${c.PropertyName ?? 'subject'} · ${c.Submarket ?? ''} · rent/SF ${c.AvgEffectiveRentPerSF ?? '—'} · rent/unit ${c.AvgEffectiveRentPerUnit ?? '—'} · vacancy ${c.VacancyPct ?? '—'}`
      : 'No CoStar match for this parcel; rent from MarketAssumption or the analyst.';
  }
}
