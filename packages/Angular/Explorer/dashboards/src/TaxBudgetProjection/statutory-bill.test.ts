import { describe, it, expect } from 'vitest';
import { computeStatutoryBill, sb1Rate, SB1_SCHEDULE, StatutoryBillInput } from './statutory-bill';

const none = { av1Pct: null, av2Pct: null, av3Pct: null };

/** Parcel 9047812, 8616 W 10th St — the TS-1 for 2025 pay 2026 the user supplied. */
const westside: StatutoryBillInput = {
  assessmentYear: 2025,
  grossAV: { av1Pct: null, av2Pct: 24_794_500, av3Pct: null },
  otherDeductions: none,
  rate: 3.6418,
  referendumRate: 0.35,
};

describe('sb1Rate — IC 6-1.1-12-47(c)', () => {
  it('phases in 6/12/19/25/30/33.4 and holds at 33.4 after AY2030', () => {
    expect(SB1_SCHEDULE).toEqual({ 2025: 0.06, 2026: 0.12, 2027: 0.19, 2028: 0.25, 2029: 0.3, 2030: 0.334 });
    expect(sb1Rate(2024)).toBe(0);
    expect(sb1Rate(2025)).toBe(0.06);
    expect(sb1Rate(2030)).toBe(0.334);
    expect(sb1Rate(2037)).toBe(0.334);
  });
});

describe('computeStatutoryBill — pure 2% parcel (9047812, pay 2026)', () => {
  const bill = computeStatutoryBill(westside);
  it('deducts 6% of the 2% AV: $1,487,670 → net $23,306,830', () => {
    expect(bill.sb1Deduction).toBe(1_487_670);
    expect(bill.netAV.av2Pct).toBe(23_306_830);
    expect(bill.netAVTotal).toBe(23_306_830);
  });
  it('gross tax = net × rate/100 = $848,788.14 (Table 1 line 3)', () => {
    expect(bill.grossTax).toBeCloseTo(848_788.14, 1);
  });
  it('referendum tax on NET AV = $81,573.91 (Table 2 "upward adjustment")', () => {
    expect(bill.referendumTax).toBeCloseTo(81_573.91, 2);
  });
  it('cap credit on the non-referendum tax = $271,324.24 (the Auditor Correction on the coupon)', () => {
    expect(bill.capCredit.av2Pct).toBeCloseTo(271_324.24, 0);
    expect(bill.capCreditTotal).toBeCloseTo(271_324.24, 0);
  });
  it('property tax due = Max Tax = $577,463.91 (Table 2)', () => {
    expect(bill.propertyTaxDue).toBeCloseTo(577_463.91, 0);
    expect(bill.maxTax).toBeCloseTo(577_463.91, 0);
    expect(bill.capped).toBe(true);
    expect(bill.impactDollars).toBe(0);
    expect(bill.impactPct).toBe(0);
  });
  it('the payYear is the assessment year + 1', () => {
    expect(bill.payYear).toBe(2026);
  });
});

describe('computeStatutoryBill — mixed parcels cap per class', () => {
  it('at 2.7291 (IPS, ref 0.373) the 2% portion caps and the 3% portion does not', () => {
    const b = computeStatutoryBill({
      assessmentYear: 2025,
      grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: 500_000 },
      otherDeductions: none,
      rate: 2.7291,
      referendumRate: 0.373,
    });
    expect(b.sb1Deduction).toBe(60_000);            // 6% of the 2% class only
    expect(b.netAV.av3Pct).toBe(500_000);            // 3% class untouched
    expect(b.grossTax).toBeCloseTo(39_299.04, 2);
    expect(b.referendumTax).toBeCloseTo(5_371.2, 2);
    expect(b.capCredit.av2Pct).toBeCloseTo(2_147.34, 2);
    expect(b.capCredit.av3Pct).toBe(0);
    expect(b.propertyTaxDue).toBeCloseTo(37_151.7, 2);
    expect(b.maxTax).toBeCloseTo(40_371.2, 2);
    expect(b.impactDollars).toBeCloseTo(3_219.5, 2);
    expect(b.impactPct).toBeCloseTo(0.0797, 3);
  });
  it('at 3.6418 (Wayne, ref 0.35) BOTH classes cap — the spreadsheet left the 3% portion uncapped', () => {
    const b = computeStatutoryBill({
      assessmentYear: 2025,
      grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: 1_000_000 },
      otherDeductions: none,
      rate: 3.6418,
      referendumRate: 0.35,
    });
    expect(b.capCredit.av3Pct).toBeCloseTo(2_918, 2);       // 1,000,000 × 3.2918% − 30,000
    expect(b.capCredit.av2Pct).toBeCloseTo(10_942.92, 2);   // 940,000 × 3.2918% − 20,000
  });
});

