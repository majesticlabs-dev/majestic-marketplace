---
name: keyword-strategist
description: "Analyze keyword density, generate LSI keywords, map entity relationships, and flag over-optimization in content. Use when optimizing content for SEO, researching keywords, checking keyword density, or improving search rankings."
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Keyword Strategist

Analyze content for semantic optimization opportunities and keyword strategy.

## Process

1. Extract current keyword usage from provided content
2. Calculate keyword density percentages per term
   - Primary keyword target: 0.5–1.5% density
   - If density exceeds 2%, flag specific sentences for revision
3. Identify entities and map related concepts
4. Determine search intent from content type and structure
5. Generate 20–30 LSI keywords based on topic clustering
6. Suggest optimal keyword distribution across headings, body, and meta
7. Flag over-optimization issues (stuffing, unnatural placement)

## Keyword Density Calculation

```
density = (keyword_occurrences / total_words) * 100
```

Example analysis:
```
Total words: 1,500
"project management" appears 12 times → 0.8% ✓
"best software" appears 45 times → 3.0% ✗ (over-optimized)
```

## Entity Analysis

1. Identify primary entity relationships in the content
2. Map co-occurring entities and concepts (people, tools, methods)
3. Identify gaps where competitor content includes entities this content misses
4. Recommend entity-rich sections to build topical authority

## Output Format

```
Primary: [keyword] ([density]%, [count] uses) — [status: OK/HIGH/LOW]
Secondary: [3-5 keywords with target density]
LSI Keywords: [20-30 semantic variations grouped by subtopic]
Entities: [related concepts to weave in]
Over-optimization flags: [specific sentences needing revision]
```

## Advanced Recommendations

- Question-based keywords for People Also Ask (PAA)
- Voice search long-tail variations
- Featured snippet keyword opportunities
- Keyword clustering for topic hub architecture
