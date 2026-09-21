/**
 * @fileoverview Pure, framework-agnostic context/resolver helpers for the
 * Property Search dashboard's AI-agent integration. Kept separate from the
 * component so the logic is directly unit-testable without Angular.
 *
 * 🚨 SAFETY BOUNDARY: this dashboard is a read-only browse/search/filter
 * surface over indiana_tax.Parcel / indiana_tax.CountyAssessorRecord. No tool
 * here writes to the database — search/filter tools only change what's
 * QUERIED and displayed; OpenParcelRecord opens a record for VIEWING only.
 */
import { MARION_COUNTY_NUMBER, ParcelDataSource, CountySourceTier, pickAssessmentRow } from './property-search-county';
// Type-only: property-search-appeal-layers.ts imports escapeSqlLiteral from THIS file, so a
// value import back here would be a cycle -- `import type` is erased at compile time and never
// executes, so it can't participate in a runtime cycle.
import type { AppealLayerFields } from './property-search-appeal-layers';

/** A single merged parcel row (CountyAssessorRecord fields + joined Parcel geometry/identity fields). */
export interface MergedParcelRow extends AppealLayerFields {
  // Index signature so this satisfies <mj-map-view>'s [Records]: Record<string, unknown>[] input.
  [key: string]: unknown;
  // The Parcel's own ID -- deliberately what <mj-map-view> keys markers by,
  // since [Entity] is Parcels. NOT the same as CountyAssessorRecordID below --
  // conflating the two was a real bug (opened the wrong entity's record).
  ID: string;
  ParcelID: string;
  // CountyAssessorRecord's own primary key -- required separately from ID/
  // ParcelID (both of which are the Parcel's ID) for anything that opens the
  // County Assessor Records entity specifically, e.g. openParcelRecord().
  // NULL for a DLGF-only county, which has no CountyAssessorRecord row at
  // all. Callers that open a record must branch on it.
  CountyAssessorRecordID: string | null;
  Address: string | null;
  ParcelNumber: string | null;
  GISParcelNumber: string | null;
  OwnerName: string | null;
  PropertyClass: string | null;
  PropertySubClassDescription: string | null;
  EstimatedSqFt: number | null;
  // EstimatedSqFt with structured parking removed -- the sum of TotalSqFt over
  // this parcel's CountyAssessorImprovementSegment rows whose [Use] is
  // 'Parking' / 'Pkg Garage' / 'Com Garage' (the county codes parking decks as
  // a building floor/use-segment, so EstimatedSqFt includes them; detached
  // garages/canopies are separate CountyAssessorImprovement rows and were
  // never in EstimatedSqFt). Equals EstimatedSqFt when the parcel has no such
  // segment (~546 of ~10.1k Marion C&I parcels do). This is the denominator
  // the rest of the tool's $/SF valuation math uses (ParcelPhysicalProfile.
  // BuildingSqFtExParking) -- reconciles exactly, 0 mismatches across all 546.
  EstimatedSqFtExGarage: number | null;
  SqFtSource: string | null;
  // Vacant-land acreage (CountyAssessorRecord.Acreage, parsed from its
  // NVARCHAR(10) storage) and the generic apartment-unit/hotel-key/nursing-
  // bed/storage-door count -- both feed the unit-of-comparison toggle in the
  // result-set analytics panel (denominatorFor()/ComparisonUnit below).
  // ComparisonUnitType/Count come exclusively from a CoStar-property-data
  // backfill (see migration V202608252036 and
  // backfill-costar-derived-fields.js) -- never from PRC parsing.
  Acreage: number | null;
  ComparisonUnitType: string | null;
  ComparisonUnitCount: number | null;
  // Year built -- YearBuilt is our own, sourced from the Tax History Report
  // parser; CoStarYearBuilt is a same-provenance-discipline fallback (see
  // migration V202608252206) populated ONLY when YearBuilt is null and a
  // single unambiguous CoStar value exists. Kept as two distinct fields
  // (never merged into one at the data layer) -- the grid blends them for
  // DISPLAY only (see the "Year Built" column's valueGetter).
  YearBuilt: number | null;
  CoStarYearBuilt: number | null;
  // Rentable Building Area -- a DIFFERENT physical measurement than
  // EstimatedSqFt (total building SF), not just a different source for the
  // same number. See migration V202608272230.
  CoStarRBA: number | null;
  // Assessed values AS OF AssessmentYear (below) -- sourced from
  // indiana_tax.Assessment via pickAssessmentRow's per-county precedence
  // (the selected county's own card source, e.g. LakePRC/MarionPRC/
  // StJosephPRC, beats a FOIA list, which beats the DLGF statewide fallback),
  // NOT CountyAssessorRecord's own undifferentiated snapshot.
  // Null (not a stale substitute) when no Assessment row exists for this
  // parcel at the selected year -- most commonly 2024, which currently has
  // no statewide fallback and only exists for already-PRC-fetched parcels.
  AssessedLandAV: number | null;
  AssessedImprovementAV: number | null;
  AssessedTotalAV: number | null;
  AssessmentYear: number | null;
  AssessmentSource: string | null;
  /** Which source the AV on this row actually came from, in words (spec §6: "every merged row carries a DataSource value"). */
  DataSource: ParcelDataSource;
  /** The route to the county's own record card for this parcel, from buildVerifyLink(...).url -- null when none can be built (see the Verify column's "not on file" cell). */
  VerifyURL: string | null;
  // Sourced from indiana_tax.TaxHistoryYear at TaxYear = AssessmentYear (the
  // two year fields are confirmed 1:1 aligned, not off-by-one) -- NOT
  // CountyAssessorRecord's own current-year-only snapshot, so these track the
  // year selector the same way AssessedTotalAV does. Null when no
  // TaxHistoryYear row exists for this parcel at the selected year (a parcel
  // not yet Tax-History-fetched, or a year the report hasn't covered yet,
  // e.g. the newest year before that cycle's report is issued).
  TotalTax: number | null;
  TaxRate: number | null;
  // The assessed value AFTER a PTABOA appeal decision, for the SELECTED
  // AssessmentYear -- sourced from indiana_tax.PTABOAAppeal.AfterTotalAV
  // (the latest-hearing-dated appeal for this parcel+year when more than one
  // exists), NOT indiana_tax.Assessment.PTABOATotalAV -- confirmed
  // 2026-08-25 that column is only ever populated for 2025/2026 statewide-
  // source rows, so it would show "no data" for a perfectly real,
  // user-selectable appeal year like 2024. Null means no appeal was decided
  // for this parcel in the selected year, not a data gap.
  PTABOAValue: number | null;
  // The hearing date of the SAME appeal PTABOAValue came from -- both are
  // read from one row, so they always describe one appeal, never a value
  // from one hearing paired with a date from another.
  PTABOADate: string | null;
  // The Indiana form this same appeal was filed under -- "130S" (subjective/
  // market-value, the most directly informative type for assessed-value
  // accuracy), "130O" (objective/mathematical error), or "136"/"136C"
  // (charitable/nonprofit Exemption -- NOT a valuation dispute; see the
  // PTABOAAppeal migration comment on why this distinction matters).
  PTABOAAppealType: string | null;
  // Most recent row from indiana_tax.CountyAssessorSaleHistory for this
  // parcel's CountyAssessorRecord, by SaleDate DESC then SaleAmount DESC (the
  // amount tiebreak matters -- a real parcel has two same-day sale rows, a
  // genuine $60.25M sale and a same-day $0 corrective/"Straight" deed; date
  // alone would pick either arbitrarily). Null when this parcel has no
  // recorded sale at all (most commonly: not yet PRC-fetched).
  LastSaleDate: string | null;
  LastSalePrice: number | null;
  LastSaleIsValid: boolean | null;
  Neighborhood: string | null;
  TaxDistrictID: string | null;
  Latitude: number | null;
  Longitude: number | null;
  BoundaryGeoJSON: string | null;
}

