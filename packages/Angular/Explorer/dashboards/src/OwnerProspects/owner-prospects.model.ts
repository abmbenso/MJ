/**
 * Owner Prospects — pure data model.
 *
 * The MJ Explorer port of the `owner-portfolios-view.html` Artifact's data layer.
 * This file is INTENTIONALLY Angular-free and MJ-free: the row types, the pure
 * view-model helpers ported (verbatim in behaviour) from the Artifact generator
 * `gen_owner_portfolios_view.js`, and the parsers that turn `RunView('simple')`
 * rows (plain objects, JSON string columns, `bit` 0/1) into those types. The
 * component (`owner-prospects-dashboard.component.ts`) owns all data access and
 * imports from here.
 *
 * Scope note: Tasks 5 / 6 / 9 append `buildBannerModel`, `buildVisibleRows`, and
 * `buildOwnerProspectsAgentContext` here on top of these interfaces.
 */

import { buildVerifyLink, CountyVerifyLink } from '../PropertySearch/property-search-county';
import { escapeSqlLiteral } from '../PropertySearch/property-search-agent-context';

// ─────────────────────────────────────────────────────────────────────────────
// Entity names — the exact strings CodeGen registered in Task 1
// (packages/GeneratedEntities/src/generated/entity_subclasses.ts,
//  `@RegisterClass(BaseEntity, '…')`).
// ─────────────────────────────────────────────────────────────────────────────

export const OWNER_PORTFOLIO_RUN_ENTITY = 'Owner Portfolio Runs';
export const OWNER_PORTFOLIO_ENTITY = 'Owner Portfolios';
export const OWNER_PORTFOLIO_PARCEL_ENTITY = 'Owner Portfolio Parcels';
export const COUNTY_ENTITY = 'Counties';
/** `indiana_tax.ParcelYearHeadline` — one assessed value per parcel-year (the detail panel reads the display years live). */
export const PARCEL_YEAR_HEADLINE_ENTITY = 'Parcel Year Headlines';

// ─────────────────────────────────────────────────────────────────────────────
// Scope (owner-prospects-statewide, Task 5). A run is either the Marion run
// (fixed 2025→2026 pair, valuation-analysis savings tier) or the Statewide run
// (latest headline pair per parcel, AV tier). `IsLatest` is per scope.
// ─────────────────────────────────────────────────────────────────────────────

export type OwnerProspectsScope = 'Marion' | 'Statewide';
export type TierBasis = 'Savings' | 'AV';

/** The Marion run's county; its parcel rows carry no `CountyNumber`, so verify links fall back to it. */
export const MARION_RUN_COUNTY_NUMBER = 49;
/** Statewide portfolios load at most this many rows per query (top by `AVCurrent`); the query asks for one more as a tripwire. */
export const STATEWIDE_ROW_CAP = 5000;
/** Tooltip on a blank savings cell — exact wording from the controller ruling. */
export const NO_ANALYSIS_TOOLTIP = 'no valuation analysis for this county yet';
/** Marker after a Statewide savings figure: it comes from the owner's Marion parcels only. */
export const MARION_PARCELS_MARKER = 'Marion parcels';
export const MARION_PARCELS_TOOLTIP = "from valuation analyses on this owner's Marion parcels only";
/** Tooltip on the Marion-parcels marker after a Statewide rep status (final-review I3). */
export const MARION_REP_TOOLTIP = "rep status from the Marion PTABOA agendas — this owner's Marion parcels only; no rep data for its other counties";
const REP_NO_DATA = 'No rep data for this county';
/** Parcels per opened Statewide owner: at most this many (the query asks for one more as a tripwire). */
export const PARCEL_ROW_CAP = 5000;
export const PARCEL_CAP_NOTE = 'showing the first 5,000 parcels';
/** Past the row cap, a search term this long re-queries the server by owner label. */
export const SERVER_SEARCH_MIN_CHARS = 3;
/** The Marion run's "no rep" status (a fact); outside Marion the builder writes "No rep data for this county" (an absence of data). */
export const NO_REP_ON_RECORD = 'No rep on record';

// ─────────────────────────────────────────────────────────────────────────────
// Row / view-model types
// ─────────────────────────────────────────────────────────────────────────────

/** Owner classifier — mirrors the `OwnerPortfolio.Kind` CHECK constraint. Only `Company` owners get a prospect `tier`. */
export type OwnerKind = 'Company' | 'Individual' | 'Government' | 'Institution';

/** One parcel within an owner group. All nullable numbers/strings as in the DB. */
export interface OwnerParcelRow {
  id: string;
  gisParcelNumber: string;
  address: string | null;
  typeGroup: string | null;
  currentAV: number | null;
  av2025: number | null;
  av2026: number | null;
  avYoYPct: number | null;
  units: number | null;
  sqft: number | null;
  ask: number | null;
  estSavingsAtAsk: number | null;
  estSavingsAtFloor: number | null;
  rec: string | null;
  conf: string | null;
  supCount: number | null;
  appealed: boolean;
  existingRep: string | null;
  lastAppealYear: number | null;
  // ── Statewide columns (absent / null on the Marion run) ──
  /** `indiana_tax.Parcel.ID` — the reliable link key statewide (GIS numbers repeat across counties). */
  parcelId?: string | null;
  /** The 18-digit state parcel number (`Parcel` view column) — what non-Marion verify links key on. */
  parcelNumber?: string | null;
  countyNumber?: number | null;
  priorYear?: number | null;
  currentYear?: number | null;
  avPrior?: number | null;
  avCurrent?: number | null;
  /** AVCurrent comes from the DLGF roll only (no county document for that year). */
  isPlaceholder?: boolean;
  sqftSource?: string | null;
  appealLevel?: string | null;
}

/**
 * One display year's figures over a set of parcels (the builder's `YearFigure`): Σ AV, how many parcels have a
 * figure for that year, and how many of those are the DLGF roll (`IsPlaceholder = 1`). A year with no figure is
 * absent from the map — never written as 0.
 */
export interface YearFigure {
  av: number;
  parcels: number;
  roll: number;
}

/**
 * The fixed pair over the run's two display years (the builder's `YearPair`): parcels with both figures and a
 * positive prior are the YoY base; a $0 prior is `newFromZero` (out of the base). `newFromZero` / `avNewFromZero`
 * read as 0 on a run written before they existed.
 */
export interface YearPair {
  prior: number;
  current: number;
  parcelsBoth: number;
  avPriorBoth: number;
  avCurrentBoth: number;
  newFromZero: number;
  avNewFromZero: number;
  yoyPct: number | null;
}

/** The run's two display years, older first — data from the run, never literals in the screen. */
export type DisplayYears = readonly [number, number];

/** One owner's slice of one county (`OwnerPortfolio.ByCountyJSON` value). */
export interface OwnerCountySlice {
  parcels: number;
  avCurrent: number;
  /** Σ prior over this county's paired (non-placeholder on both years) parcels. */
  avPrior: number | null;
  /** How many of this county's parcels are paired; null on runs written before 2026-09-28's fix round. */
  pairedParcels?: number | null;
  /** Per display year (`"2025"`); absent on runs written before the fixed-years run (2026-09-28 evening). */
  years?: Record<string, YearFigure>;
  /** The fixed pair over the display years; absent on older runs. */
  pair?: YearPair | null;
}

/** The flattened per-owner view-model consumed by the banner, table, and detail panel. */
export interface OwnerRow {
  id: string;
  ownerKey: string;
  label: string;
  kind: OwnerKind;
  tier: string | null;
  parcelCount: number;
  distinctEntities: number | null;
  totalAV: number | null;
  totalAV2025: number | null;
  totalAV2026: number | null;
  avYoYDollars: number | null;
  avYoYPct: number | null;
  parcelsUp10: number | null;
  parcelsUp25: number | null;
  totalUnits: number | null;
  totalSqFt: number | null;
  nAppealRec: number | null;
  nTwoSupport: number | null;
  nHighConfAppeal: number | null;
  estSavingsAtAsk: number | null;
  estSavingsAtFloor: number | null;
  appealedParcels: number | null;
  historicalReductionWon: number | null;
  appealYears: string | null;
  likelyRep: string | null;
  repStatus: string;
  repsOnReduction: string[];
  isFreshProspect: boolean;
  mailAddress: string | null;
  coStarTrueOwner: string | null;
  byType: Record<string, { n: number; av: number }>;
  dominantType: string | null;
  parcels: OwnerParcelRow[];
  /** Set by the Prospect-match query (Task 8) — null until an existing `indiana_tax.Prospect` row is found. */
  prospectId: string | null;
  // ── Statewide columns (absent / null on the Marion run) ──
  primaryCountyNumber?: number | null;
  countyCount?: number | null;
  /** County number (as a string key, the builder's JSON shape) → this owner's slice of that county. */
  byCounty?: Record<string, OwnerCountySlice>;
  /** Σ AVPrior over the paired parcels (non-placeholder on both years) — exactly the YoY base, not the whole portfolio. */
  avPrior?: number | null;
  avCurrent?: number | null;
  pairYears?: string | null;
  tierBasis?: TierBasis | null;
  groupKeyType?: string | null;
  /** `OwnerPortfolio.MostRecentAppealYear` (the export's "Last appeal year"). */
  mostRecentAppealYear?: number | null;
  // ── Fixed display years (set by {@link annotateOwnerYears}; the sortable year columns) ──
  /** Σ AV for the older display year; null = no parcel has a figure (the cell shows `—`). */
  avYear1?: number | null;
  /** Σ AV for the newest display year; null = no parcel has a figure (the cell shows `TBA`). */
  avYear2?: number | null;
  /** YoY % over the parcels with both display years (roll included), one decimal; null = no pair. */
  yoyPair?: number | null;
  /** Share of the newest display-year AV in parcels with both years (see {@link ownerYearSummary}); null = no pair. */
  completeness?: number | null;
  /** Σ prior-year AV of the YoY base (the pair's avPriorBoth); drives the ranking's materiality floor. */
  avPriorBoth?: number | null;
}

