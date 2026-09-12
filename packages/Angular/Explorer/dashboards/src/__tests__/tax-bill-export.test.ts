import { describe, it, expect } from 'vitest';
import {
  buildBillExport,
  exportToMarkdown,
  exportToHtml,
  buildSheets,
  columnLetter,
  exportToDocument,
  buildChartSeries,
  layoutEndLabels,
  reportColumns,
  niceTicks,
  BillExportInput,
} from '../TaxBillProjection/tax-bill-export';
import { BillColumn, BillGridLines } from '../TaxBillProjection/tax-bill-view-model';
import { BillLines, ScenarioName, ScenarioState } from '../TaxBudgetProjection/tax-budget-projection-types';

function lines(totalDue: number, source: 'actual' | 'projected'): BillGridLines {
  const f = (v: number | null) => ({ value: v, source });
  return {
    grossAV: f(24_416_700),
    deductions: f(1_465_002),
    netAV: f(22_951_698),
    rate: f(3.6418),
    grossTax: f(835_854.94),
    capCeiling: f(568_664.94),
    capSavings: f(267_190),
    otherCharges: f(0),
    totalDue: f(totalDue),
  } as BillLines as BillGridLines;
}

const col = (ay: number, totalDue: number, projected: boolean): BillColumn => ({
  assessmentYear: ay,
  payYear: ay + 1,
  label: `${ay} pay ${ay + 1}`,
  lines: lines(totalDue, projected ? 'projected' : 'actual'),
  isProjected: projected,
});

const assumptions = (): ScenarioState => ({
  mode: 'trend',
  land: [0.019, 0.019],
  imp: [0.087, 0.087],
  rate: [-0.039, -0.039],
  probability: 0.44,
  probabilitySource: 'Marion County data',
  targetValue: null,
  triggerYear: null,
  override: { enabled: false, year: 1, value: null },
});

const bill = () => ({ deductionPct: [6, 6], upliftPct: [16.45, 16.45], otherCharges: [0, 0], capRatePct: [2, 2] });

function input(over: Partial<BillExportInput> = {}): BillExportInput {
  const mk = (name: ScenarioName, label: string, due: number, edited = false) => ({
    scenario: name,
    label,
    edited,
    columns: [col(2024, 467_941, false), col(2025, due, true), col(2026, due + 50_000, true)],
    assumptions: assumptions(),
    bill: bill(),
  });
  return {
    parcelNumber: '9003241',
    address: '7300 ROCKLEIGH AV, INDIANAPOLIS, 46214-0000',
    county: 'Marion',
    generatedAt: new Date('2026-09-09T12:00:00Z'),
    activeScenario: 'MostLikely',
    scenarios: [
      mk('WorstCase', 'Worst Case', 955_239),
      mk('MostLikely', 'Most Likely', 716_997),
      mk('BestCase', 'Best Case', 640_000),
    ],
    verification: [
      { kind: 'prc' as const, label: 'Property Record Card', shortLabel: 'PRC', url: 'https://maps.indy.gov/x?ParcelNumber=9003241', retrievedAt: new Date('2026-08-29T00:00:00Z'), onFile: true, note: 'retrieved 2026-08-29' },
      { kind: 'taxHistory' as const, label: 'Tax History', shortLabel: 'Tax History', url: 'https://maps.indy.gov/y?ParcelNumber=9003241', retrievedAt: null, onFile: false, note: 'not on file — verify at the county' },
    ],
    calibration: {
      years: 5,
      deductionRatio: 0.06,
      uplift: 0.1645,
      upliftSource: 'parcel',
      capClass: 'OtherResidential',
      capRate: 0.02,
    },
    ...over,
  };
}

describe('buildBillExport', () => {
  it('identifies the parcel in the title and subtitle', () => {
    const m = buildBillExport(input());
    expect(m.title).toContain('7300 ROCKLEIGH AV');
    expect(m.subtitle).toContain('9003241');
    expect(m.subtitle).toContain('Marion');
  });

  it('carries a bill for every scenario, not just the active one', () => {
    expect(buildBillExport(input()).bills.map((b) => b.scenario)).toEqual(['WorstCase', 'MostLikely', 'BestCase']);
  });

  it('summarises total due by scenario across PROJECTED years only', () => {
    // The actual years are identical under every scenario -- listing them in a scenario
    // comparison would imply they differ, which is exactly the wrong idea to give.
    const m = buildBillExport(input());
    expect(m.summary.yearLabels).toEqual(['2025 pay 2026', '2026 pay 2027']);
    expect(m.summary.rows.find((r) => r.label === 'Worst Case')!.values).toEqual([955_239, 1_005_239]);
  });

  it('states the calibration it projected from', () => {
    const notes = buildBillExport(input()).footnotes.join(' ');
    expect(notes).toMatch(/5 filed bills/);
    expect(notes).toMatch(/6\.0%/);
    expect(notes).toMatch(/16\.4/);
    expect(notes).toMatch(/its own capped years/);
  });

  it('says so when the uplift came from the county placeholder rather than the parcel', () => {
    const m = buildBillExport(input({ calibration: { years: 1, deductionRatio: 0.06, uplift: 0.15, upliftSource: 'district', capClass: null, capRate: 0.02 } }));
    expect(m.footnotes.join(' ')).toMatch(/never been capped|county-wide/i);
  });

  it('warns, per scenario, when its bill lines were hand-edited', () => {
    const i = input();
    i.scenarios[0].edited = true;
    const m = buildBillExport(i);
    expect(m.warnings).toHaveLength(1);
    expect(m.warnings[0]).toContain('Worst Case');
    expect(m.warnings[0]).toMatch(/not the filed bill/i);
  });

  it('raises no warning when nothing was edited', () => {
    expect(buildBillExport(input()).warnings).toEqual([]);
  });
});

