---
name: majestic:style-guide:new
description: Create a project style guide interactively. Generates STYLE_GUIDE.md that copy-editor and other skills reference automatically.
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion
---

# Style Guide Generator

Create a comprehensive, project-specific style guide through guided discovery. The resulting `STYLE_GUIDE.md` file is automatically used by `copy-editor`, `content-writer`, and other content skills.

## Arguments

$ARGUMENTS

Optional: path to existing content samples to analyze for patterns.

## Process

### Phase 1: Discovery

Check for existing style context:

```bash
# Check for existing style guide
glob "STYLE_GUIDE.md" || glob ".claude/style-guide.md" || glob "docs/style-guide.md"

# Check for brand voice guide
glob "**/brand-voice.md" || glob ".claude/brand-voice.md"

# Check for existing content samples
glob "content/**/*.md" || glob "blog/**/*.md" || glob "docs/**/*.md"
```

If style guide exists, offer to update it rather than create new.

### Phase 2: Core Preferences

Use `AskUserQuestion` to gather essential choices. Ask in batches of 2-4 questions.

**Batch 1: Foundation**

```
1. What's your base style guide?
   - AP Style (journalism, marketing)
   - Chicago Manual (books, academic)
   - Microsoft Style (technical docs)
   - Start fresh (I'll define everything)

2. What's your primary content type?
   - Marketing copy (landing pages, ads, emails)
   - Technical documentation (guides, API docs)
   - Blog/thought leadership (articles, posts)
   - Mixed (multiple content types)
```

**Batch 2: Voice Basics**

```
3. How formal is your writing?
   - Formal (no contractions, professional distance)
   - Conversational (contractions, direct address)
   - Casual (slang OK, very relaxed)

4. What perspective do you use?
   - First person plural ("We believe...")
   - Second person ("You can...")
   - Third person ("The company offers...")
   - Mixed by context
```

**Batch 3: Mechanics**

```
5. Oxford comma preference?
   - Always use Oxford comma
   - Never use Oxford comma
   - Flexible (use for clarity)

6. Number formatting?
   - Spell out one-nine, numerals 10+
   - Always use numerals
   - Spell out one-ten, numerals 11+
```

**Batch 4: Vocabulary**

```
7. Jargon tolerance?
   - Avoid all jargon (general audience)
   - Industry jargon OK (expert audience)
   - Define on first use (mixed audience)

8. Any words to always avoid? (comma-separated, or "none")
```

### Phase 3: Advanced Options

If user selected "Mixed" content types or wants detailed control:

**Content-Specific Tones**

```
9. Should tone vary by content type?
   - Yes, define per type
   - No, keep consistent

If yes, ask for each relevant type:
- Landing pages: [formal/balanced/casual]
- Documentation: [formal/balanced/casual]
- Blog posts: [formal/balanced/casual]
- Emails: [formal/balanced/casual]
- Social media: [formal/balanced/casual]
```

**AI Writing Policy**

```
10. AI writing policy?
    - AI drafts allowed, human review required
    - AI for research/outlines only
    - No AI-generated content
    - No policy needed
```

### Phase 4: Generate Style Guide

Produce a structured `STYLE_GUIDE.md` based on responses.

**Output Location Options:**
1. `STYLE_GUIDE.md` (project root) - default
2. `.claude/style-guide.md` (Claude-specific)
3. `docs/style-guide.md` (documentation folder)

Ask user preference if unclear.

## Output Template

