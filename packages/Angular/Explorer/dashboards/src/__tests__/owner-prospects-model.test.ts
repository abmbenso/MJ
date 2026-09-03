import { describe, it, expect } from 'vitest';
import {
  computeOwnerProspectsSummary, filterOwnerRows, sortOwnerRows, dominantType,
  formatMoneyShort, prcUrl, taxHistoryUrl, mapOwnerPortfolioRow,
  DEFAULT_OWNER_PROSPECTS_FILTERS, OwnerRow,
} from '../OwnerProspects/owner-prospects.model';

const base: OwnerRow = {
  id: '1', ownerKey: 'acme', label: 'ACME PROPERTIES', kind: 'Company', tier: 'Prime',
  parcelCount: 3, distinctEntities: 2, totalAV: 9_000_000, totalAV2025: 8_000_000, totalAV2026: 9_000_000,
  avYoYDollars: 1_000_000, avYoYPct: 12.5, parcelsUp10: 2, parcelsUp25: 1, totalUnits: 40, totalSqFt: 50_000,
  nAppealRec: 2, nTwoSupport: 1, nHighConfAppeal: 1, estSavingsAtAsk: 120_000, estSavingsAtFloor: 200_000,
  appealedParcels: 1, historicalReductionWon: 500_000, appealYears: '2019–2023', likelyRep: null,
  repStatus: 'No rep on record', repsOnReduction: [], isFreshProspect: true, mailAddress: null,
  coStarTrueOwner: null, byType: { Industrial: { n: 2, av: 6e6 }, Office: { n: 1, av: 3e6 } },
  dominantType: 'Industrial', parcels: [], prospectId: null,
};

/** A complete `Owner Portfolios` RunView('simple') raw row — every Fields column present. */
const rawOwnerRow: Record<string, unknown> = {
  ID: 'op-1', OwnerKey: 'acme', Label: 'ACME PROPERTIES', Kind: 'Company', Tier: 'Prime',
  GroupKeyType: 'CO', CoStarTrueOwner: 'ACME Holdings', ParcelCount: 3, DistinctEntities: 2,
  TotalAV: 9000000, TotalAV2025: 8000000, TotalAV2026: 9000000, AVYoYDollars: 1000000, AVYoYPct: 0.125,
  ParcelsUp10: 2, ParcelsUp25: 1, TotalUnits: 40, TotalSqFt: 50000, NAppealRec: 2, NTwoSupport: 1,
  NHighConfAppeal: 1, EstSavingsAtAsk: 120000, EstSavingsAtFloor: 200000, AppealedParcels: 1,
  HistoricalReductionWon: 500000, AppealYears: '2019-2023', MostRecentAppealYear: 2023,
  LikelyRep: 'Faegre Drinker', RepStatus: 'Represented by FAEGRE DRINKER',
  RepsOnReductionJSON: '["A & B LLC","C Corp"]', IsFreshProspect: 0, MailAddress: '1 Main St',
  ByTypeJSON: '{"Industrial":{"n":2,"av":6000000},"Office":{"n":1,"av":3000000}}',
};

describe('mapOwnerPortfolioRow — RepsOnReductionJSON parsing', () => {
  it('parses the persisted string-array shape into rep names', () => {
    expect(mapOwnerPortfolioRow(rawOwnerRow).repsOnReduction).toEqual(['A & B LLC', 'C Corp']);
  });
  it('returns [] for a malformed JSON value', () => {
    expect(mapOwnerPortfolioRow({ ...rawOwnerRow, RepsOnReductionJSON: 'not json' }).repsOnReduction).toEqual([]);
  });
});

describe('computeOwnerProspectsSummary', () => {
  it('sums company rows and counts tiers', () => {
    const s = computeOwnerProspectsSummary([base, { ...base, id: '2', tier: 'Strong', estSavingsAtAsk: 160_000, isFreshProspect: false }]);
    expect(s.companyOwners).toBe(2);
    expect(s.oppAsk).toBe(280_000);
    expect(s.freshOpp).toBe(120_000);
    expect(s.prime).toBe(1);
    expect(s.strong).toBe(1);
  });
});

describe('filterOwnerRows', () => {
  it('rep=none keeps only "No rep on record"', () => {
    const repped: OwnerRow = { ...base, id: '2', repStatus: 'Represented by FAEGRE DRINKER' };
    const out = filterOwnerRows([base, repped], { ...DEFAULT_OWNER_PROSPECTS_FILTERS, rep: 'none' });
    expect(out.map((o) => o.id)).toEqual(['1']);
  });
  it('minOppPerYear excludes below the threshold', () => {
    const out = filterOwnerRows([base], { ...DEFAULT_OWNER_PROSPECTS_FILTERS, minOppPerYear: 150_000 });
    expect(out).toHaveLength(0);
  });
  it('query matches label or rep, case-insensitive', () => {
    expect(filterOwnerRows([base], { ...DEFAULT_OWNER_PROSPECTS_FILTERS, query: 'acme' })).toHaveLength(1);
    expect(filterOwnerRows([base], { ...DEFAULT_OWNER_PROSPECTS_FILTERS, query: 'zzz' })).toHaveLength(0);
  });
});

describe('sortOwnerRows', () => {
  it('sorts nulls last regardless of direction', () => {
    const a = { ...base, id: 'a', estSavingsAtAsk: 100 };
    const b = { ...base, id: 'b', estSavingsAtAsk: null };
    expect(sortOwnerRows([b, a], 'estSavingsAtAsk', -1).map((o) => o.id)).toEqual(['a', 'b']);
    expect(sortOwnerRows([a, b], 'estSavingsAtAsk', 1).map((o) => o.id)).toEqual(['a', 'b']);
  });
});

describe('formatters + urls', () => {
  it('formatMoneyShort', () => {
    expect(formatMoneyShort(1.23e9)).toBe('$1.23B');
    expect(formatMoneyShort(3.4e6)).toBe('$3.4M');
    expect(formatMoneyShort(12_345)).toBe('$12,345');
    expect(formatMoneyShort(null)).toBe('—');
  });
  it('dominantType picks the largest av bucket', () => {
    expect(dominantType(base.byType)).toBe('Industrial');
  });
  it('prc/tax urls carry the parcel number', () => {
    expect(prcUrl('1097651')).toContain('ParcelNumber=1097651');
    expect(taxHistoryUrl('1097651')).toContain('TaxHistoryReportPage');
  });
});
