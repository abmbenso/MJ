import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit, OnDestroy } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData } from '@memberjunction/core-entities';
import { RunView } from '@memberjunction/core';
import {
  TaxHistoryRow,
  SaleAdjustment,
  ScenarioState,
  ScenarioName,
  SCENARIO_NAMES,
  SCENARIO_META,
  ProjectionRow,
  ParcelSearchResult,
  ScenarioProbabilityRow,
  KnownAssessment,
  gapBandForRatio,
} from './tax-budget-projection-types';
import { trendStats, projectScenario, narrativeLines, selectBaseYearRow, residualProbability } from './tax-budget-projection-engine';

const COUNTY_NUMBER = 49; // Marion
const AV_RELATIONSHIP_BAND = 0.1;
const SALE_LOOKBACK_YEARS = 3;
const YEARS_BACK = 5;
const YEARS_FORWARD = 5;
const TREND_LOOKBACK = 6;

@Component({
  standalone: false,
  selector: 'mj-tax-budget-projection-dashboard',
  templateUrl: './tax-budget-projection-dashboard.component.html',
  styleUrls: ['./tax-budget-projection-dashboard.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'TaxBudgetProjectionResource')
// tab-container.component.ts resolves every nav-item target through
// ClassFactory.GetRegistrationAsync(BaseResourceComponent, driverClass) -- never
// BaseDashboard directly -- so a BaseDashboard-only registration is unreachable as an
// Application.DefaultNavItems target. Same second decorator PropertySearch and
// OwnerProspects use, for the same reason.
@RegisterClass(BaseResourceComponent, 'TaxBudgetProjectionResource')
export class TaxBudgetProjectionDashboardComponent extends BaseDashboard implements AfterViewInit, OnDestroy {
  public IsLoading = false;
  public IsSearching = false;
  public SearchTerm = '';
  public SearchResults: ParcelSearchResult[] = [];
  public SelectedParcel: ParcelSearchResult | null = null;

  public HistoricalRows: TaxHistoryRow[] = [];
  /** The last assessment year with BOTH a published value and a published tax rate. */
  public BaseYear = 0;
  public BaseLand = 0;
  public BaseImp = 0;
  public BaseRate = 0;
  /**
   * The bridge year: an assessment the Assessor has already published for a year whose
   * tax rate DLGF has not certified yet. Null outside that window (i.e. once the rate
   * lands, the year moves into history and this clears).
   */
  public KnownAV: KnownAssessment | null = null;

  /**
   * The parcel's own bill shape, from indiana_tax.TaxBill. This is what makes the
   * projection compute a real bill instead of AV x rate -- the old formula overstated tax
   * on 25% of the parcels this dashboard serves, and on 100% of multifamily.
   * Null when the parcel has no loaded bills; the projection then falls back to the
   * legacy multiplication rather than inventing a calibration.
   */
  public BillCalibration: {
    deductionRatio: number;
    capClassShare: { av1Pct: number; av2Pct: number; av3Pct: number };
    uplift: number;
    upliftSource: 'parcel' | 'district';
    otherCharges: number;
    capClass: string | null;
    years: number;
  } | null = null;
  public SaleAdjustment: SaleAdjustment | null = null;

  public Scenarios: Record<ScenarioName, ScenarioState> = this.emptyScenarios();
  public ScenarioProjections: Record<ScenarioName, ProjectionRow[]> = { WorstCase: [], MostLikely: [], BestCase: [] };
  public ScenarioNarratives: Record<ScenarioName, string[]> = { WorstCase: [], MostLikely: [], BestCase: [] };

  public readonly ScenarioNames = SCENARIO_NAMES;
  public readonly ScenarioMeta = SCENARIO_META;
  public readonly YearsForward = YEARS_FORWARD;

  /** Surfaced to the user when a query fails, instead of rendering an empty budget as if the parcel had no data. */
  public LoadError: string | null = null;

  private searchDebounce: ReturnType<typeof setTimeout> | null = null;
  /**
   * Monotonic token for parcel searches. Responses can land out of order (a slow query for
   * "730" returning after a fast one for "7300"), and the late response would otherwise
   * overwrite the newer results. Only the newest request is allowed to publish.
   */
  private searchSeq = 0;

  // navigationService is inherited from BaseDashboard/BaseResourceComponent -- never re-injected here (shadows the base with narrower visibility and breaks the build).
  constructor(private cdr: ChangeDetectorRef) {
    super();
  }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Tax Budget Projection';
  }

  initDashboard(): void {
    // No parcel selected on load -- the search box is the entry point.
  }

  async loadData(): Promise<void> {
    // Nothing to preload; NotifyLoadComplete() fires automatically after this resolves.
  }

  ngAfterViewInit(): void {
    this.publishAgentContext();
  }

  override ngOnDestroy(): void {
    // A pending debounce would otherwise fire into a destroyed view.
    if (this.searchDebounce) {
      clearTimeout(this.searchDebounce);
      this.searchDebounce = null;
    }
    super.ngOnDestroy();
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
    if (seq !== this.searchSeq) return; // a newer search has since been issued -- discard this response
    this.SearchResults = result.Success ? (result.Results ?? []) : [];
    this.LoadError = result.Success ? null : `Parcel search failed: ${result.ErrorMessage ?? 'unknown error'}`;
    this.IsSearching = false;
    this.cdr.markForCheck();
  }

  public async OnParcelSelected(parcel: ParcelSearchResult): Promise<void> {
    this.SelectedParcel = parcel;
    this.SearchResults = [];
    this.SearchTerm = `${parcel.GISParcelNumber} — ${parcel.Address}`;
    await this.loadParcelBudget(parcel.ID);
    this.publishAgentContext();
  }

  // ---------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------

  private async loadParcelBudget(parcelId: string): Promise<void> {
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

      // A failed query is NOT "this parcel has no history" -- rendering an empty budget for a
      // transport/permission failure would quietly understate a real parcel's taxes.
      const failed = [taxHistoryResult, assessmentResult, billResult, saleResult].filter((r) => !r.Success);
      if (failed.length) {
        this.LoadError = `Could not load this parcel's budget: ${failed.map((f) => f.ErrorMessage ?? 'unknown error').join('; ')}`;
      }
      this.applyTaxHistory(taxHistoryResult.Success ? ((taxHistoryResult.Results as unknown as TaxHistoryRawRow[]) ?? []) : []);
      const latestAssessment = assessmentResult.Success ? (assessmentResult.Results?.[0] as unknown as AssessmentRawRow | undefined) : undefined;
      this.applyBases(latestAssessment);
      this.applyBillCalibration(billResult.Success ? ((billResult.Results as unknown as TaxBillRawRow[]) ?? []) : []);

      const saleRow = saleResult.Success ? (saleResult.Results?.[0] as unknown as SaleRawRow | undefined) : undefined;
      this.SaleAdjustment = this.buildSaleAdjustment(saleRow);

      await this.buildScenarios();
    } finally {
      this.IsLoading = false;
      this.cdr.markForCheck();
    }
  }

  private applyTaxHistory(rows: TaxHistoryRawRow[]): void {
    const full: TaxHistoryRow[] = rows.map((r) => ({
      Year: Number(r.TaxYear),
      Land: Number(r.LandAssessment) || 0,
      Improvement: Number(r.Improvements) || 0,
      TotalAV: Number(r.GrossAssessment) || 0,
      TaxRate: Number(r.TaxRate) || 0,
      Tax: r.NetAnnualTax != null ? Number(r.NetAnnualTax) : null,
    }));
    this.fullHistory = full;
    this.HistoricalRows = full.slice(-YEARS_BACK);
  }

  private fullHistory: TaxHistoryRow[] = [];

  /**
   * Establishes the projection base and the bridge year as two SEPARATE things.
   *
   * The base must be one coherent year -- value and rate both published -- or the two
   * advance at different speeds and every projected tax comes out low. A later assessment
   * that has no rate yet is not a base; it is a pin on the first projected year.
   */
  private applyBases(latest: AssessmentRawRow | undefined): void {
    const baseRow = selectBaseYearRow(this.fullHistory);
    if (baseRow) {
      this.BaseYear = baseRow.Year;
      this.BaseLand = baseRow.Land;
      this.BaseImp = baseRow.Improvement;
      this.BaseRate = baseRow.TaxRate;
    } else {
      this.BaseYear = 0;
      this.BaseLand = 0;
      this.BaseImp = 0;
      this.BaseRate = 0;
    }

    this.KnownAV = null;
    if (latest && this.BaseYear) {
      const year = Number(latest.AssessmentYear);
      const offset = year - this.BaseYear;
      if (offset >= 1 && offset <= YEARS_FORWARD) {
        this.KnownAV = {
          year,
          land: Number(latest.OriginalLandAV) || 0,
          imp: Number(latest.OriginalImprovementAV) || 0,
        };
      }
    }
  }

  /**
   * Derives the parcel's own bill shape from its loaded DLGF bills.
   *
   * Uplift comes from the parcel's OWN capped years where it has any -- measured on real
   * parcels its own figure beats the district mean (16.45% vs 15.20% on 9003241). Only a
   * parcel that has never been capped falls back to a district-level figure, and the
   * source is carried so the UI can say which was used rather than implying false
   * precision.
   */
  private applyBillCalibration(bills: TaxBillRawRow[]): void {
    this.BillCalibration = null;
    const usable = bills.filter((b) => Number(b.GrossAssessedValue) > 0);
    if (!usable.length) return;

    // Use the LATEST bill's shape, not an average across years. A projection starts from
    // where the parcel is NOW, and deductions/abatements change: parcel 9003241 gained a
    // deduction recently, so averaging gave 1.2% where its current ratio is 6.0% -- which
    // pushed the projection above the parcel's own long-run effective rate.
    const latest = usable[0];
    const deductionRatio =
      (Number(latest.GrossAssessedValue) - Number(latest.NetAssessedValue ?? latest.GrossAssessedValue)) / Number(latest.GrossAssessedValue);
    const g = Number(latest.GrossAssessedValue);
    const capClassShare = {
      av1Pct: Number(latest.AVSubjectTo1Pct ?? 0) / g,
      av2Pct: Number(latest.AVSubjectTo2Pct ?? 0) / g,
      av3Pct: Number(latest.AVSubjectTo3Pct ?? 0) / g,
    };

    // The parcel's own uplift, from the MOST RECENT year where the cap actually bound --
    // same reasoning as the deduction ratio. District levies drift, so the latest capped
    // year is a better forward estimate than a mean across older ones.
    const capped = usable.filter((b) => Number(b.PropertyTaxCapSavings ?? 0) > 0).slice(0, 1);
    const ownUplifts = capped
      .map((b) => {
        const ceiling = Number(b.AVSubjectTo1Pct ?? 0) * 0.01 + Number(b.AVSubjectTo2Pct ?? 0) * 0.02 + Number(b.AVSubjectTo3Pct ?? 0) * 0.03;
        return ceiling > 0 ? (Number(b.TotalPropertyTaxDue) - ceiling) / ceiling : null;
      })
      .filter((u): u is number => u != null && isFinite(u));

    const uplift = ownUplifts.length ? ownUplifts.reduce((a, b) => a + b, 0) / ownUplifts.length : DISTRICT_UPLIFT_FALLBACK;

    this.BillCalibration = {
      deductionRatio,
      capClassShare,
      uplift,
      upliftSource: ownUplifts.length ? 'parcel' : 'district',
      otherCharges: Number(latest.TotalOtherCharges ?? 0),
      capClass: (latest.StatutoryCapClass as string) ?? null,
      years: usable.length,
    };
  }

  /**
   * True when the projection is BOTH using the county placeholder AND actually hitting the
   * cap -- the only situation where that placeholder changes the answer. ~0.5% of parcels.
   */
  public get FallbackUpliftIsBinding(): boolean {
    if (this.BillCalibration?.upliftSource !== 'district') return false;
    return SCENARIO_NAMES.some((n) =>
      this.ScenarioProjections[n]?.some((row) => {
        const share = this.BillCalibration!.capClassShare;
        const bare = row.totalAV * (share.av1Pct * 0.01 + share.av2Pct * 0.02 + share.av3Pct * 0.03);
        const grossTax = (row.totalAV * (1 - this.BillCalibration!.deductionRatio) * row.rate) / 100;
        return bare > 0 && grossTax > bare * (1 + this.BillCalibration!.uplift);
      }),
    );
  }

  /** True when this parcel sits in a cap class where `AV x rate` was reliably wrong. */
  public get IsMultifamilyCapClass(): boolean {
    return this.BillCalibration?.capClass === 'OtherResidential';
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
   * Zero-based index into the per-year assumption arrays of the bridge year, or -1.
   * That year's value growth is not an input -- the Assessor has already set it -- so the
   * template locks its Land/Improvement cells and leaves only its tax rate editable.
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

  // ---------------------------------------------------------------------
  // Scenario assembly
  // ---------------------------------------------------------------------

  private async buildScenarios(): Promise<void> {
    const window = this.fullHistory.slice(-TREND_LOOKBACK);
    const landTrend = trendStats(window, 'Land');
    const impTrend = trendStats(window, 'Improvement');
    const rateTrend = trendStats(window, 'TaxRate');

    const mostLikelyLand = Array(YEARS_FORWARD).fill(this.r4(landTrend.cagr ?? 0));
    const mostLikelyImp = Array(YEARS_FORWARD).fill(this.r4(impTrend.cagr ?? 0));
    const mostLikelyRate = this.clampedRateSeries(rateTrend.cagr);
    const bestLand = mostLikelyLand.map((v: number) => this.r4(v / 2));
    const bestImp = mostLikelyImp.map((v: number) => this.r4(v / 2));

    const scenarios = this.emptyScenarios();
    scenarios.MostLikely = { ...scenarios.MostLikely, mode: 'trend', land: mostLikelyLand, imp: mostLikelyImp, rate: mostLikelyRate };
    scenarios.BestCase = { ...scenarios.BestCase, mode: 'trend', land: bestLand, imp: bestImp, rate: mostLikelyRate };

    // Compare against the most recent PUBLISHED assessment (the bridge year's, when there is
    // one) -- not the older projection base, which would miss a chase that has already landed.
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
        scenarios.MostLikely.probability = this.r4(residualProbability(probs.PWorstCaseFullChase, probs.PBestCaseNoReaction));
        scenarios.MostLikely.probabilitySource = `residual after Worst Case + Best Case (${scenarios.WorstCase.probabilitySource})`;
      }
    } else if (alreadyCaughtUp && this.SaleAdjustment) {
      scenarios.WorstCase = {
        ...scenarios.WorstCase,
        mode: 'trend',
        land: mostLikelyLand.map((v: number) => this.r4(v + (landTrend.volatility ?? 0.02))),
        imp: mostLikelyImp.map((v: number) => this.r4(v + (impTrend.volatility ?? 0.02))),
        rate: mostLikelyRate,
        probabilitySource: `the ${this.CurrentAVYear} AV ($${Math.round(baseTotal).toLocaleString()}) is already at or above the $${Math.round(this.SaleAdjustment.salePrice).toLocaleString()} sale price from ${this.SaleAdjustment.saleYear} -- any chase reaction already happened between the sale and now, so this is an aggressive-trend fallback from the current (already-elevated) base, not a fresh step`,
      };
    } else {
      scenarios.WorstCase = {
        ...scenarios.WorstCase,
        mode: 'trend',
        land: mostLikelyLand.map((v: number) => this.r4(v + (landTrend.volatility ?? 0.02))),
        imp: mostLikelyImp.map((v: number) => this.r4(v + (impTrend.volatility ?? 0.02))),
        rate: mostLikelyRate,
        probabilitySource: 'no recent qualifying sale on file -- probability not estimated; this is an aggressive-trend fallback, not an empirical figure',
      };
    }

    this.Scenarios = scenarios;
    // Snapshot the model defaults (deep clone) so a later single-scenario
    // reset can restore just that scenario without discarding the user's
    // edits to the other two.
    this.defaultScenarios = JSON.parse(JSON.stringify(scenarios)) as Record<ScenarioName, ScenarioState>;
    for (const name of SCENARIO_NAMES) this.recompute(name);
  }

  private defaultScenarios: Record<ScenarioName, ScenarioState> = this.emptyScenarios();

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
    // Prefer the most recent row for the exact type, and prefer one that isn't LowSample;
    // fall back to the county-wide 'All' row when the type-specific sample is too thin.
    const exact = result.Results.find((r) => r.PropertyTypeGroup === propertyType && !r.LowSample);
    const exactAny = result.Results.find((r) => r.PropertyTypeGroup === propertyType);
    const fallback = result.Results.find((r) => r.PropertyTypeGroup === 'All');
    return exact ?? exactAny ?? fallback ?? result.Results[0];
  }

  private clampedRateSeries(cagr: number | null): number[] {
    const clamped = cagr == null ? 0 : Math.max(-0.05, Math.min(0.05, cagr));
    return Array(YEARS_FORWARD).fill(this.r4(clamped));
  }

  /**
   * Rounds a GROWTH-RATE assumption (a decimal fraction: 0.0389 = 3.89%) to four places --
   * basis-point resolution. Deliberately NOT called `r2`: the CLI twin has an `r2` that
   * rounds to two places for DOLLARS, and when both helpers shared the one name the two
   * implementations silently disagreed (a CAGR of 0.0389 became 0.04 on one side only) and
   * produced different numbers for the same parcel.
   */
  private r4(x: number): number {
    return Math.round(x * 10000) / 10000;
  }

  // ---------------------------------------------------------------------
  // Editable inputs
  // ---------------------------------------------------------------------

  public OnAssumptionChange(name: ScenarioName, key: 'land' | 'imp' | 'rate', idx: number, valuePercent: string): void {
    const v = parseFloat(valuePercent);
    this.Scenarios[name][key][idx] = isFinite(v) ? this.r4(v / 100) : 0;
    this.recompute(name);
    this.cdr.markForCheck();
  }

  public OnOverrideToggle(name: ScenarioName, enabled: boolean): void {
    this.Scenarios[name].override.enabled = enabled;
    this.recompute(name);
    this.cdr.markForCheck();
  }

  public OnOverrideYearChange(name: ScenarioName, year: number): void {
    this.Scenarios[name].override.year = year;
    this.recompute(name);
    this.cdr.markForCheck();
  }

  public OnOverrideValueChange(name: ScenarioName, value: string): void {
    const v = parseFloat(value);
    this.Scenarios[name].override.value = isFinite(v) ? v : null;
    this.recompute(name);
    this.cdr.markForCheck();
  }

  public OnResetScenario(name: ScenarioName): void {
    this.Scenarios[name] = JSON.parse(JSON.stringify(this.defaultScenarios[name])) as ScenarioState;
    this.recompute(name);
    this.cdr.markForCheck();
  }

  private recompute(name: ScenarioName): void {
    const scenario = this.Scenarios[name];
    this.ScenarioProjections[name] = projectScenario({
      baseYear: this.BaseYear,
      baseLand: this.BaseLand,
      baseImp: this.BaseImp,
      baseRate: this.BaseRate,
      scenario,
      yearsForward: YEARS_FORWARD,
      knownAV: this.KnownAV,
      deductionRatio: this.BillCalibration?.deductionRatio ?? null,
      capClassShare: this.BillCalibration?.capClassShare ?? null,
      uplift: this.BillCalibration?.uplift ?? null,
      otherCharges: this.BillCalibration?.otherCharges ?? null,
    });
    this.ScenarioNarratives[name] = narrativeLines(name, scenario, this.BaseYear, this.KnownAV);
  }

  // ---------------------------------------------------------------------
  // Agent context
  // ---------------------------------------------------------------------

  /**
   * 🚨 SAFETY BOUNDARY: this dashboard exposes only navigation (select a
   * parcel) to the agent. Scenario-assumption edits stay a human action --
   * the agent could otherwise silently rewrite a projection a taxpayer
   * relies on. No save/publish path exists on this surface at all yet.
   */
  private publishAgentContext(): void {
    this.navigationService.SetAgentContext(this, {
      SelectedParcelID: this.SelectedParcel?.ID ?? null,
      SelectedParcelAddress: this.SelectedParcel?.Address ?? null,
      BaseYear: this.BaseYear || null,
      BridgeYear: this.KnownAV ? this.KnownAV.year : null,
      HasRecentSale: this.SaleAdjustment != null,
      WorstCaseProbability: this.Scenarios.WorstCase.probability,
      MostLikelyProbability: this.Scenarios.MostLikely.probability,
      BestCaseProbability: this.Scenarios.BestCase.probability,
    });
    this.navigationService.SetAgentClientTools(this, [
      {
        Name: 'SearchParcel',
        Description: 'Search for a Marion County parcel by address, parcel number, or GIS parcel number, and load its tax budget projection',
        ParameterSchema: { type: 'object', properties: { query: { type: 'string' } }, required: ['query'] },
        Handler: async (params: Record<string, unknown>) => {
          const query = String(params['query'] ?? '');
          await this.runParcelSearch(query);
          if (this.SearchResults.length) {
            await this.OnParcelSelected(this.SearchResults[0]);
            return { Success: true, Data: { Selected: this.SearchResults[0] } };
          }
          return { Success: false, ErrorMessage: `No parcel found matching "${query}"` };
        },
      },
    ]);
  }
}

