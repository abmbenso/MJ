import { describe, it, expect, vi } from 'vitest';
import type { RunView } from '@memberjunction/core';
import {
  EMPTY_APPEAL_LAYERS, reduceCardAppeals, reduceIbtr, reduceTaxCourtParcels, fetchAppealLayers, applyAppealLayers,
} from '../PropertySearch/property-search-appeal-layers';

describe('reduceCardAppeals', () => {
  // Hand-read from a real card (Hendricks, AY2024): original 123,700 on 2024-04-18, revised by Form 134 to 90,700 on 2024-07-29.
  const appeals = [
    { ParcelID: 'P1', CardAssessmentYear: 2025, AssessmentYear: 2024, ReasonForm: 134, AsOfDate: '2024-07-29', TotalAV: 90700 },
    { ParcelID: 'P1', CardAssessmentYear: 2026, AssessmentYear: 2024, ReasonForm: 134, AsOfDate: '2024-07-29', TotalAV: 90700 },
  ];
  const originals = [
    { ParcelID: 'P1', AsOfDate: '2024-04-18', TotalAV: 123700 },
    { ParcelID: 'P1', AsOfDate: '2024-09-01', TotalAV: 111111 },
  ];
  it('pairs the newest appeal column with the earliest certified original', () => {
    expect(reduceCardAppeals(appeals, originals).get('P1')).toEqual({ form: 134, originalAV: 123700, revisedAV: 90700, date: '2024-07-29' });
  });
  it('takes the later-dated of two revisions', () => {
    const two = [...appeals, { ParcelID: 'P1', CardAssessmentYear: 2026, AssessmentYear: 2024, ReasonForm: 115, AsOfDate: '2025-02-10', TotalAV: 85000 }];
    expect(reduceCardAppeals(two, originals).get('P1')).toMatchObject({ form: 115, revisedAV: 85000, date: '2025-02-10' });
  });
  it('leaves the original blank when the card prints none', () => {
    expect(reduceCardAppeals(appeals, []).get('P1')).toMatchObject({ originalAV: null, revisedAV: 90700 });
  });
});

describe('reduceIbtr', () => {
  const rows = [
    { ID: 'A1', ParcelID: 'P1', DecisionDate: '2019-05-01', AssessmentYear: 2016, DispositionType: 'Board Determination' },
    { ID: 'A2', ParcelID: 'P1', DecisionDate: '2023-11-20', AssessmentYear: 2020, DispositionType: 'Settlement - stipulation' },
    { ID: 'A3', ParcelID: 'P2', DecisionDate: null, AssessmentYear: 2021, DispositionType: 'Remand' },
  ];
  it('reports the newest decision, the count, and a value only from that decision\'s own holding', () => {
    const out = reduceIbtr(rows, [{ IBTRAppealID: 'A1', ValueAfter: 500000 }]);
    expect(out.get('P1')).toEqual({ date: '2023-11-20', year: 2020, disposition: 'Settlement - stipulation', value: null, count: 2 });
    expect(reduceIbtr(rows, [{ IBTRAppealID: 'A2', ValueAfter: 410000 }]).get('P1')?.value).toBe(410000);
  });
  it('keeps a parcel whose only decision is undated', () => {
    expect(reduceIbtr(rows, []).get('P2')).toEqual({ date: null, year: 2021, disposition: 'Remand', value: null, count: 1 });
  });
});

describe('reduceTaxCourtParcels', () => {
  it('flags a parcel reached through any of its appeals', () => {
    const ibtr = [{ ID: 'A1', ParcelID: 'P1' }, { ID: 'A2', ParcelID: 'P2' }];
    expect([...reduceTaxCourtParcels(ibtr, [{ IBTRAppealID: 'A2' }])]).toEqual(['P2']);
  });
});

