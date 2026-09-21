import { describe, it, expect } from 'vitest';
import { compsIndication } from './comps-indication';

describe('compsIndication', () => {
  it('is the neighborhood Effective median per unit times the subject denominator, rounded to $1,000', () => {
    const r = compsIndication({ ID: 'S', SubjectParcelID: 'P', UnitOfComparison: '$/SF', HeadlineTrack: 'Effective', SubjectDenomValue: 42_000, SubjectEffectiveAV: null, SubjectPerUnitEffective: null, NeighborhoodCode: 'N', NeighborhoodCompCount: 6, NeighborhoodMedianPerUnit: 178.1, NeighborhoodMeanPerUnit: null, CountyCompCount: 10, CountyMedianPerUnit: 190, CountyMeanPerUnit: null, GeneratedAt: null }, 42_000, '$/SF');
    expect(r.value).toBe(7_480_000);
    expect(r.basis).toContain('6 comps');
  });
  it('is null without a set, a median, or a denominator', () => {
    expect(compsIndication(null, 42_000, '$/SF').value).toBeNull();
    expect(compsIndication({ NeighborhoodMedianPerUnit: null } as never, 42_000, '$/SF').value).toBeNull();
    expect(compsIndication({ NeighborhoodMedianPerUnit: 178 } as never, null, '$/SF').value).toBeNull();
  });
  it('I3: refuses the indication when the comp set unit does not match the analysis unit', () => {
    const set = { ID: 'S', SubjectParcelID: 'P', UnitOfComparison: '$/SF', HeadlineTrack: 'Effective', SubjectDenomValue: 42_000, SubjectEffectiveAV: null, SubjectPerUnitEffective: null, NeighborhoodCode: 'N', NeighborhoodCompCount: 6, NeighborhoodMedianPerUnit: 178.1, NeighborhoodMeanPerUnit: null, CountyCompCount: 10, CountyMedianPerUnit: 190, CountyMeanPerUnit: null, GeneratedAt: null } as never;
    const r = compsIndication(set, 42_000, '$/unit');
    expect(r.value).toBeNull();
    expect(r.basis).toBe('Comp set is $/SF; the analysis is $/unit');
  });
});
