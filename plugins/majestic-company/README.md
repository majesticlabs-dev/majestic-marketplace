# Majestic Company

Business operations tools. Includes 4 specialized agents and 21 skills.

## Installation

```bash
claude /plugin install majestic-company
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Identify my blind spots | `agent mj:blind-spot-analyzer` |
| Validate a business idea | `agent mj:idea-validator` |
| Strategic problem analysis | `agent mj:first-principles` |
| Create interview kit | `agent mj:people-ops` |
| Build a strategic plan | `skill ceo:strategic-planning` |
| Make a business decision | `skill ceo:decision-framework` |
| Design a startup | `skill ceo:startup-blueprint` |
| Launch in 30 days | `skill ceo:30-day-launch` |
| Build financial model | `skill ceo:financial-model` |
| Research competitor pain points | `skill problem-research` |
| Review legal document | `skill legal:document-review` |
| Create elevator pitch | `skill fundraising:elevator-pitch` |

## Agents

Invoke with: `agent mj:<name>`

| Agent | Description |
|-------|-------------|
| `mj:blind-spot-analyzer` | Identify the single most critical blind spot limiting founder/business growth through integrated analysis of thinking patterns and strategic gaps |
| `mj:idea-validator` | Validate startup ideas with real market research - orchestrates problem-research, customer-discovery, competitive-positioning for GO/NO-GO verdict |
| `mj:first-principles` | Strategic thinking using Elon Musk's first-principles methodology |
| `mj:people-ops` | People operations - hiring, onboarding, PTO, performance management |

## Skills

### ceo

Invoke with: `skill majestic-company:ceo:<name>`

| Skill | Description |
|-------|-------------|
| `30-day-launch` | Tactical 30-day business launch with templates and revenue forecasts |
| `ai-advantage` | AI competitive strategies combining research, trends, and sentiment |
| `decision-framework` | First-principles, cost/benefit, and second-order effects analysis |
| `decisions` | Tree of Thoughts business decisions with expert consultants |
| `financial-model` | Revenue projections, unit economics, P&L, and scenario analysis |
| `founder-mode` | Contrarian principles that break conventional management wisdom |
| `future-back` | Reverse-engineer pathway from vision to reality |
| `growth-audit` | 360-degree business audit with 5-10X growth blueprint |
| `industry-pulse` | Real-time pulse check on any industry for operators/investors |
| `industry-research` | Research market, identify pain, design venture for 12-month capture |
| `market-expansion` | Strategic expansion analysis with financial projections |
| `pareto` | Identify the vital 20% that produces 80% of results |
| `pricing-strategy` | Competitor pricing analysis with optimal structure roadmap |
| `startup-blueprint` | Interactive 10-phase startup planning tailored to your profile |
| `strategic-planning` | One-page strategic briefs with objective, milestones, and risks |

### fundraising

Invoke with: `skill majestic-company:fundraising:<name>`

| Skill | Description |
|-------|-------------|
| `elevator-pitch` | 30/60/90-second pitches with Villain-Hero storytelling |
| `funding-ask-optimizer` | Compelling asks with comparables and milestone roadmaps |
| `objection-destroyer` | 45-second pitch closings with FOMO triggers |
| `tam-calculator` | TAM/SAM/SOM with top-down, bottom-up, and value-theory approaches |

### legal

Invoke with: `skill majestic-company:legal:<name>`

| Skill | Description |
|-------|-------------|
| `document-review` | Legal document analysis with specific replacement text |

### research

Invoke with: `skill majestic-company:<name>`

| Skill | Description |
|-------|-------------|
| `problem-research` | Competitor pain points from G2, Capterra, Reddit with viability assessment |

## Choosing Between startup-blueprint and 30-day-launch

| Use startup-blueprint when... | Use 30-day-launch when... |
|------------------------------|--------------------------|
| You're exploring business ideas | You already know your business type |
| You want comprehensive planning | You want to launch in 30 days |
| You need product-market fit validation | You need execution templates |
| You're building something new | You're launching a proven model |

**startup-blueprint** = "What should I build and how should I plan it?"
**30-day-launch** = "I know what I'm building, help me launch it fast."

## Usage Examples

### Blind Spot Analysis

```bash
# General self-assessment
agent majestic-company:blind-spot-analyzer "Help me identify what I'm missing"

# After a setback
agent majestic-company:blind-spot-analyzer "We lost our biggest customer and I don't understand why"

# Pre-fundraise check
agent majestic-company:blind-spot-analyzer "I'm about to raise - what am I not seeing?"

# Growth plateau
agent majestic-company:blind-spot-analyzer "Stuck at $50K MRR for 8 months - what am I avoiding?"
```

### Idea Validation

```bash
# Quick validation of a business idea
agent majestic-company:idea-validator "AI tool that summarizes meeting notes for sales teams"

