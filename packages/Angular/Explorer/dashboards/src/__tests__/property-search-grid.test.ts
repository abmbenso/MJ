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