describe('exportToMarkdown', () => {
  it('keeps the TS-1 line numbers so the paste maps onto the paper bill', () => {
    const md = exportToMarkdown(buildBillExport(input()));
    expect(md).toContain('| 5 |');
    expect(md).toContain('Equals total amount due');
  });

  it('includes the provenance legend and the scenario summary', () => {
    const md = exportToMarkdown(buildBillExport(input()));
    expect(md).toContain('●');
    expect(md).toContain('‡');
    expect(md).toContain('Worst Case');
  });

  it('carries an edited-bill warning into the pasted text', () => {
    const i = input();
    i.scenarios[1].edited = true;
    expect(exportToMarkdown(buildBillExport(i))).toMatch(/not the filed bill/i);
  });
});

describe('exportToHtml', () => {
  it('emits a real table so it pastes into Word as a table, not as pipes', () => {
    const html = exportToHtml(buildBillExport(input()));
    expect(html).toMatch(/<table/);
    expect(html).toMatch(/<\/table>/);
  });

  it('escapes text rather than letting it become markup', () => {
    const html = exportToHtml(buildBillExport(input({ address: 'A & B <script>alert(1)</script>' })));
    expect(html).toContain('&amp;');
    expect(html).not.toContain('<script>');
  });

  it('carries the edited-bill warning', () => {
    const i = input();
    i.scenarios[0].edited = true;
    expect(exportToHtml(buildBillExport(i))).toMatch(/not the filed bill/i);
  });
});

describe('columnLetter', () => {
  it('maps indices to spreadsheet columns, including past Z', () => {
    expect(columnLetter(0)).toBe('A');
    expect(columnLetter(25)).toBe('Z');
    expect(columnLetter(26)).toBe('AA');
    expect(columnLetter(27)).toBe('AB');
  });
});

describe('buildSheets', () => {
  it('produces a summary sheet, one per scenario, and an assumptions sheet', () => {
    expect(buildSheets(buildBillExport(input())).map((s) => s.name)).toEqual([
      'Summary',
      'Bill — Worst Case',
      'Bill — Most Likely',
      'Bill — Best Case',
      'Assumptions',
    ]);
  });

  it('writes REAL NUMBERS so the spreadsheet can compute on them', () => {
    // A "$716,997" string is a picture of a number. The whole reason to offer Excel is
    // that the recipient can do arithmetic on it.
    const sheets = buildSheets(buildBillExport(input()));
    const billSheet = sheets.find((s) => s.name === 'Bill — Most Likely')!;
    const totalRow = (billSheet.data as unknown[][]).find((r) => String(r[1]).includes('total amount due'))!;
    expect(typeof totalRow[2]).toBe('number');
    expect(totalRow[2]).toBe(467_941);
  });

  it('marks projected figures with a style override rather than mangling the number', () => {
    const billSheet = buildSheets(buildBillExport(input())).find((s) => s.name === 'Bill — Most Likely')!;
    expect(billSheet.cellStyles && billSheet.cellStyles.length).toBeGreaterThan(0);
    expect(billSheet.cellStyles!.every((c) => /^[A-Z]+\d+$/.test(c.cell))).toBe(true);
    expect(billSheet.cellStyles!.some((c) => c.style.font?.italic === true)).toBe(true);
  });

  it('writes every editable assumption, per scenario, on the Assumptions sheet', () => {
    // The numbers are only defensible alongside what produced them. A workbook with a
    // bill and no assumptions is a claim with its reasoning removed.
    const sheet = buildSheets(buildBillExport(input())).find((s) => s.name === 'Assumptions')!;
    const rows = sheet.data as unknown[][];
    const flat = rows.flat().join(' ');
    for (const label of ['Worst Case', 'Most Likely', 'Best Case']) expect(flat).toContain(label);
    for (const a of ['Land growth', 'Improvement growth', 'Tax rate growth', 'Deductions', 'Cap ceiling', 'Outside-cap uplift', 'Other charges']) {
      expect(flat).toContain(a);
    }
  });

  it('writes assumption VALUES as numbers, not just their labels', () => {
    const sheet = buildSheets(buildBillExport(input())).find((s) => s.name === 'Assumptions')!;
    const rows = sheet.data as unknown[][];
    const land = rows.find((r) => r[0] === 'Most Likely' && String(r[1]).includes('Land growth'))!;
    // stored as the fraction 0.019 -> presented as 1.9%
    expect(land.slice(3).some((v) => typeof v === 'number' && Math.abs(v - 1.9) < 0.001)).toBe(true);
    const ded = rows.find((r) => r[0] === 'Most Likely' && String(r[1]).includes('Deductions'))!;
    expect(ded.slice(3)).toContain(6);
  });

  it('puts the warnings on the summary sheet, where they are seen first', () => {
    const i = input();
    i.scenarios[0].edited = true;
    const summary = buildSheets(buildBillExport(i)).find((s) => s.name === 'Summary')!;
    const flat = (summary.data as unknown[][]).flat().join(' ');
    expect(flat).toMatch(/not the filed bill/i);
  });
});

