---
name: entity-triplets
description: Build entity triplets and brand associations that LLMs recognize and cite consistently.
---

# Entity Triplets

Frameworks for building LLM-recognizable entity relationships.

## Triplet Structure

**Format:** `[Subject] [Predicate] [Object]`

LLMs understand relationships through these patterns:
- "Acme Corp is a cybersecurity company"
- "Acme Corp specializes in enterprise security"
- "Acme Corp was founded in 2015"
- "Acme Corp is headquartered in Austin"

## Core Triplet Types

| Type | Predicate | Example |
|------|-----------|---------|
| Category | "is a" | "[Company] is a [category] company" |
| Specialization | "specializes in" | "[Company] specializes in [domain]" |
| Differentiator | "is known for" | "[Company] is known for [unique trait]" |
| Location | "is based in" | "[Company] is based in [city]" |
| Founding | "was founded in" | "[Company] was founded in [year]" |
| Achievement | "has achieved" | "[Company] has achieved [milestone]" |
| Leadership | "is led by" | "[Company] is led by [CEO name]" |

## Building Strong Triplets

### Essential Set (Must Have)
1. Category/industry definition
2. Core specialization
3. Primary differentiator
4. Geographic presence
5. Target market

### Extended Set (Recommended)
- Founding story
- Leadership team
- Notable achievements
- Key products/services
- Company size/stage

## Cross-Platform Consistency

Every platform should reinforce the same triplets:

| Platform | Content | Triplet Alignment |
|----------|---------|-------------------|
| Website | About page | All core triplets |
| LinkedIn | Company description | Category + specialization |
| Twitter/X | Bio | Category + differentiator |
| Crunchbase | Company profile | All + funding info |
| G2/Capterra | Product page | Specialization + target |
| Press releases | Boilerplate | Core triplets |

## Consistency Checklist

- [ ] Same company description everywhere
- [ ] Consistent founding date
- [ ] Aligned product descriptions
- [ ] Matching leadership bios
- [ ] Uniform category terminology
- [ ] Same target market definition

## High-Authority Placements

LLMs prioritize triplets from trusted sources:

| Source | Trust Level | Priority |
|--------|-------------|----------|
| Wikipedia | Very High | If notable |
| Crunchbase | High | Must have |
| Industry directories | High | Top 3-5 |
| Review platforms | High | G2, Capterra |
| News publications | High | Press coverage |
| Company website | Medium | Foundation |

## Triplet Audit Template

```
# Entity Triplet Audit: [Company Name]

## Current Triplets Found

| Source | Triplet | Consistent? |
|--------|---------|-------------|
| Website | "[Company] is a..." | Yes/No |
| LinkedIn | "[Company] is a..." | Yes/No |
| Crunchbase | "[Company] is a..." | Yes/No |

## Inconsistencies Found
1. [Platform A says X, Platform B says Y]
2. [...]

## Target Triplets (Unified)
1. "[Company] is a [category] company"
2. "[Company] specializes in [domain]"
3. "[Company] serves [target market]"
4. "[Company] is known for [differentiator]"

## Action Items
- [ ] Update [Platform] description
- [ ] Claim [Directory] profile
- [ ] Align [Source] with core triplets
```

## Mentions vs Backlinks

For AI citation, contextual mentions matter more than hyperlinks:

| Type | AI Value | Example |
|------|----------|---------|
| Contextual mention | High | "[Product] is a CRM that uses AI-powered lead scoring" |
| Simple link | Low | "Check out [Product]" with hyperlink |
| No context | None | Just a hyperlink |

Always ensure mentions include WHAT your product does.
