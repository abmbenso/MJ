/**
 * Pure derivation of the rendered Legal Research answer (text + citation chips) or an
 * error message from a `RunAIAgent` result. No Angular, no DOM, no network -- kept
 * separate from the component so it's directly vitest-testable against a realistic mock
 * of the real `ExecuteAgentResult` shape (see __tests__/legal-research-answer.test.ts,
 * built from a real, live CLI-driven run of the actual "Legal Research" agent).
 */

/** Matches the `[CITE: <citation key>]` inline marker the Legal Research agent's own
 * system prompt (metadata/prompts/templates/indiana-legal-research/system-prompt.md)
 * is instructed to emit after every substantive claim. */
export const CITE_RE = /\[CITE:\s*([^\]]+)\]/g;

/** One `[CITE: ...]` token pulled out of an agent answer -- unresolved until the user
 * clicks it, then hydrated from Legal Authority Sections (see the component's
 * openCitation). */
export interface CitationChip {
  key: string;
  resolved?: { heading: string; text: string };
}

/**
 * The subset of `ExecuteAgentResult` (`@memberjunction/ai-core-plus`) this module reads.
 * A Loop-type agent with no structured-payload-writing tools -- which Legal Research is
 * -- puts its user-facing prose on `agentRun.Message`, NOT `payload` (`payload` is a
 * structured-data field for agents that mutate structured state via tools; confirmed
 * against base-agent.ts, `this._agentRun.Message = finalStep.message`, and against the
 * repo's only other RunAIAgent consumer, ai-test-harness.component.ts's
 * `fullResult.agentRun?.Message`). Narrowed to just the two fields this module needs so
 * tests construct a plain object instead of a full MJAIAgentRunEntityExtended.
 */
export interface AgentAnswerSource {
  success: boolean;
  agentRun?: { Message?: string | null; ErrorMessage?: string | null } | null;
}

export interface AgentAnswer {
  answerText: string;
  answerChips: CitationChip[];
  /** Non-null exactly when the agent run failed -- surfaced instead of silently
   * returning an empty answer with no explanation. */
  errorMessage: string | null;
}

export function parseCitationChips(text: string): CitationChip[] {
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

export function deriveAgentAnswer(result: AgentAnswerSource): AgentAnswer {
  if (!result.success) {
    return {
      answerText: '',
      answerChips: [],
      errorMessage: result.agentRun?.ErrorMessage || 'The Legal Research agent failed to answer this question.',
    };
  }

  const message = result.agentRun?.Message ?? '';
  return {
    answerText: message.replace(CITE_RE, '').trim(),
    answerChips: parseCitationChips(message),
    errorMessage: null,
  };
}
