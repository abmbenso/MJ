/**
 * First-pass assumptions for an analysis, each with the chip that says where it came from:
 *  County  — the record card (SF / units, tax rate)
 *  Market  — CoStar and MarketAssumption (rent, vacancy, cap rate)
 *  Default — the practice's conceptual defaults by property-type group (this file, DEFAULTS)
 *  Analyst — never proposed here; set when the user edits a value
 * A required input with no County or Market value is proposed as NULL with sourceRef 'enter':
 * unknown is null, never zero. Multifamily chain: docs/proposals/income-approach-costar.md §2.
 * Retail/office defaults are the 2026-09-12 mockup's placeholders until the user replaces them.
 */
import { IncomeInputs, IncomeLine, LineMode } from './income-approach';
import { SalesCoefficients } from './sales-approach';

export type TypeGroup = 'Retail' | 'Office' | 'Industrial' | 'Multifamily' | 'Other';
export type AssumptionSource = 'County' | 'Market' | 'Default' | 'Analyst';
export type AssumptionMode = LineMode | 'pct' | 'rate' | 'count' | 'flag';

export interface SubjectFacts { typeGroup: TypeGroup; sqFt: number | null; units: number | null; yearBuilt: number | null; taxRatePer100: number | null; }
export interface MarketFacts { rentPerSF: number | null; rentPerUnitMonthly: number | null; vacancyPct: number | null; capRate: number | null; rentRef: string | null; vacancyRef: string | null; capRef: string | null; }
export interface ProposedAssumption { section: 'Income' | 'Sales'; key: string; label: string; mode: AssumptionMode; value: number | null; unit: string; source: AssumptionSource; sourceRef: string; sortOrder: number; }

export const INCOME_KEYS = {
  denominator: 'denominator', rentBase: 'rent_base', incomeOther: 'income_other', vacancy: 'vacancy_pct', collection: 'collection_pct',
  management: 'exp_management', nonRecoverable: 'exp_nonrecoverable', operatingRatio: 'exp_operating_ratio', reserves: 'reserves',
  capRate: 'cap_rate', taxLoaded: 'tax_loaded', effectiveTaxRate: 'effective_tax_rate',
} as const;

/** Multifamily operating-expense ratio of EGI by effective year (income-approach-costar.md §2). */
export function opexRatioByAge(yearBuilt: number | null): number {
  if (yearBuilt == null) return 0.38;
  if (yearBuilt >= 2015) return 0.3;
  if (yearBuilt >= 2005) return 0.33;
  if (yearBuilt >= 1995) return 0.38;
  if (yearBuilt >= 1985) return 0.43;
  return 0.48;
}

interface GroupDefaults { perUnit: boolean; vacancy: number; vacancyFloor: number; collection: number; otherIncomePctOfRent: number | null; management: number | null; nonRecoverablePerSF: number | null; operatingRatio: ((y: number | null) => number) | null; reserves: number; taxLoaded: boolean; }
const NNN: GroupDefaults = { perUnit: false, vacancy: 0.08, vacancyFloor: 0, collection: 0, otherIncomePctOfRent: null, management: 0.03, nonRecoverablePerSF: 0.6, operatingRatio: null, reserves: 0.25, taxLoaded: false };
const DEFAULTS: Record<TypeGroup, GroupDefaults> = {
  Retail: NNN,
  Industrial: NNN,
  Office: { perUnit: false, vacancy: 0.12, vacancyFloor: 0, collection: 0.01, otherIncomePctOfRent: null, management: null, nonRecoverablePerSF: null, operatingRatio: () => 0.42, reserves: 0.25, taxLoaded: true },
  Multifamily: { perUnit: true, vacancy: 0.05, vacancyFloor: 0.05, collection: 0.01, otherIncomePctOfRent: 0.07, management: null, nonRecoverablePerSF: null, operatingRatio: opexRatioByAge, reserves: 450, taxLoaded: true },
  // 'Other' is also toTypeGroup's fallback for a PropertyTypeGroup outside the four recognised groups; it reuses NNN deliberately.
  Other: NNN,
};