describe('niceTicks', () => {
  it('rounds to clean, human-readable steps', () => {
    const t = niceTicks(0, 1_032_716, 4);
    expect(t.every((v) => Number.isFinite(v))).toBe(true);
    expect(t[0]).toBeLessThanOrEqual(0);
    expect(t[t.length - 1]).toBeGreaterThanOrEqual(1_032_716);
    // every step identical and a round number
    const step = t[1] - t[0];
    expect(t.every((v, i) => i === 0 || Math.abs(v - t[i - 1] - step) < 1e-6)).toBe(true);
    expect(step % 50_000).toBe(0);
  });

  it('survives a flat series without dividing by zero', () => {
    const t = niceTicks(500_000, 500_000, 4);
    expect(t.length).toBeGreaterThan(1);
    expect(t.every((v) => Number.isFinite(v))).toBe(true);
  });
});

describe('buildChartSeries', () => {
  it('draws history ONCE and fans into a line per scenario', () => {
    // The actual years are identical under every scenario; drawing them three times
    // would render three coincident lines and imply the past is uncertain.
    const s = buildChartSeries(buildBillExport(input()));
    expect(s.actual.points.length).toBe(1);
    expect(s.scenarios.map((x) => x.label)).toEqual(['Worst Case', 'Most Likely', 'Best Case']);
  });

  it('joins each scenario line to the last actual point so the fan is continuous', () => {
    const s = buildChartSeries(buildBillExport(input()));
    const lastActual = s.actual.points[s.actual.points.length - 1];
    for (const sc of s.scenarios) {
      expect(sc.points[0].x).toBe(lastActual.x);
      expect(sc.points[0].y).toBe(lastActual.y);
    }
  });

  it('assigns the validated categorical hues in fixed order', () => {
    const s = buildChartSeries(buildBillExport(input()));
    expect(s.scenarios.map((x) => x.color)).toEqual(['#2a78d6', '#eb6834', '#1baf7a']);
  });
});

