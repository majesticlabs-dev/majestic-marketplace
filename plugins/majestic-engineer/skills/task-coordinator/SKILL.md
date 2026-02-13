---
name: task-coordinator
description: Use when orchestrating multi-step workflows with Claude Code's native Task system (TaskCreate, TaskUpdate, TaskGet, TaskList) - lifecycle management, parallel execution, crash recovery, and progress visibility. Not for simple single-step tasks.
triggers:
  - task management
  - workflow tracking
  - progress tracking
  - task dependencies
  - parallel execution
  - crash recovery
---

# Task Coordinator

Patterns for integrating Claude Code's native Task system into workflow orchestration.

## When to Use

- Workflow has 3+ sequential steps needing progress visibility
- Parallel execution with dependency tracking
- Long-running workflows needing crash recovery
- Cross-session work requiring persistent state

## Config Check (Guard Pattern)

Every workflow MUST check config before any Task operations:

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
LEDGER_ENABLED = /majestic:config task_tracking.ledger false
LEDGER_PATH = /majestic:config task_tracking.ledger_path .agents/workflow-ledger.yml
AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true

If NOT TASK_TRACKING: skip all Task operations, run workflow normally
```

All Task operations below are conditional on `TASK_TRACKING == true`.

## Task Lifecycle

### 1. Create

```
TASK = TaskCreate(
  subject: "Imperative verb phrase",     # "Run security review"
  description: "What and why",
  activeForm: "Present continuous form",  # "Running security review"
  metadata: {
    workflow: WORKFLOW_ID,
    step: STEP_NUMBER,
    milestone: true|false,
    phase: "phase-name",
    parallel_group: "group-id"
  }
)
```

**Subject conventions:**
- Imperative form: "Run tests", "Build feature", "Review code"
- Match step name from workflow

**activeForm conventions:**
- Present continuous: "Running tests", "Building feature", "Reviewing code"
- Shown in spinner while task is in_progress

### 2. Start

```
TaskUpdate(TASK.id, status: "in_progress")
```

### 3. Complete

```
TaskUpdate(TASK.id, status: "completed")
```

### 4. Full Step Pattern

```
If TASK_TRACKING:
  STEP_TASK = TaskCreate(subject: "Step N: Name", activeForm: "Doing name", metadata: {...})
  TaskUpdate(STEP_TASK.id, status: "in_progress")

... existing step logic (unchanged) ...

If TASK_TRACKING:
  TaskUpdate(STEP_TASK.id, status: "completed")

If LEDGER_ENABLED AND step.milestone:
  Write checkpoint → LEDGER_PATH
```

## Metadata Conventions

| Key | Type | Purpose | Example |
|-----|------|---------|---------|
| `workflow` | string | Groups tasks to one workflow run | `"build-task-abc123"` |
| `step` | integer | Step number within workflow | `4` |
| `milestone` | boolean | Whether step triggers ledger checkpoint | `true` |
| `phase` | string | Named phase for multi-phase workflows | `"discovery"` |
| `parallel_group` | string | Groups tasks launched in parallel | `"reviewers"` |

### Workflow ID Generation

```
WORKFLOW_ID = "{workflow-name}-{timestamp}"
# Example: "build-task-20260213T1430"
```

## Dependency Mapping

Use `addBlockedBy` to express task ordering:

```
TASK_A = TaskCreate(subject: "Foundation step", ...)
TASK_B = TaskCreate(subject: "Depends on A", ...)
TaskUpdate(TASK_B.id, addBlockedBy: [TASK_A.id])
```

**Rules:**
- Create ALL tasks first, then set dependencies
- Blocked tasks cannot be claimed until blockers complete
- Use for sequential phases in multi-phase workflows

**Multi-phase example:**

```
PHASES = [
  {name: "Discovery", deps: []},
  {name: "Architecture", deps: ["Discovery"]},
  {name: "Implementation", deps: ["Architecture"]},
  {name: "Review", deps: ["Implementation"]}
]

PHASE_TASKS = {}
For each P in PHASES:
  PHASE_TASKS[P.name] = TaskCreate(
    subject: "Phase: {P.name}",
    activeForm: "Running {P.name}",
    metadata: {workflow: WORKFLOW_ID, phase: P.name}
  )

For each P in PHASES:
  If P.deps is not empty:
    BLOCKER_IDS = [PHASE_TASKS[d].id for d in P.deps]
    TaskUpdate(PHASE_TASKS[P.name].id, addBlockedBy: BLOCKER_IDS)
```

## Parallel Execution

**Pattern:** Create all tasks first, then launch Task agents in a single message for parallelism.

```
# 1. Create tasks with shared parallel_group
GROUP_ID = "reviewers-{WORKFLOW_ID}"

