# Output Styles

Pre-built formatting guides for consistent Claude Code responses.

## Available Styles

| Style | Description |
|-------|-------------|
| `bullet-points` | Hierarchical bullet points for quick scanning |
| `genui` | Generated UI component format |
| `htlm-structured` | HTML-structured output |
| `markdown-focused` | Markdown-centric formatting |
| `table-based` | Table-based presentation |
| `tts-summary` | Text-to-speech friendly summaries |
| `ultra-concise` | Minimal words, maximum speed, direct actions |
| `yaml-structured` | YAML-formatted output |

## How to Use

### Option 1: Add to CLAUDE.md (Persistent)

Copy the contents of your preferred style into your project's `CLAUDE.md` or user-level `~/.claude/CLAUDE.md`:

```bash
# After running install.sh, append a style to your CLAUDE.md
cat ~/.claude/output-styles/ultra-concise.md >> ~/.claude/CLAUDE.md
```

### Option 2: Reference in Prompts (Per-Session)

Tell Claude to use a specific style at the start of your session:

```
Use the formatting guidelines from ~/.claude/output-styles/bullet-points.md for all responses.
```

### Option 3: Include in Custom Commands

Reference a style in your custom command files:

```markdown
# My Command

Follow the output format defined in ~/.claude/output-styles/table-based.md.

[rest of command...]
```

## Style Descriptions

### ultra-concise
Absolute minimum words. No explanations unless critical. Code first, brief status after. Best for experienced developers who want speed over explanation.

### bullet-points
Hierarchical bullet structure for complex information. Good for technical documentation, analysis results, and multi-part answers.

### table-based
Tabular format for comparing options, listing features, or presenting structured data.

### markdown-focused
Rich markdown with headers, code blocks, and formatting. Good for documentation and detailed explanations.

### yaml-structured
YAML-formatted responses for machine-readable output or configuration-style answers.

### tts-summary
Optimized for text-to-speech. Short sentences, no special characters, clear pronunciation.

### genui
Generated UI component descriptions. Useful for design discussions and UI/UX work.

### htlm-structured
HTML-formatted output for web content or email templates.
