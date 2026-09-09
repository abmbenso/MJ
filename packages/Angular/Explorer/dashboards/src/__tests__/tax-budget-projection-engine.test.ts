import { describe, it, expect } from 'vitest';
import { projectScenario, selectBaseYearRow, narrativeLines, residualProbability, computeBill } from '../TaxBudgetProjection/tax-budget-projection-engine';
import { ScenarioState, TaxHistoryRow } from '../TaxBudgetProjection/tax-budget-projection-types';

/**
 * The Indiana pay-year lag is the whole subject of these tests: assessment year N
 * is billed in year N+1, so at any given moment there is a "bridge" year whose
 * assessed value is already published by the Assessor but whose tax rate is not
 * published by DLGF until early in year N+1. The engine must model that year as
 * actual-AV + projected-rate, and must never let AV and rate advance from
 * different base years.
 */

function scenario(over: Partial<ScenarioState> = {}): ScenarioState {
  return {
    mode: 'trend',
    land: [0, 0, 0, 0, 0],
    imp: [0, 0, 0, 0, 0],
    rate: [0.1, 0.1, 0.1, 0.1, 0.1],
    probability: null,
    probabilitySource: null,
    targetValue: null,
    triggerYear: null,
    override: { enabled: false, year: 1, value: null },
    ...over,
  };
}

/** Base = AY2025: the last year with BOTH an actual assessment and an actual (published) rate. */
const BASE = { baseYear: 2025, baseLand: 200_000, baseImp: 800_000, baseRate: 3.0, yearsForward: 5 };

/** AY2026: the Assessor has set the value, DLGF has not yet published the rate. */
const KNOWN_2026 = { year: 2026, land: 250_000, imp: 850_000 };

describe('projectScenario — pay-year labelling', () => {
  it('labels every row with its assessment year and the pay year that follows it', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: null });

    expect(rows.map((r) => r.assessmentYear)).toEqual([2026, 2027, 2028, 2029, 2030]);
    expect(rows.map((r) => r.payYear)).toEqual([2027, 2028, 2029, 2030, 2031]);
  });
});

describe('projectScenario — the bridge year', () => {
  it('uses the published assessment for the bridge year but still projects its rate', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: KNOWN_2026 });

    expect(rows[0].assessmentYear).toBe(2026);
    expect(rows[0].totalAV).toBe(1_100_000); // the Assessor's actual figure, not 1,000,000 trended
    expect(rows[0].avSource).toBe('actual');
    expect(rows[0].rateSource).toBe('projected');
    expect(rows[0].rate).toBeCloseTo(3.3, 6); // 3.0 grown one year — DLGF has not published this
  });

  it('trends later years off the published bridge-year assessment, not off the older base', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: KNOWN_2026 });

    expect(rows[1].assessmentYear).toBe(2027);
    expect(rows[1].totalAV).toBe(1_100_000); // 0% growth applied to the 2026 actual
    expect(rows[1].avSource).toBe('projected');
  });

  it('marks every year projected when no bridge-year assessment is published yet', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: null });

    expect(rows[0].avSource).toBe('projected');
    expect(rows[0].totalAV).toBe(1_000_000);
  });
});

describe('projectScenario — assessed value and rate advance from the same base year', () => {
  /**
   * The regression guard. The original engine took its AV base from the latest
   * Assessments row (AY2026) and its rate base from the last TaxHistoryYear row
   * (AY2025), then advanced both together — so every row's rate was one year
   * behind its own AV and every projected tax came out low.
   */
  it('advances the rate exactly as many years as the assessment for each row', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: KNOWN_2026 });

    // AY2026 is one year past the AY2025 base; AY2027 is two.
    expect(rows[0].rate).toBeCloseTo(3.0 * 1.1, 6);
    expect(rows[1].rate).toBeCloseTo(3.0 * 1.1 * 1.1, 6);
    expect(rows[4].rate).toBeCloseTo(3.0 * Math.pow(1.1, 5), 6);
  });

  it('computes tax from the same year’s assessment and rate', () => {
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: KNOWN_2026 });

    expect(rows[0].tax).toBeCloseTo((1_100_000 * (3.0 * 1.1)) / 100, 2);
    expect(rows[1].tax).toBeCloseTo((1_100_000 * (3.0 * 1.1 * 1.1)) / 100, 2);
  });
});

describe('projectScenario — a published assessment cannot be re-projected', () => {
  it('defers a sale-chase step past the bridge year instead of overwriting the published value', () => {
    const rows = projectScenario({
      ...BASE,
      scenario: scenario({ mode: 'step-to-price', targetValue: 2_000_000, triggerYear: 1 }),
      knownAV: KNOWN_2026,
    });

    expect(rows[0].totalAV).toBe(1_100_000); // AY2026 stays the Assessor's actual figure
    expect(rows[0].avSource).toBe('actual');
    expect(rows[1].totalAV).toBe(2_000_000); // the step lands on the first unpublished year
  });

  it('ignores a manual override aimed at the bridge year', () => {
    const rows = projectScenario({
      ...BASE,
      scenario: scenario({ override: { enabled: true, year: 1, value: 1_500_000 } }),
      knownAV: KNOWN_2026,
    });

    expect(rows[0].totalAV).toBe(1_100_000);
    expect(rows[0].avSource).toBe('actual');
  });

  it('still honors a manual override on a year whose assessment is not yet published', () => {
    const rows = projectScenario({
      ...BASE,
      scenario: scenario({ override: { enabled: true, year: 2, value: 1_500_000 } }),
      knownAV: KNOWN_2026,
    });

    expect(rows[1].totalAV).toBe(1_500_000);
  });
});

