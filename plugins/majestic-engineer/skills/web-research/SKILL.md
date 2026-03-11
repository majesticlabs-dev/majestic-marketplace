---
name: web-research
description: Research technical problems across GitHub issues, Stack Overflow, Reddit, and documentation. Gathers solutions from multiple community sources with structured findings. Triggers on search for solutions, find examples, research problem, community solutions, debug research.
---

# Web Research

**Audience:** Developers debugging issues or researching solutions who need comprehensive findings from multiple sources.

**Goal:** Search GitHub issues, Stack Overflow, Reddit, and docs to find relevant solutions and patterns.

## Research Process

### 1. Query Generation

- Generate 5-10 search query variations for the given topic
- Include technical terms, error messages, library names
- Consider how different people might describe the same issue
- Search for both the problem AND potential solutions

### 2. Source Exploration

| Source | What to Look For |
|--------|-----------------|
| GitHub Issues | Open and closed issues with matching symptoms |
| Stack Overflow | Accepted answers and high-vote alternatives |
| Reddit | r/programming, r/webdev, topic-specific subreddits |
| Official docs | Changelogs, migration guides, known issues |
| Blog posts | Tutorials, deep dives, experience reports |
| Hacker News | Technical discussions and alternative perspectives |

### 3. Information Gathering

- Read beyond the first few results
- Look for patterns in solutions across different sources
- Pay attention to dates to ensure relevance
- Note different approaches to the same problem
- Identify authoritative sources and experienced contributors

### 4. Quality Verification

- Cross-reference information across multiple sources
- Clearly indicate when information is speculative or unverified
- Date-stamp findings to indicate currency
- Distinguish between official solutions and community workarounds

## Search Techniques

- Use exact error messages in quotes for debugging issues
- Use `site:` operator for targeted source searching
- Use `inurl:`, `intitle:`, `filetype:` for precise results
- Check archived/cached content for removed or updated information
- Search in multiple languages if initial results are limited

## Output Format

```markdown
### Executive Summary
[Key findings in 2-3 sentences]

### Detailed Findings

#### Option 1: [Solution/Approach Name]
- Description
- Implementation details
- Pros and cons
- Source credibility

#### Option 2: [Alternative Solution]
[Continue as needed]

### Sources and References
[Direct links with brief descriptions]

### Recommendations
[Best approach based on research with trade-offs noted]
```
