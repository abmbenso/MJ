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

/**
 * Every MaxRows cap these fetchers query with, in one place: the query and the truncation
 * tripwire (rowsOrThrow) read the SAME constant, so they cannot disagree. A query that comes
 * back at its cap has been silently truncated, and a truncated layer read would show as
 * "no appeals" on the rows it lost.
 */
export const APPEAL_LAYER_MAX_ROWS = {
  /** The whole docket is 10,249 rows (2026-09-20); nothing a result page links to can exceed it. */
  ibtrAppeals: 12000,
  /** 9,585 appeal columns exist corpus-wide (2026-09-20); one year of one page is a small slice. */
  cardAppealColumns: 12000,
  /** Up to ~5 cards reprint the same year's original per parcel. */
  cardOriginalColumns: 20000,
  holdings: 5000,
  taxCourtLinks: 5000,
  detailCardColumns: 1000,
  detailCardNotes: 5000,
  detailIbtrAppeals: 500,
  detailHoldings: 1000,
  detailTaxCourtLinks: 1000,
  detailSourceDocuments: 500,
  detailTaxCourtCases: 500,
} as const;

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
  /** IBTRDecisionHolding.ValueAfter for that same decision, where exactly one holding can be attributed to it (pickHoldingValue); null when no holding was extracted (most decisions) or none is unambiguous. */
  IBTRValue: number | null;
  IBTRDecisionCount: number | null;
  /**
   * Y = a Tax Court case appears to review one of this parcel's Board decisions; N = this parcel
   * HAS Board decisions and none carries a qualifying link; null = no Board decision is matched to
   * this parcel at all (7,909 docket rows are unlinked), or the layer did not load. Only
   * fetchAppealLayers' success path ever sets 'N' -- a failed load must never read as "no".
   */
  TaxCourtDecision: 'Y' | 'N' | null;
}