REVIEWER_TASKS = []
For each REVIEWER in REVIEWER_LIST:
  T = TaskCreate(
    subject: "Run {REVIEWER}",
    activeForm: "Running {REVIEWER}",
    metadata: {
      workflow: WORKFLOW_ID,
      parallel_group: GROUP_ID,
      reviewer: REVIEWER
    }
  )
  REVIEWER_TASKS.append(T)

# 2. Launch ALL agents in a SINGLE message (enables parallelism)
# Each Task() call in the same response runs concurrently
For each T in REVIEWER_TASKS:  # all in ONE message
  Task(
    subagent_type: T.metadata.reviewer,
    prompt: "...",
    name: T.metadata.reviewer,
    run_in_background: true
  )

# 3. Collect results as agents complete
For each T in REVIEWER_TASKS:
  RESULT = wait for agent completion
  TaskUpdate(T.id, status: "completed")
```

**Key rule:** All `Task()` calls MUST be in the same response message. Splitting across messages forces sequential execution.

## Result Aggregation

After parallel tasks complete, filter by `parallel_group`:

```
ALL_TASKS = TaskList()
GROUP_TASKS = [T for T in ALL_TASKS where T.metadata.parallel_group == GROUP_ID]

COMPLETED = [T for T in GROUP_TASKS where T.status == "completed"]
FAILED = [T for T in GROUP_TASKS where T.status != "completed"]

If FAILED is not empty:
  Handle failures per error table
Else:
  Aggregate results from COMPLETED tasks
```

## Ledger Checkpoint Pattern

YAML-based receipts for crash recovery at milestone steps.

### Schema

```yaml
version: 1
workflow_id: "build-task-20260213T1430"
workflow_type: "build-task"
started_at: "2026-02-13T14:30:00Z"
last_checkpoint: "2026-02-13T14:35:00Z"
current_step: 4
status: "in_progress"  # in_progress | completed | failed
checkpoints:
  - step: 1
    name: "Workspace setup"
    status: "completed"
    completed_at: "2026-02-13T14:31:00Z"
    data: {}
  - step: 4
    name: "Build"
    status: "completed"
    completed_at: "2026-02-13T14:35:00Z"
    data:
      build_output: "success"
```

### Writing Checkpoints

```
If LEDGER_ENABLED AND step.milestone:
  CHECKPOINT = {
    step: STEP_NUMBER,
    name: STEP_NAME,
    status: "completed",
    completed_at: NOW(),
    data: {step-specific key-value pairs}
  }
  Read existing ledger from LEDGER_PATH (or create new)
  Append CHECKPOINT to checkpoints array
  Update last_checkpoint, current_step
  Write ledger to LEDGER_PATH
```

### Milestone Steps by Workflow

| Workflow | Milestone Steps |
|----------|----------------|
| build-task | Workspace setup (1), Build (4), Verify (5), Quality (7), Ship (9) |
| blueprint | Discovery (1), Architecture (4), Plan written (6), Execution (9) |
| run-blueprint | Task creation (2), Each task completion |
| quality-gate | Each reviewer completion, Final verdict |

## Resume from Crash

```
If LEDGER_ENABLED:
  LEDGER = Read LEDGER_PATH
  If LEDGER exists AND LEDGER.status == "in_progress":
    LAST_STEP = LEDGER.current_step
    COMPLETED_STEPS = [C.step for C in LEDGER.checkpoints where C.status == "completed"]

    # Resume: skip completed steps, start from next
    For each STEP in WORKFLOW_STEPS:
      If STEP.number in COMPLETED_STEPS: skip
      If STEP.number <= LAST_STEP AND STEP.number not in COMPLETED_STEPS:
        # Step was in progress when crash happened — re-run it
        Execute STEP
      Else:
        Execute STEP normally
```

**Recovery decision table:**

| Ledger State | Action |
|-------------|--------|
| No ledger file | Fresh start |
| `status: completed` | Fresh start (previous run finished) |
| `status: in_progress` | Resume from last checkpoint |
| `status: failed` | Resume from failed step |
| Ledger parse error | Log warning, fresh start |

## Workflow Integration Examples

### build-task

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
If TASK_TRACKING:
  WORKFLOW_ID = "build-task-{timestamp}"
  # Create tasks for key steps
  TASKS = {}
  For each STEP in [1: "Setup workspace", 4: "Build", 5: "Verify", 7: "Quality gate", 9: "Ship"]:
    TASKS[STEP.num] = TaskCreate(
      subject: "Step {STEP.num}: {STEP.name}",
      activeForm: "{STEP.activeForm}",
      metadata: {workflow: WORKFLOW_ID, step: STEP.num, milestone: true}
    )

  # Before each step
  TaskUpdate(TASKS[N].id, status: "in_progress")
  # After each step
  TaskUpdate(TASKS[N].id, status: "completed")
  # At milestones: write ledger checkpoint
```

