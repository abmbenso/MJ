/**
 * Taking a projection out of the tool.
 *
 * Two destinations, ONE model: a clipboard paste for writing prose, and a workbook for
 * people who would rather work in a grid. Both render from the same `BillExportModel`, so
 * an export can never quietly disagree with the screen or with the other format.
 *
 * This file is PURE -- no Angular, no clipboard, no file writing. The component owns those
 * side effects; everything decided here is testable.
 *
 * 🚨 The warnings travel. A projection whose bill lines were hand-edited is the READER'S
 * model, not the parcel's filed bill, and it must never leave this tool looking like the
 * latter. Every renderer below carries the calibration footnote, the provenance legend and
 * any edited-bill warning.
 */

import { SheetDefinition, CellStyleOverride, ExportData } from '@memberjunction/export-engine';
import { ScenarioName, ScenarioState } from '../TaxBudgetProjection/tax-budget-projection-types';
import { VerificationLink } from '../TaxBudgetProjection/marion-verification';
import { BillAssumptions, BillColumn, BillRow, buildBillGrid } from './tax-bill-view-model';

/** One scenario's fully-computed projection, as the component holds it. */
export interface ExportScenario {
  scenario: ScenarioName;
  label: string;
  /** True when this scenario's bill lines were edited away from the parcel's calibration. */
  edited: boolean;
  columns: BillColumn[];
  assumptions: ScenarioState;
  bill: BillAssumptions;
}

export interface ExportCalibration {
  years: number;
  deductionRatio: number;
  uplift: number;
  upliftSource: 'parcel' | 'district';
  capClass: string | null;
  capRate: number;
}

export interface BillExportInput {
  parcelNumber: string;
  address: string;
  county: string;
  generatedAt: Date;
  activeScenario: ScenarioName;
  scenarios: ExportScenario[];
  calibration: ExportCalibration | null;
  /** Routes back to the county's own documents. Travels with every export. */
  verification?: VerificationLink[];
}

export interface ExportBill {
  scenario: ScenarioName;
  label: string;
  edited: boolean;
  columns: BillColumn[];
  rows: BillRow[];
  /** Carried through so the workbook can state what produced these numbers. */
  assumptions: ScenarioState;
  bill: BillAssumptions;
}

export interface ExportSummary {
  yearLabels: string[];
  rows: { label: string; values: (number | null)[] }[];
}

export interface BillExportModel {
  title: string;
  subtitle: string;
  activeScenario: ScenarioName;
  bills: ExportBill[];
  summary: ExportSummary;
  legend: string;
  footnotes: string[];
  warnings: string[];
  verification: VerificationLink[];
}

export const PROVENANCE_LEGEND = '● actual · ‡ projected · — not available (never assumed to be zero)';

const EDITED_WARNING = (label: string): string =>
  `⚠ Bill lines were hand-edited for ${label}. That projection is your model, not the filed bill — ` +
  `it will not match the figures DLGF has published for this parcel.`;

function isoDay(d: Date): string {
  return d.toISOString().slice(0, 10);
}

/** Assembles everything both renderers need, once. */
export function buildBillExport(input: BillExportInput): BillExportModel {
  const bills: ExportBill[] = input.scenarios.map((s) => ({
    scenario: s.scenario,
    label: s.label,
    edited: s.edited,
    columns: s.columns,
    rows: buildBillGrid(s.columns),
    assumptions: s.assumptions,
    bill: s.bill,
  }));

  return {
    title: `Tax Bill Projection — ${input.address}`,
    subtitle: `Parcel ${input.parcelNumber} · ${input.county} County · TS-1 Table 1 · ` + `generated ${isoDay(input.generatedAt)}`,
    activeScenario: input.activeScenario,
    bills,
    summary: buildSummary(input.scenarios),
    legend: PROVENANCE_LEGEND,
    footnotes: buildFootnotes(input.calibration),
    warnings: input.scenarios.filter((s) => s.edited).map((s) => EDITED_WARNING(s.label)),
    verification: input.verification ?? [],
  };
}

/**
 * Total due by scenario, across PROJECTED years only.
 *
 * The actual years are identical under every scenario -- they are history. Listing them in
 * a scenario comparison would imply they differ, which is exactly the wrong idea to hand
 * someone reading a range.
 */
