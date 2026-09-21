import { describe, it, expect } from 'vitest';
import { reconcile, burdenOnAssessor, marginalRate, estimateSavings, Indication } from './appeal-rules';

const AV = 8_150_000;
const four: Indication[] = [
  { approach: 'Income', value: 6_720_000, status: 'Computed' },
  { approach: 'Sales', value: 7_050_000, status: 'Computed' },
  { approach: 'AssessmentComps', value: 7_480_000, status: 'Computed' },
  { approach: 'Cost', value: 8_640_000, status: 'Computed' },
  { approach: 'ActualIE', value: null, status: 'NotProvided' },
];

describe('reconcile — the mockup ladder', () => {
  it('marks credible and supporting, floors at the lowest supporting value', () => {
    const r = reconcile(four, AV, 'Lowest');
    expect(r.rows.map((x) => x.supports)).toEqual([true, true, true, false, false]);
    expect(r.rows[3].credible).toBe(true); // cost is in band but above AV
    expect(r.floor).toBe(6_720_000);
    expect(r.floorApproach).toBe('Income');
    expect(r.ask).toBe(6_720_000);
    expect(r.recommendation).toBe('Appeal');
  });
  it('SecondLowest asks for the second-lowest supporting value', () => {
    const r = reconcile(four, AV, 'SecondLowest');
    expect(r.ask).toBe(7_050_000);
    expect(r.askApproach).toBe('Sales');
    expect(r.floor).toBe(6_720_000);
  });
  it('SecondLowest with one supporting value falls back to the floor', () => {
    const r = reconcile([four[0], four[3]], AV, 'SecondLowest');
    expect(r.ask).toBe(6_720_000);
  });
  it('an indication outside [0.5, 1.2] x AV is not credible', () => {
    const r = reconcile([{ approach: 'Income', value: 3_000_000, status: 'Computed' }], AV);
    expect(r.rows[0].credible).toBe(false);
    expect(r.ask).toBeNull();
    expect(r.recommendation).toBe('Monitor');
  });
  it('credible values with none 5% below AV is No Appeal', () => {
    const r = reconcile([{ approach: 'Sales', value: 7_900_000, status: 'Computed' }], AV);
    expect(r.rows[0].supports).toBe(true);
    expect(r.recommendation).toBe('No Appeal');
  });
  it('NotProvided and Excluded rows never support', () => {
    const r = reconcile([{ approach: 'Income', value: 6_000_000, status: 'Excluded' }], AV);
    expect(r.rows[0].supports).toBe(false);
    expect(r.floor).toBeNull();
  });
  it('pctOfAV is value / AV', () => {
    expect(reconcile(four, AV).rows[1].pctOfAV).toBeCloseTo(0.865, 3);
  });
});

describe('burdenOnAssessor — IC 6-1.1-15-17.2', () => {
  it('is true above a 5% rise, false at or below, null without a prior value', () => {
    expect(burdenOnAssessor(276_000, 251_300)).toBe(true);
    expect(burdenOnAssessor(105_000, 100_000)).toBe(false);
    expect(burdenOnAssessor(105_001, 100_000)).toBe(true);
    expect(burdenOnAssessor(105_000, null)).toBeNull();
    expect(burdenOnAssessor(105_000, 0)).toBeNull();
  });
});

describe('savings — the cap is a rate modifier', () => {
  it('uses the district rate when it is below cap + referendum', () => {
    expect(marginalRate(2.9861, 0.03, 0.35)).toBeCloseTo(0.029861, 6);
  });
  it('uses cap + referendum when the district rate exceeds it', () => {
    expect(marginalRate(3.6418, 0.03, 0.35)).toBeCloseTo(0.0335, 6);
  });
  it('estimateSavings reports the basis and rounds to the dollar', () => {
    const s = estimateSavings(8_150_000, 7_050_000, 2.98, 0.03, null);
    expect(s.basis).toBe('rate');
    expect(s.rate).toBeCloseTo(0.0298, 6);
    expect(s.savings).toBe(32_780);
    expect(estimateSavings(8_150_000, 7_050_000, 3.6418, 0.03, null).basis).toBe('cap');
  });
  it('is null without a target or a rate', () => {
    expect(estimateSavings(AV, null, 2.98, 0.03, null).savings).toBeNull();
    expect(estimateSavings(AV, 7_000_000, null, 0.03, null).savings).toBeNull();
  });
});
