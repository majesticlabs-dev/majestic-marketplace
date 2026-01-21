#!/bin/bash
#
# relay-work.sh - Fresh-context task execution orchestrator
#
# Inspired by: https://github.com/gmickel/gmickel-claude-marketplace (flow-next plugin)
#
# Usage:
#   relay-work.sh [task_id] [--max-attempts N]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ledger.sh"
source "$SCRIPT_DIR/lib/prompt.sh"

# File paths
EPIC=".agents-os/relay/epic.yml"
LEDGER=".agents-os/relay/attempt-ledger.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# JSON schema for task result
TASK_RESULT_SCHEMA='{
  "type": "object",
  "properties": {
    "status": { "type": "string", "enum": ["success", "failure"] },
    "summary": { "type": "string" },
    "files_changed": { "type": "array", "items": { "type": "string" } },
    "error_category": { "type": "string" },
    "suggestion": { "type": "string" }
  },
  "required": ["status", "summary"]
}'

# Parse arguments
SPECIFIC_TASK=""
MAX_ATTEMPTS_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --max-attempts)
      MAX_ATTEMPTS_OVERRIDE="$2"
      shift 2
      ;;
    T*)
      SPECIFIC_TASK="$1"
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}" >&2
      exit 1
      ;;
  esac
done

# Check prerequisites
if [[ ! -f "$EPIC" ]]; then
  echo -e "${RED}Error: No epic found at $EPIC${NC}" >&2
  echo "Run '/relay:init <blueprint.md>' first." >&2
  exit 1
fi

if [[ ! -f "$LEDGER" ]]; then
  echo -e "${RED}Error: No ledger found at $LEDGER${NC}" >&2
  echo "Run '/relay:init <blueprint.md>' to reinitialize." >&2
  exit 1
fi

# Load settings
MAX_ATTEMPTS=$(ledger_get_setting "max_attempts_per_task" "3")

# Apply overrides
[[ -n "$MAX_ATTEMPTS_OVERRIDE" ]] && MAX_ATTEMPTS="$MAX_ATTEMPTS_OVERRIDE"

# Get epic info
EPIC_ID=$(yq -r '.id' "$EPIC")
EPIC_TITLE=$(yq -r '.title' "$EPIC")

# Detect and recover from stale state (crashed previous run)
if ! ledger_relay_is_running; then
  # Check for tasks stuck in in_progress
  STUCK_TASKS=$(yq -r '.task_status | to_entries | .[] | select(.value == "in_progress") | .key' "$LEDGER" 2>/dev/null)
  if [[ -n "$STUCK_TASKS" ]]; then
    echo -e "${YELLOW}⚠️  Recovering from crashed state...${NC}"
    for task_id in $STUCK_TASKS; do
      yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER"
      echo -e "   Reset ${task_id} to pending"
    done
  fi
fi

# Track relay process status
ledger_relay_start

# Cleanup on exit or interrupt
cleanup() {
  local exit_code=$?
  # Only update if not already stopped (avoid double-update)
  local state
  state=$(yq -r '.relay_status.state // "idle"' "$LEDGER" 2>/dev/null)
  if [[ "$state" == "running" ]]; then
    # Reset any in_progress tasks to pending before stopping
    local stuck
    stuck=$(yq -r '.task_status | to_entries | .[] | select(.value == "in_progress") | .key' "$LEDGER" 2>/dev/null || true)
    for task_id in $stuck; do
      yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER" 2>/dev/null || true
    done
    ledger_relay_stop "$exit_code" "interrupted"
  fi
}
# Trap signals including SIGPIPE (from broken pipes like head/tail)
trap cleanup EXIT INT TERM PIPE

echo -e "${BLUE}🚀 Starting epic: ${EPIC_ID}${NC}"
echo ""

# Main execution loop
while true; do
  # Find next executable task
  if [[ -n "$SPECIFIC_TASK" ]]; then
    NEXT_TASK="$SPECIFIC_TASK"
    # Clear specific task after first iteration
    SPECIFIC_TASK=""
  else
    NEXT_TASK=$(find_next_task "$EPIC" "$LEDGER")
  fi

  if [[ -z "$NEXT_TASK" ]]; then
    # Check if all done or all blocked/gated
    COMPLETED=$(ledger_count_status "completed")
    TOTAL=$(yq -r '.tasks | keys | length' "$EPIC")

    if [[ "$COMPLETED" -eq "$TOTAL" ]]; then
      # Record epic completion with timing
      ledger_epic_complete

      DURATION=$(yq -r '.duration_minutes // 0' "$LEDGER")
      echo ""
      echo -e "${GREEN}✅ Epic complete! ($COMPLETED/$TOTAL tasks in ${DURATION} min)${NC}"

      # Run compound learning aggregation
      LEARNING_STATS=$(ledger_get_learning_stats)
      TOTAL_LEARNINGS=$(echo "$LEARNING_STATS" | jq -r '.total_learnings // 0')

      if [[ "$TOTAL_LEARNINGS" -gt 0 ]]; then
        echo ""
        echo -e "${BLUE}📚 Processing $TOTAL_LEARNINGS learnings from epic...${NC}"

        EPIC_ID=$(yq -r '.id' "$EPIC")

        LEARNING_PROMPT="You are the majestic-relay:learning-processor agent.

