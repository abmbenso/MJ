import { describe, it, expect } from 'vitest';
import ExcelJS from 'exceljs';
import type { RunView, RunViewParams, RunViewResult } from '@memberjunction/core';
import { ExportEngine, SheetDefinition } from '@memberjunction/export-engine';
import {
  DisplayYears,
  OwnerParcelRow,
  annotateOwnerYears,
  buildParcelViewRows,
  exportParcelRows,
  exportRows,
  mapOwnerPortfolioRow,
  mapParcelYearHeadlines,
} from '../OwnerProspects/owner-prospects.model';
import {
  COSTAR_CAUTION,
  EXPORT_LEGEND,
  OwnerExportBasis,
  ParcelExportBasis,
  buildOwnerWorkbook,
  buildParcelWorkbook,
  isoDate,
  ownerExportFileName,
  ownerSortLabel,
  parcelExportFileName,
  pctFraction,
  primaryCountyName,
  slugify,
  tableFilterWords,
  readFilterWords,
  exportConfirmText,
  COUNTY_SCOPE_NOTE,
  MARION_COUNTIES_NOTE,
  TableFilterState,
} from '../OwnerProspects/owner-prospects-export';
import {
  EXPORT_PAGE_SIZE,
  EXPORT_ROW_CAP,
  OwnerProspectsDataAccess,
} from '../OwnerProspects/owner-prospects-statewide-data';

/**
 * Owner Prospects Excel export (owner-prospects-years-export plan, Task 3). The workbook is verified as a FILE:
 * built through `ExportEngine.toExcelMultiSheet` (the same call the dashboard makes), then read back with exceljs —
 * never trusted from the sheet definitions alone (Review Focus 3).
 *
 * Fixtures are raw `Owner Portfolios` simple rows as RunView returns them (ByCountyJSON a JSON string keyed by
 * county number, with the builder's per-county `years` / `pair`), mapped by the screen's own `mapOwnerPortfolioRow`.
 */

const Y: DisplayYears = [2025, 2026];
type Raw = Record<string, unknown>;

/** A raw statewide owner row: one county slice carrying the builder's per-year figures. */
function rawOwner(over: Raw, county: string, slice: Raw): Raw {
  return {
    ID: 'id', OwnerKey: 'CO:KEY', Label: 'Owner', Kind: 'Company', Tier: 'A', TierBasis: 'AV', GroupKeyType: 'CO',
    ParcelCount: 3, TotalAV: 1_600_000, AVYoYDollars: null, AVYoYPct: null, RepStatus: 'No rep data for this county',
    RepsOnReductionJSON: null, ByTypeJSON: '{}', PrimaryCountyNumber: Number(county), CountyCount: 1,
    ByCountyJSON: JSON.stringify({ [county]: slice }), ...over,
  };
}

// ABC: A 2025 card 1,000,000 + 2026 roll 1,100,000; B 2026 roll only 500,000; C 2025 card only 200,000 (Lake, 45).
const abcRaw = rawOwner({ ID: 'abc', Label: 'ABC Holdings', OwnerKey: 'CO:ABC', AVYoYDollars: 100_000, AppealedParcels: 1, HistoricalReductionWon: 25_000, MostRecentAppealYear: 2024 }, '45', {
  parcels: 3, avCurrent: 1_800_000, avPrior: 1_000_000, pairedParcels: 1,
  years: { '2025': { av: 1_200_000, parcels: 2, roll: 0 }, '2026': { av: 1_600_000, parcels: 2, roll: 2 } },
  pair: { prior: 2025, current: 2026, parcelsBoth: 1, avPriorBoth: 1_000_000, avCurrentBoth: 1_100_000, newFromZero: 0, avNewFromZero: 0, yoyPct: 10 },
});
// Review Focus 2: every parcel assessed only through 2025 — the county's 2026 not loaded (county 88 has no name loaded).
const only2025Raw = rawOwner({ ID: 'o25', Label: 'Only 2025 LLC', OwnerKey: 'NAME:ONLY 2025', ParcelCount: 12, TotalAV: 9_000_000 }, '88', {
  parcels: 12, avCurrent: 9_000_000, avPrior: null, pairedParcels: 0,
  years: { '2025': { av: 9_000_000, parcels: 12, roll: 12 } },
  pair: { prior: 2025, current: 2026, parcelsBoth: 0, avPriorBoth: 0, avCurrentBoth: 0, newFromZero: 0, avNewFromZero: 0, yoyPct: null },
});

