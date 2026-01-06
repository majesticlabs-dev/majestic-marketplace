---
name: customer-expansion
description: Create expansion roadmaps, QBR templates, and upsell playbooks to grow existing customer revenue through strategic account development.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# Customer Expansion Playbook Builder

**Audience:** Customer Success and Account Management teams responsible for net revenue retention and expansion revenue.

**Goal:** Create expansion roadmaps, QBR templates with upsell hooks, and conversation frameworks that surface upgrade opportunities naturally.

## Conversation Starter

Use `AskUserQuestion` to gather initial context. Begin by asking:

"I'll help you create an expansion playbook to grow revenue from existing customers.

Please provide:

1. **Product/Service**: What do you sell? What are your upsell/expansion tiers?
2. **Current Customers**: How many? What's average contract value?
3. **Expansion Opportunities**: Additional seats? Higher tiers? Add-on products?
4. **Success Metrics**: How do you measure customer health/success?
5. **Current Process**: Do you have QBRs? Who owns expansion?

I'll create expansion roadmaps and playbooks tailored to your model."

## Required Deliverables

### 1. Expansion Roadmap Template

| Month | Phase | Activities |
|-------|-------|------------|
| 1-2 | Foundation | Complete onboarding, establish metrics, identify champions |
| 3-4 | Value Realization | First QBR with ROI data, introduce expansion options |
| 5-6 | Expansion Close | Formal proposal, negotiate, close |

**Roadmap Components:**
- Current state snapshot (contract value, tier, seats, health score)
- Expansion opportunities with triggers, value, timeline, owner
- Monthly milestones with specific deliverables

### 2. QBR Template with Expansion Hooks

See [resources/qbr-conversations.yaml](resources/qbr-conversations.yaml) for complete template.

**QBR Agenda (45-60 min):**

| Section | Duration | Purpose |
|---------|----------|---------|
| Success Metrics | 15 min | Goals vs results, usage stats, ROI summary |
| Roadmap & New | 10 min | New features with expansion hooks |
| Challenges | 15 min | Questions to surface expansion opportunities |
| Next Quarter | 10 min | Action items + expansion discussion |

### 3. Expansion Conversation Framework

See [resources/qbr-conversations.yaml](resources/qbr-conversations.yaml) for email templates and objection handling.

**Trigger Types:**

| Trigger | Signal | Outreach |
|---------|--------|----------|
| Usage | At seat limit | Add seats email |
| Behavior | Power user identified | Upgrade email |
| Time | Mid-contract | Check-in email |

**Common Objections:**
- "No budget" → Plan for budget cycle, pro-rate option
- "Not using what we have" → Solve adoption first
- "Discuss at renewal" → Document for later, send proposal anyway

### 4. Account Health Scoring

| Factor | Weight | Green (3) | Yellow (2) | Red (1) |
|--------|--------|-----------|------------|---------|
| Usage | 25% | >80% DAU | 50-80% DAU | <50% DAU |
| Engagement | 20% | <24h response | <72h response | Ghosting |
| NPS/CSAT | 15% | 9-10 | 7-8 | <7 |
| Support tickets | 15% | <2/month | 2-5/month | >5/month |
| Champion status | 15% | Active advocate | Passive | None |
| Expansion signals | 10% | Asking for more | Open to discuss | Not interested |

**Expansion Readiness:**
- **Green Light**: Usage at capacity, champion engaged, ROI documented, team growing
- **Yellow Light**: Usage growing, satisfied not enthusiastic, ROI unclear
- **Red Light**: Declining usage, unresolved issues, champion left

### 5. Expansion Proposal Template

```markdown
## EXPANSION PROPOSAL: [Customer Name]

### Executive Summary
Based on [trigger], we recommend [expansion type].
- **Current:** [Tier/Seats/Value]
- **Proposed:** [New Tier/Seats/Value]
- **Additional Investment:** $[X]/year

### Why Now
- [Trigger: usage at capacity, new team, mentioned need]
- [ROI achieved: $X saved, Y hours recovered]
- [Timeline benefit before renewal]

### What You Get
| Current | Proposed | Benefit |
|---------|----------|---------|
| [Feature] | [Upgrade] | [Outcome] |

### Investment Options
| Option | Monthly | Annual | Savings |
|--------|---------|--------|---------|
| Month-to-month | $[X] | $[Y] | — |
| Annual prepay | $[X-10%] | $[Y-10%] | 10% |

### Next Steps
1. Review proposal
2. 15-min call: [Calendar link]
3. Sign amendment
4. Implementation in [X] days
```

## Output Format

```markdown
# CUSTOMER EXPANSION PLAYBOOK: [Company Name]

## SECTION 1: Expansion Roadmap Template
[6-month milestone plan]

## SECTION 2: QBR Template
[Quarterly review with expansion hooks]

## SECTION 3: Expansion Conversations
[Trigger emails and objection handling]

## SECTION 4: Health Scoring
[Account health indicators]

## SECTION 5: Expansion Proposal Template
[Ready-to-customize proposal]

## IMPLEMENTATION CHECKLIST
[ ] Set up usage alerts for expansion triggers
[ ] Schedule QBRs with top 20% of accounts
[ ] Identify expansion-ready accounts this quarter
[ ] Train CSMs on expansion conversations
```

## Quality Standards

- **Trigger-based**: Every outreach tied to specific data point
- **Template-ready**: Copy/paste emails with variables
- **ROI-focused**: Tie expansion to documented value
- **Non-pushy**: Expansion as natural next step, not hard sell
