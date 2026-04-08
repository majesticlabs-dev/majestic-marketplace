---
name: snippet-hunter
description: "Format content for featured snippet eligibility by structuring answers, lists, tables, and FAQ schema markup. Use when optimizing for position zero, Google featured snippets, rich results, answer boxes, or People Also Ask."
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Snippet Hunter

Format content for position zero potential and featured snippet eligibility.

## Process

1. Identify questions the content answers (explicit headers + implicit queries)
2. Determine best snippet format using decision criteria:
   - **Paragraph**: definition queries, "what is" → 40–60 word direct answer
   - **List**: "how to", "steps", "ways to" → 5–8 numbered/bulleted items
   - **Table**: comparisons, specifications, pricing → structured rows and columns
3. Create snippet-optimized content blocks for each target query
4. Place direct answers immediately after the question header (first sentence)
5. Add surrounding context that enriches without diluting the snippet
6. Generate FAQ schema markup for question clusters
7. Validate: answer length within snippet limits, question in H2/H3, answer is self-contained

## Snippet Template

```markdown
## [Exact question users search for]

[40-60 word direct answer with primary keyword in the first sentence.
Clear, definitive response that fully answers the query without
requiring surrounding context.]

### Supporting Details
- [Enriching context point]
- [Related entity or statistic]
- [Additional value or next step]
```

## FAQ Schema Markup

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is [topic]?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[40-60 word direct answer]"
      }
    }
  ]
}
```

## HowTo Schema Markup

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to [action]",
  "step": [
    {
      "@type": "HowToStep",
      "text": "[Step description]"
    }
  ]
}
```

## Validation Checklist

- Answer is 40–60 words for paragraph snippets
- Question appears as H2 or H3 header
- Answer starts immediately after the header (no preamble)
- List items are concise (under 15 words each)
- Table has clean markdown formatting with header row
