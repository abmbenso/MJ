import { describe, it, expect } from 'vitest';
import {
  buildPropertySearchAgentContext,
  buildSubClassAssessmentRows,
  resetFiltersForCountyChange,
  DEFAULT_PROPERTY_SEARCH_FILTERS,
} from '../PropertySearch/property-search-agent-context';

/**
 * Task 5 brief: the agent-context side of proposals/multi-county-ci-intake.md §4.3/§6 --
 * the published agent context carries the selected county's identity/tier/DLGF flag, and
 * buildSubClassAssessmentRows' per-parcel rollup goes through pickAssessmentRow (the same
 * precedence rule Task 1 pinned), not a hardcoded 'MarionPRC' comparison.
 */

describe('buildPropertySearchAgentContext -- county fields', () => {
  it('publishes CountyNumber/CountyName/CountySourceTier/HasDlgfRows', () => {
    const context = buildPropertySearchAgentContext({
      filters: { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: 45 },
      rows: [],
      totalMatchingCount: null,
      isTruncated: false,
      viewMode: 'map',
      renderMode: 'point',
      visibleColumns: [],
      selectedParcelAddress: null,
      isLoading: false,
      countyName: 'Lake',
      countySourceTier: 'County PRC',
      hasDlgfRows: false,
    });

    expect(context['CountyNumber']).toBe(45);
    expect(context['CountyName']).toBe('Lake');
    expect(context['CountySourceTier']).toBe('County PRC');
    expect(context['HasDlgfRows']).toBe(false);
  });

  it('carries a DLGF-only county honestly (null card name never masquerades as a county PRC)', () => {
    const context = buildPropertySearchAgentContext({
      filters: { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: 1 },
      rows: [],
      totalMatchingCount: null,
      isTruncated: false,
      viewMode: 'map',
      renderMode: 'point',
      visibleColumns: [],
      selectedParcelAddress: null,
      isLoading: false,
      countyName: 'Adams',
      countySourceTier: 'DLGF only',
      hasDlgfRows: true,
    });

    expect(context['CountyNumber']).toBe(1);
    expect(context['CountyName']).toBe('Adams');
    expect(context['CountySourceTier']).toBe('DLGF only');
    expect(context['HasDlgfRows']).toBe(true);
  });
});

describe('resetFiltersForCountyChange', () => {
  it('clears propertySubClass, sqFtMin, and sqFtMax when switching counties', () => {
    const filters = { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: 49, propertySubClass: 'COM HOTELS-411', sqFtMin: 5000, sqFtMax: 50000 };
    const next = resetFiltersForCountyChange(filters, 45);
    expect(next.countyNumber).toBe(45);
    expect(next.propertySubClass).toBeNull();
    expect(next.sqFtMin).toBeNull();
    expect(next.sqFtMax).toBeNull();
  });

  it('preserves the search term -- the user set it deliberately', () => {
    const filters = { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: 49, searchTerm: 'Acme Corp' };
    const next = resetFiltersForCountyChange(filters, 45);
    expect(next.searchTerm).toBe('Acme Corp');
  });

  it('preserves assessmentYear -- reset separately once the new county\'s own year list loads', () => {
    const filters = { ...DEFAULT_PROPERTY_SEARCH_FILTERS, countyNumber: 49, assessmentYear: 2024 };
    const next = resetFiltersForCountyChange(filters, 45);
    expect(next.assessmentYear).toBe(2024);
  });
});

describe('buildSubClassAssessmentRows -- county-scoped precedence', () => {
  // Same parcel, two Assessment rows: one from Lake's own card source, one from the DLGF
  // statewide fallback. Task 1's pickAssessmentRow guard, at the aggregate level: which one
  // wins depends on WHICH county is rolling up, not on source name alone.
  const carRows: Record<string, unknown>[] = [{ ParcelID: 'p1', PropertySubClassDescription: 'Retail', SqFtSource: null, EstimatedSqFt: null }];
  const assessmentRows: Record<string, unknown>[] = [
    { ParcelID: 'p1', Source: 'LakePRC', OriginalTotalAV: 500000 },
    { ParcelID: 'p1', Source: 'dlgf_gdb_2025', OriginalTotalAV: 300000 },
  ];

  it('at county 45 (Lake), rolls up the LakePRC AV -- LakePRC is Lake\'s own card source', () => {
    const rows = buildSubClassAssessmentRows(carRows, assessmentRows, 45);
    expect(rows).toHaveLength(1);
    expect(rows[0].totalAV).toBe(500000);
  });

  it('at county 49 (Marion), rolls up the DLGF AV -- LakePRC is not Marion\'s own card source, so it never masquerades as Marion card data', () => {
    const rows = buildSubClassAssessmentRows(carRows, assessmentRows, 49);
    expect(rows).toHaveLength(1);
    expect(rows[0].totalAV).toBe(300000);
  });
});
