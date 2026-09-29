import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Component, Input, NO_ERRORS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Subject } from 'rxjs';
import { IMetadataProvider, RunViewParams, RunViewResult } from '@memberjunction/core';
import { ResourceData, UserInfoEngine } from '@memberjunction/core-entities';
import { NavigationService } from '@memberjunction/ng-shared';
import { MJNotificationService } from '@memberjunction/ng-notifications';
import { renderComponentFixture, queryAll, query } from '@memberjunction/ng-test-utils';
import { OwnerProspectsDashboardComponent } from './owner-prospects-dashboard.component';
import { OwnerDetailPanelComponent } from './owner-detail-panel.component';
import { NO_ANALYSIS_TOOLTIP, OwnerRow, mapParcelYearHeadlines } from './owner-prospects.model';
import { ExportEngine, ExportResult, SheetDefinition } from '@memberjunction/export-engine';
import { MJConfirmService, MJConfirmOptions } from '@memberjunction/ng-ui-components';
import { OwnerProspectsDataAccess } from './owner-prospects-statewide-data';

/**
 * DOM/TestBed coverage for the Owner Prospects statewide scope (owner-prospects-statewide
 * plan, Task 5): the scope switch re-queries (with the 2-row run tripwire and the top-5,001
 * portfolio query), the county filter (a multi-county owner under each of its counties and
 * once under All), the query-param round trip, and the honest empties in the rendered table
 * and detail panel. The Marion path is exercised alongside to show it renders as before.
 *
 * `ProviderToUse` is a hand-rolled fake that answers by EntityName and records every
 * RunView params object. Fixture rows mirror the live Statewide run 19153E40-… shapes.
 */

type Raw = Record<string, unknown>;

const fig = (av: number, parcels: number, roll = 0): Raw => ({ av, parcels, roll });
const pair = (parcelsBoth: number, avPriorBoth: number, avCurrentBoth: number, newFromZero = 0): Raw => ({
  prior: 2025, current: 2026, parcelsBoth, avPriorBoth, avCurrentBoth, newFromZero, avNewFromZero: newFromZero ? 1 : 0, yoyPct: null,
});
/** The run-level ByCountyJSON as Task 1 writes it: per county `years` + `pair`, and the run's `years` list. */
const runJSON = (years: number[] = [2025, 2026]): string => JSON.stringify({
  '2': { parcels: 5, avCurrent: 43_143_000, years: { '2025': fig(43_143_000, 5, 5) }, pair: pair(0, 0, 0) },
  '45': {
    parcels: 15001, avCurrent: 10_521_026_180, years: { '2025': fig(9_600_000_000, 14990, 1), '2026': fig(10_521_026_180, 14851) },
    pair: pair(14851, 9_563_918_300, 10_408_930_080, 3),
  },
  '49': { parcels: 17, avCurrent: 102_416_600, years: { '2025': fig(82_776_800, 17), '2026': fig(102_416_600, 17) }, pair: pair(17, 82_776_800, 102_416_600) },
  years,
});
const STATEWIDE_RUN: Raw = {
  ID: 'S1', Scope: 'Statewide', IsLatest: 1, RunDate: '2026-09-28T21:29:44Z', MethodologyVersion: 'statewide-v1',
  CountyCount: 3, ByCountyJSON: runJSON(),
};
const MARION_RUN: Raw = { ID: 'M1', Scope: 'Marion', IsLatest: 1, RunDate: '2026-09-24T10:36:38Z', MethodologyVersion: 'sales-p25', CountyTotalAV2025: 1, CountyTotalAV2026: 2, CountyYoYPct: 15.2, ByCountyJSON: null };

const statewideOwner = (over: Raw): Raw => ({
  Kind: 'Company', Tier: 'A', TierBasis: 'AV', RepStatus: 'No rep data for this county', ParcelCount: 1,
  EstSavingsAtAsk: null, EstSavingsAtFloor: null, GroupKeyType: 'NAME', ...over,
});
const WALMART = statewideOwner({
  ID: 'w', Label: 'Walmart Inc.', GroupKeyType: 'CO', PrimaryCountyNumber: 49, CountyCount: 2, ParcelCount: 21, AVPrior: 119_809_900, AVCurrent: 138_333_200,
  TotalAV: 138_333_200, AVYoYPct: 15.5, EstSavingsAtAsk: 162_164.47, RepStatus: 'Represented by INTEGRITY TAX CONSULTING',
  PairYears: '2025→2026', NAppealRec: 5,
  ByCountyJSON: JSON.stringify({
    '45': { parcels: 4, avCurrent: 35_916_600, avPrior: 37_033_100, years: { '2025': fig(37_033_100, 4), '2026': fig(35_916_600, 4) }, pair: pair(4, 37_033_100, 35_916_600) },
    '49': { parcels: 17, avCurrent: 102_416_600, avPrior: 82_776_800, years: { '2025': fig(82_776_800, 17), '2026': fig(102_416_600, 17) }, pair: pair(17, 82_776_800, 102_416_600) },
  }),
});
const LAKE_ONLY = statewideOwner({
  ID: 'l', Label: 'Lake Only LLC', PrimaryCountyNumber: 45, CountyCount: 1, AVPrior: 5_700, AVCurrent: 2_729_600, TotalAV: 2_729_600,
  AVYoYPct: 47_787.7,
  ByCountyJSON: JSON.stringify({ '45': { parcels: 1, avCurrent: 2_729_600, avPrior: 5_700, years: { '2025': fig(5_700, 1), '2026': fig(2_729_600, 1) }, pair: pair(1, 5_700, 2_729_600) } }),
});
/** Review Focus 2: an Allen owner assessed only through 2025 (the DLGF roll) — 2026 is TBA. */
const ALLEN_ONLY = statewideOwner({
  ID: 'a', Label: 'Allen Only LLC', Tier: 'B', PrimaryCountyNumber: 2, CountyCount: 1, AVPrior: null, AVCurrent: 900_000, TotalAV: 900_000,
  ByCountyJSON: JSON.stringify({ '2': { parcels: 1, avCurrent: 900_000, avPrior: null, years: { '2025': fig(900_000, 1, 1) }, pair: pair(0, 0, 0) } }),
});
const MARION_OWNER: Raw = {
  ID: 'm', Label: 'ACME PROPERTIES', Kind: 'Company', Tier: 'Prime', TierBasis: 'Savings', RepStatus: 'No rep on record',
  ParcelCount: 1, TotalAV2025: 4_000_000, TotalAV2026: 4_200_000, AVYoYPct: 5, EstSavingsAtAsk: 51_000, EstSavingsAtFloor: 33_000,
};

/** Mimics the server's `Label LIKE '%term%'` (unescaping the quote-doubling and [x] brackets). */
function labelSearch(filter: string, rows: Raw[]): Raw[] {
  const m = /Label LIKE '%(.*)%'$/.exec(filter);
  if (!m) return rows;
  const term = m[1].replace(/''/g, "'").replace(/\[(.)\]/g, '$1').toLowerCase();
  return rows.filter((r) => String(r['Label']).toLowerCase().includes(term));
}

interface FakeState {
  runs: Raw[];
  calls: RunViewParams[];
  /** Overrides the statewide portfolio rows (the cap test). */
  statewideOwners?: Raw[];
  /** Overrides the Marion run's owner rows. */
  marionOwners?: Raw[];
  /** Parcel rows per owner id; 'fail' makes that owner's parcel read fail. Default: none. */
  parcelsFor?: (ownerId: string) => Raw[] | 'fail';
  /** Makes the server search (a `Label LIKE` owners read) fail. */
  failSearch?: boolean;
  /** `Parcel Year Headlines` rows (every read gets them all; the component keys them by ParcelID). */
  headlines?: Raw[];
  /** Makes the `Parcel Year Headlines` read fail. */
  failHeadlines?: boolean;
  /** Existing `indiana_tax.Prospect` rows (ID, OwnerKey). Default: none. */
  prospects?: Raw[];
  /** Entity saves, by entity name: the fields each saved object carried. */
  saved: Map<string, Raw[]>;
  notes: string[];
}

/** A fake entity: plain assignable fields; Save records them (Prospects get an ID). */
function fakeEntity(entityName: string, state: FakeState): Raw {
  const obj: Raw = {
    LatestResult: null,
    NewRecord: (): void => undefined,
    Save: async (): Promise<boolean> => {
      if (entityName === 'Prospects') obj['ID'] = 'prospect-1';
      const rows = state.saved.get(entityName) ?? [];
      rows.push({ ...obj });
      state.saved.set(entityName, rows);
      return true;
    },
  };
  return obj;
}

function fakeProvider(state: FakeState): IMetadataProvider {
  const ok = <T>(rows: Raw[]): RunViewResult<T> =>
    ({ Success: true, Results: rows as unknown as T[], RowCount: rows.length, TotalRowCount: rows.length }) as RunViewResult<T>;
  const answer = (p: RunViewParams): Raw[] => {
    state.calls.push(p);
    switch (p.EntityName) {
      case 'Owner Portfolio Runs': {
        const scope = /Scope = '(\w+)'/.exec(p.ExtraFilter ?? '')?.[1];
        return state.runs.filter((r) => r['Scope'] === scope);
      }
      case 'Counties':
        return [
          { CountyNumber: 2, Name: 'Allen', Slug: 'allen' },
          { CountyNumber: 45, Name: 'Lake', Slug: 'lake' },
          { CountyNumber: 49, Name: 'Marion', Slug: 'marion' },
        ];
      case 'Owner Portfolios':
        // The fake ignores the SQL county clause on purpose: the component's own filterByCounty must hold the line.
        if ((p.ExtraFilter ?? '').includes("'M1'")) return state.marionOwners ?? [MARION_OWNER];
        return labelSearch(p.ExtraFilter ?? '', state.statewideOwners ?? [WALMART, LAKE_ONLY, ALLEN_ONLY]).slice(0, p.MaxRows ?? undefined);
      case 'Prospects':
        return state.prospects ?? [];
      case 'Parcel Year Headlines':
        return state.headlines ?? [];
      case 'Owner Portfolio Parcels': {
        const id = /OwnerPortfolioID = '([^']*)'/.exec(p.ExtraFilter ?? '')?.[1] ?? '';
        const rows = state.parcelsFor?.(id) ?? [];
        return rows === 'fail' ? [] : rows.slice(0, p.MaxRows ?? undefined);
      }
      default:
        return [];
    }
  };
  const fails = (p: RunViewParams): boolean =>
    (p.EntityName === 'Owner Portfolio Parcels' && state.parcelsFor?.(/OwnerPortfolioID = '([^']*)'/.exec(p.ExtraFilter ?? '')?.[1] ?? '') === 'fail') ||
    (p.EntityName === 'Owner Portfolios' && !!state.failSearch && (p.ExtraFilter ?? '').includes('Label LIKE')) ||
    (p.EntityName === 'Parcel Year Headlines' && !!state.failHeadlines);
  const fake = {
    CurrentUser: { ID: 'u1', Name: 'Test User', Email: 'test@example.com' },
    async RunView<T>(p: RunViewParams): Promise<RunViewResult<T>> {
      if (fails(p)) {
        state.calls.push(p);
        return { Success: false, Results: [], ErrorMessage: 'simulated failure' } as unknown as RunViewResult<T>;
      }
      return ok<T>(answer(p));
    },
    async GetEntityObject<T>(entityName: string): Promise<T> {
      return fakeEntity(entityName, state) as unknown as T;
    },
    async RunViews<T>(ps: RunViewParams[]): Promise<RunViewResult<T>[]> {
      return ps.map((p) => ok<T>(answer(p)));
    },
  };
  return fake as unknown as IMetadataProvider;
}

