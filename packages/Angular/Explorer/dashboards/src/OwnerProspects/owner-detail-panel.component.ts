import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import {
  OwnerRow,
  OwnerParcelRow,
  taxHistoryUrl,
  formatMoneyShort,
  formatMoneyOrDash,
  parcelVerifyLink,
  MARION_RUN_COUNTY_NUMBER,
  NO_ANALYSIS_TOOLTIP,
  PARCEL_CAP_NOTE,
  pairYearsTooltip,
  repIsMarionOnly,
  MARION_PARCELS_MARKER,
  MARION_REP_TOOLTIP,
  DisplayYears,
  ParcelYearsMap,
  ParcelYearValue,
  ParcelViewRow,
  ParcelSortKey,
  YearCellValue,
  buildParcelViewRows,
  parcelYearCell,
  parcelSortStartsAscending,
  sortParcels,
  TBA_MARK,
  NO_FIGURE_MARK,
} from './owner-prospects.model';
import { CountyVerifyLink } from '../PropertySearch/property-search-county';

/** The panel's Export parcels request: the owner, every loaded parcel row as sorted on screen, and that sort in words. */
export interface ParcelExportRequest {
  Owner: OwnerRow;
  Rows: ParcelViewRow[];
  Sort: string;
}

/** Parcel sort keys → the column words the export's Basis sheet uses. */
const PARCEL_SORT_WORDS: Record<ParcelSortKey, string> = {
  parcel: 'Parcel', county: 'County', type: 'Type', avYear1: 'AV (older year)', avYear2: 'AV (newest year)', yoy: 'YoY',
  sqft: 'SqFt', units: 'Units', ask: 'Ask', savings: 'Save/yr', rec: 'Rec', conf: 'Conf', appealed: 'Appealed', rep: 'Rep',
};

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
 *
 * Fixed assessment years (2026-09-28 evening): both scopes show `AV <y1>` | `AV <y2>` | `YoY` per parcel from
 * the display-year figures the dashboard read live from `Parcel Year Headlines` (`ParcelYears` input), a `roll`
 * pill on a DLGF roll figure, `TBA` / `—` gaps, and every column sortable (blanks last both directions).
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
  /** The run's two display years (older first); null when the run carries none. */
  @Input() DisplayYears: DisplayYears | null = null;
  /** The owner's display-year figures by parcel (read live by the dashboard); null = not loaded. */
  @Input() ParcelYears: ParcelYearsMap | null = null;
  /** The year figures are being read. */
  @Input() YearsLoading = false;
  /** The year read failed (the cells then claim no gap). */
  @Input() YearsError: string | null = null;

  /** The column the parcel table is sorted by; null = the default order (savings on Marion, current AV Statewide). */
  public ParcelSortKey: ParcelSortKey | null = null;
  public ParcelSortDir: 1 | -1 = -1;
  /** Rows shown at most (the rest are counted in the "N more parcels" note). */
  public readonly ParcelRowLimit = 60;

  /** Emitted when the user clicks "Flag as prospect" — the dashboard creates the `indiana_tax.Prospect` (Task 8). */
  @Output() FlagRequested = new EventEmitter<OwnerRow>();
  /** Emitted when the user clicks "View prospect" — the dashboard navigates to the existing prospect record (Task 8). */
  @Output() ViewProspectRequested = new EventEmitter<OwnerRow>();
  /** Emitted when the user clicks "Export parcels" — the dashboard writes the workbook (this panel stays presentational). */
  @Output() ExportParcelsRequested = new EventEmitter<ParcelExportRequest>();
  /** The dashboard is writing an export (the button waits). */
  @Input() Exporting = false;

  /** Marion County tax-history report URL for a GIS parcel number (template ref to the model fn). */
  public readonly taxHistoryUrl = taxHistoryUrl;
  public readonly NoAnalysisTooltip = NO_ANALYSIS_TOOLTIP;
  /** Gap markers for the templates (compared against, never retyped). */
  public readonly TbaMark = TBA_MARK;
  public readonly NoFigureMark = NO_FIGURE_MARK;
  public readonly MarionParcelsMarker = MARION_PARCELS_MARKER;
  public readonly MarionRepTooltip = MARION_REP_TOOLTIP;

  /** The assessment-pair tooltip (a bare year = current year only). */
  public get PairYearsTitle(): string {
    return pairYearsTooltip(this.Owner.pairYears);
  }

  /** True when the rep status covers only the owner's Marion parcels (Statewide rows spanning Marion and more). */
  public get RepMarionOnly(): boolean {
    return repIsMarionOnly(this.Owner, this.Owner.tierBasis ?? (this.Statewide ? 'AV' : 'Savings'));
  }
  /** `$1.2M` / `$12,345` / `—` (template ref to the model `formatMoneyShort`). */
  public readonly money = formatMoneyShort;
  /** `$12,345` / `$0` / `—` (template ref to the model `formatMoneyOrDash`). */
  public readonly moneyOrDash = formatMoneyOrDash;

  private get allParcels(): OwnerParcelRow[] {
    return this.Parcels ?? this.Owner.parcels;
  }

  /**
   * The owner's parcels with their display-year figures, sorted by the clicked column (else biggest opportunity
   * first on Marion, biggest current AV first Statewide), capped at {@link ParcelRowLimit} rows.
   */
  public get TopParcels(): ParcelViewRow[] {
    return this.SortedParcels.slice(0, this.ParcelRowLimit);
  }

  /** Every loaded parcel row in the table's order (the export writes all of them, not only the rows shown). */
  public get SortedParcels(): ParcelViewRow[] {
    const key = (p: OwnerParcelRow): number => (this.Statewide ? (p.avCurrent ?? 0) : (p.estSavingsAtAsk ?? 0));
    const base = [...this.allParcels].sort((a, b) => key(b) - key(a));
    const rows = buildParcelViewRows(base, this.ParcelYears, this.DisplayYears, this.CountyNames);
    return this.ParcelSortKey ? sortParcels(rows, this.ParcelSortKey, this.ParcelSortDir) : rows;
  }

  /** The parcel table's sort in words ("AV 2026, descending"; the default order when no column was clicked). */
  public get ParcelSortLabel(): string {
    if (!this.ParcelSortKey) return this.Statewide ? 'current AV, descending (default)' : 'savings at ask, descending (default)';
    const key = this.ParcelSortKey;
    const years = this.DisplayYears;
    const words = years && (key === 'avYear1' || key === 'avYear2') ? `AV ${years[key === 'avYear1' ? 0 : 1]}` : PARCEL_SORT_WORDS[key];
    return `${words}, ${this.ParcelSortDir === 1 ? 'ascending' : 'descending'}`;
  }

  /** Export parcels is ready once the parcels and their year figures are in. */
  public get CanExportParcels(): boolean {
    return !!this.DisplayYears && !this.ParcelsLoading && !this.YearsLoading && !this.Exporting && this.allParcels.length > 0;
  }

  /** Ask the dashboard to write the parcel workbook. */
  public ExportParcels(): void {
    if (!this.CanExportParcels) return;
    this.ExportParcelsRequested.emit({ Owner: this.Owner, Rows: this.SortedParcels, Sort: this.ParcelSortLabel });
  }

  /** Header click: the same column flips direction; a new column starts ascending for words, descending for figures. */
  public SortParcelsBy(key: ParcelSortKey): void {
    if (this.ParcelSortKey === key) {
      this.ParcelSortDir = this.ParcelSortDir === 1 ? -1 : 1;
    } else {
      this.ParcelSortKey = key;
      this.ParcelSortDir = parcelSortStartsAscending(key) ? 1 : -1;
    }
  }

  /** `asc` / `desc` on the sorted header (drives the arrow), '' elsewhere. */
  public parcelSorted(key: ParcelSortKey): '' | 'asc' | 'desc' {
    return this.ParcelSortKey !== key ? '' : this.ParcelSortDir === 1 ? 'asc' : 'desc';
  }

  /** `AV 2025` / `AV 2026` headers from the display years. */
  public yearHeader(which: 0 | 1): string {
    return this.DisplayYears ? `AV ${this.DisplayYears[which]}` : 'AV —';
  }

  /** A parcel's cell for display year 0 / 1: the figure, `TBA` / `—`, or '' while the figures are not loaded. */
  public yearCell(r: ParcelViewRow, which: 0 | 1): YearCellValue | '' {
    if (!r.loaded || !this.DisplayYears) return '';
    return parcelYearCell(which === 0 ? r.y1 : r.y2, this.DisplayYears[which], this.DisplayYears);
  }

  /** Cell text: a figure with thousands separators, a gap marker verbatim. */
  public yearText(v: YearCellValue | ''): string {
    return typeof v === 'number' ? v.toLocaleString('en-US') : v;
  }

  /** The figure's source (and roll) in words; the not-loaded reason on an unloaded cell. */
  public yearTitle(r: ParcelViewRow, which: 0 | 1): string | null {
    if (!r.loaded || !this.DisplayYears) return this.YearsLoading ? 'loading the year figures…' : 'year figures not loaded';
    const v: ParcelYearValue | null = which === 0 ? r.y1 : r.y2;
    const year = this.DisplayYears[which];
    if (!v) return which === 1 ? `${year}: To Be Assessed — no ${year} figure on the record yet` : `no ${year} figure on the record`;
    const roll = v.roll ? ' — the DLGF roll (the assessed value reported to the DLGF; no county document on file)' : '';
    return `${year}: ${v.source ?? 'assessed value on the record'}${roll}`;
  }

  /** "newest assessment year on record: 2026" (the parcel cell's tooltip). */
  public newestTitle(r: ParcelViewRow): string {
    return r.newestYear == null ? 'no assessment year on record' : `newest assessment year on record: ${r.newestYear}`;
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

  /** Parcels beyond the {@link ParcelRowLimit} shown in {@link TopParcels} — drives the "N more parcels" note. */
  public get RemainingParcelCount(): number {
    return Math.max(0, this.allParcels.length - this.ParcelRowLimit);
  }

  /** Signed year-over-year percent for a parcel cell: `+7.1%` / `-4.1%` / `0%` / `—`. */
  public yoy(pct: number | null): string {
    if (pct == null) {
      return '—';
    }
    return (pct > 0 ? '+' : '') + pct + '%';
  }
}
