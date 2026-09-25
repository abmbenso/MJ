/**
 * @fileoverview Building facts in the List View that do NOT come from a county record card:
 *
 * 1. CoStar (indiana_tax.CoStarProperty, entity `Co Star Properties`) -- read directly for the
 *    page's parcels on BOTH data paths, so a DLGF-only row (no CountyAssessorRecord to carry the
 *    backfilled copies) shows its CoStar RBA / units / keys too. The rule is the one
 *    Indiana_Tax_Expert/scripts/backfill-costar-derived-fields.js applies to the assessor-record
 *    copies (kept for the comps engine and ParcelPhysicalProfile): single-parcel listings only,
 *    and one distinct value per field or nothing. The two copies of this rule are recorded in
 *    _framework/DATA_FLOW_REGISTER.md (CoStar_Data row) -- change them together.
 * 2. The DLGF state file (DLGF Improvements / DLGF Buildings) -- year built and building square
 *    feet for DLGF-only rows. It is a county-reported figure and always outranks CoStar: the
 *    CoStar year is only a marked fallback into an otherwise empty Year Built cell
 *    (formatYearBuilt), never an override.
 *
 * CoStar never reaches an assessed-value column or the headline (Data Source Kind 'Commercial').
 * Pure and framework-free except the two fetchers.
 *
 * 🚨 SAFETY: read-only. Nothing here writes.
 */

import { RunView } from '@memberjunction/core';
import { escapeSqlLiteral } from './property-search-agent-context';
import { rowsOrThrow } from './property-search-appeal-layers';

type Row = Record<string, unknown>;

export const COSTAR_ENTITY = 'Co Star Properties';
export const DLGF_IMPROVEMENTS_ENTITY = 'DLGF Improvements';
export const DLGF_BUILDINGS_ENTITY = 'DLGF Buildings';

/**
 * CoStarProperty held 14,212 rows statewide on 2026-09-25, and a parcel can carry up to 21
 * single-parcel listings. Reasoned from the table, not from a per-parcel guess -- the same
 * reasoning the sale-history read documents. rowsOrThrow turns a truncated read into a banner.
 */
export const COSTAR_LAYER_MAX_ROWS = 30000;
/** Measured 2026-09-25 on full 5,000-parcel pages: up to 29,863 improvements and 10,375 buildings (Marion). */
export const DLGF_IMPROVEMENT_MAX_ROWS = 60000;
export const DLGF_BUILDING_MAX_ROWS = 30000;

export const COSTAR_LAYER_FIELDS = ['ParcelID', 'CoStarIsMultiParcel', 'CoStarRBA', 'CoStarYearBuilt', 'CoStarNumberOfUnits', 'CoStarRooms'] as const;

export interface CoStarLayerFields {
  CoStarRBA: number | null;
  CoStarYearBuilt: number | null;
  ComparisonUnitType: string | null;
  ComparisonUnitCount: number | null;
}

export const EMPTY_COSTAR_LAYER: CoStarLayerFields = { CoStarRBA: null, CoStarYearBuilt: null, ComparisonUnitType: null, ComparisonUnitCount: null };

export interface DlgfBuildingFacts {
  YearBuilt: number | null;
  EstimatedSqFt: number | null;
  SqFtSource: 'DLGF' | null;
}

const key = (id: unknown): string => String(id ?? '').toUpperCase();
const numOrNull = (v: unknown): number | null => (v == null || v === '' || !Number.isFinite(Number(v)) ? null : Number(v));

/** The one value every listing agrees on, or null when none carries it or two disagree. */
function soleValue<T>(values: (T | null)[]): T | null {
  const distinct = [...new Set(values.filter((v): v is T => v != null))];
  return distinct.length === 1 ? distinct[0] : null;
}

function unitPair(r: Row): string | null {
  const units = numOrNull(r['CoStarNumberOfUnits']);
  const rooms = numOrNull(r['CoStarRooms']);
  if (units != null && units > 0) return `Unit:${units}`;
  if (rooms != null && rooms > 0) return `Key:${rooms}`;
  return null;
}

function reduceParcel(listings: Row[]): CoStarLayerFields {
  const pair = soleValue(listings.map(unitPair));
  const [type, count] = pair ? pair.split(':') : [null, null];
  return {
    CoStarRBA: soleValue(listings.map((r) => numOrNull(r['CoStarRBA']))),
    CoStarYearBuilt: soleValue(listings.map((r) => numOrNull(r['CoStarYearBuilt']))),
    ComparisonUnitType: type,
    ComparisonUnitCount: count == null ? null : Number(count),
  };
}

/** Parcel ID (upper-case) -> the CoStar figures the grid shows for it. Multi-parcel listings are dropped. */
export function reduceCoStarLayers(rows: Row[]): Map<string, CoStarLayerFields> {
  const byParcel = new Map<string, Row[]>();
  for (const r of rows) {
    if (!r['ParcelID'] || r['CoStarIsMultiParcel'] === true || r['CoStarIsMultiParcel'] === 1) continue;
    const k = key(r['ParcelID']);
    (byParcel.get(k) ?? byParcel.set(k, []).get(k)!).push(r);
  }
  const out = new Map<string, CoStarLayerFields>();
  for (const [k, listings] of byParcel) out.set(k, reduceParcel(listings));
  return out;
}

