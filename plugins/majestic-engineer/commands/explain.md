---
description: Explain a concept using real examples from YOUR project, not abstract theory
allowed-tools: Read, Grep, Glob, Bash
---

# Contextual Concept Explainer

Explain programming concepts using real examples from the user's current project, making abstract ideas concrete and immediately applicable.

## Arguments

The user provides a concept to explain: `/explain <concept>`

Examples:
- `/explain dependency injection`
- `/explain the repository pattern`
- `/explain how caching works here`
- `/explain polymorphism`

## Process

### 1. Identify the Concept

Parse what the user wants to understand:
- Design patterns (factory, observer, strategy, etc.)
- Language features (closures, generators, decorators)
- Architecture concepts (DI, CQRS, event sourcing)
- Project-specific patterns ("how does auth work here")

### 2. Search for Examples

Find relevant code in the current project:

```bash
# Search for pattern implementations
rg -l "pattern_keyword" --type ruby --type js --type py

# Find class/module definitions
rg "class.*Service|module.*Handler"

# Look for common naming conventions
rg -l "Factory|Repository|Observer|Strategy"
```

Prioritize:
- Clear, well-written examples over complex edge cases
- Core business logic over test files (unless tests demonstrate usage well)
- Multiple examples showing the pattern in different contexts

### 3. Explain with Context

Structure your explanation:

**What it is** (1-2 sentences)
Brief definition of the concept.

**How this project uses it**
Walk through 2-3 concrete examples from the codebase:
- Show the actual code snippet
- Explain what's happening and why
- Connect it back to the abstract concept

**Why it matters here**
- What problem does this pattern solve in THIS codebase?
- What would the code look like without it?
- When would you use this pattern vs alternatives?

**Where to find more**
- List key files demonstrating the pattern
- Note any variations or related patterns in the codebase

## Output Format

```markdown
## [Concept Name]

**In a nutshell:** [One sentence definition]

### How {{project_name}} Uses This

#### Example 1: [File/Class Name]

[Code snippet with key parts highlighted]

This shows [explanation of what's happening]...

#### Example 2: [File/Class Name]

[Another code snippet]

Here we see [explanation]...

### Why This Pattern?

[2-3 sentences on what problem it solves in this specific codebase]

### Key Files

- `path/to/example1.rb:42` - [brief description]
- `path/to/example2.rb:15` - [brief description]
```

## Guidelines

- **Concrete over abstract**: Always anchor to actual code, not hypotheticals
- **Project-first**: If the pattern doesn't exist in this codebase, say so and explain how it COULD be applied here
- **Appropriate depth**: Match explanation depth to the concept complexity
- **No condescension**: Explain clearly without being patronizing
- **Honest gaps**: If the codebase has poor examples or anti-patterns, note that constructively
