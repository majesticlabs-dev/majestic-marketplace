---
name: run-blueprint
description: Execute all tasks in a blueprint using build-task workflow
argument-hint: "[blueprint-file.md]"
---

# Run Blueprint

Execute all tasks in a blueprint plan sequentially, respecting dependencies.

## Input

```
plan_path: $ARGUMENTS (required)
```

## Task Tracking Setup

```
TASK_TRACKING = /majestic:config task_tracking.enabled false

If TASK_TRACKING:
  BLUEPRINT_ID = "run-blueprint-{timestamp}"
  TASK_MAP = {}  # Maps T1, T2 etc to Claude Task IDs
```

## Workflow

### 1. Load Blueprint

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

### 1.5. Create Tasks from Table (if tracking enabled)

```
If TASK_TRACKING:
  For each ROW in implementation_tasks:
    TASK = TaskCreate:
      subject: "{ROW.id}: {ROW.task}"
      activeForm: "Building {ROW.task}"
      metadata: {blueprint_id: BLUEPRINT_ID, task_id: ROW.id, points: ROW.points, source: plan_path}
    TASK_MAP[ROW.id] = TASK.id

  # Set up dependencies
  For each ROW in implementation_tasks where ROW.dependencies != "-":
    BLOCKED_BY = [TASK_MAP[dep] for dep in ROW.dependencies.split(",")]
    TaskUpdate(TASK_MAP[ROW.id], addBlockedBy: BLOCKED_BY)
```

### 2. Find Next Task

```
If TASK_TRACKING:
  TASKS = TaskList()
  BLUEPRINT_TASKS = filter(TASKS, task.metadata.blueprint_id == BLUEPRINT_ID)
  NEXT_TASK = first(BLUEPRINT_TASKS where status == "pending" AND blockedBy.length == 0)
Else:
  For each task in Implementation Tasks:
    If task.status == ⏳:
      If task.dependencies all ✅:
        NEXT_TASK = task
        Break
```

If no task found (all ✅ or 🔴): Go to Step 5.

### 3. Execute Task

```
/majestic:build-task "{task.id}" --no-ship
```

### 4. Update Status

```
If TASK_TRACKING:
  CLAUDE_TASK_ID = TASK_MAP[NEXT_TASK.id]
  TaskUpdate(CLAUDE_TASK_ID, status: "in_progress")
  # After build completes
  If build succeeded: TaskUpdate(CLAUDE_TASK_ID, status: "completed")
  If build failed: TaskUpdate(CLAUDE_TASK_ID, status: "completed", metadata: {result: "failed"})

# Always update markdown (for visibility in file)
Edit(file_path: plan_path):
  If build succeeded: task.status = ✅
  If build failed: task.status = 🔴
```

Go to Step 2 (next task).

### 5. Ship

When all tasks are ✅ or 🔴:

```
/majestic:ship-it
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
