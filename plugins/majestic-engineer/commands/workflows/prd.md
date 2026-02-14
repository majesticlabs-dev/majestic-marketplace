---
name: majestic:prd
description: Create a Product Requirements Document (PRD) for a new product or feature
argument-hint: "[--guided] [product or feature description]"
allowed-tools: Read, Write, Edit, WebSearch, WebFetch, AskUserQuestion, TaskCreate, TaskUpdate, TaskList, TaskGet
disable-model-invocation: true
---

# Create a Product Requirements Document (PRD)

Generate a comprehensive PRD that defines WHAT to build and WHY.

## Arguments

<raw_arguments>$ARGUMENTS</raw_arguments>

- If `--guided`: Enable guided discovery (one question at a time)
- Otherwise: Batch 3-5 questions upfront

## Task Tracking Setup

```
TASK_TRACKING = /majestic:config task_tracking.enabled false

If TASK_TRACKING:
  PRD_WORKFLOW_ID = "prd-{timestamp}"
  PHASE_TASKS = {}

  PHASES = [
    {num: 1, name: "Clarifying Questions", active: "Gathering requirements"},
    {num: 2, name: "Generate PRD", active: "Generating PRD"},
    {num: 3, name: "Review & Options", active: "Reviewing PRD"},
    {num: 4, name: "Technical Expansion", active: "Expanding technical depth"},
    {num: 5, name: "Create Backlog Items", active: "Creating backlog items"}
  ]

  For each P in PHASES:
    PHASE_TASKS[P.num] = TaskCreate(
      subject: "Phase {P.num}: {P.name}",
      activeForm: P.active,
      metadata: {workflow: PRD_WORKFLOW_ID, phase: P.num}
    )

  # Sequential dependencies; phases 4 and 5 both depend on 3 (independent of each other)
  TaskUpdate(PHASE_TASKS[2], addBlockedBy: [PHASE_TASKS[1]])
  TaskUpdate(PHASE_TASKS[3], addBlockedBy: [PHASE_TASKS[2]])
  TaskUpdate(PHASE_TASKS[4], addBlockedBy: [PHASE_TASKS[3]])
  TaskUpdate(PHASE_TASKS[5], addBlockedBy: [PHASE_TASKS[3]])
```

---

## Phase 1: Clarifying Questions

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[1], status: "in_progress")

### Default Mode

Use `AskUserQuestion` to ask 3-5 essential questions **in a single batch**:

- **Problem/Goal**: What problem does this solve?
- **Target Users**: Who will use this?
- **MVP Boundaries**: What's the minimum to ship?
- **Success Criteria**: How will we measure success?
- **Technical Context**: Any existing systems to integrate?

### Guided Mode (`--guided`)

Ask questions **ONE AT A TIME**:

1. **Problem/Opportunity** - What problem, who experiences it, how painful?
2. **Solution Concept** - How does your product solve this?
3. **Target Users** - Who specifically, technical level, current workaround?
4. **Core Capabilities** - 3-5 must-have features, what's NOT in v1?
5. **Success Criteria** - How will you know it's working?
6. **Constraints** - Technical, time, resource, dependencies?

After sufficient info, synthesize and confirm before PRD generation.

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[1], status: "completed")

---

## Phase 2: Generate PRD

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[2], status: "in_progress")

Read the PRD template from `resources/prd/prd-template.txt` (relative to this command file).

Customize with user's answers:
- Fill in problem statement, user personas
- Write user stories with acceptance criteria
- Prioritize features using MoSCoW
- Set success metrics

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[2], status: "completed")

---

## Phase 3: Review & Options

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[3], status: "in_progress")

1. **Save** to `docs/prd/prd-[feature-name].md`

2. **Auto-Preview Check**
   Read: !`claude -p "/majestic:config auto_preview false"`
   If "true": Execute `open docs/prd/prd-[feature-name].md`

3. **Present options** via AskUserQuestion:
   - **Done (Recommended)** - Balanced PRD is sufficient
   - **Expand with technical depth** - Add API, Data Model, Security, Performance sections
   - **Revise sections** - Provide feedback on specific sections
   - **Review and refine** - Apply document-refinement skill, loop to Phase 3
   - **Preview in editor** (if not auto-previewed)

**If "Revise sections":** Loop back to Phase 3 without completing (keep in_progress).

**If "Review and refine":**
```
Apply document-refinement skill to docs/prd/prd-[feature-name].md
→ Auto-fix minor issues in PRD file
→ Present refinement report to user
→ Loop to Phase 3
```

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[3], status: "completed")

---

## Phase 4: Technical Expansion (If Requested)

If user selected "Expand with technical depth":
  If TASK_TRACKING: TaskUpdate(PHASE_TASKS[4], status: "in_progress")
Else:
  If TASK_TRACKING: TaskUpdate(PHASE_TASKS[4], status: "completed")
  Skip to Phase 5

Add sections from `resources/prd/technical-expansion.txt`:
- API Specifications (endpoints, schemas, auth)
- Data Model with Mermaid ERD
- Security Considerations (AuthN/AuthZ, OWASP)
- Performance & Scalability (SLOs, scaling strategy)

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[4], status: "completed")

---

## Phase 5: Create Backlog Items (Optional)

If user accepted backlog creation:
  If TASK_TRACKING: TaskUpdate(PHASE_TASKS[5], status: "in_progress")
Else:
  If TASK_TRACKING: TaskUpdate(PHASE_TASKS[5], status: "completed")
  Skip to Output

Offer backlog creation:
- **Create Must Have items** - From Must Have features only
- **Create all items** - From all prioritized features
- **Skip**

If accepted:
1. Read backlog configuration from project CLAUDE.md
2. For each user story/feature:
   - Extract title and acceptance criteria
   - Set priority (Must=p1, Should=p2, Could=p3)
   - Create item using configured backend

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[5], status: "completed")

## Cleanup

```
If TASK_TRACKING:
  AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true
  If AUTO_CLEANUP:
    For each TASK in PHASE_TASKS.values():
      If TASK.status != "completed":
        TaskUpdate(TASK, status: "completed")
```

---

## Output

Save to: `docs/prd/prd-[feature-name].md`

Create directory if needed.