/** County-wide C&I 2025→2026 assessed-value rollup for the banner. */
export interface CountyRollup {
  parcels: number;
  totalAV2025: number;
  totalAV2026: number;
  yoyDollars: number;
  yoyPct: number;
  parcelsUp5: number;
  parcelsUp10: number;
  parcelsUp25: number;
  parcelsUp50: number;
  parcelsDown: number;
  byType: Record<string, { n: number; av2025: number; av2026: number; yoyPct: number | null }>;
  /** ISO date the source run was computed (for the provenance footer); null when the run row omits it. */
  runDate: string | null;
  /** Methodology version stamp of the source run (for the provenance footer); null when absent. */
  methodologyVersion: string | null;
}

/** The banner view-model — pre-formatted strings the template renders verbatim. */
export interface BannerModel {
  av2025: string;
  av2026: string;
  yoyPct: string;
  yoyLine: string;
  breakChips: { label: string; value: string }[];
}

/** The dashboard's filter state. */
export interface OwnerProspectsFilters {
  /** Savings tiers (Marion run) or AV tiers A–D (Statewide run). */
  tier: 'all' | 'Prime' | 'Strong' | 'Moderate' | 'A' | 'B' | 'C' | 'D';
  rep: '' | 'none' | 'has';
  hasAppealHistory: boolean;
  typeGroup: string;
  minOppPerYear: number;
  query: string;
}

export const DEFAULT_OWNER_PROSPECTS_FILTERS: OwnerProspectsFilters = {
  tier: 'all',
  rep: '',
  hasAppealHistory: false,
  typeGroup: '',
  minOppPerYear: 0,
  query: '',
};

/**
 * Coerce an untrusted blob (a persisted, possibly stale/corrupt
 * `mj.ownerProspects.filters.v1`) into a valid {@link OwnerProspectsFilters}.
 * Every field falls back to its {@link DEFAULT_OWNER_PROSPECTS_FILTERS} value
 * when out of range — a bogus `tier`/`rep` would otherwise render an empty table
 * with no UI to recover short of Reset.
 */
const KNOWN_TIERS: ReadonlySet<string> = new Set(['Prime', 'Strong', 'Moderate', 'A', 'B', 'C', 'D']);

export function sanitizeFilters(raw: unknown): OwnerProspectsFilters {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>;
  const tier = r['tier'];
  const rep = r['rep'];
  const minOpp = Number(r['minOppPerYear']);
  return {
    tier: typeof tier === 'string' && KNOWN_TIERS.has(tier) ? (tier as OwnerProspectsFilters['tier']) : 'all',
    rep: rep === 'none' || rep === 'has' ? rep : '',
    hasAppealHistory: r['hasAppealHistory'] === true,
    typeGroup: typeof r['typeGroup'] === 'string' ? r['typeGroup'] : '',
    minOppPerYear: Number.isFinite(minOpp) && minOpp >= 0 ? minOpp : 0,
    query: typeof r['query'] === 'string' ? r['query'] : '',
  };
}

/** Banner totals — summed over Company-kind rows (mirrors `gen_owner_portfolios_view.js` `totals`). */
export interface OwnerProspectsSummary {
  companyOwners: number;
  parcels: number;
  totalAV: number;
  oppAsk: number;
  oppFloor: number;
  freshOpp: number;
  prime: number;
  strong: number;
}

export type OwnerSortKey =
  | 'label'
  | 'tier'
  | 'parcelCount'
  | 'totalAV2025'
  | 'totalAV2026'
  | 'avYoYPct'
  | 'totalUnits'
  | 'nAppealRec'
  | 'estSavingsAtAsk'
  | 'estSavingsAtFloor'
  | 'historicalReductionWon'
  | 'appealYears'
  | 'repStatus'
  | 'avPrior'
  | 'avCurrent'
  | 'countyCount'
  | 'avYear1'
  | 'avYear2'
  | 'yoyPair'
  | 'completeness';

/**
 * Every valid {@link OwnerSortKey}, as a runtime set — used to reject a stale or
 * corrupt persisted `mj.ownerProspects.sort.v1` blob before it reaches
 * {@link sortOwnerRows} (an unknown key silently produces an unsorted table with
 * no UI to clear it). Keep in lockstep with the `OwnerSortKey` union above.
 */
export const KNOWN_SORT_KEYS: ReadonlySet<OwnerSortKey> = new Set<OwnerSortKey>([
  'label',
  'tier',
  'parcelCount',
  'totalAV2025',
  'totalAV2026',
  'avYoYPct',
  'totalUnits',
  'nAppealRec',
  'estSavingsAtAsk',
  'estSavingsAtFloor',
  'historicalReductionWon',
  'appealYears',
  'repStatus',
  'avPrior',
  'avCurrent',
  'countyCount',
  'avYear1',
  'avYear2',
  'yoyPair',
  'completeness',
]);

const STRING_SORT_KEYS: ReadonlySet<OwnerSortKey> = new Set<OwnerSortKey>(['label', 'tier', 'appealYears', 'repStatus']);

// ─────────────────────────────────────────────────────────────────────────────
// Formatters + URLs (ported from `gen_owner_portfolios_view.js`)
// ─────────────────────────────────────────────────────────────────────────────

/** `$1.23B` / `$3.4M` / `$12,345` / `—` (mirrors the Artifact `money()`). */
export function formatMoneyShort(n: number | null): string {
  if (n == null) return '—';
  if (n >= 1e9) return `$${(n / 1e9).toFixed(2)}B`;
  if (n >= 1e6) return `$${(n / 1e6).toFixed(1)}M`;
  return `$${Math.round(n).toLocaleString('en-US')}`;
}

/** `$12,345` / `$0` / `—` (mirrors `fmtK` / `fmt0` where non-abbreviated). */
export function formatMoneyOrDash(n: number | null): string {
  return n == null || n === 0 ? (n === 0 ? '$0' : '—') : `$${Math.round(n).toLocaleString('en-US')}`;
}

/** The type bucket with the largest `av`. */
export function dominantType(byType: Record<string, { n: number; av: number }>): string | null {
  let best: string | null = null;
  let bestAv = -1;
  for (const [k, v] of Object.entries(byType ?? {})) {
    if ((v?.av ?? 0) > bestAv) {
      bestAv = v.av ?? 0;
      best = k;
    }
  }
  return best;
}

const PRC_BASE = 'https://maps.indy.gov/AssessorPropertyCards.Reports.Service/ReportPage.aspx?ParcelNumber=';
const TH_BASE = 'https://maps.indy.gov/AssessorPropertyCards.Reports.Service/TaxHistoryReportPage.aspx?ParcelNumber=';

/** Marion County Assessor Property Record Card report for a 7-digit GIS parcel number. */
export const prcUrl = (gis: string): string => PRC_BASE + encodeURIComponent(gis);

/** Marion County tax-history report for a 7-digit GIS parcel number. */
export const taxHistoryUrl = (gis: string): string => TH_BASE + encodeURIComponent(gis);

// ─────────────────────────────────────────────────────────────────────────────
// Pure list operations (mirrors the Artifact `filtered()` / `sorted()` / `totals`)
// ─────────────────────────────────────────────────────────────────────────────

/** `completeOnly` (Statewide, `?complete=`) keeps owners whose YoY covers their portfolio ({@link isCompleteRow}). */
export function filterOwnerRows(rows: OwnerRow[], f: OwnerProspectsFilters, completeOnly = false): OwnerRow[] {
  const q = f.query.trim().toLowerCase();
  return rows.filter((o) => {
    if (completeOnly && !isCompleteRow(o)) return false;
    if (f.tier !== 'all' && o.tier !== f.tier) return false;
    if (f.rep === 'none' && o.repStatus !== 'No rep on record') return false;
    if (f.rep === 'has' && o.repStatus === 'No rep on record') return false;
    if (f.hasAppealHistory && !(o.appealedParcels && o.appealedParcels > 0)) return false;
    if (f.typeGroup && o.dominantType !== f.typeGroup) return false;
    if (f.minOppPerYear && !((o.estSavingsAtAsk ?? 0) >= f.minOppPerYear)) return false;
    if (q && !(o.label.toLowerCase().includes(q) || (o.likelyRep ?? '').toLowerCase().includes(q))) return false;
    return true;
  });
}

export function sortOwnerRows(rows: OwnerRow[], key: OwnerSortKey, dir: 1 | -1): OwnerRow[] {
  const isString = STRING_SORT_KEYS.has(key);
  return rows
    .map((r, i) => ({ r, i }))
    .sort((x, y) => {
      const a = x.r[key];
      const b = y.r[key];
      if (a == null && b == null) return x.i - y.i;
      if (a == null) return 1; // nulls last, both directions
      if (b == null) return -1;
      if (key === 'yoyPair') {
        // Three tiers, both directions: complete with a material base, complete on a small base, incomplete.
        const ta = yoyRankTier(x.r);
        const tb = yoyRankTier(y.r);
        if (ta !== tb) return ta - tb;
      }
      if (isString) return dir * String(a).localeCompare(String(b)) || x.i - y.i;
      return dir * ((a as number) - (b as number)) || x.i - y.i;
    })
    .map((w) => w.r);
}

