/**
 * @fileoverview The appeal layers beyond PTABOA (Indiana_Tax_Expert docs/proposals/multi-county-ci-intake.md §12):
 * revisions printed on the county's own record card, Indiana Board of Tax Review decisions, and a Tax Court flag.
 * Both data paths (card, DLGF-only) build their rows first and pass them through here, so the layers can never
 * differ between the two. Pure reducers + thin fetchers; the component keeps no query code of its own.
 *
 * 🚨 SAFETY: read-only. Nothing here writes.
 */
import { RunView } from '@memberjunction/core';
import { escapeSqlLiteral } from './property-search-agent-context';

type Row = Record<string, unknown>;

export const CARD_COLUMNS_ENTITY = 'Card Valuation Columns';
export const CARD_NOTES_ENTITY = 'Card Notes';
export const IBTR_APPEALS_ENTITY = 'IBTR Appeals';
export const IBTR_HOLDINGS_ENTITY = 'IBTR Decision Holdings';
export const TAX_COURT_LINKS_ENTITY = 'Tax Court IBTR Links';
export const TAX_COURT_CASES_ENTITY = 'Tax Court Cases';
export const SOURCE_DOCUMENTS_ENTITY = 'Source Documents';
/** A Tax Court link is a taxpayer-name match, not a citation; only near-identical names raise the grid flag (spec §12.4). */
export const TAX_COURT_FLAG_MIN_SCORE = 0.95;

export interface AppealLayerFields {
  /** Card layer -- scoped to the SELECTED assessment year, like the PTABOA columns. Null on a DLGF-only row. */
  CardAppealForm: number | null;
  CardOriginalAV: number | null;
  CardRevisedAV: number | null;
  CardAppealDate: string | null;
  /** IBTR layer -- the parcel's NEWEST Board decision, whatever year it concerned (a decision trails its year by years). */
  IBTRDecisionDate: string | null;
  IBTRAssessmentYear: number | null;
  IBTRDisposition: string | null;
  /** IBTRDecisionHolding.ValueAfter for that same decision; null when no holding was extracted (most decisions). */
  IBTRValue: number | null;
  IBTRDecisionCount: number | null;
  TaxCourtDecision: 'Y' | 'N';
}

export const EMPTY_APPEAL_LAYERS: AppealLayerFields = {
  CardAppealForm: null, CardOriginalAV: null, CardRevisedAV: null, CardAppealDate: null,
  IBTRDecisionDate: null, IBTRAssessmentYear: null, IBTRDisposition: null, IBTRValue: null, IBTRDecisionCount: null,
  TaxCourtDecision: 'N',
};

const time = (v: unknown): number | null => {
  if (v == null) return null;
  const t = new Date(v as string).getTime();
  return Number.isNaN(t) ? null : t;
};
const str = (v: unknown): string | null => (v == null ? null : v instanceof Date ? v.toISOString().slice(0, 10) : String(v));
const num = (v: unknown): number | null => (v == null ? null : Number(v));

export interface CardAppealSummary { form: number | null; originalAV: number | null; revisedAV: number | null; date: string | null; }

/**
 * @param appealRows ReasonKind='appeal' columns for ONE assessment year (a revision is reprinted on every later card).
 * @param originalRows certified non-appeal, non-WIP columns for the same year and parcels.
 */
export function reduceCardAppeals(appealRows: Row[], originalRows: Row[]): Map<string, CardAppealSummary> {
  const newest = new Map<string, Row>();
  for (const r of appealRows) {
    const pid = r['ParcelID'] as string;
    const cur = newest.get(pid);
    const a = time(r['AsOfDate']) ?? -Infinity;
    const b = cur ? time(cur['AsOfDate']) ?? -Infinity : -Infinity;
    if (!cur || a > b || (a === b && Number(r['CardAssessmentYear']) > Number(cur['CardAssessmentYear']))) newest.set(pid, r);
  }
  const earliest = new Map<string, Row>();
  for (const r of originalRows) {
    const pid = r['ParcelID'] as string;
    const cur = earliest.get(pid);
    if (!cur || (time(r['AsOfDate']) ?? Infinity) < (time(cur['AsOfDate']) ?? Infinity)) earliest.set(pid, r);
  }
  const out = new Map<string, CardAppealSummary>();
  for (const [pid, r] of newest) {
    out.set(pid, { form: num(r['ReasonForm']), originalAV: num(earliest.get(pid)?.['TotalAV']), revisedAV: num(r['TotalAV']), date: str(r['AsOfDate']) });
  }
  return out;
}

