/**
 * Owner Prospects — data access for both scopes, as a plain class over one `RunView`
 * (no Angular decorators; the dashboard builds it from `RunView.FromMetadataProvider(this.ProviderToUse)`).
 *
 * Owns every query the screen runs against the owner-portfolio tables: the run pick (per scope, with
 * the 2-row tripwire), the Marion run's full owner + parcel load, the Statewide owners page (top
 * {@link STATEWIDE_ROW_CAP} by AV, optionally one county), the server search past that cap, the county
 * lookup for the dropdown, the parcels of one opened owner (top {@link PARCEL_ROW_CAP}), that owner's
 * display-year figures read live from `Parcel Year Headlines`, and the existing-prospect match. The static `*Query` builders are pure so the filters can be unit-tested.
 */
import { RunView, RunViewParams } from '@memberjunction/core';
import {
  OwnerRow,
  OwnerParcelRow,
  OwnerProspectsScope,
  OWNER_PORTFOLIO_RUN_ENTITY,
  OWNER_PORTFOLIO_ENTITY,
  OWNER_PORTFOLIO_PARCEL_ENTITY,
  COUNTY_ENTITY,
  PARCEL_YEAR_HEADLINE_ENTITY,
  DisplayYears,
  ParcelYearsMap,
  mapParcelYearHeadlines,
  countyChips,
  STATEWIDE_ROW_CAP,
  PARCEL_ROW_CAP,
  latestRunFor,
  filterByCounty,
  statewidePortfolioFilter,
  statewideSearchFilter,
  countyNumbersInRun,
  mapOwnerPortfolioRow,
  mapOwnerParcelRow,
} from './owner-prospects.model';
import { escapeSqlLiteral } from '../PropertySearch/property-search-agent-context';

type RawRow = Record<string, unknown>;

/** One `<mj-dropdown>` row of the Statewide county filter. */
export interface CountyFilterOption {
  CountyNumber: number;
  Name: string;
  /** "Lake — 15,001 parcels" */
  Label: string;
  /** The county status chip for the display years (`cards` / `roll only` / `2026 TBA`); null without display years. */
  Chip: string | null;
}

/** The county dropdown plus the slug / name maps the verify links and county split read. */
export interface CountyLookup {
  Options: CountyFilterOption[];
  Slugs: Record<number, string>;
  Names: Record<number, string>;
}

export type RunPick = { run: RawRow; error: null } | { run: null; error: string };
export type OwnersResult = { ok: true; rows: OwnerRow[]; capHit: boolean } | { ok: false; error: string };
export type ParcelsResult = { ok: true; parcels: OwnerParcelRow[]; capHit: boolean } | { ok: false; error: string };
export type ParcelYearsResult = { ok: true; years: ParcelYearsMap } | { ok: false; error: string };

/** Parcel-year figures per opened owner: at most this many (the query asks for one more as a tripwire). */
export const PARCEL_YEAR_ROW_CAP = 10000;
/** The `Parcel Year Headlines` columns the panel reads (ParcelID, the year, THE assessed value, roll flag, source label). */
const PARCEL_YEAR_FIELDS: readonly string[] = ['ParcelID', 'AssessmentYear', 'HeadlineTotalAV', 'IsPlaceholder', 'HeadlineDataSource'];

/** The run columns both scopes read. */
const RUN_FIELDS: readonly string[] = [
  'ID', 'RunDate', 'MethodologyVersion', 'IsLatest', 'Scope', 'CountyCount', 'ByCountyJSON', 'CountyParcelCount',
  'CountyTotalAV2025', 'CountyTotalAV2026', 'CountyYoYDollars', 'CountyYoYPct', 'CountyParcelsUp5',
  'CountyParcelsUp10', 'CountyParcelsUp25', 'CountyParcelsUp50', 'CountyParcelsDown', 'CountyByTypeJSON',
];
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

export class OwnerProspectsDataAccess {
  constructor(private readonly rv: RunView) {}

