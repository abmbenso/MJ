import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit, OnDestroy } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData } from '@memberjunction/core-entities';
import { RunView } from '@memberjunction/core';
import {
  TaxHistoryRow,
  ScenarioState,
  ScenarioName,
  SCENARIO_NAMES,
  SCENARIO_META,
  ProjectionRow,
  ParcelSearchResult,
  KnownAssessment,
  BillFigure,
  SaleAdjustment,
  ScenarioProbabilityRow,
  gapBandForRatio,
} from '../TaxBudgetProjection/tax-budget-projection-types';
import { trendStats, projectScenario, selectBaseYearRow, computeBill, residualProbability } from '../TaxBudgetProjection/tax-budget-projection-engine';
import {
  BillAssumptions,
  BillColumn,
  BillGridLines,
  BillRow,
  billAssumptionsDifferFrom,
  blendedCapRate,
  buildBillGrid,
  capSummaryRows,
  defaultBillAssumptions,
  scaledCapAV,
} from './tax-bill-view-model';

const COUNTY_NUMBER = 49; // Marion
const YEARS_FORWARD = 5;
const TREND_LOOKBACK = 6;
const AV_RELATIONSHIP_BAND = 0.1;
const SALE_LOOKBACK_YEARS = 3;
/** Ten columns of currency does not fit a laptop; this is the default window. */
const RECENT_ACTUAL = 2;
const RECENT_PROJECTED = 3;

/**
 * County-wide placeholder uplift, used ONLY when a parcel has never been capped. Kept in
 * lockstep with V1's constant of the same name -- see the long rationale there. It is a
 * rough middle of Marion's -0.5%..+27% district spread, and where it actually binds the UI
 * says so rather than presenting it as measured.
 */
const DISTRICT_UPLIFT_FALLBACK = 0.15;