function buildSummary(scenarios: ExportScenario[]): ExportSummary {
  const first = scenarios[0];
  if (!first) return { yearLabels: [], rows: [] };
  const projected = first.columns.filter((c) => c.isProjected);
  return {
    yearLabels: projected.map((c) => c.label),
    rows: scenarios.map((s) => ({
      label: s.label,
      values: s.columns.filter((c) => c.isProjected).map((c) => c.lines.totalDue.value),
    })),
  };
}

function buildFootnotes(cal: ExportCalibration | null): string[] {
  if (!cal) {
    return ['No filed DLGF bills were available for this parcel, so no bill shape could be calibrated.'];
  }
  const upliftNote =
    cal.upliftSource === 'parcel' ? 'measured from its own capped years' : 'from a county-wide placeholder, because this parcel has never been capped';
  const notes = [
    `Projected lines use this parcel's own bill shape from its ${cal.years} filed ` +
      `${cal.years === 1 ? 'bill' : 'bills'}: deductions at ${(cal.deductionRatio * 100).toFixed(1)}% of gross AV, ` +
      `and an outside-cap uplift of ${(cal.uplift * 100).toFixed(1)}% ${upliftNote}.`,
    'Line 4a (local property tax credits) is absent from projected columns by design: the uplift above is an ' +
      'effective figure already net of those credits, so projecting a separate 4a would double-count them.',
  ];
  if (cal.capClass) {
    notes.push(
      `Circuit-breaker ceiling (IC 6-1.1-20.6) calibrated to ${(cal.capRate * 100).toFixed(2)}% of gross AV ` + `from this parcel's ${cal.capClass} class mix.`,
    );
  }
  return notes;
}

/* ===========================================================================
 * CLIPBOARD
 * =========================================================================== */

function fmt(row: BillRow, value: number | null): string {
  if (value == null) return '—';
  if (!row.isCurrency) return `${value.toFixed(4)}%`;
  return value.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });
}

function mark(source: 'actual' | 'projected'): string {
  return source === 'actual' ? '●' : '‡';
}

/** Plain-text fallback for editors that take no rich content. */
export function exportToMarkdown(m: BillExportModel): string {
  const active = m.bills.find((b) => b.scenario === m.activeScenario) ?? m.bills[0];
  const out: string[] = [`# ${m.title}`, '', m.subtitle, ''];

  if (active) {
    out.push(`## Bill — ${active.label}`, '');
    out.push(`| Line | | ${active.columns.map((c) => c.label).join(' | ')} |`);
    out.push(`| --- | --- | ${active.columns.map(() => '---:').join(' | ')} |`);
    for (const row of active.rows) {
      const cells = row.figures.map((f) => `${fmt(row, f.value)} ${mark(f.source)}`);
      out.push(`| ${row.tsLine} | ${row.label} | ${cells.join(' | ')} |`);
    }
    out.push('');
  }

  out.push('## Total due by scenario', '');
  out.push(`| Scenario | ${m.summary.yearLabels.join(' | ')} |`);
  out.push(`| --- | ${m.summary.yearLabels.map(() => '---:').join(' | ')} |`);
  for (const r of m.summary.rows) {
    const cells = r.values.map((v) => (v == null ? '—' : v.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 })));
    out.push(`| ${r.label} | ${cells.join(' | ')} |`);
  }

  out.push('', m.legend, '');
  for (const w of m.warnings) out.push(w, '');
  for (const f of m.footnotes) out.push(f, '');
  return out.join('\n').trimEnd() + '\n';
}

