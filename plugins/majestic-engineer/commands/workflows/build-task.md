---
name: majestic:build-task
description: Autonomous task implementation from GitHub Issues - research, plan, build, review, fix, ship
argument-hint: "<issue-url-or-number>"
allowed-tools: Bash, Read, Grep, Glob, Task, WebFetch, SlashCommand, TodoWrite, Skill
---

# Build Task

Autonomously implement a task from a GitHub Issue through the full development lifecycle.

## Arguments

<task_reference> $ARGUMENTS </task_reference>

**Accepted formats:**
- `#123` - Issue number
- `123` - Issue number (bare)
- `https://github.com/owner/repo/issues/123` - Full URL

## Workflow Overview

```mermaid
flowchart TD
    subgraph Input
        A[GitHub Issue #123]
    end

    subgraph "1. Fetch"
        B[gh issue view]
    end

    subgraph "2. Worktree Check"
        W{workflow: worktrees?}
        WT[Create worktree]
    end

    subgraph "3. Research (conditional)"
        C{{web-research}}
    end

    subgraph "4. Plan"
        D{{architect}}
    end

    subgraph "5. Build"
        E{{general-purpose}}
    end

    subgraph "6. Review"
        F(/code-review)
    end

    subgraph "7. Fix Loop"
        G{{general-purpose}}
        H{Attempt < 3?}
    end

    subgraph "8. Ship"
        I(/majestic:ship-it)
        J[gh issue close]
    end

    A --> B
    B --> W
    W -->|Yes| WT --> K{Research needed?}
    W -->|No| K
    K -->|Yes| C --> D
    K -->|No| D
    D --> E
    E --> F
    F --> L{Approved?}
    L -->|Yes| I
    L -->|No| G
    G --> H
    H -->|Yes| F
    H -->|No| M[Pause & Report]
    I --> J
    J --> N[Done]
```

**Legend:**
- `[ ]` Bash/CLI commands
- `{{ }}` Agents (Task tool)
- `( )` Slash commands
- `{ }` Decision points

## Step 1: Fetch & Parse Issue

```bash
# Extract issue number from input
# If URL: parse out the number
# If #123 or 123: use directly

gh issue view <NUMBER> --json title,body,labels,assignees,milestone
```

**Create TodoWrite** with high-level steps based on issue content.

## Step 1.5: Set Terminal Title

After fetching the issue, set the terminal title to identify this session:

```
Task (majestic-tools:set-title):
  prompt: |
    Set title to "🔨 #<NUMBER>: <issue-title-truncated-to-40-chars>"
```

This helps identify the terminal when running multiple Claude Code sessions.

## Step 2: Check Git Workflow Preferences

**Read `.agents.yml`** for workflow preferences:

```bash
# Read workflow and branch naming from config
WORKFLOW=$(grep "workflow:" .agents.yml 2>/dev/null | awk '{print $2}')
BRANCH_NAMING=$(grep "branch_naming:" .agents.yml 2>/dev/null | awk '{print $2}')

# Defaults
WORKFLOW=${WORKFLOW:-branches}
BRANCH_NAMING=${BRANCH_NAMING:-issue-desc}
```

**Generate branch name based on pattern:**

| Pattern in .agents.yml | Generated Branch Name |
|-----------------------|----------------------|
| `feature/desc` | `feature/<issue-title-slug>` |
| `issue-desc` | `<NUMBER>-<issue-title-slug>` |
| `type/issue-desc` | `feat/<NUMBER>-<issue-title-slug>` (or `fix/` for bugs) |
| `user/desc` | `<git-user>/<issue-title-slug>` |
| Not configured | `<NUMBER>-<issue-title-slug>` (default) |

**If workflow is "worktrees":**

1. Create a worktree for this feature:
   ```
   skill git-worktree
   ```
   - Branch name: generated from pattern above
   - Base branch: main/master

2. All subsequent steps run inside the worktree directory

3. After shipping, clean up the worktree

**If workflow is "branches" or not configured:**

1. Create branch with generated name:
   ```bash
   git checkout -b <generated-branch-name>
   ```

2. Continue with standard workflow

## Step 3: Research (Conditional)

**Trigger research if issue body contains:**
- "research", "investigate", "best practice", "how to"
- Links to external documentation
- Questions about approach
- New library/framework mentions