@Component({
  standalone: false,
  selector: 'mj-tax-bill-projection',
  templateUrl: './tax-bill-projection.component.html',
  styleUrls: ['./tax-bill-projection.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'TaxBillProjectionResource')
// tab-container.component.ts resolves every nav-item target through
// ClassFactory.GetRegistrationAsync(BaseResourceComponent, driverClass) -- never
// BaseDashboard -- so a BaseDashboard-only registration renders the "view isn't available
// in the running build" card. Both decorators are required.
@RegisterClass(BaseResourceComponent, 'TaxBillProjectionResource')
export class TaxBillProjectionComponent extends BaseDashboard implements AfterViewInit, OnDestroy {
  public IsLoading = false;
  public IsSearching = false;
  public SearchTerm = '';
  public SearchResults: ParcelSearchResult[] = [];
  public SelectedParcel: ParcelSearchResult | null = null;
  public LoadError: string | null = null;

  /** The scenario whose future the bill is showing. The bill shows ONE future at a time. */
  public ActiveScenario: ScenarioName = 'MostLikely';
  public ShowAllColumns = false;

  public BaseYear = 0;
  public BaseLand = 0;
  public BaseImp = 0;
  public BaseRate = 0;
  public KnownAV: KnownAssessment | null = null;

  public BillCalibration: {
    deductionRatio: number;
    capClassShare: { av1Pct: number; av2Pct: number; av3Pct: number };
    uplift: number;
    upliftSource: 'parcel' | 'district';
    otherCharges: number;
    capClass: string | null;
    years: number;
  } | null = null;

  public readonly ScenarioNames = SCENARIO_NAMES;
  public readonly ScenarioMeta = SCENARIO_META;
  public readonly YearsForward = YEARS_FORWARD;

  /**
   * Editable assumptions, one set per scenario -- the same state V1 exposes. V2 edits the
   * ACTIVE scenario only, because the bill shows one future at a time; switching scenarios
   * keeps each one's edits.
   */
  public Scenarios: Record<ScenarioName, ScenarioState> = this.emptyScenarios();
  public SaleAdjustment: SaleAdjustment | null = null;

  /**
   * Editable BILL lines, per scenario. Kept beside the growth assumptions (rather than as
   * one parcel-wide setting) so "what if the abatement expires" can be a scenario in its
   * own right, and so Reset restores this scenario's bill without touching the others.
   */
  public BillAssumptionsByScenario: Record<ScenarioName, BillAssumptions> = this.emptyBillAssumptions();
  /** Whether the assumptions editor is open. Closed by default: the bill is the subject. */
  public ShowAssumptions = false;

  /** The rendered grid: TS-1 Table 1 rows, one figure per visible column. */
  public GridRows: BillRow[] = [];
  public CapRows: BillRow[] = [];
  public VisibleColumns: BillColumn[] = [];

  private actualColumns: BillColumn[] = [];
  private projectedColumns: BillColumn[] = [];
  private fullHistory: TaxHistoryRow[] = [];
  /** Model defaults, deep-cloned, so one scenario can be reset without touching the others. */
  private defaultScenarios: Record<ScenarioName, ScenarioState> = this.emptyScenarios();
  private defaultBills: Record<ScenarioName, BillAssumptions> = this.emptyBillAssumptions();
  private searchDebounce: ReturnType<typeof setTimeout> | null = null;
  /** Only the newest search may publish -- a slow earlier query must not overwrite it. */
  private searchSeq = 0;

  // navigationService is inherited from BaseDashboard/BaseResourceComponent -- never re-injected.
  constructor(private cdr: ChangeDetectorRef) {
    super();
  }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Tax Bill Projection';
  }

  initDashboard(): void {
    // No parcel on load -- the search box is the entry point.
  }

  async loadData(): Promise<void> {
    // Nothing to preload; NotifyLoadComplete() fires automatically after this resolves.
  }

  ngAfterViewInit(): void {
    this.publishAgentContext();
  }

  override ngOnDestroy(): void {
    if (this.searchDebounce) {
      clearTimeout(this.searchDebounce);
      this.searchDebounce = null;
    }
    super.ngOnDestroy();
  }

  /**
   * True when this parcel has loaded DLGF bills. Without them there is no bill to shape --
   * no historical columns and no calibration -- and the honest answer is to say so and
   * point at V1 rather than render a bill-shaped grid out of invented lines.
   */
  public get HasBillShape(): boolean {
    return this.BillCalibration != null && this.actualColumns.length > 0;
  }

  public get ScenarioLabel(): string {
    return SCENARIO_META[this.ActiveScenario].label;
  }

  public get TotalColumnCount(): number {
    return this.actualColumns.length + this.projectedColumns.length;
  }

  /** The last projected year's total due -- what the whole view is for. */
  public get FinalYearTotalDue(): number | null {
    const last = this.projectedColumns[this.projectedColumns.length - 1];
    return last ? last.lines.totalDue.value : null;
  }

  public get FallbackUpliftIsBinding(): boolean {
    if (this.BillCalibration?.upliftSource !== 'district') return false;
    return this.projectedColumns.some((c) => (c.lines.capSavings.value ?? 0) > 0);
  }

  /** Total AV as of the latest PUBLISHED assessment -- the bridge year's if there is one. */
  public get CurrentAV(): number {
    return this.KnownAV ? this.KnownAV.land + this.KnownAV.imp : this.BaseLand + this.BaseImp;
  }

  /** The assessment year `CurrentAV` belongs to. */
  public get CurrentAVYear(): number {
    return this.KnownAV ? this.KnownAV.year : this.BaseYear;
  }

  /**
   * Zero-based index of the bridge year in the per-year assumption arrays, or -1. That
   * year's value growth is NOT an input -- the Assessor has already set it -- so the editor
   * locks its Land/Improvement cells and leaves only the tax rate editable.
   */
  public get PinnedYearIndex(): number {
    return this.KnownAV ? this.KnownAV.year - this.BaseYear - 1 : -1;
  }

  /** 1-based projection years whose assessment is not yet published, for the override picker. */
  public get OverridableYears(): number[] {
    const pinned = this.KnownAV ? this.KnownAV.year - this.BaseYear : -1;
    const years: number[] = [];
    for (let y = 1; y <= YEARS_FORWARD; y++) if (y !== pinned) years.push(y);
    return years;
  }

  /** 0-based indexes of the projected years, for the assumption editor's column headers. */
  public get ProjectedYearIndexes(): number[] {
    return Array.from({ length: YEARS_FORWARD }, (_, i) => i);
  }

  /** The active scenario's editable assumptions -- what the editor binds to. */
  public get ActiveAssumptions(): ScenarioState {
    return this.Scenarios[this.ActiveScenario];
  }

  /** The parcel's own calibrated ceiling rate, for the footnote that explains the default. */
  public get CalibratedCapRate(): number {
    return this.BillCalibration ? blendedCapRate(this.BillCalibration.capClassShare) : 0;
  }

  /** The active scenario's editable BILL lines. */
  public get ActiveBill(): BillAssumptions {
    return this.BillAssumptionsByScenario[this.ActiveScenario];
  }

  /**
   * True once the reader has moved a bill line off the parcel's calibrated shape. Worth
   * surfacing: from that point the projection is the READER's model of the bill, not the
   * one derived from the parcel's own filed bills, and V1 (which has no such control) will
   * legitimately disagree with it.
   */
  public get BillIsEdited(): boolean {
    return billAssumptionsDifferFrom(this.ActiveBill, this.defaultBills[this.ActiveScenario]);
  }

  public get IsMultifamilyCapClass(): boolean {
    return this.BillCalibration?.capClass === 'OtherResidential';
  }

  // ---------------------------------------------------------------------
  // Parcel search
  // ---------------------------------------------------------------------

  public OnSearchTermChange(term: string): void {
    this.SearchTerm = term;
    if (this.searchDebounce) clearTimeout(this.searchDebounce);
    if (term.trim().length < 3) {
      this.SearchResults = [];
      this.cdr.markForCheck();
      return;
    }
    this.searchDebounce = setTimeout(() => void this.runParcelSearch(term), 300);
  }

  private async runParcelSearch(term: string): Promise<void> {
    const seq = ++this.searchSeq;
    this.IsSearching = true;
    this.cdr.markForCheck();
    const esc = term.replace(/'/g, "''");
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<ParcelSearchResult>({
      EntityName: 'Parcels',
      Fields: ['ID', 'GISParcelNumber', 'Address'],
      ExtraFilter: `CountyNumber = ${COUNTY_NUMBER} AND (Address LIKE '%${esc}%' OR GISParcelNumber = '${esc}' OR ParcelNumber = '${esc}')`,
      OrderBy: 'Address ASC',
      MaxRows: 15,
      ResultType: 'simple',
    });
    if (seq !== this.searchSeq) return; // superseded by a newer search
    this.SearchResults = result.Success ? (result.Results ?? []) : [];
    this.LoadError = result.Success ? null : `Parcel search failed: ${result.ErrorMessage ?? 'unknown error'}`;
    this.IsSearching = false;
    this.cdr.markForCheck();
  }

  public async OnParcelSelected(parcel: ParcelSearchResult): Promise<void> {
    this.SelectedParcel = parcel;
    this.SearchResults = [];
    this.SearchTerm = `${parcel.GISParcelNumber} — ${parcel.Address}`;
    await this.loadParcelBill(parcel.ID);
    this.publishAgentContext();
  }

  // ---------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------

  private async loadParcelBill(parcelId: string): Promise<void> {
    this.IsLoading = true;
    this.LoadError = null;
    this.cdr.markForCheck();
    try {
      const rv = RunView.FromMetadataProvider(this.ProviderToUse);
      const minSaleDate = `${new Date().getFullYear() - SALE_LOOKBACK_YEARS}-01-01`;
      const [taxHistoryResult, assessmentResult, billResult, saleResult] = await rv.RunViews<Record<string, unknown>>([
        {
          EntityName: 'Tax History Years',
          Fields: ['TaxYear', 'LandAssessment', 'Improvements', 'GrossAssessment', 'TaxRate', 'NetAnnualTax'],
          ExtraFilter: `ParcelID = '${parcelId}' AND ColumnOrdinal <= 20`,
          OrderBy: 'TaxYear ASC',
          MaxRows: 60,
          ResultType: 'simple',
        },
        {
          EntityName: 'Assessments',
          Fields: ['AssessmentYear', 'OriginalTotalAV', 'OriginalLandAV', 'OriginalImprovementAV'],
          ExtraFilter: `ParcelID = '${parcelId}' AND Source = 'MarionPRC'`,
          OrderBy: 'AssessmentYear DESC',
          MaxRows: 10,
          ResultType: 'simple',
        },
        {
          EntityName: 'Tax Bills',
          Fields: [
            'PayYear',
            'GrossAssessedValue',
            'NetAssessedValue',
            'LocalTaxRate',
            'GrossTaxDue',
            'PropertyTaxCapSavings',
            'TotalPropertyTaxDue',
            'TotalOtherCharges',
            'AVSubjectTo1Pct',
            'AVSubjectTo2Pct',
            'AVSubjectTo3Pct',
            'StatutoryCapClass',
          ],
          ExtraFilter: `ParcelID = '${parcelId}' AND PropertyTypeCode = 'R'`,
          OrderBy: 'PayYear DESC',
          MaxRows: 10,
          ResultType: 'simple',
        },
        {
          EntityName: 'Sale Transactions',
          Fields: ['SaleDate', 'SalePrice', 'AssessedValueAtSale', 'PropertyTypeGroup'],
          ExtraFilter: `ParcelID = '${parcelId}' AND TransactionKind = 'ClosedSale' AND SaleDate >= '${minSaleDate}' AND SalePrice > 100000 AND AssessedValueAtSale > 0 AND ((Source = 'MarionPRC' AND CountyValidForTrending = 1) OR (Source = 'CoStar' AND IsArmsLength = 1)) AND ISNULL(Notes, '') NOT LIKE '%portfolio%'`,
          OrderBy: 'SaleDate DESC',
          MaxRows: 1,
          ResultType: 'simple',
        },
      ]);

      // A failed query is NOT "this parcel has no bills" -- rendering an empty bill for a
      // transport failure would quietly understate a real parcel's taxes.
      const failed = [taxHistoryResult, assessmentResult, billResult, saleResult].filter((r) => !r.Success);
      if (failed.length) {
        this.LoadError = `Could not load this parcel's bill: ${failed.map((f) => f.ErrorMessage ?? 'unknown error').join('; ')}`;
      }

      this.applyTaxHistory(taxHistoryResult.Success ? ((taxHistoryResult.Results as unknown as TaxHistoryRawRow[]) ?? []) : []);
      const latestAssessment = assessmentResult.Success ? (assessmentResult.Results?.[0] as unknown as AssessmentRawRow | undefined) : undefined;
      this.applyBases(latestAssessment);

      const bills = billResult.Success ? ((billResult.Results as unknown as TaxBillRawRow[]) ?? []) : [];
      this.applyBillCalibration(bills);
      this.buildActualColumns(bills);

      const saleRow = saleResult.Success ? (saleResult.Results?.[0] as unknown as SaleRawRow | undefined) : undefined;
      this.SaleAdjustment = this.buildSaleAdjustment(saleRow);

      await this.buildScenarios();
    } finally {
      this.IsLoading = false;
      this.cdr.markForCheck();
    }
  }

  private applyTaxHistory(rows: TaxHistoryRawRow[]): void {
    this.fullHistory = rows.map((r) => ({
      Year: Number(r.TaxYear),
      Land: Number(r.LandAssessment) || 0,
      Improvement: Number(r.Improvements) || 0,
      TotalAV: Number(r.GrossAssessment) || 0,
      TaxRate: Number(r.TaxRate) || 0,
      Tax: r.NetAnnualTax != null ? Number(r.NetAnnualTax) : null,
    }));
  }

  /**
   * Base year and bridge year are two SEPARATE things. The base must be one coherent year
   * -- value and rate both published -- or the two advance at different speeds and every
   * projected tax comes out low. A later assessment with no rate yet is not a base; it is
   * a pin on the first projected year.
   */
  private applyBases(latest: AssessmentRawRow | undefined): void {
    const baseRow = selectBaseYearRow(this.fullHistory);
    this.BaseYear = baseRow ? baseRow.Year : 0;
    this.BaseLand = baseRow ? baseRow.Land : 0;
    this.BaseImp = baseRow ? baseRow.Improvement : 0;
    this.BaseRate = baseRow ? baseRow.TaxRate : 0;

    this.KnownAV = null;
    if (latest && this.BaseYear) {
      const year = Number(latest.AssessmentYear);
      const offset = year - this.BaseYear;
      if (offset >= 1 && offset <= YEARS_FORWARD) {
        this.KnownAV = { year, land: Number(latest.OriginalLandAV) || 0, imp: Number(latest.OriginalImprovementAV) || 0 };
      }
    }
  }

  /**
   * Derives the parcel's bill shape from its LATEST loaded bill, not an average across
   * years: a projection starts from where the parcel is now, and deductions/abatements
   * change. Uplift comes from the parcel's own most recent capped year where it has one;
   * only a never-capped parcel falls back to the county placeholder, and the source is
   * carried so the UI can say which was used.
   */
  private applyBillCalibration(bills: TaxBillRawRow[]): void {
    this.BillCalibration = null;
    const usable = bills.filter((b) => Number(b.GrossAssessedValue) > 0);
    if (!usable.length) return;

    const latest = usable[0];
    const g = Number(latest.GrossAssessedValue);
    const deductionRatio = (g - Number(latest.NetAssessedValue ?? g)) / g;
    const capClassShare = {
      av1Pct: Number(latest.AVSubjectTo1Pct ?? 0) / g,
      av2Pct: Number(latest.AVSubjectTo2Pct ?? 0) / g,
      av3Pct: Number(latest.AVSubjectTo3Pct ?? 0) / g,
    };

    const capped = usable.filter((b) => Number(b.PropertyTaxCapSavings ?? 0) > 0).slice(0, 1);
    const ownUplifts = capped
      .map((b) => {
        const ceiling = Number(b.AVSubjectTo1Pct ?? 0) * 0.01 + Number(b.AVSubjectTo2Pct ?? 0) * 0.02 + Number(b.AVSubjectTo3Pct ?? 0) * 0.03;
        return ceiling > 0 ? (Number(b.TotalPropertyTaxDue) - ceiling) / ceiling : null;
      })
      .filter((u): u is number => u != null && isFinite(u));

    this.BillCalibration = {
      deductionRatio,
      capClassShare,
      uplift: ownUplifts.length ? ownUplifts[0] : DISTRICT_UPLIFT_FALLBACK,
      upliftSource: ownUplifts.length ? 'parcel' : 'district',
      otherCharges: Number(latest.TotalOtherCharges ?? 0),
      capClass: (latest.StatutoryCapClass as string) ?? null,
      years: usable.length,
    };
  }

  // ---------------------------------------------------------------------
  // Columns
  // ---------------------------------------------------------------------

  /**
   * Historical columns are read from the bill, not recomputed from it. The only
   * subtraction here is the one the paper bill itself prints: DLGF publishes gross and net
   * AV, and lines 2a and 4a are the differences between figures it already gives us.
   */
  private buildActualColumns(bills: TaxBillRawRow[]): void {
    const asc = [...bills].filter((b) => Number(b.GrossAssessedValue) > 0).sort((a, b) => Number(a.PayYear) - Number(b.PayYear));
    this.actualColumns = asc.map((b) => {
      const f = (v: number | null): BillFigure => ({ value: v, source: 'actual' });
      const grossAV = num(b.GrossAssessedValue);
      const netAV = num(b.NetAssessedValue);
      const grossTax = num(b.GrossTaxDue);
      const capSavings = num(b.PropertyTaxCapSavings) ?? 0;
      const line5 = num(b.TotalPropertyTaxDue);
      const otherCharges = num(b.TotalOtherCharges) ?? 0;

      // TS-1 line 4a. The DLGF bridge is TotalPropertyTaxDue = GrossTaxDue - SUM(type-'C'
      // credits), of which the circuit breaker is one; this residual is the rest.
      const localCredits = grossTax != null && line5 != null ? round2(grossTax - capSavings - line5) : null;

      // Land/improvement are NOT on the bill -- they come from the assessment for the year
      // this bill taxes. Absent history means the split is unknown for that year, which the
      // grid renders blank; it is never assumed to be zero.
      const assessmentYear = Number(b.PayYear) - 1;
      const hist = this.fullHistory.find((h) => h.Year === assessmentYear);

      const lines: BillGridLines = {
        land: f(hist ? hist.Land : null),
        improvement: f(hist ? hist.Improvement : null),
        grossAV: f(grossAV),
        deductions: f(grossAV != null && netAV != null ? round2(grossAV - netAV) : null),
        netAV: f(netAV),
        rate: f(num(b.LocalTaxRate)),
        grossTax: f(grossTax),
        localCredits: f(localCredits),
        // When the cap bound, the ceiling it held the taxpayer to IS the resulting line-5
        // liability. When it did not bind, the ceiling sat somewhere above the tax and the
        // bill does not say where -- so it is unavailable, not zero.
        capCeiling: f(capSavings > 0 ? line5 : null),
        capSavings: f(capSavings),
        otherCharges: f(otherCharges),
        // "Total due" means the same thing in both halves of the grid: line 5 plus Table 4.
        totalDue: f(line5 == null ? null : round2(line5 + otherCharges)),
      };
      const payYear = Number(b.PayYear);
      return { assessmentYear: payYear - 1, payYear, label: `${payYear - 1} pay ${payYear}`, lines, isProjected: false };
    });
  }

  private projectedColumn(row: ProjectionRow, index: number): BillColumn {
    const cal = this.BillCalibration!;
    const share = cal.capClassShare;
    const bill = this.ActiveBill;
    // The editor holds percentages (what a person reads and types); the engine wants
    // fractions. This is the single boundary where that conversion happens.
    const deductionRatio = (bill.deductionPct[index] ?? 0) / 100;
    const uplift = (bill.upliftPct[index] ?? 0) / 100;
    const otherCharges = bill.otherCharges[index] ?? 0;

    const lines: BillGridLines = computeBill({
      grossAV: row.totalAV,
      deductions: row.totalAV * deductionRatio,
      rate: row.rate,
      // Scaled from the parcel's OWN class shares, so an edited ceiling models a
      // reclassification's effect without rewriting which statutory buckets it sits in.
      capAV: scaledCapAV(row.totalAV, share, bill.capRatePct[index] ?? 0),
      uplift,
      otherCharges,
      source: 'projected',
    });
    // The engine already trends land and improvements SEPARATELY -- this surfaces the split
    // it computed, so a reader can see which half is driving the bill.
    const avSource = row.avSource;
    lines.land = { value: row.land, source: avSource };
    lines.improvement = { value: row.imp, source: avSource };
    // The bridge year's assessment is published fact even though its rate is not. Only the
    // gross AV earns that mark: everything below it depends on a projected deduction ratio
    // or a projected rate.
    if (row.avSource === 'actual') lines.grossAV = { value: lines.grossAV.value, source: 'actual' };
    return { assessmentYear: row.assessmentYear, payYear: row.payYear, label: `${row.assessmentYear} pay ${row.payYear}`, lines, isProjected: true };
  }

  private refreshColumns(): void {
    const visible = this.ShowAllColumns
      ? [...this.actualColumns, ...this.projectedColumns]
      : [...this.actualColumns.slice(-RECENT_ACTUAL), ...this.projectedColumns.slice(0, RECENT_PROJECTED)];
    this.VisibleColumns = visible;
    this.GridRows = buildBillGrid(visible);
    this.CapRows = capSummaryRows(visible);
  }

  // ---------------------------------------------------------------------
  // Scenario assembly (same model defaults as V1 -- same engine, same inputs)
  // ---------------------------------------------------------------------

  private emptyBillAssumptions(): Record<ScenarioName, BillAssumptions> {
    return {
      WorstCase: defaultBillAssumptions(null, YEARS_FORWARD),
      MostLikely: defaultBillAssumptions(null, YEARS_FORWARD),
      BestCase: defaultBillAssumptions(null, YEARS_FORWARD),
    };
  }

  private emptyScenarios(): Record<ScenarioName, ScenarioState> {
    const blank = (): ScenarioState => ({
      mode: 'trend',
      land: Array(YEARS_FORWARD).fill(0),
      imp: Array(YEARS_FORWARD).fill(0),
      rate: Array(YEARS_FORWARD).fill(0),
      probability: null,
      probabilitySource: null,
      targetValue: null,
      triggerYear: null,
      override: { enabled: false, year: 1, value: null },
    });
    return { WorstCase: blank(), MostLikely: blank(), BestCase: blank() };
  }

  /**
   * Builds the three scenarios EXACTLY as V1 does, including the sale-driven Worst Case.
   *
   * This is deliberately a copy of V1's assembly, not a simplification of it: the two views
   * are two renderings of ONE projection, so if a parcel's Worst Case steps to its sale
   * price in V1 it must step there in V2 too. An earlier draft of this method dropped the
   * sale lookup, which silently made the two views disagree from projection year 2 onward
   * on every parcel with a qualifying sale.
   */
  private async buildScenarios(): Promise<void> {
    const window = this.fullHistory.slice(-TREND_LOOKBACK);
    const landTrend = trendStats(window, 'Land');
    const impTrend = trendStats(window, 'Improvement');
    const rateTrend = trendStats(window, 'TaxRate');

    const mostLikelyLand = Array(YEARS_FORWARD).fill(r4(landTrend.cagr ?? 0)) as number[];
    const mostLikelyImp = Array(YEARS_FORWARD).fill(r4(impTrend.cagr ?? 0)) as number[];
    const mostLikelyRate = Array(YEARS_FORWARD).fill(r4(clampRate(rateTrend.cagr))) as number[];

    const scenarios = this.emptyScenarios();
    scenarios.MostLikely = { ...scenarios.MostLikely, mode: 'trend', land: mostLikelyLand, imp: mostLikelyImp, rate: mostLikelyRate };
    scenarios.BestCase = {
      ...scenarios.BestCase,
      mode: 'trend',
      land: mostLikelyLand.map((v) => r4(v / 2)),
      imp: mostLikelyImp.map((v) => r4(v / 2)),
      rate: mostLikelyRate,
    };

    // Compare against the most recent PUBLISHED assessment (the bridge year's, when there
    // is one) -- not the older projection base, which would miss a chase already landed.
    const baseTotal = this.CurrentAV;
    const alreadyCaughtUp = this.SaleAdjustment != null && baseTotal >= this.SaleAdjustment.salePrice;

    if (this.SaleAdjustment && !alreadyCaughtUp) {
      const gapRatio = this.SaleAdjustment.gap / this.SaleAdjustment.avAtSale;
      const band = gapBandForRatio(gapRatio);
      const probs = band ? await this.lookupScenarioProbabilities(this.SaleAdjustment.propertyType, band) : null;
      scenarios.WorstCase = {
        ...scenarios.WorstCase,
        mode: 'step-to-price',
        land: mostLikelyLand,
        imp: mostLikelyImp,
        rate: mostLikelyRate,
        probability: probs ? probs.PWorstCaseFullChase : null,
        probabilitySource: probs
          ? `Marion County data, ${probs.PropertyTypeGroup} × ${probs.GapBand} (N=${probs.SampleSize})`
          : `no comparable Marion data for gap band ${band ?? '(unbanded)'}`,
        targetValue: this.SaleAdjustment.salePrice,
        triggerYear: 1,
      };
      if (probs) {
        scenarios.BestCase.probability = probs.PBestCaseNoReaction;
        scenarios.BestCase.probabilitySource = scenarios.WorstCase.probabilitySource;
        scenarios.MostLikely.probability = r4(residualProbability(probs.PWorstCaseFullChase, probs.PBestCaseNoReaction));
        scenarios.MostLikely.probabilitySource = `residual after Worst Case + Best Case (${scenarios.WorstCase.probabilitySource})`;
      }
    } else if (alreadyCaughtUp && this.SaleAdjustment) {
      scenarios.WorstCase = {
        ...scenarios.WorstCase,
        mode: 'trend',
        land: mostLikelyLand.map((v) => r4(v + (landTrend.volatility ?? 0.02))),
        imp: mostLikelyImp.map((v) => r4(v + (impTrend.volatility ?? 0.02))),
        rate: mostLikelyRate,
        probabilitySource: `the ${this.CurrentAVYear} AV ($${Math.round(baseTotal).toLocaleString()}) is already at or above the $${Math.round(this.SaleAdjustment.salePrice).toLocaleString()} sale price from ${this.SaleAdjustment.saleYear} -- any chase reaction already happened between the sale and now, so this is an aggressive-trend fallback from the current (already-elevated) base, not a fresh step`,
      };
    } else {
      scenarios.WorstCase = {
        ...scenarios.WorstCase,
        mode: 'trend',
        land: mostLikelyLand.map((v) => r4(v + (landTrend.volatility ?? 0.02))),
        imp: mostLikelyImp.map((v) => r4(v + (impTrend.volatility ?? 0.02))),
        rate: mostLikelyRate,
        probabilitySource: 'no recent qualifying sale on file -- probability not estimated; this is an aggressive-trend fallback, not an empirical figure',
      };
    }

    this.Scenarios = scenarios;
    this.defaultScenarios = JSON.parse(JSON.stringify(scenarios)) as Record<ScenarioName, ScenarioState>;

    // Every scenario starts from the parcel's OWN calibrated bill shape; the reader edits
    // away from it per scenario.
    const shape = this.BillCalibration
      ? {
          deductionRatio: this.BillCalibration.deductionRatio,
          uplift: this.BillCalibration.uplift,
          otherCharges: this.BillCalibration.otherCharges,
          capRate: blendedCapRate(this.BillCalibration.capClassShare),
        }
      : null;
    this.BillAssumptionsByScenario = {
      WorstCase: defaultBillAssumptions(shape, YEARS_FORWARD),
      MostLikely: defaultBillAssumptions(shape, YEARS_FORWARD),
      BestCase: defaultBillAssumptions(shape, YEARS_FORWARD),
    };
    this.defaultBills = JSON.parse(JSON.stringify(this.BillAssumptionsByScenario)) as Record<ScenarioName, BillAssumptions>;

    this.recomputeProjection();
  }

  private async lookupScenarioProbabilities(propertyType: string, gapBand: string): Promise<ScenarioProbabilityRow | null> {
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<ScenarioProbabilityRow>({
      EntityName: 'Sale Reassessment Scenario Probabilities',
      Fields: [
        'PropertyTypeGroup',
        'GapBand',
        'SampleSize',
        'PWorstCaseFullChase',
        'WorstCaseMedianChaseFraction',
        'PMostLikelyPartial',
        'MostLikelyMedianChaseFraction',
        'PBestCaseNoReaction',
        'BestCaseMedianChaseFraction',
        'LowSample',
        'ComputedAt',
      ],
      ExtraFilter: `CountyNumber = ${COUNTY_NUMBER} AND GapBand = '${gapBand}' AND PropertyTypeGroup IN ('${propertyType.replace(/'/g, "''")}', 'All')`,
      OrderBy: 'ComputedAt DESC',
      MaxRows: 10,
      ResultType: 'simple',
    });
    if (!result.Success || !result.Results?.length) return null;
    const exact = result.Results.find((r) => r.PropertyTypeGroup === propertyType && !r.LowSample);
    const exactAny = result.Results.find((r) => r.PropertyTypeGroup === propertyType);
    const fallback = result.Results.find((r) => r.PropertyTypeGroup === 'All');
    return exact ?? exactAny ?? fallback ?? result.Results[0];
  }

  private buildSaleAdjustment(row: SaleRawRow | undefined): SaleAdjustment | null {
    if (!row) return null;
    const salePrice = Number(row.SalePrice);
    const avAtSale = Number(row.AssessedValueAtSale);
    const gap = salePrice - avAtSale;
    if (gap <= avAtSale * AV_RELATIONSHIP_BAND) return null; // not meaningfully above AV
    return {
      saleYear: new Date(row.SaleDate as string).getFullYear(),
      salePrice,
      avAtSale,
      gap,
      propertyType: String(row.PropertyTypeGroup ?? 'Other'),
    };
  }

  private recomputeProjection(): void {
    if (!this.BillCalibration || !this.BaseYear) {
      this.projectedColumns = [];
      this.refreshColumns();
      return;
    }
    const rows = projectScenario({
      baseYear: this.BaseYear,
      baseLand: this.BaseLand,
      baseImp: this.BaseImp,
      baseRate: this.BaseRate,
      scenario: this.Scenarios[this.ActiveScenario],
      yearsForward: YEARS_FORWARD,
      knownAV: this.KnownAV,
      deductionRatio: this.BillCalibration.deductionRatio,
      capClassShare: this.BillCalibration.capClassShare,
      uplift: this.BillCalibration.uplift,
      otherCharges: this.BillCalibration.otherCharges,
    });
    this.projectedColumns = rows.map((r, i) => this.projectedColumn(r, i));
    this.refreshColumns();
  }

  // ---------------------------------------------------------------------
  // View controls
  // ---------------------------------------------------------------------

  public OnScenarioChange(name: ScenarioName): void {
    this.ActiveScenario = name;
    this.recomputeProjection();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public OnToggleColumnWindow(): void {
    this.ShowAllColumns = !this.ShowAllColumns;
    this.refreshColumns();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public OnToggleAssumptions(): void {
    this.ShowAssumptions = !this.ShowAssumptions;
    this.cdr.markForCheck();
  }

  /**
   * Land, improvements and the tax rate are edited as PERCENTAGES per projected year, and
   * stored as decimal fractions. Land and improvements are separate series on purpose:
   * improvements carry the volatility, and a single blended growth rate cannot express that.
   */
  public OnAssumptionChange(key: 'land' | 'imp' | 'rate', idx: number, valuePercent: string): void {
    const v = parseFloat(valuePercent);
    this.ActiveAssumptions[key][idx] = isFinite(v) ? r4(v / 100) : 0;
    this.recomputeProjection();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  /**
   * Edits one bill line for one projected year. `deductionPct` and `upliftPct` are
   * percentages; `otherCharges` is dollars.
   */
  public OnBillAssumptionChange(key: keyof BillAssumptions, idx: number, value: string): void {
    const v = parseFloat(value);
    this.ActiveBill[key][idx] = isFinite(v) ? v : 0;
    this.recomputeProjection();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public OnOverrideToggle(enabled: boolean): void {
    this.ActiveAssumptions.override.enabled = enabled;
    this.recomputeProjection();
    this.cdr.markForCheck();
  }

  public OnOverrideYearChange(year: number): void {
    this.ActiveAssumptions.override.year = year;
    this.recomputeProjection();
    this.cdr.markForCheck();
  }

  public OnOverrideValueChange(value: string): void {
    const v = parseFloat(value);
    this.ActiveAssumptions.override.value = isFinite(v) ? v : null;
    this.recomputeProjection();
    this.cdr.markForCheck();
  }

  /** Restores THIS scenario's model defaults, leaving the other two scenarios' edits alone. */
  public OnResetScenario(): void {
    this.Scenarios[this.ActiveScenario] = JSON.parse(JSON.stringify(this.defaultScenarios[this.ActiveScenario])) as ScenarioState;
    this.BillAssumptionsByScenario[this.ActiveScenario] = JSON.parse(JSON.stringify(this.defaultBills[this.ActiveScenario])) as BillAssumptions;
    this.recomputeProjection();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  /** A figure with no value is blank, never "$0.00" -- those are different claims. */
  public FormatFigure(row: BillRow, figure: BillFigure): string {
    if (figure.value == null) return '—';
    if (!row.isCurrency) return `${figure.value.toFixed(4)}%`;
    return figure.value.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });
  }

  public ProvenanceMark(figure: BillFigure): string {
    return figure.source === 'actual' ? '●' : '‡';
  }

  // ---------------------------------------------------------------------
  // Agent context
  // ---------------------------------------------------------------------

  /**
   * 🚨 SAFETY BOUNDARY: this dashboard exposes only navigation and view state to the
   * agent -- select a parcel, switch scenario, widen the columns. Scenario-assumption
   * edits stay a HUMAN action: the agent could otherwise silently rewrite a projection a
   * taxpayer relies on. No save/publish path exists on this surface at all.
   */
  private publishAgentContext(): void {
    this.navigationService.SetAgentContext(this, {
      SelectedParcelID: this.SelectedParcel?.ID ?? null,
      SelectedParcelAddress: this.SelectedParcel?.Address ?? null,
      ActiveScenario: this.ActiveScenario,
      ColumnWindow: this.ShowAllColumns ? 'all' : 'recent',
      VisibleColumnLabels: this.VisibleColumns.map((c) => c.label),
      BaseYear: this.BaseYear || null,
      BridgeYear: this.KnownAV ? this.KnownAV.year : null,
      StatutoryCapClass: this.BillCalibration?.capClass ?? null,
      UpliftSource: this.BillCalibration?.upliftSource ?? null,
      CapIsBinding: this.FallbackUpliftIsBinding,
      BillLinesEdited: this.BillIsEdited,
      HasBillShape: this.HasBillShape,
      ProjectedTotalDueFinalYear: this.FinalYearTotalDue,
    });
    this.navigationService.SetAgentClientTools(this, [
      {
        Name: 'SearchParcel',
        Description: 'Search for a Marion County parcel by address, parcel number, or GIS parcel number, and load its bill-shaped tax projection',
        ParameterSchema: { type: 'object', properties: { query: { type: 'string' } }, required: ['query'] },
        Handler: async (params: Record<string, unknown>) => {
          const query = String(params['query'] ?? '');
          if (!query.trim()) return { Success: false, ErrorMessage: 'A search query is required' };
          await this.runParcelSearch(query);
          if (!this.SearchResults.length) return { Success: false, ErrorMessage: `No parcel found matching "${query}"` };
          await this.OnParcelSelected(this.SearchResults[0]);
          return { Success: true, Data: { Selected: this.SearchResults[0] } };
        },
      },
      {
        Name: 'SwitchScenario',
        Description: 'Show the projected bill under a different scenario: WorstCase, MostLikely, or BestCase',
        ParameterSchema: { type: 'object', properties: { scenario: { type: 'string', enum: [...SCENARIO_NAMES] } }, required: ['scenario'] },
        Handler: async (params: Record<string, unknown>) => {
          const raw = String(params['scenario'] ?? '');
          const match = SCENARIO_NAMES.find((n) => n.toLowerCase() === raw.toLowerCase());
          if (!match) return { Success: false, ErrorMessage: `Unknown scenario "${raw}". Available: ${SCENARIO_NAMES.join(', ')}` };
          this.OnScenarioChange(match);
          return { Success: true, Data: { ActiveScenario: match } };
        },
      },
      {
        Name: 'ToggleColumnWindow',
        Description: 'Switch between the recent window (2 actual + 3 projected years) and every loaded year',
        ParameterSchema: { type: 'object', properties: { showAll: { type: 'boolean' } }, required: [] },
        Handler: async (params: Record<string, unknown>) => {
          const requested = params['showAll'];
          this.ShowAllColumns = typeof requested === 'boolean' ? requested : !this.ShowAllColumns;
          this.refreshColumns();
          this.publishAgentContext();
          this.cdr.markForCheck();
          return { Success: true, Data: { ColumnWindow: this.ShowAllColumns ? 'all' : 'recent' } };
        },
      },
    ]);
  }
}

function num(v: number | null | undefined): number | null {
  if (v == null) return null;
  const n = Number(v);
  return isFinite(n) ? n : null;
}

/** Dollars, to the cent. Deliberately not named r2 alongside r4 -- see V1's note. */
function round2(x: number): number {
  return Math.round(x * 100) / 100;
}

/** A growth-rate assumption (0.0389 = 3.89%) to basis-point resolution. */
function r4(x: number): number {
  return Math.round(x * 10000) / 10000;
}

function clampRate(cagr: number | null): number {
  return cagr == null ? 0 : Math.max(-0.05, Math.min(0.05, cagr));
}

interface TaxHistoryRawRow {
  TaxYear: number;
  LandAssessment: number | null;
  Improvements: number | null;
  GrossAssessment: number | null;
  TaxRate: number | null;
  NetAnnualTax: number | null;
}

interface TaxBillRawRow {
  PayYear: number;
  GrossAssessedValue: number | null;
  NetAssessedValue: number | null;
  LocalTaxRate: number | null;
  GrossTaxDue: number | null;
  PropertyTaxCapSavings: number | null;
  TotalPropertyTaxDue: number | null;
  TotalOtherCharges: number | null;
  AVSubjectTo1Pct: number | null;
  AVSubjectTo2Pct: number | null;
  AVSubjectTo3Pct: number | null;
  StatutoryCapClass: string | null;
}

interface SaleRawRow {
  SaleDate: string;
  SalePrice: number;
  AssessedValueAtSale: number;
  PropertyTypeGroup: string | null;
}

interface AssessmentRawRow {
  AssessmentYear: number;
  OriginalTotalAV: number | null;
  OriginalLandAV: number | null;
  OriginalImprovementAV: number | null;
}
