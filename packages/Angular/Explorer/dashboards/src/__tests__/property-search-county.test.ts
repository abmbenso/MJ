import { describe, it, expect } from 'vitest';
import {
  MARION_COUNTY_NUMBER,
  DLGF_SOURCE,
  MARION_FOIA_SOURCE,
  COUNTY_CARD_SOURCE,
  countyCardSource,
  countySourceTier,
  assessmentSourceRank,
  pickAssessmentRow,
  dataSourceLabel,
  isDlgfSourced,
  DLGF_NOTATION,
  buildCountyOptions,
  tallyCIParcels,
  CI_CLASS_CODE_FILTER,
  CI_ROSTER_PARCEL_FILTER,
  XSOFT_ENGAGE_SLUGS,
  toDashedStateParcel,
  xsoftCardUrl,
  buildVerifyLink,
} from '../PropertySearch/property-search-county';

/**
 * Task 1 brief: proposals/multi-county-ci-intake.md §4.3 (precedence) and §6 (source tier,
 * DLGF notation, verify links). This module is pure and framework-free -- no RunView, no
 * Angular -- so every case here is a plain function call.
 */

describe('county identity + source tier', () => {
  it('knows the card source for the three onboarded counties, null otherwise', () => {
    expect(countyCardSource(45)).toBe('LakePRC');
    expect(countyCardSource(49)).toBe('MarionPRC');
    expect(countyCardSource(71)).toBe('StJosephPRC');
    expect(countyCardSource(1)).toBeNull();
  });

  it('tiers a county PRC county as County PRC, everything else as DLGF only', () => {
    expect(countySourceTier(45)).toBe('County PRC');
    expect(countySourceTier(49)).toBe('County PRC');
    expect(countySourceTier(71)).toBe('County PRC');
    expect(countySourceTier(1)).toBe('DLGF only');
  });

  it('MARION_COUNTY_NUMBER / DLGF_SOURCE / MARION_FOIA_SOURCE / COUNTY_CARD_SOURCE are the agreed constants', () => {
    expect(MARION_COUNTY_NUMBER).toBe(49);
    expect(DLGF_SOURCE).toBe('dlgf_gdb_2025');
    expect(MARION_FOIA_SOURCE).toBe('marion_foia_2026');
    expect(COUNTY_CARD_SOURCE).toEqual({ 45: 'LakePRC', 49: 'MarionPRC', 71: 'StJosephPRC' });
  });
});

describe('assessmentSourceRank', () => {
  it('ranks a source only as its OWN county\'s card source -- the bug this ordering prevents', () => {
    // LakePRC is county 45's card source: rank 3 there.
    expect(assessmentSourceRank('LakePRC', 45)).toBe(3);
    // But LakePRC is NOT county 49's (Marion's) card source -- an unrecognised source for
    // Marion, so it falls to 0, never masquerading as Marion's own card data.
    expect(assessmentSourceRank('LakePRC', 49)).toBe(0);
  });

  it('ranks marion_foia_2026 as 2 and dlgf_gdb_2025 as 1, for any county', () => {
    expect(assessmentSourceRank('marion_foia_2026', 49)).toBe(2);
    expect(assessmentSourceRank('dlgf_gdb_2025', 45)).toBe(1);
  });

  it('ranks null/missing as -1 (nothing at all), and an unrecognised source as 0', () => {
    expect(assessmentSourceRank(null, 49)).toBe(-1);
    expect(assessmentSourceRank('apra_lake_2027', 45)).toBe(0);
  });
});

describe('pickAssessmentRow', () => {
  const dlgfRow = { Source: 'dlgf_gdb_2025', OriginalTotalAV: 100000 };
  const marionRow = { Source: 'MarionPRC', OriginalTotalAV: 250000 };
  const foiaRow = { Source: 'marion_foia_2026', OriginalTotalAV: 180000 };

  it('a DLGF row already held loses to a MarionPRC candidate', () => {
    expect(pickAssessmentRow(dlgfRow, marionRow, 49)).toBe(marionRow);
  });

  it('in reverse order -- MarionPRC already held -- MarionPRC still wins over the DLGF candidate', () => {
    expect(pickAssessmentRow(marionRow, dlgfRow, 49)).toBe(marionRow);
  });

  it('marion_foia_2026 beats dlgf_gdb_2025', () => {
    expect(pickAssessmentRow(dlgfRow, foiaRow, 49)).toBe(foiaRow);
  });

  it('marion_foia_2026 loses to MarionPRC', () => {
    expect(pickAssessmentRow(foiaRow, marionRow, 49)).toBe(marionRow);
  });

  it('a tie keeps existing (first-write-wins, stable under a stable query order)', () => {
    const firstDlgf = { Source: 'dlgf_gdb_2025', OriginalTotalAV: 100000 };
    const secondDlgf = { Source: 'dlgf_gdb_2025', OriginalTotalAV: 999999 };
    expect(pickAssessmentRow(firstDlgf, secondDlgf, 49)).toBe(firstDlgf);
  });

  it('with nothing held yet, the candidate always wins', () => {
    expect(pickAssessmentRow(undefined, dlgfRow, 49)).toBe(dlgfRow);
  });
});

