/**
 * @fileoverview County identity, source tier and verification routes for Property Search.
 *
 * Pure and framework-free; imports nothing from property-search-agent-context.ts so the
 * dependency stays one-way (agent-context -> here).
 *
 * 🚨 OWNER OF THE COUNTY-CARD SOURCE NAMES: Indiana_Tax_Expert/scripts/lib/county-card-sources.js.
 * COUNTY_CARD_SOURCE below is the Angular mirror of that file. It carries one entry that file does
 * not -- Marion (49, 'MarionPRC'), whose loader predates the shared module. A county reaches this
 * table only at intake stage S3/S4 (proposals/multi-county-ci-intake.md §7), which is a deliberate,
 * recorded step; adding a county means editing BOTH files AND the CK_Assessment_ComponentSum
 * migration. A live query was considered and rejected: RunView has no DISTINCT/GROUP BY, so
 * "which counties have card data" would cost a ~180k-row scan of CountyAssessorRecord per session,
 * and it still could not label the 91 counties the user has not selected.
 */
import { prcUrl } from '../TaxBudgetProjection/marion-verification';

export const MARION_COUNTY_NUMBER = 49;
export const DLGF_SOURCE = 'dlgf_gdb_2025';
export const MARION_FOIA_SOURCE = 'marion_foia_2026';

export const COUNTY_CARD_SOURCE: Readonly<Record<number, string>> = Object.freeze({
  2: 'AllenPRC',
  45: 'LakePRC',
  49: 'MarionPRC',
  71: 'StJosephPRC',
  // xSoft Engage wave 2, added 2026-09-16 -- the same vendor as Lake/St. Joseph, a runbook re-run.
  82: 'VanderburghPRC',
  10: 'ClarkPRC',
  64: 'PorterPRC',
  32: 'HendricksPRC',
  17: 'DeKalbPRC',
  87: 'WarrickPRC',
  42: 'KnoxPRC',
  73: 'ShelbyPRC',
  14: 'DaviessPRC',
  68: 'RandolphPRC',
  65: 'PoseyPRC',
  23: 'FountainPRC',
  // Elkhart, added 2026-09-16 -- Elevate Maps' open S3 bucket, a second single-static-URL
  // vendor alongside Allen's acimap.us (SINGLE_URL_VENDOR_SLUGS below). Card is AY2024, one
  // year behind the DLGF roster -- no per-year conflict (Assessment is keyed per parcel-year;
  // AY2025 still reads DLGF because Elkhart's card has no row for that year).
  20: 'ElkhartPRC',
});

export function countyCardSource(countyNumber: number): string | null {
  return COUNTY_CARD_SOURCE[countyNumber] ?? null;
}

export type CountySourceTier = 'County PRC' | 'DLGF only';
export type ParcelDataSource = 'County record card' | 'County FOIA list' | 'DLGF statewide file' | 'No assessment on file';

export function countySourceTier(countyNumber: number): CountySourceTier {
  return countyCardSource(countyNumber) ? 'County PRC' : 'DLGF only';
}

/**
 * Rank of an Assessment row's Source for one county: county PRC > county FOIA list > DLGF.
 * Spec: proposals/multi-county-ci-intake.md §4.3. 0 = an unrecognised source (e.g. a future
 * apra_<slug>_<year> row), which still beats nothing at all but loses to every known source.
 */
export function assessmentSourceRank(source: string | null, countyNumber: number): number {
  if (!source) return -1;
  if (source === countyCardSource(countyNumber)) return 3;
  if (source === MARION_FOIA_SOURCE) return 2;
  if (source === DLGF_SOURCE) return 1;
  return 0;
}

/**
 * Winner between the Assessment row already held for a parcel-year and a new candidate.
 * Ties keep `existing` (first-write-wins), so a stable query order gives a stable result.
 */
export function pickAssessmentRow(
  existing: Record<string, unknown> | undefined,
  candidate: Record<string, unknown>,
  countyNumber: number
): Record<string, unknown> {
  if (!existing) return candidate;
  const existingRank = assessmentSourceRank(existing['Source'] as string | null, countyNumber);
  const candidateRank = assessmentSourceRank(candidate['Source'] as string | null, countyNumber);
  return candidateRank > existingRank ? candidate : existing;
}

