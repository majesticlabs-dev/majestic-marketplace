---
name: majestic:code-review
description: Generic code review that auto-detects tech stack and delegates to appropriate framework-specific orchestrator
argument-hint: "[PR #/URL | --staged | --branch | files...]"
allowed-tools: Bash, Read, Grep, Glob
---

# Code Review

Generic code review command that detects your project's tech stack and delegates to the appropriate framework-specific review orchestrator.

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Scope modes:**
- `#123` or GitHub URL → PR changes
- (no args) → unstaged changes (working directory)
- `--staged` → staged changes only
- `--branch` → current branch vs default branch
- `path/to/file ...` → specific files

## Step 1: Detect Tech Stack

### Check .agents.yml Configuration

```bash
grep "tech_stack:" "${AGENTS_CONFIG:-.agents.yml}" 2>/dev/null | awk '{print $2}'
```

If `tech_stack:` is found in `.agents.yml`, use that value.

### Auto-Detection Fallback

If not configured in `.agents.yml`, detect from project files:

| Detection | Tech Stack |
|-----------|------------|
| `Gemfile` exists | `rails` |
| `pyproject.toml` or `requirements.txt` exists | `python` |
| `package.json` exists (no Gemfile) | `javascript` |
| None of the above | `generic` |

```bash
# Detection commands
[ -f Gemfile ] && echo "rails"
[ -f pyproject.toml ] || [ -f requirements.txt ] && echo "python"
[ -f package.json ] && echo "javascript"
```

## Step 2: Gather Changed Files

Based on scope from arguments:

```bash
# Default (unstaged changes)
git diff --name-only --diff-filter=d

# Staged mode
git diff --cached --name-only --diff-filter=d

# Branch mode (read from .agents.yml, fallback to main)
DEFAULT=$(grep "default_branch:" "${AGENTS_CONFIG:-.agents.yml}" 2>/dev/null | awk '{print $2}')
DEFAULT=${DEFAULT:-main}
git diff ${DEFAULT}...HEAD --name-only --diff-filter=d

# PR mode
gh pr diff <PR_NUMBER> --name-only
```

## Step 3: Delegate to Framework Orchestrator

Based on detected tech stack, invoke the appropriate orchestrator agent via Task tool:

### Rails Projects

```
Task: majestic-rails:review/code-review-orchestrator

Prompt: "Review these Rails files. Scope: [scope mode]

Changed files:
[file list]"
```

### Python Projects

```
Task: majestic-python:review/code-review-orchestrator

Prompt: "Review these Python files. Scope: [scope mode]

Changed files:
[file list]"
```

### JavaScript Projects (Not Yet Supported)

```markdown
**Tech Stack:** JavaScript

JavaScript code review orchestrator is not yet available.

For now, you can run the generic simplicity reviewer:
`/majestic-engineer:review/simplicity-reviewer [files]`

Or configure `tech_stack: generic` in AGENTS.md to use generic reviewers.
```

### Generic Projects

For unknown or generic tech stacks, run minimal reviewers directly:

1. Load project topics (if configured)
2. Run `majestic-engineer:review/simplicity-reviewer`
3. Run `majestic-engineer:review/project-topics-reviewer` (if topics exist)
4. Synthesize output

```
Task 1: majestic-engineer:review/simplicity-reviewer
Prompt: "Review these files for YAGNI violations, unnecessary complexity: [file list]"

Task 2: majestic-engineer:review/project-topics-reviewer (if topics exist)
Prompt: "Review these files against project topics: [file list]

Topics:
[topics content]"
```

## Step 4: Report Results

The orchestrator will return a synthesized report. Present it to the user with:

1. **Status** - BLOCKED / NEEDS CHANGES / APPROVED
2. **Summary** - Key findings by severity (P1/P2/P3)
3. **Details** - Full agent reports in collapsible sections

## Tech Stack Configuration

To explicitly set your tech stack (recommended for multi-language projects), add to `AGENTS.md`:

```markdown
## Project Configuration

tech_stack: rails  # rails | python | javascript | generic
```

## Framework-Specific Commands

For direct access to framework-specific reviews (skipping detection):

| Framework | Command |
|-----------|---------|
| Rails | `/majestic-rails:code-review` |
| Python | (use this command with `tech_stack: python`) |
| Generic | (use this command with `tech_stack: generic`) |

## Examples

```bash
# Review unstaged changes (auto-detect tech stack)
/majestic:code-review

# Review staged changes
/majestic:code-review --staged

# Review current branch vs main
/majestic:code-review --branch

# Review a PR
/majestic:code-review #123

# Review specific files
/majestic:code-review app/models/user.rb app/controllers/users_controller.rb
```
