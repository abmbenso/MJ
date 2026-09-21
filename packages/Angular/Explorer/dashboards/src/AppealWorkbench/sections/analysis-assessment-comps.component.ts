import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output } from '@angular/core';
import { AnalysisRow, CompMemberRow, SubjectBundle } from '../analysis-store';
import { compsIndication } from './comps-indication';

@Component({
  standalone: false,
  selector: 'mj-analysis-assessment-comps',
  templateUrl: './analysis-assessment-comps.component.html',
  styleUrls: ['./analysis-assessment-comps.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisAssessmentCompsComponent {
  @Input() Subject: SubjectBundle | null = null;
  @Input() Analysis: AnalysisRow | null = null;
  @Input() Mode: 'comps' | 'cost' = 'comps';
  /**
   * This tab's one-click print button (Task 10). One component instance renders BOTH the
   * Assessment Comps tab (Mode='comps') and the Cost tab (Mode='cost') -- which of the two
   * PrintSections that means is the shell's call (it already knows which case block it's in),
   * so this only asks; it never picks the PrintSection key itself.
   */
  @Output() PrintRequested = new EventEmitter<void>();
  public get Indication() { return compsIndication(this.Subject?.compSet ?? null, this.Analysis?.SubjectDenominator ?? null, this.Analysis?.UnitOfComparison ?? null); }
  public members(bucket: 'Neighborhood' | 'County'): CompMemberRow[] { return (this.Subject?.compMembers ?? []).filter((m) => m.GeographyBucket === bucket).sort((a, b) => (a.SortOrder ?? 0) - (b.SortOrder ?? 0)); }
  /** I8: show the comp's GIS parcel number and address instead of its raw GUID; fall back to the ID when the member parcel wasn't resolved. */
  public compLabel(id: string): string {
    const p = this.Subject?.memberParcels[id];
    if (!p || (p.GISParcelNumber == null && p.Address == null)) return id;
    return [p.GISParcelNumber, p.Address].filter((x): x is string => x != null).join(' — ');
  }
}
