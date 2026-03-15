---
name: external-llm-review
description: Get code review feedback from external LLMs (OpenAI Codex, Google Gemini) with full project context. Use when you want a second opinion on code changes, with explicit control over review focus and project-aware prompts.
allowed-tools: Bash Read Grep Glob
---

# External LLM Code Review

**Audience:** Developers seeking second-opinion code reviews from external LLMs.
**Goal:** Invoke external LLM CLIs in sandbox/read-only mode to review code changes, then present structured findings for comparison with Claude's review.

## When to Use

- High-stakes code changes (security, breaking changes, architecture shifts)
- Validating Claude's code review with diverse AI perspectives
- Surfacing blind spots through cross-model review
- When you want explicit control over review focus areas

## General Workflow

1. Determine review scope (uncommitted, staged, branch, specific commit)
2. Gather the diff and project context (CLAUDE.md, lessons)
3. Build a review prompt with context, focus areas, and the diff
4. Execute the external CLI in sandbox/read-only mode
5. Parse and structure findings by severity

## Gathering the Diff

Based on the requested scope:

```bash
# Uncommitted changes (default)
git diff HEAD

# Staged only
git diff --cached

# Against base branch
git diff main...HEAD

# Specific commit
git show <sha>

# Specific files
git diff -- path/to/file.rb
```

## Gathering Project Context

```bash
# Project conventions
cat CLAUDE.md 2>/dev/null | head -200

# Institutional memory / lessons
ls .agents/lessons/*.md 2>/dev/null && \
  head -50 .agents/lessons/*.md
```

Lessons provide project-specific patterns and anti-patterns discovered during development.

## Building the Review Prompt

Construct a prompt that includes:

```
## Project Context

<Insert relevant CLAUDE.md sections>

## Project Lessons

<Insert relevant lessons from .agents/lessons/ if available>

## Focus Areas

<Insert user-specified focus areas, or use defaults:>
1. Logic errors and bugs
2. Security vulnerabilities
3. Performance issues
4. Error handling gaps
5. Code clarity and maintainability

## Changes to Review

<Insert git diff>

## Instructions

Review the changes above. For each issue found:
1. Specify the file and line number
2. Describe the issue clearly
3. Suggest a fix if applicable
4. Rate severity: Critical / Important / Suggestion

Provide a final verdict: APPROVE, REQUEST CHANGES, or NEEDS DISCUSSION.
```

## Codex Code Review

### Prerequisites

- Codex CLI installed (`codex --version` to verify)
- OpenAI authentication configured (`codex login`)
- Git repository with changes to review

### Available Models

| Model | Use Case | Cost |
|-------|----------|------|
| `gpt-5.2-codex` | Latest, high reasoning (default) | High |
| `gpt-5.1-codex-max` | Maximum thoroughness | High |
| `gpt-5.1-codex` | Balanced | Medium |
| `gpt-5.1-codex-mini` | Fast reviews | Low |

### CLI Execution

```bash
codex exec \
  -s read-only \
  -m gpt-5.2-codex \
  -c model_reasoning_effort="xhigh" \
  "<review-prompt>"
```

For large diffs, pipe via stdin:

```bash
cat <<'EOF' | codex exec -s read-only -m gpt-5.2-codex -c model_reasoning_effort="xhigh" -
<review-prompt-content>
EOF
```

### Codex Review Examples

```bash
# Basic review (uncommitted changes)
CONTEXT=$(cat CLAUDE.md 2>/dev/null | head -200)
DIFF=$(git diff HEAD)
codex exec -s read-only -m gpt-5.2-codex -c model_reasoning_effort="xhigh" \
  "Review these changes. Context: $CONTEXT. Diff: $DIFF"

# Review with specific focus
codex exec -s read-only -m gpt-5.2-codex -c model_reasoning_effort="xhigh" \
  "Review for security vulnerabilities and SQL injection risks only. Diff: $(git diff HEAD)"

# Review against main branch
DIFF=$(git diff main...HEAD)
codex exec -s read-only -m gpt-5.2-codex -c model_reasoning_effort="xhigh" \
  "Review all changes on this feature branch. $DIFF"
```

### Why `codex exec` over `codex review`

