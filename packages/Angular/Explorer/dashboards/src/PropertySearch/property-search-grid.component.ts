import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { ColDef, GridApi, GridOptions, GridReadyEvent, ModuleRegistry, AllCommunityModule, Theme, themeAlpine, RowClickedEvent } from 'ag-grid-community';
import {
  MergedParcelRow,
  formatCurrency as formatCurrencyValue,
  pricePerSqFt,
  formatComparisonUnitCount,
  formatYearBuilt,
  RATIO_METRIC_DEFS,
  UNIT_OF_COMPARISON_DEFS,
} from './property-search-agent-context';

// Register AG Grid community modules once (idempotent across grids in the bundle).
ModuleRegistry.registerModules([AllCommunityModule]);

/** AG Grid ValueFormatter wrapper around the shared currency formatter. */
function formatCurrency(params: { value: number | null }): string {
  return formatCurrencyValue(params.value);
}

/** Sq Ft formatter that also surfaces the SqFtSource confidence as a suffix, since the grid has no room for a separate badge column per row. */
function formatSqFt(params: { value: number | null; data?: MergedParcelRow }): string {
  if (params.value == null) return 'Unknown';
  const formatted = params.value.toLocaleString('en-US');
  const source = params.data?.SqFtSource;
  const suffix = source === 'PropertyRecordCard' ? ' ✓' : source === 'BuildingDetail' ? ' ~' : ' ?';
  return `${formatted}${suffix}`;
}

/** AG Grid formatter around the shared pricePerSqFt() -- sqft confidence is already visible in the adjacent Sq Ft column, so this doesn't re-gate on SqFtSource itself. */
function formatPricePerSqFt(params: { data?: MergedParcelRow }): string {
  const v = params.data ? pricePerSqFt(params.data) : null;
  return v == null ? '—' : `${formatCurrencyValue(Math.round(v))}/SF`;
}

/** Tax Rate is stored as dollars per $100 assessed value (e.g. 2.6094) -- numerically identical to a percentage, so displayed as one. */
function formatTaxRate(params: { value: number | null }): string {
  return params.value == null ? '—' : `${params.value.toFixed(4)}%`;
}

/** Plain date formatter for LastSaleDate -- 'date' SQL type comes through RunView('simple') as an ISO string, not a Date instance. */
function formatDate(params: { value: string | null }): string {
  if (!params.value) return '—';
  const d = new Date(params.value);
  return Number.isNaN(d.getTime()) ? '—' : d.toLocaleDateString('en-US');
}

/** Last Sale Price with a validity suffix -- same ✓/~ confidence-marker convention as the Sq Ft column, here signaling whether the county flagged this as an arm's-length market sale. */
function formatLastSalePrice(params: { value: number | null; data?: MergedParcelRow }): string {
  if (params.value == null) return '—';
  const formatted = formatCurrencyValue(params.value);
  const isValid = params.data?.LastSaleIsValid;
  const suffix = isValid === true ? ' ✓' : isValid === false ? ' ~' : '';
  return `${formatted}${suffix}`;
}

/** Year column: the year itself, with the source's confidence folded in as a suffix -- MarionPRC (this project's highest-confidence source) vs. a statewide fallback vs. no data at all for this parcel/year. */
function formatAssessmentYear(params: { value: number | null; data?: MergedParcelRow }): string {
  if (params.value == null) return 'No data';
  return params.data?.AssessmentSource === 'MarionPRC' ? `${params.value} ✓` : String(params.value);
}

/** Own YearBuilt (Tax History Report-sourced) preferred, CoStarYearBuilt shown as an explicitly-marked fallback -- see formatYearBuilt's own doc comment for why the "(CoStar)" suffix matters here specifically. */
function formatYearBuiltCell(params: { data?: MergedParcelRow }): string {
  const v = params.data ? formatYearBuilt(params.data.YearBuilt, params.data.CoStarYearBuilt) : null;
  return v ?? '—';
}

