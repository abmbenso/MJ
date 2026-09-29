import { describe, it, expect } from 'vitest';
import {
  OwnerRow,
  OwnerParcelRow,
  DEFAULT_OWNER_PROSPECTS_FILTERS,
  NO_ANALYSIS_TOOLTIP,
  latestRunFor,
  filterByCounty,
  tierLabel,
  runTierBasis,
  repCell,
  savingsCell,
  countyNumbersInRun,
  sortOwnerRows,
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
  effectiveTierBasis,
  appealRecsCell,
  hasMarionParcels,
  pairYearsTooltip,
  repIsMarionOnly,
  statewideThesis,
  PARCEL_ROW_CAP,
  PARCEL_CAP_NOTE,
  OwnerCountySlice,
  DisplayYears,
  COMPLETE_YOY_THRESHOLD,
  displayYears,
  ownerYearSummary,
  yearCell,
  yoyCell,
  statusCell,
  yearTooltip,
  isComplete,
  countyChip,
  countyChips,
  countyYearBanner,
  annotateOwnerYears,
  buildVisibleRows,
  mapParcelYearHeadlines,
  buildParcelViewRows,
  parcelYearCell,
  parcelStatus,
  snapshotTotalAV,
  liveYearTotal,
  storedYear2Total,
  runLiveSourceNote,
  runVsLiveNote,
  parcelYoYDollars,
  sortParcels,
  exportRows,
  exportParcelRows,
  YOY_MATERIAL_PRIOR,
  yoyRankTier,
  remapStatewideSortKey,
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
    expect(repCell('No rep data for this county', 'AV')).toEqual({ text: 'No rep data for this county', open: false });
    expect(repCell('Represented by RYAN LLC', 'AV')).toEqual({ text: 'Represented by RYAN LLC', open: false });
  });
  it('a Statewide row\'s "No rep on record" is verbatim, never "— open" (fix round 2, item 3)', () => {
    expect(repCell('No rep on record', 'AV')).toEqual({ text: 'No rep on record', open: false });
  });
  it('keeps the Marion "— open" rendering for "No rep on record"', () => {
    expect(repCell('No rep on record', 'Savings')).toEqual({ text: '— open', open: true });
  });
});

describe('effectiveTierBasis (fix round 2, item 2)', () => {
  it('uses the stored basis, else the scope default (the Marion persist never wrote TierBasis)', () => {
    expect(effectiveTierBasis('AV', 'Marion')).toBe('AV');
    expect(effectiveTierBasis(null, 'Marion')).toBe('Savings');
    expect(effectiveTierBasis(undefined, 'Statewide')).toBe('AV');
  });
  it('a Marion row with null TierBasis renders savings exactly as today', () => {
    expect(savingsCell(null, effectiveTierBasis(null, 'Marion'))).toEqual({ text: '—', tooltip: null, marionOnly: false });
    expect(savingsCell(51_000, effectiveTierBasis(null, 'Marion'))).toEqual({ text: '$51,000', tooltip: null, marionOnly: false });
    expect(repCell('No rep on record', effectiveTierBasis(null, 'Marion'))).toEqual({ text: '— open', open: true });
    expect(tierLabel(effectiveTierBasis(null, 'Marion'))).toBe('Savings tier');
  });
});

describe('appealRecsCell (fix round 2, item 6)', () => {
  it('Marion basis: the number, or a dash', () => {
    expect(appealRecsCell(3, 'Savings', false)).toEqual({ text: '3', tooltip: null, marionOnly: false });
    expect(appealRecsCell(null, 'Savings', false)).toEqual({ text: '—', tooltip: null, marionOnly: false });
  });
  it('AV basis without Marion parcels: blank with the no-analysis tooltip', () => {
    expect(appealRecsCell(null, 'AV', false)).toEqual({ text: '', tooltip: NO_ANALYSIS_TOOLTIP, marionOnly: false });
  });
  it('AV basis with Marion parcels: the marker when non-zero, a plain 0 otherwise', () => {
    expect(appealRecsCell(5, 'AV', true)).toEqual({ text: '5', tooltip: null, marionOnly: true });
    expect(appealRecsCell(0, 'AV', true)).toEqual({ text: '0', tooltip: null, marionOnly: false });
  });
  it('hasMarionParcels reads the ByCountyJSON key 49', () => {
    expect(hasMarionParcels(walmart)).toBe(true);
    expect(hasMarionParcels(lakeOnly)).toBe(false);
  });
});

describe('assessment years on Statewide figures (fix round 2, item 5)', () => {
  it('the AV cells carry the owner\'s PairYears', () => {
    expect(pairYearsTooltip('2025→2026')).toBe('assessment years 2025→2026');
    expect(pairYearsTooltip('mixed')).toBe('mixed assessment years across this owner\'s parcels — see the parcel list');
    expect(pairYearsTooltip(null)).toBe('no assessment year on record');
    expect(pairYearsTooltip('2026')).toBe('2026: current year only — no prior-year figure on the record');
  });
});

