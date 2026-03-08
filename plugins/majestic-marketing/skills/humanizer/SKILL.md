---
name: humanizer
description: Rewrite AI-generated text to sound naturally human-written. Strips AI vocabulary, injects burstiness and voice, defeats detection patterns. Use when content sounds robotic, generic, or flags AI detectors.
triggers:
  - humanize this
  - make it sound human
  - sounds too AI
  - AI detection
  - rewrite to sound natural
  - sounds robotic
  - too generic
  - pass AI detector
allowed-tools: Read Write Edit Glob Grep AskUserQuestion
---

# Humanizer

Rewrite AI-generated text so it reads like a skilled human wrote it. Not paraphrasing — structural transformation that changes how the text *feels*.

## When to Use

- Text sounds robotic, generic, or overly polished
- Content flags AI detection tools
- Blog posts, marketing copy, or emails feel "off"
- Need to match natural human writing patterns
- After AI-generated first drafts before publication

## When NOT to Use

- Code cleanup → use `slop-remover` agent instead
- Grammar/style review without rewriting → use `copy-editor` skill
- Writing in a specific brand voice → use `brand-voice` + `style-writer`
- Creating SEO content from scratch → use `seo-content` (has built-in humanization)
- **After `style-writer` without providing the Style DNA report** → the humanizer will treat intentional stylistic devices (anaphora, fragment pairs, zero-hedging, zero-em-dash styles) as AI tells and replace them with its own AI tells. If you must humanize voice-matched content, provide the Style DNA report (`style-forensics` output) as style context (see Phase 0)

---

## Methodology

Four phases: Style Context → Diagnose → Transform → Verify.

### Phase 0: Style Context Detection

Before diagnosing, check if the input has style constraints that override default rules.

**Detection order:**
1. User explicitly provides a Style DNA report (`*-style-dna.md` from `style-forensics`), brand-voice guide, or style constraints
2. User mentions the text was written with `style-writer` or matches a specific author
3. A `*-style-dna.md` file exists alongside the source content

If style context is found, read it and extract these overrides:

| Constraint | Style DNA Report Section | Default (no context) |
|------------|--------------------------|----------------------|
| Permitted rhetorical devices | Signature Devices → anaphora, fragment patterns, contrast patterns | None — flag all repetition |
| Punctuation rules | Punctuation DNA → em dash total, semicolons, colons | Em dashes, parentheticals OK |
| Hedging tolerance | Tone Profile → Hedging Language (count per 100 words) | Require 1 caveat per 1000 words |
| Aside frequency | Punctuation DNA → parenthetical asides (total, per 100 words) | Inject where natural |
| Absence patterns | Any metric reporting zero — absence is data | No restrictions |

**Zero counts are constraints.** If the Style DNA reports 0 em dashes, 0 parenthetical asides, or 0 hedging instances, these are hard constraints — do not inject what the author never uses.

**Store as `STYLE_OVERRIDES` for Phase 1-3.** When no style context exists, all defaults apply and the skill works exactly as before.

**If style context is detected but not provided:** Ask with `AskUserQuestion`: "This text appears to be voice-matched. Do you have a Style DNA report or brand-voice file I should respect? Without it, I may rewrite intentional stylistic devices."

### Phase 1: Diagnose

Read the input text and score it against five detection signals.

**Signal scan:**

| Signal | Check For | Red Flag |
|--------|-----------|----------|
| Perplexity | Every word feels predictable, "safe" | No surprising word choices anywhere |
| Burstiness | Sentences all similar length | Std dev of sentence length < 5 words |
| Entropy | Same words/phrases repeated | 3+ banned words in one paragraph |
| Stylometry | Perfect grammar, uniform structure | Mechanical parallelism, rule-of-three (but see style-aware check below) |
| Coherence | Every sentence flows too smoothly | No asides, digressions, or opinion |

**Prohibited words scan:**
- Check against `references/prohibited-words.md`
- Count banned word clusters per paragraph
- Flag banned phrases