export const EMPTY_APPEAL_LAYERS: AppealLayerFields = {
  CardAppealForm: null, CardOriginalAV: null, CardRevisedAV: null, CardAppealDate: null,
  IBTRDecisionDate: null, IBTRAssessmentYear: null, IBTRDisposition: null, IBTRValue: null, IBTRDecisionCount: null,
  TaxCourtDecision: null,
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

/** The two fields that identify WHICH appeal a holding belongs to. Both may be missing on a docket row. */
export interface AppealHoldingKey { PetitionNumber: string | null; AssessmentYear: number | null; }

/** A holding's `PetitionNumbers` is free text -- one number, or several comma-separated ("A, B"). */
const petitionTokens = (v: unknown): string[] => (v == null ? [] : String(v).split(',').map((t) => t.trim()).filter(Boolean));
/** `AssessmentYears` is free text too -- "2007", "2006, 2007", or empty. Match the year as a whole 4-digit token. */
const yearTokens = (v: unknown): string[] => (v == null ? [] : String(v).match(/\d{4}/g) ?? []);

/**
 * The value ONE appeal's own holding sets, or null when no single holding can be attributed to it.
 *
 * A single written determination routinely prints the Board's figure for several petitions and
 * several years (petition 53-009-07-1-4-00189, AY2007, carries five: AY2006 521,600 · AY2007
 * 515,900 · AY2008 588,600 · AY2009 592,200 · AY2010 570,200). Taking whichever row the server
 * returned first showed another year's number beside "IBTR Year 2007", so:
 *   1. exactly one holding naming this appeal's own petition number -> its value;
 *   2. else exactly one holding naming this appeal's assessment year -> its value;
 *   3. else a SOLE holding carrying no petition/year text at all -> its value (the long-standing
 *      single-holding case, which is most of the 118 extracted holdings);
 *   4. otherwise null -- blank, never a guess between several.
 *
 * @param holdings this appeal's holdings only.
 */
export function pickHoldingValue(appeal: AppealHoldingKey, holdings: Row[]): number | null {
  const valued = holdings.filter((h) => h['ValueAfter'] != null);
  if (!valued.length) return null;
  if (appeal.PetitionNumber) {
    const byPetition = valued.filter((h) => petitionTokens(h['PetitionNumbers']).includes(appeal.PetitionNumber as string));
    if (byPetition.length === 1) return Number(byPetition[0]['ValueAfter']);
  }
  if (appeal.AssessmentYear != null) {
    const byYear = valued.filter((h) => yearTokens(h['AssessmentYears']).includes(String(appeal.AssessmentYear)));
    if (byYear.length === 1) return Number(byYear[0]['ValueAfter']);
  }
  const sole = valued.length === 1 ? valued[0] : null;
  if (sole && !petitionTokens(sole['PetitionNumbers']).length && !yearTokens(sole['AssessmentYears']).length) return Number(sole['ValueAfter']);
  return null;
}

const appealKey = (r: Row): AppealHoldingKey => ({ PetitionNumber: str(r['PetitionNumber']), AssessmentYear: num(r['AssessmentYear']) });

/** @param holdingRows holdings for ALL the appeals in `ibtrRows`, carrying PetitionNumbers + AssessmentYears. */
export function reduceIbtr(ibtrRows: Row[], holdingRows: Row[]): Map<string, IbtrSummary> {
  const holdingsByAppeal = new Map<string, Row[]>();
  for (const h of holdingRows) {
    const id = h['IBTRAppealID'] as string;
    holdingsByAppeal.set(id, [...(holdingsByAppeal.get(id) ?? []), h]);
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
      value: pickHoldingValue(appealKey(r), holdingsByAppeal.get(r['ID'] as string) ?? []), count: count.get(pid) ?? 0 });
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
/**
 * The rows of one layer query, or a throw. Two ways a layer read can be wrong, both of which
 * would otherwise render as "no appeals": the query failed, or it came back AT its MaxRows cap
 * and was silently truncated (this component has been truncated by a missing/short cap four
 * times). @param maxRows the cap the query itself was issued with (APPEAL_LAYER_MAX_ROWS).
 */
export function rowsOrThrow(entity: string, r: ViewResult, maxRows: number): Row[] {
  if (!r.Success) throw new Error(`Appeal layers: ${entity} query failed: ${r.ErrorMessage ?? 'unknown error'}`);
  const rows = r.Results ?? [];
  if (rows.length >= maxRows) {
    throw new Error(`Appeal layers: ${entity} returned ${rows.length} rows — at or over its MaxRows cap (${maxRows}); results may be truncated`);
  }
  return rows;
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
      // PetitionNumber comes back so each appeal's own holding can be told from the other
      // petitions' holdings printed in the same determination (see pickHoldingValue).
      Fields: ['ID', 'ParcelID', 'PetitionNumber', 'DecisionDate', 'AssessmentYear', 'DispositionType'],
      ExtraFilter: `ParcelID IN (${ids})`,
      MaxRows: APPEAL_LAYER_MAX_ROWS.ibtrAppeals,
      ResultType: 'simple' as const,
    },
    ...(includeCard ? [{
      EntityName: CARD_COLUMNS_ENTITY,
      Fields: ['ParcelID', 'CardAssessmentYear', 'AssessmentYear', 'ReasonForm', 'AsOfDate', 'TotalAV'],
      ExtraFilter: `ParcelID IN (${ids}) AND AssessmentYear = ${Number(assessmentYear)} AND ReasonKind = 'appeal'`,
      MaxRows: APPEAL_LAYER_MAX_ROWS.cardAppealColumns,
      ResultType: 'simple' as const,
    }] : []),
  ];
  const firstResults = await rv.RunViews<Row>(first);
  const ibtrRows = rowsOrThrow(IBTR_APPEALS_ENTITY, firstResults[0], APPEAL_LAYER_MAX_ROWS.ibtrAppeals);
  const cardAppealRows = includeCard ? rowsOrThrow(CARD_COLUMNS_ENTITY, firstResults[1], APPEAL_LAYER_MAX_ROWS.cardAppealColumns) : [];

  let holdingRows: Row[] = [], linkRows: Row[] = [], originalRows: Row[] = [];
  const second: { EntityName: string; Fields: string[]; ExtraFilter: string; MaxRows: number; ResultType: 'simple' }[] = [];
  if (ibtrRows.length) {
    const appealIds = inList(ibtrRows.map((r) => r['ID'] as string));
    second.push({ EntityName: IBTR_HOLDINGS_ENTITY, Fields: ['IBTRAppealID', 'PetitionNumbers', 'AssessmentYears', 'ValueAfter'], ExtraFilter: `IBTRAppealID IN (${appealIds})`, MaxRows: APPEAL_LAYER_MAX_ROWS.holdings, ResultType: 'simple' });
    second.push({ EntityName: TAX_COURT_LINKS_ENTITY, Fields: ['IBTRAppealID'], ExtraFilter: `IBTRAppealID IN (${appealIds}) AND NameScore >= ${TAX_COURT_FLAG_MIN_SCORE}`, MaxRows: APPEAL_LAYER_MAX_ROWS.taxCourtLinks, ResultType: 'simple' });
  }
  if (cardAppealRows.length) {
    const appealed = inList([...new Set(cardAppealRows.map((r) => r['ParcelID'] as string))]);
    second.push({
      EntityName: CARD_COLUMNS_ENTITY, Fields: ['ParcelID', 'AsOfDate', 'TotalAV'],
      ExtraFilter: `ParcelID IN (${appealed}) AND AssessmentYear = ${Number(assessmentYear)} AND IsCertified = 1 AND ReasonKind NOT IN ('appeal', 'wip')`,
      MaxRows: APPEAL_LAYER_MAX_ROWS.cardOriginalColumns, ResultType: 'simple',
    });
  }
  if (second.length) {
    const results = await rv.RunViews<Row>(second);
    second.forEach((p, i) => {
      const rows = rowsOrThrow(p.EntityName, results[i], p.MaxRows);
      if (p.EntityName === IBTR_HOLDINGS_ENTITY) holdingRows = rows;
      else if (p.EntityName === TAX_COURT_LINKS_ENTITY) linkRows = rows;
      else originalRows = rows;
    });
  }

  const card = reduceCardAppeals(cardAppealRows, originalRows);
  const ibtr = reduceIbtr(ibtrRows, holdingRows);
  const court = reduceTaxCourtParcels(ibtrRows, linkRows);
  // Every REQUESTED parcel gets an entry on this (successful) path, so a blank Tax Court cell
  // can only mean "nothing is linked to this parcel" -- the caller's failure path is the only
  // other way a row ends up blank, and it says so in a banner.
  for (const pid of new Set([...parcelIds, ...card.keys(), ...ibtr.keys()])) {
    const c = card.get(pid); const b = ibtr.get(pid);
    out.set(pid, {
      CardAppealForm: c?.form ?? null, CardOriginalAV: c?.originalAV ?? null, CardRevisedAV: c?.revisedAV ?? null, CardAppealDate: c?.date ?? null,
      IBTRDecisionDate: b?.date ?? null, IBTRAssessmentYear: b?.year ?? null, IBTRDisposition: b?.disposition ?? null,
      IBTRValue: b?.value ?? null, IBTRDecisionCount: b ? b.count : null,
      // 'N' means "this parcel has Board decisions and none of them carries a qualifying Tax
      // Court link" -- a parcel with no matched Board decision has nothing a case could review.
      TaxCourtDecision: b ? (court.has(pid) ? 'Y' : 'N') : null,
    });
  }
  return out;
}