const owners = [abcRaw, only2025Raw].map(mapOwnerPortfolioRow);
annotateOwnerYears(owners, Y);

const basis: OwnerExportBasis = {
  runId: '19153E40-RUN', runDate: new Date(2026, 8, 28, 12, 0), methodologyVersion: 'statewide-v2', scope: 'Statewide',
  county: 'Lake', searchTerm: '', completeOnly: false, filters: ['company owners only'], rowsRead: 9_021,
  sort: ownerSortLabel('avCurrent', -1, Y, 'AV'), years: Y, tierBasis: 'AV', generatedAt: new Date(2026, 8, 28, 23, 30),
  capped: false, capNote: null,
};

/** Build the workbook through the export engine and read it back from its bytes. */
async function roundTrip(sheets: SheetDefinition[]): Promise<ExcelJS.Workbook> {
  const result = await ExportEngine.toExcelMultiSheet(sheets, { fileName: 'test' });
  expect(result.success).toBe(true);
  const wb = new ExcelJS.Workbook();
  await wb.xlsx.load(Buffer.from(result.data as Uint8Array));
  return wb;
}

/** Header name → 1-based column number on a data sheet. */
function columnOf(ws: ExcelJS.Worksheet, header: string): number {
  const values = (ws.getRow(1).values as ExcelJS.CellValue[]).map((v) => (v == null ? '' : String(v)));
  const i = values.indexOf(header);
  expect(i, `header "${header}"`).toBeGreaterThan(0);
  return i;
}

describe('owner export — pure helpers', () => {
  it('percent points → the fraction Excel formats as a percent; null stays null', () => {
    expect(pctFraction(7.7)).toBe(0.077);
    expect(pctFraction(-20)).toBe(-0.2);
    expect(pctFraction(null)).toBeNull();
  });
  it('file names: scope, county or all, run date', () => {
    expect(ownerExportFileName('Statewide', 'lake', new Date(2026, 8, 28))).toBe('owner-prospects_statewide_lake_2026-09-28.xlsx');
    expect(ownerExportFileName('Statewide', 'St. Joseph', new Date(2026, 8, 28))).toBe('owner-prospects_statewide_st-joseph_2026-09-28.xlsx');
    expect(ownerExportFileName('Marion', null, new Date(2026, 8, 28))).toBe('owner-prospects_marion_all_2026-09-28.xlsx');
    expect(parcelExportFileName('Walmart Inc. / Sam’s Club', new Date(2026, 0, 5))).toBe('owner-parcels_walmart-inc-sam-s-club_2026-01-05.xlsx');
    expect(isoDate(null)).toBe('undated');
    expect(slugify('***')).toBe('owner');
  });
  it('primary county: the name, the number when the name is unknown, never blank; the Marion run is Marion', () => {
    expect(primaryCountyName(45, 'Statewide', { 45: 'Lake' })).toBe('Lake');
    expect(primaryCountyName(88, 'Statewide', { 45: 'Lake' })).toBe('88');
    expect(primaryCountyName(null, 'Marion', {})).toBe('Marion');
  });
  it('sort words name the column and the direction', () => {
    expect(ownerSortLabel('yoyPair', -1, Y, 'AV')).toBe('YoY 2025→2026 (complete owners first), descending');
    expect(ownerSortLabel('avYoYDollars', 1, Y, 'AV')).toBe('YoY $ 2025→2026, ascending');
    expect(ownerSortLabel('tier', 1, Y, 'Savings')).toBe('Savings tier, ascending');
  });
});

