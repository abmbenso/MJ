/**
 * @fileoverview The DLGF-only data path: a county with no loaded record cards, read from
 * indiana_tax.Parcel + indiana_tax.Assessment and mapped into the SAME MergedParcelRow the
 * card path produces (spec §6, "two data paths, one row shape"). Everything the card path
 * fills from CountyAssessorRecord -- building sqft, sqft source, sub-class DESCRIPTION,
 * neighbourhood, appeals, sale history -- is null here, and is null honestly: the statewide
 * file does not carry it. The row's DataSource says so on every row.
 *
 * 🚨 SAFETY: read-only. Nothing here writes.
 */
import { RunView } from '@memberjunction/core';
import { MergedParcelRow, classifySearchTerm, escapeSqlLiteral, SearchTermKind } from './property-search-agent-context';
import { pickAssessmentRow, dataSourceLabel, buildVerifyLink, CI_CLASS_CODE_FILTER } from './property-search-county';
import { EMPTY_APPEAL_LAYERS } from './property-search-appeal-layers';

export interface DlgfSearchParams {
  countyNumber: number;
  /** County.Slug, threaded through to buildVerifyLink -- see buildDlgfMergedRows. */
  slug: string;
  assessmentYear: number;
  searchTerm: string;
  /** The 3-digit DLGF class code chosen in the Sub Class filter, or null. */
  propertyClassCode: string | null;
  resultCap: number;
}

export interface DlgfSearchResult {
  rows: MergedParcelRow[];
  isTruncated: boolean;
}

export function buildDlgfAssessmentFilter(
  params: DlgfSearchParams,
  parcelIdConstraint: string[] | null,
  searchTermClassCode?: string | null
): string {
  const clauses: string[] = [
    `AssessmentYear = ${params.assessmentYear}`,
    `ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = ${params.countyNumber})`,
    CI_CLASS_CODE_FILTER,
  ];
  if (params.propertyClassCode) clauses.push(`PropertyClassCode = '${escapeSqlLiteral(params.propertyClassCode)}'`);
  // A free-typed 3-digit code in the search box (classifySearchTerm's 'subClassCode') is a
  // DIFFERENT filters field than the Sub Class dropdown's propertyClassCode above -- without
  // this clause it's classified but never applied, silently ignored (the card path's equivalent
  // is buildCarExtraFilter's own kind === 'subClassCode' branch).
  if (searchTermClassCode) clauses.push(`PropertyClassCode = '${escapeSqlLiteral(searchTermClassCode)}'`);
  if (parcelIdConstraint) {
    // No matching parcel number -> an empty result, never an unfiltered one.
    clauses.push(parcelIdConstraint.length ? `ParcelID IN (${parcelIdConstraint.map((id) => `'${escapeSqlLiteral(id)}'`).join(',')})` : '1=0');
  }
  return clauses.join(' AND ');
}

/** Owner/address free-text search resolves against Parcels first, then narrows the Assessment query. */
export function buildDlgfParcelSearchFilter(countyNumber: number, term: string, kind: SearchTermKind): string | null {
  const esc = escapeSqlLiteral(term);
  if (kind === 'parcelOrGisNumber') return `CountyNumber = ${countyNumber} AND (ParcelNumber = '${esc}' OR GISParcelNumber = '${esc}')`;
  if (kind === 'freeText') return `CountyNumber = ${countyNumber} AND (OwnerName LIKE '%${esc}%' OR Address LIKE '%${esc}%')`;
  return null; // subClassCode is handled on the Assessment query's own PropertyClassCode
}