export function applyAppealLayers<T extends { ParcelID: string }>(rows: T[], layers: Map<string, AppealLayerFields>): (T & AppealLayerFields)[] {
  return rows.map((r) => ({ ...EMPTY_APPEAL_LAYERS, ...r, ...(layers.get(r.ParcelID) ?? {}) }));
}

export interface CardRevisionRow { assessmentYear: number; form: number | null; reason: string | null; asOfDate: string | null; originalTotalAV: number | null; revisedTotalAV: number | null; cardYear: number; }
export interface CardNoteRow { kind: 'appeal' | 'permit' | 'other'; form: number | null; date: string | null; code: string | null; text: string; printings: number; }
export interface IbtrDecisionRow { petitionNumber: string; decisionDate: string | null; assessmentYear: number | null; disposition: string | null; appealType: string | null; valueAfter: number | null; documentURL: string | null; }
export interface TaxCourtCaseRow { docketNumber: string; caseName: string; lastDecisionDate: string | null; opinionURL: string | null; nameScore: number; isHighConfidence: boolean; }
export interface ParcelAppealLayerDetail { cardRevisions: CardRevisionRow[]; cardNotes: CardNoteRow[]; ibtrDecisions: IbtrDecisionRow[]; taxCourtCases: TaxCourtCaseRow[]; }

