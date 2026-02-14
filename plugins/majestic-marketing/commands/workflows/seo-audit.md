---
name: majestic:seo-audit
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch
description: Quick SEO audit of provided content with actionable recommendations
disable-model-invocation: true
---

# SEO Audit Command

Perform a comprehensive SEO and GEO audit of the provided content.

## Input

$ARGUMENTS

## Instructions

1. **Read the Content**
   - If a file path is provided, read the file
   - If a URL is provided, fetch and analyze the content
   - If content is pasted, analyze directly

2. **Run Quick Audit**

   Evaluate these key areas (score each 1-10):

   **Technical SEO:**
   - Title tag (length, keyword placement)
   - Meta description (length, CTA)
   - Header hierarchy (H1 → H2 → H3)
   - URL structure
   - Internal/external links

   **Content Quality:**
   - Topic completeness
   - Unique value
   - Readability
   - Freshness

   **Keyword Optimization:**
   - Primary keyword presence
   - Keyword density
   - Semantic coverage
   - Search intent alignment

   **E-E-A-T Signals:**
   - Author credentials
   - Trust indicators
   - Source citations
   - Expertise demonstration

   **AI/GEO Readiness:**
   - Content extractability
   - Fact-density
   - Structure for AI
   - FAQ/summary presence

3. **Generate Report**

   Output format:
   ```
   ## SEO Audit: [Title/URL]

   **Overall Score: X/100**

   ### Quick Scores
   | Category | Score | Status |
   |----------|-------|--------|
   | Technical | X/20 | [emoji] |
   | Content | X/25 | [emoji] |
   | Keywords | X/15 | [emoji] |
   | E-E-A-T | X/20 | [emoji] |
   | AI Ready | X/20 | [emoji] |

   ### Top 5 Issues (Priority Order)
   1. **[Issue]** - [Quick fix]
   2. **[Issue]** - [Quick fix]
   3. **[Issue]** - [Quick fix]
   4. **[Issue]** - [Quick fix]
   5. **[Issue]** - [Quick fix]

   ### What's Working Well
   - [Positive finding]
   - [Positive finding]

   ### Action Plan
   **Do Today:**
   - [ ] [Immediate action]
   - [ ] [Immediate action]

   **Do This Week:**
   - [ ] [Short-term action]
   - [ ] [Short-term action]
   ```

4. **Offer Next Steps**
   - Offer to fix specific issues
   - Suggest running full audit with `skill seo-audit`
   - Recommend relevant SEO agents for detailed work

## Status Emojis

- Score 8-10: ✓ (Good)
- Score 5-7: ⚠ (Needs Work)
- Score 0-4: ✗ (Critical)
