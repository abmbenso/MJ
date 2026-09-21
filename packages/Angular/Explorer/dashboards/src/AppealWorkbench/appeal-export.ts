/**
 * Assembles a subset of one analysis's own tabs into a single, clean, self-contained printable
 * document -- the same mechanism already shipped for Tax Bill Projection
 * (TaxBillProjection/tax-bill-export.ts): a pure model builder, a pure HTML renderer with
 * inline CSS and print rules, opened via Blob + window.open, printed to PDF through the
 * browser's own engine. No PDF library. Pure; no Angular, no MJ.
 *
 * 🚨 Provenance travels with the numbers. A report carrying a figure and no assumptions is a
 * claim with its reasoning removed. Every AppealAnalysisAssumption row included in a printed
 * section with Source = 'Analyst' produces one line in analystEditedWarnings, rendered as a
 * leading banner -- the same treatment tax-bill-export.ts gives a hand-edited bill line.
 */
import { AnalysisRow, AssumptionRow, CompMemberRow, IBTRRow, MARION_COUNTY_NUMBER, PTABOARow, SubjectBundle } from './analysis-store';
import { Approach, COMMERCIAL_CAP, estimateSavings, IndicationStatus } from './appeal-rules';
import { SalesCompResult } from './sales-approach';
import { buildAssessmentSummary } from './sections/assessment-summary';
import { compsIndication } from './sections/comps-indication';

export type PrintSection = 'Cover' | 'Sales' | 'Income' | 'AssessmentComps' | 'Cost' | 'Tax' | 'Decisions';

export interface ReportRow {
  label: string;
  value: string;
  note?: string;
}
export interface ReportTable {
  columns: string[];
  rows: string[][];
}
export interface SectionContent {
  title: string;
  rows?: ReportRow[];
  table?: ReportTable;
  /** A second, independently-headed table. Cover is the only section that currently needs one (property facts / assessment history / valuation conclusion read as three distinct blocks). */
  secondaryTable?: ReportTable;
  secondaryTableTitle?: string;
  notes?: string[];
}

export interface AppealExportInput {
  subject: SubjectBundle;
  analysis: AnalysisRow;
  assumptions: AssumptionRow[];
  indications: IndicationRow[];
  salesResults: SalesCompResult[];
  includedSaleTransactionIds: Set<string>;
  generatedAt: Date;
}

export interface AppealExportModel {
  title: string;
  subtitle: string;
  sections: Partial<Record<PrintSection, SectionContent>>; // absent key = no data, never rendered
  analystEditedWarnings: string[];
  footnotes: string[];
}

/**
 * analysis-store.ts's own IndicationRow (uppercase fields, `Approach`/`Status` etc.) genuinely
 * conflicts with appeal-rules.ts's DIFFERENT IndicationRow (lowercase fields, extends
 * Indication) -- the two are not interchangeable, so this shape is declared locally rather than
 * importing either. `Approach` and `IndicationStatus` themselves don't conflict between the two
 * files, so those ARE imported above from appeal-rules.ts rather than re-declared.
 */
interface IndicationRow {
  ID: string;
  AppealAnalysisID: string;
  Approach: Approach;
  IndicatedValue: number | null;
  PerUnit: number | null;
  PctOfAV: number | null;
  Credible: boolean;
  Supports: boolean;
  Status: IndicationStatus;
  Rationale: string | null;
  ComputedAt: string | null;
}

const APPROACH_LABEL: Record<string, string> = {
  Income: 'Income (market)',
  Sales: 'Sales comparison',
  AssessmentComps: 'Assessment comps',
  Cost: 'Cost',
  ActualIE: 'Actual income & expenses',
};
const APPROACH_ORDER: Approach[] = ['Income', 'Sales', 'AssessmentComps', 'Cost', 'ActualIE'];

/** Only a handful of county numbers are in scope for this practice today -- extend as counties are onboarded. */
const COUNTY_NAMES: Record<number, string> = { [MARION_COUNTY_NUMBER]: 'Marion' };
const countyLabel = (n: number | null): string => (n != null ? (COUNTY_NAMES[n] ?? `County ${n}`) : 'Unknown county');

