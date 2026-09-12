import { describe, it, expect } from 'vitest';
import {
  buildBillGrid,
  capSummaryRows,
  BillColumn,
  defaultBillAssumptions,
  billAssumptionsDifferFrom,
  blendedCapRate,
  scaledCapAV,
  parseBillViewParams,
  billViewParams,
  BillShape,
} from '../TaxBillProjection/tax-bill-view-model';
import { BillLines } from '../TaxBudgetProjection/tax-budget-projection-types';

/**
 * The V2 view-model turns what the engine already computes into TS-1 rows. Its whole
 * purpose is that a reader can verify the arithmetic down a column by eye -- gross AV
 * minus deductions is net AV, net AV times rate is gross tax, gross tax minus cap savings
 * is total due. V1 showed only AV, rate and tax, which did NOT multiply out once the cap
 * was modelled, and looked like an arithmetic error.
 */
function lines(
  over: Partial<Record<keyof BillLines, number | null>> = {},
  source: 'actual' | 'projected' = 'actual',
): BillLines {
  const f = (v: number | null) => ({ value: v, source });
  const pick = (k: keyof BillLines, d: number | null) => (over[k] === undefined ? d : over[k]!);
  return {
    grossAV: f(pick('grossAV', 24_416_700)),
    deductions: f(pick('deductions', 1_465_002)),
    netAV: f(pick('netAV', 22_951_698)),
    rate: f(pick('rate', 3.6418)),
    grossTax: f(pick('grossTax', 835_854.94)),
    capCeiling: f(pick('capCeiling', 568_664.94)),
    capSavings: f(pick('capSavings', 267_190)),
    otherCharges: f(pick('otherCharges', 0)),
    totalDue: f(pick('totalDue', 568_664.94)),
  };
}

const COL = (ay: number, l: BillLines, projected = false): BillColumn => ({
  assessmentYear: ay,
  payYear: ay + 1,
  label: `${ay} pay ${ay + 1}`,
  lines: l,
  isProjected: projected,
});

