#!/usr/bin/env bash
set -euo pipefail

# Ralph Loop Setup Script
# Creates state file and initializes the iteration loop

STATE_FILE=".claude/ralph-loop.local.md"
PROGRESS_FILE=".claude/ralph-progress.local.yml"
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

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Create state file with YAML frontmatter
cat > "$STATE_FILE" << EOF
---
iteration: 1
max_iterations: ${MAX_ITERATIONS:-}
completion_promise: ${COMPLETION_PROMISE:-}
started_at: $(date -Iseconds)
---
$PROMPT
EOF

# Create progress file
cat > "$PROGRESS_FILE" << EOF
# Ralph Progress - Ephemeral session memory
# Patterns promote to AGENTS.md at loop end

started_at: $(date -Iseconds)
branch: ${CURRENT_BRANCH}

patterns: {}
  # Add discovered patterns here, e.g.:
  # migrations: "Use IF NOT EXISTS for all column additions"
  # forms: "Zod schema validation"

stories: []
  # Append completed stories here
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
echo "║ Progress: .claude/ralph-progress.local.yml                     ║"
echo "║ Monitor:  grep '^iteration:' .claude/ralph-loop.local.md       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ ⚠️  Use /cancel-ralph to stop the loop manually                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Instructions for Claude
cat << 'EOF'
---

**RALPH LOOP ACTIVE**

## Before Starting Work

1. Read `.claude/ralph-progress.local.yml` for accumulated patterns
2. Check patterns section for project-specific learnings

## After Completing Each Story

Update `.claude/ralph-progress.local.yml`:

```yaml
patterns:
  <key>: "<learning>"  # Add new patterns discovered

stories:
  - id: <story-id>
    title: <title>
    completed_at: <timestamp>
    files:
      - <file1>
      - <file2>
    learnings:
      - "<specific learning>"
```

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