**Structural pattern scan:**
- Intro-body-conclusion essay template?
- Mechanical "on one hand / on the other" balance?
- Formulaic "Challenges and Future Prospects" section?
- Everything grouped in threes?
- Negation-assertion pattern? Distinguish two forms:
  - **Mechanical** (rewrite): "This isn't just X. This is Y." / "It's not about X. It's about Y." — full-sentence negation followed by full-sentence assertion with parallel structure
  - **Rhetorical fragment** (preserve): "Not a question. A system." / "Not theory. Practice." — short fragment pairs used for emphasis. These are a deliberate device, not an AI tell
  - If `STYLE_OVERRIDES` lists fragment pairs as a signature move → always preserve
- **Bolded Inline Header:** colon pattern?

**Style-aware check (when `STYLE_OVERRIDES` exist):**

Before flagging a pattern, check whether the style context explains it:
- Anaphoric repetition (e.g., "Context means X" ×5) → check Style DNA Signature Devices for anaphora/repetition patterns. If documented, mark as **intentional device**, not a detection signal
- Consistent fragment pairs → check Style DNA for fragment stacking patterns
- "Not X. Y." contrast patterns → check Style DNA Signature Devices for this exact pattern
- Uniform sentence structure in a passage → check Style DNA sentence length distribution for documented rhythm patterns

**Rule:** A pattern explained by style context is not an AI tell. Only flag patterns that exist *despite* (or *absent*) style context.

**Report format:**

```
## Diagnosis

**AI Confidence:** [High/Medium/Low] — [1-sentence justification]

**Signals flagged:**
- Perplexity: [OK/FLAG] — [detail]
- Burstiness: [OK/FLAG] — [detail]
- Entropy: [OK/FLAG] — [detail]
- Stylometry: [OK/FLAG] — [detail]
- Coherence: [OK/FLAG] — [detail]

**Banned words found:** [count] — [list top offenders]
**Banned phrases found:** [count] — [list]
**Structural patterns:** [list patterns detected]
```

**Early exit:** If AI Confidence is Low (0-1 signals flagged, no banned word clusters), stop and tell the user the text already reads human. Don't transform text that doesn't need it.

### Phase 2: Transform

Apply transformations from `references/humanization-playbook.md` in this order:

**Step 0: Lock factual anchors**

Before any transformation, identify and protect content that must survive unchanged:
- Specific numbers, dollar amounts, percentages, dates
- Proper nouns: people, companies, products, places
- URLs, file paths, code blocks, technical terms
- Direct quotes and attributed statements
- Statistics and data points ("45,000 rows", "$14,000/month", "130,000 times")

These are untouchable. External humanizer tools destroy meaning by replacing "20 million views" with "20 black views" or "$14,000" with garbled text. Our advantage is understanding what words mean — never trade accuracy for style.

**Step 1: Kill prohibited words**
- Replace every banned word/phrase using substitution tables
- If 3+ banned words cluster in a paragraph, rewrite the whole paragraph
- Don't just swap synonyms — rephrase the sentence

**Step 2: Break the structure**
- If essay template detected: start with the most interesting point, cut the summary conclusion
- If everything is in threes: use the actual count (2, 4, 5, whatever fits)
- If mechanical negation-assertion found: delete the negation, keep only the positive claim. Preserve rhetorical fragment pairs ("Not X. Y.") — these are intentional devices, not AI tells
- If sections are suspiciously uniform length: merge short ones, split long ones
- Replace generic headers ("Overview", "Key Features") with specific ones

**Step 3: Inject burstiness**
- Identify runs of 3+ sentences with similar length
- Break them: shorten one to under 6 words, extend another past 25
- Add a single-sentence paragraph where emphasis helps
- Allow one fragment per 500 words

**Step 4: Add voice** (respect `STYLE_OVERRIDES` — skip any injection the style prohibits)
- Insert at least one opinion or stance per 500 words
- Add at least one caveat or limitation per 1000 words ("This won't work if...") — **skip if `STYLE_OVERRIDES` indicate zero-hedging voice** (author presents claims as settled fact)
- Replace smooth transitions with opinion bridges
- Add parenthetical asides where natural (like this) — **skip or limit if `STYLE_OVERRIDES` specify low aside frequency** (e.g., "max 2 per 1200 words")
- Use rhetorical questions sparingly (one per 1000 words max)

**Step 5: Make it specific**
- Replace "many companies" with named examples
- Replace "significantly improved" with actual numbers
- Replace "experts say" with named sources or remove the claim
- Convert abstract benefits to concrete outcomes