/**
 * The table's visible-row pipeline: {@link filterOwnerRows} then
 * {@link sortOwnerRows}. Pure — never mutates `all` (both helpers copy).
 * The component's `recomputeVisibleRows()` is a thin call to this.
 */
export function buildVisibleRows(
  all: OwnerRow[],
  f: OwnerProspectsFilters,
  sortKey: OwnerSortKey,
  sortDir: 1 | -1,
  completeOnly = false,
): OwnerRow[] {
  return sortOwnerRows(filterOwnerRows(all, f, completeOnly), sortKey, sortDir);
}

export function computeOwnerProspectsSummary(companyRows: OwnerRow[]): OwnerProspectsSummary {
  const co = companyRows.filter((o) => o.kind === 'Company');
  return {
    companyOwners: co.length,
    parcels: co.reduce((s, o) => s + o.parcelCount, 0),
    totalAV: co.reduce((s, o) => s + (o.totalAV ?? 0), 0),
    oppAsk: co.reduce((s, o) => s + (o.estSavingsAtAsk ?? 0), 0),
    oppFloor: co.reduce((s, o) => s + (o.estSavingsAtFloor ?? 0), 0),
    freshOpp: co.filter((o) => o.isFreshProspect).reduce((s, o) => s + (o.estSavingsAtAsk ?? 0), 0),
    prime: co.filter((o) => o.tier === 'Prime').length,
    strong: co.filter((o) => o.tier === 'Strong').length,
  };
}

/** Signed percent string: `+15.2%` / `0%` / `-4.1%`; `—` when the pct is null. */
function signedPct(pct: number | null): string {
  if (pct == null) return '—';
  return (pct > 0 ? '+' : '') + pct + '%';
}

/**
 * The Marion County C&I year-over-year banner view-model.
 * Money via {@link formatMoneyShort}; `breakChips` = the top 4 `byType` buckets by 2026 AV.
 */