/** @param columnRows every non-WIP CardValuationColumn row of ONE parcel, all cards and years. */
export function buildCardRevisionRows(columnRows: Row[]): CardRevisionRow[] {
  const byYear = new Map<number, Row[]>();
  for (const r of columnRows) { const y = Number(r['AssessmentYear']); byYear.set(y, [...(byYear.get(y) ?? []), r]); }
  const out: CardRevisionRow[] = [];
  for (const [year, rows] of byYear) {
    const originals = rows.filter((r) => r['IsCertified'] && r['ReasonKind'] !== 'appeal' && r['ReasonKind'] !== 'wip');
    const original = originals.reduce<Row | null>((a, r) => (!a || (time(r['AsOfDate']) ?? Infinity) < (time(a['AsOfDate']) ?? Infinity) ? r : a), null);
    const distinct = new Map<string, Row>();
    for (const r of rows.filter((x) => x['ReasonKind'] === 'appeal')) {
      const key = `${str(r['AsOfDate'])}|${r['TotalAV']}|${r['ReasonForm']}`;
      const cur = distinct.get(key);
      if (!cur || Number(r['CardAssessmentYear']) > Number(cur['CardAssessmentYear'])) distinct.set(key, r);
    }
    for (const r of distinct.values()) {
      out.push({ assessmentYear: year, form: num(r['ReasonForm']), reason: str(r['ReasonForChange']), asOfDate: str(r['AsOfDate']),
        originalTotalAV: num(original?.['TotalAV']), revisedTotalAV: num(r['TotalAV']), cardYear: Number(r['CardAssessmentYear']) });
    }
  }
  return out.sort((a, b) => b.assessmentYear - a.assessmentYear || (time(b.asOfDate) ?? 0) - (time(a.asOfDate) ?? 0));
}

const NOTE_KIND_ORDER: Record<CardNoteRow['kind'], number> = { appeal: 0, permit: 1, other: 2 };
export function buildCardNoteRows(noteRows: Row[]): CardNoteRow[] {
  const byKey = new Map<string, CardNoteRow>();
  for (const r of noteRows) {
    const key = (r['NoteKey'] as string) ?? `${str(r['NoteDate'])}|${r['NoteCode']}|${r['NoteText']}`;
    const cur = byKey.get(key);
    if (cur) { cur.printings++; continue; }
    const kind: CardNoteRow['kind'] = r['NoteKind'] === 'appeal' || r['NoteKind'] === 'permit' ? r['NoteKind'] : 'other';
    byKey.set(key, { kind, form: num(r['NoteForm']), date: str(r['NoteDate']), code: str(r['NoteCode']), text: String(r['NoteText'] ?? ''), printings: 1 });
  }
  return [...byKey.values()].sort((a, b) => NOTE_KIND_ORDER[a.kind] - NOTE_KIND_ORDER[b.kind] || (time(b.date) ?? 0) - (time(a.date) ?? 0));
}

