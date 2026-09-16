import { AfterViewInit, ChangeDetectionStrategy, ChangeDetectorRef, Component, inject } from '@angular/core';
import { RegisterClass } from '@memberjunction/global';
// BaseDashboard / BaseResourceComponent live in @memberjunction/ng-shared (NOT
// ng-explorer-core, which was an unverified guess during planning) -- confirmed
// against the real sibling dashboard, PropertySearchDashboardComponent.
import { BaseDashboard, BaseResourceComponent } from '@memberjunction/ng-shared';
import { ResourceData } from '@memberjunction/core-entities';
import { CompositeKey, RunView } from '@memberjunction/core';
import { GraphQLDataProvider } from '@memberjunction/graphql-dataprovider';
import { AIEngineBase } from '@memberjunction/ai-engine-base';
import { SearchService, SearchResultItem } from '@memberjunction/ng-search';
import { AgentToolResult, validateStringParam } from '../shared/agent-tool-validation';
import { classifyQuery } from './query-classifier';

/** Matches the `[CITE: <citation key>]` inline marker the Legal Research agent's own
 * system prompt (metadata/prompts/templates/indiana-legal-research/system-prompt.md)
 * is instructed to emit after every substantive claim. */
const CITE_RE = /\[CITE:\s*([^\]]+)\]/g;

/** One `[CITE: ...]` token pulled out of an agent answer -- unresolved until the user
 * clicks it, then hydrated from Legal Authority Sections (see openCitation). */
interface CitationChip {
  key: string;
  resolved?: { heading: string; text: string };
}

/**
 * Legal Research — federated search (IBTR Decisions + Legal Authority Search Scopes)
 * over Indiana property tax statute, 50 IAC, the Manual, Guidelines, and IBTR/Tax Court
 * decisions, plus a cited AI answer for question-shaped queries (see classifyQuery).
 *
 * Search execution and citation-detail lookups are read-only; this dashboard never
 * writes to any entity.
 */