describe('selectBaseYearRow', () => {
  function hist(year: number, rate: number, tax: number | null): TaxHistoryRow {
    return { Year: year, Land: 200_000, Improvement: 800_000, TotalAV: 1_000_000, TaxRate: rate, Tax: tax };
  }

  it('picks the most recent year whose tax rate has actually been published', () => {
    const row = selectBaseYearRow([hist(2023, 2.8, 30_000), hist(2024, 2.9, 31_000), hist(2025, 3.0, 32_000)]);
    expect(row?.Year).toBe(2025);
  });

  it('skips a trailing year carrying no rate, rather than basing the projection on zero', () => {
    const row = selectBaseYearRow([hist(2024, 2.9, 31_000), hist(2025, 3.0, 32_000), hist(2026, 0, null)]);
    expect(row?.Year).toBe(2025);
  });

  it('returns null when no year has a published rate', () => {
    expect(selectBaseYearRow([hist(2026, 0, null)])).toBeNull();
  });
});

describe('narrativeLines', () => {
  it('identifies the starting point as the last year with both a published value and a published rate', () => {
    const lines = narrativeLines('MostLikely', scenario(), 2025, KNOWN_2026);

    // Names the base assessment year AND the year it was billed, so "2025" can't be
    // misread as a pay year. Must never assert a published rate for the bridge year.
    expect(lines[0]).toMatch(/2025/);
    expect(lines[0]).toMatch(/2026/);
    expect(lines.join(' ')).not.toMatch(/actual 2026 value and tax rate/);
  });

  it('names the year the sale-chase step actually lands on, not the deferred trigger year', () => {
    // The engine pushes a step off the bridge year (its assessment is already published).
    // The narrative has to report where the step LANDED, or it contradicts the table beside it.
    const lines = narrativeLines(
      'WorstCase',
      scenario({ mode: 'step-to-price', targetValue: 2_000_000, triggerYear: 1, probability: 0.12, probabilitySource: 'Marion County data' }),
      2025,
      KNOWN_2026,
    );
    const step = lines.find((l) => l.includes('re-assesses'));

    expect(step).toBeDefined();
    expect(step).toMatch(/2027/);
    expect(step).not.toMatch(/assessment year 2026/);
  });

  it('states that the bridge year pairs a published assessment with a projected rate', () => {
    const lines = narrativeLines('MostLikely', scenario(), 2025, KNOWN_2026);
    const bridge = lines.find((l) => l.includes('DLGF'));

    expect(bridge).toBeDefined();
    expect(bridge).toMatch(/2026/);
    expect(bridge).toMatch(/actual|published/i);
    expect(bridge).toMatch(/projected/i);
    expect(bridge).toMatch(/DLGF/);
  });
});

describe('residualProbability', () => {
  it('gives Most Likely the share the other two scenarios leave over', () => {
    expect(residualProbability(0.12, 0.44)).toBeCloseTo(0.44, 6);
  });

  it('never returns a negative probability when the empirical rows overlap', () => {
    // The three scenarios come from independently-computed empirical columns, so nothing
    // guarantees they sum to <= 1. Presenting a negative probability to a taxpayer as
    // "-8% likely" would be worse than presenting a floor of zero.
    expect(residualProbability(0.7, 0.5)).toBe(0);
  });

  it('never exceeds 1 when both inputs are absent', () => {
    expect(residualProbability(null, null)).toBe(1);
  });

  it('treats a missing component as contributing nothing', () => {
    expect(residualProbability(0.3, null)).toBeCloseTo(0.7, 6);
  });
});

