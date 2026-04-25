---
name: style-guide-builder
description: Generate project-specific style guides for content creation. Use when setting up content standards, creating editorial guidelines, or invoked automatically by /style-guide:new. Provides templates for tone, formatting, and writing conventions.
---

# Style Guide Builder Skill

Provides templates for creating project-specific style guides.

## When to Use

Automatically invoked by `/style-guide:new` command.

## Template

- [references/style-guide-template.md](references/style-guide-template.md) - Complete style guide output format

## Integration

The generated `STYLE_GUIDE.md` is automatically used by:
- `copy-editor` - Reviews content against rules
- `content-writer` - Follows voice and formatting
- `content-atomizer` - Maintains consistency across platforms

## Quality Standards

- **Project-specific**: Only include decisions, not generic explanations
- **Actionable**: Every rule should be verifiable
- **Concise**: Target 200-400 lines max
- **Maintainable**: Structure supports easy updates
