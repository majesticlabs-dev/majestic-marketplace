---
name: elevator-pitch
description: Create compelling 30/60/90-second elevator pitches using the Villain-Hero storytelling framework, customized for different investor types with psychological hooks, timing markers, and word-for-word scripts.
allowed-tools: Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# Elevator Pitch Creator

**Audience:** Founders preparing to pitch investors (VCs, angels, accelerators) who need word-for-word scripts at multiple lengths.

**Framework:** Villain-Hero storytelling—investors fund heroes who slay villains, not features. Structure every pitch around a recognizable problem (villain) and your unique solution (hero).

## Conversation Starter

Use `AskUserQuestion` to gather initial context. Begin by asking:

"I'll help you craft elevator pitches that make investors lean in and ask for more.

The best pitches tell a story: they introduce a **villain** (the problem) that your audience recognizes, then present you as the **hero** with the weapon to defeat it.

To create your pitch arsenal, I need to understand:

1. **The Problem/Villain**: What painful problem are you solving? Who suffers from it and how badly?
2. **Your Solution/Weapon**: How do you solve it? What's your unique approach?
3. **Your Superpower**: What unfair advantage do you have? (team expertise, technology, data, network)
4. **Traction Proof**: Any evidence this works? (customers, revenue, growth, testimonials)
5. **Target Investors**: Who are you pitching to? (VCs, angels, accelerators, strategics)
6. **The Ask**: What are you raising and for what milestones?

I'll research your industry and competitors, then create multiple pitch versions customized for different investor types and contexts."

## Research Methodology

