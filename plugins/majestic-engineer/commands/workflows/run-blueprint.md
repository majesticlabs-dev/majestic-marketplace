---
name: majestic:run-blueprint
description: Execute all tasks in a blueprint using build-task workflow
argument-hint: "<blueprint-file.md>"
---

# Run Blueprint

Execute all tasks in a blueprint plan sequentially, respecting dependencies.

## Input

```
plan_path: $ARGUMENTS (required)
```

## Workflow

### 1. Start Ralph Loop

```
/majestic-ralph:ralph-loop "complete all blueprint tasks" --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

### 2. Load Blueprint

```
Read(file_path: plan_path)
```

Parse the `## Implementation Tasks` section:

| ID | Task | Points | Dependencies | Status |
|----|------|--------|--------------|--------|
| T1 | Setup auth middleware | 2 | - | ⏳ |
| T2 | Create login endpoint | 2 | T1 | ⏳ |

**Task status icons:**
- ⏳ Pending
- 🔄 In Progress
- ✅ Completed
- 🔴 Failed

### 3. Find Next Task

```
For each task in Implementation Tasks:
  If task.status == ⏳:
    If task.dependencies all ✅:
      NEXT_TASK = task
      Break
```

If no task found (all ✅ or 🔴): Go to Step 6.

### 4. Execute Task

```
/majestic:build-task "{task.id}" --no-ship
```

### 5. Update Status

```
Edit(file_path: plan_path):
  If build succeeded: task.status = ✅
  If build failed: task.status = 🔴
```

Go to Step 3 (next task).

### 6. Ship

When all tasks are ✅ or 🔴:

```
/majestic:ship-it
```

### 7. Complete

Output completion promise:

```
<promise>RUN_BLUEPRINT_COMPLETE</promise>
```

## Task ID Formats

| System | Format | Example |
|--------|--------|---------|
| GitHub Issues | `#{number}` | `#123` |
| Linear | `{PROJECT}-{number}` | `PROJ-123` |
| Beads | `BEADS-{number}` | `BEADS-123` |
| File-based | `TODO-{number}` | `TODO-123` |

## Error Handling

| Scenario | Action |
|----------|--------|
| Task build fails | Mark 🔴, continue to next task |
| All dependencies failed | Skip task, mark 🔴 |
| Blueprint file not found | Error, exit |
| No tasks section found | Error, exit |
