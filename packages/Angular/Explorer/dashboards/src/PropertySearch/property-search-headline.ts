/**
 * @fileoverview Property Search's read of indiana_tax.ParcelYearHeadline -- the ONE stored
 * headline assessed value and tax per parcel-year, resolved by the Foundation's shared rule
 * (mj-indiana-tax packages/core resolveHeadline: latest-dated official county document wins,
 * the DLGF roll only as a placeholder, commercial data never; an older-vintage official document
 * is a revision, not a disagreement). This dashboard no longer picks between Assessment rows
 * itself -- it reads the headline row and labels it. Source words come from indiana_tax.DataSource
 * (29 rows, loaded once), never from a hand-written source-name list.
 *
 * Pure and framework-free: no RunView, no Angular. 🚨 SAFETY: read-only.
 */

/** The `Data Sources` columns this dashboard reads. */
export interface DataSourceInfo {
  ID: string;
  /** Machine name, e.g. 'MarionPRC', 'dlgf_gdb_2025' -- what Assessment.Source carries. */
  Name: string;
  Kind: string;
  /** The words a practitioner reads, e.g. 'Marion County record card'. */
  Label: string;
  IsOfficial: boolean;
  IsPlaceholder: boolean;
}

export type DataSourceIndex = ReadonlyMap<string, DataSourceInfo>;

export const DATA_SOURCE_FIELDS = ['ID', 'Name', 'Kind', 'Label', 'IsOfficial', 'IsPlaceholder'] as const;

export function indexDataSources(rows: Record<string, unknown>[]): DataSourceIndex {
  const index = new Map<string, DataSourceInfo>();
  for (const r of rows) {
    const id = r['ID'] as string;
    if (!id) continue;
    index.set(id.toLowerCase(), {
      ID: id,
      Name: (r['Name'] as string) ?? '',
      Kind: (r['Kind'] as string) ?? '',
      Label: (r['Label'] as string) ?? (r['Name'] as string) ?? '',
      IsOfficial: r['IsOfficial'] === true,
      IsPlaceholder: r['IsPlaceholder'] === true,
    });
  }
  return index;
}

/** Case-insensitive lookup -- SQL Server returns uppercase GUIDs, the cache may hold either case. */
export function lookupDataSource(index: DataSourceIndex, id: string | null | undefined): DataSourceInfo | null {
  return id ? (index.get(id.toLowerCase()) ?? null) : null;
}

/** The `Parcel Year Headlines` columns this dashboard reads -- one row per parcel for the selected year. */
export const PARCEL_YEAR_HEADLINE_FIELDS = [
  'ParcelID', 'AssessmentYear',
  'HeadlineLandAV', 'HeadlineImprovementAV', 'HeadlineTotalAV',
  'HeadlineDataSourceID', 'HeadlineDocumentYear', 'HeadlineDocumentDate', 'IsPlaceholder',
  'SourceCount', 'MaxSpreadPct', 'HasDisagreement', 'HasRevision', 'RevisedFromTotalAV',
  'HeadlineTax', 'TaxDataSourceID', 'HasLaterAppeal', 'LaterAppealText',
] as const;

export const NO_ASSESSMENT_LABEL = 'No assessment on file';

/** The word a practitioner uses for a document of this kind -- mirrors vintageNoun() in mj-indiana-tax packages/core, which owns it. */
export function vintageNoun(kind: string): string {
  switch (kind) {
    case 'County Record Card': return 'card';
    case 'County Tax Bill': return 'bill';
    case 'County Tax History': return 'tax history';
    case 'County Notice': return 'notice';
    case 'State DLGF': return 'roll';
    case 'Public Records Response': return 'records response';
    default: return 'document';
  }
}

/**
 * The Source cell: "Marion County record card (2026)" -- the document's own year in parentheses,
 * because an AY2024 value can come from the 2026 card (as finally determined) or the 2024 card
 * (as noticed), and the reader must be able to tell. A placeholder row says so in its own words;
 * no headline row at all says NO_ASSESSMENT_LABEL.
 */
