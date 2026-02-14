# Majestic Company

Business operations tools. Includes 17 specialized agents and 16 skills.

## Installation

```bash
claude /plugin install majestic-company
```

## Getting Started

Run `/majestic-company:start` — the orchestrator asks qualifying questions and routes you to the right skill or agent.

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Don't know where to start | `/majestic-company:start` |
| Identify my blind spots | `agent blind-spot-analyzer` |
| Validate a business idea | `agent idea-validator` |
| Research competitor pain points | `agent problem-research` |
| Create interview kit | `agent people-ops` |
| Conduct industry research | `agent ceo:industry-research` |
| Build a financial model | `agent ceo:financial-model` |
| Design a startup | `agent ceo:startup-blueprint` |
| Launch in 30 days | `agent ceo:thirty-day-launch` |
| Create elevator pitch | `agent fundraising:elevator-pitch` |
| Calculate TAM/SAM/SOM | `agent fundraising:tam-calculator` |
| Get bootstrapped finance guidance | `skill bootstrapped-cfo` |
| Make a business decision | `skill decision-framework` |
| Strategic problem analysis | `skill first-principles` |
| Validate product-market fit | `skill pmf-validation` |
| Review legal document | `skill document-review` |

## Agents

### Core Agents

Invoke with: `agent majestic-company:<name>`

| Agent | Description |
|-------|-------------|
| `blind-spot-analyzer` | Identify the single most critical blind spot limiting founder/business growth |
| `idea-validator` | Validate startup ideas with real market research for GO/NO-GO verdict |
| `people-ops` | People operations - hiring, onboarding, PTO, performance management |
| `problem-research` | Research competitor pain points from G2, Capterra, Reddit with viability assessment |

### CEO Agents

Invoke with: `agent majestic-company:ceo:<name>`

| Agent | Description |
|-------|-------------|
| `ai-advantage` | AI competitive strategies combining research, trends, and sentiment analysis |
| `decisions` | Tree of Thoughts business decisions with expert consultant panel |
| `financial-model` | Revenue projections, unit economics, P&L, and scenario analysis |
| `future-back` | Reverse-engineer pathway from vision to reality using backward planning |
| `growth-audit` | 360-degree business audit with 0-10 scoring and 90-day roadmap |
| `industry-research` | Research market, identify pain, design venture for 12-month capture |
| `market-expansion` | Strategic expansion analysis with quantified decision trees |
| `pricing-strategy` | Competitor pricing analysis with psychological thresholds and implementation roadmap |
| `startup-blueprint` | Interactive 10-phase startup planning tailored to your profile |
| `thirty-day-launch` | Tactical 30-day business launch with templates and revenue forecasts |

### Fundraising Agents

Invoke with: `agent majestic-company:fundraising:<name>`

| Agent | Description |
|-------|-------------|
| `elevator-pitch` | 30/60/90-second pitches with Villain-Hero storytelling framework |
| `funding-ask-optimizer` | Compelling funding asks with comparables and milestone roadmaps |
| `tam-calculator` | TAM/SAM/SOM with top-down, bottom-up, and value-theory approaches |

## Skills

Invoke with: `skill majestic-company:<name>`

| Skill | Category | Description |
|-------|----------|-------------|
| `first-principles` | Thinking | 15 strategic prompts for first-principles thinking |
| `decision-framework` | Thinking | First-principles, cost/benefit, and second-order effects analysis |
| `pm-discovery` | Product | Product management discovery techniques |
| `pm-prioritization` | Product | RICE/ICE scoring, opportunity solution trees |
| `pm-jobs-to-be-done` | Product | Understand why customers "hire" your solution |
| `pm-customer-interviews` | Product | Interview question banks and synthesis templates |
| `pm-assumption-mapping` | Product | Validate product hypotheses systematically |
| `pmf-validation` | Product | Validate product-market fit through assumption testing and MVP |
| `idea-generation` | Strategy | Generate and validate startup ideas through market research |
| `industry-pulse` | Strategy | Real-time pulse check on any industry for operators/investors |
| `strategic-planning` | Strategy | One-page strategic briefs with objective, milestones, and risks |
| `omtm-growth` | Growth | One Metric That Matters growth framework |
| `bootstrapped-cfo` | Finance | Financial frameworks for self-funded companies (unit economics, runway, hiring ROI) |
| `objection-destroyer` | Fundraising | 45-second pitch closings with FOMO triggers |
| `launch-legal` | Legal | Minimum viable legal setup for business launches |
| `document-review` | Legal | Legal document analysis with specific replacement text |

