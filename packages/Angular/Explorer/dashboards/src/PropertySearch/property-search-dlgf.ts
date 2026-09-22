/**
 * @fileoverview The DLGF-only data path: a county with no loaded record cards, read from
 * indiana_tax.ParcelYearHeadline + indiana_tax.Parcel and mapped into the SAME MergedParcelRow the
 * card path produces (spec §6, "two data paths, one row shape"). Everything the card path
 * fills from CountyAssessorRecord -- building sqft, sqft source, sub-class DESCRIPTION,
 * neighbourhood, appeals, sale history -- is null here, and is null honestly: the statewide
 * file does not carry it. The row's DataSource says so on every row.
 *
 * The headline row is ONE per parcel-year, already resolved by the Foundation's shared rule
 * (see property-search-headline.ts), so there is no client-side precedence pass and no fetch
 * headroom for it any more.
 *
 * 🚨 SAFETY: read-only. Nothing here writes.
 */
import { RunView } from '@memberjunction/core';
import { MergedParcelRow, classifySearchTerm, escapeSqlLiteral, SearchTermKind } from './property-search-agent-context';
import { buildVerifyLink, CI_CLASS_CODE_FILTER } from './property-search-county';
import { EMPTY_APPEAL_LAYERS } from './property-search-appeal-layers';
import { DataSourceIndex, PARCEL_YEAR_HEADLINE_FIELDS, buildHeadlineFields, indexHeadlinesByParcel } from './property-search-headline';

export interface DlgfSearchParams {
  countyNumber: number;
  /** County.Slug, threaded through to buildVerifyLink -- see buildDlgfMergedRows. */
  slug: string;
  assessmentYear: number;
  searchTerm: string;
  /** The 3-digit DLGF class code chosen in the Sub Class filter, or null. */
  propertyClassCode: string | null;
  resultCap: number;
  /** The 29 Data Sources, loaded once by the host dashboard. */
  dataSources: DataSourceIndex;
}

export interface DlgfSearchResult {
  rows: MergedParcelRow[];
  isTruncated: boolean;
}

/**
 * The C&I roster for one county-year, expressed on the headline table: a parcel is in scope when
 * ANY Assessment row for that year carries a C&I class code (the class code lives on Assessment,
 * never on ParcelYearHeadline or Parcel -- Parcel.PropertyClassCode is NULL on every row).
 */
export function buildDlgfHeadlineFilter(
  params: DlgfSearchParams,
  parcelIdConstraint: string[] | null,
  searchTermClassCode?: string | null
): string {
  const classClauses: string[] = [`AssessmentYear = ${params.assessmentYear}`, CI_CLASS_CODE_FILTER];
  if (params.propertyClassCode) classClauses.push(`PropertyClassCode = '${escapeSqlLiteral(params.propertyClassCode)}'`);
  // A free-typed 3-digit code in the search box (classifySearchTerm's 'subClassCode') is a
  // DIFFERENT filters field than the Sub Class dropdown's propertyClassCode above -- without
  // this clause it's classified but never applied, silently ignored (the card path's equivalent
  // is buildCarExtraFilter's own kind === 'subClassCode' branch).
  if (searchTermClassCode) classClauses.push(`PropertyClassCode = '${escapeSqlLiteral(searchTermClassCode)}'`);
  classClauses.push(`ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = ${params.countyNumber})`);

  const clauses: string[] = [
    `AssessmentYear = ${params.assessmentYear}`,
    `ParcelID IN (SELECT ParcelID FROM indiana_tax.vwAssessments WHERE ${classClauses.join(' AND ')})`,
  ];
  if (parcelIdConstraint) {
    // No matching parcel number -> an empty result, never an unfiltered one.
    clauses.push(parcelIdConstraint.length ? `ParcelID IN (${parcelIdConstraint.map((id) => `'${escapeSqlLiteral(id)}'`).join(',')})` : '1=0');
  }
  return clauses.join(' AND ');
}

/** Owner/address free-text search resolves against Parcels first, then narrows the headline query. */
export function buildDlgfParcelSearchFilter(countyNumber: number, term: string, kind: SearchTermKind): string | null {
  const esc = escapeSqlLiteral(term);
  if (kind === 'parcelOrGisNumber') return `CountyNumber = ${countyNumber} AND (ParcelNumber = '${esc}' OR GISParcelNumber = '${esc}')`;
  if (kind === 'freeText') return `CountyNumber = ${countyNumber} AND (OwnerName LIKE '%${esc}%' OR Address LIKE '%${esc}%')`;
  return null; // subClassCode is handled on the headline query's own class subquery
}

/**
 * The class code per parcel for the selected year: the row whose Source matches the headline's
 * own document wins, else the first non-null. Assessment is the only table that carries it.
 */
export function indexClassCodeByParcel(
  classRows: Record<string, unknown>[],
  headlineSourceNameByParcel: ReadonlyMap<string, string | null>
): Map<string, string> {
  const byParcel = new Map<string, string>();
  const matched = new Set<string>();
  for (const a of classRows) {
    const pid = a['ParcelID'] as string;
    const code = (a['PropertyClassCode'] as string) ?? null;
    if (!code || matched.has(pid)) continue;
    if ((a['Source'] as string) === headlineSourceNameByParcel.get(pid)) {
      byParcel.set(pid, code);
      matched.add(pid);
    } else if (!byParcel.has(pid)) {
      byParcel.set(pid, code);
    }
  }
  return byParcel;
}

