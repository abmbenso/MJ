// Decides whether a Legal Research query should also invoke the answer-synthesis agent
// (a question) or just run the ranked Search Scope query (a citation/keyword lookup).
// No existing MJ utility does this classification; kept intentionally simple and tested
// rather than imported from elsewhere.

const QUESTION_OPENERS = /^(what|when|where|why|who|how|which|does|do|did|is|are|was|were|can|could|should|would|will)\b/i;
const CITATION_RE = /^(ic\s+\d|50\s*iac\b)/i;
const WORD_COUNT_THRESHOLD = 12;

export function classifyQuery(query: string): 'question' | 'lookup' {
  const trimmed = query.trim();
  if (!trimmed) return 'lookup';
  if (CITATION_RE.test(trimmed)) return 'lookup';
  if (trimmed.endsWith('?')) return 'question';
  if (QUESTION_OPENERS.test(trimmed)) return 'question';
  const wordCount = trimmed.split(/\s+/).length;
  if (wordCount > WORD_COUNT_THRESHOLD) return 'question';
  return 'lookup';
}