export interface PropertySearchFilters {
  /** Which county's parcels are searched. Defaults to Marion, so the pre-county-filter behaviour is unchanged (spec §6). */
  countyNumber: number;
  searchTerm: string;
  // Single-select, not multi -- there are 80 distinct PropertySubClassDescription
  // values in the live data (confirmed 2026-08-24), far too many for a chip
  // row; a searchable dropdown one-at-a-time is the workable UI at this scale.
  // null = no sub-class filter applied.
  propertySubClass: string | null;
  sqFtMin: number | null;
  sqFtMax: number | null;
  // Which year's Assessment figures to display -- does NOT change which
  // parcels qualify (candidate selection/ranking stays on
  // CountyAssessorRecord's own current AssessedTotalAV), only which year's
  // Land/Improvement/Total AV populate the row. Always set (not nullable) --
  // defaults to the most recent year found in AvailableAssessmentYears.
  assessmentYear: number;
}

/** Fallback default before AvailableAssessmentYears loads -- overwritten by loadAssessmentYearsIfNeeded() on init. */
export const FALLBACK_ASSESSMENT_YEAR = 2026;

export const DEFAULT_PROPERTY_SEARCH_FILTERS: PropertySearchFilters = {
  countyNumber: MARION_COUNTY_NUMBER,
  searchTerm: '',
  propertySubClass: null,
  sqFtMin: null,
  sqFtMax: null,
  assessmentYear: FALLBACK_ASSESSMENT_YEAR,
};

/**
 * Filters that must be cleared on a county switch: propertySubClass and the sqft range are
 * scoped to the PRIOR county's own dropdown values/units (a Marion sub-class name, or a sqft
 * range meaningful for Marion's building stock, silently becomes a zero-row filter against
 * another county's data) -- see property-search-dashboard.component.ts's onCountyChange. The
 * search term is NOT reset -- the user set it deliberately and it may still apply (e.g. an
 * owner name search spanning counties); assessmentYear is reset separately once the new
 * county's own year list loads (loadAssessmentYearsIfNeeded).
 */
export function resetFiltersForCountyChange(filters: PropertySearchFilters, countyNumber: number): PropertySearchFilters {
  return { ...filters, countyNumber, propertySubClass: null, sqFtMin: null, sqFtMax: null };
}

/**
 * Result cap shared by both map render modes — see
 * property-search-dashboard.component.ts header comment for the reasoning.
 * Raised from 750 to 2000 on 2026-08-24 (untested-but-reasoned increase, not
 * a measured ceiling — `boundary` mode's unclustered-polygon rendering is the
 * real constraint here, not List view or Export, which both scale much
 * higher without issue). Revisit if boundary mode feels sluggish at this size.
 */
export const PROPERTY_SEARCH_RESULT_CAP = 2000;

export interface PropertySearchAgentContextInput {
  filters: PropertySearchFilters;
  rows: MergedParcelRow[];
  totalMatchingCount: number | null;
  isTruncated: boolean;
  viewMode: 'map' | 'list' | 'analytics';
  renderMode: 'point' | 'boundary';
  visibleColumns: string[];
  selectedParcelAddress: string | null;
  isLoading: boolean;
  countyName: string | null;
  countySourceTier: CountySourceTier;
  hasDlgfRows: boolean;
}

/** Builds the ~18-field context object published via NavigationService.SetAgentContext. */
export function buildPropertySearchAgentContext(input: PropertySearchAgentContextInput): Record<string, unknown> {
  const stats = computePropertySearchSummaryStats(input.rows);
  return {
    CountyNumber: input.filters.countyNumber,
    CountyName: input.countyName,
    CountySourceTier: input.countySourceTier,
    HasDlgfRows: input.hasDlgfRows,
    SearchTerm: input.filters.searchTerm || null,
    SubClassFilter: input.filters.propertySubClass,
    SqFtMin: input.filters.sqFtMin,
    SqFtMax: input.filters.sqFtMax,
    AssessmentYear: input.filters.assessmentYear,
    VisibleColumns: input.visibleColumns,
    ResultCount: stats.count,
    TotalMatchingCount: input.totalMatchingCount,
    IsTruncated: input.isTruncated,
    ResultCap: PROPERTY_SEARCH_RESULT_CAP,
    TotalAssessedValue: stats.totalAssessedValue,
    AvgPricePerSqFt: stats.avgPricePerSqFt,
    VerifiedSqFtSampleSize: stats.verifiedSqFtSampleSize,
    ViewMode: input.viewMode,
    RenderMode: input.renderMode,
    SelectedParcelAddress: input.selectedParcelAddress,
    IsLoading: input.isLoading,
  };
}

/**
 * Heuristically classifies a free-form search term the way a CoStar/Zillow-style
 * search box does — the user doesn't pre-select "search by parcel number," they
 * just type, so this fans the term out across the right field(s).
 */