/** Signed percentage for AVYoYPct -- the sign itself is the signal (a drop is not a flag-on-sight case), so it's always shown explicitly rather than relying on a bare "-" prefix reading. */
function formatAVYoYPct(params: { value: number | null }): string {
  if (params.value == null) return '—';
  const sign = params.value > 0 ? '+' : '';
  return `${sign}${params.value.toFixed(1)}%`;
}

/** Row-level cellClassRules for the Recommendation column -- semantic color (good/warning/neutral) so a scan of the list surfaces "Appeal" rows without reading every cell, per this codebase's dashboard UI convention of encoding state in form as well as text. Kept separate from the accent hue used elsewhere in the app. */
const RECOMMENDATION_CELL_CLASS_RULES: NonNullable<ColDef<MergedParcelRow>['cellClassRules']> = {
  'psg-rec-appeal': (p) => p.value === 'Appeal',
  'psg-rec-monitor': (p) => p.value === 'Monitor',
  'psg-rec-no': (p) => p.value === 'No Appeal',
};

/** Flags AVYoYPct past the 5% threshold where IC 6-1.1-15-17.2 shifts the burden of proof to the assessor -- a specific statutory line, not just "a big jump" (see this project's "5% burden-shifting rule" memo). */
const AV_YOY_CELL_CLASS_RULES: NonNullable<ColDef<MergedParcelRow>['cellClassRules']> = {
  'psg-yoy-flag': (p) => typeof p.value === 'number' && p.value > 5,
};

/** One entry in the column registry -- the single source of truth for both AG Grid's ColumnDefs and the host dashboard's "Columns" visibility popover, so the two never drift out of sync. */
export interface PropertySearchColumnConfig {
  /** Matches ColDef.colId (or field name, when colId isn't set explicitly). */
  key: string;
  /** Shown in the Columns popover checkbox list. */
  label: string;
  /** Whether this column is visible out of the box / after a "Reset" -- Land AV, Improvement AV, GIS #, and Tax District start hidden (opt-in) since the default grid didn't show them before this control existed. */
  defaultVisible: boolean;
  /** Always visible, no checkbox -- the row's primary identifier. */
  locked?: boolean;
  /** Groups this column under a subheading in the Columns popover -- see PROPERTY_SEARCH_COLUMN_CATEGORIES for the fixed display order. Unset only for `locked` columns (Address), which never appear in the popover at all. */
  category?: PropertySearchColumnCategory;
  colDef: ColDef<MergedParcelRow>;
}

/** Fixed display order for the Columns popover's category subheadings -- see PropertySearchColumnConfig.category. */
export const PROPERTY_SEARCH_COLUMN_CATEGORIES = ['Property', 'Size & Units', 'Value per Unit', 'Assessment & Taxation', 'Appeals (PTABOA)', 'Appeal Opportunity', 'Sales'] as const;
export type PropertySearchColumnCategory = (typeof PROPERTY_SEARCH_COLUMN_CATEGORIES)[number];

/**
 * Applies this grid's default per-column filter + the shared floating-filter
 * UX to a column config, unless its colDef already opts in/out explicitly
 * (`filter: 'someOtherFilter'` or `filter: false`). Centralized here rather
 * than repeated on every column entry below (~40, including the
 * buildRatioColumns()-generated ones) so every column gets a consistent
 * AG Grid Community filter for free -- a numeric column (`type:
 * 'numericColumn'`) gets agNumberColumnFilter (equals/greater than/less
 * than/in range/blank), everything else gets agTextColumnFilter (contains/
 * equals/starts with/ends with/blank). Both are the built-in filter menu a
 * column's header filter icon already opens in AG Grid Community -- no extra
 * wiring needed for the "choose an operator" dropdown itself. floatingFilter
 * adds the always-visible quick-filter input row under the header (the same
 * UX as the reference Marion Residential Roll artifact); maxNumConditions: 1
 * keeps the popup to a single condition (no AND/OR builder), matching that
 * same reference and this grid's otherwise-simple filtering model.
 */
