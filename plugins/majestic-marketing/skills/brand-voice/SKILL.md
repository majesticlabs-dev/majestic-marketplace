---
name: brand-voice
description: |
  Create AI-optimized style guides for brand or personal voice. Extracts patterns
  from writing samples and produces a reusable guide with tone rules, structure patterns,
  signature moves, anti-pattern blacklists, and examples. Output is optimized for LLM
  consumption (Claude Projects, system prompts). Not for editing content (use copy-editor).
triggers:
  - brand voice
  - voice guide
  - tone of voice
  - brand style
  - voice document
  - company voice
  - our voice
  - my voice
  - my writing style
  - ai style guide
  - writing style guide
  - how I write
  - personal voice
allowed-tools: Read Write Edit Grep Glob WebSearch AskUserQuestion
---

# Voice Architect

Create an AI-optimized style guide — an operating manual that makes LLMs converge toward a specific voice instead of generic default output.

## Mode Detection

Detect from user input or ask:

- **Personal voice** ("my voice", "how I write", "ai style guide") → Focus on individual writing patterns, signature techniques, personal anti-patterns
- **Brand voice** ("our voice", "brand style", "company voice") → Focus on organizational identity, cross-context tone, team-wide standards

For **quantitative** voice metrics (sentence length distribution, punctuation DNA, lexical diversity scores), use `style-forensics` — it produces Style DNA reports with exact numbers. This skill produces the **qualitative operating manual** that complements those metrics.

## Deep Discovery (Optional)

For thorough voice exploration before creating the guide, run:

```
/interview "brand voice"
```

This triggers a conversational interview with voice-specific questions about identity, audience connection, tone boundaries, and existing patterns.

## Conversation Starter

Use `AskUserQuestion` to gather initial context. Adapt phrasing to detected mode.

**For personal voice:**

"I'll help you create an AI style guide — a reusable document that makes AI write like you, not like generic AI.

**Please provide one of these:**

**Option A - Writing Samples (Preferred)**
Share 3-5 pieces YOU wrote that represent your best voice:
- Blog posts, newsletters, essays, social posts, or emails
- Paste directly or provide file paths
- Choose pieces where you sound most like *yourself*

**Option B - Voice Interview**
If you don't have samples handy, I'll ask targeted questions:
1. Show you example paragraphs and ask which feel closer to your style
2. Ask about your writing instincts (do you start with stories or arguments?)
3. Probe your anti-patterns (what makes you cringe in AI writing?)

React to examples rather than self-describe — specifics emerge faster."

**For brand voice:**

"I'll help you codify your brand voice into a reusable AI style guide.

**Please provide one of these:**

**Option A - Existing Content (Preferred)**
Share 3-5 pieces of content that represent your brand voice:
- Website copy, emails, social posts, or blog articles
- Paste directly or provide URLs/file paths

**Option B - Brand Description**
If you don't have content yet, describe:
1. **Industry/Product**: What do you sell?
2. **Target Audience**: Who are you talking to?
3. **Brand Personality**: 3-5 adjectives that describe your brand
4. **Brands You Admire**: Whose voice do you like? (competitors or not)
5. **Avoid Sounding Like**: What tone would be wrong for you?

I'll analyze patterns and create your voice guide."

## Analysis Process

### If Content Provided (Option A)

Extract patterns across all samples:

