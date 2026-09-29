import { describe, it, expect } from 'vitest';
import type { RunView, RunViewParams, RunViewResult } from '@memberjunction/core';
import { OwnerProspectsDataAccess } from '../OwnerProspects/owner-prospects-statewide-data';

/**
 * Owner Prospects data access (fix round 2, item 7): the pure query builders, and the loads'
 * cap / error handling over a fake RunView.
 */

type Raw = Record<string, unknown>;

/** A fake RunView answering every query with `rows` (or failing), recording the params. */
function fakeRunView(rows: Raw[] | 'fail'): { rv: RunView; calls: RunViewParams[] } {
  const calls: RunViewParams[] = [];
  const result = <T>(p: RunViewParams): RunViewResult<T> => {
    calls.push(p);
    if (rows === 'fail') return { Success: false, Results: [], ErrorMessage: 'boom' } as unknown as RunViewResult<T>;
    const out = rows.slice(0, p.MaxRows ?? undefined);
    return { Success: true, Results: out as unknown as T[], RowCount: out.length, TotalRowCount: out.length } as RunViewResult<T>;
  };
  const rv = {
    RunView: async <T>(p: RunViewParams): Promise<RunViewResult<T>> => result<T>(p),
    RunViews: async <T>(ps: RunViewParams[]): Promise<RunViewResult<T>[]> => ps.map((p) => result<T>(p)),
  };
  return { rv: rv as unknown as RunView, calls };
}

describe('OwnerProspectsDataAccess — query builders', () => {
  it('RunQuery: latest run of one scope, 2-row tripwire', () => {
    const q = OwnerProspectsDataAccess.RunQuery('Statewide');
    expect(q.EntityName).toBe('Owner Portfolio Runs');
    expect(q.ExtraFilter).toBe("IsLatest = 1 AND Scope = 'Statewide'");
    expect(q.MaxRows).toBe(2);
    expect(q.ResultType).toBe('simple');
  });
  it('PageQuery / SearchQuery: county clause, top 5,001 by AV, the search term escaped', () => {
    const page = OwnerProspectsDataAccess.PageQuery('RUN', 45);
    expect(page.ExtraFilter).toBe(`RunID = 'RUN' AND (PrimaryCountyNumber = 45 OR ByCountyJSON LIKE '%"45":%')`);
    expect(page.OrderBy).toBe('AVCurrent DESC');
    expect(page.MaxRows).toBe(5001);
    const search = OwnerProspectsDataAccess.SearchQuery('RUN', null, "O'Neil_50%");
    expect(search.ExtraFilter).toBe("RunID = 'RUN' AND Label LIKE '%O''Neil[_]50[%]%'");
    expect(search.MaxRows).toBe(5001);
  });
  it('ParcelsQuery: one owner, escaped id, top 5,001 by AV', () => {
    const q = OwnerProspectsDataAccess.ParcelsQuery("ab'c");
    expect(q.ExtraFilter).toBe("OwnerPortfolioID = 'ab''c'");
    expect(q.OrderBy).toBe('AVCurrent DESC');
    expect(q.MaxRows).toBe(5001);
    expect(q.Fields).toContain('IsPlaceholder');
  });
  it('CountyQuery: only the run\'s counties', () => {
    expect(OwnerProspectsDataAccess.CountyQuery([2, 45, 49]).ExtraFilter).toBe('CountyNumber IN (2,45,49)');
  });
  it('MarionQueries: the run\'s owners and their parcels (as before the statewide scope)', () => {
    const [owners, parcels] = OwnerProspectsDataAccess.MarionQueries('M1');
    expect(owners.ExtraFilter).toBe("RunID = 'M1'");
    expect(owners.MaxRows).toBe(20000);
    expect(parcels.ExtraFilter).toBe("OwnerPortfolioID IN (SELECT ID FROM indiana_tax.OwnerPortfolio WHERE RunID = 'M1')");
  });
});

describe('OwnerProspectsDataAccess — loads', () => {
  it('LoadLatestRun: the one run; none → the scope\'s build hint; two → the tripwire error', async () => {
    const one = await new OwnerProspectsDataAccess(fakeRunView([{ ID: 'S1', Scope: 'Statewide', IsLatest: 1 }]).rv).LoadLatestRun('Statewide');
    expect(one.run?.['ID']).toBe('S1');
    const none = await new OwnerProspectsDataAccess(fakeRunView([]).rv).LoadLatestRun('Marion');
    expect(none.error).toBe('No owner-portfolio run has been published yet. Run scripts/build-owner-portfolios.js.');
    const two = await new OwnerProspectsDataAccess(
      fakeRunView([{ ID: 'S1', Scope: 'Statewide', IsLatest: 1 }, { ID: 'S2', Scope: 'Statewide', IsLatest: 1 }]).rv,
    ).LoadLatestRun('Statewide');
    expect(two.error).toMatch(/2 latest Statewide runs/);
  });
  it('LoadOwnersPage: trips the cap at 5,001 rows and keeps 5,000', async () => {
    const rows = Array.from({ length: 6000 }, (_, i) => ({ ID: `o${i}`, Label: `O${i}`, Kind: 'Company', RepStatus: '', PrimaryCountyNumber: 45 }));
    const res = await new OwnerProspectsDataAccess(fakeRunView(rows).rv).LoadOwnersPage('RUN', 45);
    expect(res.ok && res.capHit).toBe(true);
    expect(res.ok && res.rows.length).toBe(5000);
  });
  it('LoadParcels: trips the cap at 5,001 rows; a failed read is an error, never an empty success', async () => {
    const rows = Array.from({ length: 5001 }, (_, i) => ({ ID: `p${i}` }));
    const capped = await new OwnerProspectsDataAccess(fakeRunView(rows).rv).LoadParcels('w');
    expect(capped.ok && capped.capHit).toBe(true);
    expect(capped.ok && capped.parcels.length).toBe(5000);
    const failed = await new OwnerProspectsDataAccess(fakeRunView('fail').rv).LoadParcels('w');
    expect(failed).toEqual({ ok: false, error: 'boom' });
  });
  it('SearchOwners: a failed read is an error', async () => {
    const res = await new OwnerProspectsDataAccess(fakeRunView('fail').rv).SearchOwners('RUN', null, 'acme');
    expect(res).toEqual({ ok: false, error: 'boom' });
  });
});
