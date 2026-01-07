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

### 1. Interview (Optional)

For complex or ambiguous features, offer a deep requirements interview first:

```
AskUserQuestion: "This feature could benefit from a requirements interview. Would you like to explore it in depth first?"
Options:
- "Yes, interview me first" → Skill(skill: "majestic:interview", args: "[feature description]"), then use interview output as refined input
- "No, proceed to planning" → Continue to Step 2
```

**When to suggest interview:**
- Feature description is vague or short (< 2 sentences)
- Contains words like "maybe", "probably", "something like"
- Involves multiple stakeholders or systems
- User seems uncertain when describing

**Skip interview suggestion for:**
- Bug fixes with clear reproduction steps
- Small, well-defined tasks
- Features with existing specs/PRDs

### 2. Definition of Done

**MANDATORY: Ask the user what "done" means for this feature.**

DoD describes feature acceptance criteria, not technical quality (tests, code review, etc. are handled by other agents).

**You MUST use AskUserQuestion tool:**
```
AskUserQuestion(
  questions: [{
    question: "What behavior must work for this feature to be done?",
    header: "Done when",
    options: [
      { label: "User can perform action", description: "Feature enables a specific user action" },
      { label: "System responds correctly", description: "API/backend behaves as expected" },
      { label: "UI displays properly", description: "Visual elements render correctly" },
      { label: "Data is persisted", description: "Changes are saved to database" }
    ],
    multiSelect: true
  }]
)
```

**CRITICAL:** Do NOT skip this step. Wait for user response before proceeding.

**Good DoD examples (feature behavior):**
- "Authenticated user can login and redirect to dashboard"
- "Form validates email format before submission"
- "API returns 404 for non-existent resources"
- "Export button generates CSV with all visible columns"

**Bad DoD examples (already handled by other agents):**
- ❌ "Tests pass" → always-works-verifier
- ❌ "Code reviewed" → quality-gate
- ❌ "No lint errors" → slop-remover

**For each DoD item, capture how to verify:**

| Item | Verification |
|------|--------------|
| User can login and redirect | `curl -X POST /login` or manual check |
| Form validates email | `bundle exec rspec spec/features/signup_spec.rb` |
| API returns 404 | `curl /api/nonexistent` returns 404 |

**Store the DoD table** - it will be:
- Written to plan document (Step 8)
- Verified by `dod-verifier` agent during quality gate

### 3. Feature Classification

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

### 4. Resolve Toolbox + Discover Lessons

**Read config values (run in parallel):**
```
Skill(skill: "config-reader", args: "tech_stack generic")
Skill(skill: "config-reader", args: "lessons_path .claude/lessons/")
```

**Run both agents in parallel:**
```
Task 1 (majestic-engineer:workflow:toolbox-resolver):
  prompt: "Stage: blueprint | Tech Stack: [tech_stack from config-reader]"

Task 2 (majestic-engineer:workflow:lessons-discoverer):
  prompt: "workflow_phase: planning | tech_stack: [tech_stack] | task: [feature description]"
```

**Store outputs for subsequent steps:**
- `research_hooks` → use in Step 5
- `coding_styles` → use in Step 6
- `lessons_context` → use in Step 7 (architect)

**Error handling:**
- If no toolbox found: Continue with core agents only (Step 5)
- If lessons directory doesn't exist: Continue (no error)
- If discovery returns 0 lessons: Continue (log "No relevant lessons found")
- If discovery fails: Log warning, continue with original workflow

These are **non-blocking** - failures do not stop the workflow.

### 5. Research (Parallel Agents)

**Core agents (always run):**

```
Task(subagent_type="majestic-engineer:research:git-researcher", prompt="[feature]")
Task(subagent_type="majestic-engineer:research:docs-researcher", prompt="[feature]")
Task(subagent_type="majestic-engineer:research:best-practices-researcher", prompt="[feature]")
```

**Stack-specific agents (from toolbox):**

For each `research_hook` in toolbox config:
1. Check if `triggers.any_substring` matches feature description
2. If match, spawn: `Task(subagent_type="[hook.agent]", prompt="[feature] | Context: [hook.context]")`

Cap at 5 total agents to avoid noise.

Collect results from all agents before proceeding.

### 6. Spec Review + Skill Injection (Parallel)

Run these two steps in parallel - they have no dependencies on each other:

```
# Run in parallel:
Task(subagent_type="majestic-engineer:plan:spec-reviewer", prompt="Feature: [feature] | Research findings: [combined research]")
Skill(skill: "[each skill from toolbox.coding_styles]")
```

**Wait for BOTH to complete before proceeding to Step 7.**

Store outputs:
- `spec_findings` → gaps, edge cases, questions from spec-reviewer
- `skill_content` → loaded coding style content

### 7. Architecture Design

**CRITICAL: Do NOT run in parallel with Step 6. Wait for spec-reviewer to complete.**

The architect MUST receive spec findings to avoid designing for incomplete requirements.