export function headlineSourceLabel(headline: Record<string, unknown> | undefined, sources: DataSourceIndex): string {
  if (!headline) return NO_ASSESSMENT_LABEL;
  const ds = lookupDataSource(sources, headline['HeadlineDataSourceID'] as string | null);
  const isPlaceholder = headline['IsPlaceholder'] === true || (ds?.IsPlaceholder ?? false);
  if (isPlaceholder) return `${ds ? ds.Label.split(',')[0] : 'DLGF statewide roll'} (placeholder)`;
  const label = ds?.Label ?? 'Unknown source';
  const year = headline['HeadlineDocumentYear'] as number | null;
  if (year == null) return label;
  const noun = vintageNoun(ds?.Kind ?? '');
  // "Marion County record card (2026)" not "... (2026 card)": the label already names the document.
  return label.toLowerCase().includes(noun) ? `${label} (${year})` : `${label} (${year} ${noun})`;
}

/** The Tax Source cell: the label of the source the headline tax came from, e.g. 'Marion County tax history report'. */
export function taxSourceLabel(headline: Record<string, unknown> | undefined, sources: DataSourceIndex): string | null {
  if (!headline || headline['HeadlineTax'] == null) return null;
  return lookupDataSource(sources, headline['TaxDataSourceID'] as string | null)?.Label ?? 'Unknown source';
}

/** The headline-derived slice of MergedParcelRow -- both data paths spread this into their rows. */
export interface HeadlineFields {
  AssessedLandAV: number | null;
  AssessedImprovementAV: number | null;
  AssessedTotalAV: number | null;
  /** The selected year when a headline row exists, else null ("No data") -- feeds the Verify link too. */
  AssessmentYear: number | null;
  /** DataSource.Name of the headline document ('MarionPRC', 'dlgf_gdb_2025'), for the export. */
  AssessmentSource: string | null;
  DataSource: string;
  IsPlaceholder: boolean;
  HeadlineDocumentYear: number | null;
  MaxSpreadPct: number | null;
  HasDisagreement: boolean;
  RevisedFromTotalAV: number | null;
  HasRevision: boolean;
  TotalTax: number | null;
  TaxSource: string | null;
  /** An IBTR decision exists for this year without an extracted value; the assessed value shown is the latest document on record and may not be the value as finally determined. LaterAppealText says which, e.g. "IBTR: Settlement - withdrawal, 2026-01-30". */
  HasLaterAppeal: boolean;
  LaterAppealText: string | null;
}

export function buildHeadlineFields(headline: Record<string, unknown> | undefined, sources: DataSourceIndex, assessmentYear: number): HeadlineFields {
  if (!headline) {
    return {
      AssessedLandAV: null, AssessedImprovementAV: null, AssessedTotalAV: null,
      AssessmentYear: null, AssessmentSource: null, DataSource: NO_ASSESSMENT_LABEL,
      IsPlaceholder: false, HeadlineDocumentYear: null, MaxSpreadPct: null, HasDisagreement: false,
      RevisedFromTotalAV: null, HasRevision: false, TotalTax: null, TaxSource: null,
      HasLaterAppeal: false, LaterAppealText: null,
    };
  }
  const ds = lookupDataSource(sources, headline['HeadlineDataSourceID'] as string | null);
  return {
    AssessedLandAV: (headline['HeadlineLandAV'] as number) ?? null,
    AssessedImprovementAV: (headline['HeadlineImprovementAV'] as number) ?? null,
    AssessedTotalAV: (headline['HeadlineTotalAV'] as number) ?? null,
    AssessmentYear: assessmentYear,
    AssessmentSource: ds?.Name ?? null,
    DataSource: headlineSourceLabel(headline, sources),
    IsPlaceholder: headline['IsPlaceholder'] === true,
    HeadlineDocumentYear: (headline['HeadlineDocumentYear'] as number) ?? null,
    MaxSpreadPct: (headline['MaxSpreadPct'] as number) ?? null,
    HasDisagreement: headline['HasDisagreement'] === true,
    RevisedFromTotalAV: (headline['RevisedFromTotalAV'] as number) ?? null,
    HasRevision: headline['HasRevision'] === true,
    TotalTax: (headline['HeadlineTax'] as number) ?? null,
    TaxSource: taxSourceLabel(headline, sources),
    HasLaterAppeal: headline['HasLaterAppeal'] === true,
    LaterAppealText: (headline['LaterAppealText'] as string) ?? null,
  };
}

/** One headline row per parcel-year is guaranteed by UQ_ParcelYearHeadline; last write wins defensively. */
export function indexHeadlinesByParcel(rows: Record<string, unknown>[]): Map<string, Record<string, unknown>> {
  const byParcel = new Map<string, Record<string, unknown>>();
  for (const h of rows) byParcel.set(h['ParcelID'] as string, h);
  return byParcel;
}
