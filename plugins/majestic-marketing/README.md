# Majestic Marketing

Marketing and SEO tools for Claude Code. Includes 14 specialized agents, 2 commands, and 28 skills.

## Installation

```bash
claude /plugin install majestic-marketing
```

## Agents

All SEO agents use the `seo:` prefix. Invoke with: `agent majestic-marketing:seo:<name>`

### Traditional SEO Agents

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

### GEO (AI Visibility) Agents

| Agent | Description |
|-------|-------------|
| `seo:llm-optimizer` | Optimize content for AI citation (ChatGPT, Perplexity, Gemini) |
| `seo:entity-builder` | Brand entity and triplet optimization for LLM presence |
| `seo:schema-architect` | Schema.org and llms.txt implementation for AI extraction |

### Branding Agents

| Agent | Description |
|-------|-------------|
| `branding:namer` | Generate category-defining brand, company, and product names using Igor naming methodology |

## Commands

| Command | Description |
|---------|-------------|
| `/seo-audit [file]` | Quick SEO audit with actionable recommendations |
| `/content-check [file]` | Comprehensive content check for SEO and AI readability |

## Skills

Invoke with: `skill majestic-marketing:<name>`

| Skill | Description |
|-------|-------------|
| `copy-editor` | Review and edit copy for grammar, style, and clarity |
| `seo-audit` | Comprehensive SEO and GEO audit methodology |
| `content-optimizer` | Content optimization workflow for search and AI |
| `market-research` | Comprehensive market research with web data and competitive analysis |
| `marketing-strategy` | Interactive interview to build a custom marketing strategy with JSON export |
| `traffic-magnet` | Research organic traffic and customer acquisition methods with zero ad spend |
| `irresistible-offer` | Craft irresistible offers using direct response marketing principles |
| `free-tool-arsenal` | Build complete business tech stack with 100% free tools |
| `viral-content` | Create viral content frameworks with platform-specific patterns |
| `sales-page` | High-converting sales page templates with headline formulas and CTA psychology |
| `value-prop-sharpener` | Refine value propositions from emotional, logical, and status angles into 15-word statements |
| `hook-writer` | Generate attention-grabbing hooks from 5 investor archetype perspectives |
| `customer-discovery` | Find where potential customers discuss problems online and extract their language patterns |
| `landing-page-builder` | Generate structured landing page copy - simpler/faster alternative to sales-page |
| `email-nurture` | Design automated email nurture sequences with segmentation and behavioral triggers |
| `retention-system` | Design customer retention systems with health scoring and churn prediction |
| `bofu-keywords` | Find bottom-of-funnel keywords with high purchase intent using Perplexity |
| `referral-program` | Design viral referral programs with incentive structures and viral coefficient optimization |
| `win-back` | Design win-back campaigns to re-engage dormant customers and recover churned users |
| `case-study-writer` | Create compelling customer case studies for marketing and sales enablement |
| `linkedin-content` | Create high-performing LinkedIn content with hooks, content pillars, and posting strategy |
| `slogan-generator` | Generate and evaluate marketing slogans with scoring criteria and top recommendations |
| `content-calendar` | Generate a complete 30-day content calendar with viral ideas, formats, hooks, and CTAs |
| `content-writer` | Write articles with outline-first workflow, sentence variation, and readability guidelines |
| `power-words` | Enhance copy with emotional trigger words from 18 psychological categories |

### Sales & Acquisition Skills

| Skill | Description |
|-------|-------------|
| `outbound-sequences` | Design cold outreach sequences for email and LinkedIn with personalization frameworks and response handling |
| `sales-playbook` | Create sales playbooks with discovery frameworks, objection handling, competitive positioning, and closing techniques |
| `google-ads-strategy` | Build Google Ads campaigns with keyword strategy, ad copy, audience targeting, and budget allocation |

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

### Branding Agents

```bash
# Generate category-defining brand names
agent majestic-marketing:branding:namer
```

### Commands

```bash
# Quick SEO audit
/seo-audit path/to/content.md

# Content quality check
/content-check path/to/article.md
```

### Skills

```bash
# Full SEO audit methodology
skill majestic-marketing:seo-audit

# Content optimization workflow
skill majestic-marketing:content-optimizer

# Copy editing review
skill majestic-marketing:copy-editor

# Market research
skill majestic-marketing:market-research

# Marketing strategy builder
skill majestic-marketing:marketing-strategy

# Organic traffic generation
skill majestic-marketing:traffic-magnet

# Direct response offer creation
skill majestic-marketing:irresistible-offer

# Free business tools research
skill majestic-marketing:free-tool-arsenal

# Viral content frameworks
skill majestic-marketing:viral-content

# High-converting sales pages
skill majestic-marketing:sales-page

# Find where customers hang out online
skill majestic-marketing:customer-discovery

# Quick landing page copy (no research phase)
skill majestic-marketing:landing-page-builder

# Email nurture sequences
skill majestic-marketing:email-nurture

# Customer retention system
skill majestic-marketing:retention-system

# Viral referral program design
skill majestic-marketing:referral-program

# Win-back campaigns for churned users
skill majestic-marketing:win-back

# Customer case studies for social proof
skill majestic-marketing:case-study-writer

# LinkedIn content and posting strategy
skill majestic-marketing:linkedin-content

# Marketing slogans and taglines
skill majestic-marketing:slogan-generator

# 30-day content calendar with viral ideas
skill majestic-marketing:content-calendar

# Write articles with outline-first workflow
skill majestic-marketing:content-writer

# Enhance copy with emotional trigger words
skill majestic-marketing:power-words

# Cold outreach sequences for sales
skill majestic-marketing:outbound-sequences

# Sales playbook with objection handling
skill majestic-marketing:sales-playbook

# Google Ads campaign strategy
skill majestic-marketing:google-ads-strategy
```

## SEO vs GEO

This plugin covers both traditional SEO and modern GEO (Generative Engine Optimization):

| Aspect | Traditional SEO | GEO Focus |
|--------|-----------------|-----------|
| Goal | Rank in search results | Get cited in AI responses |
| Focus | Keywords + backlinks | Semantic depth + fact-density |
| Structure | Readable by humans | Extractable by AI |
| Authority | Domain authority | Citation quality + source reputation |

The GEO-focused agents (`llm-optimizer`, `entity-builder`, `schema-architect`) help ensure your content appears in AI-generated answers from ChatGPT, Perplexity, Gemini, and other LLMs.

## Key Features

- **14 Specialized Agents** - Cover the full SEO/GEO workflow
- **E-E-A-T Optimization** - Build authority and trust signals
- **AI Citation Ready** - Optimize for LLM visibility
- **Featured Snippets** - Format content for position zero
- **Schema Markup** - Structured data implementation
- **Content Audits** - Comprehensive quality assessment
- **Retention Marketing** - Email nurture, referral programs, win-back campaigns
- **Sales Enablement** - Outbound sequences, playbooks, objection handling
- **Paid Acquisition** - Google Ads strategy and campaign planning
