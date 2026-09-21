/**
 * The income approach, generalised from the user's Appeal Support template (Income Analysis
 * sheet): rent lines → other income → PGI → vacancy & collection → EGI → expense lines →
 * reserves → NOI → ÷ cap → value. Every line declares how its value applies (LineMode), so the
 * same engine serves NNN retail ($/SF, not tax-loaded), full-service office (% of EGI opex,
 * tax-loaded) and multifamily ($/unit, tax-loaded). Pure; no Angular, no MJ.
 */
export type LineMode = 'perSF' | 'perUnit' | 'annual' | 'pctPGI' | 'pctEGI';
export interface IncomeLine { key: string; label: string; mode: LineMode; value: number | null; }
export interface IncomeInputs {
  denominator: number | null;
  rent: IncomeLine[];
  otherIncome: IncomeLine[];
  vacancyPct: number | null;
  collectionPct: number | null;
  expenses: IncomeLine[];
  reserves: IncomeLine | null;
  capRate: number | null;
  taxLoaded: boolean;
  effectiveTaxRate: number | null;
}
export interface ComputedLine { key: string; label: string; annual: number; }
export interface IncomeResult {
  complete: boolean; missing: string[];
  rentIncome: ComputedLine[]; otherIncome: ComputedLine[];
  pgi: number; vacancy: number; collection: number; egi: number;
  expenses: ComputedLine[]; expenseTotal: number; reserves: number; noi: number;
  appliedCap: number; value: number | null; perUnit: number | null;
}

export const VALUE_ROUNDING = 1000;

export function roundTo(n: number, step: number): number { return Math.round(n / step) * step; }

function annualOf(line: IncomeLine, denominator: number, pctBase: number, egi: number): number {
  const v = line.value ?? 0;
  switch (line.mode) {
    case 'perSF':
    case 'perUnit': return v * denominator;
    case 'annual': return v;
    case 'pctPGI': return v * pctBase;
    case 'pctEGI': return v * egi;
    default: return 0;
  }
}
const sum = (lines: ComputedLine[]): number => lines.reduce((a, l) => a + l.annual, 0);

export function computeIncomeApproach(i: IncomeInputs): IncomeResult {
  const missing: string[] = [];
  if (i.denominator == null || i.denominator <= 0) missing.push('denominator');
  // I5: no rent line with a value means there is nothing to capitalize — refuse the value rather than showing a negative NOI ÷ cap.
  if (i.rent.length === 0 || i.rent.every((l) => l.value == null)) missing.push('rent');
  if (i.capRate == null || i.capRate <= 0) missing.push('capRate');
  if (i.taxLoaded && i.effectiveTaxRate == null) missing.push('effectiveTaxRate');
  const denom = i.denominator ?? 0;

  const rentIncome = i.rent.map((l) => ({ key: l.key, label: l.label, annual: annualOf(l, denom, 0, 0) }));
  const rentTotal = sum(rentIncome);
  // pctPGI on an income line means "% of rent" (the template's Other Income convention).
  const otherIncome = i.otherIncome.map((l) => ({ key: l.key, label: l.label, annual: annualOf(l, denom, rentTotal, 0) }));
  const pgi = rentTotal + sum(otherIncome);
  const vacancy = pgi * (i.vacancyPct ?? 0);
  const collection = pgi * (i.collectionPct ?? 0);
  const egi = pgi - vacancy - collection;
  const expenses = i.expenses.map((l) => ({ key: l.key, label: l.label, annual: annualOf(l, denom, pgi, egi) }));
  const expenseTotal = sum(expenses);
  const reserves = i.reserves ? annualOf(i.reserves, denom, pgi, egi) : 0;
  const noi = egi - expenseTotal - reserves;
  const appliedCap = (i.capRate ?? 0) + (i.taxLoaded ? (i.effectiveTaxRate ?? 0) : 0);
  const complete = missing.length === 0;
  const value = complete && appliedCap > 0 ? roundTo(noi / appliedCap, VALUE_ROUNDING) : null;
  const perUnit = value != null && denom > 0 ? value / denom : null;
  return { complete, missing, rentIncome, otherIncome, pgi, vacancy, collection, egi, expenses, expenseTotal, reserves, noi, appliedCap, value, perUnit };
}

/** Band of investment: Ro = M·Rm + (1−M)·Re, Rm the annual mortgage constant from a monthly amortising loan. */
export function bandOfInvestment(ltv: number, annualInterest: number, amortYears: number, equityDividendRate: number): { mortgageConstant: number; capRate: number } {
  const i = annualInterest / 12;
  const n = amortYears * 12;
  const monthly = i === 0 ? 1 / n : i / (1 - Math.pow(1 + i, -n));
  const mortgageConstant = monthly * 12;
  return { mortgageConstant, capRate: ltv * mortgageConstant + (1 - ltv) * equityDividendRate };
}