describe('buildBillGrid', () => {
  it('lays out the TS-1 Table 1 spine in bill order', () => {
    // otherCharges is non-zero here on purpose: it is suppressible, and a fixture that
    // left it at 0 would exercise suppression instead of the spine order this asserts.
    const rows = buildBillGrid([COL(2025, lines({ otherCharges: 455.4 }))]);
    expect(rows.map((r) => r.key)).toEqual([
      'grossAV',
      'deductions',
      'netAV',
      'rate',
      'grossTax',
      'capSavings',
      'otherCharges',
      'totalDue',
    ]);
  });

  it('carries the TS-1 line numbers so the layout maps onto the paper bill', () => {
    const byKey = Object.fromEntries(buildBillGrid([COL(2025, lines())]).map((r) => [r.key, r.tsLine]));
    expect(byKey['grossAV']).toBe('2');
    expect(byKey['deductions']).toBe('2a');
    expect(byKey['netAV']).toBe('3');
    expect(byKey['rate']).toBe('3a');
    expect(byKey['grossTax']).toBe('4');
    expect(byKey['capSavings']).toBe('4b');
    expect(byKey['totalDue']).toBe('5');
  });

  it('puts one figure per column, in column order', () => {
    const rows = buildBillGrid([COL(2024, lines({ totalDue: 100 })), COL(2025, lines({ totalDue: 200 }))]);
    expect(rows.find((r) => r.key === 'totalDue')!.figures.map((f) => f.value)).toEqual([100, 200]);
  });

  it('drops a suppressible line that is zero or absent in EVERY column', () => {
    // The paper bill prints Over-65 and similar because it is a FORM and must accommodate
    // every taxpayer. A tool showing "$0.00" on every commercial parcel forever is noise.
    const rows = buildBillGrid([COL(2024, lines({ otherCharges: 0 })), COL(2025, lines({ otherCharges: null }))]);
    expect(rows.find((r) => r.key === 'otherCharges')).toBeUndefined();
  });

  it('KEEPS a suppressible line that is zero in one column but not another', () => {
    const rows = buildBillGrid([COL(2024, lines({ otherCharges: 0 })), COL(2025, lines({ otherCharges: 455.4 }))]);
    const oc = rows.find((r) => r.key === 'otherCharges');
    expect(oc).toBeDefined();
    expect(oc!.figures.map((f) => f.value)).toEqual([0, 455.4]);
  });

  it('NEVER drops a spine line, even when it is zero everywhere', () => {
    // Suppressing "Total due" because a parcel is exempt would hide the answer the whole
    // view exists to give.
    const rows = buildBillGrid([COL(2025, lines({ totalDue: 0, grossTax: 0, capSavings: 0, netAV: 0 }))]);
    const keys = rows.map((r) => r.key);
    expect(keys).toContain('totalDue');
    expect(keys).toContain('grossTax');
    expect(keys).toContain('netAV');
  });

  it('preserves each figure’s provenance so actual and projected stay distinguishable', () => {
    const rows = buildBillGrid([COL(2025, lines()), COL(2026, lines({}, 'projected'), true)]);
    expect(rows.find((r) => r.key === 'totalDue')!.figures.map((f) => f.source)).toEqual(['actual', 'projected']);
  });

  it('marks the rate row as non-currency so it is not rendered as dollars', () => {
    const rows = buildBillGrid([COL(2025, lines())]);
    expect(rows.find((r) => r.key === 'rate')!.isCurrency).toBe(false);
    expect(rows.find((r) => r.key === 'grossAV')!.isCurrency).toBe(true);
  });

  it('returns no rows at all for no columns, rather than an empty skeleton', () => {
    expect(buildBillGrid([])).toEqual([]);
  });

  it('omits TS-1 line 4a when no column carries local credits', () => {
    // A projected column has no 4a by design: the calibrated uplift is already net of
    // local credits, so printing a separate line would double-count them.
    expect(buildBillGrid([COL(2025, lines())]).find((r) => r.key === 'localCredits')).toBeUndefined();
  });

  it('renders TS-1 line 4a at 4a, between gross tax and the circuit breaker', () => {
    const withCredits = { ...lines(), localCredits: { value: 12_500, source: 'actual' as const } };
    const rows = buildBillGrid([COL(2025, withCredits)]);
    const keys = rows.map((r) => r.key);
    expect(keys.indexOf('localCredits')).toBe(keys.indexOf('grossTax') + 1);
    expect(keys.indexOf('capSavings')).toBe(keys.indexOf('localCredits') + 1);
    expect(rows.find((r) => r.key === 'localCredits')!.tsLine).toBe('4a');
  });

  it('reports a missing line as unavailable rather than as zero', () => {
    // $0.00 asserts the credit was computed and came to nothing; a blank says we do not
    // have it. On a tax bill those are different claims.
    const withCredits = { ...lines(), localCredits: { value: 12_500, source: 'actual' as const } };
    const rows = buildBillGrid([COL(2024, withCredits), COL(2025, lines(), true)]);
    expect(rows.find((r) => r.key === 'localCredits')!.figures.map((f) => f.value)).toEqual([12_500, null]);
  });

  it('an actual bill with local credits still reads correctly down the column', () => {
    // grossTax - 4a - 4b + other charges = total due. This is the DLGF bridge:
    // TotalPropertyTaxDue = GrossTaxDue - SUM(type-'C' credits).
    const actual = {
      ...lines({ grossTax: 835_854.94, capSavings: 250_000, otherCharges: 455.4, totalDue: 573_610.34 }),
      localCredits: { value: 12_700, source: 'actual' as const },
    };
    const rows = buildBillGrid([COL(2025, actual)]);
    const v = (k: string) => rows.find((r) => r.key === k)!.figures[0].value!;
    expect(v('grossTax') - v('localCredits') - v('capSavings') + v('otherCharges')).toBeCloseTo(v('totalDue'), 2);
  });

  it('reads correctly down a column — the point of the format', () => {
    const rows = buildBillGrid([COL(2025, lines())]);
    const v = (k: string) => rows.find((r) => r.key === k)!.figures[0].value!;
    expect(v('grossAV') - v('deductions')).toBeCloseTo(v('netAV'), 2);
    expect((v('netAV') * v('rate')) / 100).toBeCloseTo(v('grossTax'), 1);
    expect(v('grossTax') - v('capSavings')).toBeCloseTo(v('totalDue'), 2);
  });
});

