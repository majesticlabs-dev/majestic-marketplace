---
name: headless-quality-gate
description: Run quality gate reviewers in parallel headless processes. Receives AC content directly and returns actionable findings.
tools: Bash, Read, Grep, Glob
color: green
---

# Purpose

Run code review in parallel headless Claude processes. Each reviewer gets fresh context and returns structured JSON with actionable findings.

## Input Format

```yaml
branch: string              # Branch to review (required)
ac: string                  # Acceptance criteria content (required)
context: string             # Task description, DoD, additional context (optional)
reviewers: string[]         # Override reviewer list (optional)
```

## Instructions

### 1. Validate Input

```
If branch is empty: FAIL with "branch is required"
If ac is empty: FAIL with "acceptance criteria content is required"
```

### 2. Get Configuration

```
TECH_STACK = !`claude -p "/majestic:config tech_stack generic"`
STRICTNESS = !`claude -p "/majestic:config quality_gate.strictness pedantic"`
```

### 3. Determine Reviewers

**If `reviewers` provided in input:** Use that list directly.

**Otherwise, use tech_stack defaults:**

| Tech Stack | Reviewers |
|------------|-----------|
| `rails` | security-review, simplicity-reviewer |
| `python` | security-review, simplicity-reviewer |
| `node` | security-review, simplicity-reviewer |
| `generic` | security-review, simplicity-reviewer |

Map shorthand to full paths:
- `security-review` → `majestic-engineer:qa:security-review`
- `simplicity-reviewer` → `majestic-rails:review:simplicity-reviewer`

### 4. Build Reviewer Prompt Template

```markdown
## Code Review Task

**Branch:** {branch}
**Focus:** {reviewer_focus}

## Acceptance Criteria

{ac}

## Additional Context

{context}

## Instructions

Review the code changes on branch `{branch}`.

For each issue found:
1. Identify the specific file and line
2. Describe what the code currently does
3. Describe what it should do (per AC or best practices)
4. Provide concrete fix instruction

For AC verification:
- Check each criterion against the implementation
- Mark PASS only if fully implemented
- Mark FAIL with specific gap and fix

## Output Requirements

Return findings in this exact format. EVERY finding must include:
- file: exact path
- line: line number
- current_behavior: what code does now
- expected_behavior: what AC/standards require
- fix_instruction: imperative command to fix
- code_snippet: before/after if applicable
```

### 5. Define JSON Schema

```json
{
  "type": "object",
  "properties": {
    "reviewer": { "type": "string" },
    "verdict": { "enum": ["PASS", "FAIL"] },
    "ac_results": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "criterion": { "type": "string" },
          "status": { "enum": ["PASS", "FAIL", "PARTIAL"] },
          "file": { "type": "string" },
          "line": { "type": "integer" },
          "current_behavior": { "type": "string" },
          "expected_behavior": { "type": "string" },
          "fix_instruction": { "type": "string" },
          "code_snippet": { "type": "string" }
        },
        "required": ["criterion", "status"]
      }
    },
    "code_findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "severity": { "enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW"] },
          "file": { "type": "string" },
          "line": { "type": "integer" },
          "issue": { "type": "string" },
          "current_behavior": { "type": "string" },
          "expected_behavior": { "type": "string" },
          "fix_instruction": { "type": "string" },
          "code_snippet": { "type": "string" }
        },
        "required": ["severity", "file", "issue", "fix_instruction"]
      }
    }
  },
  "required": ["reviewer", "verdict", "ac_results", "code_findings"]
}
```

### 6. Launch Parallel Reviewers

Create temp directory for outputs:
```bash
WORK_DIR=$(mktemp -d)
```

For each reviewer, launch in background:
```bash
claude -p "$REVIEWER_PROMPT" \
  --output-format json \
  --json-schema "$SCHEMA" \
  --permission-mode plan \
  > "$WORK_DIR/${reviewer_name}.json" 2>&1 &
```

Wait for all:
```bash
wait
```

### 7. Aggregate Results

Read all JSON files from `$WORK_DIR`:
```bash
for f in "$WORK_DIR"/*.json; do
  # Parse and aggregate
done
```

**Aggregate Logic:**

```
all_ac_results = []
all_code_findings = []
any_fail = false

For each reviewer result:
  If verdict == "FAIL": any_fail = true
  Append ac_results to all_ac_results
  Append code_findings to all_code_findings

# Deduplicate by file:line
deduplicated_findings = unique(all_code_findings, key=file+line)
```

### 8. Apply Strictness

| Strictness | Threshold |
|------------|-----------|
| `pedantic` | Any finding fails |
| `strict` | MEDIUM+ fails |
| `standard` | HIGH+ fails |

```
If any CRITICAL: verdict = BLOCKED
Else if findings >= threshold: verdict = NEEDS_CHANGES
Else: verdict = APPROVED
```

### 9. Cleanup

```bash
rm -rf "$WORK_DIR"
```

## Output Format

```yaml
verdict: APPROVED | NEEDS_CHANGES | BLOCKED
strictness: pedantic | strict | standard
reviewers_run:
  - security-review
  - simplicity-reviewer
summary:
  ac_passed: 3
  ac_failed: 1
  findings_critical: 0
  findings_high: 1
  findings_medium: 2
  findings_low: 0

ac_results:
  - criterion: "User can login with valid credentials"
    status: PASS
  - criterion: "Invalid login returns 401"
    status: FAIL
    file: app/controllers/sessions_controller.rb
    line: 45
    current_behavior: "Returns 200 with empty body"
    expected_behavior: "Returns 401 with error JSON"
    fix_instruction: "Add `render json: { error: 'Invalid credentials' }, status: :unauthorized` after failed auth check"
    code_snippet: |
      # Before:
      if !user&.authenticate(params[:password])
        render json: {}
      end

      # After:
      if !user&.authenticate(params[:password])
        render json: { error: 'Invalid credentials' }, status: :unauthorized
        return
      end

code_findings:
  - severity: HIGH
    file: app/controllers/sessions_controller.rb
    line: 12
    issue: "No rate limiting on login endpoint"
    current_behavior: "Unlimited login attempts allowed"
    expected_behavior: "Rate limit to 5 attempts per minute"
    fix_instruction: "Add `rate_limit to: 5, within: 1.minute` to sessions#create"
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Reviewer process fails | Log error, continue with others |
| All reviewers fail | Return BLOCKED with error details |
| JSON parse fails | Log raw output, mark reviewer as errored |
| No changes on branch | Return APPROVED (nothing to review) |
| Empty AC | FAIL with "AC content required" |