  // ───── Pure query builders (unit-tested) ─────

  /** The latest run of a scope. `IsLatest` is per scope; two rows is the tripwire. */
  public static RunQuery(scope: OwnerProspectsScope): RunViewParams {
    return {
      EntityName: OWNER_PORTFOLIO_RUN_ENTITY,
      Fields: [...RUN_FIELDS],
      ExtraFilter: `IsLatest = 1 AND Scope = '${escapeSqlLiteral(scope)}'`,
      MaxRows: 2,
      ResultType: 'simple',
    };
  }

  /** The Marion run: every owner, and every parcel of those owners. */
  public static MarionQueries(runId: string): RunViewParams[] {
    const run = escapeSqlLiteral(runId);
    return [
      { EntityName: OWNER_PORTFOLIO_ENTITY, Fields: [...OWNER_FIELDS], ExtraFilter: `RunID = '${run}'`, MaxRows: 20000, ResultType: 'simple' },
      {
        EntityName: OWNER_PORTFOLIO_PARCEL_ENTITY,
        // ParcelID: the key the live `Parcel Year Headlines` read joins on (populated on every Marion-run row).
        Fields: [...PARCEL_FIELDS, 'ParcelID'],
        ExtraFilter: `OwnerPortfolioID IN (SELECT ID FROM indiana_tax.OwnerPortfolio WHERE RunID = '${run}')`,
        MaxRows: 50000,
        ResultType: 'simple',
      },
    ];
  }

  /** A Statewide owners page (All, or one county): top {@link STATEWIDE_ROW_CAP} by AV, +1 as the tripwire. */
  public static PageQuery(runId: string, countyNumber: number | null): RunViewParams {
    return OwnerProspectsDataAccess.statewideOwners(statewidePortfolioFilter(runId, countyNumber));
  }

  /** The server search past the cap: the page's clause plus `Label LIKE`. */
  public static SearchQuery(runId: string, countyNumber: number | null, term: string): RunViewParams {
    return OwnerProspectsDataAccess.statewideOwners(statewideSearchFilter(runId, countyNumber, term));
  }

  /** One opened owner's parcels: top {@link PARCEL_ROW_CAP} by AV, +1 as the tripwire. */
  public static ParcelsQuery(ownerId: string): RunViewParams {
    return {
      EntityName: OWNER_PORTFOLIO_PARCEL_ENTITY,
      Fields: [...PARCEL_FIELDS, ...STATEWIDE_PARCEL_FIELDS],
      ExtraFilter: `OwnerPortfolioID = '${escapeSqlLiteral(ownerId)}'`,
      OrderBy: 'AVCurrent DESC',
      MaxRows: PARCEL_ROW_CAP + 1,
      ResultType: 'simple',
    };
  }

  /**
   * One opened owner's display-year figures, read live: every parcel of the owner (the subquery keys on the
   * portfolio, so the filter never carries a parcel list), the two display years, figures only (a NULL total is no
   * figure), +1 row as the tripwire.
   */
  public static ParcelYearsQuery(ownerId: string, years: DisplayYears): RunViewParams {
    const owner = escapeSqlLiteral(ownerId);
    return {
      EntityName: PARCEL_YEAR_HEADLINE_ENTITY,
      Fields: [...PARCEL_YEAR_FIELDS],
      ExtraFilter:
        `ParcelID IN (SELECT ParcelID FROM indiana_tax.OwnerPortfolioParcel WHERE OwnerPortfolioID = '${owner}') `
        + `AND AssessmentYear IN (${Math.trunc(years[0])}, ${Math.trunc(years[1])}) AND HeadlineTotalAV IS NOT NULL`,
      MaxRows: PARCEL_YEAR_ROW_CAP + 1,
      ResultType: 'simple',
    };
  }

