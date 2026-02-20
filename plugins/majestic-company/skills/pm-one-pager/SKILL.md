---
name: pm-one-pager
description: Use when writing feature briefs or decision documents. Not for full PRDs (use /majestic:prd).
triggers:
  - one pager
  - feature brief
  - decision document
  - product decision
  - decision record
disable-model-invocation: true
---

# Feature Brief & Decision Document

Lightweight PM artifacts for early exploration and decision recording. Use before committing to a full PRD (`/majestic:prd`).

## Feature Brief Template

```markdown
# Feature Brief: [Name]
**Date:** YYYY-MM-DD | **Author:** [PM] | **Status:** [Draft/Review/Approved/Rejected]

## Problem
[2-3 sentences: What pain exists, who has it, how bad is it]

## Proposed Solution
[2-3 sentences: What we'd build, core mechanic]

## Target Users
- **Primary:** [Specific segment + size estimate]
- **Secondary:** [If applicable]

## Success Metrics
| Metric | Baseline | Target | Timeline |
|--------|----------|--------|----------|
| [KPI] | [Current] | [Goal] | [By when] |

## Scope
- **In:** [3-5 bullet points]
- **Out:** [Explicit exclusions]

## Effort Estimate
- **Size:** [S/M/L/XL]
- **Teams involved:** [Eng, Design, Data, etc.]
- **Dependencies:** [Blockers or prerequisites]

## Risks
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]

## Open Questions
- [ ] [Question needing answer before PRD]

## Recommendation
**[Go / No-Go / Needs More Research]** — [One sentence rationale]

## Next Steps
- [ ] [Specific action with owner]
```

## Decision Document Template

```markdown
# Decision: [Short title]
**Date:** YYYY-MM-DD | **Decision Maker:** [Name/Role]
**Status:** [Proposed/Decided/Superseded]

## Context
[What situation requires a decision? What constraints exist?]

## Options Evaluated

### Option A: [Name]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Effort:** [S/M/L]
- **Risk:** [Low/Med/High]

### Option B: [Name]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Effort:** [S/M/L]
- **Risk:** [Low/Med/High]

### Option C: [Name] (if applicable)
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Effort:** [S/M/L]
- **Risk:** [Low/Med/High]

## Decision
**Chosen:** [Option X]
**Rationale:** [Why this option over others — specific trade-offs accepted]

## Consequences
- [What changes as a result]
- [What we're giving up]
- [What we need to monitor]

## Revisit Criteria
- Revisit if [condition changes]
- Review by [date] if [assumption unvalidated]
```

## When to Use Each

| Artifact | When | Leads To |
|----------|------|----------|
| **Feature Brief** | Early exploration, before committing resources | PRD if approved, backlog item if small |
| **Decision Document** | Choosing between approaches, recording rationale | Implementation plan |
| **PRD** (`/majestic:prd`) | Approved feature needing full specification | Blueprint, implementation |

## File Conventions

```
docs/briefs/brief-[feature-name].md    # Feature briefs
docs/decisions/decision-[topic].md      # Decision records
docs/prd/prd-[feature-name].md         # Full PRDs (via /majestic:prd)
```
