---
name: auto-decision-framework
description: Framework for automated decision-making during multi-step planning workflows. Classifies planning decisions as Mechanical (auto-decide silently), Taste (auto-decide but surface at gate), or User Challenge (never auto-decide). Reduces question fatigue by batching only decisions that need human judgment. Use when running blueprint, PRD, refactor-plan, or any workflow that asks 5+ intermediate planning questions.
triggers:
  - plan automatically
  - make planning decisions for me
  - blueprint without asking me everything
  - plan without asking me everything
---

# Auto-Decision Framework

**Audience:** Engineers running multi-step planning workflows who want fewer interruptions without losing oversight.

**Goal:** Reduce 15-30 intermediate questions to 3-5 that actually need human judgment, while maintaining a full audit trail of automated decisions.

## When to Apply

Apply this framework when orchestrating any multi-step planning workflow where intermediate decisions would otherwise interrupt the user repeatedly. The workflow must still perform full analysis at each step — auto-decision replaces the user's answer, not the analysis.

Compatible workflows: blueprint, PRD, refactor-plan, architecture planning, or any custom multi-phase planning process.

Do not apply this framework to code review, quality gates, autonomous build/ship workflows, or any flow with an existing verdict/status contract.

## The 6 Decision Principles

Use these to auto-answer intermediate questions. When principles conflict, use the tiebreaker rules below.

### P1: Choose Completeness

Ship the whole thing. Pick the approach that covers more edge cases, handles more error paths, tests more scenarios. The marginal cost of completeness with AI assistance is near-zero.

Apply when: choosing between partial and full implementations, deciding test coverage scope, selecting how many edge cases to handle.

### P2: Blast Radius Coverage

Cover the full implementation blast radius — components directly affected by the plan plus their direct dependents. Auto-approve expansions only when they stay inside that blast radius AND remain clearly small (for example, fewer than 5 files or one adjacent module, and no new infrastructure).

Apply when: deciding whether to include adjacent work discovered during planning, scoping related cleanup work.

### P3: Pragmatic

If two options fix the same thing, pick the cleaner one. Spend 5 seconds choosing, not 5 minutes. Don't deliberate on equivalent alternatives.

Apply when: choosing between two viable approaches with similar tradeoffs, picking formatting or naming conventions.

### P4: No Duplication

If a proposed solution duplicates existing functionality, reject it. Reuse what exists. Check before creating.

Apply when: evaluating whether to build a new utility, component, or helper vs. using an existing one.

### P5: Explicit Over Clever

A 10-line obvious fix beats a 200-line abstraction. Pick what a new contributor reads in 30 seconds. Straightforward code that's easy to delete later beats elegant code that's hard to understand now.

Apply when: choosing between simple and sophisticated implementations, deciding whether to add an abstraction layer.

### P6: Bias Toward Progress

Finish the plan instead of reopening settled minor questions. Flag concerns, but don't stall the planning loop on small ambiguities that implementation can safely resolve later.

Apply when: deciding whether to reopen planning for minor issues, choosing between a complete handoff and more deliberation on low-risk details.

### Tiebreaker Rules

When principles conflict, context determines which wins:

| Context | Dominant Principles |
|---------|-------------------|
| Strategy/scope decisions | P1 (completeness) + P2 (blast radius) |
| Architecture/implementation | P5 (explicit) + P3 (pragmatic) |
| Design/UX decisions | P5 (explicit) + P1 (completeness) |
| Test coverage | P1 (completeness) + P4 (no duplication) |
| Plan handoff decisions | P6 (progress) + P3 (pragmatic) |

## Decision Classification

Every auto-decision falls into exactly one class. Classification determines whether the user sees it.

### Mechanical

One clearly right answer given the principles. Auto-decide silently. Don't mention it to the user unless they request the audit trail.

Examples:
- "Run tests?" → Always yes (P1)
- "Reduce scope on a complete plan?" → Always no (P1)
- "Use existing utility vs. write new one?" → Use existing (P4)
- "Add error handling for this edge case?" → Yes (P1)

### Taste

Reasonable people could disagree. Auto-decide using the principles, but surface the decision at the final approval gate with your rationale.

Three sources of taste decisions:
- **Close approaches** — top two options are both viable with genuinely different tradeoffs
- **Borderline scope** — in blast radius but 3-5 files, or ambiguous whether it's in scope
- **Planner disagreement** — multiple research, architecture, or planning inputs recommend different approaches with valid reasoning on both sides

### User Challenge

Both the analysis AND any independent planning input agree the user's stated direction should change — merge features, split a component, add or remove something the user specified. This is qualitatively different from taste decisions because it questions the user's intent, not just implementation details.

User Challenges are NEVER auto-decided. Present them at the approval gate with:
- **What the user said:** (their original direction)
- **What the analysis recommends:** (the proposed change)
- **Why:** (the reasoning)
- **What context we might be missing:** (explicit blind-spot acknowledgment)
- **If we're wrong, the cost is:** (consequence of overriding the user incorrectly)

The user's original direction is the default. The analysis must make the case for change, not the other way around.

**Exception:** If the concern is a security vulnerability or feasibility blocker (not a preference), flag it with appropriate urgency. The user still decides, but the framing warns this is risk, not taste.

## Workflow Integration

### Before Starting

Tell the user: "I'll auto-decide obvious planning questions and batch the judgment calls for you at the end. Full audit trail available."

### During Execution

For each decision point in the planning workflow:

```
DECISION = evaluate_options(current_question)

If one option clearly wins by principles:
  classification = MECHANICAL
  action = decide silently, log to audit trail

If top options are close, or planners disagree:
  classification = TASTE
  action = decide by principles, add to approval gate batch

If analysis recommends changing user's stated direction:
  classification = USER_CHALLENGE
  action = add to approval gate batch, never auto-decide
```

The underlying analysis must still run at full depth. Auto-decision replaces the user's answer, not the work. "No issues found" is valid only after doing the analysis — state what was examined and why nothing was flagged.

### Approval Gate

After planning phases complete, present a single approval gate:

```
## Auto-Decision Summary

Mechanical decisions: N (auto-decided silently)
Taste decisions: N (auto-decided, shown below for review)
User challenges: N (require your input)

### Taste Decisions (review if you want, or approve all)
| # | Decision | Chosen | Principle | Alternative |
|---|----------|--------|-----------|-------------|
| 1 | ...      | ...    | P3        | ...         |

### User Challenges (your call)
| # | Your Direction | Recommended Change | Why | Risk if Wrong |
|---|---------------|-------------------|-----|---------------|
| 1 | ...           | ...               | ... | ...           |

[Approve all taste decisions? Y/override specific ones]
[Decision needed on each user challenge]
```

### Audit Trail

Log every auto-decision for traceability. Append to the plan or output document:

```markdown
## Decision Audit Trail

| # | Phase | Decision | Class | Principle | Rationale | Rejected Alternative |
|---|-------|----------|-------|-----------|-----------|---------------------|
| 1 | ...   | ...      | M     | P4        | ...       | ...                 |
```

Class codes: M = Mechanical, T = Taste, UC = User Challenge.

## What This Framework Does NOT Do

- Does not skip analysis steps — every section runs at full depth
- Does not compress findings into summaries — findings are reported normally
- Does not override user's explicit instructions — only auto-answers questions the workflow would have asked
- Does not apply to code review, quality-gate, build-task, ship, or other workflows with explicit verdict/status contracts
- Does not apply to one-way-door decisions (data deletion, production deploys, irreversible migrations) — those always go to the user regardless of classification
