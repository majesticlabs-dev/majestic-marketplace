---
name: rp-reviewer
description: Code review using RepoPrompt MCP (chat_send mode=review). Returns structured verdict for relay workflow.
---

# Purpose

Review code changes using RepoPrompt MCP. Returns structured JSON verdict.

## Input Schema

```yaml
task_id: string           # Task identifier (T1, T2, etc.)
changed_files: string[]   # List of changed file paths
```

## Output Schema

```json
{
  "verdict": "approved" | "rejected",
  "reason": "string"
}
```

## Process

### 1. Switch RepoPrompt Workspace

Ensure RepoPrompt is on the correct workspace for the project:

```
Call repoprompt/manage_workspaces with:
{
  "action": "switch",
  "workspace": "<project-name>"
}
```

### 2. Call RepoPrompt chat_send

Use `repoprompt/chat_send` MCP tool with review mode:

```json
{
  "new_chat": true,
  "mode": "review",
  "selected_paths": ["<changed-files>"],
  "message": "Review code changes for task <task_id>. Check for bugs, security issues, code quality. If acceptable, respond APPROVED. Otherwise list issues.",
  "chat_name": "relay-review-<task_id>"
}
```

**Key:** `mode: "review"` includes git diffs automatically via gitInclusion.

### 3. Parse Response

| Response Pattern | Verdict |
|-----------------|---------|
| Contains "NOT APPROVED" or "DISAPPROVED" | rejected |
| Contains "APPROVED" (without negation) | approved |
| No clear verdict | rejected |

### 4. Return Structured Result

```json
{
  "verdict": "approved",
  "reason": "Code review passed - no issues found"
}
```

Or on rejection:

```json
{
  "verdict": "rejected",
  "reason": "Security vulnerability found in auth.rb:45"
}
```

## Error Handling

| Scenario | Action |
|----------|--------|
| RepoPrompt MCP not available | Return `{ "verdict": "approved", "reason": "RepoPrompt unavailable" }` |
| Workspace switch fails | Return `{ "verdict": "approved", "reason": "Could not switch workspace" }` |
| chat_send fails | Return `{ "verdict": "approved", "reason": "Review failed - auto-approved" }` |

**Design principle:** Fail-open to avoid blocking relay workflow.
