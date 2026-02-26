---
name: plan-exit-review
description: >
  Use when reviewing a plan before implementation begins. Not for autonomous
  plan analysis — use plan-review agent instead. Challenges scope, walks through
  architecture/quality/tests/performance interactively with mandatory user
  checkpoints and opinionated recommendations.
version: 1.0.0
allowed-tools: Read Grep Glob AskUserQuestion
triggers:
  - review plan before coding
  - plan exit review
  - check plan before implementation
  - gate check before building
---

# Plan Exit Review

**Audience:** Engineers about to start implementation.
**Goal:** Catch scope creep, missing coverage, and design flaws interactively before writing code.

## Priority Hierarchy

If running low on context or user asks to compress:
Step 0 > Test diagram > Opinionated recommendations > Everything else.
Never skip Step 0 or the test diagram.

## Engineering Principles

These guide all recommendations:

- DRY — flag repetition aggressively
- Well-tested — rather too many tests than too few
- Engineered enough — not under-engineered (fragile) or over-engineered (premature abstraction)
- Handle more edge cases, not fewer — thoughtfulness > speed
- Explicit over clever
- Minimal diff — achieve the goal with fewest new abstractions and files touched
- Complexity proportional to the problem

## Diagrams

- Use ASCII diagrams liberally for data flow, state machines, dependency graphs, pipelines, decision trees
- When modifying code with existing ASCII diagrams nearby, verify accuracy and update in the same commit
- Stale diagrams are worse than no diagrams — they actively mislead

## Step 0: Scope Challenge (Mandatory)

Before reviewing anything, answer:

1. **What existing code already solves each sub-problem?** Can we capture outputs from existing flows rather than building parallel ones?
2. **What is the minimum set of changes that achieves the stated goal?** Flag work that could be deferred without blocking the core objective. Be ruthless about scope creep.
3. **Complexity check:** If plan touches >8 files or introduces >2 new classes/services, treat as a smell and challenge whether the same goal can be achieved with fewer moving parts.

Then AskUserQuestion with three tracks:

1. **SCOPE REDUCTION** — Plan is overbuilt. Propose a minimal version that achieves the core goal, then review that.
2. **BIG CHANGE** — Work through interactively, one section at a time (Architecture > Code Quality > Tests > Performance) with at most 4 top issues per section.
3. **SMALL CHANGE** — Compressed review: Step 0 + one combined pass covering all 4 sections. Pick the single most important issue per section. Present as a single numbered list with lettered options + mandatory test diagram + completion summary. One AskUserQuestion round at the end.

**If user does not select SCOPE REDUCTION, respect that decision fully.** Raise scope concerns once in Step 0 — after that, commit to the chosen scope and optimize within it. Do not silently reduce scope, skip planned components, or re-argue for less work.

## Review Sections (After Scope Is Agreed)

### 1. Architecture Review

Evaluate:
- System design and component boundaries
- Dependency graph and coupling concerns
- Data flow patterns and potential bottlenecks
- Scaling characteristics and single points of failure
- Security architecture (auth, data access, API boundaries)
- Whether key flows deserve ASCII diagrams in the plan or code comments
- For each new codepath or integration point: one realistic production failure scenario and whether the plan accounts for it

**STOP.** Call AskUserQuestion with findings. Do NOT proceed until user responds.

### 2. Code Quality Review

Evaluate:
- Code organization and module structure
- DRY violations — be aggressive
- Error handling patterns and missing edge cases (call out explicitly)
- Technical debt hotspots
- Over-engineered or under-engineered areas
- Existing ASCII diagrams in touched files — still accurate after this change?

**STOP.** Call AskUserQuestion with findings. Do NOT proceed until user responds.

### 3. Test Review

Make a diagram of all new UX, new data flow, new codepaths, and new branching outcomes. For each, note what is new. Then for each new item, verify a test exists.

**STOP.** Call AskUserQuestion with findings. Do NOT proceed until user responds.

### 4. Performance Review

Evaluate:
- N+1 queries and database access patterns
- Memory-usage concerns
- Caching opportunities
- Slow or high-complexity code paths

**STOP.** Call AskUserQuestion with findings. Do NOT proceed until user responds.

## Issue Presentation Format

For every issue found:

1. Describe the problem concretely with file and line references
2. Present 2-3 options including "do nothing" where reasonable
3. For each option: effort, risk, maintenance burden (one line)
4. **Lead with recommendation as directive:** "Do B. Here's why:" — not "Option B might be worth considering"
5. Map reasoning to a specific engineering principle above

AskUserQuestion format:
- Start: "We recommend [LETTER]: [one-line reason]"
- List: `A) ... B) ... C) ...`
- Label: issue NUMBER + option LETTER (e.g., "3B")
- Recommended option listed first
- One sentence max per option

## Required Outputs

### NOT In Scope

List work considered and explicitly deferred, with one-line rationale per item.

### What Already Exists

List existing code/flows that partially solve sub-problems. Note whether plan reuses them or unnecessarily rebuilds.

### TODOS.md Updates

Deferred work that would meaningfully improve the system. Each entry:
- **What:** One-line description
- **Why:** Concrete problem it solves (not "nice to have")
- **Context:** Enough detail for someone in 3 months to understand motivation, current state, where to start
- **Depends on / blocked by:** Prerequisites or ordering constraints

Ask user which deferred items to capture before writing. A TODO without context is worse than no TODO.

### Failure Modes

For each new codepath from the test diagram, list one realistic failure (timeout, nil reference, race condition, stale data) and whether:
1. A test covers that failure
2. Error handling exists
3. User sees a clear error or silent failure

If any failure mode has no test AND no error handling AND would be silent: flag as **critical gap**.

### Completion Summary

```
- Step 0: Scope Challenge (user chose: ___)
- Architecture Review: ___ issues found
- Code Quality Review: ___ issues found
- Test Review: diagram produced, ___ gaps identified
- Performance Review: ___ issues found
- NOT in scope: written
- What already exists: written
- TODOS.md updates: ___ items proposed
- Failure modes: ___ critical gaps flagged
```

## Retrospective Learning

Check git log for the branch. If prior commits suggest a previous review cycle (review-driven refactors, reverted changes), note what changed and whether the current plan touches the same areas. Be more aggressive reviewing previously problematic areas.

## Unresolved Decisions

If user does not respond to an AskUserQuestion or interrupts to move on, note which decisions were left unresolved. At the end, list as "Unresolved decisions that may bite you later" — never silently default to an option.
