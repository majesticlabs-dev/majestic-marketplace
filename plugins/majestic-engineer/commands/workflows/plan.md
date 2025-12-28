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

Detect feature type from keywords:

| Type | Keywords |
|------|----------|
| **UI** | page, component, form, button, modal, view, design, responsive |
| **DevOps** | terraform, ansible, infrastructure, deploy, cloud, docker, k8s |

**If UI feature:**
1. Check config: `Skill(skill: "config-reader", args: "design_system_path")`
2. If empty, check default: `docs/design/design-system.md`
3. If no design system found, suggest `/majestic:ux-brief` first

**If DevOps feature:** Note relevant skills (opentofu-coder, ansible-coder, cloud-init-coder).

### 2. Research (Parallel Agents)

**Set terminal title:** `Skill(skill: "majestic-engineer:terminal-title", args: "<feature_summary>")`

Run in parallel:
- `agent git-researcher "[feature]"` - repository patterns
- `agent docs-researcher "[feature]"` - library documentation
- `agent best-practices-researcher "[feature]"` - external best practices
- **If DevOps:** `agent infra-security-review` - audit existing IaC

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

**Choose template based on complexity:**

| Complexity | Template |
|------------|----------|
| Simple bug, small fix | `resources/plan-template-minimal.md` |
| Most features (default) | `resources/plan-template-standard.md` |
| Major architectural change | `resources/plan-template-comprehensive.md` |

**Output:** Write to `docs/plans/[YYYYMMDDHHMMSS]_<title>.md`

Include:
- Research findings with file paths (e.g., `src/models/user.rb:42`)
- External documentation URLs
- Related issues/PRs
- Design system reference (if UI)
- DevOps skills to apply (if infrastructure)

### 6. Review Plan

```
agent plan-review "docs/plans/<filename>.md"
```

Incorporate feedback and update the plan file before presenting to user.

### 7. Post-Generation Options

**Check auto_preview config:** `Skill(skill: "config-reader", args: "auto_preview false")`

If `auto_preview` is `true`: Execute `open docs/plans/<filename>.md`

**Then use AskUserQuestion:**

**Question:** "Plan ready at `docs/plans/<filename>.md`. What next?"

| Option | Condition | Action |
|--------|-----------|--------|
| Break into small tasks | Always | Run `agent task-breakdown` on the plan |
| Create as single epic | Always | `Skill(skill: "backlog-manager")` - one task for entire plan |
| Preview in editor | If `auto_preview` is `false` | `open docs/plans/<filename>.md` |
| Revise | Always | Ask what to change, regenerate |
| Start building | Always | `/majestic:build-task docs/plans/<filename>.md` |

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
