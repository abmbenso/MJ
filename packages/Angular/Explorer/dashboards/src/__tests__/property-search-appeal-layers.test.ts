import { describe, it, expect, vi } from 'vitest';
import type { RunView } from '@memberjunction/core';
import {
  EMPTY_APPEAL_LAYERS, reduceCardAppeals, reduceIbtr, reduceTaxCourtParcels, fetchAppealLayers, applyAppealLayers,
  pickHoldingValue, rowsOrThrow, APPEAL_LAYER_MAX_ROWS,
} from '../PropertySearch/property-search-appeal-layers';
import { buildCardRevisionRows, buildCardNoteRows } from '../PropertySearch/property-search-appeal-layers';

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

describe('pickHoldingValue', () => {
  // The five real IBTRDecisionHolding rows carried by petition 53-009-07-1-4-00189 (AY2007),
  // read from indiana_tax.IBTRDecisionHolding on 2026-09-21. Four of them are OTHER years'
  // holdings printed in the same determination -- taking the first would show AY2006's 521,600
  // beside "IBTR Year 2007".
  const fiveHoldings = [
    { PetitionNumbers: '53-009-06-1-4-00188', AssessmentYears: '2006', ValueAfter: 521600 },
    { PetitionNumbers: '53-009-07-1-4-00189', AssessmentYears: '2007', ValueAfter: 515900 },
    { PetitionNumbers: '53-009-08-1-4-00018', AssessmentYears: '2008', ValueAfter: 588600 },
    { PetitionNumbers: '53-009-09-1-4-00018', AssessmentYears: '2009', ValueAfter: 592200 },
    { PetitionNumbers: '53-009-10-1-4-00052', AssessmentYears: '2010', ValueAfter: 570200 },
  ];
  it('takes the holding that names the appeal\'s own petition number', () => {
    expect(pickHoldingValue({ PetitionNumber: '53-009-07-1-4-00189', AssessmentYear: 2007 }, fiveHoldings)).toBe(515900);
  });
  it('falls back to the one holding whose AssessmentYears names the appeal year', () => {
    // Same five holdings, but the docketed petition number is not printed in any of them.
    const unnamed = fiveHoldings.map((h) => ({ ...h, PetitionNumbers: '' }));
    expect(pickHoldingValue({ PetitionNumber: '53-009-07-1-4-00189', AssessmentYear: 2007 }, unnamed)).toBe(515900);
  });
  it('reads a 4-digit year as a whole token inside a multi-year list', () => {
    const rows = [
      { PetitionNumbers: '', AssessmentYears: '2008, 2009', ValueAfter: 740000 },
      { PetitionNumbers: '', AssessmentYears: '2011', ValueAfter: 120200 },
    ];
    expect(pickHoldingValue({ PetitionNumber: 'X', AssessmentYear: 2009 }, rows)).toBe(740000);
    expect(pickHoldingValue({ PetitionNumber: 'X', AssessmentYear: 200 }, rows)).toBeNull();
  });
  it('matches the petition number as a whole entry, not a substring', () => {
    const rows = [{ PetitionNumbers: '02-073-20-2-8-00347-21, 02-073-20-2-8-00348-21', AssessmentYears: '2020', ValueAfter: 999 }];
    expect(pickHoldingValue({ PetitionNumber: '02-073-20-2-8-0034', AssessmentYear: 2019 }, rows)).toBeNull();
    expect(pickHoldingValue({ PetitionNumber: '02-073-20-2-8-00348-21', AssessmentYear: 2019 }, rows)).toBe(999);
  });
  it('returns null when neither the petition nor the year picks exactly one', () => {
    expect(pickHoldingValue({ PetitionNumber: '53-009-07-1-4-99999', AssessmentYear: 2099 }, fiveHoldings)).toBeNull();
  });
  it('returns null when two holdings name the appeal\'s petition and year', () => {
    const rows = [
      { PetitionNumbers: 'P-1', AssessmentYears: '2007', ValueAfter: 100 },
      { PetitionNumbers: 'P-1, P-2', AssessmentYears: '2007', ValueAfter: 200 },
    ];
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2007 }, rows)).toBeNull();
  });
  it('takes a sole unlabelled holding -- the single-holding case the grid has always shown', () => {
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2007 }, [{ PetitionNumbers: null, AssessmentYears: '', ValueAfter: 43700 }])).toBe(43700);
  });
  it('will not take an unlabelled holding when the appeal has others', () => {
    const rows = [
      { PetitionNumbers: null, AssessmentYears: '', ValueAfter: 43700 },
      { PetitionNumbers: '', AssessmentYears: '', ValueAfter: 51000 },
    ];
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2007 }, rows)).toBeNull();
  });
  it('will not take a sole holding that names a DIFFERENT petition and year', () => {
    expect(pickHoldingValue({ PetitionNumber: '02-073-20-2-8-00346-21', AssessmentYear: 2020 },
      [{ PetitionNumbers: '02-073-22-2-8-00187-23', AssessmentYears: '2022', ValueAfter: 300000 }])).toBeNull();
  });
  it('ignores holdings with no extracted value, and keeps a zero', () => {
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2007 },
      [{ PetitionNumbers: 'P-1', AssessmentYears: '2007', ValueAfter: null }, { PetitionNumbers: 'P-9', AssessmentYears: '2009', ValueAfter: 5 }])).toBeNull();
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2003 }, [{ PetitionNumbers: 'P-1', AssessmentYears: '2003', ValueAfter: 0 }])).toBe(0);
  });
  it('returns null when the appeal has no holdings at all', () => {
    expect(pickHoldingValue({ PetitionNumber: 'P-1', AssessmentYear: 2007 }, [])).toBeNull();
  });
});

