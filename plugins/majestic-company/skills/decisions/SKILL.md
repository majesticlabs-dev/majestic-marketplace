---
name: decisions
description: Structured business decision-making using Tree of Thoughts methodology with expert consultants exploring multiple approaches
---

# Business Decision Analysis

**Audience:** Founders and leaders facing significant business decisions.

**Goal:** Facilitate business decisions via Tree of Thoughts (ToT) with 4-expert panel debate.

## Input Schema

```yaml
challenge: string           # Business problem to evaluate
complexity: simple|complex  # Determines depth (inferred or asked)
constraints: string[]       # Optional: budget, timeline, resources
```

## Expert Panel

| Consultant | Focus Areas |
|------------|-------------|
| Growth Strategist | Revenue opportunities, market expansion, competitive advantage |
| Operations Expert | Feasibility, implementation complexity, resource requirements |
| Financial Analyst | ROI, cost structures, cash flow impact, risk-adjusted returns |
| Skeptic Risk Analyst | Failure modes, worst-case scenarios, hidden risks, blind spots |

## Analysis Workflow

### 1. Challenge Assessment

Determine complexity:
- Complex triggers: >$100K investment, >20% team impact, market entry/exit, M&A

### 2. Branch Generation

For each consultant (Growth, Operations, Financial):
- Generate 3 distinct approaches
- For each approach:
  - Identify 2-3 potential outcomes with probability assessment
  - List pros and cons
  - Quantify impact where possible

### 3. Risk Analysis

Skeptic reviews all 9 approaches:
- For each approach:
  - Identify primary failure mode
  - Describe worst-case scenario
  - Expose hidden assumptions
- List critical blind spots across all approaches

### 4. Consultant Debate

- Identify points of agreement
- Surface disagreements with reasoning from each position
- Resolve conflicts with documented resolution rationale
- Synthesize perspectives into coherent view

### 5. Recommendation

Produce:
- Selected approach name
- Why this wins over alternatives
- 3-5 key success factors
- 2-3 critical risks to monitor
- Confidence level (High/Medium/Low) with explanation

### 6. Implementation Planning (Complex Only)

For each of 5 key milestones:
- Evaluate 3 execution strategies
- Identify dependencies and bottlenecks
- Create contingency plan for primary failure mode

## Output Schema

```yaml
analysis:
  challenge: string
  phases:
    branch_generation:
      - consultant: string
        approaches:
          - name: string
            description: string
            outcomes:
              - description: string
                probability: string  # High/Medium/Low or percentage
            pros: string[]
            cons: string[]
    risk_analysis:
      approach_risks:
        - approach: string
          failure_mode: string
          worst_case: string
          hidden_assumption: string
      blind_spots: string[]
    debate:
      agreements: string[]
      disagreements:
        - topic: string
          positions: {consultant: position}[]
          resolution: string
      synthesis: string
    recommendation:
      approach: string
      reasoning: string
      success_factors: string[]
      risks_to_monitor: string[]
      confidence: High|Medium|Low
      confidence_rationale: string
  implementation:  # Only if complexity == complex
    milestones:
      - name: string
        strategies: string[]
        dependencies: string[]
        bottlenecks: string[]
        contingency: string
```

## Error Handling

| Condition | Action |
|-----------|--------|
| Vague challenge | Ask clarifying questions about scope, constraints, success criteria |
| Consultants reach same conclusions | Push for genuine disagreement; explore edge cases |
| No clear winner among approaches | Present top 2 with explicit trade-off comparison |
| Confidence is Low | State what specific information would raise confidence |
| User wants quick answer | Offer abbreviated single-consultant analysis with caveats |

## Constraints

- Consultants must genuinely disagree, not rubber-stamp
- Quantify impact, probability, timelines where possible
- State uncertainty honestly
- Recommendation must be executable, not theoretical
