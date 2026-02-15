---
name: majestic:style-guide:new
description: Create a project style guide interactively. Generates STYLE_GUIDE.md that copy-editor and other skills reference.
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Skill
disable-model-invocation: true
---

# Style Guide Generator

Create a project-specific style guide through guided discovery.

## Arguments

$ARGUMENTS - Optional path to existing content samples.

## Phase 1: Brand Foundation Check

Before style preferences, check for brand context:

```bash
# Check for existing brand positioning
glob "**/brand-positioning.md" || glob ".claude/brand-positioning.md"
```

**If brand positioning exists:**
- Read and extract: personality traits, values, target audience
- Use these to inform voice defaults
- Skip to Phase 2

**If no brand positioning:**
- Gather minimal brand context with questions below

### Brand Context Questions (if no positioning doc)

Use `AskUserQuestion` to establish brand foundation:

1. **Brand personality?** - "Pick 3 traits that describe your brand"
   - Options: Bold, Friendly, Professional, Playful, Sophisticated, Rebellious, Trustworthy, Innovative

2. **Competitive stance?** - "How do you want to be perceived vs competitors?"
   - Options: Premium leader, Scrappy challenger, Friendly alternative, Technical expert, Category creator

3. **Primary audience emotional state?** - "What state is your audience in when they find you?"
   - Options: Frustrated (seeking relief), Ambitious (seeking growth), Confused (seeking clarity), Skeptical (seeking proof), Overwhelmed (seeking simplicity)

4. **Content relationship?** - "What role does your content play for readers?"
   - Options: Expert guide (teaching), Trusted peer (collaborating), Helpful assistant (supporting), Bold leader (inspiring)

### Store Brand Context

Save responses to include in output:

```markdown
## Brand Context

**Personality traits:** [selected traits]
**Competitive stance:** [selected stance]
**Audience state:** [selected state]
**Content role:** [selected role]

*This context informs the voice and tone decisions below.*
```

## Phase 2: Discovery

**Check for existing context (run globs in parallel):**

```
Glob 1: "STYLE_GUIDE.md" OR ".claude/style-guide.md"  # Existing style guide
Glob 2: "**/brand-voice.md"                            # Brand voice guide
Glob 3: "content/**/*.md" OR "blog/**/*.md"            # Content samples
```

If style guide exists, offer to update rather than create new.

## Phase 3: Core Preferences

Use `AskUserQuestion` in batches of 2-4 questions.

### Batch 1: Foundation

1. **Base style guide?** - AP Style, Chicago Manual, Microsoft Style, Start fresh
2. **Primary content type?** - Marketing copy, Technical docs, Blog, Mixed

### Batch 2: Voice

3. **Formality?** - Formal, Conversational, Casual
4. **Perspective?** - First plural ("We"), Second ("You"), Third person, Mixed

### Batch 3: Mechanics

5. **Oxford comma?** - Always, Never, Flexible
6. **Numbers?** - Spell 1-9, Always numerals, Spell 1-10

### Batch 4: Vocabulary

7. **Jargon tolerance?** - Avoid all, Industry OK, Define on first use
8. **Words to avoid?** - Comma-separated or "none"

## Phase 4: Advanced Options

If "Mixed" content types or detailed control needed:

- **Tone by content type?** - Yes (ask per type) / No (consistent)
- **AI writing policy?** - AI drafts allowed, AI for outlines only, No AI, No policy

## Phase 5: Generate Style Guide

Invoke skill which will guide you to find and read the template:

```
Skill(skill="style-guide-builder")
```

Follow the skill's instructions to load the template, then customize it:

- Fill Quick Reference table
- Configure voice and tone sections
- Set grammar and mechanics rules
- Add vocabulary preferences
- Include content type guidelines

### Output Location

1. `STYLE_GUIDE.md` (project root) - default
2. `.claude/style-guide.md` (Claude-specific)
3. `docs/style-guide.md` (documentation folder)

## Phase 6: Confirmation

```
✓ Style guide created: [path]

Automatically used by:
- copy-editor - Reviews against rules
- content-writer - Follows voice/formatting
- content-atomizer - Maintains consistency

Next steps:
1. Review and customize sections
2. Add project-specific vocabulary
3. Run copy-editor on existing content
```

Offer options:
- Create brand positioning document (if none exists) - Invoke `brand-positioning` skill
- Create brand voice guide - Invoke `brand-voice` skill
- Review existing content against new guide
- Add content type templates