describe('reduceIbtr', () => {
  const rows = [
    { ID: 'A1', ParcelID: 'P1', PetitionNumber: '49-800-16-1-4-00001', DecisionDate: '2019-05-01', AssessmentYear: 2016, DispositionType: 'Board Determination' },
    { ID: 'A2', ParcelID: 'P1', PetitionNumber: '49-800-20-1-4-00002', DecisionDate: '2023-11-20', AssessmentYear: 2020, DispositionType: 'Settlement - stipulation' },
    { ID: 'A3', ParcelID: 'P2', PetitionNumber: '49-800-21-1-4-00003', DecisionDate: null, AssessmentYear: 2021, DispositionType: 'Remand' },
  ];
  it('reports the newest decision, the count, and a value only from that decision\'s own holding', () => {
    const out = reduceIbtr(rows, [{ IBTRAppealID: 'A1', PetitionNumbers: '49-800-16-1-4-00001', AssessmentYears: '2016', ValueAfter: 500000 }]);
    expect(out.get('P1')).toEqual({ date: '2023-11-20', year: 2020, disposition: 'Settlement - stipulation', value: null, count: 2 });
    expect(reduceIbtr(rows, [{ IBTRAppealID: 'A2', PetitionNumbers: '49-800-20-1-4-00002', AssessmentYears: '2020', ValueAfter: 410000 }]).get('P1')?.value).toBe(410000);
  });
  it('shows no value when the newest decision\'s holdings are another year\'s', () => {
    const holdings = [
      { IBTRAppealID: 'A2', PetitionNumbers: '49-800-18-1-4-00009', AssessmentYears: '2018', ValueAfter: 300000 },
      { IBTRAppealID: 'A2', PetitionNumbers: '49-800-19-1-4-00010', AssessmentYears: '2019', ValueAfter: 310000 },
    ];
    expect(reduceIbtr(rows, holdings).get('P1')?.value).toBeNull();
  });
  it('keeps a parcel whose only decision is undated', () => {
    expect(reduceIbtr(rows, []).get('P2')).toEqual({ date: null, year: 2021, disposition: 'Remand', value: null, count: 1 });
  });
});

