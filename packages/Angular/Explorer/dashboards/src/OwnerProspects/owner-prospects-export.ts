/**
 * Owner Prospects — the Excel export (owner-prospects-years-export plan, Task 3).
 *
 * PURE: no Angular, no RunView, no file writing. It turns the screen's export rows ({@link exportRows} /
 * {@link exportParcelRows}) into `@memberjunction/export-engine` sheet definitions; the dashboard hands them to
 * `ExportEngine.toExcelMultiSheet` and downloads the bytes (the TaxBillProjection pattern).
 *
 * Cell typing (Review Focus 3): every figure is written as a REAL NUMBER with a number format (`#,##0` dollars,
 * `0.0%` YoY — the rows carry percent points, divided by 100 here), and a gap is an EMPTY cell — never the text
 * `TBA` / `—`. The words live only in the Assessment status column. Rows are written as arrays so a null stays a
 * null (the engine's object-row path would turn it into an empty string).
 *
 * Owner names and groupings are CoStar-derived: every workbook's Basis sheet says so — for internal use, not for
 * publication.
 */
import { CellStyleOverride, ExportData, SheetDefinition } from '@memberjunction/export-engine';
import {
  DisplayYears,
  MARION_RUN_COUNTY_NUMBER,
  NO_FIGURE_MARK,
  OwnerExportRow,
  OwnerProspectsScope,
  OwnerSortKey,
  ParcelExportRow,
  TBA_MARK,
  TierBasis,
  tierLabel,
} from './owner-prospects.model';
import { columnLetter } from '../TaxBillProjection/tax-bill-export';

/** Dollars: whole dollars with thousands separators. */
export const DOLLAR_FORMAT = '#,##0';
/** Counts: whole numbers with thousands separators. */
export const COUNT_FORMAT = '#,##0';
/** YoY: a fraction shown as a percent with one decimal. */
export const PERCENT_FORMAT = '0.0%';

/** The legend every Basis sheet carries (verbatim, user direction 2026-09-28). */
export const EXPORT_LEGEND: readonly (readonly [string, string])[] = [
  [TBA_MARK, 'to be assessed — no figure on the record for the newest year'],
  [NO_FIGURE_MARK, 'no figure for the older year'],
  ['roll', 'DLGF roll figure without a card'],
];
/** The CoStar caution every Basis sheet carries. */
export const COSTAR_CAUTION = 'Owner names and groupings are CoStar-derived: for internal use, not for publication.';
/** How to read the figure cells. */
export const CELL_NOTE = 'Figures are numbers. An empty year or YoY cell is a gap: the Assessment status column says which (TBA or —).';

/** What the owner export was taken from — everything the Basis sheet states. */
export interface OwnerExportBasis {
  runId: string;
  runDate: Date | null;
  methodologyVersion: string | null;
  scope: OwnerProspectsScope;
  /** The county filter's name; null = all counties. */
  county: string | null;
  searchTerm: string;
  completeOnly: boolean;
  /** Every table filter applied after the read, in words ({@link tableFilterWords}). */
  filters: string[];
  /** Rows the server read for the run + county/search clause (before the table's filters). */
  rowsRead: number;
  /** "YoY 2025→2026, descending". */
  sort: string;
  years: DisplayYears;
  tierBasis: TierBasis;
  generatedAt: Date;
  /** True when more rows matched than the export cap read. */
  capped: boolean;
  capNote: string | null;
}

/** What the parcel export was taken from. */
export interface ParcelExportBasis {
  runId: string;
  runDate: Date | null;
  methodologyVersion: string | null;
  scope: OwnerProspectsScope;
  owner: string;
  ownerKey: string;
  /** The owner's parcel count on the run. */
  ownerParcelCount: number;
  /** A cap note when the loaded parcels are not all of them; null otherwise. */
  capNote: string | null;
  sort: string;
  years: DisplayYears;
  generatedAt: Date;
}

/** One exported column: header, number format, and how a row fills it. */
interface ColumnSpec<T> {
  header: string;
  format?: string;
  value: (row: T) => string | number | null;
}

/** Percent points (7.7) → the fraction Excel formats as a percent (0.077); null stays null. */
export function pctFraction(points: number | null): number | null {
  return points == null ? null : Math.round(points * 10) / 1000;
}