/** One MergedParcelRow per headline row, top-N by AV. */
export function buildDlgfMergedRows(
  headlineRows: Record<string, unknown>[],
  parcelRows: Record<string, unknown>[],
  classRows: Record<string, unknown>[],
  dataSources: DataSourceIndex,
  countyNumber: number,
  slug: string,
  assessmentYear: number,
  resultCap: number
): DlgfSearchResult {
  const headlineByParcel = indexHeadlinesByParcel(headlineRows);
  const parcelById = new Map<string, Record<string, unknown>>();
  for (const p of parcelRows) parcelById.set(p['ID'] as string, p);
  const sourceNameByParcel = new Map<string, string | null>();
  for (const [pid, h] of headlineByParcel) sourceNameByParcel.set(pid, buildHeadlineFields(h, dataSources, assessmentYear).AssessmentSource);
  const classByParcel = indexClassCodeByParcel(classRows, sourceNameByParcel);

  const rows: MergedParcelRow[] = [];
  for (const [parcelID, h] of headlineByParcel) {
    const p = parcelById.get(parcelID);
    if (!p) continue;
    const classCode = classByParcel.get(parcelID) ?? (p['PropertyClassCode'] as string) ?? null;
    rows.push({
      ID: parcelID,
      ParcelID: parcelID,
      CountyAssessorRecordID: null,
      Address: (p['Address'] as string) ?? null,
      ParcelNumber: (p['ParcelNumber'] as string) ?? null,
      GISParcelNumber: (p['GISParcelNumber'] as string) ?? null,
      OwnerName: (p['OwnerName'] as string) ?? null,
      PropertyClass: classCode,
      // The statewide file carries a 3-digit class code, never the county's sub-class
      // DESCRIPTION -- shown as the code so the column is never silently blank.
      PropertySubClassDescription: classCode,
      EstimatedSqFt: null,
      EstimatedSqFtExGarage: null,
      SqFtSource: null,
      Acreage: (p['Acreage'] as number) ?? null,
      ComparisonUnitType: null,
      ComparisonUnitCount: null,
      YearBuilt: null,
      CoStarYearBuilt: null,
      CoStarRBA: null,
      ...buildHeadlineFields(h, dataSources, assessmentYear),
      VerifyURL: buildVerifyLink({
        countyNumber,
        slug,
        parcelNumber: (p['ParcelNumber'] as string) ?? null,
        gisParcelNumber: (p['GISParcelNumber'] as string) ?? null,
        assessmentYear,
      }).url,
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

/** Takes the RunView instance so the component keeps no query code of its own. */
export async function fetchDlgfParcelRows(rv: RunView, params: DlgfSearchParams): Promise<DlgfSearchResult> {
  const term = params.searchTerm.trim();
  const kind = term ? classifySearchTerm(term) : null;

  // A parcel-number or owner/address search resolves against Parcels FIRST -- the headline
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

  const headlineResult = await rv.RunView<Record<string, unknown>>({
    EntityName: 'Parcel Year Headlines',
    Fields: [...PARCEL_YEAR_HEADLINE_FIELDS],
    ExtraFilter: buildDlgfHeadlineFilter(params, parcelIdConstraint, searchTermClassCode),
    OrderBy: 'HeadlineTotalAV DESC',
    // ONE row per parcel-year (UQ_ParcelYearHeadline), already precedence-resolved, so the cap
    // is the cap: the top `resultCap` parcels by headline AV, matching the card path's own
    // RESULT_CAP-row cap (enforced there by MaxRows on the CountyAssessorRecord query).
    MaxRows: params.resultCap,
    ResultType: 'simple',
  });
  if (!headlineResult.Success || !headlineResult.Results?.length) return { rows: [], isTruncated: false };

  const parcelIds = headlineResult.Results.map((h) => h['ParcelID'] as string);
  const parcelIdList = parcelIds.map((id) => `'${escapeSqlLiteral(id)}'`).join(',');

  const [parcelResult, classResult] = await rv.RunViews<Record<string, unknown>>([
    {
      EntityName: 'Parcels',
      Fields: ['ID', 'ParcelNumber', 'GISParcelNumber', 'Address', 'OwnerName', 'Acreage', 'PropertyClassCode', 'TaxDistrictCode', 'Latitude', 'Longitude', 'BoundaryGeoJSON'],
      ExtraFilter: `ID IN (${parcelIdList})`,
      // One row per id in a list that is itself bounded to resultCap (see above).
      MaxRows: params.resultCap,
      ResultType: 'simple',
    },
    {
      // The class code only: it lives on Assessment (one row per source per parcel-year, so
      // up to ~3 rows per parcel), never on the headline or the parcel.
      EntityName: 'Assessments',
      Fields: ['ParcelID', 'Source', 'PropertyClassCode'],
      ExtraFilter: `ParcelID IN (${parcelIdList}) AND AssessmentYear = ${params.assessmentYear}`,
      MaxRows: params.resultCap * 4,
      ResultType: 'simple',
    },
  ]);

  const merged = buildDlgfMergedRows(
    headlineResult.Results,
    parcelResult.Success ? (parcelResult.Results ?? []) : [],
    classResult.Success ? (classResult.Results ?? []) : [],
    params.dataSources,
    params.countyNumber,
    params.slug,
    params.assessmentYear,
    params.resultCap
  );
  // A full page of headline rows means more parcels may exist beyond the cap -- the same
  // convention the card path uses (carResult.Results.length >= RESULT_CAP).
  return { rows: merged.rows, isTruncated: headlineResult.Results.length >= params.resultCap };
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