## Choosing Between startup-blueprint and thirty-day-launch

| Use startup-blueprint when... | Use thirty-day-launch when... |
|------------------------------|--------------------------|
| You're exploring business ideas | You already know your business type |
| You want comprehensive planning | You want to launch in 30 days |
| You need product-market fit validation | You need execution templates |
| You're building something new | You're launching a proven model |

**startup-blueprint** = "What should I build and how should I plan it?"
**thirty-day-launch** = "I know what I'm building, help me launch it fast."

## Usage Examples

### Blind Spot Analysis

```bash
# General self-assessment
agent majestic-company:blind-spot-analyzer "Help me identify what I'm missing"

# After a setback
agent majestic-company:blind-spot-analyzer "We lost our biggest customer and I don't understand why"

# Pre-fundraise check
agent majestic-company:blind-spot-analyzer "I'm about to raise - what am I not seeing?"
```

### Idea Validation

```bash
# Quick validation of a business idea
agent majestic-company:idea-validator "AI tool that summarizes meeting notes for sales teams"

# With more context
agent majestic-company:idea-validator "I want to build a project management tool for marketing agencies"
```

### CEO Agents

```bash
# Research a market and design a venture
agent majestic-company:ceo:industry-research "Healthcare tech"

# Comprehensive growth audit
agent majestic-company:ceo:growth-audit

# Get structured decision analysis with Tree of Thoughts
agent majestic-company:ceo:decisions

# Analyze market expansion opportunity
agent majestic-company:ceo:market-expansion

# Build a financial model
agent majestic-company:ceo:financial-model

# Start interactive startup planning
agent majestic-company:ceo:startup-blueprint

# Start tactical launch planning
agent majestic-company:ceo:thirty-day-launch
```

### Fundraising Agents

```bash
# Create elevator pitch with Villain-Hero framework
agent majestic-company:fundraising:elevator-pitch

# Calculate TAM/SAM/SOM
agent majestic-company:fundraising:tam-calculator

# Craft compelling funding ask
agent majestic-company:fundraising:funding-ask-optimizer
```

### Skills

```bash
# Walk through a decision
skill majestic-company:decision-framework

# First-principles thinking
skill majestic-company:first-principles

# Review a legal document
skill majestic-company:document-review

# Validate product-market fit
skill majestic-company:pmf-validation
```

## Key Capabilities

### Problem Research Agent
Research competitor pain points from review platforms to identify market opportunities:
- Analyzes G2, Capterra, TrustRadius, Reddit reviews
- Calculates Pain Point Scores (PPS) for ranking opportunities
- Delivers GO / PROCEED WITH CAUTION / RECONSIDER / NO-GO verdicts

### Blind-Spot-Analyzer Agent
Surfaces the ONE most critical blind spot through structured intake:
- **Founder Psychology** - Optimism bias, sunk cost attachment, identity-business fusion
- **Strategic Gaps** - Market timing blindness, competition underestimation, customer misunderstanding

### Growth Audit Agent
Evidence-backed 360-degree audit with:
- 0-10 scoring across 6 dimensions
- Benchmarking vs winners/laggards
- Bottleneck prioritization by impact x ease
- Week-by-week 90-day roadmap

### Elevator Pitch Agent
Creates word-for-word scripts using Villain-Hero framework:
- Investor-customized versions (Technical, Market, Customer-focused)
- Length variations (10s, 30s, 60s, 90s)
- Psychological hooks library
- Delivery coaching

## Important Notes

- **Not legal advice** - Consult qualified counsel before implementing policies
- **Jurisdiction-aware** - Agents ask for location to provide appropriate guidance
- **Tool-using agents** - CEO and Fundraising agents use WebSearch, AskUserQuestion, and other tools