interface Harness {
  fixture: ComponentFixture<OwnerProspectsDashboardComponent>;
  component: OwnerProspectsDashboardComponent;
  state: FakeState;
  pushed: Record<string, string | null>[];
}

function mount(queryParams: Record<string, string>, runs: Raw[] = [STATEWIDE_RUN, MARION_RUN], withPanel = false): Harness {
  const state: FakeState = { runs, calls: [], saved: new Map(), notes: [] };
  const pushed: Record<string, string | null>[] = [];
  TestBed.configureTestingModule({
    // withPanel renders the real detail panel under the opened owner (the live-read cross-check).
    declarations: withPanel ? [OwnerProspectsDashboardComponent, OwnerDetailPanelComponent] : [OwnerProspectsDashboardComponent],
    imports: withPanel ? [CommonModule, StubButton] : [CommonModule],
    providers: [
      {
        provide: NavigationService,
        useValue: {
          QueryParamChanged$: new Subject(),
          SetAgentContext: (): void => {},
          SetAgentClientTools: (): void => {},
          OpenEntityRecord: (): void => {},
          UpdateActiveTabQueryParams: (p: Record<string, string | null>): void => void pushed.push(p),
          UpdateTabQueryParams: (_t: string, p: Record<string, string | null>): void => void pushed.push(p),
        },
      },
      { provide: MJNotificationService, useValue: { CreateSimpleNotification: (m: string): void => void state.notes.push(m) } },
    ],
    schemas: [NO_ERRORS_SCHEMA],
  });
  const fixture = TestBed.createComponent(OwnerProspectsDashboardComponent);
  const component = fixture.componentInstance;
  component.Provider = fakeProvider(state);
  component.Data = new ResourceData({ Configuration: { queryParams } });
  return { fixture, component, state, pushed };
}

async function settle(h: Harness): Promise<void> {
  await vi.waitFor(() => expect(h.component.IsLoading).toBe(false));
  h.fixture.detectChanges();
}

const runCalls = (s: FakeState): RunViewParams[] => s.calls.filter((c) => c.EntityName === 'Owner Portfolio Runs');
const ownerCalls = (s: FakeState): RunViewParams[] => s.calls.filter((c) => c.EntityName === 'Owner Portfolios');
const el = (h: Harness): HTMLElement => h.fixture.nativeElement as HTMLElement;

beforeEach(() => {
  vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockReturnValue(undefined);
  vi.spyOn(UserInfoEngine.Instance, 'SetSettingDebounced').mockImplementation(() => undefined);
});

describe('Owner Prospects statewide scope (DOM)', () => {
  it('reads ?scope=Statewide on init: the Statewide run with the 2-row tripwire, then the top 5,001 portfolios by AV', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);

    expect(runCalls(h.state)).toHaveLength(1);
    expect(runCalls(h.state)[0].ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Statewide'");
    expect(runCalls(h.state)[0].MaxRows).toBe(2);
    const oc = ownerCalls(h.state);
    expect(oc).toHaveLength(1);
    expect(oc[0].ExtraFilter).toBe("RunID = 'S1'");
    expect(oc[0].OrderBy).toBe('AVCurrent DESC');
    expect(oc[0].MaxRows).toBe(5001);
    expect(h.state.calls.some((c) => c.EntityName === 'Owner Portfolio Parcels')).toBe(false); // parcels load per opened owner
    expect(h.component.VisibleRows.map((r) => r.id).sort()).toEqual(['a', 'l', 'w']);
  });

  it('switching scope re-queries the other run and pushes ?scope=', async () => {
    const h = mount({});
    h.fixture.detectChanges();
    await settle(h);
    expect(runCalls(h.state)[0].ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Marion'");
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['m']);

    h.component.onScopeChange('Statewide');
    await settle(h);
    expect(runCalls(h.state)).toHaveLength(2);
    expect(runCalls(h.state)[1].ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Statewide'");
    expect(h.pushed.at(-1)).toEqual({ scope: 'Statewide', county: null, complete: null });

    h.component.onScopeChange('Marion');
    await settle(h);
    expect(runCalls(h.state)[2].ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Marion'");
    expect(h.pushed.at(-1)).toEqual({ scope: null, county: null, complete: null });
  });

  it('county filter: a multi-county owner lists under each of its counties and once under All', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);

    h.component.onCountyChange(45);
    await settle(h);
    expect(ownerCalls(h.state).at(-1)!.ExtraFilter).toBe(`RunID = 'S1' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`);
    expect(h.component.VisibleRows.map((r) => r.id).sort()).toEqual(['l', 'w']);
    expect(h.pushed.at(-1)).toEqual({ scope: 'Statewide', county: '45', complete: null });
    expect(el(h).querySelector('[data-testid="county-banner"]')?.textContent).toContain('Lake');
    expect(el(h).querySelector('[data-testid="county-banner"]')?.textContent).toContain('+8.8%');

    h.component.onCountyChange(49);
    await settle(h);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w']);

    h.component.onCountyChange(null);
    await settle(h);
    const ids = h.component.VisibleRows.map((r) => r.id);
    expect(ids.filter((id) => id === 'w')).toHaveLength(1);
    expect(ids.sort()).toEqual(['a', 'l', 'w']);
  });

  it('?county= round-trips back in through OnQueryParamsChanged', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const deliver = (h.component as unknown as { OnQueryParamsChanged(p: Record<string, string>, s: 'popstate'): void }).OnQueryParamsChanged.bind(h.component);
    deliver({ scope: 'Statewide', county: '2' }, 'popstate');
    await settle(h);
    expect(h.component.CountyNumber).toBe(2);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['a']);
    deliver({}, 'popstate');
    await settle(h);
    expect(h.component.Scope).toBe('Marion');
    expect(h.component.CountyNumber).toBeNull();
  });

  it('renders the honest empties: AV tier header, blank savings with the tooltip, stored rep status; the YoY sort ranks complete owners', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);

    expect(query(h.fixture, '[data-testid="tier-header"]')?.textContent?.trim()).toBe('AV tier');
    const opp = queryAll(h.fixture, '[data-testid="opp-ask"]');
    expect(opp).toHaveLength(3);
    const withSavings = opp.filter((c) => (c.textContent ?? '').includes('$162,164'));
    expect(withSavings).toHaveLength(1); // Walmart's savings exist, so they show …
    const marker = withSavings[0].querySelector('[data-testid="marion-parcels-marker"]');
    expect(marker?.textContent?.trim()).toBe('Marion parcels'); // … flagged as Marion-parcels-only
    expect(marker?.getAttribute('title')).toBe("from valuation analyses on this owner's Marion parcels only");
    for (const cell of opp.filter((c) => c !== withSavings[0])) {
      expect(cell.textContent?.trim()).toBe(''); // null savings stay blank …
      expect(cell.getAttribute('title')).toBe(NO_ANALYSIS_TOOLTIP); // … with the exact tooltip
    }
    const reps = queryAll(h.fixture, '[data-testid="rep-cell"]').map((c) => c.textContent?.trim());
    expect(reps).toContain('No rep data for this county');
    // Walmart (Marion + Lake) also carries the Marion-parcels rep marker since the final-review fix round (I3).
    expect(reps.some((r) => r?.startsWith('Represented by INTEGRITY TAX CONSULTING'))).toBe(true);
    // AV, never the blank savings; the newest-figure sum says it mixes years (final-review I3); company owners (M5).
    expect(h.component.FilterCountLabel).toBe('3 company owners · Σ AV (newest figure per parcel, mixed years) $142.0M');
    expect(queryAll(h.fixture, '[data-testid="yoy-floor-pill"]')).toHaveLength(0); // the $100k floor is gone (2026-09-28 evening)
    // YoY sort (the default statewide sort is AV): Complete YoY only turns on by default — the 2026-TBA Allen owner drops out.
    h.component.onSortColumn('yoyPair'); // a fresh numeric column starts descending
    expect(h.component.CompleteOnly).toBe(true);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l']); // fix round 1: Lake's $5,700 base ranks after Walmart
  });

  it('Marion stays as it was: Savings tier header, money in the savings cells, "— open" rep cell', async () => {
    const h = mount({});
    h.fixture.detectChanges();
    await settle(h);
    expect(query(h.fixture, '[data-testid="tier-header"]')?.textContent?.trim()).toBe('Savings tier');
    expect(query(h.fixture, '[data-testid="opp-ask"]')?.textContent?.trim()).toBe('$51,000');
    expect(query(h.fixture, '[data-testid="opp-ask"]')?.getAttribute('title')).toBeNull();
    expect(query(h.fixture, '[data-testid="rep-cell"]')?.textContent?.trim()).toBe('— open');
    expect(query(h.fixture, '[data-testid="county-banner"]')).toBeNull();
  });

  it('trips the 5,000-row cap: keeps 5,000, shows the banner (county-aware wording once a county is chosen)', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = Array.from({ length: 6000 }, (_, i) =>
      statewideOwner({ ID: `o${i}`, Label: `Owner ${i}`, PrimaryCountyNumber: 45, AVCurrent: 6000 - i, ByCountyJSON: '{"45":{"parcels":1,"avCurrent":1,"avPrior":null}}' }),
    );
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.RowCapHit).toBe(true);
    expect(h.component.AllOwners).toHaveLength(5000);
    expect(h.component.RowCapMessage).toBe('showing the top 5,000 by AV; filter by county to see all; search by owner name reaches the rest');
    expect(query(h.fixture, '[data-testid="row-cap-banner"]')).not.toBeNull();
    h.component.onCountyChange(45);
    await settle(h);
    expect(h.component.RowCapMessage).toBe('showing the top 5,000 by AV in Lake; search by owner name reaches the rest');
  });

  it('past the cap, a 3+ character search re-queries the server and reaches owners beyond the top 5,000; a short or cleared term returns the page', async () => {
    const h = mount({ scope: 'Statewide', county: '45' });
    h.state.statewideOwners = Array.from({ length: 6000 }, (_, i) =>
      statewideOwner({ ID: `o${i}`, Label: `Owner ${i}`, PrimaryCountyNumber: 45, AVCurrent: 6000 - i, ByCountyJSON: '{"45":{"parcels":1,"avCurrent":1,"avPrior":null}}' }),
    );
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.RowCapHit).toBe(true);
    expect(h.component.AllOwners.some((o) => o.id === 'o5999')).toBe(false); // beyond the loaded page

    h.component.onSearchChange('Owner 5999');
    await vi.waitFor(() => expect(h.component.SearchOwners).not.toBeNull());
    const search = ownerCalls(h.state).at(-1)!;
    expect(search.ExtraFilter).toBe(`RunID = 'S1' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%') AND Label LIKE '%Owner 5999%'`);
    expect(search.MaxRows).toBe(5001);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['o5999']);

    h.component.onSearchChange('ZZZ'); // a miss is an empty table, not the page
    await vi.waitFor(() => expect(h.component.SearchOwners).toEqual([]));
    expect(h.component.VisibleRows).toEqual([]);

    h.component.onSearchChange('Ow'); // under 3 characters: back to the loaded page, client filter
    await vi.waitFor(() => expect(h.component.SearchOwners).toBeNull());
    expect(h.component.VisibleRows).toHaveLength(5000);
    const calls = ownerCalls(h.state).length;
    h.component.onSearchChange('');
    await settle(h);
    expect(ownerCalls(h.state)).toHaveLength(calls); // no server call below the threshold
    expect(h.component.VisibleRows).toHaveLength(5000);
  });

  it('below the cap, search stays client-side (no server query)', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const calls = ownerCalls(h.state).length;
    h.component.onSearchChange('walmart');
    await settle(h);
    expect(ownerCalls(h.state)).toHaveLength(calls);
    expect(h.component.SearchOwners).toBeNull();
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w']);
  });

  it('two latest runs of one scope is an error banner, never a silent pick', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, { ...STATEWIDE_RUN, ID: 'S2' }, MARION_RUN]);
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.LoadError).toMatch(/2 latest Statewide runs/);
    expect(ownerCalls(h.state)).toHaveLength(0);
    expect(h.component.VisibleRows).toEqual([]);
  });

  it('opening a statewide owner fetches only that owner’s parcels', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.VisibleRows.find((r) => r.id === 'w') as OwnerRow;
    h.component.toggleOwner(w);
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    const pc = h.state.calls.filter((c) => c.EntityName === 'Owner Portfolio Parcels');
    expect(pc).toHaveLength(1);
    expect(pc[0].ExtraFilter).toBe("OwnerPortfolioID = 'w'");
  });
});