function withDefaultFilter(config: PropertySearchColumnConfig): PropertySearchColumnConfig {
  const { colDef } = config;
  if (colDef.filter !== undefined) return config;
  const filter = colDef.type === 'numericColumn' ? 'agNumberColumnFilter' : 'agTextColumnFilter';
  return {
    ...config,
    colDef: {
      ...colDef,
      filter,
      floatingFilter: true,
      filterParams: { buttons: ['reset'], maxNumConditions: 1 },
    },
  };
}

/**
 * The raw column list, explicitly typed so every entry below is checked
 * against PropertySearchColumnConfig (category values, ColDef<MergedParcelRow>
 * generics on valueGetter's `p`, etc.) -- kept as its own const rather than
 * inlining the array literal into the exported `.map(withDefaultFilter)` call
 * below, because TypeScript only applies that contextual typing to an array
 * literal assigned directly to a typed variable, not to one passed through
 * `.map()` first (which infers each element's type from itself and widens
 * `category` to `string`, `p` to `any`, etc.).
 */
const PROPERTY_SEARCH_GRID_COLUMNS_BASE: PropertySearchColumnConfig[] = [
  {
    key: 'Address',
    label: 'Address',
    defaultVisible: true,
    locked: true,
    colDef: { field: 'Address', headerName: 'Address', flex: 2, minWidth: 220, tooltipField: 'Address' },
  },
  {
    key: 'ParcelNumber',
    label: 'Parcel #',
    defaultVisible: true,
    category: 'Property',
    colDef: { field: 'ParcelNumber', headerName: 'Parcel #', width: 150 },
  },
  {
    key: 'GISParcelNumber',
    label: 'GIS Parcel #',
    defaultVisible: false,
    category: 'Property',
    colDef: { field: 'GISParcelNumber', headerName: 'GIS Parcel #', width: 130 },
  },
  {
    key: 'OwnerName',
    label: 'Owner',
    defaultVisible: true,
    category: 'Property',
    colDef: { field: 'OwnerName', headerName: 'Owner', flex: 1, minWidth: 180, tooltipField: 'OwnerName' },
  },
  {
    key: 'OwnerEntity',
    label: 'Owner Entity',
    defaultVisible: false,
    category: 'Property',
    colDef: {
      field: 'OwnerEntity',
      headerName: 'Owner Entity',
      flex: 1,
      minWidth: 180,
      tooltipField: 'OwnerEntity',
      headerTooltip: 'The RESOLVED owner (CoStar true owner -> shared mailing address -> cleaned name, from the Owner Prospects rollup) -- e.g. "Eli Lilly & Co." / "Birge & Held ...". Different from the plain "Owner" column, which is the county\'s raw as-recorded string and can vary parcel-to-parcel for one real owner. Blank means this parcel isn\'t in the current Owner Prospects run yet.',
    },
  },
  {
    key: 'PropertySubClassDescription',
    label: 'Property Sub Class',
    defaultVisible: true,
    category: 'Property',
    colDef: { field: 'PropertySubClassDescription', headerName: 'Sub Class', flex: 1, minWidth: 200 },
  },
  {
    key: 'YearBuilt',
    label: 'Year Built',
    defaultVisible: false,
    category: 'Property',
    colDef: {
      colId: 'YearBuilt',
      headerName: 'Year Built',
      width: 120,
      type: 'numericColumn',
      valueGetter: (p) => (p.data ? p.data.YearBuilt ?? p.data.CoStarYearBuilt : null),
      valueFormatter: formatYearBuiltCell,
      headerTooltip: 'Year built. Plain year = from this parcel\'s own Tax History Report. "(CoStar)" = no county-sourced year on file, shown from CoStar property data instead.',
    },
  },
  {
    key: 'Neighborhood',
    label: 'Neighborhood',
    defaultVisible: true,
    category: 'Property',
    colDef: { field: 'Neighborhood', headerName: 'Neighborhood', width: 140 },
  },
  {
    key: 'TaxDistrictID',
    label: 'Tax District',
    defaultVisible: false,
    category: 'Property',
    colDef: { field: 'TaxDistrictID', headerName: 'Tax District', width: 130 },
  },
  {
    key: 'EstimatedSqFt',
    label: 'Building Sq Ft (County)',
    defaultVisible: true,
    category: 'Size & Units',
    colDef: { field: 'EstimatedSqFt', headerName: 'Building Sq Ft (County)', width: 170, type: 'numericColumn', valueFormatter: formatSqFt },
  },
  {
    key: 'EstimatedSqFtExGarage',
    label: 'Building Sq Ft (County XG)',
    defaultVisible: false,
    category: 'Size & Units',
    colDef: {
      field: 'EstimatedSqFtExGarage',
      headerName: 'Building Sq Ft (County XG)',
      width: 185,
      type: 'numericColumn',
      valueFormatter: (p: { value: number | null }) => (p.value == null ? '—' : p.value.toLocaleString('en-US')),
      headerTooltip: 'Building Sq Ft (County) with structured parking removed -- the county codes parking decks as a building floor/use-segment, so the base figure includes them. Equals Building Sq Ft (County) for parcels with no structured parking. This is the SF the rest of the tool uses for $/SF valuation math; the ratio columns "$/SF (County XG)" under "Value per Unit" divide by it.',
    },
  },
  {
    key: 'CoStarRBA',
    label: 'RBA (CoStar)',
    defaultVisible: false,
    category: 'Size & Units',
    colDef: {
      field: 'CoStarRBA',
      headerName: 'RBA (CoStar)',
      width: 140,
      type: 'numericColumn',
      valueFormatter: (p: { value: number | null }) => (p.value == null ? '—' : p.value.toLocaleString('en-US')),
      headerTooltip: 'Rentable Building Area, sourced from CoStar property data -- a DIFFERENT physical measurement than Building Sq Ft (County) (total building SF), not just a different source for the same number. Empty for most parcels -- only single-parcel properties with an unambiguous CoStar match are backfilled.',
    },
  },
  {
    key: 'UnitsRooms',
    label: 'Units/Rooms (CoStar)',
    defaultVisible: false,
    category: 'Size & Units',
    colDef: {
      colId: 'UnitsRooms',
      headerName: 'Units/Rooms',
      width: 130,
      valueGetter: (p) => (p.data ? (formatComparisonUnitCount(p.data.ComparisonUnitType, p.data.ComparisonUnitCount) ?? '—') : '—'),
      headerTooltip: 'Apartment unit / hotel key count, sourced entirely from CoStar property data (not county assessor records) -- "No data" for most parcels, since only single-parcel properties with an unambiguous CoStar match are backfilled.',
    },
  },
  {
    key: 'pricePerSqFt',
    label: '$/SF (County)',
    defaultVisible: true,
    category: 'Value per Unit',
    colDef: {
      colId: 'pricePerSqFt',
      headerName: '$/SF (County)',
      width: 150,
      type: 'numericColumn',
      valueGetter: (p) => (p.data ? pricePerSqFt(p.data) : null),
      valueFormatter: formatPricePerSqFt,
    },
  },
  {
    key: 'AssessedLandAV',
    label: 'Land Value',
    defaultVisible: false,
    category: 'Assessment & Taxation',
    colDef: { field: 'AssessedLandAV', headerName: 'Land Value', width: 140, type: 'numericColumn', valueFormatter: formatCurrency },
  },
  {
    key: 'AssessedImprovementAV',
    label: 'Improvement Value',
    defaultVisible: false,
    category: 'Assessment & Taxation',
    colDef: { field: 'AssessedImprovementAV', headerName: 'Improvement Value', width: 160, type: 'numericColumn', valueFormatter: formatCurrency },
  },
  {
    key: 'AssessedTotalAV',
    label: 'Total Value',
    defaultVisible: true,
    category: 'Assessment & Taxation',
    colDef: { field: 'AssessedTotalAV', headerName: 'Total Value', width: 150, type: 'numericColumn', valueFormatter: formatCurrency, sort: 'desc' },
  },
  {
    key: 'AssessmentYear',
    label: 'Assessment Year',
    defaultVisible: true,
    category: 'Assessment & Taxation',
    colDef: {
      field: 'AssessmentYear',
      headerName: 'Year',
      width: 110,
      type: 'numericColumn',
      valueFormatter: formatAssessmentYear,
      headerTooltip: 'Assessment year shown. ✓ = MarionPRC-verified (highest confidence); no checkmark = statewide fallback source; "No data" = not yet available for this parcel/year.',
    },
  },
  {
    key: 'TotalTax',
    label: 'Total Tax',
    defaultVisible: false,
    category: 'Assessment & Taxation',
    colDef: {
      field: 'TotalTax',
      headerName: 'Total Tax',
      width: 140,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: 'Net annual tax liability for the selected assessment year, from the Tax History Report. "No data" (—) when this parcel has no Tax History Report for that year yet.',
    },
  },
  {
    key: 'TaxRate',
    label: 'Tax Rate',
    defaultVisible: false,
    category: 'Assessment & Taxation',
    colDef: {
      field: 'TaxRate',
      headerName: 'Tax Rate',
      width: 120,
      type: 'numericColumn',
      valueFormatter: formatTaxRate,
      headerTooltip: 'Tax rate for the selected assessment year (per $100 of assessed value), from the Tax History Report.',
    },
  },
  {
    key: 'PTABOAValue',
    label: 'PTABOA Value',
    defaultVisible: false,
    category: 'Appeals (PTABOA)',
    colDef: {
      field: 'PTABOAValue',
      headerName: 'PTABOA Value',
      width: 150,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: 'Assessed value after a PTABOA appeal decision, for the selected assessment year. "No data" (—) means no appeal has been decided for this parcel in that year -- true for most parcels/years.',
    },
  },
  {
    key: 'PTABOADate',
    label: 'PTABOA Date',
    defaultVisible: false,
    category: 'Appeals (PTABOA)',
    colDef: {
      field: 'PTABOADate',
      headerName: 'PTABOA Date',
      width: 130,
      valueFormatter: formatDate,
      headerTooltip: 'Hearing date of the appeal that produced the PTABOA Value shown for this parcel/year.',
    },
  },
  {
    key: 'PTABOAAppealType',
    label: 'Appeal Type',
    defaultVisible: false,
    category: 'Appeals (PTABOA)',
    colDef: {
      field: 'PTABOAAppealType',
      headerName: 'Appeal Type',
      width: 120,
      headerTooltip: '"130S" = subjective/market-value appeal (the most directly informative type for assessed-value accuracy). "130O" = objective/mathematical-error appeal. "136"/"136C" = charitable/nonprofit Exemption request -- NOT a valuation dispute. From the same appeal as PTABOA Value/Date, for the selected assessment year.',
    },
  },
  {
    key: 'TaxRep',
    label: 'Rep',
    defaultVisible: false,
    category: 'Appeals (PTABOA)',
    colDef: {
      field: 'TaxRep',
      headerName: 'Rep',
      width: 160,
      tooltipField: 'TaxRep',
      // No cell renderer/badge here deliberately -- "empty" itself IS the
      // signal (a fresh, unrepresented prospect), so a blank cell needs no
      // decoration; adding one would visually compete with the "flag good
      // opportunities" columns below rather than support them.
      headerTooltip: 'The tax representative on record for THIS parcel specifically (inferred from a past PTABOA reduction, indiana_tax.OwnerPortfolioParcel.ExistingRep). Blank = no rep on record for this parcel -- a fresh-prospect signal. NOT the same as the owner’s portfolio-wide rep status -- a different parcel the same owner holds can carry a rep while this one doesn’t.',
    },
  },
  // ── Appeal Opportunity: the valuation engine's own triage signals for THIS
  // parcel, from the same Owner Prospects rollup as Owner Entity/Rep above.
  // Grouped as their own category (not folded into Appeals (PTABOA), which is
  // historical appeal record, not a forward-looking recommendation) so a user
  // can turn on just the opportunity-scoring columns without wading through
  // PTABOA history fields they don't need for triage.
  {
    key: 'Recommendation',
    label: 'Recommendation',
    defaultVisible: false,
    category: 'Appeal Opportunity',
    colDef: {
      field: 'Recommendation',
      headerName: 'Recommendation',
      width: 130,
      cellClassRules: RECOMMENDATION_CELL_CLASS_RULES,
      headerTooltip: "The valuation engine's own verdict for this parcel -- Appeal / Monitor / No Appeal (indiana_tax.OwnerPortfolioParcel.Recommendation). Blank means this parcel isn't in the current Owner Prospects run yet, not that the engine looked and found nothing.",
    },
  },
  {
    key: 'ConfidenceTier',
    label: 'Confidence',
    defaultVisible: false,
    category: 'Appeal Opportunity',
    colDef: {
      field: 'ConfidenceTier',
      headerName: 'Confidence',
      width: 110,
      headerTooltip: 'How strongly the engine backs Recommendation -- High / Medium / Low. Pair with Recommendation = Appeal to find the strongest cases first.',
    },
  },
  {
    key: 'SupportingApproachCount',
    label: 'Supporting Approaches',
    defaultVisible: false,
    category: 'Appeal Opportunity',
    colDef: {
      field: 'SupportingApproachCount',
      headerName: 'Approaches',
      width: 110,
      type: 'numericColumn',
      headerTooltip: 'Count of independent valuation approaches (sales comparison / income / cost) corroborating the recommendation. 2+ is a strong, multi-method case; 0 is typical for a "No Appeal" row, not a data gap.',
    },
  },
  {
    key: 'EstSavingsAtAsk',
    label: 'Est. Savings (Ask)',
    defaultVisible: false,
    category: 'Appeal Opportunity',
    colDef: {
      field: 'EstSavingsAtAsk',
      headerName: 'Est. Savings',
      width: 130,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: "Estimated annual tax dollars at stake if appealed to the engine's \"ask\" value (indiana_tax.OwnerPortfolioParcel.EstSavingsAtAsk). Sort descending to find the biggest-dollar opportunities first.",
    },
  },
  {
    key: 'AVYoYPct',
    label: 'AV YoY %',
    defaultVisible: false,
    category: 'Appeal Opportunity',
    colDef: {
      field: 'AVYoYPct',
      headerName: 'AV YoY %',
      width: 110,
      type: 'numericColumn',
      valueFormatter: formatAVYoYPct,
      cellClassRules: AV_YOY_CELL_CLASS_RULES,
      headerTooltip: "Year-over-year change in this parcel's assessed value. Highlighted past +5% -- the threshold where IC 6-1.1-15-17.2 shifts the burden of proof to the assessor, not just an arbitrary \"big jump.\"",
    },
  },
  {
    key: 'LastSaleDate',
    label: 'Last Sale Date',
    defaultVisible: false,
    category: 'Sales',
    colDef: {
      field: 'LastSaleDate',
      headerName: 'Last Sale Date',
      width: 130,
      valueFormatter: formatDate,
      headerTooltip: 'Most recent recorded sale for this parcel, from indiana_tax.CountyAssessorSaleHistory. "No data" (—) means no sale is on record yet (most commonly: not yet PRC-fetched).',
    },
  },
  {
    key: 'LastSalePrice',
    label: 'Last Sale Price',
    defaultVisible: false,
    category: 'Sales',
    colDef: {
      field: 'LastSalePrice',
      headerName: 'Last Sale Price',
      width: 150,
      type: 'numericColumn',
      valueFormatter: formatLastSalePrice,
      headerTooltip: 'Most recent recorded sale amount. ✓ = county-flagged arm\'s-length/market sale; ~ = flagged non-arm\'s-length (e.g. related-party transfer, corrective deed) -- still shown since it may still be informative, but weigh it accordingly.',
    },
  },
  ...buildRatioColumns(),
];