**If triggered:**
```
Task (majestic-engineer:research:web-research):
  prompt: |
    Research the following for implementation:

    Issue: [title]
    Context: [relevant body excerpts]

    Find:
    - Best practices for this approach
    - Common pitfalls to avoid
    - Example implementations
    - Relevant documentation

    Return concise, actionable findings.
```

## Step 4: Plan Implementation

```
Task (majestic-engineer:plan:architect):
  prompt: |
    Create an implementation plan for this GitHub Issue:

    ## Issue
    Title: [title]
    Body: [body]

    ## Research Findings (if any)
    [research output]

    ## Requirements
    - Create a clear, step-by-step implementation plan
    - Identify files to create/modify
    - Note any dependencies or prerequisites
    - Include test strategy

    Return a structured plan I can execute.
```

**Update TodoWrite** with specific implementation tasks from the plan.

## Step 5: Build Implementation

```
Task (general-purpose):
  prompt: |
    Implement this task following the plan below.

    ## GitHub Issue
    Title: [title]
    Body: [body]

    ## Implementation Plan
    [architect output]

    ## Instructions
    1. Follow the plan step-by-step
    2. Write tests alongside implementation
    3. Commit your work with clear messages
    4. Report back: files changed, tests written, any blockers

    Work autonomously until complete.
```

## Step 6: Code Review

**Detect project type and select reviewer:**

| Project Type | Detection | Review Command/Agent |
|--------------|-----------|---------------------|
| Rails | `Gemfile` with `rails` | `/majestic-rails:workflows:code-review --branch` |
| Ruby | `Gemfile` (no rails) | `majestic-rails:review:pragmatic-rails-reviewer` |
| Python | `pyproject.toml` or `requirements.txt` | `majestic-python:python-reviewer` |
| Other | Default | `majestic-engineer:review:simplicity-reviewer` |

**For Rails projects:**
```
SlashCommand: /majestic-rails:workflows:code-review --branch
```

**For other projects:**
```
Task (appropriate-reviewer):
  prompt: |
    Review the changes on this branch for:
    - Code quality and conventions
    - Test coverage
    - Potential issues

    Context: Implementing [issue title]

    Return: APPROVED, NEEDS CHANGES (with specific fixes), or BLOCKED (with blockers)
```

## Step 7: Fix Review Feedback (Loop)

**If review returns NEEDS CHANGES or BLOCKED:**

```
Task (general-purpose):
  prompt: |
    Fix these code review issues:

    ## Review Feedback
    [review output with specific issues]

    ## Instructions
    1. Address each issue listed
    2. Run tests to verify fixes
    3. Commit the fixes
    4. Report what you fixed
```

**Re-run Step 6 (Code Review)**

**Loop limits:**
- Max 3 iterations
- After 3 failures: pause and report to user

## Step 8: Ship

**Once review passes (APPROVED):**

```
SlashCommand: /majestic-engineer:workflows:ship-it
```

**After PR is created, close the issue:**

```bash
gh issue close <NUMBER> --comment "Implemented in PR #<PR_NUMBER>"
```

**Note:** If using a worktree, it remains active until the PR is merged. Use `skill git-worktree` to manage worktrees manually after merge.

## Output Summary

After completion, provide:

```
## Build Task Complete

**Issue:** #123 - [title]
**Status:** Shipped

### Workflow Summary
- Branch: `feat/42-add-authentication` [worktree | standard]
- Research: [Skipped | Completed - key findings]
- Plan: [X steps identified]
- Build: [X files changed, X tests added]
- Review: [Passed on attempt X]
- Ship: PR #456 created, issue closed

### Files Changed
- `path/to/file.rb` - [description]
- `spec/path/to_spec.rb` - [tests added]

### PR Link
https://github.com/owner/repo/pull/456
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Issue not found | Report error, exit |
| Research fails | Continue without research, note in summary |
| Build fails (tests don't pass) | Attempt fix, max 2 retries, then pause |
| Review blocked 3 times | Pause, report issues to user |
| Ship fails (lint/CI) | Use github-resolver agent to fix |

## Example Usage

```bash
# By issue number
/majestic:build-task #42

# By URL
/majestic:build-task https://github.com/myorg/myrepo/issues/42

# Bare number
/majestic:build-task 42
```