interface TaxHistoryRawRow {
  TaxYear: number;
  LandAssessment: number | null;
  Improvements: number | null;
  GrossAssessment: number | null;
  TaxRate: number | null;
  NetAnnualTax: number | null;
}

/**
 * County-wide fallback uplift, used only when a parcel has never been capped. Marion's
 * per-district figures span -0.5% to +27% (41 districts), so this is deliberately a
 * middling placeholder for a case where the cap is unlikely to bind at all -- it is not a
 * substitute for the district table.
 */
/**
 * County-wide placeholder, used ONLY when a parcel has never been capped.
 *
 * Deliberately NOT a per-district table. Measured on the 19,089 parcels this dashboard
 * serves: 4,543 (23.8%) are capped today and calibrate from their OWN history; ~75% never
 * cap, so this value never touches their output; and just **99 parcels (0.5%)** are
 * never-capped yet would cap under a 50% AV jump. That last group is the only population
 * whose numbers this constant changes -- far too narrow to justify a migration, a CodeGen
 * cycle and a 41-row table that would then need maintaining.
 *
 * Marion's real per-district figures span -0.5% to +27% (see
 * scripts/derive-district-uplift.js), so this IS a rough middle. Where it actually binds,
 * the UI says so rather than presenting it as measured.
 */
const DISTRICT_UPLIFT_FALLBACK = 0.15;

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

interface AssessmentRawRow {
  AssessmentYear: number;
  OriginalTotalAV: number | null;
  OriginalLandAV: number | null;
  OriginalImprovementAV: number | null;
}

interface SaleRawRow {
  SaleDate: string;
  SalePrice: number;
  AssessedValueAtSale: number;
  PropertyTypeGroup: string | null;
}