const isoDay = (d: Date): string => d.toISOString().slice(0, 10);
const pct = (v: number | null): string => (v == null ? '—' : `${(v * 100).toFixed(1)}%`);
const usd0 = (v: number | null): string => (v == null ? '—' : v.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }));
const num = (v: number | null, digits = 0): string =>
  v == null ? '—' : v.toLocaleString('en-US', { maximumFractionDigits: digits, minimumFractionDigits: digits });
const yn = (v: boolean | null): string => (v == null ? '—' : v ? 'Yes' : 'No');

/** A comp's GIS parcel number and address in place of its raw GUID -- mirrors AnalysisDecisionsComponent/AnalysisAssessmentCompsComponent's own compLabel. */
function compLabel(subject: SubjectBundle, id: string): string {
  const p = subject.memberParcels[id];
  if (!p || (p.GISParcelNumber == null && p.Address == null)) return id;
  return [p.GISParcelNumber, p.Address].filter((x): x is string => x != null).join(' — ');
}

/**
 * Fix 4 (final whole-plan review): the Sales section's own comp table was printing the raw
 * SaleTransactionID GUID in the "Comp" column instead of an address -- the same defect class the
 * user caught once already in Plan 1. Same label style as `compLabel` above, but joined against
 * `subject.comps` (Sales' own comp list, which carries CompAddress/CompSubmarket directly) rather
 * than `memberParcels` (the Assessment Comps join table, keyed by ComparableParcelID) -- Sales
 * comps are `ValuationCompRow`s keyed by SaleTransactionID, not comparable parcels.
 */
function salesCompLabel(subject: SubjectBundle, saleTransactionId: string): string {
  const c = subject.comps.find((x) => x.SaleTransactionID === saleTransactionId);
  if (!c || (c.CompAddress == null && c.CompSubmarket == null)) return saleTransactionId;
  return [c.CompAddress, c.CompSubmarket].filter((x): x is string => x != null).join(' — ');
}

/**
 * Three clearly separated blocks on paper: property facts (`rows`), the assessment history
 * (`secondaryTable`, a genuine Year | Original AV | Final AV | % Change comparison a reader
 * scans across -- not flattened into label/value lines), and the valuation conclusion (the
 * indication ladder, as the primary `table` -- the number every reader turns to first).
 */
function buildCoverSection(input: AppealExportInput): SectionContent | null {
  const { subject, analysis, indications } = input;
  const rows: ReportRow[] = [];
  rows.push({ label: 'Parcel', value: subject.parcel.ParcelNumber });
  rows.push({ label: 'Address', value: subject.parcel.Address ?? '—' });
  rows.push({ label: 'County', value: countyLabel(subject.parcel.CountyNumber) });
  rows.push({ label: 'Property type', value: subject.typeGroup });
  const denom =
    subject.record?.ComparisonUnitType === 'Unit'
      ? `${num(subject.record.ComparisonUnitCount)} units`
      : subject.record?.EstimatedSqFt != null
        ? `${num(subject.record.EstimatedSqFt)} SF`
        : '—';
  rows.push({ label: 'Size', value: denom });
  rows.push({ label: 'Year built', value: subject.record?.YearBuilt != null ? String(subject.record.YearBuilt) : '—' });

  const y = analysis.AssessmentYear;
  const summary = buildAssessmentSummary(subject.assessments, [y - 2, y - 1, y]);
  const assessmentTable: ReportTable = {
    columns: ['Year', 'Original AV', 'Final AV', '% Change'],
    rows: summary.map((s) => [String(s.year), usd0(s.original), usd0(s.final), pct(s.changePct)]),
  };

  rows.push({ label: 'Floor value', value: usd0(analysis.FloorValue), note: analysis.FloorApproach ?? undefined });
  rows.push({ label: 'Requested (ask) value', value: usd0(analysis.RequestedValue), note: analysis.RequestedValueApproach ?? undefined });
  rows.push({ label: 'Recommendation', value: analysis.Recommendation ?? '—' });
  rows.push({
    label: 'Estimated tax savings',
    value: usd0(analysis.EstimatedTaxSavings),
    note: analysis.SavingsRate != null ? `${pct(analysis.SavingsRate)} rate` : undefined,
  });
  rows.push({ label: 'Burden on assessor (IC 6-1.1-15-17.2)', value: yn(analysis.BurdenOnAssessor) });

  const ladder = [...indications].sort((a, b) => APPROACH_ORDER.indexOf(a.Approach) - APPROACH_ORDER.indexOf(b.Approach));
  const ladderTable: ReportTable = {
    columns: ['Approach', 'Indicated value', '% of AV', 'Credible', 'Supports', 'Role'],
    rows: ladder.map((row) => {
      const role = analysis.RequestedValueApproach === row.Approach ? 'Ask' : analysis.FloorApproach === row.Approach ? 'Floor' : '';
      return [
        APPROACH_LABEL[row.Approach] ?? row.Approach,
        row.Status === 'Computed' ? usd0(row.IndicatedValue) : row.Status,
        pct(row.PctOfAV),
        yn(row.Credible),
        yn(row.Supports),
        role,
      ];
    }),
  };

  const notes: string[] = [];
  if (analysis.Comments) notes.push(`Comments: ${analysis.Comments}`);

  return { title: 'Cover', rows, secondaryTable: assessmentTable, secondaryTableTitle: 'Assessment History', table: ladderTable, notes };
}

