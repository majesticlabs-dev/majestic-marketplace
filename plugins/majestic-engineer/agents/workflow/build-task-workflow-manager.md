---
name: build-task-workflow-manager
description: Orchestrates build execution workflow - build, verify, quality, fix loop, and ship.
tools: Write, Edit, Read, Bash, Skill, AskUserQuestion, Task, Glob, Grep
color: green
---

# Purpose

Execute ALL steps in order. Skipping is not allowed.

## Task Tracking Setup

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
LEDGER_ENABLED = /majestic:config task_tracking.ledger false
LEDGER_PATH = /majestic:config task_tracking.ledger_path .agents-os/workflow-ledger.yml

If TASK_TRACKING:
  WORKFLOW_ID = "build-task-{timestamp}"
  STEP_TASKS = {}  # Map step number to task ID

  # Check for crash recovery
  If LEDGER_ENABLED AND exists(LEDGER_PATH):
    LEDGER = Read(LEDGER_PATH)
    If LEDGER.status == "in_progress":
      RESUME_STEP = LEDGER.current_step
      # Resume from checkpoint
```

## Input Schema

```yaml
task_id: string           # task reference or "plan"
title: string
branch: string
plan: string              # implementation plan content
acceptance_criteria: string[]
methodology: string[]     # [tdd, etc.]
build_agent: string       # agent name or "general-purpose"
fix_agent: string
coding_styles: string[]
design_system_path: string | null
pre_ship_hooks: string[]
quality_gate_reviewers: string[]
source: enum              # "task" | "plan"
skip_ship: boolean        # default: false
```

## Workflow (MANDATORY - EXECUTE ALL STEPS)

### Step 1: Load Design System

```
# Task tracking (applies to all steps)
If TASK_TRACKING:
  STEP_TASKS[1] = TaskCreate(subject: "Step 1: Load Design System", activeForm: "Loading design system", metadata: {workflow: WORKFLOW_ID, step: 1})
  TaskUpdate(STEP_TASKS[1], status: "in_progress")

UI_KEYWORDS = [form, button, page, component, modal, card, input]

If design_system_path exists OR plan contains UI_KEYWORDS:
  DESIGN_SYSTEM = Read(design_system_path)

If TASK_TRACKING: TaskUpdate(STEP_TASKS[1], status: "completed")
```

### Step 2: Activate Methodology and Coding Styles

```
METHODOLOGIES = Skill("config-reader", args: "toolbox.build_task.methodology []")
CODING_STYLES = Skill("config-reader", args: "toolbox.build_task.coding_styles []")

For each M in METHODOLOGIES:
  If M == "tdd": Skill("majestic-engineer:tdd-workflow")

For each S in CODING_STYLES:
  Skill(S)
```

### Step 3: Build

```
If DESIGN_SYSTEM:
  Task(build_agent, prompt: "Implement: <title> | Plan: <plan> | Design System: <DESIGN_SYSTEM>")
Else:
  Task(build_agent, prompt: "Implement: <title> | Plan: <plan>")
```

### Step 4: Slop Removal (MANDATORY)

```
If TASK_TRACKING:
  STEP_TASKS[4] = TaskCreate(subject: "Step 4: Slop Removal", activeForm: "Removing code slop", metadata: {workflow: WORKFLOW_ID, step: 4, milestone: true})
  TaskUpdate(STEP_TASKS[4], status: "in_progress")

Task("majestic-engineer:qa:slop-remover", prompt: "Clean branch changes on <branch>")

If TASK_TRACKING: TaskUpdate(STEP_TASKS[4], status: "completed")

# Checkpoint (milestone step)
If LEDGER_ENABLED:
  CHECKPOINT = {step: 4, timestamp: NOW, status: "completed", receipt: {summary: "Slop removal completed"}}
  Write ledger with current_step: 4, checkpoint appended
```

### Step 5: Verify (MANDATORY)

```
VERIFY_RESULT = Task("majestic-engineer:workflow:always-works-verifier", prompt: "Verify branch: <branch>")
```

### Step 6: AC Verification (MANDATORY)

```
For each AC in acceptance_criteria:
  If AC starts with [npm, rails, bundle, pytest, make]:
    RESULT = Bash(AC), check exit 0
  Else if AC contains "localhost" or URL:
    RESULT = dev-browser or curl
  Else if AC contains file path:
    RESULT = check file exists
  Else:
    RESULT = always-works-verifier

  AC_RESULTS.append({criterion: AC, passed: RESULT})

If any AC_RESULTS.passed == false: goto Step 8
```

### Step 7: Quality Gate (MANDATORY)

```
If TASK_TRACKING:
  STEP_TASKS[7] = TaskCreate(subject: "Step 7: Quality Gate", activeForm: "Running quality gate", metadata: {workflow: WORKFLOW_ID, step: 7, milestone: true})
  TaskUpdate(STEP_TASKS[7], status: "in_progress")

QUALITY_RESULT = Task("majestic-engineer:workflow:quality-gate", prompt: "Context: <title> | Branch: <branch> | Verifier: <VERIFY_RESULT> | AC: <AC_RESULTS>")

If TASK_TRACKING: TaskUpdate(STEP_TASKS[7], status: "completed", metadata: {verdict: QUALITY_RESULT.verdict})

# Checkpoint (milestone step)
If LEDGER_ENABLED:
  CHECKPOINT = {step: 7, timestamp: NOW, status: "completed", receipt: {quality_verdict: QUALITY_RESULT.verdict}}
  Write ledger with current_step: 7, checkpoint appended
```

### Step 8: Fix Loop

```
ATTEMPTS = 0
MAX_ATTEMPTS = 3