export function escapeHtml(s: string): string {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

/**
 * Rich-text flavour. Word and Google Docs turn this into a real, restylable table;
 * pasting Markdown pipes into either would land as literal text and be useless.
 * Styling is INLINE because a pasted fragment carries no stylesheet with it.
 */
export function exportToHtml(m: BillExportModel): string {
  const active = m.bills.find((b) => b.scenario === m.activeScenario) ?? m.bills[0];
  const th = 'style="text-align:right;border-bottom:1px solid #999;padding:2px 6px;"';
  const td = 'style="text-align:right;padding:2px 6px;"';
  const lbl = 'style="text-align:left;padding:2px 6px;"';
  const out: string[] = [`<div><h2>${escapeHtml(m.title)}</h2>`, `<p>${escapeHtml(m.subtitle)}</p>`];

  if (active) {
    out.push(`<h3>Bill — ${escapeHtml(active.label)}</h3>`);
    out.push('<table cellspacing="0" cellpadding="0"><thead><tr>');
    out.push(`<th ${lbl}>Line</th><th ${lbl}></th>`);
    for (const c of active.columns) out.push(`<th ${th}>${escapeHtml(c.label)}</th>`);
    out.push('</tr></thead><tbody>');
    for (const row of active.rows) {
      out.push('<tr>');
      out.push(`<td ${lbl}>${escapeHtml(row.tsLine)}</td><td ${lbl}>${escapeHtml(row.label)}</td>`);
      for (const f of row.figures) out.push(`<td ${td}>${escapeHtml(fmt(row, f.value))} ${mark(f.source)}</td>`);
      out.push('</tr>');
    }
    out.push('</tbody></table>');
  }

  out.push('<h3>Total due by scenario</h3>');
  out.push('<table cellspacing="0" cellpadding="0"><thead><tr>');
  out.push(`<th ${lbl}>Scenario</th>`);
  for (const y of m.summary.yearLabels) out.push(`<th ${th}>${escapeHtml(y)}</th>`);
  out.push('</tr></thead><tbody>');
  for (const r of m.summary.rows) {
    out.push(`<tr><td ${lbl}>${escapeHtml(r.label)}</td>`);
    for (const v of r.values) {
      const text = v == null ? '—' : v.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });
      out.push(`<td ${td}>${escapeHtml(text)}</td>`);
    }
    out.push('</tr>');
  }
  out.push('</tbody></table>');

  out.push(`<p><small>${escapeHtml(m.legend)}</small></p>`);
  for (const w of m.warnings) out.push(`<p><strong>${escapeHtml(w)}</strong></p>`);
  for (const f of m.footnotes) out.push(`<p><small>${escapeHtml(f)}</small></p>`);
  out.push('</div>');
  return out.join('');
}

/* ===========================================================================
 * WORKBOOK
 * =========================================================================== */

/** 0-based column index to a spreadsheet letter: 0 -> A, 25 -> Z, 26 -> AA. */
export function columnLetter(index: number): string {
  let n = index;
  let out = '';
  do {
    out = String.fromCharCode(65 + (n % 26)) + out;
    n = Math.floor(n / 26) - 1;
  } while (n >= 0);
  return out;
}

const PROJECTED_STYLE = { font: { italic: true, color: '808080' } };

/**
 * One sheet per scenario plus a summary and the assumptions.
 *
 * Figures are written as REAL NUMBERS, never as "$716,997" strings -- the entire reason to
 * offer a workbook is that the recipient can do arithmetic on it, and a formatted string is
 * a picture of a number. Provenance therefore rides as a STYLE (projected values in italic
 * grey) with the legend on Summary, rather than as a marker glued into the value.
 */
export function buildSheets(m: BillExportModel): SheetDefinition[] {
  return [summarySheet(m), ...m.bills.map((b) => billSheet(b)), assumptionsSheet(m)];
}

function summarySheet(m: BillExportModel): SheetDefinition {
  const data: unknown[][] = [
    [m.title],
    [m.subtitle],
    [],
    ['Total due by scenario', ...m.summary.yearLabels],
    ...m.summary.rows.map((r) => [r.label, ...r.values]),
    [],
    [m.legend],
  ];
  for (const w of m.warnings) data.push([w]);
  data.push([]);
  if (m.verification.length) {
    data.push(['Verify against the county']);
    for (const v of m.verification) data.push([v.label, v.note, v.url]);
    data.push([]);
  }
  for (const f of m.footnotes) data.push([f]);
  return { name: 'Summary', data: data as ExportData, includeHeaders: false };
}

