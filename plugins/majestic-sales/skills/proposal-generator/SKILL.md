---
name: proposal-generator
description: Orchestrate proposal creation by gathering deal context, validating inputs, invoking proposal-writer skill, and ensuring quality output.
allowed-tools: Read Write Edit Grep Glob WebSearch WebFetch
---

# Proposal Generator

Guide proposal creation by gathering context, validating inputs, applying the `proposal-writer` skill, validating output quality, and recommending delivery.

## Step 1: Gather Context

Collect deal information:

1. **Prospect**: Company name, industry, size
2. **Stakeholders**: Who will read this? (Titles and their concerns)
3. **Discovery findings**: What problems did they share? What's the business impact?
4. **Solution**: What are you proposing? (Products, services, scope)
5. **Pricing**: What's the investment? (Or range if flexible)
6. **Competition**: Are they evaluating alternatives?
7. **Timeline**: When do they need to decide? When to implement?
8. **Objections**: Any concerns raised during sales process?

## Step 2: Validate Inputs

Before proceeding, verify:

| Required Input | Validation |
|----------------|------------|
| Prospect info | Company name + industry present |
| Stakeholders | At least 1 decision-maker identified |
| Discovery findings | Specific pain points, not generic |
| Solution | Clear scope of what's proposed |
| Pricing | Number or range provided |

**If missing:** Ask follow-up questions. Do not proceed with incomplete context.

## Step 3: Analyze Deal

| Factor | Analysis | Impact |
|--------|----------|--------|
| **Deal Size** | <$10K / $10-50K / $50K+ | Determines proposal length |
| **Stakeholder Count** | Single / Multiple | Determines sections needed |
| **Competition** | None / Active | Determines differentiation emphasis |
| **Objection History** | List concerns raised | Must address proactively |
| **Timeline Pressure** | Urgent / Standard | Affects urgency framing |

## Step 4: Apply Proposal Writer Skill

Apply `proposal-writer` with structured context:

```yaml
context:
  prospect: [company, industry, size]
  deal_size: [<$10K | $10-50K | $50K+]
  stakeholders: [list with concerns]
  pain_points: [from discovery]
  solution: [what we're proposing]
  pricing: [amount or options]
  competition: [who, their weakness]
  objections_to_address: [list]
  timeline: [decision date, implementation date]
```

## Step 5: Validate Output

### Must Pass

- [ ] Executive summary can stand alone (decision-maker reads only this)
- [ ] Pain points use prospect's words from discovery
- [ ] Outcomes are measurable (numbers, percentages, timeframes)
- [ ] Pricing presented strategically (options, anchoring)
- [ ] Each stakeholder's concern addressed somewhere
- [ ] Clear next steps with dates and owners
- [ ] Proposal length matches deal size
- [ ] No generic or boilerplate language
- [ ] Valid until date creates appropriate urgency

### Red Flags (Fix Before Delivery)

| Issue | Problem | Fix |
|-------|---------|-----|
| Leads with company history | They stop reading | Lead with their pain |
| Generic scope language | Feels like template | Reference specific discovery |
| Pricing buried at end | Seems evasive | Put in exec summary |
| No clear next steps | Deal stalls | Add action table with dates |
| Missing ROI justification | Price feels high | Add payback calculation |

## Step 6: Recommend Delivery

| Deal Size | Format | Delivery Method |
|-----------|--------|-----------------|
| <$10K | PDF | Email with brief note |
| $10K-$50K | PDF | Screen share walkthrough |
| >$50K | PDF + Deck | In-person or video presentation |

**Always recommend:** "Walk them through it rather than just sending. Control the narrative."

## Handling Edge Cases

| Situation | Action |
|-----------|--------|
| Missing discovery context | Ask: "What did they say was their biggest challenge?" |
| No clear pricing | Ask: "What's your target price point or range?" |
| Unknown stakeholders | Ask: "Who else will be involved in the decision?" |
| Output too generic | Re-apply skill with more specific pain points |
| Proposal too long | Request condensed version for deal size |

## Deliverables

1. Complete proposal (markdown or requested format)
2. Delivery recommendation
3. Suggested talk track for walkthrough
4. Follow-up timing recommendation
