import { describe, it, expect } from 'vitest';
import {
  indexDataSources,
  lookupDataSource,
  headlineSourceLabel,
  taxSourceLabel,
  buildHeadlineFields,
  indexHeadlinesByParcel,
  vintageNoun,
  NO_ASSESSMENT_LABEL,
  PARCEL_YEAR_HEADLINE_FIELDS,
} from '../PropertySearch/property-search-headline';

/**
 * Property Search reads indiana_tax.ParcelYearHeadline (the Foundation's stored headline) and
 * labels it from indiana_tax.DataSource. Fixtures mirror the real rows for parcel 1032304
 * (300 N Meridian St) after migration D on 2026-09-22 and the real Data Source seed labels.
 */

const MARION_PRC = '3555A9A5-AC1D-4F54-8ABE-B0E371EEB811';
const DLGF = '30FBA949-1111-2222-3333-444444444444';
const MARION_TAXHIST = 'F01513C2-14A6-4765-9A9D-B65D76A21DE6';
const MARION_TS1A = '1CCFE26D-5555-6666-7777-888888888888';

const sources = indexDataSources([
  { ID: MARION_PRC, Name: 'MarionPRC', Kind: 'County Record Card', Label: 'Marion County record card', IsOfficial: true, IsPlaceholder: false },
  { ID: DLGF, Name: 'dlgf_gdb_2025', Kind: 'State DLGF', Label: 'DLGF statewide roll, AY2025 (placeholder where no county record exists)', IsOfficial: false, IsPlaceholder: true },
  { ID: MARION_TAXHIST, Name: 'MarionTaxHistory', Kind: 'County Tax History', Label: 'Marion County tax history report', IsOfficial: true, IsPlaceholder: false },
  { ID: MARION_TS1A, Name: 'MarionTS1A', Kind: 'County Tax Bill', Label: 'Marion County tax bill (TS-1A)', IsOfficial: true, IsPlaceholder: false },
]);

const ay2024 = {
  ParcelID: 'p-meridian', AssessmentYear: 2024,
  HeadlineLandAV: 3_162_000, HeadlineImprovementAV: 36_345_300, HeadlineTotalAV: 39_507_300,
  HeadlineDataSourceID: MARION_PRC, HeadlineDocumentYear: 2026, HeadlineDocumentDate: '2026-01-01', IsPlaceholder: false,
  SourceCount: 1, MaxSpreadPct: null, HasDisagreement: false, HasRevision: false, RevisedFromTotalAV: null,
  HeadlineTax: 1_100_594.36, TaxDataSourceID: MARION_TAXHIST,
};

describe('indexDataSources / lookupDataSource', () => {
  it('indexes by ID case-insensitively (SQL Server GUIDs are uppercase, cached ids may not be)', () => {
    expect(lookupDataSource(sources, MARION_PRC.toLowerCase())?.Name).toBe('MarionPRC');
    expect(lookupDataSource(sources, MARION_PRC)?.Label).toBe('Marion County record card');
    expect(lookupDataSource(sources, null)).toBeNull();
    expect(lookupDataSource(sources, 'not-a-source')).toBeNull();
  });
  it('reads the bit columns as booleans and falls back to Name when Label is missing', () => {
    const idx = indexDataSources([{ ID: 'x', Name: 'Bare', Kind: 'Practitioner', Label: null, IsOfficial: false, IsPlaceholder: false }]);
    expect(lookupDataSource(idx, 'x')).toEqual({ ID: 'x', Name: 'Bare', Kind: 'Practitioner', Label: 'Bare', IsOfficial: false, IsPlaceholder: false });
  });
});

describe('headlineSourceLabel -- the Source cell carries the document year (vintage)', () => {
  it('an AY2024 value per the 2026 card reads "Marion County record card (2026)"', () => {
    expect(headlineSourceLabel(ay2024, sources)).toBe('Marion County record card (2026)');
  });
  it('adds the noun when the label does not already name the document', () => {
    const notice = { ...ay2024, HeadlineDataSourceID: 'n1', HeadlineDocumentYear: 2025 };
    const idx = indexDataSources([{ ID: 'n1', Name: 'MarionForm11', Kind: 'County Notice', Label: 'Marion County Form 11', IsOfficial: true, IsPlaceholder: false }]);
    expect(headlineSourceLabel(notice, idx)).toBe('Marion County Form 11 (2025 notice)');
  });
  it('a placeholder row says so, using the short form of the DLGF label', () => {
    const placeholder = { ...ay2024, HeadlineDataSourceID: DLGF, IsPlaceholder: true, HeadlineDocumentYear: 2025 };
    expect(headlineSourceLabel(placeholder, sources)).toBe('DLGF statewide roll (placeholder)');
  });
  it('an undated headline shows the label alone; no headline row shows the no-assessment label', () => {
    expect(headlineSourceLabel({ ...ay2024, HeadlineDocumentYear: null }, sources)).toBe('Marion County record card');
    expect(headlineSourceLabel(undefined, sources)).toBe(NO_ASSESSMENT_LABEL);
  });
  it('an unknown data source id never throws', () => {
    expect(headlineSourceLabel({ ...ay2024, HeadlineDataSourceID: 'gone' }, sources)).toBe('Unknown source (2026 document)');
  });
});

