import { Component, ChangeDetectionStrategy, ChangeDetectorRef, Input } from '@angular/core';
import { RunView } from '@memberjunction/core';
import { BaseAngularComponent } from '@memberjunction/ng-base-types';
import { ColDef, GridOptions, Theme, themeAlpine, ModuleRegistry, AllCommunityModule } from 'ag-grid-community';
import {
  SubClassAssessmentRow,
  SubClassAppealRow,
  AppealTypeFilter,
  buildSubClassAssessmentRows,
  buildSubClassAppealRows,
  formatCurrency,
} from './property-search-agent-context';
import { MARION_COUNTY_NUMBER } from './property-search-county';

ModuleRegistry.registerModules([AllCommunityModule]);

function formatCurrencyCell(params: { value: number | null }): string {
  return formatCurrency(params.value);
}
function formatDollarPerSqFtCell(params: { value: number | null }): string {
  return params.value == null ? '—' : `${formatCurrency(Math.round(params.value))}/SF`;
}
function formatPercentCell(params: { value: number | null }): string {
  return params.value == null ? '—' : `${params.value.toFixed(1)}%`;
}

/**
 * Two cross-sub-class rollups for Property Search's Analytics view mode:
 * current assessed-value profile (Assessment Analytics, year-scoped) and
 * historical PTABOA appeal outcomes (Appeal Analytics, all-time). Owns its
 * own data fetch (unlike the presentational panel/grid siblings in this
 * folder) because these are GLOBAL rollups over the full ~19,859-parcel
 * universe, independent of whatever the main dashboard's search/filter/
 * result-cap state currently is -- see the aggregation helpers' own doc
 * comments in property-search-agent-context.ts for the full reasoning.
 *
 * Lazy: does nothing until `Active` is set true (the host only does this
 * once the user actually switches to the Analytics view), then caches the
 * sub-class-invariant raw rows (CountyAssessorRecord, PTABOAAppeal -- neither
 * depends on AssessmentYear) so a later year change only re-fetches and
 * re-aggregates the Assessment half, not the whole thing.
 */
