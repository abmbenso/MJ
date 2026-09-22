import { Component, EventEmitter, Input, Output } from '@angular/core';
import { describe, it, expect } from 'vitest';
import type { IMetadataProvider, RunViewParams } from '@memberjunction/core';
import { renderComponentFixture, createFakeProvider } from '@memberjunction/ng-test-utils';
import { PropertySubclassAnalyticsComponent } from './property-subclass-analytics.component';

/**
 * Round-1 fix regression test (finding 1): Angular applies template bindings in DECLARATION
 * order, and the host template (property-search-dashboard.component.html) sets [CountyNumber]
 * BEFORE [HasCardData]. Before the fix, HasCardData was a plain field (no setter), so switching
 * a DLGF-only county -> Marion left both grids empty forever: CountyNumber's setter fired
 * Refresh() synchronously while HasCardData still held the OLD (false) value, loadAll() took the
 * early "!HasCardData" return, and HasCardData's own change (still a plain field) never triggered
 * a reload at all.
 *
 * `componentRef.setInput` invokes the same `@Input()` setter a template binding would, in exactly
 * the order the test calls it -- so calling CountyNumber then HasCardData below reproduces the
 * real template's binding order without needing a host template.
 */

@Component({ standalone: true, selector: 'ag-grid-angular', template: '' })
class StubAgGrid {
  @Input() theme: unknown;
  @Input() rowData: unknown;
  @Input() columnDefs: unknown;
  @Input() defaultColDef: unknown;
  @Input() gridOptions: unknown;
}
@Component({ standalone: true, selector: 'mj-empty-state', template: '' })
class StubEmptyState {
  @Input() Icon = '';
  @Input() Title = '';
  @Input() Message = '';
}
@Component({ standalone: true, selector: 'mj-loading', template: '' })
class StubLoading {
  @Input() text = '';
}
@Component({ standalone: true, selector: 'mj-view-toggle', template: '' })
class StubViewToggle {
  @Input() Options: unknown;
  @Input() ActiveKey: unknown;
  @Output() KeyChange = new EventEmitter<string>();
}

const CAR_ROWS = [{ ParcelID: 'p1', PropertySubClassDescription: 'Retail', SqFtSource: 'PropertyRecordCard', EstimatedSqFt: 10000 }];
// Parcel Year Headlines rows: one per parcel-year, already source-resolved (2026-09-22).
const ASSESSMENT_ROWS = [{ ParcelID: 'p1', HeadlineTotalAV: 500000 }];

function fakeProvider() {
  return createFakeProvider({
    runViewResults: (params: RunViewParams): Record<string, unknown>[] => {
      if (params.EntityName === 'County Assessor Records') return CAR_ROWS;
      if (params.EntityName === 'PTABOA Appeals') return [];
      if (params.EntityName === 'Parcel Year Headlines') return ASSESSMENT_ROWS;
      return [];
    },
  });
}

async function flush(): Promise<void> {
  // loadAll() chains TWO sequential awaits (a RunViews batch, then loadAssessmentAnalytics'
  // own RunView) on top of scheduleRefresh()'s microtask -- several macrotask ticks (the same
  // wait shape usage-patterns.component.dom.test.ts uses for its own single-await load) clears
  // the whole chain reliably.
  for (let i = 0; i < 4; i++) await new Promise((r) => setTimeout(r, 0));
}

describe('PropertySubclassAnalyticsComponent -- binding-order fix (finding 1)', () => {
  it('reaches loaded state when CountyNumber changes before HasCardData (the real template order)', async () => {
    const fixture = renderComponentFixture(PropertySubclassAnalyticsComponent, {
      declarations: [PropertySubclassAnalyticsComponent],
      imports: [StubAgGrid, StubEmptyState, StubLoading, StubViewToggle],
      inputs: { Provider: fakeProvider(), CountyNumber: 999, HasCardData: false, AssessmentYear: 2025, Active: true },
    });
    await flush();
    fixture.detectChanges();

    // Initial DLGF-only county: no card data, both grids empty.
    expect(fixture.componentInstance.AssessmentRows).toEqual([]);

    // Simulate the county switch exactly as the host template applies it: CountyNumber's
    // binding is declared first, HasCardData's second.
    fixture.componentRef.setInput('CountyNumber', 49);
    fixture.componentRef.setInput('HasCardData', true);
    await flush();
    fixture.detectChanges();

    expect(fixture.componentInstance.AssessmentRows.length).toBe(1);
    expect(fixture.componentInstance.AssessmentRows[0].subClass).toBe('Retail');
    expect(fixture.componentInstance.AssessmentRows[0].totalAV).toBe(500000);
  });

  it('also reaches loaded state when HasCardData changes before CountyNumber (order-independence)', async () => {
    const fixture = renderComponentFixture(PropertySubclassAnalyticsComponent, {
      declarations: [PropertySubclassAnalyticsComponent],
      imports: [StubAgGrid, StubEmptyState, StubLoading, StubViewToggle],
      inputs: { Provider: fakeProvider(), CountyNumber: 999, HasCardData: false, AssessmentYear: 2025, Active: true },
    });
    await flush();
    fixture.detectChanges();

    fixture.componentRef.setInput('HasCardData', true);
    fixture.componentRef.setInput('CountyNumber', 49);
    await flush();
    fixture.detectChanges();

    expect(fixture.componentInstance.AssessmentRows.length).toBe(1);
    expect(fixture.componentInstance.AssessmentRows[0].totalAV).toBe(500000);
  });
});

