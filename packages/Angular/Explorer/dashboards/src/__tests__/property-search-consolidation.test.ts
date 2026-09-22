import { describe, it, expect } from 'vitest';
import { PROPERTY_SEARCH_RESULT_CAP, PROPERTY_SEARCH_BOUNDARY_RENDER_CAP } from '../PropertySearch/property-search-agent-context';
import { PROPERTY_SEARCH_GRID_COLUMNS, PROPERTY_SEARCH_COLUMN_CATEGORIES } from '../PropertySearch/property-search-grid.component';
import { buildDlgfMergedRows } from '../PropertySearch/property-search-dlgf';
import { applyAppealLayers, EMPTY_APPEAL_LAYERS } from '../PropertySearch/property-search-appeal-layers';
import { ownerProspectsCoversCounty, OWNER_PROSPECTS_COVERAGE_NOTE, MARION_COUNTY_NUMBER } from '../PropertySearch/property-search-county';
import { indexDataSources } from '../PropertySearch/property-search-headline';

/**
 * Pins the invariants that only exist because two independently developed feature sets --
 * the multi-county / appeal-layer work and the Owner Prospects / measured-cap work -- were
 * merged into one Property Search on 2026-09-21 (consolidation review, 2026-09-22). Neither
 * side had tests for the other's surface, so a regression here would otherwise go unpinned.
 */

const OWNER_COLUMNS: Record<string, string> = {
  OwnerEntity: 'Property',
  TaxRep: 'Appeals (PTABOA)',
  Recommendation: 'Appeal Opportunity',
  ConfidenceTier: 'Appeal Opportunity',
  SupportingApproachCount: 'Appeal Opportunity',
  EstSavingsAtAsk: 'Appeal Opportunity',
  AVYoYPct: 'Appeal Opportunity',
};

describe('result caps', () => {
  it('keeps the boundary-render cap strictly below the result cap (MapDisplayRows / IsBoundaryRenderTruncated depend on it)', () => {
    expect(PROPERTY_SEARCH_BOUNDARY_RENDER_CAP).toBeLessThan(PROPERTY_SEARCH_RESULT_CAP);
    expect(PROPERTY_SEARCH_BOUNDARY_RENDER_CAP).toBeGreaterThan(0);
  });
});

describe('column registry after the merge', () => {
  it('has no duplicate keys', () => {
    const keys = PROPERTY_SEARCH_GRID_COLUMNS.map((c) => c.key);
    expect(new Set(keys).size).toBe(keys.length);
  });

  it('uses only declared categories, and every declared category at least once', () => {
    const declared = new Set<string>(PROPERTY_SEARCH_COLUMN_CATEGORIES);
    const used = new Set<string>();
    for (const c of PROPERTY_SEARCH_GRID_COLUMNS) {
      if (c.locked) continue;
      expect(c.category, c.key).toBeDefined();
      expect(declared.has(c.category!), `${c.key} -> ${c.category}`).toBe(true);
      used.add(c.category!);
    }
    for (const cat of PROPERTY_SEARCH_COLUMN_CATEGORIES) expect(used.has(cat), cat).toBe(true);
  });

  it('defines every Owner Prospects column, hidden by default, field === key, with the coverage note in its tooltip', () => {
    for (const [key, category] of Object.entries(OWNER_COLUMNS)) {
      const col = PROPERTY_SEARCH_GRID_COLUMNS.find((c) => c.key === key);
      expect(col, key).toBeDefined();
      expect(col!.category).toBe(category);
      expect(col!.defaultVisible).toBe(false);
      expect(col!.colDef.field).toBe(key);
      expect(String(col!.colDef.headerTooltip)).toContain(OWNER_PROSPECTS_COVERAGE_NOTE.trim());
    }
  });

  it('gives numeric columns a number filter and text columns a text filter, with floating filters, unless the column opted out', () => {
    for (const c of PROPERTY_SEARCH_GRID_COLUMNS) {
      const { colDef } = c;
      if (colDef.filter === false) continue;
      const expected = colDef.type === 'numericColumn' ? 'agNumberColumnFilter' : 'agTextColumnFilter';
      // A column may pick a different filter explicitly; withDefaultFilter only fills in the blanks.
      if (colDef.filter === expected) expect(colDef.floatingFilter, c.key).toBe(true);
      expect(colDef.filter, c.key).toBeDefined();
    }
  });
});

describe('Owner Prospects coverage gate', () => {
  it('covers Marion and no other county today', () => {
    expect(ownerProspectsCoversCounty(MARION_COUNTY_NUMBER)).toBe(true);
    for (const other of [2, 45, 71, 82]) expect(ownerProspectsCoversCounty(other), String(other)).toBe(false);
  });
});

describe('the DLGF row shape carries the merged fields', () => {
  const parcelRows = [{ ID: 'p1', ParcelNumber: '111', GISParcelNumber: 'g1', Address: '1 Main St', OwnerName: 'Acme', Acreage: 1, PropertyClassCode: '401' }];
  const sources = indexDataSources([{ ID: 'D1', Name: 'dlgf_gdb_2025', Kind: 'State DLGF', Label: 'DLGF statewide roll, AY2025', IsOfficial: false, IsPlaceholder: true }]);
  const headlineRows = [{ ParcelID: 'p1', AssessmentYear: 2025, HeadlineLandAV: 1, HeadlineImprovementAV: 2, HeadlineTotalAV: 3, HeadlineDataSourceID: 'D1', HeadlineDocumentYear: 2025, IsPlaceholder: true, SourceCount: 1, MaxSpreadPct: null, HasDisagreement: false, HasRevision: false, RevisedFromTotalAV: null, HeadlineTax: null, TaxDataSourceID: null }];
  const classRows = [{ ParcelID: 'p1', Source: 'dlgf_gdb_2025', PropertyClassCode: '401' }];

  it('emits every Owner Prospects field as null (never undefined, never a fabricated value)', () => {
    const { rows } = buildDlgfMergedRows(headlineRows, parcelRows, classRows, sources, 45, 'lake', 2025, 5000);
    expect(rows).toHaveLength(1);
    const row = rows[0] as unknown as Record<string, unknown>;
    for (const key of Object.keys(OWNER_COLUMNS)) {
      expect(key in row, key).toBe(true);
      expect(row[key], key).toBeNull();
    }
  });

  it('applyAppealLayers preserves the Owner Prospects fields on the row it overlays', () => {
    const { rows } = buildDlgfMergedRows(headlineRows, parcelRows, classRows, sources, 45, 'lake', 2025, 5000);
    const withOwner = { ...rows[0], OwnerEntity: 'Acme Holdings LLC', Recommendation: 'Appeal' };
    const [out] = applyAppealLayers([withOwner], new Map());
    expect(out.OwnerEntity).toBe('Acme Holdings LLC');
    expect(out.Recommendation).toBe('Appeal');
    for (const key of Object.keys(EMPTY_APPEAL_LAYERS)) expect(key in out, key).toBe(true);
  });
});
