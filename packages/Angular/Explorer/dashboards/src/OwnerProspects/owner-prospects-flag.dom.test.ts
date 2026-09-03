import { describe, it, expect } from 'vitest';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TestBed } from '@angular/core/testing';
import { IMetadataProvider, RunViewParams, RunViewResult } from '@memberjunction/core';
import { NavigationService } from '@memberjunction/ng-shared';
import { MJNotificationService } from '@memberjunction/ng-notifications';
import { OwnerProspectsDashboardComponent } from './owner-prospects-dashboard.component';
import { OwnerRow } from './owner-prospects.model';

/**
 * DOM/TestBed coverage for the ONE write path of the Owner Prospects dashboard —
 * `onFlagOwner()`, which creates an `indiana_tax.Prospect` (+ its `ProspectParcel`
 * / `ProspectSnapshot` rows) through the MJ entity layer, mirroring the Node
 * script `Indiana_Tax_Expert/scripts/flag-prospect.js`.
 *
 * The component is TestBed-instantiated but NOT change-detected — `ngOnInit`
 * (→ `loadData`) never runs, so the only data access exercised is the one under
 * test. `ProviderToUse` is a hand-rolled fake: `GetEntityObject(name)` returns a
 * fresh recording fake entity per call, and `RunView` answers the parcel-ID
 * resolution with 2 rows whose GIS numbers match the owner's 2 parcels.
 *
 * Co-located `*.dom.test.ts` (not `src/__tests__/`) — the package's dual vitest
 * preset runs TestBed specs only under `dashboards (dom)`.
 */

const PROSPECT_ID = 'prospect-fake-id';

interface FakeEntity {
  ID: string;
  LatestResult: { CompleteMessage: string } | null;
  NewRecord: () => void;
  Save: () => Promise<boolean>;
}

function createFlagFakeProvider(): {
  provider: IMetadataProvider;
  getCalls: Map<string, number>;
  saveCalls: Map<string, number>;
} {
  const getCalls = new Map<string, number>();
  const saveCalls = new Map<string, number>();
  const bump = (m: Map<string, number>, k: string): void => void m.set(k, (m.get(k) ?? 0) + 1);

  const makeEntity = (entityName: string): FakeEntity => {
    const state = { ID: '', LatestResult: null as { CompleteMessage: string } | null };
    return {
      get ID(): string {
        return state.ID;
      },
      set ID(v: string) {
        state.ID = v;
      },
      get LatestResult(): { CompleteMessage: string } | null {
        return state.LatestResult;
      },
      set LatestResult(v: { CompleteMessage: string } | null) {
        state.LatestResult = v;
      },
      NewRecord(): void {
        /* no-op */
      },
      async Save(): Promise<boolean> {
        bump(saveCalls, entityName);
        if (entityName === 'Prospects') {
          state.ID = PROSPECT_ID;
        }
        return true;
      },
    };
  };

  const fake = {
    CurrentUser: { ID: 'u1', Name: 'Test User', Email: 'test@example.com' },
    async GetEntityObject<T>(entityName: string): Promise<T> {
      bump(getCalls, entityName);
      return makeEntity(entityName) as unknown as T;
    },
    async RunView<T>(params: RunViewParams): Promise<RunViewResult<T>> {
      const rows =
        params.EntityName === 'Parcels'
          ? [
              { ID: 'parcel-id-1', GISParcelNumber: '1234567' },
              { ID: 'parcel-id-2', GISParcelNumber: '7654321' },
            ]
          : [];
      return { Success: true, Results: rows as unknown as T[], RowCount: rows.length, TotalRowCount: rows.length } as RunViewResult<T>;
    },
  };

  return { provider: fake as unknown as IMetadataProvider, getCalls, saveCalls };
}

