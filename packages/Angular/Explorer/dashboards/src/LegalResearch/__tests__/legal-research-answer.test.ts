import { describe, it, expect } from 'vitest';
import { deriveAgentAnswer, parseCitationChips, AgentAnswerSource } from '../legal-research-answer';

/**
 * REAL_LEGAL_RESEARCH_MESSAGE is not invented -- it is `agentRun.Message` captured
 * verbatim from a real, live execution of the actual "Legal Research" agent against the
 * shared dev database, run via `node packages/MJCLI/bin/run.js ai agents run -a "Legal
 * Research" -p "What is the deadline to file a Form 130 property tax appeal in
 * Indiana?" -o json -v` (AgentRunner -> base-agent.ts, no MJAPI/GraphQL layer involved,
 * so this exercises the exact production code path that sets `agentRun.Message`).
 *
 * The CLI's own output (AgentService.ts) independently confirms the API shape this fix
 * relies on: it reads `executionResult.agentRun.Message` FIRST, falling back to
 * `FinalPayload` then `payload` only if Message is empty -- i.e. the same priority this
 * dashboard's deriveAgentAnswer() now follows, previously inverted (payload only).
 *
 * See the task report (FINAL-fix-report.md) for the full captured JSON, including
 * "success": true and the finalStep object this Message came from.
 */
const REAL_LEGAL_RESEARCH_MESSAGE =
  'A taxpayer must file Form 130 (Petition to the County Property Tax Assessment Board of Appeals for ' +
  'Review of Assessment) within 45 days after the county mailed the Notice of Assessment (Form 11), or, ' +
  'if no Form 11 was mailed, within 45 days after the tax statement is mailed for taxes first due and ' +
  'payable that year, whichever is applicable under the statute governing appeal deadlines ' +
  '[CITE: IC 6-1.1-15-1.1]. Note: I was unable to run a corpus search this turn (no search action was ' +
  'available to me in this session), so please treat this citation as unverified against the current ' +
  'corpus text — I\'d recommend confirming it with a fresh search before relying on it for a filing deadline.';

describe('deriveAgentAnswer', () => {
  it('extracts the answer text and citation chip from a real captured agent run (success, agentRun.Message set)', () => {
    const result: AgentAnswerSource = {
      success: true,
      agentRun: { Message: REAL_LEGAL_RESEARCH_MESSAGE, ErrorMessage: null },
    };

    const answer = deriveAgentAnswer(result);

    expect(answer.errorMessage).toBeNull();
    expect(answer.answerText.length).toBeGreaterThan(0);
    expect(answer.answerText).not.toContain('[CITE:');
    expect(answer.answerText).toContain('45 days after the county mailed the Notice of Assessment');
    expect(answer.answerChips).toEqual([{ key: 'IC 6-1.1-15-1.1' }]);
  });

  it('regression: reading `payload` instead of `agentRun.Message` (the shipped bug) would have produced nothing', () => {
    // This is the exact real ExecuteAgentResult shape RunAIAgent returns for a Loop
    // agent with no structured-payload-writing tools: `payload` is undefined. The
    // pre-fix code (`typeof result.payload !== 'string'` -> return) silently produced
    // no answer and no chips on every single question, with no error surfaced.
    const result = {
      success: true,
      payload: undefined,
      agentRun: { Message: REAL_LEGAL_RESEARCH_MESSAGE, ErrorMessage: null },
    } as AgentAnswerSource & { payload: undefined };

    expect(typeof result.payload).not.toBe('string'); // confirms the old guard would have bailed

    const answer = deriveAgentAnswer(result);
    expect(answer.answerText.length).toBeGreaterThan(0); // the fix reads Message instead
  });

  it('surfaces agentRun.ErrorMessage when the agent run fails', () => {
    const result: AgentAnswerSource = {
      success: false,
      agentRun: { Message: null, ErrorMessage: 'Model failover exhausted all candidates.' },
    };

    const answer = deriveAgentAnswer(result);

    expect(answer.errorMessage).toBe('Model failover exhausted all candidates.');
    expect(answer.answerText).toBe('');
    expect(answer.answerChips).toEqual([]);
  });

  it('falls back to a generic error message when the agent run fails with no ErrorMessage', () => {
    const result: AgentAnswerSource = { success: false, agentRun: null };

    const answer = deriveAgentAnswer(result);

    expect(answer.errorMessage).toBe('The Legal Research agent failed to answer this question.');
  });

  it('handles a success response with no Message and no citations gracefully', () => {
    const result: AgentAnswerSource = { success: true, agentRun: { Message: '', ErrorMessage: null } };

    const answer = deriveAgentAnswer(result);

    expect(answer.answerText).toBe('');
    expect(answer.answerChips).toEqual([]);
    expect(answer.errorMessage).toBeNull();
  });
});

describe('parseCitationChips', () => {
  it('dedupes repeated citation keys and trims whitespace', () => {
    const chips = parseCitationChips(
      'First point [CITE: IC 6-1.1-15-1.1]. Second point [CITE:  IC 6-1.1-15-1.1 ]. Third [CITE: 50 IAC 26-2-2].',
    );
    expect(chips).toEqual([{ key: 'IC 6-1.1-15-1.1' }, { key: '50 IAC 26-2-2' }]);
  });

  it('returns an empty array when there are no citation markers', () => {
    expect(parseCitationChips('No citations here.')).toEqual([]);
  });
});
