# Majestic Marketing

Marketing and content tools for Claude Code. Includes 1 skill.

## Installation

```bash
claude /plugin install majestic-marketing
```

## Skills

Invoke with: `skill majestic-marketing:<name>`

| Skill | Description |
|-------|-------------|
| `copy-editor` | Review and edit copy for grammar, style, and clarity. Works with project style guides or uses sensible defaults. |

## Usage

### Copy Editor

The `copy-editor` skill reviews any text for grammar, style, and clarity issues. It supports custom project style guides with a comprehensive default fallback.

**Basic usage:**
```bash
skill majestic-marketing:copy-editor

# Then provide the file or text to review
```

**Example prompts:**
- "Review my landing page copy for issues"
- "Quick grammar check on this email"
- "Edit the blog post in drafts/post.md"
- "Check if this follows our style guide"

### Style Guide Priority

The skill looks for style guides in this order:

1. `STYLE_GUIDE.md` (project root)
2. `.claude/style-guide.md`
3. `docs/style-guide.md`
4. Falls back to bundled `DEFAULT_STYLE_GUIDE.md`

### Adding a Project Style Guide

Create a `STYLE_GUIDE.md` in your project root with your custom rules. The skill will automatically use it instead of the default.

Example structure:
```markdown
# Company Style Guide

## Voice & Tone
- Always use first-person plural ("we", "our")
- Keep tone professional but approachable

## Terminology
- Use "customers" not "users"
- Use "platform" not "software"

## Formatting
- Headlines in Title Case
- No Oxford comma (company preference)
```

## Output Formats

The skill can provide:

- **Full report**: Complete analysis with all categories
- **Quick scan**: Top 5 most important issues only
- **Category focus**: Deep dive on grammar, style, etc.
- **Inline edits**: Apply fixes directly (with permission)

## What Gets Checked

- **Grammar**: Subject-verb agreement, punctuation, spelling
- **Voice**: Active vs. passive, conciseness, clarity
- **Style**: Consistency with style guide rules, tone
- **Structure**: Headlines, paragraphs, transitions, CTAs