describe('rowsOrThrow', () => {
  it('passes a result below its MaxRows cap through', () => {
    expect(rowsOrThrow('IBTR Appeals', { Success: true, Results: [{ ID: 'A1' }] }, 2)).toHaveLength(1);
  });
  it('throws when a query comes back AT its MaxRows cap -- a truncated read must never read as "none"', () => {
    expect(() => rowsOrThrow('IBTR Appeals', { Success: true, Results: [{ ID: 'A1' }, { ID: 'A2' }] }, 2))
      .toThrow(/IBTR Appeals returned 2 rows .* at or over its MaxRows cap \(2\)/);
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
        ok([{ ID: 'A1', ParcelID: 'P1', PetitionNumber: '49-800-20-1-4-00002', DecisionDate: '2023-11-20', AssessmentYear: 2020, DispositionType: 'Board Determination' }]),
        ok([{ ParcelID: 'P1', CardAssessmentYear: 2025, AssessmentYear: 2024, ReasonForm: 134, AsOfDate: '2024-07-29', TotalAV: 90700 }]),
      ])
      .mockResolvedValueOnce([
        ok([{ IBTRAppealID: 'A1', PetitionNumbers: '49-800-20-1-4-00002', AssessmentYears: '2020', ValueAfter: 410000 }]),
        ok([{ IBTRAppealID: 'A1' }]),
        ok([{ ParcelID: 'P1', AsOfDate: '2024-04-18', TotalAV: 123700 }]),
      ]);
    const rv = { RunViews } as unknown as RunView;
    const out = await fetchAppealLayers(rv, ['P1', "P'2"], 2024, true);
    const all = [...RunViews.mock.calls[0][0], ...RunViews.mock.calls[1][0]];
    for (const p of all) { expect(p.MaxRows).toBeGreaterThan(0); expect(p.ResultType).toBe('simple'); }
    expect(RunViews.mock.calls[0][0][0].Fields).toEqual(expect.arrayContaining(['PetitionNumber']));
    expect(RunViews.mock.calls[1][0][0].Fields).toEqual(expect.arrayContaining(['PetitionNumbers', 'AssessmentYears']));
    expect(RunViews.mock.calls[0][0][1].ExtraFilter).toContain('AssessmentYear = 2024');
    expect(RunViews.mock.calls[0][0][0].ExtraFilter).toContain("'P''2'");
    expect(RunViews.mock.calls[1][0][1].ExtraFilter).toContain('NameScore >= 0.95');
    expect(out.get('P1')).toEqual({
      CardAppealForm: 134, CardOriginalAV: 123700, CardRevisedAV: 90700, CardAppealDate: '2024-07-29',
      IBTRDecisionDate: '2023-11-20', IBTRAssessmentYear: 2020, IBTRDisposition: 'Board Determination', IBTRValue: 410000, IBTRDecisionCount: 1,
      TaxCourtDecision: 'Y',
    });
    // A requested parcel the docket knows nothing about: blank, not "N" -- no Board decision is
    // matched to it, so there is nothing a Tax Court case could be reviewing.
    expect(out.get("P'2")).toMatchObject({ IBTRDecisionCount: null, TaxCourtDecision: null });
  });
  it('says N only for a parcel that HAS Board decisions and no qualifying Tax Court link', async () => {
    const RunViews = vi.fn()
      .mockResolvedValueOnce([ok([{ ID: 'A1', ParcelID: 'P1', PetitionNumber: 'P-1', DecisionDate: '2023-11-20', AssessmentYear: 2020, DispositionType: 'Dismissal' }])])
      .mockResolvedValueOnce([ok([]), ok([])]);
    const out = await fetchAppealLayers({ RunViews } as unknown as RunView, ['P1', 'P2'], 2025, false);
    expect(out.get('P1')?.TaxCourtDecision).toBe('N');
    expect(out.get('P2')?.TaxCourtDecision).toBeNull();
  });
  it('skips the card query on the DLGF path and the second round trip when nothing came back', async () => {
    const RunViews = vi.fn().mockResolvedValueOnce([ok([])]);
    const out = await fetchAppealLayers({ RunViews } as unknown as RunView, ['P1'], 2025, false);
    expect(RunViews).toHaveBeenCalledTimes(1);
    expect(RunViews.mock.calls[0][0]).toHaveLength(1);
    // Every requested parcel still gets an entry on a SUCCESSFUL load -- that is what makes
    // blank-because-nothing-is-linked distinguishable from blank-because-the-load-failed.
    expect(out.get('P1')).toEqual(EMPTY_APPEAL_LAYERS);
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
    // Not 'N': applyAppealLayers' defaults are what a row carries when NOTHING was loaded for it.
    expect(out[1]).toMatchObject({ TaxCourtDecision: null, IBTRDecisionCount: null });
  });
});