/** One MergedParcelRow per parcel, precedence applied, top-N by AV. */
export function buildDlgfMergedRows(
  assessmentRows: Record<string, unknown>[],
  parcelRows: Record<string, unknown>[],
  taxHistoryRows: Record<string, unknown>[],
  countyNumber: number,
  slug: string,
  assessmentYear: number,
  resultCap: number
): DlgfSearchResult {
  const byParcel = new Map<string, Record<string, unknown>>();
  for (const a of assessmentRows) {
    const pid = a['ParcelID'] as string;
    byParcel.set(pid, pickAssessmentRow(byParcel.get(pid), a, countyNumber));
  }
  const parcelById = new Map<string, Record<string, unknown>>();
  for (const p of parcelRows) parcelById.set(p['ID'] as string, p);
  const taxByParcel = new Map<string, Record<string, unknown>>();
  for (const t of taxHistoryRows) {
    const pid = t['ParcelID'] as string;
    const existing = taxByParcel.get(pid);
    if (!existing || (t['ColumnOrdinal'] as number) > (existing['ColumnOrdinal'] as number)) taxByParcel.set(pid, t);
  }

  const rows: MergedParcelRow[] = [];
  for (const [parcelID, a] of byParcel) {
    const p = parcelById.get(parcelID);
    if (!p) continue;
    const tax = taxByParcel.get(parcelID);
    rows.push({
      ID: parcelID,
      ParcelID: parcelID,
      CountyAssessorRecordID: null,
      Address: (p['Address'] as string) ?? null,
      ParcelNumber: (p['ParcelNumber'] as string) ?? null,
      GISParcelNumber: (p['GISParcelNumber'] as string) ?? null,
      OwnerName: (p['OwnerName'] as string) ?? null,
      PropertyClass: (a['PropertyClassCode'] as string) ?? (p['PropertyClassCode'] as string) ?? null,
      // The statewide file carries a 3-digit class code, never the county's sub-class
      // DESCRIPTION -- shown as the code so the column is never silently blank.
      PropertySubClassDescription: (a['PropertyClassCode'] as string) ?? null,
      EstimatedSqFt: null,
      EstimatedSqFtExGarage: null,
      SqFtSource: null,
      Acreage: (p['Acreage'] as number) ?? null,
      ComparisonUnitType: null,
      ComparisonUnitCount: null,
      YearBuilt: null,
      CoStarYearBuilt: null,
      CoStarRBA: null,
      AssessedLandAV: (a['OriginalLandAV'] as number) ?? null,
      AssessedImprovementAV: (a['OriginalImprovementAV'] as number) ?? null,
      AssessedTotalAV: (a['OriginalTotalAV'] as number) ?? null,
      AssessmentYear: assessmentYear,
      AssessmentSource: (a['Source'] as string) ?? null,
      DataSource: dataSourceLabel((a['Source'] as string) ?? null, countyNumber),
      VerifyURL: buildVerifyLink({
        countyNumber,
        slug,
        parcelNumber: (p['ParcelNumber'] as string) ?? null,
        gisParcelNumber: (p['GISParcelNumber'] as string) ?? null,
        assessmentYear,
      }).url,
      TotalTax: (tax?.['NetAnnualTax'] as number) ?? null,
      TaxRate: (tax?.['TaxRate'] as number) ?? null,
      PTABOAValue: null,
      PTABOADate: null,
      PTABOAAppealType: null,
      ...EMPTY_APPEAL_LAYERS,
      // Owner Prospects rollup fields are Marion-only today (OwnerPortfolio runs
      // cover Marion commercial), so a DLGF-sourced row for another county has
      // nothing to report here -- null, never a fabricated value.
      OwnerEntity: null,
      TaxRep: null,
      Recommendation: null,
      ConfidenceTier: null,
      SupportingApproachCount: null,
      EstSavingsAtAsk: null,
      AVYoYPct: null,
      LastSaleDate: null,
      LastSalePrice: null,
      LastSaleIsValid: null,
      Neighborhood: null,
      TaxDistrictID: (p['TaxDistrictCode'] as string) ?? null,
      Latitude: (p['Latitude'] as number) ?? null,
      Longitude: (p['Longitude'] as number) ?? null,
      BoundaryGeoJSON: (p['BoundaryGeoJSON'] as string) ?? null,
    });
  }
  rows.sort((x, y) => (y.AssessedTotalAV ?? 0) - (x.AssessedTotalAV ?? 0));
  return { rows: rows.slice(0, resultCap), isTruncated: rows.length > resultCap };
}

