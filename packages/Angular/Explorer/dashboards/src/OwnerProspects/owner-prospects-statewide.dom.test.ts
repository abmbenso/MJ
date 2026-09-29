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
import { NO_ANALYSIS_TOOLTIP, OwnerRow } from './owner-prospects.model';

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

const STATEWIDE_RUN: Raw = {
  ID: 'S1', Scope: 'Statewide', IsLatest: 1, RunDate: '2026-09-28T21:29:44Z', MethodologyVersion: 'statewide-v1',
  CountyCount: 3,
  ByCountyJSON: JSON.stringify({
    '2': { parcels: 5, avCurrent: 43_143_000, yoyParcels: 0, avPrior: 0, avCurrentYoY: 0, placeholderParcels: 5, pairs: { '2025 only': 5 } },
    '45': {
      parcels: 15001, avCurrent: 10_521_026_180, yoyParcels: 14851, avPrior: 9_563_918_300, avCurrentYoY: 10_408_930_080, placeholderParcels: 1,
      pairs: { '2024→2025': 14918, '2025 only': 82, '2023→2024': 1 },
    },
    '49': { parcels: 17, avCurrent: 102_416_600, yoyParcels: 17, avPrior: 82_776_800, avCurrentYoY: 102_416_600, placeholderParcels: 0, pairs: { '2025→2026': 17 } },
  }),
};
const MARION_RUN: Raw = { ID: 'M1', Scope: 'Marion', IsLatest: 1, RunDate: '2026-09-24T10:36:38Z', MethodologyVersion: 'sales-p25', CountyTotalAV2025: 1, CountyTotalAV2026: 2, CountyYoYPct: 15.2 };

