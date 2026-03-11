---
name: docs-researcher
description: Fetch and summarize API documentation from official sources before implementation. Covers Rails, Tailwind, external libraries, and gem source exploration. Triggers on fetch docs, API reference, library documentation, check docs, read documentation.
---

# Docs Researcher

**Audience:** Developers needing current library documentation before implementing features.

**Goal:** Fetch and summarize relevant API docs to ensure accurate implementation.

## Documentation Sources

| Library | URL |
|---------|-----|
| Tailwind CSS | https://tailwindcss.com/docs |
| Rails Guides | https://guides.rubyonrails.org/ |
| ReductoAI API | https://docs.reducto.ai/api-reference/ |
| ReductoAI Overview | https://docs.reducto.ai/overview |
| Other libraries | Use WebSearch to find official docs |

## Research Process

### 1. Identify Documentation Needs

- Analyze the implementation task to determine which library documentation is needed
- Identify specific topics, APIs, or patterns to research
- Prioritize official documentation sources

### 2. Fetch Documentation

- Use WebFetch to retrieve documentation from the appropriate source
- For unknown libraries, use WebSearch to find official documentation first

### 3. Extract Key Information

- Focus on the specific APIs or patterns needed for the task
- Identify current best practices and recommendations
- Note deprecations or version-specific considerations
- Extract code examples and usage patterns

### 4. Gem Source Exploration (Ruby Projects)

- Use `bundle show <gem_name>` to locate installed gems
- Read gem source code for implementation details
- Check README, CHANGELOG, and inline documentation
- Look for tests that demonstrate usage patterns

## Best Practices

- Always prefer official documentation over third-party sources
- Check for version compatibility with the project's dependencies
- Focus on extracting actionable implementation guidance
- Include both basic usage and advanced patterns when relevant
- Highlight breaking changes or migration considerations

## Output Format

```markdown
### Documentation Summary: [Library/Feature Name]

**Source:** [URL]
**Version:** [If specified]

#### Key Concepts
- [Main concepts relevant to the task]

#### Implementation Guide
[Relevant code examples from documentation]

#### Best Practices
- [Extracted best practices]

#### Important Notes
- [Warnings, gotchas, or special considerations]

#### Related Documentation
- [Links to related pages]
```
