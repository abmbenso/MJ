import { describe, it, expect } from 'vitest';
import { applyEdit, displayValue } from './income-edit';
import { AssumptionRow } from '../analysis-store';

const base = (over: Partial<AssumptionRow>): AssumptionRow => ({ ID: 'r', AppealAnalysisID: 'a', Section: 'Income', AssumptionKey: 'k', Label: 'k', Value: null, Unit: null, Mode: 'perSF', Source: 'Default', SourceRef: null, ProposedValue: null, ProposedSource: null, SortOrder: 1, ...over });

describe('applyEdit', () => {
  it('parses a percent-mode entry typed as a percent and marks it Analyst', () => {
    const r = applyEdit([base({ AssumptionKey: 'cap_rate', Mode: 'rate', Value: 0.07, Source: 'Market' })], 'cap_rate', '7.75');
    expect(r.changed).toMatchObject({ Value: 0.0775, Source: 'Analyst' });
    expect(r.rows[0].Value).toBe(0.0775);
  });
  it('parses money and count modes as plain numbers, stripping commas and $', () => {
    expect(applyEdit([base({ AssumptionKey: 'rent_base', Mode: 'perSF', Value: 14.5 })], 'rent_base', '$15.25').changed!.Value).toBe(15.25);
    expect(applyEdit([base({ AssumptionKey: 'denominator', Mode: 'count', Value: 42000 })], 'denominator', '42,500').changed!.Value).toBe(42500);
  });
  it('parses a flag as yes/no or 1/0', () => {
    expect(applyEdit([base({ AssumptionKey: 'tax_loaded', Mode: 'flag', Value: 0 })], 'tax_loaded', 'yes').changed!.Value).toBe(1);
    expect(applyEdit([base({ AssumptionKey: 'tax_loaded', Mode: 'flag', Value: 1 })], 'tax_loaded', '0').changed!.Value).toBe(0);
  });
  it('an empty entry stores null; an unchanged value is not a change; a non-number is ignored', () => {
    expect(applyEdit([base({ AssumptionKey: 'rent_base', Value: 14.5 })], 'rent_base', '').changed!.Value).toBeNull();
    expect(applyEdit([base({ AssumptionKey: 'rent_base', Value: 14.5 })], 'rent_base', '14.5').changed).toBeNull();
    expect(applyEdit([base({ AssumptionKey: 'rent_base', Value: 14.5 })], 'rent_base', 'abc').changed).toBeNull();
  });
});
describe('displayValue', () => {
  it('shows percents as percents, flags as yes/no, nulls as empty', () => {
    expect(displayValue(base({ Mode: 'rate', Value: 0.0775 }))).toBe('7.75');
    expect(displayValue(base({ Mode: 'pctEGI', Value: 0.03 }))).toBe('3');
    expect(displayValue(base({ Mode: 'flag', Value: 1 }))).toBe('yes');
    expect(displayValue(base({ Mode: 'perSF', Value: null }))).toBe('');
    expect(displayValue(base({ Mode: 'count', Value: 42000 }))).toBe('42000');
  });
});