describe('parcel cap (fix round 2, item 4)', () => {
  it('is 5,000 with the exact note', () => {
    expect(PARCEL_ROW_CAP).toBe(5000);
    expect(PARCEL_CAP_NOTE).toBe('showing the first 5,000 parcels');
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

describe('countyNumbersInRun', () => {
  it('lists counties with parcels, numerically — the run-level years array is not a county', () => {
    const json = JSON.stringify({ '45': { parcels: 15001 }, '1': { parcels: 1219 }, '3': { parcels: 0 }, years: [2025, 2026] });
    expect(countyNumbersInRun(json)).toEqual([1, 45]);
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
    expect(r.byCounty).toEqual({ '45': { parcels: 4, avCurrent: 35_916_600, avPrior: 37_033_100, pairedParcels: null } }); // pairedParcels: not on runs before the fix round
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

describe('parcelVerifyLink', () => {
  const p = (over: Partial<OwnerParcelRow>): OwnerParcelRow => ({
    id: 'p', gisParcelNumber: '', address: null, typeGroup: null, currentAV: null, av2025: null, av2026: null,
    avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null,
    conf: null, supCount: null, appealed: false, existingRep: null, lastAppealYear: null, ...over,
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
    expect(ctx['OpportunityBasis']).toBe('Marion parcels only');
    expect(ctx['PrimeCount']).toBeNull(); // Prime/Strong are savings tiers — absent on the AV basis
    expect(ctx['StrongCount']).toBeNull();
    expect(ctx['DisplayYears']).toBeNull(); // not given → null, never a guessed pair
    expect(ctx['CompleteOnly']).toBeNull();
  });
  it('adds DisplayYears and CompleteOnly (fixed assessment years, 2026-09-28)', () => {
    const ctx = buildOwnerProspectsAgentContext({
      runDate: null, methodologyVersion: null, companyOwnerCount: 0, visibleRows: [], summary: null,
      filters: DEFAULT_OWNER_PROSPECTS_FILTERS, sortKey: 'yoyPair', sortDir: -1, selectedOwnerLabel: null,
      selectedOwnerIsFlagged: false, countyYoYPct: null, scope: 'Statewide', county: null, tierBasis: 'AV',
      displayYears: [2025, 2026], completeOnly: true,
    });
    expect(ctx['DisplayYears']).toEqual([2025, 2026]);
    expect(ctx['CompleteOnly']).toBe(true);
    expect(ctx['SortKey']).toBe('yoyPair');
  });
});

describe('final-review fix round: rep scope, thesis', () => {
  const slices = (o: Record<string, [number, number | null | undefined]>) =>
    Object.fromEntries(Object.entries(o).map(([c, [parcels, paired]]) => [c, { parcels, avCurrent: 1, avPrior: null, pairedParcels: paired }]));

  it('repIsMarionOnly: Walmart-shaped (Marion + 58 other counties) on the AV basis; never on Marion, a Marion-only or a no-Marion owner', () => {
    const walmart = owner({ repStatus: 'Represented by INTEGRITY TAX CONSULTING', byCounty: slices({ '45': [4, 4], '49': [17, 17], '2': [3, 0] }) });
    expect(repIsMarionOnly(walmart, 'AV')).toBe(true);
    expect(repIsMarionOnly(walmart, 'Savings')).toBe(false);
    expect(repIsMarionOnly(owner({ repStatus: 'No rep on record', byCounty: slices({ '49': [2, 2] }) }), 'AV')).toBe(false);
    expect(repIsMarionOnly(owner({ repStatus: 'No rep data for this county', byCounty: slices({ '45': [1, 1] }) }), 'AV')).toBe(false);
  });

  it('statewideThesis scopes the opportunity and a Marion-only rep; no figure without analysis', () => {
    const walmart = owner({
      label: 'Walmart Inc.', parcelCount: 21, countyCount: 2, totalAV: 138_333_200, avYoYPct: 7.2, tier: 'A',
      estSavingsAtAsk: 162_164.47, repStatus: 'Represented by INTEGRITY TAX CONSULTING', byCounty: slices({ '45': [4, 4], '49': [17, 17] }),
      parcels: [{ isPlaceholder: true } as OwnerParcelRow, { isPlaceholder: false } as OwnerParcelRow],
    });
    expect(statewideThesis(walmart, null)).toBe(
      '21 parcels in 2 counties. AV by assessment year: not on this run. AV tier A. '
      + 'Opportunity = Marion parcels only: ~$162,164/yr at ask (EstimatedOpportunityAtAsk covers those parcels, not the portfolio). '
      + 'Rep status (Marion parcels only): Represented by INTEGRITY TAX CONSULTING.',
    );
    const lake = owner({ parcelCount: 1, countyCount: 1, totalAV: 5, avYoYPct: null, tier: 'D', estSavingsAtAsk: null,
      repStatus: 'No rep data for this county', byCounty: slices({ '45': [1, 0] }), parcels: [] });
    expect(statewideThesis(lake, PARCEL_CAP_NOTE)).toContain("Opportunity: none claimed — no valuation analysis on this owner's parcels. Rep status: No rep data for this county.");
    expect(statewideThesis(lake, PARCEL_CAP_NOTE)).toContain('Parcels attached: showing the first 5,000 parcels of 1.');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Fixed assessment years (owner-prospects-years-export plan, Task 2). Slices mirror the run written by
// Task 1: `ByCountyJSON[c].years = { "2025": { av, parcels, roll } }`, `pair = { prior, current, parcelsBoth,
// avPriorBoth, avCurrentBoth, newFromZero, avNewFromZero, yoyPct }`. No figure is ever estimated.
// ─────────────────────────────────────────────────────────────────────────────

const Y: DisplayYears = [2025, 2026];
const fig = (av: number, parcels: number, roll = 0) => ({ av, parcels, roll });
const pairOf = (over: Partial<NonNullable<OwnerCountySlice['pair']>> = {}): NonNullable<OwnerCountySlice['pair']> => ({
  prior: 2025, current: 2026, parcelsBoth: 0, avPriorBoth: 0, avCurrentBoth: 0, newFromZero: 0, avNewFromZero: 0, yoyPct: null, ...over,
});
const slice = (years: OwnerCountySlice['years'], pair: OwnerCountySlice['pair'], parcels = 1): OwnerCountySlice => ({
  parcels, avCurrent: 1, avPrior: null, years, pair,
});

// The plan's A/B/C owner (Task 1 Step 1): A 2025 card 1,000,000 + 2026 roll 1,100,000; B 2026 roll only 500,000
// (Review Focus 1); C 2025 card only 200,000.
const abc = owner({
  id: 'abc', label: 'ABC Holdings', parcelCount: 3,
  byCounty: { '45': slice({ '2025': fig(1_200_000, 2), '2026': fig(1_600_000, 2, 2) }, pairOf({ parcelsBoth: 1, avPriorBoth: 1_000_000, avCurrentBoth: 1_100_000, yoyPct: 10 }), 3) },
});
// Review Focus 2: every parcel assessed only through 2025 (the county's 2026 not loaded).
const only2025 = owner({
  id: 'o25', label: 'Only 2025 LLC', parcelCount: 12,
  byCounty: { '1': slice({ '2025': fig(9_000_000, 12, 12) }, pairOf(), 12) },
});
// Both years on every parcel, across two counties.
const complete = owner({
  id: 'cmp', label: 'Complete Co', parcelCount: 3,
  byCounty: {
    '2': slice({ '2025': fig(1_000_000, 2, 2), '2026': fig(1_100_000, 2) }, pairOf({ parcelsBoth: 2, avPriorBoth: 1_000_000, avCurrentBoth: 1_100_000, yoyPct: 10 }), 2),
    '45': slice({ '2025': fig(500_000, 1), '2026': fig(400_000, 1) }, pairOf({ parcelsBoth: 1, avPriorBoth: 500_000, avCurrentBoth: 400_000, yoyPct: -20 }), 1),
  },
});
// A parcel new since 2025 ($0 prior): out of the pair base, named in the status. `newFromZero` absent on a run
// written before the fix round reads as 0.
const newOne = owner({
  id: 'new', label: 'New Build LLC', parcelCount: 2,
  byCounty: { '49': slice({ '2025': fig(1_000_000, 2), '2026': fig(1_300_000, 2) }, pairOf({ parcelsBoth: 1, avPriorBoth: 1_000_000, avCurrentBoth: 1_050_000, newFromZero: 1, avNewFromZero: 250_000, yoyPct: 5 }), 2) },
});

describe('displayYears (display years are data)', () => {
  it('reads the run-level years of ByCountyJSON — the two newest', () => {
    expect(displayYears({ ByCountyJSON: JSON.stringify({ '45': { parcels: 1 }, years: [2025, 2026] }) })).toEqual([2025, 2026]);
    // Review Focus 4: one county already carries a 2027 roll — the run's newest two years win.
    expect(displayYears({ ByCountyJSON: JSON.stringify({ years: [2027, 2025, 2026] }) })).toEqual([2026, 2027]);
  });
  it('the Marion run: its fixed CountyTotalAV<year> columns carry the pair', () => {
    expect(displayYears({ Scope: 'Marion', ByCountyJSON: null, CountyTotalAV2025: 1, CountyTotalAV2026: 2 })).toEqual([2025, 2026]);
  });
  it('null when the run carries fewer than two years (never a guessed pair)', () => {
    expect(displayYears({ ByCountyJSON: JSON.stringify({ years: [2026] }) })).toBeNull();
    expect(displayYears({ ByCountyJSON: 'nope' })).toBeNull();
    expect(displayYears({ CountyTotalAV2025: null, CountyTotalAV2026: null })).toBeNull();
  });
});

describe('owner year cells — TBA for the newest year, — for the older, never an estimate', () => {
  it('sums the county slices per year', () => {
    const s = ownerYearSummary(abc, Y);
    expect(s.years['2025']).toEqual(fig(1_200_000, 2, 0));
    expect(s.years['2026']).toEqual(fig(1_600_000, 2, 2));
    expect(s.pair?.parcelsBoth).toBe(1);
    const c = ownerYearSummary(complete, Y);
    expect(c.years['2025']).toEqual(fig(1_500_000, 3, 2));
    expect(c.pair).toMatchObject({ parcelsBoth: 3, avPriorBoth: 1_500_000, avCurrentBoth: 1_500_000 });
  });
  it('yearCell: a number when on the record; TBA (newest year) / — (older year) when not', () => {
    expect(yearCell(abc, 2025, Y)).toBe(1_200_000);
    expect(yearCell(abc, 2026, Y)).toBe(1_600_000); // DLGF roll figures ARE the county's AV: a number
    expect(yearCell(only2025, 2026, Y)).toBe('TBA'); // Review Focus 2
    expect(yearCell(only2025, 2025, Y)).toBe(9_000_000);
    const only2026 = owner({ parcelCount: 1, byCounty: { '45': slice({ '2026': fig(500_000, 1, 1) }, pairOf(), 1) } });
    expect(yearCell(only2026, 2025, Y)).toBe('—'); // Review Focus 1 at owner level
  });
  it('yoyCell: over parcels with both years (roll included), one decimal; — when there is no pair', () => {
    expect(yoyCell(abc, Y)).toBe(10);
    expect(yoyCell(complete, Y)).toBe(0); // 1.5M → 1.5M
    expect(yoyCell(only2025, Y)).toBe('—');
    expect(yoyCell(newOne, Y)).toBe(5);
  });
  it('statusCell (final-review I2): BOTH years with their roll counts; — / TBA (n parcels) for a year with no figure; n new since y1', () => {
    expect(statusCell(abc, Y)).toBe('2025: 2 of 3 · roll 0; 2026 assessed: 2 of 3 · roll 2');
    expect(statusCell(only2025, Y)).toBe('2025: 12 of 12 · roll 12; 2026 TBA (12 parcels)');
    expect(statusCell(complete, Y)).toBe('2025: 3 of 3 · roll 2; 2026 assessed: 3 of 3 · roll 0');
    expect(statusCell(newOne, Y)).toBe('2025: 2 of 2 · roll 0; 2026 assessed: 2 of 2 · roll 0; 1 new since 2025');
    expect(statusCell(owner({ parcelCount: 112, byCounty: { '2': slice({ '2025': fig(1, 112, 74), '2026': fig(1, 39) }, pairOf(), 112) } }), Y))
      .toBe('2025: 112 of 112 · roll 74; 2026 assessed: 39 of 112 · roll 0'); // the ruling's example shape
    const only2026 = owner({ parcelCount: 1, byCounty: { '45': slice({ '2026': fig(500_000, 1, 1) }, pairOf(), 1) } });
    expect(statusCell(only2026, Y)).toBe('2025 —; 2026 assessed: 1 of 1 · roll 1');
  });
  it('yearTooltip: n of m parcels have a <year> figure; k are the DLGF roll', () => {
    expect(yearTooltip(abc, 2026, Y)).toBe('2 of 3 parcels have a 2026 figure; 2 are the DLGF roll');
    expect(yearTooltip(only2025, 2026, Y)).toBe('0 of 12 parcels have a 2026 figure; 0 are the DLGF roll');
  });
  it('the Marion run (no per-county years): its fixed AV2025/AV2026 columns, no tooltip', () => {
    const marion = owner({ tierBasis: 'Savings', totalAV2025: 4_000_000, totalAV2026: 4_200_000, avYoYPct: 5, byCounty: {} });
    expect(yearCell(marion, 2025, Y)).toBe(4_000_000);
    expect(yearCell(marion, 2026, Y)).toBe(4_200_000);
    expect(yoyCell(marion, Y)).toBe(5);
    expect(yearTooltip(marion, 2026, Y)).toBeNull();
    expect(statusCell(marion, Y)).toBe('2025 and 2026 on record');
    expect(statusCell(owner({ byCounty: {}, totalAV2025: 1, totalAV2026: null }), Y)).toBe('2026 TBA');
  });
});

describe('completeness + the Complete YoY only filter + the YoY ranking', () => {
  it('complete = at least 90% of the newest display-year AV sits in parcels with both years', () => {
    expect(COMPLETE_YOY_THRESHOLD).toBe(0.9);
    expect(ownerYearSummary(complete, Y).completeness).toBe(1);
    // A/B/C: 1.1M of (1.6M 2026 + C's 0.2M 2025-only) = 0.611 — C's parcel has no 2026 figure yet.
    expect(ownerYearSummary(abc, Y).completeness).toBeCloseTo(1_100_000 / 1_800_000, 6);
    expect(ownerYearSummary(only2025, Y).completeness).toBeNull();
    expect(isComplete(complete, Y)).toBe(true);
    expect(isComplete(abc, Y)).toBe(false);
    expect(isComplete(only2025, Y)).toBe(false); // Review Focus 2
    expect(isComplete(newOne, Y)).toBe(false); // 1.05M of 1.3M: the new build is not in the pair base
  });
  it('annotateOwnerYears puts the sortable year fields on each row', () => {
    const rows = [abc, only2025, complete].map((r) => ({ ...r }));
    annotateOwnerYears(rows, Y);
    expect(rows.map((r) => [r.avYear1, r.avYear2, r.yoyPair])).toEqual([
      [1_200_000, 1_600_000, 10], [9_000_000, null, null], [1_500_000, 1_500_000, 0],
    ]);
    expect(rows[2].completeness).toBe(1);
  });
  it('YoY sort ranks complete owners first, the rest after (both directions); blanks last; the filter drops the rest', () => {
    const big = owner({ id: 'big', avYear1: 1, avYear2: 1, yoyPair: 40, completeness: 0.5 });
    const cUp = owner({ id: 'cUp', yoyPair: 12, completeness: 0.95 });
    const cDown = owner({ id: 'cDown', yoyPair: -3, completeness: 1 });
    const none = owner({ id: 'none', yoyPair: null, completeness: null });
    const f = DEFAULT_OWNER_PROSPECTS_FILTERS;
    expect(buildVisibleRows([big, none, cDown, cUp], f, 'yoyPair', -1).map((o) => o.id)).toEqual(['cUp', 'cDown', 'big', 'none']);
    expect(buildVisibleRows([big, none, cUp, cDown], f, 'yoyPair', 1).map((o) => o.id)).toEqual(['cDown', 'cUp', 'big', 'none']);
    // Review Focus 2: excluded by Complete YoY only, included (after the complete ones) when the user turns it off.
    expect(buildVisibleRows([big, none, cDown, cUp], f, 'yoyPair', -1, true).map((o) => o.id)).toEqual(['cUp', 'cDown']);
  });
});

describe('county chip + county banner', () => {
  const run = {
    '45': { parcels: 15001, years: { '2025': fig(10e9, 15000, 3), '2026': fig(11e9, 14000, 10) }, pair: pairOf({ parcelsBoth: 13990, avPriorBoth: 9e9, avCurrentBoth: 9.9e9, newFromZero: 4, avNewFromZero: 2e6 }) },
    '1': { parcels: 1219, years: { '2025': fig(320_888_700, 1219, 1219) }, pair: pairOf() },
    '3': { parcels: 10, years: { '2025': fig(1, 10), '2026': fig(2, 10, 10) }, pair: pairOf({ parcelsBoth: 10, avPriorBoth: 1, avCurrentBoth: 2 }) },
    years: [2025, 2026],
  };
  it('cards / roll only / <year> TBA', () => {
    expect(countyChip(run['45'], Y)).toBe('cards');
    expect(countyChip(run['3'], Y)).toBe('roll only');
    expect(countyChip(run['1'], Y)).toBe('2026 TBA');
    expect(countyChips(JSON.stringify(run), Y)).toEqual({ 1: '2026 TBA', 3: 'roll only', 45: 'cards' });
  });
  it('Review Focus 4: a run whose newest year is 2027 in one county — every other county reads "2027 TBA"', () => {
    const y27: DisplayYears = [2026, 2027];
    expect(countyChip({ parcels: 5, years: { '2026': fig(1, 5), '2027': fig(1, 5, 5) } }, y27)).toBe('roll only');
    expect(countyChip(run['45'], y27)).toBe('2027 TBA');
  });
  it('the banner: Σ y1 → Σ y2 with roll counts, the pair YoY, the new-from-zero count', () => {
    const b = countyYearBanner(JSON.stringify(run), 45, Y)!;
    expect(b.countyCount).toBe(1);
    expect(b.parcels).toBe(15001);
    expect(b.y1).toEqual(fig(10e9, 15000, 3));
    expect(b.y2).toEqual(fig(11e9, 14000, 10));
    expect(b.parcelsBoth).toBe(13990);
    expect(b.yoyPct).toBe(10);
    expect(b.newFromZero).toBe(4);
    expect(b.chip).toBe('cards');
    const tba = countyYearBanner(JSON.stringify(run), 1, Y)!;
    expect(tba.y2).toBeNull();
    expect(tba.yoyPct).toBeNull();
    expect(tba.chip).toBe('2026 TBA');
    const all = countyYearBanner(JSON.stringify(run), null, Y)!;
    expect(all.countyCount).toBe(3);
    expect(all.y2).toEqual(fig(11e9 + 2, 14010, 20));
    expect(all.chip).toBeNull();
    expect(countyYearBanner(JSON.stringify(run), 99, Y)).toBeNull();
  });
});

const P = (over: Partial<OwnerParcelRow>): OwnerParcelRow => ({
  id: 'p', gisParcelNumber: '', address: null, typeGroup: null, currentAV: null, av2025: null, av2026: null,
  avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null,
  conf: null, supCount: null, appealed: false, existingRep: null, lastAppealYear: null, ...over,
});

describe('parcel years read live from Parcel Year Headlines', () => {
  const headlines = [
    { ParcelID: 'A', AssessmentYear: 2025, HeadlineTotalAV: 1_000_000, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
    { ParcelID: 'A', AssessmentYear: 2026, HeadlineTotalAV: 1_100_000, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' },
    { ParcelID: 'B', AssessmentYear: 2026, HeadlineTotalAV: 500_000, IsPlaceholder: true, HeadlineDataSource: 'DLGF assessment roll' },
    { ParcelID: 'C', AssessmentYear: 2025, HeadlineTotalAV: 200_000, IsPlaceholder: false, HeadlineDataSource: null },
    { ParcelID: 'Z', AssessmentYear: 2026, HeadlineTotalAV: 0, IsPlaceholder: false, HeadlineDataSource: null },
    { ParcelID: 'Z', AssessmentYear: 2025, HeadlineTotalAV: 0, IsPlaceholder: false, HeadlineDataSource: null },
  ];
  const map = mapParcelYearHeadlines(headlines);
  const parcels = [
    P({ id: 'a', parcelId: 'A', address: '1 A St', currentYear: 2026 }),
    P({ id: 'b', parcelId: 'B', address: '2 B St' }),
    P({ id: 'c', parcelId: 'C', address: '3 C St' }),
    P({ id: 'z', parcelId: 'Z', address: '4 Z St' }),
  ];
  const rows = buildParcelViewRows(parcels, map, Y);

  it('maps rows by parcel and year: the figure, the roll flag, the source label', () => {
    expect(map['A']['2026']).toEqual({ av: 1_100_000, roll: true, source: 'DLGF assessment roll' });
    expect(map['C']['2025']).toEqual({ av: 200_000, roll: false, source: null });
  });
  it('Review Focus 1: a 2026 roll figure and no 2025 figure — 2025 —, YoY —', () => {
    const b = rows[1];
    expect(parcelYearCell(b.y1, 2025, Y)).toBe('—');
    expect(parcelYearCell(b.y2, 2026, Y)).toBe(500_000);
    expect(b.y2?.roll).toBe(true);
    expect(b.yoyPct).toBeNull();
    expect(parcelStatus(b, Y)).toBe('2025 — · 2026 roll');
  });
  it('YoY over both figures (roll included); a $0 prior is no YoY; TBA for a missing newest year', () => {
    expect(rows[0].yoyPct).toBe(10);
    expect(parcelStatus(rows[0], Y)).toBe('2026 roll');
    expect(parcelYearCell(rows[2].y2, 2026, Y)).toBe('TBA');
    expect(parcelStatus(rows[2], Y)).toBe('2026 TBA');
    expect(rows[3].yoyPct).toBeNull();
    expect(parcelStatus(rows[3], Y)).toBe('new since 2025');
  });
  it('the newest year: the parcel row\'s own CurrentYear, else the newest headline read', () => {
    expect(rows.map((r) => r.newestYear)).toEqual([2026, 2026, 2025, 2026]);
  });
  it('not loaded (null map): no figures, no gap markers claimed', () => {
    const r = buildParcelViewRows(parcels, null, Y)[0];
    expect(r.loaded).toBe(false);
    expect(r.y1).toBeNull();
    expect(parcelStatus(r, Y)).toBe('year figures not loaded');
  });

  it('Review Focus 5: every sort puts blanks last, in both directions', () => {
    const ids = (k: Parameters<typeof sortParcels>[1], d: 1 | -1) => sortParcels(rows, k, d).map((r) => r.parcel.id);
    expect(ids('yoy', -1)).toEqual(['a', 'b', 'c', 'z']);
    expect(ids('yoy', 1)).toEqual(['a', 'b', 'c', 'z']);
    expect(ids('avYear2', -1)).toEqual(['a', 'b', 'z', 'c']);
    expect(ids('avYear2', 1)).toEqual(['z', 'b', 'a', 'c']);
    expect(ids('avYear1', 1)).toEqual(['z', 'c', 'a', 'b']);
    expect(ids('avYear1', -1)).toEqual(['a', 'c', 'z', 'b']);
    expect(ids('parcel', -1)).toEqual(['z', 'c', 'b', 'a']);
    const typed = buildParcelViewRows([P({ id: 't1', typeGroup: 'Retail' }), P({ id: 't2' }), P({ id: 't3', typeGroup: 'Office' })], map, Y);
    expect(sortParcels(typed, 'type', 1).map((r) => r.parcel.id)).toEqual(['t3', 't1', 't2']);
    expect(sortParcels(typed, 'type', -1).map((r) => r.parcel.id)).toEqual(['t1', 't3', 't2']);
  });
});

describe('export rows for Task 3 — numbers as numbers, gaps as null, a status string', () => {
  it('exportRows (Statewide): the year figures, YoY and status per owner', () => {
    const rows = exportRows([abc, only2025], Y, 'Statewide');
    expect(rows[0]).toMatchObject({ owner: 'ABC Holdings', avYear1: 1_200_000, avYear2: 1_600_000, yoyPct: 10, status: '2025: 2 of 3 · roll 0; 2026 assessed: 2 of 3 · roll 2', tierBasis: 'AV' });
    expect(rows[1]).toMatchObject({ avYear1: 9_000_000, avYear2: null, yoyPct: null, status: '2025: 12 of 12 · roll 12; 2026 TBA (12 parcels)' }); // Review Focus 3: a gap is null
    // Final-review I2: the roll parcel count per year travels as a number beside the figures.
    expect(rows.map((r) => [r.rollYear1, r.rollYear2])).toEqual([[0, 2], [12, 0]]);
    // Final-review I3: the newest-figure total (AVCurrent) travels too.
    expect(exportRows([{ ...abc, avCurrent: 1_700_000 }], Y, 'Statewide')[0].avNewest).toBe(1_700_000);
    expect(typeof rows[0].avYear1).toBe('number');
    // Task 3: the owner's AVYoYDollars travels as a number; null without a pair.
    expect(exportRows([{ ...abc, avYoYDollars: 100_000 }, only2025], Y, 'Statewide').map((r) => r.yoyDollars)).toEqual([100_000, null]);
  });
  it('exportRows (Marion): the fixed columns, the savings figure', () => {
    const marion = owner({ label: 'ACME', tierBasis: 'Savings', totalAV2025: 4_000_000, totalAV2026: 4_200_000, avYoYPct: 5, estSavingsAtAsk: 51_000, byCounty: {}, ownerKey: 'acme' });
    expect(exportRows([marion], Y, 'Marion')[0]).toMatchObject({
      owner: 'ACME', avYear1: 4_000_000, avYear2: 4_200_000, yoyPct: 5, savingsAtAsk: 51_000, savingsMarionParcelsOnly: false, ownerKey: 'acme', tierBasis: 'Savings',
      rollYear1: null, rollYear2: null, // the Marion run carries no per-year roll counts
    });
  });
  it('exportParcelRows: per-year figures and roll flags, null gaps, the status words', () => {
    const map = mapParcelYearHeadlines([{ ParcelID: 'B', AssessmentYear: 2026, HeadlineTotalAV: 500_000, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' }]);
    const rows = exportParcelRows(buildParcelViewRows([P({ id: 'b', parcelId: 'B', parcelNumber: '45-1', address: '2 B St', countyNumber: 45 })], map, Y, { 45: 'Lake' }), Y);
    expect(rows[0]).toMatchObject({ parcel: '45-1', address: '2 B St', county: 'Lake', avYear1: null, avYear2: 500_000, rollYear1: false, rollYear2: true, yoyPct: null, status: '2025 — · 2026 roll' });
    expect(rows[0]).toMatchObject({ ask: null, rec: null, conf: null }); // outside Marion: no valuation analysis
    const marion = exportParcelRows(buildParcelViewRows([P({ id: 'm', parcelId: 'M', gisParcelNumber: '1001234', ask: 900_000, rec: 'Appeal', conf: 'High' })], map, Y), Y);
    expect(marion[0]).toMatchObject({ parcel: '1001234', ask: 900_000, rec: 'Appeal', conf: 'High' });
  });
});

describe('fix round 1 — materiality floor, saved-sort remap, unmatched parcels, thesis years', () => {
  it('the YoY ranking: complete with a material base, then complete on a small base, then incomplete — both directions, blanks last', () => {
    const material = owner({ id: 'mat', yoyPair: 8, completeness: 0.95, avPriorBoth: 5_000_000 });
    const small = owner({ id: 'small', yoyPair: 26_365.2, completeness: 0.99, avPriorBoth: 9_200 });
    const incomplete = owner({ id: 'inc', yoyPair: 40, completeness: 0.5, avPriorBoth: 1_000_000 });
    const blank = owner({ id: 'blank', yoyPair: null, completeness: null, avPriorBoth: null });
    const f = DEFAULT_OWNER_PROSPECTS_FILTERS;
    expect(YOY_MATERIAL_PRIOR).toBe(100_000);
    expect(buildVisibleRows([blank, incomplete, small, material], f, 'yoyPair', -1).map((o) => o.id)).toEqual(['mat', 'small', 'inc', 'blank']);
    expect(buildVisibleRows([blank, incomplete, small, material], f, 'yoyPair', 1).map((o) => o.id)).toEqual(['mat', 'small', 'inc', 'blank']);
    // The Complete-only filter is unchanged: both complete tiers stay.
    expect(buildVisibleRows([blank, incomplete, small, material], f, 'yoyPair', -1, true).map((o) => o.id)).toEqual(['mat', 'small']);
    expect([material, small, incomplete].map(yoyRankTier)).toEqual([0, 1, 2]);
  });
  it('annotateOwnerYears stamps the pair\'s prior base (null without a pair)', () => {
    const rows = [{ ...abc }, { ...only2025 }];
    annotateOwnerYears(rows, Y);
    expect(rows.map((r) => r.avPriorBoth)).toEqual([1_000_000, null]);
  });
  it('saved Statewide sorts on the removed columns restore as the fixed-pair YoY', () => {
    expect(remapStatewideSortKey('avPrior')).toBe('yoyPair');
    expect(remapStatewideSortKey('avYoYPct')).toBe('yoyPair');
    expect(remapStatewideSortKey('avCurrent')).toBe('avCurrent');
  });
  it('a parcel with no ParcelID is not loaded — never a false TBA / —', () => {
    const map = mapParcelYearHeadlines([{ ParcelID: 'A', AssessmentYear: 2025, HeadlineTotalAV: 1 }]);
    const [withId, noId] = buildParcelViewRows([P({ id: 'a', parcelId: 'A' }), P({ id: 'x', parcelId: null })], map, Y);
    expect(withId.loaded).toBe(true);
    expect(noId.loaded).toBe(false);
    expect(parcelStatus(noId, Y)).toBe('year figures not loaded');
  });
  it('statewideThesis states AV with its years, the TBA count and the pair YoY — no year-less total, no placeholder wording', () => {
    const t = statewideThesis({ ...abc, countyCount: 1, tier: 'A', repStatus: 'No rep data for this county' }, null, Y);
    // Final-review I2: each year names its DLGF roll count.
    expect(t).toContain('3 parcels in 1 county. AV 2026 $1,600,000 (2 of 3 parcels, 2 DLGF roll); AV 2025 $1,200,000 (2 of 3 parcels, 0 DLGF roll). 1 parcel TBA for 2026. YoY +10% over parcels with both years.');
    expect(t).not.toContain('placeholder');
    expect(statewideThesis({ ...only2025, countyCount: 1 }, null, Y)).toContain('AV 2026 TBA (12 parcels); AV 2025 $9,000,000 (12 of 12 parcels, 12 DLGF roll). No 2025→2026 YoY.');
  });
});

describe('final-review fix round — snapshot total, run vs live, parcel YoY $', () => {
  it('C1: the Flag snapshot Total AV — Statewide the newest-figure total (AVCurrent), never the partial 2026 sum; Marion unchanged', () => {
    const gm = { totalAV: 382_271_300, totalAV2026: 357_342_400, avCurrent: 382_271_300 }; // 6 of 28 parcels have 2026
    expect(snapshotTotalAV(gm, 'Statewide')).toBe(382_271_300);
    expect(snapshotTotalAV({ ...gm, avCurrent: null }, 'Statewide')).toBe(382_271_300);
    expect(snapshotTotalAV({ totalAV: 4_000_000, totalAV2026: 4_200_000, avCurrent: null }, 'Marion')).toBe(4_200_000);
    expect(snapshotTotalAV({ totalAV: 4_000_000, totalAV2026: null, avCurrent: null }, 'Marion')).toBe(4_000_000);
  });
  it('I1: runVsLiveNote — null within $1 or when both are empty; the stored and live figures and the builder otherwise', () => {
    expect(runVsLiveNote(36_279_300, 36_279_300.4)).toBeNull();
    expect(runVsLiveNote(null, null)).toBeNull();
    expect(runVsLiveNote(36_279_300, 17_972_700, 'Marion'))
      .toBe("The stored run differs from today's headlines for this owner (stored $36,279,300, live $17,972,700) — re-run the Marion builder to refresh.");
    expect(runVsLiveNote(null, 5_000, 'Statewide'))
      .toBe("The stored run differs from today's headlines for this owner (stored none, live $5,000) — re-run the Statewide builder to refresh.");
    expect(runVsLiveNote(5_000, null, 'Marion')).toContain('live none');
    // The older year joins the comparison: a run stale on 2025 only still warns, naming the year.
    expect(runVsLiveNote(46_564_600, 46_564_600, 'Marion', { year: 2025, stored: 63_104_300, live: 44_421_200 }, 2026))
      .toBe("The stored run differs from today's headlines for this owner (2025: stored $63,104,300, live $44,421,200) — re-run the Marion builder to refresh.");
    expect(runVsLiveNote(1, 1, 'Marion', { year: 2025, stored: 5, live: 5 }, 2026)).toBeNull();
  });
  it('I1: the live total sums one year over the owner\'s parcels; the stored total is the scope\'s own column', () => {
    const map = mapParcelYearHeadlines([
      { ParcelID: 'A', AssessmentYear: 2026, HeadlineTotalAV: 100 },
      { ParcelID: 'B', AssessmentYear: 2026, HeadlineTotalAV: 0 },
      { ParcelID: 'B', AssessmentYear: 2025, HeadlineTotalAV: 70 },
    ]);
    expect(liveYearTotal(map, 2026)).toBe(100);
    expect(liveYearTotal(map, 2025)).toBe(70);
    expect(liveYearTotal(map, 2024)).toBeNull();
    const row = owner({ totalAV2026: 4_200_000, avYear2: 1_600_000 });
    expect(storedYear2Total(row, 'Marion')).toBe(4_200_000);
    expect(storedYear2Total(row, 'Statewide')).toBe(1_600_000);
  });
  it('I1: the source note names the scope and the run date', () => {
    expect(runLiveSourceNote('Marion', new Date(2026, 8, 24, 10))).toBe('Parcel figures are live from the headline table; the owner row is from the Marion run of 2026-09-24.');
    expect(runLiveSourceNote('Statewide', null)).toBe('Parcel figures are live from the headline table; the owner row is from the Statewide run (undated).');
  });
  it('I4: parcel YoY $ is blank for a $0 prior (and without both years)', () => {
    const v = (av: number) => ({ av, roll: false, source: null });
    expect(parcelYoYDollars(v(1_000), v(1_500))).toBe(500);
    expect(parcelYoYDollars(v(0), v(5_800))).toBeNull();
    expect(parcelYoYDollars(null, v(5_800))).toBeNull();
  });
});
