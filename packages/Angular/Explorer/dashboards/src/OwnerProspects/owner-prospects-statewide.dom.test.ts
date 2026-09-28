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
    '2': { parcels: 5, avCurrent: 43_143_000, yoyParcels: 0, avPrior: 0, avCurrentYoY: 0, placeholderParcels: 5 },
    '45': { parcels: 15001, avCurrent: 10_521_026_180, yoyParcels: 14851, avPrior: 9_563_918_300, avCurrentYoY: 10_408_930_080, placeholderParcels: 1 },
    '49': { parcels: 17, avCurrent: 102_416_600, yoyParcels: 17, avPrior: 82_776_800, avCurrentYoY: 102_416_600, placeholderParcels: 0 },
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

interface FakeState {
  runs: Raw[];
  calls: RunViewParams[];
  /** Overrides the statewide portfolio rows (the cap test). */
  statewideOwners?: Raw[];
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
        if ((p.ExtraFilter ?? '').includes("'M1'")) return [MARION_OWNER];
        return (state.statewideOwners ?? [WALMART, LAKE_ONLY, ALLEN_ONLY]).slice(0, p.MaxRows ?? undefined);
      default:
        return [];
    }
  };
  const fake = {
    CurrentUser: { ID: 'u1', Name: 'Test User', Email: 'test@example.com' },
    async RunView<T>(p: RunViewParams): Promise<RunViewResult<T>> {
      return ok<T>(answer(p));
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
  const state: FakeState = { runs, calls: [] };
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
      { provide: MJNotificationService, useValue: { CreateSimpleNotification: (): void => {} } },
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
    for (const cell of opp) {
      expect(cell.textContent?.trim()).toBe('');
      expect(cell.getAttribute('title')).toBe(NO_ANALYSIS_TOOLTIP);
    }
    const reps = queryAll(h.fixture, '[data-testid="rep-cell"]').map((c) => c.textContent?.trim());
    expect(reps).toContain('No rep data for this county');
    expect(reps).toContain('Represented by INTEGRITY TAX CONSULTING');
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
    expect(h.component.RowCapMessage).toBe('showing the top 5,000 by AV; filter by county to see all');
    expect(query(h.fixture, '[data-testid="row-cap-banner"]')).not.toBeNull();
    h.component.onCountyChange(45);
    await settle(h);
    expect(h.component.RowCapMessage).toBe("showing the top 5,000 by AV in Lake; this county's smallest owners are not loaded");
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
  });
});
