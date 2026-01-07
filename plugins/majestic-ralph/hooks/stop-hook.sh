#!/usr/bin/env bash
set -euo pipefail

# Ralph Loop Stop Hook
# Intercepts session exit and re-feeds the prompt if loop is active

STATE_FILE=".claude/ralph-loop.local.md"
PROGRESS_FILE=".claude/ralph-progress.local.yml"

# Check if loop is active
if [ ! -f "$STATE_FILE" ]; then
  # No active loop - allow normal exit
  exit 0
fi

# Parse state file (YAML frontmatter)
parse_field() {
  grep "^$1:" "$STATE_FILE" 2>/dev/null | sed "s/^$1: *//" | head -1
}

ITERATION=$(parse_field "iteration")
MAX_ITERATIONS=$(parse_field "max_iterations")
COMPLETION_PROMISE=$(parse_field "completion_promise")

# Validate numeric fields
if ! [[ "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid iteration count in state file" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

if [ -n "$MAX_ITERATIONS" ] && ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid max_iterations in state file" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Check max iterations limit
if [ -n "$MAX_ITERATIONS" ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
  echo "Ralph loop reached maximum iterations ($MAX_ITERATIONS)" >&2
  echo "" >&2
  echo "Promote valuable patterns from $PROGRESS_FILE to AGENTS.md" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Get transcript file from environment
TRANSCRIPT_FILE="${CLAUDE_TRANSCRIPT_FILE:-}"
if [ -z "$TRANSCRIPT_FILE" ] || [ ! -f "$TRANSCRIPT_FILE" ]; then
  echo "Error: Cannot read transcript file" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Extract last assistant message from transcript (JSONL format)
LAST_ASSISTANT_MSG=$(tac "$TRANSCRIPT_FILE" | grep -m1 '"role":"assistant"' | jq -r '.message.content[] | select(.type == "text") | .text' 2>/dev/null || echo "")

if [ -z "$LAST_ASSISTANT_MSG" ]; then
  echo "Warning: No assistant message found in transcript" >&2
fi

# Check for completion promise
if [ -n "$COMPLETION_PROMISE" ]; then
  # Look for <promise>COMPLETION_PROMISE</promise> pattern
  if echo "$LAST_ASSISTANT_MSG" | grep -q "<promise>${COMPLETION_PROMISE}</promise>"; then
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ✅ RALPH LOOP COMPLETE                            ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Promise fulfilled: $COMPLETION_PROMISE"
    echo "║ Iterations: $ITERATION"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Next: Promote patterns from ralph-progress.local.yml          ║"
    echo "║       to relevant AGENTS.md files                             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    rm -f "$STATE_FILE"
    exit 0
  fi
fi

# Increment iteration counter
NEW_ITERATION=$((ITERATION + 1))

# Extract prompt from state file (everything after ---\n at end of frontmatter)
PROMPT=$(awk '/^---$/{if(++n==2){getline; found=1}} found' "$STATE_FILE")

if [ -z "$PROMPT" ]; then
  echo "Error: No prompt found in state file" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Update iteration count in state file
sed -i.bak "s/^iteration: .*/iteration: $NEW_ITERATION/" "$STATE_FILE"
rm -f "$STATE_FILE.bak"

# Build context message
CONTEXT_MSG="[RALPH LOOP] Iteration $NEW_ITERATION${MAX_ITERATIONS:+ of $MAX_ITERATIONS}

## Before continuing:
1. Read \`.claude/ralph-progress.local.yml\` for accumulated patterns
2. Apply learned patterns to avoid repeating mistakes

## After completing work:
Update \`.claude/ralph-progress.local.yml\` with new patterns and story entry.

---

**TASK:**
$PROMPT"

# Output JSON to block exit and continue loop
cat << EOF
{
  "decision": "block",
  "reason": "Ralph loop iteration $NEW_ITERATION${MAX_ITERATIONS:+ of $MAX_ITERATIONS}",
  "updatedSessionContext": $(echo "$CONTEXT_MSG" | jq -Rs .)
}
EOF
