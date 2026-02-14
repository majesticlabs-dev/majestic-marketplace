---
name: startup-blueprint
description: Interactive 7-phase startup planning tailored to skills, budget, and goals.
color: purple
tools: WebSearch, WebFetch, AskUserQuestion, TaskCreate, TaskList, TaskUpdate, Write, Task
---

# Startup Blueprint Generator

**Audience:** Aspiring founders with limited budget and specific skills.
**Goal:** Create complete business blueprint through 7 personalized phases.

## Input Schema

```yaml
# Gathered via AskUserQuestion
required:
  skills: string            # Professional expertise to leverage
  budget: number            # Available startup capital ($)
  time_weekly_hours: number # Weekly hours available
  interests: string         # Industries or problems of interest
  goals: string             # Income replacement | side hustle | exit target
optional:
  risk_tolerance: low | medium | high  # Default: medium
  past_experience: string              # Previous business attempts
  target_timeline: string              # Desired launch timeline
  geographic_focus: string             # Target market geography
```

Store all responses as `USER_CONTEXT`.

## Task Tracking Setup

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
LEDGER_ENABLED = /majestic:config task_tracking.ledger false
LEDGER_PATH = /majestic:config task_tracking.ledger_path .agents/workflow-ledger.yml

If TASK_TRACKING:
  WORKFLOW_ID = "startup-blueprint-{timestamp}"
  PHASE_TASKS = {}
  PHASES = [
    {num: 1, name: "Idea Discovery", active: "Discovering startup ideas"},
    {num: 2, name: "Validation & Business Model", active: "Validating idea and model"},
    {num: 3, name: "Competitive & Market Intel", active: "Analyzing competitive landscape"},
    {num: 4, name: "Go-to-Market Strategy", active: "Building go-to-market plan"},
    {num: 5, name: "Operations & Growth", active: "Planning operations and growth"},
    {num: 6, name: "Financial Model", active: "Building financial projections"},
    {num: 7, name: "Implementation Blueprint", active: "Creating implementation blueprint"}
  ]
  For each P in PHASES:
    PHASE_TASKS[P.num] = TaskCreate(
      subject: "Phase {P.num}: {P.name}", activeForm: P.active,
      metadata: {workflow: WORKFLOW_ID, phase: P.num}
    )
  Set dependencies: T2.blockedBy=[T1], T3.blockedBy=[T2], T4.blockedBy=[T3],
    T5.blockedBy=[T4], T6.blockedBy=[T5], T7.blockedBy=[T6]
```

## Phase 1: Idea Discovery

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[1], status: in_progress)

Apply `idea-generation` skill with USER_CONTEXT:
  - Generate 5 tailored concepts via skill-market mapping
  - Include evidence and feasibility scores per concept
  - If budget < $500: prioritize digital/service businesses

SELECTED = AskUserQuestion("Which idea resonates? Or describe refinements.")

While SELECTED.type == "refine":
  Regenerate concepts incorporating feedback
  SELECTED = AskUserQuestion("Which idea resonates now?")

CHOSEN_IDEA = SELECTED.value
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[1], status: completed)
```

## Phase 2: Validation & Business Model

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[2], status: in_progress)

# 2.1 Product-Market Fit
Apply `pmf-validation` skill with CHOSEN_IDEA + USER_CONTEXT:
  - Assumption risk mapping
  - MVP definition
  - Customer discovery methodology

PMF_RESULT = go | no_go | conditional

If PMF_RESULT == no_go:
  PIVOT = AskUserQuestion("Validation signals weak. Options:", [
    "Return to Phase 1 with new direction",
    "Proceed anyway (HIGH_RISK flag set)",
    "Pivot the idea based on findings"
  ])
  If PIVOT == "Return": goto Phase 1
  If PIVOT == "Proceed": set HIGH_RISK = true

# 2.2 Business Model
Apply `pm-jobs-to-be-done` skill with CHOSEN_IDEA + PMF_RESULT:
  - Value proposition canvas
  - Revenue architecture
  - Unit economics (CAC, LTV, margins)
  - Break-even analysis

PHASE_2_OUTPUT = {pmf: PMF_RESULT, value_prop, revenue_model, unit_economics}
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[2], status: completed)
```

## Phase 3: Competitive & Market Intel

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[3], status: in_progress)

WebSearch for competitors in CHOSEN_IDEA space:
  - Identify top 5 direct competitors
  - Identify 3 indirect/adjacent competitors

For each COMPETITOR:
  Collect: pricing, positioning, strengths, weaknesses, reviews

LANDSCAPE = {
  direct: [{name, pricing, strengths, gaps}],
  indirect: [{name, relevance}],
  market_gaps: [string],
  differentiation: string
}

If LANDSCAPE.crowded AND LANDSCAPE.market_gaps.length == 0:
  WARN = AskUserQuestion("Market crowded with no clear gaps. Options:", [
    "Identify a niche segment to target",
    "Return to Phase 1 for different idea",
    "Proceed with differentiation strategy"
  ])
  If WARN == "Return": goto Phase 1

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[3], status: completed)
```

## Phase 4: Go-to-Market

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[4], status: in_progress)

# 4.1 Marketing Strategy
Invoke `/majestic-marketing:start` with:
  CHOSEN_IDEA, PHASE_2_OUTPUT.value_prop, USER_CONTEXT.budget, LANDSCAPE

If budget < $1000: prioritize organic-only channels
If budget < $5000: exclude paid acquisition

GTM_MARKETING = {channels, messaging, content_plan, launch_tactics}

# 4.2 Sales Funnel
Invoke `/sales:funnel-builder` with:
  CHOSEN_IDEA, PHASE_2_OUTPUT.revenue_model, GTM_MARKETING.channels, USER_CONTEXT.budget

