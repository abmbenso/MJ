/**
 * The statutory bill for property subject to the 2% circuit-breaker credit, with the
 * IC 6-1.1-12-47 (P.L.68-2025) phase-in deduction. Pure functions, no Angular.
 *
 * Verified against Marion pay-2026 bills before it was written (design §0):
 *   - the deduction applies to the 2%-class AV AFTER other deductions, never to 1%/3% AV;
 *   - the referendum is levied on NET AV and sits INSIDE the published total rate;
 *   - the cap credit is computed PER CLASS on the non-referendum tax;
 *   - Max Tax (TS-1 Table 2) = Σ capRate × gross AV by class + referendum tax.
 * Parcel 9047812's 2025p2026 bill reproduces to the dollar, including the $271,324.24
 * cap credit the county applied as an Auditor's Correction.
 *
 * Deliberately separate from computeBill() in tax-budget-projection-engine.ts, whose
 * `uplift` is an EMPIRICAL rate modifier calibrated from a parcel's own history. This
 * module is the statute; that one stays as it is so V1/V2 and the CLI keep working.
 */
import { CapClassAV } from './tax-budget-projection-types';

export type CapClass = keyof CapClassAV;
export const CAP_CLASSES: CapClass[] = ['av1Pct', 'av2Pct', 'av3Pct'];

/** Statutory circuit-breaker rates by class (IC 6-1.1-20.6-7.5(a)). */
export const CAP_RATES: Record<CapClass, number> = { av1Pct: 0.01, av2Pct: 0.02, av3Pct: 0.03 };

/** IC 6-1.1-12-47(c): percentage of the 2%-class AV deducted, by assessment year. */
export const SB1_SCHEDULE: Record<number, number> = { 2025: 0.06, 2026: 0.12, 2027: 0.19, 2028: 0.25, 2029: 0.3, 2030: 0.334 };
const SB1_FIRST_YEAR = 2025;
const SB1_FINAL_YEAR = 2030;

export function sb1Rate(assessmentYear: number): number {
  if (assessmentYear < SB1_FIRST_YEAR) return 0;
  if (assessmentYear >= SB1_FINAL_YEAR) return SB1_SCHEDULE[SB1_FINAL_YEAR];
  return SB1_SCHEDULE[assessmentYear];
}

export interface StatutoryBillInput {
  assessmentYear: number;
  /** Gross AV by cap class; null = the bill carries no AV in that class. */
  grossAV: CapClassAV;
  /** Deductions other than SB-1, by the class they attach to (abatements, etc.). */
  otherDeductions: CapClassAV;
  /** The district's total rate, dollars per $100 of net AV, as published. */
  rate: number;
  /** The district's referendum rate, dollars per $100, INSIDE `rate`. null = unknown. */
  referendumRate: number | null;
  /** Local credits (LIT PTRC etc.) in dollars, applied after the cap. Zero in Marion. */
  localCredits?: number;
  /** Flat other charges (storm water) in dollars. null = not supplied. */
  flatCharges?: number | null;
  /** Ad-valorem other charges (a downtown district) in dollars per $100 of net AV. null = not supplied. */
  adValoremChargeRate?: number | null;
  /** false computes the no-SB-1 counterfactual. Default true. */
  sb1Enabled?: boolean;
}

export interface StatutoryBill {
  assessmentYear: number;
  payYear: number;
  sb1Rate: number;
  sb1Deduction: number;
  netAV: CapClassAV;
  netAVTotal: number;
  grossTax: number;
  referendumKnown: boolean;
  referendumTax: number | null;
  capCredit: CapClassAV;
  capCreditTotal: number;
  localCredits: number;
  propertyTaxDue: number;
  flatCharges: number | null;
  adValoremCharges: number | null;
  chargesSupplied: boolean;
  totalBill: number;
  /** Σ capRate × gross AV — the bare ceiling without the referendum. */
  capCeiling: number;
  /** TS-1 Table 2: capCeiling + referendum tax. */
  maxTax: number;
  capped: boolean;
  /** Non-referendum tax above the ceiling, as a share of Max Tax. */
  headroom: number;
  /** (Max Tax − property tax due) / Max Tax, zero when still capped. */
  impactPct: number;
  impactDollars: number;
  /** Echo of the inputs actually used to compute this bill — summariseSb1's no-SB-1 counterfactual needs them back. */
  grossAVUsed: CapClassAV;
  otherDeductionsUsed: CapClassAV;
  rateUsed: number;
  referendumRateUsed: number | null;
}

