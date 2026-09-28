import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import {
  OwnerRow,
  OwnerParcelRow,
  taxHistoryUrl,
  formatMoneyShort,
  formatMoneyOrDash,
  parcelYears,
  parcelVerifyLink,
  MARION_RUN_COUNTY_NUMBER,
  NO_ANALYSIS_TOOLTIP,
  PARCEL_CAP_NOTE,
} from './owner-prospects.model';
import { CountyVerifyLink } from '../PropertySearch/property-search-county';

/**
 * Owner Prospects — the expandable per-owner detail row.
 *
 * PRESENTATIONAL ONLY. It reads its `@Input() Owner` and emits `FlagRequested` /
 * `ViewProspectRequested`; it never touches `RunView`, `Metadata`, or
 * `navigationService`. The dashboard renders one of these inside an expanded
 * `<tr>` under the selected owner (see owner-prospects-dashboard.component.html)
 * and owns the write side (Task 8).
 *
 * Layout: a key-value grid (`.dgrid`) of owner-level facts, a one-line
 * portfolio-by-type summary, a `table.pt` of the owner's top parcels (each with
 * outbound Marion County PRC / Tax-History links), and an actions row that shows
 * "Flag as prospect" (primary) until an `indiana_tax.Prospect` is linked, then
 * "View prospect" (secondary).
 */
@Component({
  standalone: false,
  selector: 'mj-owner-detail-panel',
  templateUrl: './owner-detail-panel.component.html',
  styleUrls: ['./owner-detail-panel.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OwnerDetailPanelComponent {
  /** The owner group whose detail this row shows. Set by the dashboard's `@for` binding. */
  @Input() Owner!: OwnerRow;
  /**
   * The owner's parcels when the dashboard fetched them after expand (Statewide) — a new array
   * reference re-renders this OnPush panel. Null = use `Owner.parcels` (the Marion run preloads them).
   */
  @Input() Parcels: OwnerParcelRow[] | null = null;
  /** Statewide run: per-parcel county, assessment years, placeholder pill, prior/current AV. */
  @Input() Statewide = false;
  /** Statewide: the owner's parcels are being fetched. */
  @Input() ParcelsLoading = false;
  /** Statewide: the owner has more parcels than the 5,000 loaded. */
  @Input() ParcelsCapped = false;
  public readonly ParcelCapNote = PARCEL_CAP_NOTE;
  /** County number → `County.Slug` (the verify-link builder's vendor key). */
  @Input() CountySlugs: Record<number, string> = {};
  /** County number → county name (the county split line and the parcel County column). */
  @Input() CountyNames: Record<number, string> = {};

  /** Emitted when the user clicks "Flag as prospect" — the dashboard creates the `indiana_tax.Prospect` (Task 8). */
  @Output() FlagRequested = new EventEmitter<OwnerRow>();
  /** Emitted when the user clicks "View prospect" — the dashboard navigates to the existing prospect record (Task 8). */
  @Output() ViewProspectRequested = new EventEmitter<OwnerRow>();

  /** Marion County tax-history report URL for a GIS parcel number (template ref to the model fn). */
  public readonly taxHistoryUrl = taxHistoryUrl;
  /** `2024→2025` / `2025 only` (template ref to the model fn). */
  public readonly parcelYears = parcelYears;
  public readonly NoAnalysisTooltip = NO_ANALYSIS_TOOLTIP;
  /** `$1.2M` / `$12,345` / `—` (template ref to the model `formatMoneyShort`). */
  public readonly money = formatMoneyShort;
  /** `$12,345` / `$0` / `—` (template ref to the model `formatMoneyOrDash`). */
  public readonly moneyOrDash = formatMoneyOrDash;

  private get allParcels(): OwnerParcelRow[] {
    return this.Parcels ?? this.Owner.parcels;
  }

  /** The owner's parcels, capped at 60 rows — biggest opportunity first (Marion), biggest current AV first (Statewide). */
  public get TopParcels(): OwnerParcelRow[] {
    const key = (p: OwnerParcelRow): number => (this.Statewide ? (p.avCurrent ?? 0) : (p.estSavingsAtAsk ?? 0));
    return [...this.allParcels].sort((a, b) => key(b) - key(a)).slice(0, 60);
  }

  /**
   * The county-document link for a parcel, through Property Search's `buildVerifyLink` — any
   * county. A Marion-run parcel carries no CountyNumber, so it falls back to Marion (the run's county).
   */
  public verifyLink(p: OwnerParcelRow): CountyVerifyLink {
    return parcelVerifyLink(p, this.CountySlugs, this.Statewide ? null : MARION_RUN_COUNTY_NUMBER);
  }

  public countyName(n: number | null | undefined): string {
    return n == null ? '—' : (this.CountyNames[n] ?? `County ${n}`);
  }

  /** "Marion 17 ($102.4M) · Allen 5 ($43.1M) · …" — the owner's county split by current AV (Statewide). */
  public get CountySplit(): string {
    return Object.entries(this.Owner.byCounty ?? {})
      .sort((a, b) => b[1].avCurrent - a[1].avCurrent)
      .map(([k, v]) => `${this.countyName(Number(k))} ${v.parcels} (${formatMoneyShort(v.avCurrent)})`)
      .join(' · ');
  }

  /** `"Industrial 4 ($3.0M) · Office 2 ($1.2M)"` — type buckets by assessed value, descending. */
  public get ByTypeSummary(): string {
    return Object.entries(this.Owner.byType ?? {})
      .sort((a, b) => b[1].av - a[1].av)
      .map(([k, v]) => `${k} ${v.n} (${formatMoneyShort(v.av)})`)
      .join(' · ');
  }

  /** Parcels beyond the 60 shown in {@link TopParcels} — drives the "N more parcels" note. */
  public get RemainingParcelCount(): number {
    return Math.max(0, this.allParcels.length - 60);
  }

  /** Signed year-over-year percent for a parcel cell: `+7.1%` / `-4.1%` / `0%` / `—`. */
  public yoy(pct: number | null): string {
    if (pct == null) {
      return '—';
    }
    return (pct > 0 ? '+' : '') + pct + '%';
  }
}
