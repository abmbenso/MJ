import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit, OnDestroy } from '@angular/core';
import { BaseDashboard, BaseResourceComponent, SharedService } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData } from '@memberjunction/core-entities';
import { RunView, UserInfo } from '@memberjunction/core';
import { TabConfig } from '@memberjunction/ng-ui-components';
import type {
  indianataxAppealAnalysisEntity, indianataxAppealAnalysisAssumptionEntity, indianataxAppealAnalysisIndicationEntity,
  indianataxAppealAnalysisCompDecisionEntity,
} from 'mj_generatedentities';

import { reconcile, burdenOnAssessor, estimateSavings, Reconciliation, AskPolicy, COMMERCIAL_CAP } from './appeal-rules';
import { computeIncomeApproach } from './income-approach';
import { computeCompAdjustment, salesIndicatedValue, SalesCompInput, SalesCompResult, SalesSubjectInput, SALES_MINIMUM_COMPS } from './sales-approach';
import { proposeIncomeAssumptions, assumptionsToIncomeInputs, assumptionsToSalesCoefficients, proposeSalesAssumptions, ProposedAssumption } from './analysis-defaults';
import { parseViewParams, formatViewParams, SectionKey, SECTION_KEYS } from './analysis-view-params';
import { compsIndication } from './sections/comps-indication';
import { resolveCompState, CompDecisionDraft } from './sections/analysis-sales.component';
import { AppealExportInput, PrintSection, buildAppealExport, exportToDocument } from './appeal-export';
import {
  EntityReader, ReadQuery, SubjectBundle, AnalysisRow, AssumptionRow, IndicationRow, CompDecisionRow, ValuationCompRow, ENTITIES,
  loadSubject, listAnalyses, loadAnalysis, finalAV, subjectFacts, marketFacts, sqlLiteral,
  CURRENT_ASSESSMENT_YEAR, MARION_COUNTY_NUMBER,
} from './analysis-store';

/** The batch script's own field mapping, matching AnalysisSalesComponent's private toCompInput exactly -- the Sales tab and the shell's Recompute must price every comp identically. */
function toSalesCompInput(c: ValuationCompRow): SalesCompInput {
  return { id: c.SaleTransactionID, rawPerUnit: c.RawPerUnit ?? 0, compDenominator: c.CompDenominator ?? 0, compYearBuilt: c.CompYearBuilt, compGradeOrdinal: c.CompGradeOrdinal, saleDate: c.SaleDate ?? '' };
}

/** A brand-new analysis (or one never opened on the Sales tab) has no saved Section='Sales' rows -- fall back to the batch's own proposed defaults, matching AnalysisSalesComponent's private toAssumptionRow. IDs are placeholders: SaveAssumptions creates the real rows on first Save. */
function toSalesAssumptionRow(p: ProposedAssumption): AssumptionRow {
  return {
    ID: '', AppealAnalysisID: '', Section: p.section, AssumptionKey: p.key, Label: p.label,
    Value: p.value, Unit: p.unit, Mode: p.mode, Source: p.source, SourceRef: p.sourceRef,
    ProposedValue: p.value, ProposedSource: p.source, SortOrder: p.sortOrder,
  };
}

/** Mirrors AnalysisSalesComponent's private seedDecisions: saved CompDecisionRows -> a working draft map, all untouched. */
function seedSalesDecisions(rows: CompDecisionRow[]): Map<string, CompDecisionDraft> {
  const map = new Map<string, CompDecisionDraft>();
  for (const d of rows) map.set(d.SaleTransactionID, { isIncluded: d.IsIncluded, sortOrder: d.SortOrder, touched: false });
  return map;
}

export const INDIANA_APP_ID = 'A20836AC-1F4B-4A50-B5A1-B5728CFAD6AC';
export const TAX_PROJECTION_NAV_LABEL = 'Tax Bill Projection V2';

interface ParcelHit { ID: string; GISParcelNumber: string; Address: string; }

const SECTION_TABS: TabConfig[] = [
  { key: 'cover', label: 'Cover page', icon: 'fa-solid fa-file-lines' },
  { key: 'sales', label: 'Sales analysis', icon: 'fa-solid fa-tags' },
  { key: 'income', label: 'Income analysis', icon: 'fa-solid fa-coins' },
  { key: 'comps', label: 'Assessment comps', icon: 'fa-solid fa-scale-balanced' },
  { key: 'cost', label: 'Cost analysis', icon: 'fa-solid fa-hammer' },
  { key: 'tax', label: 'Tax projection', icon: 'fa-solid fa-file-invoice-dollar' },
  { key: 'decisions', label: 'Decisions', icon: 'fa-solid fa-gavel' },
];

/**
 * Analyze a Property — the Appeal Workbench's centre. Pick a parcel, open (or start) an
 * analysis, walk the approaches; every figure shown is a stored row or the output of one
 * pure function over stored rows. Registered under BOTH BaseDashboard and
 * BaseResourceComponent: the Explorer shell resolves nav items through the latter
 * (baseline §5; PropertySearch's comment at line 127 explains the failure otherwise).
 */
