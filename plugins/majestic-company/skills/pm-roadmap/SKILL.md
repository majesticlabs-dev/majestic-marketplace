---
name: pm-roadmap
description: Use when planning product roadmaps with Now/Next/Later horizons. Not for feature prioritization (use pm-prioritization).
triggers:
  - roadmap
  - product roadmap
  - roadmap planning
  - now next later
---

# Product Roadmap Planning

Framework for building outcome-focused, theme-based roadmaps.

## Roadmap Structure

```
Strategic Goal
├── Theme 1: [Outcome-focused name]
│   ├── Now: [Initiative with success metric]
│   ├── Next: [Initiative with success metric]
│   └── Later: [Initiative with success metric]
├── Theme 2: [Outcome-focused name]
│   ├── Now: ...
│   └── Next: ...
└── Theme 3: [Outcome-focused name]
    └── ...
```

## Roadmap Template

```markdown
# Product Roadmap: [Product/Team]
**Last Updated:** YYYY-MM-DD | **Owner:** [PM Name]
**Strategic Goal:** [One sentence]

## Theme 1: [Outcome, not feature name]
**Why:** [Business/user outcome this theme drives]
**Success Metric:** [How we know this theme is working]

### Now (Current Quarter)
| Initiative | Outcome | Status | Owner |
|-----------|---------|--------|-------|
| [Initiative] | [Measurable result] | [🟢/🟡/🔴] | [Team] |

### Next (Next Quarter)
| Initiative | Outcome | Confidence | Dependencies |
|-----------|---------|------------|--------------|
| [Initiative] | [Expected result] | [High/Med/Low] | [Blockers] |

### Later (Future)
| Initiative | Outcome | Open Questions |
|-----------|---------|----------------|
| [Initiative] | [Hypothesis] | [What we need to learn] |

## Decisions & Trade-offs
| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| [What] | [A, B, C] | [B] | [Why] |

## What We're NOT Doing (and Why)
- [Feature/initiative]: [Reason for exclusion]
```

## Time Horizons

| Horizon | Commitment Level | Detail Level | Changes |
|---------|-----------------|--------------|---------|
| **Now** | Committed | High (initiatives, owners, metrics) | Rare |
| **Next** | Planned | Medium (initiatives, outcomes) | Monthly |
| **Later** | Exploratory | Low (themes, hypotheses) | Frequently |

## Audience-Specific Views

| Audience | Show | Hide |
|----------|------|------|
| **Executive** | Themes, outcomes, strategic alignment | Implementation details |
| **Engineering** | Initiatives, dependencies, sizing | Business rationale |
| **Sales/CS** | Timeline, customer impact, messaging | Technical details |
| **Full team** | Everything | Nothing |

## Building Process

1. **Gather inputs** — strategic goals, OKRs, discovery findings, tech debt
2. **Group into themes** — cluster related work by outcome, not feature type
3. **Prioritize themes** — use `pm-prioritization` (RICE/ICE/OST)
4. **Place in horizons** — Now=committed, Next=planned, Later=exploratory
5. **Define success** — each theme needs a measurable outcome
6. **Identify dependencies** — cross-team blockers, technical prerequisites
7. **Create audience views** — tailor detail level per stakeholder group
8. **Review cadence** — monthly for Now/Next, quarterly for Later

## Anti-Patterns

| Anti-Pattern | Problem | Instead |
|--------------|---------|---------|
| Feature list roadmap | No strategic context | Theme by outcome |
| Date-driven promises | Creates false precision | Use horizons |
| No "not doing" section | Scope creep | Explicitly exclude |
| Static document | Stale in weeks | Set review cadence |
| One view for all | Wrong detail level | Audience-specific views |
