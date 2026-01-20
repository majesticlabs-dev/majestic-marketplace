#!/bin/bash
#
# relay-work.sh - Fresh-context task execution orchestrator
#
# Inspired by: https://github.com/gmickel/gmickel-claude-marketplace (flow-next plugin)
#
# Usage:
#   relay-work.sh [task_id] [--review|--no-review] [--max-attempts N]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ledger.sh"
source "$SCRIPT_DIR/lib/prompt.sh"
source "$SCRIPT_DIR/lib/review.sh"

# File paths
EPIC=".majestic/epic.yml"
LEDGER=".majestic/attempt-ledger.yml"

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
REVIEW_OVERRIDE=""
MAX_ATTEMPTS_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --review)
      REVIEW_OVERRIDE="true"
      shift
      ;;
    --no-review)
      REVIEW_OVERRIDE="false"
      shift
      ;;
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
REVIEW_ENABLED=$(ledger_get_setting "review.enabled" "false")
REVIEW_PROVIDER=$(ledger_get_setting "review.provider" "none")

# Apply overrides
[[ -n "$MAX_ATTEMPTS_OVERRIDE" ]] && MAX_ATTEMPTS="$MAX_ATTEMPTS_OVERRIDE"
[[ "$REVIEW_OVERRIDE" == "true" ]] && REVIEW_ENABLED="true"
[[ "$REVIEW_OVERRIDE" == "false" ]] && REVIEW_ENABLED="false"

# Get epic info
EPIC_ID=$(yq -r '.id' "$EPIC")
EPIC_TITLE=$(yq -r '.title' "$EPIC")

# Track relay process status
ledger_relay_start

# Cleanup on exit or interrupt
cleanup() {
  local exit_code=$?
  # Only update if not already stopped (avoid double-update)
  local state
  state=$(yq -r '.relay_status.state // "idle"' "$LEDGER" 2>/dev/null)
  if [[ "$state" == "running" ]]; then
    ledger_relay_stop "$exit_code" "interrupted"
  fi
}
trap cleanup EXIT INT TERM

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
  OUTPUT=""
  EXIT_CODE=0

  if OUTPUT=$(claude -p "$PROMPT" --permission-mode bypassPermissions --output-format json --json-schema "$TASK_RESULT_SCHEMA" 2>&1); then
    EXIT_CODE=0
  else
    EXIT_CODE=$?
  fi

  # Parse structured result with jq (from structured_output field)
  RESULT_STATUS=$(echo "$OUTPUT" | jq -r '.structured_output.status // "failure"')
  RESULT_MESSAGE=$(echo "$OUTPUT" | jq -r '.structured_output.summary // "No summary provided"')
  RESULT_FILES=$(echo "$OUTPUT" | jq -r '.structured_output.files_changed // [] | join(", ")')
  RESULT_ERROR_CAT=$(echo "$OUTPUT" | jq -r '.structured_output.error_category // ""')
  RESULT_SUGGESTION=$(echo "$OUTPUT" | jq -r '.structured_output.suggestion // ""')

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

    # Call quality-gate via Claude
    QG_OUTPUT=""
    if QG_OUTPUT=$(claude -p "$QG_PROMPT" --allowedTools 'Task,Bash(git diff:*),Bash(git status:*),Bash(git log:*),Read,Grep,Glob' 2>&1); then
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
      echo -e "     ${YELLOW}⚠️ Quality gate agent failed, using self-reported status${NC}"
    fi
  fi

  # Update ledger with receipt
  if [[ "$RESULT_STATUS" == "success" ]]; then
    echo -e "     ${GREEN}✅ Task complete${NC}"
    ledger_record_attempt_success "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_FILES"
  else
    echo -e "     ${RED}❌ Failed: $RESULT_MESSAGE${NC}"
    ledger_record_attempt_failure "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_ERROR_CAT" "$RESULT_SUGGESTION"
  fi

  echo ""
done
