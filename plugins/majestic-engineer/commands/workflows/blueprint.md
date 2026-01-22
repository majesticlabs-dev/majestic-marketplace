---
name: majestic:blueprint
description: Transform feature descriptions into well-structured project plans
argument-hint: "[feature description, bug report, or improvement idea]"
---

# Create a Blueprint

**CRITICAL: This is a WORKFLOW COMMAND, not Claude's built-in plan mode.**
Do NOT use EnterPlanMode or ExitPlanMode tools.

## Feature Description

<feature_description> $ARGUMENTS </feature_description>

**If empty:** Ask user to describe the feature, bug fix, or improvement.

## Workflow

### Phase 1: Discovery

```
/majestic-engineer:blueprint-discovery
```

Handles: Idea Refinement, Interview decision, Acceptance Criteria, Feature Classification.

**Wait for output:** `discovery_result`

### Phase 2: Research

```
/majestic-engineer:blueprint-research feature_description, discovery_result
```

Handles: Toolbox resolution, lessons discovery, parallel research agents, spec review.

**Wait for output:** `research_result`

### Phase 3: Research Validation

Quick checkpoint before architecture. Catches misalignment early.

```
research_summary = summarize research_result:
  - Key patterns found (2-3 bullets)
  - Similar implementations discovered
  - Potential constraints/blockers

AskUserQuestion:
  question: "Research found: {research_summary}. Continue to planning?"
  header: "Validate"
  options:
    - label: "Looks good"
      description: "Proceed to architecture phase"
    - label: "Missing something"
      description: "Tell me what to research deeper"
    - label: "Wrong direction"
      description: "Let's revisit the requirements"
```

**If "Missing something":**
```
AskUserQuestion: "What should I dig into?"
→ Run targeted research agent
→ Append to research_result
→ Return to Phase 3
```

**If "Wrong direction":**
```
→ Return to Phase 1 (Discovery)
```

### Phase 4: Architecture

```
Task(majestic-engineer:plan:architect):
  prompt: |
    Feature: {feature_description}
    Research: {research_result.research_findings}
    Spec: {research_result.spec_findings}
    Skills: {research_result.skill_content}
    Lessons: {research_result.lessons_context}
```

**Wait for output:** `architect_output`

### Phase 5: Capture Learnings

```
PRIMARY_DIR = extract main folder from architect_output.file_recommendations
AGENTS_MD = walk up from PRIMARY_DIR until AGENTS.md found (default: root)

If new patterns or decisions discovered:
  Edit(AGENTS_MD, append patterns/decisions)
```

### Phase 6: Write Plan

```
/majestic-engineer:plan-builder
```

Select template based on complexity:
- **Minimal:** Single file changes, simple bugs
- **Standard:** Most features (default)
- **Comprehensive:** Major features, architectural changes

**Output:** Write to `docs/plans/[YYYYMMDDHHMMSS]_<title>.md`

### Phase 7: Review Plan

```
Task(majestic-engineer:plan:plan-review):
  prompt: "Review plan at {plan_path}"
```

Incorporate feedback and update plan file.

### Phase 8: User Decision

Check auto_preview: `/majestic:config auto_preview false`

If `true`: `Bash(command: "open {plan_path}")`

```
AskUserQuestion:
  question: "Blueprint ready at `{plan_path}`. What next?"
  options:
    - "Build as single task" → Phase 9a
    - "Break into small tasks" → Phase 9b
    - "Create as single epic" → Phase 9c
    - "Deep dive into specifics" → Phase 8.1
    - "Preview plan" → Read and display, return to Phase 8
    - "Revise" → Ask what to change, return to Phase 6
```

**IMPORTANT:** After user selects, EXECUTE that action.

### Phase 8.1: Deep Dive

```
AskUserQuestion: "What aspect needs deeper research?"
```

Run focused research:
```
Task(majestic-engineer:research:best-practices-researcher):
  prompt: "Deep dive: {aspect} for feature {feature}"
Task(majestic-engineer:research:web-research):
  prompt: "{aspect} - patterns, examples, gotchas"
```

Update plan with findings, return to Phase 8.

### Phase 9: Execution

```
/majestic-engineer:blueprint-execution plan_path, user_choice
```

Handles: Task breakdown, task creation, build offering.

## Error Handling

| Scenario | Action |
|----------|--------|
| Discovery skill fails | Ask user for AC manually, continue |
| Research skill fails | Continue with architect (degraded) |
| User skips validation | Continue to Phase 4 |
| Architect fails | Log error, ask user to provide approach |
| Plan-review fails | Continue with original plan |
| Task creation fails | Report error, ask user to create manually |
| Config read fails | Use default value |
| User cancels | End workflow gracefully |

## Notes

- Blueprint-only command - no implementation code
- Research and spec-review run in parallel (inside blueprint-research)
- Architect MUST wait for research completion
- All phases are mandatory except branches (8.1, 9a/9b/9c)
- Always execute user's selected option
