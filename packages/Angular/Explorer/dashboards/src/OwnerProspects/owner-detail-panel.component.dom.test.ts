import { describe, it, expect } from 'vitest';
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { renderComponentFixture, queryAll, capture, click } from '@memberjunction/ng-test-utils';
import { OwnerDetailPanelComponent } from './owner-detail-panel.component';
import { OwnerRow } from './owner-prospects.model';

/**
 * DOM coverage for <mj-owner-detail-panel> (module-declared, standalone:false) —
 * the presentational expandable per-owner detail row. It reads only its
 * `@Input() Owner` and emits `FlagRequested` / `ViewProspectRequested`; there is
 * NO data access to mock (no RunView / Metadata / navigationService).
 *
 *  (a) renders one `table.pt tbody tr` per parcel and shows "Flag as prospect"
 *      when the owner is not yet a prospect (`prospectId: null`);
 *  (b) clicking `[data-testid="flag-btn"]` emits `FlagRequested` with the owner.
 *
 * `button[mjButton]` is a light stub (the panel only needs the native <button>'s
 * click + the two attribute inputs) — the standard pattern for these specs.
 *
 * NOTE: co-located `*.component.dom.test.ts` (not `src/__tests__/`) because this
 * package's dual vitest preset runs `src/__tests__/**` on the node env (no DOM /
 * no TestBed platform) and only `*.dom.test.ts` under the jsdom + Angular preset.
 */

@Component({ standalone: true, selector: 'button[mjButton]', template: '<ng-content></ng-content>' })
class StubButton {
  @Input() variant = '';
  @Input() size = '';
}

const owner: OwnerRow = {
  id: 'own-1',
  ownerKey: 'acme-holdings',
  label: 'Acme Holdings LLC',
  kind: 'Company',
  tier: 'Prime',
  parcelCount: 2,
  distinctEntities: 3,
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
  repsOnReduction: ['Faegre Drinker'],
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

const render = (o: OwnerRow) =>
  renderComponentFixture(OwnerDetailPanelComponent, {
    imports: [CommonModule, StubButton],
    declarations: [OwnerDetailPanelComponent],
    inputs: { Owner: o },
  });

describe('OwnerDetailPanelComponent (DOM)', () => {
  it('lists one row per parcel and offers Flag when not yet a prospect', () => {
    const fixture = render(owner);
    expect(queryAll(fixture, 'table.pt tbody tr').length).toBe(2);
    expect((fixture.nativeElement as HTMLElement).textContent ?? '').toContain('Flag as prospect');
  });

  it('emits FlagRequested with the owner on flag-button click', () => {
    const fixture = render(owner);
    const flagged = capture(fixture.componentInstance.FlagRequested);
    click(fixture, '[data-testid="flag-btn"]');
    expect(flagged).toEqual([owner]);
  });
});
