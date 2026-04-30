---
name: schema-architect
description: Use when adding or auditing Schema.org structured data for Google Search rich results, AI Overviews, and classic search indexing. Generate JSON-LD for organization, FAQ, HowTo, product, and article schemas. Not for direct LLM citation in ChatGPT/Claude/Perplexity — use ai-crawler-readiness for HTTP-layer LLM visibility. Not for content structure — use structure-architect.
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Schema Architect

Design and implement Schema.org structured data for Google Search rich results, AI Overviews, and classic indexing.

**Routing:**
- Use this skill for: Google rich results, AI Overviews eligibility, entity disambiguation in classic search
- Use `ai-crawler-readiness` for: LLM citation in ChatGPT, Claude, Perplexity, Gemini chat
- Use `llms-txt-builder` for: AI navigation file content

**Honest caveat:** Structured data helps Google's classic indexing and AI Overviews via search. There is no public evidence current LLMs (ChatGPT, Claude, Perplexity, Gemini chat) parse JSON-LD when answering — do not treat schema as a primary GEO citation lever.

## Schema Priority Matrix

**High-Impact (Implement First):**

| Schema Type | Use Case | AI Benefit | Rich Result |
|-------------|----------|------------|-------------|
| `Organization` + `WebSite` | Company info | Entity recognition | Sitelinks search box |
| `FAQPage` | Q&A content | Direct answer extraction | FAQ dropdowns |
| `HowTo` | Tutorials/guides | Step extraction | Step-by-step snippet |
| `Article/BlogPosting` | Blog content | Content attribution | Article carousel |
| `Product` + `Offer` | Pricing/e-commerce | Product info extraction | Price in search |
| `AggregateRating` | Reviews/testimonials | Trust signals | Star ratings |
| `BreadcrumbList` | Navigation | Site structure | Breadcrumb trail |

**Medium-Impact:** `Person`, `LocalBusiness`, `Event`, `Course`, `SoftwareApplication`

## Site Archetype Mappings

See [references/site-archetypes.yaml](references/site-archetypes.yaml) for page-to-schema mappings per site type (SaaS, e-commerce, agency, blog, docs).

## Implementation Templates

See [references/schema-templates.yaml](references/schema-templates.yaml) for JSON-LD code snippets:
- Organization schema
- FAQPage schema
- HowTo schema
- Article schema
- Product schema

## Multimodal Structured Data

Include media references:
- Image objects with alt descriptions
- Video objects with transcripts
- Audio references where applicable

## Workflow

1. Audit existing structured data
2. Identify missing high-impact schemas
3. Map content types to schema types
4. Generate JSON-LD code
5. Validate with testing tools
6. Plan maintenance schedule

## Output Format

```
Schema Implementation Plan
--------------------------
Current Coverage: X/10
Target Coverage: Y/10

Priority Implementations:
1. Organization schema (homepage)
2. FAQPage schema (support pages)
3. Article schema (blog posts)
4. HowTo schema (tutorials)

Validation:
- Rich Results Test: [Pass/Fail]
- Schema.org Validator: [Pass/Fail]
```

## Validation Tools

- Google Rich Results Test
- Schema.org Validator
- Structured Data Linter

## Platform Integration

| Platform | Approach |
|----------|----------|
| WordPress | Yoast/RankMath schema settings |
| Next.js | next-seo configuration |
| Astro | schema components |
| Static | JSON-LD in `<head>` |