/** 6,000 Lake owners, `Owner 0` … `Owner 5999`, largest first — trips the 5,000 cap. */
const capPage = (): Raw[] =>
  Array.from({ length: 6000 }, (_, i) =>
    statewideOwner({ ID: `o${i}`, Label: `Owner ${i}`, PrimaryCountyNumber: 45, AVCurrent: 6000 - i, ParcelCount: 2, ByCountyJSON: '{"45":{"parcels":2,"avCurrent":1,"avPrior":null}}' }),
  );
const parcelRows = (ownerId: string, n = 2): Raw[] =>
  Array.from({ length: n }, (_, i) => ({ ID: `${ownerId}-p${i}`, OwnerPortfolioID: ownerId, ParcelID: `${ownerId}-pid${i}`, CountyNumber: 45, AVCurrent: 1000 - i }));
const parcelCalls = (s: FakeState): RunViewParams[] => s.calls.filter((c) => c.EntityName === 'Owner Portfolio Parcels');

describe('Owner Prospects statewide — review fixes (fix round 2)', () => {
  it('1: parcels fetched for an owner are reused when a server search re-creates that owner\'s row', async () => {
    const h = mount({ scope: 'Statewide', county: '45' });
    h.state.statewideOwners = capPage();
    h.state.parcelsFor = (id) => parcelRows(id);
    h.fixture.detectChanges();
    await settle(h);
    const pageRow = h.component.AllOwners.find((o) => o.id === 'o0') as OwnerRow;
    h.component.toggleOwner(pageRow);
    await vi.waitFor(() => expect(pageRow.parcels).toHaveLength(2));
    h.component.toggleOwner(pageRow); // close

    h.component.onSearchChange('Owner 0');
    await vi.waitFor(() => expect(h.component.SearchOwners).not.toBeNull());
    const searchRow = h.component.SearchOwners!.find((o) => o.id === 'o0') as OwnerRow;
    expect(searchRow).not.toBe(pageRow); // a new row object …
    expect(searchRow.parcels).toEqual([]); // … that arrives without parcels
    h.component.toggleOwner(searchRow);
    await vi.waitFor(() => expect(searchRow.parcels).toHaveLength(2)); // … and gets them from the cache
    expect(parcelCalls(h.state)).toHaveLength(1); // no second fetch
  });

  it('1: flagging a never-opened server-search row attaches its parcels', async () => {
    const h = mount({ scope: 'Statewide', county: '45' });
    h.state.statewideOwners = capPage();
    h.state.parcelsFor = (id) => parcelRows(id, 3);
    h.fixture.detectChanges();
    await settle(h);
    h.component.onSearchChange('Owner 5999');
    await vi.waitFor(() => expect(h.component.SearchOwners).toHaveLength(1));
    await h.component.onFlagOwner(h.component.SearchOwners![0]);
    expect(h.state.saved.get('Prospects')).toHaveLength(1);
    expect(h.state.saved.get('Prospect Parcels')?.map((r) => r['ParcelID'])).toEqual(['o5999-pid0', 'o5999-pid1', 'o5999-pid2']);
    expect(h.state.saved.get('Prospect Snapshots')).toHaveLength(1);
  });

  it('1: a flag whose parcel read fails is aborted with a notice — nothing is persisted', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.parcelsFor = (id) => (id === 'a' ? 'fail' : parcelRows(id));
    h.fixture.detectChanges();
    await settle(h);
    const allen = h.component.AllOwners.find((o) => o.id === 'a') as OwnerRow;
    await h.component.onFlagOwner(allen);
    expect(h.state.saved.size).toBe(0);
    expect(allen.prospectId).toBeNull();
    expect(h.state.notes.some((n) => n.startsWith('Flag aborted'))).toBe(true);
  });

  it('2: a Marion row with null TierBasis renders exactly as today', async () => {
    const h = mount({});
    h.state.marionOwners = [
      { ...MARION_OWNER, TierBasis: null },
      { ...MARION_OWNER, ID: 'm2', Label: 'NO ANALYSIS LLC', TierBasis: null, EstSavingsAtAsk: null, RepStatus: 'Represented by RYAN LLC' },
    ];
    h.fixture.detectChanges();
    await settle(h);
    expect(query(h.fixture, '[data-testid="tier-header"]')?.textContent?.trim()).toBe('Savings tier');
    const opp = queryAll(h.fixture, '[data-testid="opp-ask"]').map((c) => c.textContent?.trim());
    expect(opp.sort()).toEqual(['$51,000', '—']);
    expect(queryAll(h.fixture, '[data-testid="marion-parcels-marker"]')).toHaveLength(0);
    expect(queryAll(h.fixture, '[data-testid="rep-cell"]').map((c) => c.textContent?.trim())).toContain('— open');
  });

  it('3: a Statewide row\'s "No rep on record" renders verbatim; Marion\'s still reads "— open"', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = [statewideOwner({ ID: 'x', Label: 'Marion Only LLC', RepStatus: 'No rep on record', PrimaryCountyNumber: 49, AVCurrent: 5 })];
    h.fixture.detectChanges();
    await settle(h);
    expect(query(h.fixture, '[data-testid="rep-cell"]')?.textContent?.trim()).toBe('No rep on record');
    h.component.onScopeChange('Marion');
    await settle(h);
    expect(query(h.fixture, '[data-testid="rep-cell"]')?.textContent?.trim()).toBe('— open');
  });

  it('4: more than 5,000 parcels trips the note on the panel input and in the flagged thesis', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.parcelsFor = (id) => parcelRows(id, 5001);
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.AllOwners.find((o) => o.id === 'w') as OwnerRow;
    const call = await (async () => {
      await h.component.onFlagOwner(w);
      return parcelCalls(h.state)[0];
    })();
    expect(call.MaxRows).toBe(5001);
    expect(w.parcels).toHaveLength(5000);
    expect(h.component.ParcelsCappedFor(w)).toBe(true);
    expect(String(h.state.saved.get('Prospects')?.[0]['Thesis'])).toContain('showing the first 5,000 parcels');
  });

  it('5: the county banner — Σ 2025 → Σ 2026 with roll counts, the pair YoY, new-from-zero, the county chip', async () => {
    const h = mount({ scope: 'Statewide', county: '49' });
    h.fixture.detectChanges();
    await settle(h);
    const t = (id: string): string | undefined => query(h.fixture, `[data-testid="${id}"]`)?.textContent?.trim();
    expect(t('county-banner-chip')).toBe('cards');
    expect(t('county-banner-y1')).toBe('$82,776,800');
    expect(t('county-banner-y2')).toBe('$102,416,600');
    expect(t('county-banner-yoy')).toBe('+23.7%');
    h.component.onCountyChange(45);
    await settle(h);
    expect(t('county-banner-yoy')).toBe('+8.8%');
    expect(t('county-banner-new')).toBe('3 new since 2025');
    h.component.onCountyChange(2); // Allen: DLGF roll for 2025, no 2026 yet
    await settle(h);
    expect(t('county-banner-chip')).toBe('2026 TBA');
    expect(t('county-banner-y2')).toBe('TBA');
    expect(t('county-banner-yoy')).toBe('—');
    expect(query(h.fixture, '[data-testid="county-banner"]')?.textContent).toContain('roll 5');
    h.component.onCountyChange(null);
    await settle(h);
    expect(query(h.fixture, '[data-testid="county-banner-chip"]')).toBeNull(); // All: no single chip
    expect(t('county-banner-y2')).toBe('$10,623,442,780');
  });

  it('6: Appeal recs on Statewide rows — the Marion-parcels marker when non-zero, blank with the tooltip without Marion parcels', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const cells = queryAll(h.fixture, '[data-testid="appeal-recs"]');
    const walmart = cells.find((c) => (c.textContent ?? '').includes('5'));
    expect(walmart?.textContent).toContain('Marion parcels');
    const blanks = cells.filter((c) => c !== walmart);
    expect(blanks).toHaveLength(2);
    for (const c of blanks) {
      expect(c.textContent?.trim()).toBe('');
      expect(c.getAttribute('title')).toBe(NO_ANALYSIS_TOOLTIP);
    }
  });

  it('8: a failed server search drops the old rows and shows an error line; the stat card says top 5,000 loaded', async () => {
    const h = mount({ scope: 'Statewide', county: '45' });
    h.state.statewideOwners = capPage();
    h.fixture.detectChanges();
    await settle(h);
    expect(query(h.fixture, '[data-testid="statewide-total-av-label"]')?.textContent?.trim()).toBe('total assessed value (newest figure per parcel; top 5,000 loaded)');
    h.component.onSearchChange('Owner 5999');
    await vi.waitFor(() => expect(h.component.SearchOwners).toHaveLength(1));
    h.state.failSearch = true;
    h.component.onSearchChange('Owner 5998');
    await vi.waitFor(() => expect(h.component.SearchError).toBe('Owner search failed: simulated failure'));
    expect(h.component.SearchOwners).toBeNull();
    expect(h.component.VisibleRows.some((r) => r.id === 'o5999')).toBe(false);
    h.fixture.detectChanges();
    expect(query(h.fixture, '[data-testid="search-error"]')).not.toBeNull();
  });
});