function billSheet(b: ExportBill): SheetDefinition {
  const header = ['Line', 'Description', ...b.columns.map((c) => c.label)];
  const data: unknown[][] = [header];
  const cellStyles: CellStyleOverride[] = [];

  b.rows.forEach((row, r) => {
    data.push([row.tsLine, row.label, ...row.figures.map((f) => f.value)]);
    row.figures.forEach((f, c) => {
      // +1 for the header row, +1 because spreadsheet rows are 1-based; +2 columns for
      // Line and Description.
      if (f.source === 'projected') {
        cellStyles.push({ cell: `${columnLetter(c + 2)}${r + 2}`, style: PROJECTED_STYLE });
      }
    });
  });

  return {
    name: `Bill — ${b.label}`,
    data: data as ExportData,
    includeHeaders: false,
    cellStyles,
  };
}

/**
 * What produced the numbers, per scenario.
 *
 * A workbook carrying a bill and no assumptions is a claim with its reasoning removed --
 * and these are exactly the values the reader is invited to argue with. Growth rows are
 * stored as fractions and presented as percentages, the same conversion the editor does.
 */
function assumptionsSheet(m: BillExportModel): SheetDefinition {
  const years = m.summary.yearLabels;
  const data: unknown[][] = [['Scenario', 'Assumption', 'Unit', ...years]];

  const pct = (v: number): number => Math.round(v * 100 * 10000) / 10000;

  for (const b of m.bills) {
    data.push([b.label, 'Land growth', '%', ...b.assumptions.land.map(pct)]);
    data.push([b.label, 'Improvement growth', '%', ...b.assumptions.imp.map(pct)]);
    data.push([b.label, 'Tax rate growth', '%', ...b.assumptions.rate.map(pct)]);
    data.push([b.label, 'Deductions (of gross AV)', '%', ...b.bill.deductionPct]);
    data.push([b.label, 'Cap ceiling (of gross AV)', '%', ...b.bill.capRatePct]);
    data.push([b.label, 'Outside-cap uplift', '%', ...b.bill.upliftPct]);
    data.push([b.label, 'Other charges', '$', ...b.bill.otherCharges]);
    if (b.assumptions.override.enabled && b.assumptions.override.value != null) {
      data.push([b.label, `Exact total AV override (projected year ${b.assumptions.override.year})`, '$', b.assumptions.override.value]);
    }
    if (b.edited) data.push([b.label, 'NOTE', '', EDITED_WARNING(b.label)]);
    data.push([]);
  }

  return { name: 'Assumptions', data: data as ExportData, includeHeaders: false };
}

/* ===========================================================================
 * PRINTABLE REPORT
 *
 * A self-contained HTML document: inline styles, inline SVG, no network fetches,
 * no scripts. It has to render identically offline, from an attachment, years later --
 * and it prints to PDF through the browser's own engine, which gives real vector text
 * rather than the blurry raster a JS PDF library produces.
 * =========================================================================== */

/**
 * Categorical slots 1-3 from the validated default palette, in FIXED order
 * (Worst / Most Likely / Best), never cycled.
 *
 * Validated with the palette script (light surface, --pairs all): lightness band,
 * chroma floor, CVD separation (worst ΔE 9.2) and normal-vision floor (worst ΔE 24.0)
 * all PASS. One WARN: aqua sits below 3:1 against the light surface, which OBLIGES
 * visible relief -- so every series is directly labelled AND repeated in the summary
 * table. That relief is a requirement here, not a nicety.
 *
 * Deliberately NOT red/amber/green: status colours are reserved for state, and a
 * red/green pair is the classic colour-vision trap.
 */
const SERIES_COLORS = ['#2a78d6', '#eb6834', '#1baf7a'] as const;

/** Filed years shown in the printed bill. More than this and the table runs off the page. */
const REPORT_ACTUAL_YEARS = 2;
const INK = '#0b0b0b';
const INK_SOFT = '#52514e';
const GRID = '#e4e3df';
const SURFACE = '#ffffff';

export interface ChartPoint {
  x: number;
  y: number;
  label: string;
}

export interface ChartSeries {
  label: string;
  color: string;
  points: ChartPoint[];
}

export interface BillChart {
  actual: ChartSeries;
  scenarios: ChartSeries[];
  yTicks: number[];
  xLabels: string[];
}

