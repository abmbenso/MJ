import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { OwnerRow, OwnerParcelRow, prcUrl, taxHistoryUrl, formatMoneyShort, formatMoneyOrDash } from './owner-prospects.model';

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

  /** Emitted when the user clicks "Flag as prospect" — the dashboard creates the `indiana_tax.Prospect` (Task 8). */
  @Output() FlagRequested = new EventEmitter<OwnerRow>();
  /** Emitted when the user clicks "View prospect" — the dashboard navigates to the existing prospect record (Task 8). */
  @Output() ViewProspectRequested = new EventEmitter<OwnerRow>();

  /** Marion County Assessor Property Record Card URL for a GIS parcel number (template ref to the model fn). */
  public readonly prcUrl = prcUrl;
  /** Marion County tax-history report URL for a GIS parcel number (template ref to the model fn). */
  public readonly taxHistoryUrl = taxHistoryUrl;
  /** `$1.2M` / `$12,345` / `—` (template ref to the model `formatMoneyShort`). */
  public readonly money = formatMoneyShort;
  /** `$12,345` / `$0` / `—` (template ref to the model `formatMoneyOrDash`). */
  public readonly moneyOrDash = formatMoneyOrDash;

  /** The owner's parcels, biggest opportunity first, capped at 60 rows for the table. */
  public get TopParcels(): OwnerParcelRow[] {
    return [...this.Owner.parcels].sort((a, b) => (b.estSavingsAtAsk ?? 0) - (a.estSavingsAtAsk ?? 0)).slice(0, 60);
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
    return Math.max(0, this.Owner.parcels.length - 60);
  }

  /** Signed year-over-year percent for a parcel cell: `+7.1%` / `-4.1%` / `0%` / `—`. */
  public yoy(pct: number | null): string {
    if (pct == null) {
      return '—';
    }
    return (pct > 0 ? '+' : '') + pct + '%';
  }
}
