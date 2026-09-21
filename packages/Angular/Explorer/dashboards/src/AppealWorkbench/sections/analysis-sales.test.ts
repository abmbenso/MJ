import { describe, it, expect } from 'vitest';
import { resolveCompState, applyPreset, factorSource, AnalysisSalesComponent, CompDecisionDraft } from './analysis-sales.component';
import { AnalysisRow, AssumptionRow, ParcelRow, SubjectBundle, ValuationCompRow, CompDecisionRow } from '../analysis-store';
import { SalesCompResult } from '../sales-approach';
import { SALES_KEYS } from '../analysis-defaults';

const comp = (over: Partial<ValuationCompRow>): ValuationCompRow => ({
  ID: 'c1', ValuationAnalysisID: 'va', SaleTransactionID: 'st1', CompAddress: '1 Main St', CompSubmarket: 'North',
  SaleDate: '2025-01-01', SalePrice: 1_000_000, CompDenominator: 10_000, CompYearBuilt: 2010, CompGradeOrdinal: 4,
  UnitOfComparison: '$/SF', RawPerUnit: 100, SizeAdjPct: 0, AgeAdjPct: 0, GradeAdjPct: 0, TimeAdjPct: 0, NetAdjPct: 0,
  GrossAdjPct: 0, AdjustedPerUnit: 100, SubjectIndicatedValue: 1_000_000, SimilarityRank: 1, IsSelected: true, DropReason: null,
  ...over,
});
const decision = (over: Partial<CompDecisionRow>): CompDecisionRow => ({ ID: 'd1', AppealAnalysisID: 'a1', SaleTransactionID: 'st1', IsIncluded: true, SortOrder: null, ...over });

describe('resolveCompState', () => {
  it('a DropReason-carrying comp is always rejected, decision row or not', () => {
    expect(resolveCompState(comp({ DropReason: 'outlier', IsSelected: true }), undefined)).toBe('rejected');
    expect(resolveCompState(comp({ DropReason: 'outlier', IsSelected: false }), decision({ IsIncluded: true }))).toBe('rejected');
  });
  it('a saved decision row wins over the batch IsSelected default', () => {
    expect(resolveCompState(comp({ IsSelected: true }), decision({ IsIncluded: false }))).toBe('available');
    expect(resolveCompState(comp({ IsSelected: false }), decision({ IsIncluded: true }))).toBe('included');
  });
  it('no decision row falls back to the batch IsSelected flag', () => {
    expect(resolveCompState(comp({ IsSelected: true }), undefined)).toBe('included');
    expect(resolveCompState(comp({ IsSelected: false }), undefined)).toBe('available');
  });
  it('the specific bug case: DropReason == null, IsSelected === false, no decision row -> available, never included', () => {
    const c = comp({ DropReason: null, IsSelected: false });
    expect(resolveCompState(c, undefined)).toBe('available');
  });
});

type Row = ValuationCompRow & SalesCompResult;
const result = (over: Partial<SalesCompResult>): SalesCompResult => ({
  id: 'st1', rawPerUnit: 100, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0,
  grossAdjPct: 0, adjustedPerUnit: 100, subjectIndicatedValue: 1_000_000, grossAdjustmentWarning: false, ...over,
});
const row = (id: string, over: Partial<Row> = {}): Row => ({
  ...comp({ SaleTransactionID: id }),
  ...result({ id }),
  ...over,
} as Row);

