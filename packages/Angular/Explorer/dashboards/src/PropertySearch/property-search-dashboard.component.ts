import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData, UserInfoEngine } from '@memberjunction/core-entities';
import { CompositeKey, EntityInfo, RunView } from '@memberjunction/core';
import { FilterFieldConfig } from '@memberjunction/ng-ui-components';
import { MapMarkerClickEvent } from '@memberjunction/ng-map-view';
import { ExportDialogConfig, ExportDialogResult } from '@memberjunction/ng-export-service';
import { ExportColumn } from '@memberjunction/export-engine';
import { INDIANA_APP_ID } from '../AppealWorkbench/appeal-workbench.component';

/**
 * This dashboard only ever uses point/boundary rendering (see the class
 * doc comment for why boundary mode drives the shared 750-record cap) —
 * narrower than geo-maps' full MapRenderMode ('point'|'boundary'|
 * 'choropleth'|'heatmap'), which is why every render-mode surface here is
 * typed to this alias rather than the library's broader union.
 */
type PropertySearchRenderMode = 'point' | 'boundary';
import { AgentToolResult } from '../shared/agent-tool-validation';
import {
  MergedParcelRow,
  PropertySearchFilters,
  DEFAULT_PROPERTY_SEARCH_FILTERS,
  PROPERTY_SEARCH_RESULT_CAP,
  resetFiltersForCountyChange,
  PROPERTY_SEARCH_BOUNDARY_RENDER_CAP,
  buildPropertySearchAgentContext,
  classifySearchTerm,
  escapeSqlLiteral,
  computePropertySearchSummaryStats,
  formatCurrency,
  pricePerSqFt,
  AssessmentTrendRow,
  buildAssessmentTrendRows,
  TREND_FETCH_MAX_YEARS,
  AppealHistoryRow,
  buildAppealHistoryRows,
  CoStarPropertyRow,
  buildCoStarPropertyRows,
  formatComparisonUnitCount,
  formatYearBuilt,
  RATIO_METRIC_DEFS,
  UNIT_OF_COMPARISON_DEFS,
} from './property-search-agent-context';
import {
  CountyOption,
  countyCardSource,
  countySourceTier,
  buildCountyOptions,
  tallyCIParcels,
  pickAssessmentRow,
  dataSourceLabel,
  isDlgfSourced,
  DLGF_NOTATION,
  buildVerifyLink,
  CI_ROSTER_PARCEL_FILTER,
} from './property-search-county';
import { fetchDlgfParcelRows, buildClassCodeSubClassOptions } from './property-search-dlgf';
import { PROPERTY_SEARCH_GRID_COLUMNS, PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS, PROPERTY_SEARCH_COLUMN_CATEGORIES } from './property-search-grid.component';

/** Parses CountyAssessorRecord.Acreage (NVARCHAR(10), legacy ArcGIS-sourced text) into a number, or null for blank/non-numeric/non-positive values -- the analytics panel's per-acre calculations need a real number, not the raw string RunView('simple') returns. */
function parseAcreage(raw: string | null): number | null {
  if (!raw) return null;
  const n = Number(raw);
  return Number.isFinite(n) && n > 0 ? n : null;
}

/** Export-column definitions for every RATIO_METRIC_DEFS x UNIT_OF_COMPARISON_DEFS ratio the grid also generates (see property-search-grid.component.ts's buildRatioColumns, same exclusion: Assessed Value / SF (County) is already the hand-written 'PricePerSqFt' export column above). Same key-naming scheme as the grid's generated colIds, so the two stay in lockstep. */
function buildRatioExportColumns(): ExportColumn[] {
  const columns: ExportColumn[] = [];
  for (const metric of RATIO_METRIC_DEFS) {
    for (const unit of UNIT_OF_COMPARISON_DEFS) {
      if (metric.key === 'AssessedValue' && unit.key === 'SFCounty') continue;
      columns.push({ name: `${metric.key}Per${unit.key}`, displayName: `${metric.fullLabel} / ${unit.label}`, dataType: 'currency' });
    }
  }
  return columns;
}

/** Computes the same ratio values buildRatioExportColumns() declares, for one export row -- mirrors the grid's own valueGetter logic (property-search-grid.component.ts's buildRatioColumns) exactly, since ExportData is a plain row-object array with no valueGetter concept. */
function buildRatioExportValues(row: MergedParcelRow): Record<string, number | null> {
  const values: Record<string, number | null> = {};
  for (const metric of RATIO_METRIC_DEFS) {
    for (const unit of UNIT_OF_COMPARISON_DEFS) {
      if (metric.key === 'AssessedValue' && unit.key === 'SFCounty') continue;
      const denom = unit.denominator(row);
      const num = metric.numerator(row);
      values[`${metric.key}Per${unit.key}`] = denom == null || num == null ? null : num / denom;
    }
  }
  return values;
}

/**
 * Local alias for the client-tool shape `NavigationService.SetAgentClientTools`
 * accepts — declared here rather than imported, matching the convention used
 * by other dashboards in this package (e.g. SchedulingDashboardComponent).
 */
interface AgentClientTool {
  Name: string;
  Description: string;
  ParameterSchema: Record<string, unknown>;
  Handler: (params: Record<string, unknown>) => Promise<AgentToolResult>;
}

/**
 * Property Search — a CoStar/Zillow-style map-and-filter browse UI over
 * Marion County's commercial/industrial parcels (indiana_tax.Parcel +
 * indiana_tax.CountyAssessorRecord). Read-only presentation layer; does not
 * write to either table.
 *
 * DATA ACCESS: two sequential RunView calls (CountyAssessorRecord carries the
 * substantive filters — sqft/subclass/owner/value; Parcel carries geometry +
 * parcel-number identity), joined client-side by ParcelID. NOT a RunViews
 * batch — the second query's ExtraFilter genuinely depends on the first
 * query's result set (a bounded ParcelID IN (...) list), so a dependent
 * sequential call is the correct shape here, not an independent-queries batch.
 * See the plan this implements for why a hand-authored Virtual Entity (MJ's
 * documented joined-SQL-view mechanism) was considered and rejected: it has
 * zero production precedent anywhere in this repo.
 *
 * RESULT CAPS: the backend query (and List view / Export / Point-mode map)
 * are bounded by RESULT_CAP (5000, measured — see
 * PROPERTY_SEARCH_RESULT_CAP's own doc comment). Boundary-mode map rendering
 * is bounded SEPARATELY and more tightly by BOUNDARY_RENDER_CAP (2000,
 * unmeasured but unchanged from before this cap was raised) — geo-maps'
 * `boundary` mode has no clustering (unlike `point`, which uses Leaflet's
 * markerClusterGroup and scales past RESULT_CAP without issue), so raising
 * the backend cap for List view's sake doesn't also throw more unclustered
 * polygons at boundary rendering. See MapDisplayRows below for where that
 * slice happens.
 */
