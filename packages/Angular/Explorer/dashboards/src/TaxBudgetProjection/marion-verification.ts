/**
 * Links to the county's own documents, so a projection can be checked against its source.
 *
 * A projection nobody can check is an assertion. Every figure this tool shows for a Marion
 * parcel traces back to one of two county documents -- the Property Record Card (assessed
 * values, 2024-2026) and the Tax History report (billed history) -- and these are the
 * routes to them.
 *
 * 🚨 MARION ONLY. These endpoints are Marion County's own system; Marion does NOT use
 * Beacon/qPublic (confirmed in Big_Box_Retail's vendor-classification.json, which maps all
 * 92 Indiana counties to their assessor platform). When this tool covers another county,
 * that file is the routing table -- do not assume this URL shape generalises.
 *
 * Verified live 2026-09-10: both endpoints return a real per-parcel PDF, and the Tax
 * History PDF for 9003241 matched the tool's figures exactly (gross AV $24,416,700,
 * deductions $1,465,002, net AV $22,951,698).
 *
 * The same URL shape is already used by four artifacts in Indiana_Tax_Expert
 * (analyze-parcel, comp-assessment-view, owner-portfolios-view, valuation-analysis-view).
 */

const BASE = 'https://maps.indy.gov/AssessorPropertyCards.Reports.Service';

export type VerificationKind = 'prc' | 'taxHistory';

export interface VerificationLink {
  kind: VerificationKind;
  /** How the county names the document. */
  label: string;
  shortLabel: string;
  url: string;
  /** When we retrieved our copy, or null if we hold none. */
  retrievedAt: Date | null;
  /** True when this project holds a retrieved copy. */
  onFile: boolean;
  /** Provenance in words, for the UI and for the exports. */
  note: string;
}

/** The Property Record Card: assessed values as noticed. */
export function prcUrl(gisParcelNumber: string): string {
  return `${BASE}/ReportPage.aspx?ParcelNumber=${encodeURIComponent(gisParcelNumber)}`;
}

/** The Tax History report: billed history, year by year. */
export function taxHistoryUrl(gisParcelNumber: string): string {
  return `${BASE}/TaxHistoryReportPage.aspx?ParcelNumber=${encodeURIComponent(gisParcelNumber)}`;
}

function isoDay(d: Date): string {
  return d.toISOString().slice(0, 10);
}

export interface RetrievedCopies {
  prc?: Date | null;
  taxHistory?: Date | null;
}

/**
 * Both documents, always -- the link is derived from the parcel number, so it resolves for
 * any Marion parcel including ones never harvested. Whether we hold a COPY is a separate
 * claim, carried in `onFile`/`note`: "retrieved <date>" when we cite our own copy,
 * "not on file" when the reader must go and look. Conflating the two would either hide a
 * usable route or imply we had cited something we never pulled.
 */
export function buildVerificationLinks(gisParcelNumber: string, retrieved: RetrievedCopies): VerificationLink[] {
  const parcel = (gisParcelNumber ?? '').trim();
  if (!parcel) return [];

  const make = (kind: VerificationKind, label: string, shortLabel: string, url: string, at: Date | null | undefined): VerificationLink => {
    const retrievedAt = at ?? null;
    return {
      kind,
      label,
      shortLabel,
      url,
      retrievedAt,
      onFile: retrievedAt != null,
      note: retrievedAt ? `retrieved ${isoDay(retrievedAt)}` : 'not on file — verify at the county',
    };
  };

  return [
    make('prc', 'Property Record Card', 'PRC', prcUrl(parcel), retrieved.prc),
    make('taxHistory', 'Tax History', 'Tax History', taxHistoryUrl(parcel), retrieved.taxHistory),
  ];
}
