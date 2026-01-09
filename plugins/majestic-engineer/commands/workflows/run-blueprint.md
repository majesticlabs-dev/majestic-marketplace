---
name: majestic:run-blueprint
description: Execute all tasks in a blueprint using build-task workflow with ralph-loop iteration
argument-hint: "<blueprint-file.md>"
allowed-tools: Bash, Read, Edit, Grep, Glob, Task, Skill, SlashCommand
---

# Run Blueprint

Execute all tasks from a blueprint file through the full build-task workflow.

## Input

<blueprint_file> $ARGUMENTS </blueprint_file>

**Formats:**
- *(empty)* → Auto-detect most recent `docs/plans/*.md`
- `docs/plans/*.md` → Explicit blueprint file path

## Prerequisites

**Required:** Blueprint must have `## Implementation Tasks` section with task references.

Run `/majestic:blueprint` with "Break into small tasks" option first if tasks don't exist.

## Step 0: Load Blueprint

```
If ARGUMENTS empty:
  BLUEPRINT = ls -t docs/plans/*.md | head -1
Else:
  BLUEPRINT = ARGUMENTS

Read(BLUEPRINT)
Assert "## Implementation Tasks" section exists
```

---

## Step 1: Ralph Loop Detection

```
IN_LOOP = [ -f .claude/ralph-loop.local.yml ]

If NOT IN_LOOP:
  Skill("majestic-ralph:start", args: '"/majestic:run-blueprint <BLUEPRINT>" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"')
  STOP

# Continue if IN_LOOP
```

---

## Step 2: Parse Tasks

Extract tasks from `## Implementation Tasks` section.

**Task schema:**
```yaml
task_id: string       # T1, T2, etc. (from ##### header)
title: string         # Task title (from ##### header after ID)
priority: string      # p0, p1, p2, p3
points: integer       # Story points
files: string[]       # File paths
dependencies: string[] # Task IDs this depends on (or empty)
ac_items: string[]    # Acceptance criteria text lines
status: enum          # ⏳|🔄|✅|🔴
```

**Status markers:**
| Marker | Status |
|--------|--------|
| ⏳ Pending | Not started |
| 🔄 In Progress | Build in progress |
| ✅ Complete | All AC passed, quality gate passed |
| 🔴 Blocked | Cannot proceed (dependency issue) |

---

## Step 3: Build Dependency Graph

```
TASKS = sort by dependencies (independent first, dependent after their deps)
```

---

## Step 4: Execute Tasks

```
For each TASK in TASKS:
  # 4a. Skip complete
  If TASK.status == "✅ Complete": continue

  # 4b. Check dependencies
  For each DEP in TASK.dependencies:
    If DEP.status != "✅ Complete": mark TASK as 🔴 Blocked, continue

  # 4c. Extract AC, update status
  AC_ITEMS = extract "- [ ]" lines from TASK's Acceptance Criteria section
  Edit(BLUEPRINT, "**Status:** ⏳ Pending", "**Status:** 🔄 In Progress")

  # 4d. Run build-task
  RESULT = SlashCommand("majestic:build-task", args: "<TASK.id> --no-ship --ac '<AC_ITEMS>'")

  # 4e. Update blueprint from results
  For each AC_RESULT in RESULT.ac_results:
    If AC_RESULT.passed:
      Edit(BLUEPRINT, "- [ ] <criterion>", "- [x] <criterion>")

  If RESULT.status == PASS:
    Edit(BLUEPRINT, "**Status:** 🔄 In Progress", "**Status:** ✅ Complete")
  Else:
    Edit(BLUEPRINT, "**Status:** 🔄 In Progress", "**Status:** 🔴 Blocked")

  # 4f. Continue or stop
  If all remaining TASKS blocked: STOP
```

---

## Step 5: Completion Check

```
COMPLETED = grep -c "✅ Complete" <blueprint_file>
BLOCKED = grep -c "🔴 Blocked" <blueprint_file>
PENDING = grep -c "⏳ Pending" <blueprint_file>

If COMPLETED > 0:
  Proceed to Step 6
Else:
  Report "No tasks completed" and exit
```

---

## Step 6: Ship (MANDATORY)

```
If COMPLETED > 0:
  Skill("majestic-engineer:workflows:ship-it")
```

Ships all completed task changes in single PR (even if some tasks blocked).

---

## Ralph-Loop Integration

```
Completion signal: <promise>RUN_BLUEPRINT_COMPLETE</promise>
Condition: All tasks ✅ Complete OR no more tasks can proceed
```

---

## Output Schema

```yaml
title: string           # "Build Blueprint Complete: <title>"
tasks: array
  - id: string          # T1, T2, etc.
    title: string
    status: enum        # ✅|🔴
    ac_progress: string # "4/4"
summary:
  blueprint: string     # file path
  completed: integer
  blocked: integer
  pr: integer           # PR number
promise: string         # RUN_BLUEPRINT_COMPLETE (always output)
```

---

## Error Handling

### Missing Implementation Tasks Section

```
Error: Blueprint file missing ## Implementation Tasks section.

Run one of:
  /majestic:blueprint "<feature>" → Then select "Break into small tasks"
  agent task-breakdown "Blueprint: <blueprint-file>"
```

### Task Reference Not Found

```
Warning: Task #123 not found in task manager.
Skipping and continuing with next task.
```

### Circular Dependencies

```
Error: Circular dependency detected: #123 → #124 → #123
Please fix dependencies in blueprint file before continuing.
```

---

## Examples

```bash
# Auto-detect most recent blueprint
/majestic:run-blueprint

# Explicit blueprint file
/majestic:run-blueprint docs/plans/20241228_add-auth.md

# With ralph-loop for autonomous execution
/majestic-ralph:start "/majestic:run-blueprint docs/plans/20241228_add-auth.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```