/** Single source of truth for every column this grid can show. Exported so the host dashboard can build its Columns popover from the same list. */
export const PROPERTY_SEARCH_GRID_COLUMNS: PropertySearchColumnConfig[] = PROPERTY_SEARCH_GRID_COLUMNS_BASE.map(withDefaultFilter);

/**
 * Generates every {RATIO_METRIC_DEFS} / {UNIT_OF_COMPARISON_DEFS} combination
 * as its own column, EXCEPT Assessed Value / SF (County) -- that one already
 * exists as the hand-written 'pricePerSqFt' column above (kept as its own
 * entry so its `key` never changes, protecting anyone's already-persisted
 * VisibleColumnKeys). All generated columns start hidden (`defaultVisible:
 * false`) and live under the 'Value per Unit' category, same as the
 * hand-written $/SF (County) -- so a user comparing "$/unit across
 * Assessment, PTABOA, and Sale Price" finds every combination grouped
 * together, sortable independently, rather than scattered across the raw
 * dollar-figure categories.
 */
function buildRatioColumns(): PropertySearchColumnConfig[] {
  const columns: PropertySearchColumnConfig[] = [];
  for (const metric of RATIO_METRIC_DEFS) {
    for (const unit of UNIT_OF_COMPARISON_DEFS) {
      if (metric.key === 'AssessedValue' && unit.key === 'SFCounty') continue;
      const key = `${metric.key}Per${unit.key}`;
      const shortUnitSuffix = unit.label.split(' ')[0]; // 'SF (County)' -> 'SF', 'RBA (CoStar)' -> 'RBA', etc.
      columns.push({
        key,
        label: `${metric.fullLabel} / ${unit.label}`,
        defaultVisible: false,
        category: 'Value per Unit',
        colDef: {
          colId: key,
          headerName: `${metric.shortLabel}/${unit.label}`,
          width: 175,
          type: 'numericColumn',
          valueGetter: (p) => {
            if (!p.data) return null;
            const denom = unit.denominator(p.data);
            const num = metric.numerator(p.data);
            return denom == null || num == null ? null : num / denom;
          },
          valueFormatter: (p: { value: number | null }) => (p.value == null ? '—' : `${formatCurrencyValue(Math.round(p.value))}/${shortUnitSuffix}`),
          headerTooltip: `${metric.fullLabel} divided by ${unit.label} -- "—" when this parcel is missing either figure (most rows, for the CoStar-sourced units).`,
        },
      });
    }
  }
  return columns;
}

