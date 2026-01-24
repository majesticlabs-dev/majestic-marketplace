---
name: task-coordinator
description: Lifecycle patterns for Claude Code's native Task system - creation, status transitions, dependencies, parallel aggregation, and ledger checkpointing.
triggers:
  - task management
  - workflow tracking
  - progress tracking
  - task dependencies
  - parallel execution
  - crash recovery
---

# Task Coordinator

Patterns for using Claude Code's native Task system (TaskCreate, TaskUpdate, TaskGet, TaskList) in workflow orchestration.

## When to Use

- **Complex workflows** with 3+ sequential steps
- **Parallel execution** requiring result aggregation
- **Cross-session persistence** via CLAUDE_CODE_TASK_LIST_ID
- **Crash recovery** with ledger checkpointing

## Config Check

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
If TASK_TRACKING == false: Skip all Task operations below
```

## Task Lifecycle

### Create Task

```
TaskCreate:
  subject: "Step 4: Slop Removal"       # Imperative form
  activeForm: "Removing code slop"       # Present continuous (shown in spinner)
  description: "Full task details..."
  metadata: { workflow: "build-task", step: 4, milestone: false }
```

**Metadata conventions:**
- `workflow`: Workflow identifier (build-task, blueprint, run-blueprint)
- `step`: Step number within workflow
- `milestone`: `true` for checkpoint-worthy steps
- `phase`: Phase identifier for multi-phase workflows
- `parallel_group`: ID for tasks that run in parallel

### Start Task

```
TaskUpdate:
  taskId: TASK_ID
  status: "in_progress"
```

### Complete Task

```
TaskUpdate:
  taskId: TASK_ID
  status: "completed"
  metadata: { result: "PASS", files_changed: [...] }
```

### Task with Dependencies

```
# Create parent task
PARENT = TaskCreate: { subject: "T1: Setup auth", ... }

# Create dependent task
TaskCreate:
  subject: "T2: Login endpoint"
  addBlockedBy: [PARENT.id]
  metadata: { depends_on: ["T1"] }
```

## Parallel Execution Pattern

### Launch Parallel Tasks

```
# Create all tasks first
TASK_IDS = []
For each REVIEWER in reviewers:
  TASK = TaskCreate:
    subject: "Review: {REVIEWER}"
    activeForm: "Running {REVIEWER}"
    metadata: { parallel_group: "quality-gate", reviewer: REVIEWER }
  TASK_IDS.append(TASK.id)

# Launch all Task agents in single message (enables parallelism)
RESULTS = Task[]:
  - subagent_type: REVIEWER_1, prompt: "..."
  - subagent_type: REVIEWER_2, prompt: "..."
  - subagent_type: REVIEWER_3, prompt: "..."
```

### Aggregate Results

```
# Query completed tasks in parallel group
TASKS = TaskList()
COMPLETED = filter(TASKS, task.metadata.parallel_group == "quality-gate" AND task.status == "completed")

For each TASK in COMPLETED:
  RESULT = TaskGet(TASK.id)
  AGGREGATE.append(RESULT.metadata.findings)
```

## Ledger Checkpoint Pattern

Checkpoints provide crash recovery. Tasks = visibility; Ledger = receipts.

### Check Ledger Enabled

```
LEDGER_ENABLED = /majestic:config task_tracking.ledger false
LEDGER_PATH = /majestic:config task_tracking.ledger_path .agents-os/workflow-ledger.yml
```

### Ledger Schema

```yaml
# .agents-os/workflow-ledger.yml
version: 1
workflow_id: "build-task-20260123-210232"
started_at: "2026-01-23T21:02:32Z"
last_checkpoint: "2026-01-23T21:15:45Z"

current_step: 7
status: in_progress  # pending | in_progress | completed | failed

checkpoints:
  - step: 4
    timestamp: "2026-01-23T21:08:00Z"
    status: completed
    receipt:
      summary: "Slop removal completed"
      files_changed: [app/models/user.rb]

  - step: 7
    timestamp: "2026-01-23T21:15:45Z"
    status: in_progress
    context:
      quality_result: "NEEDS CHANGES"
      findings_count: 3
      attempt: 2
```

### Checkpoint Operations

**Write checkpoint (at milestones):**
```
If LEDGER_ENABLED AND step in [4, 7, 9]:  # Configurable milestones
  CHECKPOINT = {
    step: CURRENT_STEP,
    timestamp: NOW,
    status: completed,
    receipt: {
      summary: "Step description",
      files_changed: [...],
      result: STEP_RESULT
    }
  }

  LEDGER = Read(LEDGER_PATH) OR { version: 1, checkpoints: [] }
  LEDGER.current_step = CURRENT_STEP
  LEDGER.last_checkpoint = NOW
  LEDGER.checkpoints.append(CHECKPOINT)
  Write(LEDGER_PATH, LEDGER)