export function buildBannerModel(cr: CountyRollup): BannerModel {
  const breakChips = Object.entries(cr.byType)
    .sort((a, b) => b[1].av2026 - a[1].av2026)
    .slice(0, 4)
    .map(([label, v]) => ({ label, value: signedPct(v.yoyPct) }));
  return {
    av2025: formatMoneyShort(cr.totalAV2025),
    av2026: formatMoneyShort(cr.totalAV2026),
    yoyPct: (cr.yoyPct > 0 ? '+' : '') + cr.yoyPct + '%',
    yoyLine: `${formatMoneyShort(cr.yoyDollars)} · ${cr.parcels.toLocaleString('en-US')} parcels`,
    breakChips,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Agent context (Task 9) — pure, Angular-free snapshot the dashboard publishes
// via NavigationService.SetAgentContext. See the SAFETY BOUNDARY comment in
// owner-prospects-dashboard.component.ts for what the paired tools may do.
// ─────────────────────────────────────────────────────────────────────────────

/** The dashboard state {@link buildOwnerProspectsAgentContext} consumes — the component projects `this.*` onto this. */
export interface OwnerProspectsAgentContextState {
  runDate: string | null;
  methodologyVersion: string | null;
  companyOwnerCount: number;
  /** The visible table rows — only `label` is read (for the bounded {@link TOP_VISIBLE_OWNER_LABELS_CAP} list). */
  visibleRows: readonly Pick<OwnerRow, 'label'>[];
  summary: OwnerProspectsSummary | null;
  filters: OwnerProspectsFilters;
  sortKey: OwnerSortKey;
  sortDir: 1 | -1;
  selectedOwnerLabel: string | null;
  selectedOwnerIsFlagged: boolean;
  countyYoYPct: number | null;
  /** Which run is on screen; absent = Marion (the default scope). */
  scope?: OwnerProspectsScope;
  /** The selected county's name in Statewide scope; null = all counties. */
  county?: string | null;
  /** What the tier column ranks on for the loaded run ('Savings' | 'AV'); null when unknown. */
  tierBasis?: TierBasis | null;
  /** The run's two display years (older first); null when the run carries none. */
  displayYears?: DisplayYears | null;
  /** Statewide: the effective "Complete YoY only" filter; null outside Statewide. */
  completeOnly?: boolean | null;
}

/** Upper bound on the streamed `TopVisibleOwnerLabels` list; `TopVisibleOwnerLabelsCount` carries the true total past this. */
export const TOP_VISIBLE_OWNER_LABELS_CAP = 25;

/**
 * Builds the ~18-field agent-context object the Owner Prospects dashboard
 * publishes. Pure — no Angular / MJ imports. Emits only the named, non-opaque
 * fields below (no raw ids, no `prospectId`, no `ownerKey`, no secrets);
 * `TopVisibleOwnerLabels` is bounded at {@link TOP_VISIBLE_OWNER_LABELS_CAP}
 * with a companion `TopVisibleOwnerLabelsCount` emitted ONLY when the visible
 * set exceeds the cap.
 */
export function buildOwnerProspectsAgentContext(state: OwnerProspectsAgentContextState): Record<string, unknown> {
  const labels = state.visibleRows.slice(0, TOP_VISIBLE_OWNER_LABELS_CAP).map((r) => r.label);
  const ctx: Record<string, unknown> = {
    RunDate: state.runDate,
    MethodologyVersion: state.methodologyVersion,
    CompanyOwnerCount: state.companyOwnerCount,
    VisibleOwnerCount: state.visibleRows.length,
    TotalOpportunityAtAsk: state.summary?.oppAsk ?? null,
    FreshOpportunityAtAsk: state.summary?.freshOpp ?? null,
    // Prime/Strong are savings tiers: absent (null, not 0) on the AV basis.
    PrimeCount: state.tierBasis === 'AV' ? null : (state.summary?.prime ?? null),
    StrongCount: state.tierBasis === 'AV' ? null : (state.summary?.strong ?? null),
    TierFilter: state.filters.tier,
    RepFilter: state.filters.rep,
    TypeFilter: state.filters.typeGroup,
    MinOppPerYear: state.filters.minOppPerYear,
    SearchQuery: state.filters.query,
    SortKey: state.sortKey,
    SortDir: state.sortDir === 1 ? 'asc' : 'desc',
    SelectedOwnerLabel: state.selectedOwnerLabel,
    SelectedOwnerIsFlagged: state.selectedOwnerIsFlagged,
    CountyYoYPct: state.countyYoYPct,
    Scope: state.scope ?? 'Marion',
    County: state.county ?? null,
    TierBasis: state.tierBasis ?? null,
    DisplayYears: state.displayYears ? [...state.displayYears] : null,
    CompleteOnly: state.completeOnly ?? null,
    // What the opportunity figures cover: on the AV basis only the owner's Marion parcels were analysed.
    OpportunityBasis: state.tierBasis === 'AV' ? 'Marion parcels only' : 'Marion valuation analysis',
    TopVisibleOwnerLabels: labels,
  };
  if (state.visibleRows.length > TOP_VISIBLE_OWNER_LABELS_CAP) {
    ctx['TopVisibleOwnerLabelsCount'] = state.visibleRows.length;
  }
  return ctx;
}

// ─────────────────────────────────────────────────────────────────────────────
// RunView('simple') row coercion helpers
// ─────────────────────────────────────────────────────────────────────────────

type RawRow = Record<string, unknown>;

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

/** `null`/`''`/non-numeric → null; anything else coerced with `Number()`. */
function toNum(v: unknown): number | null {
  if (v == null || v === '') return null;
  const n = typeof v === 'number' ? v : Number(v);
  return Number.isFinite(n) ? n : null;
}

/** `null` → null; otherwise trimmed string, or null when the trim is empty. */
function toStr(v: unknown): string | null {
  if (v == null) return null;
  const s = String(v).trim();
  return s === '' ? null : s;
}

/** `bit` column: `1`/`'1'`/`true`/`'true'` → true, everything else → false. */
function toBool(v: unknown): boolean {
  return v === true || v === 1 || v === '1' || v === 'true';
}

/** Parse a JSON string column into an object; `{}` on absent/blank/malformed input. */
function parseJsonObject(v: unknown): Record<string, unknown> {
  if (isRecord(v)) return v;
  if (typeof v === 'string' && v.trim() !== '') {
    try {
      const parsed: unknown = JSON.parse(v);
      if (isRecord(parsed)) return parsed;
    } catch {
      return {};
    }
  }
  return {};
}

const OWNER_KINDS: ReadonlySet<string> = new Set<string>(['Company', 'Individual', 'Government', 'Institution']);

function toOwnerKind(v: unknown): OwnerKind {
  const s = toStr(v);
  return s != null && OWNER_KINDS.has(s) ? (s as OwnerKind) : 'Company';
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-entity parsers (one function each; kept ≤ ~40 lines)
// ─────────────────────────────────────────────────────────────────────────────

/** `OwnerPortfolio.ByTypeJSON` → `{ [type]: { n, av } }`. */
function parseOwnerByType(v: unknown): Record<string, { n: number; av: number }> {
  const out: Record<string, { n: number; av: number }> = {};
  for (const [k, raw] of Object.entries(parseJsonObject(v))) {
    const bucket = isRecord(raw) ? raw : {};
    out[k] = { n: toNum(bucket['n']) ?? 0, av: toNum(bucket['av']) ?? 0 };
  }
  return out;
}

/** `ByCountyJSON[c].years` → `{ "2025": YearFigure }`; undefined when the slice carries none (an older run). */
function parseYearFigures(v: unknown): Record<string, YearFigure> | undefined {
  if (!isRecord(v) || Array.isArray(v)) return undefined;
  const out: Record<string, YearFigure> = {};
  for (const [year, raw] of Object.entries(v)) {
    if (!isRecord(raw)) continue;
    out[year] = { av: toNum(raw['av']) ?? 0, parcels: toNum(raw['parcels']) ?? 0, roll: toNum(raw['roll']) ?? 0 };
  }
  return out;
}

/** `ByCountyJSON[c].pair` → {@link YearPair} (newFromZero / avNewFromZero default 0); undefined when absent. */
function parseYearPair(v: unknown): YearPair | null | undefined {
  if (v === null) return null;
  if (!isRecord(v)) return undefined;
  return {
    prior: toNum(v['prior']) ?? 0,
    current: toNum(v['current']) ?? 0,
    parcelsBoth: toNum(v['parcelsBoth']) ?? 0,
    avPriorBoth: toNum(v['avPriorBoth']) ?? 0,
    avCurrentBoth: toNum(v['avCurrentBoth']) ?? 0,
    newFromZero: toNum(v['newFromZero']) ?? 0,
    avNewFromZero: toNum(v['avNewFromZero']) ?? 0,
    yoyPct: toNum(v['yoyPct']),
  };
}

/** `OwnerPortfolio.ByCountyJSON` → `{ [countyNumber]: { parcels, avCurrent, avPrior, pairedParcels, years, pair } }`. */
function parseOwnerByCounty(v: unknown): Record<string, OwnerCountySlice> {
  const out: Record<string, OwnerCountySlice> = {};
  for (const [k, raw] of Object.entries(parseJsonObject(v))) {
    const b = isRecord(raw) ? raw : {};
    out[k] = {
      parcels: toNum(b['parcels']) ?? 0,
      avCurrent: toNum(b['avCurrent']) ?? 0,
      avPrior: toNum(b['avPrior']),
      pairedParcels: toNum(b['pairedParcels']),
      years: parseYearFigures(b['years']),
      pair: parseYearPair(b['pair']),
    };
  }
  return out;
}

function toTierBasis(v: unknown): TierBasis | null {
  const s = toStr(v);
  return s === 'Savings' || s === 'AV' ? s : null;
}

/** One representative name out of a string / `{ rep|name|representative }` element. */
function repNameOf(el: unknown): string {
  if (typeof el === 'string') return el;
  if (isRecord(el)) return String(el['rep'] ?? el['name'] ?? el['representative'] ?? '');
  return String(el);
}

/**
 * `OwnerPortfolio.RepsOnReductionJSON` → the list of representative names (display-only).
 * The persisted shape is `JSON.stringify(owner.repsOnReduction)` — a string array
 * (`'["Faegre Drinker","Ryan LLC"]'`). Also tolerates an array of `{ rep }` objects,
 * a `{ reps: [...] }` wrapper, and a legacy keyed `{ name: {...} }` object-map.
 */
function parseRepsOnReduction(v: unknown): string[] {
  let parsed: unknown = v;
  if (typeof v === 'string') {
    if (v.trim() === '') return [];
    try {
      parsed = JSON.parse(v);
    } catch {
      return [];
    }
  }
  if (Array.isArray(parsed)) return parsed.map(repNameOf).filter((s) => s !== '');
  if (isRecord(parsed)) {
    if (Array.isArray(parsed['reps'])) return parsed['reps'].map(repNameOf).filter((s) => s !== '');
    return Object.keys(parsed);
  }
  return [];
}

/** `Owner Portfolio Runs` (latest) → the banner `CountyRollup`. */
export function mapCountyRollup(raw: RawRow): CountyRollup {
  const byType: CountyRollup['byType'] = {};
  for (const [k, v] of Object.entries(parseJsonObject(raw['CountyByTypeJSON']))) {
    const b = isRecord(v) ? v : {};
    byType[k] = {
      n: toNum(b['n']) ?? 0,
      av2025: toNum(b['av2025']) ?? 0,
      av2026: toNum(b['av2026']) ?? 0,
      yoyPct: toNum(b['yoyPct']),
    };
  }
  return {
    parcels: toNum(raw['CountyParcelCount']) ?? 0,
    totalAV2025: toNum(raw['CountyTotalAV2025']) ?? 0,
    totalAV2026: toNum(raw['CountyTotalAV2026']) ?? 0,
    yoyDollars: toNum(raw['CountyYoYDollars']) ?? 0,
    yoyPct: toNum(raw['CountyYoYPct']) ?? 0,
    parcelsUp5: toNum(raw['CountyParcelsUp5']) ?? 0,
    parcelsUp10: toNum(raw['CountyParcelsUp10']) ?? 0,
    parcelsUp25: toNum(raw['CountyParcelsUp25']) ?? 0,
    parcelsUp50: toNum(raw['CountyParcelsUp50']) ?? 0,
    parcelsDown: toNum(raw['CountyParcelsDown']) ?? 0,
    byType,
    runDate: toStr(raw['RunDate']),
    methodologyVersion: toStr(raw['MethodologyVersion']),
  };
}

/** One `Owner Portfolio Parcels` row → `OwnerParcelRow`. */
export function mapOwnerParcelRow(raw: RawRow): OwnerParcelRow {
  return {
    id: String(raw['ID'] ?? ''),
    // Nullable since mj-indiana-tax migration V202609281100 (some counties' files carry no GIS number).
    gisParcelNumber: String(raw['GISParcelNumber'] ?? ''),
    address: toStr(raw['Address']),
    typeGroup: toStr(raw['TypeGroup']),
    currentAV: toNum(raw['CurrentAV']),
    av2025: toNum(raw['AV2025']),
    av2026: toNum(raw['AV2026']),
    avYoYPct: toNum(raw['AVYoYPct']),
    units: toNum(raw['Units']),
    sqft: toNum(raw['SqFt']),
    ask: toNum(raw['AskValue']),
    estSavingsAtAsk: toNum(raw['EstSavingsAtAsk']),
    estSavingsAtFloor: toNum(raw['EstSavingsAtFloor']),
    rec: toStr(raw['Recommendation']),
    conf: toStr(raw['ConfidenceTier']),
    supCount: toNum(raw['SupportingApproachCount']),
    appealed: toBool(raw['Appealed']),
    existingRep: toStr(raw['ExistingRep']),
    lastAppealYear: toNum(raw['LastAppealYear']),
    parcelId: toStr(raw['ParcelID']),
    parcelNumber: toStr(raw['Parcel']),
    countyNumber: toNum(raw['CountyNumber']),
    priorYear: toNum(raw['PriorYear']),
    currentYear: toNum(raw['CurrentYear']),
    avPrior: toNum(raw['AVPrior']),
    avCurrent: toNum(raw['AVCurrent']),
    isPlaceholder: toBool(raw['IsPlaceholder']),
    sqftSource: toStr(raw['SqFtSource']),
    appealLevel: toStr(raw['AppealLevel']),
  };
}

/** One `Owner Portfolios` row → `OwnerRow` (`parcels` is filled in by the component). */
export function mapOwnerPortfolioRow(raw: RawRow): OwnerRow {
  const byType = parseOwnerByType(raw['ByTypeJSON']);
  return {
    id: String(raw['ID'] ?? ''),
    ownerKey: String(raw['OwnerKey'] ?? ''),
    label: String(raw['Label'] ?? ''),
    kind: toOwnerKind(raw['Kind']),
    tier: toStr(raw['Tier']),
    parcelCount: toNum(raw['ParcelCount']) ?? 0,
    distinctEntities: toNum(raw['DistinctEntities']),
    totalAV: toNum(raw['TotalAV']),
    totalAV2025: toNum(raw['TotalAV2025']),
    totalAV2026: toNum(raw['TotalAV2026']),
    avYoYDollars: toNum(raw['AVYoYDollars']),
    avYoYPct: toNum(raw['AVYoYPct']),
    parcelsUp10: toNum(raw['ParcelsUp10']),
    parcelsUp25: toNum(raw['ParcelsUp25']),
    totalUnits: toNum(raw['TotalUnits']),
    totalSqFt: toNum(raw['TotalSqFt']),
    nAppealRec: toNum(raw['NAppealRec']),
    nTwoSupport: toNum(raw['NTwoSupport']),
    nHighConfAppeal: toNum(raw['NHighConfAppeal']),
    estSavingsAtAsk: toNum(raw['EstSavingsAtAsk']),
    estSavingsAtFloor: toNum(raw['EstSavingsAtFloor']),
    appealedParcels: toNum(raw['AppealedParcels']),
    historicalReductionWon: toNum(raw['HistoricalReductionWon']),
    appealYears: toStr(raw['AppealYears']),
    likelyRep: toStr(raw['LikelyRep']),
    repStatus: String(raw['RepStatus'] ?? ''),
    repsOnReduction: parseRepsOnReduction(raw['RepsOnReductionJSON']),
    isFreshProspect: toBool(raw['IsFreshProspect']),
    mailAddress: toStr(raw['MailAddress']),
    coStarTrueOwner: toStr(raw['CoStarTrueOwner']),
    byType,
    dominantType: dominantType(byType),
    parcels: [],
    prospectId: null,
    primaryCountyNumber: toNum(raw['PrimaryCountyNumber']),
    countyCount: toNum(raw['CountyCount']),
    byCounty: parseOwnerByCounty(raw['ByCountyJSON']),
    avPrior: toNum(raw['AVPrior']),
    avCurrent: toNum(raw['AVCurrent']),
    pairYears: toStr(raw['PairYears']),
    tierBasis: toTierBasis(raw['TierBasis']),
    groupKeyType: toStr(raw['GroupKeyType']),
    mostRecentAppealYear: toNum(raw['MostRecentAppealYear']),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Statewide scope (owner-prospects-statewide, Task 5) — run pick, county
// filter, honest empties, YoY floor, per-county banner, verify links.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * The one latest run of `scope` out of the `IsLatest = 1 AND Scope = …` query
 * (which asks for 2 rows as a tripwire). Two latest runs of one scope is an
 * error, never a silent pick.
 */
export function latestRunFor(runs: readonly RawRow[], scope: OwnerProspectsScope): { run: RawRow | null; error: string | null } {
  const hits = runs.filter((r) => toStr(r['Scope']) === scope && toBool(r['IsLatest']));
  if (hits.length === 1) return { run: hits[0], error: null };
  if (hits.length === 0) {
    return { run: null, error: `No ${scope} owner-portfolio run has been published yet.` };
  }
  return {
    run: null,
    error: `${hits.length} latest ${scope} runs are marked IsLatest — refusing to pick one. Clear IsLatest on the older run(s) in indiana_tax.OwnerPortfolioRun.`,
  };
}

/**
 * Owners under one county: every owner holding parcels there (a multi-county
 * owner appears under each of its counties, via its `ByCountyJSON` keys, else
 * its primary county). `null` = All: every owner exactly once.
 */
export function filterByCounty(rows: readonly OwnerRow[], countyNumber: number | null): OwnerRow[] {
  const seen = new Set<string>();
  const out: OwnerRow[] = [];
  for (const r of rows) {
    if (seen.has(r.id)) continue;
    if (countyNumber != null) {
      const inSlices = r.byCounty ? Object.prototype.hasOwnProperty.call(r.byCounty, String(countyNumber)) : false;
      if (!inSlices && r.primaryCountyNumber !== countyNumber) continue;
    }
    seen.add(r.id);
    out.push(r);
  }
  return out;
}

/**
 * The Statewide portfolio query's `ExtraFilter`. The builder writes
 * `ByCountyJSON` keys as quoted county numbers (`{"45":{…}}`), so `"45":` can
 * never match `"145":` or a value.
 */
export function statewidePortfolioFilter(runId: string, countyNumber: number | null): string {
  const run = `RunID = '${escapeSqlLiteral(runId)}'`;
  if (countyNumber == null) return run;
  const n = Math.trunc(countyNumber);
  return `${run} AND (PrimaryCountyNumber = ${n} OR ByCountyJSON LIKE '%"${n}":%')`;
}

/**
 * A search term as the body of a `LIKE '%…%'` literal: `[`, `%`, `_` bracket-escaped (T-SQL),
 * then quotes doubled by Property Search's `escapeSqlLiteral`. RunView sends ExtraFilter as a
 * GraphQL *variable* (GraphQLDataProvider `RunViewQuery($input)`), so no GraphQL string layer
 * applies on this path.
 */
export function likeContainsLiteral(term: string): string {
  return escapeSqlLiteral(term.replace(/[[%_]/g, (c) => `[${c}]`));
}

/** {@link statewidePortfolioFilter} plus `Label LIKE '%term%'` — the server search past the row cap. */
export function statewideSearchFilter(runId: string, countyNumber: number | null, term: string): string {
  return `${statewidePortfolioFilter(runId, countyNumber)} AND Label LIKE '%${likeContainsLiteral(term.trim())}%'`;
}

/** Server search applies only when the loaded page was capped and the term is long enough. */
export function shouldServerSearch(capHit: boolean, term: string): boolean {
  return capHit && term.trim().length >= SERVER_SEARCH_MIN_CHARS;
}

/** Tier column header — from the stored `TierBasis`, never from the scope. */
export function tierLabel(basis: TierBasis | null | undefined): string {
  if (basis === 'Savings') return 'Savings tier';
  if (basis === 'AV') return 'AV tier';
  return 'Tier';
}

/** The `TierBasis` every loaded row shares; null when none is recorded or rows disagree. */
export function runTierBasis(rows: readonly Pick<OwnerRow, 'tierBasis'>[]): TierBasis | null {
  let basis: TierBasis | null = null;
  for (const r of rows) {
    const b = r.tierBasis ?? null;
    if (b == null) return null;
    if (basis == null) basis = b;
    else if (basis !== b) return null;
  }
  return basis;
}

/** Tier toggle options for a basis: the savings tiers (Marion) or the AV bands A–D (Statewide). */
export function tierOptionsFor(basis: TierBasis | null): { key: OwnerProspectsFilters['tier']; label: string }[] {
  const keys: OwnerProspectsFilters['tier'][] = basis === 'AV' ? ['A', 'B', 'C', 'D'] : ['Prime', 'Strong', 'Moderate'];
  return [{ key: 'all', label: 'All' }, ...keys.map((k) => ({ key: k, label: k }))];
}

/**
 * The rep cell: the stored `RepStatus` verbatim. Only on the Marion basis does "No rep on record"
 * read "— open" (an open prospect in the county whose agendas were read); on a Statewide row the
 * same words are shown as stored.
 */
export function repCell(repStatus: string, basis: TierBasis): { text: string; open: boolean } {
  return basis === 'Savings' && repStatus === NO_REP_ON_RECORD ? { text: '— open', open: true } : { text: repStatus, open: false };
}

/** A row's tier basis: the stored `TierBasis`, else the scope's (the Marion persist wrote none before 2026-09-28). */
export function effectiveTierBasis(basis: TierBasis | null | undefined, scope: OwnerProspectsScope): TierBasis {
  return basis ?? (scope === 'Marion' ? 'Savings' : 'AV');
}

/** True when the owner holds parcels in Marion (the only county with valuation analyses and PTABOA reps). */
export function hasMarionParcels(row: Pick<OwnerRow, 'byCounty'>): boolean {
  return !!row.byCounty && Object.prototype.hasOwnProperty.call(row.byCounty, String(MARION_RUN_COUNTY_NUMBER));
}

/**
 * The "Appeal recs" cell. Marion basis: as always. AV basis: blank with the no-analysis tooltip when the
 * owner has no Marion parcels; otherwise the count, flagged `marionOnly` when non-zero.
 */
export function appealRecsCell(
  n: number | null,
  basis: TierBasis,
  marionParcels: boolean,
): { text: string; tooltip: string | null; marionOnly: boolean } {
  const text = n == null ? '—' : n.toLocaleString('en-US');
  if (basis === 'Savings') return { text, tooltip: null, marionOnly: false };
  if (!marionParcels) return { text: '', tooltip: NO_ANALYSIS_TOOLTIP, marionOnly: false };
  return { text, tooltip: null, marionOnly: n != null && n > 0 };
}

/**
 * True when the owner holds parcels outside Marion AND in Marion: its rep status (read from the Marion PTABOA
 * agendas only) then covers only part of the portfolio and carries the Marion-parcels marker (final-review I3).
 * An owner with no Marion parcel reads "No rep data for this county" — already scoped in its own words.
 */
export function repIsMarionOnly(row: Pick<OwnerRow, 'byCounty' | 'repStatus'>, basis: TierBasis): boolean {
  if (basis !== 'AV' || !row.byCounty || row.repStatus === REP_NO_DATA) return false;
  const counties = Object.keys(row.byCounty);
  return counties.includes(String(MARION_RUN_COUNTY_NUMBER)) && counties.some((c) => c !== String(MARION_RUN_COUNTY_NUMBER));
}

/**
 * Tooltip for a Statewide owner's AV prior/current cells: the assessment years they come from. `PairYears` is the
 * single pair, `mixed`, or (no parcel with both years) the bare current year.
 */
export function pairYearsTooltip(pairYears: string | null | undefined): string {
  if (!pairYears) return 'no assessment year on record';
  if (pairYears === 'mixed') return "mixed assessment years across this owner's parcels — see the parcel list";
  if (/^\d{4}$/.test(pairYears)) return `${pairYears}: current year only — no prior-year figure on the record`;
  return `assessment years ${pairYears}`;
}

/**
 * A savings cell. The Marion run (Savings basis) renders as always. On any other basis a
 * savings figure that exists is shown, flagged `marionOnly` (it covers only the owner's
 * Marion parcels); a null is blank with {@link NO_ANALYSIS_TOOLTIP}.
 */
export function savingsCell(
  value: number | null,
  basis: TierBasis | null | undefined,
): { text: string; tooltip: string | null; marionOnly: boolean } {
  if (basis === 'Savings') return { text: formatMoneyOrDash(value), tooltip: null, marionOnly: false };
  if (value == null) return { text: '', tooltip: NO_ANALYSIS_TOOLTIP, marionOnly: false };
  return { text: formatMoneyOrDash(value), tooltip: null, marionOnly: true };
}

/** County numbers with parcels in a run's `ByCountyJSON`, ascending. */
export function countyNumbersInRun(byCountyJSON: unknown): number[] {
  return Object.entries(parseJsonObject(byCountyJSON))
    .filter(([, v]) => isRecord(v) && (toNum(v['parcels']) ?? 0) > 0)
    .map(([k]) => Number(k))
    .filter((n) => Number.isFinite(n))
    .sort((a, b) => a - b);
}

/**
 * The county-document link for one parcel, through Property Search's
 * {@link buildVerifyLink} (any county, never a Marion-only URL). A parcel with no
 * `CountyNumber` (the Marion run) uses `fallbackCounty`.
 */
export function parcelVerifyLink(
  p: Pick<OwnerParcelRow, 'countyNumber' | 'parcelNumber' | 'gisParcelNumber' | 'currentYear'>,
  slugByCounty: Readonly<Record<number, string>>,
  fallbackCounty: number | null,
): CountyVerifyLink {
  const county = p.countyNumber ?? fallbackCounty;
  if (county == null) return { label: 'Property Record Card', url: null, note: 'not on file — verify at the county' };
  return buildVerifyLink({
    countyNumber: county,
    slug: slugByCounty[county] ?? '',
    parcelNumber: p.parcelNumber ?? null,
    gisParcelNumber: p.gisParcelNumber || null,
    assessmentYear: p.currentYear ?? null,
  });
}

/**
 * The `Prospect.Thesis` for a flag from a Statewide (AV-basis) row. Every Marion-only figure carries its scope on the
 * record (final-review I5/I3): the opportunity (`EstimatedOpportunityAtAsk` keeps the Marion-parcels figure) and a
 * Marion-only rep status; a DLGF-placeholder AV among the attached parcels is noted (no snapshot note column).
 */
export function statewideThesis(row: OwnerRow, parcelCapNote: string | null, years: DisplayYears | null = null): string {
  const counties = row.countyCount ?? 1;
  const opp = row.estSavingsAtAsk == null
    ? ' Opportunity: none claimed — no valuation analysis on this owner\'s parcels.'
    : ` Opportunity = Marion parcels only: ~$${Math.round(row.estSavingsAtAsk).toLocaleString('en-US')}/yr at ask`
      + ' (EstimatedOpportunityAtAsk covers those parcels, not the portfolio).';
  const rep = repIsMarionOnly(row, 'AV') ? `Rep status (Marion parcels only): ${row.repStatus}.` : `Rep status: ${row.repStatus}.`;
  const capped = parcelCapNote ? ` Parcels attached: ${parcelCapNote} of ${row.parcelCount}.` : '';
  return `${row.parcelCount} parcels in ${counties} ${counties === 1 ? 'county' : 'counties'}. ${thesisYears(row, years)} `
    + `AV tier ${row.tier ?? '—'}.${opp} ${rep}${capped}`;
}

/** The thesis' AV sentence, with its years: "AV 2026 $X (n of m parcels); AV 2025 $Y. k parcels TBA for 2026. YoY …". */
function thesisYears(row: OwnerRow, years: DisplayYears | null): string {
  if (!years) return 'AV by assessment year: not on this run.';
  const [y1, y2] = years;
  const s = ownerYearSummary(row, years);
  const dollars = (n: number | null): string => (n == null ? NO_FIGURE_MARK : `$${Math.round(n).toLocaleString('en-US')}`);
  const n2 = s.years[String(y2)]?.parcels ?? 0;
  const av2 = s.avYear2 == null ? `AV ${y2} ${TBA_MARK} (${count(row.parcelCount)})` : `AV ${y2} ${dollars(s.avYear2)} (${n2.toLocaleString('en-US')} of ${row.parcelCount.toLocaleString('en-US')} parcels)`;
  const tba = row.parcelCount - n2;
  const tbaNote = s.hasYearData && tba > 0 && s.avYear2 != null ? ` ${count(tba)} ${TBA_MARK} for ${y2}.` : '';
  const yoy = s.yoyPct == null ? ` No ${y1}→${y2} YoY.` : ` YoY ${s.yoyPct > 0 ? '+' : ''}${s.yoyPct}% over parcels with both years.`;
  return `${av2}; AV ${y1} ${dollars(s.avYear1)}.${tbaNote}${yoy}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixed assessment years (owner-prospects-years-export plan, Task 2 — user direction 2026-09-28).
// Every figure is an assessed value on the record (`ParcelYearHeadline`), never an estimate. A DLGF roll figure
// IS the county's assessed value for that year: shown as a number with the `roll` pill and included in YoY.
// Gaps: `TBA` (To Be Assessed) for the newest display year, `—` for the older one.
// ─────────────────────────────────────────────────────────────────────────────

/** The newest display year with no figure on the record. */
export const TBA_MARK = 'TBA';
/** The older display year with no figure on the record. */
export const NO_FIGURE_MARK = '—';
/** A table cell for one display year: the figure, or the honest gap. */
export type YearCellValue = number | typeof TBA_MARK | typeof NO_FIGURE_MARK;
/** An owner is "complete" when at least this share of its newest display-year AV sits in parcels with both years. */
export const COMPLETE_YOY_THRESHOLD = 0.9;

/** The gap marker for a display year with no figure: `TBA` for the newest, `—` for the older. */
export function gapMark(year: number, years: DisplayYears): typeof TBA_MARK | typeof NO_FIGURE_MARK {
  return year === years[1] ? TBA_MARK : NO_FIGURE_MARK;
}

/** The run's two newest years, older first. */
function twoNewest(years: readonly number[]): DisplayYears | null {
  const sorted = [...new Set(years)].filter((y) => Number.isInteger(y)).sort((a, b) => a - b);
  return sorted.length < 2 ? null : [sorted[sorted.length - 2], sorted[sorted.length - 1]];
}

/**
 * The run's display years: the run-level `ByCountyJSON.years` (the builder writes the years that carry any
 * figure), the newest two. The Marion run carries no `years`; its fixed pair is its `CountyTotalAV<year>` columns
 * (the run's AV2025/AV2026 figures). Null when fewer than two years are on the run — never a guessed pair.
 */
export function displayYears(run: RawRow): DisplayYears | null {
  const listed = parseJsonObject(run['ByCountyJSON'])['years'];
  if (Array.isArray(listed)) {
    const ys = listed.map(toNum).filter((y): y is number => y != null);
    if (ys.length) return twoNewest(ys);
  }
  const fromColumns = Object.keys(run)
    .map((k) => /^CountyTotalAV(\d{4})$/.exec(k))
    .filter((m): m is RegExpExecArray => m != null && toNum(run[m[0]]) != null)
    .map((m) => Number(m[1]));
  return twoNewest(fromColumns);
}

/** One owner's figures over the display years, summed across its county slices. */
export interface OwnerYearSummary {
  /** False when no slice carries per-year figures (the Marion run, or a run before fixed years). */
  hasYearData: boolean;
  years: Record<string, YearFigure>;
  pair: YearPair | null;
  /** Σ AV per display year; null = no parcel has a figure for that year. */
  avYear1: number | null;
  avYear2: number | null;
  yoyPct: number | null;
  /** avCurrentBoth ÷ the portfolio's newest display-year AV (Σ y2 + the y1 AV of parcels with no y2 figure). */
  completeness: number | null;
}

function emptyPair(years: DisplayYears): YearPair {
  return { prior: years[0], current: years[1], parcelsBoth: 0, avPriorBoth: 0, avCurrentBoth: 0, newFromZero: 0, avNewFromZero: 0, yoyPct: null };
}

/** Σ per-year figures and the pair over a set of county slices (an owner's, or a run's). */
function sumSlices(slices: readonly OwnerCountySlice[], years: DisplayYears): { years: Record<string, YearFigure>; pair: YearPair | null; any: boolean } {
  const out: Record<string, YearFigure> = {};
  const pair = emptyPair(years);
  let any = false;
  let anyPair = false;
  for (const s of slices) {
    if (s.years) any = true;
    for (const y of years) {
      const f = s.years?.[String(y)];
      if (!f) continue;
      const slot = out[String(y)] ?? (out[String(y)] = { av: 0, parcels: 0, roll: 0 });
      slot.av += f.av;
      slot.parcels += f.parcels;
      slot.roll += f.roll;
    }
    if (!s.pair) continue;
    anyPair = true;
    pair.parcelsBoth += s.pair.parcelsBoth;
    pair.avPriorBoth += s.pair.avPriorBoth;
    pair.avCurrentBoth += s.pair.avCurrentBoth;
    pair.newFromZero += s.pair.newFromZero;
    pair.avNewFromZero += s.pair.avNewFromZero;
  }
  pair.yoyPct = pairYoY(pair);
  return { years: out, pair: anyPair ? pair : null, any };
}

/** YoY % over the pair base, one decimal; null with no parcel in the base. */
function pairYoY(pair: YearPair | null): number | null {
  if (!pair || pair.parcelsBoth <= 0 || !(pair.avPriorBoth > 0)) return null;
  return Math.round((pair.avCurrentBoth / pair.avPriorBoth - 1) * 1000) / 10;
}

/** A year figure's AV, or null when no parcel has one. */
function figureAV(f: YearFigure | undefined): number | null {
  return f && f.parcels > 0 ? f.av : null;
}

/** The Marion run's fixed columns (it writes no per-county years): AV2025 / AV2026. */
function marionColumn(row: OwnerRow, year: number): number | null {
  if (year === 2025) return row.totalAV2025;
  if (year === 2026) return row.totalAV2026;
  return null;
}

/**
 * An owner's display-year figures. `completeness` = avCurrentBoth ÷ (Σ y2 AV + the y1 AV of parcels without a y2
 * figure) — the share of the portfolio's newest display-year AV that the YoY covers; a parcel still `TBA` for y2
 * counts against it at its y1 figure.
 */
export function ownerYearSummary(row: OwnerRow, years: DisplayYears): OwnerYearSummary {
  const summed = sumSlices(Object.values(row.byCounty ?? {}), years);
  if (!summed.any) {
    return {
      hasYearData: false, years: {}, pair: null, avYear1: marionColumn(row, years[0]), avYear2: marionColumn(row, years[1]),
      yoyPct: row.avYoYPct, completeness: null,
    };
  }
  const y1 = summed.years[String(years[0])];
  const y2 = summed.years[String(years[1])];
  const pair = summed.pair;
  const denominator = (y2?.av ?? 0) + (y1?.av ?? 0) - (pair?.avPriorBoth ?? 0);
  const completeness = pair && pair.parcelsBoth > 0 && denominator > 0 ? pair.avCurrentBoth / denominator : null;
  return {
    hasYearData: true, years: summed.years, pair, avYear1: figureAV(y1), avYear2: figureAV(y2),
    yoyPct: pair?.yoyPct ?? null, completeness,
  };
}

/** The owner's cell for one display year: its Σ AV, or `TBA` (newest year) / `—` (older year). */
export function yearCell(row: OwnerRow, year: number, years: DisplayYears): YearCellValue {
  const s = ownerYearSummary(row, years);
  const av = year === years[0] ? s.avYear1 : year === years[1] ? s.avYear2 : null;
  return av ?? gapMark(year, years);
}

/** The owner's YoY over its parcels with both display years (roll included); `—` without a pair. */
export function yoyCell(row: OwnerRow, years: DisplayYears): number | typeof NO_FIGURE_MARK {
  return ownerYearSummary(row, years).yoyPct ?? NO_FIGURE_MARK;
}

const count = (n: number, noun = 'parcel'): string => `${n.toLocaleString('en-US')} ${noun}${n === 1 ? '' : 's'}`;

/**
 * The Assessment status column: `2026 assessed: 38 of 112 · roll 30` / `2026 TBA (12 parcels)`, then
 * `2025 —: 3 parcels` for parcels with no older-year figure and `n new since 2025` for $0 priors.
 */
export function statusCell(row: OwnerRow, years: DisplayYears): string {
  const [y1, y2] = years;
  const s = ownerYearSummary(row, years);
  if (!s.hasYearData) {
    if (s.avYear2 == null) return `${y2} ${TBA_MARK}`;
    return s.avYear1 == null ? `${y1} ${NO_FIGURE_MARK}` : `${y1} and ${y2} on record`;
  }
  const m = row.parcelCount;
  const f2 = s.years[String(y2)];
  const f1 = s.years[String(y1)];
  const parts: string[] = [];
  if (f2 && f2.parcels > 0) {
    parts.push(`${y2} assessed: ${f2.parcels.toLocaleString('en-US')} of ${m.toLocaleString('en-US')}${f2.roll > 0 ? ` · roll ${f2.roll.toLocaleString('en-US')}` : ''}`);
  } else {
    parts.push(`${y2} ${TBA_MARK} (${count(m)})`);
  }
  const missing1 = m - (f1?.parcels ?? 0);
  if (missing1 > 0 && f2 && f2.parcels > 0) parts.push(`${y1} ${NO_FIGURE_MARK}: ${count(missing1)}`);
  if ((s.pair?.newFromZero ?? 0) > 0) parts.push(`${(s.pair?.newFromZero ?? 0).toLocaleString('en-US')} new since ${y1}`);
  return parts.join(' · ');
}

/** Tooltip on an owner's year cell: "n of m parcels have a <year> figure; k are the DLGF roll" (null on the Marion run). */
export function yearTooltip(row: OwnerRow, year: number, years: DisplayYears): string | null {
  const s = ownerYearSummary(row, years);
  if (!s.hasYearData) return null;
  const f = s.years[String(year)];
  return `${(f?.parcels ?? 0).toLocaleString('en-US')} of ${row.parcelCount.toLocaleString('en-US')} parcels have a ${year} figure; ${(f?.roll ?? 0).toLocaleString('en-US')} are the DLGF roll`;
}

/** True when the owner's YoY covers at least {@link COMPLETE_YOY_THRESHOLD} of its newest display-year AV. */
export function isComplete(row: OwnerRow, years: DisplayYears): boolean {
  const c = ownerYearSummary(row, years).completeness;
  return c != null && c >= COMPLETE_YOY_THRESHOLD;
}

/** The same test on an annotated row (sort / filter never recompute the slices). */
export function isCompleteRow(row: Pick<OwnerRow, 'completeness'>): boolean {
  return row.completeness != null && row.completeness >= COMPLETE_YOY_THRESHOLD;
}

/**
 * The YoY ranking's materiality floor (ruling, 2026-09-28 fix round 1): a complete owner whose paired prior-year AV
 * is below this ranks after the complete owners above it — its % is shown, never hidden, but a percentage on a tiny
 * base (a land line turned into a building) does not head the list.
 */
export const YOY_MATERIAL_PRIOR = 100_000;

/** 0 = complete with a material base, 1 = complete on a small base, 2 = incomplete. */
export function yoyRankTier(row: Pick<OwnerRow, 'completeness' | 'avPriorBoth'>): 0 | 1 | 2 {
  if (!isCompleteRow(row)) return 2;
  return (row.avPriorBoth ?? 0) >= YOY_MATERIAL_PRIOR ? 0 : 1;
}

/**
 * A saved Statewide sort on a column the fixed-years table removed (`avPrior` "AV prior (paired)", `avYoYPct` the
 * per-parcel-newest YoY) restores as the fixed-pair YoY; every other key is kept.
 */
export function remapStatewideSortKey(key: OwnerSortKey): OwnerSortKey {
  return key === 'avPrior' || key === 'avYoYPct' ? 'yoyPair' : key;
}

/** Stamp the sortable display-year fields on each row (mutates: the rows are the component's view models). */
export function annotateOwnerYears(rows: OwnerRow[], years: DisplayYears | null): void {
  for (const r of rows) {
    const s = years ? ownerYearSummary(r, years) : null;
    r.avYear1 = s?.avYear1 ?? null;
    r.avYear2 = s?.avYear2 ?? null;
    r.yoyPair = s?.yoyPct ?? null;
    r.completeness = s?.completeness ?? null;
    r.avPriorBoth = s?.pair && s.pair.parcelsBoth > 0 ? s.pair.avPriorBoth : null;
  }
}

/** A run `ByCountyJSON` value as a slice (the same `years` / `pair` shape as an owner's). */
function runSlice(v: unknown): OwnerCountySlice | null {
  if (!isRecord(v) || Array.isArray(v)) return null;
  return {
    parcels: toNum(v['parcels']) ?? 0,
    avCurrent: toNum(v['avCurrent']) ?? 0,
    avPrior: toNum(v['avPrior']),
    years: parseYearFigures(v['years']),
    pair: parseYearPair(v['pair']),
  };
}

/**
 * The county status chip: `cards` (the newest display year has county-document figures), `roll only` (every newest-year
 * figure is the DLGF roll), or `<year> TBA` (no newest-year figure yet) — so a TBA is never mistaken for missing data.
 */
export function countyChip(runCounty: unknown, years: DisplayYears): string {
  const f = runSlice(runCounty)?.years?.[String(years[1])];
  if (!f || f.parcels <= 0) return `${years[1]} ${TBA_MARK}`;
  return f.roll >= f.parcels ? 'roll only' : 'cards';
}

/** County number → chip for every county with parcels in a run's `ByCountyJSON`. */
export function countyChips(byCountyJSON: unknown, years: DisplayYears): Record<number, string> {
  const out: Record<number, string> = {};
  const all = parseJsonObject(byCountyJSON);
  for (const n of countyNumbersInRun(byCountyJSON)) out[n] = countyChip(all[String(n)], years);
  return out;
}

/** The Statewide county banner over the display years. */
export interface CountyYearBanner {
  countyCount: number;
  parcels: number;
  /** Σ over parcels with an older-year figure; null when none has one. */
  y1: YearFigure | null;
  /** Σ over parcels with a newest-year figure; null when none has one (the banner says TBA). */
  y2: YearFigure | null;
  parcelsBoth: number;
  avPriorBoth: number;
  avCurrentBoth: number;
  /** YoY over the parcels with both years; null with none. */
  yoyPct: number | null;
  newFromZero: number;
  /** The one county's chip; null for All. */
  chip: string | null;
}

/** One county's (or, for null, every county's) display-year banner from the run's `ByCountyJSON`; null when absent. */
export function countyYearBanner(byCountyJSON: unknown, countyNumber: number | null, years: DisplayYears): CountyYearBanner | null {
  const all = parseJsonObject(byCountyJSON);
  const keys = countyNumber == null ? countyNumbersInRun(byCountyJSON).map(String) : [String(countyNumber)];
  const slices = keys.map((k) => runSlice(all[k])).filter((s): s is OwnerCountySlice => s != null && s.parcels > 0);
  if (!slices.length) return null;
  const summed = sumSlices(slices, years);
  const pair = summed.pair ?? emptyPair(years);
  const f1 = summed.years[String(years[0])];
  const f2 = summed.years[String(years[1])];
  return {
    countyCount: slices.length,
    parcels: slices.reduce((n, s) => n + s.parcels, 0),
    y1: f1 && f1.parcels > 0 ? f1 : null,
    y2: f2 && f2.parcels > 0 ? f2 : null,
    parcelsBoth: pair.parcelsBoth,
    avPriorBoth: pair.avPriorBoth,
    avCurrentBoth: pair.avCurrentBoth,
    yoyPct: pairYoY(pair),
    newFromZero: pair.newFromZero,
    chip: countyNumber == null ? null : countyChip(all[String(countyNumber)], years),
  };
}

// ───── Parcel rows: display years read live from `Parcel Year Headlines` ─────

/** One parcel-year figure from `Parcel Year Headlines`. */
export interface ParcelYearValue {
  /** `HeadlineTotalAV`. */
  av: number;
  /** `IsPlaceholder` — the DLGF roll is the figure (no county document on file). */
  roll: boolean;
  /** `HeadlineDataSource` — the data source's label (the words shown beside the figure). */
  source: string | null;
}

/** `ParcelID` → `"2025"` → figure. */
export type ParcelYearsMap = Record<string, Record<string, ParcelYearValue>>;

/** `Parcel Year Headlines` simple rows → {@link ParcelYearsMap} (a row with no total is no figure). */
export function mapParcelYearHeadlines(rows: readonly RawRow[]): ParcelYearsMap {
  const out: ParcelYearsMap = {};
  for (const r of rows) {
    const id = toStr(r['ParcelID']);
    const year = toNum(r['AssessmentYear']);
    const av = toNum(r['HeadlineTotalAV']);
    if (!id || year == null || av == null) continue;
    (out[id] ?? (out[id] = {}))[String(year)] = { av, roll: toBool(r['IsPlaceholder']), source: toStr(r['HeadlineDataSource']) };
  }
  return out;
}

/** One parcel as the detail panel's table shows it. */
export interface ParcelViewRow {
  parcel: OwnerParcelRow;
  /** False while the year figures are not loaded (loading / failed) — no gap marker is claimed then. */
  loaded: boolean;
  y1: ParcelYearValue | null;
  y2: ParcelYearValue | null;
  /** YoY over both figures (roll included), one decimal; null when either is missing or the prior is $0. */
  yoyPct: number | null;
  /** The parcel's newest assessment year on record (its own `CurrentYear`, else the newest figure read). */
  newestYear: number | null;
  countyName: string | null;
}

function parcelYoY(y1: ParcelYearValue | null, y2: ParcelYearValue | null): number | null {
  if (!y1 || !y2 || !(y1.av > 0)) return null;
  return Math.round((y2.av / y1.av - 1) * 1000) / 10;
}

/** The panel's rows: each parcel with its display-year figures (from `map`; null = not loaded). */
export function buildParcelViewRows(
  parcels: readonly OwnerParcelRow[],
  map: ParcelYearsMap | null,
  years: DisplayYears | null,
  countyNames: Readonly<Record<number, string>> = {},
): ParcelViewRow[] {
  return parcels.map((p) => {
    const figs = map && p.parcelId ? (map[p.parcelId] ?? {}) : {};
    const y1 = years ? (figs[String(years[0])] ?? null) : null;
    const y2 = years ? (figs[String(years[1])] ?? null) : null;
    const read = Object.keys(figs).map(Number);
    const newest = Math.max(p.currentYear ?? -Infinity, ...read);
    return {
      // A parcel with no ParcelID cannot be matched to a figure: not loaded, so no TBA / — is ever claimed for it.
      parcel: p, loaded: map != null && years != null && !!p.parcelId, y1, y2, yoyPct: parcelYoY(y1, y2),
      newestYear: Number.isFinite(newest) ? newest : null,
      countyName: p.countyNumber != null ? (countyNames[p.countyNumber] ?? `County ${p.countyNumber}`) : null,
    };
  });
}

/** A parcel's cell for one display year: the figure, or `TBA` / `—`. */
export function parcelYearCell(v: ParcelYearValue | null, year: number, years: DisplayYears): YearCellValue {
  return v ? v.av : gapMark(year, years);
}

/** The parcel's status words (export + tooltips): gaps, roll years, a $0 prior. */
export function parcelStatus(r: ParcelViewRow, years: DisplayYears): string {
  if (!r.loaded) return 'year figures not loaded';
  const [y1, y2] = years;
  const parts: string[] = [];
  if (!r.y1) parts.push(`${y1} ${NO_FIGURE_MARK}`);
  else if (r.y1.roll) parts.push(`${y1} roll`);
  if (!r.y2) parts.push(`${y2} ${TBA_MARK}`);
  else if (r.y2.roll) parts.push(`${y2} roll`);
  if (r.y1 && r.y2 && r.y1.av === 0) parts.push(`new since ${y1}`);
  return parts.length ? parts.join(' · ') : `${y1} and ${y2} on record`;
}

/** Every sortable column of the detail panel's parcel tables (both scopes). */
export type ParcelSortKey =
  | 'parcel' | 'county' | 'type' | 'avYear1' | 'avYear2' | 'yoy' | 'sqft' | 'units' | 'ask' | 'savings'
  | 'rec' | 'conf' | 'appealed' | 'rep';

const PARCEL_STRING_KEYS: ReadonlySet<ParcelSortKey> = new Set<ParcelSortKey>(['parcel', 'county', 'type', 'rec', 'conf', 'rep']);

/** A fresh column starts ascending for words, descending for figures. */
export function parcelSortStartsAscending(key: ParcelSortKey): boolean {
  return PARCEL_STRING_KEYS.has(key);
}

/** The value a parcel row sorts by; null / '' = blank. */
function parcelSortValue(r: ParcelViewRow, key: ParcelSortKey): string | number | null {
  const p = r.parcel;
  switch (key) {
    case 'parcel': return p.address ?? p.parcelNumber ?? (p.gisParcelNumber || null);
    case 'county': return r.countyName;
    case 'type': return p.typeGroup;
    case 'avYear1': return r.y1?.av ?? null;
    case 'avYear2': return r.y2?.av ?? null;
    case 'yoy': return r.yoyPct;
    case 'sqft': return p.sqft;
    case 'units': return p.units;
    case 'ask': return p.ask;
    case 'savings': return p.estSavingsAtAsk;
    case 'rec': return p.rec;
    case 'conf': return p.conf;
    case 'appealed': return p.appealed ? (p.lastAppealYear ?? 0) : null;
    case 'rep': return p.existingRep;
    default: return null;
  }
}

/** Sort parcel rows by any column; blanks (no figure / no text) sort last in BOTH directions; stable. */
export function sortParcels(rows: readonly ParcelViewRow[], key: ParcelSortKey, dir: 1 | -1): ParcelViewRow[] {
  return rows
    .map((r, i) => ({ r, i, v: parcelSortValue(r, key) }))
    .sort((a, b) => {
      const blankA = a.v == null || a.v === '';
      const blankB = b.v == null || b.v === '';
      if (blankA || blankB) return blankA === blankB ? a.i - b.i : blankA ? 1 : -1;
      const cmp = typeof a.v === 'number' && typeof b.v === 'number' ? a.v - b.v : String(a.v).localeCompare(String(b.v));
      return dir * cmp || a.i - b.i;
    })
    .map((w) => w.r);
}

// ───── Export rows (consumed by Task 3's workbook builder) ─────

/** One owner as exported: numbers as numbers, gaps as null, the status in words. `yoyPct` is in percent points (7.7 = +7.7 %). */
export interface OwnerExportRow {
  owner: string;
  kind: OwnerKind;
  tier: string | null;
  tierBasis: TierBasis;
  parcels: number;
  counties: number | null;
  primaryCountyNumber: number | null;
  avYear1: number | null;
  avYear2: number | null;
  yoyPct: number | null;
  status: string;
  repStatus: string;
  savingsAtAsk: number | null;
  /** True when the savings figure covers only the owner's Marion parcels (AV basis). */
  savingsMarionParcelsOnly: boolean;
  appealedParcels: number | null;
  reductionWon: number | null;
  lastAppealYear: number | null;
  ownerKey: string;
}

/** The owner rows on screen, as export rows (same figures and words as the table). */
export function exportRows(owners: readonly OwnerRow[], years: DisplayYears, scope: OwnerProspectsScope): OwnerExportRow[] {
  return owners.map((o) => {
    const s = ownerYearSummary(o, years);
    const basis = effectiveTierBasis(o.tierBasis, scope);
    return {
      owner: o.label, kind: o.kind, tier: o.tier, tierBasis: basis, parcels: o.parcelCount,
      counties: o.countyCount ?? null, primaryCountyNumber: o.primaryCountyNumber ?? null,
      avYear1: s.avYear1, avYear2: s.avYear2, yoyPct: s.yoyPct, status: statusCell(o, years),
      repStatus: o.repStatus, savingsAtAsk: o.estSavingsAtAsk,
      savingsMarionParcelsOnly: basis === 'AV' && o.estSavingsAtAsk != null,
      appealedParcels: o.appealedParcels, reductionWon: o.historicalReductionWon,
      lastAppealYear: o.mostRecentAppealYear ?? null, ownerKey: o.ownerKey,
    };
  });
}

/** One parcel as exported: per-year figures and roll flags, null gaps, the status words. */
export interface ParcelExportRow {
  parcel: string;
  address: string | null;
  county: string | null;
  type: string | null;
  avYear1: number | null;
  avYear2: number | null;
  rollYear1: boolean;
  rollYear2: boolean;
  yoyPct: number | null;
  newestYear: number | null;
  status: string;
  sqft: number | null;
  units: number | null;
  savingsAtAsk: number | null;
  appealed: boolean;
  lastAppealYear: number | null;
  rep: string | null;
}

/** The panel's parcel rows (as sorted on screen) as export rows. */
export function exportParcelRows(rows: readonly ParcelViewRow[], years: DisplayYears): ParcelExportRow[] {
  return rows.map((r) => {
    const p = r.parcel;
    return {
      parcel: p.parcelNumber ?? p.gisParcelNumber, address: p.address, county: r.countyName, type: p.typeGroup,
      avYear1: r.y1?.av ?? null, avYear2: r.y2?.av ?? null, rollYear1: r.y1?.roll ?? false, rollYear2: r.y2?.roll ?? false,
      yoyPct: r.yoyPct, newestYear: r.newestYear, status: parcelStatus(r, years), sqft: p.sqft, units: p.units,
      savingsAtAsk: p.estSavingsAtAsk, appealed: p.appealed, lastAppealYear: p.lastAppealYear, rep: p.existingRep,
    };
  });
}
