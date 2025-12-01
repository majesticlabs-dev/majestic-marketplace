---
name: rails:code-review
description: Comprehensive Rails code review using smart agent selection based on changed files
argument-hint: "[PR #/URL | --staged | --branch | files...]"
allowed-tools: Bash, Read, Grep, Glob, Task, AskUserQuestion
---

# Rails Code Review

Review code changes using specialized agents run in parallel.

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Scope modes:**
- `#123` or GitHub URL → PR changes
- (no args) → unstaged changes (working directory)
- `--staged` → staged changes only
- `--branch` → current branch vs default branch
- `path/to/file.rb ...` → specific files

## Step 1: Gather Changed Files

```bash
# Default (unstaged changes)
git diff --name-only

# Staged mode
git diff --cached --name-only

# Branch mode (detect default branch first)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
git diff ${DEFAULT_BRANCH:-master}...HEAD --name-only

# PR mode
gh pr diff <PR_NUMBER> --name-only
```

## Step 2: Select Agents

**Always run:**
- `review/simplicity-reviewer`
- `review/pragmatic-rails-reviewer`

**Add if detected:**
| Pattern | Agent |
|---------|-------|
| `db/migrate/*` | + `review/data-integrity-reviewer` |
| `app/models/*.rb` with associations/queries | + `review/dhh-code-reviewer` |
| `.each`, `.map`, `.all`, complex queries | + `review/performance-reviewer` |

**If uncertain (>5 files, no patterns detected):** Use `AskUserQuestion` to ask which additional agents to run with multi-select enabled.

## Step 3: Run Agents in Parallel

Launch ALL selected agents in a SINGLE message with multiple Task tool calls:

```
Task 1: review/simplicity-reviewer → "Review [files] for YAGNI, anti-patterns"
Task 2: review/pragmatic-rails-reviewer → "Review [files] for Rails conventions"
Task 3: (if selected) review/data-integrity-reviewer → "Review [files] for migration safety"
Task 4: (if selected) review/performance-reviewer → "Review [files] for N+1, performance"
Task 5: (if selected) review/dhh-code-reviewer → "Review [files] for Rails philosophy"
```

## Step 4: Synthesize Output

Collect agent outputs and categorize:

**P1 - Critical (Blocks Merge):** Security, data integrity, breaking changes
**P2 - Important (Should Fix):** Performance, convention violations, complexity
**P3 - Suggestions:** Style, optional improvements

**Status:** BLOCKED (any P1) | NEEDS CHANGES (P2 only) | APPROVED (P3 or clean)

## Example Usage

```bash
/code-review                    # Unstaged changes (default)
/code-review --staged           # Pre-commit
/code-review --branch           # Branch vs default branch
/code-review #123               # PR
/code-review app/models/*.rb    # Specific files
```