```

**Resume from checkpoint (after crash):**
```
If exists(LEDGER_PATH):
  LEDGER = Read(LEDGER_PATH)
  If LEDGER.status == "in_progress":
    RESUME_STEP = LEDGER.current_step
    CONTEXT = LEDGER.checkpoints[-1].context
    # Resume workflow from RESUME_STEP with CONTEXT
```

## Workflow Integration Patterns

### build-task-workflow-manager

```
# Step 1: Check config
TASK_TRACKING = /majestic:config task_tracking.enabled false
If not TASK_TRACKING: proceed without Tasks

# Step 2: Create workflow task list
WORKFLOW_ID = "build-task-{timestamp}"
TASKS = {}

For STEP in [1..13]:
  TASKS[STEP] = TaskCreate:
    subject: "Step {STEP}: {STEP_NAME}"
    activeForm: "{STEP_ACTIVE_FORM}"
    metadata: { workflow: "build-task", step: STEP }

# Step 3: Execute with tracking
For STEP in [1..13]:
  TaskUpdate(TASKS[STEP].id, status: "in_progress")

  # Execute step...

  TaskUpdate(TASKS[STEP].id, status: "completed", metadata: { result: ... })

  If STEP in [4, 7, 9]:  # Milestones
    Write checkpoint to ledger
```

### run-blueprint

```
# Parse Implementation Tasks table into Tasks
For each ROW in implementation_tasks:
  TASK = TaskCreate:
    subject: "{ROW.id}: {ROW.task}"
    activeForm: "Building {ROW.task}"
    metadata: {
      points: ROW.points,
      blueprint_id: ROW.id,
      source: plan_path
    }

  # Map dependencies
  If ROW.dependencies:
    BLOCKED_BY = lookup_task_ids(ROW.dependencies)
    TaskUpdate(TASK.id, addBlockedBy: BLOCKED_BY)

# Find next available task
TASKS = TaskList()
NEXT = first(TASKS where status == "pending" AND blockedBy.length == 0)
```

### quality-gate

```
# Create task per reviewer
REVIEWER_TASKS = []
For each REVIEWER in reviewers:
  TASK = TaskCreate:
    subject: "Review: {REVIEWER.name}"
    activeForm: "Running {REVIEWER.name}"
    metadata: { parallel_group: "qg-{timestamp}", reviewer: REVIEWER }
  REVIEWER_TASKS.append(TASK)

# Launch all reviewers in parallel (single message, multiple Task calls)
# ... reviewer execution ...

# Aggregate findings from task metadata
FINDINGS = []
For each TASK in REVIEWER_TASKS:
  RESULT = TaskGet(TASK.id)
  FINDINGS.extend(RESULT.metadata.findings)
```

## Cross-Session Persistence

### Per-Workflow Isolation

```bash
# Set unique task list per workflow
export CLAUDE_CODE_TASK_LIST_ID="build-task-20260123-210232"
claude
```

### Project-Wide Persistence

```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "my-project-tasks"
  }
}
```

## Cleanup

```
AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true

If AUTO_CLEANUP AND workflow_completed:
  TASKS = TaskList()
  For each TASK in TASKS where TASK.metadata.workflow == CURRENT_WORKFLOW:
    TaskUpdate(TASK.id, status: "completed")  # Mark done for visibility

  # Ledger persists as receipt; Tasks cleaned for next workflow
```

## Error Handling

| Scenario | Action |
|----------|--------|
| TaskCreate fails | Log warning, continue without tracking |
| TaskUpdate fails | Retry once, then log and continue |
| TaskList timeout | Use ledger as fallback |
| Ledger write fails | Log error, continue (Tasks still work) |
| Resume with stale ledger | Verify git state matches checkpoint |

## State Relationship

```
┌─────────────────────────────────────────────────────────────┐
│  Native Tasks (TaskCreate, TaskUpdate, TaskList)            │
│  - Real-time visibility (ctrl+t)                           │
│  - Dependency resolution                                    │
│  - Cross-session persistence (CLAUDE_CODE_TASK_LIST_ID)     │
│  - Source of truth for current state                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓ supplements
┌─────────────────────────────────────────────────────────────┐
│  YAML Ledger (.agents-os/workflow-ledger.yml)               │
│  - Detailed receipts (files changed, findings, errors)      │
│  - Crash recovery checkpoints                               │
│  - Historical record for debugging                          │
│  - NOT source of truth - just receipts                      │
└─────────────────────────────────────────────────────────────┘
```

Tasks are primary. Ledger is supplementary receipts for crash recovery and debugging.