/**
 * Rounds a dollar figure to cents. A plain `Math.round(x * 100) / 100` misrounds exact
 * halfway cents (e.g. 23,306,830 × 0.35 / 100 = 81,573.905 mathematically, but the
 * float multiplication lands at 81,573.90499999998 and rounds DOWN to .90 instead of
 * .91 — verified against the 9047812 referendum-tax line). The tiny epsilon nudges
 * genuine halfway values back onto the correct side without perturbing any other value.
 */
const r2 = (x: number): number => Math.round((x + 1e-7) * 100) / 100;

export function computeStatutoryBill(input: StatutoryBillInput): StatutoryBill {
  const sb1Enabled = input.sb1Enabled ?? true;
  const schedule = sb1Enabled ? sb1Rate(input.assessmentYear) : 0;
  const refKnown = input.referendumRate != null;
  const ref = input.referendumRate ?? 0;
  const gross = (c: CapClass) => input.grossAV[c] ?? 0;
  const other = (c: CapClass) => input.otherDeductions[c] ?? 0;

  // SB-1 applies to the 2% class only, after other deductions. Whole dollars: AV is billed in whole dollars.
  const base2 = Math.max(0, gross('av2Pct') - other('av2Pct'));
  const sb1Deduction = Math.round(base2 * schedule);

  const netAV: CapClassAV = { av1Pct: null, av2Pct: null, av3Pct: null };
  for (const c of CAP_CLASSES) {
    if (input.grossAV[c] == null) continue;
    const n = Math.max(0, gross(c) - other(c) - (c === 'av2Pct' ? sb1Deduction : 0));
    netAV[c] = n;
  }
  const netAVTotal = CAP_CLASSES.reduce((s, c) => s + (netAV[c] ?? 0), 0);

  // Everything below is computed on RAW (unrounded) dollars and rounded exactly once, at the
  // point each field is returned. Rounding grossTax/referendumTax/capCredit independently and
  // then deriving propertyTaxDue/maxTax from those already-rounded pieces can leave the two
  // a cent apart (each component's own cent rounds a different direction) even though they are
  // mathematically identical when the parcel is fully capped — verified against 9047812, whose
  // Max Tax and property tax due are the same $577,463.91 line on the TS-1.
  const grossTaxRaw = (netAVTotal * input.rate) / 100;
  const referendumTaxRaw = refKnown ? (netAVTotal * ref) / 100 : null;

  const capCreditRaw: CapClassAV = { av1Pct: null, av2Pct: null, av3Pct: null };
  let capCeilingRaw = 0;
  for (const c of CAP_CLASSES) {
    if (input.grossAV[c] == null) continue;
    const ceiling = CAP_RATES[c] * gross(c);
    capCeilingRaw += ceiling;
    const nonRefTax = ((netAV[c] ?? 0) * (input.rate - ref)) / 100;
    capCreditRaw[c] = Math.max(0, nonRefTax - ceiling);
  }
  const capCreditTotalRaw = CAP_CLASSES.reduce((s, c) => s + (capCreditRaw[c] ?? 0), 0);

  const localCredits = input.localCredits ?? 0;
  const propertyTaxDueRaw = grossTaxRaw - capCreditTotalRaw - localCredits;

  const flatCharges = input.flatCharges ?? null;
  const adValoremChargesRaw = input.adValoremChargeRate == null ? null : (netAVTotal * input.adValoremChargeRate) / 100;
  const chargesSupplied = flatCharges != null || adValoremChargesRaw != null;
  const totalBillRaw = propertyTaxDueRaw + (flatCharges ?? 0) + (adValoremChargesRaw ?? 0);

  const maxTaxRaw = capCeilingRaw + (referendumTaxRaw ?? 0);
  const nonRefTotalRaw = grossTaxRaw - (referendumTaxRaw ?? 0);
  const headroom = maxTaxRaw > 0 ? (nonRefTotalRaw - capCeilingRaw) / maxTaxRaw : 0;
  const impactDollarsRaw = Math.max(0, maxTaxRaw - propertyTaxDueRaw);
  const impactPct = maxTaxRaw > 0 ? impactDollarsRaw / maxTaxRaw : 0;

  const capCredit: CapClassAV = {
    av1Pct: capCreditRaw.av1Pct == null ? null : r2(capCreditRaw.av1Pct),
    av2Pct: capCreditRaw.av2Pct == null ? null : r2(capCreditRaw.av2Pct),
    av3Pct: capCreditRaw.av3Pct == null ? null : r2(capCreditRaw.av3Pct),
  };
  const grossTax = r2(grossTaxRaw);
  const referendumTax = referendumTaxRaw == null ? null : r2(referendumTaxRaw);
  const capCreditTotal = r2(capCreditTotalRaw);
  const propertyTaxDue = r2(propertyTaxDueRaw);
  const adValoremCharges = adValoremChargesRaw == null ? null : r2(adValoremChargesRaw);
  const totalBill = r2(totalBillRaw);
  const capCeiling = r2(capCeilingRaw);
  const maxTax = r2(maxTaxRaw);
  const capped = capCreditTotal > 0;
  const impactDollars = r2(impactDollarsRaw);

  return {
    assessmentYear: input.assessmentYear,
    payYear: input.assessmentYear + 1,
    sb1Rate: schedule,
    sb1Deduction,
    netAV,
    netAVTotal,
    grossTax,
    referendumKnown: refKnown,
    referendumTax,
    capCredit,
    capCreditTotal,
    localCredits,
    propertyTaxDue,
    flatCharges,
    adValoremCharges,
    chargesSupplied,
    totalBill,
    capCeiling,
    maxTax,
    capped,
    headroom,
    impactPct,
    impactDollars,
    grossAVUsed: { ...input.grossAV },
    otherDeductionsUsed: { ...input.otherDeductions },
    rateUsed: input.rate,
    referendumRateUsed: input.referendumRate,
  };
}