describe('computeBill — the TS-1 chain', () => {
  // Parcel 9003241, pay 2026, straight from DLGF:
  //   grossAV 24,416,700 -> netAV 22,951,698 -> x3.6418% -> 835,854.94
  //   -> minus 267,190 cap savings -> 568,664.94 actually billed.
  // Its cap class is the 2% bucket (multifamily), and its own implied uplift is 16.45%.
  const PARCEL = {
    grossAV: 24_416_700,
    deductions: 1_465_002,
    rate: 3.6418,
    capAV: { av1Pct: 0, av2Pct: 24_416_700, av3Pct: 0 },
    uplift: 0.1645,
    otherCharges: 0,
  };

  it('computes gross tax from NET assessed value, not gross', () => {
    const bill = computeBill(PARCEL);
    expect(bill.netAV.value).toBe(22_951_698);
    expect(bill.grossTax.value).toBeCloseTo(835_854.94, 1);
  });

  it('reproduces what the taxpayer was actually billed', () => {
    // The old engine returned grossAV x rate = $889,207 here -- 56% high.
    const bill = computeBill(PARCEL);
    expect(bill.totalDue.value).toBeCloseTo(568_664.94, 0);
  });

  it('caps at the ceiling LIFTED by the uplift, not at the bare statutory ceiling', () => {
    // A bare 2% ceiling is $488,334. Referendum debt sits OUTSIDE the cap, so using the
    // bare ceiling would understate the bill by ~$80k -- the cap is a rate modifier,
    // not a gate.
    const bill = computeBill(PARCEL);
    expect(bill.capCeiling.value).toBeCloseTo(24_416_700 * 0.02 * 1.1645, 0);
    expect(bill.totalDue.value).toBeGreaterThan(24_416_700 * 0.02);
  });

  it('leaves the bill uncapped when gross tax is below the lifted ceiling', () => {
    const bill = computeBill({
      grossAV: 100_000,
      deductions: 0,
      rate: 1.0,
      capAV: { av1Pct: 0, av2Pct: 0, av3Pct: 100_000 },
      uplift: 0.1,
      otherCharges: 0,
    });
    expect(bill.capSavings.value).toBe(0);
    expect(bill.totalDue.value).toBeCloseTo(1000, 2);
  });

  it('adds other charges AFTER the cap, since they are not property tax', () => {
    // Storm water and special assessments ride on the bill but are not subject to the
    // circuit breaker. Adding them before the cap would let the cap erase them.
    const bill = computeBill({
      grossAV: 100_000,
      deductions: 0,
      rate: 1.0,
      capAV: { av1Pct: 0, av2Pct: 0, av3Pct: 100_000 },
      uplift: 0.1,
      otherCharges: 455.4,
    });
    expect(bill.totalDue.value).toBeCloseTo(1455.4, 2);
  });

  it('returns null figures rather than zeros when an input is unavailable', () => {
    const bill = computeBill({
      grossAV: 100_000,
      deductions: null,
      rate: null,
      capAV: { av1Pct: null, av2Pct: null, av3Pct: null },
      uplift: null,
      otherCharges: null,
    });
    expect(bill.grossTax.value).toBeNull();
    expect(bill.capCeiling.value).toBeNull();
    expect(bill.totalDue.value).toBeNull();
  });

  it('marks every figure with whether it is actual or projected', () => {
    const bill = computeBill({ ...PARCEL, source: 'projected' });
    expect(bill.totalDue.source).toBe('projected');
    expect(bill.capCeiling.source).toBe('projected');
  });
});

describe('projectScenario — bill-shaped when bill parameters are supplied', () => {
  const BILL_BASE = {
    ...BASE,
    // Parcel 9003241's own shape: 6% of gross AV deducted, all AV in the 2% cap bucket,
    // its own implied uplift of 16.45%.
    deductionRatio: 0.06,
    capClassShare: { av1Pct: 0, av2Pct: 1, av3Pct: 0 },
    uplift: 0.1645,
    otherCharges: 0,
  };

  it('caps a projected year instead of letting tax grow without bound', () => {
    // The defect this whole landing exists to fix: with a 20%/yr AV climb and no cap,
    // year 5's tax runs away. Capped, it tracks ~2% of gross AV plus the uplift.
    const rows = projectScenario({
      ...BILL_BASE,
      scenario: scenario({ land: [0.2, 0.2, 0.2, 0.2, 0.2], imp: [0.2, 0.2, 0.2, 0.2, 0.2], rate: [0, 0, 0, 0, 0] }),
      knownAV: null,
    });
    const last = rows[4];

    // Bare 2% of gross AV, lifted by the uplift, is the ceiling this must respect.
    expect(last.tax).toBeCloseTo(last.totalAV * 0.02 * 1.1645, 0);
    // And it must be well below the uncapped product, which is what the old engine gave.
    expect(last.tax).toBeLessThan((last.totalAV * 3.0) / 100);
  });

  it('leaves an uncapped parcel alone — the cap only binds when it binds', () => {
    const rows = projectScenario({
      ...BILL_BASE,
      capClassShare: { av1Pct: 0, av2Pct: 0, av3Pct: 1 }, // 3% cap, well above a 3% rate on net AV
      scenario: scenario({ rate: [0, 0, 0, 0, 0] }),
      knownAV: null,
    });

    // netAV = 94% of gross, x 3.0% = 2.82% of gross -- under the 3% ceiling lifted 16.45%.
    expect(rows[0].tax).toBeCloseTo((rows[0].totalAV * 0.94 * 3.0) / 100, 1);
  });

  it('still behaves exactly as before when no bill parameters are given', () => {
    // Backward compatibility: every existing caller and test must be unaffected.
    const rows = projectScenario({ ...BASE, scenario: scenario(), knownAV: null });
    expect(rows[0].tax).toBeCloseTo((rows[0].totalAV * rows[0].rate) / 100, 2);
  });
});
