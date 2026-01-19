---
description: Get code review from external LLMs (Codex, Gemini) on current changes
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: "[--uncommitted|--staged|--branch|--base <branch>] [--llm codex|gemini|all] [--model <model>]"
---

# External Review

Get code review feedback from external LLMs (Codex, Gemini) on your current changes.

## Arguments

<input_arguments> $ARGUMENTS </input_arguments>

**Scope Options:**
- (no args) - Uncommitted changes (default)
- `--staged` - Only staged changes
- `--branch` - Current branch vs main
- `--base <branch>` - Changes against specific branch
- `--uncommitted` - Staged + unstaged + untracked

**LLM Options:**
- `--llm codex` - Use only Codex
- `--llm gemini` - Use only Gemini
- `--llm all` - Use both (default)
- `--model <model>` - Specific model to use

**Examples:**
```
/majestic-llm:review
/majestic-llm:review --staged --llm codex
/majestic-llm:review --branch --llm all
/majestic-llm:review --base main --model gpt-5.2-codex
```

## Available Models

### Codex (OpenAI)
| Model | Use Case |
|-------|----------|
| `gpt-5.2-codex` | Latest, high reasoning (default) |
| `gpt-5.1-codex-max` | Maximum thoroughness |
| `gpt-5.1-codex` | Balanced |
| `gpt-5.1-codex-mini` | Fast reviews |

### Gemini (Google)
| Model | Use Case |
|-------|----------|
| `gemini-2.5-flash` | Fast reviews |
| `gemini-2.5-pro` | Balanced |
| `gemini-3.0-pro-preview` | Latest (default) |

## Process

### Step 1: Parse Arguments

Extract from `$ARGUMENTS`:
- **Scope:** `--uncommitted`, `--staged`, `--branch`, or `--base <branch>`
- **LLM selection:** `--llm` value (default: `all`)
- **Model:** `--model` value (default: max models for reviews)

### Step 2: Check for Changes

```bash
# Check if there are changes to review
git status --porcelain
```

If no changes, report and exit.

### Step 3: Check CLI Availability

```bash
which codex >/dev/null 2>&1 && echo "codex:ok" || echo "codex:missing"
which gemini >/dev/null 2>&1 && echo "gemini:ok" || echo "gemini:missing"
```

### Step 4: Launch Reviews

**Single LLM Mode:**

For Codex (has built-in review command):
```
Task: majestic-llm:codex-reviewer
Prompt: "Review [scope]. Model: [model]"
```

For Gemini:
```
Task: majestic-llm:gemini-reviewer
Prompt: "Review [scope]. Model: [model]"
```

**Multi-LLM Mode:**
Launch BOTH agents in parallel:
```
Task 1: majestic-llm:codex-reviewer
Prompt: "Review [scope]. Model: [model]"

Task 2: majestic-llm:gemini-reviewer
Prompt: "Review [scope]. Model: [model]"
```

### Step 5: Synthesize Results

**Single LLM:** Present issues directly with severity.

**Multi-LLM:** Synthesize into unified view:
- **Consensus issues:** Found by both (high priority)
- **Codex-only:** Issues unique to Codex
- **Gemini-only:** Issues unique to Gemini

## Output Format

### Single LLM

```markdown
## External Code Review

**Scope:** [uncommitted / staged / branch]
**Reviewer:** [Codex/Gemini] ([model])

### Issues Found

#### Critical
- **[Issue]** - `file:line` - [Description]

#### Important
- **[Issue]** - `file:line` - [Description]

#### Suggestions
- [Suggestion]

### Verdict
[APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]
```

### Multi-LLM

```markdown
## External Code Review

**Scope:** [uncommitted / staged / branch]
**Reviewers:** Codex ([model]), Gemini ([model])

---

### Consensus Issues (High Priority)
Issues found by BOTH reviewers:

#### Critical
- **[Issue]** - `file:line` - [Description]
  - Codex: [detail]
  - Gemini: [detail]

#### Important
- **[Issue]** - `file:line` - [Description]

---

### Codex-Only Findings
Issues only Codex caught:
- **[Issue]** - `file:line` - [Description]

### Gemini-Only Findings
Issues only Gemini caught:
- **[Issue]** - `file:line` - [Description]

---

### Combined Verdict

| Reviewer | Verdict | Critical | Important | Suggestions |
|----------|---------|----------|-----------|-------------|
| Codex | [verdict] | X | Y | Z |
| Gemini | [verdict] | X | Y | Z |

**Recommendation:** [BLOCKED / NEEDS CHANGES / APPROVED]

---

<details>
<summary>Full Codex Review</summary>

[Response]

</details>

<details>
<summary>Full Gemini Review</summary>

[Response]

</details>
```

## Examples

### Quick Review of Uncommitted Changes
```
/majestic-llm:review
```

### Review Staged Changes with Codex Only
```
/majestic-llm:review --staged --llm codex
```

### Thorough Branch Review
```
/majestic-llm:review --branch --model gpt-5.2-codex
```

### Review Against Specific Branch
```
/majestic-llm:review --base develop --llm all
```

## Error Handling

### No Changes
```markdown
**No changes to review**

Ensure you have:
- Uncommitted changes (default)
- Staged changes (`--staged`)
- Commits on your branch (`--branch`)
```

### No LLMs Available
```markdown
**Error:** No external LLMs available

Please install at least one:
- Codex: `npm install -g @openai/codex && codex login`
- Gemini: See https://github.com/google-gemini/gemini-cli
```

### Diff Too Large
```markdown
**Warning:** Diff is very large (X lines)

Consider:
- Reviewing specific files instead
- Breaking changes into smaller commits
- Using `--staged` to review incrementally
```

## Integration with Claude Review

This command complements Claude's built-in review capabilities:

1. Run Claude's review first: `/majestic:code-review`
2. Get external perspectives: `/majestic-llm:review`
3. Compare findings to identify blind spots

The multi-LLM approach helps catch issues that any single model might miss.

## How It Works

Unlike generic LLM reviews, this command uses `codex exec` with custom prompts that include:

- **Project context** from CLAUDE.md
- **Project lessons** from `.agents-os/lessons/`
- **Explicit focus areas** for targeted review

This gives you control over what gets reviewed, rather than relying on opinionated built-in review commands.