**Voice Patterns to Identify:**
- Sentence length distribution (short/medium/long)
- Use of contractions (can't vs cannot)
- First/second/third person preference
- Active vs passive voice ratio
- Question usage frequency
- Exclamation point usage
- Emoji/punctuation style
- Paragraph length patterns
- Opening patterns (how pieces start)
- Closing patterns (how pieces end)

**Vocabulary Patterns:**
- Recurring power words
- Industry jargon usage (heavy/light/none)
- Colloquialisms and slang
- Metaphor and analogy patterns
- Words that appear frequently
- Words that are notably absent

**Tone Markers:**
- Formality level (1-10 scale)
- Humor usage (frequent/occasional/never)
- Confidence level (bold claims vs hedging)
- Emotional warmth (distant vs intimate)
- Authority stance (peer vs expert vs mentor)

### If Description Provided (Option B)

Use WebSearch to find:
- Example content from admired brands
- Industry voice benchmarks
- Competitor voice analysis
- Audience communication preferences

Then synthesize a voice based on inputs.

## Brand Voice Guide Structure

### 1. Voice DNA (Core Identity)

```markdown
## Voice DNA

### Brand Personality
[3-5 defining traits with explanations]

| Trait | What It Means | How It Shows Up |
|-------|---------------|-----------------|
| [Trait 1] | [Definition] | [Example in copy] |
| [Trait 2] | [Definition] | [Example in copy] |
| [Trait 3] | [Definition] | [Example in copy] |

### The Elevator Pitch
"We sound like [description]. Think [reference point] meets [reference point]."

### If Our Brand Were a Person
[2-3 sentence description of brand as human—age, profession, how they talk at a party]
```

### 2. Tone Spectrum

```markdown
## Tone Spectrum

Our voice stays consistent, but tone adapts to context.

| Context | Tone | Example |
|---------|------|---------|
| Homepage hero | Confident, bold | "Stop guessing. Start knowing." |
| Error message | Helpful, calm | "Something went wrong. Let's fix it together." |
| Success message | Warm, celebratory | "You did it! Your first campaign is live." |
| Sales email | Direct, valuable | "Here's what's working for teams like yours." |
| Support docs | Clear, patient | "First, open Settings. You'll find it in the top right." |
| Social media | Casual, engaging | "Hot take: [opinion]. Fight me in the comments." |
| Legal/Terms | Clear, straightforward | "Your data belongs to you. Here's exactly what we collect." |

### Tone Dial

**Formal ←――――――→ Casual**
[Mark where brand sits: e.g., "We sit at 3/10—professional but never stiff."]

**Serious ←――――――→ Playful**
[Mark where brand sits: e.g., "We sit at 6/10—we crack jokes but know when to be serious."]

**Reserved ←――――――→ Enthusiastic**
[Mark where brand sits: e.g., "We sit at 7/10—we're excited about what we do and it shows."]
```

### 3. Structure Patterns

```markdown
## Structure

How pieces organize ideas — the architectural blueprint AI must follow.

### Opening Pattern
[How pieces begin: e.g., "Open with friction — a problem, tension, or surprising claim"]

### Body Organization
[How the middle works: e.g., "Alternate between concept and concrete example. Never explain without showing."]

### Closing Pattern
[How pieces end: e.g., "Land on a usable takeaway — something the reader can do today"]

### Transitions
[How sections connect: e.g., "Jump-cut between ideas. No 'Furthermore' or 'Additionally.'"]
```

### 4. Signature Moves

```markdown
## Signature Moves

Named techniques that make this voice distinctive. AI should deploy these at natural frequency.

| Move | Description | Frequency |
|------|-------------|-----------|
| [Name] | [What it looks like — e.g., "Starts with a concrete anecdote, then zooms out to the principle"] | [Every piece / Often / Occasionally] |
| [Name] | [e.g., "Drops a one-sentence paragraph for emphasis after a longer passage"] | [Frequency] |
| [Name] | [e.g., "Uses parenthetical asides to add personality — like this"] | [Frequency] |

### Moves to Avoid
| Move | Why It's Wrong |
|------|---------------|
| [Name] | [e.g., "Listicle structure — feels like content marketing, not our voice"] |
```

### 5. Vocabulary Guide

```markdown
## Vocabulary

### Words We Love
| Word/Phrase | Why | Use When |
|-------------|-----|----------|
| [Word] | [Reason] | [Context] |

### Words We Avoid
| Avoid | Use Instead | Why |
|-------|-------------|-----|
| [Word] | [Alternative] | [Reason] |

### Industry Jargon Rules
[How much jargon is acceptable and when]

### Pronouns
- **We/Our**: [When to use]
- **You/Your**: [When to use]
- **I/My**: [When to use, if ever]
- **They/The company**: [When to use, if ever]

### Anti-Pattern Blacklist
Patterns to eliminate — these are structural, not just word-level:
| Pattern | Example | Fix |
|---------|---------|-----|
| [e.g., "Correlative construction"] | ["Not X, but Y"] | ["Rewrite as direct claim"] |
| [e.g., "Throat-clearing opener"] | ["In today's fast-paced world..."] | ["Cut to the point"] |
| [e.g., "Hedge stacking"] | ["It might perhaps be worth considering..."] | ["State the claim, then qualify once"] |
```

### 6. Sentence Style

```markdown
## Sentence Style

### Length
- **Target**: [X words average per sentence]
- **Mix**: [Short sentences for punch, longer for explanation]
- **Paragraphs**: [Max X sentences per paragraph]

### Structure Preferences
- **Contractions**: [Always/Sometimes/Never] — "you're" vs "you are"
- **Active voice**: [Percentage target] — "We built this" vs "This was built"
- **Starting sentences**: [Patterns to use/avoid]
- **Questions**: [Rhetorical? Direct? Frequency?]

### Punctuation
- **Exclamation points**: [Rules for usage]
- **Em dashes**: [Heavy use/light use]
- **Ellipses**: [Never/sparingly/frequently]
- **Oxford comma**: [Yes/No]
- **Emojis**: [Never/sparingly/frequently + which ones]
```

### 7. Formatting Conventions

```markdown
## Formatting

### Headlines
- **Case**: [Sentence case / Title Case]
- **Length**: [Max X words]
- **Punctuation**: [Period/No period]

### CTAs
- **Style**: [Action verb first]
- **Examples**: [List of preferred CTA phrases]

### Lists
- **Bullet style**: [Dashes/dots/checkmarks]
- **Capitalization**: [First word only / Each word]
- **Punctuation**: [Periods/No periods]

### Numbers
- **Spell out**: [One through ten / all / none]
- **Percentages**: [50% vs fifty percent]
- **Currency**: [$X vs X dollars]
```

### 8. Do/Don't Examples

```markdown
## Do/Don't Examples

### Homepage Hero
❌ "Welcome to [Company]. We are the leading provider of innovative solutions."
✅ "[Bold claim that shows, not tells]."

### Feature Description
❌ "Our platform leverages cutting-edge technology to deliver best-in-class results."
✅ "[Specific outcome in plain language]."

### Email Subject Line
❌ "Newsletter #47 - Monthly Update"
✅ "[Curiosity hook or specific benefit]."

### Error Message
❌ "Error 403: Forbidden access denied."
✅ "[Human explanation + next step]."

### CTA Button
❌ "Submit" / "Click Here"
✅ "[Action + Outcome]" — "Start Free Trial" / "Get Your Report"

### Social Post
❌ "We are pleased to announce..."
✅ "[Direct statement or hook]."
```

### 9. Revision Checklist

```markdown
## Revision Checklist

Run through before publishing. Each question should produce a confident "yes."

### Voice
- [ ] Does this sound like a real person — not a committee?
- [ ] Could this only be written by us/me? (Not generic AI)
- [ ] Are 2+ signature moves deployed naturally?
- [ ] Zero blacklisted patterns present?

### Tone
- [ ] Is the tone calibrated for this context?
- [ ] Does it match the tone dial positions?

### Language
- [ ] No words from the "avoid" list?
- [ ] Anti-pattern blacklist clear?
- [ ] Contractions/pronouns consistent?

### Structure
- [ ] Opening follows the structure pattern?
- [ ] Transitions feel like jump-cuts, not academic bridges?
- [ ] Closing lands on something usable?

### Gut Check
- [ ] Read it aloud — does it sound like talking, not writing?
```

## Output Format

Use "VOICE GUIDE" for personal, "BRAND VOICE GUIDE" for organizational.

```markdown
# [BRAND] VOICE GUIDE: [Name]

*Version 1.0 | Created [Date] | Optimized for AI consumption*

---

## Quick Reference

**Voice:** [3 traits]
**Sounds like:** [1-sentence description]
**Never sounds:** [What to avoid]

---

## 1. VOICE DNA
[Personality traits + identity]

## 2. TONE SPECTRUM
[Context-based tone adjustments]

## 3. STRUCTURE PATTERNS
[Opening, body, closing, transition patterns]

## 4. SIGNATURE MOVES
[Named techniques with frequency]

## 5. VOCABULARY + ANTI-PATTERNS
[Words we love/avoid + structural blacklist]

## 6. SENTENCE STYLE
[Length, rhythm, punctuation rules]

## 7. FORMATTING
[Headlines, CTAs, lists, numbers]

## 8. DO/DON'T EXAMPLES
[Before/after examples by content type]

## 9. REVISION CHECKLIST
[Pre-publish validation questions]

## APPENDIX: Sample Rewrites
[Off-voice → on-voice with annotations]
```

## File Output

After generating the guide, offer to save it:

- **Brand:** `docs/brand-voice.md` (recommended)
- **Personal:** `docs/style-guide.md` or user's preferred location (e.g., Claude Projects)
- Referenced by content-writer, content-atomizer, linkedin-content, landing-page-builder, style-writer

## Quality Standards

- **Specific over generic** - "We use contractions" not "We're casual"
- **Examples required** - Every rule needs a concrete example
- **Actionable rules** - Must be possible to verify compliance
- **Source from reality** - Extract from actual content, don't invent
- **Living document** - Note that voice guides should evolve

## Integration with Other Skills

This voice guide works with:
- `content-writer` - Apply voice to articles
- `content-atomizer` - Maintain voice across platforms
- `linkedin-content` - On-brand social posts
- `landing-page-builder` - Voice-aligned landing pages
- `sales-page` - Consistent sales messaging

**Related skills:**
- `style-forensics` - Quantitative personal voice extraction (Style DNA reports)
- `style-writer` - Write new content matching a Style DNA or brand voice
- `humanizer` - Strip AI tells while respecting style constraints

**Usage pattern:**
```
"Write this using the voice guide in docs/brand-voice.md"
```

## Maintenance Notes

Voice guides should be updated when:
- Brand positioning changes
- New content types are added
- Team feedback reveals gaps
- Voice drifts from guide (realign or update)

Recommend quarterly reviews.