| Aspect | `codex review` | `codex exec` (recommended) |
|--------|----------------|---------------------------|
| Prompt | Codex's opinionated | Custom, project-aware |
| Context | None | CLAUDE.md, lessons |
| Focus | Generic | Explicit guidance |
| Flexibility | Limited | Full control |

### Codex Error Handling

| Error | Resolution |
|-------|------------|
| CLI not found | Install: `npm install -g @openai/codex` then `codex login` |
| Auth failed | Run: `codex login` |
| No changes found | Verify scope: uncommitted, staged, branch, or commit SHA |
| Diff too large | Review specific files, break into smaller commits, or use `--staged` incrementally |
| Context gathering failed | Proceed with generic review; note that CLAUDE.md/.agents/lessons/ improve results |

## Gemini Code Review

### Prerequisites

- Gemini CLI installed (`gemini --version` to verify)
- Google authentication configured
- Git repository with changes to review

### Available Models

| Model | Use Case | Cost |
|-------|----------|------|
| `gemini-2.5-flash` | Fast reviews | Low |
| `gemini-2.5-pro` | Balanced reasoning | Medium |
| `gemini-3.0-pro-preview` | Latest Gemini 3 Pro (default) | Medium |

Parse model from prompt if specified (e.g., "using flash, review..." or "model: gemini-2.5-pro").

### CLI Execution

```bash
gemini --sandbox --output-format text --model <model> "<review-prompt-with-diff>"
```

**Important flags:**
- `--sandbox` - Prevents code modifications
- `--output-format text` - Plain text output
- `--model <model>` - Model to use (default: `gemini-3.0-pro-preview`)

### Gemini Review Examples

```bash
# Review unstaged changes
DIFF=$(git diff)
gemini --sandbox --output-format text \
  "Review this code diff for bugs, security issues, and code quality problems. Provide file:line references.

$DIFF"

# Review with focus areas
DIFF=$(git diff --cached)
gemini --sandbox --output-format text "$(cat <<EOF
Review this diff focusing on:
1. SQL injection vulnerabilities
2. N+1 query patterns
3. Missing error handling
4. Breaking API changes

Provide specific file:line references for each issue.

Diff:
$DIFF
EOF
)"

# Review branch changes
DIFF=$(git diff main...HEAD)
gemini --sandbox --output-format text \
  "Review this branch diff for production readiness. Check for bugs, security issues, performance problems, and test coverage gaps.

$DIFF"

# Review specific files if diff is too large
DIFF=$(git diff -- app/models/user.rb)
gemini --sandbox --output-format text "Review this diff:

$DIFF"
```

### Gemini Error Handling

| Error | Resolution |
|-------|------------|
| CLI not found | Install and authenticate following official docs |
| No changes found | Verify scope: unstaged, staged, branch |
| Diff too large | Split into smaller chunks, review file-by-file, or summarize large files |

## Output Format

```markdown
## [Codex/Gemini] Code Review Results

**Scope:** [uncommitted / staged / base:main / commit:abc123 / files]
**Model:** [model used] (via [Codex/Gemini] CLI)

### Context Used
- CLAUDE.md: [Yes/No - summary of relevant sections]
- Lessons: [Yes/No - count of lessons applied]
- Focus Areas: [List of focus areas]

### Summary
[High-level assessment]

### Issues Found

#### Critical
- **[Issue]** - `file:line` - [Description and fix suggestion]

#### Important
- **[Issue]** - `file:line` - [Description]

#### Suggestions
- **[Suggestion]** - `file:line` - [Description]

### Verdict
[APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]

### Unique Insights
Issues found that might not be in Claude's review:
- [Insight 1]
- [Insight 2]

### Raw Output
<details>
<summary>Full Review</summary>

[Complete unedited response]

</details>
```

## Comparing Results with Claude's Review

When presenting results from external LLMs alongside Claude's review, highlight:

1. **Consensus** - Issues both Claude and the external LLM identified
2. **External-only** - Issues only the external LLM caught (Claude's blind spots)
3. **Claude-only** - Issues only Claude caught (for reference)
4. **Conflicts** - Where Claude and the external LLM disagree

## Safety Constraints

- **Always use sandbox/read-only mode** - No code modifications
- **Truncate large diffs** - Don't overwhelm with huge diffs
- **No secrets in prompts** - Scrub sensitive data from diffs if needed
- **Verify suggestions** - External LLM feedback is one perspective, not authoritative