/** Clean, evenly-spaced axis values. Guards the flat-series case rather than dividing by zero. */
export function niceTicks(min: number, max: number, count: number): number[] {
  const lo = Math.min(min, max);
  const hi = Math.max(min, max);
  const span = hi - lo || Math.abs(hi) || 1;
  const rawStep = span / Math.max(1, count);
  const mag = Math.pow(10, Math.floor(Math.log10(rawStep)));
  const step = [1, 2, 2.5, 5, 10].map((m) => m * mag).find((s) => s >= rawStep) ?? 10 * mag;
  const start = Math.floor(lo / step) * step;
  const end = Math.ceil(hi / step) * step;
  const out: number[] = [];
  for (let v = start; v <= end + step / 2; v += step) out.push(Math.round(v * 1e6) / 1e6);
  return out.length > 1 ? out : [start, start + step];
}

/**
 * History drawn ONCE, then a line per scenario.
 *
 * The actual years are identical under every scenario -- they are history. Drawing them
 * three times would render three coincident lines and imply the past is uncertain. Each
 * scenario line starts at the last actual point so the fan is continuous.
 */
export function buildChartSeries(m: BillExportModel): BillChart {
  const first = m.bills[0];
  if (!first) return { actual: { label: 'Actual', color: INK, points: [] }, scenarios: [], yTicks: [0, 1], xLabels: [] };

  const allColumns = first.columns;
  const xLabels = allColumns.map((c) => c.label);
  const xOf = (label: string): number => xLabels.indexOf(label);

  const actualCols = allColumns.filter((c) => !c.isProjected);
  const actual: ChartSeries = {
    label: 'Actual',
    color: INK,
    points: actualCols.map((c) => ({ x: xOf(c.label), y: c.lines.totalDue.value ?? 0, label: c.label })),
  };
  const lastActual = actual.points[actual.points.length - 1];

  const scenarios: ChartSeries[] = m.bills.map((b, i) => {
    const pts = b.columns.filter((c) => c.isProjected).map((c) => ({ x: xOf(c.label), y: c.lines.totalDue.value ?? 0, label: c.label }));
    return {
      label: b.label,
      color: SERIES_COLORS[i % SERIES_COLORS.length],
      // Join to history so the fan reads as one continuous story.
      points: lastActual ? [lastActual, ...pts] : pts,
    };
  });

  const values = [...actual.points, ...scenarios.flatMap((s) => s.points)].map((p) => p.y);
  return {
    actual,
    scenarios,
    yTicks: niceTicks(Math.min(0, ...values), Math.max(...values, 0), 4),
    xLabels,
  };
}

/**
 * Pushes converging end-labels apart, keeping each tied to its own line so a leader can be
 * drawn back to it. Stacked text on stacked text is the collision a reader notices first,
 * and nudging without a leader detaches the label from its line.
 */
export function layoutEndLabels<T extends { y: number }>(items: T[], minGap: number): (T & { labelY: number })[] {
  const sorted = [...items].sort((a, b) => a.y - b.y).map((it) => ({ ...it, labelY: it.y }));
  for (let i = 1; i < sorted.length; i++) {
    const gap = sorted[i].labelY - sorted[i - 1].labelY;
    if (gap < minGap) sorted[i].labelY = sorted[i - 1].labelY + minGap;
  }
  return sorted;
}

/**
 * The columns the printed bill can actually show.
 *
 * Ten currency columns do not fit 8.5in portrait -- they printed off the edge of the
 * sheet. Projected years are never dropped (they are the point); history is trimmed to
 * the most recent few, and the complete filed history stays in the workbook export.
 */
export function reportColumns(columns: BillColumn[], keepActual: number): BillColumn[] {
  const actual = columns.filter((c) => !c.isProjected);
  const projected = columns.filter((c) => c.isProjected);
  return [...actual.slice(-keepActual), ...projected];
}

const usd0 = (v: number): string => v.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });

