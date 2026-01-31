#!/bin/bash
#
# relay-work.sh - Fresh-context task execution orchestrator
#
# Usage: relay-work.sh [task_id] [--max-attempts N]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ledger.sh"
source "$SCRIPT_DIR/lib/prompt.sh"
source "$SCRIPT_DIR/lib/task-exec.sh"
source "$SCRIPT_DIR/lib/quality-gate.sh"
source "$SCRIPT_DIR/lib/learning.sh"

EPIC=".agents-os/relay/epic.yml"
LEDGER=".agents-os/relay/attempt-ledger.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    --max-attempts) MAX_ATTEMPTS_OVERRIDE="$2"; shift 2 ;;
    T*) SPECIFIC_TASK="$1"; shift ;;
    *) echo -e "${RED}Unknown option: $1${NC}" >&2; exit 1 ;;
  esac
done

# Check prerequisites
[[ ! -f "$EPIC" ]] && { echo -e "${RED}Error: No epic found at $EPIC${NC}" >&2; exit 1; }
[[ ! -f "$LEDGER" ]] && { echo -e "${RED}Error: No ledger found at $LEDGER${NC}" >&2; exit 1; }

# Load settings
MAX_ATTEMPTS=$(ledger_get_setting "max_attempts_per_task" "3")
[[ -n "$MAX_ATTEMPTS_OVERRIDE" ]] && MAX_ATTEMPTS="$MAX_ATTEMPTS_OVERRIDE"

# Recover from stale state
if ! ledger_relay_is_running; then
  STUCK=$(yq -r '.task_status | to_entries | .[] | select(.value == "in_progress") | .key' "$LEDGER" 2>/dev/null)
  if [[ -n "$STUCK" ]]; then
    echo -e "${YELLOW}⚠️  Recovering from crashed state...${NC}"
    for task_id in $STUCK; do
      yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER"
    done
  fi
fi

ledger_relay_start

cleanup() {
  local state
  state=$(yq -r '.relay_status.state // "idle"' "$LEDGER" 2>/dev/null)
  if [[ "$state" == "running" ]]; then
    local stuck
    stuck=$(yq -r '.task_status | to_entries | .[] | select(.value == "in_progress") | .key' "$LEDGER" 2>/dev/null || true)
    for task_id in $stuck; do
      yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER" 2>/dev/null || true
    done
    ledger_relay_stop "$?" "interrupted"
  fi
}
trap cleanup EXIT INT TERM PIPE

EPIC_ID=$(yq -r '.id' "$EPIC")
echo -e "${BLUE}🚀 Starting epic: ${EPIC_ID}${NC}"
echo ""

# Share TaskList across worker instances for real-time coordination
export CLAUDE_CODE_TASK_LIST_ID="relay-${EPIC_ID}"

# Main loop
while true; do
  # Find next task
  if [[ -n "$SPECIFIC_TASK" ]]; then
    NEXT_TASK="$SPECIFIC_TASK"
    SPECIFIC_TASK=""
  else
    NEXT_TASK=$(find_next_task "$EPIC" "$LEDGER")
  fi

  # Handle completion or no tasks
  if [[ -z "$NEXT_TASK" ]]; then
    COMPLETED=$(ledger_count_status "completed")
    TOTAL=$(yq -r '.tasks | keys | length' "$EPIC")

    if [[ "$COMPLETED" -eq "$TOTAL" ]]; then
      ledger_epic_complete
      DURATION=$(yq -r '.duration_minutes // 0' "$LEDGER")
      echo -e "${GREEN}✅ Epic complete! ($COMPLETED/$TOTAL tasks in ${DURATION} min)${NC}"
      process_epic_learnings "$EPIC" "$LEDGER"
      ledger_relay_stop 0 "epic_complete"
      exit 0
    else
      GATED=$(yq -r '.gated_tasks | keys | length' "$LEDGER")
      echo -e "${YELLOW}⏸️  No executable tasks remaining${NC}"
      echo "  Completed: $COMPLETED/$TOTAL"
      [[ "$GATED" -gt 0 ]] && echo -e "  ${RED}Gated: $GATED tasks${NC}"
      ledger_relay_stop 1 "no_runnable_tasks"
      exit 1
    fi
  fi

  TASK_TITLE=$(yq -r ".tasks.${NEXT_TASK}.title" "$EPIC")
  ATTEMPTS=$(ledger_count_attempts "$NEXT_TASK")

  # Check attempt limit
  if [[ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]]; then
    echo -e "${RED}🚫 Gating $NEXT_TASK: max attempts exceeded${NC}"
    ledger_gate_task "$NEXT_TASK" "max_attempts_exceeded"
    continue
  fi

  ATTEMPT_ID=$((ATTEMPTS + 1))
  echo -e "${BLUE}[$NEXT_TASK]${NC} $TASK_TITLE"
  echo -e "     Attempt $ATTEMPT_ID/$MAX_ATTEMPTS..."

  ledger_record_attempt_start "$NEXT_TASK" "$ATTEMPT_ID"

  # Execute task
  PROMPT=$(build_task_prompt "$EPIC" "$LEDGER" "$NEXT_TASK")
  execute_task "$PROMPT" "$TASK_RESULT_SCHEMA"

  # Quality gate on success
  if [[ "$RESULT_STATUS" == "success" ]]; then
    run_quality_gate "$TASK_SESSION_ID" "$NEXT_TASK" "$TASK_TITLE" "$EPIC"
    QG_RESULT=$?
    case $QG_RESULT in
      2) ledger_gate_task "$NEXT_TASK" "quality_gate_blocked"; continue ;;
    esac
    echo ""
  fi

  # Record result
  if [[ "$RESULT_STATUS" == "success" ]]; then
    echo -e "     ${GREEN}✅ Task complete${NC}"
    ledger_record_attempt_success "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_FILES"
  else
    echo -e "     ${RED}❌ Failed: $RESULT_MESSAGE${NC}"
    ledger_record_attempt_failure "$NEXT_TASK" "$ATTEMPT_ID" "$RESULT_MESSAGE" "$RESULT_ERROR_CAT" "$RESULT_SUGGESTION"
  fi

  extract_learning "$NEXT_TASK" "$ATTEMPT_ID" "$TASK_TITLE" "$RESULT_STATUS" "$RESULT_MESSAGE" "$RESULT_ERROR_CAT" "$RESULT_SUGGESTION"
  echo ""
done
