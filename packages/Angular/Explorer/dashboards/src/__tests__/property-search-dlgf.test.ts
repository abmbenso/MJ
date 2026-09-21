import { describe, it, expect } from 'vitest';
import {
  buildDlgfAssessmentFilter,
  buildDlgfParcelSearchFilter,
  buildDlgfMergedRows,
  buildClassCodeSubClassOptions,
  resolveDlgfTopParcelIds,
  DlgfSearchParams,
} from '../PropertySearch/property-search-dlgf';
import { CI_CLASS_CODE_FILTER } from '../PropertySearch/property-search-county';

/**
 * Task 3 brief: proposals/multi-county-ci-intake.md §6 (two data paths, one row shape).
 * This module is pure and framework-free -- no RunView, no Angular -- so every case here is
 * a plain function call, matching the property-search-county.test.ts convention.
 */

const baseParams: DlgfSearchParams = {
  countyNumber: 45,
  slug: 'lake',
  assessmentYear: 2025,
  searchTerm: '',
  propertyClassCode: null,
  resultCap: 2000,
};

describe('buildDlgfAssessmentFilter', () => {
  it('contains the county subquery, the year, and CI_CLASS_CODE_FILTER', () => {
    const filter = buildDlgfAssessmentFilter(baseParams, null);
    expect(filter).toContain('AssessmentYear = 2025');
    expect(filter).toContain('CountyNumber = 45');
    expect(filter).toContain(CI_CLASS_CODE_FILTER);
  });

  it('yields 1=0 (never an unfiltered query) when parcelIdConstraint is an empty array', () => {
    const filter = buildDlgfAssessmentFilter(baseParams, []);
    expect(filter).toContain('1=0');
  });

  it('escapes a class code containing an apostrophe', () => {
    const filter = buildDlgfAssessmentFilter({ ...baseParams, propertyClassCode: "4'11" }, null);
    expect(filter).toContain("PropertyClassCode = '4''11'");
  });

  it('applies a search-term-classified 3-digit code (finding 4) even with no dropdown propertyClassCode set', () => {
    const filter = buildDlgfAssessmentFilter(baseParams, null, '411');
    expect(filter).toContain("PropertyClassCode = '411'");
  });

  it('applies both the dropdown propertyClassCode and a search-term code when both are set', () => {
    const filter = buildDlgfAssessmentFilter({ ...baseParams, propertyClassCode: '401' }, null, '411');
    expect(filter).toContain("PropertyClassCode = '401'");
    expect(filter).toContain("PropertyClassCode = '411'");
  });

  it('omits the search-term clause entirely when no code is classified (null/undefined)', () => {
    // CI_CLASS_CODE_FILTER itself mentions PropertyClassCode twice (the class-range check) --
    // this asserts no THIRD occurrence is added when neither the dropdown nor a classified
    // search term supplies a code.
    const filter = buildDlgfAssessmentFilter(baseParams, null, null);
    expect(filter.match(/PropertyClassCode/g)).toHaveLength(2);
    expect(filter).not.toContain('PropertyClassCode = ');
  });
});

describe('resolveDlgfTopParcelIds (finding 6)', () => {
  it('caps the returned ids to resultCap, keeping the highest-AV winners', () => {
    const rows = [
      { ParcelID: 'p1', Source: 'dlgf_gdb_2025', OriginalTotalAV: 100 },
      { ParcelID: 'p2', Source: 'dlgf_gdb_2025', OriginalTotalAV: 900 },
      { ParcelID: 'p3', Source: 'dlgf_gdb_2025', OriginalTotalAV: 500 },
    ];
    const { ids, totalDistinctCount } = resolveDlgfTopParcelIds(rows, 45, 2);
    expect(ids).toEqual(['p2', 'p3']);
    expect(totalDistinctCount).toBe(3);
  });

  it('resolves precedence per parcel BEFORE ranking -- a county PRC row beats a higher-AV DLGF row for the same parcel', () => {
    const rows = [
      { ParcelID: 'p1', Source: 'dlgf_gdb_2025', OriginalTotalAV: 900 },
      { ParcelID: 'p1', Source: 'LakePRC', OriginalTotalAV: 400 },
      { ParcelID: 'p2', Source: 'dlgf_gdb_2025', OriginalTotalAV: 500 },
    ];
    const { ids, totalDistinctCount } = resolveDlgfTopParcelIds(rows, 45, 2);
    expect(totalDistinctCount).toBe(2);
    // p1's winning row is the LakePRC one (AV 400), so p2 (AV 500) outranks it.
    expect(ids).toEqual(['p2', 'p1']);
  });

  it('returns every id (no truncation) when the distinct count is under resultCap', () => {
    const rows = [{ ParcelID: 'p1', Source: 'dlgf_gdb_2025', OriginalTotalAV: 100 }];
    const { ids, totalDistinctCount } = resolveDlgfTopParcelIds(rows, 45, 2000);
    expect(ids).toEqual(['p1']);
    expect(totalDistinctCount).toBe(1);
  });
});

