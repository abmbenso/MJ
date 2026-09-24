import { describe, it, expect, vi } from 'vitest';

/**
 * Round-1 fix regression test (finding 8): the VerifyLink column's AG Grid `cellRenderer`
 * returns a raw HTML string (not a DOM node), so an unescaped VerifyURL interpolated into an
 * `href` attribute would let a hostile value break out of the attribute and inject markup.
 * Mock Angular so importing the component file doesn't pull the runtime -- same pattern as
 * database-preview-pane.test.ts.
 */
vi.mock('@angular/core', () => ({
  Component: () => (target: Function) => target,
  Input: () => () => {},
  Output: () => () => {},
  EventEmitter: class {
    emit() {}
  },
  ChangeDetectionStrategy: { OnPush: 1 },
}));

import { PROPERTY_SEARCH_GRID_COLUMNS } from '../PropertySearch/property-search-grid.component';

function verifyLinkRenderer(): (p: { value: string | null }) => string {
  const col = PROPERTY_SEARCH_GRID_COLUMNS.find((c) => c.key === 'VerifyLink');
  if (!col) throw new Error('VerifyLink column not found');
  return col.colDef.cellRenderer as (p: { value: string | null }) => string;
}

describe('VerifyLink cellRenderer', () => {
  it('renders a normal URL as a link', () => {
    const html = verifyLinkRenderer()({ value: 'https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf' });
    expect(html).toBe(
      '<a href="https://engageblob.blob.core.windows.net/lake/pdf/2025/45-07-06-207-002.000-023.pdf" target="_blank" rel="noopener noreferrer">Card ↗</a>'
    );
  });

  it('escapes a hostile value so it cannot break out of the href attribute or inject markup', () => {
    const hostile = '"><script>alert(1)</script>';
    const html = verifyLinkRenderer()({ value: hostile });
    expect(html).not.toContain('<script>');
    expect(html).not.toContain('"><');
    expect(html).toContain('&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;');
  });

  it('renders "not on file" for a null value', () => {
    expect(verifyLinkRenderer()({ value: null })).toBe('not on file');
  });
});

describe('appeal-layer columns (spec §12)', () => {
  const expected: Record<string, string> = {
    CardAppealForm: 'Appeals (Card)', CardOriginalAV: 'Appeals (Card)', CardRevisedAV: 'Appeals (Card)', CardAppealDate: 'Appeals (Card)',
    IBTRDecisionDate: 'Appeals (IBTR)', IBTRAssessmentYear: 'Appeals (IBTR)', IBTRDisposition: 'Appeals (IBTR)', IBTRValue: 'Appeals (IBTR)', IBTRDecisionCount: 'Appeals (IBTR)',
    TaxCourtDecision: 'Appeals (Tax Court)',
  };
  it('defines every layer column, in its category, hidden by default, with a tooltip', () => {
    for (const [key, category] of Object.entries(expected)) {
      const col = PROPERTY_SEARCH_GRID_COLUMNS.find((c) => c.key === key);
      expect(col, key).toBeDefined();
      expect(col!.category).toBe(category);
      expect(col!.defaultVisible).toBe(false);
      expect(col!.colDef.field).toBe(key);
      expect(String(col!.colDef.headerTooltip ?? '').length).toBeGreaterThan(40);
    }
  });
});

describe('appeal-outcome columns', () => {
  const find = (key: string) => PROPERTY_SEARCH_GRID_COLUMNS.find((c) => c.key === key);
  it('adds the certainty pill to Appeals (PTABOA), the year-scoped IBTR value and the later-appeal badge', () => {
    expect(find('PTABOACertainty')?.category).toBe('Appeals (PTABOA)');
    expect(find('IBTRYearValue')?.category).toBe('Appeals (IBTR)');
    expect(find('HasLaterAppeal')?.category).toBe('Appeals (IBTR)');
  });
  it('renders the certainty as a pill, blank when there is no County outcome', () => {
    const render = find('PTABOACertainty')!.colDef.cellRenderer as (p: { value: string | null }) => string;
    expect(render({ value: 'Ratified' })).toBe('<span class="psg-pill psg-pill-ratified">Ratified</span>');
    expect(render({ value: 'Provisional' })).toBe('<span class="psg-pill psg-pill-provisional">Provisional</span>');
    expect(render({ value: null })).toBe('');
  });
  it('says Withdrawn / Exemption in the PTABOA Value cell rather than a bare dash', () => {
    const fmt = find('PTABOAValue')!.colDef.valueFormatter as (p: { value: number | null; data?: { PTABOAOutcomeKind: string | null } }) => string;
    expect(fmt({ value: null, data: { PTABOAOutcomeKind: 'Withdrawal' } })).toBe('Withdrawn');
    expect(fmt({ value: null, data: { PTABOAOutcomeKind: 'Exemption' } })).toBe('Exemption');
    expect(fmt({ value: null, data: { PTABOAOutcomeKind: null } })).toBe('—');
    expect(fmt({ value: 1_980_000, data: { PTABOAOutcomeKind: 'Valuation' } })).toContain('1,980,000');
  });
  it('shows a date-only PTABOA Date as that calendar day in any time zone (never the day before)', () => {
    const fmt = find('PTABOADate')!.colDef.valueFormatter as (p: { value: string | null }) => string;
    expect(fmt({ value: '2025-08-01' })).toBe('8/1/2025');
    expect(fmt({ value: null })).toBe('—');
  });
  it('badges HasLaterAppeal with the text as its tooltip, and sorts true first on a descending sort', () => {
    const col = find('HasLaterAppeal')!;
    const render = col.colDef.cellRenderer as (p: { value: boolean | null }) => string;
    expect(render({ value: true })).toContain('psg-pill-later');
    expect(render({ value: false })).toBe('');
    expect(col.colDef.tooltipField).toBe('LaterAppealText');
  });
});
