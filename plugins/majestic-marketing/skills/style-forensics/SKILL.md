---
name: style-forensics
description: |
  Forensic style analysis of a writing sample. Measures sentence length, rhythm,
  punctuation DNA, vocabulary, tone, rhetorical devices, and verbal tics.
  Outputs a Style DNA report. Use when asked to analyze writing style, extract
  voice metrics, or create a style fingerprint. Not for writing in a voice (use
  style-writer). Not for codifying brand guidelines (use brand-voice).
triggers:
  - analyze writing style
  - style forensics
  - style dna
  - voice fingerprint
  - style analysis
  - extract voice
  - writing analysis
  - measure writing style
allowed-tools: Read Write Edit Glob Grep Bash
---

# Style Forensics

Analyze: $ARGUMENTS

**Audience:** Writers and content creators who need a precise, measured voice fingerprint for use with `style-writer` and `humanizer`.

**Goal:** Extract quantitative style metrics from writing samples and produce a Style DNA report. Measure, don't guess.

---

## Phase 1: Extract Prose

Strip the file to prose only before measuring anything. Remove:
- Code blocks (``` ... ```)
- Inline code (replace with "CODE")
- Headings (lines starting with #)
- Blockquotes (lines starting with >)
- Horizontal rules (---)
- Metadata lines (tags, bylines, dates)
- URLs inside markdown links (keep link text)

Save the cleaned prose to a temp file for all subsequent analysis.

**Report:** Total prose word count.

---

## Phase 2: Sentence Metrics

Extract individual sentences from the prose. Handle:
- Decimal numbers (don't split on "4.5")
- Abbreviations (e.g., i.e.)
- Quoted strings containing periods

**Measure and report:**

| Metric | How |
|---|---|
| Total sentences | Count |
| Average sentence length | words / sentences |
| Median sentence length | Middle value of sorted lengths |
| Min / Max | Extremes |
| Short sentence ratio | % of sentences under 8 words |
| Sentence length distribution | 4 bands: 1-7, 8-15, 16-25, 26+ words with counts and percentages |

**Describe the rhythm pattern:** How do short and long sentences alternate? Do short sentences cluster? Are long sentences followed by punchy landings?

---

## Phase 3: Punctuation DNA

Count across the full prose text:

| Mark | Measure |
|---|---|
| Commas | Total and per 100 words |
| Semicolons | Total and per 100 words |
| Colons | Total and per 100 words |
| Em dashes (— and –) | Total |
| Exclamation marks | Total |
| Parenthetical asides | Total, per 100 words, list each one |
| Rhetorical questions | Total, per 100 words, list each one |

**Identify the punctuation fingerprint:** Which marks carry the structural load? What's absent? Note any unusual ratios (e.g., colon-to-semicolon ratio).

---

## Phase 4: Paragraph Structure

| Metric | How |
|---|---|
| Total prose paragraphs | Count (exclude pure list paragraphs) |
| Average paragraph length | Words |
| One-sentence paragraph ratio | % of paragraphs with 0-1 sentence-ending punctuation |

---

## Phase 5: Vocabulary Profile

| Metric | How |
|---|---|
| Total words | Count alpha-only tokens |
| Unique words | Count distinct |
| Lexical diversity | unique / total |
| Long words (8+ chars) | Count and percentage |
| Common word ratio | % that are top-100 English function words |
| Top 15 long words | With frequency counts |

**Describe the vocabulary character:** Academic or accessible? Jargon-heavy or plain? Are key terms repeated deliberately (thematic anchoring) or is vocabulary varied?

---

## Phase 6: Tone Profile

### POV and Address
- Count I/my/me instances (per 100 words)
- Count we/our instances (per 100 words)
- Count you/your instances (per 100 words)
- Determine dominant POV

### Hedging Language
Search for: probably, perhaps, maybe, might, could be, I think, kinda, sort of, likely, arguably, roughly, nearly, pretty, fairly, basically, genuinely, honestly, admittedly, I guess, I don't think

Report total, per 100 words, and each instance. Note whether hedges appear on claims, predictions, or data.

### Emotional Register
- Profanity count and context for each instance
- Exclamation marks (already counted)
- Describe the overall temperature: restrained, casual, intense, breathless?

### Contractions
- Total count and per 100 words
- Top 10 most frequent

---

## Phase 7: Signature Devices

Search for and quantify each of these patterns. Not all will be present. Report what IS there and what IS NOT.

### Sentence openers
- Top 15 opening words with counts
- Conjunction openers (And/But/Or/So): total count, percentage of all sentences, breakdown by word

### Fragment patterns
- List all sentences under 6 words ending in a period
- Identify fragment stacking (2+ consecutive fragments)
- Identify single-word sentences

### Recurring structures
Search for:
- "That's..." landing sentences
- "Here's..." launcher sentences
- "The [noun] is/was..." authoritative declaratives
- "Not X. Y." contrast patterns
- "I just..." casualness markers
- "Let me..." gear-shift cues
- "Same with X." stacking
- Credential references ("I've built/seen/written...")
- Direct persuasion ("believe me," "face it," "let's be honest")
- Any other repeated phrase pattern that appears 3+ times

### Rhetorical devices
- Anaphora / repetition patterns
- Rhetorical question clusters (2+ questions in sequence)
- Colon setup-payoff structures
- Historical framing / analogy patterns

### Temporal markers
- Count temporal words (first, then, next, eventually, now, started, etc.)
- Describe the temporal architecture: chronological? thematic? diary-style?

---

## Phase 8: Structural Blueprint

Describe the macro-structure:

### Opening pattern
How does the piece begin? (Bold thesis? Scene setting? Credential stack? Anecdote?)

### Body organization
How are sections structured internally? What's the repeating unit?

### Closing pattern
How does the piece end? (Call to action? Honest concession? Restatement? Promise?)

---

## Phase 9: Compile the Report

Write the full Style DNA report as a markdown file saved next to the source file, named `[source-filename]-style-dna.md`.

The report MUST include:

1. **Header** with source file, word count, date analyzed
2. **Measured Metrics** table (all numbers from phases 2-4)
3. **Sentence Length Distribution** table
4. **Vocabulary Profile** table with top words
5. **Tone Profile** section (POV, hedging, emotional register)
6. **Signature Devices** section (only devices that actually appear, with counts and examples)
7. **Structural Blueprint** section
8. **Quick Reference Card** (code block with all key numbers for at-a-glance use)

If analyzing multiple files by the same author, add a **Cross-Article Comparison** section with a comparison table and analysis of which traits are stable fingerprints vs. sliding dials.

---

## Execution Notes

- Run all independent measurements in parallel (sentence analysis, punctuation counts, vocabulary analysis can run simultaneously)
- Use Python for accurate counting. Shell one-liners are fine for simple counts but Python handles sentence splitting and edge cases better.
- Do not round aggressively. Report to 1 decimal place for percentages, 2 for per-100-word densities.
- List concrete examples for every device you identify. Numbers without examples are useless.
- If a metric reads zero, report it explicitly. Absence is data.

---

## Phase 10: Save Prompt

After presenting the report, ask the user:

> Style DNA report ready. Want me to save it as `[source-filename]-style-dna.md` next to the source file?

Wait for confirmation before writing. If the user says yes, save the full report. If analyzing multiple files, also offer to save the cross-article comparison as a separate file.

---

## Integration

Produces Style DNA reports consumed by other skills:

```
[writing samples] --> style-forensics --> Style DNA report
                                              |
                                              +--> style-writer (write new content in that voice)
                                              +--> humanizer (preserve style when stripping AI tells)
                                              +--> copy-editor (respect voice during editing)
```

- **Before style-forensics:** Gather 1-5 writing samples (pre-AI preferred)
- **After style-forensics:** `style-writer` to write new content matching the voice
- **Not this skill:** `brand-voice` for qualitative brand guidelines, `copy-editor` for grammar review