While VERIFY_RESULT != PASS OR QUALITY_RESULT != APPROVED:
  ATTEMPTS++
  If ATTEMPTS > MAX_ATTEMPTS: return FAIL

  Task(fix_agent, prompt: "Fix findings: <findings>")
  goto Step 4  # Slop → Verify → Quality
```

### Step 9: Quality Gate Checkpoint

```
If TASK_TRACKING:
  STEP_TASKS[9] = TaskCreate(subject: "Step 9: Quality Checkpoint", activeForm: "Verifying quality gate", metadata: {workflow: WORKFLOW_ID, step: 9, milestone: true})
  TaskUpdate(STEP_TASKS[9], status: "in_progress")

Assert slop-remover ran
Assert VERIFY_RESULT == PASS
Assert QUALITY_RESULT == APPROVED

If any assertion fails: goto Step 8

If TASK_TRACKING: TaskUpdate(STEP_TASKS[9], status: "completed")

# Checkpoint (milestone step)
If LEDGER_ENABLED:
  CHECKPOINT = {step: 9, timestamp: NOW, status: "completed", receipt: {summary: "All quality checks passed"}}
  Write ledger with current_step: 9, checkpoint appended
```

### Step 10: Capture Implementation Learnings

Document patterns, gotchas, and anti-patterns discovered during implementation to closest AGENTS.md.

```
# Get modified files from this task
MODIFIED_FILES = git diff --name-only $(git merge-base HEAD main)..HEAD

If MODIFIED_FILES empty: SKIP

# Find primary directory (most common parent)
PRIMARY_DIR = most common parent directory of MODIFIED_FILES

# Find closest AGENTS.md
AGENTS_MD = walk up from PRIMARY_DIR until AGENTS.md found
If not found: AGENTS_MD = "AGENTS.md" (root)

# Extract implementation learnings
IMPL_LEARNINGS = []

# Patterns: What conventions emerged from the code?
For each FILE in MODIFIED_FILES:
  PATTERNS = analyze for:
    - Import organization
    - Naming conventions
    - File structure patterns
    - Code organization
  If PATTERN is consistent across 2+ files:
    IMPL_LEARNINGS.append({type: "pattern", content: PATTERN, location: FILE})

# Gotchas: What non-obvious things were required?
For each GOTCHA discovered during build/fix:
  IMPL_LEARNINGS.append({
    type: "gotcha",
    content: GOTCHA.what,
    context: GOTCHA.why_needed
  })

# Anti-patterns: What failed in fix-loop?
If ATTEMPTS > 1:
  For each FAILED_APPROACH in fix_loop_history:
    IMPL_LEARNINGS.append({
      type: "anti_pattern",
      dont: FAILED_APPROACH.what,
      why: FAILED_APPROACH.why_failed,
      do_instead: FAILED_APPROACH.what_worked
    })

# Dedupe against existing AGENTS.md
EXISTING = Read(AGENTS_MD)
NEW_LEARNINGS = IMPL_LEARNINGS - EXISTING (by content similarity)

If NEW_LEARNINGS empty: SKIP

# Format and append
FORMAT = """
## Patterns

| Pattern | Location |
|---------|----------|
{for each L in NEW_LEARNINGS where L.type == "pattern":}
| {L.content} | `{L.location}` |
{end for}

## Gotchas

{for each L in NEW_LEARNINGS where L.type == "gotcha":}
- {L.content} — {L.context}
{end for}

## Anti-Patterns

{if any L.type == "anti_pattern":}
| Don't | Why | Do Instead |
|-------|-----|------------|
{for each L in NEW_LEARNINGS where L.type == "anti_pattern":}
| {L.dont} | {L.why} | {L.do_instead} |
{end for}
{end if}
"""

# Append to relevant section or create if missing
Edit(AGENTS_MD, append FORMAT to existing sections or create new ones)
```

Skip if:
- No files modified
- All learnings already documented
- Trivial changes (typos, formatting only)

### Step 11: Pre-Ship Hooks

```
If skip_ship: SKIP

For each HOOK in pre_ship_hooks:
  HOOK_RESULT = Task(HOOK.agent, prompt: "Pre-ship check on branch: <branch>")
  If HOOK.required AND HOOK_RESULT == FAIL: return FAIL
```

### Step 12: Ship

```
If skip_ship: return {status: PASS, message: "shipping deferred"}

If source == "task":
  Skill("majestic-engineer:workflows:ship-it", args: "closes #<task_id>")
Else:
  Skill("majestic-engineer:workflows:ship-it")
```

### Step 13: Complete Task Status

```
If skip_ship OR source == "plan": SKIP

Task("majestic-engineer:workflow:task-status-updater", prompt: "Action: ship | Task: <task_id> | PR: <pr_number>")

# Task tracking cleanup
If TASK_TRACKING:
  AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true
  If AUTO_CLEANUP:
    For each TASK in STEP_TASKS.values():
      TaskUpdate(TASK, status: "completed")

If LEDGER_ENABLED:
  Update ledger: status: "completed", completed_at: NOW
```

## Output Schema

```yaml
status: enum              # PASS | FAIL
title: string
ac_results: array
  - criterion: string
    passed: boolean
    error: string | null
source: string            # task #ID or plan file
branch: string
pr: integer | null        # null if skip_ship
attempts: integer         # 1-3
error: string | null      # if FAIL
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Build fails | goto Step 8 |
| Verify fails | goto Step 8 |
| Quality fails | goto Step 8 |
| 3 attempts exhausted | return FAIL |
| Required hook fails | return FAIL |
| Ship fails | return FAIL |
