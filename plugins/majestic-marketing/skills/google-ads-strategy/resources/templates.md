# Google Ads Strategy Templates

## Campaign Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    GOOGLE ADS ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────────┤
│  SEARCH CAMPAIGNS                                               │
│  ├── Brand Campaign (Protect brand terms)                       │
│  ├── Competitor Campaign (Conquest keywords)                    │
│  ├── Non-Brand High Intent (Bottom-funnel)                     │
│  └── Non-Brand Research (Top/Mid-funnel)                       │
│                                                                 │
│  PERFORMANCE MAX (If e-commerce/local)                         │
│  └── Asset group per product category                          │
│                                                                 │
│  DISPLAY/RETARGETING                                           │
│  ├── Site Visitors (7-day, 30-day segments)                    │
│  └── Cart/Form Abandoners                                       │
│                                                                 │
│  YOUTUBE (Optional - awareness)                                │
│  └── In-stream for competitor audiences                        │
└─────────────────────────────────────────────────────────────────┘
```

## Keyword Tables

### Brand Keywords Template
| Keyword | Match Type | Est. CPC | Priority |
|---------|------------|----------|----------|
| [brand name] | Exact | $[X] | High |
| [brand name] + review | Exact | $[X] | High |
| [brand name] + pricing | Exact | $[X] | High |
| [brand name] + alternative | Exact | $[X] | High |

### High Intent Keywords Template
| Keyword | Match Type | Est. CPC | Search Vol | Intent |
|---------|------------|----------|------------|--------|
| [product category] software | Exact | $[X] | [X]/mo | Transactional |
| best [product category] | Exact | $[X] | [X]/mo | Commercial |
| [product category] for [use case] | Exact | $[X] | [X]/mo | Transactional |
| [competitor] alternative | Exact | $[X] | [X]/mo | Commercial |

### Keyword Discovery Process (2026)

**Using Google Keyword Planner:**
1. Tools > Keyword Planner > Discover new keywords
2. Input seed term + website URL for context
3. Filter: average monthly searches > 30 (avoid low-volume noise)
4. Prioritize head terms over long-tail—match types capture variants anyway
5. Use "Refine Keywords" to identify themes (running, hiking, gender-specific, etc.)

**Validation checklist:**
- [ ] Competition level checked (how many advertisers bid)
- [ ] Top-of-page bid estimates reviewed for expected CPCs
- [ ] Forecast Tool run for scaling potential and budget expectations

**Head term vs. long-tail (2026 guidance):**
- Prefer: "compression knee sleeves" (9,900 searches)
- Skip: "best compression knee sleeve for arthritis" (140 searches)
- Why: Exact and broad match now capture long-tail variants automatically

### Standard Negative Keywords
```
-free -cheap -diy -job -jobs -career -careers
-salary -course -courses -training -certification
-template -reddit -quora -repair -rental -used
```

## RSA Headlines Library (30 char max)

**Value Proposition**
1. "[Main Benefit] in [Timeframe]"
2. "[Result] Without [Pain Point]"
3. "The [Category] That [Differentiator]"

**Social Proof**
4. "Trusted by [X]+ Companies"
5. "[X]% [Improvement] Guaranteed"
6. "#1 Rated [Category] on G2"

**CTA**
7. "Get Your Free [Offer]"
8. "Start Your Free Trial Today"
9. "See [Product] in Action"

**Features**
10. "[Key Feature 1] Built-In"
11. "[Key Feature 2] Included"
12. "All-in-One [Category]"

**Urgency/Offer**
13. "[X]% Off - Limited Time"
14. "Free [Timeframe] Trial"
15. "No Credit Card Required"

## RSA Descriptions (90 char max)

1. **Benefit**: "[Solve pain point]. [Achieve outcome]. Start your free trial and see results in [timeframe]."
2. **Feature**: "Get [feature 1], [feature 2], and [feature 3]. Everything you need to [achieve goal]. Try free."
3. **Social Proof**: "Join [X]+ companies using [Product] to [achieve result]. [Star rating] on [review site]."
4. **CTA**: "Ready to [achieve goal]? See why teams choose [Product]. Schedule your demo today."

## Sitelinks Template
| Sitelink | Description | Landing Page |
|----------|-------------|--------------|
| Pricing | See plans + pricing | /pricing |
| Features | Explore all features | /features |
| Case Studies | See customer results | /customers |
| Free Trial | Start free today | /signup |
| Demo | Watch product demo | /demo |

## Audience Targeting Tables

### In-Market Audiences
| Audience | Campaign | Bid Adjustment |
|----------|----------|----------------|
| Business Software | Non-Brand | +20% |
| [Specific category] | Non-Brand | +30% |

### Remarketing Lists
| Audience | Window | Bid Adj | Campaign |
|----------|--------|---------|----------|
| All Site Visitors | 30 days | +50% | Search, Display |
| Pricing Page Visitors | 7 days | +100% | Search |
| Cart/Form Abandoners | 7 days | +150% | Search, Display |
| Converted (Exclude) | 540 days | -100% | All |

## Landing Page Structure

```
┌─────────────────────────────────────────┐
│          ABOVE THE FOLD                 │
├─────────────────────────────────────────┤
│  Headline (matches ad) | Hero image     │
│  Subheadline (benefit) | CTA button     │
│  Trust badges                           │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│          BODY                           │
├─────────────────────────────────────────┤
│  Problem → Solution → Proof             │
│  Key benefits (3-4)                     │
│  Social proof (logos, testimonials)     │
│  FAQ (objection handling)               │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│          FOOTER CTA                     │
├─────────────────────────────────────────┤
│  Repeat offer + CTA button              │
└─────────────────────────────────────────┘
```

## Bid Strategy Phases

### Phase 1: Launch (Weeks 1-4)
| Campaign | Bid Strategy | Target |
|----------|--------------|--------|
| Brand | Manual CPC | Position 1 |
| Non-Brand High Intent | Maximize Conversions | N/A |
| Competitor | Manual CPC | Test |
| Retargeting | Maximize Conversions | N/A |

### Phase 2: Optimize (Weeks 5-8)
| Campaign | Bid Strategy | Target |
|----------|--------------|--------|
| Brand | Target Impression Share | 95% |
| Non-Brand High Intent | Target CPA | $[X] |
| Competitor | Target CPA | $[X] |
| Retargeting | Target CPA | $[X] |

### Phase 3: Scale (Week 9+)
| Campaign | Bid Strategy | Target |
|----------|--------------|--------|
| All | Target ROAS or Value-Based | [X]% |

## KPI Benchmarks

| Metric | Target | Warning | Action if Warning |
|--------|--------|---------|-------------------|
| CTR | >3% | <2% | Improve ad copy |
| Conv. Rate | >3% | <1.5% | Improve landing page |
| CPA | <$[X] | >$[X] | Lower bids, refine targeting |
| ROAS | >[X]x | <[X]x | Focus on high-intent |
| Quality Score | >7 | <5 | Improve relevance |

## Optimization Troubleshooting

### Low CTR (<2%)
- Test new headline angles
- Add negative keywords
- Tighten keyword match types

### High CPC
- Improve Quality Score
- Find long-tail alternatives
- Test manual bidding

### Low Conversion Rate (<1.5%)
- A/B test landing page
- Review search terms for intent
- Strengthen CTA and offer

### High CPA
- Tighten targeting
- Focus on high-intent keywords
- Lower bids