describe('APPEAL_LAYER_MAX_ROWS', () => {
  it('is the single source of every cap the fetchers query with', () => {
    for (const cap of Object.values(APPEAL_LAYER_MAX_ROWS)) expect(cap).toBeGreaterThan(0);
  });
});

describe('buildCardRevisionRows', () => {
  const cols = [
    { CardAssessmentYear: 2026, AssessmentYear: 2025, IsCertified: true, ReasonKind: 'appeal', ReasonForm: 134, ReasonForChange: 'Reval/134', AsOfDate: '2025-08-21', TotalAV: 93500 },
    { CardAssessmentYear: 2026, AssessmentYear: 2025, IsCertified: true, ReasonKind: 'annual', ReasonForm: null, ReasonForChange: 'Annual-Adj', AsOfDate: '2025-04-17', TotalAV: 184100 },
    { CardAssessmentYear: 2026, AssessmentYear: 2024, IsCertified: true, ReasonKind: 'appeal', ReasonForm: 134, ReasonForChange: 'Reval/134', AsOfDate: '2024-07-29', TotalAV: 90700 },
    { CardAssessmentYear: 2025, AssessmentYear: 2024, IsCertified: true, ReasonKind: 'appeal', ReasonForm: 134, ReasonForChange: 'Reval/134', AsOfDate: '2024-07-29', TotalAV: 90700 },
    { CardAssessmentYear: 2025, AssessmentYear: 2024, IsCertified: true, ReasonKind: 'annual', ReasonForm: null, ReasonForChange: 'Annual-Adj', AsOfDate: '2024-04-18', TotalAV: 123700 },
  ];
  it('lists each distinct revision once (reprints collapsed), newest year first, with its original', () => {
    expect(buildCardRevisionRows(cols)).toEqual([
      { assessmentYear: 2025, form: 134, reason: 'Reval/134', asOfDate: '2025-08-21', originalTotalAV: 184100, revisedTotalAV: 93500, cardYear: 2026 },
      { assessmentYear: 2024, form: 134, reason: 'Reval/134', asOfDate: '2024-07-29', originalTotalAV: 123700, revisedTotalAV: 90700, cardYear: 2026 },
    ]);
  });
});

describe('buildCardNoteRows', () => {
  it('collapses repeated printings on NoteKey and orders appeal, permit, other -- newest first', () => {
    const notes = [
      { NoteKey: 'k1', NoteKind: 'other', NoteForm: null, NoteDate: '2020-01-01', NoteCode: 'GEN', NoteText: 'x' },
      { NoteKey: 'k2', NoteKind: 'appeal', NoteForm: 130, NoteDate: '2017-01-30', NoteCode: 'CBTB', NoteText: '2016 CBTB (FORM 130) - ADJ AV' },
      { NoteKey: 'k2', NoteKind: 'appeal', NoteForm: 130, NoteDate: '2017-01-30', NoteCode: 'CBTB', NoteText: '2016 CBTB (FORM 130) - ADJ AV' },
      { NoteKey: 'k3', NoteKind: 'permit', NoteForm: null, NoteDate: '2022-06-01', NoteCode: 'BP', NoteText: 'new roof' },
    ];
    expect(buildCardNoteRows(notes).map((n) => [n.kind, n.printings])).toEqual([['appeal', 2], ['permit', 1], ['other', 1]]);
  });
});