/** Formats one Sales-section assumption row (a coefficient) as a single readable clause. */
function coefficientsNote(assumptions: AssumptionRow[]): string {
  const rows = assumptions.filter((a) => a.Section === 'Sales').sort((a, b) => a.SortOrder - b.SortOrder);
  if (!rows.length) return 'No coefficients on file for this analysis.';
  const parts = rows.map((r) => `${r.Label} ${r.Value ?? '—'}${r.Unit ? ` ${r.Unit}` : ''}`);
  return `Coefficients: ${parts.join(' · ')}`;
}

function buildSalesSection(input: AppealExportInput): SectionContent | null {
  const included = input.salesResults.filter((r) => input.includedSaleTransactionIds.has(r.id));
  if (!included.length) return null;
  return {
    title: 'Comparable Sales',
    table: {
      columns: ['Comp', 'Raw $/unit', 'Size', 'Age', 'Grade', 'Time', 'Net', 'Gross', 'Adjusted $/unit'],
      rows: included.map((r) => [
        salesCompLabel(input.subject, r.id),
        r.rawPerUnit.toFixed(2),
        pct(r.sizeAdjPct),
        pct(r.ageAdjPct),
        pct(r.gradeAdjPct),
        pct(r.timeAdjPct),
        pct(r.netAdjPct),
        pct(r.grossAdjPct),
        r.adjustedPerUnit.toFixed(2),
      ]),
    },
    notes: [coefficientsNote(input.assumptions), 'Included, decided comps only -- not the full candidate pool.'],
  };
}

function buildIncomeSection(input: AppealExportInput): SectionContent | null {
  const rows = input.assumptions.filter((a) => a.Section === 'Income').sort((a, b) => a.SortOrder - b.SortOrder);
  const indication = input.indications.find((i) => i.Approach === 'Income');
  if (!rows.length && (!indication || indication.Status !== 'Computed')) return null;
  const table: ReportTable = {
    columns: ['Line', 'Value', 'Unit', 'Source'],
    rows: rows.map((r) => [
      r.Label,
      // Fix 7 (final whole-plan review): the ternary's two branches were both `2` -- dead code that
      // masked a real bug, a %/pct-unit row (e.g. a 0.0775 cap rate) printed its raw decimal instead
      // of a percentage. `pct()` is this file's own existing percent formatter (used throughout Cover/
      // Sales/Tax above), so a %/pct row uses it here too, rather than `num()`'s plain-decimal format.
      r.Value == null ? '—' : r.Unit === '%' || r.Unit === 'pct' ? pct(r.Value) : num(r.Value, 2),
      r.Unit ?? '',
      r.SourceRef ? `${r.Source} (${r.SourceRef})` : r.Source,
    ]),
  };
  const notes: string[] = [];
  if (indication) {
    notes.push(
      indication.Status === 'Computed'
        ? `Indicated value: ${usd0(indication.IndicatedValue)} (${pct(indication.PctOfAV)} of current AV)`
        : `Indicated value: ${indication.Status}`,
    );
    if (indication.Rationale) notes.push(indication.Rationale);
  }
  return { title: 'Income Analysis', table, notes };
}

