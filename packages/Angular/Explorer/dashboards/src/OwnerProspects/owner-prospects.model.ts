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

// ─────────────────────────────────────────────────────────────────────────────
// Entity names — the exact strings CodeGen registered in Task 1
// (packages/GeneratedEntities/src/generated/entity_subclasses.ts,
//  `@RegisterClass(BaseEntity, '…')`).
// ─────────────────────────────────────────────────────────────────────────────

export const OWNER_PORTFOLIO_RUN_ENTITY = 'Owner Portfolio Runs';
export const OWNER_PORTFOLIO_ENTITY = 'Owner Portfolios';
export const OWNER_PORTFOLIO_PARCEL_ENTITY = 'Owner Portfolio Parcels';

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
  tier: 'all' | 'Prime' | 'Strong' | 'Moderate';
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
export function sanitizeFilters(raw: unknown): OwnerProspectsFilters {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>;
  const tier = r['tier'];
  const rep = r['rep'];
  const minOpp = Number(r['minOppPerYear']);
  return {
    tier: tier === 'Prime' || tier === 'Strong' || tier === 'Moderate' ? tier : 'all',
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
  | 'repStatus';

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
  };
}
