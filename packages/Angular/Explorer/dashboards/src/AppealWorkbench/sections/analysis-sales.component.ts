import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output } from '@angular/core';
import { computeCompAdjustment, SalesCompInput, SalesCompResult, SalesCoefficients, SalesSubjectInput, SalesIndication, salesIndicatedValue, SALES_MINIMUM_COMPS } from '../sales-approach';
import { assumptionsToSalesCoefficients, proposeSalesAssumptions, AssumptionSource, ProposedAssumption, SALES_KEYS } from '../analysis-defaults';
import { AnalysisRow, AssumptionRow, CompDecisionRow, SubjectBundle, ValuationCompRow } from '../analysis-store';

/**
 * The old `Kept = comps.filter(c => !c.DropReason)` / `Dropped = comps.filter(c => !!c.DropReason)`
 * split cannot represent the widened comp pool correctly: a comp that simply wasn't in the
 * batch's original top-10 has `DropReason == null` but `IsSelected === false`, and the old logic
 * misclassified it as "kept." This three-state model, driven by the merged decision (a saved
 * CompDecisionRow, when one exists, always wins over the batch's own IsSelected default), is the
 * replacement. Pure and exported so it's independently testable — see analysis-sales.test.ts.
 */
export type CompState = 'included' | 'available' | 'rejected';

export function resolveCompState(comp: ValuationCompRow, decision: CompDecisionRow | undefined): CompState {
  if (comp.DropReason) return 'rejected'; // genuine data-quality drop
  const included = decision ? decision.IsIncluded : comp.IsSelected; // decision row wins; else the batch default
  return included ? 'included' : 'available';
}

/**
 * A local, unsaved edit to one comp's inclusion/order. `touched` distinguishes an analyst edit
 * (write on Save — Task 8) from the inherited default (nothing to write): a row seeded straight
 * from a saved CompDecisionRow is `touched: false` until the analyst actually changes it, whether
 * by hand or via a preset.
 */
export interface CompDecisionDraft { isIncluded: boolean; sortOrder: number | null; touched: boolean; }

/**
 * Every adjustment/value column displays the LIVE `SalesCompResult` (re-priced through
 * `Coefficients`, which may diverge from the batch's own stored constants) — never the
 * batch-stored `ValuationCompRow` column. So every one of those columns must sort by its
 * live camelCase key, not the stale PascalCase one: sorting by a stale key would silently
 * reorder rows by numbers that no longer match what's on screen the moment Coefficients
 * diverges from the batch defaults (invisible today only because they start out equal).
 * `keyof ValuationCompRow` still covers the non-adjustment columns (address/date/raw $/unit/
 * similarity rank, none of which the live engine recomputes differently).
 */
export type SalesSortColumn = keyof ValuationCompRow
  | 'sizeAdjPct' | 'ageAdjPct' | 'gradeAdjPct' | 'timeAdjPct'
  | 'netAdjPct' | 'grossAdjPct' | 'adjustedPerUnit' | 'subjectIndicatedValue';
export type SalesPreset = 'leastAdjusted' | 'mostSimilar' | 'sameSubmarket' | 'all' | 'none';
export type CompRow = ValuationCompRow & SalesCompResult & { state: CompState };

/**
 * A brand-new analysis has no saved Section='Sales' assumption rows yet -- `workingAssumptions`
 * falls back to `proposeSalesAssumptions()` (the batch script's own constants) in that case, and
 * this converts one of those proposals into the same `AssumptionRow` shape the saved rows use.
 * ID/AppealAnalysisID are placeholders: nothing is persisted here (Task 8's Save assigns the
 * real IDs), matching Income's own first-open pattern of deriving a working row set before Save.
 */
function toAssumptionRow(p: ProposedAssumption): AssumptionRow {
  return {
    ID: '', AppealAnalysisID: '', Section: p.section, AssumptionKey: p.key, Label: p.label,
    Value: p.value, Unit: p.unit, Mode: p.mode, Source: p.source, SourceRef: p.sourceRef,
    ProposedValue: p.value, ProposedSource: p.source, SortOrder: p.sortOrder,
  };
}

/**
 * One coefficients-panel row: an enable flag + a rate, each its own `AssumptionRow` (and so,
 * potentially, its own Source -- toggling only the checkbox flips `Enabled.Source` to Analyst
 * without touching `Rate.Source`, and vice versa). `Source` is the single combined chip value
 * the row renders (see `AnalysisSalesComponent.Factors`): 'Analyst' if either half was edited,
 * otherwise the rate's own Source -- this is the row's ONLY visual provenance signal (there's no
 * row-highlight here the way Income's dirty-row shading works), so it must reflect either edit.
 */