```
Task(subagent_type="majestic-engineer:plan:architect",
     prompt="Feature: [feature] | Research: [research] | Spec: [spec_findings] | Skills: [skill_content] | Lessons: [lessons_context from Step 4]")
```

The architect agent:
- Studies existing codebase architecture
- Designs solution approach informed by spec gaps
- Considers lessons from past implementations (from Step 4)
- Identifies integration points
- Recommends libraries/packages if needed

**Lessons integration:** If lessons_context contains relevant lessons, the architect should:
- Reference constraints from documented anti-patterns
- Apply patterns from similar past work
- Avoid known pitfalls documented in lessons

### 8. Write Plan

Load the plan-builder skill for template guidance:
```
Skill(skill: "plan-builder")
```

Select template based on complexity:
- **Minimal:** Single file changes, simple bugs
- **Standard:** Most features, multi-file changes (default)
- **Comprehensive:** Major features, architectural changes

**Output:** Write to `docs/plans/[YYYYMMDDHHMMSS]_<title>.md`

### 9. Review Plan

```
Task(subagent_type="majestic-engineer:plan:plan-review", prompt="Review plan at docs/plans/<filename>.md")
```

Incorporate feedback and update the plan file.

### 10. Preview and User Options

**Check auto_preview config:**
```
Skill(skill: "config-reader", args: "auto_preview false")
```

**If `auto_preview` is `true`:** Open the plan file in the user's default editor:
```
Bash(command: "open docs/plans/<filename>.md")
```

**MANDATORY: Use AskUserQuestion to present options:**

Question: "Blueprint ready at `docs/plans/<filename>.md`. What next?"

| Option | Action |
|--------|--------|
| Build as single task | Go to Step 11.1 |
| Break into small tasks | Go to Step 11.2 |
| Create as single epic | Go to Step 11.3 |
| Deep dive into specifics | Go to Step 10.1 |
| Preview plan | Read and display plan content, return to Step 10 |
| Revise | Ask what to change, return to Step 8 |

**IMPORTANT:** After user selects an option, EXECUTE that action. Do not stop.

### 10.1. Deep Dive

**Ask user what aspect needs more research:**

```
AskUserQuestion: "What aspect of the plan needs deeper research?"
Options: [Free text input expected]
```

**Execute focused research:**

Check toolbox `research_hooks` for relevant agents based on user's aspect, then run:

```
# Core deep-dive:
Task(subagent_type="majestic-engineer:research:best-practices-researcher", prompt="Deep dive: [user's aspect] for feature [feature]")
Task(subagent_type="majestic-engineer:research:web-research", prompt="[user's aspect] - patterns, examples, gotchas")

# Plus any matching research_hooks from toolbox
```

**Update the plan:**

1. Read the existing plan: `Read(file_path="docs/plans/<filename>.md")`
2. Identify the section most relevant to user's aspect
3. Enrich that section with research findings
4. Write updated plan: `Edit(file_path="docs/plans/<filename>.md", ...)`

**Return to Step 10** to present options again.

### 11.1. Build Single Task

```
Skill(skill: "majestic-engineer:workflows:build-task", args="docs/plans/<filename>.md")
```

**End workflow.**

### 11.2. Task Breakdown

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

- **If `true`:** Skip to Step 12
- **If `false`:** Ask user "Tasks added to plan. Create these in your task manager?"
  - If Yes → Go to Step 12
  - If No → End workflow

### 11.3. Single Epic

Create a single task covering the entire plan:
```
Skill(skill: "backlog-manager")
```

Update the plan document with the task reference, then go to Step 13.

### 12. Create Tasks

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

### 13. Offer Build

Use AskUserQuestion:

Question: "Tasks created. Start building?"

| Option | Action |
|--------|--------|
| Build all tasks now | `Skill(skill: "majestic-engineer:workflows:run-blueprint", args="docs/plans/<filename>.md")` |
| Build with ralph (autonomous) | Display ralph-loop command (see below) |
| Done for now | End workflow |

**Ralph command to display:**
```
/ralph-wiggum:ralph-loop "/majestic:run-blueprint docs/plans/<filename>.md" --max-iterations 50 --completion-promise "RUN_BLUEPRINT_COMPLETE"
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Toolbox resolution fails | Continue with core agents only |
| Research agent fails | Log warning, continue with available research |
| Plan-review fails | Log warning, continue with original plan |
| Task creation fails | Report error, ask user to create manually |
| Config read fails | Use default value (false) |
| User cancels at any step | End workflow gracefully |

## Notes

- This is a blueprint-only command - no implementation code
- Research agents run in parallel to save time
- Step 6 (spec-review + skill injection) runs in parallel internally
- **Step 7 (architect) MUST wait for Step 6** - architect needs spec findings to avoid designing for incomplete requirements
- Toolbox provides stack-specific capabilities without hardcoding
- All steps are mandatory except branches (11.1/11.2/11.3)
- Always execute user's selected option - never stop at presenting choices
