# Majestic Marketing

Marketing and SEO tools for Claude Code. Includes 16 specialized agents, 6 commands, and 49 skills.

## Installation

```bash
claude /plugin install majestic-marketing
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| **Where do I start?** | `skill marketing-playbook` |
| **Complete AEO workflow** | `/majestic-marketing:workflows:aeo-workflow` |
| Quick SEO audit | `/majestic-marketing:workflows:seo-audit` |
| Comprehensive content check | `/majestic-marketing:workflows:content-check` |
| Optimize for AI citation | `agent llm-optimizer` |
| Build brand authority | `agent authority-builder` |
| Generate brand names | `agent namer` |
| **Analyze my writing voice** | `skill style-forensics` |
| **Codify brand voice** | `skill brand-voice` |
| **Write in someone's voice** | `skill style-writer` |
| **Make AI text sound human** | `skill humanizer` |
| **Repurpose content multi-platform** | `skill content-atomizer` |
| **Write newsletter editions** | `skill newsletter` |
| **Create lead magnets** | `skill lead-magnet` |
| Create sales page | `skill sales-page` |
| Design email nurture | `skill email-nurture` |
| Build content calendar | `skill content-calendar` |

## Content Creation: Which Skill Do I Use?

Multiple skills handle writing and content — each for a different job. Use this guide to pick the right one.

### The Content Pipeline

```
style-forensics → style-writer → humanizer (with DNA) → copy-editor
(measure voice)   (write in voice)  (strip AI tells)      (polish)
```

### Decision Table

| I want to... | Use this | Why not the others? |
|--------------|----------|---------------------|
| **Write an article from scratch** | `content-writer` | General-purpose, outline-first workflow. No SEO or voice targeting. |
| **Write an SEO article that ranks** | `seo-content` | Keyword research → draft → built-in humanization → on-page SEO. Has its own AI-detection pass. |
| **Write matching someone's exact voice** | `style-writer` | Takes a Style DNA report, hits measured metrics (sentence length, comma density, device frequency). Precision ghostwriting. |
| **Measure my personal writing voice** | `style-forensics` | Forensic analysis producing quantitative Style DNA report. Run this *before* style-writer. |
| **Codify organizational brand voice** | `brand-voice` | Qualitative brand voice guide with tone spectrum, vocabulary, do/don'ts. For companies, not individuals. |
| **Make AI text sound human** | `humanizer` | Rewrites existing AI-generated text. Strips banned words, injects burstiness and voice, defeats detectors. Accepts Style DNA to preserve intentional devices. |
| **Polish grammar and style** | `copy-editor` | Reviews and reports issues. Doesn't rewrite — diagnoses. Run *after* other skills. |
| **Repurpose content for social** | `content-atomizer` | Transforms long-form into Twitter threads, LinkedIn posts, email excerpts, video scripts. |
| **Write a newsletter** | `newsletter` | Edition-focused: curator, educator, or thought leader archetypes. |
| **Build a case study** | `case-study-writer` | Customer story format with problem → solution → results. |

### Common Workflows

**Blog post (no voice target):**
`content-writer` → `humanizer` → `copy-editor`

**SEO article:**
`seo-content` (handles everything including humanization)

**Ghostwriting in someone's style:**
`style-forensics` (once, to create DNA) → `style-writer` → `humanizer` (with same DNA) → `copy-editor`

**Fix robotic AI draft:**
`humanizer` → `copy-editor`

**Content repurposing:**
Any writing skill → `content-atomizer`

## Agents

### branding

Invoke with: `agent <name>`

| Agent | Description |
|-------|-------------|
| `namer` | Generate category-defining brand, company, and product names using Igor naming methodology |

### seo

Invoke with: `agent <name>`

#### Traditional SEO

| Agent | Description |
|-------|-------------|
| `authority-builder` | E-E-A-T analysis and authority signal optimization |
| `cannibalization-detector` | Keyword overlap and conflict detection |
| `content-auditor` | Content quality and SEO best practices audit |
| `content-planner` | Topic clusters and content calendar planning |
| `content-refresher` | Identify outdated content and suggest updates |
| `content-writer` | SEO-optimized content creation |
| `keyword-strategist` | Keyword density, LSI, semantic optimization |
| `meta-optimizer` | Meta titles, descriptions, URL optimization |
| `snippet-hunter` | Featured snippet and SERP feature optimization |
| `structure-architect` | Header hierarchy, schema, internal linking |

#### GEO (AI Visibility)

| Agent | Description |
|-------|-------------|
| `entity-builder` | Brand entity and triplet optimization for LLM presence |
| `llm-optimizer` | Optimize content for AI citation (ChatGPT, Perplexity, Gemini) |
| `schema-architect` | Schema.org and llms.txt implementation for AI extraction |

## Commands

Invoke with: `/majestic-marketing:workflows:<name>`

| Command | Description |
|---------|-------------|
| `workflows:content-check` | Comprehensive content check for SEO and AI readability |
| `workflows:seo-audit` | Quick SEO audit with actionable recommendations |

## Skills

Invoke with: `skill majestic-marketing:<name>`

### Content & Copy

| Skill | Description |
|-------|-------------|
| `brand-voice` | Codify organizational brand voice into a reusable style guide with tone spectrum, vocabulary, and do/don'ts |
| `content-atomizer` | Transform long-form content into Twitter threads, LinkedIn carousels, email excerpts, video scripts, and Instagram posts |
| `content-calendar` | 30-day content calendar with viral ideas, formats, hooks, and CTAs |
| `content-optimizer` | Content optimization workflow for search and AI |
| `content-writer` | Articles with outline-first workflow and readability guidelines |
| `copy-editor` | Review and edit copy for grammar, style, and clarity |
| `humanizer` | Rewrite AI-generated text to sound naturally human-written, defeat detection patterns |
| `hook-writer` | Attention-grabbing hooks from 5 investor archetype perspectives |
| `linkedin-content` | LinkedIn content with hooks, pillars, and posting strategy |
| `power-words` | Enhance copy with emotional trigger words from 18 categories |
| `seo-audit` | Comprehensive SEO and GEO audit methodology |
| `slogan-generator` | Marketing slogans with scoring and recommendations |
| `style-forensics` | Forensic style analysis producing quantitative Style DNA reports with measured metrics |
| `style-writer` | Write articles matching a specific author's voice from a Style DNA report |
| `viral-content` | Viral content frameworks with platform-specific patterns |

### Marketing & Strategy

| Skill | Description |
|-------|-------------|
| `bofu-keywords` | Bottom-of-funnel keywords with high purchase intent |
| `competitive-positioning` | Analyze competitors, craft differentiators, taglines, and pitches |
| `lead-magnet` | Create checklists, templates, swipe files, guides, and toolkits that convert |
| `customer-discovery` | Find where customers discuss problems, extract language |
| `free-tool-arsenal` | Complete business tech stack with 100% free tools |
| `irresistible-offer` | Craft offers using direct response marketing principles |
| `landing-page-builder` | Structured landing page copy (simpler than sales-page) |
| `market-research` | Comprehensive research with web data and competitive analysis |
| `marketing-strategy` | Interactive interview to build custom strategy with JSON export |
| `sales-page` | High-converting templates with headline formulas and CTA psychology |
| `traffic-magnet` | Organic traffic and customer acquisition with zero ad spend |
| `value-prop-sharpener` | Refine value propositions into 15-word statements |

### Acquisition & Ads

| Skill | Description |
|-------|-------------|
| `case-study-writer` | Customer case studies for marketing and sales enablement |
| `google-ads-strategy` | Google Ads campaigns with keyword strategy and budget allocation |

### Retention & Nurture

| Skill | Description |
|-------|-------------|
| `email-nurture` | Automated email sequences with segmentation and triggers |
| `newsletter` | Create engaging newsletter editions with curator, educator, and thought leader archetypes |
| `retention-system` | Customer retention with health scoring and churn prediction |

### GEO/AEO (AI Visibility)

| Skill | Description |
|-------|-------------|
| `aeo-scorecard` | AEO measurement framework with AI visibility, share of voice, and citation metrics |

### Meta / Getting Started

| Skill | Description |
|-------|-------------|
| `marketing-playbook` | Your guide to the toolkit - diagnoses your stage and recommends what to use next |

## SEO vs GEO vs AEO

This plugin covers traditional SEO, GEO (Generative Engine Optimization), and AEO (Answer Engine Optimization):

| Aspect | Traditional SEO | GEO/AEO Focus |
|--------|-----------------|---------------|
| Goal | Rank in search results | Get cited in AI responses |
| Focus | Keywords + backlinks | Semantic depth + fact-density |
| Structure | Readable by humans | Extractable by AI |
| Authority | Domain authority | Citation quality + source reputation |
| Measurement | Rankings, traffic | AI visibility, share of voice, citations |

### AEO-Enhanced Agents

- **`llm-optimizer`** - Now includes 7-step AEO on-page checklist, query fan-out analysis, and the "Taco Bell Test" for content chunking
- **`entity-builder`** - Enhanced with AI citation source strategy (mentions > backlinks) and feature-specific review guidance
- **`content-planner`** - Now includes buyer persona × journey grid and three-pronged query sourcing

### AEO Measurement

Use `skill aeo-scorecard` to learn the four key AEO metrics:
1. **AI Visibility** - Are you recommended for priority queries?
2. **AI Share of Voice** - Your mentions vs. competitors
3. **AI Citations** - Is YOUR site the source?
4. **Referral Demand** - Traffic from AI that doesn't click through

## Usage Examples

### SEO Agents

```bash
# E-E-A-T analysis
agent majestic-marketing:seo:authority-builder

