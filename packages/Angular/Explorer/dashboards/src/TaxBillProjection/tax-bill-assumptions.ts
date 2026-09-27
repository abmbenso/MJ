/**
 * Tax Bill Projection V2 -- the dashboard-only helpers: the editable bill lines (deductions, uplift,
 * other charges, cap rate per projected year) and the URL round-trip. Moved verbatim from
 * tax-bill-view-model.ts (lines 164-333 at 7d0a207933) when the TS-1 row model moved to
 * @abmbenso/mj-indiana-tax-core (2026-09-27). PURE: no data access, no Angular.
 */

import { CapClassAV, ScenarioName, SCENARIO_NAMES } from '../TaxBudgetProjection/tax-budget-projection-types';

/* ===========================================================================
 * EDITABLE BILL LINES
 *
 * The growth assumptions move the ASSESSMENT (land, improvements, rate). These move the
 * BILL itself -- what is deducted from the AV before tax, what the circuit breaker lets
 * through, and what non-tax charges ride along. Together they are the "vary a variable up
 * and down the bill" the bill-shaped format exists to make possible: model an abatement
 * burning off, a deduction being lost, a referendum passing.
 *
 * Per YEAR, not a single figure, because the things they represent are inherently
 * year-by-year -- an abatement phases out on a schedule; a single deduction number could
 * not express that at all.
 *
 * Stored in PERCENT (and dollars) because that is the unit a person reads and types. The
 * conversion back to the engine's fractions happens once, at the boundary.
 * =========================================================================== */

/** The parcel's calibrated bill shape, as derived from its own filed DLGF bills. */
export interface BillShape {
  deductionRatio: number;
  uplift: number;
  otherCharges: number;
  /** The statutory ceiling as a FRACTION of gross AV -- see blendedCapRate. */
  capRate: number;
}

/** Editable bill-line values, one entry per projected year. */
export interface BillAssumptions {
  /** TS-1 line 2a, as a percentage of gross AV. */
  deductionPct: number[];
  /** TS-1 line 4b: how far above the bare statutory ceiling the bill sits, as a percentage. */
  upliftPct: number[];
  /** TS-1 Table 4, in dollars. Not property tax, so not subject to the cap. */
  otherCharges: number[];
  /**
   * The statutory circuit-breaker ceiling as a percentage of gross AV (IC 6-1.1-20.6).
   *
   * Exposed as ONE number rather than three cap-class shares: it is the only quantity the
   * ceiling actually depends on, it blends a mixed-class parcel natively, and it is what a
   * taxpayer understands ("my cap is 2% of gross AV"). Typing 2 -> 3 models the EFFECT of a
   * reclassification, which is a real event -- 14,814 Marion parcels moved 3% -> 2% in
   * pay-2025 alone.
   */
  capRatePct: number[];
}

/** Statutory circuit-breaker rates by cap class (IC 6-1.1-20.6). */
const CAP_RATES: ReadonlyArray<[keyof CapClassAV, number]> = [
  ['av1Pct', 0.01],
  ['av2Pct', 0.02],
  ['av3Pct', 0.03],
];

/**
 * A parcel's blended ceiling as a fraction of gross AV, from its cap-class SHARES
 * (each share is that class's portion of gross AV, so the three sum to ~1).
 *
 * A missing share counts as zero -- one unclassified bucket is not a reason to refuse a
 * ceiling for the buckets we do have.
 */
export function blendedCapRate(shares: CapClassAV): number {
  return CAP_RATES.reduce((sum, [key, rate]) => sum + (shares[key] ?? 0) * rate, 0);
}

/**
 * Cap-class AV (in dollars) that produces `capRatePct`% of gross AV as the ceiling, while
 * PRESERVING the parcel's class mix.
 *
 * Editing the ceiling models the effect of a reclassification; it must not silently rewrite
 * which statutory buckets the parcel's AV sits in, so the existing shares are scaled rather
 * than replaced. A parcel with no classified AV has no mix to preserve, so the whole
 * ceiling is expressed through the 1% bucket -- arithmetically identical, and the only
 * option that can reach the requested rate at all.
 */
