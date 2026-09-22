import { describe, it, expect } from 'vitest';
import {
  buildDlgfHeadlineFilter,
  buildDlgfParcelSearchFilter,
  buildDlgfMergedRows,
  buildClassCodeSubClassOptions,
  indexClassCodeByParcel,
  DlgfSearchParams,
} from '../PropertySearch/property-search-dlgf';
import { CI_CLASS_CODE_FILTER } from '../PropertySearch/property-search-county';
import { indexDataSources } from '../PropertySearch/property-search-headline';

/**
 * Task 3 brief: proposals/multi-county-ci-intake.md §6 (two data paths, one row shape), re-based
 * on 2026-09-22 onto indiana_tax.ParcelYearHeadline (one already-resolved row per parcel-year).
 * This module is pure and framework-free -- no RunView, no Angular -- so every case here is
 * a plain function call, matching the property-search-county.test.ts convention.
 */

const LAKE_PRC = 'A1';
const DLGF = 'D1';
const sources = indexDataSources([
  { ID: LAKE_PRC, Name: 'LakePRC', Kind: 'County Record Card', Label: 'Lake County record card', IsOfficial: true, IsPlaceholder: false },
  { ID: DLGF, Name: 'dlgf_gdb_2025', Kind: 'State DLGF', Label: 'DLGF statewide roll, AY2025 (placeholder where no county record exists)', IsOfficial: false, IsPlaceholder: true },
]);

const baseParams: DlgfSearchParams = {
  countyNumber: 45,
  slug: 'lake',
  assessmentYear: 2025,
  searchTerm: '',
  propertyClassCode: null,
  resultCap: 2000,
  dataSources: sources,
};

function headline(parcelID: string, totalAV: number, extra: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    ParcelID: parcelID, AssessmentYear: 2025, HeadlineLandAV: 1, HeadlineImprovementAV: totalAV - 1, HeadlineTotalAV: totalAV,
    HeadlineDataSourceID: DLGF, HeadlineDocumentYear: 2025, HeadlineDocumentDate: '2025-01-01', IsPlaceholder: true,
    SourceCount: 1, MaxSpreadPct: null, HasDisagreement: false, HasRevision: false, RevisedFromTotalAV: null,
    HeadlineTax: null, TaxDataSourceID: null, ...extra,
  };
}

describe('buildDlgfHeadlineFilter', () => {
  it('scopes the headline table to the year and to parcels whose Assessment rows carry a C&I class code in that county', () => {
    const f = buildDlgfHeadlineFilter(baseParams, null);
    expect(f).toContain('AssessmentYear = 2025 AND ParcelID IN (SELECT ParcelID FROM indiana_tax.vwAssessments WHERE AssessmentYear = 2025');
    expect(f).toContain(CI_CLASS_CODE_FILTER);
    expect(f).toContain('ParcelID IN (SELECT ID FROM indiana_tax.vwParcels WHERE CountyNumber = 45)');
  });

  it('yields 1=0 (never an unfiltered query) when parcelIdConstraint is an empty array', () => {
    expect(buildDlgfHeadlineFilter(baseParams, [])).toContain('1=0');
  });

  it('escapes a class code containing an apostrophe', () => {
    const f = buildDlgfHeadlineFilter({ ...baseParams, propertyClassCode: "4'01" }, null);
    expect(f).toContain("PropertyClassCode = '4''01'");
  });

  it('applies a search-term-classified 3-digit code even with no dropdown propertyClassCode set', () => {
    const f = buildDlgfHeadlineFilter(baseParams, null, '429');
    expect(f).toContain("PropertyClassCode = '429'");
  });

  it('applies both the dropdown propertyClassCode and a search-term code when both are set', () => {
    const f = buildDlgfHeadlineFilter({ ...baseParams, propertyClassCode: '401' }, null, '429');
    expect(f).toContain("PropertyClassCode = '401'");
    expect(f).toContain("PropertyClassCode = '429'");
  });

  it('omits the search-term clause entirely when no code is classified (null/undefined)', () => {
    expect(buildDlgfHeadlineFilter(baseParams, null, null)).not.toContain("PropertyClassCode = '");
    expect(buildDlgfHeadlineFilter(baseParams, null)).not.toContain("PropertyClassCode = '");
  });

  it('narrows to the resolved parcel ids on the headline table itself', () => {
    const f = buildDlgfHeadlineFilter(baseParams, ['p1', "p'2"]);
    expect(f).toContain("ParcelID IN ('p1','p''2')");
  });
});