export interface SeriesYearOverride {
  assessmentYear: number;
  grossAV?: CapClassAV;
  otherDeductions?: CapClassAV;
  rate?: number;
  referendumRate?: number | null;
  flatCharges?: number | null;
  adValoremChargeRate?: number | null;
}

/**
 * One bill per assessment year from firstAY to lastAY inclusive. The RECORD case holds
 * every input flat (the template's convention — it isolates the statutory effect); an
 * override for a year replaces the named inputs and CARRIES FORWARD to later years, so a
 * known AY2026 assessment pins the bridge year and everything after it.
 */
export function projectSb1Series(
  template: Omit<StatutoryBillInput, 'assessmentYear'>,
  firstAY: number,
  lastAY: number,
  overrides: SeriesYearOverride[] = [],
): StatutoryBill[] {
  const byYear = new Map(overrides.map((o) => [o.assessmentYear, o]));
  let current: Omit<StatutoryBillInput, 'assessmentYear'> = { ...template };
  const out: StatutoryBill[] = [];
  for (let ay = firstAY; ay <= lastAY; ay++) {
    const o = byYear.get(ay);
    if (o) {
      const { assessmentYear: _ignored, ...rest } = o;
      current = { ...current, ...rest };
    }
    out.push(computeStatutoryBill({ ...current, assessmentYear: ay }));
  }
  return out;
}

