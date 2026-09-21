import { describe, it, expect } from 'vitest';
import { parseViewParams, formatViewParams } from './analysis-view-params';

describe('view params', () => {
  it('parses parcel, analysis and section, defaulting the section to cover', () => {
    expect(parseViewParams({ parcel: 'P1', analysis: 'A1', section: 'income' })).toEqual({ parcelId: 'P1', analysisId: 'A1', section: 'income' });
    expect(parseViewParams({})).toEqual({ parcelId: null, analysisId: null, section: 'cover' });
    expect(parseViewParams({ section: 'bogus' }).section).toBe('cover');
  });
  it('formats nulls as removals, never empty strings', () => {
    expect(formatViewParams({ parcelId: null, analysisId: null, section: 'cover' })).toEqual({ parcel: null, analysis: null, section: 'cover' });
    expect(formatViewParams({ parcelId: 'P1', analysisId: 'A1', section: 'tax' })).toEqual({ parcel: 'P1', analysis: 'A1', section: 'tax' });
  });
});