describe('applyPreset', () => {
  const rows: Row[] = [
    row('a', { grossAdjPct: 0.40, SimilarityRank: 3, CompSubmarket: 'North' }),
    row('b', { grossAdjPct: 0.05, SimilarityRank: 5, CompSubmarket: 'South' }),
    row('c', { grossAdjPct: 0.10, SimilarityRank: 1, CompSubmarket: 'North' }),
    row('d', { grossAdjPct: 0.20, SimilarityRank: 2, CompSubmarket: 'North' }),
    row('e', { grossAdjPct: 0.15, SimilarityRank: 4, CompSubmarket: 'South' }),
    row('f', { grossAdjPct: 0.30, SimilarityRank: 6, CompSubmarket: 'North' }),
  ];

  it('leastAdjusted takes the 5 lowest grossAdjPct', () => {
    const set = applyPreset(rows, 'leastAdjusted', null);
    expect(set).toEqual(new Set(['b', 'c', 'e', 'd', 'f']));
    expect(set.has('a')).toBe(false);
  });
  it('mostSimilar takes the 5 lowest SimilarityRank', () => {
    const set = applyPreset(rows, 'mostSimilar', null);
    expect(set).toEqual(new Set(['c', 'd', 'a', 'e', 'b']));
    expect(set.has('f')).toBe(false);
  });
  it('sameSubmarket takes only rows matching the subject submarket', () => {
    expect(applyPreset(rows, 'sameSubmarket', 'North')).toEqual(new Set(['a', 'c', 'd', 'f']));
    expect(applyPreset(rows, 'sameSubmarket', 'South')).toEqual(new Set(['b', 'e']));
  });
  it('sameSubmarket with no subject submarket returns an empty set', () => {
    expect(applyPreset(rows, 'sameSubmarket', null)).toEqual(new Set());
  });
  it('all takes every row', () => {
    expect(applyPreset(rows, 'all', null)).toEqual(new Set(['a', 'b', 'c', 'd', 'e', 'f']));
  });
  it('none (or an unrecognized preset) returns an empty set', () => {
    expect(applyPreset(rows, 'none', null)).toEqual(new Set());
    expect(applyPreset(rows, 'bogus', null)).toEqual(new Set());
  });
});

/**
 * Coordinator-requested fix (post-review): every adjustment/value column in `Rows`/`SortableRows`
 * DISPLAYS the live, recomputed `SalesCompResult` value -- never the batch-stored `ValuationCompRow`
 * column. So sorting by that column must also read the live value, or the row order silently stops
 * matching what's on screen the moment `Coefficients` diverges from the batch's own stored constants
 * (which is Task 7's entire purpose). This fixture deliberately makes the two disagree on 'size':
 * the live recompute (default sizeElasticity 0.10, subject denom 1000) puts 'hi' (CompDenominator
 * 2000) ABOVE zero and 'lo' (CompDenominator 500) BELOW zero, while the batch-STORED SizeAdjPct
 * columns are set to the opposite sign on purpose, so sorting by the live key vs. the stale stored
 * key produces genuinely different, checkable orderings.
 */