export function scaledCapAV(grossAV: number, shares: CapClassAV, capRatePct: number): CapClassAV {
  const target = capRatePct / 100;
  const base = blendedCapRate(shares);
  if (base <= 0) {
    // ceiling = av1 * 0.01, so av1 = grossAV * target / 0.01
    return { av1Pct: (grossAV * target) / 0.01, av2Pct: 0, av3Pct: 0 };
  }
  const scale = target / base;
  return {
    av1Pct: grossAV * (shares.av1Pct ?? 0) * scale,
    av2Pct: grossAV * (shares.av2Pct ?? 0) * scale,
    av3Pct: grossAV * (shares.av3Pct ?? 0) * scale,
  };
}

/** Four decimal places on a percentage -- basis-point resolution, matching the rate editor. */
function pct4(fraction: number): number {
  return Math.round(fraction * 100 * 10000) / 10000;
}

/**
 * The starting point: the parcel's own calibrated shape, held flat across every projected
 * year. `null` yields zeros -- a parcel with no filed bills has no shape to spread, and V2
 * declines to render a bill for it at all, so this is only ever what an empty editor shows.
 */
export function defaultBillAssumptions(shape: BillShape | null, yearsForward: number): BillAssumptions {
  const fill = (v: number): number[] => Array.from({ length: yearsForward }, () => v);
  if (!shape) return { deductionPct: fill(0), upliftPct: fill(0), otherCharges: fill(0), capRatePct: fill(0) };
  return {
    deductionPct: fill(pct4(shape.deductionRatio)),
    upliftPct: fill(pct4(shape.uplift)),
    otherCharges: fill(shape.otherCharges),
    capRatePct: fill(pct4(shape.capRate)),
  };
}

/** Whether the reader has moved anything off the calibrated defaults -- drives the "edited" flag. */
export function billAssumptionsDifferFrom(current: BillAssumptions, defaults: BillAssumptions): boolean {
  const differs = (a: number[], b: number[]): boolean => a.length !== b.length || a.some((v, i) => v !== b[i]);
  return (
    differs(current.deductionPct, defaults.deductionPct) ||
    differs(current.upliftPct, defaults.upliftPct) ||
    differs(current.otherCharges, defaults.otherCharges) ||
    differs(current.capRatePct, defaults.capRatePct)
  );
}

/* ===========================================================================
 * URL ROUND-TRIP
 *
 * Explorer CACHES and REUSES resource components -- switching tabs away and back
 * reattaches the same instance rather than building a new one -- so state that lives only
 * in component fields survives a tab switch by luck, not design, and does not survive a
 * refresh or a shared link at all. Without this the reader loses their parcel every time
 * they look at something else and has to search for it again.
 *
 * `UpdateQueryParams` and `OnQueryParamsChanged` are a PAIR: anything pushed to the URL
 * owes a matching restore. These pure helpers are that pair's encode/decode, kept here so
 * the parsing of untrusted URL text is testable on its own.
 * =========================================================================== */

/** View state that survives a refresh, a tab switch, or a shared link. */
export interface BillViewParams {
  parcelId: string | null;
  scenario: ScenarioName | null;
  showAllColumns: boolean;
}

/**
 * Reads view state out of the URL.
 *
 * An unrecognised scenario yields `null` rather than a guess. URLs get hand-edited and go
 * stale, and silently landing the reader on a different scenario than the one named would
 * put a number in front of them under the wrong label.
 */
export function parseBillViewParams(params: Record<string, string>): BillViewParams {
  const rawScenario = (params['scenario'] ?? '').trim().toLowerCase();
  const scenario = SCENARIO_NAMES.find((n) => n.toLowerCase() === rawScenario) ?? null;
  return {
    parcelId: params['parcel']?.trim() || null,
    scenario,
    showAllColumns: (params['columns'] ?? '').trim().toLowerCase() === 'all',
  };
}

/**
 * Writes view state to the URL. `null` REMOVES a param rather than emptying it -- a
 * trailing `?parcel=` makes a cleared view look like a broken deep link.
 */
export function billViewParams(parcelId: string | null, scenario: ScenarioName, showAllColumns: boolean): Record<string, string | null> {
  return {
    parcel: parcelId || null,
    scenario,
    columns: showAllColumns ? 'all' : 'recent',
  };
}
