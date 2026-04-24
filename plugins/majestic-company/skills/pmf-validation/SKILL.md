---
name: pmf-validation
description: Use when validating product-market fit through demand interrogation, assumption testing, customer discovery, and MVP strategy. Starts with forcing questions to expose demand reality before investing in validation. Don't use for side projects or hackathons — use brainstorming instead.
triggers:
  - is this worth building
  - validate this idea
  - product market fit
  - does anyone want this
---

# PMF Validation

Frameworks for achieving and measuring product-market fit.

## Related Skills

- `pm-assumption-mapping` - Prioritizing assumptions by risk
- `pm-customer-interviews` - Discovery interview techniques
- `pm-jobs-to-be-done` - Understanding customer motivations

**Side project, hackathon, or learning exercise?** Use `brainstorming` instead. This skill is for ideas where demand validation matters.

## Phase 0: Demand Interrogation

Before testing assumptions, expose whether real demand exists. Ask these questions **one at a time**. Push on each until the answer is specific, evidence-based, and uncomfortable.

### Route by Stage

| Stage | Questions to Ask |
|-------|-----------------|
| Pre-product | Q1, Q2, Q3 |
| Has users | Q2, Q4, Q5 |
| Has paying customers | Q4, Q5, Q6 |

Skip questions already answered by earlier responses.

### Operating Principles

- **Specificity is the only currency.** "Enterprises in healthcare" is not a customer. You need a name, a role, a company, a reason.
- **Interest is not demand.** Waitlists, signups, "that's interesting" — none count. Behavior counts. Money counts. Panic when it breaks counts.
- **The status quo is the real competitor.** Not the other startup — the spreadsheet-and-Slack workaround they already live with.
- **Narrow beats wide, early.** The smallest version someone will pay for this week beats the full platform vision.

### The Six Forcing Questions

#### Q1: Demand Reality

"What's the strongest evidence someone actually wants this — not 'is interested,' but would be genuinely upset if it disappeared tomorrow?"

Push until you hear specific behavior: someone paying, expanding usage, building workflow around it, scrambling if it vanished.

Red flags: "People say it's interesting." "500 waitlist signups." "VCs are excited."

After the first answer, check: Are key terms defined and measurable? What does the framing take for granted? Is evidence real or hypothetical?

#### Q2: Status Quo

"What are your users doing right now to solve this — even badly? What does that workaround cost them?"

Push until you hear a specific workflow: hours spent, dollars wasted, tools duct-taped together, people hired to do it manually.

Red flags: "Nothing — no solution exists." If no one does anything about it, the problem probably isn't painful enough.

#### Q3: Desperate Specificity

"Name the actual human who needs this most. Title? What gets them promoted? What gets them fired? What keeps them up at night?"

Push until you hear a name, a role, a specific consequence they face. Match the consequence to the domain — B2B: career impact. Consumer: daily pain. Developer tools: the weekend project that gets unblocked.

Red flags: Category-level answers. "SMBs." "Marketing teams." You can't email a category.

#### Q4: Narrowest Wedge

"What's the smallest version someone would pay real money for — this week, not after you build the platform?"

Push until you hear one feature, one workflow, something shippable in days.

Red flags: "Need to build the full platform first." "Stripping it down removes differentiation." Attachment to architecture over value.

Bonus push: "What if the user got value with zero setup — no login, no integration?"

#### Q5: Observation

"Have you sat down and watched someone use this without helping them? What surprised you?"

Push until you hear a specific surprise — something the user did that contradicted assumptions.

Red flags: "We sent a survey." "We did demo calls." "Going as expected." Surveys lie. Demos are theater. "As expected" means filtered through assumptions.

The gold: users doing something the product wasn't designed for. That's often the real product.

#### Q6: Future-Fit

"If the world looks meaningfully different in 3 years — and it will — does your product become more essential or less?"

Push until you hear a specific claim about how their users' world changes and why that makes the product more valuable.