Use the workflow defined in your agent spec to:
1. Read learnings from: $LEDGER
2. Consolidate similar patterns
3. Apply frequency thresholds (1=skip, 2=emerging, 3+=recommend, 4+=strong)
4. Categorize into AGENTS.md vs .agents.yml
5. Present findings and ask user before applying changes

Epic: $EPIC_ID
Ledger: $LEDGER

Read the ledger and process all learnings. Use AskUserQuestion before making any file changes."

        # Run learning processor (interactive - user confirms changes)
        claude -p "$LEARNING_PROMPT" --allowedTools 'Read,Write,Edit,Grep,Glob,Bash(yq:*),Bash(grep:*),AskUserQuestion' 2>/dev/null || {
          echo -e "${YELLOW}⚠️  Learning processor skipped (non-critical)${NC}"
        }
      else
        echo -e "${YELLOW}📝 No learnings captured during epic${NC}"
      fi

      ledger_relay_stop 0 "epic_complete"
      exit 0
    else
      GATED=$(yq -r '.gated_tasks | keys | length' "$LEDGER")
      echo ""
      echo -e "${YELLOW}⏸️  No executable tasks remaining${NC}"
      echo "  Completed: $COMPLETED/$TOTAL"
      [[ "$GATED" -gt 0 ]] && echo -e "  ${RED}Gated: $GATED tasks${NC}"
      echo ""
      echo "Run '/relay:status --verbose' for details."
      ledger_relay_stop 1 "no_runnable_tasks"
      exit 1
    fi
  fi

  # Get task info
  TASK_TITLE=$(yq -r ".tasks.${NEXT_TASK}.title" "$EPIC")

  # Check attempt count
  ATTEMPTS=$(ledger_count_attempts "$NEXT_TASK")

  if [[ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]]; then
    echo -e "${RED}🚫 Gating $NEXT_TASK: max attempts exceeded ($ATTEMPTS/$MAX_ATTEMPTS)${NC}"
    ledger_gate_task "$NEXT_TASK" "max_attempts_exceeded"
    continue
  fi

  # Start new attempt
  ATTEMPT_ID=$((ATTEMPTS + 1))
  echo -e "${BLUE}[$NEXT_TASK]${NC} $TASK_TITLE"
  echo -e "     Attempt $ATTEMPT_ID/$MAX_ATTEMPTS..."

  ledger_record_attempt_start "$NEXT_TASK" "$ATTEMPT_ID"

  # Build re-anchoring prompt
  PROMPT=$(build_task_prompt "$EPIC" "$LEDGER" "$NEXT_TASK")

  # Spawn fresh Claude instance with JSON output
  # Use tee to stream output to terminal while capturing to temp file
  TEMP_OUTPUT=$(mktemp)
  trap "rm -f $TEMP_OUTPUT" RETURN

  echo ""
  claude -p "$PROMPT" --permission-mode bypassPermissions --output-format json --json-schema "$TASK_RESULT_SCHEMA" 2>&1 | tee "$TEMP_OUTPUT" || true
  CLAUDE_EXIT_CODE=${PIPESTATUS[0]}
  echo ""

  OUTPUT=$(cat "$TEMP_OUTPUT")
  rm -f "$TEMP_OUTPUT"

  # Validate JSON before parsing
  if ! echo "$OUTPUT" | jq empty 2>/dev/null; then
    RESULT_STATUS="failure"
    RESULT_MESSAGE="CLI error: $(echo "$OUTPUT" | head -1 | cut -c1-100)"
    RESULT_FILES=""
    RESULT_ERROR_CAT="cli_error"
    RESULT_SUGGESTION="Claude CLI returned non-JSON output (exit code: $CLAUDE_EXIT_CODE). May be transient."
  else
    # Parse structured result with jq (from structured_output field)
    RESULT_STATUS=$(echo "$OUTPUT" | jq -r '.structured_output.status // "failure"')
    RESULT_MESSAGE=$(echo "$OUTPUT" | jq -r '.structured_output.summary // "No summary provided"')
    RESULT_FILES=$(echo "$OUTPUT" | jq -r '.structured_output.files_changed // [] | join(", ")')
    RESULT_ERROR_CAT=$(echo "$OUTPUT" | jq -r '.structured_output.error_category // ""')
    RESULT_SUGGESTION=$(echo "$OUTPUT" | jq -r '.structured_output.suggestion // ""')
  fi

  # Run quality gate (replaces old review step)
  # Quality gate verifies AC + runs configured reviewers
  if [[ "$RESULT_STATUS" == "success" ]]; then
    echo -e "     ${BLUE}🔍 Running quality gate...${NC}"

    # Build quality gate prompt
    # Quality gate agent expects: Context, Branch, AC Path, Task ID
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo 'unknown')

    QG_PROMPT="You are running quality-gate verification for a relay task.

Use the Task tool to invoke the quality-gate agent:

