/**
 * V2 view model: turns what the shared engine already computes into TS-1 bill rows.
 *
 * The whole point of the bill-shaped layout is that a reader can verify the arithmetic
 * down a column by eye -- gross AV minus deductions is net AV, net AV times the rate is
 * gross tax, gross tax minus the circuit-breaker credit is what is due. V1 showed only
 * AV, rate and tax, which stopped multiplying out once the cap was modelled and read as
 * an arithmetic error.
 *
 * This file is PURE. It does no data access and knows nothing about Angular, so the
 * layout is unit-testable and the component stays a thin renderer. All computation still
 * belongs to ../TaxBudgetProjection/tax-budget-projection-engine.
 */

import { BillFigure, BillLines, CapClassAV } from '../TaxBudgetProjection/tax-budget-projection-types';

/**
 * The engine's TS-1 chain plus the one line it has no need to model.
 *
 * `localCredits` is TS-1 line 4a -- LIT property-tax-replacement and similar local credits
 * that reduce the bill BEFORE the circuit breaker's 4b. A real DLGF bill has them
 * (TotalPropertyTaxDue = GrossTaxDue - SUM of type-'C' adjustments, which is what the
 * taxbill-bridge integrity check gates on), so without this line a historical column does
 * not add up and the format's whole promise -- verify the arithmetic by eye -- fails.
 *
 * It is absent on PROJECTED columns by design, not by omission: the calibrated uplift is
 * an EFFECTIVE figure already net of these credits (see scripts/lib/district-uplift.js),
 * so projecting a separate 4a would double-count them.
 */
export type BillGridLines = BillLines & {
  localCredits?: BillFigure;
  /* --- Assessment breakdown. NOT TS-1 lines. ---
   * The paper TS-1 splits line 1 by CAP CLASS (homestead / other residential / all other),
   * never land vs improvement. These come from the assessment, not the bill, and are shown
   * because land and improvements trend differently -- improvements carry the volatility --
   * so a projection has to let them move at different rates. They roll up to line 2. */
  land?: BillFigure;
  improvement?: BillFigure;
};

/** One year's bill, rendered as a column. */
export interface BillColumn {
  assessmentYear: number;
  /** Indiana bills assessment year N in year N + 1. */
  payYear: number;
  /** Column heading, e.g. "2025 pay 2026". */
  label: string;
  lines: BillGridLines;
  isProjected: boolean;
}

/**
 * Every line the grid can render. Derived from BillLines rather than restated as a hand
 * written union, so a new engine line cannot silently go missing here.
 */
export type BillLineKey = keyof BillGridLines;

/** One TS-1 line, rendered as a row across every column. */
export interface BillRow {
  key: BillLineKey;
  /** The line number as it appears on the paper TS-1, so the layouts map onto each other. */
  tsLine: string;
  label: string;
  /** false for the tax rate, which is a percentage and must not render as dollars. */
  isCurrency: boolean;
  /** One figure per column, in column order. Provenance is preserved per figure. */
  figures: BillFigure[];
  /** True for the assessment breakdown rows, which carry no TS-1 line number. */
  isBreakdown: boolean;
}

interface SpineEntry {
  key: BillLineKey;
  tsLine: string;
  label: string;
  isCurrency: boolean;
  isBreakdown?: boolean;
}

/**
 * TS-1 Table 1, in bill order. Labels track the paper form's wording so a taxpayer
 * comparing the two is reading the same line twice, not translating between them.
 */
const SPINE: readonly SpineEntry[] = [
  { key: 'land', tsLine: '', label: 'Land', isCurrency: true, isBreakdown: true },
  { key: 'improvement', tsLine: '', label: 'Improvements', isCurrency: true, isBreakdown: true },
  { key: 'grossAV', tsLine: '2', label: 'Equals total gross assessed value of property', isCurrency: true },
  { key: 'deductions', tsLine: '2a', label: 'Minus deductions', isCurrency: true },
  { key: 'netAV', tsLine: '3', label: 'Equals subtotal of net assessed value of property', isCurrency: true },
  { key: 'rate', tsLine: '3a', label: 'Multiplied by your local tax rate', isCurrency: false },
  { key: 'grossTax', tsLine: '4', label: 'Equals gross tax liability', isCurrency: true },
  { key: 'localCredits', tsLine: '4a', label: 'Minus local property tax credits', isCurrency: true },
  { key: 'capSavings', tsLine: '4b', label: 'Minus circuit breaker credit', isCurrency: true },
  { key: 'otherCharges', tsLine: 'T4', label: 'Plus other charges and assessments (Table 4)', isCurrency: true },
  { key: 'totalDue', tsLine: '5', label: 'Equals total amount due', isCurrency: true },
];

/**
 * Lines that may be dropped when they are zero or absent in EVERY column.
 *
 * The paper bill prints these because it is a FORM -- it must accommodate every taxpayer,
 * including the one with an Over-65 deduction. A tool that shows "$0.00" forever on every
 * commercial parcel is just noise. Everything else is spine: suppressing "total due"
 * because a parcel is exempt would hide the answer the view exists to give.
 */
const SUPPRESSIBLE: ReadonlySet<BillLineKey> = new Set<BillLineKey>([
  'otherCharges',
  'deductions',
  'localCredits',
  // Dropped together when the parcel has no assessment split at all -- two permanently
  // blank rows above the bill would be noise, not information.
  'land',
  'improvement',
]);

function hasSubstance(figures: readonly BillFigure[]): boolean {
  return figures.some((f) => f.value != null && f.value !== 0);
}

const UNAVAILABLE: BillFigure = { value: null, source: 'projected' };

function figuresFor(columns: readonly BillColumn[], key: BillLineKey): BillFigure[] {
  // A line the column does not carry is UNAVAILABLE, never a fabricated $0.00.
  return columns.map((c) => c.lines[key] ?? UNAVAILABLE);
}

/**
 * Build the TS-1 Table 1 grid: one row per bill line, one figure per column.
 *
 * Returns [] for no columns rather than an empty skeleton -- a header with no figures
 * under it invites the reader to think the bill is zero rather than unloaded.
 */
export function buildBillGrid(columns: readonly BillColumn[]): BillRow[] {
  if (!columns.length) return [];

  const rows: BillRow[] = [];
  for (const entry of SPINE) {
    const figures = figuresFor(columns, entry.key);
    if (SUPPRESSIBLE.has(entry.key) && !hasSubstance(figures)) continue;
    rows.push({ ...entry, isBreakdown: entry.isBreakdown === true, figures });
  }
  return rows;
}

const CAP_SUMMARY: readonly SpineEntry[] = [
  { key: 'capCeiling', tsLine: '4b', label: 'Circuit breaker cap ceiling', isCurrency: true },
  { key: 'capSavings', tsLine: '4b', label: 'Credit applied (tax above the ceiling)', isCurrency: true },
];

/**
 * TS-1 Table 2, the circuit-breaker block.
 *
 * Returns [] when the cap never bound in any column: an all-zero savings block tells the
 * reader nothing, and printing it implies the cap is doing work when it is not. As soon
 * as it binds in ANY column the whole block appears, so the reader can see the year it
 * started biting.
 */
export function capSummaryRows(columns: readonly BillColumn[]): BillRow[] {
  if (!columns.length) return [];
  if (!hasSubstance(figuresFor(columns, 'capSavings'))) return [];
  return CAP_SUMMARY.map((entry) => ({ ...entry, isBreakdown: false, figures: figuresFor(columns, entry.key) }));
}

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
