---
name: problem-research
description: Research competitor pain points from review platforms (G2, Capterra, Reddit) to find wedge opportunities. SaaS/B2B focus. Use for market validation, competitive analysis, or deciding whether to build. Always concludes with brutally honest viability assessment.
allowed-tools: Read, Write, Edit, WebSearch, WebFetch, AskUserQuestion, TodoWrite, mcp__browsermcp__*
---

# Problem Research

Research competitor pain points from review platforms to identify market opportunities for SaaS/B2B products.

## Overview

This skill analyzes reviews from G2, Capterra, TrustRadius, Reddit, and other platforms to extract:
- **Pain points** - What users hate, churn reasons, broken features
- **Must-haves** - Features users can't live without
- **Hidden gems** - Underserved needs competitors ignore
- **Wedge opportunities** - Where a newcomer can attack the market

Every report concludes with a **brutally honest business viability assessment**.

## When to Use

- Validating a new product idea before building
- Finding entry points into competitive markets
- Understanding why users switch from competitors
- Identifying underserved needs and hidden opportunities
- Deciding whether to pursue or abandon an idea

## The Process

### Phase 1: Collect Context

Gather from the user:
- **Target Product/Category**: What you want to build (e.g., "CRM for agencies")
- **Industry/Vertical**: B2B SaaS, E-commerce, Healthcare, etc.

### Phase 2: Select Research Scope

Ask user to choose research depth:

| Depth | Competitors | Est. Time | Best For |
|-------|-------------|-----------|----------|
| **Light** (default) | 3-5 top players | 5-10 min | Quick validation, early ideation |
| **Medium** | 5-10 competitors | 15-25 min | Market entry research |
| **Deep** | 10+ competitors | 30-45 min | Comprehensive competitive intelligence |

### Phase 3: Select Execution Mode

Ask user which execution approach to use:

**A) Semi-Automated** (WebSearch + WebFetch)
- Faster, more reliable
- Searches review aggregator summaries and accessible pages
- May miss some nuanced quotes
- Works without additional setup
- **Recommended for most use cases**

**B) Agentic Browsing** (Browser MCP)
- Slower, more thorough
- Navigates actual review sites interactively
- Captures exact quotes with full context
- Requires Chrome with CDP enabled
- **Use when exact quotes are critical for sales copy**

### Phase 4: Execute Research

Track progress via TodoWrite through these steps:

1. **Identify top competitors** - Find 3-10 players based on scope
2. **Analyze review platforms** - G2, Capterra, TrustRadius per competitor
3. **Process Reddit discussions** - r/[industry], relevant subreddits
4. **Extract pain points** - Categorize and score each complaint
5. **Identify must-haves** - Features that are table stakes
6. **Find hidden gems** - Underserved needs no one addresses
7. **Synthesize findings** - Rank and prioritize insights

### Phase 5: Generate Report

Produce the structured report (see Output Format below):
- Executive Summary
- Pain Points Table (ranked with quotes)
- Must-Haves Table
- Hidden Gems
- Opportunity Map
- Viability Assessment (verdict + brutal truth)

### Phase 6: Save Options

Ask user via AskUserQuestion:
- **Display only** (default) - Already shown
- **Save to file** - Save as `docs/research/[date]-[topic]-problem-research.md`

---

## Research Sources

### Primary Sources (Priority Order)

| Platform | Strengths | Search Pattern |
|----------|-----------|----------------|
| **G2** | Structured likes/dislikes, verified users, company size data | `"[competitor]" site:g2.com reviews` |
| **Capterra** | Large volume, verified buyers, detailed pros/cons | `"[competitor]" site:capterra.com reviews` |
| **TrustRadius** | In-depth tradeoffs section, enterprise focus | `"[competitor]" site:trustradius.com` |
| **Reddit** | Authentic, unfiltered, real frustration | `"[competitor]" site:reddit.com (frustrated OR hate OR switching)` |
| **GetApp** | SMB focus, similar to Capterra | `"[competitor]" site:getapp.com reviews` |

### Search Query Templates

```
# Pain-focused searches
"[competitor name]" reviews "what I dislike"
"[competitor name]" vs "looking for alternative"
"switching from [competitor]" OR "left [competitor]"
"[competitor name]" frustrated OR annoying OR terrible

# Feature-focused searches
"[competitor name]" "can't live without"
"[competitor name]" "favorite feature"
"best thing about [competitor name]"
```

---

## Scoring Frameworks

### Pain Point Score (PPS)

```
PPS = Frequency Score × Severity Score × Recency Multiplier
```

**Frequency Score (1-5):**
| Score | Mentions | Interpretation |
|-------|----------|----------------|
| 1 | 1-2 | Isolated complaint |
| 2 | 3-5 | Notable pattern |
| 3 | 6-10 | Common issue |
| 4 | 11-20 | Widespread problem |
| 5 | 20+ | Systemic failure |

**Severity Score (1-4):**
| Score | Level | Signal Words |
|-------|-------|--------------|
| 1 | Annoyance | "wish," "minor," "sometimes" |
| 2 | Friction | "frustrating," "annoying," "confusing" |
| 3 | Blocker | "can't," "impossible," "forced to" |
| 4 | Dealbreaker | "leaving," "nightmare," "unacceptable" |

