---
name: style-writer
description: |
  Write a new article matching a specific author's voice using a Style DNA report
  as the blueprint. Takes a style-dna.md file and a topic, produces an article
  that hits the exact measured metrics. Use when asked to ghostwrite, write in
  someone's style, or produce content matching a forensic style profile.
  Not for creating the voice profile itself (use brand-voice).
triggers:
  - write in my voice
  - ghostwrite
  - write in style
  - match my voice
  - style dna
  - write like me
allowed-tools: Read Write Edit Glob Grep AskUserQuestion
---

# Style Writer

Write an article on: $ARGUMENTS

**Audience:** Content creators with a Style DNA or brand voice report who need new articles written in that exact voice.

**Goal:** Produce articles that match a measured voice fingerprint precisely — hitting the numbers, not approximating.

---

## Phase 1: Load the Style DNA

Read the style-dna.md file specified by the user. Extract and internalize:

1. **Hard metrics** from the Quick Reference Card (sentence length, short ratio, comma density, paragraph length, etc.)
2. **Punctuation rules** (what's used, what's forbidden)
3. **Signature devices** with their frequencies (fragment stacking, conjunction openers, landing patterns, etc.)
4. **Structural blueprint** (opening pattern, body organization, closing pattern)
5. **Tone profile** (POV, hedging placement, emotional register)
6. **Banned patterns** if listed
7. **Vocabulary character** (lexical diversity, thematic anchoring terms, accessibility level)

If the DNA file has a Cross-Article Comparison with multiple modes (e.g., "workshop tour" vs. "war story"), determine which mode fits the requested topic and target word count. State which mode you're using and why.

---

## Phase 2: Plan the Article

Before writing a single sentence, build a skeleton:

### Core thesis
State the single boldest, most specific claim about this topic in one sentence. This becomes your opening.

### Historical anchor or analogy
What prior shift, pattern, or concrete comparison grounds this piece? Identify it.

### Specifics inventory
List the concrete details you'll use:
- 2-4 named companies, people, or products
- 3-5 specific numbers, dollar amounts, or data points
- 1 attributed quote (if available and natural)
- 2-3 concrete scenarios or examples

### Section plan
Outline 3-5 headed sections. For each, note:
- Section thesis (1 sentence)
- Key evidence or example
- Landing sentence or fragment

### Opening and closing
Plan the first 3-4 paragraphs and last 3-4 paragraphs according to the structural blueprint from the DNA.

**Present the plan to the user and wait for approval before drafting.**

---

## Phase 3: Draft the Article

Write the full article following the plan. While drafting, actively manage these constraints:

### Rhythm management
- After every 2-3 sentences in the 16-25 word range, drop one in the 1-7 range
- Never stack more than 2 long sentences (26+) consecutively
- Use fragment stacking at the frequency specified in the DNA
- Hit the target sentence length distribution across the full piece

### Punctuation compliance
- Use ONLY the punctuation marks the DNA permits
- If em dashes are zero in the DNA, use zero em dashes. No exceptions.
- Hit the target comma density (check after drafting)
- Use colons, semicolons, and parentheticals at the DNA's measured frequency

### Device placement
- Place signature devices at their measured frequency
- Distribute conjunction openers (And/But/Or/So) evenly, not clustered
- Place rhetorical questions where the DNA indicates (section openers? clusters? dismissals?)
- Use landing patterns ("That's...", fragments, one-sentence paragraphs) at section closes

### Tone calibration
- Match the POV (first person singular? plural? mixed?)
- Place hedges on the same type of claims the DNA shows (predictions? data? never on thesis?)
- Match the emotional register (profanity only if DNA shows it, and only at equivalent intensity points)
- Use contractions at the DNA's measured rate

### Vocabulary
- Keep lexical diversity near the DNA's target
- Repeat key topic terms deliberately (thematic anchoring), don't synonym-hunt
- Match the long-word percentage
- Use the same accessibility level: if the DNA shows accessible vocabulary, don't go academic

---

## Phase 4: Self-Audit

After completing the draft, run a verification pass. For each metric, compare your draft against the DNA target:

### Metrics to check

Use Python or manual counting to measure your draft:

| Metric | DNA Target | Your Draft | Accuracy |
|---|---|---|---|
| Avg sentence length | | | |
| Short sentence ratio (<8 words) | | | |
| Comma density per 100w | | | |
| Colon density per 100w | | | |
| Semicolons | | | |
| Em/en dashes | | | |
| One-sentence paragraph % | | | |
| Avg paragraph length (words) | | | |
| Conjunction openers % | | | |
| Rhetorical questions (count) | | | |
| Parenthetical asides (count) | | | |
| Contractions per 100w | | | |
| You/your per 100w | | | |
| I/my/me per 100w | | | |
| Exclamation marks | | | |

### Accuracy scoring
For each metric, calculate accuracy as:
```
accuracy = 100 - abs(target - actual) / target * 100
```
Clamp to 0-100%. Report the average across all metrics.

### Fix pass
If any metric is below 80% accuracy:
1. Identify which sentences or paragraphs are pulling the metric off target
2. Revise those specific passages
3. Re-measure to confirm improvement

Do NOT present the draft until the average accuracy is above 85% and no single metric is below 70%.

---

## Phase 5: Present the Draft

Show the user:

1. **The article** in full
2. **The accuracy table** (side-by-side comparison of DNA targets vs. draft metrics with accuracy percentages)
3. **Overall accuracy score** (average of all metric accuracies)
4. **Device checklist** noting which signature devices were used and their counts

Then ask:

> Article ready at [X]% overall style accuracy. Want me to save it, or revise specific sections?

Wait for the user's direction before saving.

---

## Execution Notes

- If the user doesn't specify a style-dna.md file, check for any `*-style-dna.md` or `voice-dna.md` files in `.claude/` and the current directory. Ask which one to use.
- If multiple DNA files exist for the same author, prefer the one from the longer source article (it captures the fuller voice).
- Target word count: match the source article's length unless the user specifies otherwise.
- Never sacrifice readability to hit a metric. If hitting a number makes a sentence awkward, prioritize natural flow and note the deviation.
- The banned phrases list is absolute. Zero tolerance. Check every sentence against it.

---

## Integration

Works with the content creation pipeline:

```
brand-voice (create DNA) → style-writer (write in that voice) → humanizer (strip AI tells) → copy-editor (polish)
```

- **Before style-writer:** `brand-voice` to create the Style DNA report
- **After style-writer:** `humanizer` to strip any remaining AI patterns, `copy-editor` for final polish
- **Instead of style-writer:** `content-writer` for general articles without a voice target, `seo-content` for SEO-first articles
