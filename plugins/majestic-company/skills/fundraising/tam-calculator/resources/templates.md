# TAM Calculator Templates

## Market Definition Framework

```markdown
## MARKET DEFINITION

**Product Category:** [What category does this fall into?]
**Core Value Proposition:** [What job does it do for customers?]
**Market Boundaries:**
- Included: [What's in scope]
- Excluded: [What's explicitly out of scope and why]

**Customer Segments:**
| Segment | Description | % of Total Market |
|---------|-------------|-------------------|
| Primary | [Description] | X% |
| Secondary | [Description] | X% |
| Adjacent | [Description] | X% |

**Current Alternatives:**
| Alternative | Weakness | Your Advantage |
|-------------|----------|----------------|
| [Competitor/Solution] | [Limitation] | [Your edge] |
```

## Top-Down TAM Template

```markdown
## TOP-DOWN TAM CALCULATION

### Step-by-Step Breakdown

| Step | Description | Data Source | Value |
|------|-------------|-------------|-------|
| 1. Global Market | Total [industry] market | [Source, Year] | $X B |
| 2. Geographic Filter | [Region] share | [Source] | × X% |
| 3. Segment Filter | [Relevant segment] | [Source] | × X% |
| 4. Product Category | [Specific category] | [Source] | × X% |
| **TAM (Top-Down)** | | | **$X B** |

### Calculation
Global Market ($X B) × Geographic (X%) × Segment (X%) × Category (X%) = **$X B TAM**

### Source Documentation
- [Source 1]: "[Exact quote or figure]" - [URL/Report Name], [Date]
- [Source 2]: "[Exact quote or figure]" - [URL/Report Name], [Date]
```

## Bottom-Up TAM Template

```markdown
## BOTTOM-UP TAM CALCULATION

### Customer Segment Analysis

| Segment | # of Potential Customers | Data Source | Annual Spend | Segment TAM |
|---------|--------------------------|-------------|--------------|-------------|
| [Segment A] | X | [Source] | $Y | $Z |
| [Segment B] | X | [Source] | $Y | $Z |
| [Segment C] | X | [Source] | $Y | $Z |
| **Total** | | | | **$X** |

### Calculation Breakdown

**Segment A:**
- Total potential customers: [Number] ([Source])
- % who have the problem: X% ([Reasoning/Source])
- % who would pay for solution: X% ([Reasoning/Source])
- Average annual contract value: $X ([Your pricing × expected usage])
- Segment TAM: [Customers] × [Problem %] × [Pay %] × [ACV] = **$X**

### Formula
TAM = Σ (Customers per Segment × Penetration Rate × Annual Revenue per Customer)
```

## Value-Theory TAM Template

```markdown
## VALUE-THEORY TAM CALCULATION

### Problem Cost Analysis

| Cost Component | Annual Cost per Customer | # of Customers | Total Addressable Cost |
|----------------|--------------------------|----------------|------------------------|
| [Direct cost 1] | $X | Y | $Z |
| [Direct cost 2] | $X | Y | $Z |
| [Opportunity cost] | $X | Y | $Z |
| **Total Problem Cost** | | | **$X** |

### Value Capture Analysis

- Total cost of problem: $X
- Reasonable value capture (%): X% ([Justification - typically 10-30%])
- **Value-Based TAM**: $X × X% = **$X**

### Validation
- Willingness-to-pay evidence: [Customer interviews, pricing tests, competitor pricing]
- Value capture comparable: [Similar products capture X% of value created]
```

## TAM Triangulation Template

```markdown
## TAM TRIANGULATION

| Methodology | TAM Estimate | Confidence Level |
|-------------|--------------|------------------|
| Top-Down | $X B | [High/Medium/Low] |
| Bottom-Up | $X B | [High/Medium/Low] |
| Value-Theory | $X B | [High/Medium/Low] |

### Reconciliation Analysis

**Why estimates differ:**
- [Explanation of variance between methodologies]
- [Which assumptions drive the differences]

**Recommended TAM: $X B**
- Primary basis: [Which methodology and why]
- Adjusted for: [Any corrections made]
- Confidence interval: $X B - $X B
```

## SAM Calculation Template