```markdown
# Style Guide

*Project style guide for [Project Name]. Used by copy-editor and content skills.*

---

## Quick Reference

| Aspect | Standard |
|--------|----------|
| Base guide | [AP/Chicago/Microsoft/Custom] |
| Voice | [Formal/Conversational/Casual] |
| Perspective | [We/You/Third person] |
| Oxford comma | [Always/Never/Flexible] |
| Numbers | [Spell 1-9/Always numerals/Spell 1-10] |

---

## 1. Voice & Tone

### Core Voice

[Description based on responses - 2-3 sentences max]

### Tone by Context

| Context | Tone | Example |
|---------|------|---------|
| [Type] | [Formal/Balanced/Casual] | "[Example phrase]" |

### Perspective

- **Default**: [We/You/They]
- **When to switch**: [Specific contexts]

---

## 2. Grammar & Mechanics

### Punctuation

- **Oxford comma**: [Rule]
- **Contractions**: [Allowed/Not allowed/Context-specific]
- **Em dashes**: [Usage rule]
- **Exclamation points**: [Sparingly/Never/Context-specific]

### Capitalization

- **Headlines**: [Title Case/Sentence case]
- **Subheadings**: [Title Case/Sentence case]
- **Product names**: [Always capitalize/Follow specific list]

### Numbers

- **Spell out**: [Rule]
- **Percentages**: [X% or X percent]
- **Currency**: [$X or X dollars]
- **Dates**: [Format]
- **Times**: [Format]

---

## 3. Vocabulary

### Words We Use

| Preferred | Instead of | Why |
|-----------|------------|-----|
| [word] | [word] | [reason] |

### Words We Avoid

| Avoid | Use Instead | Why |
|-------|-------------|-----|
| [word] | [word] | [reason] |

### Jargon Policy

[Policy description]

---

## 4. Formatting

### Structure

- **Paragraph length**: [X sentences max]
- **Sentence length**: [X words average]
- **Headings**: Every [X] words

### Lists

- **Bullet style**: [Dashes/Dots]
- **Capitalization**: [First word only/Each word]
- **Punctuation**: [Periods if sentences/None if fragments]

### Links

- **Style**: [Descriptive text, never "click here"]
- **External links**: [Open in new tab/Same tab]

---

## 5. Content Types

### [Type 1: e.g., Landing Pages]

- **Tone**: [Formal/Balanced/Casual]
- **Length**: [Target word count or range]
- **Structure**: [Key elements required]
- **CTA style**: [Specific guidance]

### [Type 2: e.g., Blog Posts]

- **Tone**: [Formal/Balanced/Casual]
- **Length**: [Target word count or range]
- **Structure**: [Key elements required]

[Repeat for each content type]

---

## 6. AI Writing Policy

[Policy based on response, or omit section if "No policy needed"]

---

## 7. Pre-Publish Checklist

Before publishing any content:

- [ ] Voice matches our standards
- [ ] Grammar follows this guide
- [ ] No words from "avoid" list
- [ ] Formatting is consistent
- [ ] [Additional checks based on responses]

---

## References

- **Brand voice guide**: [path if exists, or "Not yet created - use `brand-voice` skill"]
- **Base style guide**: [Link to AP/Chicago/Microsoft if applicable]
- **Last updated**: [Date]
```

### Phase 5: Integration Confirmation

After generating, confirm:

```
✓ Style guide created: [path]

This guide is now automatically used by:
- `copy-editor` - Reviews content against your rules
- `content-writer` - Follows your voice and formatting
- `content-atomizer` - Maintains consistency across platforms

Next steps:
1. Review and customize the generated sections
2. Add project-specific vocabulary to Section 3
3. Run `copy-editor` on existing content to check compliance

Would you like me to:
- [ ] Create a brand voice guide (complements this style guide)
- [ ] Review existing content against this new guide
- [ ] Add more content type templates
```

## Quality Standards

- **Project-specific**: Only include decisions, not generic explanations
- **Actionable**: Every rule should be verifiable
- **Concise**: Target 200-400 lines max
- **Maintainable**: Structure supports easy updates
- **Integrated**: Works seamlessly with existing skills

## Relationship to Other Tools

| Tool | Relationship |
|------|--------------|
| `brand-voice` | Creates complementary voice guide (personality focus) |
| `copy-editor` | Enforces this style guide during review |
| `content-writer` | Follows these rules when creating content |
| `DEFAULT_STYLE_GUIDE.md` | Fallback when no project guide exists |