describe('taxSourceLabel', () => {
  it('names the tax source when a tax is present, null when the year is unbilled', () => {
    expect(taxSourceLabel(ay2024, sources)).toBe('Marion County tax history report');
    expect(taxSourceLabel({ ...ay2024, HeadlineTax: null, TaxDataSourceID: null }, sources)).toBeNull();
    expect(taxSourceLabel(undefined, sources)).toBeNull();
  });
});

describe('buildHeadlineFields', () => {
  it('maps the 1032304 AY2024 headline row onto the merged-row fields', () => {
    const f = buildHeadlineFields(ay2024, sources, 2024);
    expect(f).toEqual({
      AssessedLandAV: 3_162_000, AssessedImprovementAV: 36_345_300, AssessedTotalAV: 39_507_300,
      AssessmentYear: 2024, AssessmentSource: 'MarionPRC', DataSource: 'Marion County record card (2026)',
      IsPlaceholder: false, HeadlineDocumentYear: 2026, MaxSpreadPct: null, HasDisagreement: false,
      RevisedFromTotalAV: null, HasRevision: false, TotalTax: 1_100_594.36, TaxSource: 'Marion County tax history report',
      HasLaterAppeal: false, LaterAppealText: null,
    });
  });
  it('no headline row -> every value null, AssessmentYear null (so the Verify link never claims a year), DataSource = no assessment', () => {
    const f = buildHeadlineFields(undefined, sources, 2024);
    expect(f.AssessedTotalAV).toBeNull();
    expect(f.AssessmentYear).toBeNull();
    expect(f.DataSource).toBe(NO_ASSESSMENT_LABEL);
    expect(f.IsPlaceholder).toBe(false);
    expect(f.TotalTax).toBeNull();
  });
  it('carries disagreement and revision through as the grid reads them', () => {
    const f = buildHeadlineFields({ ...ay2024, MaxSpreadPct: 10.2578, HasDisagreement: true, HasRevision: true, RevisedFromTotalAV: 41_000_000 }, sources, 2024);
    expect(f.MaxSpreadPct).toBeCloseTo(10.2578, 4);
    expect(f.HasDisagreement).toBe(true);
    expect(f.HasRevision).toBe(true);
    expect(f.RevisedFromTotalAV).toBe(41_000_000);
  });
  it('maps HasLaterAppeal and its text from the headline (a later IBTR disposition the grid badges)', () => {
    const f = buildHeadlineFields({ ...ay2024, HasLaterAppeal: true, LaterAppealText: 'IBTR: Settlement - withdrawal, 2026-01-30' }, sources, 2024);
    expect(f.HasLaterAppeal).toBe(true);
    expect(f.LaterAppealText).toBe('IBTR: Settlement - withdrawal, 2026-01-30');
    expect(buildHeadlineFields(undefined, sources, 2024)).toMatchObject({ HasLaterAppeal: false, LaterAppealText: null });
  });
  it('reads HasLaterAppeal and LaterAppealText from Parcel Year Headlines', () => {
    expect(PARCEL_YEAR_HEADLINE_FIELDS).toEqual(expect.arrayContaining(['HasLaterAppeal', 'LaterAppealText']));
  });
  it('a placeholder headline is flagged IsPlaceholder and labelled as one', () => {
    const f = buildHeadlineFields({ ...ay2024, HeadlineDataSourceID: DLGF, IsPlaceholder: true, HeadlineDocumentYear: 2025, HeadlineTax: null, TaxDataSourceID: null }, sources, 2025);
    expect(f.IsPlaceholder).toBe(true);
    expect(f.DataSource).toBe('DLGF statewide roll (placeholder)');
    expect(f.AssessmentSource).toBe('dlgf_gdb_2025');
    expect(f.TaxSource).toBeNull();
  });
});

describe('indexHeadlinesByParcel', () => {
  it('keys rows by ParcelID', () => {
    const m = indexHeadlinesByParcel([ay2024, { ...ay2024, ParcelID: 'p2' }]);
    expect(m.size).toBe(2);
    expect(m.get('p2')?.['ParcelID']).toBe('p2');
  });
});

describe('constants', () => {
  it('reads every column the merged row needs, and nothing that does not exist on the entity', () => {
    expect(PARCEL_YEAR_HEADLINE_FIELDS).toContain('HeadlineDocumentYear');
    expect(PARCEL_YEAR_HEADLINE_FIELDS).toContain('RevisedFromTotalAV');
    expect(PARCEL_YEAR_HEADLINE_FIELDS).not.toContain('TaxRate');
  });
  it('vintage nouns read the way a practitioner says them', () => {
    expect(vintageNoun('County Record Card')).toBe('card');
    expect(vintageNoun('County Tax Bill')).toBe('bill');
    expect(vintageNoun('Practitioner')).toBe('document');
  });
});