describe('buildDlgfParcelSearchFilter', () => {
  it('freeText searches both OwnerName and Address', () => {
    const f = buildDlgfParcelSearchFilter(45, "O'Neil", 'freeText');
    expect(f).toBe("CountyNumber = 45 AND (OwnerName LIKE '%O''Neil%' OR Address LIKE '%O''Neil%')");
  });

  it('parcel numbers match either parcel field', () => {
    expect(buildDlgfParcelSearchFilter(45, '450706207002000023', 'parcelOrGisNumber')).toContain("ParcelNumber = '450706207002000023' OR GISParcelNumber = '450706207002000023'");
  });

  it('subClassCode returns null -- handled on the headline side', () => {
    expect(buildDlgfParcelSearchFilter(45, '429', 'subClassCode')).toBeNull();
  });
});

describe('indexClassCodeByParcel', () => {
  it("prefers the class code from the headline's own source, else the first non-null", () => {
    const byParcel = indexClassCodeByParcel(
      [
        { ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401' },
        { ParcelID: 'p1', Source: 'LakePRC', PropertyClassCode: '429' },
        { ParcelID: 'p2', Source: 'dlgf_gdb_2025', PropertyClassCode: null },
        { ParcelID: 'p2', Source: 'LakePRC', PropertyClassCode: '402' },
      ],
      new Map([['p1', 'LakePRC'], ['p2', 'dlgf_gdb_2025']])
    );
    expect(byParcel.get('p1')).toBe('429');
    expect(byParcel.get('p2')).toBe('402');
  });
});

describe('buildDlgfMergedRows', () => {
  const parcelRows = [
    { ID: 'p1', ParcelNumber: '111', GISParcelNumber: 'g1', Address: '1 Main St', OwnerName: 'Acme', Acreage: 1.5, PropertyClassCode: null, TaxDistrictCode: 'TD1', Latitude: 39.1, Longitude: -86.2, BoundaryGeoJSON: null },
    { ID: 'p2', ParcelNumber: '222', GISParcelNumber: 'g2', Address: '2 Main St', OwnerName: 'Beta', Acreage: 2, PropertyClassCode: null, TaxDistrictCode: 'TD2', Latitude: 39.2, Longitude: -86.3, BoundaryGeoJSON: null },
  ];
  const classRows = [
    { ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401' },
    { ParcelID: 'p2', Source: 'dlgf_gdb_2025', PropertyClassCode: '402' },
  ];

  it('reads the headline AV and labels a placeholder row as the DLGF roll', () => {
    const { rows } = buildDlgfMergedRows([headline('p1', 30000)], parcelRows, classRows, sources, 45, 'lake', 2025, 2000);
    expect(rows).toHaveLength(1);
    expect(rows[0].AssessedTotalAV).toBe(30000);
    expect(rows[0].DataSource).toBe('DLGF statewide roll (placeholder)');
    expect(rows[0].IsPlaceholder).toBe(true);
    expect(rows[0].AssessmentSource).toBe('dlgf_gdb_2025');
    expect(rows[0].PropertyClass).toBe('401');
    expect(rows[0].PropertySubClassDescription).toBe('401');
  });

  it('a county-card headline in a DLGF-path county carries its vintage label', () => {
    const { rows } = buildDlgfMergedRows([headline('p1', 40000, { HeadlineDataSourceID: LAKE_PRC, IsPlaceholder: false, HeadlineDocumentYear: 2026 })], parcelRows, classRows, sources, 45, 'lake', 2025, 2000);
    expect(rows[0].DataSource).toBe('Lake County record card (2026)');
    expect(rows[0].HeadlineDocumentYear).toBe(2026);
    expect(rows[0].IsPlaceholder).toBe(false);
  });

  it('drops a parcel with no matching Parcel row', () => {
    const { rows } = buildDlgfMergedRows([headline('p999', 2)], parcelRows, classRows, sources, 45, 'lake', 2025, 2000);
    expect(rows).toHaveLength(0);
  });

  it('sorts by AV descending and truncates at resultCap with isTruncated: true', () => {
    const { rows, isTruncated } = buildDlgfMergedRows([headline('p1', 100), headline('p2', 900)], parcelRows, classRows, sources, 45, 'lake', 2025, 1);
    expect(rows).toHaveLength(1);
    expect(rows[0].ParcelID).toBe('p2');
    expect(isTruncated).toBe(true);
  });

  it('every produced row carries the one-row-shape contract: CountyAssessorRecordID null, EstimatedSqFt null, non-null DataSource, TaxSource null when untaxed', () => {
    const { rows } = buildDlgfMergedRows([headline('p1', 100), headline('p2', 200)], parcelRows, classRows, sources, 45, 'lake', 2025, 2000);
    expect(rows.length).toBe(2);
    for (const row of rows) {
      expect(row.CountyAssessorRecordID).toBeNull();
      expect(row.EstimatedSqFt).toBeNull();
      expect(row.DataSource).not.toBeNull();
      expect(row.TotalTax).toBeNull();
      expect(row.TaxSource).toBeNull();
    }
  });

  it('populates VerifyURL for a Lake parcel with an 18-digit state parcel number', () => {
    const lakeParcelRows = [{ ...parcelRows[0], ParcelNumber: '450706207002000023' }];
    const { rows } = buildDlgfMergedRows([headline('p1', 100)], lakeParcelRows, classRows, sources, 45, 'lake', 2025, 2000);
    expect(rows[0].VerifyURL).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
  });

  it('leaves VerifyURL null for a county not in XSOFT_ENGAGE_SLUGS', () => {
    const { rows } = buildDlgfMergedRows([headline('p1', 100)], parcelRows, classRows, sources, 29, 'hamilton', 2025, 2000);
    expect(rows[0].VerifyURL).toBeNull();
  });

  it('starts every DLGF row at the empty appeal layers -- all blank, Tax Court included, until a load fills them in', () => {
    const { rows } = buildDlgfMergedRows(
      [headline('P1', 3)],
      [{ ID: 'P1', ParcelNumber: '180000000000000001', Address: '1 Main' }], [], sources, 18, 'delaware', 2025, 10);
    expect(rows[0]).toMatchObject({ TaxCourtDecision: null, IBTRDecisionCount: null, CardRevisedAV: null });
    expect(rows[0].PropertyClass).toBeNull();
  });
});

describe('buildClassCodeSubClassOptions', () => {
  it('formats Code/Label so the existing 3-digit-code resolver still resolves', () => {
    const options = buildClassCodeSubClassOptions([{ Code: '411', Label: 'COM HOTELS' }]);
    expect(options).toEqual([{ text: 'COM HOTELS-411', value: '411' }]);
  });

  it('keeps only the C&I class range the roster is built from (300-499), sorted by code', () => {
    const options = buildClassCodeSubClassOptions([
      { Code: '510', Label: 'RES 1 FAMILY' },
      { Code: '499', Label: 'COM OTHER' },
      { Code: '100', Label: 'VACANT AGRICULTURAL' },
      { Code: '300', Label: 'IND VACANT' },
      { Code: '640', Label: 'EXEMPT' },
      { Code: '411', Label: 'COM HOTELS' },
    ]);
    expect(options.map((o) => o.value)).toEqual(['300', '411', '499']);
  });
});