describe('fetchAppealLayers', () => {
  const ok = (Results: Record<string, unknown>[]) => ({ Success: true, Results });
  it('returns nothing and queries nothing for an empty parcel list', async () => {
    const rv = { RunViews: vi.fn() } as unknown as RunView;
    expect((await fetchAppealLayers(rv, [], 2024, true)).size).toBe(0);
    expect((rv.RunViews as ReturnType<typeof vi.fn>)).not.toHaveBeenCalled();
  });
  it('sets MaxRows and ResultType on every query, scopes the card query to the year, and merges all three layers', async () => {
    const RunViews = vi.fn()
      .mockResolvedValueOnce([
        ok([{ ID: 'A1', ParcelID: 'P1', DecisionDate: '2023-11-20', AssessmentYear: 2020, DispositionType: 'Board Determination' }]),
        ok([{ ParcelID: 'P1', CardAssessmentYear: 2025, AssessmentYear: 2024, ReasonForm: 134, AsOfDate: '2024-07-29', TotalAV: 90700 }]),
      ])
      .mockResolvedValueOnce([
        ok([{ IBTRAppealID: 'A1', ValueAfter: 410000 }]),
        ok([{ IBTRAppealID: 'A1' }]),
        ok([{ ParcelID: 'P1', AsOfDate: '2024-04-18', TotalAV: 123700 }]),
      ]);
    const rv = { RunViews } as unknown as RunView;
    const out = await fetchAppealLayers(rv, ['P1', "P'2"], 2024, true);
    const all = [...RunViews.mock.calls[0][0], ...RunViews.mock.calls[1][0]];
    for (const p of all) { expect(p.MaxRows).toBeGreaterThan(0); expect(p.ResultType).toBe('simple'); }
    expect(RunViews.mock.calls[0][0][1].ExtraFilter).toContain('AssessmentYear = 2024');
    expect(RunViews.mock.calls[0][0][0].ExtraFilter).toContain("'P''2'");
    expect(RunViews.mock.calls[1][0][1].ExtraFilter).toContain('NameScore >= 0.95');
    expect(out.get('P1')).toEqual({
      CardAppealForm: 134, CardOriginalAV: 123700, CardRevisedAV: 90700, CardAppealDate: '2024-07-29',
      IBTRDecisionDate: '2023-11-20', IBTRAssessmentYear: 2020, IBTRDisposition: 'Board Determination', IBTRValue: 410000, IBTRDecisionCount: 1,
      TaxCourtDecision: 'Y',
    });
  });
  it('skips the card query on the DLGF path and the second round trip when nothing came back', async () => {
    const RunViews = vi.fn().mockResolvedValueOnce([ok([])]);
    const out = await fetchAppealLayers({ RunViews } as unknown as RunView, ['P1'], 2025, false);
    expect(RunViews).toHaveBeenCalledTimes(1);
    expect(RunViews.mock.calls[0][0]).toHaveLength(1);
    expect(out.size).toBe(0);
  });
  it('throws when a layer query fails, so a failed load is never shown as "none"', async () => {
    const RunViews = vi.fn().mockResolvedValueOnce([{ Success: false, ErrorMessage: 'boom', Results: [] }]);
    await expect(fetchAppealLayers({ RunViews } as unknown as RunView, ['P1'], 2025, false)).rejects.toThrow(/IBTR Appeals.*boom/);
  });
});

describe('applyAppealLayers', () => {
  it('overlays found layers and leaves other rows at the empty defaults', () => {
    const rows = [{ ParcelID: 'P1', ...EMPTY_APPEAL_LAYERS }, { ParcelID: 'P2', ...EMPTY_APPEAL_LAYERS }];
    const out = applyAppealLayers(rows, new Map([['P1', { ...EMPTY_APPEAL_LAYERS, TaxCourtDecision: 'Y' as const, IBTRDecisionCount: 3 }]]));
    expect(out[0]).toMatchObject({ TaxCourtDecision: 'Y', IBTRDecisionCount: 3 });
    expect(out[1]).toMatchObject({ TaxCourtDecision: 'N', IBTRDecisionCount: null });
  });
});
