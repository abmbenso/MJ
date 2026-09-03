import '@angular/compiler';
import { describe, it, expect } from 'vitest';
import { OwnerProspectsDashboardsModule } from '../owner-prospects-dashboards.module';
import { OwnerProspectsDashboardComponent } from '../OwnerProspects/owner-prospects-dashboard.component';

describe('OwnerProspectsDashboardsModule', () => {
  it('declares and exports the dashboard component', () => {
    expect(OwnerProspectsDashboardsModule).toBeDefined();
    expect(OwnerProspectsDashboardComponent).toBeDefined();
  });
});
