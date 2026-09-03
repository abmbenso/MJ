import { Component, ChangeDetectionStrategy, Input, Output, EventEmitter } from '@angular/core';
import {
  MergedParcelRow,
  formatCurrency,
  pricePerSqFt,
  AssessmentTrendRow,
  TrendYearsOption,
  DEFAULT_TREND_YEARS,
  AppealHistoryRow,
  appealStatusVariant,
  appealAVChange,
  appealAVChangePct,
  appealConfirmationStatus,
  AppealConfirmationStatus,
  CoStarPropertyRow,
} from './property-search-agent-context';

interface SqFtConfidenceBadge {
  label: string;
  variant: 'success' | 'warning' | 'default';
}

/**
 * Presentational right-side slide-in panel showing one parcel's detail,
 * triggered by a map marker click. Read-only — the two outputs (Close,
 * OpenRecord) are the only ways this component talks back to its parent.
 */
@Component({
  standalone: false,
  selector: 'mj-property-detail-panel',
  templateUrl: './property-detail-panel.component.html',
  styleUrls: ['./property-detail-panel.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PropertyDetailPanelComponent {
  @Input() Parcel: MergedParcelRow | null = null;
  @Input() Visible = false;
  /** Up to 10 years for Parcel, newest first -- host fetches once per selection; this component only slices via TrendYearsOption below. */
  @Input() TrendRows: AssessmentTrendRow[] = [];
  @Input() IsTrendLoading = false;

  /** SelectedParcel's PTABOA appeal history, newest first -- host fetches once per selection. Setter resets the expand state below so a stale card doesn't stay open when the parcel changes. */
  @Input()
  set Appeals(value: AppealHistoryRow[]) {
    this._appeals = value ?? [];
    this.expandedAppealIndices.clear();
  }
  get Appeals(): AppealHistoryRow[] {
    return this._appeals;
  }
  private _appeals: AppealHistoryRow[] = [];
  @Input() IsAppealsLoading = false;

  /** The selected parcel's CoStar matches -- usually 0 or 1, occasionally more (see CoStarPropertyRow's doc comment on why this is a list, not a single merged value). Host fetches once per selection. */
  @Input() CoStarMatches: CoStarPropertyRow[] = [];

  @Output() Close = new EventEmitter<void>();
  @Output() OpenRecord = new EventEmitter<MergedParcelRow>();

  /** Local, ephemeral view preference (not an @Input) -- purely a display slice of the already-fetched TrendRows, no re-fetch involved, so it doesn't need to round-trip through the host. Persists across parcel selections within the session, matching the ActiveViewMode/ActiveRenderMode precedent elsewhere in this dashboard. */
  public TrendYearsOption: TrendYearsOption = DEFAULT_TREND_YEARS;

  public readonly TrendYearsToggleOptions = [
    { key: '5', label: '5 yr' },
    { key: '10', label: '10 yr' },
  ];

  public onTrendYearsToggle(key: string): void {
    this.TrendYearsOption = (Number(key) === 10 ? 10 : 5) as TrendYearsOption;
  }

  public get VisibleTrendRows(): AssessmentTrendRow[] {
    return this.TrendRows.slice(0, this.TrendYearsOption);
  }

  public get TrendYears(): number[] {
    return this.VisibleTrendRows.map((r) => r.taxYear);
  }

  public formatTaxRate(value: number | null): string {
    return value == null ? '—' : `${value.toFixed(4)}%`;
  }

  public get Title(): string {
    return this.Parcel?.Address ?? this.Parcel?.ParcelNumber ?? 'Parcel';
  }

  public get SqFtConfidence(): SqFtConfidenceBadge {
    switch (this.Parcel?.SqFtSource) {
      case 'PropertyRecordCard':
        return { label: 'Verified from Property Record Card', variant: 'success' };
      case 'BuildingDetail':
        return { label: 'May undercount multi-floor buildings', variant: 'warning' };
      default:
        return { label: 'Unverified — may reflect land area, not building size', variant: 'default' };
    }
  }

  public formatCurrency(value: number | null): string {
    return formatCurrency(value);
  }

  public get PricePerSqFtDisplay(): string {
    if (!this.Parcel) return '—';
    const v = pricePerSqFt(this.Parcel);
    return v == null ? '—' : `${formatCurrency(Math.round(v))}/SF`;
  }

  public formatSqFt(value: number | null): string {
    if (value == null) return 'Unknown';
    return `${value.toLocaleString('en-US')} sq ft`;
  }

  public onOpenRecord(): void {
    if (this.Parcel) this.OpenRecord.emit(this.Parcel);
  }

  // ───── Appeal History ─────

  /** Which appeal cards have their Circumstances text expanded -- indices into Appeals, cleared whenever Appeals itself changes (see the setter above). */
  private readonly expandedAppealIndices = new Set<number>();

  public isAppealExpanded(index: number): boolean {
    return this.expandedAppealIndices.has(index);
  }

  public toggleAppealExpanded(index: number): void {
    if (this.expandedAppealIndices.has(index)) this.expandedAppealIndices.delete(index);
    else this.expandedAppealIndices.add(index);
  }

  public appealStatusVariant(status: string | null): 'success' | 'warning' | 'default' {
    return appealStatusVariant(status);
  }

  public formatHearingDate(value: string | null): string {
    if (!value) return '—';
    const d = new Date(value);
    return Number.isNaN(d.getTime()) ? '—' : d.toLocaleDateString('en-US');
  }

  /** One-line AV change summary for the (always-visible) card header, e.g. "$8,445,800 → $7,721,800 (−8.6%)". Null when Before/After weren't captured for this appeal (e.g. an older or unresolved-format record). */
  public formatAVChangeSummary(appeal: AppealHistoryRow): string | null {
    if (appeal.beforeTotalAV == null || appeal.afterTotalAV == null) return null;
    const pct = appealAVChangePct(appeal);
    const pctText = pct == null ? '' : ` (${pct > 0 ? '+' : ''}${pct.toFixed(1)}%)`;
    return `${formatCurrency(appeal.beforeTotalAV)} → ${formatCurrency(appeal.afterTotalAV)}${pctText}`;
  }

  /** 'reduction' | 'increase' | 'none' -- drives the color of the AV change summary, independent of the DecisionStatus chip (a "Recommended" appeal can still show a real reduction, and vice versa). */
  public avChangeDirection(appeal: AppealHistoryRow): 'reduction' | 'increase' | 'none' {
    const change = appealAVChange(appeal);
    if (change == null || change === 0) return 'none';
    return change < 0 ? 'reduction' : 'increase';
  }

  /**
   * 'confirmed' / 'revised' / 'pending' -- whether this appeal's agenda-
   * reported outcome (DecisionStatus/afterTotalAV above) has actually been
   * ratified by a real Form 115 Final Determination yet. Independent of
   * DecisionStatus/avChangeDirection -- an agenda can say "Final Agreement"
   * and still be unconfirmed for over a year (the real example that started
   * this investigation, case 49-101-24-0-4-00083). See
   * appealConfirmationStatus's own doc comment.
   */
  public appealConfirmationStatus(appeal: AppealHistoryRow): AppealConfirmationStatus {
    return appealConfirmationStatus(appeal);
  }

  public appealConfirmationLabel(appeal: AppealHistoryRow): string {
    switch (this.appealConfirmationStatus(appeal)) {
      case 'confirmed':
        return 'Confirmed';
      case 'revised':
        return `Confirmed — revised to ${formatCurrency(appeal.finalDeterminationTotalAV)}`;
      case 'pending':
        return 'Pending confirmation';
    }
  }

  // ───── CoStar ─────

  /** "42 units" / "186 rooms" / "40,543 SF" -- whichever of Units/Rooms/RBA this listing actually has, in that priority order (a listing generally has one primary size metric, not all three). Null when none are populated. */
  public coStarSizeSummary(match: CoStarPropertyRow): string | null {
    if (match.numberOfUnits != null) return `${match.numberOfUnits.toLocaleString('en-US')} units`;
    if (match.rooms != null) return `${match.rooms.toLocaleString('en-US')} rooms`;
    if (match.rba != null) return `${match.rba.toLocaleString('en-US')} SF (RBA)`;
    return null;
  }

  public formatSaleDate(value: string | null): string {
    if (!value) return '—';
    const d = new Date(value);
    return Number.isNaN(d.getTime()) ? '—' : d.toLocaleDateString('en-US');
  }
}