describe('dataSourceLabel', () => {
  it('no source at all -> No assessment on file', () => {
    expect(dataSourceLabel(null, 49)).toBe('No assessment on file');
  });

  it('DLGF statewide source -> DLGF statewide file', () => {
    expect(dataSourceLabel('dlgf_gdb_2025', 45)).toBe('DLGF statewide file');
  });

  it("a county's own card source -> County record card", () => {
    expect(dataSourceLabel('StJosephPRC', 71)).toBe('County record card');
  });

  it('Marion FOIA source -> County FOIA list', () => {
    expect(dataSourceLabel('marion_foia_2026', 49)).toBe('County FOIA list');
  });

  it('an unrecognised source still resolves to DLGF statewide file (rank 0)', () => {
    expect(dataSourceLabel('apra_lake_2027', 45)).toBe('DLGF statewide file');
  });
});

describe('isDlgfSourced', () => {
  it('true only for the DLGF statewide file label', () => {
    expect(isDlgfSourced('DLGF statewide file')).toBe(true);
    expect(isDlgfSourced('County record card')).toBe(false);
    expect(isDlgfSourced('County FOIA list')).toBe(false);
    expect(isDlgfSourced('No assessment on file')).toBe(false);
  });
});

describe('DLGF_NOTATION', () => {
  it('matches spec §6 verbatim -- pinned so a wording edit is a failing test, not silent drift', () => {
    expect(DLGF_NOTATION).toBe(
      'Source: Indiana DLGF statewide parcel file — assessment year 2025, as initially determined. ' +
        'This is not the county\'s property record card. Data runs through AY2025.',
    );
  });

  it('is the one string the banner, the export header row and the export column tooltip all read', () => {
    expect(DLGF_NOTATION).toContain('as initially determined');
    expect(DLGF_NOTATION).toContain("not the county's property record card");
    expect(DLGF_NOTATION).toContain('through AY2025');
  });
});

describe('buildCountyOptions', () => {
  const countyRows: Record<string, unknown>[] = [
    { CountyNumber: 45, Name: 'Lake', Slug: 'lake' },
    { CountyNumber: 1, Name: 'Adams', Slug: 'adams' },
    { CountyNumber: 49, Name: 'Marion', Slug: 'marion' },
  ];

  it('labels a County PRC county with its C&I count and tier', () => {
    const ciCountByCounty = new Map<number, number>([[45, 15001]]);
    const options = buildCountyOptions(countyRows, ciCountByCounty);
    const lake = options.find((o) => o.CountyNumber === 45)!;
    expect(lake.Label).toBe('Lake — 15,001 C&I · County PRC');
    expect(lake.Tier).toBe('County PRC');
    expect(lake.CICount).toBe(15001);
  });

  it('labels a DLGF-only county with its C&I count and tier', () => {
    const ciCountByCounty = new Map<number, number>([[1, 412]]);
    const options = buildCountyOptions(countyRows, ciCountByCounty);
    const adams = options.find((o) => o.CountyNumber === 1)!;
    expect(adams.Label).toBe('Adams — 412 C&I · DLGF only');
    expect(adams.Tier).toBe('DLGF only');
  });

  it('a county missing from the tally gets "count unavailable", never "0 C&I"', () => {
    const ciCountByCounty = new Map<number, number>([[45, 15001]]);
    const options = buildCountyOptions(countyRows, ciCountByCounty);
    const marion = options.find((o) => o.CountyNumber === 49)!;
    expect(marion.Label).toBe('Marion — count unavailable · County PRC');
    expect(marion.CICount).toBeNull();
  });

  it('sorts by name, not by county number', () => {
    const options = buildCountyOptions(countyRows, new Map());
    expect(options.map((o) => o.Name)).toEqual(['Adams', 'Lake', 'Marion']);
  });
});

describe('tallyCIParcels', () => {
  it('counts parcels per county', () => {
    const rows = [{ CountyNumber: 45 }, { CountyNumber: 45 }, { CountyNumber: 49 }];
    const tally = tallyCIParcels(rows);
    expect(tally.get(45)).toBe(2);
    expect(tally.get(49)).toBe(1);
  });

  it('skips rows with a non-number CountyNumber rather than throwing', () => {
    const rows = [{ CountyNumber: 45 }, { CountyNumber: null }, { CountyNumber: 'x' }];
    const tally = tallyCIParcels(rows as Record<string, unknown>[]);
    expect(tally.get(45)).toBe(1);
    expect(tally.size).toBe(1);
  });
});

