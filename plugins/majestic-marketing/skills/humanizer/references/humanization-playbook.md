# Humanization Playbook

How AI detectors work and the specific transformations that defeat them. Each technique targets a measurable detection signal.

---

## How Detection Works

Detectors measure five signals. Humanization must move ALL five toward human baselines.

| Signal | What It Measures | AI Pattern | Human Pattern |
|--------|-----------------|------------|---------------|
| **Perplexity** | Word predictability | Smooth, mid-range (safe word choices) | Irregular spikes (surprising word choices) |
| **Burstiness** | Sentence length variance | Uniform length and structure | Mix of short and long, varied rhythm |
| **Entropy** | Vocabulary diversity | Repetitive at paragraph level | Higher type-token ratio, rare words |
| **Stylometry** | Punctuation, function words, structure | Regular patterns, heavy discourse markers | Idiosyncratic, personal habits |
| **Semantic coherence** | Topic flow between sentences | Ultra-smooth transitions | Discontinuities, asides, digressions |

---

## Transformation Techniques

### 1. Burstiness Injection

**Target signal:** Burstiness (sentence length variance)

**What to do:**
- Break uniform sentences into varied lengths
- Follow a long analytical sentence with a short punchy one
- Insert single-sentence paragraphs for emphasis
- Let some sentences run with commas and clauses
- Use fragments occasionally. Like this.

**Before:**
> The platform provides comprehensive analytics capabilities. Users can track their performance metrics in real-time. The dashboard offers customizable views for different stakeholders. Reports can be generated automatically on a weekly basis.

**After:**
> The analytics are solid. You get real-time performance tracking, customizable dashboards, and auto-generated weekly reports — the kind of stuff that used to take a full-time analyst. Most teams care about the dashboard views, though. That's where you'll spend your time.

### 2. Perplexity Boost

**Target signal:** Perplexity (word predictability)

**What to do:**
- Replace predictable phrases with less common but accurate alternatives
- Use domain-specific jargon where appropriate (not generic synonyms)
- Choose concrete nouns over abstract ones
- Prefer the unexpected-but-correct word over the safe one

**Before:** "This tool helps businesses improve their marketing efforts."
**After:** "This tool cut our cold email response rate from 2% to 11% in three weeks."

### 3. Structural Disruption

**Target signal:** Stylometry (structural patterns)

**Style context override:** Distinguish mechanical parallelism from intentional rhetorical devices. Anaphora (deliberate repetition of an opening phrase, e.g., "Context means X" ×5) is a rhetorical device, not an AI tell. If the pattern matches a signature move in the style context, preserve it. Dissolving anaphora into subject-verb enumeration ("It understands... It catches... The output sounds...") creates a stronger AI summarization signal than the original.

**What to do:**
- Break the intro-body-conclusion template
- Start with the conclusion or a specific example
- Vary paragraph length (1 sentence to 6+ sentences)
- Avoid mechanical headers ("Overview", "Key Features", "Conclusion")
- Break the rule of three — use 2 items, or 4, or 7
- Mix prose with lists instead of all-list or all-prose
- Preserve intentional repetition patterns that match style context signature moves

### 4. Voice Injection

**Target signal:** Semantic coherence + Stylometry

**Style context override:** When `STYLE_OVERRIDES` exist, skip any injection that conflicts:
- Zero-hedging voice → skip limitation/caveat injection entirely
- Low aside frequency (e.g., "max 2 per 1200 words") → respect the limit
- Author never hedges → don't add hedges. The caveat will read as the most AI-detectable paragraph in the piece.

**What to do:**
- Add personal experience or opinion with reasoning
- Include admissions of limitation ("This won't work if...") — unless style context specifies zero hedging
- Insert parenthetical asides (they break the smooth flow) — unless style context limits aside frequency
- Use rhetorical questions
- Add contextual humor — not jokes, just wry observations
- Show thought evolution ("I assumed X at first. Wrong.")

**Voice injection points:**
- After a factual claim → add personal validation or challenge
- At transitions → replace "Now let's discuss Y" with an opinion bridge
- Before recommendations → add honest caveats

### 5. Conversational Texture

**Target signal:** Stylometry + Entropy

**Style context override:** When `STYLE_OVERRIDES` specify punctuation rules, respect them. Some voices use zero em dashes (commas and periods only), zero parenthetical asides, or zero semicolons. Injecting these punctuation marks creates a stronger AI signal than the one you're trying to fix.

**What to do:**
- Use contractions (it's, don't, won't, can't)
- Address the reader directly (you, your)
- Use colloquialisms appropriate to audience
- Deploy metaphors and analogies from everyday life
- Include the occasional self-correction or qualification
- Add em dashes for rhythm — unless style context prohibits them
- Write how you'd explain it to a smart friend over coffee

### 6. Specificity Over Abstraction

**Target signal:** Perplexity + Entropy

**What to do:**
- Replace generic claims with specific numbers, dates, names
- Swap "many companies" for "Stripe, Shopify, and Linear"
- Replace "significantly improved" with "went from 12% to 34%"
- Name tools, people, places — specifics are hard to fake
- Include concrete examples, not hypothetical ones

### 7. Imperfection Tolerance

**Target signal:** Stylometry (perfect grammar detection)

**What to do:**
- Allow natural contractions and informal grammar
- Don't over-edit into corporate polish
- Let some sentences start with "And" or "But"
- Permit the occasional dash-heavy sentence — like this one — when it fits (skip if style context = zero em dashes)
- End with prepositions when it sounds natural (that's what we're here for)
- Use "they" as singular when appropriate

**Do NOT:** Add random typos or errors. That's manipulation, not humanization. The goal is natural imperfection, not artificial mistakes.

---

## Transformation Order

Apply techniques in this sequence for best results:

1. **Prohibited words scan** — Replace banned vocabulary first (fastest wins)
2. **Structural disruption** — Break template patterns, reorder sections
3. **Burstiness injection** — Vary sentence lengths throughout
4. **Voice injection** — Add personal elements, opinions, caveats
5. **Specificity pass** — Swap abstractions for concrete details
6. **Conversational texture** — Add contractions, direct address, informality
7. **Perplexity boost** — Final pass for unexpected-but-accurate word choices

---

## Quick Detection Self-Test

After humanizing, verify:

```
[ ] No 3+ banned words in any single paragraph
[ ] Sentence lengths vary (some under 5 words, some over 25)
[ ] At least one personal opinion or experience per 500 words
[ ] At least one specific number or named example per 500 words
[ ] At least one admission of limitation or caveat per 1000 words (SKIP if style context = zero hedging)
[ ] Not everything grouped in threes
[ ] No "In today's..." openings or "In conclusion..." closings
[ ] No mechanical negation-assertion patterns — rhetorical fragment pairs are OK
[ ] Punctuation respects style context constraints (em dashes, asides, etc.)
[ ] Intentional rhetorical devices from style context preserved
[ ] Would I say this out loud to a smart friend?
[ ] Each paragraph has a different rhythm than the one before it
[ ] No section is suspiciously the same length as another
```