export interface IbtrSummary { date: string | null; year: number | null; disposition: string | null; value: number | null; count: number; }

export function reduceIbtr(ibtrRows: Row[], holdingRows: Row[]): Map<string, IbtrSummary> {
  const valueByAppeal = new Map<string, number>();
  for (const h of holdingRows) {
    const id = h['IBTRAppealID'] as string;
    if (h['ValueAfter'] != null && !valueByAppeal.has(id)) valueByAppeal.set(id, Number(h['ValueAfter']));
  }
  const newest = new Map<string, Row>();
  const count = new Map<string, number>();
  for (const r of ibtrRows) {
    const pid = r['ParcelID'] as string;
    count.set(pid, (count.get(pid) ?? 0) + 1);
    const cur = newest.get(pid);
    if (!cur || (time(r['DecisionDate']) ?? -Infinity) > (time(cur['DecisionDate']) ?? -Infinity)) newest.set(pid, r);
  }
  const out = new Map<string, IbtrSummary>();
  for (const [pid, r] of newest) {
    out.set(pid, { date: str(r['DecisionDate']), year: num(r['AssessmentYear']), disposition: str(r['DispositionType']),
      value: valueByAppeal.get(r['ID'] as string) ?? null, count: count.get(pid) ?? 0 });
  }
  return out;
}

/** @param linkRows Tax Court links ALREADY filtered to NameScore >= TAX_COURT_FLAG_MIN_SCORE. */
export function reduceTaxCourtParcels(ibtrRows: Row[], linkRows: Row[]): Set<string> {
  const linked = new Set(linkRows.map((l) => l['IBTRAppealID'] as string));
  const out = new Set<string>();
  for (const r of ibtrRows) if (linked.has(r['ID'] as string)) out.add(r['ParcelID'] as string);
  return out;
}

const inList = (ids: string[]): string => ids.map((id) => `'${escapeSqlLiteral(id)}'`).join(',');

interface ViewResult { Success: boolean; ErrorMessage?: string; Results?: Row[]; }
function rowsOrThrow(entity: string, r: ViewResult): Row[] {
  if (!r.Success) throw new Error(`Appeal layers: ${entity} query failed: ${r.ErrorMessage ?? 'unknown error'}`);
  return r.Results ?? [];
}

/**
 * The three layers for one result page. Two round trips at most: (1) IBTR appeals + this year's card appeal
 * columns; (2) only for what (1) found -- holdings, Tax Court links, the card originals. Throws on any failed
 * query: a failed load must never read as "no appeals" (the caller shows a banner instead).
 */