/** A local calendar date as `YYYY-MM-DD` ('undated' without one). */
export function isoDate(d: Date | null): string {
  if (!d || Number.isNaN(d.getTime())) return 'undated';
  const pad = (n: number): string => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

/** A local timestamp as `YYYY-MM-DD HH:MM`. */
function isoMinute(d: Date): string {
  const pad = (n: number): string => String(n).padStart(2, '0');
  return `${isoDate(d)} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** Lower-case, words joined by `-`, at most 60 characters (a file-name part). */
export function slugify(s: string): string {
  const slug = s.toLowerCase().normalize('NFKD').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  return slug.slice(0, 60).replace(/-+$/, '') || 'owner';
}

/** `owner-prospects_<scope>_<county|all>_<runDate>.xlsx`. */
export function ownerExportFileName(scope: OwnerProspectsScope, countySlug: string | null, runDate: Date | null): string {
  return `owner-prospects_${scope.toLowerCase()}_${countySlug ? slugify(countySlug) : 'all'}_${isoDate(runDate)}.xlsx`;
}

/** `owner-parcels_<owner-slug>_<runDate>.xlsx`. */
export function parcelExportFileName(owner: string, runDate: Date | null): string {
  return `owner-parcels_${slugify(owner)}_${isoDate(runDate)}.xlsx`;
}

/** The words for a table sort: the column's header and the direction. */
export function ownerSortLabel(key: OwnerSortKey, dir: 1 | -1, years: DisplayYears | null, tierBasis: TierBasis): string {
  const y = years ? { y1: `AV ${years[0]}`, y2: `AV ${years[1]}`, pair: `${years[0]}→${years[1]}` } : { y1: 'AV —', y2: 'AV —', pair: '' };
  const names: Record<OwnerSortKey, string> = {
    label: 'Owner', tier: tierLabel(tierBasis), parcelCount: 'Parcels', totalAV2025: 'AV 2025', totalAV2026: 'AV 2026',
    avYoYPct: 'YoY', totalUnits: 'Units', nAppealRec: 'Appeal recs', estSavingsAtAsk: 'Opp / yr (ask)',
    estSavingsAtFloor: 'Opp / yr (floor)', historicalReductionWon: 'Hist. reduction', appealYears: 'Appeals filed',
    repStatus: 'Tax rep', avPrior: 'AV prior', avCurrent: 'AV current', countyCount: 'Counties', avYear1: y.y1,
    avYear2: y.y2, yoyPair: `YoY ${y.pair} (complete owners first)`, avYoYDollars: `YoY $ ${y.pair}`,
    completeness: 'Assessment status (YoY coverage)',
  };
  return `${names[key]}, ${dir === 1 ? 'ascending' : 'descending'}`;
}

/** The Owners sheet's columns for the display years and tier basis. */
function ownerColumns(years: DisplayYears, basis: TierBasis): ColumnSpec<OwnerExportRow & { countyName: string | null }>[] {
  const [y1, y2] = years;
  return [
    { header: 'Owner', value: (r) => r.owner },
    { header: 'Kind', value: (r) => r.kind },
    { header: tierLabel(basis), value: (r) => r.tier },
    { header: 'Parcels', format: COUNT_FORMAT, value: (r) => r.parcels },
    { header: 'Counties', format: COUNT_FORMAT, value: (r) => r.counties },
    { header: 'Primary county', value: (r) => r.countyName },
    { header: `AV ${y1}`, format: DOLLAR_FORMAT, value: (r) => r.avYear1 },
    { header: `AV ${y2}`, format: DOLLAR_FORMAT, value: (r) => r.avYear2 },
    { header: 'YoY %', format: PERCENT_FORMAT, value: (r) => pctFraction(r.yoyPct) },
    { header: `YoY $ ${y1}→${y2}`, format: DOLLAR_FORMAT, value: (r) => r.yoyDollars },
    { header: 'Assessment status', value: (r) => r.status },
    { header: 'Rep status', value: (r) => r.repStatus },
    { header: basis === 'AV' ? 'Savings at ask (Marion parcels only)' : 'Savings at ask', format: DOLLAR_FORMAT, value: (r) => r.savingsAtAsk },
    { header: 'Appealed parcels', format: COUNT_FORMAT, value: (r) => r.appealedParcels },
    { header: 'Reduction won', format: DOLLAR_FORMAT, value: (r) => r.reductionWon },
    { header: 'Last appeal year', value: (r) => r.lastAppealYear },
    { header: 'Owner key', value: (r) => r.ownerKey },
  ];
}

/** The Parcels sheet's columns for the display years. */
function parcelColumns(years: DisplayYears): ColumnSpec<ParcelExportRow>[] {
  const [y1, y2] = years;
  return [
    { header: 'Parcel', value: (r) => r.parcel },
    { header: 'Address', value: (r) => r.address },
    { header: 'County', value: (r) => r.county },
    { header: 'Type', value: (r) => r.type },
    { header: `AV ${y1}`, format: DOLLAR_FORMAT, value: (r) => r.avYear1 },
    { header: `${y1} roll`, value: (r) => (r.rollYear1 ? 'roll' : null) },
    { header: `AV ${y2}`, format: DOLLAR_FORMAT, value: (r) => r.avYear2 },
    { header: `${y2} roll`, value: (r) => (r.rollYear2 ? 'roll' : null) },
    { header: 'YoY %', format: PERCENT_FORMAT, value: (r) => pctFraction(r.yoyPct) },
    { header: `YoY $ ${y1}→${y2}`, format: DOLLAR_FORMAT, value: (r) => (r.avYear1 != null && r.avYear2 != null ? r.avYear2 - r.avYear1 : null) },
    { header: 'Newest year', value: (r) => r.newestYear },
    { header: 'Assessment status', value: (r) => r.status },
    { header: 'SqFt', format: COUNT_FORMAT, value: (r) => r.sqft },
    { header: 'Units', format: COUNT_FORMAT, value: (r) => r.units },
    { header: 'Ask', format: DOLLAR_FORMAT, value: (r) => r.ask },
    { header: 'Rec', value: (r) => r.rec },
    { header: 'Conf', value: (r) => r.conf },
    { header: 'Savings at ask', format: DOLLAR_FORMAT, value: (r) => r.savingsAtAsk },
    { header: 'Appealed', value: (r) => (r.appealed ? 'yes' : null) },
    { header: 'Last appeal year', value: (r) => r.lastAppealYear },
    { header: 'Rep', value: (r) => r.rep },
  ];
}

/**
 * A data sheet: bold frozen header, one array row per record (nulls stay empty), number formats per column. Column
 * widths are the engine's auto-fit (header or longest value, capped at 50): its multi-sheet path does not apply an
 * explicit width (`addSheet` → `autoFitColumns` skips a column that has one and never sets it), so none is passed.
 */
function dataSheet<T>(name: string, rows: readonly T[], columns: ColumnSpec<T>[]): SheetDefinition {
  const last = rows.length + 1;
  const cellStyles: CellStyleOverride[] = [];
  columns.forEach((c, i) => {
    if (c.format && rows.length > 0) cellStyles.push({ cell: `${columnLetter(i)}2:${columnLetter(i)}${last}`, style: { numFmt: c.format } });
  });
  return {
    name,
    headers: columns.map((c) => c.header),
    data: rows.map((r) => columns.map((c) => c.value(r))) as ExportData,
    headerStyle: { font: { bold: true }, alignment: { vertical: 'top', wrapText: true } },
    freeze: { row: 2 },
    autoFilter: rows.length > 0,
    cellStyles,
  };
}

/** A two-column label / value sheet (the Basis): labels bold, no header row. */
function basisSheet(lines: readonly (readonly [string, string | number])[]): SheetDefinition {
  const data: (string | number)[][] = lines.map(([k, v]) => [k, v]);
  return {
    name: 'Basis',
    data: data as ExportData,
    includeHeaders: false,
    cellStyles: [{ cell: `A1:A${Math.max(1, lines.length)}`, style: { font: { bold: true } } }],
  };
}

/** The lines every Basis sheet ends with: legend, cell note, CoStar caution. */
function legendLines(): [string, string][] {
  return [
    ['', ''],
    ['Legend', ''],
    ...EXPORT_LEGEND.map(([k, v]): [string, string] => [k, v]),
    ['Cells', CELL_NOTE],
    ['CoStar caution', COSTAR_CAUTION],
  ];
}

/** The run lines both Basis sheets open with. */
function runLines(b: { runId: string; runDate: Date | null; methodologyVersion: string | null; scope: OwnerProspectsScope; years: DisplayYears }): [string, string][] {
  return [
    ['Run ID', b.runId],
    ['Run date', isoDate(b.runDate)],
    ['Methodology', b.methodologyVersion ?? 'n/a'],
    ['Scope', b.scope],
    ['Assessment years', `${b.years[0]} and ${b.years[1]}`],
  ];
}

/** Said on the Basis sheet whenever a county is chosen: the figures are the owner's, not the county's. */
export const COUNTY_SCOPE_NOTE =
  "Figures and completeness are owner-wide (all counties), not this county's; the county filter selects owners with a parcel here.";
/** Said on the Marion Basis sheet: the Marion run writes no county count. */
export const MARION_COUNTIES_NOTE = 'n/a on the Marion run';

/** The table state whose filters are applied after the read. */
export interface TableFilterState {
  scope: OwnerProspectsScope;
  completeOnly: boolean;
  searchTerm: string;
  tier: string;
  tierHeader: string;
  rep: '' | 'none' | 'has';
  hasAppealHistory: boolean;
  typeGroup: string;
  minOppPerYear: number;
}

/** Every filter the table applies, in words — exactly those in force ("company owners only" always). */
export function tableFilterWords(f: TableFilterState): string[] {
  const out: string[] = ['company owners only'];
  if (f.scope === 'Statewide' && f.completeOnly) out.push('Complete YoY only');
  if (f.searchTerm.trim()) out.push(`search “${f.searchTerm.trim()}” (owner or rep)`);
  if (f.tier !== 'all') out.push(`${f.tierHeader}: ${f.tier}`);
  if (f.rep === 'none') out.push('no rep on record');
  if (f.rep === 'has') out.push('represented');
  if (f.hasAppealHistory) out.push('has an appealed parcel');
  if (f.typeGroup) out.push(`dominant type: ${f.typeGroup}`);
  if (f.scope === 'Marion' && f.minOppPerYear > 0) out.push(`opportunity ≥ $${f.minOppPerYear.toLocaleString('en-US')}/yr`);
  return out;
}

/** The server-side read clause in words: "the Lake county filter", "the “acme” search filter", … */
export function readFilterWords(county: string | null, serverSearch: string | null): string {
  const term = serverSearch?.trim() ? `“${serverSearch.trim()}” search` : null;
  if (county && term) return `the ${county} county and ${term} filter`;
  if (county) return `the ${county} county filter`;
  if (term) return `the ${term} filter`;
  return 'no county or search filter (all counties)';
}

/** The large-export confirm: the pre-filter read count (a read-cost warning), and the filters applied after reading. */
export function exportConfirmText(count: number, readWords: string, filters: readonly string[], cap: number): { message: string; detail: string; confirmText: string } {
  const n = count.toLocaleString('en-US');
  const capped = count > cap ? ` Only the first ${cap.toLocaleString('en-US')} will be read; the Basis sheet will say so.` : '';
  return {
    message: `${n} owners on this run match ${readWords} and will be read; the table's filters are applied after reading: ${filters.join(', ')}.`,
    detail: `This is a read-cost warning on the pre-filter count — the file will hold fewer rows; the Basis sheet records rows read and rows written.${capped}`,
    confirmText: `Read ${n} rows`,
  };
}

