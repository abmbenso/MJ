import { describe, it, expect } from 'vitest';
import {
  EMPTY_OUTCOME_LAYERS, reduceCurrentOutcomes, applyOutcomeLayers, buildAppealOutcomeRows,
} from '../PropertySearch/property-search-outcomes';

/**
 * The Appeal Outcomes read (indiana_tax.vwAppealOutcomes, one IsCurrent row per parcel-year-level)
 * feeding the grid's PTABOA / IBTR columns and the detail panel's Appeal History. Row shapes are
 * the view's own columns as RunView ResultType 'simple' returns them: uppercase GUIDs, DecidedAt a
 * 'YYYY-MM-DD' string, bits as booleans.
 */
const PTABOA_ID = '6F1C2A40-0000-4000-8000-000000000001';
const county = (over: Record<string, unknown> = {}) => ({
  ID: 'O-1', ParcelID: 'P1', AssessmentYear: 2023, Level: 'County-PTABOA', Kind: 'Valuation', Certainty: 'Ratified',
  OriginalTotalAV: 2_450_000, DeterminedTotalAV: 1_980_000, DecidedAt: '2024-03-14', CaseNumber: '49-800-23-0-4-00123',
  DispositionText: null, SourceDocumentID: 'D-115', PTABOAAppealID: PTABOA_ID, IBTRAppealID: null, CardValuationColumnID: null,
  IsCurrent: true, Agenda115Differs: false, ...over,
});
const ptaboa = [{ ID: PTABOA_ID.toLowerCase(), AppealType: '130S' }];

describe('reduceCurrentOutcomes', () => {
  it('a ratified County valuation -> PTABOA Value = the determined total, certainty Ratified, date = DecidedAt, type from the linked appeal', () => {
    expect(reduceCurrentOutcomes([county()], ptaboa).get('P1')).toEqual({
      ...EMPTY_OUTCOME_LAYERS,
      PTABOAValue: 1_980_000, PTABOADate: '2024-03-14', PTABOAAppealType: '130S', PTABOACertainty: 'Ratified', PTABOAOutcomeKind: 'Valuation',
    });
  });
  it('a provisional County valuation -> certainty Provisional and PTABOA Value = the recommended (agenda) value', () => {
    const out = reduceCurrentOutcomes([county({ Certainty: 'Provisional', DeterminedTotalAV: 2_100_000, SourceDocumentID: null })], ptaboa).get('P1');
    expect(out).toMatchObject({ PTABOACertainty: 'Provisional', PTABOAValue: 2_100_000, PTABOAOutcomeKind: 'Valuation' });
  });
  it('an Exemption or Withdrawal carries its date and certainty but no value -- it is not a valuation', () => {
    for (const Kind of ['Exemption', 'Withdrawal']) {
      const out = reduceCurrentOutcomes([county({ Kind, DeterminedTotalAV: null })], ptaboa).get('P1');
      expect(out).toMatchObject({ PTABOAValue: null, PTABOADate: '2024-03-14', PTABOACertainty: 'Ratified', PTABOAOutcomeKind: Kind });
    }
  });
  it('never shows a value for a non-valuation kind even if the row carried one', () => {
    expect(reduceCurrentOutcomes([county({ Kind: 'Withdrawal', DeterminedTotalAV: 5 })], ptaboa).get('P1')?.PTABOAValue).toBeNull();
  });
  it('a card-revision County outcome has no linked PTABOA appeal -> Appeal Type blank, the value still shows', () => {
    const out = reduceCurrentOutcomes([county({ PTABOAAppealID: null, CardValuationColumnID: 'C-1', CaseNumber: null })], ptaboa).get('P1');
    expect(out).toMatchObject({ PTABOAValue: 1_980_000, PTABOAAppealType: null, PTABOACertainty: 'Ratified' });
  });
  it('a State valuation -> IBTR Value (this year); the County columns stay blank when there is no County row', () => {
    const state = county({ ID: 'O-2', Level: 'State-IBTR', DeterminedTotalAV: 1_750_000, PTABOAAppealID: null, IBTRAppealID: 'I-1' });
    expect(reduceCurrentOutcomes([state], ptaboa).get('P1')).toEqual({ ...EMPTY_OUTCOME_LAYERS, IBTRYearValue: 1_750_000 });
  });
  it('a State disposition sets no value', () => {
    const disp = county({ Level: 'State-IBTR', Kind: 'Disposition', Certainty: 'Disposition', DeterminedTotalAV: null, PTABOAAppealID: null, IBTRAppealID: 'I-1', DispositionText: 'Dismissal' });
    expect(reduceCurrentOutcomes([disp], ptaboa).get('P1')).toEqual(EMPTY_OUTCOME_LAYERS);
  });
  it('County and State rows for one parcel land on the same entry', () => {
    const state = county({ ID: 'O-2', Level: 'State-IBTR', DeterminedTotalAV: 1_750_000, PTABOAAppealID: null, IBTRAppealID: 'I-1' });
    expect(reduceCurrentOutcomes([county(), state], ptaboa).get('P1')).toMatchObject({ PTABOAValue: 1_980_000, IBTRYearValue: 1_750_000 });
  });
  it('keeps DecidedAt as the stored calendar day -- a DATE column serialized at UTC midnight must not drift a day', () => {
    expect(reduceCurrentOutcomes([county({ DecidedAt: '2025-08-01T00:00:00.000Z' })], ptaboa).get('P1')?.PTABOADate).toBe('2025-08-01');
    expect(reduceCurrentOutcomes([county({ DecidedAt: new Date('2025-12-01T00:00:00.000Z') })], ptaboa).get('P1')?.PTABOADate).toBe('2025-12-01');
  });
  it('ignores a non-current row defensively (the query asks for IsCurrent = 1 only)', () => {
    expect(reduceCurrentOutcomes([county({ IsCurrent: false })], ptaboa).has('P1')).toBe(false);
  });
});

