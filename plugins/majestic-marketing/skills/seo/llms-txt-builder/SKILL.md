---
name: llms-txt-builder
description: Create llms.txt files that help AI systems navigate and understand your site structure for better citations.
allowed-tools: Read Write Edit Glob
disable-model-invocation: true
---

# llms.txt Builder

**Audience:** Site owners wanting AI visibility
**Goal:** Generate llms.txt file for AI system navigation

## What is llms.txt?

A file at `https://yoursite.com/llms.txt` that helps AI systems understand site structure.

## Format

```
# Site Name
> Brief description of the site and its purpose

## Main Sections

- [Section Name](URL): Description of this section
- [Products](URL): Description of products/services
- [Blog](URL): Description of blog content

## Key Resources

- [Getting Started Guide](URL): Description
- [API Documentation](URL): Description
- [Pricing](URL): Description

## Contact

- Email: contact@example.com
- Support: support@example.com
```

## Best Practices

- Keep descriptions concise (1 sentence each)
- Prioritize most important pages (top 10-15)
- Update when site structure changes
- Include key landing pages for each persona
- Use consistent formatting

## Content Priority

**Must Include:**
- Homepage
- Core product/service pages
- Main category pages
- Contact/support

**Should Include:**
- Popular blog posts
- Key documentation
- Pricing page
- About/team page

**Consider:**
- Case studies
- Integration pages
- API docs
- Changelog

## Workflow

1. Scan site structure (glob for main pages)
2. Identify priority pages per section
3. Write concise descriptions
4. Format as llms.txt
5. Validate links work
6. Recommend placement in root

## Output

```
# [Site Name]
> [One-line site purpose]

## Main Sections
[3-5 core sections with links]

## Key Resources
[5-10 important pages]

## Contact
[Support channels]
```