/** The owner export's Basis lines. */
export function ownerBasisLines(b: OwnerExportBasis, rowCount: number): (readonly [string, string | number])[] {
  return [
    ['Owner Prospects — owners export', ''],
    ...runLines(b),
    ['County', b.county ?? 'All counties'],
    ['Filters applied', b.filters.join('; ')],
    ['Rows read (run + county/search)', b.rowsRead],
    ['Rows written after table filters', rowCount],
    ...(b.county ? [['County scope', COUNTY_SCOPE_NOTE] as [string, string]] : []),
    ['Search term', b.searchTerm.trim() || 'none'],
    ['Complete YoY only', b.scope === 'Statewide' ? (b.completeOnly ? 'on' : 'off') : 'n/a (Marion)'],
    ['Sort', b.sort],
    ...(b.scope === 'Marion' ? [['Counties', MARION_COUNTIES_NOTE] as [string, string]] : []),
    ...(b.capped && b.capNote ? [['Row cap', b.capNote] as [string, string]] : []),
    ['Generated at', isoMinute(b.generatedAt)],
    ...legendLines(),
  ];
}

/** The owner workbook: `Basis`, then `Owners`. `countyNames` resolves each row's primary county number. */
export function buildOwnerWorkbook(
  rows: readonly OwnerExportRow[],
  basis: OwnerExportBasis,
  countyNames: Readonly<Record<number, string>>,
): SheetDefinition[] {
  const named = rows.map((r) => ({ ...r, countyName: primaryCountyName(r.primaryCountyNumber, basis.scope, countyNames) }));
  return [basisSheet(ownerBasisLines(basis, rows.length)), dataSheet('Owners', named, ownerColumns(basis.years, basis.tierBasis))];
}

