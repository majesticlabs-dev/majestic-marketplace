---
name: pm-discovery
description: Product discovery frameworks for PMs - customer interviews, assumption mapping, JTBD, RICE prioritization, and opportunity solution trees. Transforms research into product decisions.
triggers:
  - pm discovery
  - product discovery
  - customer interview
  - assumption mapping
  - rice prioritization
  - ice scoring
  - jobs to be done
  - jtbd
  - opportunity solution tree
  - feature prioritization
  - product hypothesis
---

# PM Discovery

Product discovery frameworks for turning research into product decisions. Use after market research, before implementation planning.

## When to Use

- After customer interviews, before synthesizing insights
- When prioritizing features or opportunities
- When validating product hypotheses
- When mapping assumptions to test
- When structuring discovery findings for stakeholders

## Discovery Frameworks

### 1. Customer Interview Synthesis

**Interview Question Bank:**

```markdown
## Problem Discovery
- "Walk me through the last time you [did X]..."
- "What's the hardest part about [doing X]?"
- "Why is that hard?" (ask 3x)
- "What have you tried to solve this?"
- "What happened when you tried that?"

## Current Solution Analysis
- "How do you handle [X] today?"
- "How often do you do this?"
- "What would happen if you couldn't do this?"
- "How much time/money does this cost you?"

## Switching Signals
- "Have you looked for other solutions?"
- "What would make you switch?"
- "What's stopping you from switching now?"

## Value Discovery
- "If you could wave a magic wand, what would change?"
- "What would that be worth to you?"
- "Who else cares about this problem?"
```

**Interview Synthesis Template:**

```markdown
## Interview: [Customer Name/Segment]
**Date:** YYYY-MM-DD | **Duration:** X min | **Role:** [Title]

### Problem Quotes (verbatim)
> "[Exact quote about the problem]"
> "[Another revealing quote]"

### Current Behavior
- Does [X] using [current solution]
- Frequency: [daily/weekly/monthly]
- Time spent: [X hours/month]

### Pain Intensity: [1-5]
- 1: Mild annoyance
- 3: Significant friction
- 5: "Hair on fire" problem

### Willingness to Pay Signal
- [ ] Actively searching for solutions
- [ ] Has budget allocated
- [ ] Named a specific price point: $___
- [ ] Would switch immediately if solved

### Key Insight
[One sentence capturing the non-obvious learning]
```

### 2. Assumption Mapping

**Riskiest Assumption Test (RAT):**

```markdown
## Assumption Map

### Desirability (Will they want it?)
| Assumption | Evidence For | Evidence Against | Risk Level |
|------------|--------------|------------------|------------|
| [Users want X] | [data] | [data] | High/Med/Low |

### Viability (Will it work for the business?)
| Assumption | Evidence For | Evidence Against | Risk Level |
|------------|--------------|------------------|------------|
| [Users will pay $X] | [data] | [data] | High/Med/Low |

### Feasibility (Can we build it?)
| Assumption | Evidence For | Evidence Against | Risk Level |
|------------|--------------|------------------|------------|
| [We can integrate with X] | [data] | [data] | High/Med/Low |

### Riskiest Assumption to Test Next
**Assumption:** [The one with highest risk + least evidence]
**Test:** [Cheapest way to validate/invalidate]
**Success Criteria:** [Specific threshold]
**Timeline:** [Days/weeks]
```

### 3. Jobs-to-be-Done (JTBD)

**Job Statement Format:**

```
When [situation/trigger],
I want to [motivation/goal],
so I can [expected outcome].
```

**JTBD Canvas:**

```markdown
## Job: [Core functional job]

### Trigger/Situation
- When does this job arise?
- What context are they in?

### Functional Job (what they're trying to do)
[Action verb] + [object] + [clarifying context]
Example: "Organize customer feedback by theme before the weekly product meeting"

### Emotional Job (how they want to feel)
- Feel [emotion] about [situation]
Example: "Feel confident presenting insights to leadership"

### Social Job (how they want to be perceived)
- Be seen as [perception] by [audience]
Example: "Be seen as data-driven by the exec team"

### Current Solutions
| Solution | Hiring Criteria | Firing Criteria |
|----------|-----------------|-----------------|
| [Tool/workaround] | [Why they use it] | [Why they'd stop] |

### Outcome Metrics
What does "job done well" look like?
- Speed: [Complete X in Y minutes]
- Quality: [Z accuracy/completeness]
- Confidence: [Feel certain about decision]
```

