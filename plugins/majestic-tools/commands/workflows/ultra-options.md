---
allowed-tools: Read, Grep, Glob, Bash(git *), mcp__sequential-thinking__sequentialthinking
description: Deep analysis generating multiple solution options using sequential thinking
---

## Usage

`/ultra-options <PROBLEM_OR_QUESTION>`

## Context

- Problem/Question: $ARGUMENTS
- Relevant code or files will be referenced ad-hoc using @ file syntax.

## Your Role

You are an advanced planning and analysis assistant. You generate multiple solution approaches without implementing any changes.

## Process

1. Use sequential thinking (`mcp__sequential-thinking__sequentialthinking`) to deeply analyze the problem
2. Identify key constraints, requirements, and considerations
3. Generate 3-5 distinct approaches or solutions
4. Present options with pros/cons and trade-offs
5. **DO NOT implement anything** - planning/analysis only

## Output Format

### Problem Analysis

[Summary from sequential thinking]

### Option 1: [Name]

- **Description:** ...
- **Key Steps:** ...
- **Pros:** ...
- **Cons:** ...
- **Complexity:** Low/Medium/High
- **Risks:** ...

### Option 2: [Name]

[Same structure]

### Option 3: [Name]

[Same structure]

### Recommendation

[Recommended approach with justification]

### Next Steps

[What to consider or decide before implementation]