/**
 * Precedence-resolves the raw (possibly multi-source-per-parcel) Assessment rows and returns the
 * IDs of only the top `resultCap` parcels by AV -- the ids the follow-up Parcels/Tax History
 * queries actually need. Without this, a big county's assessmentResult (up to resultCap*3 rows,
 * fetched with headroom for the precedence de-dupe) could carry up to resultCap*3 (15,000 at the current 5,000 cap)
 * DISTINCT parcel ids, turning the two follow-up `IN (...)` literals into ~230KB query strings --
 * when buildDlgfMergedRows' own final slice(0, resultCap) only ever keeps `resultCap` of them.
 * Mirrors buildDlgfMergedRows' own pickAssessmentRow + AV-descending sort exactly, so the ids
 * returned here are exactly the ones that final slice would keep -- matches the card path's own
 * RESULT_CAP-row cap (5,000 today; there enforced by MaxRows on the CountyAssessorRecord query itself).
 */
export function resolveDlgfTopParcelIds(
  assessmentRows: Record<string, unknown>[],
  countyNumber: number,
  resultCap: number
): { ids: string[]; totalDistinctCount: number } {
  const byParcel = new Map<string, Record<string, unknown>>();
  for (const a of assessmentRows) {
    const pid = a['ParcelID'] as string;
    byParcel.set(pid, pickAssessmentRow(byParcel.get(pid), a, countyNumber));
  }
  const winners = Array.from(byParcel.entries());
  winners.sort((x, y) => ((y[1]['OriginalTotalAV'] as number) ?? 0) - ((x[1]['OriginalTotalAV'] as number) ?? 0));
  return { ids: winners.slice(0, resultCap).map(([pid]) => pid), totalDistinctCount: winners.length };
}