### 4. Feature Prioritization

**RICE Scoring:**

```
RICE Score = (Reach × Impact × Confidence) / Effort
```

| Factor | Definition | Scale |
|--------|------------|-------|
| **Reach** | Users affected per quarter | Actual number |
| **Impact** | Effect on users | 3=Massive, 2=High, 1=Medium, 0.5=Low, 0.25=Minimal |
| **Confidence** | How sure are you? | 100%=High, 80%=Medium, 50%=Low |
| **Effort** | Person-months to ship | Actual estimate |

**RICE Table:**

```markdown
| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| [Feature A] | 5000 | 2 | 80% | 2 | 4000 |
| [Feature B] | 1000 | 3 | 50% | 1 | 1500 |
```

**ICE Scoring (simpler alternative):**

```
ICE Score = Impact × Confidence × Ease
```

| Factor | Scale |
|--------|-------|
| **Impact** | 1-10 (potential value) |
| **Confidence** | 1-10 (certainty of impact) |
| **Ease** | 1-10 (implementation simplicity) |

### 5. Opportunity Solution Tree

**Structure:**

```
Outcome (measurable business goal)
├── Opportunity 1 (unmet customer need)
│   ├── Solution 1a
│   │   └── Experiment: [test]
│   └── Solution 1b
│       └── Experiment: [test]
├── Opportunity 2 (another need)
│   └── Solution 2a
│       └── Experiment: [test]
└── Opportunity 3
    └── ...
```

**OST Template:**

```markdown
## Outcome
**Goal:** [Measurable objective]
**Current:** [Baseline metric]
**Target:** [Target metric]
**Timeline:** [By when]

## Opportunity Map

### Opportunity 1: [Customer need/pain point]
**Evidence:** [Interview quotes, data]
**Size:** [How many users affected]

**Solutions considered:**
1. **[Solution A]**
   - Effort: [S/M/L]
   - Experiment: [How to test cheaply]
   - Success metric: [What to measure]

2. **[Solution B]**
   - Effort: [S/M/L]
   - Experiment: [How to test cheaply]
   - Success metric: [What to measure]

**Selected:** [Which and why]
```

### 6. Product Hypothesis

**Hypothesis Format:**

```markdown
## Hypothesis: [Short name]

**We believe that** [building this feature/making this change]
**For** [target user segment]
**Will result in** [expected outcome/behavior change]
**We will know we're right when** [measurable success criteria]

### Riskiest Assumption
[The assumption that if wrong, invalidates the hypothesis]

### Minimum Test
[Cheapest/fastest way to validate]
- Type: [Prototype/Fake door/Concierge/etc]
- Duration: [X days/weeks]
- Sample size: [N users]

### Decision Criteria
- **Ship if:** [specific threshold met]
- **Iterate if:** [mixed signals, specify]
- **Kill if:** [specific threshold not met]
```

## Discovery Synthesis

After gathering insights, synthesize into:

```markdown
## Discovery Summary: [Feature/Initiative]

### What We Learned
1. [Key insight with evidence]
2. [Key insight with evidence]
3. [Key insight with evidence]

### User Segments & Their Jobs
| Segment | Primary Job | Pain Intensity | Size |
|---------|-------------|----------------|------|
| [Segment A] | [JTBD] | [1-5] | [N users] |

### Prioritized Opportunities
| Rank | Opportunity | Evidence | RICE |
|------|-------------|----------|------|
| 1 | [Opp] | [Quote/data] | [Score] |

### Recommended Next Step
**Do:** [Specific action]
**Test:** [What to validate]
**Success looks like:** [Measurable outcome]

### What We Still Don't Know
- [ ] [Open question to investigate]
- [ ] [Assumption still untested]
```

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Instead Do |
|--------------|--------------|------------|
| Leading questions | Confirms bias, not truth | Ask open-ended, follow with "why" |
| Hypothetical pricing | People lie about future spending | Ask about current spending |
| Feature requests as truth | Users describe solutions, not problems | Dig for underlying need |
| Small sample size decisions | Anecdotes ≠ patterns | Require 5+ signals minimum |
| Skipping competitor analysis | Reinventing existing solutions | Research before ideating |

## Integration with Other Skills

- **Before PM Discovery:** Use `problem-research` for market pain points
- **Before PM Discovery:** Use `customer-discovery` to find user communities
- **After PM Discovery:** Use `/majestic:prd` to document requirements
- **After PM Discovery:** Use `/majestic:plan` for implementation planning
