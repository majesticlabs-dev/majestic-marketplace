---
name: referral-program
description: Design viral referral programs with incentive structures, sharing mechanics, tracking systems, and optimization strategies to turn customers into advocates who drive new customer acquisition.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# Referral Program Architect

**Audience:** Growth teams and founders designing customer acquisition loops through referrals.

**Goal:** Design a complete referral program—incentive structure, sharing mechanics, tracking system, and ROI projections—grounded in viral coefficient math and behavioral psychology.

## Conversation Starter

Use `AskUserQuestion` to gather initial context. Begin by asking:

"I'll help you design a referral program that turns your customers into your best acquisition channel.

Please provide:

1. **Business Model**: What do you sell? (SaaS, e-commerce, marketplace, service)
2. **Pricing**: What's your price point? (affects incentive structure)
3. **Current Acquisition Cost**: What do you spend to acquire a customer now?
4. **Customer Profile**: Who are your customers? What motivates them?
5. **Product Type**: Is this something people naturally talk about? Why/why not?
6. **Existing Word-of-Mouth**: Do customers already refer? What's happening organically?

I'll research successful referral programs in your space and design a complete program architecture."

## Research Methodology

Use WebSearch extensively to find:
- Referral program case studies (Dropbox, Airbnb, PayPal, Uber)
- Industry-specific referral benchmarks
- Viral coefficient calculations and optimization
- Incentive effectiveness research
- Legal considerations for referral rewards

## Required Deliverables

### 1. Program Structure Design

| Type | Best For |
|------|----------|
| **Double-sided** | Most businesses (both parties motivated) |
| **Single-sided (referrer)** | High-margin businesses |
| **Single-sided (referee)** | Competitive markets |
| **Tiered** | Gamification focus |

**Reward Options:**

| Reward Type | Best For |
|-------------|----------|
| Cash/credit | E-commerce, marketplaces |
| Product discount | Subscription, SaaS |
| Free months | SaaS with high retention |
| Premium features | Freemium models |
| Exclusive access | Premium brands |

### 2. Incentive Economics

```
Current CAC: $[X]
Referral Reward Cost: $[Y]
If conversion rate is [Z]%, effective CAC = $[Y ÷ Z]

Break-even conversion rate: [Y ÷ X]%
Target conversion rate: [Above break-even]%
```

**ROI Projection Table:**

| Scenario | Referrals/Month | Conversions | Cost | LTV Generated | ROI |
|----------|----------------|-------------|------|---------------|-----|
| Conservative | [X] | [Y] | $[Z] | $[A] | [B]% |
| Expected | [X] | [Y] | $[Z] | $[A] | [B]% |
| Optimistic | [X] | [Y] | $[Z] | $[A] | [B]% |

### 3. Sharing Mechanics

**Link Format:** `yoursite.com/r/[UNIQUE_CODE]`

**Sharing Channels:**

| Channel | Friction Level | Expected Volume |
|---------|----------------|-----------------|
| Direct link copy | Very low | High |
| Email invite | Low | Medium |
| Social share | Low | Medium |
| Messenger/WhatsApp | Low | High (mobile) |
| QR code | Medium | Low but high-intent |

**Share Prompt Placement:**

| Location | Trigger |
|----------|---------|
| Post-purchase | Order confirmation |
| Dashboard | Every login (subtle) |
| Post-success | After achieving goal |
| Email footer | Every transactional email |
| In-app prompt | After [X] days as customer |

### 4. Messaging Templates

Full templates for:
- Email invite (referrer to friend)
- Landing page (referee arrives)
- Social share copy (Twitter, LinkedIn, Facebook)
- Thank you messages (referrer and referee)

See [resources/messaging-templates.yaml](resources/messaging-templates.yaml)

### 5. Viral Coefficient Framework

**K = i × c**

Where:
- i = invitations sent per customer
- c = conversion rate of invitations

| K-Factor | Meaning |
|----------|---------|
| < 0.5 | Weak referrals, needs other channels |
| 0.5-1.0 | Healthy referrals, amplifies growth |
| > 1.0 | Viral growth, self-sustaining |

**To improve:**
- Increase invitations (i): More prompts, easier sharing, gamification
- Increase conversion (c): Better landing page, higher incentive, trust signals

### 6. Tracking & Attribution

- Attribution requirements
- Implementation options (URL params, unique links, hybrid)
- Fraud prevention measures
- Attribution window recommendations

See [resources/tracking-launch.yaml](resources/tracking-launch.yaml)

### 7. Launch Plan

**Phase 1: Soft Launch (Week 1-2)**
- Top 10% customers (NPS promoters)
- Personal outreach
- Monitor for issues

**Phase 2: Expansion (Week 3-4)**
- All customers
- In-app prompts
- Email announcement

**Phase 3: Optimization (Week 5+)**
- A/B test incentives
- Add gamification
- Scale sustainably

Full roadmap: [resources/tracking-launch.yaml](resources/tracking-launch.yaml)

## Output Format

```markdown
# REFERRAL PROGRAM BLUEPRINT: [Business Name]

## Executive Summary
[Strategy and expected impact]

## Program Structure
[Incentive design and mechanics]

## Economics Model
[CAC comparison, ROI projection]

## Sharing System
[Links, channels, placements]

## Messaging Library
[All templates and copy]

## Viral Coefficient
[K-factor analysis and optimization]

## Tracking System
[Attribution and fraud prevention]

## Launch Plan
[Phased rollout with milestones]

## Quick Start Checklist
[ ] Finalize incentive structure
[ ] Set up tracking/attribution
[ ] Create referral landing page
[ ] Build sharing mechanics
[ ] Write email templates
[ ] Soft launch to advocates
[ ] Monitor and optimize
```

## Quality Standards

- **Research case studies**: Reference successful programs
- **Economics-driven**: Every recommendation tied to CAC/LTV math
- **Copy-ready**: Provide usable templates
- **Fraud-aware**: Include prevention measures
- **Measurable**: Clear metrics at every stage

## Tone

Strategic and growth-focused. Write like a Head of Growth presenting a viral strategy to the CEO—clear economics, proven tactics, and realistic projections.
