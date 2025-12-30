---
name: majestic:plan
description: Transform feature descriptions into well-structured project plans
argument-hint: "[feature description, bug report, or improvement idea]"
---

# Create a Plan

Transform feature descriptions into well-structured markdown plans.

## Feature Description

<feature_description> $ARGUMENTS </feature_description>

**If empty:** Ask user to describe the feature, bug fix, or improvement.

## Workflow

### 1. Feature Classification

Detect feature type and delegate to specialists:

| Type | Detection | Action |
|------|-----------|--------|
| **UI** | page, component, form, button, modal, design | Check design system |
| **DevOps** | terraform, ansible, infrastructure, cloud, docker | Delegate to `devops-plan` |

**If UI feature:**
1. Check config: `Skill(skill: "config-reader", args: "design_system_path")`
2. If empty, check default: `docs/design/design-system.md`
3. If no design system found, suggest `/majestic:ux-brief` first

**If DevOps feature:**
```
Skill(skill: "majestic-devops:devops-plan")
```
This skill detects IaC tools, providers, runs security review, and returns context for the plan.

### 2. Research (Parallel Agents)

Run in parallel with budget-enforced outputs via context-proxy:
- `agent context-proxy "agent: git-researcher | budget: 1500 | prompt: [feature]"` - repository patterns
- `agent context-proxy "agent: docs-researcher | budget: 2000 | prompt: [feature]"` - library documentation
- `agent context-proxy "agent: best-practices-researcher | budget: 2000 | prompt: [feature]"` - external best practices

**Budget guidance:**
| Agent | Budget | Rationale |
|-------|--------|-----------|
| git-researcher | 1500 | Historical patterns are concise |
| docs-researcher | 2000 | May need code examples |
| best-practices-researcher | 2000 | Citations important |

### 2.5. Context Check (Post-Research)

If combined research output > 5000 chars or context feels heavy:
- Run `/smart-compact` before proceeding
- Focus compaction on SUMMARIZE for research findings

### 3. Spec Review

```
agent context-proxy "agent: spec-reviewer | budget: 1500 | prompt: [feature + research findings]"
```

Incorporate gaps and edge cases into the plan.

### 4. Architecture Design

```
agent context-proxy "agent: architect | budget: 3000 | prompt: [feature + research + spec review findings]"
```

The architect agent:
- Studies existing codebase architecture
- Designs solution approach
- Identifies integration points
- Recommends libraries/packages if needed

**Note:** Architect has larger budget (3000) as it produces the implementation plan.

### 5. Write Plan

**Load plan-builder skill for template guidance:**

```
Skill(skill: "plan-builder")
```

The skill provides template selection criteria and templates in its resources.

**Output:** Write to `docs/plans/[YYYYMMDDHHMMSS]_<title>.md`

### 6. Review Plan

```
agent plan-review "docs/plans/<filename>.md"
```

Incorporate feedback and update the plan file before presenting to user.

### 7. Post-Generation Options - IMPORTANT!

**Check auto_preview config:** `Skill(skill: "config-reader", args: "auto_preview false")`

If `auto_preview` is `true`: Execute `open docs/plans/<filename>.md`

**Then use AskUserQuestion:**

**Question:** "Plan ready at `docs/plans/<filename>.md`. What next?"

| Option | Action |
|--------|--------|
| Break into small tasks | Run `agent task-breakdown` on the plan |
| Create as single epic  | `Skill(skill: "backlog-manager")` - one task for entire plan |
| Preview in editor | `open docs/plans/<filename>.md` |
| Revise | Ask what to change, regenerate |
| Build as single task | `/majestic:build-task docs/plans/<filename>.md` |

### 8. Handle Task Breakdown

If user selects "Break into small tasks":

```
agent task-breakdown "Plan: docs/plans/<filename>.md"
```

The agent appends `## Implementation Tasks` section with:
- Parallelization matrix
- Tasks with story points (1-3 each)
- Dependencies between tasks

**Check plan.auto_create_task config:** `Skill(skill: "config-reader", args: "plan.auto_create_task false")`

**If `plan.auto_create_task` is `true`:** Skip to step 9 (auto-create tasks).

**If `false`, use AskUserQuestion:**

**Question:** "Tasks added to plan. Create these in your task manager?"

| Option | Action |
|--------|--------|
| Yes, create all tasks | Create tasks and update plan (see step 9) |
| Revise | Ask what to change, regenerate |
| Build all tasks | `/majestic:build-plan docs/plans/<filename>.md` |

### 9. Create Tasks and Update Plan

When user chooses to create tasks (or if auto_create_task is true):

1. **Create tasks:** `Skill(skill: "backlog-manager")` for each task in Implementation Tasks section
2. **Collect task IDs:** Store the returned task ID/number for each created task
3. **Update plan document:** Edit the plan file to add task references

**Update format for Implementation Tasks section:**

```markdown
## Implementation Tasks

| Task | Points | Dependencies | Tracker |
|------|--------|--------------|---------|
| Set up database schema | 2 | - | #123 |
| Create API endpoints | 3 | #123 | #124 |
| Build UI components | 2 | #124 | #125 |
```

Or inline format:
```markdown
- [ ] Set up database schema (2 pts) → #123
- [ ] Create API endpoints (3 pts, depends: #123) → #124
```

**Task ID formats by system:**
- GitHub Issues: `#123`
- Linear: `PROJ-123`
- Beads: `BEADS-123`
- File-based: `TODO-123`

### 10. Offer to Build All Tasks

After tasks are created, use AskUserQuestion:

**Question:** "Tasks created in task manager. Start building?"

| Option | Action |
|--------|--------|
| Build all tasks now | `/majestic:build-plan docs/plans/<filename>.md` |
| Build with ralph (autonomous) | Show ralph-loop command to run |
| Done for now | Exit planning |

**If "Build with ralph":** Display:
```
Run this command for autonomous execution:
/ralph-loop "/majestic:build-plan docs/plans/<filename>.md" --max-iterations 50 --completion-promise "BUILD_PLAN_COMPLETE"
```

## Notes

- This is a planning-only command - no implementation code
- Prefer simpler templates unless complexity warrants more detail
- Research agents run in parallel to save time
