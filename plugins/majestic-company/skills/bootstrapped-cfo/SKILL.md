---
name: bootstrapped-cfo
description: Financial frameworks for bootstrapped startups. Triggers on cash management, runway, unit economics, hiring ROI, and capital allocation questions. Emphasizes profit as constraint, not goal.
---

# Bootstrapped CFO

Financial guidance for self-funded companies where capital discipline forces superior decision-making.

## Core Principle

**Profit is a constraint, not a goal.** Bootstrapped companies must generate profit to survive—this constraint produces better decisions than abundant capital.

## When This Applies

Trigger on financial questions from bootstrapped/self-funded companies:
- "Should we make this hire?"
- "What's a healthy LTV:CAC ratio?"
- "How much runway do we need?"
- "Is this investment worth it?"
- "How should we think about spending?"

## Unit Economics Thresholds

| Metric | Minimum | Target | Best-in-Class |
|--------|---------|--------|---------------|
| LTV:CAC | 3:1 | 5:1 | 7-8:1 |
| CAC Payback | <18 months | <12 months | 5-7 months |
| Gross Margin | >60% | >70% | >80% |
| Net Revenue Retention | >100% | >110% | >120% |

**Formulas:**
```
LTV = ARPA × Gross Margin × (1 / Monthly Churn Rate)
CAC = (Sales + Marketing Spend) / New Customers Acquired
Payback Months = CAC / (ARPA × Gross Margin)
```

## Revenue Per Employee Benchmarks

| Stage | ARR | Target RPE |
|-------|-----|------------|
| Early | $1-5M | $110-150K |
| Growth | $5-20M | $150-200K |
| Scale | $20M+ | $200-300K |

**Rule:** Every hire must justify their fully-loaded cost within 12 months through revenue or measurable efficiency gains.

## Cash Management

### Runway Targets

| Runway | Status | Action |
|--------|--------|--------|
| 36+ months | Healthy | Execute growth plan |
| 24-36 months | Good | Monitor, maintain discipline |
| 12-24 months | Caution | Reduce burn or accelerate revenue |
| <12 months | Critical | Survival mode, cut to extend |

### Reserve Structure

| Reserve Type | Target | Purpose |
|--------------|--------|---------|
| Operating | 3-6 months expenses | Day-to-day operations |
| Contingency | 3 months expenses | Unexpected downturns |
| Growth | Variable | Opportunistic investments |

### Burn Multiple

```
Burn Multiple = Net Burn / Net New ARR
```

| Burn Multiple | Rating | Interpretation |
|---------------|--------|----------------|
| <1x | Excellent | Efficient growth |
| 1-1.5x | Good | Sustainable |
| 1.5-2x | Concerning | Optimize spend |
| >2x | Poor | Restructure immediately |

**Bootstrapped target:** Zero or negative burn (profitable growth).

## Capital Allocation Framework

### Investment Payback Rule

Every investment must show payback within 12 months. Evaluate:

```
ROI = (Gain from Investment - Cost) / Cost
Payback Period = Investment / Monthly Benefit
```

| Investment Type | Max Payback | Example |
|-----------------|-------------|---------|
| Sales hire | 6-9 months | Rep reaches quota |
| Marketing spend | 3-6 months | CAC recovery |
| Tool/software | 6-12 months | Efficiency gain |
| Engineering hire | 12 months | Feature revenue/savings |

### Rule of 40

```
Rule of 40 Score = Revenue Growth % + EBITDA Margin %
```

| Score | Rating | Bootstrapped Context |
|-------|--------|---------------------|
| 40+ | Excellent | Healthy balance |
| 25-40 | Good | Acceptable trade-off |
| <25 | Poor | Fix growth or profitability |

**Bootstrapped path:** Often 15% growth + 25% margin beats 35% growth + 5% margin.

### Hiring Decision Framework

Before any hire, answer:

1. **Revenue impact:** Will this person generate/enable $X revenue within 12 months?
2. **Cost justification:** Fully-loaded cost (salary × 1.3) recoverable in year one?
3. **Constraint test:** What happens if we don't hire for 6 more months?
4. **Department growth:** Avoid >50% headcount growth in any department at once

**Red flags:**
- "We need this role to look professional"
- "Everyone else has this position"
- "We'll figure out their impact later"

## Working Capital Optimization

### Cash Conversion Cycle

```
CCC = Days Sales Outstanding + Days Inventory - Days Payable Outstanding
```

| Business Model | Target CCC |
|----------------|------------|
| SaaS (annual) | -30 to -90 days |
| SaaS (monthly) | 0 to -30 days |
| Services | 30-45 days |

### AR/AP Discipline

| Metric | Target | Tactic |
|--------|--------|--------|
| DSO (Days Sales Outstanding) | <45 days | Invoice immediately, follow up at 30 days |
| Annual prepay rate | 30%+ of customers | Offer 15-20% discount for annual |
| DPO (Days Payable Outstanding) | 30-45 days | Use full payment terms |

**Annual prepay benefits:**
- 15-20% discount still profitable
- 30% lower churn than monthly
- Cash up front improves runway

## Spending Benchmarks

### By Department ($3-5M ARR, Bootstrapped)

| Department | % of Revenue | Notes |
|------------|--------------|-------|
| Sales | 15-20% | Include commissions |
| Marketing | 10-15% | CAC-conscious |
| R&D/Engineering | 25-35% | Core product investment |
| Customer Success | 10-15% | Retention-focused |
| G&A | 10-15% | Lean operations |
| **Total** | **70-95%** | Leaves 5-30% profit |

**Contrast with VC-backed:** Often 100-120% of revenue (burning cash for growth).

## Financial Review Cadence

### Weekly (30 min)

- Cash position and 4-week forecast
- AR aging (anything >30 days)
- Pipeline coverage for next month
- Burn rate vs budget

### Monthly (2 hours)

- Full P&L close
- Unit economics recalculation
- Cohort analysis (retention, expansion)
- Variance analysis vs plan

### Quarterly (Half day)

- Three-scenario planning (base, upside, downside)
- Runway recalculation
- Strategic spend review
- Hiring plan adjustment

## Decision Frameworks

### "Should We Spend X?" Test

1. **Payback:** Will this pay for itself in <12 months?
2. **Necessity:** What happens if we wait 6 months?
3. **Reversibility:** Can we undo this if wrong?
4. **Opportunity cost:** What else could this money do?

### Pricing Discipline

- Raise prices annually (5-15%) until churn increases
- Grandfather existing customers for 6-12 months
- New features = premium tier opportunity
- Never discount >20% without executive approval

### When to Accelerate Spend

Only when ALL conditions met:
- Unit economics proven (LTV:CAC >4:1)
- Payback <9 months demonstrated
- 24+ months runway maintained post-spend
- Clear capacity constraint being solved

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| "We'll grow into it" | Speculative hiring | Hire behind demand |
| "Industry standard" | Ignoring your economics | Use your unit economics |
| "Everyone uses X tool" | Undisciplined spend | Justify each tool's ROI |
| "We need enterprise features" | Premature complexity | Build for current customers |
| "Competitors are spending more" | VC-backed comparison | They have different economics |

## Output Guidance

When answering financial questions:

1. **State the relevant benchmark/threshold**
2. **Apply their specific numbers** (ask if not provided)
3. **Give a clear recommendation** with the key constraint
4. **Flag if the question reveals concerning metrics**

Example response pattern:
> "For bootstrapped companies, CAC payback should be under 12 months. At $500 CAC and $100 MRR with 80% gross margin, your payback is 6.25 months—healthy. The hire makes sense if they can maintain this efficiency at higher volume."
