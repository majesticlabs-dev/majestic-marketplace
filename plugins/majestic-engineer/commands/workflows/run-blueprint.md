---
name: majestic:run-blueprint
description: Execute all tasks in a blueprint using build-task workflow with ralph-loop iteration
argument-hint: "<blueprint-file.md>"
allowed-tools: Bash, Read, Edit, Grep, Glob, Task, Skill
---

# Run Blueprint

<blueprint_file> $ARGUMENTS </blueprint_file>

## Workflow

```
# 1. Load blueprint
If ARGUMENTS empty: BLUEPRINT = `ls -t docs/plans/*.md | head -1`
Else: BLUEPRINT = ARGUMENTS
Read(BLUEPRINT)
If missing "## Implementation Tasks": error → run /majestic:blueprint first

# 2. Start ralph-loop if not in one
If NOT exists .claude/ralph-loop.local.yml:
  /majestic-ralph:ralph-loop "/majestic:run-blueprint <BLUEPRINT>" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
  STOP

# 3. Parse tasks from ## Implementation Tasks
TASKS = extract tasks sorted by dependencies (independent first)
Status markers: ⏳ Pending | 🔄 In Progress | ✅ Complete | 🔴 Blocked

# 4. Execute next incomplete task
For TASK in TASKS where status != ✅:
  If any dependency not ✅: mark 🔴 Blocked, continue
  Edit blueprint: ⏳ → 🔄
  RESULT = /majestic:build-task "<TASK.id>" --no-ship --ac "<TASK.ac_items>"
  If RESULT.passed: Edit blueprint: 🔄 → ✅
  Else: Edit blueprint: 🔄 → 🔴
  Break after first task (ralph-loop handles iteration)

# 5. Check completion
If all tasks ✅ OR all remaining 🔴:
  /majestic:ship-it
  Output <promise>RUN_BLUEPRINT_COMPLETE</promise>
```
