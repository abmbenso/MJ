/** URL state for Analyze a Property: ?parcel=&analysis=&section=. Null REMOVES a param (Tax Bill Projection's convention). */
export type SectionKey = 'cover' | 'sales' | 'income' | 'comps' | 'cost' | 'tax' | 'decisions';
export const SECTION_KEYS: SectionKey[] = ['cover', 'sales', 'income', 'comps', 'cost', 'tax', 'decisions'];
export interface AnalysisViewParams { parcelId: string | null; analysisId: string | null; section: SectionKey; }

export function parseViewParams(params: Record<string, string>): AnalysisViewParams {
  const s = (params['section'] ?? '').trim().toLowerCase();
  return {
    parcelId: params['parcel']?.trim() || null,
    analysisId: params['analysis']?.trim() || null,
    section: (SECTION_KEYS as string[]).includes(s) ? (s as SectionKey) : 'cover',
  };
}
export function formatViewParams(p: AnalysisViewParams): Record<string, string | null> {
  return { parcel: p.parcelId || null, analysis: p.analysisId || null, section: p.section };
}