export async function fetchAppealLayers(rv: RunView, parcelIds: string[], assessmentYear: number, includeCard: boolean): Promise<Map<string, AppealLayerFields>> {
  const out = new Map<string, AppealLayerFields>();
  if (!parcelIds.length) return out;
  const ids = inList(parcelIds);

  const first = [
    {
      EntityName: IBTR_APPEALS_ENTITY,
      Fields: ['ID', 'ParcelID', 'DecisionDate', 'AssessmentYear', 'DispositionType'],
      ExtraFilter: `ParcelID IN (${ids})`,
      // The whole docket is 10,249 rows; nothing a result page links to can exceed it.
      MaxRows: 12000,
      ResultType: 'simple' as const,
    },
    ...(includeCard ? [{
      EntityName: CARD_COLUMNS_ENTITY,
      Fields: ['ParcelID', 'CardAssessmentYear', 'AssessmentYear', 'ReasonForm', 'AsOfDate', 'TotalAV'],
      ExtraFilter: `ParcelID IN (${ids}) AND AssessmentYear = ${Number(assessmentYear)} AND ReasonKind = 'appeal'`,
      // 9,585 appeal columns exist corpus-wide (2026-09-20); one year of one page is a small slice of that.
      MaxRows: 12000,
      ResultType: 'simple' as const,
    }] : []),
  ];
  const firstResults = await rv.RunViews<Row>(first);
  const ibtrRows = rowsOrThrow(IBTR_APPEALS_ENTITY, firstResults[0]);
  const cardAppealRows = includeCard ? rowsOrThrow(CARD_COLUMNS_ENTITY, firstResults[1]) : [];

  let holdingRows: Row[] = [], linkRows: Row[] = [], originalRows: Row[] = [];
  const second: { EntityName: string; Fields: string[]; ExtraFilter: string; MaxRows: number; ResultType: 'simple' }[] = [];
  if (ibtrRows.length) {
    const appealIds = inList(ibtrRows.map((r) => r['ID'] as string));
    second.push({ EntityName: IBTR_HOLDINGS_ENTITY, Fields: ['IBTRAppealID', 'ValueAfter'], ExtraFilter: `IBTRAppealID IN (${appealIds})`, MaxRows: 5000, ResultType: 'simple' });
    second.push({ EntityName: TAX_COURT_LINKS_ENTITY, Fields: ['IBTRAppealID'], ExtraFilter: `IBTRAppealID IN (${appealIds}) AND NameScore >= ${TAX_COURT_FLAG_MIN_SCORE}`, MaxRows: 5000, ResultType: 'simple' });
  }
  if (cardAppealRows.length) {
    const appealed = inList([...new Set(cardAppealRows.map((r) => r['ParcelID'] as string))]);
    second.push({
      EntityName: CARD_COLUMNS_ENTITY, Fields: ['ParcelID', 'AsOfDate', 'TotalAV'],
      ExtraFilter: `ParcelID IN (${appealed}) AND AssessmentYear = ${Number(assessmentYear)} AND IsCertified = 1 AND ReasonKind NOT IN ('appeal', 'wip')`,
      // Up to ~5 cards reprint the same year's original per parcel.
      MaxRows: 20000, ResultType: 'simple',
    });
  }
  if (second.length) {
    const results = await rv.RunViews<Row>(second);
    second.forEach((p, i) => {
      const rows = rowsOrThrow(p.EntityName, results[i]);
      if (p.EntityName === IBTR_HOLDINGS_ENTITY) holdingRows = rows;
      else if (p.EntityName === TAX_COURT_LINKS_ENTITY) linkRows = rows;
      else originalRows = rows;
    });
  }

  const card = reduceCardAppeals(cardAppealRows, originalRows);
  const ibtr = reduceIbtr(ibtrRows, holdingRows);
  const court = reduceTaxCourtParcels(ibtrRows, linkRows);
  for (const pid of new Set([...card.keys(), ...ibtr.keys()])) {
    const c = card.get(pid); const b = ibtr.get(pid);
    out.set(pid, {
      CardAppealForm: c?.form ?? null, CardOriginalAV: c?.originalAV ?? null, CardRevisedAV: c?.revisedAV ?? null, CardAppealDate: c?.date ?? null,
      IBTRDecisionDate: b?.date ?? null, IBTRAssessmentYear: b?.year ?? null, IBTRDisposition: b?.disposition ?? null,
      IBTRValue: b?.value ?? null, IBTRDecisionCount: b ? b.count : null,
      TaxCourtDecision: court.has(pid) ? 'Y' : 'N',
    });
  }
  return out;
}

export function applyAppealLayers<T extends { ParcelID: string }>(rows: T[], layers: Map<string, AppealLayerFields>): (T & AppealLayerFields)[] {
  return rows.map((r) => ({ ...EMPTY_APPEAL_LAYERS, ...r, ...(layers.get(r.ParcelID) ?? {}) }));
}