export type SearchTermKind = 'parcelOrGisNumber' | 'subClassCode' | 'freeText';

export function classifySearchTerm(term: string): SearchTermKind {
  const trimmed = term.trim();
  if (/^\d{7}$/.test(trimmed) || /^\d{17,18}$/.test(trimmed)) return 'parcelOrGisNumber';
  if (/^\d{3}$/.test(trimmed)) return 'subClassCode';
  return 'freeText';
}

/** Escapes single quotes for safe inclusion in a RunView ExtraFilter string literal. */
export function escapeSqlLiteral(value: string): string {
  return value.replace(/'/g, "''");
}

/** $/SF for one row — AssessedTotalAV (already the selected-year value) / EstimatedSqFt. Null when either input is missing/unusable. Shared by the grid's $/SF column and Export's synthetic column. */
export function pricePerSqFt(row: MergedParcelRow): number | null {
  if (row.AssessedTotalAV == null || !row.EstimatedSqFt || row.EstimatedSqFt <= 0) return null;
  return row.AssessedTotalAV / row.EstimatedSqFt;
}

/** One year's row in the detail panel's multi-year Value Trend / Tax Liability Trend tables — sourced from indiana_tax.TaxHistoryYear. */
export interface AssessmentTrendRow {
  taxYear: number;
  landAssessment: number | null;
  improvements: number | null;
  /** Land + Improvements before deductions/exemptions -- matches AssessedTotalAV's own "Total" semantics in the single-year section above this table, not NetAssessment (which is post-deduction). */
  grossAssessment: number | null;
  netAnnualTax: number | null;
  taxRate: number | null;
}

/** How many trailing years the detail panel's trend tables can show -- a UI-local toggle, not persisted (matches ActiveViewMode/ActiveRenderMode precedent: a viewing preference, not a durable setting). */
export type TrendYearsOption = 5 | 10;
export const DEFAULT_TREND_YEARS: TrendYearsOption = 5;
/** Upper bound fetched per parcel regardless of the toggle -- fetching once at the max and slicing client-side means toggling 5↔10 never re-queries. Comfortably covers every year on file (Marion's Tax History Report goes back to 2000, ~26 years including the duplicate-2007 row). */
export const TREND_FETCH_MAX_YEARS = 30;

/**
 * Dedupes one parcel's raw Tax History Years rows down to one row per
 * TaxYear, then returns the most recent `yearsRequested` of them, newest
 * first. The real 2007 Marion County reassessment-cycle transition produces
 * two rows for TaxYear=2007 at different ColumnOrdinal values (zeroed AV/rate
 * vs. real figures -- see the TaxHistoryYear migration comment) -- the higher
 * ColumnOrdinal is consistently the real-data row across every document
 * checked, so it wins the tie. Same rule as the year-selector merge in
 * runSearchInternal(), reimplemented here (not shared) because that one dedups
 * across MANY parcels at a SINGLE year, while this dedups ONE parcel across
 * MANY years -- different enough shapes that sharing one function would need
 * an awkward key-by parameter for no real reuse benefit.
 */
export function buildAssessmentTrendRows(rawRows: Record<string, unknown>[], yearsRequested: number): AssessmentTrendRow[] {
  const byYear = new Map<number, Record<string, unknown>>();
  for (const r of rawRows) {
    const year = r['TaxYear'] as number;
    const existing = byYear.get(year);
    if (!existing || (r['ColumnOrdinal'] as number) > (existing['ColumnOrdinal'] as number)) {
      byYear.set(year, r);
    }
  }
  return Array.from(byYear.values())
    .sort((a, b) => (b['TaxYear'] as number) - (a['TaxYear'] as number))
    .slice(0, yearsRequested)
    .map((r) => ({
      taxYear: r['TaxYear'] as number,
      landAssessment: (r['LandAssessment'] as number) ?? null,
      improvements: (r['Improvements'] as number) ?? null,
      grossAssessment: (r['GrossAssessment'] as number) ?? null,
      netAnnualTax: (r['NetAnnualTax'] as number) ?? null,
      taxRate: (r['TaxRate'] as number) ?? null,
    }));
}

/** One row in the detail panel's Appeal History section — sourced from indiana_tax.PTABOAAppeal. */
export interface AppealHistoryRow {
  assessmentYear: number | null;
  hearingDate: string | null;
  decisionStatus: string | null;
  caseNumber: string | null;
  /** Who represented the taxpayer, when listed on the PTABOA agenda (law firm, tax-advocate firm, or an individual). Null means self-represented, not a data gap — see the PTABOAAppeal migration comment. */
  taxRepresentative: string | null;
  circumstances: string | null;
  beforeLandAV: number | null;
  beforeImprovementAV: number | null;
  beforeTotalAV: number | null;
  afterLandAV: number | null;
  afterImprovementAV: number | null;
  afterTotalAV: number | null;
  // Whether this appeal's agenda-reported outcome has actually been ratified
  // by a real Form 115 Final Determination -- see migration V202608251908
  // and match-ptaboa-final-determinations.js. NOT NULL/present means
  // confirmed; finalDeterminationTotalAV is the ratified figure, which can
  // genuinely differ from afterTotalAV above (the agenda's own prediction) --
  // that mismatch is the rare, real case this whole confirmation mechanism
  // exists to catch (56 found across the full historical run as of
  // 2026-08-27). A case can sit unconfirmed for a long time -- the concrete
  // example that started this investigation, 49-101-24-0-4-00083, is STILL
  // unconfirmed over a year after its agenda "Final Agreement" label.
  finalDeterminationTotalAV: number | null;
}

/** 'confirmed' when the ratified Final Determination matches the agenda's own predicted afterTotalAV; 'revised' when it genuinely differs (the rare, real case this mechanism exists to catch); 'pending' when no Final Determination has been matched yet. */
export type AppealConfirmationStatus = 'confirmed' | 'revised' | 'pending';

export function appealConfirmationStatus(row: AppealHistoryRow): AppealConfirmationStatus {
  if (row.finalDeterminationTotalAV == null) return 'pending';
  if (row.afterTotalAV != null && Math.round(row.afterTotalAV) !== Math.round(row.finalDeterminationTotalAV)) return 'revised';
  return 'confirmed';
}

/** This appeal's AV change (After − Before) — negative means a reduction. Null when either side is missing. Computed rather than stored (see the PTABOAAppeal migration comment on why Change isn't a persisted column). */
export function appealAVChange(row: AppealHistoryRow): number | null {
  if (row.beforeTotalAV == null || row.afterTotalAV == null) return null;
  return row.afterTotalAV - row.beforeTotalAV;
}

/** This appeal's AV change as a percentage of the Before value — negative means a reduction. Null when Before is missing or zero (can't express a meaningful percentage off a $0 base). */
export function appealAVChangePct(row: AppealHistoryRow): number | null {
  const change = appealAVChange(row);
  if (change == null || !row.beforeTotalAV) return null;
  return (change / row.beforeTotalAV) * 100;
}

/** Sorts a parcel's raw PTABOAAppeal rows most-recent-first (AssessmentYear DESC, HearingDate DESC as a tiebreak within the same year). */
export function buildAppealHistoryRows(rawRows: Record<string, unknown>[]): AppealHistoryRow[] {
  return [...rawRows]
    .sort((a, b) => {
      const yearDiff = ((b['AssessmentYear'] as number) ?? 0) - ((a['AssessmentYear'] as number) ?? 0);
      if (yearDiff !== 0) return yearDiff;
      const aDate = (a['HearingDate'] as string) ?? '';
      const bDate = (b['HearingDate'] as string) ?? '';
      return bDate.localeCompare(aDate);
    })
    .map((r) => ({
      assessmentYear: (r['AssessmentYear'] as number) ?? null,
      hearingDate: (r['HearingDate'] as string) ?? null,
      decisionStatus: (r['DecisionStatus'] as string) ?? null,
      caseNumber: (r['CaseNumber'] as string) ?? null,
      taxRepresentative: (r['TaxRepresentative'] as string) ?? null,
      circumstances: (r['Circumstances'] as string) ?? null,
      beforeLandAV: (r['BeforeLandAV'] as number) ?? null,
      beforeImprovementAV: (r['BeforeImprovementAV'] as number) ?? null,
      beforeTotalAV: (r['BeforeTotalAV'] as number) ?? null,
      afterLandAV: (r['AfterLandAV'] as number) ?? null,
      afterImprovementAV: (r['AfterImprovementAV'] as number) ?? null,
      afterTotalAV: (r['AfterTotalAV'] as number) ?? null,
      finalDeterminationTotalAV: (r['FinalDeterminationTotalAV'] as number) ?? null,
    }));
}

/**
 * One CoStar property matched to the selected parcel — sourced from
 * indiana_tax.CoStarProperty (see migration V202608252109). A parcel can
 * have MORE than one of these (confirmed live: 130 Marion parcels are
 * matched by more than one CoStarProperty row, including genuinely
 * mixed-use buildings like "220 N Meridian St" -- an office listing AND a
 * separate 250-unit apartment listing on the same parcel) -- the detail
 * panel shows each one, it never merges/picks one.
 */
export interface CoStarPropertyRow {
  costarPropertyID: number | null;
  propertyName: string | null;
  propertyType: string | null;
  numberOfUnits: number | null;
  rooms: number | null;
  rba: number | null;
  buildingClass: string | null;
  starRating: number | null;
  lastSalePrice: number | null;
  lastSaleDate: string | null;
  /** True if THIS CoStar listing itself spans multiple parcels (the selected parcel is only one of them) -- see the CoStarProperty migration for why a whole-complex Unit/Room count on one such parcel would be misleading. */
  isMultiParcel: boolean;
  sourceExportFile: string | null;
}

/** Pass-through mapper for the selected parcel's CoStarProperty matches (fetched via `ParcelID = @p OR CoStarSecondaryParcelID = @p`) -- no sorting/dedup needed, this project's own investigation confirmed multiple real rows per parcel are a genuine, honest thing to show, not noise to collapse. */
export function buildCoStarPropertyRows(rawRows: Record<string, unknown>[]): CoStarPropertyRow[] {
  return rawRows.map((r) => ({
    costarPropertyID: (r['CoStarPropertyID'] as number) ?? null,
    propertyName: (r['CoStarPropertyName'] as string) ?? null,
    propertyType: (r['CoStarPropertyType'] as string) ?? null,
    numberOfUnits: (r['CoStarNumberOfUnits'] as number) ?? null,
    rooms: (r['CoStarRooms'] as number) ?? null,
    rba: (r['CoStarRBA'] as number) ?? null,
    buildingClass: (r['CoStarBuildingClass'] as string) ?? null,
    starRating: (r['CoStarStarRating'] as number) ?? null,
    lastSalePrice: (r['CoStarLastSalePrice'] as number) ?? null,
    lastSaleDate: (r['CoStarLastSaleDate'] as string) ?? null,
    isMultiParcel: (r['CoStarIsMultiParcel'] as boolean) ?? false,
    sourceExportFile: (r['SourceExportFile'] as string) ?? null,
  }));
}

/**
 * Semantic variant for the Appeal History status chip -- a defensible 3-bucket
 * grouping of the real DecisionStatus values on file (confirmed 2026-08-26:
 * 'Final Agreement', 'Withdrawn', 'Exemption-Approved', 'Exemption-AppPartial',
 * 'Recommended', 'Exemption-Denied', 'Not Assigned', 'PTABOA Tabled',
 * 'PTABOA Scheduled', plus a small number of null/malformed values). Not a
 * claim that every bucket is precisely "good/bad" -- 'Recommended' and
 * 'Withdrawn' in particular can mean different things case to case -- just
 * the least-wrong default coloring until a real outcome taxonomy exists.
 */
export function appealStatusVariant(status: string | null): 'success' | 'warning' | 'default' {
  if (!status) return 'default';
  if (/Denied/i.test(status)) return 'warning';
  if (/Final Agreement|Exemption-Approved|Exemption-AppPartial/i.test(status)) return 'success';
  return 'default';
}

/** Shared currency formatter — used by the detail panel and the results summary stats. */
export function formatCurrency(value: number | null): string {
  if (value == null) return '—';
  return value.toLocaleString('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 });
}

/** Sub-classes of SqFtSource considered reliable enough to feed an aggregate $/sqft stat -- excludes NULL/unverified, which may reflect land area rather than building size (see the SqFtSource confidence badge in the detail panel). */
export const RELIABLE_SQFT_SOURCES = new Set(['PropertyRecordCard', 'BuildingDetail']);

export interface PropertySearchSummaryStats {
  count: number;
  totalAssessedValue: number;
  /** Blended sum(AV)/sum(SqFt) over verified-sqft rows only -- not an average of each row's own ratio, which would let small-sqft parcels disproportionately skew the result. Null if no row in the current result set has a reliable SqFtSource. */
  avgPricePerSqFt: number | null;
  /** How many of `count` rows contributed to avgPricePerSqFt -- shown alongside the stat so "verified sqft only" isn't a silent asterisk. */
  verifiedSqFtSampleSize: number;
}

/** Computes the [meta]-slot summary stats for the current result set, client-side over the already-loaded MergedResults array (no extra query -- these are simple sums over data already in memory). */
export function computePropertySearchSummaryStats(rows: MergedParcelRow[]): PropertySearchSummaryStats {
  let totalAssessedValue = 0;
  let reliableAvSum = 0;
  let reliableSqFtSum = 0;
  let verifiedSqFtSampleSize = 0;

  for (const row of rows) {
    if (row.AssessedTotalAV != null) totalAssessedValue += row.AssessedTotalAV;
    if (row.SqFtSource && RELIABLE_SQFT_SOURCES.has(row.SqFtSource) && row.EstimatedSqFt && row.EstimatedSqFt > 0 && row.AssessedTotalAV != null) {
      reliableAvSum += row.AssessedTotalAV;
      reliableSqFtSum += row.EstimatedSqFt;
      verifiedSqFtSampleSize++;
    }
  }

  return {
    count: rows.length,
    totalAssessedValue,
    avgPricePerSqFt: reliableSqFtSum > 0 ? reliableAvSum / reliableSqFtSum : null,
    verifiedSqFtSampleSize,
  };
}

// ───────────────────── Result-Set Analytics Panel ─────────────────────
//
// A collapsible Avg/Median/Min/Max breakdown over the CURRENT filtered
// result set (unlike Sub Class Analytics above, which is a global,
// filter-independent DB rollup). $/SF is the right comparison unit for
// retail/office/industrial, but wrong for multifamily (per-unit),
// hospitality (per-key/room), nursing/hospital (per-bed), self-storage
// (per-door), and vacant land (per-acre) -- ComparisonUnit lets the panel
// switch its whole denominator. See migration V202608252036 and
// backfill-costar-derived-fields.js: Unit/Key are populated via a CoStar-
// property-data backfill (948 Marion parcels as of 2026-08-25); Bed/Door
// have no CoStar-matched source data yet; Acres (CountyAssessorRecord.
// Acreage) has always had real data for vacant land.

export type ComparisonUnit = 'sqft' | 'acre' | 'unit' | 'key' | 'bed' | 'door';

/** Display label for the raw size/count row and for "$/{unit}" ratio labels. */
export const COMPARISON_UNIT_LABELS: Record<ComparisonUnit, string> = {
  sqft: 'Sq Ft',
  acre: 'Acre',
  unit: 'Unit',
  key: 'Key',
  bed: 'Bed',
  door: 'Door',
};

/** Pluralized labels for CountyAssessorRecord.ComparisonUnitType's own value set (a DB CHECK-constrained string, not the ComparisonUnit union above -- 'sqft'/'acre' aren't valid ComparisonUnitType values, they're sourced from their own dedicated columns) -- used by the grid's Units/Rooms column, distinct from COMPARISON_UNIT_LABELS' singular "$/{unit}" labels. */
const COMPARISON_UNIT_TYPE_PLURAL_LABELS: Record<string, string> = {
  Unit: 'Units',
  Key: 'Keys',
  Bed: 'Beds',
  Door: 'Doors',
};

/** "250 Units" / "186 Keys" for the grid's Units/Rooms column -- null (not "0 Units") when this parcel has no backfilled comparison-unit data, which is most parcels (see migration V202608252036). */
export function formatComparisonUnitCount(type: string | null, count: number | null): string | null {
  if (!type || count == null) return null;
  const label = COMPARISON_UNIT_TYPE_PLURAL_LABELS[type] ?? type;
  return `${count.toLocaleString('en-US')} ${label}`;
}

/**
 * "1998" when the parcel's own YearBuilt (Tax History Report-sourced) is
 * present; "2005 (CoStar)" when only the CoStarYearBuilt fallback is (see
 * migration V202608252206) -- the "(CoStar)" suffix matters here specifically
 * per this project's provenance-characterization rule, since this is a
 * display-layer blend of two distinct-provenance columns, not a single-
 * source field. Null when neither is populated.
 */
export function formatYearBuilt(yearBuilt: number | null, coStarYearBuilt: number | null): string | null {
  if (yearBuilt != null) return `${yearBuilt}`;
  if (coStarYearBuilt != null) return `${coStarYearBuilt} (CoStar)`;
  return null;
}

// ───────────── List-view $-per-unit-of-comparison columns ─────────────
//
// Every $ figure (Assessed Value, PTABOA Value, Sale Price) comparable per
// every unit of comparison (County SF, CoStar RBA, CoStar Units, CoStar
// Keys) as SEPARATE, always-available, independently-sortable grid columns
// -- not a single toggle switching one shared unit (that's the Analytics
// panel's own, different job: aggregate stats over the whole result set).
// Generated from these two small arrays (RATIO_METRIC_DEFS x
// UNIT_OF_COMPARISON_DEFS) in property-search-grid.component.ts rather than
// hand-written as 12 near-identical column blocks -- adding a unit (e.g. a
// real "Rentable" source distinct from CoStar's RBA, should one ever exist)
// or a metric later is one new array entry, not four new hand-copied
// columns.

/** One unit of comparison a $ figure can be divided by. RBA (CoStar) is Rentable Building Area -- a DIFFERENT physical measurement than SF (County) (total building SF), not just a different source for the same number -- confirmed with the user 2026-08-27. */
export interface UnitOfComparisonDef {
  key: string;
  label: string;
  denominator: (row: MergedParcelRow) => number | null;
}

export const UNIT_OF_COMPARISON_DEFS: UnitOfComparisonDef[] = [
  { key: 'SFCounty', label: 'SF (County)', denominator: (r) => (r.EstimatedSqFt && r.EstimatedSqFt > 0 ? r.EstimatedSqFt : null) },
  { key: 'SFCountyXG', label: 'SF (County XG)', denominator: (r) => (r.EstimatedSqFtExGarage && r.EstimatedSqFtExGarage > 0 ? r.EstimatedSqFtExGarage : null) },
  { key: 'RBACoStar', label: 'RBA (CoStar)', denominator: (r) => (r.CoStarRBA && r.CoStarRBA > 0 ? r.CoStarRBA : null) },
  { key: 'UnitCoStar', label: 'Unit (CoStar)', denominator: (r) => (r.ComparisonUnitType === 'Unit' && r.ComparisonUnitCount ? r.ComparisonUnitCount : null) },
  { key: 'KeyCoStar', label: 'Key (CoStar)', denominator: (r) => (r.ComparisonUnitType === 'Key' && r.ComparisonUnitCount ? r.ComparisonUnitCount : null) },
];

/** One $ figure that can be divided by a unit of comparison above. shortLabel keeps generated grid headers compact (e.g. "$/RBA (CoStar)" rather than "Assessed Value/RBA (CoStar)"); the popover checkbox list uses the fuller name instead (built in property-search-grid.component.ts). */
export interface RatioMetricDef {
  key: string;
  shortLabel: string;
  fullLabel: string;
  numerator: (row: MergedParcelRow) => number | null;
}

export const RATIO_METRIC_DEFS: RatioMetricDef[] = [
  { key: 'AssessedValue', shortLabel: '$', fullLabel: 'Assessed Value', numerator: (r) => r.AssessedTotalAV },
  { key: 'PTABOAValue', shortLabel: 'PTABOA', fullLabel: 'PTABOA Value', numerator: (r) => r.PTABOAValue },
  { key: 'SalePrice', shortLabel: 'Sale', fullLabel: 'Sale Price', numerator: (r) => r.LastSalePrice },
];

/** Maps a ComparisonUnit to the CountyAssessorRecord.ComparisonUnitType value it corresponds to -- null for 'sqft'/'acre', which are sourced from their own dedicated columns instead. */
const COMPARISON_UNIT_TO_DB_TYPE: Record<ComparisonUnit, string | null> = {
  sqft: null,
  acre: null,
  unit: 'Unit',
  key: 'Key',
  bed: 'Bed',
  door: 'Door',
};

/**
 * Resolves the denominator a row should be divided by for the given unit, or
 * null if this row doesn't have a usable one -- callers must skip the row
 * for that unit's stats rather than divide by null/0. 'unit'/'key'/'bed'/
 * 'door' only resolve when ComparisonUnitType actually matches (an
 * apartment's count should never divide a hotel's AV even if both happened
 * to be non-null).
 */
export function denominatorFor(row: MergedParcelRow, unit: ComparisonUnit): number | null {
  if (unit === 'sqft') {
    if (!row.SqFtSource || !RELIABLE_SQFT_SOURCES.has(row.SqFtSource)) return null;
    return row.EstimatedSqFt && row.EstimatedSqFt > 0 ? row.EstimatedSqFt : null;
  }
  if (unit === 'acre') {
    return row.Acreage && row.Acreage > 0 ? row.Acreage : null;
  }
  const dbType = COMPARISON_UNIT_TO_DB_TYPE[unit];
  if (row.ComparisonUnitType !== dbType) return null;
  return row.ComparisonUnitCount && row.ComparisonUnitCount > 0 ? row.ComparisonUnitCount : null;
}

/** Which units have at least one row with a usable denominator in the current result set -- drives which toggle options render. 'sqft' is always included first when any row has one, matching the panel's default. */
export function availableComparisonUnits(rows: MergedParcelRow[]): ComparisonUnit[] {
  const allUnits: ComparisonUnit[] = ['sqft', 'acre', 'unit', 'key', 'bed', 'door'];
  return allUnits.filter((unit) => rows.some((row) => denominatorFor(row, unit) != null));
}

/** Standard sorted-array median. Returns 0 for an empty array (callers gate on sampleSize > 0 before displaying). */
export function median(values: number[]): number {
  if (!values.length) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0 ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid];
}

export interface MetricStats {
  avg: number;
  median: number;
  min: number;
  max: number;
  /** How many of the result set's rows contributed -- a distinct count per metric, not one shared figure, since e.g. Sale Price will have a much smaller N than AV. */
  sampleSize: number;
}

/** Computes {avg,median,min,max,sampleSize} over whatever values were collected -- null (not a zeroed MetricStats) when nothing qualified, so callers show "no data" rather than a misleading 0. */
function summarize(values: number[]): MetricStats | null {
  if (!values.length) return null;
  const sum = values.reduce((s, v) => s + v, 0);
  return { avg: sum / values.length, median: median(values), min: Math.min(...values), max: Math.max(...values), sampleSize: values.length };
}

export interface ResultSetAnalytics {
  unit: ComparisonUnit;
  /** The raw denominator's own distribution (e.g. "Building Sq Ft" or "Acres") -- always meaningful physical size/count regardless of what ratios below are being compared per. */
  size: MetricStats | null;
  assessedValuePerUnit: MetricStats | null;
  totalTaxPerUnit: MetricStats | null;
  ptaboaValuePerUnit: MetricStats | null;
  salePricePerUnit: MetricStats | null;
}

/**
 * Computes the result-set analytics panel's five metric rows for the given
 * unit, client-side over the already-loaded rows (no extra query). A row
 * only contributes to a given ratio when BOTH its numerator and denominator
 * are present -- same gating discipline as computePropertySearchSummaryStats
 * above, and the reason sampleSize is tracked per metric rather than shared:
 * Sale Price in particular will have a much smaller N than AV, and blending
 * sample sizes would misrepresent confidence.
 */
export function computeResultSetAnalytics(rows: MergedParcelRow[], unit: ComparisonUnit): ResultSetAnalytics {
  const sizes: number[] = [];
  const avPerUnit: number[] = [];
  const taxPerUnit: number[] = [];
  const ptaboaPerUnit: number[] = [];
  const salePricePerUnit: number[] = [];

  for (const row of rows) {
    const denom = denominatorFor(row, unit);
    if (denom == null) continue;
    sizes.push(denom);
    if (row.AssessedTotalAV != null) avPerUnit.push(row.AssessedTotalAV / denom);
    if (row.TotalTax != null) taxPerUnit.push(row.TotalTax / denom);
    if (row.PTABOAValue != null) ptaboaPerUnit.push(row.PTABOAValue / denom);
    if (row.LastSalePrice != null) salePricePerUnit.push(row.LastSalePrice / denom);
  }

  return {
    unit,
    size: summarize(sizes),
    assessedValuePerUnit: summarize(avPerUnit),
    totalTaxPerUnit: summarize(taxPerUnit),
    ptaboaValuePerUnit: summarize(ptaboaPerUnit),
    salePricePerUnit: summarize(salePricePerUnit),
  };
}

// ───────────────────────── Sub Class Analytics ─────────────────────────
//
// Two rollups, both grouped by CountyAssessorRecord.PropertySubClassDescription:
// current assessed-value profile, and historical PTABOA appeal outcomes.
// Both are computed CLIENT-SIDE over raw RunView results (MJ's RunView has no
// SQL-level GROUP BY -- this is the documented pattern for aggregate views in
// this codebase, see data-access.md "Client-Side Data Aggregation"), joined
// by ParcelID the same way the rest of this dashboard already joins
// CountyAssessorRecord/Assessment/PTABOAAppeal (no Virtual Entity -- see the
// dashboard's own class doc comment for why that mechanism was rejected).
//
// Deliberately UNSCOPED by the dashboard's current search/filter state --
// these are global rollups meant for cross-sub-class comparison, not a
// summary of "whatever's currently filtered." Assessment Analytics IS scoped
// to the selected AssessmentYear (matches every other AV figure in this
// dashboard); Appeal Analytics is NOT year-scoped (a sub class's appeal
// track record spans many years, and most sub classes have too few appeals
// in any single year to be a meaningful sample).

/** A sub class with no PropertySubClassDescription on file -- rare, but real (unclassified parcels exist), and shown as its own row rather than silently dropped. */
export const UNCLASSIFIED_SUBCLASS = 'Unclassified';

export interface SubClassAssessmentRow {
  subClass: string;
  parcelCount: number;
  totalAV: number;
  avgAV: number;
  /** Blended sum(AV)/sum(SqFt) over reliable-sqft-source parcels only, same convention as computePropertySearchSummaryStats. Null when no parcel in this sub class has a reliable sqft figure (e.g. Vacant Land sub classes, which have no building). */
  avgDollarPerSqFt: number | null;
}

export interface SubClassAppealRow {
  subClass: string;
  /**
   * "130S" (subjective/market-value -- the most directly informative type
   * for whether a sub class's typical assessed value holds up), "130O"
   * (objective/mathematical-error correction -- a real valuation appeal, but
   * a narrower one: it fixes a specific data error rather than disputing
   * market value), or "136"/"136C" (charitable/nonprofit Exemption -- not a
   * valuation dispute at all, only present when the AppealTypeFilter is
   * 'all'). Each sub class gets one row PER type it has appeals for, rather
   * than one blended row, precisely so 130O and 130S (and Exemptions, when
   * shown) don't average into a single misleading number -- confirmed
   * 2026-08-26 that blending them was exactly the skew this table exists to
   * avoid.
   */
  appealType: string;
  appealCount: number;
  /** Appeals that produced any AV reduction (AfterTotalAV < BeforeTotalAV) -- the same "win" definition already used by AppealLead's PeerWinRate (score_appeal_leads.py), for consistency with that existing signal. */
  reductions: number;
  /** reductions / appealCount, as a percentage (0-100). */
  winRate: number;
  /** Average % reduction, computed ONLY over winning appeals (matches AppealLead's PeerAvgPctReduction convention exactly) -- averaging over all appeals including non-reductions would understate how large a typical win actually is. Negative = a reduction. Null when this sub class has zero wins. */
  avgPctReductionWhenWon: number | null;
}

/**
 * 'valuation' (the default) includes only Form 130O/130S appeals -- the two
 * types that actually dispute assessed VALUE. 'all' also includes Form
 * 136/136C Exemption records, which decide tax-exempt STATUS, not value --
 * confirmed 2026-08-26 that mixing them in skews a valuation win-rate/
 * reduction rollup (a "Requested 100% Allowed 100%" charitable exemption
 * reads as a huge "reduction" without saying anything about whether the sub
 * class's typical assessed value holds up).
 */
export type AppealTypeFilter = 'valuation' | 'all';

export interface SubClassAppealAnalytics {
  rows: SubClassAppealRow[];
  /** How many appeals matched the filter and were actually aggregated -- lets the UI show "N appeals" honestly rather than just the sub-class row count. */
  includedCount: number;
  /** How many Exemption (136/136C) records existed but were excluded by the 'valuation' filter -- shown so the exclusion is visible, not silent. Always 0 under the 'all' filter. */
  excludedExemptionCount: number;
}

/**
 * Groups CountyAssessorRecord + year-scoped Assessment rows by sub class.
 * @param carRows Raw 'County Assessor Records' rows -- needs ParcelID, PropertySubClassDescription, SqFtSource, EstimatedSqFt.
 * @param assessmentRows Raw 'Assessments' rows already scoped to one AssessmentYear -- needs ParcelID, Source, OriginalTotalAV.
 */
export function buildSubClassAssessmentRows(
  carRows: Record<string, unknown>[],
  assessmentRows: Record<string, unknown>[],
  countyNumber: number
): SubClassAssessmentRow[] {
  // Prefer the county's own card source per parcel (pickAssessmentRow, spec §4.3) -- same
  // data-integrity rule as the main dashboard's own assessmentByParcel map.
  const assessmentByParcel = new Map<string, Record<string, unknown>>();
  for (const a of assessmentRows) {
    const pid = a['ParcelID'] as string;
    assessmentByParcel.set(pid, pickAssessmentRow(assessmentByParcel.get(pid), a, countyNumber));
  }

  interface Bucket {
    parcelCount: number;
    totalAV: number;
    reliableAVSum: number;
    reliableSqFtSum: number;
  }
  const buckets = new Map<string, Bucket>();
  for (const car of carRows) {
    const pid = car['ParcelID'] as string;
    const av = assessmentByParcel.get(pid)?.['OriginalTotalAV'] as number | null | undefined;
    // No Assessment row for this parcel at the selected year -- excluded from
    // this sub class's rollup entirely, not counted as $0 (which would drag
    // down AvgAV with parcels that simply haven't been fetched for this year).
    if (av == null) continue;

    const subClass = (car['PropertySubClassDescription'] as string) || UNCLASSIFIED_SUBCLASS;
    let bucket = buckets.get(subClass);
    if (!bucket) {
      bucket = { parcelCount: 0, totalAV: 0, reliableAVSum: 0, reliableSqFtSum: 0 };
      buckets.set(subClass, bucket);
    }
    bucket.parcelCount++;
    bucket.totalAV += av;

    const sqFtSource = car['SqFtSource'] as string | null;
    const sqFt = car['EstimatedSqFt'] as number | null;
    if (sqFtSource && RELIABLE_SQFT_SOURCES.has(sqFtSource) && sqFt && sqFt > 0) {
      bucket.reliableAVSum += av;
      bucket.reliableSqFtSum += sqFt;
    }
  }

  return Array.from(buckets.entries())
    .map(([subClass, b]) => ({
      subClass,
      parcelCount: b.parcelCount,
      totalAV: b.totalAV,
      avgAV: b.totalAV / b.parcelCount,
      avgDollarPerSqFt: b.reliableSqFtSum > 0 ? b.reliableAVSum / b.reliableSqFtSum : null,
    }))
    .sort((a, c) => c.parcelCount - a.parcelCount);
}

/**
 * Groups PTABOAAppeal rows by their parcel's CURRENT sub class. Appeals whose
 * parcel isn't found in carRows (out of this project's C&I scope, or the
 * appeal's own parcel-number crosswalk didn't resolve -- confirmed 14 such
 * rows as of 2026-08-26) are excluded rather than lumped into Unclassified,
 * since that's a different, honest reason for exclusion.
 *
 * De-dupes by CaseNumber before aggregating (keeping the row with the latest
 * HearingDate per case) -- confirmed 2026-08-26 (cross-checking real August/
 * July 2025 Form 115 Final Determination batches against agenda-derived
 * data) that the SAME case can appear on more than one month's agenda as it
 * progresses toward ratification, sometimes with a DIFFERENT DecisionStatus
 * each time (one real example: an agenda labeled a case "Final Agreement"
 * one month; the SAME case's next-month agenda entry showed "Recommended...
 * the agreement will be submitted to the PTABOA at the next hearing for
 * final approval" -- i.e. the earlier "Final Agreement" label was premature,
 * not yet board-ratified). Without this de-dupe, such a case would be
 * double-counted in appealCount/reductions. Confirmed 14 CaseNumbers (16
 * extra rows) affected as of 2026-08-26.
 * @param appealRows Raw 'PTABOA Appeals' rows -- needs ParcelID, CaseNumber, HearingDate, BeforeTotalAV, AfterTotalAV, RecordKind, AppealType.
 * @param carRows Raw 'County Assessor Records' rows -- needs ParcelID, PropertySubClassDescription.
 * @param filter 'valuation' (default) excludes Exemption (136/136C) records -- see AppealTypeFilter's doc comment.
 */
export function buildSubClassAppealRows(
  appealRows: Record<string, unknown>[],
  carRows: Record<string, unknown>[],
  filter: AppealTypeFilter = 'valuation'
): SubClassAppealAnalytics {
  const subClassByParcel = new Map<string, string>();
  for (const car of carRows) {
    subClassByParcel.set(car['ParcelID'] as string, (car['PropertySubClassDescription'] as string) || UNCLASSIFIED_SUBCLASS);
  }

  // De-dupe by CaseNumber -- keep the latest HearingDate per case (a later
  // agenda mention is more likely to reflect the case's true current status
  // than an earlier one, per the real example in this function's doc
  // comment). Rows with no CaseNumber (shouldn't happen post-migration, but
  // defensively) are each kept as their own "case".
  const latestByCase = new Map<string, Record<string, unknown>>();
  let dedupeCounter = 0;
  for (const a of appealRows) {
    const caseNumber = (a['CaseNumber'] as string | null) || `__no-case-${dedupeCounter++}`;
    const existing = latestByCase.get(caseNumber);
    const existingDate = (existing?.['HearingDate'] as string) ?? '';
    const thisDate = (a['HearingDate'] as string) ?? '';
    if (!existing || thisDate > existingDate) latestByCase.set(caseNumber, a);
  }
  const dedupedAppealRows = Array.from(latestByCase.values());

  interface Bucket {
    subClass: string;
    appealType: string;
    appealCount: number;
    reductions: number;
    pctReductionSum: number;
    pctReductionCount: number;
  }
  // Keyed by (subClass, appealType) -- NOT subClass alone -- so 130O and
  // 130S never average into one blended row.
  const buckets = new Map<string, Bucket>();
  let includedCount = 0;
  let excludedExemptionCount = 0;
  for (const a of dedupedAppealRows) {
    const before = a['BeforeTotalAV'] as number | null;
    const after = a['AfterTotalAV'] as number | null;
    if (before == null || after == null) continue;
    const subClass = subClassByParcel.get(a['ParcelID'] as string);
    if (!subClass) continue;
    const appealType = (a['AppealType'] as string | null) || 'Unknown';

    const isExemption = a['RecordKind'] === 'Exemption';
    if (isExemption && filter === 'valuation') {
      excludedExemptionCount++;
      continue;
    }
    includedCount++;

    const key = `${subClass}|${appealType}`;
    let bucket = buckets.get(key);
    if (!bucket) {
      bucket = { subClass, appealType, appealCount: 0, reductions: 0, pctReductionSum: 0, pctReductionCount: 0 };
      buckets.set(key, bucket);
    }
    bucket.appealCount++;
    if (after < before) {
      bucket.reductions++;
      if (before > 0) {
        bucket.pctReductionSum += ((after - before) / before) * 100;
        bucket.pctReductionCount++;
      }
    }
  }

  const rows = Array.from(buckets.values())
    .map((b) => ({
      subClass: b.subClass,
      appealType: b.appealType,
      appealCount: b.appealCount,
      reductions: b.reductions,
      winRate: (b.reductions / b.appealCount) * 100,
      avgPctReductionWhenWon: b.pctReductionCount > 0 ? b.pctReductionSum / b.pctReductionCount : null,
    }))
    // Grouped by sub class first (so a class's appeal types sit together),
    // then by appeal type -- a stable, readable default; every column
    // remains independently sortable in the grid.
    .sort((a, c) => a.subClass.localeCompare(c.subClass) || a.appealType.localeCompare(c.appealType));

  return { rows, includedCount, excludedExemptionCount };
}
