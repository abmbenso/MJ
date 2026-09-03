import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData } from '@memberjunction/core-entities';
import { RunView } from '@memberjunction/core';
import {
  OwnerRow,
  OwnerParcelRow,
  CountyRollup,
  OwnerProspectsFilters,
  OwnerProspectsSummary,
  OwnerSortKey,
  BannerModel,
  DEFAULT_OWNER_PROSPECTS_FILTERS,
  computeOwnerProspectsSummary,
  buildBannerModel,
  formatMoneyShort,
  mapOwnerPortfolioRow,
  mapOwnerParcelRow,
  mapCountyRollup,
  OWNER_PORTFOLIO_RUN_ENTITY,
  OWNER_PORTFOLIO_ENTITY,
  OWNER_PORTFOLIO_PARCEL_ENTITY,
} from './owner-prospects.model';

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

  private filters: OwnerProspectsFilters = { ...DEFAULT_OWNER_PROSPECTS_FILTERS };
  private sortKey: OwnerSortKey = 'estSavingsAtAsk';
  private sortDir: 1 | -1 = -1;
  private latestRunId: string | null = null;

  constructor(private cdr: ChangeDetectorRef) {
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

  initDashboard(): void {
    // No sub-state to restore on init — loadData() (called by BaseDashboard.ngOnInit) does the work.
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
   * Task 8 fills this in — matches the loaded owners against existing
   * `indiana_tax.Prospect` rows and sets {@link OwnerRow.prospectId}.
   */
  private matchExistingProspects(): Promise<void> {
    return Promise.resolve();
  }

  /**
   * Task 6 fills this in — applies {@link filters} + {@link sortKey}/{@link sortDir}
   * to {@link AllOwners} to produce the visible table rows.
   */
  private recomputeVisibleRows(): void {
    // no-op until Task 6
  }

  ngAfterViewInit(): void {
    // publishAgentContext() added in Task 9
  }
}

export function LoadOwnerProspectsDashboard(): void {
  // Prevents tree-shaking of the component when only referenced via ClassFactory.
}
