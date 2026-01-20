---
name: majestic-relay:work
description: Execute epic tasks with fresh-context Claude instances and quality gate verification
argument-hint: "[task_id] [--max-attempts N]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/relay-work.sh:*)
---

# Execute Epic Tasks

Run pending tasks from `.agents-os/relay/epic.yml` using fresh Claude instances per task. Each task must pass quality gate verification before completion.

## Input

```
<arguments> $ARGUMENTS </arguments>

Options:
  [task_id]         Run specific task only (e.g., T2)
  --max-attempts N  Override max attempts per task
```

## Prerequisites

```
If not exists(".agents-os/relay/epic.yml"):
  Error: "No epic found. Run `/relay:init <blueprint.md>` first."
  Exit

If not exists(".agents-os/relay/attempt-ledger.yml"):
  Error: "Ledger missing. Run `/relay:init <blueprint.md>` to reinitialize."
  Exit
```

## Execute

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/relay-work.sh" $ARGUMENTS
```

## How It Works

The shell script orchestrates task execution:

```
┌─────────────────────────────────────────────────────────┐
│                   relay-work.sh                         │
│                                                         │
│  1. Find next unblocked, ungated task                  │
│  2. Check attempt count (gate if exceeded)             │
│  3. Build re-anchoring prompt                          │
│  4. Spawn fresh Claude: claude -p --output-format json │
│  5. Parse structured result with jq                    │
│  6. Run quality-gate agent (mandatory):                │
│     - Verifies acceptance criteria                     │
│     - Runs configured reviewers from .agents.yml       │
│     - Returns: APPROVED | NEEDS CHANGES | BLOCKED      │
│  7. Handle verdict:                                    │
│     - APPROVED → Mark complete                         │
│     - NEEDS CHANGES → Retry with findings              │
│     - BLOCKED → Gate task                              │
│  8. Loop until all tasks complete or blocked           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Re-anchoring Context

Each fresh Claude instance receives:

- Current git state (branch, last commit, uncommitted changes)
- Epic summary
- Task details (files, acceptance criteria)
- Dependencies status
- Previous attempt receipts (if any)

This prevents context drift and ensures each task starts with fresh awareness.

## Structured Output

Claude instances are invoked with `--output-format json --json-schema`, returning:

```json
{
  "status": "success" | "failure",
  "summary": "Brief description",
  "files_changed": ["file1.rb", "file2.rb"],
  "error_category": "missing_dependency",
  "suggestion": "What to try differently"
}
```

The shell script parses this with `jq` to update the ledger.

## Attempt Gating

Tasks are gated (blocked from retry) when:

- Max attempts exceeded (default: 3)
- Same error repeated with same approach

Gated tasks require manual intervention:
1. Fix the underlying issue
2. Remove from `gated_tasks` in ledger
3. Re-run `/relay:work`

## Output

```
🚀 Starting epic: 20260111-user-authentication

[T1] Create users table migration
     Attempt 1/3...
     🔍 Running quality gate...
     ✅ Quality gate: APPROVED
     ✅ Task complete

[T2] Add login form component
     Attempt 1/3...
     🔍 Running quality gate...
     ⚠️ Quality gate: NEEDS CHANGES
     ❌ Failed: Quality gate requires changes
     Attempt 2/3...
     🔍 Running quality gate...
     ✅ Quality gate: APPROVED
     ✅ Task complete

[T3] Implement password hashing
     Attempt 1/3...
     🔍 Running quality gate...
     🛑 Quality gate: BLOCKED
     (Task gated - critical security issue)

⏸️ No executable tasks remaining
   Completed: 2/3
   Gated: 1 tasks
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No pending tasks | Check for gated tasks, report status |
| All tasks blocked | Report dependency chain, suggest manual fix |
| Claude instance fails | Record failure receipt, retry or gate |
| Quality gate: NEEDS CHANGES | Record findings, retry with feedback |
| Quality gate: BLOCKED | Gate task immediately (critical issue) |
| Ctrl+C interrupt | Save current state, exit cleanly |

## Notes

- Tasks execute sequentially (one at a time)
- Each task gets a fresh Claude context
- Progress persists in `.agents-os/relay/attempt-ledger.yml`
- Can resume anytime with `/relay:work`