export function proposeIncomeAssumptions(s: SubjectFacts, m: MarketFacts): ProposedAssumption[] {
  const d = DEFAULTS[s.typeGroup];
  const unit = d.perUnit ? 'units' : 'SF';
  const perMode: LineMode = d.perUnit ? 'perUnit' : 'perSF';
  const rows: ProposedAssumption[] = [];
  let order = 0;
  const push = (key: string, label: string, mode: AssumptionMode, value: number | null, u: string, source: AssumptionSource, sourceRef: string) =>
    rows.push({ section: 'Income', key, label, mode, value, unit: u, source, sourceRef, sortOrder: ++order });
  const market = (value: number | null, ref: string | null, fallback: number | null, fallbackRef: string): [number | null, AssumptionSource, string] =>
    value != null ? [value, 'Market', ref ?? 'market'] : [fallback, 'Default', fallbackRef];

  const denom = d.perUnit ? s.units : s.sqFt;
  push(INCOME_KEYS.denominator, d.perUnit ? 'Units' : 'Leasable area', 'count', denom, unit, denom != null ? 'County' : 'Default', denom != null ? 'County Assessor Record' : 'enter');

  const rentValue = d.perUnit ? (m.rentPerUnitMonthly != null ? m.rentPerUnitMonthly * 12 : null) : m.rentPerSF;
  const [rv, rs, rr] = market(rentValue, m.rentRef, null, 'enter');
  push(INCOME_KEYS.rentBase, d.perUnit ? 'Rent per unit (annual)' : 'Market rent', perMode, rv, d.perUnit ? '$/unit/yr' : '$/SF/yr', rs, rr);

  if (d.otherIncomePctOfRent != null) push(INCOME_KEYS.incomeOther, 'Other income (% of rent)', 'pctPGI', d.otherIncomePctOfRent, '%', 'Default', 'income-approach-costar.md §2');
  else push(INCOME_KEYS.incomeOther, 'Other income', perMode, 0, d.perUnit ? '$/unit/yr' : '$/SF/yr', 'Default', 'none assumed');

  const [vv, vs, vr] = market(m.vacancyPct != null ? Math.max(m.vacancyPct, d.vacancyFloor) : null, m.vacancyRef, d.vacancy, 'Workbench default');
  push(INCOME_KEYS.vacancy, 'Vacancy (% of PGI)', 'pct', vv, '%', vs, vr);
  push(INCOME_KEYS.collection, 'Collection loss (% of PGI)', 'pct', d.collection, '%', 'Default', 'Workbench default');

  if (d.management != null) push(INCOME_KEYS.management, 'Management (% of EGI)', 'pctEGI', d.management, '%', 'Default', 'Workbench default');
  if (d.nonRecoverablePerSF != null) push(INCOME_KEYS.nonRecoverable, 'Non-recoverable expenses', 'perSF', d.nonRecoverablePerSF, '$/SF/yr', 'Default', 'Workbench default');
  if (d.operatingRatio) push(INCOME_KEYS.operatingRatio, 'Operating expenses (% of EGI)', 'pctEGI', d.operatingRatio(s.yearBuilt), '%', 'Default', d.perUnit ? 'income-approach-costar.md §2 (by age)' : 'Workbench default');
  push(INCOME_KEYS.reserves, 'Replacement reserves', perMode, d.reserves, d.perUnit ? '$/unit/yr' : '$/SF/yr', 'Default', d.perUnit ? 'income-approach-costar.md §2' : 'Workbench default');

  const [cv, cs, cr] = market(m.capRate, m.capRef, null, 'enter');
  push(INCOME_KEYS.capRate, 'Capitalization rate', 'rate', cv, '%', cs, cr);
  push(INCOME_KEYS.taxLoaded, 'Tax-loaded cap rate', 'flag', d.taxLoaded ? 1 : 0, 'yes/no', 'Default', d.taxLoaded ? 'landlord pays the tax' : 'tenants reimburse the tax');
  push(INCOME_KEYS.effectiveTaxRate, 'Effective tax rate', 'rate', s.taxRatePer100 != null ? s.taxRatePer100 / 100 : null, '%', s.taxRatePer100 != null ? 'County' : 'Default', s.taxRatePer100 != null ? 'County Assessor Record TaxRate' : 'enter');
  return rows;
}

