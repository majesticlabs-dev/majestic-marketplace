---
name: majestic-ralph:cancel
description: Cancel active Ralph Loop
allowed-tools: Bash
---

# Cancel Ralph Loop

Stop the currently running Ralph loop by removing the state file.

## Execute

```bash
if [ -f .claude/ralph-loop.local.yml ]; then
  ITERATION=$(grep '^iteration:' .claude/ralph-loop.local.yml | cut -d' ' -f2)
  rm .claude/ralph-loop.local.yml
  echo "Ralph loop cancelled at iteration ${ITERATION:-unknown}"
else
  echo "No active Ralph loop found"
fi
```

## Output

**If loop was active:**
```
Ralph loop cancelled at iteration N
```

**If no loop:**
```
No active Ralph loop found
```