function buildAssessmentCompsSection(input: AppealExportInput): SectionContent | null {
  const { subject, analysis } = input;
  if (!subject.compSet && !subject.compMembers.length) return null;
  const indication = compsIndication(subject.compSet, analysis.SubjectDenominator, analysis.UnitOfComparison);
  const rows: ReportRow[] = [
    { label: 'Indicated value', value: usd0(indication.value), note: indication.basis },
    { label: 'Track', value: subject.compSet?.HeadlineTrack ?? '—' },
    {
      label: 'Subject per-unit (effective)',
      value: subject.compSet?.SubjectPerUnitEffective != null ? `${num(subject.compSet.SubjectPerUnitEffective, 2)} ${subject.compSet.UnitOfComparison}` : '—',
    },
    {
      label: 'Neighborhood median',
      value:
        subject.compSet?.NeighborhoodMedianPerUnit != null
          ? `${num(subject.compSet.NeighborhoodMedianPerUnit, 2)} ${subject.compSet.UnitOfComparison} (${subject.compSet.NeighborhoodCompCount ?? 0} comps)`
          : '—',
    },
    {
      label: 'County median',
      value:
        subject.compSet?.CountyMedianPerUnit != null
          ? `${num(subject.compSet.CountyMedianPerUnit, 2)} ${subject.compSet.UnitOfComparison} (${subject.compSet.CountyCompCount ?? 0} comps)`
          : '—',
    },
  ];
  const memberRow = (m: CompMemberRow): string[] => [
    compLabel(subject, m.ComparableParcelID),
    num(m.ComparableBuildingSqFt),
    m.ComparableGradeCode ?? '',
    usd0(m.OriginalAV),
    m.AppealedAV == null ? '—' : usd0(m.AppealedAV),
    m.AppealLevel ?? '',
    m.AppealPctChange == null ? '' : `${m.AppealPctChange}%`,
    m.AppealRepresentative ?? '',
    num(m.EffectivePerUnit, 2),
    num(m.SimilarityScore, 2),
  ];
  const columns = ['Comp parcel', 'SF', 'Grade', 'Original AV', 'Appealed AV', 'Level', '% chg', 'Representative', 'Effective /unit', 'Score'];
  const neighborhood = subject.compMembers.filter((m) => m.GeographyBucket === 'Neighborhood').sort((a, b) => (a.SortOrder ?? 0) - (b.SortOrder ?? 0));
  const county = subject.compMembers.filter((m) => m.GeographyBucket === 'County').sort((a, b) => (a.SortOrder ?? 0) - (b.SortOrder ?? 0));
  const table: ReportTable = {
    columns: ['Bucket', ...columns],
    rows: [...neighborhood.map((m) => ['Neighborhood', ...memberRow(m)]), ...county.map((m) => ['County', ...memberRow(m)])],
  };
  return { title: 'Assessment Comps', rows, table, notes: ['Appeal status travels with every comparable -- the batch selection is shown.'] };
}

function buildCostSection(input: AppealExportInput): SectionContent | null {
  const v = input.subject.valuation;
  if (!v || v.CostProxyValue == null) return null;
  return {
    title: 'Cost Analysis',
    rows: [{ label: 'Cost proxy value', value: usd0(v.CostProxyValue) }],
    notes: [
      v.CostProxyNote ?? "The county's own replacement-cost figure from the record card, less its depreciation, plus land.",
      'A sanity anchor, never the argument: a cost figure above the assessment does not support an appeal.',
    ],
  };
}

