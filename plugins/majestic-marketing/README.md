# Majestic Marketing

Marketing and SEO tools for Claude Code. Includes 13 specialized agents, 2 commands, and 10 skills.

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

- **13 Specialized Agents** - Cover the full SEO/GEO workflow
- **E-E-A-T Optimization** - Build authority and trust signals
- **AI Citation Ready** - Optimize for LLM visibility
- **Featured Snippets** - Format content for position zero
- **Schema Markup** - Structured data implementation
- **Content Audits** - Comprehensive quality assessment
