---
name: attempt-ledger
description: "Track task execution attempts, gate infinite retries, and persist failure context across relay sessions. Use when implementing retry logic, limiting task attempts, resuming interrupted epics, or debugging repeated failures."
---

# Attempt Ledger Pattern

Track execution attempts for tasks within relay epics, enabling retry with context, gating of stuck tasks, and progress persistence across sessions.

See [references/schemas.md](references/schemas.md) for full YAML schemas (epic, ledger, receipts).

## Gating Rules

Tasks are gated (blocked from retry) when:

| Condition | Gating Action |
|-----------|---------------|
| `attempts >= max_attempts` | Gate with `max_attempts_exceeded` |
| Same error repeated 2+ times | Gate with `repeated_failure` |
| Quality gate returns BLOCKED | Gate with `quality_gate_blocked` |
| Manual block by user | Gate with `user_blocked` |

## Task Status Flow

```
pending → in_progress → completed
              ↓
          failure → pending (retry)
              ↓
          max_attempts → gated
```

## Compound Learning

After each attempt (success or failure), extract:
- **learning**: one-sentence reusable insight
- **pattern_tags**: comma-separated tags for grouping

### Epic Completion Flow

1. Read all learnings from ledger
2. Consolidate similar patterns by semantic meaning
3. Apply frequency thresholds: 1x skip, 2x emerging, 3x recommend, 4+ strong signal
4. Promote to AGENTS.md Key Learnings
5. Clear learnings from ledger after promotion

Learnings are temporary working memory; AGENTS.md is the permanent store.

## Re-anchoring Context

Each fresh Claude instance receives:

1. **Git state:** current branch, last commit, uncommitted changes
2. **Epic context:** title, description, overall progress
3. **Task details:** files, acceptance criteria, dependencies
4. **Previous receipts:** what was tried, what failed, why

## Commands

| Command | Purpose |
|---------|---------|
| `/majestic-relay:init` | Create epic and ledger from blueprint |
| `/majestic-relay:status` | Show progress and gated tasks |
| `/majestic-relay:work` | Execute tasks with attempt tracking |

## Defaults

- `max_attempts_per_task: 3` — retry limit before gating
- `timeout_minutes: 15` — max execution time per task
- Override at runtime with `--max-attempts N`
