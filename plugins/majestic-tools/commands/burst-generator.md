---
description: Generate multiple response variants with probability scores for any request
argument-hint: "[count:N] <request>"
---

# Burst Generator

Generate multiple distinct responses with their correspond  probability.

## Input Parsing

**Arguments:** `{{ARGS}}`

Parse:
- **count** - Number of responses (default: 5, max: 10)
  - Explicit: `count:3`, `n:7`, `5x`
  - Implicit: defaults to 5
- **request** - Everything else is the request to generate variants for

## Probability Interpretation

The meaning of "probability" adapts to the request type:

| Request Type | Probability Means |
|--------------|-------------------|
| Marketing copy | Conversion likelihood |
| Names/taglines | Memorability + fit |
| Technical solutions | Correctness + feasibility |
| Creative writing | Quality + originality |
| Email subjects | Open rate potential |
| Predictions | Confidence in accuracy |
| Recommendations | Suitability for context |

## Generation Rules

1. **Diversity first** - Each response must be meaningfully different
   - Different angles, tones, or approaches
   - Not just word substitutions

2. **Quality maintained** - All responses should be viable
   - No filler responses to hit the count
   - Each could stand alone as a valid answer

3. **Honest scoring** - Probabilities reflect genuine assessment
   - Probabilities should NOT sum to 100% (they're independent quality scores)
   - Score each response on its own merits
   - It's fine if multiple responses score high or low

## Output Format

```markdown
## Burst: {{count}} Variants

**Request:** {{request}}
**Probability basis:** [What the scores represent for this request]

---

### 1. [Brief label] — **{{probability}}%**

[Complete response]

**Rationale:** [Why this probability score]

---

### 2. [Brief label] — **{{probability}}%**

[Complete response]

**Rationale:** [Why this probability score]

---

[Continue for all variants...]

---

## Summary

| # | Variant | Probability | Key Differentiator |
|---|---------|-------------|-------------------|
| 1 | [label] | XX% | [What makes it unique] |
| 2 | [label] | XX% | [What makes it unique] |
...

**Recommendation:** [Which variant(s) to consider and why]
```

## Edge Cases

- **count > 10**: Cap at 10, note the limit
- **count = 1**: Just provide single response with confidence score
- **Ambiguous request**: Ask for clarification before generating
- **Request requires context**: Note what context would improve the variants