### run-blueprint

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
If TASK_TRACKING:
  WORKFLOW_ID = "run-blueprint-{timestamp}"
  # Parse implementation tasks from plan markdown
  PLAN_TASKS = parse_table(plan_path)

  # Create native tasks mirroring plan
  NATIVE_TASKS = {}
  For each PT in PLAN_TASKS:
    NATIVE_TASKS[PT.id] = TaskCreate(
      subject: PT.name,
      activeForm: "Building {PT.name}",
      metadata: {
        workflow: WORKFLOW_ID,
        blueprint_task_id: PT.id,
        points: PT.points
      }
    )

  # Map dependencies
  For each PT in PLAN_TASKS:
    If PT.dependencies is not empty:
      BLOCKER_IDS = [NATIVE_TASKS[d].id for d in PT.dependencies]
      TaskUpdate(NATIVE_TASKS[PT.id].id, addBlockedBy: BLOCKER_IDS)

  # Task selection: use TaskList() to find next unblocked task
  NEXT = first task from TaskList() where status == "pending" AND blockedBy is empty
```

### quality-gate

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
If TASK_TRACKING:
  WORKFLOW_ID = "quality-gate-{timestamp}"
  GROUP_ID = "reviewers-{WORKFLOW_ID}"

  # Create task per reviewer
  For each R in REVIEWERS:
    TaskCreate(
      subject: "Run {R}",
      activeForm: "Running {R}",
      metadata: {workflow: WORKFLOW_ID, parallel_group: GROUP_ID, reviewer: R}
    )

  # Launch all reviewers in ONE message (parallel)
  # Collect results, aggregate verdict
```

## Cross-Session Persistence

For workflows spanning multiple sessions (e.g., relay epics):

```
# At workflow start: export task list ID
TASK_LIST_ID = current task list identifier
Set env: CLAUDE_CODE_TASK_LIST_ID = TASK_LIST_ID

# In new session: restore task list
If env CLAUDE_CODE_TASK_LIST_ID is set:
  Restore task list from CLAUDE_CODE_TASK_LIST_ID
  ALL_TASKS = TaskList()
  Resume from incomplete tasks
```

**Note:** Cross-session persistence requires the task list ID to be stored externally (env var, file, or ledger).

## Cleanup

```
AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true

If TASK_TRACKING AND workflow completed successfully:
  If AUTO_CLEANUP:
    ALL_TASKS = TaskList()
    WORKFLOW_TASKS = [T for T in ALL_TASKS where T.metadata.workflow == WORKFLOW_ID]
    For each T in WORKFLOW_TASKS:
      TaskUpdate(T.id, status: "completed")  # ensure all marked done

  If LEDGER_ENABLED:
    Update ledger: status = "completed", last_checkpoint = NOW()
```

## Error Handling

| Error | Action | Rationale |
|-------|--------|-----------|
| TaskCreate fails | Log warning, continue workflow without tracking | Tracking is supplementary |
| TaskUpdate fails | Retry once, then log warning and continue | Eventual consistency acceptable |
| TaskList timeout | Fall back to ledger if available | Ledger = backup state source |
| TaskGet returns stale data | Re-fetch before update | Avoid overwriting concurrent changes |
| Ledger write fails | Log warning, continue without checkpoint | Workflow execution > receipts |
| Ledger parse error | Log warning, treat as fresh start | Corrupted state not recoverable |
| Dependency cycle detected | Log error, remove cycle, continue | Never block workflow on tracking bug |

**Principle:** Task tracking failures MUST NEVER block workflow execution. Always degrade gracefully.

## State Relationship

```
+---------------------------+     +---------------------------+
|     Native Tasks          |     |     YAML Ledger           |
|  (TaskCreate/Update/List) |     |  (.agents/workflow-ledger) |
+---------------------------+     +---------------------------+
|  Source of truth for:     |     |  Supplementary for:       |
|  - Current step status    |     |  - Crash recovery         |
|  - Dependency tracking    |     |  - Cross-session resume   |
|  - Progress visibility    |     |  - Milestone receipts     |
|  - Parallel coordination  |     |  - Audit trail            |
+---------------------------+     +---------------------------+
         PRIMARY                         SECONDARY

If conflict: Tasks win. Ledger is advisory only.
```

**Design rationale:**
- Tasks provide real-time UI feedback (spinner, progress)
- Ledger persists across session boundaries where Tasks may not
- Both are opt-in via independent config flags
- Neither blocks workflow execution on failure
