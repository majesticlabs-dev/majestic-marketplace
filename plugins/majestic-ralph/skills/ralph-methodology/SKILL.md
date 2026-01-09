---
name: ralph-methodology
description: Technical mechanics for autonomous AI coding loops
triggers:
  - ralph
  - autonomous loop
  - iteration loop
---

# Ralph Loop Mechanics

## How It Works

1. **Start:** User runs `/majestic-ralph:start "<prompt>" --max-iterations N --completion-promise "WORD"`
2. **Loop:** Stop hook intercepts session exit, re-feeds same prompt
3. **Exit:** Output `<promise>WORD</promise>` to signal genuine completion

## State File

Location: `.claude/ralph-loop.local.yml`

```yaml
iteration: 1
max_iterations: 50
completion_promise: DONE
started_at: 2024-01-15T10:30:00Z
prompt: |
  Your prompt here.
  Can be multiline.
```

## Completion Signal

Output exactly: `<promise>YOUR_PHRASE</promise>`

- Only output when genuinely complete
- Lying restarts the loop
- Max iterations is a hard stop

## Safety Rules

| Rule | Reason |
|------|--------|
| Idempotent operations | Migrations with `IF NOT EXISTS`, etc. |
| Non-interactive commands | No `-i` flags, no prompts |
| Clear exit criteria | Vague goals loop forever |

## Monitoring

```bash
# Check iteration
grep '^iteration:' .claude/ralph-loop.local.yml

# Cancel loop
/majestic-ralph:cancel
```
