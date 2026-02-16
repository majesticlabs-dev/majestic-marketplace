---
name: marketing-playbook
description: Your guide to the marketing toolkit. Diagnoses where you are in your marketing journey and recommends the right skills, agents, and workflows to use next.
triggers:
  - marketing help
  - where do I start
  - marketing guide
  - what marketing skill
  - marketing playbook
allowed-tools: AskUserQuestion
---

<!-- DEPRECATED: This skill is routing logic, not teaching content.
     Content should be moved to plugin README or converted to lightweight agent.
     See skill-auditor report for details. -->

# Marketing Playbook

## Conversation Starter

Use `AskUserQuestion` to diagnose their stage:

"I'll help you navigate the marketing toolkit.

**Where are you right now?**

1. **Starting from scratch** - No marketing yet, need foundation
2. **Have a product, need customers** - Ready to acquire users
3. **Have traffic, need conversions** - Getting visitors, not converting
4. **Have customers, need retention** - Want repeat business
5. **Have content, need distribution** - Created stuff, need eyeballs
6. **Need a specific asset** - Know what you want (email, landing page, etc.)"

## Stage Routing

| Stage | Recommended Path |
|-------|-----------------|
| **1. From Scratch** | competitive-positioning → value-prop-sharpener → brand-voice → marketing-strategy |
| **2. Need Customers** | bofu-keywords → content-calendar → content-writer → lead-magnet → landing-page-builder → email-nurture |
| **3. Need Conversions** | customer-discovery → irresistible-offer → sales-page → hook-writer |
| **4. Need Retention** | retention-system → newsletter → case-study-writer |
| **5. Need Distribution** | content-atomizer → linkedin-content → viral-content → llm-optimizer agent |

## Skill Lookup

| Need This | Use This |
|-----------|----------|
| Competitive analysis | `competitive-positioning` |
| Value proposition | `value-prop-sharpener` |
| Brand voice guide | `brand-voice` |
| Marketing strategy | `marketing-strategy` |
| Market research | `market-research` |
| Blog article | `content-writer` |
| Content calendar | `content-calendar` |
| Newsletter | `newsletter` |
| LinkedIn posts | `linkedin-content` |
| Viral content | `viral-content` |
| Landing page | `landing-page-builder` |
| Sales page | `sales-page` |
| Email sequence | `email-nurture` |
| Slogans | `slogan-generator` |
| Hooks | `hook-writer` |
| Lead magnet | `lead-magnet` |
| Case study | `case-study-writer` |
| SEO audit | `/majestic-marketing:workflows:seo-audit` |
| AI optimization | `llm-optimizer` agent |
| Featured snippets | `snippet-hunter` agent |
| Google Ads | `google-ads-strategy` |
| Repurpose content | `content-atomizer` |
| Brand names | `namer` agent |
| Retention system | `retention-system` |

## Quick Commands

| Goal | Command |
|------|---------|
| SEO audit | `/majestic-marketing:workflows:seo-audit` |
| Content check | `/majestic-marketing:workflows:content-check` |
| AEO workflow | `/majestic-marketing:workflows:aeo-workflow` |
