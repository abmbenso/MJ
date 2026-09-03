import { describe, it, expect } from 'vitest';
import {
  computeOwnerProspectsSummary, filterOwnerRows, sortOwnerRows, dominantType,
  formatMoneyShort, prcUrl, taxHistoryUrl, mapOwnerPortfolioRow, buildBannerModel,
  buildVisibleRows, sanitizeFilters, KNOWN_SORT_KEYS,
  DEFAULT_OWNER_PROSPECTS_FILTERS, OwnerRow, CountyRollup,
  buildOwnerProspectsAgentContext, OwnerProspectsAgentContextState,
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

const rollup: CountyRollup = {
  parcels: 10126, totalAV2025: 28.8e9, totalAV2026: 33.2e9, yoyDollars: 4.4e9, yoyPct: 15.2,
  parcelsUp5: 9000, parcelsUp10: 8941, parcelsUp25: 3000, parcelsUp50: 900, parcelsDown: 400,
  runDate: '2026-08-15', methodologyVersion: 'v3',
  byType: {
    Office: { n: 200, av2025: 8e9, av2026: 8.4e9, yoyPct: 5.0 },
    Industrial: { n: 100, av2025: 5e9, av2026: 6.25e9, yoyPct: 25.1 },
    Retail: { n: 150, av2025: 6e9, av2026: 7.2e9, yoyPct: 20.0 },
    Apartment: { n: 80, av2025: 4e9, av2026: 5.6e9, yoyPct: 40.0 },
    Warehouse: { n: 50, av2025: 3e9, av2026: 3.3e9, yoyPct: null },
  },
};

describe('buildBannerModel', () => {
  it('formats the one-year C&I rollup line', () => {
    const b = buildBannerModel(rollup);
    expect(b.av2025).toBe('$28.80B');
    expect(b.av2026).toBe('$33.20B');
    expect(b.yoyPct).toBe('+15.2%');
    expect(b.yoyLine).toBe('$4.40B · 10,126 parcels');
  });

  it('takes the top 4 byType entries by av2026 descending', () => {
    const b = buildBannerModel(rollup);
    expect(b.breakChips.map((c) => c.label)).toEqual(['Office', 'Retail', 'Industrial', 'Apartment']);
    expect(b.breakChips.some((c) => c.label === 'Industrial' && c.value === '+25.1%')).toBe(true);
  });

  it('signs positive percentages and dashes a null yoyPct', () => {
    const b = buildBannerModel({
      ...rollup,
      byType: { A: { n: 1, av2025: 1, av2026: 9, yoyPct: null }, B: { n: 1, av2025: 1, av2026: 1, yoyPct: -3.2 } },
    });
    expect(b.breakChips.find((c) => c.label === 'A')?.value).toBe('—');
    expect(b.breakChips.find((c) => c.label === 'B')?.value).toBe('-3.2%');
  });

  it('does not prefix a non-positive top-level yoyPct with a plus', () => {
    expect(buildBannerModel({ ...rollup, yoyPct: 0 }).yoyPct).toBe('0%');
    expect(buildBannerModel({ ...rollup, yoyPct: -4.1 }).yoyPct).toBe('-4.1%');
  });
});

describe('buildVisibleRows', () => {
  it('filters then sorts', () => {
    const rows = [
      { ...base, id: 'a', estSavingsAtAsk: 50_000, repStatus: 'No rep on record' },
      { ...base, id: 'b', estSavingsAtAsk: 300_000, repStatus: 'No rep on record' },
      { ...base, id: 'c', estSavingsAtAsk: 300_000, repStatus: 'Represented by X' },
    ] as OwnerRow[];
    const out = buildVisibleRows(
      rows,
      { ...DEFAULT_OWNER_PROSPECTS_FILTERS, rep: 'none', minOppPerYear: 100_000 },
      'estSavingsAtAsk',
      -1
    );
    expect(out.map((o) => o.id)).toEqual(['b']);
  });

  it('sorts the filtered set ascending when dir is 1', () => {
    const rows = [
      { ...base, id: 'a', estSavingsAtAsk: 300_000 },
      { ...base, id: 'b', estSavingsAtAsk: 100_000 },
      { ...base, id: 'c', estSavingsAtAsk: 200_000 },
    ] as OwnerRow[];
    const out = buildVisibleRows(rows, { ...DEFAULT_OWNER_PROSPECTS_FILTERS }, 'estSavingsAtAsk', 1);
    expect(out.map((o) => o.id)).toEqual(['b', 'c', 'a']);
  });

  it('does not mutate the input array', () => {
    const rows = [
      { ...base, id: 'a', estSavingsAtAsk: 100 },
      { ...base, id: 'b', estSavingsAtAsk: 900 },
    ] as OwnerRow[];
    const snapshot = rows.map((r) => r.id);
    buildVisibleRows(rows, { ...DEFAULT_OWNER_PROSPECTS_FILTERS }, 'estSavingsAtAsk', -1);
    expect(rows.map((r) => r.id)).toEqual(snapshot);
  });

  it('excludes a filtered row and returns the two survivors reordered', () => {
    const rows = [
      { ...base, id: 'a', estSavingsAtAsk: 100_000, repStatus: 'Represented by X' },
      { ...base, id: 'b', estSavingsAtAsk: 120_000, repStatus: 'No rep on record' },
      { ...base, id: 'c', estSavingsAtAsk: 400_000, repStatus: 'No rep on record' },
    ] as OwnerRow[];
    // rep=none drops 'a'; survivors enter as [b, c], sort desc swaps them to [c, b].
    const out = buildVisibleRows(rows, { ...DEFAULT_OWNER_PROSPECTS_FILTERS, rep: 'none' }, 'estSavingsAtAsk', -1);
    expect(out.map((o) => o.id)).toEqual(['c', 'b']);
  });
});

describe('KNOWN_SORT_KEYS', () => {
  it('covers every OwnerSortKey union member', () => {
    expect(KNOWN_SORT_KEYS.size).toBe(13);
    for (const k of ['label', 'tier', 'parcelCount', 'totalAV2025', 'totalAV2026', 'avYoYPct', 'totalUnits',
      'nAppealRec', 'estSavingsAtAsk', 'estSavingsAtFloor', 'historicalReductionWon', 'appealYears', 'repStatus'] as const) {
      expect(KNOWN_SORT_KEYS.has(k)).toBe(true);
    }
  });
});

describe('sanitizeFilters', () => {
  it('passes a valid blob through unchanged', () => {
    const good = { tier: 'Prime', rep: 'has', hasAppealHistory: true, typeGroup: 'Industrial', minOppPerYear: 50_000, query: 'acme' };
    expect(sanitizeFilters(good)).toEqual(good);
  });
  it('replaces a bogus tier / rep with the defaults', () => {
    const out = sanitizeFilters({ tier: 'Bogus', rep: 'x' });
    expect(out.tier).toBe('all');
    expect(out.rep).toBe('');
  });
  it('clamps a negative / non-numeric minOppPerYear to 0 and coerces the rest', () => {
    expect(sanitizeFilters({ minOppPerYear: -5 }).minOppPerYear).toBe(0);
    expect(sanitizeFilters({ minOppPerYear: 'lots' }).minOppPerYear).toBe(0);
    expect(sanitizeFilters({ hasAppealHistory: 'false', typeGroup: 42, query: null })).toEqual(DEFAULT_OWNER_PROSPECTS_FILTERS);
  });
  it('returns the full default set for a non-object input', () => {
    expect(sanitizeFilters(null)).toEqual(DEFAULT_OWNER_PROSPECTS_FILTERS);
    expect(sanitizeFilters('nope')).toEqual(DEFAULT_OWNER_PROSPECTS_FILTERS);
  });
});

describe('buildOwnerProspectsAgentContext', () => {
  const mkState = (over: Partial<OwnerProspectsAgentContextState> = {}): OwnerProspectsAgentContextState => ({
    runDate: '2026-08-15', methodologyVersion: 'v3', companyOwnerCount: 42,
    visibleRows: [{ label: 'ACME PROPERTIES' }, { label: 'BETA HOLDINGS' }],
    summary: { companyOwners: 42, parcels: 100, totalAV: 9e9, oppAsk: 1_200_000, oppFloor: 800_000, freshOpp: 500_000, prime: 4, strong: 7 },
    filters: { ...DEFAULT_OWNER_PROSPECTS_FILTERS, tier: 'Prime', rep: 'none', typeGroup: 'Industrial', minOppPerYear: 50_000, query: 'acme' },
    sortKey: 'estSavingsAtAsk', sortDir: -1,
    selectedOwnerLabel: 'ACME PROPERTIES', selectedOwnerIsFlagged: true, countyYoYPct: 15.2,
    ...over,
  });

  const NAMED_FIELDS = [
    'RunDate', 'MethodologyVersion', 'CompanyOwnerCount', 'VisibleOwnerCount', 'TotalOpportunityAtAsk',
    'FreshOpportunityAtAsk', 'PrimeCount', 'StrongCount', 'TierFilter', 'RepFilter', 'TypeFilter',
    'MinOppPerYear', 'SearchQuery', 'SortKey', 'SortDir', 'SelectedOwnerLabel', 'SelectedOwnerIsFlagged', 'CountyYoYPct',
  ] as const;

  it('emits every documented named field plus the bounded label list', () => {
    const ctx = buildOwnerProspectsAgentContext(mkState());
    for (const key of NAMED_FIELDS) expect(ctx).toHaveProperty(key);
    expect(ctx).toHaveProperty('TopVisibleOwnerLabels');
    expect(ctx['CompanyOwnerCount']).toBe(42);
    expect(ctx['VisibleOwnerCount']).toBe(2);
    expect(ctx['TotalOpportunityAtAsk']).toBe(1_200_000);
    expect(ctx['FreshOpportunityAtAsk']).toBe(500_000);
    expect(ctx['PrimeCount']).toBe(4);
    expect(ctx['StrongCount']).toBe(7);
    expect(ctx['TierFilter']).toBe('Prime');
    expect(ctx['SortDir']).toBe('desc');
    expect(ctx['SelectedOwnerIsFlagged']).toBe(true);
    expect(ctx['CountyYoYPct']).toBe(15.2);
    expect(ctx['TopVisibleOwnerLabels']).toEqual(['ACME PROPERTIES', 'BETA HOLDINGS']);
  });

  it('caps TopVisibleOwnerLabels at 25 and emits TopVisibleOwnerLabelsCount only when truncated', () => {
    const at25 = buildOwnerProspectsAgentContext(mkState({ visibleRows: Array.from({ length: 25 }, (_, i) => ({ label: `OWNER ${i}` })) }));
    expect(at25['TopVisibleOwnerLabels']).toHaveLength(25);
    expect(at25).not.toHaveProperty('TopVisibleOwnerLabelsCount');

    const over25 = buildOwnerProspectsAgentContext(mkState({ visibleRows: Array.from({ length: 40 }, (_, i) => ({ label: `OWNER ${i}` })) }));
    expect(over25['TopVisibleOwnerLabels']).toHaveLength(25);
    expect(over25['TopVisibleOwnerLabelsCount']).toBe(40);
    expect(over25['VisibleOwnerCount']).toBe(40);
  });

  it('leaks no opaque / id / prospect field — only the documented keys appear', () => {
    const allowed = new Set<string>([...NAMED_FIELDS, 'TopVisibleOwnerLabels', 'TopVisibleOwnerLabelsCount']);
    const ctx = buildOwnerProspectsAgentContext(mkState({ visibleRows: Array.from({ length: 30 }, (_, i) => ({ label: `OWNER ${i}` })) }));
    for (const key of Object.keys(ctx)) expect(allowed.has(key)).toBe(true);
    for (const banned of ['id', 'prospectId', 'ownerKey', 'SelectedOwnerId', 'runId', 'coStarTrueOwner']) {
      expect(Object.keys(ctx)).not.toContain(banned);
    }
  });

  it('nulls the summary-derived metrics when no run summary is loaded', () => {
    const ctx = buildOwnerProspectsAgentContext(mkState({ summary: null, countyYoYPct: null }));
    expect(ctx['TotalOpportunityAtAsk']).toBeNull();
    expect(ctx['FreshOpportunityAtAsk']).toBeNull();
    expect(ctx['PrimeCount']).toBeNull();
    expect(ctx['StrongCount']).toBeNull();
    expect(ctx['CountyYoYPct']).toBeNull();
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