describe('AnalysisSalesComponent — column sort tracks the LIVE recomputed value, not the stale stored one', () => {
  const parcel: ParcelRow = { ID: 'p1', ParcelNumber: '49-01-01-000-001.000-001', GISParcelNumber: null, Address: null, OwnerName: null, PropertyClassCode: null, CountyNumber: 49 };
  const analysis: AnalysisRow = {
    ID: 'a1', ParcelID: 'p1', AssessmentYear: 2026, Name: 'Test analysis', PropertyTypeGroup: 'Multifamily', Status: 'Draft',
    UnitOfComparison: '$/SF', SubjectDenominator: 1000, CurrentTotalAV: null, PriorTotalAV: null, BurdenOnAssessor: null,
    AskPolicy: 'Lowest', RequestedValue: null, RequestedValueApproach: null, FloorValue: null, FloorApproach: null,
    Recommendation: null, EstimatedTaxSavings: null, SavingsRate: null, Comments: null, ValuationAnalysisID: null, ComparableAssessmentSetID: null,
  };
  // 'hi' has a bigger CompDenominator than the subject (1000) -> live sizeAdjPct is POSITIVE.
  // 'lo' has a smaller one -> live sizeAdjPct is NEGATIVE. SaleDate == the analysis's own lien
  // date (2026-01-01) zeroes the time factor; null CompYearBuilt/CompGradeOrdinal zero age/grade.
  const compHi = comp({ SaleTransactionID: 'hi', CompDenominator: 2000, CompYearBuilt: null, CompGradeOrdinal: null, SaleDate: '2026-01-01', SizeAdjPct: -0.05, IsSelected: true, SimilarityRank: 1 });
  const compLo = comp({ SaleTransactionID: 'lo', CompDenominator: 500, CompYearBuilt: null, CompGradeOrdinal: null, SaleDate: '2026-01-01', SizeAdjPct: 0.05, IsSelected: true, SimilarityRank: 2 });
  const subject: SubjectBundle = {
    parcel, record: null, assessments: [], valuation: null, comps: [compHi, compLo], compSet: null, compMembers: [],
    memberParcels: {}, ptaboa: [], ibtr: [], costar: null, marketAssumptions: [], typeGroup: 'Multifamily', subjectGradeOrdinal: null,
  };

  function buildComponent(sortColumn: 'sizeAdjPct' | 'SizeAdjPct'): AnalysisSalesComponent {
    const c = new AnalysisSalesComponent();
    c.Subject = subject;
    c.Analysis = analysis;
    c.SalesAssumptions = []; // brand-new analysis -> Coefficients falls back to the batch defaults: sizeElasticity 0.10, enabled
    c.SortColumn = sortColumn;
    c.SortDirection = 'asc';
    return c;
  }

  it('confirms the fixture: live recompute and the stale stored column genuinely disagree on sign', () => {
    const results = buildComponent('sizeAdjPct').Results;
    const hi = results.find((r) => r.id === 'hi')!;
    const lo = results.find((r) => r.id === 'lo')!;
    expect(hi.sizeAdjPct).toBeGreaterThan(0); // live: bigger comp -> positive
    expect(lo.sizeAdjPct).toBeLessThan(0);    // live: smaller comp -> negative
    // batch-stored columns were set to the opposite sign on purpose (see comp() calls above)
    expect(compHi.SizeAdjPct).toBeLessThan(0);
    expect(compLo.SizeAdjPct).toBeGreaterThan(0);
  });

  it('sorting ascending by the live key (sizeAdjPct) orders rows by the recomputed value', () => {
    const ids = buildComponent('sizeAdjPct').SortableRows.map((r) => r.SaleTransactionID);
    expect(ids).toEqual(['lo', 'hi']); // lo's live value is negative, hi's is positive
  });

  it('sorting ascending by the stale stored key (SizeAdjPct) would give the OPPOSITE order -- proving live and stored are genuinely different data paths', () => {
    const ids = buildComponent('SizeAdjPct').SortableRows.map((r) => r.SaleTransactionID);
    expect(ids).toEqual(['hi', 'lo']);
  });
});

/**
 * Task 7: the coefficients panel and the live summary block. `OnCoefficientEdit` follows Income's
 * one-way-data-flow pattern (emit, don't mutate in place) -- see analysis-sales.component.ts's
 * `OnCoefficientEdit` doc comment -- so these tests read the emitted working set, not component state.
 */