describe('applyOutcomeLayers', () => {
  it('a parcel with no outcome keeps nulls -- unchanged behaviour for the ~99% of rows never appealed', () => {
    const rows = [{ ParcelID: 'P1', ...EMPTY_OUTCOME_LAYERS }, { ParcelID: 'P2', ...EMPTY_OUTCOME_LAYERS }];
    const out = applyOutcomeLayers(rows, reduceCurrentOutcomes([county()], ptaboa));
    expect(out[0]).toMatchObject({ PTABOAValue: 1_980_000, PTABOACertainty: 'Ratified' });
    expect(out[1]).toMatchObject({ PTABOAValue: null, PTABOADate: null, PTABOAAppealType: null, PTABOACertainty: null, PTABOAOutcomeKind: null, IBTRYearValue: null });
  });
});

describe('buildAppealOutcomeRows', () => {
  const urls = new Map([['d-115', 'https://example.test/115.pdf']]);
  it('lists every outcome -- newest assessment year first, then newest decision -- with its source and document link', () => {
    const rows = buildAppealOutcomeRows([
      county({ ID: 'a', AssessmentYear: 2022, DecidedAt: '2023-02-01', SourceDocumentID: null, Certainty: 'Provisional', IsCurrent: true }),
      county({ ID: 'b', IsCurrent: false, Certainty: 'Provisional', DecidedAt: '2023-12-01', SourceDocumentID: null, DeterminedTotalAV: 2_000_000 }),
      county({ ID: 'c' }),
      county({ ID: 'd', Level: 'State-IBTR', Kind: 'Disposition', Certainty: 'Disposition', DeterminedTotalAV: null, OriginalTotalAV: null,
        PTABOAAppealID: null, IBTRAppealID: 'I-1', DispositionText: 'Settlement - withdrawal', DecidedAt: '2025-06-30', SourceDocumentID: null }),
    ], urls);
    expect(rows.map((r) => r.id)).toEqual(['d', 'c', 'b', 'a']);
    expect(rows[1]).toEqual({
      id: 'c', assessmentYear: 2023, level: 'County', kind: 'Valuation', certainty: 'Ratified', originalTotalAV: 2_450_000,
      determinedTotalAV: 1_980_000, decidedAt: '2024-03-14', caseNumber: '49-800-23-0-4-00123', dispositionText: null,
      source: 'PTABOA', documentURL: 'https://example.test/115.pdf', isCurrent: true, agenda115Differs: false,
    });
    expect(rows[0]).toMatchObject({ level: 'State', certainty: 'Disposition', source: 'IBTR', dispositionText: 'Settlement - withdrawal', documentURL: null });
  });
  it('names a card-revision outcome as such', () => {
    expect(buildAppealOutcomeRows([county({ PTABOAAppealID: null, CardValuationColumnID: 'C-1' })], urls)[0].source).toBe('Record card');
  });
});