function buildTaxSection(input: AppealExportInput): SectionContent | null {
  const { analysis, subject } = input;
  const taxRate = subject.record?.TaxRate ?? null;
  if (analysis.CurrentTotalAV == null || taxRate == null) return null;
  const atAsk = estimateSavings(analysis.CurrentTotalAV, analysis.RequestedValue, taxRate, COMMERCIAL_CAP, null);
  const atFloor = estimateSavings(analysis.CurrentTotalAV, analysis.FloorValue, taxRate, COMMERCIAL_CAP, null);
  const basisNote = (b: 'cap' | 'rate' | null): string => (b === 'cap' ? 'cap-bound (circuit breaker)' : b === 'rate' ? 'rate-bound' : '—');
  return {
    title: 'Tax',
    rows: [
      { label: 'Estimated saving at ask', value: usd0(atAsk.savings), note: `${pct(atAsk.rate)} marginal rate, ${basisNote(atAsk.basis)}` },
      { label: 'Estimated saving at floor', value: usd0(atFloor.savings), note: `${pct(atFloor.rate)} marginal rate, ${basisNote(atFloor.basis)}` },
      { label: 'District tax rate', value: `${num(taxRate, 4)} per $100` },
    ],
    notes: [
      'The circuit breaker is a rate modifier, not a gate: min(district rate, commercial cap + referendum). No referendum rate is carried in the subject bundle, so referendum relief is not reflected above.',
    ],
  };
}

function buildDecisionsSection(input: AppealExportInput): SectionContent | null {
  const { subject } = input;
  if (!subject.ptaboa.length && !subject.ibtr.length) return null;
  const notes: string[] = [];
  const ptaboaTable: string[][] = subject.ptaboa.map((p: PTABOARow) => [p.HearingDate ?? '—', p.DecisionStatus ?? '—', p.Circumstances ?? '']);
  const ibtrTable: string[][] = subject.ibtr.map((i: IBTRRow) => [
    i.PetitionNumber,
    i.DecisionDate ?? '—',
    i.DispositionType,
    i.AppealType ?? '',
    i.UseCategory ?? '',
  ]);
  const compOutcomes = subject.compMembers.filter((m) => m.AppealedAV != null || m.AppealLevel);
  const table: ReportTable = {
    columns: ['Kind', 'Reference', 'Date', 'Status/Disposition', 'Detail'],
    rows: [
      ...ptaboaTable.map((r) => ['Subject PTABOA', '—', r[0], r[1], r[2]]),
      ...ibtrTable.map((r) => ['Subject IBTR', r[0], r[1], r[2], r[3]]),
      ...compOutcomes.map((m) => [
        'Comp outcome',
        compLabel(subject, m.ComparableParcelID),
        '',
        m.AppealLevel ?? '',
        `${m.AppealPctChange == null ? '' : `${m.AppealPctChange}% `}${m.AppealRepresentative ?? ''}`.trim(),
      ]),
    ],
  };
  if (!subject.ptaboa.length) notes.push('No subject PTABOA history on file.');
  if (!subject.ibtr.length) notes.push('No subject IBTR history on file.');
  return { title: 'Decisions', table, notes };
}

const SECTION_BUILDERS: Record<PrintSection, (input: AppealExportInput) => SectionContent | null> = {
  Cover: buildCoverSection,
  Sales: buildSalesSection,
  Income: buildIncomeSection,
  AssessmentComps: buildAssessmentCompsSection,
  Cost: buildCostSection,
  Tax: buildTaxSection,
  Decisions: buildDecisionsSection,
};

const SECTION_ORDER: PrintSection[] = ['Cover', 'Sales', 'Income', 'AssessmentComps', 'Cost', 'Tax', 'Decisions'];

const EDITED_WARNING = (a: AssumptionRow): string =>
  `⚠ ${a.Label} (${a.Section}) was hand-edited by the analyst${a.SourceRef ? ` — ${a.SourceRef}` : ''}. That figure is the analyst's own judgment, not the county's or the market's.`;