/** The direct read wins over any stored copy; a parcel with no single-parcel listing shows none. */
export function applyCoStarLayers<T extends { ParcelID: string } & CoStarLayerFields>(rows: T[], layers: Map<string, CoStarLayerFields>): T[] {
  return rows.map((r) => ({ ...r, ...(layers.get(key(r.ParcelID)) ?? EMPTY_COSTAR_LAYER) }));
}

/** A four-digit construction year no later than next year; the state file also carries '0' and blanks. */
function constructionYear(v: unknown): number | null {
  const s = String(v ?? '').trim();
  if (!/^\d{4}$/.test(s)) return null;
  const y = Number(s);
  return y >= 1800 && y <= new Date().getFullYear() + 1 ? y : null;
}

/**
 * Parcel ID (upper-case) -> year built (the largest improvement's own year) and building square
 * feet (the sum of the parcel's buildings) from the DLGF state file.
 */
export function reduceDlgfBuildingFacts(improvements: Row[], buildings: Row[]): Map<string, DlgfBuildingFacts> {
  const out = new Map<string, DlgfBuildingFacts>();
  const get = (k: string): DlgfBuildingFacts => out.get(k) ?? out.set(k, { YearBuilt: null, EstimatedSqFt: null, SqFtSource: null }).get(k)!;
  const largest = new Map<string, number>();
  for (const i of improvements) {
    const year = constructionYear(i['YearConstructed']);
    if (year == null) continue;
    const k = key(i['ParcelID']);
    const size = numOrNull(i['ImprovementSize']) ?? 0;
    if (!largest.has(k) || size > largest.get(k)!) {
      largest.set(k, size);
      get(k).YearBuilt = year;
    }
  }
  for (const b of buildings) {
    const sqft = numOrNull(b['TotalSquareFootArea']);
    if (sqft == null || sqft <= 0) continue;
    const f = get(key(b['ParcelID']));
    f.EstimatedSqFt = (f.EstimatedSqFt ?? 0) + sqft;
    f.SqFtSource = 'DLGF';
  }
  return out;
}

const inList = (ids: string[]): string => ids.map((id) => `'${escapeSqlLiteral(id)}'`).join(',');

/** The page's single-parcel CoStar listings. Throws on failure or truncation (the caller shows a banner). */
export async function fetchCoStarLayers(rv: RunView, parcelIds: string[]): Promise<Map<string, CoStarLayerFields>> {
  if (!parcelIds.length) return new Map();
  const r = await rv.RunView<Row>({
    EntityName: COSTAR_ENTITY,
    Fields: [...COSTAR_LAYER_FIELDS],
    ExtraFilter: `ParcelID IN (${inList(parcelIds)}) AND CoStarIsMultiParcel = 0`,
    MaxRows: COSTAR_LAYER_MAX_ROWS,
    ResultType: 'simple',
  });
  return reduceCoStarLayers(rowsOrThrow(COSTAR_ENTITY, r, COSTAR_LAYER_MAX_ROWS));
}

/** Year built and square feet from the DLGF state file for DLGF-only rows. Throws on failure or truncation. */
export async function fetchDlgfBuildingFacts(rv: RunView, parcelIds: string[]): Promise<Map<string, DlgfBuildingFacts>> {
  if (!parcelIds.length) return new Map();
  const filter = `ParcelID IN (${inList(parcelIds)})`;
  const [imp, bld] = await rv.RunViews<Row>([
    { EntityName: DLGF_IMPROVEMENTS_ENTITY, Fields: ['ParcelID', 'YearConstructed', 'ImprovementSize'], ExtraFilter: filter, MaxRows: DLGF_IMPROVEMENT_MAX_ROWS, ResultType: 'simple' },
    { EntityName: DLGF_BUILDINGS_ENTITY, Fields: ['ParcelID', 'TotalSquareFootArea'], ExtraFilter: filter, MaxRows: DLGF_BUILDING_MAX_ROWS, ResultType: 'simple' },
  ]);
  return reduceDlgfBuildingFacts(
    rowsOrThrow(DLGF_IMPROVEMENTS_ENTITY, imp, DLGF_IMPROVEMENT_MAX_ROWS),
    rowsOrThrow(DLGF_BUILDINGS_ENTITY, bld, DLGF_BUILDING_MAX_ROWS),
  );
}

/** Fills the DLGF-only rows' Year Built and Building Sq Ft from the state file; card rows are left alone. */
export function applyDlgfBuildingFacts<T extends { ParcelID: string; CountyAssessorRecordID: string | null; YearBuilt: number | null; EstimatedSqFt: number | null; SqFtSource: string | null }>(
  rows: T[],
  facts: Map<string, DlgfBuildingFacts>,
): T[] {
  return rows.map((r) => {
    if (r.CountyAssessorRecordID) return r;
    const f = facts.get(key(r.ParcelID));
    return f ? { ...r, YearBuilt: f.YearBuilt, EstimatedSqFt: f.EstimatedSqFt, SqFtSource: f.SqFtSource } : r;
  });
}

