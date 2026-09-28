import { describe, it, expect } from 'vitest';
import {
  OwnerRow,
  OwnerParcelRow,
  DEFAULT_OWNER_PROSPECTS_FILTERS,
  NO_ANALYSIS_TOOLTIP,
  YOY_PRIOR_FLOOR,
  latestRunFor,
  filterByCounty,
  tierLabel,
  runTierBasis,
  repCell,
  savingsCell,
  countyBanner,
  countyNumbersInRun,
  isBelowYoYFloor,
  sortOwnerRows,
  parcelYears,
  parcelVerifyLink,
  mapOwnerPortfolioRow,
  mapOwnerParcelRow,
  sanitizeFilters,
  tierOptionsFor,
  statewidePortfolioFilter,
  statewideSearchFilter,
  likeContainsLiteral,
  shouldServerSearch,
  SERVER_SEARCH_MIN_CHARS,
  MARION_PARCELS_MARKER,
  MARION_PARCELS_TOOLTIP,
  buildOwnerProspectsAgentContext,
} from '../OwnerProspects/owner-prospects.model';

/**
 * Owner Prospects statewide (owner-prospects-statewide plan, Task 5) — the pure
 * rules the screen's scope toggle, county filter and honest empties rest on.
 * Fixtures mirror the live Statewide run 19153E40-… (2026-09-28): portfolio
 * `ByCountyJSON` keys are county numbers as strings, `{ parcels, avCurrent,
 * avPrior }`; the run's `ByCountyJSON` carries `avPrior` / `avCurrentYoY` over
 * the paired parcels only.
 */

const owner = (over: Partial<OwnerRow>): OwnerRow => ({
  id: 'o', ownerKey: 'k', label: 'L', kind: 'Company', tier: 'A',
  parcelCount: 1, distinctEntities: 1, totalAV: 1, totalAV2025: null, totalAV2026: null,
  avYoYDollars: null, avYoYPct: null, parcelsUp10: null, parcelsUp25: null, totalUnits: null, totalSqFt: null,
  nAppealRec: null, nTwoSupport: null, nHighConfAppeal: null, estSavingsAtAsk: null, estSavingsAtFloor: null,
  appealedParcels: null, historicalReductionWon: null, appealYears: null, likelyRep: null,
  repStatus: 'No rep data for this county', repsOnReduction: [], isFreshProspect: false, mailAddress: null,
  coStarTrueOwner: null, byType: {}, dominantType: null, parcels: [], prospectId: null,
  ...over,
});

// A 3-county owner (Walmart-shaped), a Lake-only owner, an Allen-only owner.
const walmart = owner({
  id: 'w', label: 'Walmart Inc.', primaryCountyNumber: 30, countyCount: 3,
  byCounty: { '30': { parcels: 4, avCurrent: 122_671_000, avPrior: null }, '45': { parcels: 4, avCurrent: 35_916_600, avPrior: 37_033_100 }, '49': { parcels: 17, avCurrent: 102_416_600, avPrior: 82_776_800 } },
});
const lakeOnly = owner({ id: 'l', label: 'Lake Only LLC', primaryCountyNumber: 45, countyCount: 1, byCounty: { '45': { parcels: 1, avCurrent: 500_000, avPrior: 480_000 } } });
const allenOnly = owner({ id: 'a', label: 'Allen Only LLC', primaryCountyNumber: 2, countyCount: 1, byCounty: { '2': { parcels: 1, avCurrent: 900_000, avPrior: null } } });

describe('latestRunFor', () => {
  it('returns the one latest run of the scope', () => {
    const r = latestRunFor([{ ID: 's1', Scope: 'Statewide', IsLatest: 1 }, { ID: 'm1', Scope: 'Marion', IsLatest: true }], 'Statewide');
    expect(r.run?.['ID']).toBe('s1');
    expect(r.error).toBeNull();
  });
  it('never silently picks one of two latest runs of a scope', () => {
    const r = latestRunFor([{ ID: 's1', Scope: 'Statewide', IsLatest: 1 }, { ID: 's2', Scope: 'Statewide', IsLatest: 1 }], 'Statewide');
    expect(r.run).toBeNull();
    expect(r.error).toMatch(/2 latest Statewide runs/);
  });
  it('reports a missing run for the scope', () => {
    const r = latestRunFor([{ ID: 'm1', Scope: 'Marion', IsLatest: 1 }], 'Statewide');
    expect(r.run).toBeNull();
    expect(r.error).toMatch(/No Statewide owner-portfolio run/);
  });
});

