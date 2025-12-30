---
name: majestic:blueprint
description: Transform feature descriptions into well-structured project plans
argument-hint: "[feature description, bug report, or improvement idea]"
---

# Create a Blueprint

**CRITICAL: This is a WORKFLOW SKILL, not Claude's built-in plan mode.**
Do NOT use EnterPlanMode or ExitPlanMode tools. Execute each step below using the specified tools.

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

### 2. Research (Parallel Agents)

Execute these THREE Task() calls in parallel:

```
Task(subagent_type="majestic-engineer:research:git-researcher", prompt="[feature description]")
Task(subagent_type="majestic-engineer:research:docs-researcher", prompt="[feature description]")
Task(subagent_type="majestic-engineer:research:best-practices-researcher", prompt="[feature description]")
```

Collect results from all three before proceeding.

### 3. Spec Review

```
Task(subagent_type="majestic-engineer:plan:spec-reviewer", prompt="Feature: [feature] | Research findings: [combined research]")
```

Incorporate gaps and edge cases into the plan.

### 4. Architecture Design

```
Task(subagent_type="majestic-engineer:plan:architect", prompt="Feature: [feature] | Research: [research] | Spec review: [spec findings]")
```

The architect agent:
- Studies existing codebase architecture
- Designs solution approach
- Identifies integration points
- Recommends libraries/packages if needed

### 5. Write Plan

Load the plan-builder skill for template guidance:
```
Skill(skill: "plan-builder")
```

Select template based on complexity:
- **Minimal:** Single file changes, simple bugs
- **Standard:** Most features, multi-file changes (default)
- **Comprehensive:** Major features, architectural changes

**Output:** Write to `docs/plans/[YYYYMMDDHHMMSS]_<title>.md`

### 6. Review Plan

```
Task(subagent_type="majestic-engineer:plan:plan-review", prompt="Review plan at docs/plans/<filename>.md")
```

Incorporate feedback and update the plan file.

### 7. Set Terminal Title

```
Skill(skill: "rename", args="<plan-title>")
```

### 8. Preview and User Options

**Check auto_preview config:**
```
Skill(skill: "config-reader", args: "auto_preview false")
```

If `auto_preview` is `true`: Show plan content using `Read(file_path="docs/plans/<filename>.md")`

**MANDATORY: Use AskUserQuestion to present options:**

Question: "Blueprint ready at `docs/plans/<filename>.md`. What next?"

| Option | Action |
|--------|--------|
| Build as single task | Go to Step 9A |
| Break into small tasks | Go to Step 9B |
| Create as single epic | Go to Step 9C |
| Preview plan | Read and display plan content, return to Step 8 |
| Revise | Ask what to change, return to Step 5 |

**IMPORTANT:** After user selects an option, EXECUTE that action. Do not stop.

### 9A: Build Single Task

```
Skill(skill: "majestic-engineer:workflows:build-task", args="docs/plans/<filename>.md")
```

**End workflow.**

### 9B: Task Breakdown

```
Task(subagent_type="majestic-engineer:plan:task-breakdown", prompt="Plan: docs/plans/<filename>.md")
```

The agent appends `## Implementation Tasks` section with:
- Parallelization matrix
- Tasks with story points (1-3 each)
- Dependencies between tasks

**Check auto_create_task config:**
```
Skill(skill: "config-reader", args: "blueprint.auto_create_task false")
```

- **If `true`:** Skip to Step 10
- **If `false`:** Ask user "Tasks added to plan. Create these in your task manager?"
  - If Yes → Go to Step 10
  - If No → End workflow

### 9C: Single Epic

Create a single task covering the entire plan:
```
Skill(skill: "backlog-manager")
```

Update the plan document with the task reference, then go to Step 11.

### 10: Create Tasks

For each task in the Implementation Tasks section:
1. Create task: `Skill(skill: "backlog-manager")`
2. Collect the returned task ID/number
3. Update the plan document with task references

**Task ID formats by system:**
| System | Format |
|--------|--------|
| GitHub Issues | `#123` |
| Linear | `PROJ-123` |
| Beads | `BEADS-123` |
| File-based | `TODO-123` |

### 11: Offer Build

Use AskUserQuestion:

Question: "Tasks created. Start building?"

| Option | Action |
|--------|--------|
| Build all tasks now | `Skill(skill: "majestic-engineer:workflows:run-blueprint", args="docs/plans/<filename>.md")` |
| Build with ralph (autonomous) | Display ralph-loop command (see below) |
| Done for now | End workflow |

**Ralph command to display:**
```
/ralph-loop "/majestic:run-blueprint docs/plans/<filename>.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Research agent fails | Log warning, continue with available research |
| Plan-review fails | Log warning, continue with original plan |
| Task creation fails | Report error, ask user to create manually |
| Config read fails | Use default value (false) |
| User cancels at any step | End workflow gracefully |

## Notes

- This is a blueprint-only command - no implementation code
- Research agents run in parallel to save time
- All steps are mandatory except branches (9A/9B/9C)
- Always execute user's selected option - never stop at presenting choices
