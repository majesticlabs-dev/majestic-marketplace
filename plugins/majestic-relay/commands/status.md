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
If not exists(".agents-os/relay/epic.yml"):
  Error: "No epic found. Run `/relay:init <blueprint.md>` first."
  Exit
```

### 2. Load State

```
EPIC = Read(".agents-os/relay/epic.yml") → parse YAML
LEDGER = Read(".agents-os/relay/attempt-ledger.yml") → parse YAML
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

If LEDGER.ended_at exists:
  Print: "Completed: {LEDGER.ended_at} ({LEDGER.duration_minutes} min)"

Progress: [████████░░░░░░░░░░░░] {percentage}%
```

### 4.5. Display Relay Status

```
RELAY_STATE = LEDGER.relay_status.state // "unknown"
RELAY_STOPPED_AT = LEDGER.relay_status.stopped_at
RELAY_EXIT_REASON = LEDGER.relay_status.last_exit_reason

If RELAY_STATE == "running":
  PID = LEDGER.relay_status.pid
  Print: "Relay: 🟢 running (PID {PID})"

Else If RELAY_STATE == "idle":
  TIME_AGO = humanize(now - RELAY_STOPPED_AT)

  REASON_ICON = {
    epic_complete: "✅",
    no_runnable_tasks: "⏸️",
    interrupted: "⚠️",
    crashed: "💥",
    error: "❌"
  }

  Print: "Relay: {REASON_ICON} {RELAY_EXIT_REASON} ({TIME_AGO} ago)"

Else:
  Print: "Relay: ⚪ never run"
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
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No epic found | Suggest running /relay:init |
| Malformed YAML | Error with parse details |
| Missing ledger | Suggest re-running /relay:init |