/** The words shown to the user for a row's Source -- what `MergedParcelRow.DataSource` carries. */
export function dataSourceLabel(source: string | null, countyNumber: number): ParcelDataSource {
  switch (assessmentSourceRank(source, countyNumber)) {
    case 3: return 'County record card';
    case 2: return 'County FOIA list';
    case 1: return 'DLGF statewide file';
    case 0: return 'DLGF statewide file';
    default: return 'No assessment on file';
  }
}

export function isDlgfSourced(dataSource: ParcelDataSource): boolean {
  return dataSource === 'DLGF statewide file';
}

/** Spec §6, verbatim. One constant: the banner, the export header line and the export column all read it. */
export const DLGF_NOTATION =
  'Source: Indiana DLGF statewide parcel file — assessment year 2025, as initially determined. ' +
  'This is not the county\'s property record card. Data runs through AY2025.';

export interface CountyOption {
  CountyNumber: number;
  Name: string;
  Slug: string;
  /** C&I (class 300–499) parcel count, measured live; null when the count query failed. */
  CICount: number | null;
  Tier: CountySourceTier;
  /** "Marion — 20,722 C&I · County PRC" */
  Label: string;
}

/**
 * Builds the dropdown options from the 92 County rows and a live per-county C&I tally.
 * Sorted by name so the list reads like a county list, not a DLGF-number list.
 */
export function buildCountyOptions(
  countyRows: Record<string, unknown>[],
  ciCountByCounty: ReadonlyMap<number, number>
): CountyOption[] {
  return countyRows
    .map((r) => {
      const countyNumber = r['CountyNumber'] as number;
      const name = (r['Name'] as string) ?? `County ${countyNumber}`;
      const tier = countySourceTier(countyNumber);
      const count = ciCountByCounty.get(countyNumber) ?? null;
      const countText = count == null ? 'count unavailable' : `${count.toLocaleString('en-US')} C&I`;
      return {
        CountyNumber: countyNumber,
        Name: name,
        Slug: (r['Slug'] as string) ?? '',
        CICount: count,
        Tier: tier,
        Label: `${name} — ${countText} · ${tier}`,
      };
    })
    .sort((a, b) => a.Name.localeCompare(b.Name));
}

/** Tally of C&I parcels per county from a one-column Parcels fetch (CountyNumber only). */
export function tallyCIParcels(parcelRows: Record<string, unknown>[]): Map<number, number> {
  const counts = new Map<number, number>();
  for (const row of parcelRows) {
    const n = row['CountyNumber'] as number;
    if (typeof n !== 'number') continue;
    counts.set(n, (counts.get(n) ?? 0) + 1);
  }
  return counts;
}

/** The C&I class range, one place. Both the county tally and the DLGF data path read it. */
export const CI_CLASS_CODE_FILTER = "PropertyClassCode >= '300' AND PropertyClassCode <= '499'";

/**
 * Parcels-side filter for "the statewide C&I roster": a parcel whose AY2025 DLGF row carries a
 * C&I class code. The class code lives on Assessment, not Parcel -- Parcel.PropertyClassCode is
 * NULL on every row (verified 2026-09-13; the county tally read it and counted nothing, so every
 * label said "count unavailable"). RunView has no GROUP BY, so this pulls one small column for
 * ~202k rows (11.6 s measured) and tallies client-side, deferred off the first paint. The
 * subquery shape is the one property-subclass-analytics already uses. Counts reconcile to the
 * intake rosters exactly (Lake 15,001, St. Joseph 7,454).
 */
export const CI_ROSTER_PARCEL_FILTER =
  `ID IN (SELECT ParcelID FROM indiana_tax.vwAssessments WHERE Source = '${DLGF_SOURCE}' AND ${CI_CLASS_CODE_FILTER})`;

export interface VerifyLinkTarget {
  countyNumber: number;
  slug: string;
  parcelNumber: string | null;
  gisParcelNumber: string | null;
  assessmentYear: number | null;
}

export interface CountyVerifyLink {
  label: string;
  /** Null when no link can be built for this county/parcel — see `note`. */
  url: string | null;
  note: string;
}

/**
 * xSoft Engage counties whose blob route has been CONFIRMED at intake stage S0
 * (proposals/multi-county-ci-intake.md §7). Keyed by County.Slug, which is the DB's own value.
 * A county joins this set when its S0 gate passes -- never on the assumption that a vendor
 * generalises, because a 404 masquerading as a verification route is worse than no link.
 */