describe('Owner Prospects statewide — final-review fix round', () => {
  // Stored OwnerKey is the Prospect key in both scopes since the v2 statewide run (I1).
  const LILLY = statewideOwner({
    ID: 'e', Label: 'Eli Lilly & Co.', OwnerKey: 'eli lilly', GroupKeyType: 'CO', CoStarTrueOwner: 'Eli Lilly & Co.',
    PrimaryCountyNumber: 49, CountyCount: 2, ParcelCount: 68, PairYears: '2025→2026', AVPrior: 700_000_000,
    AVCurrent: 798_586_994, TotalAV: 798_586_994, RepStatus: 'No rep on record',
    ByCountyJSON: '{"49":{"parcels":66,"avCurrent":790000000,"avPrior":700000000,"pairedParcels":60},"29":{"parcels":2,"avCurrent":8586994,"avPrior":null,"pairedParcels":0}}',
  });

  it('I1: a Statewide row whose OwnerKey is an existing Prospect key shows as flagged', async () => {
    const h = mount({ scope: 'Statewide', county: '49' });
    h.state.statewideOwners = [LILLY, WALMART];
    h.state.prospects = [{ ID: 'P-lilly', OwnerKey: 'eli lilly' }];
    h.fixture.detectChanges();
    await settle(h);
    const lilly = h.component.AllOwners.find((o) => o.id === 'e') as OwnerRow;
    expect(lilly.prospectId).toBe('P-lilly');
    const row = queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes('Eli Lilly'));
    expect(row?.querySelector('.pill--flagged')?.textContent?.trim()).toBe('flagged');
    const walmartRow = queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes('Walmart'));
    expect(walmartRow?.querySelector('.pill--flagged')).toBeNull();
  });

  it('I3: a Walmart-shaped row (Marion + Lake) carries the Marion-parcels marker on its rep cell; a Lake-only row does not', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const cells = queryAll(h.fixture, '[data-testid="rep-cell"]');
    const walmart = cells.find((c) => c.textContent?.includes('INTEGRITY TAX CONSULTING'));
    const marker = walmart?.querySelector('[data-testid="rep-marion-marker"]');
    expect(marker?.textContent?.trim()).toBe('Marion parcels');
    expect(marker?.getAttribute('title')).toContain('Marion PTABOA agendas');
    expect(queryAll(h.fixture, '[data-testid="rep-marion-marker"]')).toHaveLength(1);
  });

  it('I5: flagging a Statewide owner keeps the Marion-parcels figure and scopes it in the Thesis', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.parcelsFor = (id) => parcelRows(id);
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.AllOwners.find((o) => o.id === 'w') as OwnerRow;
    await h.component.onFlagOwner(w);
    const saved = h.state.saved.get('Prospects')?.[0] ?? {};
    expect(saved['EstimatedOpportunityAtAsk']).toBe(162_164.47);
    expect(String(saved['Thesis'])).toContain('Opportunity = Marion parcels only: ~$162,164/yr at ask');
    expect(String(saved['Thesis'])).toContain('Rep status (Marion parcels only): Represented by INTEGRITY TAX CONSULTING.');
    expect(saved['Priority']).toBe('High'); // M7: AV tier A
  });
});

@Component({ standalone: true, selector: 'button[mjButton]', template: '<ng-content></ng-content>' })
class StubButton {
  @Input() variant = '';
  @Input() size = '';
}

describe('OwnerDetailPanelComponent — statewide parcels (DOM)', () => {
  const owner: OwnerRow = {
    id: 'w', ownerKey: 'walmart', label: 'Walmart Inc.', kind: 'Company', tier: 'A', parcelCount: 2, distinctEntities: 1,
    totalAV: 38_000_000, totalAV2025: null, totalAV2026: null, avYoYDollars: null, avYoYPct: 7.2, parcelsUp10: null,
    parcelsUp25: null, totalUnits: null, totalSqFt: null, nAppealRec: null, nTwoSupport: null, nHighConfAppeal: null,
    estSavingsAtAsk: null, estSavingsAtFloor: null, appealedParcels: 0, historicalReductionWon: null, appealYears: null,
    likelyRep: null, repStatus: 'No rep data for this county', repsOnReduction: [], isFreshProspect: false, mailAddress: null,
    coStarTrueOwner: 'Walmart Inc.', byType: {}, dominantType: null, parcels: [], prospectId: null,
    countyCount: 2, tierBasis: 'AV', pairYears: 'mixed', groupKeyType: 'CO',
    byCounty: { '45': { parcels: 1, avCurrent: 35_916_600, avPrior: 37_033_100 }, '1': { parcels: 1, avCurrent: 7_645_300, avPrior: null } },
  };
  const parcels = [
    {
      id: 'p1', gisParcelNumber: '', address: '1 Lake Ave', typeGroup: 'Retail', currentAV: null, av2025: null, av2026: null,
      avYoYPct: -3, units: null, sqft: 180_000, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null, conf: null,
      supCount: null, appealed: false, existingRep: null, lastAppealYear: null,
      parcelId: 'pid1', parcelNumber: '450706207002000023', countyNumber: 45, priorYear: 2024, currentYear: 2025, avPrior: 37_033_100, avCurrent: 35_916_600, isPlaceholder: false,
    },
    {
      id: 'p2', gisParcelNumber: '', address: '2 Adams St', typeGroup: 'Retail', currentAV: null, av2025: null, av2026: null,
      avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null, conf: null,
      supCount: null, appealed: false, existingRep: null, lastAppealYear: null,
      parcelId: 'pid2', parcelNumber: '010101010101010101', countyNumber: 1, priorYear: null, currentYear: 2025, avPrior: null, avCurrent: 7_645_300, isPlaceholder: true,
    },
  ];
  // Live `Parcel Year Headlines` figures: p1 cards both years; p2 a 2026 DLGF roll figure and no 2025 (Review Focus 1).
  const years = mapParcelYearHeadlines([
    { ParcelID: 'pid1', AssessmentYear: 2025, HeadlineTotalAV: 37_033_100, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
    { ParcelID: 'pid1', AssessmentYear: 2026, HeadlineTotalAV: 35_916_600, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
    { ParcelID: 'pid2', AssessmentYear: 2026, HeadlineTotalAV: 7_645_300, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' },
  ]);
  const render = () =>
    renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton],
      declarations: [OwnerDetailPanelComponent],
      inputs: {
        Owner: owner, Parcels: parcels, Statewide: true, CountySlugs: { 45: 'lake', 1: 'adams' }, CountyNames: { 45: 'Lake', 1: 'Adams' },
        DisplayYears: [2025, 2026], ParcelYears: years,
      },
    });
  const cell = (row: Element, id: string): string | undefined => row.querySelector(`[data-testid="${id}"]`)?.textContent?.trim();

  it('shows AV 2025 | AV 2026 | YoY from the live figures, the roll pill, the — gap, a Lake card link and an honest no-link', () => {
    const f = render();
    expect(query(f, '[data-testid="pt-year1-header"]')?.textContent?.trim()).toBe('AV 2025');
    expect(query(f, '[data-testid="pt-year2-header"]')?.textContent?.trim()).toBe('AV 2026');
    const rows = queryAll(f, 'table.pt tbody tr');
    expect(rows).toHaveLength(2);
    expect(cell(rows[0], 'pt-year1')).toBe('37,033,100');
    expect(cell(rows[0], 'pt-year2')).toBe('35,916,600');
    expect(cell(rows[0], 'pt-yoy')).toBe('-3%');
    expect(rows[0].querySelector('[data-testid="roll-pill"]')).toBeNull();
    // Review Focus 1: 2026 roll figure, no 2025 figure — 2025 —, YoY —, the roll pill on 2026.
    expect(cell(rows[1], 'pt-year1')).toBe('—');
    expect(cell(rows[1], 'pt-year2')).toBe('7,645,300 roll');
    expect(rows[1].querySelector('[data-testid="pt-year2"] [data-testid="roll-pill"]')?.textContent?.trim()).toBe('roll');
    expect(rows[1].querySelector('[data-testid="pt-year2"]')?.getAttribute('title')).toContain('DLGF roll');
    expect(cell(rows[1], 'pt-yoy')).toBe('—');
    expect(rows[0].querySelector('[data-testid="pt-parcel"]')?.getAttribute('title')).toBe('newest assessment year on record: 2026');
    expect(f.nativeElement.textContent).not.toContain('placeholder'); // the superseded pills are gone
    expect(rows[0].querySelector('a')?.getAttribute('href')).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
    expect(rows[1].querySelector('a')).toBeNull();
    expect(rows[1].textContent).toContain('no card link');
    expect(query(f, '[data-testid="county-split"]')?.textContent).toContain('Lake 1 ($35.9M) · Adams 1 ($7.6M)');
    expect(query(f, '[data-testid="parcels-capped"]')).toBeNull();
  });

  it('TBA for a parcel with no 2026 figure on the record', () => {
    const only2025 = mapParcelYearHeadlines([{ ParcelID: 'pid1', AssessmentYear: 2025, HeadlineTotalAV: 37_033_100, IsPlaceholder: 0 }]);
    const tba = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton], declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: [parcels[0]], Statewide: true, CountySlugs: {}, CountyNames: {}, DisplayYears: [2025, 2026], ParcelYears: only2025 },
    });
    const row = queryAll(tba, 'table.pt tbody tr')[0];
    expect(cell(row, 'pt-year2')).toBe('TBA');
    expect(row.querySelector('[data-testid="pt-year2"]')?.getAttribute('title')).toBe('2026: To Be Assessed — no 2026 figure on the record yet');
  });

  it('claims no gap while the year figures are not loaded or the read failed — never a false TBA', () => {
    const failed = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton], declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: parcels, Statewide: true, CountySlugs: {}, CountyNames: {}, DisplayYears: [2025, 2026], ParcelYears: null, YearsError: 'Year figures could not be read: boom' },
    });
    expect(query(failed, '[data-testid="years-error"]')?.textContent?.trim()).toBe('Year figures could not be read: boom');
    for (const r of queryAll(failed, 'table.pt tbody tr')) {
      expect(cell(r, 'pt-year1')).toBe('');
      expect(cell(r, 'pt-year2')).toBe(''); // never a false TBA
    }
  });

  it('Review Focus 5: every column sorts on a header click, asc/desc, blanks last both directions', () => {
    const base = parcels[0];
    const many = [
      { ...base, id: 'a', parcelId: 'A', address: 'A St', sqft: 100 },
      { ...base, id: 'b', parcelId: 'B', address: 'B St', sqft: null },
      { ...base, id: 'c', parcelId: 'C', address: 'C St', sqft: 300 },
      { ...base, id: 'd', parcelId: 'D', address: 'D St', sqft: 200 },
    ];
    const map = mapParcelYearHeadlines([
      { ParcelID: 'A', AssessmentYear: 2025, HeadlineTotalAV: 100 }, { ParcelID: 'A', AssessmentYear: 2026, HeadlineTotalAV: 150 },
      { ParcelID: 'B', AssessmentYear: 2025, HeadlineTotalAV: 400 },
      { ParcelID: 'C', AssessmentYear: 2025, HeadlineTotalAV: 200 }, { ParcelID: 'C', AssessmentYear: 2026, HeadlineTotalAV: 210 },
      { ParcelID: 'D', AssessmentYear: 2026, HeadlineTotalAV: 900, IsPlaceholder: 1 },
    ]);
    const f = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton], declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: many, Statewide: true, CountySlugs: {}, CountyNames: {}, DisplayYears: [2025, 2026], ParcelYears: map },
    });
    const order = (): string[] => queryAll(f, 'table.pt tbody tr').map((r) => r.querySelector('.pt__addr')?.textContent?.trim() ?? '');
    const header = (label: string): HTMLElement =>
      queryAll(f, 'table.pt thead th').find((th) => th.textContent?.trim() === label) as HTMLElement;
    const clickHeader = (label: string): void => {
      header(label).click();
      f.detectChanges();
    };
    clickHeader('AV 2026'); // a figure column starts descending
    expect(order()).toEqual(['D St', 'C St', 'A St', 'B St']);
    expect(header('AV 2026').getAttribute('data-sort')).toBe('desc');
    clickHeader('AV 2026');
    expect(order()).toEqual(['A St', 'C St', 'D St', 'B St']); // the TBA parcel stays last
    clickHeader('YoY');
    expect(order()).toEqual(['A St', 'C St', 'B St', 'D St']); // +50%, +5%, then the two blanks in their prior order
    clickHeader('YoY');
    expect(order()).toEqual(['C St', 'A St', 'B St', 'D St']);
    clickHeader('SqFt');
    expect(order()).toEqual(['C St', 'D St', 'A St', 'B St']);
    clickHeader('Parcel'); // words start ascending
    expect(order()).toEqual(['A St', 'B St', 'C St', 'D St']);
    for (const label of ['County', 'Type', 'AV 2025', 'Units', 'Save/yr', 'Appealed', 'Rep']) {
      clickHeader(label);
      expect(header(label).getAttribute('data-sort')).not.toBe('');
    }
  });

  it('I3: the detail "Rep status" line carries the Marion-parcels marker for a Marion + other-county owner', () => {
    const f = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton],
      declarations: [OwnerDetailPanelComponent],
      inputs: {
        Owner: { ...owner, repStatus: 'Represented by INTEGRITY TAX CONSULTING', byCounty: { ...owner.byCounty, '49': { parcels: 1, avCurrent: 1, avPrior: null } } },
        Parcels: parcels, Statewide: true, CountySlugs: {}, CountyNames: {},
      },
    });
    expect(query(f, '[data-testid="detail-rep-marion-marker"]')?.textContent?.trim()).toBe('Marion parcels');
  });

  it('I3: no Marion parcel, no rep marker in the detail panel', () => {
    expect(query(render(), '[data-testid="detail-rep-marion-marker"]')).toBeNull();
  });

  it('shows "showing the first 5,000 parcels" when the owner\'s parcels were capped', () => {
    const f = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton],
      declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: parcels, Statewide: true, ParcelsCapped: true, CountySlugs: {}, CountyNames: {} },
    });
    expect(query(f, '[data-testid="parcels-capped"]')?.textContent?.trim()).toBe('showing the first 5,000 parcels');
  });
});