export type ReliefBucket = 'none-through-2031' | 'begins-2030-31' | 'begins-2028-29' | 'immediate' | 'not-applicable';

export interface Sb1Summary {
  /**
   * First pay year in which SB-1 lowers the bill by at least $1 against the no-SB-1
   * counterfactual — BOTH channels: the capped general portion (rare; only when the
   * deduction eventually pierces the cap) AND the referendum portion (routine; the
   * referendum sits outside the circuit-breaker cap and is levied on NET AV, so SB-1's
   * deduction shrinks it every phase-in year even while the parcel stays fully capped).
   * This can be earlier than `firstPayYearBelowMaxTax` for exactly that reason — a
   * capped parcel in a referendum district saves through the referendum channel starting
   * in the first phase-in year, while its total bill still sits at Max Tax. Use this
   * figure for "how much does SB-1 actually save this taxpayer"; use
   * `firstPayYearBelowMaxTax` for "when does the cap stop binding."
   */
  firstPayYearWithSavings: number | null;
  /**
   * First pay year (≤ throughPayYear) whose bill falls below Max Tax by at least $1 —
   * i.e. the cap no longer binds (`impactDollars >= 1`). STRUCTURAL, not attributable to
   * SB-1: it includes gaps that exist without SB-1 at all — an uncapped 3% slice on a
   * mixed parcel, or a low-rate district whose bill never reaches Max Tax — so a parcel
   * can sit below Max Tax in pay 2026 for reasons that have nothing to do with the
   * deduction. Use `firstPayYearCapRelief` for SB-1's own effect on the cap; this figure
   * is kept for context ("when does the cap stop binding, whatever the cause").
   */
  firstPayYearBelowMaxTax: number | null;
  /**
   * First pay year (≤ throughPayYear) in which SB-1's OWN deduction moves the bill below
   * Max Tax — the first year the cap-channel saving reaches $1, measured as
   * `bill.impactDollars − counterfactual.impactDollars >= 1`. Algebraically this is the
   * total saving less the referendum-channel saving: on a capped parcel the referendum
   * portion shrinks from the first phase-in year while the bill stays pinned at Max Tax,
   * and that shows up equally in both the with- and without-SB-1 gaps, so it cancels.
   * What is left is exactly the year SB-1 itself pushes the bill off the ceiling. This is
   * the headline figure and is what `reliefBucket` keys off.
   */
  firstPayYearCapRelief: number | null;
  /**
   * (Max Tax − property tax due) / Max Tax in the final pay year of the horizon.
   * STRUCTURAL, like `firstPayYearBelowMaxTax`: the whole gap below Max Tax whatever its
   * cause (an uncapped 3% slice, a low rate), not just SB-1's share of it. See
   * `sb1ImpactPct2031` for the SB-1-attributable figure.
   */
  impactPct2031: number;
  /**
   * SB-1's OWN share of Max Tax in the final pay year: (impactDollars −
   * counterfactual impactDollars) / Max Tax, i.e. how much of the ceiling the deduction
   * itself has cleared. Zero when Max Tax is zero. Always ≤ `impactPct2031`.
   */
  sb1ImpactPct2031: number;
  /** Σ (counterfactual due − due) across the horizon, dollars. */
  cumulativeSavings: number;
  stillCapped2031: boolean;
  reliefBucket: ReliefBucket;
  /** Per-year savings against the no-SB-1 counterfactual, keyed by pay year. */
  savingsByPayYear: Record<number, number>;
}