describe('filterByCounty (Review Focus 5)', () => {
  const all = [walmart, lakeOnly, allenOnly];
  it('All lists every owner exactly once', () => {
    const out = filterByCounty([...all, walmart], null);
    expect(out.map((o) => o.id)).toEqual(['w', 'l', 'a']);
  });
  it('a multi-county owner appears under each of its counties', () => {
    expect(filterByCounty(all, 45).map((o) => o.id)).toEqual(['w', 'l']);
    expect(filterByCounty(all, 49).map((o) => o.id)).toEqual(['w']);
    expect(filterByCounty(all, 30).map((o) => o.id)).toEqual(['w']);
    expect(filterByCounty(all, 2).map((o) => o.id)).toEqual(['a']);
  });
  it('falls back to PrimaryCountyNumber when ByCountyJSON is absent', () => {
    const bare = owner({ id: 'b', primaryCountyNumber: 45, byCounty: undefined });
    expect(filterByCounty([bare], 45).map((o) => o.id)).toEqual(['b']);
    expect(filterByCounty([bare], 2)).toEqual([]);
  });
});

describe('statewidePortfolioFilter', () => {
  it('filters by run only for All', () => {
    expect(statewidePortfolioFilter('RUN', null)).toBe("RunID = 'RUN'");
  });
  it('adds the primary-county OR ByCountyJSON-key clause for a county', () => {
    expect(statewidePortfolioFilter('RUN', 45)).toBe(`RunID = 'RUN' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`);
  });
});

describe('server search past the cap (fix round 1)', () => {
  it('escapes LIKE wildcards with brackets and doubles quotes via escapeSqlLiteral', () => {
    expect(likeContainsLiteral("O'Brien 100% [x]_y")).toBe("O''Brien 100[%] [[]x][_]y");
  });
  it('adds the Label LIKE clause to the county clause', () => {
    expect(statewideSearchFilter('RUN', 45, "O'Brien 50%")).toBe(
      `RunID = 'RUN' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%') AND Label LIKE '%O''Brien 50[%]%'`,
    );
    expect(statewideSearchFilter('RUN', null, '  acme  ')).toBe("RunID = 'RUN' AND Label LIKE '%acme%'");
  });
  it('searches the server only when the cap tripped and the term has 3+ characters', () => {
    expect(SERVER_SEARCH_MIN_CHARS).toBe(3);
    expect(shouldServerSearch(true, 'ab')).toBe(false);
    expect(shouldServerSearch(true, ' abc ')).toBe(true);
    expect(shouldServerSearch(false, 'abcdef')).toBe(false);
  });
});

describe('tierLabel / runTierBasis', () => {
  it('labels from TierBasis, never from scope', () => {
    expect(tierLabel('Savings')).toBe('Savings tier');
    expect(tierLabel('AV')).toBe('AV tier');
    expect(tierLabel(null)).toBe('Tier');
  });
  it('the run basis is the shared TierBasis, or null when rows disagree', () => {
    expect(runTierBasis([owner({ tierBasis: 'AV' }), owner({ tierBasis: 'AV' })])).toBe('AV');
    expect(runTierBasis([owner({ tierBasis: 'AV' }), owner({ tierBasis: 'Savings' })])).toBeNull();
    expect(runTierBasis([])).toBeNull();
  });
  it('tier options follow the basis', () => {
    expect(tierOptionsFor('Savings').map((o) => o.key)).toEqual(['all', 'Prime', 'Strong', 'Moderate']);
    expect(tierOptionsFor('AV').map((o) => o.key)).toEqual(['all', 'A', 'B', 'C', 'D']);
  });
  it('sanitizeFilters keeps the AV tiers', () => {
    expect(sanitizeFilters({ tier: 'B' }).tier).toBe('B');
    expect(sanitizeFilters({ tier: 'E' }).tier).toBe('all');
  });
});

describe('repCell', () => {
  it('shows the stored RepStatus verbatim outside Marion', () => {
    expect(repCell('No rep data for this county')).toEqual({ text: 'No rep data for this county', open: false });
    expect(repCell('Represented by RYAN LLC')).toEqual({ text: 'Represented by RYAN LLC', open: false });
  });
  it('keeps the Marion "— open" rendering for "No rep on record"', () => {
    expect(repCell('No rep on record')).toEqual({ text: '— open', open: true });
  });
});

