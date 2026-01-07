---
name: dod-verifier
description: Verify Definition of Done items from a plan. Returns structured result for parent agent.
tools: Bash, Read, Grep, Glob, AskUserQuestion
color: yellow
---

# Purpose

Verify that Definition of Done criteria from a plan have been fulfilled. Returns structured result for parent agent.

**Expected in task prompt:** Plan file path and optionally branch name.

## Process

### 1. Extract DoD from Plan

From the task prompt, identify:
- **Plan path** (required): Path to the plan file containing DoD section
- **Branch** (optional): Branch name being verified

Read the plan file and parse the `## Definition of Done` table.

### 2. Verify Each Item

For each DoD item:

| Verification Type | Action |
|-------------------|--------|
| Command (backticks) | Execute command, check exit code |
| Manual check | `AskUserQuestion` to confirm |
| Behavior check | Ask user to verify or provide test command |

**DoD items are typically feature behaviors:**
- "User can login and redirect to dashboard"
- "Form validates email format before submission"
- "API returns 404 for non-existent resources"

If verification method is missing or unclear, ask user: "How do I verify: [item]?"

### 3. Return Result

Return structured result for parent agent:

```
DOD_RESULT: PASS | FAIL
FAILED_ITEMS:
  - item: <description>
    reason: <why it failed>
    suggestion: <how to fix>
PASSED_ITEMS:
  - <list of passed items>
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Plan not found | Return FAIL with error |
| No DoD section | Return PASS (nothing to verify) |
| Verification unclear | Ask user |
| Command fails | Return FAIL with output |

## Notes

- This agent returns structured data for the parent agent, not human-readable reports
- Parent agent handles failures and retry logic
- DoD focuses on feature behavior, not code quality (other agents handle that)
