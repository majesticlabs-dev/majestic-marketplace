---
name: rails:code-review
description: Rails-specific code review using smart agent selection based on changed files
argument-hint: "[PR #/URL | --staged | --branch | files...]"
allowed-tools: Bash, Read, Grep, Glob
---

# Rails Code Review

Rails-specific code review that invokes the Rails code review orchestrator.

> **Note:** For generic code review with auto-detection, use `/majestic:code-review` instead.

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
git diff --name-only --diff-filter=d

# Staged mode
git diff --cached --name-only --diff-filter=d

# Branch mode (read from config with local override support)
config_get() {
  local key="$1" val=""
  if [ -z "${AGENTS_CONFIG:-}" ]; then
    val=$(grep "^${key}:" .agents.local.yml 2>/dev/null | head -1 | awk '{print $2}')
    [ -z "$val" ] && val=$(grep "^${key}:" .agents.yml 2>/dev/null | head -1 | awk '{print $2}')
  else
    val=$(grep "^${key}:" "$AGENTS_CONFIG" 2>/dev/null | head -1 | awk '{print $2}')
  fi
  echo "$val"
}
DEFAULT=$(config_get default_branch)
DEFAULT=${DEFAULT:-main}
git diff ${DEFAULT}...HEAD --name-only --diff-filter=d

# PR mode
gh pr diff <PR_NUMBER> --name-only
```

## Step 2: Invoke Rails Code Review Orchestrator

Use the Task tool to invoke the Rails code review orchestrator agent:

```
Task: majestic-rails:review/code-review-orchestrator

Prompt: "Review these Rails files. Scope: [scope mode from arguments]

Changed files:
[file list from Step 1]"
```

The orchestrator will:
1. Select appropriate specialized agents based on file patterns
2. Load project-specific review topics (if configured)
3. Run all agents in parallel
4. Synthesize findings into P1/P2/P3 severity levels
5. Return a comprehensive review report

## Step 3: Present Results

The orchestrator returns a synthesized report with:
- **Status:** BLOCKED / NEEDS CHANGES / APPROVED
- **P1 Critical Issues:** Security, data integrity, breaking changes
- **P2 Important Issues:** Performance, conventions, project topics
- **P3 Suggestions:** Style, optional improvements
- **Agent Reports:** Full details in collapsible sections

Present this report to the user.

## Example Usage

```bash
/rails:code-review                    # Unstaged changes (default)
/rails:code-review --staged           # Pre-commit
/rails:code-review --branch           # Branch vs default branch
/rails:code-review #123               # PR
/rails:code-review app/models/*.rb    # Specific files
```

## Related Commands

- `/majestic:code-review` - Generic code review with tech stack auto-detection
- `/majestic:init-agents-md` - Configure review topics and tech stack
