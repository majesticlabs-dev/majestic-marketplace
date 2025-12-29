---
name: majestic:style-guide:new
description: Create a project style guide interactively. Generates STYLE_GUIDE.md that copy-editor and other skills reference.
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Skill
---

# Style Guide Generator

Create a project-specific style guide through guided discovery.

## Arguments

$ARGUMENTS - Optional path to existing content samples.

## Phase 1: Discovery

Check for existing context:

```bash
# Existing style guide
glob "STYLE_GUIDE.md" || glob ".claude/style-guide.md"

# Brand voice guide
glob "**/brand-voice.md"

# Content samples
glob "content/**/*.md" || glob "blog/**/*.md"
```

If style guide exists, offer to update rather than create new.

## Phase 2: Core Preferences

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

## Phase 3: Advanced Options

If "Mixed" content types or detailed control needed:

- **Tone by content type?** - Yes (ask per type) / No (consistent)
- **AI writing policy?** - AI drafts allowed, AI for outlines only, No AI, No policy

## Phase 4: Generate Style Guide

Invoke skill for template:

```
Skill(skill="style-guide-builder")
```

Read and customize `@plugins/majestic-marketing/skills/style-guide-builder/resources/style-guide-template.md`:

- Fill Quick Reference table
- Configure voice and tone sections
- Set grammar and mechanics rules
- Add vocabulary preferences
- Include content type guidelines

### Output Location

1. `STYLE_GUIDE.md` (project root) - default
2. `.claude/style-guide.md` (Claude-specific)
3. `docs/style-guide.md` (documentation folder)

## Phase 5: Confirmation

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
- Create brand voice guide
- Review existing content
- Add content type templates
