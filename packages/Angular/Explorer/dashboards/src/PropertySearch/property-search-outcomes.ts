/**
 * @fileoverview Appeal outcomes in Property Search -- indiana_tax.vwAppealOutcomes (entity
 * `Appeal Outcomes`), the materialized record of every County-PTABOA and State-IBTR outcome, one
 * row per source row, with exactly one `IsCurrent` row per (ParcelID, AssessmentYear, Level)
 * (Indiana_Tax_Expert docs/proposals/2026-09-24-appeal-outcomes-design.md §3, §7).
 *
 * The grid's PTABOA columns read the CURRENT County row for the selected year, so value, date,
 * certainty and kind always describe one outcome; the year-scoped IBTR value reads the current State
 * row. The detail panel lists every outcome of the parcel. Pure and framework-free (the fetchers
 * live with the other layer fetchers in property-search-appeal-layers.ts, which owns rowsOrThrow).
 *
 * 🚨 SAFETY: read-only. Nothing here writes.
 */

import type { indianataxAppealOutcomeEntity } from 'mj_generatedentities';

type Row = Record<string, unknown>;
type OutcomeCertaintyValue = indianataxAppealOutcomeEntity['Certainty'];
type OutcomeKindValue = indianataxAppealOutcomeEntity['Kind'];

export const APPEAL_OUTCOMES_ENTITY = 'Appeal Outcomes';
export const PTABOA_APPEALS_ENTITY = 'PTABOA Appeals';

/** The `Appeal Outcomes` columns the grid's current-outcome read needs. */
export const CURRENT_OUTCOME_FIELDS = [
  'ParcelID', 'AssessmentYear', 'Level', 'Kind', 'Certainty', 'DeterminedTotalAV', 'DecidedAt', 'PTABOAAppealID', 'IsCurrent',
] as const;

/** The `Appeal Outcomes` columns the detail panel's outcome list needs. */
export const OUTCOME_HISTORY_FIELDS = [
  'ID', 'AssessmentYear', 'Level', 'Kind', 'Certainty', 'OriginalTotalAV', 'DeterminedTotalAV', 'DecidedAt', 'CaseNumber',
  'DispositionText', 'SourceDocumentID', 'PTABOAAppealID', 'IBTRAppealID', 'CardValuationColumnID', 'IsCurrent', 'Agenda115Differs',
] as const;

/** A County outcome's certainty -- the entity's value list minus 'Disposition' (a State-only, valueless row). */
export type OutcomeCertainty = Exclude<OutcomeCertaintyValue, 'Disposition'>;
/** A County outcome's kind -- the entity's value list minus 'Disposition'. */
export type CountyOutcomeKind = Exclude<OutcomeKindValue, 'Disposition'>;

/** The outcome-derived slice of MergedParcelRow, for the SELECTED assessment year. */
export interface OutcomeLayerFields {
  /**
   * The current County outcome's determined total: the ratified Form 115 / card-revision figure,
   * or -- when Provisional -- the agenda's recommended value. Null for an Exemption or Withdrawal
   * (not a valuation) and when the parcel has no County outcome for the year.
   */
  PTABOAValue: number | null;
  /** DecidedAt of that SAME outcome (Form 115 date, else hearing date, else card as-of date). */
  PTABOADate: string | null;
  /** The linked PTABOA appeal's form ("130S", "130O", "136"...); null for a card-revision outcome, which has no agenda row. */
  PTABOAAppealType: string | null;
  /** Ratified (a Form 115 or a revised card column) vs Provisional (agenda only). Null = no County outcome. */
  PTABOACertainty: OutcomeCertainty | null;
  /** What the County outcome was -- lets the grid say "Withdrawn" / "Exemption" where PTABOAValue is null by design. */
  PTABOAOutcomeKind: CountyOutcomeKind | null;
  /**
   * The current State-IBTR valuation for the SELECTED year (Appeal Outcomes). Distinct from
   * IBTRValue, which belongs to the parcel's NEWEST Board decision whatever year it concerned --
   * the two answer different questions and are never mixed in one column.
   */
  IBTRYearValue: number | null;
}

export const EMPTY_OUTCOME_LAYERS: OutcomeLayerFields = {
  PTABOAValue: null, PTABOADate: null, PTABOAAppealType: null, PTABOACertainty: null, PTABOAOutcomeKind: null, IBTRYearValue: null,
};

const str = (v: unknown): string | null => (v == null ? null : v instanceof Date ? v.toISOString().slice(0, 10) : String(v));
const num = (v: unknown): number | null => (v == null ? null : Number(v));
/**
 * DecidedAt is a SQL DATE: it arrives as 'YYYY-MM-DD', as an ISO string at UTC midnight, or as a
 * Date at UTC midnight. Keep the stored calendar day -- formatting it through a local-time Date
 * would show the day before anywhere west of UTC (Indiana: 2025-08-01 read as 7/31/2025).
 */
const calendarDay = (v: unknown): string | null => {
  if (v == null) return null;
  if (v instanceof Date) return Number.isNaN(v.getTime()) ? null : v.toISOString().slice(0, 10);
  const m = /^(\d{4}-\d{2}-\d{2})/.exec(String(v));
  return m ? m[1] : String(v);
};
/** SQL Server returns uppercase GUIDs; a cached or hand-entered id may not be. */
const idKey = (v: unknown): string | null => (v == null ? null : String(v).toLowerCase());
const isCurrent = (r: Row): boolean => r['IsCurrent'] === true || r['IsCurrent'] === 1;

function asCertainty(v: unknown): OutcomeCertainty | null {
  return v === 'Ratified' || v === 'Provisional' ? v : null;
}
function asCountyKind(v: unknown): CountyOutcomeKind | null {
  return v === 'Valuation' || v === 'Exemption' || v === 'Withdrawal' ? v : null;
}