@Component({
  standalone: false,
  selector: 'mj-property-search-dashboard',
  templateUrl: './property-search-dashboard.component.html',
  styleUrls: ['./property-search-dashboard.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'PropertySearchResource')
// tab-container.component.ts's nav-item resolver always looks up
// ClassFactory.GetRegistrationAsync(BaseResourceComponent, driverClass) --
// never BaseDashboard directly -- so a BaseDashboard-only registration is
// unreachable as a direct Application.DefaultNavItems target (confirmed by
// how every OTHER working dashboard in this package does it: Scheduling
// registers a *separate* BaseResourceComponent wrapper alongside its
// BaseDashboard class for exactly this reason). This second decorator makes
// the same class discoverable via both lookup paths rather than adding a
// redundant wrapper file for a single-page dashboard that doesn't need one.
@RegisterClass(BaseResourceComponent, 'PropertySearchResource')
export class PropertySearchDashboardComponent extends BaseDashboard implements AfterViewInit {
  public IsLoading = false;
  public MergedResults: MergedParcelRow[] = [];
  public IsTruncated = false;
  public ActiveRenderMode: PropertySearchRenderMode = 'point';
  public SelectedParcel: MergedParcelRow | null = null;
  public DetailPanelVisible = false;
  /** Up to TREND_FETCH_MAX_YEARS years for SelectedParcel, newest first -- fetched once per selection; the panel's own 5yr/10yr toggle slices this client-side rather than re-querying. */
  public SelectedParcelTrend: AssessmentTrendRow[] = [];
  public IsTrendLoading = false;
  /** SelectedParcel's PTABOA appeal history, newest first -- fetched alongside the trend rows on selection (same RunViews batch). */
  public SelectedParcelAppeals: AppealHistoryRow[] = [];
  public IsAppealsLoading = false;
  /** SelectedParcel's CoStar matches (usually 0 or 1, occasionally more -- see CoStarPropertyRow's doc comment) -- fetched alongside the trend/appeal rows on selection (same RunViews batch). */
  public SelectedParcelCoStarMatches: CoStarPropertyRow[] = [];

  /** Map (the default) vs. List (a sortable, exportable AG Grid of the same result set) vs. Analytics (cross-sub-class rollups, independent of the current search/filter state). */
  public ActiveViewMode: 'map' | 'list' | 'analytics' = 'map';

  public ShowExportDialog = false;
  public ExportDialogConfig: ExportDialogConfig | null = null;

  /** Populated once by loadAssessmentYearsIfNeeded(); empty until then (year toggle hidden). */
  public AvailableAssessmentYears: number[] = [];

  /** All 92 counties, labelled with their C&I count and source tier. Loaded once in loadData(). */
  public CountyOptions: CountyOption[] = [];

  public get SelectedCountyNumber(): number {
    return this.filters.countyNumber;
  }

  public get SelectedCounty(): CountyOption | null {
    return this.CountyOptions.find((c) => c.CountyNumber === this.filters.countyNumber) ?? null;
  }

  /** True when the selected county's own record cards are loaded (CountyAssessorRecord path). */
  public get CountyHasCardData(): boolean {
    return countyCardSource(this.filters.countyNumber) != null;
  }

  /** True when ANY row on screen is DLGF-sourced -- the condition spec §6 sets for the notation. */
  public get HasDlgfRows(): boolean {
    return this.MergedResults.some((r) => isDlgfSourced(r.DataSource));
  }
  public readonly DlgfNotation = DLGF_NOTATION;

  public onCountyChange(countyNumber: number): void {
    if (!Number.isFinite(countyNumber) || countyNumber === this.filters.countyNumber) return;
    // Everything downstream of the county is county-scoped: the year list, the sub-class
    // options, and the results. resetFiltersForCountyChange also clears propertySubClass /
    // sqFtMin / sqFtMax -- carrying those across a county switch silently zeros out the new
    // county's result set (see its own doc comment) -- but NOT the search term, which the
    // user set deliberately.
    this.filters = resetFiltersForCountyChange(this.filters, countyNumber);
    this.subClassOptionsCache = [];
    void this.reloadForCounty();
  }

  private async reloadForCounty(): Promise<void> {
    this.IsLoading = true;
    this.cdr.markForCheck();
    try {
      await Promise.all([this.loadSubClassOptionsIfNeeded(), this.loadAssessmentYearsIfNeeded()]);
      await this.runSearchInternal();
    } finally {
      this.IsLoading = false;
      this.publishAgentContext();
      this.cdr.markForCheck();
    }
  }

  /**
   * indiana_tax.OwnerPortfolioRun.ID where IsLatest = 1 -- cached once by
   * loadLatestOwnerPortfolioRunIfNeeded() so every search doesn't re-look it
   * up. null until loaded, and stays null if the portfolio pipeline has never
   * been run (OwnerEntity/TaxRep are then simply absent from every row --
   * this dashboard degrades gracefully rather than erroring). Needed because
   * indiana_tax.OwnerPortfolioParcel keeps one row per parcel PER RUN (history
   * is never overwritten) -- without scoping to the latest run, a parcel with
   * N historical portfolio builds would merge as N duplicate rows.
   */
  private latestOwnerPortfolioRunID: string | null = null;
  private ownerPortfolioRunLoadAttempted = false;

  /**
   * The AG Grid's own displayed-row count in List view, reported via
   * (FilteredRowCountChanged) whenever a column filter (or sort/rowData
   * change) alters what's actually on screen there -- see that output's own
   * doc comment on PropertySearchGridComponent. null before the grid has
   * reported anything (Map/Analytics view, or List view before first paint).
   * Consumed by ParcelCountBadgeValue below, NOT read directly by the
   * template, so the "is this stale/irrelevant right now" logic lives in one
   * place.
   */
  public ListViewFilteredRowCount: number | null = null;

  /** List-view column visibility -- persisted per-account via UserInfoEngine (never localStorage, per this codebase's standing rule). */
  public VisibleColumnKeys = new Set<string>(PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS);
  public readonly GridColumnOptions = PROPERTY_SEARCH_GRID_COLUMNS.filter((c) => !c.locked);
  /** GridColumnOptions grouped under the Columns popover's category subheadings, in PROPERTY_SEARCH_COLUMN_CATEGORIES' fixed order -- built by filtering (not by reordering PROPERTY_SEARCH_GRID_COLUMNS itself), so this stays independent of the grid's own column display order. Empty categories are skipped rather than rendering a bare heading. */
  public readonly GroupedColumnOptions = PROPERTY_SEARCH_COLUMN_CATEGORIES.map((category) => ({
    category,
    columns: this.GridColumnOptions.filter((c) => c.category === category),
  })).filter((group) => group.columns.length > 0);

  public readonly RESULT_CAP = PROPERTY_SEARCH_RESULT_CAP;
  public readonly BOUNDARY_RENDER_CAP = PROPERTY_SEARCH_BOUNDARY_RENDER_CAP;

  /** UserInfoEngine setting key, versioned so a future shape change can migrate cleanly rather than misreading an old value. */
  private static readonly COLUMNS_SETTING_KEY = 'mj.propertySearch.gridColumns.v1';

  private filters: PropertySearchFilters = { ...DEFAULT_PROPERTY_SEARCH_FILTERS };
  private subClassOptionsCache: { text: string; value: string }[] = [];
  private parcelsEntityInfo: EntityInfo | null = null;

  constructor(private cdr: ChangeDetectorRef) {
    super();
  }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Property Search';
  }

  public get ParcelsEntity(): EntityInfo | null {
    return this.parcelsEntityInfo;
  }

  // ───── Summary stats ([meta] slot) ─────
  // Computed client-side over the already-loaded MergedResults -- no extra
  // query. Updates live as filters/search narrow the result set.

  /**
   * Count with no map coordinates, WITHIN what the map is actually drawing
   * (MapDisplayRows, not the full MergedResults) -- these rows are still
   * included everywhere else (stats, List, Export), just invisible on the
   * Map view. Scoped to MapDisplayRows (not MergedResults) so this stays
   * accurate in boundary mode, where the map draws only the top
   * BOUNDARY_RENDER_CAP rows -- counting missing-geometry rows outside that
   * slice would overstate a gap the user can't even see reflected on screen.
   */
  public get RowsWithoutGeometryCount(): number {
    return this.MapDisplayRows.filter((r) => r.Latitude == null || r.Longitude == null).length;
  }

  /**
   * What <mj-map-view> actually renders. Point mode (Leaflet clustering) and
   * every non-map surface (List, Export, summary stats) use the full
   * MergedResults, up to RESULT_CAP. Boundary/outline mode -- unclustered
   * polygon drawing, a different and unmeasured rendering cost -- is sliced
   * down further to BOUNDARY_RENDER_CAP, which is smaller than RESULT_CAP
   * (see that constant's own doc comment for why raising RESULT_CAP for List
   * view's sake shouldn't also throw more polygons at boundary rendering).
   * MergedResults is already ORDER BY AssessedTotalAV DESC from the CAR
   * query, so this slice keeps the same "top N by value" framing as
   * IsTruncated uses for the overall result cap.
   */
  public get MapDisplayRows(): MergedParcelRow[] {
    if (this.ActiveRenderMode !== 'boundary' || this.MergedResults.length <= this.BOUNDARY_RENDER_CAP) {
      return this.MergedResults;
    }
    return this.MergedResults.slice(0, this.BOUNDARY_RENDER_CAP);
  }

  /** True when boundary mode is showing FEWER parcels than the full search result specifically because of BOUNDARY_RENDER_CAP -- a narrower, map-rendering-specific truncation than IsTruncated (the overall RESULT_CAP), and can be true even when IsTruncated is false. */
  public get IsBoundaryRenderTruncated(): boolean {
    return this.ActiveRenderMode === 'boundary' && this.MergedResults.length > this.BOUNDARY_RENDER_CAP;
  }

  /**
   * Value for the header's parcel-count badge. In List view, once a column
   * filter has narrowed what the grid actually shows, this renders "X of Y"
   * (X = the grid's own filtered count, Y = the full search result) instead
   * of silently continuing to show Y alone -- the mismatch a plain
   * MergedResults.length would otherwise produce the moment someone filters
   * the grid down. Falls back to the plain total whenever there's nothing to
   * reconcile against (Map/Analytics view, no active grid filter, or List
   * view before the grid's first report).
   */
  public get ParcelCountBadgeValue(): string | number {
    const total = this.MergedResults.length;
    if (this.ActiveViewMode === 'list' && this.ListViewFilteredRowCount != null && this.ListViewFilteredRowCount !== total) {
      return `${this.ListViewFilteredRowCount} of ${total}`;
    }
    return total;
  }

  /** (FilteredRowCountChanged) handler from <mj-property-search-grid> -- see ListViewFilteredRowCount's own doc comment. */
  public onGridFilteredRowCountChanged(count: number): void {
    this.ListViewFilteredRowCount = count;
    this.cdr.markForCheck();
  }

  public get FormattedTotalAssessedValue(): string {
    return formatCurrency(computePropertySearchSummaryStats(this.MergedResults).totalAssessedValue);
  }

  public get FormattedAvgPricePerSqFt(): string {
    const stats = computePropertySearchSummaryStats(this.MergedResults);
    if (stats.avgPricePerSqFt == null) return 'N/A';
    return `${formatCurrency(Math.round(stats.avgPricePerSqFt))}/sqft`;
  }

  /** Sub-label for the avg-$/sqft badge, disclosing the sample it's actually based on -- see computePropertySearchSummaryStats' doc comment for why unverified sqft is excluded rather than silently blended in. */
  public get AvgPricePerSqFtSubLabel(): string {
    const stats = computePropertySearchSummaryStats(this.MergedResults);
    return `avg $/sqft (${stats.verifiedSqFtSampleSize} of ${stats.count} w/ verified sqft)`;
  }

  // ───── Filter panel plumbing ─────

  public get ParcelFilterFields(): FilterFieldConfig[] {
    return [
      {
        // Single-select dropdown, not chips -- 80 distinct sub-class values in
        // the live data (confirmed 2026-08-24), far too many for a chip row.
        // filterable:true gives type-to-narrow, essential at this count.
        key: 'propertySubClass',
        type: 'dropdown',
        label: 'Property Sub Class',
        icon: 'fa-solid fa-shapes',
        placeholder: 'All Sub Classes',
        filterable: true,
        options: [{ text: 'All Sub Classes', value: '' }, ...this.subClassOptionsCache],
      },
    ];
  }

  public get ParcelFilterValues(): Record<string, unknown> {
    return {
      propertySubClass: this.filters.propertySubClass ?? '',
    };
  }

  public get ActiveFilterCount(): number {
    let n = 0;
    if (this.filters.propertySubClass) n++;
    if (this.filters.sqFtMin != null || this.filters.sqFtMax != null) n++;
    return n;
  }

  public get SqFtMin(): number | null {
    return this.filters.sqFtMin;
  }
  public get SqFtMax(): number | null {
    return this.filters.sqFtMax;
  }

  public onSqFtMinChange(value: number | null): void {
    this.filters = { ...this.filters, sqFtMin: value };
    this.runSearch();
  }
  public onSqFtMaxChange(value: number | null): void {
    this.filters = { ...this.filters, sqFtMax: value };
    this.runSearch();
  }

  public onFilterValuesChange(v: Record<string, unknown>): void {
    const next = (v ?? {}) as { propertySubClass?: string };
    this.filters = {
      ...this.filters,
      propertySubClass: next.propertySubClass || null,
    };
    this.runSearch();
  }

  public resetFilters(): void {
    this.filters = { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: this.filters.countyNumber, assessmentYear: this.filters.assessmentYear };
    this.cdr.markForCheck();
    this.runSearch();
  }

  // ───── Search box ─────

  public get SearchTerm(): string {
    return this.filters.searchTerm;
  }

  public onSearchChange(term: string): void {
    this.filters = { ...this.filters, searchTerm: term };
    this.runSearch();
  }

  // ───── View mode (Map / List) ─────

  public onViewModeChange(mode: 'map' | 'list' | 'analytics'): void {
    this.ActiveViewMode = mode;
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  /** ViewToggle emits its option `key`, which is a string (see YearToggleOptions) -- parsed back to a number here. */
  public onAssessmentYearChange(yearKey: string): void {
    const year = Number(yearKey);
    if (!Number.isFinite(year) || year === this.filters.assessmentYear) return;
    this.filters = { ...this.filters, assessmentYear: year };
    this.runSearch();
  }

  public get SelectedAssessmentYear(): number {
    return this.filters.assessmentYear;
  }

  /** ViewToggleOption[] for the year toggle -- labels the most recent year "(Current)" since that's what CountyAssessorRecord's own live fields (used for candidate ranking) reflect. */
  public get YearToggleOptions(): { key: string; label: string }[] {
    return this.AvailableAssessmentYears.map((y, i) => ({
      key: String(y),
      label: i === 0 ? `${y} (Current)` : String(y),
    }));
  }

  // ───── Map ─────

  public onRenderModeChange(mode: PropertySearchRenderMode): void {
    this.ActiveRenderMode = mode;
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public onMarkerClick(event: MapMarkerClickEvent): void {
    this.selectParcel(event.Record as unknown as MergedParcelRow);
  }

  // ───── List ─────

  public onGridRowClicked(parcel: MergedParcelRow): void {
    this.selectParcel(parcel);
  }

  private selectParcel(parcel: MergedParcelRow): void {
    this.SelectedParcel = parcel;
    this.DetailPanelVisible = true;
    // Reset (not carry over) the prior parcel's trend/appeal rows immediately
    // -- the stale data would otherwise flash under the new parcel's header
    // while the fetch below is in flight.
    this.SelectedParcelTrend = [];
    this.SelectedParcelAppeals = [];
    this.SelectedParcelCoStarMatches = [];
    this.IsTrendLoading = true;
    this.IsAppealsLoading = true;
    void this.loadParcelDetail(parcel.ParcelID);
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public closeDetailPanel(): void {
    this.DetailPanelVisible = false;
    this.SelectedParcel = null;
    this.SelectedParcelTrend = [];
    this.SelectedParcelAppeals = [];
    this.SelectedParcelCoStarMatches = [];
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  /**
   * Fetches this parcel's multi-year assessment/tax-liability trend
   * (indiana_tax.TaxHistoryYear, for Value Trend / Tax Liability Trend) and
   * its PTABOA appeal history (indiana_tax.PTABOAAppeal, for Appeal History)
   * -- both independent, both scoped to one parcel, batched as one RunViews
   * call rather than two sequential RunView calls.
   */
  private async loadParcelDetail(parcelID: string): Promise<void> {
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const [trendResult, appealsResult, coStarResult] = await rv.RunViews<Record<string, unknown>>([
      {
        EntityName: 'Tax History Years',
        Fields: ['TaxYear', 'ColumnOrdinal', 'LandAssessment', 'Improvements', 'GrossAssessment', 'NetAnnualTax', 'TaxRate'],
        ExtraFilter: `ParcelID = '${escapeSqlLiteral(parcelID)}'`,
        OrderBy: 'TaxYear DESC',
        MaxRows: TREND_FETCH_MAX_YEARS,
        ResultType: 'simple',
      },
      {
        EntityName: 'PTABOA Appeals',
        Fields: [
          'AssessmentYear',
          'HearingDate',
          'DecisionStatus',
          'CaseNumber',
          'TaxRepresentative',
          'Circumstances',
          'BeforeLandAV',
          'BeforeImprovementAV',
          'BeforeTotalAV',
          'AfterLandAV',
          'AfterImprovementAV',
          'AfterTotalAV',
          'FinalDeterminationTotalAV',
        ],
        ExtraFilter: `ParcelID = '${escapeSqlLiteral(parcelID)}'`,
        // Most parcels have 0-2 appeals ever; a generous ceiling costs
        // nothing and avoids the silent-truncation bug class this project
        // has hit before on a too-tight MaxRows.
        MaxRows: 200,
        ResultType: 'simple',
      },
      {
        // "Co Star Properties" is CodeGen's generated entity name for
        // indiana_tax.CoStarProperty -- it split "CoStar" into two words.
        // OR CoStarSecondaryParcelID: a parcel can be the MATCHED MAX end of
        // a multi-parcel property, not just the Min end (see the
        // CoStarProperty migration) -- both directions need checking.
        EntityName: 'Co Star Properties',
        Fields: [
          'CoStarPropertyID',
          'CoStarPropertyName',
          'CoStarPropertyType',
          'CoStarNumberOfUnits',
          'CoStarRooms',
          'CoStarRBA',
          'CoStarBuildingClass',
          'CoStarStarRating',
          'CoStarLastSalePrice',
          'CoStarLastSaleDate',
          'CoStarIsMultiParcel',
          'SourceExportFile',
        ],
        ExtraFilter: `ParcelID = '${escapeSqlLiteral(parcelID)}' OR CoStarSecondaryParcelID = '${escapeSqlLiteral(parcelID)}'`,
        // A parcel matched by more than a handful of CoStar listings would be
        // very unusual (confirmed live: the real max seen this session was
        // 4) -- generous headroom, not a tight guess.
        MaxRows: 10,
        ResultType: 'simple',
      },
    ]);
    // Only apply if the user hasn't already selected a DIFFERENT parcel while
    // this fetch was in flight -- avoids a slow response for an earlier
    // selection overwriting a faster one for whatever's now on screen.
    if (this.SelectedParcel?.ParcelID !== parcelID) return;
    this.SelectedParcelTrend = trendResult.Success ? buildAssessmentTrendRows(trendResult.Results ?? [], TREND_FETCH_MAX_YEARS) : [];
    this.IsTrendLoading = false;
    this.SelectedParcelAppeals = appealsResult.Success ? buildAppealHistoryRows(appealsResult.Results ?? []) : [];
    this.IsAppealsLoading = false;
    this.SelectedParcelCoStarMatches = coStarResult.Success ? buildCoStarPropertyRows(coStarResult.Results ?? []) : [];
    this.cdr.markForCheck();
  }

  // ───── Export ─────

  public openExportDialog(): void {
    if (!this.MergedResults.length) return;
    const columns: ExportColumn[] = [
      { name: 'Address', displayName: 'Address' },
      { name: 'ParcelNumber', displayName: 'Parcel #' },
      { name: 'GISParcelNumber', displayName: 'GIS Parcel #' },
      { name: 'OwnerName', displayName: 'Owner' },
      { name: 'OwnerEntity', displayName: 'Owner Entity' },
      { name: 'PropertyClass', displayName: 'Property Class' },
      { name: 'PropertySubClassDescription', displayName: 'Property Sub Class' },
      { name: 'AssessmentYear', displayName: 'Assessment Year', dataType: 'number' },
      { name: 'AssessmentSource', displayName: 'Assessment Source' },
      { name: 'DataSource', displayName: 'Data Source' },
      { name: 'VerifyURL', displayName: 'Verify (county document)' },
      { name: 'EstimatedSqFt', displayName: 'Building Sq Ft', dataType: 'number' },
      { name: 'EstimatedSqFtExGarage', displayName: 'Building Sq Ft (County XG)', dataType: 'number' },
      { name: 'SqFtSource', displayName: 'Sq Ft Source' },
      { name: 'PricePerSqFt', displayName: '$/SF (County)', dataType: 'currency' },
      { name: 'CoStarRBA', displayName: 'RBA (CoStar)', dataType: 'number' },
      { name: 'UnitsRooms', displayName: 'Units/Rooms (CoStar)' },
      { name: 'YearBuiltDisplay', displayName: 'Year Built' },
      ...buildRatioExportColumns(),
      { name: 'AssessedLandAV', displayName: 'Assessed Land AV', dataType: 'currency' },
      { name: 'AssessedImprovementAV', displayName: 'Assessed Improvement AV', dataType: 'currency' },
      { name: 'AssessedTotalAV', displayName: 'Assessed Total AV', dataType: 'currency' },
      { name: 'TotalTax', displayName: 'Total Tax', dataType: 'currency' },
      { name: 'TaxRate', displayName: 'Tax Rate', dataType: 'number' },
      { name: 'PTABOAValue', displayName: 'PTABOA Value', dataType: 'currency' },
      { name: 'PTABOADate', displayName: 'PTABOA Date', dataType: 'date' },
      { name: 'PTABOAAppealType', displayName: 'Appeal Type' },
      { name: 'TaxRep', displayName: 'Rep' },
      { name: 'Recommendation', displayName: 'Recommendation' },
      { name: 'ConfidenceTier', displayName: 'Confidence' },
      { name: 'SupportingApproachCount', displayName: 'Supporting Approaches', dataType: 'number' },
      { name: 'EstSavingsAtAsk', displayName: 'Est. Savings (Ask)', dataType: 'currency' },
      { name: 'AVYoYPct', displayName: 'AV YoY %', dataType: 'number' },
      { name: 'LastSaleDate', displayName: 'Last Sale Date', dataType: 'date' },
      { name: 'LastSalePrice', displayName: 'Last Sale Price', dataType: 'currency' },
      { name: 'LastSaleIsValid', displayName: 'Last Sale Valid?', dataType: 'boolean' },
      { name: 'Neighborhood', displayName: 'Neighborhood' },
      { name: 'TaxDistrictID', displayName: 'Tax District' },
    ];
    // ExportData is a plain array of row objects (no valueGetter concept like
    // the grid has), so $/SF gets computed onto a shallow-copied export row
    // rather than mutating MergedResults itself.
    const exportRows = this.MergedResults.map((r) => ({
      ...r,
      PricePerSqFt: pricePerSqFt(r),
      UnitsRooms: formatComparisonUnitCount(r.ComparisonUnitType, r.ComparisonUnitCount),
      YearBuiltDisplay: formatYearBuilt(r.YearBuilt, r.CoStarYearBuilt),
      ...buildRatioExportValues(r),
    }));
    // Spec §6 asks for the notation as a header LINE as well as a column. The shared export
    // dialog exports a row array with no banner concept, so the line is a leading row whose
    // first column carries the text -- visible as line 1 in CSV/Excel and as element 0 in JSON.
    const rowsToExport = this.HasDlgfRows
      ? [{ Address: `SOURCE NOTE: ${DLGF_NOTATION}` } as Record<string, unknown>, ...exportRows]
      : exportRows;
    this.ExportDialogConfig = {
      data: rowsToExport,
      columns,
      defaultFileName: 'property-search-results',
      availableFormats: ['excel', 'csv', 'json'],
      defaultFormat: 'excel',
      showSamplingOptions: false,
      dialogTitle: `Export ${this.MergedResults.length} Parcel${this.MergedResults.length === 1 ? '' : 's'}`,
    };
    this.ShowExportDialog = true;
    this.cdr.markForCheck();
  }

  public onExportDialogClosed(_result: ExportDialogResult): void {
    this.ShowExportDialog = false;
    this.ExportDialogConfig = null;
    this.cdr.markForCheck();
  }

  public openParcelRecord(parcel: MergedParcelRow): void {
    // A DLGF-only row has no CountyAssessorRecord to open -- the Parcel itself is the record.
    const entityName = parcel.CountyAssessorRecordID ? 'County Assessor Records' : 'Parcels';
    const id = parcel.CountyAssessorRecordID ?? parcel.ParcelID;
    const compositeKey = new CompositeKey([{ FieldName: 'ID', Value: id }]);
    this.navigationService.OpenEntityRecord(entityName, compositeKey);
  }

  /** Hand the selected parcel to Analyze a Property (Appeal Workbench Plan 1). SwitchToApp applies the params before a cached component reattaches, so the intent survives. */
  public async openAnalyze(parcel: MergedParcelRow): Promise<void> {
    await this.navigationService.SwitchToApp(INDIANA_APP_ID, 'Analyze a Property', { parcel: parcel.ParcelID, analysis: null, section: 'cover' });
  }

  // NOTE: a "chat with the agent about this parcel" action was planned but
  // dropped from this first version — NavigationService has no method to open
  // a new conversation with a pre-seeded message (verified against
  // navigation.service.ts's public API before implementation, not just
  // assumed), and this dashboard's own SetAgentContext/SetAgentClientTools
  // wiring already lets the Conversations chat agent see and act on whatever
  // is currently selected here without a dedicated hand-off button. Revisit
  // if/when a real "open conversation with seed message" API exists.

  // ───── Lifecycle / data loading ─────

  initDashboard(): void {
    // Resolve the Parcels EntityInfo once — needed by <mj-map-view>'s [Entity] input.
    this.parcelsEntityInfo = this.ProviderToUse.EntityByName('Parcels') ?? null;
    this.loadColumnPreference();
  }

  // ───── Column visibility (List view) ─────

  private loadColumnPreference(): void {
    const raw = UserInfoEngine.Instance.GetSetting(PropertySearchDashboardComponent.COLUMNS_SETTING_KEY);
    if (!raw) return;
    try {
      const saved = JSON.parse(raw) as string[];
      if (Array.isArray(saved) && saved.length) this.VisibleColumnKeys = new Set(saved);
    } catch {
      // Malformed/older-shape value -- fall back to the default set already assigned, not a crash.
    }
  }

  private saveColumnPreference(): void {
    UserInfoEngine.Instance.SetSettingDebounced(
      PropertySearchDashboardComponent.COLUMNS_SETTING_KEY,
      JSON.stringify(Array.from(this.VisibleColumnKeys))
    );
  }

  public toggleColumnVisible(key: string, visible: boolean): void {
    const next = new Set(this.VisibleColumnKeys);
    if (visible) next.add(key);
    else next.delete(key);
    this.VisibleColumnKeys = next;
    this.saveColumnPreference();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  public resetColumnsToDefault(): void {
    this.VisibleColumnKeys = new Set(PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS);
    this.saveColumnPreference();
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  ngAfterViewInit(): void {
    this.publishAgentContext();
  }

  async loadData(): Promise<void> {
    this.IsLoading = true;
    this.cdr.markForCheck();
    try {
      await Promise.all([this.loadSubClassOptionsIfNeeded(), this.loadAssessmentYearsIfNeeded(), this.loadLatestOwnerPortfolioRunIfNeeded()]);
      await this.runSearchInternal();
    } finally {
      this.IsLoading = false;
      this.publishAgentContext();
      this.cdr.markForCheck();
    }
    // The county dropdown's full option list carries a live ~203k-row C&I tally
    // (loadCountyOptionsIfNeeded) -- fire-and-forget AFTER the first search has already resolved
    // and NotifyLoadComplete has already fired (BaseDashboard calls it right after loadData()
    // returns), so Marion's default open never waits on it. The instance cache inside
    // loadCountyOptionsIfNeeded still applies, so this only ever runs once. The combobox shows a
    // brief loading placeholder (see the template's @if(CountyOptions.length)) until this fills in.
    void this.loadCountyOptionsIfNeeded().then(() => this.cdr.markForCheck());
  }

  public runSearch(): void {
    this.IsLoading = true;
    this.cdr.markForCheck();
    this.runSearchInternal()
      .catch(() => undefined)
      .finally(() => {
        this.IsLoading = false;
        this.publishAgentContext();
        this.cdr.markForCheck();
      });
  }

  /**
   * Distinct assessment years actually present for the SELECTED county's parcels specifically
   * (indiana_tax.Assessment also carries every other county's bulk-loaded data --
   * confirmed one statewide source alone has 200K+ rows, far more than any one
   * county's parcel count -- so this is scoped via a subquery against
   * vwParcels rather than a bare DISTINCT AssessmentYear, which could offer a
   * year that returns zero results for this county and looks like a dead end).
   * A stable, load-once list (like subClassOptionsCache) -- NOT re-derived
   * from the current filtered candidate set, so the year picker doesn't
   * shrink/flicker as other filters narrow the results.
   */
  /** Years cached PER COUNTY -- switching counties must not show another county's years. */
  private assessmentYearsByCounty = new Map<number, number[]>();

  private async loadAssessmentYearsIfNeeded(): Promise<void> {
    const county = this.filters.countyNumber;
    const cached = this.assessmentYearsByCounty.get(county);
    if (cached) {
      this.AvailableAssessmentYears = cached;
      if (!cached.includes(this.filters.assessmentYear)) this.filters = { ...this.filters, assessmentYear: cached[0] };
      return;
    }
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<{ AssessmentYear: number }>({
      EntityName: 'Assessments',
      Fields: ['AssessmentYear'],
      ExtraFilter: `ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = ${county})`,
      OrderBy: 'AssessmentYear DESC',
      // Per-ROW query (one row per Assessment record, not per distinct year), so the cap must
      // cover the biggest county's parcels x sources x years: Lake 15,001 parcels x 4 published
      // card years x up to 2 sources = ~120,000; Marion ~19,859 x 5 = ~99,295. 200000 gives
      // headroom as PRC coverage grows. Ordered DESC, so a short cap would silently hide the
      // OLDER years -- never an error, just a quietly missing option.
      MaxRows: 200000,
      ResultType: 'simple',
    });
    if (!result.Success) return;
    const years = Array.from(new Set((result.Results ?? []).map((r) => r.AssessmentYear))).sort((a, b) => b - a);
    if (!years.length) return;
    this.assessmentYearsByCounty.set(county, years);
    this.AvailableAssessmentYears = years;
    if (!years.includes(this.filters.assessmentYear)) this.filters = { ...this.filters, assessmentYear: years[0] };
  }

  /**
   * The 92 counties plus a live C&I (class 300-499) tally per county, for the dropdown's
   * labels. The tally is a one-column fetch over Parcels aggregated client-side -- MJ's
   * RunView has no GROUP BY (data-access.md "Client-Side Data Aggregation"), and the same
   * shape is already what loadAssessmentYearsIfNeeded does.
   */
  private async loadCountyOptionsIfNeeded(): Promise<void> {
    if (this.CountyOptions.length) return;
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    // Two stages, deliberately NOT one RunViews batch: the 92-row county list is what the
    // control needs to appear, and the per-county C&I tally below is a ~203k-row fetch that
    // took over two minutes on the dev box (click-through, 2026-09-13). Batched together the
    // control read "Loading counties..." until the tally returned; names first, counts after.
    const countyResult = await rv.RunView<Record<string, unknown>>({
      EntityName: 'Counties',
      Fields: ['CountyNumber', 'Name', 'Slug'],
      OrderBy: 'Name',
      // Exactly 92 rows by construction (one per Indiana county); 200 is headroom, not a guess.
      MaxRows: 200,
      ResultType: 'simple',
    });
    if (!countyResult.Success) return;
    const counties = countyResult.Results ?? [];
    this.CountyOptions = buildCountyOptions(counties, new Map<number, number>());
    this.cdr.markForCheck();
    const parcelResult = await rv.RunView<Record<string, unknown>>({
      EntityName: 'Parcels',
      Fields: ['CountyNumber'],
      // NOT CI_CLASS_CODE_FILTER on Parcels: Parcel.PropertyClassCode is NULL everywhere, the
      // class code lives on the AY2025 DLGF Assessment row -- see CI_ROSTER_PARCEL_FILTER.
      ExtraFilter: CI_ROSTER_PARCEL_FILTER,
      // Per-ROW query deduped client-side, the same truncation bug class as
      // loadSubClassOptionsIfNeeded/loadAssessmentYearsIfNeeded. The C&I universe is
      // 182,265 parcels outside Marion (proposals/multi-county-ci-intake.md §2) plus
      // Marion's ~20,722 = ~203,000. 300000 gives headroom as AY2026 lands. Silent
      // truncation here would UNDERCOUNT the alphabetically-later counties' labels,
      // never error -- which is exactly how this component was bitten before.
      MaxRows: 300000,
      ResultType: 'simple',
    });
    if (!parcelResult.Success) return;
    this.CountyOptions = buildCountyOptions(counties, tallyCIParcels(parcelResult.Results ?? []));
  }

  /**
   * Looks up the current indiana_tax.OwnerPortfolioRun (IsLatest = 1) once and
   * caches its ID -- see latestOwnerPortfolioRunID's own doc comment for why
   * this matters (OwnerPortfolioParcel keeps every historical run's rows).
   * Load-once like loadAssessmentYearsIfNeeded/loadSubClassOptionsIfNeeded,
   * but guarded by an attempted-flag rather than an empty-array check: a
   * genuinely empty result (no run yet) is itself the cached answer, not a
   * signal to retry on every search.
   */
  private async loadLatestOwnerPortfolioRunIfNeeded(): Promise<void> {
    if (this.ownerPortfolioRunLoadAttempted) return;
    this.ownerPortfolioRunLoadAttempted = true;
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<{ ID: string }>({
      EntityName: 'Owner Portfolio Runs',
      Fields: ['ID'],
      ExtraFilter: 'IsLatest = 1',
      MaxRows: 1,
      ResultType: 'simple',
    });
    if (result.Success && result.Results?.length) {
      this.latestOwnerPortfolioRunID = result.Results[0].ID;
    }
  }

  private async loadSubClassOptionsIfNeeded(): Promise<void> {
    if (this.subClassOptionsCache.length) return;
    if (!this.CountyHasCardData) {
      const rv = RunView.FromMetadataProvider(this.ProviderToUse);
      const result = await rv.RunView<Record<string, unknown>>({
        EntityName: 'Property Class Maps',
        Fields: ['Code', 'Label'],
        OrderBy: 'Code',
        // One row per 3-digit DLGF class code; the table is ~100 rows. 1000 is headroom.
        MaxRows: 1000,
        ResultType: 'simple',
      });
      if (result.Success) this.subClassOptionsCache = buildClassCodeSubClassOptions(result.Results ?? []);
      return;
    }
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<{ PropertySubClassDescription: string }>({
      EntityName: 'County Assessor Records',
      Fields: ['PropertySubClassDescription'],
      ExtraFilter: `CountyNumber = ${this.filters.countyNumber} AND PropertySubClassDescription IS NOT NULL`,
      OrderBy: 'PropertySubClassDescription',
      // MaxRows must cover every CountyAssessorRecord row (not just the number
      // of distinct values) -- this is a per-ROW query deduped client-side, and
      // RunView's own default cap is well under the ~19,859-row table. Without
      // an explicit MaxRows here, the query silently truncated alphabetically
      // and only "COM..."-prefixed sub-classes ever appeared in the dropdown --
      // a real bug caught 2026-08-24. 25000 covers the current table with
      // headroom as more parcels are ingested.
      MaxRows: 25000,
      ResultType: 'simple',
    });
    if (!result.Success) return;
    const seen = new Set<string>();
    const options: { text: string; value: string }[] = [];
    for (const row of result.Results ?? []) {
      const v = row.PropertySubClassDescription;
      if (v && !seen.has(v)) {
        seen.add(v);
        options.push({ text: v, value: v });
      }
    }
    this.subClassOptionsCache = options;
  }

  /**
   * Tolerant resolver for the FilterByPropertySubClass agent tool: exact match
   * first, then a 3-digit DLGF code as a "-XXX" suffix match, then a
   * case-insensitive partial match. Returns null (not a throw) on no match,
   * matching this codebase's established tolerant-resolver convention.
   */
  private resolveSubClassOption(raw: string): string | null {
    const exact = this.subClassOptionsCache.find((o) => o.value === raw);
    if (exact) return exact.value;
    if (/^\d{3}$/.test(raw)) {
      const byCode = this.subClassOptionsCache.find((o) => o.value.endsWith(`-${raw}`));
      if (byCode) return byCode.value;
    }
    const lower = raw.toLowerCase();
    const partial = this.subClassOptionsCache.find((o) => o.value.toLowerCase().includes(lower));
    return partial ? partial.value : null;
  }

  private async runSearchInternal(): Promise<void> {
    // A county with no loaded record cards reads Parcel + Assessment instead (spec §6).
    if (!this.CountyHasCardData) {
      await this.runDlgfSearchInternal();
      return;
    }
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const term = this.filters.searchTerm.trim();
    const kind = term ? classifySearchTerm(term) : null;

    // A parcel/GIS-number search resolves against Parcels FIRST, narrowing to
    // a bounded ParcelID list that gets AND'd into the CountyAssessorRecord
    // query below — this is the one case where the two entities' filters
    // genuinely depend on each other.
    let parcelIdConstraint: string[] | null = null;
    if (kind === 'parcelOrGisNumber') {
      const esc = escapeSqlLiteral(term);
      const idResult = await rv.RunView<{ ID: string }>({
        EntityName: 'Parcels',
        Fields: ['ID'],
        ExtraFilter: `ParcelNumber = '${esc}' OR GISParcelNumber = '${esc}'`,
        // A parcel number is unique statewide and a GIS number within a county;
        // 100 is generous headroom. Explicit so this never inherits the entity cap.
        MaxRows: 100,
        ResultType: 'simple',
      });
      parcelIdConstraint = idResult.Success ? (idResult.Results ?? []).map((r) => r.ID) : [];
    }

    const carResult = await rv.RunView<Record<string, unknown>>({
      EntityName: 'County Assessor Records',
      Fields: [
        'ID',
        'ParcelID',
        'OwnerName',
        'PropertyClass',
        'PropertySubClassDescription',
        'AssessedLandAV',
        'AssessedImprovementAV',
        'AssessedTotalAV',
        'EstimatedSqFt',
        'SqFtSource',
        'Acreage',
        'ComparisonUnitType',
        'ComparisonUnitCount',
        'YearBuilt',
        'CoStarYearBuilt',
        'CoStarRBA',
        'Neighborhood',
        'TaxDistrictID',
      ],
      ExtraFilter: this.buildCarExtraFilter(term, kind, parcelIdConstraint),
      // GrossAssessment (the Tax History billed figure) leads: it reconciles to
      // the noticed value and is year-consistent. AssessedTotalAV is a stale
      // ArcGIS assessor-layer snapshot -- not year-aligned to TaxYear and wrong
      // for ~1,300 C&I parcels (OPP-33) -- used as the ranking value ONLY when
      // GrossAssessment is null, via COALESCE, NOT as a plain second ORDER BY
      // key. `GrossAssessment DESC, AssessedTotalAV DESC` (the old form) sorts
      // ALL null-GrossAssessment rows to the very bottom as a group, no matter
      // how large their AssessedTotalAV is -- SQL Server puts NULLs last in a
      // DESC sort, and the second key only breaks ties within rows that share
      // the first key's value, so it can never rescue a null-first-key row.
      // Found live 2026-09-12 chasing a "why does filtering Owner Entity for
      // Eli Lilly show fewer parcels than the Owner Prospects rollup" report:
      // one of their parcels (231 Virginia Ave, $48.4M AssessedTotalAV) has a
      // null GrossAssessment and was landing dead last in the sort instead of
      // near the top where its actual value belongs -- one of 62 parcels
      // county-wide with a null GrossAssessment whose AssessedTotalAV alone
      // would place them above this search's current RESULT_CAP cutoff.
      // COALESCE ranks every row by whichever figure it actually has, so a
      // parcel's absence from Tax History data no longer buries it regardless
      // of size. The AV actually displayed/analysed still comes from
      // Assessment via the merge below, never from this fetch ordering.
      OrderBy: 'COALESCE(GrossAssessment, AssessedTotalAV) DESC, AssessedTotalAV DESC',
      MaxRows: this.RESULT_CAP,
      ResultType: 'simple',
    });

    if (!carResult.Success || !carResult.Results?.length) {
      this.MergedResults = [];
      this.IsTruncated = false;
      return;
    }

    // Deliberately NOT filtering on Latitude/Longitude here -- a parcel
    // missing geometry should still count toward the result set (summary
    // stats, List view, Export), it just won't have a pin/outline to draw.
    // <mj-map-view> already tolerates and silently skips records with null
    // coordinates (confirmed in geo-maps' own docs), so passing the full set
    // through is safe -- the alternative (filtering here) was silently
    // dropping a parcel's data everywhere, not just off the map, which is
    // exactly the kind of silent data loss this project tries not to do.
    const parcelIDs = carResult.Results.map((r) => r['ParcelID'] as string).filter(Boolean);
    const parcelIdList = parcelIDs.map((id) => `'${escapeSqlLiteral(id)}'`).join(',');
    // Sale history is keyed by CountyAssessorRecordID, not ParcelID -- the
    // one join in this batch that needs the OTHER id from carResult.
    const carIdList = carResult.Results.map((r) => `'${escapeSqlLiteral(r['ID'] as string)}'`).join(',');

    // Geometry, year-specific Assessment figures, year-specific tax history,
    // and sale history are independent of each other (all four only depend
    // on ids already known from carResult above) -- batch as one RunViews
    // call rather than sequential RunView calls.
    const [parcelResult, assessmentResult, taxHistoryResult, saleHistoryResult, ptaboaDateResult, parkingSegmentResult, ownerPortfolioResult] = await rv.RunViews<Record<string, unknown>>([
      {
        EntityName: 'Parcels',
        Fields: ['ID', 'ParcelNumber', 'GISParcelNumber', 'Address', 'OwnerName', 'Latitude', 'Longitude', 'BoundaryGeoJSON'],
        ExtraFilter: `ID IN (${parcelIdList})`,
        // MISSING MaxRows here was a real, pre-existing occurrence of this
        // project's documented silent-truncation bug class (see
        // loadSubClassOptionsIfNeeded/loadAssessmentYearsIfNeeded's own
        // MaxRows comments) -- found live 2026-09-12: Parcels.UserViewMaxRows
        // is 1000 (a CodeGen default never customized, true of EVERY entity
        // this dashboard queries), so with no explicit MaxRows this query
        // silently fell back to that 1000-row entity default regardless of
        // RESULT_CAP's own value. carResult (the CAR query, which DOES set
        // MaxRows explicitly) would correctly fetch up to RESULT_CAP rows,
        // but the merge loop below silently dropped every one of those rows
        // whose Parcel didn't make it into this query's arbitrary first-1000
        // -- exactly what the user saw: the header badge and List view stuck
        // at 1000 parcels no matter how many times RESULT_CAP itself was
        // raised (2000, then 5000), because THIS query, not RESULT_CAP, was
        // the actual bottleneck the whole time. One row per parcel expected
        // (Parcels.ID is a primary key), so MaxRows must be >= RESULT_CAP --
        // tied directly to it (not a separate hardcoded number) so this can
        // never drift out of sync with RESULT_CAP again.
        MaxRows: this.RESULT_CAP,
        ResultType: 'simple',
      },
      {
        EntityName: 'Assessments',
        Fields: ['ParcelID', 'Source', 'OriginalLandAV', 'OriginalImprovementAV', 'OriginalTotalAV'],
        ExtraFilter: `ParcelID IN (${parcelIdList}) AND AssessmentYear = ${this.filters.assessmentYear}`,
        // No MaxRows here was the same silent-truncation bug class this batch's
        // other queries already guard against (see County Assessor Sale
        // Histories / PTABOA Appeals / County Assessor Improvement Segments
        // below) -- an unset MaxRows falls back to the entity's
        // UserViewMaxRows (or the provider's own default) which silently
        // truncated this query, leaving most parcels with no matching row in
        // assessmentByParcel below -- the real cause of the List View's
        // "No data" bug reported 2026-09-03 (confirmed live: parcel 1055259
        // has correct 2026 Assessment data in the DB but showed "No data" in
        // the grid).
        //
        // Consolidation 2026-09-21: expressed as RESULT_CAP * 4 (= 20000 at 5000) so it scales;
        // the multi-county branch found up to 2 sources per parcel-year (county card + statewide)
        // and this cap must hold for any county.
        // RESULT_CAP parcels x up to 2 sources (MarionPRC + a statewide
        // fallback) for the selected year is the theoretical max -- measured
        // live 2026-09-11 at RESULT_CAP=5000: 9,794-9,961 rows depending on
        // year (2025/2026 run closest to the old 10000 ceiling with
        // essentially zero headroom). Raised to 20000 -- 2x the theoretical
        // max, not just past the last observed number -- since this scales
        // directly with RESULT_CAP and needs real margin if RESULT_CAP is
        // ever nudged again without someone re-deriving this from scratch.
        MaxRows: this.RESULT_CAP * 4,
        ResultType: 'simple',
      },
      {
        EntityName: 'Tax History Years',
        Fields: ['ParcelID', 'ColumnOrdinal', 'NetAnnualTax', 'TaxRate'],
        ExtraFilter: `ParcelID IN (${parcelIdList}) AND TaxYear = ${this.filters.assessmentYear}`,
        // Same gap as Assessments above -- no MaxRows meant this was exposed
        // to the identical silent-truncation risk. Measured live 2026-09-11
        // at RESULT_CAP=5000: max ~4,584 rows across years (well under the
        // old 10000 -- most parcels don't yet have Tax History Report data
        // for every year), but raised alongside Assessments to 20000 anyway
        // since it scales with the same RESULT_CAP and shouldn't need its
        // own re-derivation the next time that constant moves.
        // Expressed as RESULT_CAP * 4 so it scales with the cap (consolidation 2026-09-21).
        MaxRows: this.RESULT_CAP * 4,
        ResultType: 'simple',
      },
      {
        EntityName: 'County Assessor Sale Histories',
        Fields: ['CountyAssessorRecordID', 'SaleDate', 'SaleAmount', 'IsValidSale'],
        ExtraFilter: `CountyAssessorRecordID IN (${carIdList})`,
        // Most recent sale wins; a SaleAmount tiebreak on a date tie handles
        // a real observed case (parcel 8050459): two same-day rows, a real
        // $60.25M sale (IsValidSale=false -- excluded from the county's ratio
        // study, not "not a real transaction") and a $0 same-day corrective/
        // "Straight" deed (IsValidSale=true). Ordering by date alone with an
        // arbitrary tie could surface the uninformative $0 row -- SaleAmount
        // DESC as the tiebreak reliably picks the transaction that's actually
        // informative, without needing to interpret IsValidSale's own meaning.
        OrderBy: 'SaleDate DESC, SaleAmount DESC',
        // The "whole table is small enough to not need to scale this"
        // reasoning this comment used to rely on went stale: the table was
        // 7,722 rows on 2026-08-25 and had grown to 46,873 by 2026-09-11 --
        // a 6x increase in under a month as more counties'/years' sale
        // history gets ingested, with no reason to expect it to stop. That
        // growth had ALREADY made the old 10000 ceiling unsafe: measured live
        // at RESULT_CAP=5000 (the top 5000 parcels by assessed value, which
        // skew toward older commercial buildings with deeper sale histories),
        // this query returns 11,904 rows -- past the old ceiling before this
        // fix, meaning some parcels' sale history was ALREADY being silently
        // truncated. Raised to 30000, well past both the measured number and
        // the whole-table total, and no longer reasoned from "the table is
        // small" -- reasoned from "it isn't, and keeps growing."
        MaxRows: 30000,
        ResultType: 'simple',
      },
      {
        EntityName: 'PTABOA Appeals',
        // Sourced directly from PTABOAAppeal.AfterTotalAV, NOT
        // Assessment.PTABOATotalAV -- confirmed 2026-08-25 that
        // Assessment.PTABOATotalAV is only ever populated on the 2025/2026
        // statewide-source rows (238+7 of 245 total, zero for any other
        // year), so a parcel appealed in e.g. 2024 -- a perfectly normal,
        // user-selectable year -- would show "no data" every time despite a
        // real AfterTotalAV existing right here. Reading it straight from
        // the appeal itself has no such gap.
        Fields: ['ParcelID', 'HearingDate', 'AfterTotalAV', 'AppealType'],
        ExtraFilter: `ParcelID IN (${parcelIdList}) AND AssessmentYear = ${this.filters.assessmentYear}`,
        // Latest hearing wins when a parcel has more than one appeal case for
        // the same year (confirmed real: the same case can appear on two
        // agendas, e.g. a "scheduled" pass then a "final" pass). Measured
        // live 2026-09-11 at RESULT_CAP=5000: max 283 rows (2024, the busiest
        // appeal year in the data) -- 10000 remains comfortable headroom,
        // left unchanged.
        OrderBy: 'HearingDate DESC',
        MaxRows: 10000,
        ResultType: 'simple',
      },
      {
        // Structured-parking floor/use-segments only -- the county codes a
        // parking deck as a Building segment, so CountyAssessorRecord.
        // EstimatedSqFt includes it. Summed per CountyAssessorRecordID below
        // and subtracted to give EstimatedSqFtExGarage (the "(County XG)" SF
        // the rest of the tool's $/SF math already uses). Only 838 such
        // segments exist county-wide (confirmed 2026-09-11) -- measured at
        // RESULT_CAP=5000: 520 rows, comfortably under 10000, left unchanged.
        EntityName: 'County Assessor Improvement Segments',
        Fields: ['CountyAssessorRecordID', 'TotalSqFt'],
        ExtraFilter: `CountyAssessorRecordID IN (${carIdList}) AND [Use] IN ('Parking', 'Pkg Garage', 'Com Garage')`,
        MaxRows: 10000,
        ResultType: 'simple',
      },
      {
        // OwnerEntity (the resolved owner -- see MergedParcelRow's doc comment
        // for why this differs from OwnerName) + TaxRep (existing-rep flag) +
        // the engine's own appeal-opportunity signals (Recommendation/
        // ConfidenceTier/SupportingApproachCount/EstSavingsAtAsk/AVYoYPct),
        // all sourced from the Owner Prospects pipeline's persisted rollup.
        // Scoped to the LATEST run only -- see latestOwnerPortfolioRunID's doc
        // comment -- via a subquery rather than a plain field filter, because
        // OwnerPortfolioParcel/vwOwnerPortfolioParcels doesn't expose RunID
        // itself (it's one hop up, on the parent OwnerPortfolio). When the
        // portfolio pipeline has never run, latestOwnerPortfolioRunID is null
        // and this filter is deliberately unsatisfiable (`1=0`) rather than
        // omitted -- an empty, well-formed result the merge below already
        // treats as "no data for this parcel", not a thrown error or a
        // silently-unscoped (all-runs) fetch.
        EntityName: 'Owner Portfolio Parcels',
        Fields: ['ParcelID', 'OwnerPortfolio', 'ExistingRep', 'Recommendation', 'ConfidenceTier', 'SupportingApproachCount', 'EstSavingsAtAsk', 'AVYoYPct'],
        ExtraFilter: this.latestOwnerPortfolioRunID
          ? `ParcelID IN (${parcelIdList}) AND OwnerPortfolioID IN (SELECT ID FROM indiana_tax.OwnerPortfolio WHERE RunID = '${escapeSqlLiteral(this.latestOwnerPortfolioRunID)}')`
          : '1=0',
        // One row per parcel per run at most, so this query's true row count
        // is always exactly the number of parcels fetched above -- it must
        // stay >= RESULT_CAP (currently 5000; confirmed exactly at cap in
        // testing) or it will start silently dropping Owner Entity/Rep/
        // Recommendation data for the overflow. Left at 10000 (2x headroom
        // over the current RESULT_CAP) -- MUST be revisited again if
        // RESULT_CAP is ever raised past 10000.
        MaxRows: 10000,
        ResultType: 'simple',
      },
    ]);

    const parcelById = new Map<string, Record<string, unknown>>();
    if (parcelResult.Success) {
      for (const p of parcelResult.Results ?? []) parcelById.set(p['ID'] as string, p);
    }

    // Per parcel, prefer the county's own PRC-sourced row over the year's
    // statewide fallback (marion_foia_2026 / dlgf_gdb_2025) -- matches this
    // project's established data-integrity priority (county PRC is the
    // highest-confidence source), via the one shared precedence rule
    // (spec §4.3, pickAssessmentRow). 2024 currently has no statewide
    // fallback at all, so a parcel not yet PRC-fetched will have no entry
    // here for that year -- shown as null/"No data", not silently
    // substituted from another year.
    const assessmentByParcel = new Map<string, Record<string, unknown>>();
    if (assessmentResult.Success) {
      for (const a of assessmentResult.Results ?? []) {
        const pid = a['ParcelID'] as string;
        assessmentByParcel.set(pid, pickAssessmentRow(assessmentByParcel.get(pid), a, this.filters.countyNumber));
      }
    }

    // Query already returns rows ORDER BY HearingDate DESC, so the first row
    // per parcel is this year's latest-hearing appeal -- PTABOA Value, Date,
    // and Type all come from that SAME row, so they always describe the same
    // appeal (never a value from one hearing paired with a type from another).
    const ptaboaValueByParcel = new Map<string, number>();
    const ptaboaDateByParcel = new Map<string, string>();
    const ptaboaAppealTypeByParcel = new Map<string, string>();
    if (ptaboaDateResult.Success) {
      for (const d of ptaboaDateResult.Results ?? []) {
        const pid = d['ParcelID'] as string;
        if (ptaboaDateByParcel.has(pid)) continue;
        const value = d['AfterTotalAV'] as number | null;
        const date = d['HearingDate'] as string | null;
        const appealType = d['AppealType'] as string | null;
        if (value != null) ptaboaValueByParcel.set(pid, value);
        if (date != null) ptaboaDateByParcel.set(pid, date);
        if (appealType != null) ptaboaAppealTypeByParcel.set(pid, appealType);
      }
    }

    // At most one TaxHistoryYear row per (ParcelID, TaxYear) is expected --
    // the query above is already scoped to a single TaxYear. The one
    // confirmed exception is the real 2007 Marion County reassessment-cycle
    // transition, where a parcel can have two TaxYear=2007 rows at different
    // ColumnOrdinal values (one with zeroed AV/rate fields, one with the real
    // figures) -- see the TaxHistoryYear migration comment. When that
    // happens, prefer the higher ColumnOrdinal, which is consistently the
    // real-data row across every document checked.
    const taxHistoryByParcel = new Map<string, Record<string, unknown>>();
    if (taxHistoryResult.Success) {
      for (const t of taxHistoryResult.Results ?? []) {
        const pid = t['ParcelID'] as string;
        const existing = taxHistoryByParcel.get(pid);
        if (!existing || (t['ColumnOrdinal'] as number) > (existing['ColumnOrdinal'] as number)) {
          taxHistoryByParcel.set(pid, t);
        }
      }
    }

    // Query already returns rows ORDER BY SaleDate DESC, SaleAmount DESC, so
    // the first row encountered per CountyAssessorRecordID is the one to
    // keep -- a plain "first write wins" map, no comparison needed here (the
    // comparison already happened server-side via the ORDER BY).
    const lastSaleByCar = new Map<string, Record<string, unknown>>();
    if (saleHistoryResult.Success) {
      for (const s of saleHistoryResult.Results ?? []) {
        const carId = s['CountyAssessorRecordID'] as string;
        if (!lastSaleByCar.has(carId)) lastSaleByCar.set(carId, s);
      }
    }

    // Sum of structured-parking segment SqFt per CountyAssessorRecordID -- a
    // CAR with no parking segment simply isn't in this map (treated as 0
    // below, so its ex-garage SF equals its gross SF).
    const parkingSqFtByCar = new Map<string, number>();
    if (parkingSegmentResult.Success) {
      for (const seg of parkingSegmentResult.Results ?? []) {
        const carId = seg['CountyAssessorRecordID'] as string;
        const sqft = Number(seg['TotalSqFt']) || 0;
        parkingSqFtByCar.set(carId, (parkingSqFtByCar.get(carId) ?? 0) + sqft);
      }
    }

    // Owner Portfolio Parcels is already scoped to (at most) one row per
    // parcel via the latest-run subquery above, keyed by ParcelID -- a plain
    // "first write wins" map is correct here (there's nothing to compare).
    const ownerPortfolioByParcel = new Map<string, Record<string, unknown>>();
    if (ownerPortfolioResult.Success) {
      for (const o of ownerPortfolioResult.Results ?? []) {
        const pid = o['ParcelID'] as string;
        if (!ownerPortfolioByParcel.has(pid)) ownerPortfolioByParcel.set(pid, o);
      }
    }

    const merged: MergedParcelRow[] = [];
    for (const car of carResult.Results) {
      const parcelID = car['ParcelID'] as string;
      const p = parcelById.get(parcelID);
      // Only genuinely missing here if the Parcel record itself can't be
      // found (shouldn't happen given the FK, but a defensive guard) -- NOT
      // when it merely lacks Latitude/Longitude/BoundaryGeoJSON, which the
      // merged row now carries through as null and the map skips gracefully.
      if (!p) continue;
      const assessment = assessmentByParcel.get(parcelID);
      const taxHistory = taxHistoryByParcel.get(parcelID);
      const lastSale = lastSaleByCar.get(car['ID'] as string);
      const rowAssessmentYear = assessment ? this.filters.assessmentYear : null;
      const ownerPortfolio = ownerPortfolioByParcel.get(parcelID);
      merged.push({
        ID: p['ID'] as string,
        ParcelID: parcelID,
        CountyAssessorRecordID: car['ID'] as string,
        Address: (p['Address'] as string) ?? null,
        ParcelNumber: (p['ParcelNumber'] as string) ?? null,
        GISParcelNumber: (p['GISParcelNumber'] as string) ?? null,
        OwnerName: (car['OwnerName'] as string) ?? (p['OwnerName'] as string) ?? null,
        PropertyClass: (car['PropertyClass'] as string) ?? null,
        PropertySubClassDescription: (car['PropertySubClassDescription'] as string) ?? null,
        EstimatedSqFt: (car['EstimatedSqFt'] as number) ?? null,
        EstimatedSqFtExGarage: ((): number | null => {
          const gross = (car['EstimatedSqFt'] as number) ?? null;
          if (gross == null) return null;
          const parking = parkingSqFtByCar.get(car['ID'] as string) ?? 0;
          const net = gross - parking;
          // Guard the (unobserved) case where coded parking exceeds gross --
          // fall back to gross rather than emit a negative/zero denominator.
          return net > 0 ? net : gross;
        })(),
        SqFtSource: (car['SqFtSource'] as string) ?? null,
        // Acreage is NVARCHAR(10) at the DB layer (confirmed 2026-08-25 --
        // legacy ArcGIS-sourced text, not a numeric column), so RunView
        // ResultType 'simple' comes through as a string here -- parsed to a
        // number for the analytics panel's per-acre calculations.
        Acreage: parseAcreage(car['Acreage'] as string | null),
        ComparisonUnitType: (car['ComparisonUnitType'] as string) ?? null,
        ComparisonUnitCount: (car['ComparisonUnitCount'] as number) ?? null,
        YearBuilt: (car['YearBuilt'] as number) ?? null,
        CoStarYearBuilt: (car['CoStarYearBuilt'] as number) ?? null,
        CoStarRBA: (car['CoStarRBA'] as number) ?? null,
        AssessedLandAV: (assessment?.['OriginalLandAV'] as number) ?? null,
        AssessedImprovementAV: (assessment?.['OriginalImprovementAV'] as number) ?? null,
        AssessedTotalAV: (assessment?.['OriginalTotalAV'] as number) ?? null,
        // null (not this.filters.assessmentYear) when this row has no Assessment for the
        // selected year -- also feeds VerifyURL below, so a row with no data for this year
        // never claims a card link for a year it doesn't actually have (buildVerifyLink's
        // xSoft Engage branch requires a non-null assessmentYear; "not on file" otherwise).
        AssessmentYear: rowAssessmentYear,
        AssessmentSource: (assessment?.['Source'] as string) ?? null,
        DataSource: dataSourceLabel((assessment?.['Source'] as string) ?? null, this.filters.countyNumber),
        VerifyURL: buildVerifyLink({
          countyNumber: this.filters.countyNumber,
          slug: this.SelectedCounty?.Slug ?? '',
          parcelNumber: (p['ParcelNumber'] as string) ?? null,
          gisParcelNumber: (p['GISParcelNumber'] as string) ?? null,
          assessmentYear: rowAssessmentYear,
        }).url,
        TotalTax: (taxHistory?.['NetAnnualTax'] as number) ?? null,
        TaxRate: (taxHistory?.['TaxRate'] as number) ?? null,
        PTABOAValue: ptaboaValueByParcel.get(parcelID) ?? null,
        PTABOADate: ptaboaDateByParcel.get(parcelID) ?? null,
        PTABOAAppealType: ptaboaAppealTypeByParcel.get(parcelID) ?? null,
        LastSaleDate: (lastSale?.['SaleDate'] as string) ?? null,
        LastSalePrice: (lastSale?.['SaleAmount'] as number) ?? null,
        LastSaleIsValid: lastSale ? ((lastSale['IsValidSale'] as boolean) ?? null) : null,
        Neighborhood: (car['Neighborhood'] as string) ?? null,
        TaxDistrictID: (car['TaxDistrictID'] as string) ?? null,
        Latitude: (p['Latitude'] as number) ?? null,
        Longitude: (p['Longitude'] as number) ?? null,
        BoundaryGeoJSON: (p['BoundaryGeoJSON'] as string) ?? null,
        // OwnerEntity/TaxRep/Recommendation/ConfidenceTier/SupportingApproachCount/
        // EstSavingsAtAsk/AVYoYPct -- see MergedParcelRow's own doc comments for
        // why these are distinct from OwnerName/PTABOAValue above.
        OwnerEntity: (ownerPortfolio?.['OwnerPortfolio'] as string) ?? null,
        TaxRep: (ownerPortfolio?.['ExistingRep'] as string) ?? null,
        Recommendation: (ownerPortfolio?.['Recommendation'] as string) ?? null,
        ConfidenceTier: (ownerPortfolio?.['ConfidenceTier'] as string) ?? null,
        SupportingApproachCount: (ownerPortfolio?.['SupportingApproachCount'] as number) ?? null,
        EstSavingsAtAsk: (ownerPortfolio?.['EstSavingsAtAsk'] as number) ?? null,
        AVYoYPct: (ownerPortfolio?.['AVYoYPct'] as number) ?? null,
      });
    }

    this.MergedResults = merged;
    this.IsTruncated = carResult.Results.length >= this.RESULT_CAP;
  }

  /** The DLGF-only path. All of its logic lives in property-search-dlgf.ts; this only wires it. */
  private async runDlgfSearchInternal(): Promise<void> {
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const { rows, isTruncated } = await fetchDlgfParcelRows(rv, {
      countyNumber: this.filters.countyNumber,
      slug: this.SelectedCounty?.Slug ?? '',
      assessmentYear: this.filters.assessmentYear,
      searchTerm: this.filters.searchTerm,
      propertyClassCode: this.filters.propertySubClass,
      resultCap: this.RESULT_CAP,
    });
    this.MergedResults = rows;
    this.IsTruncated = isTruncated;
  }

  private buildCarExtraFilter(term: string, kind: ReturnType<typeof classifySearchTerm> | null, parcelIdConstraint: string[] | null): string {
    const clauses: string[] = [];

    clauses.push(`CountyNumber = ${this.filters.countyNumber}`);
    if (this.filters.propertySubClass) {
      clauses.push(`PropertySubClassDescription = '${escapeSqlLiteral(this.filters.propertySubClass)}'`);
    }
    if (this.filters.sqFtMin != null) clauses.push(`EstimatedSqFt >= ${this.filters.sqFtMin}`);
    if (this.filters.sqFtMax != null) clauses.push(`EstimatedSqFt <= ${this.filters.sqFtMax}`);

    if (kind === 'parcelOrGisNumber') {
      const ids = parcelIdConstraint ?? [];
      // No matching parcel numbers -> force an empty result rather than an
      // unfiltered one (a 1=0 clause reads clearly in a query log too).
      clauses.push(ids.length ? `ParcelID IN (${ids.map((id) => `'${escapeSqlLiteral(id)}'`).join(',')})` : '1=0');
    } else if (kind === 'subClassCode') {
      const esc = escapeSqlLiteral(term);
      clauses.push(`(PropertySubClassDescription LIKE '%-${esc}' OR PropertyClass = '${esc}')`);
    } else if (kind === 'freeText' && term) {
      const esc = escapeSqlLiteral(term);
      clauses.push(`OwnerName LIKE '%${esc}%'`);
    }

    return clauses.length ? clauses.join(' AND ') : '';
  }

  // ───── Agent context + client tools (required per dashboards/CLAUDE.md) ─────

  private publishAgentContext(): void {
    this.navigationService.SetAgentContext(
      this,
      buildPropertySearchAgentContext({
        filters: this.filters,
        rows: this.MergedResults,
        totalMatchingCount: null,
        isTruncated: this.IsTruncated,
        viewMode: this.ActiveViewMode,
        renderMode: this.ActiveRenderMode,
        visibleColumns: Array.from(this.VisibleColumnKeys),
        selectedParcelAddress: this.SelectedParcel?.Address ?? null,
        isLoading: this.IsLoading,
        countyName: this.SelectedCounty?.Name ?? null,
        countySourceTier: countySourceTier(this.filters.countyNumber),
        hasDlgfRows: this.HasDlgfRows,
      })
    );
    this.navigationService.SetAgentClientTools(this, this.buildAgentTools());
  }

  // 🚨 SAFETY BOUNDARY: every tool below is search / filter / navigate /
  // view only. None writes to CountyAssessorRecord or Parcel. OpenParcelRecord
  // opens the entity record for VIEWING — it does not edit or delete.
  // ExportResults only OPENS the export dialog — the actual file
  // format-selection and download still requires the user's own confirm
  // click inside that dialog, same as any other export surface in this app.
  private buildAgentTools(): AgentClientTool[] {
    return [
      {
        Name: 'SearchParcels',
        Description: 'Search parcels by address, owner name, parcel number, GIS parcel number, or a 3-digit DLGF subclass code (e.g. 411 for hotels).',
        ParameterSchema: { type: 'object', properties: { term: { type: 'string' } }, required: ['term'] },
        Handler: async (params) => {
          this.onSearchChange(String(params['term'] ?? ''));
          return { Success: true };
        },
      },
      {
        Name: 'FilterBySqFt',
        Description: 'Filter results by a building square footage range. Pass null for either bound to leave it open.',
        ParameterSchema: {
          type: 'object',
          properties: { min: { type: ['number', 'null'] }, max: { type: ['number', 'null'] } },
        },
        Handler: async (params) => {
          const min = params['min'];
          const max = params['max'];
          this.filters = {
            ...this.filters,
            sqFtMin: typeof min === 'number' ? min : null,
            sqFtMax: typeof max === 'number' ? max : null,
          };
          this.runSearch();
          return { Success: true };
        },
      },
      {
        Name: 'FilterByPropertySubClass',
        Description:
          "Filter to one property sub-class (e.g. 'COM HOTELS-411'). Accepts an exact sub-class name, a 3-digit DLGF code (e.g. '411'), or a partial name (case-insensitive contains-match). Pass an empty string to clear the filter.",
        ParameterSchema: { type: 'object', properties: { subClass: { type: 'string' } }, required: ['subClass'] },
        Handler: async (params) => {
          const raw = String(params['subClass'] ?? '').trim();
          if (!raw) {
            this.filters = { ...this.filters, propertySubClass: null };
            this.runSearch();
            return { Success: true };
          }
          await this.loadSubClassOptionsIfNeeded();
          const resolved = this.resolveSubClassOption(raw);
          if (!resolved) {
            const available = this.subClassOptionsCache.map((o) => o.text).slice(0, 25).join(', ');
            return { Success: false, ErrorMessage: `No property sub-class matching '${raw}'. Available: ${available}${this.subClassOptionsCache.length > 25 ? ', …' : ''}` };
          }
          this.filters = { ...this.filters, propertySubClass: resolved };
          this.runSearch();
          return { Success: true };
        },
      },
      {
        Name: 'ClearParcelFilters',
        Description: `Clear all active search terms and filters, returning to the default top-${this.RESULT_CAP}-by-assessed-value view (the selected county and assessment year are preserved -- use SwitchCounty / SwitchAssessmentYear to change those separately).`,
        ParameterSchema: { type: 'object', properties: {} },
        Handler: async () => {
          this.resetFilters();
          return { Success: true };
        },
      },
      {
        Name: 'SetColumnVisible',
        Description: `Show or hide a List-view column. Available columns: ${this.GridColumnOptions.map((c) => c.key).join(', ')}. Address is always shown and cannot be hidden.`,
        ParameterSchema: {
          type: 'object',
          properties: { column: { type: 'string' }, visible: { type: 'boolean' } },
          required: ['column', 'visible'],
        },
        Handler: async (params) => {
          const key = String(params['column'] ?? '');
          const match = this.GridColumnOptions.find((c) => c.key === key);
          if (!match) {
            return { Success: false, ErrorMessage: `Unknown column '${key}'. Available: ${this.GridColumnOptions.map((c) => c.key).join(', ')}.` };
          }
          this.toggleColumnVisible(key, params['visible'] !== false);
          return { Success: true };
        },
      },
      {
        Name: 'SwitchAssessmentYear',
        Description: 'Switch which assessment year\'s Land/Improvement/Total AV figures are shown. Does not change which parcels are in the result set.',
        ParameterSchema: { type: 'object', properties: { year: { type: 'number' } }, required: ['year'] },
        Handler: async (params) => {
          const year = Number(params['year']);
          if (!this.AvailableAssessmentYears.includes(year)) {
            return { Success: false, ErrorMessage: `Invalid year ${String(params['year'])} — available years: ${this.AvailableAssessmentYears.join(', ')}.` };
          }
          this.onAssessmentYearChange(String(year));
          return { Success: true };
        },
      },
      {
        // SAFETY BOUNDARY: this tool only changes which county is SELECTED (the query
        // scope) -- same as any other filter tool in this file. No mutation.
        Name: 'SwitchCounty',
        Description:
          'Switch which Indiana county is searched. Accepts a county name (e.g. "Lake") or its DLGF county number (e.g. 45). Counties whose record cards are loaded show county-card data; every other county shows DLGF statewide data for assessment year 2025, labelled as such.',
        ParameterSchema: { type: 'object', properties: { county: { type: ['string', 'number'] } }, required: ['county'] },
        Handler: async (params) => {
          const raw = String(params['county'] ?? '').trim();
          if (!raw) return { Success: false, ErrorMessage: 'No county given.' };
          const byNumber = Number(raw);
          const match =
            this.CountyOptions.find((c) => c.CountyNumber === byNumber) ??
            this.CountyOptions.find((c) => c.Name.toLowerCase() === raw.toLowerCase()) ??
            this.CountyOptions.find((c) => c.Name.toLowerCase().includes(raw.toLowerCase()));
          if (!match) {
            const available = this.CountyOptions.slice(0, 25).map((c) => c.Name).join(', ');
            return { Success: false, ErrorMessage: `No county matching '${raw}'. Available: ${available}${this.CountyOptions.length > 25 ? ', …' : ''}` };
          }
          this.onCountyChange(match.CountyNumber);
          return { Success: true };
        },
      },
      {
        Name: 'SwitchMapRenderMode',
        Description: "Switch the map between 'point' (clustered pins) and 'boundary' (actual parcel outlines).",
        ParameterSchema: { type: 'object', properties: { mode: { type: 'string', enum: ['point', 'boundary'] } }, required: ['mode'] },
        Handler: async (params) => {
          const mode = params['mode'];
          if (mode !== 'point' && mode !== 'boundary') {
            return { Success: false, ErrorMessage: `Invalid mode '${String(mode)}' — expected 'point' or 'boundary'.` };
          }
          this.onRenderModeChange(mode);
          return { Success: true };
        },
      },
      {
        Name: 'OpenParcelRecord',
        Description: 'Open the full County Assessor Record for a parcel, by its County Assessor Record ID or its Parcel ID, for viewing (read-only navigation).',
        ParameterSchema: { type: 'object', properties: { parcelRecordId: { type: 'string' } }, required: ['parcelRecordId'] },
        Handler: async (params) => {
          const id = String(params['parcelRecordId'] ?? '');
          const match = this.MergedResults.find((r) => r.CountyAssessorRecordID === id || r.ParcelID === id);
          if (!match) {
            return { Success: false, ErrorMessage: `No parcel with ID '${id}' in the current result set.` };
          }
          this.openParcelRecord(match);
          return { Success: true };
        },
      },
      {
        Name: 'SwitchViewMode',
        Description:
          "Switch between the map view, a sortable/exportable list (table) view of the same results, and the Analytics view (cross-sub-class assessment and appeal-outcome rollups, independent of the current search/filter state).",
        ParameterSchema: { type: 'object', properties: { mode: { type: 'string', enum: ['map', 'list', 'analytics'] } }, required: ['mode'] },
        Handler: async (params) => {
          const mode = params['mode'];
          if (mode !== 'map' && mode !== 'list' && mode !== 'analytics') {
            return { Success: false, ErrorMessage: `Invalid mode '${String(mode)}' — expected 'map', 'list', or 'analytics'.` };
          }
          this.onViewModeChange(mode);
          return { Success: true };
        },
      },
      {
        // Opens the export dialog for user confirmation -- does not silently
        // write a file. The user still picks format and confirms the actual
        // download from the dialog itself.
        Name: 'ExportResults',
        Description: 'Open the export dialog for the current search results (user picks CSV/Excel/JSON and confirms the download).',
        ParameterSchema: { type: 'object', properties: {} },
        Handler: async () => {
          if (!this.MergedResults.length) {
            return { Success: false, ErrorMessage: 'No results to export — the current search/filter returned nothing.' };
          }
          this.openExportDialog();
          return { Success: true };
        },
      },
    ];
  }
}
