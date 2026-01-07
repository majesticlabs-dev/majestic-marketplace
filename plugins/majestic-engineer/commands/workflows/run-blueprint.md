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

```bash
# If empty, find most recent blueprint
ls -t docs/plans/*.md 2>/dev/null | head -1
```

Read the blueprint file and verify it has an Implementation Tasks section.

---

## Step 1: Ralph Loop Detection

Check if already running inside ralph-loop:

```bash
[ -f .claude/ralph-loop.local.md ] && echo "IN_RALPH_LOOP" || echo "NOT_IN_LOOP"
```

**If NOT in loop:** Invoke ralph-loop with run-blueprint as the prompt:

```
Skill(skill: "majestic-ralph:start", args: '"/majestic:run-blueprint <blueprint_file>" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"')
```

Then **STOP** - ralph-loop will re-invoke this command and handle iterations.

**If IN loop:** Continue with Step 2.

---

## Step 2: Parse Tasks

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

## Step 3: Build Dependency Graph

Order tasks respecting dependencies:

```
Independent tasks (no deps) → Run first
Dependent tasks → Run after their dependencies complete
```

**Parallelization:** Tasks with no mutual dependencies CAN run in parallel, but for simplicity run sequentially to maintain clean git history.

---

## Step 4: Execute Tasks

For each task in dependency order:

### 4a. Skip if Complete

If task already marked complete in blueprint, skip it.

### 4b. Check Dependencies

Verify all dependencies are marked complete before proceeding.

### 4c. Run Build-Task

```
SlashCommand(command: "majestic:build-task", args: "<task_ref> --no-ship")
```

This invokes the build-task workflow with deferred shipping:
- Workspace setup (reuses existing branch or creates new)
- Toolbox resolution
- Research hooks
- Build
- Slop-remover (MANDATORY)
- Verify (MANDATORY)
- Quality-gate (MANDATORY)
- Fix loop if needed
- **Shipping deferred** (handled in Step 6 after all tasks complete)

### 4d. Update Blueprint Progress

After successful completion, update the blueprint file:

**Table format:** Add checkmark or strikethrough to completed row
**Checkbox format:** Change `- [ ]` to `- [x]`

```
Edit(file_path: "<blueprint_file>", old_string: "- [ ] <task_desc> → <ref>", new_string: "- [x] <task_desc> → <ref>")
```

### 4e. Continue or Retry

- **Success:** Move to next task
- **Failure after 3 fix attempts:** Log failure, continue to next independent task
- **All tasks blocked:** Stop and report

---

## Step 5: Completion Check

After processing all tasks:

| Status | Action |
|--------|--------|
| All tasks complete | Proceed to Step 6 (Ship) |
| Some tasks failed | List failures, still proceed to Step 6 if any succeeded |
| Blocked tasks remain | List blocked tasks and their blockers |

---

## Step 6: Ship (MANDATORY)

After all tasks have been built and passed quality gates, run ship-it to create the PR:

```
Skill(skill: "majestic-engineer:workflows:ship-it")
```

This creates a single PR containing all the changes from the completed tasks.

**Note:** This step runs even if some tasks failed. The PR will contain changes from all successfully completed tasks.

---

## Ralph-Loop Integration

This command is designed to work with ralph-loop for autonomous iteration.

**Start with ralph:**
```bash
/majestic-ralph:start "/majestic:run-blueprint docs/plans/xxx.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

**Completion signal:** Output `<promise>RUN_BLUEPRINT_COMPLETE</promise>` when:
- All tasks marked complete in blueprint file
- All PRs created successfully

**Ralph handles:**
- Tasks that fail quality gates repeatedly
- Regressions (earlier task broken by later changes)
- Interrupted sessions (resumes from unchecked tasks)

---

## Output

```markdown
## Build Blueprint Complete: <blueprint-title>

### Tasks Executed
- [x] #123 - Set up database schema ✓ Quality passed
- [x] #124 - Create API endpoints ✓ Quality passed
- [x] #125 - Build UI components ✓ Quality passed

### Summary
- Blueprint: docs/plans/xxx.md
- Tasks: 3/3 complete
- PR: #456 (contains all tasks)
- Quality: All passed

<promise>RUN_BLUEPRINT_COMPLETE</promise>
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
