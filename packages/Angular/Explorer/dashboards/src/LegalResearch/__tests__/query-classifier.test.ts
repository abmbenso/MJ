import { describe, it, expect } from 'vitest';
import { classifyQuery } from '../query-classifier';

describe('classifyQuery', () => {
  it('treats a bare citation as a lookup', () => {
    expect(classifyQuery('IC 6-1.1-15-17.2')).toBe('lookup');
    expect(classifyQuery('50 IAC 26-2-2')).toBe('lookup');
  });

  it('treats a short keyword phrase as a lookup', () => {
    expect(classifyQuery('burden of proof')).toBe('lookup');
    expect(classifyQuery('purchase price evidence')).toBe('lookup');
  });

  it('treats a question mark as a question', () => {
    expect(classifyQuery('Does a 6% AV increase shift the burden of proof?')).toBe('question');
  });

  it('treats a wh-/aux-word opener as a question even without a question mark', () => {
    expect(classifyQuery('what evidence shifts the burden of proof')).toBe('question');
    expect(classifyQuery('can the assessor use my purchase price against me')).toBe('question');
    expect(classifyQuery('does obsolescence apply to a vacant building')).toBe('question');
  });

  it('treats a long natural-language sentence as a question even without a trigger word', () => {
    expect(classifyQuery('my assessment went up more than five percent this year and I want to know what that means for who has to prove what')).toBe('question');
  });
});
