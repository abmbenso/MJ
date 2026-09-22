import { describe, it, expect } from 'vitest';
import { IsCurrencyFieldName, IsDecimalSQLType } from '../lib/utils/currency-field.util';

describe('IsCurrencyFieldName', () => {
  it('keeps the long-standing amount/price/cost/total rule for any numeric type', () => {
    expect(IsCurrencyFieldName('TotalAmount', 'int')).toBe(true);
    expect(IsCurrencyFieldName('UnitPrice', 'float')).toBe(true);
    expect(IsCurrencyFieldName('HeadlineTotalAV', 'decimal')).toBe(true);
  });
  it('treats decimal tax, fee, savings, relief, due and AV columns as currency', () => {
    for (const name of ['HeadlineTax', 'NetAnnualTax', 'GrossTaxDue', 'LocalTaxRelief', 'PropertyTaxCapSavings', 'HeadlineLandAV', 'OriginalImprovementAV', 'RevisedFromTotalAV', 'FilingFee', 'AnnualRevenue']) {
      expect(IsCurrencyFieldName(name, 'decimal'), name).toBe(true);
    }
    expect(IsCurrencyFieldName('HeadlineTax', 'money')).toBe(true);
    expect(IsCurrencyFieldName('HeadlineTax', 'numeric')).toBe(true);
  });
  it('never treats rates, percentages, ratios or counts as currency', () => {
    for (const name of ['LocalTaxRate', 'MaxSpreadPct', 'TaxPercent', 'SalesRatio', 'TaxCount', 'AVFactor']) {
      expect(IsCurrencyFieldName(name, 'decimal'), name).toBe(false);
    }
  });
  it('never treats integers as currency under the decimal tier', () => {
    expect(IsCurrencyFieldName('TaxYear', 'int')).toBe(false);
    expect(IsCurrencyFieldName('DaysDue', 'int')).toBe(false);
    expect(IsCurrencyFieldName('AssessmentYear', 'int')).toBe(false);
  });
  it('ignores unrelated names and empty input', () => {
    expect(IsCurrencyFieldName('Acreage', 'decimal')).toBe(false);
    expect(IsCurrencyFieldName('Latitude', 'decimal')).toBe(false);
    expect(IsCurrencyFieldName('', 'decimal')).toBe(false);
  });
});

describe('IsDecimalSQLType', () => {
  it('matches decimal, numeric and money; not int or float', () => {
    expect(IsDecimalSQLType('decimal')).toBe(true);
    expect(IsDecimalSQLType('numeric')).toBe(true);
    expect(IsDecimalSQLType('smallmoney')).toBe(true);
    expect(IsDecimalSQLType('int')).toBe(false);
    expect(IsDecimalSQLType('float')).toBe(false);
    expect(IsDecimalSQLType(null)).toBe(false);
  });
});
