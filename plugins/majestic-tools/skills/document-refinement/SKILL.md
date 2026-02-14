---
name: document-refinement
description: Use when reviewing brainstorms, plans, or PRDs for clarity and readiness before next workflow phase. Assesses documents for vagueness, gaps, and YAGNI violations.
---

# Document Refinement

Structured review to answer: "Is this document clear and ready for the next phase?"

**Audience:** Engineers reviewing brainstorm outputs, plans, or PRDs before handoff.
**Goal:** Catch vagueness and gaps early. Auto-fix minor issues, flag substantive ones.

## Assessment Criteria

Score each 1-5:

| Criterion | 1 (Fail) | 3 (Acceptable) | 5 (Excellent) |
|-----------|----------|-----------------|---------------|
| **Clarity** | Vague language, undefined terms | Mostly clear, few ambiguities | Every statement is actionable and specific |
| **Completeness** | Missing required sections | Has all sections, some thin | All sections substantive with no gaps |
| **Specificity** | "Handle errors appropriately" | Some concrete details | Exact behaviors, values, and boundaries defined |
| **YAGNI** | Speculative features, gold-plating | Minor scope creep | Every item traces to a stated requirement |
| **User Intent Fidelity** | Drifted from original request | Mostly aligned | Precisely captures what user asked for |

## Review Protocol

```
DOCUMENT = read target document
DOC_TYPE = classify(DOCUMENT) → brainstorm | plan | prd | other
REQUIREMENTS = load resources/document-type-requirements.md[DOC_TYPE]
VAGUE_PATTERNS = load resources/vague-language-patterns.md

Step 1: Structural Check
  For each REQUIRED_SECTION in REQUIREMENTS[DOC_TYPE].sections:
    If REQUIRED_SECTION missing from DOCUMENT:
      findings.blocking.append({type: "missing_section", section: REQUIRED_SECTION})

Step 2: Vagueness Scan
  For each LINE in DOCUMENT:
    If LINE matches VAGUE_PATTERNS.qualifier_words OR VAGUE_PATTERNS.hedge_phrases:
      If context is risk-identification OR explicit-deferral:
        skip (acceptable vagueness)
      Else if fix is obvious (simple word replacement):
        auto_fixes.append({line: LINE, fix: replacement})
      Else:
        findings.blocking.append({type: "vague_language", line: LINE, suggestion: "specify X"})

Step 3: Criteria Scoring
  For each CRITERION in [Clarity, Completeness, Specificity, YAGNI, User Intent Fidelity]:
    score[CRITERION] = assess(DOCUMENT, CRITERION) → 1-5
    If score[CRITERION] < 3:
      findings.blocking.append({type: "low_score", criterion: CRITERION, details: "..."})

Step 4: Categorize Findings
  blocking = findings where score < 3 OR missing required sections
  polish = findings where score 3-4 (improvable but not blocking)
```

## Output Format

```markdown
## Document Refinement Report

**Document:** [filename or title]
**Type:** [brainstorm | plan | prd]
**Verdict:** READY | NEEDS REVISION

### Scores
| Criterion | Score | Notes |
|-----------|-------|-------|
| Clarity | X/5 | ... |
| Completeness | X/5 | ... |
| Specificity | X/5 | ... |
| YAGNI | X/5 | ... |
| User Intent Fidelity | X/5 | ... |

### Auto-Fixed (applied)
- [Line X]: "should handle" → "returns 422 with error message"

### Blocking Issues
1. [Issue]: [What's wrong] → [What to specify]

### Polish Suggestions
- [Improvement that would raise score but isn't blocking]
```

## Iteration Rules

```
MAX_ROUNDS = 2

If VERDICT == "NEEDS REVISION":
  Apply auto-fixes directly to document
  Present blocking issues to user
  User addresses blocking issues
  Re-run assessment (round 2)

If round 2 still has blocking issues:
  Present remaining issues
  Ask user: "Ship as-is or address remaining items?"
  Do NOT run round 3 (diminishing returns)
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Instead |
|--------------|----------------|---------|
| Reviewing implementation code | This skill is for documents, not code | Use code-review or plan-review |
| Scoring every line | Over-analysis kills velocity | Focus on section-level assessment |
| Blocking on style preferences | "I'd phrase it differently" isn't a gap | Only block on missing information or ambiguity |
| Expanding scope during review | "You should also add X" | Only flag what's missing per doc-type requirements |
| Perfect scores required | 3/5 on all criteria = ready to proceed | Block only on scores below 3 |
