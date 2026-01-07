---
name: majestic-ralph:help
description: Explain Ralph Loop plugin and available commands
---

# Ralph Loop Help

Ralph Loop is an autonomous AI coding system that ships features while you sleep.

## Core Concept

A **self-referential feedback loop** where:
- A single prompt never changes between iterations
- Your previous work persists in files and git history
- Each iteration sees modified files and improves upon them
- Learnings compound in progress file across iterations

## Available Commands

| Command | Purpose |
|---------|---------|
| `/majestic-ralph:start "<prompt>"` | Start an iteration loop |
| `/majestic-ralph:cancel` | Stop the active loop |
| `/majestic-ralph:help` | This help message |

## Quick Start

```bash
# Start a loop with completion promise
/majestic-ralph:start "Build a login form with validation. Output <promise>DONE</promise> when complete." --max-iterations 20 --completion-promise "DONE"
```

## Key Options

- `--max-iterations N` - Safety limit (recommended: 10-50)
- `--completion-promise "TEXT"` - Phrase that signals genuine completion

## Files

| File | Purpose |
|------|---------|
| `.claude/ralph-loop.local.md` | Loop state (iteration, prompt) |
| `.claude/ralph-progress.local.yml` | Patterns and story log |

Both are gitignored (`.local.` suffix).

## Progress File

Read at start of each iteration, update after completing work:

```yaml
patterns:
  migrations: "Use IF NOT EXISTS"
  forms: "Zod validation"

stories:
  - id: US-001
    title: Add login form
    files: [app/login/page.tsx]
    learnings:
      - "Submit handler in separate action"
```

Promote valuable patterns to AGENTS.md at loop end.

## Best Practices

### 1. Small, Focused Tasks
```
✅ "Add login form with email validation"
❌ "Build entire auth system"
```

### 2. Explicit Completion Criteria
```
"Implement feature X:
- Acceptance criteria 1
- Acceptance criteria 2
- Tests passing
Output <promise>COMPLETE</promise> when ALL criteria met."
```

### 3. Include Escape Hatches
```
"After 15 iterations, if not complete:
- Document what's blocking progress
- List what was attempted
- Suggest alternative approaches"
```

### 4. Use with Blueprints
```bash
/majestic-ralph:start "/majestic:run-blueprint docs/plans/feature.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## When to Use Ralph

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration (getting tests to pass)
- Greenfield projects you can walk away from
- Tasks with automatic verification (tests, linters)

**Not good for:**
- Tasks requiring human judgment/design decisions
- One-shot operations
- Unclear success criteria
- Production debugging

## Monitoring Progress

```bash
# Check current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# View accumulated patterns
cat .claude/ralph-progress.local.yml
```

## Philosophy

| Principle | Description |
|-----------|-------------|
| **Iteration > Perfection** | Don't aim for perfect first try; let the loop refine |
| **Failures Are Data** | Each failure informs the next attempt |
| **Learnings Compound** | By iteration 10, patterns from 1-9 are visible |
| **Persistence Wins** | Keep trying until genuine success |

## Reference

Original technique: [ghuntley.com/ralph](https://ghuntley.com/ralph)