describe('Owner Prospects — fixed assessment years (years-export plan, Task 2)', () => {
  const t = (el: Element | null | undefined): string | undefined => el?.textContent?.trim();
  const rowOf = (h: Harness, label: string): Element | undefined => queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes(label));
  const cellIn = (row: Element | undefined, id: string): Element | null | undefined => row?.querySelector(`[data-testid="${id}"]`);

  it('year columns from the run: AV 2025 | AV 2026 | YoY 2025→2026 | Assessment status; TBA / — gaps (Review Focus 1, 2)', async () => {
    const h = mount({ scope: 'Statewide' });
    // Review Focus 1: a 2026 roll figure and no 2025 figure.
    const NEW26 = statewideOwner({
      ID: 'n', Label: 'New 2026 LLC', PrimaryCountyNumber: 45, CountyCount: 1, AVCurrent: 400_000, TotalAV: 400_000,
      ByCountyJSON: JSON.stringify({ '45': { parcels: 1, avCurrent: 400_000, years: { '2026': fig(400_000, 1, 1) }, pair: pair(0, 0, 0) } }),
    });
    h.state.statewideOwners = [WALMART, LAKE_ONLY, ALLEN_ONLY, NEW26];
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.DisplayYears).toEqual([2025, 2026]);
    expect(t(query(h.fixture, '[data-testid="year1-header"]'))).toBe('AV 2025');
    expect(t(query(h.fixture, '[data-testid="year2-header"]'))).toBe('AV 2026');
    expect(t(query(h.fixture, '[data-testid="yoy-header"]'))).toBe('YoY 2025→2026');
    expect(el(h).textContent).not.toContain('AV prior (paired)');

    const w = rowOf(h, 'Walmart');
    expect(t(cellIn(w, 'av-year1'))).toBe('$119,809,900');
    expect(cellIn(w, 'av-year1')?.getAttribute('title')).toBe('21 of 21 parcels have a 2025 figure; 0 are the DLGF roll');
    expect(t(cellIn(w, 'av-year2'))).toBe('$138,333,200');
    expect(t(cellIn(w, 'yoy-pair'))).toBe('+15.5%');
    expect(t(cellIn(w, 'assessment-status'))).toBe('2025: 21 of 21 · roll 0; 2026 assessed: 21 of 21 · roll 0');

    // Review Focus 2: assessed only through 2025 — 2026 TBA, YoY —, "2026 TBA (n parcels)".
    const a = rowOf(h, 'Allen Only');
    expect(t(cellIn(a, 'av-year1'))).toBe('$900,000');
    expect(cellIn(a, 'av-year1')?.getAttribute('title')).toBe('1 of 1 parcels have a 2025 figure; 1 are the DLGF roll');
    expect(t(cellIn(a, 'av-year2'))).toBe('TBA');
    expect(cellIn(a, 'av-year2')?.classList.contains('gap')).toBe(true);
    expect(t(cellIn(a, 'yoy-pair'))).toBe('—');
    expect(t(cellIn(a, 'assessment-status'))).toBe('2025: 1 of 1 · roll 1; 2026 TBA (1 parcel)'); // final-review I2: the 2025 roll count

    const n = rowOf(h, 'New 2026');
    expect(t(cellIn(n, 'av-year1'))).toBe('—');
    expect(t(cellIn(n, 'av-year2'))).toBe('$400,000');
    expect(t(cellIn(n, 'yoy-pair'))).toBe('—');
    expect(t(cellIn(n, 'assessment-status'))).toBe('2025 —; 2026 assessed: 1 of 1 · roll 1');
  });

  it('Review Focus 4: a run whose newest year is 2027 in one county — the columns follow the run, every other county reads 2027 TBA', async () => {
    const run27 = { ...STATEWIDE_RUN, ByCountyJSON: runJSON([2025, 2026, 2027]) };
    const h = mount({ scope: 'Statewide' }, [run27, MARION_RUN]);
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.DisplayYears).toEqual([2026, 2027]);
    expect(t(query(h.fixture, '[data-testid="year2-header"]'))).toBe('AV 2027');
    expect(t(cellIn(rowOf(h, 'Walmart'), 'av-year1'))).toBe('$138,333,200'); // 2026 is now the older year
    expect(t(cellIn(rowOf(h, 'Walmart'), 'av-year2'))).toBe('TBA');
    expect(h.component.CountyOptions.map((o) => o.Chip)).toEqual(['2027 TBA', '2027 TBA', '2027 TBA']);
  });

  it('county dropdown items carry the chip: cards / 2026 TBA', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.CountyOptions.map((o) => [o.Name, o.Chip])).toEqual([['Allen', '2026 TBA'], ['Lake', 'cards'], ['Marion', 'cards']]);
  });

  it('Complete YoY only: off by default on the AV sort, on by default for the YoY sort, the toolbar says which; ?complete= round-trips', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.CompleteOnly).toBe(false);
    expect(t(query(h.fixture, '[data-testid="complete-note"]'))).toBe('off (default; on for the YoY sort)');
    expect(h.component.VisibleRows).toHaveLength(3);

    h.component.onSortColumn('yoyPair');
    h.fixture.detectChanges();
    expect(h.component.CompleteOnly).toBe(true);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l']); // Review Focus 2: the 2026-TBA owner is excluded
    expect(t(query(h.fixture, '[data-testid="complete-note"]'))).toBe('on (default for the YoY sort) · 1 owner without a complete YoY hidden');

    h.component.onCompleteOnlyChange(false); // the user turns it off: included, ranked after the complete owners
    h.fixture.detectChanges();
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l', 'a']);
    expect(h.pushed.at(-1)).toEqual({ scope: 'Statewide', county: null, complete: '0' });
    expect(t(query(h.fixture, '[data-testid="complete-note"]'))).toBe('off');

    const deliver = (h.component as unknown as { OnQueryParamsChanged(p: Record<string, string>, s: 'popstate'): void }).OnQueryParamsChanged.bind(h.component);
    deliver({ scope: 'Statewide', complete: '1' }, 'popstate');
    expect(h.component.CompleteOnly).toBe(true);
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l']);
    deliver({ scope: 'Statewide' }, 'popstate'); // no param → the default for the YoY sort (on)
    expect(h.component.CompleteOnly).toBe(true);
    h.component.onSortColumn('avCurrent');
    expect(h.component.CompleteOnly).toBe(false);
  });

  it('?complete=1 on a deep link applies before the first load', async () => {
    const h = mount({ scope: 'Statewide', complete: '1' });
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.CompleteOnly).toBe(true);
    expect(h.component.VisibleRows.map((r) => r.id).sort()).toEqual(['l', 'w']);
  });

  it('opening an owner reads its display years live from Parcel Year Headlines; the panel matches the parcel rows\' AV2025/AV2026 (cross-check)', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, MARION_RUN], true);
    const walmartParcels: Raw[] = [
      { ID: 'wp1', OwnerPortfolioID: 'w', ParcelID: 'P1', Address: '1 Lake Ave', CountyNumber: 45, AVCurrent: 35_916_600, AV2025: 37_033_100, AV2026: 35_916_600 },
      { ID: 'wp2', OwnerPortfolioID: 'w', ParcelID: 'P2', Address: '2 Allen Rd', CountyNumber: 2, AVCurrent: 900_000, AV2025: 900_000, AV2026: null },
    ];
    h.state.parcelsFor = (id) => (id === 'w' ? walmartParcels : []);
    h.state.headlines = [
      { ParcelID: 'P1', AssessmentYear: 2025, HeadlineTotalAV: 37_033_100, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
      { ParcelID: 'P1', AssessmentYear: 2026, HeadlineTotalAV: 35_916_600, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
      { ParcelID: 'P2', AssessmentYear: 2025, HeadlineTotalAV: 900_000, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' },
    ];
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.VisibleRows.find((r) => r.id === 'w') as OwnerRow;
    h.component.toggleOwner(w);
    await vi.waitFor(() => expect(h.component.ParcelYearsFor(w)).not.toBeNull());
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    const read = h.state.calls.filter((c) => c.EntityName === 'Parcel Year Headlines');
    expect(read).toHaveLength(1);
    expect(read[0].ExtraFilter).toContain("OwnerPortfolioID = 'w'");
    expect(read[0].ExtraFilter).toContain('AssessmentYear IN (2025, 2026)');
    expect(read[0].MaxRows).toBe(10001);
    expect(read[0].ResultType).toBe('simple');
    h.fixture.detectChanges();

    const rows = queryAll(h.fixture, 'mj-owner-detail-panel table.pt tbody tr');
    expect(rows).toHaveLength(2);
    const shown = (r: Element, id: string): string => r.querySelector(`[data-testid="${id}"]`)?.textContent?.replace(/\s*roll\s*$/, '').trim() ?? '';
    const asText = (v: unknown): string => (v == null ? '' : Number(v).toLocaleString('en-US'));
    for (const r of rows) {
      const src = walmartParcels.find((p) => r.textContent?.includes(String(p['Address']))) as Raw;
      expect(shown(r, 'pt-year1')).toBe(asText(src['AV2025']));
      // The builder's AV2026 null is the headline's "no 2026 figure": the panel says TBA.
      expect(shown(r, 'pt-year2')).toBe(src['AV2026'] == null ? 'TBA' : asText(src['AV2026']));
    }
    const allen = rows.find((r) => r.textContent?.includes('2 Allen Rd'));
    expect(allen?.querySelector('[data-testid="pt-year1"] [data-testid="roll-pill"]')).not.toBeNull();
  });

  it('a failed year read shows the error in the panel and claims no gap', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.parcelsFor = (id) => (id === 'a' ? [{ ID: 'ap1', OwnerPortfolioID: 'a', ParcelID: 'PA', Address: '9 Fort Wayne', CountyNumber: 2 }] : []);
    h.state.failHeadlines = true;
    h.fixture.detectChanges();
    await settle(h);
    const a = h.component.VisibleRows.find((r) => r.id === 'a') as OwnerRow;
    h.component.toggleOwner(a);
    await vi.waitFor(() => expect(h.component.ParcelYearsErrorFor(a)).not.toBeNull());
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    h.fixture.detectChanges();
    expect(t(query(h.fixture, '[data-testid="years-error"]'))).toContain('could not be read');
    expect(t(query(h.fixture, 'mj-owner-detail-panel [data-testid="pt-year2"]'))).toBe('');
  });

  it('the Marion scope keeps its owner columns; its detail panel reads the Marion run\'s 2025/2026 live too', async () => {
    const h = mount({});
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.DisplayYears).toEqual([2025, 2026]); // from the Marion run's CountyTotalAV2025/2026
    expect(query(h.fixture, '[data-testid="year1-header"]')).toBeNull();
    expect(query(h.fixture, '[data-testid="assessment-status"]')).toBeNull();
    const parcelsQuery = h.state.calls.find((c) => c.EntityName === 'Owner Portfolio Parcels');
    expect(parcelsQuery?.Fields).toContain('ParcelID');
    h.component.toggleOwner(h.component.VisibleRows[0]);
    await vi.waitFor(() => expect(h.state.calls.some((c) => c.EntityName === 'Parcel Year Headlines')).toBe(true));
    const read = h.state.calls.find((c) => c.EntityName === 'Parcel Year Headlines');
    expect(read?.ExtraFilter).toContain("OwnerPortfolioID = 'm'");
    expect(read?.ExtraFilter).toContain('AssessmentYear IN (2025, 2026)');
  });
});

