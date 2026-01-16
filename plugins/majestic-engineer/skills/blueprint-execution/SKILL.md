---
name: blueprint-execution
description: Execution phase for blueprint workflow - task breakdown options, task creation, and build offering
---

# Blueprint Execution

Handles Steps 12-14 of the blueprint workflow: Task breakdown options, task creation, and build offering.

## Input

```yaml
plan_path: string              # e.g., docs/plans/20260114_auth.md
user_choice: string            # "single_task" | "breakdown" | "epic"
```

## 1. Execution Options

Present to user via AskUserQuestion:

| Option | Description | Next Step |
|--------|-------------|-----------|
| Build as single task | Execute plan in one session | → Single Task Flow |
| Break into small tasks | Decompose into 1-3 point tasks | → Task Breakdown Flow |
| Create as single epic | Track as one backlog item | → Epic Flow |

## 2. Single Task Flow

```
Skill(skill: "majestic-engineer:workflows:build-task", args="{plan_path}")
```

**End workflow.**

## 3. Task Breakdown Flow

```
Task(majestic-engineer:plan:task-breakdown, prompt="Plan: {plan_path}")
```

Agent appends to plan:
```markdown
## Implementation Tasks

| ID | Task | Points | Dependencies |
|----|------|--------|--------------|
| T1 | Setup auth middleware | 2 | - |
| T2 | Create login endpoint | 2 | T1 |
| T3 | Add session handling | 3 | T1 |

### Parallelization Matrix
- **Parallel Group 1:** T1
- **Parallel Group 2:** T2, T3 (after T1)
```

**Check auto-create config:**
```
/majestic:config blueprint.auto_create_task false
```

- If `true` → Create tasks automatically
- If `false` → Ask user confirmation

## 4. Epic Flow

Create single backlog item covering entire plan:
```
Skill(skill: "backlog-manager")
```

Update plan with task reference.

## 5. Create Tasks

For each task in Implementation Tasks:
```
Skill(skill: "backlog-manager")
→ Collect returned task_id
→ Update plan with reference
```

**Task ID formats by system:**

| System | Format | Example |
|--------|--------|---------|
| GitHub Issues | `#{number}` | `#123` |
| Linear | `{PROJECT}-{number}` | `PROJ-123` |
| Beads | `BEADS-{number}` | `BEADS-123` |
| File-based | `TODO-{number}` | `TODO-123` |

## 6. Build Offering

Present via AskUserQuestion:

| Option | Action |
|--------|--------|
| Build all tasks now | Invoke run-blueprint |
| Build with ralph (autonomous) | Display ralph command |
| Done for now | End workflow |

**Run-blueprint invocation:**
```
Skill(skill: "majestic-engineer:workflows:run-blueprint", args="{plan_path}")
```

**Ralph command to display:**
```
/ralph-loop "/majestic:run-blueprint {plan_path}" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## Output

```yaml
execution_result:
  execution_type: "single_task" | "breakdown" | "epic"
  tasks_created:
    - id: string
      title: string
      points: number
  plan_updated: boolean
  build_started: boolean
  ralph_command: string | null  # If user chose ralph
```
