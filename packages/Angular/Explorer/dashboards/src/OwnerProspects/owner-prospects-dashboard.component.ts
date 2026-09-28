import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData, UserInfoEngine } from '@memberjunction/core-entities';
import { CompositeKey, RunView, UserInfo } from '@memberjunction/core';
import { MJNotificationService } from '@memberjunction/ng-notifications';
import { indianataxProspectEntity, indianataxProspectParcelEntity, indianataxProspectSnapshotEntity } from 'mj_generatedentities';
import { FilterFieldConfig } from '@memberjunction/ng-ui-components';
import { ownerKeyFromRow } from './owner-key';
import {
  OwnerRow,
  OwnerParcelRow,
  CountyRollup,
  OwnerProspectsFilters,
  OwnerProspectsSummary,
  OwnerSortKey,
  BannerModel,
  DEFAULT_OWNER_PROSPECTS_FILTERS,
  KNOWN_SORT_KEYS,
  sanitizeFilters,
  computeOwnerProspectsSummary,
  buildBannerModel,
  buildVisibleRows,
  buildOwnerProspectsAgentContext,
  formatMoneyShort,
  formatMoneyOrDash,
  mapOwnerPortfolioRow,
  mapOwnerParcelRow,
  mapCountyRollup,
  OWNER_PORTFOLIO_RUN_ENTITY,
  OWNER_PORTFOLIO_ENTITY,
  OWNER_PORTFOLIO_PARCEL_ENTITY,
  COUNTY_ENTITY,
  OwnerProspectsScope,
  TierBasis,
  CountyBannerModel,
  STATEWIDE_ROW_CAP,
  latestRunFor,
  filterByCounty,
  statewidePortfolioFilter,
  tierLabel,
  runTierBasis,
  tierOptionsFor,
  repCell,
  savingsCell,
  countyBanner,
  countyNumbersInRun,
  isBelowYoYFloor,
} from './owner-prospects.model';
import { AgentToolResult, validateEnumParam, validateStringParam, validateNonNegativeNumberParam } from '../shared/agent-tool-validation';

/**
 * Local alias for the client-tool shape `NavigationService.SetAgentClientTools`
 * accepts — declared here rather than imported, matching the convention used
 * by other dashboards in this package (e.g. PropertySearchDashboardComponent).
 */
interface AgentClientTool {
  Name: string;
  Description: string;
  ParameterSchema: Record<string, unknown>;
  Handler: (params: Record<string, unknown>) => Promise<AgentToolResult>;
}

/** ViewToggle option shape (mirrors `<mj-view-toggle>`'s `[Options]`). */
interface ViewToggleOption {
  key: string;
  label: string;
  icon?: string;
}

/** One `<mj-dropdown>` row of the Statewide county filter. */
export interface CountyFilterOption {
  CountyNumber: number;
  Name: string;
  /** "Lake — 15,001 parcels" */
  Label: string;
}

/** The `Owner Portfolios` columns both scopes read. */
const OWNER_FIELDS: readonly string[] = [
  'ID', 'OwnerKey', 'Label', 'Kind', 'Tier', 'GroupKeyType', 'CoStarTrueOwner', 'ParcelCount', 'DistinctEntities',
  'TotalAV', 'TotalAV2025', 'TotalAV2026', 'AVYoYDollars', 'AVYoYPct', 'ParcelsUp10', 'ParcelsUp25', 'TotalUnits',
  'TotalSqFt', 'NAppealRec', 'NTwoSupport', 'NHighConfAppeal', 'EstSavingsAtAsk', 'EstSavingsAtFloor',
  'AppealedParcels', 'HistoricalReductionWon', 'AppealYears', 'MostRecentAppealYear', 'LikelyRep', 'RepStatus',
  'RepsOnReductionJSON', 'IsFreshProspect', 'MailAddress', 'ByTypeJSON', 'TierBasis',
];
/** Extra `Owner Portfolios` columns the Statewide run carries. */
const STATEWIDE_OWNER_FIELDS: readonly string[] = ['PrimaryCountyNumber', 'CountyCount', 'ByCountyJSON', 'AVPrior', 'AVCurrent', 'PairYears'];
/** The `Owner Portfolio Parcels` columns both scopes read. */
const PARCEL_FIELDS: readonly string[] = [
  'ID', 'OwnerPortfolioID', 'GISParcelNumber', 'Address', 'TypeGroup', 'CurrentAV', 'AV2025', 'AV2026', 'AVYoYPct',
  'SqFt', 'Units', 'AskValue', 'EstSavingsAtAsk', 'EstSavingsAtFloor', 'Recommendation', 'ConfidenceTier',
  'SupportingApproachCount', 'Appealed', 'ExistingRep', 'LastAppealYear',
];
/** Extra `Owner Portfolio Parcels` columns the Statewide run carries (`Parcel` = the 18-digit state number). */
const STATEWIDE_PARCEL_FIELDS: readonly string[] = [
  'ParcelID', 'Parcel', 'CountyNumber', 'PriorYear', 'CurrentYear', 'AVPrior', 'AVCurrent', 'IsPlaceholder', 'SqFtSource', 'AppealLevel',
];

/**
 * Owner Prospects — C&I parcels rolled up to the operating company that owns
 * them. Two scopes (owner-prospects-statewide, 2026-09-28): **Marion** (the
 * default, unchanged: the Marion run, triaged by dollars at stake) and
 * **Statewide** (the latest Statewide run, ranked by assessed value, with a
 * county filter; a multi-county owner lists once under All and under each of
 * its counties). The MJ Explorer port of the
 * `owner-portfolios-view.html` Artifact; reads live indiana_tax.OwnerPortfolio*
 * entities (written by scripts/build-owner-portfolios.js) instead of a baked
 * JSON blob. Read-only over the portfolio tables; the one write it can make is
 * flagging an owner as an indiana_tax.Prospect (see flagOwnerAsProspect).
 *
 * Registered against BaseResourceComponent as well as BaseDashboard for the
 * same reason PropertySearchDashboardComponent is: the tab-container's nav-item
 * resolver only ever looks up BaseResourceComponent by driver class.
 */