describe('savingsCell', () => {
  it('is blank with the exact tooltip when an AV-basis row has no savings', () => {
    expect(savingsCell(null, 'AV')).toEqual({ text: '', tooltip: NO_ANALYSIS_TOOLTIP, marionOnly: false });
    expect(NO_ANALYSIS_TOOLTIP).toBe('no valuation analysis for this county yet');
  });
  it('shows savings that exist on an AV-basis row, flagged as Marion-parcels-only', () => {
    expect(savingsCell(162_164.47, 'AV')).toEqual({ text: '$162,164', tooltip: null, marionOnly: true });
    expect(MARION_PARCELS_MARKER).toBe('Marion parcels');
    expect(MARION_PARCELS_TOOLTIP).toBe("from valuation analyses on this owner's Marion parcels only");
  });
  it('is blank with the tooltip when no basis is recorded and no savings exist', () => {
    expect(savingsCell(null, null)).toEqual({ text: '', tooltip: NO_ANALYSIS_TOOLTIP, marionOnly: false });
  });
  it('keeps the Marion money / dash rendering for the Savings basis', () => {
    expect(savingsCell(51_000, 'Savings')).toEqual({ text: '$51,000', tooltip: null, marionOnly: false });
    expect(savingsCell(null, 'Savings')).toEqual({ text: '—', tooltip: null, marionOnly: false });
  });
});

describe('countyBanner', () => {
  const json = JSON.stringify({
    '45': { parcels: 15001, avCurrent: 10_521_026_180, yoyParcels: 14851, avPrior: 9_563_918_300, avCurrentYoY: 10_408_930_080, placeholderParcels: 1 },
    '1': { parcels: 1219, avCurrent: 320_888_700, yoyParcels: 0, avPrior: 0, avCurrentYoY: 0, placeholderParcels: 1219 },
  });
  it('reads one county: parcels, sums and YoY over the paired parcels', () => {
    const b = countyBanner(json, 45);
    expect(b).not.toBeNull();
    expect(b!.parcels).toBe(15001);
    expect(b!.avCurrent).toBe(10_521_026_180);
    expect(b!.avPrior).toBe(9_563_918_300);
    expect(b!.avCurrentPaired).toBe(10_408_930_080);
    expect(b!.yoyPct).toBe(8.8);
  });
  it('omits YoY when a county has no paired sums', () => {
    const b = countyBanner(json, 1);
    expect(b!.yoyPct).toBeNull();
    expect(b!.avPrior).toBeNull();
    expect(b!.placeholderParcels).toBe(1219);
  });
  it('sums every county for All', () => {
    const b = countyBanner(json, null);
    expect(b!.parcels).toBe(16220);
    expect(b!.countyCount).toBe(2);
    expect(b!.yoyPct).toBe(8.8);
  });
  it('is null for an absent county or unparseable JSON', () => {
    expect(countyBanner(json, 99)).toBeNull();
    expect(countyBanner('nope', 45)).toBeNull();
    expect(countyBanner(null, null)).toBeNull();
  });
  it('countyNumbersInRun lists counties with parcels, numerically', () => {
    expect(countyNumbersInRun(json)).toEqual([1, 45]);
    expect(countyNumbersInRun(JSON.stringify({ '3': { parcels: 0 } }))).toEqual([]);
  });
});

describe('YoY floor', () => {
  const big = owner({ id: 'big', avPrior: 5_000_000, avYoYPct: 12 });
  const tiny = owner({ id: 'tiny', avPrior: 5_700, avYoYPct: 47_787.7 });
  const mid = owner({ id: 'mid', avPrior: YOY_PRIOR_FLOOR, avYoYPct: 3 });
  const none = owner({ id: 'none', avPrior: null, avYoYPct: null });
  const marion = owner({ id: 'marion', avPrior: undefined, totalAV2025: 50_000, avYoYPct: 20 });
  it('flags rows whose prior AV is under $100k', () => {
    expect(isBelowYoYFloor(tiny)).toBe(true);
    expect(isBelowYoYFloor(mid)).toBe(false);
    expect(isBelowYoYFloor(none)).toBe(false);
    expect(isBelowYoYFloor(marion)).toBe(false);
  });
  it('YoY sort ranks only rows at or above the floor; below-floor rows sort last (before nulls), both directions', () => {
    expect(sortOwnerRows([tiny, none, mid, big], 'avYoYPct', -1).map((o) => o.id)).toEqual(['big', 'mid', 'tiny', 'none']);
    expect(sortOwnerRows([tiny, none, big, mid], 'avYoYPct', 1).map((o) => o.id)).toEqual(['mid', 'big', 'tiny', 'none']);
  });
  it('leaves rows without an AVPrior (the Marion run) ranked as before', () => {
    expect(sortOwnerRows([big, marion], 'avYoYPct', -1).map((o) => o.id)).toEqual(['marion', 'big']);
  });
});