Use WebSearch extensively to find:
- How competitors pitch themselves (investor decks, press releases, TechCrunch coverage)
- Industry-specific language and metrics investors expect
- Recent funding rounds in the space (who's investing, at what valuations)
- Market trends and growth projections to reference
- Successful pitch examples from similar startups
- Common objections investors raise in this market

## The Villain-Hero Framework

Every powerful pitch follows this narrative arc:

```
┌─────────────────────────────────────────────────────────────┐
│  ACT 1: THE VILLAIN                                         │
│  Introduce the problem as a villain your audience knows     │
│  Make them feel the pain. Make them hate the villain.       │
├─────────────────────────────────────────────────────────────┤
│  ACT 2: THE HERO EMERGES                                    │
│  You (and your team) are the hero with the unique weapon    │
│  Show why YOU are destined to slay this villain             │
├─────────────────────────────────────────────────────────────┤
│  ACT 3: THE VICTORY                                         │
│  Paint the picture of the world after the villain is dead   │
│  Proof it's working. The call to join the quest.            │
└─────────────────────────────────────────────────────────────┘
```

## Required Deliverables

### 1. Villain Analysis

Before writing pitches, deeply understand the villain:

```markdown
## THE VILLAIN: [Problem Name]

**Villain's Victims:** [Who suffers]
**Villain's Damage:** [Quantified pain - money lost, time wasted, lives affected]
**Villain's Disguise:** [Why hasn't this been solved? What makes it tricky?]
**Villain's Weakness:** [The insight that lets you beat it]

### Villain Introduction Lines
- "[Statistic that shocks] — that's how much [villain] costs [victims] every year."
- "Every [time period], [number of people] struggle with [villain]."
- "[Personal story or customer quote about the villain]"
- "Right now, [victims] are forced to [painful workaround]."
```

### 2. Hero Positioning

Define your unique hero qualities:

```markdown
## THE HERO: [Company Name]

**Hero's Weapon:** [Your unique solution/approach]
**Hero's Origin Story:** [Why you? What makes you the destined hero?]
**Hero's Proof:** [Evidence the weapon works]
**Hero's Quest:** [Vision of the world you're creating]

### Hero Introduction Lines
- "We [built/discovered/developed] [solution] that [specific outcome]."
- "Our team at [Company] has [relevant credibility]."
- "Unlike [alternatives], we [key differentiator]."
```

### 3. Investor-Customized Pitches

Create three distinct versions, each emphasizing what that investor type values most:

#### A. Technical Investor Pitch
*For: Technical VCs, engineers-turned-investors, deep tech funds*

| Element | Focus | Example Phrases |
|---------|-------|-----------------|
| Villain | Technical complexity | "The legacy stack..." |
| Hero | Innovation, IP | "Our proprietary algorithm..." |
| Proof | Technical moat | "We're 10x faster because..." |
| Metrics | Performance, patents | "Processing time, accuracy..." |

**Script Structure:**
```
[0:00-0:15] THE VILLAIN - Technical problem statement
"[Industry] runs on [outdated approach]. The result? [Technical pain point
with specific numbers]. It's not that people haven't tried to fix this—
[Previous attempts] failed because [technical reason]."

[0:15-0:40] THE HERO - Your technical innovation
"We built [Product]. Unlike [alternatives], we [technical differentiator].
Our team includes [technical credibility]. We've [technical achievement]."

[0:40-0:55] THE VICTORY - Proof and potential
"[Customer/pilot] is already seeing [specific technical improvement].
Our architecture enables [future capability]."

[0:55-0:60] THE ASK
"We're raising [amount] to [technical milestone]. I'd love to show you
how [technical deep-dive offer]."
```

#### B. Market-Focused Investor Pitch
*For: Growth VCs, business-focused angels, institutional investors*

| Element | Focus | Example Phrases |
|---------|-------|-----------------|
| Villain | Market inefficiency | "A $X billion market..." |
| Hero | Business model | "We've cracked the..." |
| Proof | Traction metrics | "Growing X% MoM..." |
| Metrics | Revenue, CAC/LTV, TAM | "Unit economics show..." |

**Script Structure:**
```
[0:00-0:15] THE VILLAIN - Market opportunity
"[Industry] is a $[X] billion market where [painful inefficiency].
Companies waste $[Y] annually on [workaround]. Despite this, no one has
solved it because [barrier to entry/insight]."

[0:15-0:40] THE HERO - Your business breakthrough
"[Company] is [one-line description]. We've discovered that [insight].
Our model [business model advantage]. We're seeing [key metric]."

[0:40-0:55] THE VICTORY - Growth story
"We launched [timeframe] ago and have [traction proof]. Our customers
include [notable names/segments]. We're growing [growth rate]."

[0:55-0:60] THE ASK
"We're raising [amount] at [terms if appropriate] to [growth milestone].
[Urgency if applicable—competitive funding, closing soon]."
```

#### C. Customer-Obsessed Investor Pitch
*For: Consumer investors, impact funds, customer-centric VCs*

| Element | Focus | Example Phrases |
|---------|-------|-----------------|
| Villain | User pain | "Sarah spends 4 hours..." |
| Hero | User experience | "Now Sarah just..." |
| Proof | User love | "Our NPS is 72..." |
| Metrics | Retention, NPS, testimonials | "Users stay because..." |

**Script Structure:**
```
[0:00-0:15] THE VILLAIN - Personal story
"Meet [persona]. Every [time period], [they] struggle with [problem].
[Emotional detail]. [They're] not alone—[X million] people face this
exact frustration."

[0:15-0:40] THE HERO - Transformation story
"Now, [persona] uses [Product]. Instead of [old way], [they] simply
[new way]. [Quote or reaction]. What changed? We [insight/innovation]."

[0:40-0:55] THE VICTORY - User love proof
"[Persona] isn't unique. Our [number] users [engagement proof].
[Testimonial snippet]. Our NPS is [score], with [retention metric]."

[0:55-0:60] THE ASK
"We're raising [amount] to bring this to [expansion]. [Compelling
user-centric vision]."
```

### 4. Pitch Length Variations

#### 10-Second One-Liner
```
"We're [Company]—we [action verb] for [audience] so they can [outcome]."

OR (Analogy version):
"We're the [known company] of [your market]."

OR (Problem-Solution):
"[Big number] [people/companies] waste [resource] on [problem].
We [solution]."
```

#### 30-Second Pitch
```
[0:00-0:10] VILLAIN
"[Shocking statistic or story about the problem]"

[0:10-0:20] HERO
"[Company] [solves how]. [Key differentiator]."

[0:20-0:30] VICTORY + ASK
"[Traction proof]. We're raising [amount] for [milestone]."
```

#### 60-Second Pitch
*(Use the investor-type scripts above)*

#### 90-Second Pitch
Add to 60-second version:
```
[Additional 0:30 after the ask]

EXPANDED PROOF & VISION:
"Let me give you one example. [Specific customer story with numbers].

What excites us most is [vision]. As [market trend], we're positioned
to [strategic opportunity]. Our next milestone is [specific goal],
and with this raise, we'll [concrete achievement].

Can we schedule 30 minutes to dive deeper?"
```

### 5. Pitch Variations by Context

#### Conference/Networking Version
- Lead with curiosity hook
- Conversational, not performative
- End with exchange (card, LinkedIn, meeting request)

#### Cold Email/LinkedIn Version
- Subject line = villain hook
- First line = relevance to recipient
- Body = compressed 30-second pitch
- CTA = specific, low-friction ask

#### Investor Meeting Opener
- Acknowledge their portfolio/expertise
- Villain with "you've probably seen this" framing
- Sets up deeper deck walkthrough

#### Follow-Up/Second Meeting Version
- Reference previous conversation
- Address any concerns raised
- Advance the narrative with new proof

### 6. Psychological Hooks Library

**Problem Recognition Hooks:**
- "[Big number] [companies/people] still [outdated behavior]."
- "You've probably noticed that [observable trend]."
- "The last time [industry] innovated was [date]."

**Urgency/FOMO Hooks:**
- "[Trend] is accelerating. The window to capture [market] is [timeframe]."
- "[Competitor funding news or market timing]."
- "We're talking to [other investors] but wanted to give you first look."

**Credibility Hooks:**
- "I spent [X years] at [notable company] where I saw [insight]."
- "[Notable person/company] is already [using/advising/investing]."
- "We're the team that [previous achievement]."

**Contrast Hooks:**
- "Unlike [competitor/alternative], we [key difference]."
- "Everyone else [common approach]. We [contrarian approach]."
- "The old way: [pain]. Our way: [gain]."

### 7. Delivery Coaching

**Body Language Tips:**
- Stand grounded, shoulders back (confidence without arrogance)
- Maintain eye contact during villain setup (draw them in)
- Use hands to illustrate scale and transformation
- Pause before the ask (let tension build)

**Voice Modulation:**
- Lower pitch for villain (gravity, seriousness)
- Raise energy for hero/solution (excitement)
- Slow down on key numbers (let them land)
- Speed up slightly on context (keep momentum)

**Common Mistakes to Avoid:**
- Starting with your company name (boring, forgettable)
- Feature dumping (they don't care yet)
- Vague market sizing ("it's a huge market")
- No clear ask (what do you want them to DO?)
- Apologizing or hedging ("we're still early, but...")
- Not knowing when to stop (leave them wanting more)

### 8. Iteration Framework

**A/B Testing Your Pitch:**

| Test | Version A | Version B | Measure |
|------|-----------|-----------|---------|
| Hook | Stat-based | Story-based | Engagement |
| Villain | Industry | Personal | Emotional response |
| Proof | Metrics | Testimonial | Credibility |
| Ask | Specific | Open | Conversion |

**Feedback Collection After Each Pitch:**
1. Did they lean in or lean back?
2. What questions did they ask?
3. What did they remember when summarizing back?
4. Did they offer to introduce or follow up?

**Refinement Triggers:**
- Same question from 3+ investors → Add clarity to pitch
- Confusion about market → Strengthen villain setup
- "What makes you different?" → Sharpen hero positioning
- No follow-up → Revisit urgency and ask

## Output Format

```markdown
# ELEVATOR PITCH ARSENAL: [Company Name]

## PITCH STRATEGY OVERVIEW
[2-3 sentences on villain-hero positioning and key angles]

---

## SECTION 1: VILLAIN-HERO ANALYSIS
[Deep villain and hero positioning]

---

## SECTION 2: INVESTOR-CUSTOMIZED PITCHES
[Three full scripts: Technical, Market, Customer]

---

## SECTION 3: LENGTH VARIATIONS
[10s, 30s, 60s, 90s versions]

---

## SECTION 4: CONTEXT ADAPTATIONS
[Conference, email, meeting opener, follow-up]

---

## SECTION 5: PSYCHOLOGICAL HOOKS
[Customized hooks for this specific business]

---

## SECTION 6: DELIVERY NOTES
[Specific coaching for this pitch]

---

## SECTION 7: ITERATION PLAN
[What to test and track]

---

## QUICK REFERENCE CARD
[Pocket cheat sheet with key lines]
```

## Quality Standards

- **Research real context**: Use WebSearch to find actual competitor language, market stats, recent funding
- **Be specific**: Real numbers, real names, real stories beat vague claims
- **Honor the villain**: A weak villain = weak pitch. Make them feel the pain.
- **Keep the hero humble**: Confidence yes, arrogance no
- **Test the timing**: Read aloud and time each section
- **End with action**: Every version needs a clear ask

## Tone

Confident, conversational, and compelling. Write like a founder who truly believes they're going to change the world—because conviction is contagious. No corporate speak, no buzzword bingo. Tell a story that matters.
