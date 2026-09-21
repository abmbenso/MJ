/**
 * Pure helper for the Cover page's assessment-summary table. Kept Angular-free (imports only
 * `../analysis-store`) so it can be unit-tested under Vitest's node preset without pulling in
 * `@angular/core` — see analysis-cover.test.ts.
 */
import { AssessmentRow, finalAV } from '../analysis-store';

export interface AssessmentSummaryRow { year: number; original: number | null; final: number | null; changePct: number | null; }

/** One row per year; final = as finally determined (finalAV); change = this year's final vs the prior year's final, 4 dp. */
export function buildAssessmentSummary(rows: AssessmentRow[], years: number[]): AssessmentSummaryRow[] {
  const sorted = [...years].sort((a, b) => a - b);
  return sorted.map((year) => {
    const ofYear = rows.filter((r) => r.AssessmentYear === year).sort((a, b) => (a.Source === 'MarionPRC' ? -1 : 0) - (b.Source === 'MarionPRC' ? -1 : 0));
    const original = ofYear[0]?.OriginalTotalAV ?? null;
    const fin = finalAV(rows, year);
    const prior = finalAV(rows, year - 1);
    const changePct = fin != null && prior != null && prior > 0 ? Math.round((fin / prior - 1) * 10000) / 10000 : null;
    return { year, original, final: fin, changePct };
  });
}