/** Takes the RunView instance so the component keeps no query code of its own. */
export async function fetchDlgfParcelRows(rv: RunView, params: DlgfSearchParams): Promise<DlgfSearchResult> {
  const term = params.searchTerm.trim();
  const kind = term ? classifySearchTerm(term) : null;

  // A parcel-number or owner/address search resolves against Parcels FIRST -- the Assessment
  // query has neither field, so this is a genuinely dependent sequential call, not a batch.
  let parcelIdConstraint: string[] | null = null;
  const parcelSearchFilter = kind ? buildDlgfParcelSearchFilter(params.countyNumber, term, kind) : null;
  if (parcelSearchFilter) {
    const idResult = await rv.RunView<{ ID: string }>({
      EntityName: 'Parcels',
      Fields: ['ID'],
      ExtraFilter: parcelSearchFilter,
      // An owner LIKE can legitimately match thousands of parcels in a big county (a REIT,
      // a utility, a school corporation). 20000 covers the largest county's whole C&I set
      // (Lake, 15,001) so the constraint is never silently narrowed.
      MaxRows: 20000,
      ResultType: 'simple',
    });
    parcelIdConstraint = idResult.Success ? (idResult.Results ?? []).map((r) => r.ID) : [];
  }

  const searchTermClassCode = kind === 'subClassCode' ? term : null;

  const assessmentResult = await rv.RunView<Record<string, unknown>>({
    EntityName: 'Assessments',
    Fields: ['ParcelID', 'Source', 'PropertyClassCode', 'OriginalLandAV', 'OriginalImprovementAV', 'OriginalTotalAV'],
    ExtraFilter: buildDlgfAssessmentFilter(params, parcelIdConstraint, searchTermClassCode),
    OrderBy: 'OriginalTotalAV DESC',
    // Up to 3 sources can exist for one parcel-year (county PRC, FOIA list, DLGF), and the
    // precedence de-dupe happens client-side -- so fetch 3x the cap to be certain the top
    // `resultCap` DISTINCT parcels are all present after de-duping. 3 x RESULT_CAP (15,000 at 5,000), well
    // under the 202,150 dlgf_gdb_2025 Assessment rows (2026-09-13 controller probe) since
    // this query is always county-scoped.
    MaxRows: params.resultCap * 3,
    ResultType: 'simple',
  });
  if (!assessmentResult.Success || !assessmentResult.Results?.length) return { rows: [], isTruncated: false };

  // Bounded to the top `resultCap` parcels by AV (after precedence de-dupe) -- NOT every distinct
  // id in assessmentResult, which can run up to resultCap*3. See resolveDlgfTopParcelIds' doc
  // comment. totalDistinctCount (the full de-duped parcel count, pre-cap) is the source of truth
  // for isTruncated below -- buildDlgfMergedRows can no longer compute that itself once it's only
  // given Parcel rows for this already-capped id set.
  const { ids: parcelIds, totalDistinctCount } = resolveDlgfTopParcelIds(assessmentResult.Results, params.countyNumber, params.resultCap);
  // Guard the empty-list case: `ID IN ()` is a SQL syntax error, not an empty result.
  if (!parcelIds.length) return { rows: [], isTruncated: false };
  const parcelIdList = parcelIds.map((id) => `'${escapeSqlLiteral(id)}'`).join(',');

  const [parcelResult, taxHistoryResult] = await rv.RunViews<Record<string, unknown>>([
    {
      EntityName: 'Parcels',
      Fields: ['ID', 'ParcelNumber', 'GISParcelNumber', 'Address', 'OwnerName', 'Acreage', 'PropertyClassCode', 'TaxDistrictCode', 'Latitude', 'Longitude', 'BoundaryGeoJSON'],
      ExtraFilter: `ID IN (${parcelIdList})`,
      // One row per id in a list that is itself bounded to resultCap (see above) -- matches the
      // card path's own RESULT_CAP (5,000 today).
      MaxRows: params.resultCap,
      ResultType: 'simple',
    },
    {
      // Outside Marion this returns nothing today (Tax History Reports are Marion-only), and
      // that is fine: the column shows "no data", which is true. Kept in the batch so the day
      // another county's tax history loads, it simply appears.
      EntityName: 'Tax History Years',
      Fields: ['ParcelID', 'ColumnOrdinal', 'NetAnnualTax', 'TaxRate'],
      ExtraFilter: `ParcelID IN (${parcelIdList}) AND TaxYear = ${params.assessmentYear}`,
      MaxRows: params.resultCap,
      ResultType: 'simple',
    },
  ]);

  const merged = buildDlgfMergedRows(
    assessmentResult.Results,
    parcelResult.Success ? (parcelResult.Results ?? []) : [],
    taxHistoryResult.Success ? (taxHistoryResult.Results ?? []) : [],
    params.countyNumber,
    params.slug,
    params.assessmentYear,
    params.resultCap
  );
  // buildDlgfMergedRows' own isTruncated is unreliable here -- it's computed from how many of
  // ITS rows survive `parcelById.get(...)`, and parcelResult now only ever contains the
  // already-capped ids above, so its rows.length can never exceed resultCap. totalDistinctCount
  // (computed before the cap was applied) is the real signal for "more parcels exist".
  return { rows: merged.rows, isTruncated: totalDistinctCount > params.resultCap };
}

/**
 * The DLGF sub-class options source -- the statewide file has class CODES, not the county's
 * sub-class DESCRIPTIONS, so the dropdown is built from Property Class Maps (Code, Label),
 * labelled in the same NAME-### shape Marion uses so the existing 3-digit-code resolver
 * (resolveSubClassOption) keeps working unmodified.
 */
export function buildClassCodeSubClassOptions(classMapRows: Record<string, unknown>[]): { text: string; value: string }[] {
  return classMapRows
    .map((r) => ({ text: `${(r['Label'] as string) ?? 'Class'}-${r['Code'] as string}`, value: (r['Code'] as string) ?? '' }))
    // Only the C&I range the roster is built from (CI_CLASS_CODE_FILTER, 300-499): the class
    // map also carries agricultural (1xx), residential (5xx) and exempt (6xx) codes, and every
    // one of those is a guaranteed zero-row filter here. Seen in the click-through: Allen
    // offered 181 codes of which only 74 could ever match.
    .filter((o) => /^\d{3}$/.test(o.value) && o.value >= '300' && o.value <= '499')
    .sort((a, b) => a.value.localeCompare(b.value));
}
