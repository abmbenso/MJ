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
/** The YoY column ranks only owners whose prior-year AV is at least this; smaller priors (new construction) sort last. */
export const YOY_PRIOR_FLOOR = 100_000;
/** Tooltip on a blank savings cell — exact wording from the controller ruling. */
export const NO_ANALYSIS_TOOLTIP = 'no valuation analysis for this county yet';
/** Marker after a Statewide savings figure: it comes from the owner's Marion parcels only. */
export const MARION_PARCELS_MARKER = 'Marion parcels';
export const MARION_PARCELS_TOOLTIP = "from valuation analyses on this owner's Marion parcels only";
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

/** One owner's slice of one county (`OwnerPortfolio.ByCountyJSON` value). */
export interface OwnerCountySlice {
  parcels: number;
  avCurrent: number;
  avPrior: number | null;
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
  /** Σ AVPrior over the parcels that have a prior year — the YoY base, not the whole portfolio. */
  avPrior?: number | null;
  avCurrent?: number | null;
  pairYears?: string | null;
  tierBasis?: TierBasis | null;
  groupKeyType?: string | null;
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
  | 'countyCount';

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

export function filterOwnerRows(rows: OwnerRow[], f: OwnerProspectsFilters): OwnerRow[] {
  const q = f.query.trim().toLowerCase();
  return rows.filter((o) => {
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
      if (key === 'avYoYPct') {
        // The YoY floor: a percentage on a tiny prior (new construction) is honest but never tops the list.
        const fa = isBelowYoYFloor(x.r);
        const fb = isBelowYoYFloor(y.r);
        if (fa !== fb) return fa ? 1 : -1;
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
export function buildVisibleRows(all: OwnerRow[], f: OwnerProspectsFilters, sortKey: OwnerSortKey, sortDir: 1 | -1): OwnerRow[] {
  return sortOwnerRows(filterOwnerRows(all, f), sortKey, sortDir);
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
    PrimeCount: state.summary?.prime ?? null,
    StrongCount: state.summary?.strong ?? null,
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

/** `OwnerPortfolio.ByCountyJSON` → `{ [countyNumber]: { parcels, avCurrent, avPrior } }`. */
function parseOwnerByCounty(v: unknown): Record<string, OwnerCountySlice> {
  const out: Record<string, OwnerCountySlice> = {};
  for (const [k, raw] of Object.entries(parseJsonObject(v))) {
    const b = isRecord(raw) ? raw : {};
    out[k] = { parcels: toNum(b['parcels']) ?? 0, avCurrent: toNum(b['avCurrent']) ?? 0, avPrior: toNum(b['avPrior']) };
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

/** The rep cell: the stored `RepStatus` verbatim, except the Marion "No rep on record" fact, which reads "— open". */
export function repCell(repStatus: string): { text: string; open: boolean } {
  return repStatus === NO_REP_ON_RECORD ? { text: '— open', open: true } : { text: repStatus, open: false };
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

/** True when a row carries a prior-year AV below {@link YOY_PRIOR_FLOOR} and a YoY % (the `prior < $100k` pill). */
export function isBelowYoYFloor(row: Pick<OwnerRow, 'avPrior' | 'avYoYPct'>): boolean {
  return row.avPrior != null && row.avYoYPct != null && row.avPrior < YOY_PRIOR_FLOOR;
}

/** The per-county (or all-county) banner view-model from the run's `ByCountyJSON`. */
export interface CountyBannerModel {
  countyCount: number;
  parcels: number;
  /** Σ AVCurrent over every parcel with an AV. */
  avCurrent: number;
  /** Σ AVPrior over the paired parcels; null when none are paired. */
  avPrior: number | null;
  /** Σ AVCurrent over the same paired parcels; null when none are paired. */
  avCurrentPaired: number | null;
  yoyParcels: number;
  /** Paired YoY %, one decimal — only when both paired sums exist. */
  yoyPct: number | null;
  placeholderParcels: number;
}

/** County numbers with parcels in a run's `ByCountyJSON`, ascending. */
export function countyNumbersInRun(byCountyJSON: unknown): number[] {
  return Object.entries(parseJsonObject(byCountyJSON))
    .filter(([, v]) => isRecord(v) && (toNum(v['parcels']) ?? 0) > 0)
    .map(([k]) => Number(k))
    .filter((n) => Number.isFinite(n))
    .sort((a, b) => a - b);
}

/** One county's rollup (or every county's, summed, when `countyNumber` is null); null when absent. */
export function countyBanner(byCountyJSON: unknown, countyNumber: number | null): CountyBannerModel | null {
  const all = parseJsonObject(byCountyJSON);
  const picked = countyNumber == null ? Object.values(all) : [all[String(countyNumber)]];
  const slices = picked.filter(isRecord).filter((v) => (toNum(v['parcels']) ?? 0) > 0);
  if (!slices.length) return null;
  const sum = (k: string): number => slices.reduce((s, v) => s + (toNum(v[k]) ?? 0), 0);
  const prior = sum('avPrior');
  const curPaired = sum('avCurrentYoY');
  const both = prior > 0 && curPaired > 0;
  return {
    countyCount: slices.length,
    parcels: sum('parcels'),
    avCurrent: sum('avCurrent'),
    avPrior: both ? prior : null,
    avCurrentPaired: both ? curPaired : null,
    yoyParcels: sum('yoyParcels'),
    yoyPct: both ? Math.round((curPaired / prior - 1) * 1000) / 10 : null,
    placeholderParcels: sum('placeholderParcels'),
  };
}

/** `2024→2025`, `2025 only`, or `''` when the parcel carries no years (the Marion run). */
export function parcelYears(p: Pick<OwnerParcelRow, 'priorYear' | 'currentYear'>): string {
  if (p.currentYear == null) return '';
  return p.priorYear == null ? `${p.currentYear} only` : `${p.priorYear}→${p.currentYear}`;
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