describe('computeStatutoryBill — other deductions, charges, credits, unknowns', () => {
  it('abated parcel: SB-1 applies to the 2% AV AFTER other deductions', () => {
    const b = computeStatutoryBill({
      assessmentYear: 2025,
      grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: null },
      otherDeductions: { av1Pct: null, av2Pct: 400_000, av3Pct: null },
      rate: 3.0,
      referendumRate: 0,
    });
    expect(b.sb1Deduction).toBe(36_000);   // 6% × 600,000
    expect(b.netAV.av2Pct).toBe(564_000);
  });
  it('an uncapped parcel pays gross tax and is reported as not capped', () => {
    const b = computeStatutoryBill({ ...westside, rate: 1.8, referendumRate: 0 });
    expect(b.capCreditTotal).toBe(0);
    expect(b.capped).toBe(false);
    expect(b.propertyTaxDue).toBeCloseTo(b.grossTax, 6);
  });
  it('flat charges are added after the cap; ad-valorem charges are levied on net AV; neither enters Max Tax', () => {
    const b = computeStatutoryBill({ ...westside, flatCharges: 7_484.4, adValoremChargeRate: 0.1 });
    expect(b.flatCharges).toBe(7_484.4);
    expect(b.adValoremCharges).toBeCloseTo(23_306.83, 2);
    expect(b.totalBill).toBeCloseTo(577_463.91 + 7_484.4 + 23_306.83, 0);
    expect(b.maxTax).toBeCloseTo(577_463.91, 0);
    expect(b.chargesSupplied).toBe(true);
  });
  it('with no charges supplied the total bill equals the property tax due and says so', () => {
    const b = computeStatutoryBill(westside);
    expect(b.flatCharges).toBeNull();
    expect(b.adValoremCharges).toBeNull();
    expect(b.chargesSupplied).toBe(false);
    expect(b.totalBill).toBeCloseTo(b.propertyTaxDue, 6);
  });
  it('local credits reduce the tax due after the cap (zero in Marion, needed for Lake)', () => {
    const b = computeStatutoryBill({ ...westside, localCredits: 1_000 });
    expect(b.propertyTaxDue).toBeCloseTo(576_463.91, 0);
  });
  it('an unknown referendum rate yields a null referendum tax, Max Tax at the bare cap, and referendumKnown false', () => {
    const b = computeStatutoryBill({ ...westside, referendumRate: null });
    expect(b.referendumTax).toBeNull();
    expect(b.referendumKnown).toBe(false);
    expect(b.maxTax).toBe(495_890);
    expect(b.capCreditTotal).toBeCloseTo(848_788.14 - 495_890, 0);
  });
  it('sb1Enabled:false computes the no-SB-1 counterfactual', () => {
    const b = computeStatutoryBill({ ...westside, sb1Enabled: false });
    expect(b.sb1Deduction).toBe(0);
    expect(b.netAVTotal).toBe(24_794_500);
  });
  it('headroom is the non-referendum tax above the ceiling as a share of Max Tax', () => {
    const b = computeStatutoryBill(westside);
    expect(b.headroom).toBeCloseTo(271_324.24 / 577_463.91, 4);
  });
});

import { projectSb1Series, summariseSb1, inferOtherDeductions } from './statutory-bill';