describe('OnCoefficientEdit — flips only the edited row to Analyst', () => {
  function buildComponent(): AnalysisSalesComponent {
    const c = new AnalysisSalesComponent();
    c.SalesAssumptions = []; // brand-new analysis -> the 8 proposed defaults, all Source: 'Default'
    return c;
  }

  it('editing one coefficient rate flips only its own Source to Analyst; the other seven rows are untouched', () => {
    const c = buildComponent();
    let emitted: AssumptionRow[] = [];
    c.AssumptionsChanged.subscribe((rows) => { emitted = rows; });

    c.OnCoefficientEdit(SALES_KEYS.sizeRate, 0.25);

    expect(emitted).toHaveLength(8);
    const changed = emitted.find((r) => r.AssumptionKey === SALES_KEYS.sizeRate)!;
    expect(changed.Value).toBe(0.25);
    expect(changed.Source).toBe('Analyst');
    const untouched = emitted.filter((r) => r.AssumptionKey !== SALES_KEYS.sizeRate);
    expect(untouched).toHaveLength(7);
    for (const r of untouched) expect(r.Source).toBe('Default');
  });

  it('editing an enable flag (boolean) coerces to 0/1 and flips only that row to Analyst', () => {
    const c = buildComponent();
    let emitted: AssumptionRow[] = [];
    c.AssumptionsChanged.subscribe((rows) => { emitted = rows; });

    c.OnCoefficientEdit(SALES_KEYS.ageEnabled, false);

    const changed = emitted.find((r) => r.AssumptionKey === SALES_KEYS.ageEnabled)!;
    expect(changed.Value).toBe(0);
    expect(changed.Source).toBe('Analyst');
    const untouched = emitted.filter((r) => r.AssumptionKey !== SALES_KEYS.ageEnabled);
    expect(untouched).toHaveLength(7);
    for (const r of untouched) expect(r.Source).toBe('Default');
  });

  /**
   * Coordinator-requested fix (post-review): the panel's chip was hardcoded to `f.Rate.Source`,
   * so toggling ONLY the enable flag (rate left untouched at Default) still showed "Default" --
   * the panel's only provenance signal reading as "nothing here was touched" when the underlying
   * data was genuinely edited. `Factors[].Source` (via `factorSource`) must read Analyst here.
   */
  it('toggling only the enable flag (rate left at Default) makes the row-level Factors.Source Analyst, not Default', () => {
    const c = buildComponent();
    let emitted: AssumptionRow[] = [];
    c.AssumptionsChanged.subscribe((rows) => { emitted = rows; });

    c.OnCoefficientEdit(SALES_KEYS.ageEnabled, false); // toggle OFF; rate never touched

    c.SalesAssumptions = emitted; // one-way data flow: the parent hands the working set back via the Input
    const ageFactor = c.Factors.find((f) => f.EnabledKey === SALES_KEYS.ageEnabled)!;
    expect(ageFactor.Enabled.Source).toBe('Analyst');
    expect(ageFactor.Rate.Source).toBe('Default'); // confirms the rate genuinely wasn't touched
    expect(ageFactor.Source).toBe('Analyst'); // the combined chip value must reflect the enable-flag edit too
  });
});

describe('factorSource — the coefficients panel\'s single combined Source', () => {
  const row = (source: AssumptionRow['Source'], key: string): AssumptionRow => ({
    ID: '', AppealAnalysisID: '', Section: 'Sales', AssumptionKey: key, Label: key, Value: 1, Unit: '',
    Mode: 'rate', Source: source, SourceRef: null, ProposedValue: 1, ProposedSource: source, SortOrder: 1,
  });

  it('is Analyst when only the enable flag is Analyst-sourced', () => {
    expect(factorSource(row('Analyst', 'enabled'), row('Default', 'rate'))).toBe('Analyst');
  });
  it('is Analyst when only the rate is Analyst-sourced', () => {
    expect(factorSource(row('Default', 'enabled'), row('Analyst', 'rate'))).toBe('Analyst');
  });
  it('is Analyst when both are Analyst-sourced', () => {
    expect(factorSource(row('Analyst', 'enabled'), row('Analyst', 'rate'))).toBe('Analyst');
  });
  it('falls back to the rate\'s own Source when neither half is Analyst-sourced', () => {
    expect(factorSource(row('Default', 'enabled'), row('Default', 'rate'))).toBe('Default');
    expect(factorSource(row('Default', 'enabled'), row('Market', 'rate'))).toBe('Market');
    expect(factorSource(row('County', 'enabled'), row('County', 'rate'))).toBe('County');
  });
});