export const XSOFT_ENGAGE_SLUGS: ReadonlySet<string> = new Set(['lake', 'stjoseph', 'vanderburgh', 'clark', 'porter', 'hendricks', 'dekalb', 'warrick', 'knox', 'shelby', 'daviess', 'randolph', 'posey', 'fountain']);

/**
 * Counties on a single-static-URL vendor CONFIRMED at intake stage S0 -- one route per parcel,
 * no year in the path (Allen's acimap.us; scripts/lib/acimap.js). Unlike XSOFT_ENGAGE_SLUGS, the
 * link built here does NOT depend on target.assessmentYear -- the same URL answers for every
 * year on screen, because the vendor itself publishes only its current card (see
 * data/county_intake/allen/PILOT_FINDINGS.md's "genuinely different vendor shape").
 */
export const SINGLE_URL_VENDOR_SLUGS: ReadonlySet<string> = new Set(['allen', 'elkhart']);

/** "45-07-06-207-002.000-023" from the 18-digit state parcel number. Null when it isn't 18 digits. */
export function toDashedStateParcel(parcelNumber: string | null): string | null {
  const d = (parcelNumber ?? '').replace(/\D/g, '');
  if (d.length !== 18) return null;
  return `${d.slice(0, 2)}-${d.slice(2, 4)}-${d.slice(4, 6)}-${d.slice(6, 9)}-${d.slice(9, 12)}.${d.slice(12, 15)}-${d.slice(15, 18)}`;
}

export function xsoftCardUrl(slug: string, dashedParcel: string, year: number): string {
  return `https://engageblob.blob.core.windows.net/${slug}/pdf/${year}/${dashedParcel}.pdf`;
}

/** Allen's own site: one static, year-less URL per parcel -- the 18-digit number as-is, no dashing. */
export function acimapCardUrl(parcelNumber: string): string {
  return `https://acimap.us/website/prc/${parcelNumber}.pdf`;
}

/** Elkhart's own site (Elevate Maps' open S3 bucket): one static, year-less URL per parcel --
 *  dashed, unlike acimap.us. */
export function elevateMapsCardUrl(dashedParcel: string): string {
  return `https://s3.amazonaws.com/assets.elevatemaps.io/ElkhartIN/PRC/${dashedParcel}.pdf`;
}

/**
 * The route to the county's own document for one parcel, or an honest statement that there
 * isn't one. Marion uses its own report service (keyed by the 7-digit GIS parcel number);
 * xSoft Engage counties serve a static blob PDF per assessment year (keyed by the dashed
 * 18-digit state parcel number). Hamilton's file key (LRSN) is not derivable from the parcel
 * number at all -- that county will always land in the null branch.
 */
export function buildVerifyLink(target: VerifyLinkTarget): CountyVerifyLink {
  const noRoute = (): CountyVerifyLink => ({
    label: 'Property Record Card',
    url: null,
    note: 'not on file — verify at the county',
  });
  if (target.countyNumber === MARION_COUNTY_NUMBER) {
    const gis = (target.gisParcelNumber ?? '').trim();
    return gis ? { label: 'Property Record Card', url: prcUrl(gis), note: 'Marion County Assessor' } : noRoute();
  }
  if (XSOFT_ENGAGE_SLUGS.has(target.slug) && target.assessmentYear != null) {
    const dashed = toDashedStateParcel(target.parcelNumber);
    return dashed
      ? { label: `Record Card (AY${target.assessmentYear})`, url: xsoftCardUrl(target.slug, dashed, target.assessmentYear), note: 'xSoft Engage' }
      : noRoute();
  }
  if (SINGLE_URL_VENDOR_SLUGS.has(target.slug)) {
    const digits = (target.parcelNumber ?? '').replace(/\D/g, '');
    if (digits.length !== 18) return noRoute();
    // The label carries no "(AYxxxx)" -- unlike the xSoft link, this one is NOT scoped to the
    // year on screen; it is the vendor's one current card, whatever year that happens to be.
    const url = target.slug === 'elkhart' ? elevateMapsCardUrl(toDashedStateParcel(digits) ?? '') : acimapCardUrl(digits);
    return { label: 'Record Card (current)', url, note: "the county's own site" };
  }
  return noRoute();
}
