import { describe, it, expect } from 'vitest';
import * as core from '@abmbenso/mj-indiana-tax-core';
import {
  buildBillGrid,
  capSummaryRows,
  billColumnsFromTaxBills,
  defaultBillAssumptions,
  billAssumptionsDifferFrom,
  blendedCapRate,
  scaledCapAV,
  parseBillViewParams,
  billViewParams,
  BillShape,
} from '../TaxBillProjection/tax-bill-view-model';

/**
 * The TS-1 row model (buildBillGrid / capSummaryRows / billColumnsFromTaxBills) is owned by
 * @abmbenso/mj-indiana-tax-core and tested there (mj-indiana-tax packages/core/src/__tests__/
 * ts1-*.test.ts). This file tests the dashboard-only editing and URL helpers, and that the trunk
 * re-exports core's functions rather than holding a second copy.
 */
describe('one owner — the TS-1 row model is core’s', () => {
  it('re-exports core’s functions, not copies of them', () => {
    expect(buildBillGrid).toBe(core.buildBillGrid);
    expect(capSummaryRows).toBe(core.capSummaryRows);
    expect(billColumnsFromTaxBills).toBe(core.billColumnsFromTaxBills);
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
