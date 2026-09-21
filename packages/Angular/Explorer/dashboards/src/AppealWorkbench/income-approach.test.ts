import { describe, it, expect } from 'vitest';
import { computeIncomeApproach, bandOfInvestment, roundTo, IncomeInputs } from './income-approach';

/** The mockup's NNN retail center: 42,000 SF, $14.50 rent, $0.35 other, 8% V&C, 3% mgmt, $0.60 non-rec, $0.25 reserves, 7.75% cap. */
const retail: IncomeInputs = {
  denominator: 42_000,
  rent: [{ key: 'rent_base', label: 'Base rent', mode: 'perSF', value: 14.5 }],
  otherIncome: [{ key: 'income_other', label: 'Other income', mode: 'perSF', value: 0.35 }],
  vacancyPct: 0.08,
  collectionPct: 0,
  expenses: [
    { key: 'exp_management', label: 'Management', mode: 'pctEGI', value: 0.03 },
    { key: 'exp_nonrecoverable', label: 'Non-recoverable', mode: 'perSF', value: 0.6 },
  ],
  reserves: { key: 'reserves', label: 'Replacement reserves', mode: 'perSF', value: 0.25 },
  capRate: 0.0775,
  taxLoaded: false,
  effectiveTaxRate: 0.0298,
};

describe('computeIncomeApproach — NNN retail', () => {
  it('walks PGI → EGI → NOI → value, rounded to $1,000', () => {
    const r = computeIncomeApproach(retail);
    expect(r.complete).toBe(true);
    expect(r.pgi).toBe(623_700);
    expect(r.vacancy).toBeCloseTo(49_896, 0);
    expect(r.egi).toBeCloseTo(573_804, 0);
    expect(r.expenses.find((e) => e.key === 'exp_management')!.annual).toBeCloseTo(17_214.12, 1);
    expect(r.expenseTotal).toBeCloseTo(42_414.12, 1);
    expect(r.reserves).toBe(10_500);
    expect(r.noi).toBeCloseTo(520_889.88, 1);
    expect(r.appliedCap).toBe(0.0775);
    expect(r.value).toBe(6_721_000);
    expect(r.perUnit).toBeCloseTo(160.02, 2);
  });
  it('adds the effective tax rate to the cap only when tax-loaded', () => {
    const r = computeIncomeApproach({ ...retail, taxLoaded: true });
    expect(r.appliedCap).toBeCloseTo(0.1073, 6);
    expect(r.value).toBeLessThan(6_721_000);
  });
  it('pctPGI expense lines apply to PGI, perUnit lines to the denominator', () => {
    const r = computeIncomeApproach({
      ...retail,
      denominator: 100,
      rent: [{ key: 'rent_base', label: 'Rent', mode: 'perUnit', value: 12_000 }],
      otherIncome: [{ key: 'income_other', label: 'Other', mode: 'pctPGI', value: 0.07 }],
      expenses: [{ key: 'exp_operating_ratio', label: 'Opex', mode: 'pctEGI', value: 0.4 }],
      reserves: { key: 'reserves', label: 'Reserves', mode: 'perUnit', value: 450 },
    });
    expect(r.pgi).toBeCloseTo(1_284_000, 0); // 1.2M rent + 7% of rent
    expect(r.reserves).toBe(45_000);
  });
  it('is incomplete, with the missing keys named, when a required input is null', () => {
    const r = computeIncomeApproach({ ...retail, capRate: null, denominator: null });
    expect(r.complete).toBe(false);
    expect(r.missing).toEqual(['denominator', 'capRate']);
    expect(r.value).toBeNull();
  });
  it('a null line value contributes nothing but does not block', () => {
    const r = computeIncomeApproach({ ...retail, otherIncome: [{ key: 'x', label: 'x', mode: 'perSF', value: null }] });
    expect(r.complete).toBe(true);
    expect(r.pgi).toBe(609_000);
  });
  it('I5: is incomplete, with a null value, when every rent line is null even though a cap rate is present', () => {
    const r = computeIncomeApproach({ ...retail, rent: [{ key: 'rent_base', label: 'Base rent', mode: 'perSF', value: null }] });
    expect(r.complete).toBe(false);
    expect(r.missing).toContain('rent');
    expect(r.value).toBeNull();
  });
});

describe('bandOfInvestment — 60% at 6.25% over 25 years, 8% equity', () => {
  it('gives the mockup 7.95%', () => {
    const b = bandOfInvestment(0.6, 0.0625, 25, 0.08);
    expect(b.mortgageConstant).toBeCloseTo(0.07916, 4);
    expect(b.capRate).toBeCloseTo(0.0795, 3);
  });
});

describe('roundTo', () => {
  it('rounds to the step', () => { expect(roundTo(6_721_160, 1000)).toBe(6_721_000); expect(roundTo(6_721_500, 1000)).toBe(6_722_000); });
});