describe('Owner Prospects — years fix round 1', () => {
  it('a saved Statewide sort on a removed column (avPrior / avYoYPct) restores as the fixed-pair YoY', async () => {
    vi.spyOn(UserInfoEngine.Instance, 'GetSetting').mockImplementation((k: string) =>
      k === 'mj.ownerProspects.sort.statewide.v1' ? JSON.stringify({ key: 'avPrior', dir: -1 }) : undefined);
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    expect(h.component.CompleteOnly).toBe(true); // the YoY sort is active, so its default applies
    expect(query(h.fixture, '[data-testid="yoy-header"]')?.getAttribute('data-sort')).toBe('desc');
  });

  it('the YoY ranking puts a complete owner on a small base after the material ones; its tooltip names the base', async () => {
    const BIG = statewideOwner({
      ID: 'b', Label: 'Big Base LLC', PrimaryCountyNumber: 45, CountyCount: 1, AVCurrent: 1_100_000, TotalAV: 1_100_000,
      ByCountyJSON: JSON.stringify({ '45': { parcels: 1, avCurrent: 1_100_000, years: { '2025': fig(1_000_000, 1), '2026': fig(1_100_000, 1) }, pair: pair(1, 1_000_000, 1_100_000) } }),
    });
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = [WALMART, LAKE_ONLY, ALLEN_ONLY, BIG];
    h.fixture.detectChanges();
    await settle(h);
    h.component.onSortColumn('yoyPair');
    h.fixture.detectChanges();
    // Lake Only (+47,787.7% on a $5,700 base) no longer heads the list.
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'b', 'l']);
    const lake = queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes('Lake Only'));
    expect(lake?.querySelector('[data-testid="yoy-pair"]')?.textContent?.trim()).toBe('+47787.7%'); // the % still shows
    expect(lake?.querySelector('[data-testid="yoy-pair"]')?.getAttribute('title')).toContain('small base: paired prior $5,700');
    const walmart = queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes('Walmart'));
    expect(walmart?.querySelector('[data-testid="yoy-pair"]')?.getAttribute('title')).not.toContain('small base');
    expect(h.component.IncompleteHiddenCount).toBe(1);
  });

  it('FilterOwnerProspects with completeOnly in the Marion scope says Statewide only and stores nothing', async () => {
    const h = mount({});
    h.fixture.detectChanges();
    await settle(h);
    type Tool = { Name: string; Handler: (p: Record<string, unknown>) => Promise<{ Success: boolean; ErrorMessage?: string }> };
    const tools = (h.component as unknown as { buildAgentTools(): Tool[] }).buildAgentTools();
    const filter = tools.find((t) => t.Name === 'FilterOwnerProspects') as Tool;
    const before = h.pushed.length;
    const res = await filter.Handler({ completeOnly: true, tier: 'Prime' });
    expect(res.Success).toBe(false);
    expect(res.ErrorMessage).toContain('Statewide scope only');
    expect(res.ErrorMessage).toContain('not stored');
    expect(h.component.TierFilter).toBe('all'); // nothing in the call was applied
    expect(h.pushed.length).toBe(before);
    h.component.onScopeChange('Statewide');
    await settle(h);
    expect(h.component.CompleteOnly).toBe(false); // the refused choice did not carry over
    const ok = await filter.Handler({ completeOnly: true });
    expect(ok.Success).toBe(true);
    expect(h.component.CompleteOnly).toBe(true);
  });
});

