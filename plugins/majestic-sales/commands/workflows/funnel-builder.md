---
name: sales:funnel-builder
allowed-tools: WebSearch, AskUserQuestion, Write, Skill
description: Build comprehensive, high-converting sales funnels through a guided 5-phase process
---

# Sales Funnel Builder

**Audience:** Founders and marketers building end-to-end sales funnels.

**Goal:** Guide through 5 phases to build a complete, conversion-optimized funnel by orchestrating specialized skills.

## Input

$ARGUMENTS

## Skills

| Phase | Skill | Purpose |
|-------|-------|---------|
| 1 | `icp-discovery` | Customer avatar and journey mapping |
| 2 | `lead-magnet-design` | Lead magnets, entry points, opt-in |
| 3 | `majestic-marketing:email-sequence-builder` | Nurture sequence development |
| 4 | `conversion-optimization` | Sales page, offers, pricing, checkout |
| 5 | `customer-expansion` | Upsells and cross-sells |
| 5 | `referral-program` | Referral system design |
| 5 | `win-back` | Retention and reactivation |

## Initial Gathering

Use `AskUserQuestion`:

"I'll help you build a high-converting sales funnel.

**Product/Service:**
1. Main offering? (Brief description)
2. Price point/structure?
3. Problem solved?
4. What makes it unique?

**Target Market:**
1. Ideal customer?
2. Main pain points?
3. Where they search for solutions?
4. Common objections?"

## Process

After each phase:
1. Summarize insights and decisions
2. Provide implementation recommendations
3. Explain next phase
4. Use `AskUserQuestion` to confirm readiness

### Phase 1: Customer Avatar

Apply `icp-discovery` patterns:
- Primary customer avatar (persona, goals, frustrations)
- Customer journey map (awareness → consideration → decision)
- Pain point analysis with severity scoring
- Value perception matrix

### Phase 2: Lead Magnet & Entry Points

Apply `lead-magnet-design` patterns:
- 3-5 lead magnet concepts with format selection
- Entry point strategy by traffic source
- Landing page blueprint with headline options
- Segmentation strategy (quiz/survey if applicable)

### Phase 3: Nurture Sequence

Apply `majestic-marketing:email-sequence-builder` patterns:
- 7-12 email nurture sequence
- Content strategy (value-building, stories, social proof)
- Objection handling framework
- Behavioral triggers for acceleration/re-engagement

### Phase 4: Conversion Mechanism

Apply `conversion-optimization` patterns:
- Sales page architecture and copy framework
- Offer structure with value stack
- Pricing strategy and payment options
- Urgency/scarcity mechanics
- Checkout optimization with order bumps

### Phase 5: Upsell & Retention

Apply retention skills:
- `customer-expansion`: Immediate upsell, ascension model
- `referral-program`: Incentive structure, request timing
- `win-back`: Churn triggers, re-engagement sequence

## Output

At completion:
1. Complete funnel architecture summary
2. Implementation priority order
3. Key metrics per stage
4. Testing recommendations

Use `Write` to save complete funnel plan if requested.