/** Assembles everything both the model and the renderer need, once. */
export function buildAppealExport(input: AppealExportInput): AppealExportModel {
  const sections: Partial<Record<PrintSection, SectionContent>> = {};
  for (const key of SECTION_ORDER) {
    const content = SECTION_BUILDERS[key](input);
    if (content) sections[key] = content;
  }
  const address = input.subject.parcel.Address ?? input.subject.parcel.ParcelNumber;
  return {
    title: `Analyze a Property — ${address}`,
    subtitle: `Parcel ${input.subject.parcel.ParcelNumber} · ${countyLabel(input.subject.parcel.CountyNumber)} County · ${input.analysis.AssessmentYear} · generated ${isoDay(input.generatedAt)}`,
    sections,
    analystEditedWarnings: input.assumptions.filter((a) => a.Source === 'Analyst').map(EDITED_WARNING),
    footnotes: [
      'Every figure in this report is a stored row from the analysis or the output of one pure function over stored rows -- none are re-derived for print.',
    ],
  };
}

/* ===========================================================================
 * PRINTABLE REPORT
 *
 * A self-contained HTML document: inline styles, no network fetches, no scripts beyond the
 * Print button. It has to render identically offline, from a saved attachment, years later.
 * Ported directly from TaxBillProjection/tax-bill-export.ts's DOC_CSS structure.
 * =========================================================================== */

const INK = '#0b0b0b';
const INK_SOFT = '#52514e';
const GRID = '#e4e3df';
const SURFACE = '#ffffff';

