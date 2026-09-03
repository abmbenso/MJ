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
  formatMoneyShort,
  formatMoneyOrDash,
  mapOwnerPortfolioRow,
  mapOwnerParcelRow,
  mapCountyRollup,
  OWNER_PORTFOLIO_RUN_ENTITY,
  OWNER_PORTFOLIO_ENTITY,
  OWNER_PORTFOLIO_PARCEL_ENTITY,
} from './owner-prospects.model';

/** ViewToggle option shape (mirrors `<mj-view-toggle>`'s `[Options]`). */
interface ViewToggleOption {
  key: string;
  label: string;
  icon?: string;
}

/**
 * Owner Prospects — Marion County parcels rolled up to the operating company
 * that owns them, triaged by dollars at stake. The MJ Explorer port of the
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

  private filters: OwnerProspectsFilters = { ...DEFAULT_OWNER_PROSPECTS_FILTERS };
  private sortKey: OwnerSortKey = 'estSavingsAtAsk';
  private sortDir: 1 | -1 = -1;
  private latestRunId: string | null = null;

  /** UserInfoEngine setting keys — versioned so a future shape change migrates cleanly. */
  private static readonly FILTERS_KEY = 'mj.ownerProspects.filters.v1';
  private static readonly SORT_KEY = 'mj.ownerProspects.sort.v1';
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

  /** Pre-formatted Marion County C&I year-over-year banner strings (null until {@link CountyRollup} loads). */
  public get Banner(): BannerModel | null {
    return this.CountyRollup ? buildBannerModel(this.CountyRollup) : null;
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
  /** Segmented tier control options for the inline `<mj-view-toggle>`. */
  public readonly TierOptions: ViewToggleOption[] = [
    { key: 'all', label: 'All' },
    { key: 'Prime', label: 'Prime' },
    { key: 'Strong', label: 'Strong' },
    { key: 'Moderate', label: 'Moderate' },
  ];

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
    UserInfoEngine.Instance.SetSettingDebounced(OwnerProspectsDashboardComponent.SORT_KEY, JSON.stringify({ key: this.sortKey, dir: this.sortDir }));
    this.recomputeVisibleRows();
  }
  public isSorted(key: OwnerSortKey): '' | 'asc' | 'desc' {
    return this.sortKey !== key ? '' : this.sortDir === 1 ? 'asc' : 'desc';
  }

  // ───── Row expansion (Task 6 tracks the id only; Task 7 renders the panel) ─────

  public toggleOwner(row: OwnerRow): void {
    this.SelectedOwnerId = this.SelectedOwnerId === row.id ? null : row.id;
    this.cdr.markForCheck();
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
    const p = this.ProviderToUse;
    const user = p.CurrentUser;

    const prospect = await this.createProspect(row, user);
    if (!prospect) {
      return;
    }

    const repd = await this.attachProspectParcels(prospect, row, user);
    await this.writeProspectSnapshot(prospect, row, repd, user);

    row.prospectId = prospect.ID;
    this.notify(`Flagged “${row.label}” as a prospect.`, 'success');
    this.recomputeVisibleRows();
    this.cdr.markForCheck();
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
    const yoySign = (row.avYoYPct ?? 0) >= 0 ? '+' : '';
    const opp = Math.round(row.estSavingsAtAsk ?? 0).toLocaleString('en-US');
    return (
      `${row.parcelCount} Marion parcels, $${av} AV ` +
      `(${yoySign}${row.avYoYPct}% YoY). Modeled opportunity ~$${opp}/yr at ask ` +
      `across ${row.nAppealRec} appeal-rec parcels. Rep status: ${row.repStatus}.`
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
    const inList = gisList.map((g) => `'${g}'`).join(',');
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
    const idByGis = await this.resolveParcelIds(row.parcels.map((pp) => pp.gisParcelNumber));
    const p = this.ProviderToUse;
    let repd = 0;
    for (const pp of row.parcels) {
      const parcelId = idByGis.get(pp.gisParcelNumber);
      if (!parcelId) {
        continue;
      }
      const link = await p.GetEntityObject<indianataxProspectParcelEntity>('Prospect Parcels', user);
      link.NewRecord();
      link.ProspectID = prospect.ID;
      link.ParcelID = parcelId;
      link.Disposition = this.dispositionFor(pp);
      link.ExistingRep = pp.existingRep?.trim() || null;
      link.SnapshotAV = pp.av2026 ?? pp.currentAV ?? null;
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

  /** Persist the filter state and rebuild the visible rows. */
  private afterFilterChange(): void {
    UserInfoEngine.Instance.SetSettingDebounced(OwnerProspectsDashboardComponent.FILTERS_KEY, JSON.stringify(this.filters));
    this.recomputeVisibleRows();
  }

  initDashboard(): void {
    // No sub-state to restore on init — loadData() (called by BaseDashboard.ngOnInit) does the work.
    // Task 6: restore the per-user filter + sort preferences before the first load.
    this.restoreFilterAndSortPrefs();
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
    const rawS = UserInfoEngine.Instance.GetSetting(OwnerProspectsDashboardComponent.SORT_KEY);
    if (rawS) {
      try {
        const s = JSON.parse(rawS) as { key?: unknown; dir?: unknown };
        if (typeof s?.key === 'string' && KNOWN_SORT_KEYS.has(s.key as OwnerSortKey)) {
          this.sortKey = s.key as OwnerSortKey;
          this.sortDir = s.dir === 1 ? 1 : -1;
        }
      } catch {
        /* keep defaults */
      }
    }
  }

  async loadData(): Promise<void> {
    this.IsLoading = true;
    this.LoadError = null;
    this.cdr.markForCheck();
    try {
      const rv = RunView.FromMetadataProvider(this.ProviderToUse);
      const runRes = await rv.RunView<Record<string, unknown>>({
        EntityName: OWNER_PORTFOLIO_RUN_ENTITY,
        Fields: [
          'ID',
          'RunDate',
          'MethodologyVersion',
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
        ExtraFilter: 'IsLatest = 1',
        MaxRows: 1,
        ResultType: 'simple',
      });
      if (!runRes.Success || !runRes.Results?.length) {
        this.LoadError = 'No owner-portfolio run has been published yet. Run scripts/build-owner-portfolios.js.';
        return;
      }
      const runRow = runRes.Results[0];
      this.latestRunId = String(runRow['ID']);
      this.CountyRollup = mapCountyRollup(runRow);

      const [ownerRes, parcelRes] = await rv.RunViews<Record<string, unknown>>([
        {
          EntityName: OWNER_PORTFOLIO_ENTITY,
          Fields: [
            'ID',
            'OwnerKey',
            'Label',
            'Kind',
            'Tier',
            'GroupKeyType',
            'CoStarTrueOwner',
            'ParcelCount',
            'DistinctEntities',
            'TotalAV',
            'TotalAV2025',
            'TotalAV2026',
            'AVYoYDollars',
            'AVYoYPct',
            'ParcelsUp10',
            'ParcelsUp25',
            'TotalUnits',
            'TotalSqFt',
            'NAppealRec',
            'NTwoSupport',
            'NHighConfAppeal',
            'EstSavingsAtAsk',
            'EstSavingsAtFloor',
            'AppealedParcels',
            'HistoricalReductionWon',
            'AppealYears',
            'MostRecentAppealYear',
            'LikelyRep',
            'RepStatus',
            'RepsOnReductionJSON',
            'IsFreshProspect',
            'MailAddress',
            'ByTypeJSON',
          ],
          ExtraFilter: `RunID = '${this.latestRunId}'`,
          MaxRows: 20000,
          ResultType: 'simple',
        },
        {
          EntityName: OWNER_PORTFOLIO_PARCEL_ENTITY,
          Fields: [
            'ID',
            'OwnerPortfolioID',
            'GISParcelNumber',
            'Address',
            'TypeGroup',
            'CurrentAV',
            'AV2025',
            'AV2026',
            'AVYoYPct',
            'SqFt',
            'Units',
            'AskValue',
            'EstSavingsAtAsk',
            'EstSavingsAtFloor',
            'Recommendation',
            'ConfidenceTier',
            'SupportingApproachCount',
            'Appealed',
            'ExistingRep',
            'LastAppealYear',
          ],
          // Scoped to the latest run's owner groups via a subquery (mirrors PropertySearch's
          // Assessments-year subquery pattern); ParcelID/join not needed for display.
          ExtraFilter: `OwnerPortfolioID IN (SELECT ID FROM indiana_tax.OwnerPortfolio WHERE RunID = '${this.latestRunId}')`,
          MaxRows: 50000,
          ResultType: 'simple',
        },
      ]);
      if (!ownerRes.Success) {
        this.LoadError = ownerRes.ErrorMessage || 'Failed to load owners.';
        return;
      }
      if (!parcelRes.Success) {
        this.LoadError = parcelRes.ErrorMessage || 'Failed to load parcels.';
        return;
      }

      const parcelsByOwner = new Map<string, OwnerParcelRow[]>();
      for (const raw of parcelRes.Results ?? []) {
        const pr = mapOwnerParcelRow(raw);
        const key = String(raw['OwnerPortfolioID']);
        if (!parcelsByOwner.has(key)) parcelsByOwner.set(key, []);
        parcelsByOwner.get(key)!.push(pr);
      }
      this.AllOwners = (ownerRes.Results ?? []).map((raw) => {
        const row = mapOwnerPortfolioRow(raw);
        row.parcels = parcelsByOwner.get(row.id) ?? [];
        return row;
      });
      this.CompanyOwners = this.AllOwners.filter((o) => o.kind === 'Company');
      this.Summary = computeOwnerProspectsSummary(this.CompanyOwners);
      await this.matchExistingProspects(); // Task 8
      this.recomputeVisibleRows(); // Task 6
    } finally {
      this.IsLoading = false;
      // Task 9 publishes agent context here.
      this.cdr.markForCheck();
    }
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
    this.VisibleRows = buildVisibleRows(this.CompanyOwners, this.filters, this.sortKey, this.sortDir);
    this.cdr.markForCheck();
  }

  ngAfterViewInit(): void {
    // publishAgentContext() added in Task 9
  }
}

export function LoadOwnerProspectsDashboard(): void {
  // Prevents tree-shaking of the component when only referenced via ClassFactory.
}