  /** The counties named in a run (never a 92-row catalogue read). */
  public static CountyQuery(countyNumbers: readonly number[]): RunViewParams {
    return {
      EntityName: COUNTY_ENTITY,
      Fields: ['CountyNumber', 'Name', 'Slug'],
      ExtraFilter: `CountyNumber IN (${countyNumbers.map((n) => Math.trunc(n)).join(',')})`,
      OrderBy: 'Name',
      MaxRows: 100,
      ResultType: 'simple',
    };
  }

  private static statewideOwners(extraFilter: string): RunViewParams {
    return {
      EntityName: OWNER_PORTFOLIO_ENTITY,
      Fields: [...OWNER_FIELDS, ...STATEWIDE_OWNER_FIELDS],
      ExtraFilter: extraFilter,
      OrderBy: 'AVCurrent DESC',
      MaxRows: STATEWIDE_ROW_CAP + 1,
      ResultType: 'simple',
    };
  }

  // ───── Loads ─────

  /** The one latest run of `scope`, or the reason there isn't one (none published / more than one). */
  public async LoadLatestRun(scope: OwnerProspectsScope): Promise<RunPick> {
    const res = await this.rv.RunView<RawRow>(OwnerProspectsDataAccess.RunQuery(scope));
    if (!res.Success) return { run: null, error: res.ErrorMessage || 'Failed to load the owner-portfolio run.' };
    const rows = res.Results ?? [];
    const pick = latestRunFor(rows, scope);
    if (pick.run) return { run: pick.run, error: null };
    if (rows.length > 0) return { run: null, error: pick.error ?? 'Owner-portfolio run not found.' };
    return {
      run: null,
      error:
        scope === 'Marion'
          ? 'No owner-portfolio run has been published yet. Run scripts/build-owner-portfolios.js.'
          : 'No Statewide owner-portfolio run has been published yet. Run mj-indiana-tax/scripts/build-owner-portfolios-statewide.js.',
    };
  }

  /** The Marion run: all owners with their parcels attached (never capped). */
  public async LoadMarionOwners(runId: string): Promise<OwnersResult> {
    const [ownerRes, parcelRes] = await this.rv.RunViews<RawRow>(OwnerProspectsDataAccess.MarionQueries(runId));
    if (!ownerRes.Success) return { ok: false, error: ownerRes.ErrorMessage || 'Failed to load owners.' };
    if (!parcelRes.Success) return { ok: false, error: parcelRes.ErrorMessage || 'Failed to load parcels.' };
    const byOwner = new Map<string, OwnerParcelRow[]>();
    for (const raw of parcelRes.Results ?? []) {
      const key = String(raw['OwnerPortfolioID']);
      const list = byOwner.get(key) ?? [];
      list.push(mapOwnerParcelRow(raw));
      byOwner.set(key, list);
    }
    const rows = (ownerRes.Results ?? []).map((raw) => {
      const row = mapOwnerPortfolioRow(raw);
      row.parcels = byOwner.get(row.id) ?? [];
      return row;
    });
    return { ok: true, rows, capHit: false };
  }

  /** A Statewide owners page (All or one county). */
  public async LoadOwnersPage(runId: string, countyNumber: number | null): Promise<OwnersResult> {
    return this.loadOwners(OwnerProspectsDataAccess.PageQuery(runId, countyNumber), countyNumber);
  }

  /** The server search past the cap. */
  public async SearchOwners(runId: string, countyNumber: number | null, term: string): Promise<OwnersResult> {
    return this.loadOwners(OwnerProspectsDataAccess.SearchQuery(runId, countyNumber, term), countyNumber);
  }

  private async loadOwners(params: RunViewParams, countyNumber: number | null): Promise<OwnersResult> {
    const res = await this.rv.RunView<RawRow>(params);
    if (!res.Success) return { ok: false, error: res.ErrorMessage || 'Failed to load owners.' };
    const raw = res.Results ?? [];
    const rows = filterByCounty(raw.slice(0, STATEWIDE_ROW_CAP).map(mapOwnerPortfolioRow), countyNumber);
    return { ok: true, rows, capHit: raw.length > STATEWIDE_ROW_CAP };
  }

