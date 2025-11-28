---
name: seo-audit
description: Comprehensive SEO and GEO audit methodology covering technical SEO, on-page optimization, content quality, E-E-A-T signals, and AI citation readiness. Use for thorough content and site audits.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch
---

# SEO Audit Skill

A comprehensive SEO audit methodology that evaluates content for both traditional search engine optimization and modern AI/LLM visibility (GEO).

## When to Use

- Auditing existing content for SEO performance
- Reviewing new content before publication
- Identifying optimization opportunities
- Assessing AI citation readiness
- Evaluating E-E-A-T signals
- Checking technical SEO elements

## Audit Framework

### Phase 1: Technical SEO Check

Evaluate foundational technical elements:

**Page-Level Technical:**
- [ ] URL structure (clean, descriptive, <60 chars)
- [ ] Title tag (50-60 chars, keyword in first 30)
- [ ] Meta description (150-160 chars, compelling CTA)
- [ ] H1 tag (single, matches topic)
- [ ] Header hierarchy (logical H1→H2→H3)
- [ ] Image alt text (descriptive, keyword-relevant)
- [ ] Internal links (contextual, relevant)
- [ ] External links (authoritative sources)

**Site-Level Technical:**
- [ ] HTTPS enabled
- [ ] Mobile-friendly
- [ ] Page speed (<1.8s mobile)
- [ ] Schema markup present
- [ ] XML sitemap inclusion
- [ ] robots.txt accessibility

### Phase 2: Content Quality Assessment

Evaluate content depth and value:

**Content Completeness:**
| Factor | Check | Score |
|--------|-------|-------|
| Topic coverage | Comprehensive vs. shallow | /10 |
| Unique value | Original insights vs. rehash | /10 |
| Accuracy | Factual, verifiable | /10 |
| Freshness | Current information | /10 |
| Depth | Expert-level detail | /10 |

**Readability:**
- Reading level (target: Grade 8-10)
- Paragraph length (2-3 sentences ideal)
- Sentence variety
- Scannable formatting (bullets, headers)
- Visual aids (images, tables, diagrams)

### Phase 3: Keyword & Semantic Analysis

Assess keyword optimization:

**Primary Keyword:**
- Present in title tag
- In H1 and early H2s
- Natural density (0.5-1.5%)
- In meta description
- In first 100 words

**Semantic Coverage:**
- LSI keywords present
- Related entities covered
- Topic cluster alignment
- Question variations addressed
- Search intent match

### Phase 4: E-E-A-T Evaluation

Assess Experience, Expertise, Authority, Trust signals:

**Experience Signals:**
- [ ] First-hand experience indicated
- [ ] Case studies/examples included
- [ ] Original data/research
- [ ] Process documentation

**Expertise Signals:**
- [ ] Author credentials visible
- [ ] Technical accuracy
- [ ] Comprehensive coverage
- [ ] Expert quotes/interviews

**Authority Signals:**
- [ ] Authoritative external citations
- [ ] Industry recognition
- [ ] Brand mentions
- [ ] Published research

**Trust Signals:**
- [ ] Contact information
- [ ] Privacy policy
- [ ] Editorial guidelines
- [ ] Reviews/testimonials
- [ ] Security indicators

### Phase 5: AI/GEO Readiness

Assess content for LLM visibility:

**Extractability:**
- [ ] TL;DR or summary present
- [ ] Paragraphs <120 words
- [ ] Clear topic sentences
- [ ] Bullet lists for features
- [ ] Tables for comparisons
- [ ] FAQ section present

**Fact-Density:**
- [ ] Statistics with sources
- [ ] Specific numbers/dates
- [ ] Verifiable data points
- [ ] Expert quotes with attribution

**Structure for AI:**
- [ ] Question-based headers
- [ ] Direct answers near top
- [ ] Logical information hierarchy
- [ ] Schema markup (FAQPage, HowTo)

## Output Format

### SEO Audit Report

```markdown
## SEO Audit Report

**Page:** [URL or filename]
**Date:** [Audit date]
**Overall Score:** X/100

### Executive Summary
[2-3 sentence overview of findings]

### Scores by Category

| Category | Score | Status |
|----------|-------|--------|
| Technical SEO | X/20 | [Good/Needs Work/Critical] |
| Content Quality | X/25 | [Good/Needs Work/Critical] |
| Keyword Optimization | X/15 | [Good/Needs Work/Critical] |
| E-E-A-T Signals | X/20 | [Good/Needs Work/Critical] |
| AI/GEO Readiness | X/20 | [Good/Needs Work/Critical] |

### Priority Issues (Fix First)

1. **[Issue]** - [Impact] - [Fix]
2. **[Issue]** - [Impact] - [Fix]
3. **[Issue]** - [Impact] - [Fix]

### Technical SEO Findings
[Detailed findings with specific recommendations]

### Content Quality Findings
[Detailed findings with specific recommendations]

### Keyword Analysis
[Primary keyword performance, semantic gaps]

### E-E-A-T Assessment
[Specific signals present/missing]

### AI Visibility Assessment
[GEO readiness score and improvements]

### Action Plan

**Immediate (This Week):**
- [ ] Action 1
- [ ] Action 2

**Short-term (This Month):**
- [ ] Action 1
- [ ] Action 2

**Ongoing:**
- [ ] Action 1
- [ ] Action 2
```

## Scoring Guide

**90-100:** Excellent - Minor optimizations only
**70-89:** Good - Some improvements needed
**50-69:** Needs Work - Significant gaps to address
**Below 50:** Critical - Major overhaul required

## Quick Audit Option

For faster audits, focus on:

1. **Title & Meta** - Optimized, compelling?
2. **H1 & Structure** - Clear hierarchy?
3. **Content Depth** - Comprehensive?
4. **E-E-A-T** - Author/trust signals?
5. **AI Ready** - Extractable format?

Deliver top 5 issues with fixes.