describe('owner workbook — read back from the file (Review Focus 3)', () => {
  it('Basis first, then Owners', async () => {
    const wb = await roundTrip(buildOwnerWorkbook(exportRows(owners, Y, 'Statewide'), basis, { 45: 'Lake' }));
    expect(wb.worksheets.map((w) => w.name)).toEqual(['Basis', 'Owners']);
  });

  it('Basis states the run, the filters, the row count, the legend and the CoStar caution', async () => {
    const wb = await roundTrip(buildOwnerWorkbook(exportRows(owners, Y, 'Statewide'), basis, { 45: 'Lake' }));
    const ws = wb.getWorksheet('Basis') as ExcelJS.Worksheet;
    const lines = new Map<string, ExcelJS.CellValue>();
    ws.eachRow((row) => lines.set(String(row.getCell(1).value ?? ''), row.getCell(2).value));
    expect(lines.get('Run ID')).toBe('19153E40-RUN');
    expect(lines.get('Run date')).toBe('2026-09-28');
    expect(lines.get('Methodology')).toBe('statewide-v2');
    expect(lines.get('Scope')).toBe('Statewide');
    expect(lines.get('County')).toBe('Lake');
    expect(lines.get('Search term')).toBe('none');
    expect(lines.get('Complete YoY only')).toBe('off');
    expect(lines.get('Sort')).toBe('AV current, descending');
    expect(lines.get('Rows read (run + county/search)')).toBe(9_021);
    expect(lines.get('Rows written after table filters')).toBe(2);
    expect(lines.get('Filters applied')).toBe('company owners only');
    expect(lines.get('County scope')).toBe(COUNTY_SCOPE_NOTE);
    expect(lines.has('Counties')).toBe(false);
    expect(lines.get('Generated at')).toBe('2026-09-28 23:30');
    for (const [mark, words] of EXPORT_LEGEND) expect(lines.get(mark)).toBe(words);
    expect(lines.get('TBA')).toBe('to be assessed — no figure on the record for the newest year');
    expect(lines.get('CoStar caution')).toBe(COSTAR_CAUTION);
    expect(ws.getCell('A2').font?.bold).toBe(true);
  });

  it('figures are numbers with number formats; a TBA year cell is EMPTY; the words live in the status column', async () => {
    const wb = await roundTrip(buildOwnerWorkbook(exportRows(owners, Y, 'Statewide'), basis, { 45: 'Lake' }));
    const ws = wb.getWorksheet('Owners') as ExcelJS.Worksheet;
    const c = (h: string): number => columnOf(ws, h);
    const abc = ws.getRow(2);
    const tba = ws.getRow(3);

    expect(abc.getCell(c('Owner')).value).toBe('ABC Holdings');
    expect(abc.getCell(c('AV 2025')).type).toBe(ExcelJS.ValueType.Number);
    expect(abc.getCell(c('AV 2025')).value).toBe(1_200_000);
    expect(abc.getCell(c('AV 2026')).value).toBe(1_600_000);
    expect(abc.getCell(c('AV 2026')).numFmt).toBe('#,##0');
    expect(abc.getCell(c('YoY %')).value).toBe(0.1);
    expect(abc.getCell(c('YoY %')).numFmt).toBe('0.0%');
    expect(abc.getCell(c('YoY $ 2025→2026')).value).toBe(100_000);
    expect(abc.getCell(c('YoY $ 2025→2026')).numFmt).toBe('#,##0');
    expect(abc.getCell(c('Assessment status')).value).toBe('2026 assessed: 2 of 3 · roll 2 · 2025 —: 1 parcel');
    expect(abc.getCell(c('Primary county')).value).toBe('Lake');
    expect(abc.getCell(c('Reduction won')).value).toBe(25_000);
    expect(abc.getCell(c('Last appeal year')).value).toBe(2024);
    expect(abc.getCell(c('Last appeal year')).numFmt ?? 'General').not.toBe('#,##0'); // a year is never "2,024"

    // Review Focus 2/3: the 2026 cell of an owner with no 2026 figure is EMPTY — not the text "TBA", not 0.
    expect(tba.getCell(c('AV 2025')).value).toBe(9_000_000);
    expect(tba.getCell(c('AV 2026')).type).toBe(ExcelJS.ValueType.Null);
    expect(tba.getCell(c('YoY %')).type).toBe(ExcelJS.ValueType.Null);
    expect(tba.getCell(c('YoY $ 2025→2026')).type).toBe(ExcelJS.ValueType.Null);
    expect(tba.getCell(c('Assessment status')).value).toBe('2026 TBA (12 parcels)');
    expect(tba.getCell(c('Primary county')).value).toBe('88'); // unknown name → the number, never blank

    // No figure column anywhere carries the gap words.
    for (const h of ['AV 2025', 'AV 2026', 'YoY %', 'YoY $ 2025→2026']) {
      ws.getColumn(c(h)).eachCell((cell, row) => {
        if (row > 1) expect(['TBA', '—']).not.toContain(cell.value);
      });
    }
  });

  it('header row bold and frozen; column widths fitted; the savings header names its Marion-only scope', async () => {
    const wb = await roundTrip(buildOwnerWorkbook(exportRows(owners, Y, 'Statewide'), basis, { 45: 'Lake' }));
    const ws = wb.getWorksheet('Owners') as ExcelJS.Worksheet;
    expect(ws.getRow(1).getCell(1).font?.bold).toBe(true);
    expect(ws.views[0]).toMatchObject({ state: 'frozen', ySplit: 1 });
    // Auto-fit widths: at least the header, at most 52 (the engine's cap of 50 + padding).
    for (let i = 1; i <= ws.columnCount; i++) {
      const w = ws.getColumn(i).width ?? 9; // exceljs omits a width equal to its default (9) on write
      expect(w).toBeGreaterThanOrEqual(Math.min(String(ws.getRow(1).getCell(i).value).length, 50));
      expect(w).toBeLessThanOrEqual(52);
    }
    expect(columnOf(ws, 'Savings at ask (Marion parcels only)')).toBeGreaterThan(0);
    expect(columnOf(ws, 'AV tier')).toBeGreaterThan(0);
  });

  it('Marion scope: the Marion run\'s fixed columns, Savings tier, primary county Marion', async () => {
    const marion = mapOwnerPortfolioRow({
      ID: 'm', OwnerKey: 'acme', Label: 'ACME', Kind: 'Company', Tier: 'Prime', TierBasis: 'Savings', ParcelCount: 4,
      TotalAV2025: 4_000_000, TotalAV2026: 4_200_000, AVYoYDollars: 200_000, AVYoYPct: 5, EstSavingsAtAsk: 51_000,
      RepStatus: 'No rep on record', ByTypeJSON: '{}',
    });
    const b: OwnerExportBasis = { ...basis, scope: 'Marion', county: null, tierBasis: 'Savings', sort: ownerSortLabel('estSavingsAtAsk', -1, Y, 'Savings') };
    const wb = await roundTrip(buildOwnerWorkbook(exportRows([marion], Y, 'Marion'), b, {}));
    const ws = wb.getWorksheet('Owners') as ExcelJS.Worksheet;
    const row = ws.getRow(2);
    expect(row.getCell(columnOf(ws, 'AV 2026')).value).toBe(4_200_000);
    expect(row.getCell(columnOf(ws, 'YoY %')).value).toBe(0.05);
    expect(row.getCell(columnOf(ws, 'Savings at ask')).value).toBe(51_000);
    expect(row.getCell(columnOf(ws, 'Savings tier')).value).toBe('Prime');
    expect(row.getCell(columnOf(ws, 'Primary county')).value).toBe('Marion');
    expect(row.getCell(columnOf(ws, 'Counties')).type).toBe(ExcelJS.ValueType.Null); // stays empty — the Basis says why
    const lines = new Map<string, ExcelJS.CellValue>();
    (wb.getWorksheet('Basis') as ExcelJS.Worksheet).eachRow((r) => lines.set(String(r.getCell(1).value ?? ''), r.getCell(2).value));
    expect(lines.get('Counties')).toBe(MARION_COUNTIES_NOTE);
    expect(lines.has('County scope')).toBe(false); // no county chosen
  });
});

