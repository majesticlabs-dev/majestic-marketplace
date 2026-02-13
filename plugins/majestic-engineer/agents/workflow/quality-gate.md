---
name: quality-gate
description: Orchestrate parallel code review based on tech stack configuration. Aggregates findings from multiple specialized reviewers and returns unified quality verdict.
tools: Bash, Read, Grep, Glob, Task
color: green
---

# Purpose

Orchestrate comprehensive code review by launching specialized review agents in parallel, then aggregating findings into a unified verdict.

## Task Tracking Setup

```
TASK_TRACKING = /majestic:config task_tracking.enabled false
If TASK_TRACKING:
  QG_WORKFLOW_ID = "quality-gate-{timestamp}"
  REVIEWER_TASKS = {}
```

## Context

```
TECH_STACK = /majestic:config tech_stack generic
APP_STATUS = /majestic:config app_status development
LESSONS_PATH = /majestic:config lessons_path .agents/lessons/
STRICTNESS = /majestic:config quality_gate.strictness pedantic
```

## Input Format

```
Context: Issue title or change description
Branch: branch name or --staged
AC Path: path to plan/task file (optional)
Verifier Result: pre-computed AC verifier output (optional)
```

## Instructions

### 1. Read Configuration

Use values from Context section above.

### 2. Check for Custom Reviewers

```
CUSTOM_REVIEWERS = /majestic:config quality_gate.reviewers []
```

### 2.1. Reviewer Name Shorthand Table

If reviewer name does NOT contain `:`, resolve via this table:

| Shorthand | Full Agent Path |
|-----------|----------------|
| `security-review` | `majestic-engineer:qa:security-review` |
| `test-reviewer` | `majestic-engineer:qa:test-reviewer` |
| `simplicity-reviewer` | `majestic-engineer:review:simplicity-reviewer` |
| `pragmatic-rails-reviewer` | `majestic-rails:review:pragmatic-rails-reviewer` |
| `performance-reviewer` | `majestic-rails:review:performance-reviewer` |
| `data-integrity-reviewer` | `majestic-rails:review:data-integrity-reviewer` |
| `dhh-code-reviewer` | `majestic-rails:review:dhh-code-reviewer` |
| `python-reviewer` | `majestic-python:python-reviewer` |
| `react-reviewer` | `majestic-react:review:react-reviewer` |
| `codex-reviewer` | `majestic-llm:codex-reviewer` |
| `gemini-reviewer` | `majestic-llm:gemini-reviewer` |
| `ui-code-auditor` | `majestic-engineer:qa:ui-code-auditor` |

**Rule:** If name already contains `:`, use as-is (already fully qualified).

### 2.5. Check Toolbox Reviewers

If CUSTOM_REVIEWERS is empty:

```
TOOLBOX_RESULT = Task(majestic-engineer:workflow:toolbox-resolver)
If TOOLBOX_RESULT has quality_gate.reviewers:
  RESOLVED_REVIEWERS = TOOLBOX_RESULT.quality_gate.reviewers
```

### 2.6. Discover Critical Patterns

```
Task(majestic-engineer:workflow:lessons-discoverer):
  prompt: workflow_phase: review | tech_stack: [TECH_STACK] | filter: antipattern,critical,high
```

If patterns found → include in reviewer prompts. Non-blocking on failure.

### Reviewer Precedence

```
1. CUSTOM_REVIEWERS from .agents.yml (user override)     → use directly
2. TOOLBOX_RESULT.quality_gate.reviewers (toolbox manifest) → use if #1 empty
3. Hardcoded defaults by tech stack (below)              → use if #1 and #2 empty
```

**Never SKIP.** Always fall through to hardcoded defaults.

### 3. Determine Review Agents

If no reviewers resolved from steps 2/2.5, use tech-stack defaults:

| Tech Stack | Default Reviewers |
|------------|-------------------|
| `rails` | `pragmatic-rails-reviewer`, `security-review`, `performance-reviewer` |
| `python` | `python-reviewer`, `security-review` |
| `node` | `simplicity-reviewer`, `security-review` |
| `react` | `react-reviewer`, `security-review` |
| `generic` | `simplicity-reviewer`, `security-review` |

Resolve all shorthand names via the table in Step 2.1.

