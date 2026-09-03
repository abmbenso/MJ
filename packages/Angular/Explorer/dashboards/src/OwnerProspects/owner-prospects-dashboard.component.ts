import { Component, ChangeDetectionStrategy, ChangeDetectorRef, AfterViewInit } from '@angular/core';
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { RegisterClass } from '@memberjunction/global';
import { ResourceData } from '@memberjunction/core-entities';

/**
 * Owner Prospects — Marion County parcels rolled up to the operating company
 * that owns them, triaged by dollars at stake. The MJ Explorer port of the
 * `owner-portfolios-view.html` Artifact; reads live indiana_tax.OwnerPortfolio*
 * entities (written by scripts/build-owner-portfolios.js) instead of a baked
 * JSON blob. Read-only over the portfolio tables; the one write it can make is
 * flagging an owner as an indiana_tax.Prospect (see flagOwnerAsProspect).
 *
 * Registered against BaseResourceComponent as well as BaseDashboard for the
 * same reason PropertySearchDashboardComponent is: the tab-container's nav-item
 * resolver only ever looks up BaseResourceComponent by driver class.
 */
@Component({
  standalone: false,
  selector: 'mj-owner-prospects-dashboard',
  templateUrl: './owner-prospects-dashboard.component.html',
  styleUrls: ['./owner-prospects-dashboard.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'OwnerProspectsResource')
@RegisterClass(BaseResourceComponent, 'OwnerProspectsResource')
export class OwnerProspectsDashboardComponent extends BaseDashboard implements AfterViewInit {
  public IsLoading = false;

  constructor(private cdr: ChangeDetectorRef) {
    super();
  }

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Owner Prospects';
  }

  initDashboard(): void {
    // resolved in Task 4
  }

  async loadData(): Promise<void> {
    // populated in Task 4 — BaseDashboard.ngOnInit() calls this then NotifyLoadComplete()
  }

  ngAfterViewInit(): void {
    // publishAgentContext() added in Task 9
  }
}

export function LoadOwnerProspectsDashboard(): void {
  // Prevents tree-shaking of the component when only referenced via ClassFactory.
}