/** Inline SVG. 2px round-capped lines, solid hairline grid, end markers with a surface ring. */
function renderChart(chart: BillChart): string {
  const W = 680;
  const H = 260;
  const padL = 74;
  const padR = 104; // room for direct labels at the line ends
  const padT = 14;
  const padB = 34;
  const plotW = W - padL - padR;
  const plotH = H - padT - padB;

  const yMin = chart.yTicks[0];
  const yMax = chart.yTicks[chart.yTicks.length - 1];
  const xMax = Math.max(1, chart.xLabels.length - 1);
  const px = (x: number): number => padL + (x / xMax) * plotW;
  const py = (y: number): number => padT + plotH - ((y - yMin) / (yMax - yMin || 1)) * plotH;
  const path = (pts: ChartPoint[]): string => pts.map((p) => `${px(p.x).toFixed(1)},${py(p.y).toFixed(1)}`).join(' ');

  const out: string[] = [`<svg viewBox="0 0 ${W} ${H}" width="100%" role="img" aria-label="Total tax due by pay year, by scenario">`];

  // Gridlines + y ticks. Solid hairlines, one step off the surface.
  for (const t of chart.yTicks) {
    const y = py(t).toFixed(1);
    out.push(`<line x1="${padL}" y1="${y}" x2="${padL + plotW}" y2="${y}" stroke="${GRID}" stroke-width="1"/>`);
    out.push(`<text x="${padL - 8}" y="${y}" text-anchor="end" dominant-baseline="middle" class="tick">${usd0(t)}</text>`);
  }

  // X labels: first, the actual/projected boundary, and last -- not every year.
  const boundary = chart.actual.points.length - 1;
  const shown = new Set([0, Math.max(0, boundary), chart.xLabels.length - 1]);
  chart.xLabels.forEach((label, i) => {
    if (!shown.has(i)) return;
    out.push(`<text x="${px(i).toFixed(1)}" y="${padT + plotH + 20}" text-anchor="middle" class="tick">${escapeHtml(label)}</text>`);
  });

  // The moment history stops and projection starts.
  if (boundary >= 0 && boundary < chart.xLabels.length - 1) {
    const bx = px(boundary).toFixed(1);
    out.push(`<line x1="${bx}" y1="${padT}" x2="${bx}" y2="${padT + plotH}" stroke="${GRID}" stroke-width="1"/>`);
  }

  if (chart.actual.points.length) {
    out.push(`<polyline fill="none" stroke="${INK}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" points="${path(chart.actual.points)}"/>`);
  }
  for (const s of chart.scenarios) {
    out.push(`<polyline fill="none" stroke="${s.color}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" points="${path(s.points)}"/>`);
  }

  // End labels laid out together so converging lines do not stack their text.
  const ends = chart.scenarios
    .map((s) => {
      const end = s.points[s.points.length - 1];
      return end ? { color: s.color, label: s.label, value: end.y, x: px(end.x), y: py(end.y) } : null;
    })
    .filter((e): e is NonNullable<typeof e> => e !== null);

  for (const e of layoutEndLabels(ends, 30)) {
    // 2px surface ring keeps overlapping end markers legible.
    out.push(`<circle cx="${e.x.toFixed(1)}" cy="${e.y.toFixed(1)}" r="4" fill="${e.color}" stroke="${SURFACE}" stroke-width="2"/>`);
    const lx = e.x + 14;
    // Leader line, drawn only when the label had to move off its own line.
    if (Math.abs(e.labelY - e.y) > 1) {
      out.push(
        `<path d="M ${(e.x + 5).toFixed(1)} ${e.y.toFixed(1)} L ${(lx - 4).toFixed(1)} ${e.labelY.toFixed(1)}" fill="none" stroke="${GRID}" stroke-width="1"/>`,
      );
    }
    // A colour key beside TEXT-INK type -- the text never wears the series colour.
    out.push(`<rect x="${lx.toFixed(1)}" y="${(e.labelY - 9).toFixed(1)}" width="8" height="3" rx="1.5" fill="${e.color}"/>`);
    out.push(`<text x="${(lx + 12).toFixed(1)}" y="${(e.labelY - 6).toFixed(1)}" class="lbl">${escapeHtml(e.label)}</text>`);
    out.push(`<text x="${(lx + 12).toFixed(1)}" y="${(e.labelY + 6).toFixed(1)}" class="lblv">${usd0(e.value)}</text>`);
  }
  out.push('</svg>');
  return out.join('');
}

