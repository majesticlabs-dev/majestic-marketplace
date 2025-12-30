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

### 3. Context Check (Post-Research)

If combined research output > 5000 chars or context feels heavy:
- Run `/smart-compact` before proceeding
- Focus compaction on SUMMARIZE for research findings

### 4. Spec Review

```
agent context-proxy "agent: spec-reviewer | budget: 1500 | prompt: [feature + research findings]"
```

Incorporate gaps and edge cases into the plan.

### 5. Architecture Design

```
agent context-proxy "agent: architect | budget: 3000 | prompt: [feature + research + spec review findings]"
```

The architect agent:
- Studies existing codebase architecture
- Designs solution approach
- Identifies integration points
- Recommends libraries/packages if needed

**Note:** Architect has larger budget (3000) as it produces the implementation plan.

### 6. Delegate to Plan Workflow Manager

Pass all gathered context to the plan-workflow-manager agent:

```
agent majestic-engineer:workflow:plan-workflow-manager "Feature: [feature description] | Research: [combined research] | Spec Review: [spec findings] | Architecture: [architect recommendations]"
```

The agent handles:
1. Writing the plan document
2. Running plan review
3. Setting terminal title (`/rename`)
4. Auto-preview check
5. Presenting user options
6. Task breakdown (if selected)
7. Creating tasks in tracker
8. Offering build options

**IMPORTANT:** The workflow manager agent executes all steps sequentially. Do not add additional steps after delegation - the agent handles everything through completion.

## Notes

- This command gathers context (steps 1-5), then delegates orchestration (step 6)
- Research agents run in parallel to save time
- The workflow manager agent ensures no steps are skipped
- This is a planning-only command - no implementation code
