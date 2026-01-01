---
name: git:code-story
description: Generate documentary-style narrative of repository development history
argument-hint: "[--output PATH] [--detail minimal|standard|comprehensive] [--since DATE] [--commits N]"
allowed-tools: Bash, Read, Grep, Glob, Write, Task, Skill
---

Transform git history into an engaging documentary narrative.

## Context

- Default branch: !`claude -p "/majestic:config default_branch main"`
- Repository root: !`git rev-parse --show-toplevel 2>/dev/null`
- Total commits: !`git rev-list --count HEAD 2>/dev/null`
- First commit: !`git log --reverse --format="%H|%ai|%an|%s" 2>/dev/null | head -1`

## Arguments

| Option | Format | Default | Description |
|--------|--------|---------|-------------|
| `--output` | PATH | STORY.md | Output file |
| `--detail` | minimal\|standard\|comprehensive | standard | Detail level |
| `--since` | YYYY-MM-DD | (all) | Analyze after date |
| `--commits` | N | (all) | Limit to N commits |

## Pre-Flight Checks

1. Is this a git repo? (`git rev-parse --git-dir`)
2. Any commits? (Error if 0)
3. Single commit? (Generate minimal "genesis only" story)
4. Large repo (>1000 commits)? (Apply smart sampling)

## Smart Sampling

For large repos:

**Always include:**
- First commit (genesis)
- Tagged commits (releases)
- Merge commits to default branch
- Top 10 commits by files changed

**Sample size by detail:**
- `minimal`: 20 additional
- `standard`: 50 additional
- `comprehensive`: 100 additional

## 5-Pass Analysis

### Pass 1: Repository Overview

```bash
# Project name, age, tags, top contributors, monthly distribution
basename "$(git rev-parse --show-toplevel)"
git log --reverse --format="%ai" | head -1
git tag -l --format='%(creatordate:short)|%(refname:short)' | sort
git shortlog -sn --no-merges | head -10
```

### Pass 2: Timeline Analysis

Invoke git-researcher agent:
```
Task (majestic-engineer:research:git-researcher):
  Analyze evolution: milestones, contributor growth, architecture changes,
  development patterns, turning points.
```

### Pass 3: Decision Points

- Major refactors (commits touching many files)
- Dependency changes
- Feature branch merges
- Commit message patterns

### Pass 4: Narrative Synthesis

Invoke code-story skill which will guide you to find and read the appropriate template:

```
Skill(skill="code-story")
```

Follow the skill's instructions to load the template matching the detail level.

### Pass 5: Output Generation

1. Check if output exists (confirm overwrite)
2. Write using Write tool
3. Display summary

## Output Summary

```
📚 Code Story Generated

**Output:** [file_path]
**Detail Level:** [minimal|standard|comprehensive]
**Commits Analyzed:** [count]
**Contributors Featured:** [count]

The story is ready: [file_path]
```

## Error Handling

| Scenario | Response |
|----------|----------|
| Not a git repo | "Error: Not a git repository" |
| Empty repo | "Error: Empty repository" |
| Single commit | Generate "genesis only" minimal story |
| No tags | Note: "No formal releases yet" |