describe('Owner Prospects — YoY $ column and Excel export (years-export plan, Task 3)', () => {
  const t = (e: Element | null | undefined): string | undefined => e?.textContent?.trim();
  const rowOf = (h: Harness, label: string): Element | undefined => queryAll(h.fixture, 'tbody tr').find((tr) => tr.textContent?.includes(label));
  const withDollars = (): Raw[] => [
    { ...WALMART, AVYoYDollars: 18_523_300 },
    { ...LAKE_ONLY, AVYoYDollars: 2_723_900 },
    { ...ALLEN_ONLY, AVYoYDollars: null },
  ];

  /** Capture the sheets handed to the export engine and the file name the browser is given; nothing is written. */
  function captureExport(): { sheets: SheetDefinition[][]; files: string[] } {
    const sheets: SheetDefinition[][] = [];
    const files: string[] = [];
    vi.spyOn(ExportEngine, 'toExcelMultiSheet').mockImplementation(async (s: SheetDefinition[]): Promise<ExportResult> => {
      sheets.push(s);
      return { success: true, data: new Uint8Array([1]), mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' } as ExportResult;
    });
    Object.defineProperty(URL, 'createObjectURL', { value: (): string => 'blob:x', configurable: true });
    Object.defineProperty(URL, 'revokeObjectURL', { value: (): void => undefined, configurable: true });
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(function (this: HTMLAnchorElement) {
      files.push(this.download);
    });
    return { sheets, files };
  }
  const column = (sheet: SheetDefinition, header: string): unknown[] => {
    const i = (sheet.headers ?? []).indexOf(header);
    expect(i, header).toBeGreaterThanOrEqual(0);
    return sheet.data.map((r) => (r as unknown[])[i]);
  };

  it('YoY $ <y1>→<y2> after the YoY % column: signed dollars, — without a pair, sortable with blanks last', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = withDollars();
    h.fixture.detectChanges();
    await settle(h);
    const headers = queryAll(h.fixture, 'thead th').map((th) => th.textContent?.trim());
    expect(headers.indexOf('YoY $ 2025→2026')).toBe(headers.indexOf('YoY 2025→2026') + 1);
    expect(t(rowOf(h, 'Walmart')?.querySelector('[data-testid="yoy-dollars"]'))).toBe('+$18,523,300');
    expect(t(rowOf(h, 'Allen Only')?.querySelector('[data-testid="yoy-dollars"]'))).toBe('—');
    expect(h.component.ColumnCount).toBe(17);
    h.component.onSortColumn('avYoYDollars');
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l', 'a']);
    h.component.onSortColumn('avYoYDollars');
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['l', 'w', 'a']); // blanks last both directions
  });

  it('Export owners (Statewide, Lake): the page\'s own county filter, count then keyset pages, rows sorted as the table, the file name', async () => {
    const h = mount({ scope: 'Statewide', county: '45' });
    h.state.statewideOwners = withDollars();
    h.fixture.detectChanges();
    await settle(h);
    const cap = captureExport();
    h.state.calls.length = 0;
    (query(h.fixture, '[data-testid="export-owners-btn"]') as HTMLButtonElement).click();
    await vi.waitFor(() => expect(cap.files).toHaveLength(1));

    const reads = ownerCalls(h.state);
    const countQ = reads.find((c) => c.ResultType === 'count_only');
    const pageQ = reads.find((c) => c.ResultType === 'simple');
    const clause = `RunID = 'S1' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`;
    expect(countQ?.ExtraFilter).toBe(clause);
    expect(pageQ?.ExtraFilter).toBe(clause);
    expect(pageQ?.MaxRows).toBe(5001);
    expect(pageQ?.OrderBy).toBeUndefined();
    expect(cap.files[0]).toBe('owner-prospects_statewide_lake_2026-09-28.xlsx');

    const [basisSheet, owners] = cap.sheets[0];
    expect(basisSheet.name).toBe('Basis');
    expect(owners.name).toBe('Owners');
    // The county filter holds (Allen is not in Lake); the table's sort (AV current, descending) is the row order.
    expect(column(owners, 'Owner')).toEqual(h.component.VisibleRows.map((r) => r.label));
    expect(column(owners, 'Owner')).toEqual(['Walmart Inc.', 'Lake Only LLC']);
    expect(column(owners, 'YoY $ 2025→2026')).toEqual([18_523_300, 2_723_900]);
    expect(column(owners, 'Primary county')).toEqual(['Marion', 'Lake']);
    expect(h.component.IsExporting).toBe(false);
  });

  it('Export owners (Statewide, All): an owner with no 2026 figure exports an empty (null) 2026 cell and the TBA words in the status', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = withDollars();
    h.fixture.detectChanges();
    await settle(h);
    const cap = captureExport();
    await h.component.onExportOwners();
    expect(cap.files[0]).toBe('owner-prospects_statewide_all_2026-09-28.xlsx');
    const owners = cap.sheets[0][1];
    const labels = column(owners, 'Owner');
    const allen = labels.indexOf('Allen Only LLC');
    expect(column(owners, 'AV 2026')[allen]).toBeNull();
    expect(column(owners, 'Assessment status')[allen]).toBe('2025: 1 of 1 · roll 1; 2026 TBA (1 parcel)');
    expect(column(owners, 'roll 2025')[allen]).toBe(1); // final-review I2
    expect(column(owners, 'roll 2026')[allen]).toBe(0);
    expect(column(owners, 'AV newest (mixed years)')[allen]).toBe(900_000); // final-review I3
    expect(column(owners, 'Primary county')[allen]).toBe('Allen');
  });

  it('Export owners (Marion): the loaded table, no re-read', async () => {
    const h = mount({});
    h.fixture.detectChanges();
    await settle(h);
    const cap = captureExport();
    h.state.calls.length = 0;
    await h.component.onExportOwners();
    expect(ownerCalls(h.state)).toHaveLength(0);
    expect(cap.files[0]).toBe('owner-prospects_marion_all_2026-09-24.xlsx');
    expect(column(cap.sheets[0][1], 'Owner')).toEqual(['ACME PROPERTIES']);
    expect(column(cap.sheets[0][1], 'Savings at ask')).toEqual([51_000]);
  });

  it('Export parcels: every loaded parcel of the opened owner, in the panel\'s sort', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.parcelsFor = (id) => (id === 'w' ? [
      { ID: 'wp1', OwnerPortfolioID: 'w', ParcelID: 'P1', Parcel: '450706207002000023', Address: '1 Lake Ave', CountyNumber: 45, AVCurrent: 35_916_600 },
      { ID: 'wp2', OwnerPortfolioID: 'w', ParcelID: 'P2', Parcel: '020000000000000001', Address: '2 Allen Rd', CountyNumber: 2, AVCurrent: 900_000 },
    ] : []);
    h.state.headlines = [
      { ParcelID: 'P1', AssessmentYear: 2025, HeadlineTotalAV: 37_033_100, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
      { ParcelID: 'P1', AssessmentYear: 2026, HeadlineTotalAV: 35_916_600, IsPlaceholder: 0, HeadlineDataSource: 'Lake County property record card' },
      { ParcelID: 'P2', AssessmentYear: 2025, HeadlineTotalAV: 900_000, IsPlaceholder: 1, HeadlineDataSource: 'DLGF assessment roll' },
    ];
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.VisibleRows.find((r) => r.id === 'w') as OwnerRow;
    h.component.toggleOwner(w);
    await vi.waitFor(() => expect(h.component.ParcelYearsFor(w)).not.toBeNull());
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    h.fixture.detectChanges();
    // Sort the panel by AV 2025 ascending: Allen (900,000) before Lake (37,033,100).
    const year1Header = query(h.fixture, 'mj-owner-detail-panel [data-testid="pt-year1-header"]') as HTMLElement;
    year1Header.click();
    year1Header.click();
    h.fixture.detectChanges();
    const cap = captureExport();
    (query(h.fixture, '[data-testid="export-parcels-btn"]') as HTMLButtonElement).click();
    await vi.waitFor(() => expect(cap.files).toHaveLength(1));
    expect(cap.files[0]).toBe('owner-parcels_walmart-inc_2026-09-28.xlsx');
    const [basisSheet, parcels] = cap.sheets[0];
    expect(parcels.name).toBe('Parcels');
    expect(column(parcels, 'Address')).toEqual(['2 Allen Rd', '1 Lake Ave']);
    expect(column(parcels, 'AV 2026')).toEqual([null, 35_916_600]);
    expect(column(parcels, '2025 roll')).toEqual(['roll', null]);
    expect(column(parcels, 'Assessment status')).toEqual(['2025 roll · 2026 TBA', '2025 and 2026 on record']);
    const sortLine = basisSheet.data.find((r) => (r as unknown[])[0] === 'Sort') as unknown[];
    expect(sortLine[1]).toBe('AV 2025, ascending');
  });
});

describe('Owner Prospects export — fix round 1 (the confirm names the filters; read vs written)', () => {
  /** Force the large-read confirm (count above 20,000) and capture it; the user cancels, so nothing is read. */
  function captureConfirm(): MJConfirmOptions[] {
    const seen: MJConfirmOptions[] = [];
    vi.spyOn(OwnerProspectsDataAccess.prototype, 'CountOwners').mockResolvedValue({ ok: true, count: 109_346 });
    vi.spyOn(MJConfirmService.prototype, 'Confirm').mockImplementation(async (o: MJConfirmOptions | string): Promise<boolean> => {
      if (typeof o !== 'string') seen.push(o);
      return false;
    });
    return seen;
  }

  it('the confirm names Complete YoY only when it is on (the YoY sort default), with a neutral Read button', async () => {
    const h = mount({ scope: 'Statewide', county: '45', complete: '1' });
    h.fixture.detectChanges();
    await settle(h);
    const seen = captureConfirm();
    h.state.calls.length = 0;
    await h.component.onExportOwners();
    expect(seen).toHaveLength(1);
    expect(seen[0].message).toBe("109,346 owners on this run match the Lake county filter and will be read; the table's filters are applied after reading: company owners only, Complete YoY only.");
    expect(seen[0].detail).toContain('read-cost warning on the pre-filter count');
    expect(seen[0].confirmText).toBe('Read 109,346 rows');
    expect(ownerCalls(h.state).filter((c) => c.ResultType === 'simple')).toHaveLength(0); // cancelled: nothing read
  });

  it('the confirm omits Complete YoY only when it is off', async () => {
    const h = mount({ scope: 'Statewide', complete: '0' });
    h.fixture.detectChanges();
    await settle(h);
    const seen = captureConfirm();
    await h.component.onExportOwners();
    expect(seen[0].message).not.toContain('Complete YoY only');
    expect(seen[0].message).toContain('match no county or search filter (all counties)');
    expect(seen[0].message).toMatch(/applied after reading: company owners only\.$/);
  });

  it('the Basis records rows read vs rows written and lists the filters applied', async () => {
    const h = mount({ scope: 'Statewide', county: '45', complete: '1' });
    h.fixture.detectChanges();
    await settle(h);
    const sheets: SheetDefinition[][] = [];
    vi.spyOn(ExportEngine, 'toExcelMultiSheet').mockImplementation(async (s: SheetDefinition[]): Promise<ExportResult> => {
      sheets.push(s);
      return { success: true, data: new Uint8Array([1]) } as ExportResult;
    });
    Object.defineProperty(URL, 'createObjectURL', { value: (): string => 'blob:x', configurable: true });
    Object.defineProperty(URL, 'revokeObjectURL', { value: (): void => undefined, configurable: true });
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => undefined);
    await h.component.onExportOwners();
    const lines = new Map(sheets[0][0].data.map((r) => [(r as unknown[])[0], (r as unknown[])[1]]));
    expect(lines.get('Rows read (run + county/search)')).toBe(2); // Walmart + Lake Only: the county clause (filterByCounty) holds; Allen is not read
    expect(lines.get('Rows written after table filters')).toBe(sheets[0][1].data.length);
    expect(lines.get('Filters applied')).toBe('company owners only; Complete YoY only');
    expect(String(lines.get('County scope'))).toContain('owner-wide (all counties)');
  });
});

