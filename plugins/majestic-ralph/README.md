# majestic-ralph

Autonomous AI coding loops for Claude Code. Ship features while you sleep.

## Overview

Ralph Loop creates a **self-referential feedback loop** where:
- A single prompt never changes between iterations
- Your previous work persists in files and git history
- Each iteration sees modified files and improves upon them
- Learnings compound in a progress file across iterations

## Installation

```bash
claude plugins add majestic-ralph
```

## Commands

| Command | Description |
|---------|-------------|
| `/majestic-ralph:start "<prompt>"` | Start an autonomous iteration loop |
| `/majestic-ralph:cancel` | Stop the active loop |
| `/majestic-ralph:help` | Show help and best practices |

## Quick Start

```bash
# Basic autonomous loop
/majestic-ralph:start "Build a login form with validation. Output <promise>DONE</promise> when complete." --max-iterations 20 --completion-promise "DONE"

# With blueprint integration
/majestic-ralph:start "/majestic:run-blueprint docs/plans/add-auth.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## Options

- `--max-iterations N` - Safety limit (recommended: 10-50)
- `--completion-promise "<text>"` - Phrase that signals genuine completion

## Files

| File | Purpose | Git |
|------|---------|-----|
| `.claude/ralph-loop.local.md` | Loop state (iteration, prompt) | Ignored |
| `.claude/ralph-progress.local.yml` | Patterns and story log | Ignored |

## Progress File

Learnings compound across iterations via `.claude/ralph-progress.local.yml`:

```yaml
patterns:
  migrations: "Use IF NOT EXISTS for all column additions"
  forms: "Zod schema validation"
  auth: "Server actions in actions.ts"

stories:
  - id: US-001
    title: Add login form
    completed_at: 2024-01-15T10:45:00Z
    files:
      - app/login/page.tsx
    learnings:
      - "Form validation uses zod"
```

**Workflow:**
1. Read patterns before each iteration
2. Update after completing each story
3. Promote valuable patterns to AGENTS.md at loop end

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
- Document blockers
- List attempts
- Suggest alternatives"
```

## When to Use

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration (getting tests to pass)
- Greenfield projects you can walk away from
- Tasks with automatic verification (tests, linters)

**Not good for:**
- Tasks requiring human judgment
- Production debugging
- Unclear success criteria

## Monitoring

```bash
# Check iteration
grep '^iteration:' .claude/ralph-loop.local.md

# View patterns
cat .claude/ralph-progress.local.yml

# Cancel loop
/majestic-ralph:cancel
```

## What Makes This Different

| Feature | Other Implementations | majestic-ralph |
|---------|----------------------|----------------|
| **Progress format** | Markdown (unstructured) | YAML (structured, parseable) |
| **Git handling** | Committed to history | Gitignored → promotes to AGENTS.md |
| **Pattern access** | Buried in narrative | Top-level `patterns:` key |
| **Blueprint integration** | None | Built-in via `/majestic:run-blueprint` |
| **Ecosystem** | Standalone | Integrates with majestic-engineer workflows |

### Key Innovation: Ephemeral → Permanent Memory

```
During loop:     .claude/ralph-progress.local.yml  (gitignored, working memory)
                              ↓
After loop:      AGENTS.md patterns section         (committed, permanent)
```

Learnings compound during the loop, then valuable patterns promote to permanent documentation.

## Credits

Original technique: [Geoffrey Huntley](https://ghuntley.com/ralph)

## Contents

- **Commands:** 3 (`start`, `cancel`, `help`)
- **Skills:** 1 (ralph-methodology)
- **Hooks:** 1 (stop hook for loop continuation)
