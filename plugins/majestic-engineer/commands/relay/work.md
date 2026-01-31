---
name: majestic-relay:work
description: Execute epic tasks with fresh-context Claude instances and quality gate verification
argument-hint: "[task_id] [--max-attempts N]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/relay/relay-work.sh:*)
---

# Execute Epic Tasks

## Input

```yaml
task_id: string    # Optional: T1, T2 (run specific task)
max_attempts: int  # Optional: Override default (3)
```

## Workflow

```
If not exists(".agents-os/relay/epic.yml"):
  Error: "No epic found. Run `/majestic-relay:init <blueprint.md>` first."

If not exists(".agents-os/relay/attempt-ledger.yml"):
  Error: "Ledger missing. Run `/majestic-relay:init <blueprint.md>` to reinitialize."

Execute: "${CLAUDE_PLUGIN_ROOT}/scripts/relay/relay-work.sh" $ARGUMENTS
```

## Task Coordination

Workers share a TaskList via environment variable:

```bash
export CLAUDE_CODE_TASK_LIST_ID="relay-${EPIC_ID}"
```

Workers can discover and log additional work:
- Use `TaskCreate` for discovered work outside current task scope
- Continue with current task - do NOT block on discoveries
- Orchestrator sees discovered tasks after worker completes

**Note:** Ledger tracks detailed attempt receipts. Tasks enable worker-to-orchestrator communication.

## Error Handling

| Scenario | Action |
|----------|--------|
| No pending tasks | Report status, check for gated tasks |
| All tasks blocked | Report dependency chain |
| Quality gate: NEEDS CHANGES | Retry with findings |
| Quality gate: BLOCKED | Gate task immediately |
| Ctrl+C | Save state, exit cleanly |
