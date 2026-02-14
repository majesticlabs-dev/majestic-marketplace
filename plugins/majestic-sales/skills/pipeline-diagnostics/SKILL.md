---
name: pipeline-diagnostics
description: Pipeline health assessment with coverage ratios, conversion benchmarks, velocity analysis, and problem diagnosis frameworks.
allowed-tools: []
disable-model-invocation: true
---

# Pipeline Diagnostics

Framework for assessing B2B sales pipeline health and identifying problems.

## Pipeline Coverage

**Minimum Coverage by Quarter Week:**

| Week | Coverage Needed | Why |
|------|-----------------|-----|
| Week 1 | 4x quota | Time to work deals |
| Week 5 | 3x quota | Deals maturing |
| Week 9 | 2x quota | Late-stage heavy |
| Week 13 | 1.2x quota | Commit deals |

**Formula:**
```
Coverage Ratio = Total Pipeline / Quota Target
```

## Stage Conversion Benchmarks

| Stage | Benchmark | If Below |
|-------|-----------|----------|
| Lead to Qualified | 30-40% | ICP targeting issue |
| Qualified to Discovery | 60-70% | Qualification criteria issue |
| Discovery to Demo | 50-60% | Discovery quality issue |
| Demo to Proposal | 40-50% | Demo effectiveness issue |
| Proposal to Closed | 30-40% | Negotiation/pricing issue |

## Deal Velocity

**Formula:**
```
Sales Velocity = (Deals × Win Rate × ACV) / Sales Cycle

Higher velocity = more revenue, faster
```

**Improvement Levers:**
1. More qualified opportunities (volume)
2. Higher win rate (quality)
3. Larger deal sizes (ACV)
4. Shorter sales cycles (speed)

## Stage Distribution Analysis

```
Healthy Pipeline Shape:

Stage 1 (Qualified):    ████████████████████ 35%
Stage 2 (Discovery):    ████████████████ 25%
Stage 3 (Demo):         ████████████ 20%
Stage 4 (Proposal):     ████████ 12%
Stage 5 (Negotiation):  █████ 8%

Red Flags:
- Top-heavy: Too much early stage
- Bottom-heavy: Not enough new pipeline
- Middle stuck: Conversion problem
```

## Age Analysis

| Stage | Healthy Age | Stale Threshold |
|-------|-------------|-----------------|
| Qualified | 0-14 days | >21 days |
| Discovery | 7-21 days | >30 days |
| Demo | 14-30 days | >45 days |
| Proposal | 7-14 days | >21 days |
| Negotiation | 7-21 days | >30 days |

**Stale Deal Actions:**
- <7 days stale: Update and next steps
- 7-14 days stale: Manager review
- >14 days stale: Downgrade or close

## Win/Loss Analysis

**Win Analysis Questions:**
- What was the trigger event?
- Who was the champion?
- What was the competitive situation?
- What value resonated most?
- How long was the sales cycle?

**Loss Analysis Questions:**
- What stage did we lose?
- Who made the decision?
- What was the stated reason?
- What was the real reason?
- What would we do differently?

## Problem Diagnosis

### Not Enough Pipeline

**Symptoms:**
- Coverage <3x in first half of quarter
- New pipeline creation slowing
- Deals closing without replacement

**Solutions:**
- Increase outbound activity 50%
- Run targeted campaign to ICP
- Re-engage closed-lost from 6+ months ago
- Ask for referrals from recent wins
- Partner-sourced pipeline push

### Deals Stuck in Stage

**Symptoms:**
- Average age exceeds benchmark
- Same deals appearing in reviews
- No clear next steps

**Solutions:**
- Implement stage exit criteria
- Add "days in stage" to dashboards
- Manager review for stale deals
- Create urgency with limited-time offer
- Multi-thread to other stakeholders

### Low Win Rate

**Symptoms:**
- Win rate <20%
- Losing to "no decision"
- Losing to specific competitor

**Solutions:**
- Tighten qualification criteria
- Improve discovery process
- Build champion enablement
- Create competitive battle cards
- Address pricing/packaging

### Inaccurate Forecasts

**Symptoms:**
- Consistent over/under forecasting
- Deals slipping between periods
- Late-quarter surprises

**Solutions:**
- Define clear commit criteria
- Weekly deal-by-deal review
- Track forecast accuracy by rep
- Implement deal scoring
- Require close plan for commits
