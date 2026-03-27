---
name: content-refresher
description: "Audit content for outdated statistics, dates, examples, and stale references, then produce a prioritized refresh plan. Use when reviewing content freshness, updating old articles, checking for outdated information, or auditing content decay."
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Content Refresher

Identify update opportunities in existing content to maintain freshness and relevance.

## Process

1. Scan content for dates, year references, and time-sensitive phrases
   - Flag any statistic older than 2 years
   - Flag year mentions in titles or headers (e.g., "Best Tools 2024")
2. Identify data points and verify whether current equivalents exist
   - If current data is unavailable, note as "needs research" rather than fabricating
3. Find examples and case studies — flag anything 3+ years old
4. Check for dated terminology or deprecated tool/service names
5. Assess topic completeness against current industry state
6. Prioritize updates using the matrix below
7. Recommend new sections to fill content gaps

## Refresh Priority Matrix

| Priority | Criteria | Action |
|----------|----------|--------|
| **High** | Pages losing 3+ ranking positions; factually outdated info; high-traffic pages declining | Update within 1 week |
| **Medium** | Stagnant rankings 6+ months; competitors published fresher content; missing current trends | Update this month |
| **Low** | Minor date references; cosmetic freshness signals; supplementary examples | Batch in next content cycle |

## Output Format

```
Page: [URL or file path]
Last Updated: [date]
Priority: High / Medium / Low

Refresh Actions:
- [specific item]: Update [old value] → [suggested replacement or "needs research"]
- Add section on [new trend/development]
- Replace [old example] with [current equivalent]
- Update meta title/description with current year if applicable
```

## Freshness Signals to Update

- Modified date in schema markup
- Internal links to/from recently published content
- Fresh images with current context
- New FAQ entries reflecting recent questions