@Component({
  standalone: false,
  selector: 'mj-owner-prospects-dashboard',
  templateUrl: './owner-prospects-dashboard.component.html',
  styleUrls: ['./owner-prospects-dashboard.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'OwnerProspectsResource')
@RegisterClass(BaseResourceComponent, 'OwnerProspectsResource')
export class OwnerProspectsDashboardComponent extends BaseDashboard implements AfterViewInit {
  public IsLoading = false;

  /** Every owner group in the latest run — Company, Individual, Government, Institution. */
  public AllOwners: OwnerRow[] = [];
  /** The `Company`-kind subset of {@link AllOwners} — the prospect universe the table/banner work over. */
  public CompanyOwners: OwnerRow[] = [];
  /** County-wide C&I 2025→2026 rollup for the banner (null until loaded / when no run exists). */
  public CountyRollup: CountyRollup | null = null;
  /** Banner totals over {@link CompanyOwners} (null until loaded). */
  public Summary: OwnerProspectsSummary | null = null;
  /** User-facing load failure message (e.g. no published run) — null when the load succeeded. */
  public LoadError: string | null = null;

  /** {@link CompanyOwners} after the active filters + sort — what the table renders (Task 6). */
  public VisibleRows: OwnerRow[] = [];
  /** The owner whose detail row is expanded, or null. Task 7 renders the panel; Task 6 just tracks the id. */
  public SelectedOwnerId: string | null = null;
  /** Hard render cap — rows beyond this collapse into a "N more" trailing row. */
  public readonly RENDER_CAP = 1000;

  /** Which run is on screen — `?scope=` round-trips it. Marion is the default. */
  public Scope: OwnerProspectsScope = 'Marion';
  /** Statewide only: the county filter (`?county=`); null = all counties. */
  public CountyNumber: number | null = null;
  public readonly ScopeOptions: ViewToggleOption[] = [
    { key: 'Marion', label: 'Marion' },
    { key: 'Statewide', label: 'Statewide' },
  ];
  /** Statewide county dropdown — the counties with parcels in the run (from its `ByCountyJSON`), by name. */
  public CountyOptions: CountyFilterOption[] = [];
  /** The loaded run's shared `TierBasis` — drives the tier header, tier options and the savings cells. */
  public RunTierBasis: TierBasis | null = null;
  /** Statewide: the selected county's (or every county's) rollup from the run's `ByCountyJSON`. */
  public CountyBanner: CountyBannerModel | null = null;
  /** Statewide: the portfolio query returned more than {@link STATEWIDE_ROW_CAP} rows; only the top ones by AV are shown. */
  public RowCapHit = false;
  /** Statewide: tier → company-owner count over the loaded rows. */
  public TierCounts: Record<string, number | undefined> = {};
  /** Statewide: id of the owner whose parcels are loading on expand. */
  public LoadingParcelsFor: string | null = null;

  private filters: OwnerProspectsFilters = { ...DEFAULT_OWNER_PROSPECTS_FILTERS };
  private sortKey: OwnerSortKey = 'estSavingsAtAsk';
  private sortDir: 1 | -1 = -1;
  /** Each scope keeps its own sort (Statewide savings are blank, so it ranks by AV). */
  private sortByScope: Record<OwnerProspectsScope, { key: OwnerSortKey; dir: 1 | -1 }> = {
    Marion: { key: 'estSavingsAtAsk', dir: -1 },
    Statewide: { key: 'avCurrent', dir: -1 },
  };
  private latestRunId: string | null = null;
  private runByCountyJSON: string | null = null;
  private slugByCounty: Record<number, string> = {};
  private nameByCounty: Record<number, string> = {};
  private countyOptionsRunId: string | null = null;
  /** Statewide: owners whose parcels have been fetched (parcels load per opened owner). */
  private parcelsLoaded = new Set<string>();
  /** Only the newest load may publish (a scope/county switch mid-load supersedes the older one). */
  private loadSeq = 0;
  /** True once OnQueryParamsChanged has applied URL state (so initDashboard doesn't overwrite it with an unmerged config). */
  private paramsDelivered = false;
  /** Set by initDashboard — later param deliveries reload; earlier ones ride the first load. */
  private initialized = false;

  /** UserInfoEngine setting keys — versioned so a future shape change migrates cleanly. */
  private static readonly FILTERS_KEY = 'mj.ownerProspects.filters.v1';
  private static readonly SORT_KEY = 'mj.ownerProspects.sort.v1';
  private static readonly SORT_KEY_STATEWIDE = 'mj.ownerProspects.sort.statewide.v1';
  /** Sort keys that compare as strings — a fresh column on one of these starts ascending. */
  private static readonly STRING_SORT_KEYS: readonly OwnerSortKey[] = ['label', 'tier', 'appealYears', 'repStatus'];

  /** tier → `Prospect.Priority` (mirrors `flag-prospect.js` `TIER_PRIORITY`). */
  private static readonly TIER_PRIORITY: Record<string, indianataxProspectEntity['Priority']> = {
    Prime: 'High',
    Strong: 'High',
    Moderate: 'Medium',
    Watch: 'Low',
  };

  constructor(
    private cdr: ChangeDetectorRef,
    private notifications: MJNotificationService,
  ) {
    super();
  }

  /** Pre-formatted Marion County C&I year-over-year banner strings (Marion scope only; null until {@link CountyRollup} loads). */
  public get Banner(): BannerModel | null {
    return this.CountyRollup && this.Scope === 'Marion' ? buildBannerModel(this.CountyRollup) : null;
  }

  public get IsStatewide(): boolean {
    return this.Scope === 'Statewide';
  }

  public get Subtitle(): string {
    return this.IsStatewide
      ? 'C&I parcels in every loaded county rolled up to the owner — ranked by assessed value'
      : 'Marion County parcels rolled up to the operating company — triaged by dollars at stake';
  }

  /** Tier column header — from the run's `TierBasis` ("Savings tier" / "AV tier"), never from the scope. */
  public get TierHeader(): string {
    return tierLabel(this.RunTierBasis);
  }

  /** The selected county's name, or null for all counties / Marion scope. */
  public get CountyName(): string | null {
    return this.CountyNumber == null ? null : (this.nameByCounty[this.CountyNumber] ?? `County ${this.CountyNumber}`);
  }

  /** Statewide banner heading: the county, or "All N counties". */
  public get CountyBannerTitle(): string {
    return this.CountyName ?? `All ${this.CountyBanner?.countyCount ?? 0} counties`;
  }

  /** County slugs / names for the detail panel's verify links and county split. */
  public get CountySlugs(): Record<number, string> {
    return this.slugByCounty;
  }
  public get CountyNames(): Record<number, string> {
    return this.nameByCounty;
  }

  /** Table column count (drives the detail / overflow rows' colspan). */
  public get ColumnCount(): number {
    return this.IsStatewide ? 15 : 14;
  }

  public readonly repCell = repCell;
  public readonly isBelowYoYFloor = isBelowYoYFloor;

  /** A savings cell (blank with the "no valuation analysis" tooltip unless the row's tier rests on savings). */
  public savings(row: OwnerRow, value: number | null): { text: string; tooltip: string | null } {
    return savingsCell(value, row.tierBasis ?? null);
  }

  /** "Lake: 4 parcels · $35.9M" — the owner's slice of the selected county (Statewide, county chosen). */
  public countySlice(row: OwnerRow): string | null {
    if (this.CountyNumber == null) return null;
    const slice = row.byCounty?.[String(this.CountyNumber)];
    if (!slice) return null;
    return `${this.CountyName}: ${slice.parcels.toLocaleString('en-US')} parcel${slice.parcels === 1 ? '' : 's'} · ${formatMoneyShort(slice.avCurrent)}`;
  }

  // ───── Scope + county (query params `scope`, `county`) ─────

  public onScopeChange(key: string): void {
    const next: OwnerProspectsScope = key === 'Statewide' ? 'Statewide' : 'Marion';
    if (next === this.Scope) return;
    this.switchScope(next, null);
    this.pushScopeParams();
    void this.loadData();
  }

  public onCountyChange(value: unknown): void {
    const next = typeof value === 'number' && Number.isFinite(value) ? value : null;
    if (next === this.CountyNumber) return;
    this.CountyNumber = next;
    this.pushScopeParams();
    void this.loadData();
  }

  /** Apply `?scope=` / `?county=` — the other half of every {@link pushScopeParams}. */
  protected override OnQueryParamsChanged(params: Record<string, string>, _source: 'popstate' | 'deeplink'): void {
    const changed = this.applyScopeParams(params);
    this.paramsDelivered = true;
    // Before initDashboard, BaseDashboard.ngOnInit's own loadData() picks the state up.
    if (changed && this.initialized) {
      void this.loadData();
    }
  }

  /** Returns true when the params changed the scope or county. */
  private applyScopeParams(params: Record<string, string>): boolean {
    const scope: OwnerProspectsScope = params['scope'] === 'Statewide' ? 'Statewide' : 'Marion';
    const raw = Number(params['county']);
    const county = scope === 'Statewide' && params['county'] && Number.isInteger(raw) && raw > 0 ? raw : null;
    if (scope === this.Scope && county === this.CountyNumber) return false;
    this.switchScope(scope, county);
    return true;
  }

  /** Set scope + county, swapping in that scope's remembered sort. */
  private switchScope(scope: OwnerProspectsScope, county: number | null): void {
    if (scope !== this.Scope) {
      this.sortByScope[this.Scope] = { key: this.sortKey, dir: this.sortDir };
      this.sortKey = this.sortByScope[scope].key;
      this.sortDir = this.sortByScope[scope].dir;
      this.SelectedOwnerId = null;
    }
    this.Scope = scope;
    this.CountyNumber = scope === 'Statewide' ? county : null;
  }

  private pushScopeParams(): void {
    this.UpdateQueryParams({
      scope: this.IsStatewide ? 'Statewide' : null,
      county: this.IsStatewide && this.CountyNumber != null ? String(this.CountyNumber) : null,
    });
  }

  /** {@link OwnerProspectsSummary.totalAV} as `$X.XB` (`—` before load). */
  public get SummaryTotalAV(): string {
    return formatMoneyShort(this.Summary?.totalAV ?? null);
  }

  /** {@link OwnerProspectsSummary.oppAsk} as `$X.XM` — the hero metric, also used in the `[meta]` badge. */
  public get SummaryOppAsk(): string {
    return formatMoneyShort(this.Summary?.oppAsk ?? null);
  }

  /** {@link OwnerProspectsSummary.freshOpp} — opportunity where no rep is on record. */
  public get SummaryFreshOpp(): string {
    return formatMoneyShort(this.Summary?.freshOpp ?? null);
  }

  /** Point-in-time provenance footer; empty string when there's no run date to cite. */
  public get ProvenanceLine(): string {
    const cr = this.CountyRollup;
    if (!cr || !cr.runDate) {
      return '';
    }
    const runDate = new Date(cr.runDate).toLocaleDateString('en-US');
    return `Point-in-time render — run ${runDate} · methodology ${cr.methodologyVersion ?? 'n/a'}`;
  }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Owner Prospects';
  }

  // ───── Toolbar: search + filters + sort (Task 6) ─────

  public get SearchTerm(): string {
    return this.filters.query;
  }
  public onSearchChange(term: string): void {
    this.filters = { ...this.filters, query: term };
    this.afterFilterChange();
  }

  public get TierFilter(): string {
    return this.filters.tier;
  }
  public onTierChange(v: string): void {
    const tier = (v as OwnerProspectsFilters['tier']) || 'all';
    this.filters = { ...this.filters, tier };
    this.afterFilterChange();
  }
  /** Segmented tier control options for the inline `<mj-view-toggle>` — savings tiers (Marion) or AV bands A–D. */
  public TierOptions: ViewToggleOption[] = tierOptionsFor('Savings');

  public get MinOppPerYear(): number {
    return this.filters.minOppPerYear;
  }
  public onMinOppChange(v: number | null): void {
    this.filters = { ...this.filters, minOppPerYear: v ?? 0 };
    this.afterFilterChange();
  }

  public get HasAppealHistory(): boolean {
    return this.filters.hasAppealHistory;
  }
  public onHasAppealHistoryChange(checked: boolean): void {
    this.filters = { ...this.filters, hasAppealHistory: checked };
    this.afterFilterChange();
  }

  /** Distinct non-null dominant property types across the loaded owners, sorted. */
  public get TypeGroupOptions(): string[] {
    return [...new Set(this.CompanyOwners.map((o) => o.dominantType).filter((t): t is string => !!t))].sort();
  }

  /** Config-driven fields for `<mj-filter-panel>` — the two dropdowns. */
  public get FilterFields(): FilterFieldConfig[] {
    return [
      {
        key: 'rep',
        type: 'dropdown',
        label: 'Representation',
        icon: 'fa-solid fa-user-tie',
        options: [
          { text: 'Any', value: '' },
          { text: 'No rep on record', value: 'none' },
          { text: 'Represented', value: 'has' },
        ],
      },
      {
        key: 'typeGroup',
        type: 'dropdown',
        label: 'Dominant property type',
        icon: 'fa-solid fa-shapes',
        filterable: true,
        options: [{ text: 'Any', value: '' }, ...this.TypeGroupOptions.map((t) => ({ text: t, value: t }))],
      },
    ];
  }
  public get FilterValues(): Record<string, unknown> {
    return { rep: this.filters.rep, typeGroup: this.filters.typeGroup };
  }
  public onFilterValuesChange(v: Record<string, unknown>): void {
    const next = (v ?? {}) as { rep?: string; typeGroup?: string };
    this.filters = {
      ...this.filters,
      rep: (next.rep as OwnerProspectsFilters['rep']) || '',
      typeGroup: next.typeGroup || '',
    };
    this.afterFilterChange();
  }

  public get ActiveFilterCount(): number {
    let n = 0;
    if (this.filters.tier !== 'all') n++;
    if (this.filters.rep) n++;
    if (this.filters.hasAppealHistory) n++;
    if (this.filters.typeGroup) n++;
    if (this.filters.minOppPerYear > 0) n++;
    return n;
  }

  public resetFilters(): void {
    this.filters = { ...DEFAULT_OWNER_PROSPECTS_FILTERS };
    this.afterFilterChange();
  }

  /** `"1,234 owners · Σ opp/yr $12.3M (ask) / $8.1M (floor)"` — mirrors the Artifact `cnt`. */
  public get FilterCountLabel(): string {
    const rows = this.VisibleRows;
    if (this.IsStatewide) {
      // No valuation analysis outside Marion: the statewide line sums AV, never the (blank) savings.
      const av = rows.reduce((s, o) => s + (o.avCurrent ?? o.totalAV ?? 0), 0);
      return `${rows.length.toLocaleString('en-US')} owners · Σ AV current ${formatMoneyShort(av)}`;
    }
    const ask = rows.reduce((s, o) => s + (o.estSavingsAtAsk ?? 0), 0);
    const floor = rows.reduce((s, o) => s + (o.estSavingsAtFloor ?? 0), 0);
    return `${rows.length.toLocaleString('en-US')} owners · Σ opp/yr ${formatMoneyShort(ask)} (ask) / ${formatMoneyShort(floor)} (floor)`;
  }

  /** Count of rows past {@link RENDER_CAP} — drives the "N more" trailing row. */
  public get OverflowRowCount(): number {
    return Math.max(0, this.VisibleRows.length - this.RENDER_CAP);
  }

  // ───── Sort ─────

  public onSortColumn(key: OwnerSortKey): void {
    if (this.sortKey === key) {
      this.sortDir = this.sortDir === 1 ? -1 : 1;
    } else {
      this.sortKey = key;
      this.sortDir = OwnerProspectsDashboardComponent.STRING_SORT_KEYS.includes(key) ? 1 : -1;
    }
    this.persistSort();
    this.recomputeVisibleRows();
    this.publishAgentContext();
  }

  /** Persist the current sort key + direction to the per-user setting (shared by {@link onSortColumn} and the SortOwnerProspects tool). */
  private persistSort(): void {
    const key = this.IsStatewide ? OwnerProspectsDashboardComponent.SORT_KEY_STATEWIDE : OwnerProspectsDashboardComponent.SORT_KEY;
    UserInfoEngine.Instance.SetSettingDebounced(key, JSON.stringify({ key: this.sortKey, dir: this.sortDir }));
  }
  public isSorted(key: OwnerSortKey): '' | 'asc' | 'desc' {
    return this.sortKey !== key ? '' : this.sortDir === 1 ? 'asc' : 'desc';
  }

  // ───── Row expansion (Task 6 tracks the id only; Task 7 renders the panel) ─────

  public toggleOwner(row: OwnerRow): void {
    this.SelectedOwnerId = this.SelectedOwnerId === row.id ? null : row.id;
    if (this.SelectedOwnerId && this.IsStatewide && !this.parcelsLoaded.has(row.id)) {
      void this.loadOwnerParcels(row);
    }
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  /** Statewide: fetch one owner's parcels on expand (202,987 parcels statewide are never loaded at once). */
  private async loadOwnerParcels(row: OwnerRow): Promise<void> {
    this.LoadingParcelsFor = row.id;
    this.cdr.markForCheck();
    try {
      const res = await RunView.FromMetadataProvider(this.ProviderToUse).RunView<Record<string, unknown>>({
        EntityName: OWNER_PORTFOLIO_PARCEL_ENTITY,
        Fields: [...PARCEL_FIELDS, ...STATEWIDE_PARCEL_FIELDS],
        ExtraFilter: `OwnerPortfolioID = '${row.id.replace(/'/g, "''")}'`,
        OrderBy: 'AVCurrent DESC',
        MaxRows: 5000,
        ResultType: 'simple',
      });
      if (res.Success) {
        row.parcels = (res.Results ?? []).map(mapOwnerParcelRow);
        this.parcelsLoaded.add(row.id);
      } else {
        this.notify(`Parcels for “${row.label}” failed to load: ${res.ErrorMessage ?? 'unknown error'}`, 'error');
      }
    } finally {
      if (this.LoadingParcelsFor === row.id) this.LoadingParcelsFor = null;
      this.cdr.markForCheck();
    }
  }

  /**
   * Detail-panel `(FlagRequested)` handler — creates the `indiana_tax.Prospect`
   * (+ its `ProspectParcel` / `ProspectSnapshot` rows) through the MJ entity
   * layer, mirroring `Indiana_Tax_Expert/scripts/flag-prospect.js`. Idempotent on
   * the row: a row that already links a prospect is a no-op.
   */
  public async onFlagOwner(row: OwnerRow): Promise<void> {
    if (row.prospectId) {
      this.notify(`“${row.label}” is already a prospect.`, 'info');
      return;
    }
    try {
      const p = this.ProviderToUse;
      const user = p.CurrentUser;
      if (this.IsStatewide && !this.parcelsLoaded.has(row.id)) {
        await this.loadOwnerParcels(row); // statewide parcels load per owner — the prospect needs them
      }

      const prospect = await this.createProspect(row, user);
      if (!prospect) {
        return;
      }

      const repd = await this.attachProspectParcels(prospect, row, user);
      await this.writeProspectSnapshot(prospect, row, repd, user);

      row.prospectId = prospect.ID;
      this.notify(`Flagged “${row.label}” as a prospect.`, 'success');
      this.recomputeVisibleRows();
      this.publishAgentContext();
      this.cdr.markForCheck();
    } catch (e) {
      // An infrastructure-level failure (network/connection) inside GetEntityObject/Save/RunView
      // throws rather than returning false — unlike the boolean Save() failures createProspect/
      // attachProspectParcels/writeProspectSnapshot already handle gracefully. Without this guard
      // a user clicking "Flag as prospect" directly (bypassing the agent-tool path, which has its
      // own try/catch) would see the promise reject with no toast and the button left stuck.
      this.notify(`Flagging “${row.label}” failed: ${e instanceof Error ? e.message : String(e)}`, 'error');
      this.cdr.markForCheck();
    }
  }

  /** Detail-panel `(ViewProspectRequested)` handler — opens the linked prospect record. */
  public onViewProspect(row: OwnerRow): void {
    if (!row.prospectId) {
      return;
    }
    this.navigationService.OpenEntityRecord('Prospects', new CompositeKey([{ FieldName: 'ID', Value: row.prospectId }]));
  }

  // ───── Flag-as-prospect internals (mirror flag-prospect.js) ─────

  /** `Prospect.RelationshipType` from the owner's rep status string. */
  private relationshipFrom(repStatus: string): indianataxProspectEntity['RelationshipType'] {
    const s = (repStatus ?? '').toLowerCase();
    if (s.includes('faegre')) {
      return 'ExistingClientExpand';
    }
    if (s.startsWith('represented by') || s.startsWith('multiple reps')) {
      return 'CompetitorRepped';
    }
    return 'Cold';
  }

  /** `ProspectParcel.Disposition` inferred per parcel. */
  private dispositionFor(pp: OwnerParcelRow): indianataxProspectParcelEntity['Disposition'] {
    if (pp.existingRep && pp.existingRep.trim()) {
      return 'AlreadyRepresented';
    }
    if (pp.rec === 'Appeal' || pp.rec === 'Monitor') {
      return 'InScope';
    }
    return 'Monitoring';
  }

  /** The free-text `Prospect.Thesis` sentence (parcels, AV, YoY, modeled opportunity, rep status). */
  private buildThesis(row: OwnerRow): string {
    const av = Math.round(row.totalAV2026 ?? row.totalAV ?? 0).toLocaleString('en-US');
    const yoyPct = row.avYoYPct ?? 0;
    const yoySign = yoyPct >= 0 ? '+' : '';
    if (row.tierBasis === 'AV') {
      // Statewide: no valuation analysis outside Marion, so no opportunity figure is claimed.
      const counties = row.countyCount ?? 1;
      const yoy = row.avYoYPct == null ? 'no prior-year pair' : `${yoySign}${yoyPct}% YoY on paired parcels`;
      return (
        `${row.parcelCount} parcels in ${counties} ${counties === 1 ? 'county' : 'counties'}, $${av} AV (${yoy}). ` +
        `AV tier ${row.tier ?? '—'}. Rep status: ${row.repStatus}.`
      );
    }
    const opp = Math.round(row.estSavingsAtAsk ?? 0).toLocaleString('en-US');
    return (
      `${row.parcelCount} Marion parcels, $${av} AV ` +
      `(${yoySign}${yoyPct}% YoY). Modeled opportunity ~$${opp}/yr at ask ` +
      `across ${row.nAppealRec ?? 0} appeal-rec parcels. Rep status: ${row.repStatus}.`
    );
  }

  /** Create + save the `Prospects` row; null (and a toast) on failure. */
  private async createProspect(row: OwnerRow, user: UserInfo): Promise<indianataxProspectEntity | null> {
    const prospect = await this.ProviderToUse.GetEntityObject<indianataxProspectEntity>('Prospects', user);
    prospect.NewRecord();
    prospect.OwnerKey = ownerKeyFromRow({ coStarTrueOwner: row.coStarTrueOwner, label: row.label });
    prospect.DisplayName = row.label;
    prospect.RelationshipType = this.relationshipFrom(row.repStatus);
    prospect.Stage = 'Identified';
    prospect.StageEnteredDate = new Date();
    prospect.Priority = OwnerProspectsDashboardComponent.TIER_PRIORITY[row.tier ?? 'Watch'] ?? 'Medium';
    prospect.IdentifiedDate = new Date();
    prospect.IdentificationSource = 'Owner Prospects dashboard';
    prospect.EstimatedOpportunityAtAsk = row.estSavingsAtAsk;
    prospect.Thesis = this.buildThesis(row);
    if (!(await prospect.Save())) {
      this.notify(`Flag failed: ${prospect.LatestResult?.CompleteMessage ?? 'unknown error'}`, 'error');
      return null;
    }
    return prospect;
  }

  /** Resolve `indiana_tax.Parcel.ID` for a list of GIS parcel numbers → `Map<gis, id>`. */
  private async resolveParcelIds(gisList: string[]): Promise<Map<string, string>> {
    const byGis = new Map<string, string>();
    if (!gisList.length) {
      return byGis;
    }
    const inList = gisList.map((g) => `'${g.replace(/'/g, "''")}'`).join(',');
    const res = await RunView.FromMetadataProvider(this.ProviderToUse).RunView<{ ID: string; GISParcelNumber: string }>({
      EntityName: 'Parcels',
      Fields: ['ID', 'GISParcelNumber'],
      ExtraFilter: `GISParcelNumber IN (${inList})`,
      MaxRows: 5000,
      ResultType: 'simple',
    });
    if (res.Success) {
      for (const r of res.Results) {
        byGis.set(r.GISParcelNumber, r.ID);
      }
    }
    return byGis;
  }

  /** Attach every resolvable parcel as a `ProspectParcel`; returns the represented-parcel count. */
  private async attachProspectParcels(prospect: indianataxProspectEntity, row: OwnerRow, user: UserInfo): Promise<number> {
    // Statewide parcel rows carry ParcelID (GIS numbers repeat across counties); the Marion run resolves by GIS number.
    const needGis = row.parcels.filter((pp) => !pp.parcelId && pp.gisParcelNumber).map((pp) => pp.gisParcelNumber);
    const idByGis = await this.resolveParcelIds(needGis);
    const p = this.ProviderToUse;
    let repd = 0;
    for (const pp of row.parcels) {
      const parcelId = pp.parcelId ?? idByGis.get(pp.gisParcelNumber);
      if (!parcelId) {
        continue;
      }
      const link = await p.GetEntityObject<indianataxProspectParcelEntity>('Prospect Parcels', user);
      link.NewRecord();
      link.ProspectID = prospect.ID;
      link.ParcelID = parcelId;
      link.Disposition = this.dispositionFor(pp);
      link.ExistingRep = pp.existingRep?.trim() || null;
      link.SnapshotAV = pp.av2026 ?? pp.currentAV ?? pp.avCurrent ?? null;
      link.SnapshotOpportunityAtAsk = pp.estSavingsAtAsk ?? null;
      link.SnapshotOpportunityAtFloor = pp.estSavingsAtFloor ?? null;
      if (pp.existingRep?.trim()) {
        repd++;
      }
      if (!(await link.Save())) {
        this.notify(`Parcel ${pp.gisParcelNumber} not attached: ${link.LatestResult?.CompleteMessage ?? ''}`, 'warning');
      }
    }
    return repd;
  }

  /** Write the first `ProspectSnapshot` for a freshly-flagged prospect. */
  private async writeProspectSnapshot(prospect: indianataxProspectEntity, row: OwnerRow, repd: number, user: UserInfo): Promise<void> {
    const snap = await this.ProviderToUse.GetEntityObject<indianataxProspectSnapshotEntity>('Prospect Snapshots', user);
    snap.NewRecord();
    snap.ProspectID = prospect.ID;
    snap.PortfolioRunTag = 'dashboard-flag';
    snap.ParcelCount = row.parcelCount;
    snap.TotalAV = row.totalAV2026 ?? row.totalAV ?? null;
    snap.OpportunityAtAsk = row.estSavingsAtAsk ?? null;
    snap.OpportunityAtFloor = row.estSavingsAtFloor ?? null;
    snap.RepdParcelCount = repd;
    snap.FreshParcelCount = Math.max(0, row.parcelCount - repd);
    snap.AVYoYPct = row.avYoYPct ?? null;
    if (!(await snap.Save())) {
      this.notify(`Snapshot not written: ${snap.LatestResult?.CompleteMessage ?? ''}`, 'warning');
    }
  }

  /** Route a short message through the package's toast service. */
  private notify(message: string, style: 'success' | 'error' | 'warning' | 'info'): void {
    this.notifications.CreateSimpleNotification(message, style, style === 'error' ? 6000 : 3500);
  }

  /** Money formatter for the table cells (`$12,345` / `$0` / `—`). */
  public money(n: number | null): string {
    return formatMoneyOrDash(n);
  }

  /** Signed YoY percent for the table cell: `+15.2%` / `-4.1%` / `—`. */
  public yoy(pct: number | null): string {
    if (pct == null) return '—';
    return (pct > 0 ? '+' : '') + pct + '%';
  }

  /** {@link VisibleRows} capped at {@link RENDER_CAP} — what the `<tbody>` actually renders. */
  public get RenderedRows(): OwnerRow[] {
    return this.VisibleRows.length > this.RENDER_CAP ? this.VisibleRows.slice(0, this.RENDER_CAP) : this.VisibleRows;
  }

  /**
   * The row-cap banner. Under All it points to the county filter; a county can itself hold more
   * than the cap (Lake: 9,021 owners), and there it says plainly that the smallest owners are not loaded.
   */
  public get RowCapMessage(): string {
    const cap = STATEWIDE_ROW_CAP.toLocaleString('en-US');
    return this.CountyNumber == null
      ? `showing the top ${cap} by AV; filter by county to see all`
      : `showing the top ${cap} by AV in ${this.CountyName}; this county's smallest owners are not loaded`;
  }

  /** Statewide: tooltip on the AV-prior column header. */
  public readonly AVPriorTooltip =
    'Sum of the prior-year AV over the parcels that have a prior year — the YoY base, not the whole portfolio.';

  /** Persist the filter state and rebuild the visible rows. */
  private afterFilterChange(): void {
    UserInfoEngine.Instance.SetSettingDebounced(OwnerProspectsDashboardComponent.FILTERS_KEY, JSON.stringify(this.filters));
    this.recomputeVisibleRows();
    this.publishAgentContext();
  }

  initDashboard(): void {
    // Task 6: restore the per-user filter + sort preferences before the first load.
    this.restoreFilterAndSortPrefs();
    // Statewide Task 5: `?scope=` / `?county=` from the tab config — unless OnQueryParamsChanged already applied them.
    if (!this.paramsDelivered) {
      this.applyScopeParams(this.GetQueryParams());
    }
    this.initialized = true;
  }

  /** Rehydrate {@link filters} / {@link sortKey} / {@link sortDir} from `UserInfoEngine`; keep defaults on any failure. */
  private restoreFilterAndSortPrefs(): void {
    const rawF = UserInfoEngine.Instance.GetSetting(OwnerProspectsDashboardComponent.FILTERS_KEY);
    if (rawF) {
      try {
        this.filters = sanitizeFilters(JSON.parse(rawF));
      } catch {
        /* keep defaults */
      }
    }
    this.sortByScope.Marion = this.readSortPref(OwnerProspectsDashboardComponent.SORT_KEY) ?? this.sortByScope.Marion;
    this.sortByScope.Statewide = this.readSortPref(OwnerProspectsDashboardComponent.SORT_KEY_STATEWIDE) ?? this.sortByScope.Statewide;
    this.sortKey = this.sortByScope[this.Scope].key;
    this.sortDir = this.sortByScope[this.Scope].dir;
  }

  /** One persisted sort blob, or null when absent / unknown key / corrupt. */
  private readSortPref(settingKey: string): { key: OwnerSortKey; dir: 1 | -1 } | null {
    const raw = UserInfoEngine.Instance.GetSetting(settingKey);
    if (!raw) return null;
    try {
      const s = JSON.parse(raw) as { key?: unknown; dir?: unknown };
      if (typeof s?.key === 'string' && KNOWN_SORT_KEYS.has(s.key as OwnerSortKey)) {
        return { key: s.key as OwnerSortKey, dir: s.dir === 1 ? 1 : -1 };
      }
    } catch {
      /* keep defaults */
    }
    return null;
  }

  async loadData(): Promise<void> {
    const seq = ++this.loadSeq;
    this.IsLoading = true;
    this.LoadError = null;
    this.RowCapHit = false;
    this.cdr.markForCheck();
    try {
      const rv = RunView.FromMetadataProvider(this.ProviderToUse);
      const runRes = await rv.RunView<Record<string, unknown>>({
        EntityName: OWNER_PORTFOLIO_RUN_ENTITY,
        Fields: [
          'ID',
          'RunDate',
          'MethodologyVersion',
          'IsLatest',
          'Scope',
          'CountyCount',
          'ByCountyJSON',
          'CountyParcelCount',
          'CountyTotalAV2025',
          'CountyTotalAV2026',
          'CountyYoYDollars',
          'CountyYoYPct',
          'CountyParcelsUp5',
          'CountyParcelsUp10',
          'CountyParcelsUp25',
          'CountyParcelsUp50',
          'CountyParcelsDown',
          'CountyByTypeJSON',
        ],
        // IsLatest is per scope. Two rows is the tripwire: two latest runs of one scope is an error, never a silent pick.
        ExtraFilter: `IsLatest = 1 AND Scope = '${this.Scope}'`,
        MaxRows: 2,
        ResultType: 'simple',
      });
      if (seq !== this.loadSeq) return;
      if (!runRes.Success) {
        this.clearLoaded(runRes.ErrorMessage || 'Failed to load the owner-portfolio run.');
        return;
      }
      const pick = latestRunFor(runRes.Results ?? [], this.Scope);
      if (!pick.run) {
        const noRun = (runRes.Results ?? []).length === 0;
        this.clearLoaded(
          noRun && this.Scope === 'Marion'
            ? 'No owner-portfolio run has been published yet. Run scripts/build-owner-portfolios.js.'
            : noRun
              ? 'No Statewide owner-portfolio run has been published yet. Run mj-indiana-tax/scripts/build-owner-portfolios-statewide.js.'
              : (pick.error ?? 'Owner-portfolio run not found.'),
        );
        return;
      }
      const runRow = pick.run;
      this.latestRunId = String(runRow['ID']);
      this.CountyRollup = mapCountyRollup(runRow);
      this.runByCountyJSON = typeof runRow['ByCountyJSON'] === 'string' ? runRow['ByCountyJSON'] : null;

      const owners = this.Scope === 'Marion' ? await this.loadMarionOwners(rv) : await this.loadStatewideOwners(rv);
      if (seq !== this.loadSeq || owners == null) return;

      this.AllOwners = owners;
      this.CompanyOwners = this.AllOwners.filter((o) => o.kind === 'Company');
      this.Summary = computeOwnerProspectsSummary(this.CompanyOwners);
      this.RunTierBasis = runTierBasis(this.AllOwners);
      this.TierOptions = tierOptionsFor(this.RunTierBasis ?? (this.IsStatewide ? 'AV' : 'Savings'));
      if (!this.TierOptions.some((o) => o.key === this.filters.tier)) {
        this.filters = { ...this.filters, tier: 'all' };
      }
      this.TierCounts = this.countTiers(this.CompanyOwners);
      this.CountyBanner = this.IsStatewide ? countyBanner(this.runByCountyJSON, this.CountyNumber) : null;
      await this.matchExistingProspects(); // Task 8
      if (seq !== this.loadSeq) return;
      this.recomputeVisibleRows(); // Task 6
    } finally {
      if (seq === this.loadSeq) {
        this.IsLoading = false;
        this.publishAgentContext();
        this.cdr.markForCheck();
      }
    }
  }

  /** Drop the loaded run (scope switch to a scope with no/ambiguous run) and show why. */
  private clearLoaded(message: string): void {
    this.LoadError = message;
    this.latestRunId = null;
    this.CountyRollup = null;
    this.CountyBanner = null;
    this.AllOwners = [];
    this.CompanyOwners = [];
    this.VisibleRows = [];
    this.Summary = null;
  }

  /** Marion run: every owner and every parcel of the run, as before the statewide scope. */
  private async loadMarionOwners(rv: RunView): Promise<OwnerRow[] | null> {
    const [ownerRes, parcelRes] = await rv.RunViews<Record<string, unknown>>([
      {
        EntityName: OWNER_PORTFOLIO_ENTITY,
        Fields: [...OWNER_FIELDS],
        ExtraFilter: `RunID = '${this.latestRunId}'`,
        MaxRows: 20000,
        ResultType: 'simple',
      },
      {
        EntityName: OWNER_PORTFOLIO_PARCEL_ENTITY,
        Fields: [...PARCEL_FIELDS],
        // Scoped to the latest run's owner groups via a subquery (mirrors PropertySearch's
        // Assessments-year subquery pattern); ParcelID/join not needed for display.
        ExtraFilter: `OwnerPortfolioID IN (SELECT ID FROM indiana_tax.OwnerPortfolio WHERE RunID = '${this.latestRunId}')`,
        MaxRows: 50000,
        ResultType: 'simple',
      },
    ]);
    if (!ownerRes.Success) {
      this.LoadError = ownerRes.ErrorMessage || 'Failed to load owners.';
      return null;
    }
    if (!parcelRes.Success) {
      this.LoadError = parcelRes.ErrorMessage || 'Failed to load parcels.';
      return null;
    }
    const parcelsByOwner = new Map<string, OwnerParcelRow[]>();
    for (const raw of parcelRes.Results ?? []) {
      const pr = mapOwnerParcelRow(raw);
      const key = String(raw['OwnerPortfolioID']);
      if (!parcelsByOwner.has(key)) parcelsByOwner.set(key, []);
      parcelsByOwner.get(key)!.push(pr);
    }
    return (ownerRes.Results ?? []).map((raw) => {
      const row = mapOwnerPortfolioRow(raw);
      row.parcels = parcelsByOwner.get(row.id) ?? [];
      return row;
    });
  }

  /**
   * Statewide run: the county's owners (or all), top {@link STATEWIDE_ROW_CAP} by
   * `AVCurrent` — 109,346 portfolios are never loaded at once. Parcels load per
   * opened owner ({@link loadOwnerParcels}).
   */
  private async loadStatewideOwners(rv: RunView): Promise<OwnerRow[] | null> {
    await this.ensureCountyOptions(rv);
    const res = await rv.RunView<Record<string, unknown>>({
      EntityName: OWNER_PORTFOLIO_ENTITY,
      Fields: [...OWNER_FIELDS, ...STATEWIDE_OWNER_FIELDS],
      ExtraFilter: statewidePortfolioFilter(this.latestRunId ?? '', this.CountyNumber),
      OrderBy: 'AVCurrent DESC',
      MaxRows: STATEWIDE_ROW_CAP + 1, // +1 is the tripwire for the "top 5,000" banner
      ResultType: 'simple',
    });
    if (!res.Success) {
      this.LoadError = res.ErrorMessage || 'Failed to load owners.';
      return null;
    }
    const raw = res.Results ?? [];
    this.RowCapHit = raw.length > STATEWIDE_ROW_CAP;
    this.parcelsLoaded.clear();
    return filterByCounty(raw.slice(0, STATEWIDE_ROW_CAP).map(mapOwnerPortfolioRow), this.CountyNumber);
  }

  /** County names/slugs for the counties with parcels in the run (from its `ByCountyJSON`) — once per run. */
  private async ensureCountyOptions(rv: RunView): Promise<void> {
    if (this.countyOptionsRunId === this.latestRunId) return;
    const numbers = countyNumbersInRun(this.runByCountyJSON);
    if (!numbers.length) {
      this.CountyOptions = [];
      return;
    }
    const res = await rv.RunView<{ CountyNumber: number; Name: string; Slug: string }>({
      EntityName: COUNTY_ENTITY,
      Fields: ['CountyNumber', 'Name', 'Slug'],
      ExtraFilter: `CountyNumber IN (${numbers.join(',')})`,
      OrderBy: 'Name',
      MaxRows: 100,
      ResultType: 'simple',
    });
    const rows = res.Success ? (res.Results ?? []) : [];
    this.slugByCounty = {};
    this.nameByCounty = {};
    for (const r of rows) {
      this.slugByCounty[r.CountyNumber] = r.Slug;
      this.nameByCounty[r.CountyNumber] = r.Name;
    }
    const byCounty = JSON.parse(this.runByCountyJSON ?? '{}') as Record<string, { parcels?: number }>;
    this.CountyOptions = numbers
      .map((n) => {
        const name = this.nameByCounty[n] ?? `County ${n}`;
        const parcels = byCounty[String(n)]?.parcels ?? 0;
        return { CountyNumber: n, Name: name, Label: `${name} — ${parcels.toLocaleString('en-US')} parcels` };
      })
      .sort((a, b) => a.Name.localeCompare(b.Name));
    this.countyOptionsRunId = this.latestRunId;
  }

  private countTiers(rows: readonly OwnerRow[]): Record<string, number | undefined> {
    const out: Record<string, number> = {};
    for (const r of rows) {
      if (r.tier) out[r.tier] = (out[r.tier] ?? 0) + 1;
    }
    return out;
  }

  /**
   * Match the loaded owners against existing `indiana_tax.Prospect` rows by
   * `OwnerKey` and stamp {@link OwnerRow.prospectId} on every hit — so the table
   * pill and the detail panel's "View prospect" affordance light up for owners
   * that are already flagged.
   */
  private async matchExistingProspects(): Promise<void> {
    const res = await RunView.FromMetadataProvider(this.ProviderToUse).RunView<{ ID: string; OwnerKey: string }>({
      EntityName: 'Prospects',
      Fields: ['ID', 'OwnerKey'],
      MaxRows: 20000,
      ResultType: 'simple',
    });
    if (!res.Success) {
      return;
    }
    const byKey = new Map<string, string>(res.Results.map((r): [string, string] => [r.OwnerKey, r.ID]));
    for (const row of this.AllOwners) {
      row.prospectId = byKey.get(row.ownerKey) ?? null;
    }
  }

  /**
   * Applies {@link filters} + {@link sortKey}/{@link sortDir} to {@link CompanyOwners}
   * to produce the visible table rows (a thin call to the pure {@link buildVisibleRows}).
   */
  private recomputeVisibleRows(): void {
    // Statewide: the opportunity filter would act on savings the table blanks, so it is off there.
    const f = this.IsStatewide ? { ...this.filters, minOppPerYear: 0 } : this.filters;
    this.VisibleRows = buildVisibleRows(this.CompanyOwners, f, this.sortKey, this.sortDir);
    this.cdr.markForCheck();
  }

  ngAfterViewInit(): void {
    this.publishAgentContext();
  }

  // ───── Agent context + client tools (required per dashboards/CLAUDE.md) ─────

  /**
   * Report the dashboard's state to the AI agent and (re-)register the client
   * tools it may invoke. Called from {@link ngAfterViewInit} and on every
   * meaningful state change (load, filter, sort, row expand, flag success).
   */
  private publishAgentContext(): void {
    const selected = this.SelectedOwnerId ? (this.AllOwners.find((o) => o.id === this.SelectedOwnerId) ?? null) : null;
    this.navigationService.SetAgentContext(
      this,
      buildOwnerProspectsAgentContext({
        runDate: this.CountyRollup?.runDate ?? null,
        methodologyVersion: this.CountyRollup?.methodologyVersion ?? null,
        companyOwnerCount: this.CompanyOwners.length,
        visibleRows: this.VisibleRows,
        summary: this.Summary,
        filters: this.filters,
        sortKey: this.sortKey,
        sortDir: this.sortDir,
        selectedOwnerLabel: selected?.label ?? null,
        selectedOwnerIsFlagged: !!selected?.prospectId,
        countyYoYPct: this.IsStatewide ? (this.CountyBanner?.yoyPct ?? null) : (this.CountyRollup?.yoyPct ?? null),
        scope: this.Scope,
        county: this.CountyName,
        tierBasis: this.RunTierBasis,
      }),
    );
    this.navigationService.SetAgentClientTools(this, this.buildAgentTools());
  }

  /** id → exact-label → partial-contains (case-insensitive) lookup over {@link CompanyOwners}; null on a miss. */
  private resolveOwner(ref: string): OwnerRow | null {
    const needle = (ref ?? '').trim();
    if (!needle) {
      return null;
    }
    const byId = this.CompanyOwners.find((o) => o.id === needle);
    if (byId) {
      return byId;
    }
    const lower = needle.toLowerCase();
    return this.CompanyOwners.find((o) => o.label.toLowerCase() === lower) ?? this.CompanyOwners.find((o) => o.label.toLowerCase().includes(lower)) ?? null;
  }

  /** Tolerant "no such owner" result listing up to 15 candidate labels (never throws). */
  private ownerNotFound(ref: string): AgentToolResult {
    const names = this.CompanyOwners.slice(0, 15)
      .map((o) => o.label)
      .join(', ');
    const more = this.CompanyOwners.length > 15 ? ', …' : '';
    return { Success: false, ErrorMessage: `No owner matching "${ref}". Available (first 15): ${names}${more}` };
  }

  /** FilterOwnerProspects handler body — validates each provided key, merges into {@link filters}, re-filters. */
  private applyAgentFilters(params: Record<string, unknown>): AgentToolResult {
    const next: OwnerProspectsFilters = { ...this.filters };
    if (params['tier'] !== undefined) {
      const v = validateEnumParam(params['tier'], ['all', 'Prime', 'Strong', 'Moderate', 'A', 'B', 'C', 'D'] as const, 'tier');
      if (!v.ok) return v.result;
      next.tier = v.value;
    }
    if (params['rep'] !== undefined) {
      const v = validateEnumParam(params['rep'], ['', 'none', 'has'] as const, 'rep');
      if (!v.ok) return v.result;
      next.rep = v.value;
    }
    if (params['typeGroup'] !== undefined) {
      const v = validateStringParam(params['typeGroup'], 'typeGroup');
      if (!v.ok) return v.result;
      next.typeGroup = v.value;
    }
    if (params['minOppPerYear'] !== undefined) {
      const v = validateNonNegativeNumberParam(params['minOppPerYear'], 'minOppPerYear');
      if (!v.ok) return v.result;
      next.minOppPerYear = v.value;
    }
    if (params['hasAppealHistory'] !== undefined) {
      if (typeof params['hasAppealHistory'] !== 'boolean') {
        return { Success: false, ErrorMessage: 'hasAppealHistory must be a boolean.' };
      }
      next.hasAppealHistory = params['hasAppealHistory'];
    }
    this.filters = next;
    this.afterFilterChange();
    return { Success: true };
  }

  /** SortOwnerProspects handler body — validates key + direction, sets sort, persists, re-filters, re-publishes. */
  private applyAgentSort(params: Record<string, unknown>): AgentToolResult {
    const key = String(params['key'] ?? '');
    if (!KNOWN_SORT_KEYS.has(key as OwnerSortKey)) {
      return { Success: false, ErrorMessage: `Invalid sort key "${key}". Expected one of: ${[...KNOWN_SORT_KEYS].join(', ')}.` };
    }
    const dir = params['direction'];
    if (dir !== 'asc' && dir !== 'desc') {
      return { Success: false, ErrorMessage: `Invalid direction "${String(dir)}". Expected 'asc' or 'desc'.` };
    }
    this.sortKey = key as OwnerSortKey;
    this.sortDir = dir === 'asc' ? 1 : -1;
    this.persistSort();
    this.recomputeVisibleRows();
    this.publishAgentContext();
    return { Success: true };
  }

  /**
   * 🚨 SAFETY BOUNDARY: every tool below is filter / search / sort / select /
   * clear-filters / open-prospect-record (VIEW) only — EXCEPT FlagOwnerAsProspect,
   * the one deliberate mutating tool. Creating an indiana_tax.Prospect IS this
   * screen's purpose (it parallels RunClassificationPipeline being exposed on the
   * Classify dashboard), and it is idempotent: flagging an owner that is already
   * a prospect is a no-op that returns success — never a duplicate Prospect
   * (enforced by the `row.prospectId` check). OpenProspectRecord opens the linked
   * Prospect for VIEWING only; an unflagged owner yields a structured
   * "not a prospect yet" result, not an error/throw.
   *
   * NOT EXPOSED: editing or deleting a Prospect; editing Stage /
   * ConflictCheckStatus / any other Prospect field; any ProspectParcel
   * disposition change; any write to the OwnerPortfolio* tables; any bulk flag.
   * Every Handler returns an AgentToolResult and never throws.
   */
  private buildAgentTools(): AgentClientTool[] {
    return [
      {
        Name: 'FilterOwnerProspects',
        Description:
          "Filter the owners table. tier: 'all' | 'Prime' | 'Strong' | 'Moderate' (Marion scope, savings tiers) | 'A' | 'B' | 'C' | 'D' (Statewide scope, AV tiers). rep: '' (any) | 'none' (no rep on record) | 'has' (represented). typeGroup: a dominant-property-type label (empty string clears). minOppPerYear: minimum modeled opportunity/yr at ask. hasAppealHistory: true keeps only owners with a prior appeal. Omitted keys are left unchanged.",
        ParameterSchema: {
          type: 'object',
          properties: {
            tier: { type: 'string', enum: ['all', 'Prime', 'Strong', 'Moderate', 'A', 'B', 'C', 'D'] },
            rep: { type: 'string', enum: ['', 'none', 'has'] },
            typeGroup: { type: 'string' },
            minOppPerYear: { type: 'number' },
            hasAppealHistory: { type: 'boolean' },
          },
        },
        Handler: async (params) => this.applyAgentFilters(params),
      },
      {
        Name: 'SearchOwnerProspects',
        Description: 'Set the free-text search over owner label / likely representative (case-insensitive contains-match). Pass an empty string to clear.',
        ParameterSchema: { type: 'object', properties: { query: { type: 'string' } }, required: ['query'] },
        Handler: async (params) => {
          const v = validateStringParam(params['query'], 'query');
          if (!v.ok) return v.result;
          this.filters = { ...this.filters, query: v.value };
          this.afterFilterChange();
          return { Success: true };
        },
      },
      {
        Name: 'SortOwnerProspects',
        Description: `Sort the owners table. key: one of ${[...KNOWN_SORT_KEYS].join(', ')}. direction: 'asc' or 'desc'.`,
        ParameterSchema: {
          type: 'object',
          properties: { key: { type: 'string' }, direction: { type: 'string', enum: ['asc', 'desc'] } },
          required: ['key', 'direction'],
        },
        Handler: async (params) => this.applyAgentSort(params),
      },
      {
        Name: 'SelectOwner',
        Description:
          "Expand one owner's detail row, by owner ID or label (exact, then case-insensitive contains-match). On a miss, returns the available owner labels.",
        ParameterSchema: { type: 'object', properties: { owner: { type: 'string' } }, required: ['owner'] },
        Handler: async (params) => {
          const ref = String(params['owner'] ?? '');
          const row = this.resolveOwner(ref);
          if (!row) return this.ownerNotFound(ref);
          this.SelectedOwnerId = row.id;
          this.publishAgentContext();
          this.cdr.markForCheck();
          return { Success: true };
        },
      },
      {
        Name: 'ClearOwnerProspectsFilters',
        Description: 'Reset every filter (tier, representation, dominant type, appeal-history, min opportunity/yr, search) to its default.',
        ParameterSchema: { type: 'object', properties: {} },
        Handler: async () => {
          this.resetFilters();
          return { Success: true };
        },
      },
      {
        Name: 'OpenProspectRecord',
        Description:
          'Open the linked indiana_tax.Prospect record for an owner (by ID or label) for VIEWING. If the owner is not flagged as a prospect yet, returns a structured "not a prospect yet" result — use FlagOwnerAsProspect first.',
        ParameterSchema: { type: 'object', properties: { owner: { type: 'string' } }, required: ['owner'] },
        Handler: async (params) => {
          const ref = String(params['owner'] ?? '');
          const row = this.resolveOwner(ref);
          if (!row) return this.ownerNotFound(ref);
          if (!row.prospectId) {
            return { Success: false, ErrorMessage: `"${row.label}" is not flagged as a prospect yet — use FlagOwnerAsProspect first.` };
          }
          this.onViewProspect(row);
          return { Success: true };
        },
      },
      {
        Name: 'FlagOwnerAsProspect',
        Description:
          "Flag an owner (by ID or label) as an indiana_tax.Prospect — the screen's purpose. Idempotent: an owner that is already a prospect returns success with no duplicate created. This is the only tool here that writes.",
        ParameterSchema: { type: 'object', properties: { owner: { type: 'string' } }, required: ['owner'] },
        Handler: async (params) => {
          const ref = String(params['owner'] ?? '');
          const row = this.resolveOwner(ref);
          if (!row) return this.ownerNotFound(ref);
          if (row.prospectId) {
            return { Success: true };
          }
          try {
            await this.onFlagOwner(row);
          } catch (e) {
            return { Success: false, ErrorMessage: `Flagging "${row.label}" failed: ${e instanceof Error ? e.message : String(e)}` };
          }
          return row.prospectId
            ? { Success: true }
            : { Success: false, ErrorMessage: `Flagging "${row.label}" did not complete — see the dashboard for the error detail.` };
        },
      },
    ];
  }
}

export function LoadOwnerProspectsDashboard(): void {
  // Prevents tree-shaking of the component when only referenced via ClassFactory.
}
