# Retention Intervention Playbooks

## Playbook 1: Usage Decline

**Trigger:** >30% usage decline over 14 days

**Day 1: Soft Touch**
- In-app message: "We noticed you've been quiet. Need help?"
- Link to quick win article

**Day 3: Email Outreach**
- Subject: "Is everything okay, {{first_name}}?"
- Content: Check-in, offer help, no sales pitch

**Day 7: CSM Call (if high-value)**
- Purpose: Understand blockers
- Questions: What's changed? What would help?
- Outcome: Action plan

**Day 14: Re-engagement Offer**
- If still declining: Offer training session
- If at-risk tier: Offer temporary discount

## Playbook 2: Support Escalation

**Trigger:** 3+ support tickets with negative sentiment

**Immediate:**
- Flag account in CRM
- Assign senior support agent
- Notify CSM

**Within 24 hours:**
- CSM personal outreach
- Acknowledge frustration
- Provide direct line

**Within 72 hours:**
- Root cause analysis complete
- Solution presented
- Follow-up scheduled

**Within 7 days:**
- Resolution confirmed
- NPS pulse check
- Service credit if warranted

## Playbook 3: Competitor Threat

**Trigger:** Competitor mentioned in support/conversation

**Immediate:**
- Alert sales/CSM
- Document specific competitor
- Pull competitive positioning

**Within 24 hours:**
- CSM outreach: "Let's talk about your needs"
- Prepare competitive comparison
- Identify gaps and advantages

**Within 48 hours:**
- Value reinforcement meeting
- Address specific competitor features
- If losing: Executive escalation

## Playbook 4: Payment Failure

**Trigger:** Failed payment

| Day | Action |
|-----|--------|
| 0 | Automatic retry + email notification |
| 3 | Second retry + email with update link |
| 7 | Final retry + urgent email + CSM notification |
| 14 | Account restriction + final notice |
| 30 | Service suspension + win-back sequence |

## Playbook 5: Renewal Risk

**Trigger:** 90 days before renewal with health score <70

| Days Out | Actions |
|----------|---------|
| 90 | CSM assigned, value assessment, executive sponsor ID |
| 60 | QBR scheduled, ROI report prepared, expansion opportunities |
| 30 | Renewal discussion, address concerns, finalize terms |
| 7 | Contract sent, escalation if unsigned |

## Detailed Health Score Model

### Product Usage Scoring (40 points)

| Metric | Poor (0-3) | Fair (4-6) | Good (7-8) | Excellent (9-10) | Weight |
|--------|------------|------------|------------|------------------|--------|
| Login frequency | <1x/week | 1-2x/week | 3-4x/week | Daily | 15 |
| Core feature usage | <20% | 20-50% | 50-80% | >80% | 15 |
| Session duration | <2 min | 2-5 min | 5-15 min | >15 min | 10 |

### Engagement Scoring (25 points)

| Metric | Poor | Fair | Good | Excellent | Weight |
|--------|------|------|------|-----------|--------|
| Email engagement | No opens | Some opens | Regular opens | Replies | 10 |
| Support sentiment | Negative | Neutral | Positive | Advocate | 10 |
| Community participation | None | Lurker | Contributor | Leader | 5 |

### Relationship Scoring (20 points)

| Metric | Poor | Fair | Good | Excellent | Weight |
|--------|------|------|------|-----------|--------|
| NPS Response | Detractor | Passive | Promoter | 9-10 | 10 |
| Executive sponsor | None | Identified | Engaged | Champion | 5 |
| Stakeholder coverage | 1 user | 2-3 users | 4+ users | Org-wide | 5 |

### Business Health Scoring (15 points)

| Metric | Poor | Fair | Good | Excellent | Weight |
|--------|------|------|------|-----------|--------|
| Payment history | Late/failed | Occasional late | On time | Auto-pay | 5 |
| Contract status | Month-to-month | Quarterly | Annual | Multi-year | 5 |
| Growth potential | Contracting | Flat | Growing | High growth | 5 |

## Customer Success Tier Model

### Tier 1: High-Touch (Enterprise)

**Criteria:** ARR > $[X] OR strategic accounts

| Resource | Ratio | Activities |
|----------|-------|------------|
| Dedicated CSM | 1:20-30 | Proactive, strategic |
| Executive Sponsor | 1:5-10 | Quarterly engagement |
| Technical Account Manager | 1:50 | Implementation, technical |

### Tier 2: Mid-Touch (Growth)

**Criteria:** ARR $[X]-$[Y] OR growth potential

| Resource | Ratio | Activities |
|----------|-------|------------|
| Pooled CSM | 1:50-100 | Reactive + triggered proactive |
| Support | Prioritized | Faster response SLA |

### Tier 3: Tech-Touch (SMB)

**Criteria:** ARR < $[X] OR self-serve

| Resource | Ratio | Activities |
|----------|-------|------------|
| Digital CSM | 1:500+ | Automated + scale |
| Support | Standard | Standard SLA |
