/**
 * Owner Prospects — the OwnerKey normalizer.
 *
 * A literal TypeScript port of `Indiana_Tax_Expert/scripts/lib/owner-key.js` —
 * the single normalizer for `indiana_tax.Prospect.OwnerKey`, the stable join key
 * that re-links a flagged prospect back to the Owner Prospects screen across
 * portfolio re-runs. Prefers the CoStar true-owner name, falls back to the raw
 * label. Lowercased, legal-form suffixes and punctuation stripped, whitespace
 * collapsed.
 *
 * Only true legal-form tokens are stripped (LLC / LP / INC / CORP / CO / TRUST /
 * ...), NOT descriptive words like "realty" / "group" / "properties" — those
 * distinguish otherwise-similar names and must be kept.
 *
 * MUST stay byte-for-byte consistent with the Node original — import from here,
 * never re-implement. Angular-free / MJ-free on purpose.
 */

const SUFFIX_RE = /[\s]+(l l c|l l p|l p|llc|llp|lllp|lp|inc|incorporated|corp|corporation|co|company|trust|ltd|limited|partnership|plc|pllc)$/;

/**
 * Normalize an owner name into its stable OwnerKey.
 *
 * Lowercase → `&`→` and ` → `._,/`→space → strip any remaining non-alphanumerics
 * → collapse whitespace → repeatedly strip a trailing legal-form token (keeping
 * at least one token) → drop a lone trailing `" and"` left by e.g. `Eli Lilly & Co`.
 */
export function normalizeOwnerKey(input: string): string {
  let s = String(input ?? '')
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[._,/]/g, ' ')
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  // strip trailing legal-form tokens repeatedly (e.g. "... llc lp"), keep >= 1 token
  let prev: string;
  do {
    prev = s;
    const stripped = s.replace(SUFFIX_RE, '').trim();
    if (stripped && stripped !== s) {
      s = stripped;
    }
  } while (s !== prev);
  // a lone trailing "and" left by e.g. "Eli Lilly & Co"
  return s.replace(/\s+and$/, '').trim();
}

/**
 * The OwnerKey for an Owner Prospects row: the normalized CoStar true-owner name,
 * falling back to the raw label. Mirrors `ownerKey(owner)` in the Node original
 * for an `owners.json` owner object.
 */
export function ownerKeyFromRow(row: { coStarTrueOwner: string | null; label: string }): string {
  return normalizeOwnerKey(row.coStarTrueOwner || row.label || '');
}
