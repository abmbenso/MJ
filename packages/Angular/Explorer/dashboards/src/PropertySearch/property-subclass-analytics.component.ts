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
  @Input()
  set Active(value: boolean) {
    const wasActive = this._active;
    this._active = value;
    if (value && !wasActive && !this._loadedOnce) {
      void this.loadAll();
    }
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

  public Refresh(): void {
    this.carRowsCache = null;
    this.appealRowsCache = null;
    this._loadedOnce = false;
    void this.loadAll();
  }

  private async loadAll(): Promise<void> {
    this.IsLoading = true;
    this.cdr.markForCheck();

    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const [carResult, appealResult] = await rv.RunViews<Record<string, unknown>>([
      {
        EntityName: 'County Assessor Records',
        Fields: ['ParcelID', 'PropertySubClassDescription', 'SqFtSource', 'EstimatedSqFt'],
        // Full C&I universe, not the main dashboard's filtered/capped result
        // set -- ~19,859 parcels as of 2026-08-26, comfortably under this ceiling.
        MaxRows: 25000,
        ResultType: 'simple',
      },
      {
        EntityName: 'PTABOA Appeals',
        Fields: ['ParcelID', 'CaseNumber', 'HearingDate', 'BeforeTotalAV', 'AfterTotalAV', 'RecordKind'],
        // All 1,223 appeals on file -- generous headroom, not year-scoped.
        MaxRows: 5000,
        ResultType: 'simple',
      },
    ]);

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
    this.IsLoading = true;
    this.cdr.markForCheck();

    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<Record<string, unknown>>({
      EntityName: 'Assessments',
      Fields: ['ParcelID', 'Source', 'OriginalTotalAV'],
      ExtraFilter: `AssessmentYear = ${this.AssessmentYear} AND ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = 49)`,
      // A full year's worth of statewide Assessment rows across all sources
      // can approach ~40,000 (up to 2 sources x ~19,859 parcels) -- see
      // loadAssessmentYearsIfNeeded's own comment in the host dashboard for
      // the same ceiling reasoning.
      MaxRows: 50000,
      ResultType: 'simple',
    });

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