@Component({
  standalone: false,
  selector: 'mj-property-subclass-analytics',
  templateUrl: './property-subclass-analytics.component.html',
  styleUrls: ['./property-subclass-analytics.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PropertySubclassAnalyticsComponent extends BaseAngularComponent {
  /**
   * The host template declares [Active]="true" BEFORE [CountyNumber] / [HasCardData] /
   * [AssessmentYear], and Angular applies bindings in declaration order -- so on creation this
   * setter fires while the other inputs still hold their defaults (Marion, card data, this
   * year). The first load is therefore DEFERRED through scheduleRefresh()'s microtask, which
   * runs only after every binding of the cycle has been applied. Loading synchronously here
   * fetched Marion's 20,722 record cards for whichever county was actually selected (caught in
   * the Plan B click-through, 2026-09-13: Analytics on Lake rolled up Marion's sub-classes).
   */
  @Input()
  set Active(value: boolean) {
    const wasActive = this._active;
    this._active = value;
    if (value && !wasActive && !this._loadedOnce) this.scheduleRefresh();
  }
  get Active(): boolean {
    return this._active;
  }
  private _active = false;
  private _loadedOnce = false;

  @Input()
  set AssessmentYear(value: number) {
    const changed = value !== this._assessmentYear;
    this._assessmentYear = value;
    if (changed && this._loadedOnce) {
      void this.loadAssessmentAnalytics();
    }
  }
  get AssessmentYear(): number {
    return this._assessmentYear;
  }
  private _assessmentYear = new Date().getFullYear();

  /**
   * County / card-data changes refresh whenever the surface is active -- NOT only once a prior
   * load has finished. Gating on _loadedOnce silently dropped any switch that arrived while a
   * fetch was still in flight (a 20k-row fetch takes seconds), leaving the previous county's
   * rows under the new county's number. A superseded fetch is discarded by loadSeq instead.
   */
  @Input()
  set CountyNumber(value: number) {
    const changed = value !== this._countyNumber;
    this._countyNumber = value;
    if (changed && this._active) this.scheduleRefresh();
  }
  get CountyNumber(): number {
    return this._countyNumber;
  }
  private _countyNumber = MARION_COUNTY_NUMBER;

  /**
   * False for a DLGF-only county: there are no CountyAssessorRecord rows to roll up. MUST be a
   * setter (not a plain field) -- Angular applies template bindings in declaration order, and
   * the host template sets [CountyNumber] before [HasCardData], so on a county switch
   * CountyNumber's setter can fire and reload BEFORE HasCardData's own binding has updated to
   * match. Both setters route through scheduleRefresh() (a microtask-coalesced Refresh()), so
   * whichever binding lands first the actual reload runs once, after both inputs are current --
   * the component reaches the right state regardless of binding order.
   */
  @Input()
  set HasCardData(value: boolean) {
    const changed = value !== this._hasCardData;
    this._hasCardData = value;
    if (changed && this._active) this.scheduleRefresh();
  }
  get HasCardData(): boolean {
    return this._hasCardData;
  }
  private _hasCardData = true;

  public IsLoading = false;
  public AssessmentRows: SubClassAssessmentRow[] = [];
  public AppealRows: SubClassAppealRow[] = [];
  public IncludedAppealCount = 0;
  public ExcludedExemptionCount = 0;

  /** 'valuation' (default) excludes Form 136/136C Exemption records from the appeal rollup -- see AppealTypeFilter's doc comment for why mixing them in skews a valuation-focused win-rate/reduction view. Local UI state, not persisted -- matches the ActiveViewMode/TrendYearsOption precedent elsewhere in this dashboard. */
  public AppealTypeFilterValue: AppealTypeFilter = 'valuation';
  public readonly AppealTypeFilterOptions = [
    { key: 'valuation', label: 'Valuation Appeals (130O/130S)' },
    { key: 'all', label: 'All Types (incl. Exemptions)' },
  ];

  public onAppealTypeFilterChange(key: string): void {
    this.AppealTypeFilterValue = key === 'all' ? 'all' : 'valuation';
    this.recomputeAppealAnalytics();
    this.cdr.markForCheck();
  }

  /** CountyAssessorRecord rows -- fetched once, reused by BOTH rollups (sub class lookup doesn't depend on year). */
  private carRowsCache: Record<string, unknown>[] | null = null;
  /** PTABOAAppeal rows -- fetched once (all-time, not year-scoped). Re-aggregated (not re-fetched) whenever AppealTypeFilterValue changes. */
  private appealRowsCache: Record<string, unknown>[] | null = null;

  constructor(private cdr: ChangeDetectorRef) {
    super();
  }

  /**
   * Coalesces CountyNumber + HasCardData changes that land in the same change-detection cycle
   * into exactly one Refresh() call, deferred to a microtask so it runs only after every input
   * setter for this cycle has already updated its own backing field -- see HasCardData's doc
   * comment above for why this matters.
   */
  private refreshScheduled = false;
  private scheduleRefresh(): void {
    if (this.refreshScheduled) return;
    this.refreshScheduled = true;
    void Promise.resolve().then(() => {
      this.refreshScheduled = false;
      this.Refresh();
    });
  }

  /**
   * Monotonic load token. Every loadAll() takes the next value and, after each await, drops
   * its results if a newer load has started since -- so the rows on screen always belong to
   * the inputs that were current when the LATEST load began, never to an older in-flight fetch
   * that happened to land last.
   */
  private loadSeq = 0;

  public Refresh(): void {
    this.carRowsCache = null;
    this.appealRowsCache = null;
    this._loadedOnce = false;
    void this.loadAll();
  }

  private async loadAll(): Promise<void> {
    const seq = ++this.loadSeq;
    if (!this.HasCardData) {
      this.AssessmentRows = [];
      this.AppealRows = [];
      this.IsLoading = false;
      this._loadedOnce = true;
      this.cdr.markForCheck();
      return;
    }
    this.IsLoading = true;
    this.cdr.markForCheck();

    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const [carResult, appealResult] = await rv.RunViews<Record<string, unknown>>([
      {
        EntityName: 'County Assessor Records',
        Fields: ['ParcelID', 'PropertySubClassDescription', 'SqFtSource', 'EstimatedSqFt'],
        ExtraFilter: `CountyNumber = ${this.CountyNumber}`,
        // Full C&I universe for the SELECTED county, not the main dashboard's filtered/capped
        // result set -- Marion's own count was ~19,859 parcels as of 2026-08-26; 25000 gives
        // headroom for any county with card data (this branch only runs when HasCardData is true).
        MaxRows: 25000,
        ResultType: 'simple',
      },
      {
        EntityName: 'PTABOA Appeals',
        Fields: ['ParcelID', 'CaseNumber', 'HearingDate', 'BeforeTotalAV', 'AfterTotalAV', 'RecordKind'],
        ExtraFilter: `ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = ${this.CountyNumber})`,
        // All appeals on file for the selected county (Marion's own count was 1,223 as of
        // 2026-08-26) -- generous headroom, not year-scoped.
        MaxRows: 5000,
        ResultType: 'simple',
      },
    ]);

    if (seq !== this.loadSeq) return; // superseded by a later county / card-data change

    this.carRowsCache = carResult.Success ? (carResult.Results ?? []) : [];
    this.appealRowsCache = appealResult.Success ? (appealResult.Results ?? []) : [];
    this.recomputeAppealAnalytics();
    this._loadedOnce = true;

    await this.loadAssessmentAnalytics();
  }

  /** Pure re-aggregation over the already-fetched appeal/CAR rows -- no network round trip, so the type-filter toggle is instant. */
  private recomputeAppealAnalytics(): void {
    const { rows, includedCount, excludedExemptionCount } = buildSubClassAppealRows(
      this.appealRowsCache ?? [],
      this.carRowsCache ?? [],
      this.AppealTypeFilterValue
    );
    this.AppealRows = rows;
    this.IncludedAppealCount = includedCount;
    this.ExcludedExemptionCount = excludedExemptionCount;
  }

  private async loadAssessmentAnalytics(): Promise<void> {
    if (!this.carRowsCache) return; // loadAll() hasn't populated the shared CAR cache yet
    const seq = this.loadSeq;
    this.IsLoading = true;
    this.cdr.markForCheck();

    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<Record<string, unknown>>({
      // The stored headline (one row per parcel-year, already source-resolved by the
      // Foundation's rule) -- the same number the Property Search grid shows, so the
      // sub-class totals and the list can never disagree with each other.
      EntityName: 'Parcel Year Headlines',
      Fields: ['ParcelID', 'HeadlineTotalAV'],
      ExtraFilter: `AssessmentYear = ${this.AssessmentYear} AND ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = ${this.CountyNumber})`,
      // One row per parcel: the largest county's whole roster is ~20,000 parcels
      // (Marion C&I 20,722), so 50,000 keeps the same headroom the old
      // two-sources-per-parcel query had.
      MaxRows: 50000,
      ResultType: 'simple',
    });

    if (seq !== this.loadSeq || !this.carRowsCache) return; // a newer load owns the screen now

    this.AssessmentRows = result.Success ? buildSubClassAssessmentRows(this.carRowsCache, result.Results ?? []) : [];
    this.IsLoading = false;
    this.cdr.markForCheck();
  }

  // ───── Assessment grid ─────

  public AssessmentColumnDefs: ColDef<SubClassAssessmentRow>[] = [
    { field: 'subClass', headerName: 'Property Sub Class', flex: 2, minWidth: 220, sort: 'asc' },
    { field: 'parcelCount', headerName: 'Parcels', width: 110, type: 'numericColumn' },
    { field: 'totalAV', headerName: 'Total Assessed Value', width: 170, type: 'numericColumn', valueFormatter: formatCurrencyCell },
    { field: 'avgAV', headerName: 'Avg Assessed Value', width: 160, type: 'numericColumn', valueFormatter: formatCurrencyCell },
    { field: 'avgDollarPerSqFt', headerName: 'Avg $/SF', width: 120, type: 'numericColumn', valueFormatter: formatDollarPerSqFtCell },
  ];

  // ───── Appeal grid ─────

  public AppealColumnDefs: ColDef<SubClassAppealRow>[] = [
    { field: 'subClass', headerName: 'Property Sub Class', flex: 2, minWidth: 220, sort: 'asc' },
    {
      field: 'appealType',
      headerName: 'Type',
      width: 90,
      headerTooltip: '130S = subjective/market-value (most directly informative for assessed-value accuracy). 130O = objective/mathematical-error correction. 136/136C = charitable/nonprofit Exemption (shown only under "All Types").',
    },
    { field: 'appealCount', headerName: 'Appeals', width: 100, type: 'numericColumn' },
    { field: 'reductions', headerName: 'Reductions', width: 110, type: 'numericColumn' },
    { field: 'winRate', headerName: 'Win Rate', width: 110, type: 'numericColumn', valueFormatter: formatPercentCell },
    { field: 'avgPctReductionWhenWon', headerName: 'Avg Reduction (when won)', width: 190, type: 'numericColumn', valueFormatter: formatPercentCell },
  ];

  public DefaultColDef: ColDef = { sortable: true, resizable: true, minWidth: 90 };

  public GridOptions: GridOptions = {
    animateRows: true,
    rowHeight: 34,
    headerHeight: 38,
    suppressCellFocus: true,
    enableCellTextSelection: true,
  };

  public Theme: Theme = themeAlpine.withParams({
    backgroundColor: 'var(--mj-bg-surface)',
    foregroundColor: 'var(--mj-text-primary)',
    textColor: 'var(--mj-text-primary)',
    borderColor: 'var(--mj-border-default)',
    chromeBackgroundColor: 'var(--mj-bg-surface-card)',
    headerBackgroundColor: 'var(--mj-bg-surface-card)',
    headerTextColor: 'var(--mj-text-secondary)',
    cellTextColor: 'var(--mj-text-primary)',
    subtleTextColor: 'var(--mj-text-muted)',
    dataBackgroundColor: 'var(--mj-bg-surface)',
    oddRowBackgroundColor: 'var(--mj-bg-surface-card)',
    rowHoverColor: 'var(--mj-bg-surface-hover, color-mix(in srgb, var(--mj-brand-primary) 5%, var(--mj-bg-surface)))',
    accentColor: 'var(--mj-brand-primary)',
    borderRadius: 'var(--mj-radius-sm)',
    browserColorScheme: 'inherit',
  });
}