@Component({
  standalone: false,
  selector: 'mj-legal-research-dashboard',
  templateUrl: './legal-research-dashboard.component.html',
  styleUrls: ['./legal-research-dashboard.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
@RegisterClass(BaseDashboard, 'LegalResearchResource')
// tab-container.component.ts's nav-item resolver always looks up
// ClassFactory.GetRegistrationAsync(BaseResourceComponent, driverClass) -- never
// BaseDashboard directly -- so a BaseDashboard-only registration is unreachable as a
// direct nav target. Mirrors PropertySearchDashboardComponent's identical second
// registration for the identical reason.
@RegisterClass(BaseResourceComponent, 'LegalResearchResource')
export class LegalResearchDashboardComponent extends BaseDashboard implements AfterViewInit {
  public query = '';
  public loading = false;
  public sourceResults: SearchResultItem[] = [];
  public answerText = '';
  public answerChips: CitationChip[] = [];
  public activeChip: CitationChip | null = null;

  private search = inject(SearchService);
  private cdr = inject(ChangeDetectorRef);

  private ibtrScopeId: string | null = null;
  private legalAuthorityScopeId: string | null = null;

  async GetResourceDisplayName(_data: ResourceData): Promise<string> {
    return 'Legal Research';
  }

  // ───── BaseDashboard lifecycle ─────
  // BaseDashboard.ngOnInit() (packages/Angular/Explorer/shared/src/lib/base-dashboard.ts)
  // already calls initDashboard() then awaits loadData() then calls NotifyLoadComplete()
  // -- there is no need (and it would double-run init) to also drive this from
  // ngAfterViewInit, which the illustrative draft of this component mistakenly did.

  protected initDashboard(): void {
    // Nothing to do synchronously -- loadData() below does the one thing this
    // dashboard needs at startup (loading the two Search Scope IDs). Required
    // override (BaseDashboard.initDashboard is abstract).
    //
    // NOTE: this used to also set `this.search.Provider = this.ProviderToUse`.
    // Removed per code review: SearchService is `@Injectable({ providedIn: 'root' })`
    // -- a process-wide singleton, the only place in this codebase that ever set
    // that field -- so doing so here would silently redirect every OTHER
    // consumer of the shared SearchService (e.g. the global search omnibar) to
    // this dashboard's provider for the rest of the session, with no reset in
    // ngOnDestroy. It was also a no-op in the current single-provider
    // deployment: SearchService.LoadScopes() hardcodes Metadata.Provider
    // internally regardless (see its own `// global-provider-ok` comment), so
    // the line never even made scope-loading provider-aware. If this dashboard
    // is ever embedded under a genuinely non-default provider, SearchService
    // itself needs a per-call provider parameter -- not a component reaching in
    // and mutating shared singleton state.
  }

  protected async loadData(): Promise<void> {
    const scopes = await this.search.LoadScopes();
    this.ibtrScopeId = scopes.find((s) => s.Name === 'IBTR Decisions')?.ID ?? null;
    this.legalAuthorityScopeId = scopes.find((s) => s.Name === 'Legal Authority')?.ID ?? null;
  }

  ngAfterViewInit(): void {
    this.registerAgentClientTools();
    this.publishAgentContext();
  }

  // ───── Search + agent answer ─────

  public async runSearch(): Promise<void> {
    const trimmed = this.query.trim();
    if (!trimmed) return;

    this.loading = true;
    this.answerText = '';
    this.answerChips = [];
    this.activeChip = null;
    this.cdr.markForCheck();

    try {
      const scopeIDs = [this.ibtrScopeId, this.legalAuthorityScopeId].filter((id): id is string => !!id);
      const response = await this.search.ExecuteSearch({
        Query: trimmed,
        MaxResults: 25,
        ActiveFilters: {},
        IncludeSources: ['vector', 'fulltext', 'entity'],
        ScopeIDs: scopeIDs,
      });
      this.sourceResults = response.Success ? response.Results : [];

      if (classifyQuery(trimmed) === 'question') {
        await this.runAgentAnswer(trimmed);
      }
    } finally {
      this.loading = false;
      this.publishAgentContext();
      this.cdr.markForCheck();
    }
  }

  public clearSearch(): void {
    this.query = '';
    this.sourceResults = [];
    this.answerText = '';
    this.answerChips = [];
    this.activeChip = null;
    this.publishAgentContext();
    this.cdr.markForCheck();
  }

  private async runAgentAnswer(query: string): Promise<void> {
    await AIEngineBase.Instance.Config(false);
    const agent = AIEngineBase.Instance.Agents.find((a) => a.Name === 'Legal Research');
    if (!agent) return;

    const provider = this.ProviderToUse as GraphQLDataProvider;
    const result = await provider.AI.RunAIAgent({
      agent,
      conversationMessages: [{ role: 'user', content: query }],
    });
    if (!result.success || typeof result.payload !== 'string') return;

    this.answerChips = this.parseCitationChips(result.payload);
    this.answerText = result.payload.replace(CITE_RE, '').trim();
  }

  private parseCitationChips(text: string): CitationChip[] {
    const chips: CitationChip[] = [];
    const seen = new Set<string>();
    for (const match of text.matchAll(CITE_RE)) {
      const key = match[1].trim();
      if (!key || seen.has(key)) continue;
      seen.add(key);
      chips.push({ key });
    }
    return chips;
  }

  // ───── Citations + source records ─────

  /**
   * Resolves a citation chip's full text from Legal Authority Sections -- the entity
   * the Legal Research agent's own system prompt names as the citation-key source (see
   * metadata/prompts/templates/indiana-legal-research/system-prompt.md and
   * metadata/search-scopes/.indiana-tax-legal-authority.json, which confirms the entity
   * exists and is bound to the Legal Authority Search Scope). Its CitationKey/Heading/
   * FullText column names were not independently verifiable in this checkout (no
   * migration for this indiana_tax-schema table is committed here) -- see the task
   * report. Decision citations (IBTR petition numbers, Tax Court cause numbers) are not
   * resolved by this lookup; such chips render inert (no detail panel) rather than a
   * wrong answer.
   */
  public async openCitation(chip: CitationChip): Promise<void> {
    if (chip.resolved) {
      this.activeChip = chip;
      this.cdr.markForCheck();
      return;
    }
    const rv = RunView.FromMetadataProvider(this.ProviderToUse);
    const result = await rv.RunView<{ Heading: string; FullText: string }>({
      EntityName: 'Legal Authority Sections',
      ExtraFilter: `CitationKey = '${chip.key.replace(/'/g, "''")}'`,
      MaxRows: 1,
      ResultType: 'simple',
    });
    if (result.Success && result.Results?.length) {
      const row = result.Results[0];
      chip.resolved = { heading: row.Heading, text: row.FullText };
    }
    this.activeChip = chip;
    this.cdr.markForCheck();
  }

  /** Opens a federated-search result card's underlying record for viewing. SearchResultItem
   * carries no citation key of its own (only ID/EntityName/RecordID/Title/Snippet), so unlike
   * an agent-answer citation chip, a source card drills into the real record rather than a
   * resolved-text panel. */
  public openSourceRecord(item: SearchResultItem): void {
    this.navigationService.OpenEntityRecord(item.EntityName, CompositeKey.FromID(item.RecordID));
  }

  // ───── Agent context + client tools ─────
  // Required for every dashboard in this package -- see packages/Angular/Explorer/dashboards/CLAUDE.md
  // ("Agent Context & Client Tools — REQUIRED FOR EVERY DASHBOARD").
  //
  // 🚨 SAFETY BOUNDARY: the only exposed tool is the surface's own primary read-only
  // lookup (run a search / clear it) -- there is no mutation on this dashboard to gate.

  private publishAgentContext(): void {
    this.navigationService.SetAgentContext(this, {
      CurrentQuery: this.query,
      IsLoading: this.loading,
      ResultCount: this.sourceResults.length,
      HasAnswer: !!this.answerText,
      CitationChipCount: this.answerChips.length,
    });
  }

  private registerAgentClientTools(): void {
    this.navigationService.SetAgentClientTools(this, [
      {
        Name: 'RunLegalResearchSearch',
        Description:
          'Search Indiana property tax statute, 50 IAC, the Real Property Assessment Manual, DLGF Guidelines, and IBTR/Tax Court decisions for a query. Question-shaped queries also get a cited AI answer.',
        ParameterSchema: {
          type: 'object',
          properties: { Query: { type: 'string', description: 'The search query or question.' } },
          required: ['Query'],
        },
        Handler: async (params: Record<string, unknown>): Promise<AgentToolResult> => {
          const q = validateStringParam(params['Query'], 'Query');
          if (!q.ok) return q.result;
          this.query = q.value;
          await this.runSearch();
          return { Success: true };
        },
      },
      {
        Name: 'ClearLegalResearchSearch',
        Description: 'Clear the current Legal Research query, results, and answer.',
        ParameterSchema: { type: 'object', properties: {} },
        Handler: async (): Promise<AgentToolResult> => {
          this.clearSearch();
          return { Success: true };
        },
      },
    ]);
  }
}