describe('buildBillGrid — land / improvement breakout', () => {
  const split = (l = 4_000_000, i = 20_416_700) => ({
    ...lines(),
    land: { value: l, source: 'actual' as const },
    improvement: { value: i, source: 'actual' as const },
  });

  it('puts land and improvements ABOVE the gross AV they sum to', () => {
    const keys = buildBillGrid([COL(2025, split())]).map((r) => r.key);
    expect(keys.indexOf('land')).toBe(0);
    expect(keys.indexOf('improvement')).toBe(1);
    expect(keys.indexOf('grossAV')).toBe(2);
  });

  it('land + improvements = gross AV down the column', () => {
    // This is the whole reason to break them out: the reader applies different growth to
    // each and must be able to see the two roll up to the line the bill actually taxes.
    const rows = buildBillGrid([COL(2025, split(4_000_000, 20_416_700))]);
    const v = (k: string) => rows.find((r) => r.key === k)!.figures[0].value!;
    expect(v('land') + v('improvement')).toBeCloseTo(v('grossAV'), 2);
  });

  it('marks them as a breakdown, because the paper TS-1 does not itemise them', () => {
    // The TS-1 splits line 1 by cap class (homestead / other residential / all other),
    // never land vs improvement. Presenting these as bill lines would misrepresent the
    // form; they come from the assessment, so they carry no TS-1 line number.
    const rows = buildBillGrid([COL(2025, split())]);
    const land = rows.find((r) => r.key === 'land')!;
    expect(land.isBreakdown).toBe(true);
    expect(land.tsLine).toBe('');
    expect(rows.find((r) => r.key === 'grossAV')!.isBreakdown).toBe(false);
  });

  it('drops both rows when no column carries the split', () => {
    const keys = buildBillGrid([COL(2025, lines())]).map((r) => r.key);
    expect(keys).not.toContain('land');
    expect(keys).not.toContain('improvement');
  });

  it('keeps the rows when only some columns carry the split, blanking the rest', () => {
    // A parcel can have assessment history for recent years but not older ones. That is a
    // gap in what we know, not a $0 land value.
    const rows = buildBillGrid([COL(2023, lines()), COL(2025, split(4_000_000, 20_416_700))]);
    expect(rows.find((r) => r.key === 'land')!.figures.map((f) => f.value)).toEqual([null, 4_000_000]);
  });

  it('keeps land and improvement provenance independent of the rest of the bill', () => {
    const projected = {
      ...lines({}, 'projected'),
      land: { value: 4_400_000, source: 'projected' as const },
      improvement: { value: 22_000_000, source: 'projected' as const },
    };
    const rows = buildBillGrid([COL(2025, split()), COL(2026, projected, true)]);
    expect(rows.find((r) => r.key === 'improvement')!.figures.map((f) => f.source)).toEqual(['actual', 'projected']);
  });
});

describe('capSummaryRows — TS-1 Table 2', () => {
  it('shows the ceiling and what the cap actually saved', () => {
    const keys = capSummaryRows([COL(2025, lines())]).map((r) => r.key);
    expect(keys).toContain('capCeiling');
    expect(keys).toContain('capSavings');
  });

  it('returns nothing when the cap never bound in any column', () => {
    // No cap, no Table 2 -- an all-zero savings block tells the reader nothing.
    expect(capSummaryRows([COL(2025, lines({ capSavings: 0 }))])).toEqual([]);
  });

  it('appears as soon as the cap binds in any one column', () => {
    const rows = capSummaryRows([COL(2024, lines({ capSavings: 0 })), COL(2025, lines({ capSavings: 267_190 }))]);
    expect(rows.length).toBeGreaterThan(0);
    expect(rows.find((r) => r.key === 'capSavings')!.figures.map((f) => f.value)).toEqual([0, 267_190]);
  });
});

