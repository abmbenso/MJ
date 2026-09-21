/**
 * The Appeal Workbench's decision rules. One owner per rule:
 *  - reconcile(): credible band, supports, floor, ask, recommendation
 *    (band and 5% discount from Indiana_Tax_Expert/docs/proposals/valuation-target-value.md).
 *  - burdenOnAssessor(): the IC 6-1.1-15-17.2 comparison. The prior value must be
 *    "as finally determined" (PTABOA value first); the screen-level rule and its
 *    exceptions (new construction, use or zoning change) are owned by
 *    Indiana_Tax_Expert/scripts/burden_shift_screen.sql — do not restate them here.
 *  - estimateSavings(): the circuit breaker as a rate modifier: min(rate, cap + referendum).
 * Pure functions; no Angular, no MJ.
 */
export type Approach = 'Income' | 'Sales' | 'AssessmentComps' | 'Cost' | 'ActualIE';
export type IndicationStatus = 'Computed' | 'NotProvided' | 'Excluded';
export type AskPolicy = 'Lowest' | 'SecondLowest';
export type Recommendation = 'Appeal' | 'No Appeal' | 'Monitor';

export interface Indication { approach: Approach; value: number | null; status: IndicationStatus; }
export interface IndicationRow extends Indication { pctOfAV: number | null; credible: boolean; supports: boolean; }
export interface Reconciliation {
  rows: IndicationRow[];
  floor: number | null; floorApproach: Approach | null;
  ask: number | null; askApproach: Approach | null;
  recommendation: Recommendation;
}

export const CREDIBLE_BAND = { low: 0.5, high: 1.2 } as const;
export const MIN_ASK_DISCOUNT = 0.05;
export const COMMERCIAL_CAP = 0.03;

export function reconcile(indications: Indication[], currentAV: number, policy: AskPolicy = 'Lowest'): Reconciliation {
  const rows: IndicationRow[] = indications.map((i) => {
    const v = i.status === 'Computed' ? i.value : null;
    const pctOfAV = v != null && currentAV > 0 ? v / currentAV : null;
    const credible = pctOfAV != null && pctOfAV >= CREDIBLE_BAND.low && pctOfAV <= CREDIBLE_BAND.high;
    const supports = credible && (v as number) < currentAV;
    return { ...i, pctOfAV, credible, supports };
  });
  const supporting = rows.filter((r) => r.supports).sort((a, b) => (a.value as number) - (b.value as number));
  const floorRow = supporting[0] ?? null;
  const askRow = policy === 'SecondLowest' && supporting.length >= 2 ? supporting[1] : floorRow;
  const ask = askRow?.value ?? null;
  const recommendation: Recommendation =
    ask != null && ask <= currentAV * (1 - MIN_ASK_DISCOUNT) ? 'Appeal'
    : rows.some((r) => r.credible) ? 'No Appeal'
    : 'Monitor';
  return {
    rows,
    floor: floorRow?.value ?? null, floorApproach: floorRow?.approach ?? null,
    ask, askApproach: askRow?.approach ?? null,
    recommendation,
  };
}

export function burdenOnAssessor(currentAV: number, priorFinalAV: number | null): boolean | null {
  if (priorFinalAV == null || priorFinalAV <= 0) return null;
  return currentAV > priorFinalAV * 1.05;
}

/** Decimal marginal rate: the lesser of the district rate and the cap plus referendum rate. Rates arrive per $100. */
export function marginalRate(taxRatePer100: number, capPct: number, referendumRatePer100: number | null): number {
  return Math.min(taxRatePer100 / 100, capPct + (referendumRatePer100 ?? 0) / 100);
}

export function estimateSavings(
  currentAV: number, target: number | null, taxRatePer100: number | null, capPct: number, referendumRatePer100: number | null,
): { rate: number | null; savings: number | null; basis: 'cap' | 'rate' | null } {
  if (target == null || taxRatePer100 == null || taxRatePer100 <= 0) return { rate: null, savings: null, basis: null };
  const rate = marginalRate(taxRatePer100, capPct, referendumRatePer100);
  const basis = rate < taxRatePer100 / 100 ? 'cap' : 'rate';
  return { rate, savings: Math.round(Math.max(0, currentAV - target) * rate), basis };
}
