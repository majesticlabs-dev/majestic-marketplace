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
disable-model-invocation: true
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

---

## Methodology

Three phases: Diagnose → Transform → Verify.

### Phase 1: Diagnose

Read the input text and score it against five detection signals.

**Signal scan:**

| Signal | Check For | Red Flag |
|--------|-----------|----------|
| Perplexity | Every word feels predictable, "safe" | No surprising word choices anywhere |
| Burstiness | Sentences all similar length | Std dev of sentence length < 5 words |
| Entropy | Same words/phrases repeated | 3+ banned words in one paragraph |
| Stylometry | Perfect grammar, uniform structure | Mechanical parallelism, rule-of-three |
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
- Negation-assertion pattern? ("This isn't X. This is Y.") — fatal, always rewrite
- **Bolded Inline Header:** colon pattern?

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

### Phase 2: Transform

Apply transformations from `references/humanization-playbook.md` in this order:

**Step 1: Kill prohibited words**
- Replace every banned word/phrase using substitution tables
- If 3+ banned words cluster in a paragraph, rewrite the whole paragraph
- Don't just swap synonyms — rephrase the sentence

**Step 2: Break the structure**
- If essay template detected: start with the most interesting point, cut the summary conclusion
- If everything is in threes: use the actual count (2, 4, 5, whatever fits)
- If negation-assertion found: delete the negation, keep only the positive claim
- If sections are suspiciously uniform length: merge short ones, split long ones
- Replace generic headers ("Overview", "Key Features") with specific ones

**Step 3: Inject burstiness**
- Identify runs of 3+ sentences with similar length
- Break them: shorten one to under 6 words, extend another past 25
- Add a single-sentence paragraph where emphasis helps
- Allow one fragment per 500 words

**Step 4: Add voice**
- Insert at least one opinion or stance per 500 words
- Add at least one caveat or limitation per 1000 words ("This won't work if...")
- Replace smooth transitions with opinion bridges
- Add parenthetical asides where natural (like this)
- Use rhetorical questions sparingly (one per 1000 words max)

**Step 5: Make it specific**
- Replace "many companies" with named examples
- Replace "significantly improved" with actual numbers
- Replace "experts say" with named sources or remove the claim
- Convert abstract benefits to concrete outcomes

**Step 6: Conversational pass**
- Add contractions (it's, don't, won't, can't, we're)
- Use "you" and "your" for direct address
- Start some sentences with "And" or "But"
- End with prepositions when natural
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
[ ] No 3+ banned words in any single paragraph
[ ] Sentence lengths vary (some under 5 words, some over 25)
[ ] At least one personal opinion or experience per 500 words
[ ] At least one specific number or named example per 500 words
[ ] At least one limitation or caveat per 1000 words
[ ] Not everything grouped in threes
[ ] No "In today's..." openings or "In conclusion..." closings
[ ] No negation-assertion patterns ("This isn't X. This is Y.")
[ ] Each paragraph has different rhythm than neighbors
[ ] No section suspiciously same length as another
[ ] No engagement bait ("Let that sink in", "Read that again")
[ ] No sycophantic phrases ("I hope this helps")
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
