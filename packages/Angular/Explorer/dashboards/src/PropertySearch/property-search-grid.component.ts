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

/** Minimal HTML escaper for the VerifyLink cellRenderer below -- AG Grid's cellRenderer here returns
 * a raw HTML string (not a DOM node/component), so an unescaped VerifyURL interpolated into an
 * href attribute would let a hostile value break out of the attribute and inject markup. VerifyURL
 * is always tool-built today (buildVerifyLink/prcUrl/xsoftCardUrl), but escaping here is defense in
 * depth against any future source of that value. */
function escapeHtmlAttribute(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
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

/** Year column: the year itself, with the source's confidence folded in as a suffix -- a county's own record card (this project's highest-confidence source) vs. a statewide/FOIA fallback vs. no data at all for this parcel/year. */
function formatAssessmentYear(params: { value: number | null; data?: MergedParcelRow }): string {
  if (params.value == null) return 'No data';
  return params.data?.DataSource === 'County record card' ? `${params.value} ✓` : String(params.value);
}

/** Own YearBuilt (Tax History Report-sourced) preferred, CoStarYearBuilt shown as an explicitly-marked fallback -- see formatYearBuilt's own doc comment for why the "(CoStar)" suffix matters here specifically. */
function formatYearBuiltCell(params: { data?: MergedParcelRow }): string {
  const v = params.data ? formatYearBuilt(params.data.YearBuilt, params.data.CoStarYearBuilt) : null;
  return v ?? '—';
}

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
export const PROPERTY_SEARCH_COLUMN_CATEGORIES = ['Property', 'Size & Units', 'Value per Unit', 'Assessment & Taxation', 'Appeals (PTABOA)', 'Appeals (Card)', 'Appeals (IBTR)', 'Appeals (Tax Court)', 'Sales'] as const;
export type PropertySearchColumnCategory = (typeof PROPERTY_SEARCH_COLUMN_CATEGORIES)[number];

/** Single source of truth for every column this grid can show. Exported so the host dashboard can build its Columns popover from the same list. */
export const PROPERTY_SEARCH_GRID_COLUMNS: PropertySearchColumnConfig[] = [
  {
    key: 'Address',
    label: 'Address',
    defaultVisible: true,
    locked: true,
    colDef: { field: 'Address', headerName: 'Address', flex: 2, minWidth: 220, tooltipField: 'Address' },
  },
  {
    key: 'DataSource',
    label: 'Source',
    defaultVisible: true,
    locked: true,
    colDef: {
      field: 'DataSource',
      headerName: 'Source',
      width: 170,
      headerTooltip: 'Where this row’s assessed values came from. "County record card" = the county’s own PRC (highest confidence). "County FOIA list" = a county-provided list. "DLGF statewide file" = the state’s AY2025 file, as initially determined — not the county’s card.',
    },
  },
  {
    key: 'VerifyLink',
    label: 'Verify',
    defaultVisible: true,
    locked: true,
    colDef: {
      colId: 'VerifyLink',
      headerName: 'Verify',
      width: 110,
      sortable: false,
      valueGetter: (p) => (p.data ? (p.data.VerifyURL ?? null) : null),
      cellRenderer: (p: { value: string | null }) =>
        p.value ? `<a href="${escapeHtmlAttribute(p.value)}" target="_blank" rel="noopener noreferrer">Card ↗</a>` : 'not on file',
      headerTooltip: 'Opens the county’s own record card for this parcel. "not on file" = no link can be built from the parcel number for this county — verify at the county.',
    },
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
      headerTooltip: 'Assessment year shown. ✓ = from the county\'s own record card (highest confidence); no checkmark = a statewide/FOIA fallback source — see the Source column; "No data" = nothing on file for this parcel/year.',
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
    key: 'CardAppealForm',
    label: 'Card Appeal Form',
    defaultVisible: false,
    category: 'Appeals (Card)',
    colDef: {
      field: 'CardAppealForm',
      headerName: 'Card Appeal Form',
      width: 140,
      type: 'numericColumn',
      headerTooltip: 'The form behind the revision the county printed on its own record card for the selected assessment year: 130 (taxpayer appeal), 134 (informal settlement), 115 (PTABOA determination), 133 (correction of error), 113, 131. Blank means the card shows no revision for that year. County-card counties only.',
    },
  },
  {
    key: 'CardOriginalAV',
    label: 'Card Original AV',
    defaultVisible: false,
    category: 'Appeals (Card)',
    colDef: {
      field: 'CardOriginalAV',
      headerName: 'Card Original AV',
      width: 150,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: 'Total assessed value as first certified for the selected year, read from the record card -- the figure the revision replaced. Shown only when the card also prints a revision for that year.',
    },
  },
  {
    key: 'CardRevisedAV',
    label: 'Card Revised AV',
    defaultVisible: false,
    category: 'Appeals (Card)',
    colDef: {
      field: 'CardRevisedAV',
      headerName: 'Card Revised AV',
      width: 150,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: 'Total assessed value after the newest revision the record card prints for the selected year (see Card Appeal Form for which form produced it).',
    },
  },
  {
    key: 'CardAppealDate',
    label: 'Card Appeal Date',
    defaultVisible: false,
    category: 'Appeals (Card)',
    colDef: {
      field: 'CardAppealDate',
      headerName: 'Card Appeal Date',
      width: 140,
      valueFormatter: formatDate,
      headerTooltip: 'The as-of date the record card prints beside the revised value for the selected year.',
    },
  },
  {
    key: 'IBTRDecisionDate',
    label: 'IBTR Decision Date',
    defaultVisible: false,
    category: 'Appeals (IBTR)',
    colDef: {
      field: 'IBTRDecisionDate',
      headerName: 'IBTR Decision Date',
      width: 150,
      valueFormatter: formatDate,
      headerTooltip: 'Date of this parcel\'s NEWEST Indiana Board of Tax Review disposition, from the Board\'s POPLAR docket (2002 onward). NOT tied to the selected year: a Board decision trails its assessment year by years -- see IBTR Year.',
    },
  },
  {
    key: 'IBTRAssessmentYear',
    label: 'IBTR Year',
    defaultVisible: false,
    category: 'Appeals (IBTR)',
    colDef: {
      field: 'IBTRAssessmentYear',
      headerName: 'IBTR Year',
      width: 110,
      type: 'numericColumn',
      headerTooltip: 'The assessment year the newest Board disposition concerned (it is usually several years before the decision date).',
    },
  },
  {
    key: 'IBTRDisposition',
    label: 'IBTR Disposition',
    defaultVisible: false,
    category: 'Appeals (IBTR)',
    colDef: {
      field: 'IBTRDisposition',
      headerName: 'IBTR Disposition',
      width: 190,
      headerTooltip: 'How the newest Board appeal ended: Board Determination, Settlement - stipulation, Settlement - withdrawal, Dismissal, or Remand. A determination is not necessarily a reduction -- open the parcel for the decision.',
    },
  },
  {
    key: 'IBTRValue',
    label: 'IBTR Value',
    defaultVisible: false,
    category: 'Appeals (IBTR)',
    colDef: {
      field: 'IBTRValue',
      headerName: 'IBTR Value',
      width: 150,
      type: 'numericColumn',
      valueFormatter: formatCurrency,
      headerTooltip: 'The value the Board set in that newest decision, where it has been extracted from the written determination AND can be attributed to that decision unambiguously (one determination often prints several petitions\' and several years\' figures). Extracted for only a small share of decisions so far -- blank means "not extracted" or "not unambiguous", never "unchanged".',
    },
  },
  {
    key: 'IBTRDecisionCount',
    label: 'IBTR Decisions',
    defaultVisible: false,
    category: 'Appeals (IBTR)',
    colDef: {
      field: 'IBTRDecisionCount',
      headerName: 'IBTR Decisions',
      width: 140,
      type: 'numericColumn',
      headerTooltip: 'How many Board dispositions the docket holds for this parcel, all years. Blank means none matched this parcel; appeals docketed under an old or malformed parcel number may not be matched.',
    },
  },
  {
    key: 'TaxCourtDecision',
    label: 'Tax Court',
    defaultVisible: false,
    category: 'Appeals (Tax Court)',
    colDef: {
      field: 'TaxCourtDecision',
      headerName: 'Tax Court',
      width: 110,
      headerTooltip: 'Y = an Indiana Tax Court case appears to review one of this parcel\'s Board decisions -- a taxpayer-name match (score 0.95 or higher) in the same county within 75 days of the decision, a lead to verify rather than a citation; open the parcel for the case. N = this parcel has Board decisions and none of them carries a qualifying link. Blank = no Board decision is matched to this parcel at all, or the appeal layers did not load (the banner above says which).',
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
 * only has ag-grid-community.
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
  }

  public OnRowClicked(event: RowClickedEvent<MergedParcelRow>): void {
    if (event.data) this.RowClicked.emit(event.data);
  }

  private applyColumnVisibility(): void {
    if (!this.gridApi) return;
    for (const c of PROPERTY_SEARCH_GRID_COLUMNS) {
      this.gridApi.setColumnsVisible([c.key], c.locked || this._visibleColumnKeys.has(c.key));
    }
  }
}