# With more context
agent majestic-company:idea-validator "I want to build a project management tool for marketing agencies. I've worked at 3 agencies."

# Specific question
agent majestic-company:idea-validator "Should I build a Notion competitor for developers?"
```

### First-Principles Thinking

```bash
# Strategic problem analysis
agent majestic-company:first-principles "My business is plateauing at $1M ARR"

# Decision making
agent majestic-company:first-principles "Should I pivot from B2C to B2B?"

# Product prioritization
agent majestic-company:first-principles "My product roadmap has 50 items - help me cut 90%"
```

### People Operations

```bash
# Create a structured interview kit
agent majestic-company:people-ops "Create interview kit for Senior Engineer in California"

# Draft a PTO policy
agent majestic-company:people-ops "Draft accrual-based PTO policy for 50-person company"

# Generate onboarding plan
agent majestic-company:people-ops "Create 30/60/90 onboarding plan for remote Product Manager"
```

### CEO Skills

```bash
# Build a strategic plan
skill majestic-company:ceo:strategic-planning

# Walk through a decision
skill majestic-company:ceo:decision-framework

# Get industry pulse check
skill majestic-company:ceo:industry-pulse

# Comprehensive growth audit
skill majestic-company:ceo:growth-audit

# Research a market and design a venture
skill majestic-company:ceo:industry-research

# Develop AI competitive strategy
skill majestic-company:ceo:ai-advantage

# Identify your vital 20%
skill majestic-company:ceo:pareto

# Create a future back plan
skill majestic-company:ceo:future-back

# Get structured decision analysis
skill majestic-company:ceo:decisions

# Analyze market expansion opportunity
skill majestic-company:ceo:market-expansion

# Build a financial model
skill majestic-company:ceo:financial-model

# Start interactive startup planning
skill majestic-company:ceo:startup-blueprint

# Start tactical launch planning
skill majestic-company:ceo:30-day-launch
```

### Research & Legal

```bash
# Research competitor pain points
skill majestic-company:problem-research "Project management software for marketing teams"

# Review a legal document
skill majestic-company:legal:document-review
```

### Fundraising

```bash
# Create elevator pitch
skill majestic-company:fundraising:elevator-pitch

# Calculate TAM/SAM/SOM
skill majestic-company:fundraising:tam-calculator

# Craft funding ask
skill majestic-company:fundraising:funding-ask-optimizer

# Create pitch closing
skill majestic-company:fundraising:objection-destroyer
```

## Blind-Spot-Analyzer Capabilities

The blind-spot-analyzer agent uses structured intake questions to surface the ONE most critical blind spot:

- **Founder Psychology** - Optimism bias, sunk cost attachment, identity-business fusion, fear-driven avoidance, expertise trap
- **Strategic Gaps** - Market timing blindness, competition underestimation, customer misunderstanding, premature scaling, metric misdirection

Output includes diagnosis with evidence from your own words, consequences analysis, and highest-leverage prescription.

## Idea-Validator Capabilities

The idea-validator agent orchestrates real research tools for evidence-based validation:

- **Problem Validation** - Uses `problem-research` to find real pain points from G2/Capterra/Reddit
- **Customer Discovery** - Uses `customer-discovery` to find where customers talk and their language
- **Market Sizing** - Uses `market-research` and `tam-calculator` for TAM/SAM/SOM
- **Competitive Positioning** - Uses `competitive-positioning` to find differentiation opportunities
- **Synthesis** - Delivers GO / PROCEED WITH CAUTION / PIVOT / NO-GO verdict

Three validation depths: Quick (10-15 min), Standard (20-30 min), Full (45-60 min).

## First-Principles Capabilities

The first-principles agent uses 15 strategic prompts organized into 6 categories:

- **Foundation** - Strip problems to objective reality, challenge assumptions
- **Ideal State** - Envision optimal solutions, apply brutal prioritization
- **Risk Analysis** - Pre-mortem failure analysis, challenge industry norms
- **Breakthrough** - Find minimum viable breakthrough, clean slate thinking
- **Constraints & Politics** - Identify hidden constraints, remove social friction
- **Scale & Leverage** - 10x acceleration, design for millions, highest-leverage actions

## People-Ops Capabilities

- **Hiring & Recruiting** - Job descriptions, interview kits, candidate communication
- **Onboarding & Offboarding** - 30/60/90 plans, IT checklists, exit interviews
- **PTO & Leave** - Accrual/grant-based policies, jurisdiction-aware templates
- **Performance Management** - Competency matrices, SMART goals, PIP templates
- **Employee Relations** - Investigation templates, documentation standards

## Important Notes

- **Not legal advice** - Consult qualified counsel before implementing policies
- **Jurisdiction-aware** - Agents ask for location to provide appropriate guidance
- **Compliance-focused** - Templates follow labor law best practices