function billTableHtml(b: ExportBill): string {
  const out: string[] = ['<table class="bill"><thead><tr><th class="ln">Line</th><th class="desc"></th>'];
  for (const c of b.columns) {
    out.push(
      `<th class="${c.isProjected ? 'proj' : 'act'}"><span class="yr">${escapeHtml(String(c.assessmentYear))}</span><span class="pay">pay ${escapeHtml(String(c.payYear))}</span></th>`,
    );
  }
  out.push('</tr></thead><tbody>');
  for (const row of b.rows) {
    const cls = [row.key === 'totalDue' ? 'total' : '', row.key === 'capSavings' ? 'cap' : '', row.isBreakdown ? 'sub' : ''].filter(Boolean).join(' ');
    out.push(`<tr class="${cls}"><td class="ln">${escapeHtml(row.tsLine)}</td><td class="desc">${escapeHtml(row.label)}</td>`);
    row.figures.forEach((f, i) => {
      const col = b.columns[i];
      out.push(`<td class="${col?.isProjected ? 'proj' : 'act'}">${escapeHtml(fmt(row, f.value))}<span class="pv">${mark(f.source)}</span></td>`);
    });
    out.push('</tr>');
  }
  out.push('</tbody></table>');
  return out.join('');
}

const DOC_CSS = `
:root { --ink:${INK}; --soft:${INK_SOFT}; --grid:${GRID}; --surface:${SURFACE}; }
* { box-sizing: border-box; }
body { margin:0; background:#f4f4f2; color:var(--ink);
  font: 13px/1.45 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
.sheet { max-width: 11in; margin: 24px auto; padding: 40px 44px 48px; background: var(--surface);
  box-shadow: 0 1px 3px rgba(0,0,0,.12); }
h1 { font-size: 19px; margin: 0 0 4px; letter-spacing: -0.01em; }
.sub { color: var(--soft); font-size: 12px; margin: 0 0 22px; }
h2 { font-size: 12px; text-transform: uppercase; letter-spacing: .07em; color: var(--soft);
  margin: 28px 0 10px; padding-bottom: 5px; border-bottom: 1px solid var(--grid); }
.warn { border:1px solid #e0b94e; border-left:4px solid #e0b94e; background:#fdf7e6;
  padding:11px 14px; margin:0 0 18px; font-size:12.5px; }
.warn strong { display:block; margin-bottom:2px; }
table { width:100%; border-collapse:collapse; font-variant-numeric: tabular-nums; }
th, td { padding:5px 8px; text-align:right; white-space:nowrap; }
th.ln, td.ln { width:34px; text-align:left; color:var(--soft); font-weight:400; }
th.desc, td.desc { text-align:left; white-space:normal; width:auto; }
/* table-layout:fixed with EXPLICIT widths -- the numeric columns get whatever the
   description does not take. No ellipsis on a figure: a silently truncated dollar
   amount in a tax document is far worse than a table that has to be made to fit. */
.bill { font-size:10.5px; table-layout:fixed; }
.bill th, .bill td { padding:4px 6px; }
.bill th.ln, .bill td.ln { width:26px; }
.bill th.desc, .bill td.desc { width:190px; overflow-wrap:break-word; }
.bill thead th { font-size:10px; color:var(--soft); font-weight:600; border-bottom:1px solid var(--grid); }
.bill thead th .yr { display:block; font-size:12px; color:var(--ink); }
.bill thead th .pay { display:block; font-weight:400; }
.bill td.act, .bill th.act { background:#f7f7f5; }
.bill th.proj:first-of-type, .bill td.proj:first-of-type { border-left:2px solid var(--grid); }
.bill tbody tr.sub td { color:var(--soft); font-size:12px; }
.bill tbody tr.cap td { color:#8a4b12; }
.bill tbody tr.total td { font-weight:700; font-size:13.5px; border-top:1.5px solid var(--ink); padding-top:7px; }
.pv { color:var(--soft); font-size:9px; margin-left:3px; vertical-align:2px; }
.scen th { font-size:10.5px; color:var(--soft); border-bottom:1px solid var(--grid); }
.scen td.name { text-align:left; }
.key { display:inline-block; width:8px; height:3px; border-radius:1.5px; margin-right:6px; vertical-align:2px; }
.tick { font-size:9.5px; fill:var(--soft); }
.lbl { font-size:10px; fill:var(--ink); font-weight:600; }
.lblv { font-size:9.5px; fill:var(--soft); }
.legend { margin:10px 0 0; font-size:11px; color:var(--soft); }
.notes { margin-top:22px; padding-top:12px; border-top:1px solid var(--grid); }
.notes p { margin:0 0 6px; font-size:10.5px; color:var(--soft); line-height:1.5; }
.notes p.verify { font-size:11px; color:var(--ink); }
.notes p.verify a { color:var(--ink); }
.notes p.verify span { color:var(--soft); }
.toolbar { max-width:11in; margin:16px auto 0; text-align:right; }
.toolbar button { font:inherit; padding:7px 15px; border:1px solid var(--grid);
  background:#fff; border-radius:6px; cursor:pointer; }
@media print {
  body { background:#fff; }
  .sheet { box-shadow:none; margin:0; max-width:none; padding:0; }
  .toolbar { display:none; }
  h2 { break-after:avoid; }
  table, .chartwrap { break-inside:avoid; }
}
/* Landscape: a seven-column financial schedule does not fit portrait without
   shrinking the figures to the point of squinting. Schedules are conventionally
   landscape for exactly this reason. */
@page { size: letter landscape; margin: 0.5in; }
* { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
`;

