# Majestic Marketing

Marketing and SEO tools for Claude Code. Includes 14 specialized agents, 2 commands, and 30 skills.

## Installation

```bash
claude /plugin install majestic-marketing
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Quick SEO audit | `/majestic-marketing:workflows:seo-audit` |
| Comprehensive content check | `/majestic-marketing:workflows:content-check` |
| Optimize for AI citation | `agent seo:llm-optimizer` |
| Build brand authority | `agent seo:authority-builder` |
| Generate brand names | `agent branding:namer` |
| Create sales page | `skill sales-page` |
| Design email nurture | `skill email-nurture` |
| Build content calendar | `skill content-calendar` |

## Agents

### branding

Invoke with: `agent majestic-marketing:branding:<name>`

| Agent | Description |
|-------|-------------|
| `branding:namer` | Generate category-defining brand, company, and product names using Igor naming methodology |

### seo

Invoke with: `agent majestic-marketing:seo:<name>`

#### Traditional SEO

| Agent | Description |
|-------|-------------|
| `seo:authority-builder` | E-E-A-T analysis and authority signal optimization |
| `seo:cannibalization-detector` | Keyword overlap and conflict detection |
| `seo:content-auditor` | Content quality and SEO best practices audit |
| `seo:content-planner` | Topic clusters and content calendar planning |
| `seo:content-refresher` | Identify outdated content and suggest updates |
| `seo:content-writer` | SEO-optimized content creation |
| `seo:keyword-strategist` | Keyword density, LSI, semantic optimization |
| `seo:meta-optimizer` | Meta titles, descriptions, URL optimization |
| `seo:snippet-hunter` | Featured snippet and SERP feature optimization |
| `seo:structure-architect` | Header hierarchy, schema, internal linking |

#### GEO (AI Visibility)

| Agent | Description |
|-------|-------------|
| `seo:entity-builder` | Brand entity and triplet optimization for LLM presence |
| `seo:llm-optimizer` | Optimize content for AI citation (ChatGPT, Perplexity, Gemini) |
| `seo:schema-architect` | Schema.org and llms.txt implementation for AI extraction |

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
| `content-calendar` | 30-day content calendar with viral ideas, formats, hooks, and CTAs |
| `content-optimizer` | Content optimization workflow for search and AI |
| `content-writer` | Articles with outline-first workflow and readability guidelines |
| `copy-editor` | Review and edit copy for grammar, style, and clarity |
| `hook-writer` | Attention-grabbing hooks from 5 investor archetype perspectives |
| `linkedin-content` | LinkedIn content with hooks, pillars, and posting strategy |
| `power-words` | Enhance copy with emotional trigger words from 18 categories |
| `seo-audit` | Comprehensive SEO and GEO audit methodology |
| `slogan-generator` | Marketing slogans with scoring and recommendations |
| `viral-content` | Viral content frameworks with platform-specific patterns |

### Marketing & Strategy

| Skill | Description |
|-------|-------------|
| `bofu-keywords` | Bottom-of-funnel keywords with high purchase intent |
| `customer-discovery` | Find where customers discuss problems, extract language |
| `free-tool-arsenal` | Complete business tech stack with 100% free tools |
| `irresistible-offer` | Craft offers using direct response marketing principles |
| `landing-page-builder` | Structured landing page copy (simpler than sales-page) |
| `market-research` | Comprehensive research with web data and competitive analysis |
| `marketing-strategy` | Interactive interview to build custom strategy with JSON export |
| `sales-page` | High-converting templates with headline formulas and CTA psychology |
| `traffic-magnet` | Organic traffic and customer acquisition with zero ad spend |
| `value-prop-sharpener` | Refine value propositions into 15-word statements |

### Sales & Acquisition

| Skill | Description |
|-------|-------------|
| `case-study-writer` | Customer case studies for marketing and sales enablement |
| `google-ads-strategy` | Google Ads campaigns with keyword strategy and budget allocation |
| `icp-discovery` | Ideal Customer Profile with firmographics and scoring matrices |
| `outbound-sequences` | Cold outreach sequences for email and LinkedIn |
| `proposal-writer` | Sales proposals with scope, pricing, and ROI justification |
| `sales-playbook` | Discovery frameworks, objection handling, closing techniques |

### Retention & Growth

| Skill | Description |
|-------|-------------|
| `email-nurture` | Automated email sequences with segmentation and triggers |
| `referral-program` | Viral referral programs with incentive structures |
| `retention-system` | Customer retention with health scoring and churn prediction |
| `win-back` | Win-back campaigns to re-engage dormant customers |

## SEO vs GEO

This plugin covers both traditional SEO and modern GEO (Generative Engine Optimization):

| Aspect | Traditional SEO | GEO Focus |
|--------|-----------------|-----------|
| Goal | Rank in search results | Get cited in AI responses |
| Focus | Keywords + backlinks | Semantic depth + fact-density |
| Structure | Readable by humans | Extractable by AI |
| Authority | Domain authority | Citation quality + source reputation |

The GEO-focused agents (`llm-optimizer`, `entity-builder`, `schema-architect`) help ensure your content appears in AI-generated answers from ChatGPT, Perplexity, Gemini, and other LLMs.

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
# Full SEO audit methodology
skill majestic-marketing:seo-audit

# Content optimization workflow
skill majestic-marketing:content-optimizer

# 30-day content calendar
skill majestic-marketing:content-calendar

# Write articles with outline-first workflow
skill majestic-marketing:content-writer

# Enhance copy with emotional trigger words
skill majestic-marketing:power-words
```

### Marketing & Strategy Skills

```bash
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

### Sales & Acquisition Skills

```bash
# Define your Ideal Customer Profile
skill majestic-marketing:icp-discovery

# Cold outreach sequences
skill majestic-marketing:outbound-sequences

# Sales playbook with objection handling
skill majestic-marketing:sales-playbook

# Create winning proposals
skill majestic-marketing:proposal-writer

# Google Ads campaign strategy
skill majestic-marketing:google-ads-strategy
```

### Retention & Growth Skills

```bash
# Email nurture sequences
skill majestic-marketing:email-nurture

# Customer retention system
skill majestic-marketing:retention-system

# Viral referral program design
skill majestic-marketing:referral-program

# Win-back campaigns
skill majestic-marketing:win-back

# Customer case studies
skill majestic-marketing:case-study-writer
```
