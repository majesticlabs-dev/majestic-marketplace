# Tracking & Launch Guide

## Attribution Requirements

| Data Point | Purpose | How to Track |
|------------|---------|--------------|
| Referrer ID | Credit rewards | Unique code in URL |
| Referee ID | Match relationships | Account creation |
| Referral timestamp | Attribution window | Event logging |
| Conversion event | Trigger rewards | Purchase/signup event |
| Reward status | Fulfillment | Database flag |

## Tracking Implementation

**URL Parameter Method:**
`yoursite.com/?ref=USER123`
- Simple to implement
- Works across sessions with cookies
- Vulnerable to cookie deletion

**Unique Link Method:**
`yoursite.com/r/USER123`
- Cleaner URLs
- Better for sharing
- Requires redirect handling

**Hybrid Approach:**
- Unique links for active sharing
- Cookies for attribution persistence
- Email/account matching as backup

## Fraud Prevention

| Fraud Type | Prevention Method |
|------------|-------------------|
| Self-referral | Email domain matching, IP tracking |
| Fake accounts | Email verification, phone verification |
| Abuse at scale | Rate limiting, manual review thresholds |
| Reward exploitation | Delayed reward release, clawback terms |

## Attribution Window

| Model | Window | Best For |
|-------|--------|----------|
| First-touch | 30-90 days | Longer sales cycles |
| Last-touch | 7-14 days | Impulse purchases |
| Multi-touch | Weighted | Complex journeys |

---

# Launch Roadmap

## Phase 1: Soft Launch (Week 1-2)

**Goals:**
- Test mechanics with small group
- Identify friction points
- Baseline metrics

**Actions:**
- [ ] Launch to top 10% of customers (NPS promoters)
- [ ] Personal outreach explaining program
- [ ] Monitor closely for issues
- [ ] Gather qualitative feedback

**Success Criteria:**
- [ ] [X]% participation rate
- [ ] No technical issues
- [ ] Positive feedback

## Phase 2: Expansion (Week 3-4)

**Goals:**
- Increase visibility
- Optimize based on learnings
- Build momentum

**Actions:**
- [ ] Launch to all existing customers
- [ ] Add in-app prompts
- [ ] Email announcement
- [ ] Optimize landing page based on data

**Success Criteria:**
- [ ] [X] referrals generated
- [ ] [X]% conversion rate
- [ ] K-factor > [X]

## Phase 3: Optimization (Week 5+)

**Goals:**
- Maximize viral coefficient
- Scale sustainably
- Automate operations

**Actions:**
- [ ] A/B test incentive levels
- [ ] A/B test messaging
- [ ] Add gamification elements
- [ ] Implement advanced fraud detection

## A/B Testing Priorities

| Test | Hypothesis | Metric |
|------|------------|--------|
| Incentive amount | Higher reward → more shares | Shares per customer |
| Incentive type | Credit vs. cash | Conversion rate |
| CTA placement | Earlier prompt → more action | Click rate |
| Email timing | Day 7 vs. Day 14 | Response rate |
| Landing page | Video vs. text | Signup rate |
