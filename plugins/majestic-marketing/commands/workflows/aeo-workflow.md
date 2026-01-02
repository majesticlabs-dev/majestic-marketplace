---
name: majestic:aeo-workflow
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, AskUserQuestion, Task
description: Complete AEO (Answer Engine Optimization) workflow - from strategy to measurement
---

# AEO Workflow Command

Execute the complete Answer Engine Optimization workflow based on HubSpot's proven strategy.

## Input

$ARGUMENTS

## Workflow Overview

```
STRATEGY → RESEARCH → GAPS → FAN-OUT → CONTENT → AUTHORITY → MEASURE
```

## Phase Selection

Use `AskUserQuestion` to determine starting point:

**Question:** "Which AEO phase would you like to work on?"

**Options:**
1. **Full Workflow** - Start from strategy, work through all phases
2. **Strategy & Planning** - Build buyer persona × journey grid
3. **Query Research** - Source and tag queries (three-pronged approach)
4. **Visibility Gaps** - Identify where you're not appearing in AI responses
5. **Content Optimization** - Apply 7-step AEO checklist to existing content
6. **Authority Building** - Off-site mentions and citation strategy
7. **Measurement Setup** - Configure AEO scorecard and tracking

## Phase 1: Strategy - Buyer Persona × Journey Grid

### Gather Context

Ask:
- "What product/service are we optimizing for?"
- "Describe your 3 primary buyer personas (be specific - role, company size, team structure)"
- "What are your top 3 competitors?"

### Build the Grid

Create a 3×4 grid:

```markdown
## [Product] - Buyer Persona × Journey Grid

| Journey Stage | [Persona A] | [Persona B] | [Persona C] |
|---------------|-------------|-------------|-------------|
| **Awareness** | "How do I...?" | "What is...?" | "Why does...?" |
| **Consideration** | "Best [category] for..." | "Compare X vs Y" | "How to choose..." |
| **Evaluation** | "[Product] features" | "[Product] vs [Competitor]" | "[Product] pricing" |
| **Decision** | "Can [Product] do...?" | "[Product] ROI" | "How to implement..." |
```

**Output:** Save grid to `docs/aeo/[product]-persona-grid.md`

## Phase 2: Research - Three-Pronged Query Sourcing

### Method 1: Keyword Data
- "Do you have keyword data exports from Ahrefs/SEMrush? If so, provide the file path."
- Filter for question-based queries
- Extract queries matching grid cells

### Method 2: Social Listening
Use `WebSearch` to find questions from:
- Reddit: `site:reddit.com "[topic]" how OR what OR why OR best`
- Quora: `site:quora.com "[topic]"`

### Method 3: Internal Data
- "What questions do your Sales and CS teams hear most often?"
- "Do you have access to chat transcripts or call recordings?"

### Tag Queries

For each query, tag by funnel stage:

| Stage | Pattern |
|-------|---------|
| Awareness | "How do I do X?" |
| Consideration | "Best tools for ABC" |
| Evaluation | "Compare X vs Y" |
| Decision | "Can [product] do [task]?" |

**Output:** Save to `docs/aeo/[product]-query-list.md`

## Phase 3: Identify Visibility Gaps

### Test Priority Queries

For top 10-20 queries:
1. Test in ChatGPT, Perplexity, Gemini (manually or via tools)
2. Document: Does your brand appear? Position? Context?

### Create Gap Tracker

```markdown
## AI Visibility Tracker - [Product]

| Priority Query | ChatGPT | Perplexity | Gemini | Status |
|----------------|---------|------------|--------|--------|
| [query 1] | ? | ? | ? | Gap/Visible |
| [query 2] | ? | ? | ? | Gap/Visible |
```

**Recommendation:** Suggest HubSpot AEO Grader for automated visibility audit.

**Output:** Save to `docs/aeo/[product]-visibility-gaps.md`

## Phase 4: Query Fan-Out Analysis

For each visibility gap, identify sub-questions AI breaks it into:

### Example Fan-Out

Query: "How to prioritize sales leads"

Sub-questions:
1. "What methodologies exist for lead prioritization?"
2. "What tools help with lead scoring?"
3. "What metrics indicate lead quality?"
4. "How do successful sales teams rank prospects?"