/**
 * Click-through fix (2026-09-13): the host declares [Active]="true" BEFORE [CountyNumber] /
 * [HasCardData], so on creation Active's setter used to call loadAll() synchronously while the
 * other inputs still held their defaults (Marion, card data) -- fetching Marion's 20k record
 * cards for whichever county was actually selected -- and every input applied while that fetch
 * was in flight was dropped by the `_loadedOnce` guard. Lake's Analytics view rolled up Marion's
 * sub-classes. The first load is now deferred to the coalescing microtask and a superseded
 * in-flight load is discarded (loadSeq).
 */
const CAR_ROWS_BY_COUNTY: Record<string, Record<string, unknown>[]> = {
  '49': CAR_ROWS,
  '45': [{ ParcelID: 'lake1', PropertySubClassDescription: 'Lake Retail', SqFtSource: 'PropertyRecordCard', EstimatedSqFt: 20000 }],
};
const ASSESSMENT_ROWS_BY_COUNTY: Record<string, Record<string, unknown>[]> = {
  '49': ASSESSMENT_ROWS,
  '45': [{ ParcelID: 'lake1', HeadlineTotalAV: 750000 }],
};
function countyOf(params: RunViewParams): string {
  const m = /CountyNumber = (\d+)/.exec(String(params.ExtraFilter ?? ''));
  return m ? m[1] : '';
}
function countyProvider(carFilters: string[]) {
  return createFakeProvider({
    runViewResults: (params: RunViewParams): Record<string, unknown>[] => {
      const county = countyOf(params);
      if (params.EntityName === 'County Assessor Records') {
        carFilters.push(String(params.ExtraFilter));
        return CAR_ROWS_BY_COUNTY[county] ?? [];
      }
      if (params.EntityName === 'Parcel Year Headlines') return ASSESSMENT_ROWS_BY_COUNTY[county] ?? [];
      return [];
    },
  });
}

describe('PropertySubclassAnalyticsComponent -- first load waits for every binding; a superseded load is discarded', () => {
  it('fetches the bound county, not the Marion default, when Active is bound before CountyNumber', async () => {
    const carFilters: string[] = [];
    const fixture = renderComponentFixture(PropertySubclassAnalyticsComponent, {
      declarations: [PropertySubclassAnalyticsComponent],
      imports: [StubAgGrid, StubEmptyState, StubLoading, StubViewToggle],
      // Same order as the host template: Active first, the county-scoped inputs after it.
      inputs: { Provider: countyProvider(carFilters), Active: true, CountyNumber: 45, HasCardData: true, AssessmentYear: 2025 },
    });
    await flush();
    fixture.detectChanges();

    expect(carFilters).toEqual(['CountyNumber = 45']);
    expect(fixture.componentInstance.AssessmentRows.map((r) => r.subClass)).toEqual(['Lake Retail']);
    expect(fixture.componentInstance.AssessmentRows[0].totalAV).toBe(750000);
  });

  it('shows the county selected LAST when a switch lands while the previous load is still in flight', async () => {
    const carFilters: string[] = [];
    const base = countyProvider(carFilters);
    // Marion's fetch is slow (it is 20k rows in production); Lake's answers at once.
    const slowMarion: IMetadataProvider = {
      ...base,
      RunViews: async (list: RunViewParams[]) => {
        if (list.some((p) => countyOf(p) === '49')) await new Promise((r) => setTimeout(r, 40));
        return base.RunViews(list);
      },
    };
    const fixture = renderComponentFixture(PropertySubclassAnalyticsComponent, {
      declarations: [PropertySubclassAnalyticsComponent],
      imports: [StubAgGrid, StubEmptyState, StubLoading, StubViewToggle],
      inputs: { Provider: slowMarion, Active: true, CountyNumber: 49, HasCardData: true, AssessmentYear: 2025 },
    });
    await new Promise((r) => setTimeout(r, 0)); // the deferred first load has started (Marion, in flight)
    fixture.componentRef.setInput('CountyNumber', 45);
    await new Promise((r) => setTimeout(r, 80)); // long enough for BOTH fetches to land
    await flush();
    fixture.detectChanges();

    // Both fetches ran (the fake records a call when it answers, so Lake's instant reply is
    // listed before Marion's delayed one) -- and Marion's late-landing rows were discarded.
    expect([...carFilters].sort()).toEqual(['CountyNumber = 45', 'CountyNumber = 49']);
    expect(fixture.componentInstance.AssessmentRows.map((r) => r.subClass)).toEqual(['Lake Retail']);
    expect(fixture.componentInstance.CountyNumber).toBe(45);
  });
});