describe('defaultBillAssumptions', () => {
  const shape: BillShape = { deductionRatio: 0.06, uplift: 0.1645, otherCharges: 455.4, capRate: 0.02 };

  it('spreads the parcel\u2019s own calibrated bill shape across every projected year', () => {
    const a = defaultBillAssumptions(shape, 5);
    expect(a.deductionPct).toEqual([6, 6, 6, 6, 6]);
    expect(a.upliftPct).toEqual([16.45, 16.45, 16.45, 16.45, 16.45]);
    expect(a.otherCharges).toEqual([455.4, 455.4, 455.4, 455.4, 455.4]);
    expect(a.capRatePct).toEqual([2, 2, 2, 2, 2]);
  });

  it('converts ratios to percentages, because that is the unit a person edits in', () => {
    // The engine works in fractions; a taxpayer reads and types "6.0%". Storing the editor
    // in percent and converting once at the boundary keeps the rounding in one place.
    expect(defaultBillAssumptions({ deductionRatio: 0.06, uplift: 0.1645, otherCharges: 0, capRate: 0.02 }, 1).deductionPct[0]).toBe(6);
  });

  it('holds to basis-point resolution rather than snapping to whole percents', () => {
    const a = defaultBillAssumptions({ deductionRatio: 0.012345, uplift: 0.269412, otherCharges: 0, capRate: 0.02 }, 1);
    expect(a.deductionPct[0]).toBeCloseTo(1.2345, 4);
    expect(a.upliftPct[0]).toBeCloseTo(26.9412, 4);
  });

  it('falls back to zeros when the parcel has no calibrated shape at all', () => {
    // A parcel with no filed bills has no shape to spread. Zeros are the honest neutral
    // here -- they are what the editor SHOWS, not a claim about the parcel's real bill,
    // and V2 refuses to render a bill for such a parcel in the first place.
    const a = defaultBillAssumptions(null, 3);
    expect(a.deductionPct).toEqual([0, 0, 0]);
    expect(a.otherCharges).toEqual([0, 0, 0]);
    expect(a.upliftPct).toEqual([0, 0, 0]);
    expect(a.capRatePct).toEqual([0, 0, 0]);
  });
});

describe('blendedCapRate', () => {
  it('is the parcel\u2019s statutory ceiling as a fraction of gross AV', () => {
    // IC 6-1.1-20.6: 1% homestead / 2% other residential / 3% everything else, applied to
    // GROSS AV. A parcel wholly in the 2% bucket has a 2% ceiling.
    expect(blendedCapRate({ av1Pct: 0, av2Pct: 1, av3Pct: 0 })).toBeCloseTo(0.02, 6);
    expect(blendedCapRate({ av1Pct: 1, av2Pct: 0, av3Pct: 0 })).toBeCloseTo(0.01, 6);
    expect(blendedCapRate({ av1Pct: 0, av2Pct: 0, av3Pct: 1 })).toBeCloseTo(0.03, 6);
  });

  it('blends a mixed-class parcel rather than forcing it into one bucket', () => {
    // Marion has 4,933 genuinely Mixed bills; collapsing them to a single class would
    // misstate the ceiling in both directions.
    expect(blendedCapRate({ av1Pct: 0.5, av2Pct: 0.5, av3Pct: 0 })).toBeCloseTo(0.015, 6);
  });

  it('treats a missing class share as zero, not as a reason to give up', () => {
    expect(blendedCapRate({ av1Pct: null, av2Pct: 1, av3Pct: null })).toBeCloseTo(0.02, 6);
  });

  it('is 0 for a parcel with no classified AV at all', () => {
    expect(blendedCapRate({ av1Pct: null, av2Pct: null, av3Pct: null })).toBe(0);
  });
});

describe('scaledCapAV', () => {
  it('hits the requested ceiling rate exactly', () => {
    const av = scaledCapAV(30_785_600, { av1Pct: 0, av2Pct: 1, av3Pct: 0 }, 3);
    const ceiling = (av.av1Pct ?? 0) * 0.01 + (av.av2Pct ?? 0) * 0.02 + (av.av3Pct ?? 0) * 0.03;
    expect(ceiling).toBeCloseTo(30_785_600 * 0.03, 2);
  });

  it('PRESERVES the parcel\u2019s class mix while changing the rate', () => {
    // Editing the ceiling models a reclassification's EFFECT; it must not silently rewrite
    // which statutory buckets the parcel's AV sits in.
    const av = scaledCapAV(1_000_000, { av1Pct: 0.5, av2Pct: 0.5, av3Pct: 0 }, 3);
    expect(av.av1Pct).toBeCloseTo(av.av2Pct!, 6);
    expect(av.av3Pct).toBe(0);
  });

  it('still reaches the rate when the parcel has no classified AV to scale', () => {
    const av = scaledCapAV(1_000_000, { av1Pct: null, av2Pct: null, av3Pct: null }, 2);
    const ceiling = (av.av1Pct ?? 0) * 0.01 + (av.av2Pct ?? 0) * 0.02 + (av.av3Pct ?? 0) * 0.03;
    expect(ceiling).toBeCloseTo(20_000, 2);
  });

  it('returns a zero ceiling for a zero rate rather than NaN', () => {
    const av = scaledCapAV(1_000_000, { av1Pct: 0, av2Pct: 1, av3Pct: 0 }, 0);
    const ceiling = (av.av1Pct ?? 0) * 0.01 + (av.av2Pct ?? 0) * 0.02 + (av.av3Pct ?? 0) * 0.03;
    expect(ceiling).toBe(0);
  });
});