/** Inverse of the proposal: stored assumption rows → engine inputs. Unknown keys become expense lines (the user may add lines later). */
export function assumptionsToIncomeInputs(rows: Array<{ key: string; label: string; mode: AssumptionMode; value: number | null }>): IncomeInputs {
  const by = new Map(rows.map((r) => [r.key, r]));
  const num = (k: string): number | null => by.get(k)?.value ?? null;
  const line = (k: string): IncomeLine | null => { const r = by.get(k); return r ? { key: r.key, label: r.label, mode: r.mode as LineMode, value: r.value } : null; };
  const known = new Set<string>(Object.values(INCOME_KEYS));
  const expenseKeys = [INCOME_KEYS.management, INCOME_KEYS.nonRecoverable, INCOME_KEYS.operatingRatio];
  const expenses = [
    ...expenseKeys.map(line).filter((l): l is IncomeLine => l != null),
    ...rows.filter((r) => !known.has(r.key) && r.key.startsWith('exp_')).map((r) => ({ key: r.key, label: r.label, mode: r.mode as LineMode, value: r.value })),
  ];
  return {
    denominator: num(INCOME_KEYS.denominator),
    rent: [line(INCOME_KEYS.rentBase)].filter((l): l is IncomeLine => l != null),
    otherIncome: [line(INCOME_KEYS.incomeOther)].filter((l): l is IncomeLine => l != null),
    vacancyPct: num(INCOME_KEYS.vacancy),
    collectionPct: num(INCOME_KEYS.collection),
    expenses,
    reserves: line(INCOME_KEYS.reserves),
    capRate: num(INCOME_KEYS.capRate),
    taxLoaded: (num(INCOME_KEYS.taxLoaded) ?? 0) === 1,
    effectiveTaxRate: num(INCOME_KEYS.effectiveTaxRate),
  };
}

export const SALES_KEYS = {
  sizeRate: 'sales_size_rate', sizeEnabled: 'sales_size_enabled',
  ageRate: 'sales_age_rate', ageEnabled: 'sales_age_enabled',
  gradeRate: 'sales_grade_rate', gradeEnabled: 'sales_grade_enabled',
  timeRate: 'sales_time_rate', timeEnabled: 'sales_time_enabled',
} as const;

/** The batch script's own fixed constants (build-valuation-comps.js) -- the Default starting point. */
const SALES_RATE_DEFAULTS = { sizeRate: 0.10, ageRate: 0.005, gradeRate: 0.08, timeRate: 0.03 };

export function proposeSalesAssumptions(): ProposedAssumption[] {
  let order = 0;
  const push = (key: string, label: string, mode: AssumptionMode, value: number, unit: string): ProposedAssumption =>
    ({ section: 'Sales', key, label, mode, value, unit, source: 'Default', sourceRef: 'build-valuation-comps.js batch constant', sortOrder: ++order });
  return [
    push(SALES_KEYS.sizeEnabled, 'Size adjustment', 'flag', 1, 'yes/no'),
    push(SALES_KEYS.sizeRate, 'Size elasticity', 'rate', SALES_RATE_DEFAULTS.sizeRate, 'ln($)'),
    push(SALES_KEYS.ageEnabled, 'Age adjustment', 'flag', 1, 'yes/no'),
    push(SALES_KEYS.ageRate, 'Age rate', 'rate', SALES_RATE_DEFAULTS.ageRate, '%/yr'),
    push(SALES_KEYS.gradeEnabled, 'Grade adjustment', 'flag', 1, 'yes/no'),
    push(SALES_KEYS.gradeRate, 'Grade rate', 'rate', SALES_RATE_DEFAULTS.gradeRate, '%/step'),
    push(SALES_KEYS.timeEnabled, 'Time (market conditions) adjustment', 'flag', 1, 'yes/no'),
    push(SALES_KEYS.timeRate, 'Appreciation rate', 'rate', SALES_RATE_DEFAULTS.timeRate, '%/yr'),
  ];
}

/** Inverse: stored Section='Sales' assumption rows -> engine coefficients. Unknown/missing rows fall back to the batch defaults, never to zero. */
export function assumptionsToSalesCoefficients(rows: Array<{ key: string; value: number | null }>): SalesCoefficients {
  const by = new Map(rows.map((r) => [r.key, r.value]));
  const num = (k: string, fallback: number): number => by.get(k) ?? fallback;
  const flag = (k: string): boolean => (by.get(k) ?? 1) === 1;
  return {
    sizeElasticity: num(SALES_KEYS.sizeRate, SALES_RATE_DEFAULTS.sizeRate), sizeEnabled: flag(SALES_KEYS.sizeEnabled),
    ageRatePerYear: num(SALES_KEYS.ageRate, SALES_RATE_DEFAULTS.ageRate), ageEnabled: flag(SALES_KEYS.ageEnabled),
    gradeRatePerStep: num(SALES_KEYS.gradeRate, SALES_RATE_DEFAULTS.gradeRate), gradeEnabled: flag(SALES_KEYS.gradeEnabled),
    appreciationRatePerYear: num(SALES_KEYS.timeRate, SALES_RATE_DEFAULTS.timeRate), timeEnabled: flag(SALES_KEYS.timeEnabled),
  };
}
