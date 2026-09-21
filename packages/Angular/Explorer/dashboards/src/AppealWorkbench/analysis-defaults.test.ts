import { describe, it, expect } from 'vitest';
import { proposeIncomeAssumptions, assumptionsToIncomeInputs, opexRatioByAge, proposeSalesAssumptions, assumptionsToSalesCoefficients, SALES_KEYS, SubjectFacts, MarketFacts } from './analysis-defaults';
import { computeIncomeApproach } from './income-approach';

const noMarket: MarketFacts = { rentPerSF: null, rentPerUnitMonthly: null, vacancyPct: null, capRate: null, rentRef: null, vacancyRef: null, capRef: null };
const retailSubject: SubjectFacts = { typeGroup: 'Retail', sqFt: 42_000, units: null, yearBuilt: 1998, taxRatePer100: 2.98 };
const retailMarket: MarketFacts = { rentPerSF: 14.5, rentPerUnitMonthly: null, vacancyPct: 0.08, capRate: 0.0775, rentRef: 'CoStar 2026', vacancyRef: 'MarketAssumption Vacancy Retail 2026', capRef: 'MarketAssumption CapRate Retail 2026' };

describe('proposeIncomeAssumptions — retail', () => {
  const rows = proposeIncomeAssumptions(retailSubject, retailMarket);
  const by = (k: string) => rows.find((r) => r.key === k)!;
  it('tags SF and tax rate County, rent/vacancy/cap Market, the rest Default', () => {
    expect(by('denominator')).toMatchObject({ value: 42_000, mode: 'count', source: 'County', unit: 'SF' });
    expect(by('effective_tax_rate')).toMatchObject({ value: 0.0298, mode: 'rate', source: 'County' });
    expect(by('rent_base')).toMatchObject({ value: 14.5, mode: 'perSF', source: 'Market', sourceRef: 'CoStar 2026' });
    expect(by('vacancy_pct')).toMatchObject({ value: 0.08, source: 'Market' });
    expect(by('cap_rate')).toMatchObject({ value: 0.0775, mode: 'rate', source: 'Market' });
    expect(by('exp_management')).toMatchObject({ value: 0.03, mode: 'pctEGI', source: 'Default' });
    expect(by('exp_nonrecoverable')).toMatchObject({ value: 0.6, mode: 'perSF', source: 'Default' });
    expect(by('reserves')).toMatchObject({ value: 0.25, mode: 'perSF', source: 'Default' });
    expect(by('tax_loaded')).toMatchObject({ value: 0, mode: 'flag', source: 'Default' });
  });
  it('is ordered and has no duplicate keys', () => {
    expect(rows.map((r) => r.sortOrder)).toEqual([...rows.map((r) => r.sortOrder)].sort((a, b) => a - b));
    expect(new Set(rows.map((r) => r.key)).size).toBe(rows.length);
  });
  it('proposes null, never zero, when a required market input is absent', () => {
    const r = proposeIncomeAssumptions(retailSubject, noMarket);
    const rent = r.find((x) => x.key === 'rent_base')!;
    expect(rent.value).toBeNull();
    expect(rent.source).toBe('Default');
    expect(rent.sourceRef).toBe('enter');
    expect(r.find((x) => x.key === 'cap_rate')!.value).toBeNull();
    expect(r.find((x) => x.key === 'vacancy_pct')!.value).toBe(0.08); // the default, labelled Default
  });
  it('round-trips into IncomeInputs and reproduces the mockup value', () => {
    const inputs = assumptionsToIncomeInputs(rows);
    expect(inputs.taxLoaded).toBe(false);
    expect(computeIncomeApproach(inputs).value).toBe(6_552_000);
  });
});

describe('proposeIncomeAssumptions — office and multifamily', () => {
  it('office is full-service: opex ratio of EGI, tax-loaded', () => {
    const r = proposeIncomeAssumptions({ ...retailSubject, typeGroup: 'Office' }, retailMarket);
    expect(r.find((x) => x.key === 'exp_operating_ratio')).toMatchObject({ value: 0.42, mode: 'pctEGI', source: 'Default' });
    expect(r.find((x) => x.key === 'tax_loaded')!.value).toBe(1);
    expect(r.find((x) => x.key === 'vacancy_pct')!.value).toBe(0.08); // market beats the 12% default
    expect(r.find((x) => x.key === 'exp_nonrecoverable')).toBeUndefined();
  });
  it('multifamily is per unit: annual rent from monthly, 7% other income, $450 reserves, opex by age', () => {
    const r = proposeIncomeAssumptions(
      { typeGroup: 'Multifamily', sqFt: 180_000, units: 200, yearBuilt: 1990, taxRatePer100: 3.2 },
      { ...noMarket, rentPerUnitMonthly: 1_250, vacancyPct: 0.03, capRate: 0.065, rentRef: 'CoStar', vacancyRef: 'CoStar', capRef: 'MA' },
    );
    const by = (k: string) => r.find((x) => x.key === k)!;
    expect(by('denominator')).toMatchObject({ value: 200, unit: 'units', source: 'County' });
    expect(by('rent_base')).toMatchObject({ value: 15_000, mode: 'perUnit', source: 'Market' });
    expect(by('income_other')).toMatchObject({ value: 0.07, mode: 'pctPGI', source: 'Default' });
    expect(by('vacancy_pct').value).toBe(0.05); // floor 5%
    expect(by('collection_pct').value).toBe(0.01);
    expect(by('exp_operating_ratio').value).toBe(0.43);
    expect(by('reserves')).toMatchObject({ value: 450, mode: 'perUnit' });
    expect(by('tax_loaded').value).toBe(1);
  });
});

describe('opexRatioByAge', () => {
  it('follows the proposal bands', () => {
    expect(opexRatioByAge(2020)).toBe(0.3);
    expect(opexRatioByAge(2010)).toBe(0.33);
    expect(opexRatioByAge(2000)).toBe(0.38);
    expect(opexRatioByAge(1990)).toBe(0.43);
    expect(opexRatioByAge(1970)).toBe(0.48);
    expect(opexRatioByAge(null)).toBe(0.38);
  });
});

describe('proposeSalesAssumptions', () => {
  it('proposes 8 rows, all Default, matching the batch constants', () => {
    const rows = proposeSalesAssumptions();
    expect(rows).toHaveLength(8);
    expect(rows.every((r) => r.source === 'Default')).toBe(true);
    expect(rows.find((r) => r.key === SALES_KEYS.sizeRate)?.value).toBe(0.10);
  });
});

describe('assumptionsToSalesCoefficients', () => {
  it('falls back to batch defaults for missing rows, never zero', () => {
    const coef = assumptionsToSalesCoefficients([]);
    expect(coef.sizeElasticity).toBe(0.10);
    expect(coef.sizeEnabled).toBe(true);
  });
  it('honors an analyst override', () => {
    const coef = assumptionsToSalesCoefficients([{ key: SALES_KEYS.ageEnabled, value: 0 }]);
    expect(coef.ageEnabled).toBe(false);
  });
});