describe('buildDlgfParcelSearchFilter', () => {
  it('freeText searches both OwnerName and Address', () => {
    const filter = buildDlgfParcelSearchFilter(45, 'Acme', 'freeText');
    expect(filter).toContain('OwnerName LIKE');
    expect(filter).toContain('Address LIKE');
    expect(filter).toContain('CountyNumber = 45');
  });

  it('subClassCode returns null -- handled on the Assessment side', () => {
    expect(buildDlgfParcelSearchFilter(45, '411', 'subClassCode')).toBeNull();
  });
});

describe('buildDlgfMergedRows', () => {
  const parcelRows = [
    { ID: 'p1', ParcelNumber: '111', GISParcelNumber: 'g1', Address: '1 Main St', OwnerName: 'Acme', Acreage: 1.5, PropertyClassCode: '401', TaxDistrictCode: 'TD1', Latitude: 39.1, Longitude: -86.2, BoundaryGeoJSON: null },
    { ID: 'p2', ParcelNumber: '222', GISParcelNumber: 'g2', Address: '2 Main St', OwnerName: 'Beta', Acreage: 2, PropertyClassCode: '402', TaxDistrictCode: 'TD2', Latitude: 39.2, Longitude: -86.3, BoundaryGeoJSON: null },
  ];

  it('collapses two Assessment rows for one parcel to the higher-precedence AV and DataSource', () => {
    const assessmentRows = [
      { ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 10000, OriginalImprovementAV: 20000, OriginalTotalAV: 30000 },
      { ParcelID: 'p1', Source: 'LakePRC', PropertyClassCode: '401', OriginalLandAV: 15000, OriginalImprovementAV: 25000, OriginalTotalAV: 40000 },
    ];
    const { rows } = buildDlgfMergedRows(assessmentRows, parcelRows, [], 45, 'lake', 2025, 2000);
    expect(rows).toHaveLength(1);
    expect(rows[0].AssessedTotalAV).toBe(40000);
    expect(rows[0].DataSource).toBe('County record card');
  });

  it('drops a parcel with no matching Parcel row', () => {
    const assessmentRows = [{ ParcelID: 'p999', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 2 }];
    const { rows } = buildDlgfMergedRows(assessmentRows, parcelRows, [], 45, 'lake', 2025, 2000);
    expect(rows).toHaveLength(0);
  });

  it('sorts by AV descending and truncates at resultCap with isTruncated: true', () => {
    const assessmentRows = [
      { ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 100 },
      { ParcelID: 'p2', Source: 'dlgf_gdb_2025', PropertyClassCode: '402', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 900 },
    ];
    const { rows, isTruncated } = buildDlgfMergedRows(assessmentRows, parcelRows, [], 45, 'lake', 2025, 1);
    expect(rows).toHaveLength(1);
    expect(rows[0].ParcelID).toBe('p2');
    expect(isTruncated).toBe(true);
  });

  it('every produced row carries the one-row-shape contract: CountyAssessorRecordID null, EstimatedSqFt null, non-null DataSource', () => {
    const assessmentRows = [
      { ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 100 },
      { ParcelID: 'p2', Source: 'dlgf_gdb_2025', PropertyClassCode: '402', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 200 },
    ];
    const { rows } = buildDlgfMergedRows(assessmentRows, parcelRows, [], 45, 'lake', 2025, 2000);
    expect(rows.length).toBeGreaterThan(0);
    for (const row of rows) {
      expect(row.CountyAssessorRecordID).toBeNull();
      expect(row.EstimatedSqFt).toBeNull();
      expect(row.DataSource).not.toBeNull();
    }
  });

  it('populates VerifyURL for a Lake parcel with an 18-digit state parcel number', () => {
    const assessmentRows = [{ ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 100 }];
    const lakeParcelRows = [{ ...parcelRows[0], ParcelNumber: '450706207002000023' }];
    const { rows } = buildDlgfMergedRows(assessmentRows, lakeParcelRows, [], 45, 'lake', 2025, 2000);
    expect(rows[0].VerifyURL).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
  });

  it('leaves VerifyURL null for a county not in XSOFT_ENGAGE_SLUGS', () => {
    const assessmentRows = [{ ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401', OriginalLandAV: 1, OriginalImprovementAV: 1, OriginalTotalAV: 100 }];
    const { rows } = buildDlgfMergedRows(assessmentRows, parcelRows, [], 29, 'hamilton', 2025, 2000);
    expect(rows[0].VerifyURL).toBeNull();
  });

  it('starts every DLGF row at the empty appeal layers (Tax Court N, everything else null)', () => {
    const { rows } = buildDlgfMergedRows(
      [{ ParcelID: 'P1', Source: 'dlgf_gdb_2025', PropertyClassCode: '429', OriginalLandAV: 1, OriginalImprovementAV: 2, OriginalTotalAV: 3 }],
      [{ ID: 'P1', ParcelNumber: '180000000000000001', Address: '1 Main' }], [], 18, 'delaware', 2025, 10);
    expect(rows[0]).toMatchObject({ TaxCourtDecision: 'N', IBTRDecisionCount: null, CardRevisedAV: null });
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