Task(majestic-engineer:workflow:quality-gate):
  prompt: |
    Context: ${NEXT_TASK} - ${TASK_TITLE}
    Branch: ${CURRENT_BRANCH}
    AC Path: ${EPIC}
    Task ID: ${NEXT_TASK}

Return the verdict exactly as: Verdict: APPROVED or Verdict: NEEDS CHANGES or Verdict: BLOCKED"

    # Call quality-gate via Claude (stream output)
    QG_TEMP=$(mktemp)
    echo ""
    if claude -p "$QG_PROMPT" --allowedTools 'Task,Bash(git diff:*),Bash(git status:*),Bash(git log:*),Read,Grep,Glob' 2>&1 | tee "$QG_TEMP"; then
      QG_OUTPUT=$(cat "$QG_TEMP")
      rm -f "$QG_TEMP"
      # Parse verdict from output (look for "Verdict: APPROVED/NEEDS CHANGES/BLOCKED")
      QG_VERDICT=$(echo "$QG_OUTPUT" | grep -oE 'Verdict: (APPROVED|NEEDS CHANGES|BLOCKED)' | tail -1 | cut -d' ' -f2-)

      case "$QG_VERDICT" in
        "APPROVED")
          echo -e "     ${GREEN}✅ Quality gate: APPROVED${NC}"
          RESULT_STATUS="success"
          ;;
        "NEEDS CHANGES")
          echo -e "     ${YELLOW}⚠️ Quality gate: NEEDS CHANGES${NC}"
          RESULT_STATUS="failure"
          RESULT_MESSAGE="Quality gate requires changes"
          RESULT_ERROR_CAT="quality_gate"
          # Extract findings for next attempt
          RESULT_SUGGESTION=$(echo "$QG_OUTPUT" | grep -A 100 "### Required Fixes" | head -50)
          ;;
        "BLOCKED")
          echo -e "     ${RED}🛑 Quality gate: BLOCKED${NC}"
          # Gate the task immediately - critical issues found
          ledger_gate_task "$NEXT_TASK" "quality_gate_blocked"
          echo ""
          continue
          ;;
        *)
          # Fallback: if no clear verdict, treat as needs review
          echo -e "     ${YELLOW}⚠️ Quality gate: unclear verdict, treating as needs changes${NC}"
          RESULT_STATUS="failure"
          RESULT_MESSAGE="Quality gate returned unclear verdict"
          RESULT_ERROR_CAT="quality_gate"
          ;;
      esac
    else
      # Quality gate failed to run - log warning but don't block
      rm -f "$QG_TEMP"
      echo -e "     ${YELLOW}⚠️ Quality gate agent failed, using self-reported status${NC}"
    fi
    echo ""
  fi

  # Update ledger with receipt
  if [[ "$RESULT_STATUS" == "success" ]]; then
    echo -e "     ${GREEN}✅ Task complete${NC}"
    ledger_record_attempt_success "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_FILES"
  else
    echo -e "     ${RED}❌ Failed: $RESULT_MESSAGE${NC}"
    ledger_record_attempt_failure "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_ERROR_CAT" "$RESULT_SUGGESTION"
  fi

  # Extract learning from attempt (compound learning)
  echo -e "     ${BLUE}📚 Extracting learning...${NC}"
  LEARNING_CONTEXT="Task: $TASK_TITLE
Result: $RESULT_STATUS
Summary: $RESULT_MESSAGE"
  [[ -n "$RESULT_ERROR_CAT" ]] && LEARNING_CONTEXT="$LEARNING_CONTEXT
Error: $RESULT_ERROR_CAT"
  [[ -n "$RESULT_SUGGESTION" ]] && LEARNING_CONTEXT="$LEARNING_CONTEXT
Suggestion: $RESULT_SUGGESTION"

  LEARNING_PROMPT="Based on this task attempt, extract ONE reusable learning (1 sentence max).
Focus on: patterns, gotchas, techniques that apply beyond this specific task.

$LEARNING_CONTEXT

Output format: LEARNING: <sentence> | TAGS: <comma-separated>
Or output 'none' if nothing generalizable."

  LEARNING_OUTPUT=""
  if LEARNING_OUTPUT=$(claude -p "$LEARNING_PROMPT" --model haiku 2>/dev/null); then
    # Parse learning and tags
    if [[ "$LEARNING_OUTPUT" != *"none"* ]]; then
      LEARNING_TEXT=$(echo "$LEARNING_OUTPUT" | grep -oE 'LEARNING: [^|]+' | sed 's/LEARNING: //' | head -1)
      LEARNING_TAGS=$(echo "$LEARNING_OUTPUT" | grep -oE 'TAGS: .+' | sed 's/TAGS: //' | head -1)

      if [[ -n "$LEARNING_TEXT" ]]; then
        ledger_record_learning "$NEXT_TASK" "$ATTEMPT_ID" "$LEARNING_TEXT" "$LEARNING_TAGS"
        echo -e "     ${GREEN}📝 Learned: ${LEARNING_TEXT:0:60}...${NC}"
      fi
    fi
  fi

  echo ""
done