describe('Owner Prospects — final-review fix round (C1, I1, I3, minors)', () => {
  const t = (e: Element | null | undefined): string | undefined => e?.textContent?.trim();
  type AlertEl = Element & { Message?: string };

  it('C1: flagging a Statewide owner with 2026 on only some parcels writes the full newest-figure total, not the partial 2026 sum', async () => {
    const GM = statewideOwner({
      ID: 'gm', Label: 'General Motors LLC', PrimaryCountyNumber: 45, CountyCount: 1, ParcelCount: 28,
      TotalAV: 382_271_300, AVCurrent: 382_271_300, TotalAV2025: 370_000_000, TotalAV2026: 357_342_400, // 6 of 28 parcels have 2026
      ByCountyJSON: JSON.stringify({ '45': { parcels: 28, avCurrent: 382_271_300, years: { '2025': fig(370_000_000, 28), '2026': fig(357_342_400, 6) }, pair: pair(6, 330_000_000, 357_342_400) } }),
    });
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = [GM];
    h.state.parcelsFor = (id) => parcelRows(id);
    h.fixture.detectChanges();
    await settle(h);
    await h.component.onFlagOwner(h.component.AllOwners[0]);
    const snap = h.state.saved.get('Prospect Snapshots')?.[0] ?? {};
    expect(snap['TotalAV']).toBe(382_271_300);
    expect(snap['TotalAV']).not.toBe(357_342_400);
    // The thesis says what the 2026 figure covers, with the roll counts per year (I2).
    const thesis = String(h.state.saved.get('Prospects')?.[0]?.['Thesis']);
    expect(thesis).toContain('AV 2026 $357,342,400 (6 of 28 parcels, 0 DLGF roll); AV 2025 $370,000,000 (28 of 28 parcels, 0 DLGF roll). 22 parcels TBA for 2026.');
  });

  it('C1: the Marion scope keeps TotalAV2026 on the snapshot', async () => {
    const h = mount({});
    h.state.parcelsFor = () => [{ ID: 'mp1', OwnerPortfolioID: 'm', ParcelID: 'PM1', GISParcelNumber: '1012122', AV2025: 4_000_000, AV2026: 4_200_000 }];
    h.fixture.detectChanges();
    await settle(h);
    await h.component.onFlagOwner(h.component.AllOwners[0]);
    expect(h.state.saved.get('Prospect Snapshots')?.[0]?.['TotalAV']).toBe(4_200_000);
  });

  it('I1: a stale Marion run — the panel says the figures are live, and warns that the stored run differs (stored vs live)', async () => {
    const h = mount({}, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.marionOwners = [{ ...MARION_OWNER, Label: 'West Ohio II Property Owner, LLC', TotalAV2025: 36_279_300, TotalAV2026: 4_200_000 }];
    h.state.parcelsFor = () => [{ ID: 'mp1', OwnerPortfolioID: 'm', ParcelID: 'PM1', GISParcelNumber: '1012122', Address: '1 W Ohio St', AV2025: 36_279_300, AV2026: 4_200_000 }];
    h.state.headlines = [
      { ParcelID: 'PM1', AssessmentYear: 2025, HeadlineTotalAV: 17_972_700, IsPlaceholder: 0, HeadlineDataSource: 'Marion County property record card' },
      { ParcelID: 'PM1', AssessmentYear: 2026, HeadlineTotalAV: 3_000_000, IsPlaceholder: 0, HeadlineDataSource: 'Marion County property record card' },
    ];
    h.fixture.detectChanges();
    await settle(h);
    const row = h.component.VisibleRows[0];
    h.component.toggleOwner(row);
    await vi.waitFor(() => expect(h.component.ParcelYearsFor(row)).not.toBeNull());
    h.fixture.detectChanges();
    expect(t(query(h.fixture, '[data-testid="run-live-note"]'))).toBe(
      `Parcel figures are live from the headline table; the owner row is from the Marion run of ${isoLocal('2026-09-24T10:36:38Z')}.`,
    );
    const alert = query(h.fixture, 'mj-owner-detail-panel [data-testid="run-live-alert"]') as AlertEl | null;
    expect(alert).not.toBeNull();
    expect(alert?.Message).toBe("The stored run differs from today's headlines for this owner (2025: stored $36,279,300, live $17,972,700; 2026: stored $4,200,000, live $3,000,000) — re-run the Marion builder to refresh.");
    // The panel shows the live record, not the run's stored figure.
    expect(t(query(h.fixture, 'mj-owner-detail-panel [data-testid="pt-year1"]'))).toBe('17,972,700');
  });

  it('I1: a run stale on the older year only (West Ohio II: 2026 agrees, 2025 does not) still warns, naming 2025', async () => {
    const h = mount({}, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.marionOwners = [{ ...MARION_OWNER, Label: 'West Ohio II Property Owner, LLC', TotalAV2025: 63_104_300, TotalAV2026: 46_564_600 }];
    h.state.parcelsFor = () => [{ ID: 'mp1', OwnerPortfolioID: 'm', ParcelID: 'PM1', GISParcelNumber: '1012122', Address: '101 W Ohio St' }];
    h.state.headlines = [
      { ParcelID: 'PM1', AssessmentYear: 2025, HeadlineTotalAV: 44_421_200, IsPlaceholder: 0 },
      { ParcelID: 'PM1', AssessmentYear: 2026, HeadlineTotalAV: 46_564_600, IsPlaceholder: 0 },
    ];
    h.fixture.detectChanges();
    await settle(h);
    const row = h.component.VisibleRows[0];
    h.component.toggleOwner(row);
    await vi.waitFor(() => expect(h.component.ParcelYearsFor(row)).not.toBeNull());
    expect(h.component.RunLiveDiffFor(row)).toBe("The stored run differs from today's headlines for this owner (2025: stored $63,104,300, live $44,421,200) — re-run the Marion builder to refresh.");
  });

  it('I1: a Statewide owner whose live headlines agree with the run gets the note and no alert; M9: a $0-prior YoY says why', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.parcelsFor = (id) => (id === 'w' ? [
      { ID: 'wp1', OwnerPortfolioID: 'w', ParcelID: 'P1', Address: '1 Lake Ave', CountyNumber: 45, AVCurrent: 138_333_200 },
      { ID: 'wp2', OwnerPortfolioID: 'w', ParcelID: 'P2', Address: '2 New Rd', CountyNumber: 45, AVCurrent: 0 },
    ] : []);
    h.state.headlines = [
      { ParcelID: 'P1', AssessmentYear: 2025, HeadlineTotalAV: 119_809_900, IsPlaceholder: 0 },
      { ParcelID: 'P1', AssessmentYear: 2026, HeadlineTotalAV: 138_333_200, IsPlaceholder: 0 },
      { ParcelID: 'P2', AssessmentYear: 2025, HeadlineTotalAV: 0, IsPlaceholder: 0 },
      { ParcelID: 'P2', AssessmentYear: 2026, HeadlineTotalAV: 0, IsPlaceholder: 0 },
    ];
    h.fixture.detectChanges();
    await settle(h);
    const w = h.component.VisibleRows.find((r) => r.id === 'w') as OwnerRow;
    h.component.toggleOwner(w);
    await vi.waitFor(() => expect(h.component.ParcelYearsFor(w)).not.toBeNull());
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    h.fixture.detectChanges();
    expect(t(query(h.fixture, '[data-testid="run-live-note"]'))).toContain('the owner row is from the Statewide run of');
    expect(query(h.fixture, '[data-testid="run-live-alert"]')).toBeNull();
    expect(h.component.RunLiveDiffFor(w)).toBeNull();
    const newRow = queryAll(h.fixture, 'mj-owner-detail-panel table.pt tbody tr').find((r) => r.textContent?.includes('2 New Rd'));
    expect(newRow?.querySelector('[data-testid="pt-yoy"]')?.getAttribute('title')).toBe('new since 2025 ($0 prior — not a comparable base)');
  });

  it('I3: the toolbar says "sorted by newest AV" on the default Statewide sort, and not once another column is sorted', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    expect(t(query(h.fixture, '[data-testid="sort-note"]'))).toBe('sorted by newest AV');
    expect(t(query(h.fixture, '[data-testid="statewide-total-av-label"]'))).toBe('total assessed value (newest figure per parcel)');
    h.component.onSortColumn('avYear2');
    h.fixture.detectChanges();
    expect(query(h.fixture, '[data-testid="sort-note"]')).toBeNull();
  });

  it('I3: the Owners export carries AV newest (mixed years), the column the Basis sort names', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    let sheets: SheetDefinition[] = [];
    vi.spyOn(ExportEngine, 'toExcelMultiSheet').mockImplementation(async (s: SheetDefinition[]): Promise<ExportResult> => {
      sheets = s;
      return { success: true, data: new Uint8Array([1]) } as ExportResult;
    });
    Object.defineProperty(URL, 'createObjectURL', { value: (): string => 'blob:x', configurable: true });
    Object.defineProperty(URL, 'revokeObjectURL', { value: (): void => undefined, configurable: true });
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => undefined);
    await h.component.onExportOwners();
    const basisRows = sheets[0].data as unknown[][];
    expect(basisRows.find((r) => r[0] === 'Sort')?.[1]).toBe('AV newest (mixed years), descending');
    expect(sheets[1].headers).toContain('AV newest (mixed years)');
    expect(String(basisRows.find((r) => r[0] === 'Figures')?.[1])).toContain('the owner row is from the Statewide run of');
  });

  it('M4: when Complete YoY only hides every owner, the empty state names it', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = [ALLEN_ONLY];
    h.fixture.detectChanges();
    await settle(h);
    h.component.onSortColumn('yoyPair');
    expect(h.component.VisibleRows).toHaveLength(0);
    expect(h.component.EmptyMessage).toBe('Complete YoY only is hiding 1 owner without a complete YoY — switch it off, or adjust the search, tier, or filters above.');
    h.component.onCompleteOnlyChange(false);
    expect(h.component.EmptyMessage).toBe('Adjust the search, tier, or filters above.');
  });

  it('M6: Export parcels stays disabled after a failed year read', async () => {
    const h = mount({ scope: 'Statewide' }, [STATEWIDE_RUN, MARION_RUN], true);
    h.state.parcelsFor = (id) => (id === 'a' ? [{ ID: 'ap1', OwnerPortfolioID: 'a', ParcelID: 'PA', Address: '9 Fort Wayne', CountyNumber: 2 }] : []);
    h.state.failHeadlines = true;
    h.fixture.detectChanges();
    await settle(h);
    const a = h.component.VisibleRows.find((r) => r.id === 'a') as OwnerRow;
    h.component.toggleOwner(a);
    await vi.waitFor(() => expect(h.component.ParcelYearsErrorFor(a)).not.toBeNull());
    await vi.waitFor(() => expect(h.component.LoadingParcelsFor).toBeNull());
    h.fixture.detectChanges();
    expect((query(h.fixture, '[data-testid="export-parcels-btn"]') as HTMLButtonElement).disabled).toBe(true);
  });

  it('M7: the agent sort on a removed Statewide column sorts as the fixed-pair YoY', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);
    const sort = (h.component as unknown as { applyAgentSort(p: Record<string, unknown>): { Success: boolean } }).applyAgentSort.bind(h.component);
    expect(sort({ key: 'avPrior', direction: 'desc' }).Success).toBe(true);
    expect(h.component.isSorted('yoyPair')).toBe('desc');
  });
});

/** An ISO instant as the local calendar date (the note uses the viewer's day). */
function isoLocal(iso: string): string {
  const d = new Date(iso);
  const pad = (n: number): string => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}
