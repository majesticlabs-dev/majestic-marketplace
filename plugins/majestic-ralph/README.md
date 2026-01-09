# majestic-ralph

Autonomous AI coding loops for Claude Code. Ship features while you sleep.

## Overview

Ralph Loop creates a **self-referential feedback loop** where:
- A single prompt never changes between iterations
- Your previous work persists in files and git history
- Each iteration sees modified files and improves upon them

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

## State File

Location: `.claude/ralph-loop.local.yml` (gitignored)

```yaml
iteration: 1
max_iterations: 50
completion_promise: DONE
started_at: 2024-01-15T10:30:00Z
prompt: |
  Your prompt here.
```

## Monitoring

```bash
# Check iteration
grep '^iteration:' .claude/ralph-loop.local.yml

# Cancel loop
/majestic-ralph:cancel
```

---

## Best Practices

### 1. Small, Focused Tasks

```
✅ "Add login form with email validation"
❌ "Build entire auth system"
```

**Heuristic:** If you can't verify it with a single test run, it's too big.

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
- Suggest alternatives
- Output <promise>BLOCKED</promise>"
```

### 4. Idempotent Operations

```sql
-- Always use IF NOT EXISTS for migrations
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
```

### 5. Non-Interactive Commands

```bash
# Pipe input to avoid interactive prompts
echo -e "\n\n\n" | npm run db:generate

# Use --yes flags where available
npm init -y
```

## Prompt Templates

### Basic Autonomous Loop

```
Implement: [TASK TITLE]

Acceptance Criteria:
- [Criterion 1]
- [Criterion 2]
- typecheck passes
- tests pass

Output <promise>COMPLETE</promise> when ALL criteria met.
```

### With TDD

```
Implement [FEATURE] following TDD:
1. Write failing tests first
2. Implement minimum code to pass
3. Run typecheck and tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green

Output <promise>COMPLETE</promise> when tests pass.
```

### With Escape Hatch

```
Implement [FEATURE].

After 15 iterations, if not complete:
- Document what's blocking progress
- List approaches attempted
- Suggest alternatives
- Output <promise>BLOCKED</promise>

Otherwise, output <promise>COMPLETE</promise> when done.
```

### Multi-Phase

```
Build [SYSTEM] in phases:

Phase 1: [Component A] - tests passing
Phase 2: [Component B] - tests passing
Phase 3: [Integration] - all tests passing

Output <promise>COMPLETE</promise> when all phases done.
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
- Major refactors needing architecture decisions
- Security-critical changes

## Integration with Blueprints

Use Ralph with `/majestic:run-blueprint` for multi-task features:

```bash
# Just run this - ralph is auto-launched
/majestic:run-blueprint docs/plans/add-auth.md
```

**The blueprint provides:**
- Task breakdown with dependencies (T1, T2, T3...)
- Acceptance criteria as checkboxes per task
- Status markers (⏳ 🔄 ✅ 🔴) updated during execution
- Learnings captured to closest AGENTS.md after each task
- Quality gates per task
- Batch shipping at end

**Progress tracking:** The looped agent (run-blueprint) tracks progress in the blueprint file. Ralph only manages the loop itself.

## What Makes This Different

| Feature | Other Implementations | majestic-ralph |
|---------|----------------------|----------------|
| **Responsibility** | Manages stories/patterns | Pure loop mechanism |
| **Progress tracking** | In ralph's files | In the looped agent |
| **State format** | Markdown | YAML (parseable) |
| **Blueprint integration** | None | Built-in via `/majestic:run-blueprint` |
| **Ecosystem** | Standalone | Integrates with majestic-engineer workflows |

### Key Principle: Ralph is Just a Loop

```
What Ralph IS:
┌─────────────────────────────────┐
│ 1. Start with prompt            │
│ 2. Check: completion promise?   │
│    YES → Exit                   │
│    NO  → Re-feed same prompt    │
│ 3. Repeat until max iterations  │
└─────────────────────────────────┘

What Ralph DOESN'T know:
- Stories, tasks, sprints, points
- Acceptance criteria format
- Testing methodology
- Progress tracking details
```

Progress tracking belongs to the looped agent (e.g., run-blueprint), not ralph.

## Credits

Original technique: [Geoffrey Huntley](https://ghuntley.com/ralph)

## Contents

- **Commands:** 3 (`start`, `cancel`, `help`)
- **Skills:** 1 (ralph-methodology)
- **Hooks:** 1 (stop hook for loop continuation)