describe('statewide row parsing', () => {
  it('maps the statewide portfolio columns', () => {
    const r = mapOwnerPortfolioRow({
      ID: 'x', Label: 'Walmart Inc.', Kind: 'Company', Tier: 'A', RepStatus: 'No rep data for this county',
      PrimaryCountyNumber: 30, CountyCount: 59, AVPrior: 325_709_600, AVCurrent: 955_800_900, PairYears: 'mixed',
      TierBasis: 'AV', GroupKeyType: 'CO', ByCountyJSON: '{"45":{"parcels":4,"avCurrent":35916600,"avPrior":37033100}}',
    });
    expect(r.primaryCountyNumber).toBe(30);
    expect(r.countyCount).toBe(59);
    expect(r.avPrior).toBe(325_709_600);
    expect(r.avCurrent).toBe(955_800_900);
    expect(r.tierBasis).toBe('AV');
    expect(r.pairYears).toBe('mixed');
    expect(r.groupKeyType).toBe('CO');
    expect(r.byCounty).toEqual({ '45': { parcels: 4, avCurrent: 35_916_600, avPrior: 37_033_100 } });
  });
  it('maps the statewide parcel columns, GISParcelNumber nullable', () => {
    const p = mapOwnerParcelRow({
      ID: 'p', ParcelID: 'pid', Parcel: '450706207002000023', GISParcelNumber: null, CountyNumber: 45,
      PriorYear: 2024, CurrentYear: 2025, AVPrior: 100, AVCurrent: 110, IsPlaceholder: 1, SqFtSource: 'DLGF', AppealLevel: 'State-IBTR',
    });
    expect(p.gisParcelNumber).toBe('');
    expect(p.parcelId).toBe('pid');
    expect(p.parcelNumber).toBe('450706207002000023');
    expect(p.countyNumber).toBe(45);
    expect(p.isPlaceholder).toBe(true);
    expect(p.priorYear).toBe(2024);
    expect(p.avCurrent).toBe(110);
    expect(p.appealLevel).toBe('State-IBTR');
  });
});

describe('parcelYears / parcelVerifyLink', () => {
  const p = (over: Partial<OwnerParcelRow>): OwnerParcelRow => ({
    id: 'p', gisParcelNumber: '', address: null, typeGroup: null, currentAV: null, av2025: null, av2026: null,
    avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null,
    conf: null, supCount: null, appealed: false, existingRep: null, lastAppealYear: null, ...over,
  });
  it('PriorYear→CurrentYear, current only, or blank', () => {
    expect(parcelYears(p({ priorYear: 2024, currentYear: 2025 }))).toBe('2024→2025');
    expect(parcelYears(p({ priorYear: null, currentYear: 2025 }))).toBe('2025 only');
    expect(parcelYears(p({}))).toBe('');
  });
  it('builds a Lake xSoft card link through the Property Search builder', () => {
    const l = parcelVerifyLink(p({ countyNumber: 45, parcelNumber: '450706207002000023', currentYear: 2025 }), { 45: 'lake' }, null);
    expect(l.url).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
  });
  it('builds the Marion PRC link for a Marion-run parcel with no county (the fallback county)', () => {
    const l = parcelVerifyLink(p({ gisParcelNumber: '1234567' }), {}, 49);
    expect(l.url).toContain('ReportPage.aspx?ParcelNumber=1234567');
  });
  it('is honest about a county with no route', () => {
    const l = parcelVerifyLink(p({ countyNumber: 1, parcelNumber: '010101010101010101', currentYear: 2025 }), { 1: 'adams' }, null);
    expect(l.url).toBeNull();
    expect(l.note).toBe('not on file — verify at the county');
  });
});

describe('agent context — scope, county, tier basis', () => {
  it('adds Scope, County and TierBasis', () => {
    const ctx = buildOwnerProspectsAgentContext({
      runDate: null, methodologyVersion: null, companyOwnerCount: 0, visibleRows: [], summary: null,
      filters: DEFAULT_OWNER_PROSPECTS_FILTERS, sortKey: 'avCurrent', sortDir: -1, selectedOwnerLabel: null,
      selectedOwnerIsFlagged: false, countyYoYPct: 8.8, scope: 'Statewide', county: 'Lake', tierBasis: 'AV',
    });
    expect(ctx['Scope']).toBe('Statewide');
    expect(ctx['County']).toBe('Lake');
    expect(ctx['TierBasis']).toBe('AV');
  });
});