function makeOwnerRow(): OwnerRow {
  return {
    id: 'own-1',
    ownerKey: 'acme holdings',
    label: 'Acme Holdings LLC',
    kind: 'Company',
    tier: 'Prime',
    parcelCount: 2,
    distinctEntities: 2,
    totalAV: 4_200_000,
    totalAV2025: 4_000_000,
    totalAV2026: 4_200_000,
    avYoYDollars: 200_000,
    avYoYPct: 5,
    parcelsUp10: 1,
    parcelsUp25: 0,
    totalUnits: 120,
    totalSqFt: 88_000,
    nAppealRec: 2,
    nTwoSupport: 1,
    nHighConfAppeal: 2,
    estSavingsAtAsk: 51_000,
    estSavingsAtFloor: 33_000,
    appealedParcels: 1,
    historicalReductionWon: 90_000,
    appealYears: '2021; 2023',
    likelyRep: 'Faegre Drinker',
    repStatus: 'No rep on record',
    repsOnReduction: [],
    isFreshProspect: true,
    mailAddress: '1 Main St, Indianapolis, IN',
    coStarTrueOwner: 'Acme Holdings LLC',
    byType: { Industrial: { n: 1, av: 3_000_000 }, Office: { n: 1, av: 1_200_000 } },
    dominantType: 'Industrial',
    parcels: [
      {
        id: 'p-1',
        gisParcelNumber: '1234567',
        address: '100 Industrial Way',
        typeGroup: 'Industrial',
        currentAV: 3_000_000,
        av2025: 2_800_000,
        av2026: 3_000_000,
        avYoYPct: 7.1,
        units: 80,
        sqft: 60_000,
        ask: 2_400_000,
        estSavingsAtAsk: 36_000,
        estSavingsAtFloor: 22_000,
        rec: 'Appeal',
        conf: 'High',
        supCount: 2,
        appealed: true,
        existingRep: null,
        lastAppealYear: 2023,
      },
      {
        id: 'p-2',
        gisParcelNumber: '7654321',
        address: '200 Office Park',
        typeGroup: 'Office',
        currentAV: 1_200_000,
        av2025: 1_200_000,
        av2026: 1_200_000,
        avYoYPct: 0,
        units: 40,
        sqft: 28_000,
        ask: 1_000_000,
        estSavingsAtAsk: 15_000,
        estSavingsAtFloor: 11_000,
        rec: 'Monitor',
        conf: 'Medium',
        supCount: 1,
        appealed: false,
        existingRep: null,
        lastAppealYear: null,
      },
    ],
    prospectId: null,
  };
}

function instantiate(): { component: OwnerProspectsDashboardComponent; getCalls: Map<string, number>; saveCalls: Map<string, number> } {
  const { provider, getCalls, saveCalls } = createFlagFakeProvider();
  TestBed.configureTestingModule({
    declarations: [OwnerProspectsDashboardComponent],
    imports: [CommonModule],
    providers: [
      {
        provide: NavigationService,
        useValue: {
          OpenEntityRecord: (): void => {},
          // Task 9: onFlagOwner's success path now publishes agent context.
          SetAgentContext: (): void => {},
          SetAgentClientTools: (): void => {},
        },
      },
      { provide: MJNotificationService, useValue: { CreateSimpleNotification: (): void => {} } },
    ],
    schemas: [NO_ERRORS_SCHEMA],
  });
  const fixture = TestBed.createComponent(OwnerProspectsDashboardComponent);
  const component = fixture.componentInstance;
  component.Provider = provider;
  return { component, getCalls, saveCalls };
}

describe('OwnerProspectsDashboardComponent.onFlagOwner (DOM)', () => {
  it('creates the Prospect + one ProspectParcel per resolved parcel + a snapshot, and links the row', async () => {
    const { component, getCalls, saveCalls } = instantiate();
    const row = makeOwnerRow();

    await component.onFlagOwner(row);

    expect(getCalls.get('Prospects')).toBe(1);
    expect(saveCalls.get('Prospects')).toBe(1);
    expect(getCalls.get('Prospect Parcels')).toBe(2);
    expect(saveCalls.get('Prospect Parcels')).toBe(2);
    expect(getCalls.get('Prospect Snapshots')).toBe(1);
    expect(saveCalls.get('Prospect Snapshots')).toBe(1);
    expect(row.prospectId).toBe(PROSPECT_ID);
  });

  it('is a no-op when the row already links a prospect', async () => {
    const { component, getCalls } = instantiate();
    const row = makeOwnerRow();
    row.prospectId = 'existing-id';

    await component.onFlagOwner(row);

    expect(getCalls.size).toBe(0);
    expect(row.prospectId).toBe('existing-id');
  });
});
