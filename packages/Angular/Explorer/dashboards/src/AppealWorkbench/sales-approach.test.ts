import { describe, it, expect } from 'vitest';
import { computeCompAdjustment, salesIndicatedValue, SALES_MINIMUM_COMPS } from './sales-approach';

const DEFAULT_COEF = {
  sizeElasticity: 0.1, sizeEnabled: true,
  ageRatePerYear: 0.005, ageEnabled: true,
  gradeRatePerStep: 0.08, gradeEnabled: true,
  appreciationRatePerYear: 0.03, timeEnabled: true,
};

/**
 * Golden-test fixtures below are two real rows pulled live from `indiana_tax.ValuationComp`
 * (2026-09-16), both against the same subject (ValuationAnalysisID 04BAF63E-F36B-1410-8D34-
 * 00F6C896F66E, a Multifamily parcel):
 *
 *   SELECT TOP 3 vc.*, va.ParcelID, ppp.EffectiveYear, ppp.GradeOrdinal
 *   FROM indiana_tax.ValuationComp vc
 *   JOIN indiana_tax.ValuationAnalysis va ON va.ID = vc.ValuationAnalysisID
 *   LEFT JOIN indiana_tax.ParcelPhysicalProfile ppp ON ppp.ParcelID = va.ParcelID
 *   WHERE vc.SizeAdjPct IS NOT NULL AND vc.CompYearBuilt IS NOT NULL AND vc.CompGradeOrdinal IS NOT NULL ...
 *
 * The comp-side columns (rawPerUnit, compDenominator, compYearBuilt, compGradeOrdinal, saleDate)
 * below are copied verbatim from that query. The SUBJECT-side inputs are NOT copied from the
 * joined ParcelPhysicalProfile row, because build-valuation-comps.js writes SizeAdjPct/
 * AgeAdjPct/GradeAdjPct/TimeAdjPct through `r2()` -- rounded to 2 decimal places -- before the
 * INSERT. Feeding the real subject characteristics (denominator 353,579 SF, EffectiveYear 2011,
 * GradeOrdinal 4.33) back through the unrounded formula reproduces each stored percentage only
 * to ~±0.005, not the ±0.0001 this golden test requires. So, per the brief's algebraic-back-
 * solve allowance, each subject field is instead the exact inverse of its own factor's formula,
 * solved against the real stored percentage:
 *   denominator        = compDenominator / exp(storedSizeAdjPct / sizeElasticity)
 *   effectiveYearBuilt  = compYearBuilt + storedAgeAdjPct / ageRatePerYear
 *   gradeOrdinal        = compGradeOrdinal + storedGradeAdjPct / gradeRatePerStep
 *   lienDate            = saleDate + (storedTimeAdjPct / appreciationRatePerYear) years
 * Each factor depends on a single, independent subject field, so all four inversions compose
 * into one consistent SalesSubjectInput. This proves the ported arithmetic -- log elasticity,
 * per-year age/time rates, per-step grade rate, and the clamps -- exactly reproduces production
 * output; it is not a claim that this SalesSubjectInput is the parcel's actual physical profile.
 */