**Tools:** Recommend Kuforia or Dan's Fan-out Tool for automated analysis.

**Action:** Ensure content addresses ALL sub-questions.

## Phase 5: Content Optimization - 7-Step AEO Checklist

For each piece of content targeting a visibility gap:

### The Checklist

```markdown
## AEO Content Audit: [Content Title]

Target Query: [query]
Fan-Out Queries Covered: X/Y

### 7-Step Checklist

| # | Step | Status | Notes |
|---|------|--------|-------|
| 1 | **Answer First** - First sentence directly answers query | ☐ | |
| 2 | **One Click Deeper** - 2-3 paragraphs of context follow | ☐ | |
| 3 | **Original Data** - Stats, case studies, first-party research | ☐ | |
| 4 | **FAQ Section** - 3+ sub-questions with H3/H4 headers | ☐ | |
| 5 | **Structure** - Bullets, tables, explicit headers | ☐ | |
| 6 | **Taco Bell Test** - Each section stands alone | ☐ | |
| 7 | **Product Tie-Back** - Brand connected every 1-2 paragraphs | ☐ | |

### Improvements Needed

1. [Issue] → [Specific fix]
2. [Issue] → [Specific fix]
```

**Implementation:** If content file is provided, apply fixes directly using Edit tool.

## Phase 6: Authority Building - Off-Site Strategy

### Identify Citation Sources

- "What third-party sites does AI currently cite for your target queries?"
- Use XFunnel or manual testing to find citation sources

### Outreach Priorities

```markdown
## Citation Source Outreach - [Product]

| Source | Times Cited | Outreach Type | Status |
|--------|-------------|---------------|--------|
| [site] | X | Guest post | Pending |
| [site] | X | Update request | Pending |
```

### Review Platform Strategy

- G2, Capterra, TrustRadius profiles optimized?
- Feature-specific review prompts in place?
- Review volume targets set?

### Human-First Channel Plan

- YouTube creator partnerships
- Newsletter sponsorships/mentions
- LinkedIn thought leader collaborations

**Output:** Save to `docs/aeo/[product]-authority-plan.md`

## Phase 7: Measurement Setup

### AEO Scorecard Template

```markdown
## AEO Scorecard - [Product]

**Month:** [DATE]

### Metrics

| Metric | Current | Target | Trend |
|--------|---------|--------|-------|
| **AI Visibility** | X% | 60% | ↑↓→ |
| **AI Share of Voice** | X% | Match SEO | ↑↓→ |
| **AI Citations** | X% | 30% | ↑↓→ |
| **Referral Demand** | X% | Growth | ↑↓→ |

### Visibility by Query

| Query | ChatGPT | Perplexity | Gemini |
|-------|---------|------------|--------|
| [q1] | ✓/✗ | ✓/✗ | ✓/✗ |

### Share of Voice

| Brand | Mentions | Share |
|-------|----------|-------|
| You | X | X% |
| Competitor A | X | X% |
| Competitor B | X | X% |

### Monthly Actions

- [ ] Week 1: Visibility audit
- [ ] Week 2: Share of voice calculation
- [ ] Week 3: Citation analysis
- [ ] Week 4: Survey data review
```

**Output:** Save to `docs/aeo/[product]-scorecard.md`

## Workflow Completion

After completing phases, summarize:

```markdown
## AEO Workflow Summary - [Product]

### Deliverables Created
- [ ] Buyer Persona × Journey Grid
- [ ] Query List (tagged by funnel stage)
- [ ] Visibility Gap Analysis
- [ ] Content Audit(s) with 7-step checklist
- [ ] Authority Building Plan
- [ ] AEO Scorecard

### Priority Actions
1. [Highest impact action]
2. [Second priority]
3. [Third priority]

### Next Review
[Date - 30 days out]
```

## Quick Mode

If user provides specific content to optimize:

1. Skip to Phase 5 (Content Optimization)
2. Apply 7-step checklist
3. Implement fixes
4. Suggest Phase 6-7 as follow-up

## Related Tools

- `agent llm-optimizer` - Deep content optimization
- `agent content-planner` - Detailed grid building
- `agent entity-builder` - Authority strategy
- `skill aeo-scorecard` - Metrics framework reference