Red flags: "Market growing 20% YoY." Growth rate is not a vision. "AI makes everything better." That's not a thesis — every competitor says the same.

### Demand Interrogation Verdict

After questions, synthesize:

| Signal | Verdict | Next Step |
|--------|---------|-----------|
| Specific demand evidence, named users, clear wedge | **Proceed** | Move to Assumption Risk Framework below |
| Mixed signals, some evidence, vague on specifics | **Sharpen** | Use `pm-customer-interviews` to fill gaps |
| No evidence, hypothetical users, category-level answers | **Pause** | Use `idea-generation` to find a better angle |

---

## Assumption Risk Framework

### High Risk (Validate First)

| Assumption | Validation Method | Success Criteria |
|------------|------------------|------------------|
| Problem exists | Customer interviews (10+) | 7/10 confirm problem |
| Willing to pay | Price testing, pre-orders | 3+ paying commitments |
| Pain is acute | Severity scoring | Average 8+/10 |

### Medium Risk (Validate During MVP)

| Assumption | Validation Method | Success Criteria |
|------------|------------------|------------------|
| Features priority | Usage analytics | 60%+ use core feature |
| Channel works | A/B testing | CAC < 1/3 LTV |
| Positioning | Competitive testing | Clear preference signals |

### Low Risk (Validate Post-Launch)

- Scale assumptions
- Expansion opportunities
- Adjacent markets

## MVP Strategy

### Definition Criteria

| Element | Question | Output |
|---------|----------|--------|
| Core value | What's the one thing it MUST do? | Single feature |
| Target user | Who has this problem most acutely? | Narrow persona |
| Success metric | How do we know it works? | Measurable KPI |
| Timeline | What's the fastest we can test? | Weeks, not months |

### Feature Prioritization

| Category | Include in MVP | Defer |
|----------|----------------|-------|
| Must-have | Core value delivery | Enhancement features |
| Differentiator | Key unique angle | Secondary differentiators |
| Table stakes | Minimum viable | Nice-to-haves |

## Validation Methodology

### Customer Discovery Script

**Opening (2 min)**
- Build rapport
- Explain purpose: learning, not selling

**Problem Exploration (10 min)**
- "Tell me about the last time you dealt with [problem]..."
- "What did you try? What worked/didn't work?"
- "On a scale of 1-10, how painful is this?"

**Solution Testing (5 min)**
- "If you could wave a magic wand, what would happen?"
- "I'm working on something that [brief description]..."
- "Would this help? Why or why not?"

**Commitment Testing (3 min)**
- "Would you be interested in trying an early version?"
- "What would you expect to pay for something like this?"
- "Can I follow up when we have something to show?"

### Signal Interpretation

| Signal | Meaning | Action |
|--------|---------|--------|
| "I'd pay for this" | Interest | Get specific on price |
| "Keep me updated" | Lukewarm | Find stronger pain |
| "I already have X" | Competition | Differentiate or pivot |
| "Let me introduce you to..." | Enthusiasm | Strong signal |

## Decision Framework

### Green Light (Proceed)

- 70%+ confirm problem exists
- 3+ paying commitments
- Clear differentiation
- Unit economics work

### Yellow Light (Iterate)

- Mixed feedback on value prop
- Price resistance but interest
- Unclear positioning
- Channel uncertainty

### Red Light (Pivot)

- <30% problem confirmation
- No willingness to pay
- Existing solutions "good enough"
- No user enthusiasm

## PMF Indicators

| Metric | Pre-PMF | At PMF | Strong PMF |
|--------|---------|--------|------------|
| Retention | <20% | 40%+ | 60%+ |
| NPS | <20 | 40+ | 60+ |
| Word of mouth | <10% | 25%+ | 40%+ |
| Revenue growth | Flat | 20%+ MoM | 50%+ MoM |
| Inbound demand | None | Some | Pull > Push |