**Step 6: Conversational pass** (respect `STYLE_OVERRIDES` punctuation rules)
- Add contractions (it's, don't, won't, can't, we're)
- Use "you" and "your" for direct address
- Start some sentences with "And" or "But"
- End with prepositions when natural
- Add em dashes for rhythm and texture — **skip if `STYLE_OVERRIDES` specify zero em dashes** (some voices rely entirely on commas and periods)
- Write how you'd explain it over coffee — then tighten

**Step 7: Final perplexity boost**
- Read each paragraph aloud mentally
- Where every word feels predictable, swap one for an unexpected-but-accurate choice
- Prefer the specific over the generic, the concrete over the abstract
- Don't overdo it — one surprise per paragraph is enough

### Phase 3: Verify

Run the detection self-test after transformation.

**Verification checklist:**

```
[ ] All factual anchors preserved (numbers, names, stats, quotes unchanged)
[ ] No 3+ banned words in any single paragraph
[ ] Sentence lengths vary (some under 5 words, some over 25)
[ ] At least one personal opinion or experience per 500 words
[ ] At least one specific number or named example per 500 words
[ ] At least one limitation or caveat per 1000 words (SKIP if STYLE_OVERRIDES = zero-hedging)
[ ] Not everything grouped in threes
[ ] No "In today's..." openings or "In conclusion..." closings
[ ] No mechanical negation-assertion patterns — rhetorical fragment pairs are OK
[ ] Each paragraph has different rhythm than neighbors
[ ] No section suspiciously same length as another
[ ] No engagement bait ("Let that sink in", "Read that again")
[ ] No sycophantic phrases ("I hope this helps")
[ ] Punctuation matches STYLE_OVERRIDES constraints (em dashes, asides, etc.)
[ ] Intentional rhetorical devices from style context preserved (anaphora, fragments)
[ ] Would I say this out loud to a smart friend?
```

If any check fails, return to Phase 2 and fix the specific issue.

---

## Output Format

Present the humanized text with a brief change summary.

```markdown
## Humanized Version

[Full rewritten text]

---

## Changes Applied

**Banned words replaced:** [count]
- [word] → [replacement] (×[count])

**Structural changes:**
- [Change 1]
- [Change 2]

**Voice injections:**
- [What was added and where]

**Verification:** All checks passed / [list remaining concerns]
```

---

## Calibration by Content Type

Different content types need different humanization intensity.

| Content Type | Burstiness | Voice | Informality | Specificity |
|-------------|-----------|-------|-------------|-------------|
| Blog post | High | High | Medium-High | High |
| Marketing copy | High | Medium | Medium | High |
| Email | Medium | High | High | Medium |
| Documentation | Low | Low | Low | High |
| Social media | High | High | High | Medium |
| White paper | Medium | Medium | Low | High |
| Landing page | High | Medium | Medium-High | High |

Adjust transformation intensity based on this table. Documentation gets light touch; blog posts get full treatment.

---

## Principles

1. **Transform, don't paraphrase.** Synonym swapping without structural change is shallow and detectable.
2. **Imperfect on purpose.** Natural writing has rough edges. Don't over-polish.
3. **Specificity is the best humanizer.** Concrete details are hard to fake and easy to trust.
4. **Voice > vocabulary.** Swapping words helps; adding genuine perspective transforms.
5. **Respect the content.** Don't inject humor into serious topics or casualness into formal contexts.
6. **The coffee test.** If you wouldn't say it to a smart friend over coffee, rewrite it.

---

## Integration

Complementary skills in the writing pipeline:

```
[AI draft] → humanizer → copy-editor → brand-voice
```

- **Before humanizer:** Any AI-generated first draft
- **After humanizer:** `copy-editor` for grammar/style polish, `brand-voice` for voice consistency
- **Instead of humanizer:** `seo-content` (has built-in humanization for new content)
- **For code:** `slop-remover` agent (different domain, same concept)

**Pipeline with voice-matched content:**

```
[source samples] → style-forensics → Style DNA report
[AI draft] → style-writer (with Style DNA) → humanizer (with same Style DNA) → copy-editor
```

Never run humanizer after `style-writer` without providing the same Style DNA report as style context. The humanizer will destroy the voice work otherwise.