export interface SalesFactorRow { Label: string; EnabledKey: string; RateKey: string; Enabled: AssumptionRow; Rate: AssumptionRow; Source: AssumptionSource; }

/** The coefficients-panel row's single combined Source: 'Analyst' if either half was analyst-edited, else the rate's own Source. Exported so it's independently testable. */
export function factorSource(enabled: AssumptionRow, rate: AssumptionRow): AssumptionSource {
  return enabled.Source === 'Analyst' || rate.Source === 'Analyst' ? 'Analyst' : rate.Source;
}

/**
 * Pure preset logic — mirrors the reference artifact's segmented-control behavior. Each preset
 * returns the full set of SaleTransactionIDs that should be `isIncluded: true`; everything else
 * in the pool becomes `isIncluded: false`. Exported so it's independently testable.
 */
export function applyPreset(rows: Array<ValuationCompRow & SalesCompResult>, preset: string, subjectSubmarket: string | null): Set<string> {
  switch (preset) {
    case 'leastAdjusted': return new Set([...rows].sort((a, b) => a.grossAdjPct - b.grossAdjPct).slice(0, 5).map((r) => r.SaleTransactionID));
    case 'mostSimilar': return new Set([...rows].sort((a, b) => (a.SimilarityRank ?? 99) - (b.SimilarityRank ?? 99)).slice(0, 5).map((r) => r.SaleTransactionID));
    case 'sameSubmarket': return new Set(rows.filter((r) => subjectSubmarket && r.CompSubmarket === subjectSubmarket).map((r) => r.SaleTransactionID));
    case 'all': return new Set(rows.map((r) => r.SaleTransactionID));
    default: return new Set();
  }
}

function compareValues(a: unknown, b: unknown): number {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  if (typeof a === 'string' && typeof b === 'string') return a.localeCompare(b);
  return Number(a) - Number(b);
}

/**
 * The editable comp grid: every batch-seeded comp (Task 3's `Subject.comps`) is re-priced live
 * through Task 4's pure engine (`computeCompAdjustment`) using `Coefficients` (Task 7: derived
 * from `SalesAssumptions`, falling back to the batch's own proposed defaults on a brand-new
 * analysis), then joined against the analyst's working inclusion decisions
 * (`resolveCompState`/`decisions`) to drive the three-state grid. Nothing is written here — Save
 * is Task 8's job; this component only emits the working `decisions` map on every change via
 * `DecisionsChanged`.
 *
 * `Decisions` -- NOTE: the brief's Step 2 says "seed `decisions` from `Subject.compDecisions`",
 * but `SubjectBundle` (analysis-store.ts) carries no `compDecisions` field -- like `Assumptions`
 * and `Indications`, saved comp decisions come back from `loadAnalysis` as a sibling of `analysis`,
 * not nested in `SubjectBundle`. Unlike a first draft of this component, `Decisions` is NOT a raw
 * `CompDecisionRow[]` @Input() this component reseeds itself from: the final whole-plan review
 * (Ruling 8) found that pattern silently discarded unsaved comp curation -- a tab switch destroys
 * and recreates this component (the shell's `@switch` template), and the shell's own
 * `reseedSales=false` round-trip (after a bare Recompute/SaveHeader) still reassigned its
 * database-sourced `CompDecisions` field, which fed straight back into a reseed here and clobbered
 * the analyst's live edits on the very next `ToggleRow`. The fix: `Decisions` IS the parent's own
 * working `Map<string, CompDecisionDraft>` (`AppealWorkbenchComponent.SalesDecisions`), passed
 * straight through as the `@Input()` below -- nothing here re-derives it from a database read, so
 * there is nothing left to silently discard. The shell seeds `SalesDecisions` from the loaded
 * `CompDecisionRow[]` exactly once, on a genuine first-load/analysis-switch (`reseedSales: true`
 * in `AppealWorkbenchComponent.openAnalysis`), and simply carries the same Map through on every
 * later round-trip.
 */
