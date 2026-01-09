#!/usr/bin/env bash
set -euo pipefail

# Ralph Loop Setup Script
# Creates state file and initializes the iteration loop

STATE_FILE=".claude/ralph-loop.local.yml"
STATE_DIR=".claude"

# Initialize variables
PROMPT=""
MAX_ITERATIONS=""
COMPLETION_PROMISE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      # Accumulate as prompt (strip surrounding quotes if present)
      if [ -z "$PROMPT" ]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

# Strip surrounding quotes from prompt
PROMPT=$(echo "$PROMPT" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")

# Validate required argument
if [ -z "$PROMPT" ]; then
  echo "Error: Prompt is required" >&2
  echo "Usage: /ralph \"<prompt>\" [--max-iterations N] [--completion-promise \"<text>\"]" >&2
  exit 1
fi

# Validate max-iterations is numeric
if [ -n "$MAX_ITERATIONS" ] && ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Error: --max-iterations must be a number" >&2
  exit 1
fi

# Check if loop is already active
if [ -f "$STATE_FILE" ]; then
  CURRENT_ITERATION=$(grep '^iteration:' "$STATE_FILE" | sed 's/^iteration: *//')
  echo "Warning: Ralph loop already active at iteration $CURRENT_ITERATION" >&2
  echo "Use /cancel-ralph to stop the current loop first" >&2
  exit 1
fi

# Create state directory if needed
mkdir -p "$STATE_DIR"

# Create state file (YAML format)
cat > "$STATE_FILE" << EOF
iteration: 1
max_iterations: ${MAX_ITERATIONS:-}
completion_promise: ${COMPLETION_PROMISE:-}
started_at: $(date -Iseconds)
prompt: |
$(echo "$PROMPT" | sed 's/^/  /')
EOF

# Display startup message
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🔄 RALPH LOOP STARTED                       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ Iteration: 1${MAX_ITERATIONS:+ of $MAX_ITERATIONS}                                                    "
if [ -n "$COMPLETION_PROMISE" ]; then
echo "║ Completion: Output <promise>$COMPLETION_PROMISE</promise> when done"
fi
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ State: .claude/ralph-loop.local.yml                            ║"
echo "║ Monitor: grep '^iteration:' .claude/ralph-loop.local.yml       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ ⚠️  Use /cancel-ralph to stop the loop manually                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Instructions for Claude
cat << 'EOF'
---

**RALPH LOOP ACTIVE**

## Completion Rule

EOF

if [ -n "$COMPLETION_PROMISE" ]; then
  echo "Output \`<promise>$COMPLETION_PROMISE</promise>\` ONLY when genuinely complete."
  echo "Do NOT output false promises to escape the loop."
  echo ""
fi

echo "---"
echo ""
echo "**TASK:**"
echo ""
echo "$PROMPT"
