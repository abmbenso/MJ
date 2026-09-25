import { describe, it, expect } from 'vitest';
import {
  reduceCoStarLayers,
  applyCoStarLayers,
  reduceDlgfBuildingFacts,
  COSTAR_LAYER_MAX_ROWS,
  EMPTY_COSTAR_LAYER,
} from '../PropertySearch/property-search-costar';
import { formatYearBuilt, PROPERTY_SEARCH_RESULT_CAP } from '../PropertySearch/property-search-agent-context';

/**
 * CoStar in the List View, read from indiana_tax.CoStarProperty for the page's parcels on BOTH data
 * paths (card and DLGF-only), with the same rule the assessor-record backfill
 * (Indiana_Tax_Expert/scripts/backfill-costar-derived-fields.js) applies: single-parcel listings
 * only, and one distinct value per field or nothing. Fixtures are shaped like the real rows
 * (uppercase GUIDs, booleans, a parcel with several listings).
 */
const P1 = 'AAAAAAAA-0000-0000-0000-000000000001';
const P2 = 'AAAAAAAA-0000-0000-0000-000000000002';
const row = (o: Record<string, unknown>) => ({ ParcelID: P1, CoStarIsMultiParcel: false, CoStarRBA: null, CoStarYearBuilt: null, CoStarNumberOfUnits: null, CoStarRooms: null, ...o });

describe('reduceCoStarLayers', () => {
  it('one single-parcel listing gives its RBA, year and units', () => {
    const m = reduceCoStarLayers([row({ CoStarRBA: 164466, CoStarYearBuilt: 1996, CoStarNumberOfUnits: 120 })]);
    expect(m.get(P1)).toEqual({ CoStarRBA: 164466, CoStarYearBuilt: 1996, ComparisonUnitType: 'Unit', ComparisonUnitCount: 120 });
  });
  it('rooms become a Key count', () => {
    expect(reduceCoStarLayers([row({ CoStarRooms: 94 })]).get(P1)).toMatchObject({ ComparisonUnitType: 'Key', ComparisonUnitCount: 94 });
  });
  it('several listings that agree give the value; listings that disagree give nothing for that field only', () => {
    const m = reduceCoStarLayers([
      row({ CoStarRBA: 86000, CoStarYearBuilt: 1982 }),
      row({ CoStarRBA: 88564, CoStarYearBuilt: 1982 }),
    ]);
    expect(m.get(P1)).toEqual({ CoStarRBA: null, CoStarYearBuilt: 1982, ComparisonUnitType: null, ComparisonUnitCount: null });
  });
  it('a listing with units and another with rooms is ambiguous', () => {
    const m = reduceCoStarLayers([row({ CoStarNumberOfUnits: 96 }), row({ CoStarRooms: 94 })]);
    expect(m.get(P1)).toMatchObject({ ComparisonUnitType: null, ComparisonUnitCount: null });
  });
  it('a null on one listing does not contradict a value on another', () => {
    expect(reduceCoStarLayers([row({ CoStarRBA: 50000 }), row({ CoStarRBA: null })]).get(P1)?.CoStarRBA).toBe(50000);
  });
  it('multi-parcel listings never feed a per-parcel figure', () => {
    const m = reduceCoStarLayers([row({ CoStarIsMultiParcel: true, CoStarRBA: 900000 }), row({ ParcelID: P2, CoStarRBA: 40000 })]);
    expect(m.has(P1)).toBe(false);
    expect(m.get(P2)?.CoStarRBA).toBe(40000);
  });
  it('matches parcels case-insensitively', () => {
    expect(reduceCoStarLayers([row({ ParcelID: P1.toLowerCase(), CoStarRBA: 1 })]).get(P1)?.CoStarRBA).toBe(1);
  });
});

describe('applyCoStarLayers', () => {
  const base = { ParcelID: P1, CoStarRBA: 5 as number | null, CoStarYearBuilt: 2001 as number | null, ComparisonUnitType: 'Unit' as string | null, ComparisonUnitCount: 3 as number | null, YearBuilt: 1990 as number | null };
  it('overwrites the stored copies with the direct read, and clears them when the parcel has no listing', () => {
    const layers = reduceCoStarLayers([row({ CoStarRBA: 7 })]);
    expect(applyCoStarLayers([base], layers)[0]).toMatchObject({ CoStarRBA: 7, CoStarYearBuilt: null, ComparisonUnitType: null });
    expect(applyCoStarLayers([{ ...base, ParcelID: P2 }], layers)[0]).toMatchObject(EMPTY_COSTAR_LAYER);
  });
  it('never touches the county year built', () => {
    expect(applyCoStarLayers([base], new Map())[0].YearBuilt).toBe(1990);
  });
  it('the cap is reasoned from the table, not the page: at least 2 rows per parcel on a full page', () => {
    expect(COSTAR_LAYER_MAX_ROWS).toBeGreaterThanOrEqual(PROPERTY_SEARCH_RESULT_CAP * 2);
  });
});

describe('reduceDlgfBuildingFacts (the state file, ahead of any CoStar fallback)', () => {
  const imp = (o: Record<string, unknown>) => ({ ParcelID: P1, YearConstructed: null, ImprovementSize: null, ...o });
  const bld = (o: Record<string, unknown>) => ({ ParcelID: P1, TotalSquareFootArea: null, ...o });
  it('year built is the largest improvement\'s year; square feet is the sum of the buildings', () => {
    const m = reduceDlgfBuildingFacts(
      [imp({ YearConstructed: '1970', ImprovementSize: 2000 }), imp({ YearConstructed: '1998', ImprovementSize: 150000 })],
      [bld({ TotalSquareFootArea: 150000 }), bld({ TotalSquareFootArea: 2000 })],
    );
    expect(m.get(P1)).toEqual({ YearBuilt: 1998, EstimatedSqFt: 152000, SqFtSource: 'DLGF' });
  });
  it('ignores years that are not plausible construction years', () => {
    const m = reduceDlgfBuildingFacts([imp({ YearConstructed: '0', ImprovementSize: 9 }), imp({ YearConstructed: 'ABCD', ImprovementSize: 8 }), imp({ YearConstructed: '1955', ImprovementSize: 1 })], []);
    expect(m.get(P1)?.YearBuilt).toBe(1955);
  });
  it('no usable year and no square feet leaves both null, never zero', () => {
    const m = reduceDlgfBuildingFacts([imp({ YearConstructed: '', ImprovementSize: 10 })], [bld({ TotalSquareFootArea: 0 })]);
    expect(m.get(P1) ?? { YearBuilt: null, EstimatedSqFt: null }).toMatchObject({ YearBuilt: null, EstimatedSqFt: null });
  });
  it('a state-file year keeps the CoStar year out of the cell', () => {
    const facts = reduceDlgfBuildingFacts([imp({ YearConstructed: '1988', ImprovementSize: 5 })], []);
    expect(formatYearBuilt(facts.get(P1)?.YearBuilt ?? null, 2004)).toBe('1988');
    expect(formatYearBuilt(null, 2004)).toBe('2004 (CoStar)');
  });
});