  /** One opened owner's parcels (top {@link PARCEL_ROW_CAP} by AV). */
  public async LoadParcels(ownerId: string): Promise<ParcelsResult> {
    const res = await this.rv.RunView<RawRow>(OwnerProspectsDataAccess.ParcelsQuery(ownerId));
    if (!res.Success) return { ok: false, error: res.ErrorMessage || 'Failed to load parcels.' };
    const raw = res.Results ?? [];
    return { ok: true, parcels: raw.slice(0, PARCEL_ROW_CAP).map(mapOwnerParcelRow), capHit: raw.length > PARCEL_ROW_CAP };
  }

  /**
   * One opened owner's display-year figures. Past the tripwire it is an error, never a partial map: a parcel whose
   * row was cut would otherwise read as `TBA` / `—` — a false statement about the record.
   */
  public async LoadParcelYears(ownerId: string, years: DisplayYears): Promise<ParcelYearsResult> {
    const res = await this.rv.RunView<RawRow>(OwnerProspectsDataAccess.ParcelYearsQuery(ownerId, years));
    if (!res.Success) return { ok: false, error: res.ErrorMessage || 'Failed to load the parcel year figures.' };
    const rows = res.Results ?? [];
    if (rows.length > PARCEL_YEAR_ROW_CAP) {
      return { ok: false, error: `more than ${PARCEL_YEAR_ROW_CAP.toLocaleString('en-US')} parcel-year figures — too many to show here` };
    }
    return { ok: true, years: mapParcelYearHeadlines(rows) };
  }

  /** The county dropdown for a run (counties with parcels in its `ByCountyJSON`), by name, each with its status chip. */
  public async LoadCountyLookup(byCountyJSON: string | null, years: DisplayYears | null = null): Promise<CountyLookup> {
    const numbers = countyNumbersInRun(byCountyJSON);
    const lookup: CountyLookup = { Options: [], Slugs: {}, Names: {} };
    if (!numbers.length) return lookup;
    const res = await this.rv.RunView<{ CountyNumber: number; Name: string; Slug: string }>(OwnerProspectsDataAccess.CountyQuery(numbers));
    for (const r of res.Success ? (res.Results ?? []) : []) {
      lookup.Slugs[r.CountyNumber] = r.Slug;
      lookup.Names[r.CountyNumber] = r.Name;
    }
    // countyNumbersInRun already parsed it tolerantly (non-empty here); never throw out of loadData (M14).
    let parcelsBy: Record<string, { parcels?: number }> = {};
    try {
      parcelsBy = JSON.parse(byCountyJSON ?? '{}') as Record<string, { parcels?: number }>;
    } catch {
      parcelsBy = {};
    }
    const chips = years ? countyChips(byCountyJSON, years) : {};
    lookup.Options = numbers
      .map((n) => {
        const name = lookup.Names[n] ?? `County ${n}`;
        const parcels = parcelsBy[String(n)]?.parcels ?? 0;
        return { CountyNumber: n, Name: name, Label: `${name} — ${parcels.toLocaleString('en-US')} parcels`, Chip: chips[n] ?? null };
      })
      .sort((a, b) => a.Name.localeCompare(b.Name));
    return lookup;
  }

  /** `OwnerKey → Prospect.ID` for every existing prospect; null when the read fails. */
  public async LoadProspectIdsByKey(): Promise<Map<string, string> | null> {
    const res = await this.rv.RunView<{ ID: string; OwnerKey: string }>({
      EntityName: 'Prospects',
      Fields: ['ID', 'OwnerKey'],
      MaxRows: 20000,
      ResultType: 'simple',
    });
    if (!res.Success) return null;
    return new Map<string, string>((res.Results ?? []).map((r): [string, string] => [r.OwnerKey, r.ID]));
  }
}
