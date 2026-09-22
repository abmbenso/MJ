import { describe, it, expect } from 'vitest';
import {
  MARION_COUNTY_NUMBER,
  DLGF_SOURCE,
  MARION_FOIA_SOURCE,
  COUNTY_CARD_SOURCE,
  countyCardSource,
  countySourceTier,
  DLGF_NOTATION,
  buildCountyOptions,
  tallyCIParcels,
  CI_CLASS_CODE_FILTER,
  CI_ROSTER_PARCEL_FILTER,
  XSOFT_ENGAGE_SLUGS,
  SINGLE_URL_VENDOR_SLUGS,
  toDashedStateParcel,
  xsoftCardUrl,
  acimapCardUrl,
  elevateMapsCardUrl,
  buildVerifyLink,
} from '../PropertySearch/property-search-county';

/**
 * Task 1 brief: proposals/multi-county-ci-intake.md §4.3 (precedence) and §6 (source tier,
 * DLGF notation, verify links). This module is pure and framework-free -- no RunView, no
 * Angular -- so every case here is a plain function call.
 */

describe('county identity + source tier', () => {
  it('knows the card source for the seventeen onboarded counties, null otherwise', () => {
    expect(countyCardSource(2)).toBe('AllenPRC');
    expect(countyCardSource(45)).toBe('LakePRC');
    expect(countyCardSource(49)).toBe('MarionPRC');
    expect(countyCardSource(71)).toBe('StJosephPRC');
    expect(countyCardSource(82)).toBe('VanderburghPRC');
    expect(countyCardSource(10)).toBe('ClarkPRC');
    expect(countyCardSource(64)).toBe('PorterPRC');
    expect(countyCardSource(32)).toBe('HendricksPRC');
    expect(countyCardSource(17)).toBe('DeKalbPRC');
    expect(countyCardSource(87)).toBe('WarrickPRC');
    expect(countyCardSource(42)).toBe('KnoxPRC');
    expect(countyCardSource(73)).toBe('ShelbyPRC');
    expect(countyCardSource(14)).toBe('DaviessPRC');
    expect(countyCardSource(68)).toBe('RandolphPRC');
    expect(countyCardSource(65)).toBe('PoseyPRC');
    expect(countyCardSource(23)).toBe('FountainPRC');
    expect(countyCardSource(20)).toBe('ElkhartPRC');
    expect(countyCardSource(88)).toBe('WashingtonPRC');
    expect(countyCardSource(1)).toBeNull();
  });

  it('tiers a county PRC county as County PRC, everything else as DLGF only', () => {
    expect(countySourceTier(2)).toBe('County PRC');
    expect(countySourceTier(45)).toBe('County PRC');
    expect(countySourceTier(49)).toBe('County PRC');
    expect(countySourceTier(71)).toBe('County PRC');
    expect(countySourceTier(1)).toBe('DLGF only');
  });

  it('MARION_COUNTY_NUMBER / DLGF_SOURCE / MARION_FOIA_SOURCE / COUNTY_CARD_SOURCE are the agreed constants', () => {
    expect(MARION_COUNTY_NUMBER).toBe(49);
    expect(DLGF_SOURCE).toBe('dlgf_gdb_2025');
    expect(MARION_FOIA_SOURCE).toBe('marion_foia_2026');
    expect(COUNTY_CARD_SOURCE).toEqual({
      2: 'AllenPRC', 45: 'LakePRC', 49: 'MarionPRC', 71: 'StJosephPRC',
      82: 'VanderburghPRC', 10: 'ClarkPRC', 64: 'PorterPRC', 32: 'HendricksPRC', 17: 'DeKalbPRC',
      87: 'WarrickPRC', 42: 'KnoxPRC', 73: 'ShelbyPRC', 14: 'DaviessPRC', 68: 'RandolphPRC',
      65: 'PoseyPRC', 23: 'FountainPRC', 20: 'ElkhartPRC', 88: 'WashingtonPRC',
    });
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
  it('carries all fifteen S0-confirmed slugs', () => {
    for (const slug of ['lake', 'stjoseph', 'vanderburgh', 'clark', 'porter', 'hendricks', 'dekalb',
                         'warrick', 'knox', 'shelby', 'daviess', 'randolph', 'posey', 'fountain', 'washington']) {
      expect(XSOFT_ENGAGE_SLUGS.has(slug)).toBe(true);
    }
    expect(XSOFT_ENGAGE_SLUGS.has('hamilton')).toBe(false);
    expect(XSOFT_ENGAGE_SLUGS.has('allen')).toBe(false); // Allen is SINGLE_URL_VENDOR_SLUGS, not xSoft
    expect(XSOFT_ENGAGE_SLUGS.has('elkhart')).toBe(false); // so is Elkhart
  });
});

describe('SINGLE_URL_VENDOR_SLUGS', () => {
  it('carries both single-static-URL vendor slugs', () => {
    expect(SINGLE_URL_VENDOR_SLUGS.has('allen')).toBe(true);
    expect(SINGLE_URL_VENDOR_SLUGS.has('elkhart')).toBe(true);
    expect(SINGLE_URL_VENDOR_SLUGS.has('lake')).toBe(false);
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

  it('Washington (xSoft, card year ahead of the DLGF roster) with an 18-digit parcel -> the xSoft Engage blob URL for the requested year', () => {
    const link = buildVerifyLink({
      countyNumber: 88,
      slug: 'washington',
      parcelNumber: '882418224004000022',
      gisParcelNumber: null,
      assessmentYear: 2026,
    });
    expect(link.url).toBe('https://engageblob.blob.core.windows.net/washington/pdf/2026/88-24-18-224-004.000-022.pdf');
    expect(link.label).toBe('Record Card (AY2026)');
    expect(link.note).toBe('xSoft Engage');
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

  it('Allen (single-URL vendor) with an 18-digit parcel -> the acimap.us URL, year-independent', () => {
    const link = buildVerifyLink({
      countyNumber: 2,
      slug: 'allen',
      parcelNumber: '021617100003000048',
      gisParcelNumber: null,
      assessmentYear: 2024, // deliberately NOT the card's current year -- the link ignores it
    });
    expect(link.url).toBe('https://acimap.us/website/prc/021617100003000048.pdf');
    expect(link.label).toBe('Record Card (current)');
    expect(link.note).toBe("the county's own site");
  });

  it('Allen with no assessment year at all still builds the link (unlike the xSoft branch)', () => {
    const link = buildVerifyLink({
      countyNumber: 2,
      slug: 'allen',
      parcelNumber: '021617100003000048',
      gisParcelNumber: null,
      assessmentYear: null,
    });
    expect(link.url).toBe('https://acimap.us/website/prc/021617100003000048.pdf');
  });

  it('Allen with an unparsable parcel number -> null url, not a broken link', () => {
    const link = buildVerifyLink({
      countyNumber: 2,
      slug: 'allen',
      parcelNumber: 'not-a-parcel',
      gisParcelNumber: null,
      assessmentYear: null,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });

  it('Elkhart (single-URL vendor, second vendor) with an 18-digit parcel -> the dashed Elevate Maps URL', () => {
    const link = buildVerifyLink({
      countyNumber: 20,
      slug: 'elkhart',
      parcelNumber: '200319200010000030',
      gisParcelNumber: null,
      assessmentYear: 2025, // deliberately not the card's own AY2024 -- the link ignores it
    });
    expect(link.url).toBe('https://s3.amazonaws.com/assets.elevatemaps.io/ElkhartIN/PRC/20-03-19-200-010.000-030.pdf');
    expect(link.label).toBe('Record Card (current)');
    expect(link.note).toBe("the county's own site");
  });

  it('Elkhart with an unparsable parcel number -> null url, not a broken link', () => {
    const link = buildVerifyLink({
      countyNumber: 20,
      slug: 'elkhart',
      parcelNumber: 'not-a-parcel',
      gisParcelNumber: null,
      assessmentYear: null,
    });
    expect(link.url).toBeNull();
    expect(link.note).toBe('not on file — verify at the county');
  });
});

describe('acimapCardUrl', () => {
  it('builds the static, year-less, undashed URL', () => {
    expect(acimapCardUrl('021617100003000048')).toBe('https://acimap.us/website/prc/021617100003000048.pdf');
  });
});

describe('elevateMapsCardUrl', () => {
  it('builds the static, year-less, DASHED URL (unlike acimap.us)', () => {
    expect(elevateMapsCardUrl('20-03-19-200-010.000-030')).toBe(
      'https://s3.amazonaws.com/assets.elevatemaps.io/ElkhartIN/PRC/20-03-19-200-010.000-030.pdf',
    );
  });
});