/**
 * The full report. Self-contained by construction: every style is inline, the chart is
 * inline SVG, and nothing is fetched. The one script is the Print button, which does
 * nothing but call window.print() and is hidden on paper.
 */
export function exportToDocument(m: BillExportModel): string {
  const active = m.bills.find((b) => b.scenario === m.activeScenario) ?? m.bills[0];
  const chart = buildChartSeries(m);

  const out: string[] = [
    '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
    `<title>${escapeHtml(m.title)}</title>`,
    `<style>${DOC_CSS}</style></head><body>`,
    '<div class="toolbar"><button type="button" onclick="window.print()">Print / Save as PDF</button></div>',
    '<div class="sheet">',
    `<h1>${escapeHtml(m.title)}</h1>`,
    `<p class="sub">${escapeHtml(m.subtitle)}</p>`,
  ];

  // The warning leads. If a projection is the reader's model rather than the filed bill,
  // that is the first thing they should see -- not a footnote under the numbers.
  for (const w of m.warnings) {
    out.push(`<div class="warn"><strong>Hand-edited projection</strong>${escapeHtml(w.replace(/^⚠\s*/, ''))}</div>`);
  }

  out.push('<h2>Projected total due by scenario</h2>');
  out.push('<div class="chartwrap">', renderChart(chart), '</div>');

  out.push('<table class="scen"><thead><tr><th class="name"></th>');
  for (const y of m.summary.yearLabels) out.push(`<th>${escapeHtml(y)}</th>`);
  out.push('</tr></thead><tbody>');
  m.summary.rows.forEach((r, i) => {
    const color = SERIES_COLORS[i % SERIES_COLORS.length];
    out.push(`<tr><td class="name"><span class="key" style="background:${color}"></span>${escapeHtml(r.label)}</td>`);
    for (const v of r.values) out.push(`<td>${v == null ? '—' : escapeHtml(usd0(v))}</td>`);
    out.push('</tr>');
  });
  out.push('</tbody></table>');

  if (active) {
    const shown = reportColumns(active.columns, REPORT_ACTUAL_YEARS);
    const trimmed = active.columns.length - shown.length;
    out.push(`<h2>Bill detail — ${escapeHtml(active.label)}</h2>`);
    out.push(billTableHtml({ ...active, columns: shown, rows: buildBillGrid(shown) }));
    out.push(`<p class="legend">${escapeHtml(m.legend)}</p>`);
    if (trimmed > 0) {
      out.push(
        `<p class="legend">Showing the ${REPORT_ACTUAL_YEARS} most recent filed years so the bill fits the page; ` +
          `all ${active.columns.length} loaded years are in the Excel export.</p>`,
      );
    }
  }

  out.push('<div class="notes">');
  if (m.verification.length) {
    const items = m.verification
      .map((v) => `<a href="${escapeHtml(v.url)}">${escapeHtml(v.label)} \u2197</a> <span>${escapeHtml(v.note)}</span>`)
      .join(' &nbsp;·&nbsp; ');
    out.push(`<p class="verify"><strong>Verify against the county:</strong> ${items}</p>`);
  }
  for (const f of m.footnotes) out.push(`<p>${escapeHtml(f)}</p>`);
  out.push('</div></div></body></html>');
  return out.join('');
}
