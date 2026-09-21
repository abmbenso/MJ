import { CompSetRow } from '../analysis-store';
import { roundTo } from '../income-approach';

/**
 * The assessment-comps indication: neighborhood median (Effective track) × subject denominator.
 * One owner; the shell's Recompute calls this. I3: the comp set carries its own unit
 * (UnitOfComparison); when it doesn't match the analysis's unit, the indication is refused
 * rather than silently multiplying a $/unit median by a $/SF denominator (or vice versa).
 */
export function compsIndication(set: CompSetRow | null, denominator: number | null, unit: '$/SF' | '$/unit' | null): { value: number | null; basis: string } {
  if (!set || set.NeighborhoodMedianPerUnit == null || denominator == null || denominator <= 0) return { value: null, basis: 'No comparable-assessment set, median or denominator on file' };
  if (set.UnitOfComparison !== unit) return { value: null, basis: `Comp set is ${set.UnitOfComparison}; the analysis is ${unit}` };
  const denom = set.SubjectDenomValue ?? denominator;
  return { value: roundTo(set.NeighborhoodMedianPerUnit * denom, 1000), basis: `Neighborhood ${set.NeighborhoodCode ?? ''} median ${set.NeighborhoodMedianPerUnit} ${set.UnitOfComparison} × ${denom.toLocaleString()} (Effective track, ${set.NeighborhoodCompCount ?? 0} comps); county median ${set.CountyMedianPerUnit ?? '—'} as a check` };
}