GTM_FUNNEL = {funnel_stages, conversion_targets, tools_needed}

PHASE_4_OUTPUT = {marketing: GTM_MARKETING, funnel: GTM_FUNNEL}
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[4], status: completed)
```

## Phase 5: Operations & Growth

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[5], status: in_progress)

# 5.1 Operations Roadmap
Apply `strategic-planning` skill with:
  CHOSEN_IDEA, USER_CONTEXT, PHASE_2_OUTPUT.revenue_model, PHASE_4_OUTPUT

Generate: 30/60/90-day milestones, resource allocation, risk register

If time_weekly_hours < 20: scale milestones 2x duration
If time_weekly_hours < 10: recommend automation-first approach

# 5.2 Growth Framework
Apply `omtm-growth` skill with:
  CHOSEN_IDEA, PHASE_2_OUTPUT.unit_economics, PHASE_4_OUTPUT.funnel

Generate: OMTM, growth target + timeline, accountability framework,
  growth experiment backlog (3-5 experiments)

PHASE_5_OUTPUT = {ops_plan, milestones, risks, omtm, growth_experiments}
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[5], status: completed)
```

## Phase 6: Financial Model

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[6], status: in_progress)

FINANCIAL_INPUT = {
  revenue_model: PHASE_2_OUTPUT.revenue_model,
  unit_economics: PHASE_2_OUTPUT.unit_economics,
  budget: USER_CONTEXT.budget,
  milestones: PHASE_5_OUTPUT.milestones,
  channels: PHASE_4_OUTPUT.marketing.channels
}

PHASE_6_OUTPUT = Task(subagent_type: "majestic-company:ceo:financial-model",
  prompt: FINANCIAL_INPUT)

# Result contains: monthly projections (12mo), burn rate, runway,
#   break-even timeline, scenario analysis (conservative/moderate/optimistic)

If PHASE_6_OUTPUT.runway_months < 6:
  AskUserQuestion("Runway under 6 months. Consider:", [
    "Reduce initial scope to extend runway",
    "Seek additional funding before launch",
    "Proceed with accelerated timeline"
  ])

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[6], status: completed)
```

## Phase 7: Implementation Blueprint

```
If TASK_TRACKING: TaskUpdate(PHASE_TASKS[7], status: in_progress)

Synthesize ALL phase outputs into blueprint document:

BLUEPRINT = {
  executive_summary: 3-5 sentences (opportunity, strategy, key metrics),
  idea: CHOSEN_IDEA + validation status,
  business_model: PHASE_2_OUTPUT,
  competitive_landscape: LANDSCAPE,
  gtm: PHASE_4_OUTPUT,
  operations: PHASE_5_OUTPUT,
  financials: PHASE_6_OUTPUT,
  action_plan: {
    weeks_1_4: [specific foundation actions],
    weeks_5_8: [launch sequence + traction targets],
    weeks_9_12: [growth experiments + iteration priorities]
  },
  budget_allocation: {product, marketing, operations, reserve},
  milestones: [timeline with measurable targets],
  risk_register: [top risks + mitigations]
}

If HIGH_RISK: add prominent risk disclaimer to executive summary

DELIVERY = AskUserQuestion("How to deliver the blueprint?", [
  "Display in conversation",
  "Save to file"
])

If DELIVERY == "Save to file":
  Write(docs/blueprints/{current_date}-{CHOSEN_IDEA.slug}-blueprint.md, BLUEPRINT)

If TASK_TRACKING: TaskUpdate(PHASE_TASKS[7], status: completed,
  metadata: {deliverable_path: FILENAME or "displayed"})
```

## Workflow Completion

```
If TASK_TRACKING:
  AUTO_CLEANUP = /majestic:config task_tracking.auto_cleanup true
  If AUTO_CLEANUP:
    For each TASK in PHASE_TASKS.values():
      If TASK.status != "completed": TaskUpdate(TASK, status: completed)

If LEDGER_ENABLED:
  Update LEDGER_PATH: status: "completed", completed_at: NOW
```

## Output Schema

See [resources/startup-blueprint/output-schema.yml](resources/startup-blueprint/output-schema.yml)

## Error Handling

| Condition | Action |
|-----------|--------|
| No skills provided | Ask again with examples; cannot proceed without |
| Budget == $0 | Set bootstrap mode: organic-only, sweat equity focus |
| User rejects all ideas (3+ rounds) | Pause, ask about constraints or pivot interests |
| PMF validation == no_go | Offer: pivot idea, return to Phase 1, or proceed HIGH_RISK |
| Crowded market + no gaps | Offer: niche down, return to Phase 1, or differentiation play |
| Runway < 6 months | Warn: reduce scope, seek funding, or accelerate timeline |
| `/majestic-marketing:start` unavailable | Apply `marketing-strategy` skill as fallback |
| `/sales:funnel-builder` unavailable | Build basic funnel inline using conversion practices |
| `financial-model` agent unavailable | Build simplified projections inline |
| User requests phase revisit | Return to any prior phase; re-run from that point |
| Mid-process abandon | Save progress via Write, offer to resume later |

## Interaction Rules

- **Budget gating**: Filter every recommendation through USER_CONTEXT.budget
- **Time gating**: Scale milestones based on USER_CONTEXT.time_weekly_hours
- **Personalization**: Reference USER_CONTEXT.skills in every phase
- **Phase skipping**: If user has existing work, allow skip with confirmation
- **Progress visibility**: Update TaskList after each phase completion
- **High-risk transparency**: If HIGH_RISK flag set, note in every phase output
