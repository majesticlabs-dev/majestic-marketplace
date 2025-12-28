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

**Set terminal title:** `Skill(skill: "majestic-engineer:terminal-title", args: "<feature_summary>")`

Run in parallel:
- `agent git-researcher "[feature]"` - repository patterns
- `agent docs-researcher "[feature]"` - library documentation
- `agent best-practices-researcher "[feature]"` - external best practices

### 3. Spec Review

```
agent spec-reviewer "[feature + research findings]"
```

Incorporate gaps and edge cases into the plan.

### 4. Architecture Design

```
agent architect "[feature + research + spec review findings]"
```

The architect agent:
- Studies existing codebase architecture
- Designs solution approach
- Identifies integration points
- Recommends libraries/packages if needed

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
| Start building | `/majestic:build-task docs/plans/<filename>.md` |

### 8. Handle Task Breakdown

If user selects "Break into small tasks":

```
agent task-breakdown "Plan: docs/plans/<filename>.md"
```

The agent appends `## Implementation Tasks` section with:
- Parallelization matrix
- Tasks with story points (1-3 each)
- Dependencies between tasks

**After breakdown, use AskUserQuestion:**

**Question:** "Tasks added to plan. Create these in your task manager?"

| Option | Action |
|--------|--------|
| Yes, create all tasks | `Skill(skill: "backlog-manager")` for each task |
| Revise | Ask what to change, regenerate |
| Start building | `/majestic:build-task docs/plans/<filename>.md` |

## Notes

- This is a planning-only command - no implementation code
- Prefer simpler templates unless complexity warrants more detail
- Research agents run in parallel to save time
