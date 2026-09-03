import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { ViewToggleOption } from '@memberjunction/ng-ui-components';
import {
  MergedParcelRow,
  ComparisonUnit,
  ResultSetAnalytics,
  MetricStats,
  COMPARISON_UNIT_LABELS,
  availableComparisonUnits,
  computeResultSetAnalytics,
  formatCurrency,
} from './property-search-agent-context';

/** One row of the metric table: a label, its MetricStats (or null if nothing qualified), and whether its values are dollar amounts (currency-formatted) or a plain count (the raw size/count row). */
interface MetricRow {
  label: string;
  stats: MetricStats | null;
  isCurrency: boolean;
}

/**
 * Collapsible Avg/Median/Min/Max breakdown over the CURRENT filtered result
 * set, with a unit-of-comparison toggle (Sq Ft / Acre / Unit / Key / Bed /
 * Door — whichever the result set actually has data for). Purely
 * presentational: no own RunView fetch, derives everything from the [Rows]
 * input already loaded by the host dashboard — matches PropertySearchGrid's
 * pattern, not PropertySubclassAnalytics' independent-fetch one, since this
 * panel is result-set-scoped and must recompute instantly on every filter
 * change, not re-query.
 *
 * See property-search-agent-context.ts's "Result-Set Analytics Panel"
 * section for the pure calc functions and why Unit/Key/Bed/Door mostly show
 * no data today (not populated by PRC parsing — see migration
 * V202608252036).
 */
@Component({
  standalone: false,
  selector: 'mj-property-search-analytics-panel',
  templateUrl: './property-search-analytics-panel.component.html',
  styleUrls: ['./property-search-analytics-panel.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PropertySearchAnalyticsPanelComponent {
  @Input()
  set Rows(value: MergedParcelRow[]) {
    this._rows = value ?? [];
    // The previously-selected unit may no longer be available in the new
    // result set (e.g. the user just filtered down to hotels-only, dropping
    // 'acre') -- fall back to 'sqft' rather than silently showing stale
    // empty data under a unit that no longer applies.
    if (!this.AvailableUnits.includes(this.SelectedUnit)) {
      this.SelectedUnit = 'sqft';
    }
  }
  get Rows(): MergedParcelRow[] {
    return this._rows;
  }
  private _rows: MergedParcelRow[] = [];

  public IsExpanded = false;
  public SelectedUnit: ComparisonUnit = 'sqft';

  public toggleExpanded(): void {
    this.IsExpanded = !this.IsExpanded;
  }

  public onUnitChange(key: string): void {
    this.SelectedUnit = key as ComparisonUnit;
  }

  /** Which units have real data in the current result set -- drives whether the toggle row renders at all (single-'sqft'-option result sets skip it, same graceful-degradation spirit as the rest of this panel's gating). */
  public get AvailableUnits(): ComparisonUnit[] {
    return availableComparisonUnits(this._rows);
  }

  public get UnitToggleOptions(): ViewToggleOption[] {
    return this.AvailableUnits.map((unit) => ({ key: unit, label: COMPARISON_UNIT_LABELS[unit] }));
  }

  public get Analytics(): ResultSetAnalytics {
    return computeResultSetAnalytics(this._rows, this.SelectedUnit);
  }

  /** Unit/Key counts come from CountyAssessorRecord.ComparisonUnitCount, which -- as of this dashboard's build -- is only ever populated via a CoStar-property-data backfill (see migration V202608252036's comment and backfill-comparison-unit-from-costar.js), never from county-assessor parsing itself. Sq Ft/Acres are the county's own figures, so this caption only applies to those two units. */
  public get ShowCoStarProvenanceNote(): boolean {
    return this.SelectedUnit === 'unit' || this.SelectedUnit === 'key';
  }

  /** Label for the raw size/count row -- distinct from the plural of COMPARISON_UNIT_LABELS' singular toggle labels ("Sq Ft" isn't "Sq Fts", "Unit" reads better as "Apartment Units" than a bare plural). */
  private static readonly SIZE_ROW_LABELS: Record<ComparisonUnit, string> = {
    sqft: 'Building Sq Ft',
    acre: 'Acres',
    unit: 'Apartment Units',
    key: 'Hotel/Motel Keys',
    bed: 'Nursing/Hospital Beds',
    door: 'Self-Storage Doors',
  };

  /** The five metric rows for the current unit, in display order. The raw size/count row first (always a meaningful physical size regardless of what's being compared per), then the four $-per-unit ratios. */
  public get MetricRows(): MetricRow[] {
    const a = this.Analytics;
    const unitLabel = COMPARISON_UNIT_LABELS[this.SelectedUnit];
    return [
      { label: PropertySearchAnalyticsPanelComponent.SIZE_ROW_LABELS[this.SelectedUnit], stats: a.size, isCurrency: false },
      { label: `Assessed Value / ${unitLabel}`, stats: a.assessedValuePerUnit, isCurrency: true },
      { label: `Total Tax / ${unitLabel}`, stats: a.totalTaxPerUnit, isCurrency: true },
      { label: `PTABOA Value / ${unitLabel}`, stats: a.ptaboaValuePerUnit, isCurrency: true },
      { label: `Sale Price / ${unitLabel}`, stats: a.salePricePerUnit, isCurrency: true },
    ];
  }

  public formatStat(value: number, isCurrency: boolean): string {
    return isCurrency ? formatCurrency(Math.round(value)) : value.toLocaleString('en-US', { maximumFractionDigits: 1 });
  }
}
