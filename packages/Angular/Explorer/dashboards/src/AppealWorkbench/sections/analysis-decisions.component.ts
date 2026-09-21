import { Component, ChangeDetectionStrategy, EventEmitter, Input, Output } from '@angular/core';
import { IBTRRow, PTABOARow, SubjectBundle } from '../analysis-store';

@Component({
  standalone: false,
  selector: 'mj-analysis-decisions',
  templateUrl: './analysis-decisions.component.html',
  styleUrls: ['./analysis-decisions.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalysisDecisionsComponent {
  @Input() Subject: SubjectBundle | null = null;
  /** This tab's one-click print button (Task 10) -- the shell alone holds what an export needs, so this only asks. */
  @Output() PrintRequested = new EventEmitter<void>();
  public get Ptaboa(): PTABOARow[] { return this.Subject?.ptaboa ?? []; }
  public get Ibtr(): IBTRRow[] { return this.Subject?.ibtr ?? []; }
  public get CompOutcomes() { return (this.Subject?.compMembers ?? []).filter((m) => m.AppealedAV != null || m.AppealLevel); }
  /** I8: show the comp's GIS parcel number and address instead of its raw GUID; fall back to the ID when the member parcel wasn't resolved. */
  public compLabel(id: string): string {
    const p = this.Subject?.memberParcels[id];
    if (!p || (p.GISParcelNumber == null && p.Address == null)) return id;
    return [p.GISParcelNumber, p.Address].filter((x): x is string => x != null).join(' — ');
  }
}
