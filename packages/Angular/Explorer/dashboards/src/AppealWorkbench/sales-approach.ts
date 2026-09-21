/**
 * The sales-comparison approach, ported from the batch script that seeds candidate comps
 * (Indiana_Tax_Expert scripts/build-valuation-comps.js) so the analyst can see, question and
 * tune the same adjustment math live instead of trusting a nightly black box. Four factors,
 * each a fixed coefficient times a raw characteristic difference, each independently clamped.
 * The clamps are engine constants, never analyst-editable -- the guardrail against an edited
 * coefficient producing an indefensible outlier. Pure; no Angular, no MJ.
 */
export interface SalesCompInput {
  id: string;              // SaleTransactionID -- the stable key across batch re-runs
  rawPerUnit: number;      // the comp's actual observed $/SF or $/unit -- never derived
  compDenominator: number;
  compYearBuilt: number | null;
  compGradeOrdinal: number | null;
  saleDate: string;        // ISO date
}
export interface SalesSubjectInput {
  denominator: number;
  effectiveYearBuilt: number | null;
  gradeOrdinal: number | null;
  lienDate: string;        // ISO date -- Jan 1 of the ANALYSIS's own AssessmentYear, never hardcoded
}
export interface SalesCoefficients {
  sizeElasticity: number; sizeEnabled: boolean;
  ageRatePerYear: number; ageEnabled: boolean;
  gradeRatePerStep: number; gradeEnabled: boolean;
  appreciationRatePerYear: number; timeEnabled: boolean;
}
export interface SalesCompResult {
  id: string; rawPerUnit: number;
  sizeAdjPct: number; ageAdjPct: number; gradeAdjPct: number; timeAdjPct: number;
  netAdjPct: number; grossAdjPct: number;
  adjustedPerUnit: number; subjectIndicatedValue: number;
  /** gross > 50% -- informational only (the old batch behaviour was a hard drop; here it's a badge). */
  grossAdjustmentWarning: boolean;
}

const SIZE_CAP = 0.15, AGE_CAP = 0.20, GRADE_CAP = 0.20, TIME_CAP_LO = -0.05, TIME_CAP_HI = 0.30;
const GROSS_WARNING_THRESHOLD = 0.50;
const MS_PER_YEAR = 365.25 * 86400000;

const clamp = (x: number, lo: number, hi: number): number => Math.max(lo, Math.min(hi, x));
const yearsBetween = (from: string, to: string): number => Math.max(0, (new Date(to).getTime() - new Date(from).getTime()) / MS_PER_YEAR);

export function computeCompAdjustment(subject: SalesSubjectInput, comp: SalesCompInput, coef: SalesCoefficients): SalesCompResult {
  const sizeAdjPct = coef.sizeEnabled && comp.compDenominator > 0 && subject.denominator > 0
    ? clamp(coef.sizeElasticity * Math.log(comp.compDenominator / subject.denominator), -SIZE_CAP, SIZE_CAP) : 0;
  const ageAdjPct = coef.ageEnabled && subject.effectiveYearBuilt != null && comp.compYearBuilt != null
    ? clamp((subject.effectiveYearBuilt - comp.compYearBuilt) * coef.ageRatePerYear, -AGE_CAP, AGE_CAP) : 0;
  const gradeAdjPct = coef.gradeEnabled && subject.gradeOrdinal != null && comp.compGradeOrdinal != null
    ? clamp((subject.gradeOrdinal - comp.compGradeOrdinal) * coef.gradeRatePerStep, -GRADE_CAP, GRADE_CAP) : 0;
  const timeAdjPct = coef.timeEnabled
    ? clamp(coef.appreciationRatePerYear * yearsBetween(comp.saleDate, subject.lienDate), TIME_CAP_LO, TIME_CAP_HI) : 0;

  const netAdjPct = sizeAdjPct + ageAdjPct + gradeAdjPct + timeAdjPct;
  const grossAdjPct = Math.abs(sizeAdjPct) + Math.abs(ageAdjPct) + Math.abs(gradeAdjPct) + Math.abs(timeAdjPct);
  const adjustedPerUnit = comp.rawPerUnit * (1 + netAdjPct);
  return {
    id: comp.id, rawPerUnit: comp.rawPerUnit,
    sizeAdjPct, ageAdjPct, gradeAdjPct, timeAdjPct, netAdjPct, grossAdjPct,
    adjustedPerUnit, subjectIndicatedValue: adjustedPerUnit * subject.denominator,
    grossAdjustmentWarning: grossAdjPct > GROSS_WARNING_THRESHOLD,
  };
}

function median(values: number[]): number | null {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const mid = sorted.length >> 1;
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

export const SALES_MINIMUM_COMPS = 3;

export interface SalesIndication { value: number | null; unadjustedValue: number | null; comps: number; belowMinimum: boolean; }

/** Median across INCLUDED comps only. Rounded to $1,000, matching income-approach.ts's own rounding. */
export function salesIndicatedValue(results: SalesCompResult[], includedIds: Set<string>, subjectDenominator: number, roundStep = 1000): SalesIndication {
  const included = results.filter((r) => includedIds.has(r.id));
  const round = (n: number | null): number | null => (n == null ? null : Math.round(n / roundStep) * roundStep);
  return {
    value: round(median(included.map((r) => r.subjectIndicatedValue))),
    unadjustedValue: round(median(included.map((r) => r.rawPerUnit * subjectDenominator))),
    comps: included.length,
    belowMinimum: included.length < SALES_MINIMUM_COMPS,
  };
}