/** A county number as its name — the number when the name is unknown, never blank; the Marion run is Marion. */
export function primaryCountyName(n: number | null, scope: OwnerProspectsScope, names: Readonly<Record<number, string>>): string | null {
  if (n == null) return scope === 'Marion' ? (names[MARION_RUN_COUNTY_NUMBER] ?? 'Marion') : null;
  return names[n] ?? String(n);
}

/** The parcel export's Basis lines. */
export function parcelBasisLines(b: ParcelExportBasis, rowCount: number): (readonly [string, string | number])[] {
  return [
    ['Owner Prospects — owner parcels export', ''],
    ...runLines(b),
    ['Owner', b.owner],
    ['Owner key', b.ownerKey],
    ['Parcels on the run', b.ownerParcelCount],
    ['Rows', rowCount],
    ...(b.capNote ? [['Row cap', b.capNote] as [string, string]] : []),
    ['Sort', b.sort],
    ['Generated at', isoMinute(b.generatedAt)],
    ...legendLines(),
  ];
}

/** The parcel workbook: `Basis`, then `Parcels` (the owner summary's rows, as sorted on screen). */
export function buildParcelWorkbook(rows: readonly ParcelExportRow[], basis: ParcelExportBasis): SheetDefinition[] {
  return [basisSheet(parcelBasisLines(basis, rows.length)), dataSheet('Parcels', rows, parcelColumns(basis.years))];
}