describe('CI_CLASS_CODE_FILTER', () => {
  it('is the 300-499 class range', () => {
    expect(CI_CLASS_CODE_FILTER).toBe("PropertyClassCode >= '300' AND PropertyClassCode <= '499'");
  });
});

describe('CI_ROSTER_PARCEL_FILTER', () => {
  it('keys the county tally on the AY2025 DLGF assessment row, not on Parcel.PropertyClassCode (NULL everywhere)', () => {
    expect(CI_ROSTER_PARCEL_FILTER).toBe(
      "ID IN (SELECT ParcelID FROM indiana_tax.vwAssessments WHERE Source = 'dlgf_gdb_2025' AND PropertyClassCode >= '300' AND PropertyClassCode <= '499')"
    );
  });
});

describe('XSOFT_ENGAGE_SLUGS', () => {
  it('carries the two S0-confirmed slugs', () => {
    expect(XSOFT_ENGAGE_SLUGS.has('lake')).toBe(true);
    expect(XSOFT_ENGAGE_SLUGS.has('stjoseph')).toBe(true);
    expect(XSOFT_ENGAGE_SLUGS.has('hamilton')).toBe(false);
  });
});

describe('toDashedStateParcel', () => {
  it('dashes an 18-digit state parcel number', () => {
    expect(toDashedStateParcel('450706207002000023')).toBe('45-07-06-207-002.000-023');
  });

  it('returns null for a 17-digit string', () => {
    expect(toDashedStateParcel('45070620700200002')).toBeNull();
  });

  it('a value already dashed round-trips to itself (digits are re-extracted then re-dashed)', () => {
    expect(toDashedStateParcel('45-07-06-207-002.000-023')).toBe('45-07-06-207-002.000-023');
  });

  it('returns null for null input', () => {
    expect(toDashedStateParcel(null)).toBeNull();
  });
});

describe('xsoftCardUrl', () => {
  it('builds the engageblob URL', () => {
    expect(xsoftCardUrl('lake', '45-07-06-207-002.000-023', 2025)).toBe(
      'https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf',
    );
  });
});

describe('buildVerifyLink', () => {
  it('Marion with a GIS number -> the maps.indy.gov PRC URL', () => {
    const link = buildVerifyLink({
      countyNumber: MARION_COUNTY_NUMBER,
      slug: 'marion',
      parcelNumber: null,
      gisParcelNumber: '9003241',
      assessmentYear: 2025,
    });
    expect(link.url).toBe('https://maps.indy.gov/AssessorPropertyCards.Reports.Service/ReportPage.aspx?ParcelNumber=9003241');
    expect(link.label).toBe('Property Record Card');
    expect(link.note).toBe('Marion County Assessor');
  });

  it('Marion with no GIS number -> null url and the exact "not on file" note', () => {
    const link = buildVerifyLink({
      countyNumber: MARION_COUNTY_NUMBER,
      slug: 'marion',
      parcelNumber: null,
      gisParcelNumber: null,
      assessmentYear: 2025,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });

  it('Lake with an 18-digit parcel and year 2025 -> the xSoft Engage blob URL', () => {
    const link = buildVerifyLink({
      countyNumber: 45,
      slug: 'lake',
      parcelNumber: '450706207002000023',
      gisParcelNumber: null,
      assessmentYear: 2025,
    });
    expect(link.url).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
    expect(link.label).toBe('Record Card (AY2025)');
    expect(link.note).toBe('xSoft Engage');
  });

  it('Hamilton (not in the xSoft set) -> null url and the "not on file" note', () => {
    const link = buildVerifyLink({
      countyNumber: 29,
      slug: 'hamilton',
      parcelNumber: '290000000000000000',
      gisParcelNumber: null,
      assessmentYear: 2025,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });

  it('an xSoft county with no assessment year -> null url (the blob path is year-addressed)', () => {
    const link = buildVerifyLink({
      countyNumber: 71,
      slug: 'stjoseph',
      parcelNumber: '710115400008000017',
      gisParcelNumber: null,
      assessmentYear: null,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });

  it('an xSoft county with an unparsable parcel number -> null url, not a broken link', () => {
    const link = buildVerifyLink({
      countyNumber: 45,
      slug: 'lake',
      parcelNumber: 'not-a-parcel',
      gisParcelNumber: null,
      assessmentYear: 2025,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });
});
