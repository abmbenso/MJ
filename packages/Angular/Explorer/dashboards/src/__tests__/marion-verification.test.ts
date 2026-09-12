import { describe, it, expect } from 'vitest';
import {
  prcUrl,
  taxHistoryUrl,
  buildVerificationLinks,
} from '../TaxBudgetProjection/marion-verification';

/**
 * Verification is the point: a projection nobody can check is an assertion. These links
 * must reach the county's own document for the parcel on screen, and must say plainly
 * whether we hold a retrieved copy or the reader has to go and look.
 */
describe('document URLs', () => {
  it('matches the endpoints the other project artifacts already use', () => {
    expect(prcUrl('9003241')).toBe(
      'https://maps.indy.gov/AssessorPropertyCards.Reports.Service/ReportPage.aspx?ParcelNumber=9003241',
    );
    expect(taxHistoryUrl('9003241')).toBe(
      'https://maps.indy.gov/AssessorPropertyCards.Reports.Service/TaxHistoryReportPage.aspx?ParcelNumber=9003241',
    );
  });

  it('encodes the parcel number rather than pasting it into the query string', () => {
    expect(prcUrl('90 03&241')).toContain('90%2003%26241');
  });
});

describe('buildVerificationLinks', () => {
  it('offers BOTH documents even when we hold neither copy', () => {
    // The link is deterministic from the parcel number, so it works for any Marion parcel
    // -- including one we have never harvested. Withholding it would leave the reader with
    // no route to check at all, which is the opposite of the point.
    const links = buildVerificationLinks('9003241', {});
    expect(links.map((l) => l.kind)).toEqual(['prc', 'taxHistory']);
    expect(links.every((l) => l.url.includes('9003241'))).toBe(true);
  });

  it('says when a copy was retrieved, so the reader can judge its vintage', () => {
    const links = buildVerificationLinks('9003241', { prc: new Date('2026-08-29T03:25:01Z') });
    const prc = links.find((l) => l.kind === 'prc')!;
    expect(prc.retrievedAt).not.toBeNull();
    expect(prc.note).toContain('2026-08-29');
    expect(prc.onFile).toBe(true);
  });

  it('says plainly when nothing is on file, rather than implying we cited something', () => {
    const links = buildVerificationLinks('9003241', { prc: new Date('2026-08-29T03:25:01Z') });
    const th = links.find((l) => l.kind === 'taxHistory')!;
    expect(th.retrievedAt).toBeNull();
    expect(th.onFile).toBe(false);
    expect(th.note).toMatch(/not on file/i);
  });

  it('returns nothing without a parcel number — never a link to nowhere', () => {
    expect(buildVerificationLinks('', { prc: new Date() })).toEqual([]);
    expect(buildVerificationLinks('   ', {})).toEqual([]);
  });

  it('labels each document the way the county names it', () => {
    const links = buildVerificationLinks('9003241', {});
    expect(links.find((l) => l.kind === 'prc')!.label).toBe('Property Record Card');
    expect(links.find((l) => l.kind === 'taxHistory')!.label).toBe('Tax History');
  });
});