describe('parcel workbook — read back from the file', () => {
  const P = (over: Partial<OwnerParcelRow>): OwnerParcelRow => ({
    id: 'p', gisParcelNumber: '', address: null, typeGroup: null, currentAV: null, av2025: null, av2026: null,
    avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null,
    conf: null, supCount: null, appealed: false, existingRep: null, lastAppealYear: null, ...over,
  });
  const map = mapParcelYearHeadlines([
    { ParcelID: 'A', AssessmentYear: 2025, HeadlineTotalAV: 1_000_000, IsPlaceholder: 0, HeadlineDataSource: 'Marion County property record card' },
    { ParcelID: 'A', AssessmentYear: 2026, HeadlineTotalAV: 1_100_000, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' },
    { ParcelID: 'C', AssessmentYear: 2025, HeadlineTotalAV: 200_000, IsPlaceholder: 0, HeadlineDataSource: null },
  ]);
  const view = buildParcelViewRows([
    P({ id: 'a', parcelId: 'A', parcelNumber: '49-101', address: '1 A St', countyNumber: 49, ask: 900_000, rec: 'Appeal', conf: 'High', estSavingsAtAsk: 4_000, appealed: true, lastAppealYear: 2023 }),
    P({ id: 'c', parcelId: 'C', parcelNumber: '45-303', address: '3 C St', countyNumber: 45 }),
  ], map, Y, { 45: 'Lake', 49: 'Marion' });
  const pBasis: ParcelExportBasis = {
    runId: 'RUN', runDate: new Date(2026, 8, 28), methodologyVersion: 'v2', scope: 'Statewide', owner: 'ABC Holdings',
    ownerKey: 'CO:ABC', ownerParcelCount: 2, capNote: null, sort: 'AV 2026, descending', years: Y, generatedAt: new Date(2026, 8, 28, 23, 0),
  };

  it('Basis then Parcels; roll flags as words beside numeric years; Marion ask / rec / conf; a TBA cell empty', async () => {
    const wb = await roundTrip(buildParcelWorkbook(exportParcelRows(view, Y), pBasis));
    expect(wb.worksheets.map((w) => w.name)).toEqual(['Basis', 'Parcels']);
    const ws = wb.getWorksheet('Parcels') as ExcelJS.Worksheet;
    const c = (h: string): number => columnOf(ws, h);
    const a = ws.getRow(2);
    const tba = ws.getRow(3);
    expect(a.getCell(c('AV 2026')).value).toBe(1_100_000);
    expect(a.getCell(c('2026 roll')).value).toBe('roll');
    expect(a.getCell(c('2025 roll')).type).toBe(ExcelJS.ValueType.Null);
    expect(a.getCell(c('YoY %')).value).toBe(0.1);
    expect(a.getCell(c('YoY %')).numFmt).toBe('0.0%');
    expect(a.getCell(c('YoY $ 2025→2026')).value).toBe(100_000);
    expect(a.getCell(c('Ask')).value).toBe(900_000);
    expect(a.getCell(c('Rec')).value).toBe('Appeal');
    expect(a.getCell(c('Conf')).value).toBe('High');
    expect(a.getCell(c('County')).value).toBe('Marion');
    expect(tba.getCell(c('AV 2026')).type).toBe(ExcelJS.ValueType.Null);
    expect(tba.getCell(c('Assessment status')).value).toBe('2026 TBA');
    expect(tba.getCell(c('Ask')).type).toBe(ExcelJS.ValueType.Null); // outside Marion: no analysis
    const lines = new Map<string, ExcelJS.CellValue>();
    (wb.getWorksheet('Basis') as ExcelJS.Worksheet).eachRow((row) => lines.set(String(row.getCell(1).value ?? ''), row.getCell(2).value));
    expect(lines.get('Owner')).toBe('ABC Holdings');
    expect(lines.get('Sort')).toBe('AV 2026, descending');
    expect(lines.get('Rows')).toBe(2);
    expect(lines.get('CoStar caution')).toBe(COSTAR_CAUTION);
  });
});

// ───── Collection: the page's own filter, keyset pages, the cap ─────

/** A fake RunView over `total` owner rows with ascending IDs, honouring AfterKey + MaxRows like the server. */
function pagedRunView(total: number, failAtCall = -1): { rv: RunView; calls: RunViewParams[] } {
  const ids = Array.from({ length: total }, (_, i) => `00000000-0000-0000-0000-${String(i).padStart(12, '0')}`);
  const calls: RunViewParams[] = [];
  const run = <T>(p: RunViewParams): RunViewResult<T> => {
    calls.push(p);
    if (calls.length - 1 === failAtCall) return { Success: false, Results: [], ErrorMessage: 'boom' } as unknown as RunViewResult<T>;
    if (p.ResultType === 'count_only') return { Success: true, Results: [], RowCount: 0, TotalRowCount: total } as unknown as RunViewResult<T>;
    const after = p.AfterKey?.KeyValuePairs[0]?.Value;
    const start = after == null ? 0 : ids.indexOf(String(after)) + 1;
    const rows = ids.slice(start, start + (p.MaxRows ?? total)).map((id) => ({ ...abcRaw, ID: id }));
    return { Success: true, Results: rows as unknown as T[], RowCount: rows.length, TotalRowCount: rows.length } as RunViewResult<T>;
  };
  const rv = { RunView: async <T>(p: RunViewParams): Promise<RunViewResult<T>> => run<T>(p) };
  return { rv: rv as unknown as RunView, calls };
}

describe('owner export collection', () => {
  it('the filter is the page\'s own (run + county), or the server search\'s when the table shows one', () => {
    expect(OwnerProspectsDataAccess.ExportFilter('RUN', 45, null)).toBe(`RunID = 'RUN' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`);
    expect(OwnerProspectsDataAccess.ExportFilter('RUN', null, "O'Neil")).toBe("RunID = 'RUN' AND Label LIKE '%O''Neil%'");
  });
  it('pages are keyset on ID: no OrderBy, 5,001 rows (the tripwire), simple, narrow Fields; the count is count_only', () => {
    const q = OwnerProspectsDataAccess.ExportPageQuery("RunID = 'RUN'", '00000000-0000-0000-0000-000000000009');
    expect(q.OrderBy).toBeUndefined();
    expect(q.MaxRows).toBe(EXPORT_PAGE_SIZE + 1);
    expect(q.ResultType).toBe('simple');
    expect(q.Fields).toContain('ByCountyJSON');
    expect(q.AfterKey?.KeyValuePairs).toEqual([{ FieldName: 'ID', Value: '00000000-0000-0000-0000-000000000009' }]);
    expect(OwnerProspectsDataAccess.ExportPageQuery('x', null).AfterKey).toBeUndefined();
    const count = OwnerProspectsDataAccess.ExportCountQuery('x');
    expect(count.ResultType).toBe('count_only');
    expect(count.MaxRows).toBe(1);
  });
  it('reads every row across pages until exhausted, reporting progress', async () => {
    const { rv, calls } = pagedRunView(12_345);
    const progress: number[] = [];
    const res = await new OwnerProspectsDataAccess(rv).LoadAllOwners("RunID = 'RUN'", null, (n) => progress.push(n));
    expect(res.ok && res.rows.length).toBe(12_345);
    expect(res.ok && res.capHit).toBe(false);
    expect(new Set(res.ok ? res.rows.map((r) => r.id) : []).size).toBe(12_345); // no row twice, none skipped
    expect(calls.length).toBe(3);
    expect(progress).toEqual([5000, 10_000, 12_345]);
  });
  it('an exact multiple of the page size ends on the tripwire, not an extra empty page', async () => {
    const { rv, calls } = pagedRunView(10_000);
    const res = await new OwnerProspectsDataAccess(rv).LoadAllOwners('x', null);
    expect(res.ok && res.rows.length).toBe(10_000);
    expect(calls.length).toBe(2);
  });
  it('stops at the cap and says so', async () => {
    const { rv } = pagedRunView(EXPORT_ROW_CAP + 7);
    const res = await new OwnerProspectsDataAccess(rv).LoadAllOwners('x', null);
    expect(res.ok && res.rows.length).toBe(EXPORT_ROW_CAP);
    expect(res.ok && res.capHit).toBe(true);
  });
  it('a failed page fails the export — never a partial workbook', async () => {
    const { rv } = pagedRunView(12_000, 1);
    const res = await new OwnerProspectsDataAccess(rv).LoadAllOwners('x', null);
    expect(res.ok).toBe(false);
  });
  it('CountOwners reads TotalRowCount', async () => {
    const { rv } = pagedRunView(38_412);
    expect(await new OwnerProspectsDataAccess(rv).CountOwners('x')).toEqual({ ok: true, count: 38_412 });
  });
});

describe('fix round 1 — the confirm and the Basis name the filters; read vs written', () => {
  const state = (over: Partial<TableFilterState> = {}): TableFilterState => ({
    scope: 'Statewide', completeOnly: false, searchTerm: '', tier: 'all', tierHeader: 'AV tier', rep: '', hasAppealHistory: false,
    typeGroup: '', minOppPerYear: 0, ...over,
  });
  it('tableFilterWords lists exactly the filters in force', () => {
    expect(tableFilterWords(state())).toEqual(['company owners only']);
    expect(tableFilterWords(state({ completeOnly: true, searchTerm: ' acme ', tier: 'A', rep: 'none', hasAppealHistory: true, typeGroup: 'Retail' }))).toEqual([
      'company owners only', 'Complete YoY only', 'search “acme” (owner or rep)', 'AV tier: A', 'no rep on record', 'has an appealed parcel', 'dominant type: Retail',
    ]);
    // Complete-only is Statewide; the opportunity floor is Marion.
    expect(tableFilterWords(state({ scope: 'Marion', completeOnly: true, minOppPerYear: 50_000, tierHeader: 'Savings tier' }))).toEqual(['company owners only', 'opportunity ≥ $50,000/yr']);
    expect(tableFilterWords(state({ minOppPerYear: 50_000 }))).toEqual(['company owners only']);
  });
  it('readFilterWords names the server clause', () => {
    expect(readFilterWords('Lake', null)).toBe('the Lake county filter');
    expect(readFilterWords(null, 'acme')).toBe('the “acme” search filter');
    expect(readFilterWords('Lake', 'acme')).toBe('the Lake county and “acme” search filter');
    expect(readFilterWords(null, null)).toBe('no county or search filter (all counties)');
  });
  it('exportConfirmText: pre-filter count as a read-cost warning, the filters listed, a neutral "Read N rows"', () => {
    const t = exportConfirmText(109_346, readFilterWords(null, null), ['company owners only', 'Complete YoY only'], 150_000);
    expect(t.message).toBe("109,346 owners on this run match no county or search filter (all counties) and will be read; the table's filters are applied after reading: company owners only, Complete YoY only.");
    expect(t.detail).toContain('read-cost warning on the pre-filter count');
    expect(t.confirmText).toBe('Read 109,346 rows');
    expect(exportConfirmText(160_000, 'x', ['company owners only'], 150_000).detail).toContain('Only the first 150,000 will be read');
  });
});