export function summariseSb1(series: StatutoryBill[], throughPayYear = 2031): Sb1Summary {
  const savingsByPayYear: Record<number, number> = {};
  let first: number | null = null;
  let firstBelowMaxTax: number | null = null;
  let firstCapRelief: number | null = null;
  let cumulative = 0;
  let lastWithout: StatutoryBill | null = null;
  for (const b of series) {
    if (b.payYear > throughPayYear) continue;
    const without = computeStatutoryBill({
      assessmentYear: b.assessmentYear,
      grossAV: b.grossAVUsed,
      otherDeductions: b.otherDeductionsUsed,
      rate: b.rateUsed,
      referendumRate: b.referendumKnown ? b.referendumRateUsed : null,
      localCredits: b.localCredits,
      sb1Enabled: false,
    });
    const saving = r2(Math.max(0, without.propertyTaxDue - b.propertyTaxDue));
    savingsByPayYear[b.payYear] = saving;
    cumulative += saving;
    if (first == null && saving >= 1) first = b.payYear;
    if (firstBelowMaxTax == null && b.impactDollars >= 1) firstBelowMaxTax = b.payYear;
    // The cap channel alone: the gap below Max Tax that SB-1 opened, net of the gap that
    // would exist anyway (an uncapped 3% slice, a low-rate district).
    if (firstCapRelief == null && b.impactDollars - without.impactDollars >= 1) firstCapRelief = b.payYear;
    lastWithout = without;
  }
  const last = series.filter((b) => b.payYear <= throughPayYear).slice(-1)[0];
  const impactPct2031 = last ? last.impactPct : 0;
  const sb1ImpactPct2031 = last && lastWithout && last.maxTax > 0 ? (last.impactDollars - lastWithout.impactDollars) / last.maxTax : 0;
  const stillCapped2031 = last ? last.capped : false;
  let reliefBucket: ReliefBucket;
  if (firstCapRelief == null) reliefBucket = 'none-through-2031';
  else if (firstCapRelief <= 2027) reliefBucket = 'immediate';
  else if (firstCapRelief <= 2029) reliefBucket = 'begins-2028-29';
  else reliefBucket = 'begins-2030-31';
  return {
    firstPayYearWithSavings: first,
    firstPayYearBelowMaxTax: firstBelowMaxTax,
    firstPayYearCapRelief: firstCapRelief,
    impactPct2031,
    sb1ImpactPct2031,
    cumulativeSavings: r2(cumulative),
    stillCapped2031,
    reliefBucket,
    savingsByPayYear,
  };
}

export interface DlgfBillAV {
  assessmentYear: number;
  grossAV: CapClassAV;
  /** DLGF NetAssessedValue — the total after ALL deductions including SB-1. */
  netAVTotal: number;
}

export interface InferredDeductions {
  otherDeductions: CapClassAV;
  /** The SB-1 deduction the statute implies on the inferred base. */
  impliedSb1: number;
  flag: 'sb1-not-taken' | null;
}

/**
 * The DLGF file carries one net AV, not the deduction lines. Solve for other deductions
 * assuming they attach to the 2% class (99.8% of mixed bills carry none, and 88.8% of
 * abated bills fit a post-other-deduction base — design §0):
 *   net = gross − other − s × (av2 − other)   ⇒   other = (gross − net − s × av2) / (1 − s)
 */
export function inferOtherDeductions(bill: DlgfBillAV): InferredDeductions {
  const s = sb1Rate(bill.assessmentYear);
  const av2 = bill.grossAV.av2Pct ?? 0;
  const grossTotal = CAP_CLASSES.reduce((t, c) => t + (bill.grossAV[c] ?? 0), 0);
  const totalDeductions = grossTotal - bill.netAVTotal;
  let other2 = (totalDeductions - s * av2) / (1 - s);
  let flag: InferredDeductions['flag'] = null;
  if (other2 < -1) {
    // Net is higher than SB-1 alone would leave it: the deduction was not applied on this bill.
    other2 = 0;
    flag = 'sb1-not-taken';
  }
  other2 = Math.max(0, Math.round(other2));
  const otherDeductions: CapClassAV = {
    av1Pct: bill.grossAV.av1Pct == null ? null : 0,
    av2Pct: bill.grossAV.av2Pct == null ? null : other2,
    av3Pct: bill.grossAV.av3Pct == null ? null : 0,
  };
  return { otherDeductions, impliedSb1: Math.round(Math.max(0, av2 - other2) * s), flag };
}
