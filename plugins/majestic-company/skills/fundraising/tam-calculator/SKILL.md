---
name: tam-calculator
description: Calculate Total Addressable Market (TAM), Serviceable Addressable Market (SAM), and Serviceable Obtainable Market (SOM) using top-down, bottom-up, and value-theory approaches with credible data sources and VC-ready presentation.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# TAM Calculator

**Audience:** Founders preparing investor materials who need defensible market sizing that survives due diligence pushback.

**Goal:** Calculate TAM/SAM/SOM using three methodologies (top-down, bottom-up, value-theory) with credible data sources. Every number must be traceable to Tier 1-3 sources.

## Conversation Starter

Use `AskUserQuestion` to gather initial context. Begin by asking:

"I'll help you calculate TAM, SAM, and SOM that investors will actually believe.

The biggest mistake founders make is starting with a massive number and hoping investors won't push back. Smart investors will. Instead, we'll build your market sizing from multiple angles so you can defend it under scrutiny.

To create investor-ready market analysis, I need:

1. **Product/Service**: What exactly are you selling? (Be specific about the core offering)
2. **Target Customer**: Who buys this? (Industry, company size, job title, or consumer segment)
3. **Pricing Model**: How do you charge? (subscription, one-time, usage-based, freemium)
4. **Price Point**: What do customers pay? (per month, per year, per transaction)
5. **Geography**: Where will you sell? (local, national, specific countries, global)
6. **Competitors**: Who else serves this market? (direct and indirect alternatives)

I'll research industry reports, government data, and competitor information to build your TAM from multiple methodologies."

## Research Methodology

Use WebSearch to find:
- Industry analyst reports (Gartner, IDC, Statista, IBISWorld, Grand View Research)
- Government census and economic data (BLS, Census Bureau, Eurostat)
- Competitor financials (annual reports, Crunchbase, PitchBook data)
- Industry growth rates and projections from credible sources
- Market research from trade associations

**Source Quality Hierarchy:**

| Tier | Source Type | Credibility |
|------|-------------|-------------|
| 1 | Government data (Census, BLS, SEC filings) | Highest |
| 2 | Industry analysts (Gartner, IDC) | High |
| 3 | Trade association data | Medium-high |
| 4 | Company reports and filings | Medium |
| 5 | News articles citing sources | Low (trace to original) |
| 6 | Blog posts and estimates | Not acceptable |

## Three Methodologies

### 1. Top-Down Approach

Start with broadest market data and narrow down:

| Step | Description |
|------|-------------|
| 1 | Global market for industry |
| 2 | Geographic filter (your regions) |
| 3 | Segment filter (your customers) |
| 4 | Product category filter |

**Formula**: Global Market × Geographic % × Segment % × Category % = TAM

### 2. Bottom-Up Approach

Build from individual customer units:

| Component | Calculation |
|-----------|-------------|
| Total potential customers | Count from data source |
| × Problem incidence | % who have the problem |
| × Willingness to pay | % who would pay for solution |
| × ACV | Your annual contract value |
| = TAM | |

**Formula**: TAM = Σ (Customers × Penetration Rate × Annual Revenue per Customer)

### 3. Value-Theory Approach

Calculate based on value delivered:

| Component | Calculation |
|-----------|-------------|
| Cost of problem | Annual cost per customer |
| × Customers affected | Number with problem |
| = Total problem cost | |
| × Value capture | Typically 10-30% |
| = TAM | |

## TAM → SAM → SOM Funnel

### TAM (Total Addressable Market)
"Everyone who could theoretically buy"
- All three methodologies should converge (within 50%)
- Document sources for every figure

### SAM (Serviceable Addressable Market)
"Market we can realistically serve"

Apply constraints:
- Geographic (where you'll sell)
- Customer segment (who you can reach)
- Product fit (who your product works for)
- Distribution (channels you can access)
- Pricing (who can afford you)

### SOM (Serviceable Obtainable Market)
"What we can actually win"

| Year | Market Share | Basis |
|------|--------------|-------|
| 1 | Conservative | Pipeline + conversion rates |
| 3 | Growth trajectory | Comparable company data |
| 5 | Mature state | Category leader benchmarks |

See [resources/templates.md](resources/templates.md) for detailed calculation templates.

## Quality Checklist

✅ **Not claiming inflated TAM** - TAM reflects actual opportunity
✅ **Bottom-up validates top-down** - Multiple methodologies converge
✅ **Realistic SOM assumptions** - Market share backed by comparables
✅ **Credible sources cited** - Government/analyst data with URLs
✅ **Assumptions explicit** - Key inputs listed and justified
✅ **Geography matches strategy** - SAM reflects go-to-market plan
✅ **Pricing validated** - ACV based on customer research

## Output Structure

```markdown
# MARKET SIZING ANALYSIS: [Company/Product Name]

## Executive Summary
[3-4 sentence overview of TAM, SAM, SOM with key insight]

## Market Definition
[Clear boundaries and customer segments]

## TAM Calculation
[All three methodologies with sources]

## TAM Triangulation
[Reconciliation and recommended figure]

## SAM Calculation
[Constraint analysis and calculation]

## SOM Calculation
[Competitive analysis and projections]

## Visual Funnel
[TAM → SAM → SOM diagram - see resources/templates.md]

## Source Credibility Matrix
[Data quality assessment for all sources]

## Sensitivity Analysis
[Scenario modeling for key assumptions]

## Investor Presentation Summary
[Slide-ready version]

## Q&A Preparation
[Anticipated investor questions with answers]
```

## Quality Standards

- **Cite everything**: No unsourced market figures
- **Show your work**: Every calculation transparent
- **Use multiple methods**: Triangulate for credibility
- **Be conservative on SOM**: Better to exceed than disappoint
- **Date your data**: Markets change; timestamps matter
- **Acknowledge uncertainty**: Confidence levels build trust