```markdown
## SERVICEABLE ADDRESSABLE MARKET (SAM)

SAM = TAM × (Segments You Can Serve)

### Constraint Analysis

| Constraint Type | Limitation | Impact on TAM |
|-----------------|------------|---------------|
| Geographic | [Countries/regions you'll serve] | TAM × X% |
| Customer Segment | [Segments you can reach] | × X% |
| Product Fit | [Who your product works for today] | × X% |
| Distribution | [Channels you can access] | × X% |
| Pricing | [Who can afford your price point] | × X% |

### SAM Calculation

TAM ($X B) × Geographic (X%) × Segment (X%) × Product (X%) × Distribution (X%) = **SAM: $X M**
```

## SOM Calculation Template

```markdown
## SERVICEABLE OBTAINABLE MARKET (SOM)

SOM = SAM × Realistic Market Share

### Competitive Landscape

| Competitor | Est. Market Share | Strengths | Weaknesses |
|------------|-------------------|-----------|------------|
| [Competitor 1] | X% | [Strengths] | [Weaknesses] |
| [Competitor 2] | X% | [Strengths] | [Weaknesses] |
| Fragmented/Other | X% | | |

### Market Share Assumptions

| Timeframe | Target Market Share | Basis for Assumption |
|-----------|---------------------|----------------------|
| Year 1 | X% | [Conservative estimate with justification] |
| Year 3 | X% | [Growth trajectory with comparables] |
| Year 5 | X% | [Mature state with competitive analysis] |

### SOM Projections

| Year | SAM | Market Share | SOM |
|------|-----|--------------|-----|
| 1 | $X M | X% | $X M |
| 3 | $X M | X% | $X M |
| 5 | $X M | X% | $X M |
```

## Visual Market Funnel

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                     TAM: $X Billion                             │
│              Total Addressable Market                           │
│     "Everyone who could theoretically buy this product"         │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                           ↓                                     │
│         Constraints: Geography, Segment, Product Fit            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │      SAM: $X Million        │                    │
│              │ Serviceable Addressable Mkt │                    │
│              │  "Market we can realistically│                   │
│              │   serve with current model" │                    │
│              └─────────────────────────────┘                    │
│                           ↓                                     │
│            Constraints: Competition, Capacity                   │
│                                                                 │
│                   ┌─────────────────┐                           │
│                   │  SOM: $X Million│                           │
│                   │  (Year 1 / 3 / 5)│                          │
│                   │  "What we can   │                           │
│                   │   actually win" │                           │
│                   └─────────────────┘                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Investor Presentation Template

```markdown
## INVESTOR-READY SUMMARY

### Executive Summary (2-3 sentences)
"[Market] represents a $[TAM] opportunity, of which $[SAM] is serviceable by
[Company] today. With our [competitive advantage], we're targeting $[SOM]
in revenue by Year [X], representing [X]% market share in our core segment."

### Key Assumptions Table

| Assumption | Value | Source | Confidence |
|------------|-------|--------|------------|
| [Assumption 1] | [Value] | [Source] | High/Med/Low |
| [Assumption 2] | [Value] | [Source] | High/Med/Low |

### Market Sizing Slide Structure

**Slide Title:** "$[X]B market opportunity in [Industry]"

**Visual:** TAM/SAM/SOM funnel

**Key Points:**
- TAM: $X B — [One-sentence justification]
- SAM: $X M — [Geographic/segment focus]
- SOM (Yr 3): $X M — [Conservative path to capture]

**Credibility Proof:**
- "Based on [credible source] data"
- "Validated through [X] customer interviews"
- "Consistent with [comparable company] trajectory"
```

## Investor Q&A Preparation

### On TAM
**Q: "Isn't this TAM too large/small?"**
A: [Prepared response with sources]

**Q: "How did you get to this market size?"**
A: [Methodology walkthrough]

### On SAM
**Q: "Why can't you serve the whole TAM?"**
A: [Honest constraint explanation]

**Q: "When do you expand to adjacent segments?"**
A: [Roadmap answer]

### On SOM
**Q: "These market share assumptions seem aggressive/conservative."**
A: [Comparable company evidence]

**Q: "What if [competitor] defends their position?"**
A: [Competitive response strategy]