/** Everything the detail panel shows for one parcel. Three round trips at most; throws on a failed query. */
export async function fetchParcelAppealLayerDetail(rv: RunView, parcelID: string): Promise<ParcelAppealLayerDetail> {
  const pid = escapeSqlLiteral(parcelID);
  const [colRes, noteRes, ibtrRes] = await rv.RunViews<Row>([
    { EntityName: CARD_COLUMNS_ENTITY, Fields: ['CardAssessmentYear', 'AssessmentYear', 'IsCertified', 'ReasonKind', 'ReasonForm', 'ReasonForChange', 'AsOfDate', 'TotalAV'],
      ExtraFilter: `ParcelID = '${pid}' AND ReasonKind <> 'wip'`, MaxRows: APPEAL_LAYER_MAX_ROWS.detailCardColumns, ResultType: 'simple' },
    { EntityName: CARD_NOTES_ENTITY, Fields: ['NoteKey', 'NoteKind', 'NoteForm', 'NoteDate', 'NoteCode', 'NoteText'],
      ExtraFilter: `ParcelID = '${pid}'`, MaxRows: APPEAL_LAYER_MAX_ROWS.detailCardNotes, ResultType: 'simple' },
    { EntityName: IBTR_APPEALS_ENTITY, Fields: ['ID', 'PetitionNumber', 'DecisionDate', 'AssessmentYear', 'DispositionType', 'AppealType', 'SourceDocumentID'],
      ExtraFilter: `ParcelID = '${pid}'`, OrderBy: 'DecisionDate DESC', MaxRows: APPEAL_LAYER_MAX_ROWS.detailIbtrAppeals, ResultType: 'simple' },
  ]);
  const ibtrRows = rowsOrThrow(IBTR_APPEALS_ENTITY, ibtrRes, APPEAL_LAYER_MAX_ROWS.detailIbtrAppeals);
  const detail: ParcelAppealLayerDetail = {
    cardRevisions: buildCardRevisionRows(rowsOrThrow(CARD_COLUMNS_ENTITY, colRes, APPEAL_LAYER_MAX_ROWS.detailCardColumns)),
    cardNotes: buildCardNoteRows(rowsOrThrow(CARD_NOTES_ENTITY, noteRes, APPEAL_LAYER_MAX_ROWS.detailCardNotes)), ibtrDecisions: [], taxCourtCases: [],
  };
  if (!ibtrRows.length) return detail;

  const appealIds = inList(ibtrRows.map((r) => r['ID'] as string));
  const docIds = ibtrRows.map((r) => r['SourceDocumentID'] as string | null).filter((v): v is string => !!v);
  const [holdRes, linkRes, docRes] = await rv.RunViews<Row>([
    { EntityName: IBTR_HOLDINGS_ENTITY, Fields: ['IBTRAppealID', 'PetitionNumbers', 'AssessmentYears', 'ValueAfter'], ExtraFilter: `IBTRAppealID IN (${appealIds})`, MaxRows: APPEAL_LAYER_MAX_ROWS.detailHoldings, ResultType: 'simple' },
    { EntityName: TAX_COURT_LINKS_ENTITY, Fields: ['TaxCourtCaseID', 'NameScore'], ExtraFilter: `IBTRAppealID IN (${appealIds})`, MaxRows: APPEAL_LAYER_MAX_ROWS.detailTaxCourtLinks, ResultType: 'simple' },
    { EntityName: SOURCE_DOCUMENTS_ENTITY, Fields: ['ID', 'SourceURL'], ExtraFilter: docIds.length ? `ID IN (${inList(docIds)})` : '1=0', MaxRows: APPEAL_LAYER_MAX_ROWS.detailSourceDocuments, ResultType: 'simple' },
  ]);
  const holdingsByAppeal = new Map<string, Row[]>();
  for (const h of rowsOrThrow(IBTR_HOLDINGS_ENTITY, holdRes, APPEAL_LAYER_MAX_ROWS.detailHoldings)) {
    const id = h['IBTRAppealID'] as string;
    holdingsByAppeal.set(id, [...(holdingsByAppeal.get(id) ?? []), h]);
  }
  const urlByDoc = new Map(rowsOrThrow(SOURCE_DOCUMENTS_ENTITY, docRes, APPEAL_LAYER_MAX_ROWS.detailSourceDocuments).map((d) => [d['ID'] as string, str(d['SourceURL'])]));
  detail.ibtrDecisions = ibtrRows.map((r) => ({
    petitionNumber: String(r['PetitionNumber'] ?? ''), decisionDate: str(r['DecisionDate']), assessmentYear: num(r['AssessmentYear']),
    disposition: str(r['DispositionType']), appealType: str(r['AppealType']),
    // Same attribution rule as the grid -- this decision's OWN holding, never another year's.
    valueAfter: pickHoldingValue(appealKey(r), holdingsByAppeal.get(r['ID'] as string) ?? []),
    documentURL: urlByDoc.get(r['SourceDocumentID'] as string) ?? null,
  }));

  const bestScoreByCase = new Map<string, number>();
  for (const l of rowsOrThrow(TAX_COURT_LINKS_ENTITY, linkRes, APPEAL_LAYER_MAX_ROWS.detailTaxCourtLinks)) {
    const id = l['TaxCourtCaseID'] as string; const s = Number(l['NameScore']);
    if (s > (bestScoreByCase.get(id) ?? -1)) bestScoreByCase.set(id, s);
  }
  if (bestScoreByCase.size) {
    const caseRes = await rv.RunView<Row>({ EntityName: TAX_COURT_CASES_ENTITY, Fields: ['ID', 'DocketNumber', 'CaseName', 'LastDecisionDate', 'OpinionURL'],
      ExtraFilter: `ID IN (${inList([...bestScoreByCase.keys()])})`, MaxRows: APPEAL_LAYER_MAX_ROWS.detailTaxCourtCases, ResultType: 'simple' });
    detail.taxCourtCases = rowsOrThrow(TAX_COURT_CASES_ENTITY, caseRes, APPEAL_LAYER_MAX_ROWS.detailTaxCourtCases).map((c) => {
      const score = bestScoreByCase.get(c['ID'] as string) ?? 0;
      return { docketNumber: String(c['DocketNumber']), caseName: String(c['CaseName']), lastDecisionDate: str(c['LastDecisionDate']),
        opinionURL: str(c['OpinionURL']), nameScore: score, isHighConfidence: score >= TAX_COURT_FLAG_MIN_SCORE };
    }).sort((a, b) => b.nameScore - a.nameScore);
  }
  return detail;
}
