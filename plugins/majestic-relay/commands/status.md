---
name: majestic-relay:status
description: Show current epic progress and task status
argument-hint: "[--verbose]"
---

# Epic Status

Display the current epic progress, task status, and any gated tasks.

## Workflow

### 1. Check for Epic

```
If not exists(".majestic/epic.yml"):
  Error: "No epic found. Run `/relay:init <blueprint.md>` first."
  Exit
```

### 2. Load State

```
EPIC = Read(".majestic/epic.yml") → parse YAML
LEDGER = Read(".majestic/attempt-ledger.yml") → parse YAML
```

### 3. Calculate Progress

```
TOTAL_TASKS = count(EPIC.tasks)
COMPLETED = count where LEDGER.task_status[task] == "completed"
IN_PROGRESS = count where LEDGER.task_status[task] == "in_progress"
BLOCKED = count where LEDGER.task_status[task] == "blocked"
GATED = count(LEDGER.gated_tasks)
PENDING = TOTAL_TASKS - COMPLETED - IN_PROGRESS - BLOCKED - GATED
```

### 4. Display Summary

```
Epic: {EPIC.id} ({COMPLETED}/{TOTAL_TASKS} tasks complete)
Source: {EPIC.source}
Started: {LEDGER.started_at}

Progress: [████████░░░░░░░░░░░░] {percentage}%
```

### 5. Display Task List

For each task in dependency order:

```
STATUS_ICON = {
  completed: "✅",
  in_progress: "🔄",
  pending: "⏳",
  blocked: "⏸️",
  gated: "🚫"
}

For each TASK_ID in EPIC.tasks:
  STATUS = LEDGER.task_status[TASK_ID]
  TITLE = EPIC.tasks[TASK_ID].title

  If STATUS == "in_progress":
    ATTEMPTS = count(LEDGER.attempts[TASK_ID])
    MAX = LEDGER.settings.max_attempts_per_task
    Print: "{ICON} {TASK_ID}: {TITLE} (attempt {ATTEMPTS}/{MAX})"

  Else If STATUS == "blocked":
    BLOCKERS = EPIC.tasks[TASK_ID].depends_on
    Print: "{ICON} {TASK_ID}: {TITLE} (blocked by {BLOCKERS})"

  Else If TASK_ID in LEDGER.gated_tasks:
    REASON = LEDGER.gated_tasks[TASK_ID].reason
    Print: "🚫 {TASK_ID}: {TITLE} (gated: {REASON})"

  Else:
    Print: "{ICON} {TASK_ID}: {TITLE}"
```

### 6. Verbose Mode (--verbose)

If `--verbose` in arguments, also show:

```
## Recent Attempts

For each TASK_ID with attempts:
  For each ATTEMPT in LEDGER.attempts[TASK_ID]:
    Print:
      Attempt {ATTEMPT.id} ({ATTEMPT.result})
      Started: {ATTEMPT.started_at}
      Ended: {ATTEMPT.ended_at}

      If ATTEMPT.receipt:
        If ATTEMPT.result == "success":
          Summary: {ATTEMPT.receipt.summary}
          Files: {ATTEMPT.receipt.files_changed}
        Else:
          Error: {ATTEMPT.receipt.error_summary}
          Suggestion: {ATTEMPT.receipt.suggestion}

## Settings

Max attempts: {LEDGER.settings.max_attempts_per_task}
Timeout: {LEDGER.settings.timeout_minutes} minutes
Review: {LEDGER.settings.review.provider} ({enabled/disabled})
```

## Output Example

```
Epic: 20260111-user-authentication (3/5 tasks complete)
Source: docs/plans/20260111_user_auth.md
Started: 2026-01-11T17:30:00Z

Progress: [████████████░░░░░░░░] 60%

✅ T1: Create users table migration
✅ T2: Add login form component
✅ T3: Implement password hashing
🔄 T4: Add session management (attempt 2/3)
⏸️ T5: Add logout endpoint (blocked by T4)
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No epic found | Suggest running /relay:init |
| Malformed YAML | Error with parse details |
| Missing ledger | Suggest re-running /relay:init |