describe('billAssumptionsDifferFrom', () => {
  const shape: BillShape = { deductionRatio: 0.06, uplift: 0.1645, otherCharges: 455.4, capRate: 0.02 };

  it('is false for untouched defaults, so the UI does not cry "edited" on load', () => {
    expect(billAssumptionsDifferFrom(defaultBillAssumptions(shape, 5), defaultBillAssumptions(shape, 5))).toBe(false);
  });

  it('is true once any single year of any line is changed', () => {
    const edited = defaultBillAssumptions(shape, 5);
    edited.deductionPct[2] = 0;
    expect(billAssumptionsDifferFrom(edited, defaultBillAssumptions(shape, 5))).toBe(true);
  });

  it('notices a changed uplift and a changed other-charge, not just deductions', () => {
    const base = defaultBillAssumptions(shape, 5);
    const upliftEdit = defaultBillAssumptions(shape, 5);
    upliftEdit.upliftPct[0] = 30;
    expect(billAssumptionsDifferFrom(upliftEdit, base)).toBe(true);

    const chargeEdit = defaultBillAssumptions(shape, 5);
    chargeEdit.otherCharges[4] = 0;
    expect(billAssumptionsDifferFrom(chargeEdit, base)).toBe(true);

    const capEdit = defaultBillAssumptions(shape, 5);
    capEdit.capRatePct[1] = 3;
    expect(billAssumptionsDifferFrom(capEdit, base)).toBe(true);
  });
});

describe('URL round-trip — parseBillViewParams', () => {
  it('restores the parcel, scenario and column window from a deep link', () => {
    expect(parseBillViewParams({ parcel: 'abc-123', scenario: 'WorstCase', columns: 'all' })).toEqual({
      parcelId: 'abc-123',
      scenario: 'WorstCase',
      showAllColumns: true,
    });
  });

  it('returns nulls for an empty URL rather than inventing a default parcel', () => {
    expect(parseBillViewParams({})).toEqual({ parcelId: null, scenario: null, showAllColumns: false });
  });

  it('IGNORES an unrecognised scenario instead of guessing one', () => {
    // A hand-edited or stale URL must not silently land the reader on a scenario they did
    // not ask for -- a projection labelled "Worst Case" that is actually Most Likely is a
    // number someone could rely on.
    expect(parseBillViewParams({ scenario: 'Catastrophic' }).scenario).toBeNull();
  });

  it('accepts a scenario regardless of case, since URLs get hand-edited', () => {
    expect(parseBillViewParams({ scenario: 'mostlikely' }).scenario).toBe('MostLikely');
    expect(parseBillViewParams({ scenario: 'BESTCASE' }).scenario).toBe('BestCase');
  });

  it('treats any columns value other than "all" as the recent window', () => {
    expect(parseBillViewParams({ columns: 'recent' }).showAllColumns).toBe(false);
    expect(parseBillViewParams({ columns: 'nonsense' }).showAllColumns).toBe(false);
    expect(parseBillViewParams({ columns: 'ALL' }).showAllColumns).toBe(true);
  });
});

describe('URL round-trip — billViewParams', () => {
  it('writes the state a reader would want back', () => {
    expect(billViewParams('abc-123', 'WorstCase', true)).toEqual({
      parcel: 'abc-123',
      scenario: 'WorstCase',
      columns: 'all',
    });
  });

  it('nulls the parcel when none is selected, so the param LEAVES the URL', () => {
    // Writing an empty string would leave "?parcel=" behind and make a cleared view look
    // like a broken deep link.
    expect(billViewParams(null, 'MostLikely', false).parcel).toBeNull();
  });

  it('round-trips: what it writes, the parser reads back unchanged', () => {
    for (const scenario of ['WorstCase', 'MostLikely', 'BestCase'] as const) {
      for (const showAll of [true, false]) {
        const written = billViewParams('p1', scenario, showAll);
        const params: Record<string, string> = {};
        for (const [k, v] of Object.entries(written)) if (v != null) params[k] = v;
        expect(parseBillViewParams(params)).toEqual({ parcelId: 'p1', scenario, showAllColumns: showAll });
      }
    }
  });
});