**Recency Multiplier:**
| Multiplier | Timeframe | Rationale |
|------------|-----------|-----------|
| 0.5 | >2 years old | Possibly fixed |
| 1.0 | Mixed recency | Standard weight |
| 1.5 | Mostly <6 months | Active problem |

**PPS Range: 0.5 to 30**
- **Critical (20-30)**: Solve this, win the market
- **High (10-19)**: Strong opportunity
- **Medium (5-9)**: Worth considering
- **Low (<5)**: Nice-to-have territory

### Hidden Gem Score

```
Hidden Gem Score = Pain Frequency × Competitor Gap Score
```

**Competitor Gap Score (0-5):**
| Score | Coverage |
|-------|----------|
| 0 | All major competitors have it |
| 3 | Few competitors address it |
| 5 | No competitor addresses it |

### Viability Scorecard (30 max)

| Factor | What to Look For | Score |
|--------|------------------|-------|
| **Market Pain Severity** | Emotional language, switching behavior | 1-5 |
| **Willingness to Pay** | Price complaints (good!), "worth any price" | 1-5 |
| **Competitor Vulnerability** | Ignored complaints, stale products, acquisitions | 1-5 |
| **Switching Cost Reality** | Data portability, "stuck with" comments | 1-5 |
| **Market Timing** | Recent pricing changes, feature removal, windows | 1-5 |
| **Differentiation Potential** | Can you solve 1 thing 10x better? | 1-5 |

See [references/scoring-rubrics.md](references/scoring-rubrics.md) for detailed scoring criteria.

---

## Viability Verdicts

### GO (25-30)
Strong opportunity. Clear pain, achievable solution, winnable market.

### PROCEED WITH CAUTION (18-24)
Opportunity exists but validate further. Address specific risks identified.

### RECONSIDER (12-17)
Significant risks. Consider pivoting focus or target segment.

### NO-GO (6-11)
Do not pursue without fundamental changes to the approach.

---

## Brutal Honesty Framework

**Every report must answer these questions honestly:**

1. **What would make this fail completely?**
2. **Why hasn't someone already solved this?**
3. **What are you not seeing that incumbents see?**
4. **Is this a vitamin or a painkiller?**
5. **If built perfectly, would anyone actually switch?**
6. **What's your unfair advantage in solving this?**

**No sugar-coating. No wishful thinking. Data-backed brutal truth.**

---

## Output Format

Target length: **1,500-2,500 words** (substantial but scannable)

See [references/output-template.md](references/output-template.md) for the complete template.

### Quick Reference

```markdown
# Problem Research: [Category]
**Industry:** [Vertical] | **Competitors:** [Count] | **Date:** [YYYY-MM-DD]

## Executive Summary
[3-4 sentences: Top pain, biggest opportunity, verdict]

## Pain Points Table
| Rank | Pain Point | Freq | Severity | PPS | Sample Quote |
|------|------------|------|----------|-----|--------------|

## Must-Haves Table
| Must-Have | Coverage | Why Non-Negotiable |
|-----------|----------|---------------------|

## Hidden Gems
### Gem 1: [Underserved Need]
- **Evidence:** [Quote]
- **Why ignored:** [Hypothesis]
- **Opportunity:** [S/M/L]

## Opportunity Map
| Wedge | Target | Pain Solved | Defensibility |
|-------|--------|-------------|---------------|

## Viability Assessment
**VERDICT: [GO / PROCEED WITH CAUTION / RECONSIDER / NO-GO]**

### The Brutal Truth
[Unflinching analysis]

### Red Flags / Green Lights
### If You Proceed / Kill Criteria

## Data Sources
| Source | Competitors | Reviews |
|--------|-------------|---------|
```

---

## Pain Point Categories

When categorizing pain points, use these standard categories:

1. **UX/Usability** - Interface complexity, learning curve, navigation
2. **Performance** - Speed, reliability, uptime, latency
3. **Features** - Missing capabilities, limited functionality
4. **Pricing** - Cost, value perception, billing issues, hidden fees
5. **Support** - Response time, quality, availability
6. **Reliability** - Bugs, crashes, data loss, inconsistency
7. **Integration** - API limitations, third-party connections
8. **Onboarding** - Setup difficulty, documentation, training
9. **Mobile** - Mobile app quality, cross-device experience
10. **Reporting** - Data visibility, export limitations, analytics

---

## Key Principles

- **Evidence over opinion**: Every insight backed by real quotes
- **Frequency matters**: Weight by how often something appears
- **Sentiment context**: Note the emotion, not just the complaint
- **Segment awareness**: Note if pain is specific to SMB/Enterprise/Industry
- **Brutal honesty**: The viability assessment pulls no punches
- **Actionable output**: Everything leads to go/no-go decisions

---

## Example Invocations

```bash
# Full interactive session
skill problem-research

# With initial context
skill problem-research "Project management software for marketing teams"

# Specific competitor focus
skill problem-research "CRM alternatives to Salesforce for SMBs"
```

---

## Quick Start

1. User provides target category/product
2. Select research scope (Light/Medium/Deep)
3. Select execution mode (Semi-automated/Agentic browsing)
4. Research executes with TodoWrite progress tracking
5. Report generated with all sections
6. User chooses save option

**Skill Status**: Complete