function countyFields(r: Row, appealTypeById: Map<string, string | null>): Omit<OutcomeLayerFields, 'IBTRYearValue'> {
  const kind = asCountyKind(r['Kind']);
  const ptaboaId = idKey(r['PTABOAAppealID']);
  return {
    // Only a valuation carries a value -- an exemption or withdrawal is not an assessed value.
    PTABOAValue: kind === 'Valuation' ? num(r['DeterminedTotalAV']) : null,
    PTABOADate: calendarDay(r['DecidedAt']),
    PTABOAAppealType: ptaboaId ? (appealTypeById.get(ptaboaId) ?? null) : null,
    PTABOACertainty: asCertainty(r['Certainty']),
    PTABOAOutcomeKind: kind,
  };
}

/**
 * @param outcomeRows current `Appeal Outcomes` rows for ONE assessment year (IsCurrent = 1; a
 *   non-current row is ignored defensively).
 * @param ptaboaRows `PTABOA Appeals` rows carrying ID + AppealType -- joined on PTABOAAppealID.
 */
export function reduceCurrentOutcomes(outcomeRows: Row[], ptaboaRows: Row[]): Map<string, OutcomeLayerFields> {
  const appealTypeById = new Map<string, string | null>();
  for (const a of ptaboaRows) {
    const id = idKey(a['ID']);
    if (id) appealTypeById.set(id, str(a['AppealType']));
  }
  const out = new Map<string, OutcomeLayerFields>();
  for (const r of outcomeRows) {
    if (!isCurrent(r)) continue;
    const pid = r['ParcelID'] as string;
    const cur = out.get(pid) ?? { ...EMPTY_OUTCOME_LAYERS };
    if (r['Level'] === 'County-PTABOA') Object.assign(cur, countyFields(r, appealTypeById));
    else if (r['Level'] === 'State-IBTR' && r['Kind'] === 'Valuation') cur.IBTRYearValue = num(r['DeterminedTotalAV']);
    out.set(pid, cur);
  }
  return out;
}

export function applyOutcomeLayers<T extends { ParcelID: string }>(rows: T[], layers: Map<string, OutcomeLayerFields>): (T & OutcomeLayerFields)[] {
  return rows.map((r) => ({ ...EMPTY_OUTCOME_LAYERS, ...r, ...(layers.get(r.ParcelID) ?? {}) }));
}

/** One row of the detail panel's outcome list. */
export interface AppealOutcomeRow {
  id: string;
  assessmentYear: number | null;
  level: 'County' | 'State';
  kind: OutcomeKindValue | null;
  /** 'Disposition' for a State row with no value (dismissal, settlement, remand...). */
  certainty: OutcomeCertaintyValue | null;
  originalTotalAV: number | null;
  determinedTotalAV: number | null;
  decidedAt: string | null;
  caseNumber: string | null;
  dispositionText: string | null;
  /** Which record the outcome came from: a PTABOA agenda/Form 115, a revised record-card column, or an IBTR docket row. */
  source: 'PTABOA' | 'Record card' | 'IBTR';
  /** The outcome's own source document (Form 115, card, Board determination), when one is on file. */
  documentURL: string | null;
  isCurrent: boolean;
  agenda115Differs: boolean;
}

function outcomeSource(r: Row): AppealOutcomeRow['source'] {
  if (r['CardValuationColumnID'] != null) return 'Record card';
  if (r['IBTRAppealID'] != null || r['Level'] === 'State-IBTR') return 'IBTR';
  return 'PTABOA';
}

function toOutcomeRow(r: Row, urlByDocId: ReadonlyMap<string, string | null>): AppealOutcomeRow {
  const certainty: OutcomeCertaintyValue | null = r['Certainty'] === 'Disposition' ? 'Disposition' : asCertainty(r['Certainty']);
  const kind: OutcomeKindValue | null = r['Kind'] === 'Disposition' ? 'Disposition' : asCountyKind(r['Kind']);
  const docId = idKey(r['SourceDocumentID']);
  return {
    id: String(r['ID']),
    assessmentYear: num(r['AssessmentYear']),
    level: r['Level'] === 'State-IBTR' ? 'State' : 'County',
    kind,
    certainty,
    originalTotalAV: num(r['OriginalTotalAV']),
    determinedTotalAV: num(r['DeterminedTotalAV']),
    decidedAt: calendarDay(r['DecidedAt']),
    caseNumber: str(r['CaseNumber']),
    dispositionText: str(r['DispositionText']),
    source: outcomeSource(r),
    documentURL: docId ? (urlByDocId.get(docId) ?? null) : null,
    isCurrent: isCurrent(r),
    agenda115Differs: r['Agenda115Differs'] === true || r['Agenda115Differs'] === 1,
  };
}

/** Undated sorts last; a finite sentinel so two undated rows compare equal (never NaN). */
const dayValue = (d: string | null): number => (d ? new Date(d).getTime() || 0 : Number.MIN_SAFE_INTEGER);

/**
 * Every outcome of ONE parcel, newest assessment year first, then newest decision (undated last),
 * the current row first on a tie. Provisional rows are included -- this is a practitioner tool.
 * @param urlByDocId SourceURL by lower-cased SourceDocumentID.
 */
export function buildAppealOutcomeRows(rows: Row[], urlByDocId: ReadonlyMap<string, string | null>): AppealOutcomeRow[] {
  return rows.map((r) => toOutcomeRow(r, urlByDocId)).sort((a, b) =>
    (b.assessmentYear ?? 0) - (a.assessmentYear ?? 0)
    || dayValue(b.decidedAt) - dayValue(a.decidedAt)
    || Number(b.isCurrent) - Number(a.isCurrent));
}