const statewideOwner = (over: Raw): Raw => ({
  Kind: 'Company', Tier: 'A', TierBasis: 'AV', RepStatus: 'No rep data for this county', ParcelCount: 1,
  EstSavingsAtAsk: null, EstSavingsAtFloor: null, GroupKeyType: 'NAME', ...over,
});
const WALMART = statewideOwner({
  ID: 'w', Label: 'Walmart Inc.', GroupKeyType: 'CO', PrimaryCountyNumber: 49, CountyCount: 2, AVPrior: 119_809_900, AVCurrent: 138_333_200,
  TotalAV: 138_333_200, AVYoYPct: 7.2, EstSavingsAtAsk: 162_164.47, RepStatus: 'Represented by INTEGRITY TAX CONSULTING',
  PairYears: 'mixed', NAppealRec: 5,
  ByCountyJSON: '{"45":{"parcels":4,"avCurrent":35916600,"avPrior":37033100},"49":{"parcels":17,"avCurrent":102416600,"avPrior":82776800}}',
});
const LAKE_ONLY = statewideOwner({
  ID: 'l', Label: 'Lake Only LLC', PrimaryCountyNumber: 45, CountyCount: 1, AVPrior: 5_700, AVCurrent: 2_729_600, TotalAV: 2_729_600,
  AVYoYPct: 47_787.7, ByCountyJSON: '{"45":{"parcels":1,"avCurrent":2729600,"avPrior":5700}}',
});
const ALLEN_ONLY = statewideOwner({
  ID: 'a', Label: 'Allen Only LLC', Tier: 'B', PrimaryCountyNumber: 2, CountyCount: 1, AVPrior: null, AVCurrent: 900_000, TotalAV: 900_000,
  ByCountyJSON: '{"2":{"parcels":1,"avCurrent":900000,"avPrior":null}}',
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
    (p.EntityName === 'Owner Portfolios' && !!state.failSearch && (p.ExtraFilter ?? '').includes('Label LIKE'));
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

function mount(queryParams: Record<string, string>, runs: Raw[] = [STATEWIDE_RUN, MARION_RUN]): Harness {
  const state: FakeState = { runs, calls: [], saved: new Map(), notes: [] };
  const pushed: Record<string, string | null>[] = [];
  TestBed.configureTestingModule({
    declarations: [OwnerProspectsDashboardComponent],
    imports: [CommonModule],
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
    expect(h.pushed.at(-1)).toEqual({ scope: 'Statewide', county: null });

    h.component.onScopeChange('Marion');
    await settle(h);
    expect(runCalls(h.state)[2].ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Marion'");
    expect(h.pushed.at(-1)).toEqual({ scope: null, county: null });
  });

  it('county filter: a multi-county owner lists under each of its counties and once under All', async () => {
    const h = mount({ scope: 'Statewide' });
    h.fixture.detectChanges();
    await settle(h);

    h.component.onCountyChange(45);
    await settle(h);
    expect(ownerCalls(h.state).at(-1)!.ExtraFilter).toBe(`RunID = 'S1' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`);
    expect(h.component.VisibleRows.map((r) => r.id).sort()).toEqual(['l', 'w']);
    expect(h.pushed.at(-1)).toEqual({ scope: 'Statewide', county: '45' });
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

  it('renders the honest empties: AV tier header, blank savings with the tooltip, stored rep status, YoY floor pill', async () => {
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
    expect(h.component.FilterCountLabel).toBe('3 owners · Σ AV current $142.0M'); // AV, never the blank savings
    const pills = queryAll(h.fixture, '[data-testid="yoy-floor-pill"]');
    expect(pills).toHaveLength(1);
    expect(pills[0].textContent?.trim()).toBe('prior < $100k');
    // YoY sort (the default statewide sort is AV) — the tiny-prior row never tops the list.
    h.component.onSortColumn('avYoYPct'); // a fresh numeric column starts descending
    expect(h.component.VisibleRows.map((r) => r.id)).toEqual(['w', 'l', 'a']); // 47,787.7% on a $5,700 prior sorts after 7.2%
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

  it('5: the county banner names its assessment years — one pair, or mixed pairs; All says mixed assessment pairs', async () => {
    const h = mount({ scope: 'Statewide', county: '49' });
    h.fixture.detectChanges();
    await settle(h);
    const years = (): string | undefined => query(h.fixture, '[data-testid="county-banner-years"]')?.textContent?.trim();
    expect(years()).toBe('assessment years 2025→2026');
    h.component.onCountyChange(45);
    await settle(h);
    expect(years()).toBe('mixed pairs — mostly 2024→2025 (14,918 of 15,001 parcels)');
    h.component.onCountyChange(null);
    await settle(h);
    expect(years()).toBe('mixed assessment pairs — mostly 2024→2025 (14,918 of 15,023 parcels)');
    const w = queryAll(h.fixture, '[data-testid="av-current"]').find((c) => c.textContent?.includes('138,333,200'));
    expect(w?.getAttribute('title')).toBe("mixed assessment years across this owner's parcels — see the parcel list");
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
    expect(query(h.fixture, '[data-testid="statewide-total-av-label"]')?.textContent?.trim()).toBe('total assessed value (top 5,000 loaded)');
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

  it('C1/I4: the AV prior cell states the paired n of m; a bare-year PairYears reads "current year only"', async () => {
    const h = mount({ scope: 'Statewide' });
    h.state.statewideOwners = [
      LILLY,
      statewideOwner({ ID: 's', Label: 'Single Year LLC', PrimaryCountyNumber: 2, CountyCount: 1, AVCurrent: 900_000, TotalAV: 900_000,
        AVPrior: null, PairYears: '2026', ByCountyJSON: '{"2":{"parcels":1,"avCurrent":900000,"avPrior":null,"pairedParcels":0}}' }),
    ];
    h.fixture.detectChanges();
    await settle(h);
    const priors = queryAll(h.fixture, '[data-testid="av-prior"]').map((c) => c.getAttribute('title'));
    expect(priors).toContain('paired, non-placeholder parcels only (60 of 68) — assessment years 2025→2026');
    const current = queryAll(h.fixture, '[data-testid="av-current"]').map((c) => c.getAttribute('title'));
    expect(current).toContain('2026: current year only — no prior-year figure on the record');
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
      parcelNumber: '450706207002000023', countyNumber: 45, priorYear: 2024, currentYear: 2025, avPrior: 37_033_100, avCurrent: 35_916_600, isPlaceholder: false,
    },
    {
      id: 'p2', gisParcelNumber: '', address: '2 Adams St', typeGroup: 'Retail', currentAV: null, av2025: null, av2026: null,
      avYoYPct: null, units: null, sqft: null, ask: null, estSavingsAtAsk: null, estSavingsAtFloor: null, rec: null, conf: null,
      supCount: null, appealed: false, existingRep: null, lastAppealYear: null,
      parcelNumber: '010101010101010101', countyNumber: 1, priorYear: null, currentYear: 2025, avPrior: null, avCurrent: 7_645_300, isPlaceholder: true,
    },
  ];
  const render = () =>
    renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton],
      declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: parcels, Statewide: true, CountySlugs: { 45: 'lake', 1: 'adams' }, CountyNames: { 45: 'Lake', 1: 'Adams' } },
    });

  it('shows PriorYear→CurrentYear, the placeholder pill, a Lake card link and an honest no-link', () => {
    const f = render();
    const rows = queryAll(f, 'table.pt tbody tr');
    expect(rows).toHaveLength(2);
    expect(rows[0].textContent).toContain('2024→2025');
    expect(rows[0].querySelector('[data-testid="placeholder-pill"]')).toBeNull();
    expect(rows[1].textContent).toContain('2025 only');
    expect(rows[1].querySelector('[data-testid="placeholder-pill"]')?.textContent?.trim()).toBe('placeholder');
    expect(rows[0].querySelector('a')?.getAttribute('href')).toBe('https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf');
    expect(rows[1].querySelector('a')).toBeNull();
    expect(rows[1].textContent).toContain('no card link');
    expect(query(f, '[data-testid="county-split"]')?.textContent).toContain('Lake 1 ($35.9M) · Adams 1 ($7.6M)');
    expect(query(f, '[data-testid="parcels-capped"]')).toBeNull();
  });

  it('C1: a DLGF-placeholder prior carries the "prior placeholder" pill; a paired or overflowed prior does not', () => {
    const base = parcels[0];
    const rows = [
      { ...base, id: 'q1', address: 'Q1 placeholder prior', avPrior: 900_000, avCurrent: 950_000, avYoYPct: null, isPlaceholder: false },
      { ...base, id: 'q2', address: 'Q2 overflow', avPrior: 700, avCurrent: 2_522_200, avYoYPct: null, isPlaceholder: false },
      { ...base, id: 'q3', address: 'Q3 paired' },
      { ...base, id: 'q4', address: 'Q4 zero prior', avPrior: 0, avCurrent: 50_000, avYoYPct: null, isPlaceholder: false },
    ];
    const f = renderComponentFixture(OwnerDetailPanelComponent, {
      imports: [CommonModule, StubButton],
      declarations: [OwnerDetailPanelComponent],
      inputs: { Owner: owner, Parcels: rows, Statewide: true, CountySlugs: {}, CountyNames: {} },
    });
    const tr = (a: string): Element | undefined => queryAll(f, 'table.pt tbody tr').find((r) => r.textContent?.includes(a));
    const pill = tr('Q1 placeholder prior')?.querySelector('[data-testid="prior-placeholder-pill"]');
    expect(pill?.textContent?.trim()).toBe('prior placeholder');
    expect(pill?.getAttribute('title')).toContain('DLGF roll figure only');
    expect(tr('Q2 overflow')?.querySelector('[data-testid="prior-placeholder-pill"]')).toBeNull();
    expect(tr('Q3 paired')?.querySelector('[data-testid="prior-placeholder-pill"]')).toBeNull();
    expect(tr('Q4 zero prior')?.querySelector('[data-testid="prior-placeholder-pill"]')).toBeNull();
    expect(tr('Q4 zero prior')?.querySelector('[data-testid="prior-zero-pill"]')?.textContent?.trim()).toBe('prior $0');
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
