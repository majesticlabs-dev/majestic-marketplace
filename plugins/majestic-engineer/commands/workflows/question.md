---
name: majestic:question
allowed-tools: Bash(git ls-files:*), Read, Grep, Glob, WebSearch, WebFetch
description: Answer questions about the project structure, documentation, or external topics without coding
disable-model-invocation: true
---

# Question

Answer the user's question by analyzing relevant sources. This prompt is for information and answers only - no code changes.

## Instructions

- **DO NOT write, edit, or create any files**
- **Focus on understanding and explaining**
- **If the question requires code changes, explain conceptually without implementing**

## Question Classification

First, classify the question:

| Type | Examples | Research Method |
|------|----------|-----------------|
| **Project-specific** | "Where is X defined?", "How does Y work in this codebase?" | Local files only |
| **External/Docs** | "How does Claude Code handle X?", "What's the best practice for Y?" | Web search first |
| **Mixed** | "Does this project follow the recommended pattern for X?" | Both |

## Research Steps

### For Project-Specific Questions

1. `git ls-files` to understand project structure
2. `Grep` and `Glob` to find relevant files
3. `Read` to analyze content
4. Answer based on findings

### For External/Documentation Questions

1. **Use `WebSearch` or Perplexity MCP** to find authoritative sources
2. **Use `WebFetch`** to read documentation pages
3. Synthesize findings with citations

### For Mixed Questions

1. Research external best practices first
2. Then analyze how the project implements them
3. Compare and provide recommendations

## Response Format

- Direct answer to the question
- Supporting evidence (file paths, documentation links)
- Citations for external sources
- Conceptual explanations where applicable

## Question

$ARGUMENTS