describe('projectSb1Series + summariseSb1 — the algebra of relief', () => {
  const pure2 = (rate: number): StatutoryBillInput => ({
    assessmentYear: 2025,
    grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: null },
    otherDeductions: none,
    rate,
    referendumRate: 0,
  });
  it('at a 3.0% rate the deduction only bites in AY2030 (33.4% > 1 − 2/3): first pay year with savings = 2031', () => {
    const s = projectSb1Series(pure2(3.0), 2025, 2030);
    expect(s.map((b) => b.payYear)).toEqual([2026, 2027, 2028, 2029, 2030, 2031]);
    expect(s[4].propertyTaxDue).toBe(20_000);          // AY2029: 700,000 × 3% = 21,000 → capped at 20,000
    expect(s[5].propertyTaxDue).toBeCloseTo(19_980, 2); // AY2030: 666,000 × 3% = 19,980 < 20,000
    const sum = summariseSb1(s);
    expect(sum.firstPayYearWithSavings).toBe(2031);
    // referendumRate: 0 here, so there's no referendum-leakage channel — the cap-piercing
    // savings figure and the "bill falls below Max Tax" figure land on the same pay year.
    expect(sum.firstPayYearBelowMaxTax).toBe(2031);
    // …and with no structural gap either (pure 2% class, no uncapped slice) the
    // SB-1-attributable headline lands on that same year.
    expect(sum.firstPayYearCapRelief).toBe(2031);
    expect(sum.impactPct2031).toBeCloseTo(0.001, 4);
    expect(sum.cumulativeSavings).toBeCloseTo(20, 2);
    expect(sum.stillCapped2031).toBe(false);
  });
  it('at 2.5% relief begins at 25% (AY2028, pay 2029) — 19% in AY2027 is short of 1 − 2/2.5', () => {
    const sum = summariseSb1(projectSb1Series(pure2(2.5), 2025, 2030));
    expect(sum.firstPayYearWithSavings).toBe(2029);
    expect(sum.firstPayYearBelowMaxTax).toBe(2029); // referendumRate: 0, same as above
    expect(sum.firstPayYearCapRelief).toBe(2029);   // no structural gap either
  });
  it('at 4.24% (Marion max) nothing through 2031: still capped, impact 0', () => {
    const sum = summariseSb1(projectSb1Series(pure2(4.24), 2025, 2030));
    expect(sum.firstPayYearWithSavings).toBeNull();
    expect(sum.firstPayYearBelowMaxTax).toBeNull(); // referendumRate: 0, same as above
    expect(sum.firstPayYearCapRelief).toBeNull();
    expect(sum.impactPct2031).toBe(0);
    expect(sum.sb1ImpactPct2031).toBe(0);
    expect(sum.stillCapped2031).toBe(true);
    expect(sum.reliefBucket).toBe('none-through-2031');
  });
  it('an uncapped parcel saves from pay 2026 and is bucketed immediate', () => {
    const sum = summariseSb1(projectSb1Series(pure2(1.8), 2025, 2030));
    expect(sum.firstPayYearWithSavings).toBe(2026);
    expect(sum.firstPayYearBelowMaxTax).toBe(2026); // uncapped from the start — both figures agree
    expect(sum.firstPayYearCapRelief).toBe(2026);   // and SB-1 itself widens the gap from year one
    expect(sum.reliefBucket).toBe('immediate');
    // savings are measured against the no-SB-1 counterfactual, not against Max Tax
    expect(sum.cumulativeSavings).toBeCloseTo((0.06 + 0.12 + 0.19 + 0.25 + 0.3 + 0.334) * 1_000_000 * 0.018, 0);
  });
  it('9047812 (Wayne, rate 3.6418, referendum 0.35): fully capped through 2031, but the referendum channel still saves — the two headline figures diverge', () => {
    // Bridge/record case: gross AV, rate and referendum held flat from the pay-2026 actual
    // bill. The general (non-referendum) portion is capped every year through 2031 at this
    // rate, so the bill never falls below Max Tax — firstPayYearBelowMaxTax is null and the
    // parcel buckets 'none-through-2031'. But the referendum is levied on NET AV and sits
    // OUTSIDE the circuit-breaker cap (IC 6-1.1-20.6), so SB-1's deduction shrinks the
    // referendum tax every phase-in year regardless of the cap — firstPayYearWithSavings
    // is 2026 (the very first assessment year in this series; AY2025's 6% phase-in already
    // trims the referendum base relative to the no-SB-1 counterfactual for that same year).
    const s = projectSb1Series(
      { grossAV: { av1Pct: null, av2Pct: 24_794_500, av3Pct: null }, otherDeductions: none, rate: 3.6418, referendumRate: 0.35 },
      2025,
      2030,
    );
    const sum = summariseSb1(s);
    expect(sum.firstPayYearBelowMaxTax).toBeNull();
    expect(sum.firstPayYearCapRelief).toBeNull(); // SB-1 never pierces the cap here
    expect(sum.sb1ImpactPct2031).toBe(0);
    expect(sum.reliefBucket).toBe('none-through-2031');
    expect(sum.stillCapped2031).toBe(true);
    expect(sum.firstPayYearWithSavings).toBe(2026);
    expect(sum.cumulativeSavings).toBeGreaterThan(0);
  });
  it('a mixed parcel is below Max Tax from pay 2026 for a reason that is not SB-1 — the two headlines separate', () => {
    // av2 1,000,000 / av3 500,000 at 2.7291 (IPS, ref 0.373). The 3% slice never caps
    // (2.3561% non-referendum rate < 3%), so the bill sits below Max Tax in pay 2026
    // already — with or without SB-1. SB-1's own cap-channel saving only opens once the
    // 2% slice's net AV falls under $848,860, i.e. at the 19% phase-in (AY2027 / pay 2028).
    const s = projectSb1Series(
      { grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: 500_000 }, otherDeductions: none, rate: 2.7291, referendumRate: 0.373 },
      2025,
      2030,
    );
    const sum = summariseSb1(s);
    expect(sum.firstPayYearBelowMaxTax).toBe(2026);  // structural: the uncapped 3% slice
    expect(sum.firstPayYearCapRelief).toBe(2028);    // SB-1's own effect on the cap
    expect(sum.reliefBucket).toBe('begins-2028-29'); // the bucket keys off the SB-1 figure
    expect(sum.sb1ImpactPct2031).toBeLessThan(sum.impactPct2031);
    expect(sum.sb1ImpactPct2031).toBeGreaterThan(0);
  });

  it('overrides replace gross AV, rate or referendum for a named assessment year and carry forward', () => {
    const s = projectSb1Series(pure2(3.0), 2025, 2030, [
      { assessmentYear: 2026, grossAV: { av1Pct: null, av2Pct: 1_200_000, av3Pct: null } },
    ]);
    expect(s[0].netAVTotal).toBe(940_000);
    expect(s[1].netAVTotal).toBe(1_056_000);
    expect(s[2].netAVTotal).toBe(972_000); // carried forward, not reverted
  });
  it('relief buckets: begins 2030–31 / begins 2028–29 / immediate / none', () => {
    expect(summariseSb1(projectSb1Series(pure2(3.0), 2025, 2030)).reliefBucket).toBe('begins-2030-31');
    expect(summariseSb1(projectSb1Series(pure2(2.5), 2025, 2030)).reliefBucket).toBe('begins-2028-29');
  });
});