export function escapeHtml(s: string): string {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

/**
 * Fix 3 (final whole-plan review): `LANDSCAPE_SECTIONS`/`wide` (below) existed with a comment
 * promising landscape "like the Tax Bill schedule," but the `@page` rule was hardcoded `letter
 * portrait` regardless -- `wide` only ever affected the on-screen `.sheet` max-width, which
 * `window.print()` doesn't consult. `DOC_CSS` is now a function of the same `landscape` flag
 * `exportToDocument` already computes as `wide`, mirroring how tax-bill-export.ts's own DOC_CSS
 * hardcodes `landscape` for its always-landscape bill schedule -- here the printed set of
 * sections varies, so the orientation has to be computed per-document instead of baked in once.
 */
function buildDocCss(landscape: boolean): string {
  return `
:root { --ink:${INK}; --soft:${INK_SOFT}; --grid:${GRID}; --surface:${SURFACE}; }
* { box-sizing: border-box; }
body { margin:0; background:#f4f4f2; color:var(--ink);
  font: 13px/1.45 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
.sheet { max-width: 8.5in; margin: 24px auto; padding: 40px 44px 48px; background: var(--surface);
  box-shadow: 0 1px 3px rgba(0,0,0,.12); }
.sheet.wide { max-width: 11in; }
h1 { font-size: 19px; margin: 0 0 4px; letter-spacing: -0.01em; }
.sub { color: var(--soft); font-size: 12px; margin: 0 0 22px; }
h2 { font-size: 12px; text-transform: uppercase; letter-spacing: .07em; color: var(--soft);
  margin: 28px 0 10px; padding-bottom: 5px; border-bottom: 1px solid var(--grid); page-break-after: avoid; }
h3 { font-size: 11px; font-weight: 600; color: var(--ink); margin: 14px 0 6px; page-break-after: avoid; }
.warn { border:1px solid #e0b94e; border-left:4px solid #e0b94e; background:#fdf7e6;
  padding:11px 14px; margin:0 0 10px; font-size:12.5px; }
.warn strong { display:block; margin-bottom:2px; }
dl.rows { display:grid; grid-template-columns: max-content 1fr; column-gap:14px; row-gap:4px; margin:0 0 12px; font-size:12.5px; }
dl.rows dt { color:var(--soft); }
dl.rows dd { margin:0; font-variant-numeric: tabular-nums; }
dl.rows dd .note { color:var(--soft); font-size:11px; margin-left:6px; }
table { width:100%; border-collapse:collapse; font-variant-numeric: tabular-nums; font-size:11.5px; margin:0 0 10px; }
th, td { padding:5px 8px; text-align:right; white-space:nowrap; }
th:first-child, td:first-child { text-align:left; white-space:normal; }
thead th { font-size:10.5px; color:var(--soft); font-weight:600; border-bottom:1px solid var(--grid); }
.notes p { margin:0 0 6px; font-size:10.5px; color:var(--soft); line-height:1.5; }
.toolbar { max-width:8.5in; margin:16px auto 0; text-align:right; }
.toolbar button { font:inherit; padding:7px 15px; border:1px solid var(--grid);
  background:#fff; border-radius:6px; cursor:pointer; }
@media print {
  body { background:#fff; }
  .sheet { box-shadow:none; margin:0; max-width:none; padding:0; }
  .toolbar { display:none; }
  h2, h3 { break-after:avoid; }
  table, dl.rows { break-inside:avoid; }
}
@page { size: letter ${landscape ? 'landscape' : 'portrait'}; margin: 0.5in; }
* { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
`;
}

/** The Sales adjustment grid runs one column per comp characteristic -- landscape, like the Tax Bill schedule. */
const LANDSCAPE_SECTIONS: Set<PrintSection> = new Set(['Sales']);

function rowsHtml(rows: ReportRow[]): string {
  const out: string[] = ['<dl class="rows">'];
  for (const r of rows) {
    out.push(`<dt>${escapeHtml(r.label)}</dt><dd>${escapeHtml(r.value)}${r.note ? `<span class="note">${escapeHtml(r.note)}</span>` : ''}</dd>`);
  }
  out.push('</dl>');
  return out.join('');
}

function tableHtml(t: ReportTable): string {
  const out: string[] = ['<table><thead><tr>'];
  for (const c of t.columns) out.push(`<th>${escapeHtml(c)}</th>`);
  out.push('</tr></thead><tbody>');
  for (const row of t.rows) {
    out.push('<tr>');
    for (const cell of row) out.push(`<td>${escapeHtml(cell)}</td>`);
    out.push('</tr>');
  }
  out.push('</tbody></table>');
  return out.join('');
}

function sectionHtml(key: PrintSection, content: SectionContent): string {
  const out: string[] = [`<h2>${escapeHtml(content.title)}</h2>`];
  if (content.rows?.length) out.push(rowsHtml(content.rows));
  if (content.secondaryTable?.rows.length) {
    if (content.secondaryTableTitle) out.push(`<h3>${escapeHtml(content.secondaryTableTitle)}</h3>`);
    out.push(tableHtml(content.secondaryTable));
  }
  if (content.table?.rows.length) out.push(tableHtml(content.table));
  if (content.notes?.length) {
    out.push('<div class="notes">');
    for (const n of content.notes) out.push(`<p>${escapeHtml(n)}</p>`);
    out.push('</div>');
  }
  return out.join('');
}

/**
 * Renders only sections both present in the model (non-null) AND requested in `include`, in
 * the fixed Cover/Sales/Income/AssessmentComps/Cost/Tax/Decisions order. The analyst-edited
 * warning banner leads -- before any section content -- exactly where tax-bill-export.ts's own
 * warning banner sits.
 */
export function exportToDocument(m: AppealExportModel, include: Set<PrintSection>): string {
  const requested = SECTION_ORDER.filter((key) => include.has(key) && m.sections[key]);
  const wide = requested.some((key) => LANDSCAPE_SECTIONS.has(key));

  const out: string[] = [
    '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
    `<title>${escapeHtml(m.title)}</title>`,
    `<style>${buildDocCss(wide)}</style></head><body>`,
    '<div class="toolbar"><button type="button" onclick="window.print()">Print / Save as PDF</button></div>',
    `<div class="sheet${wide ? ' wide' : ''}">`,
    `<h1>${escapeHtml(m.title)}</h1>`,
    `<p class="sub">${escapeHtml(m.subtitle)}</p>`,
  ];

  for (const w of m.analystEditedWarnings) {
    out.push(`<div class="warn"><strong>Hand-edited by the analyst</strong>${escapeHtml(w.replace(/^⚠\s*/, ''))}</div>`);
  }

  for (const key of requested) out.push(sectionHtml(key, m.sections[key] as SectionContent));

  if (m.footnotes.length) {
    out.push('<div class="notes">');
    for (const f of m.footnotes) out.push(`<p>${escapeHtml(f)}</p>`);
    out.push('</div>');
  }

  out.push('</div></body></html>');
  return out.join('');
}