# Check for keyword cannibalization
agent majestic-marketing:seo:cannibalization-detector

# Optimize for featured snippets
agent majestic-marketing:seo:snippet-hunter
```

### GEO (AI Visibility) Agents

```bash
# Optimize content for LLM citation
agent majestic-marketing:seo:llm-optimizer

# Build brand entity presence
agent majestic-marketing:seo:entity-builder

# Implement schema for AI extraction
agent majestic-marketing:seo:schema-architect
```

### Branding

```bash
# Generate category-defining brand names
agent majestic-marketing:branding:namer
```

### Commands

```bash
# Quick SEO audit
/majestic-marketing:workflows:seo-audit path/to/content.md

# Content quality check
/majestic-marketing:workflows:content-check path/to/article.md
```

### Content & Copy Skills

```bash
# Create brand voice guide from existing content
skill majestic-marketing:brand-voice

# Repurpose article into multi-platform assets
skill majestic-marketing:content-atomizer

# Full SEO audit methodology
skill majestic-marketing:seo-audit

# Content optimization workflow
skill majestic-marketing:content-optimizer

# 30-day content calendar
skill majestic-marketing:content-calendar

# Write articles with outline-first workflow
skill majestic-marketing:content-writer

# Analyze writing samples to create Style DNA report
skill majestic-marketing:style-forensics path/to/writing-sample.md

# Write matching a specific author's voice
skill majestic-marketing:style-writer

# Rewrite AI text to sound human (respects Style DNA if provided)
skill majestic-marketing:humanizer

# Enhance copy with emotional trigger words
skill majestic-marketing:power-words
```

### Marketing & Strategy Skills

```bash
# Create lead magnets (checklists, templates, guides)
skill majestic-marketing:lead-magnet

# Market research
skill majestic-marketing:market-research

# Marketing strategy builder
skill majestic-marketing:marketing-strategy

# Direct response offer creation
skill majestic-marketing:irresistible-offer

# High-converting sales pages
skill majestic-marketing:sales-page

# Quick landing page copy
skill majestic-marketing:landing-page-builder
```

### Acquisition & Ads Skills

```bash
# Google Ads campaign strategy
skill majestic-marketing:google-ads-strategy

# Customer case studies
skill majestic-marketing:case-study-writer
```

### Retention & Nurture Skills

```bash
# Email nurture sequences
skill majestic-marketing:email-nurture

# Newsletter editions (curator, educator, thought leader)
skill majestic-marketing:newsletter

# Customer retention system
skill majestic-marketing:retention-system
```
