---
name: sales-playbook
description: Create comprehensive sales playbooks with discovery frameworks, objection handling, competitive positioning, demo scripts, and closing techniques for B2B sales teams.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# Sales Playbook Builder

**Audience:** B2B sales teams needing battle-tested playbooks
**Goal:** Deliver copy-ready sales playbook tailored to their specific selling motion

## Conversation Starter

Use `AskUserQuestion` to gather context:

1. **Product/Service**: What do you sell? (Features, pricing model, typical deal size)
2. **Target Buyer**: Who makes the buying decision? (Title, company profile)
3. **Sales Cycle**: How long is your typical deal? (Days/weeks/months)
4. **Main Competitors**: Who do you lose deals to? (Top 2-3 competitors)
5. **Win/Loss Patterns**: Why do you win? Why do you lose?
6. **Current Process**: What does your sales process look like today?

## Research Methodology

Use WebSearch for:
- Competitor positioning, pricing, weaknesses (G2, Capterra, Reddit)
- Industry-specific sales benchmarks and conversion rates
- Common objections for their space
- Buyer journey patterns for their ICP

## Playbook Components

Build each section using resource templates:

| Component | Resource |
|-----------|----------|
| Sales Process Map | [resources/sales-process.yaml](resources/sales-process.yaml) |
| Qualification (BANT+) | [resources/qualification-framework.yaml](resources/qualification-framework.yaml) |
| Discovery Calls | [resources/discovery-framework.yaml](resources/discovery-framework.yaml) |
| Demo Framework | [resources/demo-framework.yaml](resources/demo-framework.yaml) |
| Objection Handling | [resources/objection-handling.yaml](resources/objection-handling.yaml) |
| Battle Cards | [resources/battle-cards.yaml](resources/battle-cards.yaml) |
| Closing Techniques | [resources/closing-techniques.yaml](resources/closing-techniques.yaml) |
| Follow-up Templates | [resources/follow-up-templates.yaml](resources/follow-up-templates.yaml) |

## Output Format

```markdown
# SALES PLAYBOOK: [Company Name]

## Executive Summary
[2-3 sentences on sales motion and key differentiators]

## Sales Process Map
[Stage table with entry/exit criteria from sales-process.yaml]

## Qualification Framework
[BANT+ scoring from qualification-framework.yaml]

## Discovery Call Framework
[From discovery-framework.yaml]

## Demo Framework
[From demo-framework.yaml]

## Objection Handling
[Top objections from objection-handling.yaml]

## Competitive Battle Cards
[From battle-cards.yaml, one per competitor]

## Closing Techniques
[From closing-techniques.yaml]

## Stakeholder Mapping
[From sales-process.yaml stakeholder section]

## Implementation Checklist
[ ] Week 1: Role-play discovery calls
[ ] Week 2: Practice demo flow, memorize top 5 objections
[ ] Week 3: Study competitive battle cards
[ ] Week 4: Shadow live calls
```

## Quality Standards

- **Research competitors**: G2/Capterra reviews, Reddit complaints
- **Copy-ready scripts**: Every talk track ready to use
- **Situation-specific**: Tailored to their sales cycle, deal size, buyer persona
- **Measurable**: Include benchmarks and scoring criteria

## Tone

Direct and actionable. Write like a VP Sales who has closed millions in deals. No fluff.
