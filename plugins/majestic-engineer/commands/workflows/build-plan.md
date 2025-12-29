---
name: majestic:build-plan
description: Execute all tasks in a plan using build-task workflow with ralph-wiggum iteration
argument-hint: "<plan-file.md>"
allowed-tools: Bash, Read, Edit, Grep, Glob, Task, Skill, SlashCommand
---

# Build Plan

Execute all tasks from a plan file through the full build-task workflow.

## Input

<plan_file> $ARGUMENTS </plan_file>

**Formats:**
- *(empty)* → Auto-detect most recent `docs/plans/*.md`
- `docs/plans/*.md` → Explicit plan file path

## Prerequisites

**Required:** Plan must have `## Implementation Tasks` section with task references.

Run `/majestic:plan` with "Break into small tasks" option first if tasks don't exist.

## Step 0: Load Plan

```bash
# If empty, find most recent plan
ls -t docs/plans/*.md 2>/dev/null | head -1
```

Read the plan file and verify it has an Implementation Tasks section.

**Set terminal title:** `Skill(skill: "majestic-engineer:terminal-title", args: "Build: <plan-title>")`

---

## Step 1: Parse Tasks

Extract tasks from `## Implementation Tasks` section.

**Supported formats:**

Table format:
```markdown
| Task | Points | Dependencies | Tracker |
|------|--------|--------------|---------|
| Set up database schema | 2 | - | #123 |
| Create API endpoints | 3 | #123 | #124 |
```

Checkbox format:
```markdown
- [ ] Set up database schema (2 pts) → #123
- [x] Create API endpoints (3 pts, depends: #123) → #124
```

**Extract for each task:**
- `task_ref`: Task reference (#123, PROJ-123, BEADS-123)
- `dependencies`: List of task refs this depends on
- `completed`: Whether checkbox is checked or row is struck through

---

## Step 2: Build Dependency Graph

Order tasks respecting dependencies:

```
Independent tasks (no deps) → Run first
Dependent tasks → Run after their dependencies complete
```

**Parallelization:** Tasks with no mutual dependencies CAN run in parallel, but for simplicity run sequentially to maintain clean git history.

---

## Step 3: Execute Tasks

For each task in dependency order:

### 3a. Skip if Complete

If task already marked complete in plan, skip it.

### 3b. Check Dependencies

Verify all dependencies are marked complete before proceeding.

### 3c. Run Build-Task

```
SlashCommand(command: "majestic:build-task", args: "<task_ref>")
```

This invokes the full build-task workflow:
- Workspace setup (reuses existing branch or creates new)
- Toolbox resolution
- Research hooks
- Build
- Slop-remover (MANDATORY)
- Verify (MANDATORY)
- Quality-gate (MANDATORY)
- Fix loop if needed
- Ship (creates PR)

### 3d. Update Plan Progress

After successful completion, update the plan file:

**Table format:** Add ✓ or strikethrough to completed row
**Checkbox format:** Change `- [ ]` to `- [x]`

```
Edit(file_path: "<plan_file>", old_string: "- [ ] <task_desc> → <ref>", new_string: "- [x] <task_desc> → <ref>")
```

### 3e. Continue or Retry

- **Success:** Move to next task
- **Failure after 3 fix attempts:** Log failure, continue to next independent task
- **All tasks blocked:** Stop and report

---

## Step 4: Completion Check

After processing all tasks:

| Status | Action |
|--------|--------|
| All tasks complete | Report success |
| Some tasks failed | List failures with reasons |
| Blocked tasks remain | List blocked tasks and their blockers |

---

## Ralph-Wiggum Integration

This command is designed to work with ralph-wiggum for autonomous iteration.

**Start with ralph:**
```bash
/ralph-loop "/majestic:build-plan docs/plans/xxx.md" --max-iterations 50 --completion-promise "BUILD_PLAN_COMPLETE"
```

**Completion signal:** Output `<promise>BUILD_PLAN_COMPLETE</promise>` when:
- All tasks marked complete in plan file
- All PRs created successfully

**Ralph handles:**
- Tasks that fail quality gates repeatedly
- Regressions (earlier task broken by later changes)
- Interrupted sessions (resumes from unchecked tasks)

---

## Output

```markdown
## Build Plan Complete: <plan-title>

### Tasks Executed
- [x] #123 - Set up database schema → PR #456
- [x] #124 - Create API endpoints → PR #457
- [x] #125 - Build UI components → PR #458

### Summary
- Plan: docs/plans/xxx.md
- Tasks: 3/3 complete
- PRs: #456, #457, #458
- Quality: All passed

<promise>BUILD_PLAN_COMPLETE</promise>
```

---

## Error Handling

### Missing Implementation Tasks Section

```
Error: Plan file missing ## Implementation Tasks section.

Run one of:
  /majestic:plan "<feature>" → Then select "Break into small tasks"
  agent task-breakdown "Plan: <plan-file>"
```

### Task Reference Not Found

```
Warning: Task #123 not found in task manager.
Skipping and continuing with next task.
```

### Circular Dependencies

```
Error: Circular dependency detected: #123 → #124 → #123
Please fix dependencies in plan file before continuing.
```

---

## Examples

```bash
# Auto-detect most recent plan
/majestic:build-plan

# Explicit plan file
/majestic:build-plan docs/plans/20241228_add-auth.md

# With ralph-wiggum for autonomous execution
/ralph-loop "/majestic:build-plan docs/plans/20241228_add-auth.md" --max-iterations 50 --completion-promise "BUILD_PLAN_COMPLETE"
```