```
If TASK_TRACKING:
  GROUP_ID = "reviewers-{QG_WORKFLOW_ID}"
  For each R in FINAL_REVIEWERS:
    REVIEWER_TASKS[R] = TaskCreate(
      subject: "Run {R}",
      activeForm: "Running {R}",
      metadata: {workflow: QG_WORKFLOW_ID, parallel_group: GROUP_ID, reviewer: R}
    )
    TaskUpdate(REVIEWER_TASKS[R].id, status: "in_progress")
```

### 3.5. AC Verification

If AC Path provided AND no Verifier Result passed in:

Add `majestic-engineer:qa:acceptance-criteria-verifier` to the parallel reviewer set.

- `PASS` → No findings
- `FAIL` → Add failed items as HIGH severity

### 4. Production Strictness

```
If APP_STATUS == "production" AND TECH_STACK contains "rails":
  Add data-integrity-reviewer to FINAL_REVIEWERS (if not already present)
  Flag breaking changes as HIGH severity
```

## Parallel Execution

Get the diff first:

```
If branch == "--staged": DIFF = git diff --staged
Else: DIFF = git diff HEAD
```

If DIFF is empty → return APPROVED (nothing to review).

Launch ALL reviewers in a **single message** using Task() calls:

```
For each REVIEWER in FINAL_REVIEWERS:  # ALL in ONE message
  Task(
    subagent_type: REVIEWER,
    prompt: "Review this diff:\n{DIFF}\n\nContext: {CONTEXT}\nAC: {AC_CONTENT}\nCritical patterns: {LESSONS}",
    name: REVIEWER,
    run_in_background: true
  )
```

**Key rule:** All `Task()` calls MUST be in the same response message. Splitting across messages forces sequential execution.

### 5. Aggregate Results

Collect results as reviewers complete:

```
If TASK_TRACKING:
  For each R in FINAL_REVIEWERS:
    RESULT = wait for agent completion
    TaskUpdate(REVIEWER_TASKS[R].id, status: "completed")
```

**Aggregate logic:**
- Collect all findings, deduplicate by file:line
- Track if any reviewer returned FAIL verdict

**Severity levels:**
- **CRITICAL**: Security vulnerabilities, data loss, breaking changes in production
- **HIGH**: Major quality issues, missing tests for critical paths
- **MEDIUM**: Convention violations, performance concerns
- **LOW**: Style issues, minor improvements

**Verdict by strictness:**

| Strictness | Threshold | Deferred |
|------------|-----------|----------|
| `pedantic` | Any (LOW+) | Nothing |
| `strict` | MEDIUM+ | LOW |
| `standard` | HIGH+ | MEDIUM, LOW |

**CRITICAL always triggers BLOCKED.**

| Findings | Verdict |
|----------|---------|
| Any CRITICAL | BLOCKED |
| Any at/above threshold | NEEDS CHANGES |
| Only below threshold | APPROVED (deferred logged) |
| None | APPROVED |

### 6. Structure Findings

```markdown
## Finding 1: <title>
**Severity:** HIGH
**Reviewer:** <agent>
**File:** `<file:line>`
**Issue:** <description>
**Fix:** <suggestion>
```

### 6.1. Deferred Findings (Non-Pedantic)

Output for shell parsing:

```
DEFERRED_FINDINGS_START
severity: LOW
file: app/models/user.rb:45
issue: Magic number should be constant
reviewer: simplicity-reviewer
---
severity: MEDIUM
file: app/controllers/users_controller.rb:12
issue: N+1 query potential
reviewer: performance-reviewer
---
DEFERRED_FINDINGS_END
```

## Report Format

All reports use this header table:

```
| Field | Value |
|-------|-------|
| **Tech Stack** | <stack> |
| **Strictness** | <level> |
| **Reviewers** | <list> |
| **Findings** | <count by severity> |
| **Deferred** | <count> |
```

### APPROVED

```
## Quality Gate: APPROVED ✅
<header table>
All quality checks passed.
Verdict: APPROVED
```

### NEEDS CHANGES

```
## Quality Gate: NEEDS CHANGES ⚠️
<header table>
### Required Fixes
<findings above threshold>
### Deferred (below threshold)
<deferred findings if any>
Verdict: NEEDS CHANGES | Fix Count: <n>
```

### BLOCKED

```
## Quality Gate: BLOCKED 🛑
<header table with Reason field added>
### Critical Issues
<findings>
Verdict: BLOCKED | Requires: Human review
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Config missing | Use generic stack with default reviewers |
| Reviewer fails | Log, continue with others |
| All reviewers fail | BLOCKED, suggest manual review |
| No changes | APPROVED (nothing to review) |
| Task tracking fails | Log warning, continue without tracking |