describe('exportToDocument', () => {
  const doc = () => exportToDocument(buildBillExport(input()));

  it('is a complete, self-contained document — nothing loaded from the network', () => {
    // It has to render identically offline, from an email attachment, years later.
    // A HYPERLINK is not a loaded resource: the verification links point at the county's
    // site, but nothing is fetched to render the page. What must be absent is any
    // SUBRESOURCE -- images, stylesheets, scripts, fonts, CSS url()/@import.
    const d = doc();
    expect(d).toMatch(/^<!DOCTYPE html>/i);
    expect(d).toContain('</html>');
    expect(d).not.toMatch(/<img/i);
    expect(d).not.toMatch(/<link\b/i);
    expect(d).not.toMatch(/<script\s[^>]*\bsrc=/i);
    expect(d).not.toMatch(/url\(\s*['"]?https?:/i);
    expect(d).not.toMatch(/@import/i);
    // Every remaining absolute URL is an href the reader may CHOOSE to follow.
    const urls = d.match(/https?:\/\/[^"'\s<>)]+/g) ?? [];
    for (const u of urls) expect(d).toContain(`href="${u}"`);
  });

  it('draws the chart as real inline SVG, not a raster', () => {
    expect(doc()).toMatch(/<svg[\s\S]*<\/svg>/);
  });

  it('uses solid hairline gridlines, never dashed', () => {
    // Dashing reads as "projection" or "threshold" when it is just a grid.
    expect(doc()).not.toContain('stroke-dasharray');
  });

  it('direct-labels every scenario, which the aqua contrast WARN obliges', () => {
    const d = doc();
    for (const label of ['Worst Case', 'Most Likely', 'Best Case']) expect(d).toContain(label);
  });

  it('leads with the edited-bill warning rather than burying it in a footnote', () => {
    const i = input();
    i.scenarios[1].edited = true;
    const d = exportToDocument(buildBillExport(i));
    expect(d).toMatch(/not the filed bill/i);
    // the callout must precede the bill table it qualifies
    expect(d.indexOf('not the filed bill')).toBeLessThan(d.indexOf('Equals total amount due'));
  });

  it('keeps the calibration and the provenance legend', () => {
    const d = doc();
    expect(d).toMatch(/5 filed bills/);
    expect(d).toContain('●');
    expect(d).toContain('‡');
  });

  it('escapes text rather than letting it become markup', () => {
    const d = exportToDocument(buildBillExport(input({ address: 'A & B <script>alert(1)</script>' })));
    expect(d).toContain('&amp;');
    expect(d).not.toContain('<script>alert');
  });

  it('carries print rules so a Save-as-PDF keeps its colours', () => {
    expect(doc()).toContain('print-color-adjust');
    expect(doc()).toMatch(/@page/);
  });
});

describe('layoutEndLabels', () => {
  it('leaves well-separated labels where their lines end', () => {
    const out = layoutEndLabels([{ y: 10 }, { y: 100 }, { y: 200 }], 26);
    expect(out.map((o) => o.labelY)).toEqual([10, 100, 200]);
  });

  it('pushes converging labels apart instead of letting them overlap', () => {
    // Best Case and Most Likely converge on a flat-rate parcel; stacked text on stacked
    // text is unreadable, and it is the collision a reader notices first.
    const out = layoutEndLabels([{ y: 100 }, { y: 108 }, { y: 112 }], 26);
    for (let i = 1; i < out.length; i++) {
      expect(out[i].labelY - out[i - 1].labelY).toBeGreaterThanOrEqual(26);
    }
  });

  it('keeps each label tied to its own line so the leader can be drawn', () => {
    const out = layoutEndLabels([{ y: 100 }, { y: 108 }], 26);
    expect(out.map((o) => o.y)).toEqual([100, 108]);
    expect(out.some((o) => o.labelY !== o.y)).toBe(true);
  });

  it('orders by position, not by input order', () => {
    const out = layoutEndLabels([{ y: 300 }, { y: 10 }], 26);
    expect(out[0].y).toBe(10);
  });
});

describe('reportColumns', () => {
  it('trims history so the bill fits the page instead of running off it', () => {
    // Ten currency columns do not fit 8.5in portrait -- they printed cut off. The full
    // filed history stays available in the workbook.
    const all = buildBillExport(input()).bills[0].columns;
    const kept = reportColumns(all, 2);
    expect(kept.length).toBeLessThanOrEqual(all.length);
    expect(kept.filter((c) => !c.isProjected).length).toBeLessThanOrEqual(2);
  });

  it('never drops a projected year — the projection is the point', () => {
    const all = buildBillExport(input()).bills[0].columns;
    const projected = all.filter((c) => c.isProjected).length;
    expect(reportColumns(all, 2).filter((c) => c.isProjected).length).toBe(projected);
  });

  it('keeps the most RECENT actual years, not the oldest', () => {
    const all = buildBillExport(input()).bills[0].columns;
    const kept = reportColumns(all, 1).filter((c) => !c.isProjected);
    const actuals = all.filter((c) => !c.isProjected);
    expect(kept[0].label).toBe(actuals[actuals.length - 1].label);
  });
});

describe('verification travels with the export', () => {
  it('puts both county documents in the report, with their provenance', () => {
    // An exported projection that leaves the tool without a route back to the source is
    // exactly what the verification requirement is guarding against.
    const d = exportToDocument(buildBillExport(input()));
    expect(d).toContain('Property Record Card');
    expect(d).toContain('Tax History');
    expect(d).toContain('retrieved 2026-08-29');
    expect(d).toMatch(/not on file/i);
    expect(d).toContain('ParcelNumber=9003241');
  });

  it('puts them on the workbook Summary sheet too', () => {
    const summary = buildSheets(buildBillExport(input())).find((s) => s.name === 'Summary')!;
    const flat = (summary.data as unknown[][]).flat().join(' ');
    expect(flat).toContain('Property Record Card');
    expect(flat).toMatch(/not on file/i);
  });

  it('omits the section entirely when there is nothing to verify against', () => {
    const d = exportToDocument(buildBillExport(input({ verification: [] })));
    expect(d).not.toContain('Verify against the county');
  });
});