@Component({
  standalone: false,
  selector: 'mj-appeal-workbench',
  templateUrl: './appeal-workbench.component.html',
  styleUrls: ['./appeal-workbench.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'AppealWorkbenchResource')
@RegisterClass(BaseResourceComponent, 'AppealWorkbenchResource')
export class AppealWorkbenchComponent extends BaseDashboard implements AfterViewInit, OnDestroy {
  public IsLoading = false;
  public IsSaving = false;
  public LoadError: string | null = null;
  public Notice: string | null = null;

  public SearchTerm = '';
  public SearchResults: ParcelHit[] = [];
  public IsSearching = false;

  public Subject: SubjectBundle | null = null;
  public Analyses: AnalysisRow[] = [];
  public Analysis: AnalysisRow | null = null;
  public Assumptions: AssumptionRow[] = [];
  public Indications: IndicationRow[] = [];
  /** Saved AppealAnalysisCompDecision rows for the open analysis -- loadAnalysis's sibling of Assumptions/Indications (analysis-store.ts's own doc-comment on why it isn't nested in SubjectBundle). */
  public CompDecisions: CompDecisionRow[] = [];
  /** The Sales tab's working Section='Sales' assumption set (Task 7's AssumptionsChanged output) -- empty until the analyst edits a coefficient or Save creates the rows for the first time. */
  public SalesAssumptionsWorking: AssumptionRow[] = [];
  /** The Sales tab's working comp-inclusion decisions (Task 6's DecisionsChanged output), keyed by SaleTransactionID -- seeded from CompDecisions on load, replaced wholesale on every edit. */
  public SalesDecisions: Map<string, CompDecisionDraft> = new Map();
  public Reconciled: Reconciliation | null = null;
  public Savings: { atAsk: ReturnType<typeof estimateSavings>; atFloor: ReturnType<typeof estimateSavings> } | null = null;
  /** I4: >0 while the Income section has unsaved edits — Recompute and New analysis are disabled until saved or reverted. */
  public IncomeDirty = 0;

  /** The Cover tab's Print Package dialog (Task 10) — visibility + the checklist of sections actually present in the current export model. */
  public PrintDialogVisible = false;
  public PrintDialogSections: Array<{ key: PrintSection; label: string; checked: boolean }> = [];

  public ActiveSection: SectionKey = 'cover';
  public readonly Tabs = SECTION_TABS;

  private searchDebounce: ReturnType<typeof setTimeout> | null = null;
  private searchSeq = 0;

  constructor(private cdr: ChangeDetectorRef) { super(); }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> { return 'Analyze a Property'; }

  initDashboard(): void { /* nothing one-time; the URL drives the first load */ }

  async loadData(): Promise<void> { await this.applyViewParams(this.initialParams()); }

  ngAfterViewInit(): void { this.publishAgentContext(); }
  ngOnDestroy(): void { super.ngOnDestroy(); if (this.searchDebounce) clearTimeout(this.searchDebounce); }

  // ───── URL state (the Tax Bill Projection pattern: address bar beats cached tab on first mount) ─────
  private initialParams(): Record<string, string> {
    const fromTab = this.GetQueryParams();
    if (typeof window === 'undefined' || !window.location?.search) return fromTab;
    const url = new URLSearchParams(window.location.search);
    const parcel = url.get('parcel');
    if (!parcel || parcel === fromTab['parcel']) return fromTab;
    const merged: Record<string, string> = { ...fromTab };
    for (const key of ['parcel', 'analysis', 'section']) { const v = url.get(key); if (v != null) merged[key] = v; else delete merged[key]; }
    return merged;
  }
  protected override OnQueryParamsChanged(params: Record<string, string>): void { void this.applyViewParams(params); }
  private async applyViewParams(params: Record<string, string>): Promise<void> {
    const wanted = parseViewParams(params);
    if (wanted.section !== this.ActiveSection) this.ActiveSection = wanted.section;
    if (!wanted.parcelId) { this.clearSubject(); }
    else if (wanted.parcelId !== this.Subject?.parcel.ID) { await this.openParcel(wanted.parcelId, wanted.analysisId); }
    else if (wanted.analysisId && wanted.analysisId !== this.Analysis?.ID) {
      try { await this.openAnalysis(wanted.analysisId, true); }
      catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    }
    this.publishAgentContext();
    this.cdr.markForCheck();
  }
  private syncQueryParams(): void {
    this.UpdateQueryParams(formatViewParams({ parcelId: this.Subject?.parcel.ID ?? null, analysisId: this.Analysis?.ID ?? null, section: this.ActiveSection }));
  }

  // ───── MJ plumbing behind the store's EntityReader ─────
  private get reader(): EntityReader {
    const provider = this.ProviderToUse;
    return {
      run: async <T>(q: ReadQuery): Promise<T[]> => {
        const r = await RunView.FromMetadataProvider(provider).RunView<T>({
          EntityName: q.entity, Fields: q.fields, ExtraFilter: q.filter, OrderBy: q.orderBy, MaxRows: q.maxRows ?? 500, ResultType: 'simple',
        });
        if (!r.Success) throw new Error(`${q.entity}: ${r.ErrorMessage ?? 'read failed'}`);
        return r.Results ?? [];
      },
    };
  }
  private get user(): UserInfo { return this.ProviderToUse.CurrentUser; }

  // ───── Parcel search ─────
  public OnSearchTermChange(term: string): void {
    this.SearchTerm = term;
    if (this.searchDebounce) clearTimeout(this.searchDebounce);
    if (term.trim().length < 3) { this.SearchResults = []; this.cdr.markForCheck(); return; }
    this.searchDebounce = setTimeout(() => void this.runParcelSearch(term), 300);
  }
  private async runParcelSearch(term: string): Promise<void> {
    const seq = ++this.searchSeq;
    this.IsSearching = true; this.cdr.markForCheck();
    const esc = sqlLiteral(term);
    try {
      const hits = await this.reader.run<ParcelHit>({
        entity: ENTITIES.parcels, fields: ['ID', 'GISParcelNumber', 'Address'],
        filter: `CountyNumber = ${MARION_COUNTY_NUMBER} AND (Address LIKE '%${esc}%' OR GISParcelNumber = '${esc}' OR ParcelNumber = '${esc}')`,
        orderBy: 'Address ASC', maxRows: 15,
      });
      if (seq !== this.searchSeq) return;
      this.SearchResults = hits;
    } catch (e) { if (seq === this.searchSeq) this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { if (seq === this.searchSeq) { this.IsSearching = false; this.cdr.markForCheck(); } }
  }
  public async SelectParcel(hit: ParcelHit): Promise<void> {
    this.SearchResults = [];
    this.SearchTerm = `${hit.GISParcelNumber} — ${hit.Address}`;
    await this.openParcel(hit.ID, null);
    this.syncQueryParams();
  }

  // ───── Subject + analysis lifecycle ─────
  private clearSubject(): void {
    this.Subject = null; this.Analyses = []; this.Analysis = null; this.Assumptions = []; this.Indications = [];
    this.CompDecisions = []; this.SalesAssumptionsWorking = []; this.SalesDecisions = new Map();
    this.Reconciled = null; this.Savings = null; this.SearchTerm = ''; this.LoadError = null; this.Notice = null;
  }
  private async openParcel(parcelId: string, analysisId: string | null): Promise<void> {
    this.IsLoading = true; this.LoadError = null; this.cdr.markForCheck();
    try {
      const bundle = await loadSubject(this.reader, parcelId);
      // I1: clear first, THEN set the error — clearSubject() nulls LoadError, so setting it first would be immediately erased.
      if (!bundle) { this.clearSubject(); this.LoadError = `The parcel in this link (${parcelId}) no longer exists.`; return; }
      this.Subject = bundle;
      this.SearchTerm = `${bundle.parcel.GISParcelNumber ?? bundle.parcel.ParcelNumber} — ${bundle.parcel.Address ?? ''}`;
      this.Analyses = await listAnalyses(this.reader, parcelId);
      const target = analysisId ?? this.Analyses.find((a) => a.Status === 'Draft')?.ID ?? this.Analyses[0]?.ID ?? null;
      if (target) await this.openAnalysis(target, true);
      else {
        this.Analysis = null; this.Assumptions = []; this.Indications = [];
        this.CompDecisions = []; this.SalesAssumptionsWorking = []; this.SalesDecisions = new Map();
        this.Reconciled = null; this.Savings = null;
      }
    } catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { this.IsLoading = false; this.cdr.markForCheck(); }
  }
  public async OpenAnalysis(analysisId: string): Promise<void> {
    try { await this.openAnalysis(analysisId, true); this.syncQueryParams(); }
    catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { this.cdr.markForCheck(); }
  }
  /**
   * `reseedSales` defaults to false -- deliberately NOT the same "always reset" pattern Income
   * uses (Income's Rows/Dirty reset whenever its Assumptions input reference changes, because
   * Income's own Save button always persists first). A bare Recompute() must compute the Sales
   * indication from the analyst's live, not-yet-saved SalesAssumptionsWorking/SalesDecisions
   * (per the brief's own manual-verification script: exclude a comp, edit the age rate, THEN
   * Recompute -- before ever clicking Save) and must NOT wipe them back to the DB's still-stale
   * copy afterward. Only a genuine switch to a different/fresh analysis, or a reload right after
   * SaveAssumptions has actually persisted the Sales rows, should pass reseedSales: true.
   */
  private async openAnalysis(analysisId: string, reseedSales = false): Promise<void> {
    const loaded = await loadAnalysis(this.reader, analysisId);
    if (!loaded) { this.LoadError = `Analysis ${analysisId} no longer exists.`; return; }
    this.Analysis = loaded.analysis; this.Assumptions = loaded.assumptions; this.Indications = loaded.indications;
    this.CompDecisions = loaded.compDecisions;
    if (reseedSales) {
      this.SalesAssumptionsWorking = this.Assumptions.filter((r) => r.Section === 'Sales');
      this.SalesDecisions = seedSalesDecisions(this.CompDecisions);
    }
    this.deriveFromRows();
  }

  /** Start a new Draft for the subject: header from the record, income assumptions proposed with chips, indications seeded from the batch engines. */
  public async NewAnalysis(): Promise<void> {
    if (!this.Subject) return;
    this.IsSaving = true; this.cdr.markForCheck();
    try {
      const b = this.Subject;
      const facts = subjectFacts(b);
      const currentAV = finalAV(b.assessments, CURRENT_ASSESSMENT_YEAR) ?? b.record?.AssessedTotalAV ?? null;
      const priorAV = finalAV(b.assessments, CURRENT_ASSESSMENT_YEAR - 1);
      const perUnit = b.typeGroup === 'Multifamily';
      const a = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisEntity>(ENTITIES.appealAnalysis, this.user);
      a.NewRecord();
      a.ParcelID = b.parcel.ID;
      a.AssessmentYear = CURRENT_ASSESSMENT_YEAR;
      a.Name = `${b.parcel.Address ?? b.parcel.ParcelNumber} — AY${CURRENT_ASSESSMENT_YEAR} — ${new Date().toISOString().slice(0, 10)}`;
      a.PropertyTypeGroup = b.typeGroup;
      a.Status = 'Draft';
      a.UnitOfComparison = perUnit ? '$/unit' : '$/SF';
      a.SubjectDenominator = perUnit ? facts.units : facts.sqFt;
      a.CurrentTotalAV = currentAV;
      a.PriorTotalAV = priorAV;
      a.BurdenOnAssessor = currentAV != null ? burdenOnAssessor(currentAV, priorAV) : null;
      a.AskPolicy = 'Lowest';
      a.ValuationAnalysisID = b.valuation?.ID ?? null;
      a.ComparableAssessmentSetID = b.compSet?.ID ?? null;
      if (!(await a.Save())) throw new Error(a.LatestResult?.Message ?? 'Could not save the analysis');
      for (const p of proposeIncomeAssumptions(facts, marketFacts(b))) {
        const row = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisAssumptionEntity>(ENTITIES.appealAssumptions, this.user);
        row.NewRecord();
        row.AppealAnalysisID = a.ID; row.Section = p.section; row.AssumptionKey = p.key; row.Label = p.label; row.Value = p.value; row.Unit = p.unit;
        row.Mode = p.mode; row.Source = p.source; row.SourceRef = p.sourceRef; row.ProposedValue = p.value; row.ProposedSource = p.source; row.SortOrder = p.sortOrder;
        if (!(await row.Save())) throw new Error(row.LatestResult?.Message ?? `Could not save ${p.key}`);
      }
      this.Analyses = await listAnalyses(this.reader, b.parcel.ID);
      await this.openAnalysis(a.ID, true);
      await this.Recompute();
      this.syncQueryParams();
      this.Notice = 'New analysis started from the county record and the market data on file.';
    } catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { this.IsSaving = false; this.cdr.markForCheck(); }
  }

  // ───── Derivation: rows → results (never the other way) ─────
  /** The stored Income-section assumption rows, shaped for the income-approach engine. Shared by deriveFromRows and Recompute. */
  private incomeRows(): Array<{ key: string; label: string; mode: AssumptionRow['Mode']; value: number | null }> {
    return this.Assumptions.filter((r) => r.Section === 'Income').map((r) => ({ key: r.AssumptionKey, label: r.Label, mode: r.Mode, value: r.Value }));
  }
  private deriveFromRows(): void {
    const a = this.Analysis; if (!a) { this.Reconciled = null; this.Savings = null; return; }
    const av = a.CurrentTotalAV;
    this.Reconciled = av != null ? reconcile(this.Indications.map((i) => ({ approach: i.Approach, value: i.IndicatedValue, status: i.Status })), av, a.AskPolicy) : null;
    const rate = this.Subject?.record?.TaxRate ?? null;
    this.Savings = av != null ? { atAsk: estimateSavings(av, this.Reconciled?.ask ?? null, rate, COMMERCIAL_CAP, null), atFloor: estimateSavings(av, this.Reconciled?.floor ?? null, rate, COMMERCIAL_CAP, null) } : null;
  }

  /**
   * Every batch-seeded comp, re-priced live through the working Section='Sales' coefficients
   * (SalesAssumptionsWorking, falling back to the batch's own proposed defaults exactly as the
   * Sales tab's own workingAssumptions getter does) -- the SAME per-comp pricing salesIndication
   * uses to derive its median, and buildExportInput/printSections use to populate the printed
   * Sales section, so it's factored out once rather than reimplemented a third time.
   */
  private salesCompResults(b: SubjectBundle, a: AnalysisRow): SalesCompResult[] {
    const rows = this.SalesAssumptionsWorking.length
      ? this.SalesAssumptionsWorking.map((r) => ({ key: r.AssumptionKey, value: r.Value }))
      : proposeSalesAssumptions().map((p) => ({ key: p.key, value: p.value }));
    const coef = assumptionsToSalesCoefficients(rows);
    const subject: SalesSubjectInput = {
      denominator: a.SubjectDenominator ?? 0,
      // Fix 5 (final whole-plan review, documentation only): no true "effective year built" source
      // is currently reachable from this code -- see analysis-sales.component.ts's subjectInput
      // getter for the same substitution, which this method parallels. Age silently substitutes
      // the parcel's recorded, actual YearBuilt and computes an adjustment from it anyway --
      // coarser than the effective-age standard used elsewhere in this project, with no visible
      // indication of the substitution. This assembly point is the higher-consequence one: its
      // output feeds both the persisted Sales indication (via Recompute) and the printed package
      // (via the print/export wiring) -- the document an analyst hands to an assessor. Sourcing a
      // real EffectiveYear is out of scope for this fix; this comment (and the Sales tab's own
      // on-screen note) is the fix.
      effectiveYearBuilt: b.record?.YearBuilt ?? null,
      gradeOrdinal: b.subjectGradeOrdinal ?? null,
      lienDate: `${a.AssessmentYear}-01-01`,
    };
    return b.comps.map((c) => computeCompAdjustment(subject, toSalesCompInput(c), coef));
  }

  /**
   * The live Sales indication from the SAME inputs AnalysisSalesComponent itself uses:
   * salesCompResults (above) and every comp's inclusion state (salesIncludedIds). Nothing here
   * is persisted -- Recompute writes only the resulting IndicationRow, same as Income.
   */
  private salesIndication(b: SubjectBundle, a: AnalysisRow): { value: number | null; comps: number; belowMinimum: boolean } {
    const results = this.salesCompResults(b, a);
    return salesIndicatedValue(results, this.salesIncludedIds(b.comps), a.SubjectDenominator ?? 0);
  }

  /**
   * Merges each comp's own IsSelected default with the working decision (a saved
   * CompDecisionRow, or the Sales tab's own not-yet-saved edit via DecisionsChanged) -- the
   * exact same merge AnalysisSalesComponent's resolveCompState/Rows performs. Re-derived here
   * (rather than reusing that component's decisionRow(), which is private) by building the same
   * shape resolveCompState expects, since resolveCompState itself IS exported and reused as-is.
   */
  private salesIncludedIds(comps: ValuationCompRow[]): Set<string> {
    const ids = new Set<string>();
    for (const c of comps) {
      const draft = this.SalesDecisions.get(c.SaleTransactionID);
      const decisionRow: CompDecisionRow | undefined = draft
        ? { ID: c.SaleTransactionID, AppealAnalysisID: this.Analysis?.ID ?? '', SaleTransactionID: c.SaleTransactionID, IsIncluded: draft.isIncluded, SortOrder: draft.sortOrder }
        : undefined;
      if (resolveCompState(c, decisionRow) === 'included') ids.add(c.SaleTransactionID);
    }
    return ids;
  }

  /** Recompute every indication from its source, reconcile, and write the rows back. */
  public async Recompute(): Promise<void> {
    const a = this.Analysis, b = this.Subject; if (!a || !b) return;
    this.IsSaving = true; this.cdr.markForCheck();
    try {
      const incomeRows = this.incomeRows();
      const income = incomeRows.length ? computeIncomeApproach(assumptionsToIncomeInputs(incomeRows)) : null;
      const denom = a.SubjectDenominator;
      const ci = compsIndication(b.compSet, denom, a.UnitOfComparison);
      const sales = this.salesIndication(b, a);
      const wanted: Array<{ approach: IndicationRow['Approach']; value: number | null; status: IndicationRow['Status']; rationale: string }> = [
        { approach: 'Income', value: income?.value ?? null, status: income?.complete ? 'Computed' : 'NotProvided', rationale: income?.complete ? `NOI ${Math.round(income.noi).toLocaleString()} ÷ ${(income.appliedCap * 100).toFixed(2)}%` : `Missing: ${income?.missing.join(', ') ?? 'income assumptions'}` },
        { approach: 'Sales', value: sales.value, status: sales.value != null ? 'Computed' : 'NotProvided', rationale: sales.value != null ? `Median of ${sales.comps} included comp${sales.comps === 1 ? '' : 's'}${sales.belowMinimum ? ` (below the ${SALES_MINIMUM_COMPS}-comp minimum)` : ''}` : (b.comps.length ? 'No comps currently included' : 'No sales comps on file') },
        { approach: 'AssessmentComps', value: ci.value, status: ci.value != null ? 'Computed' : 'NotProvided', rationale: ci.basis },
        { approach: 'Cost', value: b.valuation?.CostProxyValue ?? null, status: b.valuation?.CostProxyValue != null ? 'Computed' : 'NotProvided', rationale: b.valuation?.CostProxyNote ?? "The county's own cost figure; a sanity anchor, not an argument" },
        { approach: 'ActualIE', value: null, status: 'NotProvided', rationale: 'Owner income and expenses not provided' },
      ];
      const existing = new Map(this.Indications.map((i) => [i.Approach, i.ID]));
      const av = a.CurrentTotalAV ?? 0;
      const rec = reconcile(wanted.map((w) => ({ approach: w.approach, value: w.value, status: w.status })), av, a.AskPolicy);
      const now = new Date();
      for (const w of wanted) {
        const row = rec.rows.find((r) => r.approach === w.approach)!;
        const id = existing.get(w.approach);
        const e = id
          ? await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisIndicationEntity>(ENTITIES.appealIndications, this.user).then(async (x) => { await x.Load(id); return x; })
          : await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisIndicationEntity>(ENTITIES.appealIndications, this.user).then((x) => { x.NewRecord(); x.AppealAnalysisID = a.ID; x.Approach = w.approach; return x; });
        e.IndicatedValue = w.value; e.PerUnit = w.value != null && denom ? w.value / denom : null; e.PctOfAV = row.pctOfAV;
        e.Credible = row.credible; e.Supports = row.supports; e.Status = w.status; e.Rationale = w.rationale; e.ComputedAt = now;
        if (!(await e.Save())) throw new Error(e.LatestResult?.Message ?? `Could not save ${w.approach}`);
      }
      const rate = b.record?.TaxRate ?? null;
      const s = estimateSavings(av, rec.ask, rate, COMMERCIAL_CAP, null);
      const h = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisEntity>(ENTITIES.appealAnalysis, this.user);
      await h.Load(a.ID);
      h.RequestedValue = rec.ask; h.RequestedValueApproach = rec.askApproach; h.FloorValue = rec.floor; h.FloorApproach = rec.floorApproach;
      h.Recommendation = rec.recommendation; h.EstimatedTaxSavings = s.savings; h.SavingsRate = s.rate;
      if (!(await h.Save())) throw new Error(h.LatestResult?.Message ?? 'Could not save the analysis header');
      await this.openAnalysis(a.ID);
      this.Notice = `Recomputed: ${rec.recommendation}${rec.ask != null ? `, ask $${rec.ask.toLocaleString()}` : ''}.`;
    } catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { this.IsSaving = false; this.publishAgentContext(); this.cdr.markForCheck(); }
  }

  /**
   * Persist edited assumption rows -- the Income section's own Save button calls this with its
   * Dirty rows; the toolbar's Save button (Sales has no Save button of its own -- see the class
   * doc-comment on SalesAssumptionsWorking/SalesDecisions) calls this with `[]`. Either way this
   * ALSO always upserts this session's pending Sales-tab edits: touched comp decisions (Task 6)
   * and the eight Sales assumption rows (Task 7) -- so a Sales-only edit is never silently
   * dropped just because nothing in Income happened to be dirty.
   */
  public async SaveAssumptions(changed: AssumptionRow[]): Promise<void> {
    const a = this.Analysis; if (!a) return;
    this.IsSaving = true; this.cdr.markForCheck();
    try {
      for (const c of changed) {
        const e = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisAssumptionEntity>(ENTITIES.appealAssumptions, this.user);
        await e.Load(c.ID);
        e.Value = c.Value; e.Source = c.Source; e.SourceRef = c.SourceRef;
        if (!(await e.Save())) throw new Error(e.LatestResult?.Message ?? `Could not save ${c.AssumptionKey}`);
      }
      await this.saveSalesDecisions(a.ID);
      await this.saveSalesAssumptions(a.ID);
      // Now that Sales decisions/assumptions are actually persisted, reload and reseed the working
      // state from the DB (this is where a first-time Sales row picks up its real ID) -- unlike
      // Recompute's own trailing reload (reseedSales defaults to false there), this one deliberately
      // discards the in-memory working copy because it's now redundant with what was just written.
      await this.openAnalysis(a.ID, true);
    } catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); return; }
    finally { this.IsSaving = false; this.cdr.markForCheck(); }
    await this.Recompute();
  }

  /**
   * Upserts only the comp decisions the analyst actually touched this session
   * (`CompDecisionDraft.touched`) -- never a row for every comp in the pool, most of which the
   * analyst never interacted with. Creates the row when none exists yet for
   * `(AppealAnalysisID, SaleTransactionID)`; updates the existing one otherwise.
   */
  private async saveSalesDecisions(analysisId: string): Promise<void> {
    for (const [saleTransactionId, draft] of this.SalesDecisions) {
      if (!draft.touched) continue;
      const existing = this.CompDecisions.find((d) => d.SaleTransactionID === saleTransactionId);
      const e = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisCompDecisionEntity>(ENTITIES.compDecisions, this.user);
      if (existing) await e.Load(existing.ID);
      else { e.NewRecord(); e.AppealAnalysisID = analysisId; e.SaleTransactionID = saleTransactionId; }
      e.IsIncluded = draft.isIncluded; e.SortOrder = draft.sortOrder;
      // Fix 2 (final whole-plan review): LatestResult.Message initializes to '' (not null/undefined),
      // so `?? fallback` never fires on failure -- `''` isn't nullish. CompleteMessage + `||` gives a
      // real fallback string even when both the message AND CompleteMessage come back empty.
      if (!(await e.Save())) throw new Error(e.LatestResult?.CompleteMessage || `Could not save the comp decision for ${saleTransactionId}`);
    }
  }

  /**
   * Upserts all eight Sales assumption rows, identically to how Income assumption rows are
   * saved -- except a Sales row may not exist yet (a brand-new analysis, or one never opened on
   * the Sales tab), so this creates the row when its ID is still the `''` placeholder from
   * toSalesAssumptionRow / the Sales tab's own `proposeSalesAssumptions` fallback, and updates
   * it otherwise.
   */
  private async saveSalesAssumptions(analysisId: string): Promise<void> {
    const rows = this.SalesAssumptionsWorking.length ? this.SalesAssumptionsWorking : proposeSalesAssumptions().map(toSalesAssumptionRow);
    for (const r of rows) {
      const e = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisAssumptionEntity>(ENTITIES.appealAssumptions, this.user);
      if (r.ID) {
        await e.Load(r.ID);
        e.Value = r.Value; e.Source = r.Source; e.SourceRef = r.SourceRef;
      } else {
        e.NewRecord();
        // Literal, not r.Section: this method only ever processes Section='Sales' rows, and the entity's
        // own Section property is a narrower CHECK-constraint union than AssumptionRow['Section'] (string).
        e.AppealAnalysisID = analysisId; e.Section = 'Sales'; e.AssumptionKey = r.AssumptionKey; e.Label = r.Label;
        e.Value = r.Value; e.Unit = r.Unit; e.Mode = r.Mode; e.Source = r.Source; e.SourceRef = r.SourceRef;
        e.ProposedValue = r.ProposedValue; e.ProposedSource = r.ProposedSource; e.SortOrder = r.SortOrder;
      }
      // Fix 2 (final whole-plan review): same empty-string-fallback fix as saveSalesDecisions above.
      if (!(await e.Save())) throw new Error(e.LatestResult?.CompleteMessage || `Could not save ${r.AssumptionKey}`);
    }
  }

  /** The Sales tab's live coefficient edits (Task 7) -- captured in memory only; SaveAssumptions persists it. */
  public OnSalesAssumptionsChanged(next: AssumptionRow[]): void {
    this.SalesAssumptionsWorking = next;
    this.cdr.markForCheck();
  }

  /** The Sales tab's live inclusion/order edits (Task 6) -- captured in memory only; SaveAssumptions persists whichever entries are `touched`. */
  public OnSalesDecisionsChanged(next: Map<string, CompDecisionDraft>): void {
    this.SalesDecisions = next;
    this.cdr.markForCheck();
  }

  // ───── Print package (Task 10) ─────
  /**
   * Assembles one AppealExportInput from whatever the shell already holds -- the same
   * subject/analysis/indications Recompute derives from, the same merged Sales assumption
   * working set (falling back to the batch defaults exactly like saveSalesAssumptions does)
   * and the same salesCompResults/salesIncludedIds merge logic the Sales tab and Recompute
   * both use. Null only when there's no open analysis to print.
   */
  private buildExportInput(): AppealExportInput | null {
    const a = this.Analysis, b = this.Subject;
    if (!a || !b) return null;
    const salesRows = this.SalesAssumptionsWorking.length ? this.SalesAssumptionsWorking : proposeSalesAssumptions().map(toSalesAssumptionRow);
    return {
      subject: b,
      analysis: a,
      assumptions: [...this.Assumptions.filter((r) => r.Section !== 'Sales'), ...salesRows],
      indications: this.Indications,
      salesResults: this.salesCompResults(b, a),
      includedSaleTransactionIds: this.salesIncludedIds(b.comps),
      generatedAt: new Date(),
    };
  }

  /**
   * Builds the export model and opens it as a standalone HTML document -- exactly the Tax Bill
   * Projection pattern (TaxBillProjection/tax-bill-projection.component.ts's OnOpenReport): a
   * Blob URL rather than document.write, revoked after a delay once the new tab has had time to
   * load it. Called both by the Cover tab's Print Package dialog (a chosen subset of sections)
   * and by each tab's own one-click print button (a single-element Set).
   */
  /** Template helper: `new Set(...)` isn't valid Angular template-expression syntax, so each per-tab print button calls this to build the single-section Set that printSections wants. */
  public printOne(key: PrintSection): Set<PrintSection> {
    return new Set([key]);
  }
  public printSections(include: Set<PrintSection>): void {
    const input = this.buildExportInput();
    if (!input) return;
    const model = buildAppealExport(input);
    const html = exportToDocument(model, include);
    const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
    const opened = window.open(url, '_blank');
    if (!opened) this.Notice = 'Your browser blocked the new tab — allow pop-ups for this site to print.';
    setTimeout(() => URL.revokeObjectURL(url), 60_000);
    this.cdr.markForCheck();
  }

  /** Cover tab's Print Package button: builds the export model once, up front, so the checklist only ever offers sections with real content -- default-checked, per the brief. */
  public OpenPrintPackageDialog(): void {
    const input = this.buildExportInput();
    if (!input) return;
    const model = buildAppealExport(input);
    // Object key order mirrors SECTION_ORDER (appeal-export.ts builds `sections` by iterating it) -- the fixed Cover/Sales/Income/... order carries through without re-importing a private const.
    this.PrintDialogSections = (Object.keys(model.sections) as PrintSection[]).map((key) => ({ key, label: model.sections[key]!.title, checked: true }));
    this.PrintDialogVisible = true;
    this.cdr.markForCheck();
  }
  public TogglePrintSection(key: PrintSection, checked: boolean): void {
    this.PrintDialogSections = this.PrintDialogSections.map((s) => (s.key === key ? { ...s, checked } : s));
    this.cdr.markForCheck();
  }
  public ConfirmPrintPackage(): void {
    const include = new Set(this.PrintDialogSections.filter((s) => s.checked).map((s) => s.key));
    this.PrintDialogVisible = false;
    this.cdr.markForCheck();
    this.printSections(include);
  }
  public CancelPrintPackage(): void {
    this.PrintDialogVisible = false;
    this.cdr.markForCheck();
  }

  public async SetAskPolicy(policy: AskPolicy): Promise<void> {
    const a = this.Analysis; if (!a || a.AskPolicy === policy) return;
    await this.SaveHeader({ AskPolicy: policy } as Partial<AnalysisRow>);
    await this.Recompute();
  }
  public async SaveHeader(patch: Partial<AnalysisRow>): Promise<void> {
    const a = this.Analysis; if (!a) return;
    this.IsSaving = true; this.cdr.markForCheck();
    try {
      const h = await this.ProviderToUse.GetEntityObject<indianataxAppealAnalysisEntity>(ENTITIES.appealAnalysis, this.user);
      await h.Load(a.ID);
      for (const [k, v] of Object.entries(patch)) (h as unknown as Record<string, unknown>)[k] = v;
      if (!(await h.Save())) throw new Error(h.LatestResult?.Message ?? 'Could not save');
      await this.openAnalysis(a.ID);
    } catch (e) { this.LoadError = e instanceof Error ? e.message : String(e); }
    finally { this.IsSaving = false; this.cdr.markForCheck(); }
  }

  // ───── Sections and hand-offs ─────
  public OnSectionChange(key: string): void {
    if (!(SECTION_KEYS as string[]).includes(key)) return;
    this.ActiveSection = key as SectionKey;
    setTimeout(() => SharedService.Instance.InvokeManualResize(), 100);
    this.syncQueryParams(); this.publishAgentContext(); this.cdr.markForCheck();
  }
  public async OpenTaxProjection(): Promise<void> {
    if (!this.Subject) return;
    await this.navigationService.SwitchToApp(INDIANA_APP_ID, TAX_PROJECTION_NAV_LABEL, { parcel: this.Subject.parcel.ID });
  }
  public DismissNotice(): void { this.Notice = null; this.LoadError = null; this.cdr.markForCheck(); }

  private publishAgentContext(): void {
    this.navigationService.SetAgentContext(this, {
      Parcel: this.Subject?.parcel.GISParcelNumber ?? null, Address: this.Subject?.parcel.Address ?? null,
      AnalysisID: this.Analysis?.ID ?? null, Section: this.ActiveSection,
      CurrentAV: this.Analysis?.CurrentTotalAV ?? null, Ask: this.Reconciled?.ask ?? null, Floor: this.Reconciled?.floor ?? null,
      Recommendation: this.Reconciled?.recommendation ?? null, AskPolicy: this.Analysis?.AskPolicy ?? null,
    });
    this.navigationService.SetAgentClientTools(this, [
      { Name: 'SwitchSection', Description: 'Show a section of the analysis', ParameterSchema: { type: 'object', properties: { section: { type: 'string', enum: SECTION_KEYS } }, required: ['section'] }, Handler: async (p) => { this.OnSectionChange(String(p['section'])); return { Success: true }; } },
      { Name: 'Recompute', Description: 'Recompute every indication and the ask from the stored assumptions', ParameterSchema: { type: 'object', properties: {} }, Handler: async () => { await this.Recompute(); return { Success: !this.LoadError, Message: this.LoadError ?? this.Notice ?? '' }; } },
    ]);
  }
}
