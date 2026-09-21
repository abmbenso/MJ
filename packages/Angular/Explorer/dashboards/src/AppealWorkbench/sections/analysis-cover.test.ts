import { describe, it, expect } from 'vitest';
import { buildAssessmentSummary } from './assessment-summary';

const rows = [
  { ID: 'a', ParcelID: 'P', AssessmentYear: 2026, Source: 'MarionPRC', OriginalTotalAV: 8_150_000, PTABOATotalAV: null },
  { ID: 'b', ParcelID: 'P', AssessmentYear: 2025, Source: 'MarionPRC', OriginalTotalAV: 7_600_000, PTABOATotalAV: 7_410_000 },
  { ID: 'c', ParcelID: 'P', AssessmentYear: 2024, Source: 'DLGF', OriginalTotalAV: 7_000_000, PTABOATotalAV: null },
];
describe('buildAssessmentSummary', () => {
  it('one row per requested year, final = as finally determined, change vs the prior final', () => {
    const s = buildAssessmentSummary(rows, [2024, 2025, 2026]);
    expect(s.map((r) => r.year)).toEqual([2024, 2025, 2026]);
    expect(s[1]).toEqual({ year: 2025, original: 7_600_000, final: 7_410_000, changePct: 0.0586 });
    expect(s[2].changePct).toBeCloseTo(0.0999, 4);
    expect(s[0].changePct).toBeNull();
  });
  it('a missing year is a row of nulls, not a skipped year', () => {
    expect(buildAssessmentSummary(rows, [2023])).toEqual([{ year: 2023, original: null, final: null, changePct: null }]);
  });
});
