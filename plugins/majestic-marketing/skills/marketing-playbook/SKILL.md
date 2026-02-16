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
6. **Need a specific asset** - Know what you want (email, landing page, etc.)

## Stage-Based Recommendations

### Stage 1: Starting from Scratch

```
1. competitive-positioning → Find your edge
2. value-prop-sharpener → Nail your message
3. brand-voice → Define how you speak
4. marketing-strategy → Build your plan
```

**Why this order:**
- Can't market what you can't differentiate
- Value prop drives all messaging
- Voice ensures consistency
- Strategy ties it together

### Stage 2: Need Customers (Acquisition)

```
TRAFFIC GENERATION:
1. bofu-keywords → Find high-intent search terms
2. content-calendar → Plan your content
3. content-writer → Create the content
4. seo-audit → Optimize for search

LEAD CAPTURE:
5. lead-magnet → Create opt-in offer
6. landing-page-builder → Build conversion page
7. email-nurture → Set up follow-up sequence
```

**Alternative:** `google-ads-strategy` for paid acquisition

### Stage 3: Need Conversions

```
DIAGNOSE:
1. customer-discovery → Understand their language

CONVERT:
2. irresistible-offer → Strengthen your offer
3. sales-page → Build high-converting page
4. hook-writer → Create compelling hooks
5. power-words → Strengthen your copy
```

### Stage 4: Need Retention

```
1. retention-system → Build retention playbook
2. newsletter → Ongoing communication
3. case-study-writer → Showcase success stories
```

### Stage 5: Need Distribution

```
1. content-atomizer → Repurpose into multiple formats
2. linkedin-content → LinkedIn strategy
3. viral-content → Create shareable content

AI VISIBILITY:
4. llm-optimizer agent → Get cited by AI
5. entity-builder agent → Build brand presence
```

### Stage 6: Need Specific Asset

| Need This | Use This | Command |
|-----------|----------|---------|
| **Positioning/Strategy** | | |
| Competitive analysis | `competitive-positioning` | `skill competitive-positioning` |
| Value proposition | `value-prop-sharpener` | `skill value-prop-sharpener` |
| Brand voice guide | `brand-voice` | `skill brand-voice` |
| Marketing strategy | `marketing-strategy` | `skill marketing-strategy` |
| Market research | `market-research` | `skill market-research` |
| **Content** | | |
| Blog article | `content-writer` | `skill content-writer` |
| Content calendar | `content-calendar` | `skill content-calendar` |
| Newsletter | `newsletter` | `skill newsletter` |
| LinkedIn posts | `linkedin-content` | `skill linkedin-content` |
| Viral content | `viral-content` | `skill viral-content` |
| **Copy** | | |
| Landing page | `landing-page-builder` | `skill landing-page-builder` |
| Sales page | `sales-page` | `skill sales-page` |
| Email sequence | `email-nurture` | `skill email-nurture` |
| Slogans | `slogan-generator` | `skill slogan-generator` |
| Hooks | `hook-writer` | `skill hook-writer` |
| **Lead Gen** | | |
| Lead magnet | `lead-magnet` | `skill lead-magnet` |
| Case study | `case-study-writer` | `skill case-study-writer` |
| **SEO/AEO** | | |
| SEO audit | workflow | `/seo-audit` |
| AI optimization | `llm-optimizer` agent | `agent llm-optimizer` |
| Featured snippets | `snippet-hunter` agent | `agent snippet-hunter` |
| **Paid** | | |
| Google Ads | `google-ads-strategy` | `skill google-ads-strategy` |
| **Distribution** | | |
| Repurpose content | `content-atomizer` | `skill content-atomizer` |
| **Brand** | | |
| Brand names | `namer` agent | `agent namer` |
| **Retention** | | |
| Retention system | `retention-system` | `skill retention-system` |

## The Full Marketing Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     FOUNDATION                               │
│  competitive-positioning → value-prop-sharpener → brand-voice│
│                         ↓                                    │
│                 marketing-strategy                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     ACQUISITION                              │
│                                                              │
│   CONTENT PATH          │         PAID PATH                 │
│   ──────────────        │         ─────────                 │
│   bofu-keywords         │         google-ads-strategy       │
│   content-calendar      │                                   │
│   content-writer        │                                   │
│   seo-audit             │                                   │
│         ↓               │               ↓                   │
│   ┌─────────────────────────────────────────┐               │
│   │           LEAD CAPTURE                  │               │
│   │   lead-magnet → landing-page-builder    │               │
│   │              → email-nurture            │               │
│   └─────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     CONVERSION                               │
│   customer-discovery → irresistible-offer → sales-page      │
│                      → hook-writer → power-words             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     RETENTION                                │
│   retention-system → newsletter → case-study-writer         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    AMPLIFICATION                             │
│   content-atomizer → linkedin-content → viral-content       │
│                    → llm-optimizer (AI visibility)          │
└─────────────────────────────────────────────────────────────┘
```

## Common Workflows

### "I need to launch a product"
```
1. competitive-positioning (differentiation)
2. value-prop-sharpener (messaging)
3. brand-voice (consistency)
4. landing-page-builder (conversion page)
5. email-nurture (follow-up)
6. content-atomizer (promotion)
```

### "I need more traffic"
```
1. bofu-keywords (find what to write)
2. content-writer (create content)
3. seo-audit (optimize)
4. content-atomizer (distribute)
```

### "I need more leads"
```
1. lead-magnet (create opt-in)
2. landing-page-builder (capture page)
3. email-nurture (follow-up sequence)
```

### "I need to sell more"
```
1. customer-discovery (understand language)
2. irresistible-offer (strengthen offer)
3. sales-page (high-converting copy)
4. hook-writer + power-words (polish)
```

### "I need AI to recommend me"
```
1. llm-optimizer agent (optimize for AI citation)
2. entity-builder agent (build brand entity)
3. schema-architect agent (structured data)
4. /aeo-workflow command (full process)
```

## Quick Commands

| Goal | Command |
|------|---------|
| SEO audit | `/majestic-marketing:workflows:seo-audit` |
| Content check | `/majestic-marketing:workflows:content-check` |
| AEO workflow | `/majestic-marketing:workflows:aeo-workflow` |
