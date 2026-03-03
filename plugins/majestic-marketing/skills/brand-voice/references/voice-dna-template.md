# Voice DNA Template

Simplified output format for personal voice recovery. Used when the user wants to capture their own writing voice (not a brand's).

## Output Structure

```markdown
# Voice DNA

## Writing Rules
- [Rule 1: sentence structure preference]
- [Rule 2: contraction usage]
- [Rule 3: paragraph length]
- [Rule 4: directness level]
- [Rule 5: specificity preference]
- [Rule 6: sentence length variation]
- [Rule 7: transition style]
- [Rule 8: uncertainty expression]
- [Rule 9: conciseness preference]
- [Rule 10: verb style (physical vs abstract)]
- [Rule 11: humor approach]
- [Rule 12: punctuation habits (parenthetical asides, etc.)]

## Formatting Rules
- [Paragraph length default]
- [Number formatting: digits vs spelled out]
- [Contraction policy]
- [Punctuation preferences: em dashes, semicolons, colons]
- [Bold/emphasis usage]
- [Code block conventions]

## Banned Phrases (never use these, ever)

### Dead AI Language
[Extracted from writing samples: phrases the author never uses that AI defaults to]

### Dead Transitions
[Mechanical transitions that don't match the author's style]

### The Author's Specific Bans
[Patterns identified from samples that would feel wrong in this voice]

## Writing Samples

[Original samples preserved here for voice matching]
```

## Extraction Rules

When analyzing writing samples to fill this template:

1. **Count actual patterns** - don't guess. Measure contraction rate, sentence length, paragraph length
2. **Identify absence** - what the author DOESN'T do is as important as what they do
3. **Note signature moves** - recurring devices (parenthetical asides, rhetorical questions, specific punctuation)
4. **Preserve specificity** - "Uses contractions 90% of the time" beats "casual tone"
5. **Physical verbs** - check if author uses concrete/physical verbs for abstract processes
6. **Humor detection** - is humor from specificity, self-deprecation, exaggeration, or wordplay?

## Placement Guidance

Suggest saving the Voice DNA file to one of:
- `.claude/voice-dna.md` (session-persistent, Claude reads automatically)
- `docs/voice-dna.md` (version controlled, shareable)
- Project CLAUDE.md (inline, always loaded)

For maximum effect: `.claude/voice-dna.md` so Claude reads it every session.
