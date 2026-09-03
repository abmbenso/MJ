import { describe, it, expect } from 'vitest';
import { normalizeOwnerKey, ownerKeyFromRow } from '../OwnerProspects/owner-key';

/**
 * Parity fixtures for the OwnerKey normalizer — must match
 * `Indiana_Tax_Expert/scripts/lib/owner-key.js` exactly. Node preset (lives in
 * `__tests__/`); pure, no Angular / MJ.
 */
describe('normalizeOwnerKey', () => {
  it('strips trailing legal-form tokens repeatedly, keeps >= 1 token', () => {
    expect(normalizeOwnerKey('ACME HOLDINGS LLC LP')).toBe('acme holdings');
  });

  it('never strips a lone legal-form token to empty', () => {
    expect(normalizeOwnerKey('LLC')).toBe('llc');
  });

  it('expands & to " and " and drops a lone trailing "and"', () => {
    expect(normalizeOwnerKey('Eli Lilly & Co')).toBe('eli lilly');
  });

  it('keeps descriptive words (realty / group / properties)', () => {
    expect(normalizeOwnerKey('Keystone Realty Group, LLC')).toBe('keystone realty group');
  });
});

describe('ownerKeyFromRow', () => {
  it('prefers coStarTrueOwner over label', () => {
    expect(ownerKeyFromRow({ coStarTrueOwner: 'J.C. Hart Company, Inc.', label: 'PENROSE ON MASS LLC' })).toBe('j c hart');
  });

  it('falls back to label when coStarTrueOwner is null', () => {
    expect(ownerKeyFromRow({ coStarTrueOwner: null, label: 'Keystone Realty Group, LLC' })).toBe('keystone realty group');
  });
});