describe('Indication — belowMinimum and the adjusted-vs-unadjusted live summary', () => {
  const parcel2: ParcelRow = { ID: 'p2', ParcelNumber: '49-01-01-000-002.000-001', GISParcelNumber: null, Address: null, OwnerName: null, PropertyClassCode: null, CountyNumber: 49 };
  const analysis2: AnalysisRow = {
    ID: 'a2', ParcelID: 'p2', AssessmentYear: 2026, Name: 'Test analysis 2', PropertyTypeGroup: 'Multifamily', Status: 'Draft',
    UnitOfComparison: '$/SF', SubjectDenominator: 1000, CurrentTotalAV: null, PriorTotalAV: null, BurdenOnAssessor: null,
    AskPolicy: 'Lowest', RequestedValue: null, RequestedValueApproach: null, FloorValue: null, FloorApproach: null,
    Recommendation: null, EstimatedTaxSavings: null, SavingsRate: null, Comments: null, ValuationAnalysisID: null, ComparableAssessmentSetID: null,
  };
  // Three comps, all IsSelected -- inclusion is driven entirely by `Decisions`, set directly per test below.
  // Same fixed SaleDate ('2025-01-01', from the shared `comp()` factory) as the analysis's lien date
  // (2026-01-01) so every comp picks up a nonzero, non-degenerate timeAdjPct under the batch defaults --
  // guaranteeing the adjusted indication diverges from the raw one regardless of the varying CompDenominator.
  const c1 = comp({ SaleTransactionID: 'c1', CompDenominator: 2000, IsSelected: true, SimilarityRank: 1 });
  const c2 = comp({ SaleTransactionID: 'c2', CompDenominator: 1500, IsSelected: true, SimilarityRank: 2 });
  const c3 = comp({ SaleTransactionID: 'c3', CompDenominator: 800, IsSelected: true, SimilarityRank: 3 });
  const subject2: SubjectBundle = {
    parcel: parcel2, record: null, assessments: [], valuation: null, comps: [c1, c2, c3], compSet: null, compMembers: [],
    memberParcels: {}, ptaboa: [], ibtr: [], costar: null, marketAssumptions: [], typeGroup: 'Multifamily', subjectGradeOrdinal: null,
  };

  function buildComponent(): AnalysisSalesComponent {
    const c = new AnalysisSalesComponent();
    c.Subject = subject2;
    c.Analysis = analysis2;
    c.SalesAssumptions = []; // batch defaults, all factors enabled
    return c;
  }
  const included = (ids: string[]) => new Map(['c1', 'c2', 'c3'].map((id) => [id, { isIncluded: ids.includes(id), sortOrder: null, touched: false }]));

  it('belowMinimum is true with 2 included comps and false with 3', () => {
    const c = buildComponent();
    c.Decisions = included(['c1', 'c2']);
    expect(c.Indication.comps).toBe(2);
    expect(c.Indication.belowMinimum).toBe(true);

    c.Decisions = included(['c1', 'c2', 'c3']);
    expect(c.Indication.comps).toBe(3);
    expect(c.Indication.belowMinimum).toBe(false);
  });

  it('the adjusted indicated value differs from the unadjusted one once an enabled coefficient produces a nonzero adjustment', () => {
    const c = buildComponent();
    c.Decisions = included(['c1', 'c2', 'c3']);
    const ind = c.Indication;
    expect(ind.value).not.toBeNull();
    expect(ind.unadjustedValue).not.toBeNull();
    expect(ind.value).not.toBe(ind.unadjustedValue);
  });
});

/**
 * Fix 1 (final whole-plan review, Critical) -- regression coverage for the data-loss bug: the old
 * design reseeded a local `Decisions` map from a raw `CompDecisions: CompDecisionRow[]` @Input on
 * ANY change to Subject/Analysis/CompDecisions, including a tab switch (which destroys and
 * recreates this component via the shell's `@switch`) and the shell's own `reseedSales=false`
 * round-trip. The fix makes `Decisions` itself the @Input -- the parent's own live-edit
 * `Map<string, CompDecisionDraft>`, never re-derived here -- so there is nothing left in this
 * component to reseed. These tests exercise both trigger scenarios from Ruling 8's own bug
 * description and assert the analyst's prior exclusion survives each one.
 */
