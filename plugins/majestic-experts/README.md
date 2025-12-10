# majestic-experts

Expert panel discussion system for Claude Code. Assemble panels of thought leaders to explore difficult questions from multiple perspectives.

## Overview

This plugin provides:
- **1 command**: `/expert-panel` - Lead structured expert discussions
- **2 agents**: Panel orchestrator and expert perspective simulator
- **22 curated expert personas** across 5 categories:
  - **Engineering** (6): DHH, Martin Fowler, Kent Beck, Uncle Bob, Sandi Metz, Rich Hickey
  - **Business** (7): Seth Godin, Peter Thiel, Naval Ravikant, Jason Fried, Paul Graham, April Dunford, Rand Fishkin
  - **Product** (4): Ryan Singer, Julie Zhuo, Marty Cagan, Alan Cooper
  - **Pricing** (3): Patrick Campbell, Rob Walling, Josh Pigford
  - **Security** (2): Troy Hunt, Tanya Janca

## Installation

```bash
claude /plugin install majestic-experts
```

## Usage

```bash
# Start new discussion
/expert-panel Should we migrate from monolith to microservices?
/expert-panel What's the best authentication strategy for our SaaS app?

# Resume saved discussion
/expert-panel --resume 20251209-150000-microservices-migration

# List saved sessions
/expert-panel --list

# Export to markdown
/expert-panel --export 20251209-150000-microservices-migration
```

### Discussion Types

- **round-table** - Single round, each expert shares perspective (5-10 min)
- **debate** - Two opposing camps with rebuttals (10-20 min)
- **consensus-seeking** - Iterate until agreement or impasse (10-30 min)
- **deep-dive** - Three rounds of sequential exploration (20-40 min)

### Configuration (.agents.yml)

Control which experts are available per project:

```yaml
# .agents.yml
expert_panel:
  # Enable only specific categories
  enabled_categories:
    - engineering
    - product

  # OR disable specific categories
  disabled_categories:
    - business

  # Disable individual experts
  disabled_experts:
    - peter-thiel
    - uncle-bob

  # Add custom experts from your project
  custom_experts_path: "docs/experts/"
```

**Resolution Logic:**
1. If `enabled_categories` specified → only those categories
2. Apply `disabled_categories` → remove those
3. Apply `disabled_experts` → remove individuals
4. Merge `custom_experts_path` if specified
5. Default: all experts enabled

## Expert Definition Format

Each expert is defined in a Markdown file with YAML frontmatter:

```markdown
---
name: expert-name
display_name: "Display Name"
full_name: "Full Legal Name"
credentials: "Brief credentials"
category: engineering
subcategories:
  - architecture
  - testing
keywords:
  - keyword1
  - keyword2
---

## Philosophy

Their core beliefs and approach...

## Communication Style

- **Tone:** How they communicate
- **Formality:** Level of formality
- **Sentence length:** Typical patterns

## Known Positions

### On Topic 1
- **Position:** Explanation

## Key Phrases

- "Phrase they're known for"

## Context for Responses

When embodying this expert:
1. Guideline 1
2. Guideline 2

## Famous Works

- Work 1
- Work 2

## Debate Tendencies

- How they behave in discussions
```

## Adding Custom Experts

Create expert files in your project:

```
docs/experts/
├── your-expert.md
└── another-expert.md
```

Configure in `.agents.yml`:

```yaml
expert_panel:
  custom_experts_path: "docs/experts/"
```

Custom experts automatically merge with library experts.

## Expert Categories

### Engineering

| Expert | Subcategories | Known For |
|--------|--------------|-----------|
| DHH | rails, architecture, testing, frontend | Rails, Majestic Monolith |
| Martin Fowler | architecture, refactoring, patterns | Refactoring, Enterprise Patterns |
| Kent Beck | tdd, xp, agile, design | TDD, XP, JUnit |
| Uncle Bob | clean-code, solid, architecture | Clean Code, SOLID |
| Sandi Metz | oo-design, ruby, refactoring | POODR, 99 Bottles |
| Rich Hickey | functional, simplicity, state | Clojure, Simple Made Easy |

### Business

| Expert | Subcategories | Known For |
|--------|--------------|-----------|
| Seth Godin | marketing, branding, content | Purple Cow, Permission Marketing |
| Peter Thiel | startups, strategy, contrarian | Zero to One, PayPal |
| Naval Ravikant | leverage, philosophy, investing | AngelList, Wealth/Happiness |
| Jason Fried | bootstrapping, calm, remote | Basecamp, REWORK |
| Paul Graham | startups, essays, yc | Y Combinator, Essays |
| April Dunford | positioning, b2b, marketing | Obviously Awesome |
| Rand Fishkin | seo, content, marketing | SparkToro, Moz |

### Product

| Expert | Subcategories | Known For |
|--------|--------------|-----------|
| Ryan Singer | shaping, appetite, cycles | Shape Up, Basecamp |
| Julie Zhuo | design, management, leadership | Making of a Manager, Facebook |
| Marty Cagan | product-management, teams, discovery | Inspired, SVPG |
| Alan Cooper | interaction-design, ux, personas | Visual Basic, About Face |

### Pricing & Monetization

| Expert | Subcategories | Known For |
|--------|--------------|-----------|
| Patrick Campbell | pricing, saas, monetization | ProfitWell, Pricing Strategy |
| Rob Walling | saas, bootstrapping, startups | TinySeed, MicroConf |
| Josh Pigford | metrics, bootstrapping, transparency | Baremetrics, Open Startup |

### Security

| Expert | Subcategories | Known For |
|--------|--------------|-----------|
| Troy Hunt | web-security, breaches, education | Have I Been Pwned |
| Tanya Janca | appsec, devsecops, training | We Hack Purple |

## Integration

This plugin is self-contained with:
- `/majestic-experts:expert-panel` command for starting discussions
- `majestic-experts:expert-panel-discussion` orchestrator agent
- `majestic-experts:expert-perspective` panelist agent

The expert panel system reads the `_registry.yml` for fast expert discovery, then loads full definitions on demand.

## File Structure

```
plugins/majestic-experts/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── expert-panel-discussion.md
│   └── expert-perspective.md
├── commands/
│   └── expert-panel.md
├── experts/
│   ├── registry.yml           # Fast lookup index
│   ├── engineering/
│   │   ├── dhh.md
│   │   ├── martin-fowler.md
│   │   ├── kent-beck.md
│   │   ├── uncle-bob.md
│   │   ├── sandi-metz.md
│   │   └── rich-hickey.md
│   ├── business/
│   │   ├── seth-godin.md
│   │   ├── peter-thiel.md
│   │   ├── naval-ravikant.md
│   │   ├── jason-fried.md
│   │   ├── paul-graham.md
│   │   ├── april-dunford.md
│   │   └── rand-fishkin.md
│   ├── product/
│   │   ├── ryan-singer.md
│   │   ├── julie-zhuo.md
│   │   ├── marty-cagan.md
│   │   └── alan-cooper.md
│   ├── pricing/
│   │   ├── patrick-campbell.md
│   │   ├── rob-walling.md
│   │   └── josh-pigford.md
│   └── security/
│       ├── troy-hunt.md
│       └── tanya-janca.md
├── README.md
└── CHANGELOG.md
```

## License

Part of the Majestic Marketplace. See repository LICENSE for details.