describe('computeCompAdjustment — golden tests against live ValuationComp rows', () => {
  it('reproduces production comp BAE20841-…-F66E (SizeAdjPct 0.01, AgeAdjPct -0.01, GradeAdjPct -0.01, TimeAdjPct 0.04)', () => {
    const subject = { denominator: 365554.31688652764, effectiveYearBuilt: 2012, gradeOrdinal: 4.375, lienDate: '2026-01-04' };
    const comp = { id: 'BAE20841-F36B-1410-8D3A-00F6C896F66E', rawPerUnit: 168.94, compDenominator: 404000, compYearBuilt: 2014, compGradeOrdinal: 4.5, saleDate: '2024-09-04' };
    const result = computeCompAdjustment(subject, comp, DEFAULT_COEF);
    expect(result.sizeAdjPct).toBeCloseTo(0.01, 4);
    expect(result.ageAdjPct).toBeCloseTo(-0.01, 4);
    expect(result.gradeAdjPct).toBeCloseTo(-0.01, 4);
    expect(result.timeAdjPct).toBeCloseTo(0.04, 4);
  });

  it('reproduces production comp C6E20841-…-F66E (SizeAdjPct -0.05, AgeAdjPct 0.01, GradeAdjPct -0.01, TimeAdjPct 0.02)', () => {
    const subject = { denominator: 362718.6795540282, effectiveYearBuilt: 2012, gradeOrdinal: 4.375, lienDate: '2025-11-30' };
    const comp = { id: 'C6E20841-F36B-1410-8D3A-00F6C896F66E', rawPerUnit: 227.27, compDenominator: 220000, compYearBuilt: 2010, compGradeOrdinal: 4.5, saleDate: '2025-04-01' };
    const result = computeCompAdjustment(subject, comp, DEFAULT_COEF);
    expect(result.sizeAdjPct).toBeCloseTo(-0.05, 4);
    expect(result.ageAdjPct).toBeCloseTo(0.01, 4);
    expect(result.gradeAdjPct).toBeCloseTo(-0.01, 4);
    expect(result.timeAdjPct).toBeCloseTo(0.02, 4);
  });

  it('skips a factor when the subject is missing the characteristic', () => {
    const subject = { denominator: 87000, effectiveYearBuilt: null, gradeOrdinal: null, lienDate: '2026-01-01' };
    const comp = { id: 'c1', rawPerUnit: 30, compDenominator: 90000, compYearBuilt: 2000, compGradeOrdinal: 3, saleDate: '2024-01-01' };
    const result = computeCompAdjustment(subject, comp, DEFAULT_COEF);
    expect(result.ageAdjPct).toBe(0);
    expect(result.gradeAdjPct).toBe(0);
  });

  it('clamps even when an edited coefficient would exceed the cap', () => {
    const subject = { denominator: 1000, effectiveYearBuilt: 2020, gradeOrdinal: 3, lienDate: '2026-01-01' };
    const comp = { id: 'c2', rawPerUnit: 30, compDenominator: 1000, compYearBuilt: 1970, compGradeOrdinal: 3, saleDate: '2024-01-01' };
    const result = computeCompAdjustment(subject, comp, { ...DEFAULT_COEF, ageRatePerYear: 5 });
    expect(result.ageAdjPct).toBe(0.2); // capped, not 250
  });

  it('flags grossAdjustmentWarning only when gross adjustment exceeds 50%', () => {
    const subject = { denominator: 1000, effectiveYearBuilt: 2020, gradeOrdinal: 5, lienDate: '2026-01-01' };
    const comp = { id: 'c3', rawPerUnit: 30, compDenominator: 4000, compYearBuilt: 1970, compGradeOrdinal: 1, saleDate: '2024-01-01' };
    const result = computeCompAdjustment(subject, comp, DEFAULT_COEF);
    // size 0.1*ln(4)~0.139 (uncapped) + age 0.20 (capped) + grade 0.20 (capped) + time 0.06 -> gross ~0.60 > 0.50
    expect(result.grossAdjPct).toBeGreaterThan(0.5);
    expect(result.grossAdjustmentWarning).toBe(true);
  });
});

describe('salesIndicatedValue', () => {
  it('flags belowMinimum under 3 included comps', () => {
    const r = salesIndicatedValue([], new Set(), 1000);
    expect(r.belowMinimum).toBe(true);
    expect(r.value).toBeNull();
  });

  it('reaches the minimum with exactly SALES_MINIMUM_COMPS included comps', () => {
    const results = [
      { id: 'a', rawPerUnit: 100, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 100, subjectIndicatedValue: 100_000, grossAdjustmentWarning: false },
      { id: 'b', rawPerUnit: 110, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 110, subjectIndicatedValue: 110_000, grossAdjustmentWarning: false },
      { id: 'c', rawPerUnit: 120, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 120, subjectIndicatedValue: 120_000, grossAdjustmentWarning: false },
    ];
    const r = salesIndicatedValue(results, new Set(['a', 'b', 'c']), 1000);
    expect(r.comps).toBe(SALES_MINIMUM_COMPS);
    expect(r.belowMinimum).toBe(false);
    expect(r.value).toBe(110_000);
  });

  it('medians only over includedIds -- a comp present in results but excluded from includedIds must not move the median', () => {
    const results = [
      { id: 'a', rawPerUnit: 100, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 100, subjectIndicatedValue: 100_000, grossAdjustmentWarning: false },
      { id: 'b', rawPerUnit: 110, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 110, subjectIndicatedValue: 110_000, grossAdjustmentWarning: false },
      { id: 'c', rawPerUnit: 120, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 120, subjectIndicatedValue: 120_000, grossAdjustmentWarning: false },
      // Present in results but deliberately excluded -- a huge outlier that WOULD move the
      // median to 110_000 -> unchanged only if excluded comps are truly ignored.
      { id: 'outlier', rawPerUnit: 900, sizeAdjPct: 0, ageAdjPct: 0, gradeAdjPct: 0, timeAdjPct: 0, netAdjPct: 0, grossAdjPct: 0, adjustedPerUnit: 900, subjectIndicatedValue: 900_000, grossAdjustmentWarning: false },
    ];
    const withOutlier = salesIndicatedValue(results, new Set(['a', 'b', 'c', 'outlier']), 1000);
    const withoutOutlier = salesIndicatedValue(results, new Set(['a', 'b', 'c']), 1000);
    expect(withoutOutlier.value).toBe(110_000);
    expect(withoutOutlier.comps).toBe(3);
    expect(withOutlier.value).not.toBe(withoutOutlier.value);
  });
});