describe('inferOtherDeductions — from a DLGF bill row', () => {
  it('9047812: gross − net is exactly the 6% deduction, so other deductions are zero', () => {
    const r = inferOtherDeductions({ assessmentYear: 2025, grossAV: { av1Pct: null, av2Pct: 24_794_500, av3Pct: null }, netAVTotal: 23_306_830 });
    expect(r.otherDeductions.av2Pct).toBe(0);
    expect(r.impliedSb1).toBe(1_487_670);
    expect(r.flag).toBeNull();
  });
  it('abated: (gross − net) exceeds the SB-1 share; the remainder attaches to the 2% class post-deduction', () => {
    // gross 1,000,000; other 400,000; SB-1 = 6% × 600,000 = 36,000; net = 564,000
    const r = inferOtherDeductions({ assessmentYear: 2025, grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: null }, netAVTotal: 564_000 });
    expect(r.otherDeductions.av2Pct).toBeCloseTo(400_000, 0);
    expect(r.flag).toBeNull();
  });
  it('mixed: other deductions are attributed to the 2% portion (99.8% of mixed bills carry none)', () => {
    const r = inferOtherDeductions({ assessmentYear: 2025, grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: 500_000 }, netAVTotal: 1_440_000 });
    expect(r.otherDeductions.av2Pct).toBe(0);
    expect(r.otherDeductions.av3Pct).toBe(0);
  });
  it('net ABOVE the SB-1-implied net (deduction not taken) is clamped to zero and flagged', () => {
    const r = inferOtherDeductions({ assessmentYear: 2025, grossAV: { av1Pct: null, av2Pct: 1_000_000, av3Pct: null }, netAVTotal: 1_000_000 });
    expect(r.otherDeductions.av2Pct).toBe(0);
    expect(r.flag).toBe('sb1-not-taken');
  });
});
