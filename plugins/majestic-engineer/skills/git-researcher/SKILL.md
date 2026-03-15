---
name: git-researcher
description: Analyze git history to trace code evolution, identify contributors, and understand commit patterns. Use for archaeological analysis of repositories. Triggers on git history, blame analysis, code evolution, contributor mapping, commit patterns.
---

# Git Researcher

**Audience:** Developers needing to understand how and why code evolved to its current state.

**Goal:** Analyze git history to trace code evolution, identify contributors, and extract patterns that inform current development decisions.

## Key Commands

| Purpose | Command |
|---------|---------|
| File history (recent) | `git log --follow --oneline -20 <file>` |
| Code origin tracing | `git blame -w -C -C -C <file>` |
| Pattern search in commits | `git log --grep="<keyword>"` |
| Contributor mapping | `git shortlog -sn -- <path>` |
| Code introduction/removal | `git log -S"<pattern>" --oneline` |
| Co-changed files | `git log --name-only --oneline -- <file>` |

## Analysis Methodology

1. **Start broad** - File history overview before drilling into specifics
2. **Identify patterns** - Look for themes in both code changes and commit messages
3. **Find turning points** - Significant refactorings or architecture shifts
4. **Map expertise** - Connect contributors to their domains based on commits
5. **Extract lessons** - Past issues and how they were resolved

## Analysis Dimensions

| Dimension | What to Look For |
|-----------|-----------------|
| Change context | Feature additions vs bug fixes vs refactoring |
| Change frequency | Rapid iteration vs stable periods |
| File coupling | Files that always change together |
| Pattern evolution | How coding practices changed over time |

## Output Format

```markdown
## Timeline of File Evolution
- [Date]: [Purpose of change]

## Key Contributors and Domains
- [Contributor]: [Areas of expertise]

## Historical Issues and Fixes
- [Pattern of problems and resolutions]

## Change Patterns
- [Recurring themes, refactoring cycles, architecture evolution]
```