describe('Fix 1 — Decisions is the parent\'s own live-edit map, never reseeded from a database Input', () => {
  const parcel3: ParcelRow = { ID: 'p3', ParcelNumber: '49-01-01-000-003.000-001', GISParcelNumber: null, Address: null, OwnerName: null, PropertyClassCode: null, CountyNumber: 49 };
  const analysis3: AnalysisRow = {
    ID: 'a3', ParcelID: 'p3', AssessmentYear: 2026, Name: 'Test analysis 3', PropertyTypeGroup: 'Multifamily', Status: 'Draft',
    UnitOfComparison: '$/SF', SubjectDenominator: 1000, CurrentTotalAV: null, PriorTotalAV: null, BurdenOnAssessor: null,
    AskPolicy: 'Lowest', RequestedValue: null, RequestedValueApproach: null, FloorValue: null, FloorApproach: null,
    Recommendation: null, EstimatedTaxSavings: null, SavingsRate: null, Comments: null, ValuationAnalysisID: null, ComparableAssessmentSetID: null,
  };
  // All three default IsSelected=true, so with an empty Decisions map every comp starts 'included'.
  const d1 = comp({ SaleTransactionID: 'd1', IsSelected: true, SimilarityRank: 1 });
  const d2 = comp({ SaleTransactionID: 'd2', IsSelected: true, SimilarityRank: 2 });
  const d3 = comp({ SaleTransactionID: 'd3', IsSelected: true, SimilarityRank: 3 });
  const subject3: SubjectBundle = {
    parcel: parcel3, record: null, assessments: [], valuation: null, comps: [d1, d2, d3], compSet: null, compMembers: [],
    memberParcels: {}, ptaboa: [], ibtr: [], costar: null, marketAssumptions: [], typeGroup: 'Multifamily', subjectGradeOrdinal: null,
  };

  function buildComponent(decisions: Map<string, CompDecisionDraft>): AnalysisSalesComponent {
    const c = new AnalysisSalesComponent();
    c.Subject = subject3;
    c.Analysis = analysis3;
    c.SalesAssumptions = []; // brand-new analysis -> batch defaults
    c.Decisions = decisions;
    return c;
  }

  it('an analyst exclusion survives a simulated tab-switch destroy/recreate: the recreated component is handed the SAME parent Decisions map, not a fresh/reset one', () => {
    // The analyst excludes d2 on the pre-switch component instance.
    const before = buildComponent(new Map());
    before.ToggleRow('d2', false);
    const carriedForward = before.Decisions; // what the shell's SalesDecisions now holds, per OnSalesDecisionsChanged

    // Simulate the shell's `@switch` destroying and recreating AnalysisSalesComponent on a tab
    // switch: a BRAND-NEW instance, bound with `[Decisions]="SalesDecisions"` -- i.e. handed the
    // exact same map the prior instance just produced.
    const after = buildComponent(carriedForward);
    const d2Row = after.Rows.find((r) => r.SaleTransactionID === 'd2')!;
    expect(d2Row.state).toBe('available'); // still excluded -- NOT reset back to 'included'
  });

  it('a reseedSales=false round-trip (Subject/Analysis/SalesAssumptions reassigned to fresh references, Decisions left alone) leaves a prior exclusion untouched', () => {
    const decisions = new Map<string, CompDecisionDraft>([['d1', { isIncluded: false, sortOrder: null, touched: true }]]);
    const c = buildComponent(decisions);
    expect(c.Rows.find((r) => r.SaleTransactionID === 'd1')!.state).toBe('available');

    // Mimics what the shell's own reseedSales=false round-trip does after a bare Recompute/
    // SaveHeader: Subject/Analysis/SalesAssumptions get reassigned to fresh object references (a
    // real reload from the DB), but SalesDecisions is deliberately NOT reassigned. There is no
    // ngOnChanges left in this component to react to that reassignment and reseed Decisions from
    // a database read, so the analyst's exclusion survives untouched.
    c.Subject = { ...subject3 };
    c.Analysis = { ...analysis3 };
    c.SalesAssumptions = [...c.SalesAssumptions];
    expect(c.Rows.find((r) => r.SaleTransactionID === 'd1')!.state).toBe('available');
  });

  /**
   * Re-review finding: the two tests above drive the component class directly and never invoke
   * Angular's `ngOnChanges` lifecycle hook, so they'd pass identically whether or not a buggy
   * `ngOnChanges`-based reseed existed -- proven empirically by running these exact tests against
   * a reconstructed pre-fix component (which also passed). The actual fix is structural: the
   * component has no `ngOnChanges` at all -- `Decisions` is a plain @Input bound directly to the
   * parent's own persistent state, with no reseed-on-change logic anywhere in the component. This
   * test guards against that specific regression class directly: a future edit reintroducing a
   * reseed-on-change lifecycle hook fails this test immediately, without relying on a lifecycle
   * call the unit tests never make.
   */
  it('has no ngOnChanges reseed hook (regression guard: the fix removed the database-driven reseed entirely)', () => {
    const c = new AnalysisSalesComponent();
    expect((c as { ngOnChanges?: unknown }).ngOnChanges).toBeUndefined();
  });
});