export const PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS: string[] = PROPERTY_SEARCH_GRID_COLUMNS.filter((c) => c.defaultVisible).map((c) => c.key);

/**
 * Thin, reusable AG Grid listing of the current Property Search result set —
 * the "list view" alternative to the map, sortable/resizable, feeding the
 * Export dialog wired in the host dashboard. Read-only: selecting a row
 * bubbles (RowClicked) up to the host, which owns the detail panel and
 * NavigationService (this component owns neither, matching the established
 * convention for these thin grid wrappers — see ClassifyItemGridComponent).
 *
 * Column visibility is host-driven (VisibleColumnKeys) rather than AG Grid's
 * own Columns tool panel, which is an Enterprise-only feature -- this repo
 * only has ag-grid-community. Per-column filtering (the header filter icon's
 * operator menu -- contains/equals/starts with for text, equals/greater
 * than/less than/in range for numbers -- plus an always-visible
 * floating-filter input row) IS a Community feature and is on for every
 * column via withDefaultFilter() above, sourced automatically from
 * PROPERTY_SEARCH_GRID_COLUMNS' colDef.type -- no per-column opt-in needed.
 */
@Component({
  standalone: false,
  selector: 'mj-property-search-grid',
  templateUrl: './property-search-grid.component.html',
  styleUrls: ['./property-search-grid.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PropertySearchGridComponent {
  // Setter (not a plain field) so new search results reach an already-ready
  // grid, not just the grid's initial render -- matches this codebase's
  // input-change convention (setters over ngOnChanges).
  @Input()
  set Rows(value: MergedParcelRow[]) {
    this._rows = value ?? [];
    this.gridApi?.setGridOption('rowData', this._rows);
  }
  get Rows(): MergedParcelRow[] {
    return this._rows;
  }
  private _rows: MergedParcelRow[] = [];

  @Input()
  set VisibleColumnKeys(value: Set<string>) {
    this._visibleColumnKeys = value ?? new Set(PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS);
    this.applyColumnVisibility();
  }
  get VisibleColumnKeys(): Set<string> {
    return this._visibleColumnKeys;
  }
  private _visibleColumnKeys: Set<string> = new Set(PROPERTY_SEARCH_DEFAULT_VISIBLE_COLUMNS);

  private gridApi: GridApi<MergedParcelRow> | null = null;

  @Output() RowClicked = new EventEmitter<MergedParcelRow>();
  /**
   * The grid's own row count AFTER its column filters (and sort/rowData
   * changes) are applied -- fired from GridOptions.onModelUpdated below,
   * which AG Grid calls after filtering, sorting, or a rowData swap. The host
   * dashboard uses this to keep its header parcel-count badge honest once a
   * user narrows the List view with a column filter -- without it, that badge
   * would keep showing the full (pre-filter) search result count, silently
   * out of sync with what's actually on screen.
   */
  @Output() FilteredRowCountChanged = new EventEmitter<number>();

  public Theme: Theme = themeAlpine.withParams({
    backgroundColor: 'var(--mj-bg-surface)',
    foregroundColor: 'var(--mj-text-primary)',
    textColor: 'var(--mj-text-primary)',
    borderColor: 'var(--mj-border-default)',
    chromeBackgroundColor: 'var(--mj-bg-surface-card)',
    headerBackgroundColor: 'var(--mj-bg-surface-card)',
    headerTextColor: 'var(--mj-text-secondary)',
    cellTextColor: 'var(--mj-text-primary)',
    subtleTextColor: 'var(--mj-text-muted)',
    dataBackgroundColor: 'var(--mj-bg-surface)',
    oddRowBackgroundColor: 'var(--mj-bg-surface-card)',
    rowHoverColor: 'var(--mj-bg-surface-hover, color-mix(in srgb, var(--mj-brand-primary) 5%, var(--mj-bg-surface)))',
    selectedRowBackgroundColor: 'color-mix(in srgb, var(--mj-brand-primary) 10%, var(--mj-bg-surface))',
    accentColor: 'var(--mj-brand-primary)',
    borderRadius: 'var(--mj-radius-sm)',
    browserColorScheme: 'inherit',
  });

  public GridOptions: GridOptions<MergedParcelRow> = {
    animateRows: true,
    rowHeight: 36,
    headerHeight: 40,
    suppressCellFocus: true,
    enableCellTextSelection: true,
    suppressNoRowsOverlay: true,
    // Covers filter, sort, AND rowData changes in one callback -- a plain
    // onFilterChanged would miss the case where a NEW search result set
    // arrives while an existing column filter is still active (AG Grid
    // re-applies the retained filter model to the new rowData and this still
    // fires with the correct re-filtered count).
    onModelUpdated: () => this.emitFilteredRowCount(),
  };

  public DefaultColDef: ColDef = {
    sortable: true,
    resizable: true,
    minWidth: 90,
  };

  /** Initial column defs -- hide computed from the default visibility set; live toggling after grid-ready goes through applyColumnVisibility()/gridApi instead of rebuilding this array. */
  public ColumnDefs: ColDef<MergedParcelRow>[] = PROPERTY_SEARCH_GRID_COLUMNS.map((c) => ({
    ...c.colDef,
    hide: !this.VisibleColumnKeys.has(c.key),
  }));

  public OnGridReady(event: GridReadyEvent<MergedParcelRow>): void {
    this.gridApi = event.api;
    this.gridApi.setGridOption('rowData', this._rows);
    this.applyColumnVisibility();
    // Belt-and-suspenders alongside onModelUpdated -- reports the correct
    // count immediately on first render rather than waiting on that event to
    // fire for this initial rowData set.
    this.emitFilteredRowCount();
  }

  public OnRowClicked(event: RowClickedEvent<MergedParcelRow>): void {
    if (event.data) this.RowClicked.emit(event.data);
  }

  private emitFilteredRowCount(): void {
    if (this.gridApi) this.FilteredRowCountChanged.emit(this.gridApi.getDisplayedRowCount());
  }

  private applyColumnVisibility(): void {
    if (!this.gridApi) return;
    for (const c of PROPERTY_SEARCH_GRID_COLUMNS) {
      this.gridApi.setColumnsVisible([c.key], c.locked || this._visibleColumnKeys.has(c.key));
    }
  }
}