@Component({
  standalone: false,
  selector: 'mj-analysis-sales',
  templateUrl: './analysis-sales.component.html',
  styleUrls: ['./analysis-sales.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisSalesComponent {
  @Input() Subject: SubjectBundle | null = null;
  @Input() Analysis: AnalysisRow | null = null;
  /** Section='Sales' rows from the loaded analysis; empty on a brand-new analysis (see `workingAssumptions`). */
  @Input() SalesAssumptions: AssumptionRow[] = [];
  /** The parent's own working comp-inclusion decisions, keyed by SaleTransactionID — see the class doc-comment above. Owned by the parent; never reseeded here. */
  @Input() Decisions: Map<string, CompDecisionDraft> = new Map();
  @Output() DecisionsChanged = new EventEmitter<Map<string, CompDecisionDraft>>();
  /** Working assumption edits (one-way data flow, mirroring Income): the parent holds the authoritative copy and hands it back via `SalesAssumptions`. */
  @Output() AssumptionsChanged = new EventEmitter<AssumptionRow[]>();
  /** This tab's one-click print button (Task 10) -- the shell alone holds what an export needs, so this only asks. */
  @Output() PrintRequested = new EventEmitter<void>();

  // Public members are PascalCase per repo convention (typescript-style.md; see AnalysisIncomeComponent's
  // Rows/Result/Dirty) -- the brief's Step 2 snippet used lowercase, but that snippet also carried the
  // DEFAULT_SALES_COEFFICIENTS naming that turned out not to exist; treat it as illustrative, not literal.
  public SortColumn: SalesSortColumn = 'SimilarityRank';
  public SortDirection: 'asc' | 'desc' = 'asc';
  /**
   * Fix 6 (final whole-plan review, free bundle-in): 'leastAdjusted' as the initial value lied --
   * that preset's own filter logic (`applyPreset`) never actually ran on first open, so the button
   * rendered pressed/active while the real initial inclusion set came from the batch's own
   * `IsSelected` defaults (which can differ from what "least adjusted 5" would pick). 'none' is the
   * only value that's true on first open: no preset has been applied yet, the grid is showing the
   * engine's own defaults via `resolveCompState`. See `ApplyPreset`, the only other place this is set.
   */
  public ActivePreset: SalesPreset = 'none';
  /** For the template's belowMinimum warning text — SALES_MINIMUM_COMPS itself isn't reachable from a template binding. */
  public readonly MinimumComps = SALES_MINIMUM_COMPS;

  private get subjectInput(): SalesSubjectInput {
    const year = this.Analysis?.AssessmentYear;
    return {
      denominator: this.Analysis?.SubjectDenominator ?? 0,
      // Fix 5 (final whole-plan review, documentation only): no true "effective year built" source
      // is currently reachable from this code -- the same underlying gap `subjectGradeOrdinal`
      // (below) discloses for grade, see analysis-store.ts's Ruling 6-style comment on that field.
      // Unlike grade, which correctly SKIPS its adjustment factor when the ordinal is null, age
      // silently substitutes the parcel's recorded, actual YearBuilt and computes an adjustment
      // from it anyway -- coarser than the effective-age standard used elsewhere in this project,
      // with no visible indication of the substitution. Sourcing a real EffectiveYear is out of
      // scope for this fix; this comment (and the Sales tab's own on-screen note) is the fix.
      effectiveYearBuilt: this.Subject?.record?.YearBuilt ?? null,
      gradeOrdinal: this.Subject?.subjectGradeOrdinal ?? null,
      lienDate: year != null ? `${year}-01-01` : new Date().toISOString().slice(0, 10), // Jan 1 of the ANALYSIS's own AssessmentYear, never hardcoded
    };
  }

  private toCompInput(c: ValuationCompRow): SalesCompInput {
    return { id: c.SaleTransactionID, rawPerUnit: c.RawPerUnit ?? 0, compDenominator: c.CompDenominator ?? 0, compYearBuilt: c.CompYearBuilt, compGradeOrdinal: c.CompGradeOrdinal, saleDate: c.SaleDate ?? '' };
  }

  /** `SalesAssumptions` as loaded, or (a brand-new analysis) the batch's own proposed defaults — never an empty set. */
  private get workingAssumptions(): AssumptionRow[] {
    return this.SalesAssumptions.length ? this.SalesAssumptions : proposeSalesAssumptions().map(toAssumptionRow);
  }

  /**
   * Replaces the old `@Input() Coefficients` (Task 6's temporary bridge) with a getter derived
   * from `workingAssumptions` — every existing reader (`Results`, transitively `Rows`) keeps
   * working unchanged since the name and return type are identical.
   */
  public get Coefficients(): SalesCoefficients {
    return assumptionsToSalesCoefficients(this.workingAssumptions.map((a) => ({ key: a.AssumptionKey, value: a.Value })));
  }

  /** One row per adjustment factor for the coefficients panel; only rendered once both its keys are present in `workingAssumptions`. */
  public get Factors(): SalesFactorRow[] {
    const by = new Map(this.workingAssumptions.map((a) => [a.AssumptionKey, a]));
    const pairs: Array<{ Label: string; EnabledKey: string; RateKey: string }> = [
      { Label: 'Size', EnabledKey: SALES_KEYS.sizeEnabled, RateKey: SALES_KEYS.sizeRate },
      { Label: 'Age', EnabledKey: SALES_KEYS.ageEnabled, RateKey: SALES_KEYS.ageRate },
      { Label: 'Grade', EnabledKey: SALES_KEYS.gradeEnabled, RateKey: SALES_KEYS.gradeRate },
      { Label: 'Time', EnabledKey: SALES_KEYS.timeEnabled, RateKey: SALES_KEYS.timeRate },
    ];
    return pairs
      .map((p) => ({ ...p, Enabled: by.get(p.EnabledKey), Rate: by.get(p.RateKey) }))
      .filter((f): f is Omit<SalesFactorRow, 'Source'> => f.Enabled != null && f.Rate != null)
      .map((f) => ({ ...f, Source: factorSource(f.Enabled, f.Rate) }));
  }

  /** Editing a coefficient (rate or its enable flag) flips that row's Source to Analyst and emits the whole working set — the parent (Task 8) holds the authoritative copy and hands it back via `SalesAssumptions`, same one-way-data-flow pattern as Income's `OnEdit`. */
  public OnCoefficientEdit(key: string, value: number | boolean): void {
    const next = this.workingAssumptions.map((a) => a.AssumptionKey === key
      ? { ...a, Value: typeof value === 'boolean' ? (value ? 1 : 0) : value, Source: 'Analyst' as const }
      : a);
    this.AssumptionsChanged.emit(next);
  }

  public get Results(): SalesCompResult[] {
    return (this.Subject?.comps ?? []).map((c) => computeCompAdjustment(this.subjectInput, this.toCompInput(c), this.Coefficients));
  }

  private decisionRow(id: string): CompDecisionRow | undefined {
    const d = this.Decisions.get(id);
    return d ? { ID: id, AppealAnalysisID: this.Analysis?.ID ?? '', SaleTransactionID: id, IsIncluded: d.isIncluded, SortOrder: d.sortOrder } : undefined;
  }

  /** Full merged + sorted set: included rows first, then available, then rejected (data-quality drops) always last, regardless of column sort. */
  public get Rows(): CompRow[] {
    const comps = this.Subject?.comps ?? [];
    const resultById = new Map(this.Results.map((r) => [r.id, r]));
    const merged: CompRow[] = comps.map((c) => ({ ...c, ...resultById.get(c.SaleTransactionID)!, state: resolveCompState(c, this.decisionRow(c.SaleTransactionID)) }));
    const rank: Record<CompState, number> = { included: 0, available: 1, rejected: 2 };
    const dir = this.SortDirection === 'asc' ? 1 : -1;
    return [...merged].sort((a, b) => (rank[a.state] !== rank[b.state] ? rank[a.state] - rank[b.state] : compareValues(a[this.SortColumn], b[this.SortColumn]) * dir));
  }

  /** The sortable table: included + available only — rejected (DropReason-carrying) rows never mix in here. */
  public get SortableRows(): CompRow[] { return this.Rows.filter((r) => r.state !== 'rejected'); }
  /** The de-emphasized group rendered below the sortable table. */
  public get RejectedRows(): CompRow[] { return this.Rows.filter((r) => r.state === 'rejected'); }

  /** The live summary: median $/unit and total across only the 'included' rows, per the current Coefficients. */
  public get Indication(): SalesIndication {
    const includedIds = new Set([...this.Rows].filter((r) => r.state === 'included').map((r) => r.SaleTransactionID));
    return salesIndicatedValue(this.Results, includedIds, this.subjectInput.denominator);
  }

  public SetSort(col: SalesSortColumn): void {
    if (this.SortColumn === col) this.SortDirection = this.SortDirection === 'asc' ? 'desc' : 'asc';
    else { this.SortColumn = col; this.SortDirection = 'asc'; }
  }

  /** Clicking a preset replaces the working decisions' isIncluded flags for every eligible (non-rejected) row, all touched: true. */
  public ApplyPreset(preset: SalesPreset): void {
    this.ActivePreset = preset;
    const pool = this.Rows.filter((r) => r.state !== 'rejected');
    const subjectSubmarket = this.Subject?.costar?.Submarket ?? null;
    const includedIds = applyPreset(pool, preset, subjectSubmarket);
    const next = new Map(this.Decisions);
    for (const r of pool) next.set(r.SaleTransactionID, { isIncluded: includedIds.has(r.SaleTransactionID), sortOrder: next.get(r.SaleTransactionID)?.sortOrder ?? null, touched: true });
    this.Decisions = next;
    this.DecisionsChanged.emit(this.Decisions);
  }

  /** A manual per-row toggle breaks any preset match, so the segmented control drops to 'none'. */
  public ToggleRow(id: string, isIncluded: boolean): void {
    const next = new Map(this.Decisions);
    next.set(id, { isIncluded, sortOrder: next.get(id)?.sortOrder ?? null, touched: true });
    this.Decisions = next;
    this.ActivePreset = 'none';
    this.DecisionsChanged.emit(this.Decisions);
  }
}
