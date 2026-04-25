---
name: quality-gate
description: Run quality gate checks on code changes with tech stack-aware reviewers
argument-hint: "[PR #/URL | --staged | --branch | files...]"
allowed-tools: Bash Read Grep Glob Task
---

# Quality Gate

Run comprehensive code review through the quality gate agent, which orchestrates multiple specialized reviewers based on your project's tech stack.

## Config

```
TECH_STACK = config_read("tech_stack", "generic")
APP_STATUS = config_read("app_status", "development")
LESSONS_PATH = config_read("lessons_path", ".agents/lessons/")
```

```bash
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
```

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Scope modes:**
- `#123` or GitHub URL → PR changes
- (no args) → unstaged changes (working directory)
- `--staged` → staged changes only
- `--branch` → current branch vs default branch
- `path/to/file ...` → specific files

## Step 1: Determine Scope

Parse arguments to determine what code to review:

```bash
# Default (unstaged changes)
git diff --name-only --diff-filter=d

# Staged mode
git diff --cached --name-only --diff-filter=d

# Branch mode (use default_branch from Context)
git diff <default_branch>...HEAD --name-only --diff-filter=d

# PR mode
gh pr diff <PR_NUMBER> --name-only
```

If no changes found, report:

```
## Quality Gate: APPROVED

**Reason:** No changes to review.
```

## Step 2: Determine Context Description

Create a context description based on scope:

| Scope | Context Description |
|-------|---------------------|
| PR #123 | PR #123: <PR title from gh pr view> |
| --branch | Branch: <current branch name> |
| --staged | Staged changes |
| (no args) | Working directory changes |
| files... | Files: <file list> |

## Step 3: Invoke Quality Gate Agent

Launch the quality-gate agent with the determined context:

```
Task: majestic-engineer:workflow:quality-gate

Prompt: |
  Context: <context description from Step 2>
  Branch: <branch name or --staged>

  Changed files:
  <file list>
```

## Step 4: Present Results

The quality-gate agent returns a structured verdict. Present the full report to the user.

**Verdict outcomes:**
- **APPROVED** - Ready to ship
- **NEEDS CHANGES** - Fix required issues before shipping
- **BLOCKED** - Critical issues require immediate attention

## Examples

```bash
# Review unstaged changes
/majestic-engineer:quality-gate

# Review staged changes
/majestic-engineer:quality-gate --staged

# Review current branch vs main
/majestic-engineer:quality-gate --branch

# Review a PR
/majestic-engineer:quality-gate #123

# Review specific files
/majestic-engineer:quality-gate app/models/user.rb app/controllers/users_controller.rb
```

## Configuration

Configure reviewers in `.agents.yml`:

```yaml
quality_gate:
  reviewers:
    - security-review
    - pragmatic-rails-reviewer
    - performance-reviewer
```

See CLAUDE.md for available reviewers and configuration options.
