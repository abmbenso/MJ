/**
 * Pure helpers for the Income page's editable pro forma: parsing a typed edit back into an
 * AssumptionRow (applyEdit) and rendering a row's stored value back into the input (displayValue).
 * Kept Angular-free (imports only `../analysis-store` types) so they can be unit-tested under
 * Vitest's node preset without pulling in `@angular/core` — see analysis-income.test.ts.
 */
import { AssumptionRow } from '../analysis-store';

export const PCT_MODES = new Set(['pct', 'rate', 'pctPGI', 'pctEGI']);

/** Inverse of applyEdit's percent scaling: a stored decimal (0.0775) renders as the percent (7.75). */
export function displayValue(row: AssumptionRow): string {
  if (row.Value == null) return '';
  if (row.Mode === 'flag') return row.Value === 1 ? 'yes' : 'no';
  if (PCT_MODES.has(row.Mode)) return String(Math.round(row.Value * 1_000_000) / 10_000);
  return String(row.Value);
}

/**
 * Parses `raw` per the row's Mode (pct/rate/pctPGI/pctEGI typed as a percent e.g. 7.75 → 0.0775;
 * flag as yes/no/1/0; money/count strip $ and commas; empty → null) and, if the parsed value
 * differs from the row's current Value, returns an updated row set with that row marked
 * Source: 'Analyst' and a SourceRef noting what it overrode. An unknown key, an unparseable
 * entry, or an entry equal to the current value returns `changed: null` and the rows unchanged.
 */
export function applyEdit(rows: AssumptionRow[], key: string, raw: string): { rows: AssumptionRow[]; changed: AssumptionRow | null } {
  const idx = rows.findIndex((r) => r.AssumptionKey === key);
  if (idx < 0) return { rows, changed: null };
  const row = rows[idx];
  const text = raw.trim().toLowerCase();
  let value: number | null;
  if (text === '') value = null;
  else if (row.Mode === 'flag') {
    if (['yes', 'y', '1', 'true'].includes(text)) value = 1;
    else if (['no', 'n', '0', 'false'].includes(text)) value = 0;
    else return { rows, changed: null };
  } else {
    const n = Number(text.replace(/[$,%\s]/g, ''));
    if (!Number.isFinite(n)) return { rows, changed: null };
    value = PCT_MODES.has(row.Mode) ? Math.round(n * 10_000) / 1_000_000 : n;
  }
  if (value === row.Value) return { rows, changed: null };
  const changed: AssumptionRow = {
    ...row,
    Value: value,
    Source: 'Analyst',
    SourceRef: `Analyst override of ${row.ProposedSource ?? row.Source}${row.ProposedValue != null ? ` ${row.ProposedValue}` : ''}`,
  };
  const next = [...rows];
  next[idx] = changed;
  return { rows: next, changed };
}
