#!/bin/bash
#
# quality-gate.sh - Quality gate with fix loop
#
# Reads quality gate agent from config for domain-agnostic execution.
#

# Source config reader (SCRIPT_DIR set by parent relay-work.sh)
source "$SCRIPT_DIR/lib/config.sh"

DEFERRED_LOG=".agents-os/relay/deferred-findings.log"

# Extract and log deferred findings from quality gate output
# Usage: log_deferred_findings "$qg_output" "$task_id"
log_deferred_findings() {
  local output="$1"
  local task_id="$2"
  local deferred timestamp

  # Extract content between markers
  # grep -v returns 1 on empty input, which with pipefail causes script exit
  deferred=$(echo "$output" | sed -n '/DEFERRED_FINDINGS_START/,/DEFERRED_FINDINGS_END/p' | grep -v 'DEFERRED_FINDINGS' || true)

  if [[ -n "$deferred" ]]; then
    mkdir -p "$(dirname "$DEFERRED_LOG")"
    timestamp=$(date -Iseconds)

    echo "# [$timestamp] Task: $task_id" >> "$DEFERRED_LOG"
    echo "$deferred" >> "$DEFERRED_LOG"
    echo "" >> "$DEFERRED_LOG"

    local count
    count=$(echo "$deferred" | grep -c "^severity:" || echo "0")
    echo -e "     ${YELLOW}Deferred $count finding(s) to log${NC}"
  fi
}

# Run quality gate with fix loop (up to 2 fix attempts via session resume)
# Sets: RESULT_STATUS, RESULT_MESSAGE, RESULT_ERROR_CAT on failure
# Returns: 0=approved, 1=failed, 2=blocked
# Usage: run_quality_gate "$SESSION_ID" "$TASK_ID" "$TASK_TITLE" "$EPIC"
run_quality_gate() {
  local session_id="$1"
  local task_id="$2"
  local task_title="$3"
  local epic="$4"
  local branch qg_prompt fix_attempt qg_temp qg_output qg_verdict findings
  local reviewers strictness tech_stack app_status reviewers_yaml
  local qg_agent lessons_agent skip_lessons

  # Read quality gate agent from config (with default)
  qg_agent=$(config_get "relay.quality_gate_agent" "majestic-engineer:workflow:quality-gate")
  lessons_agent=$(config_get "relay.lessons_agent" "majestic-engineer:workflow:lessons-discoverer")
  skip_lessons=$(config_get "relay.skip_lessons" "false")

  # Pre-read config (eliminates LLM skill invocation in headless mode)
  reviewers=$(config_get_array "quality_gate.reviewers")

  if [[ -z "$reviewers" ]]; then
    echo -e "     ${YELLOW}**Verdict: SKIPPED**${NC}"
    echo "     No reviewers configured in quality_gate.reviewers"
    echo "     Configure in .agents.yml or .agents.local.yml"
    return 0
  fi

  strictness=$(config_get "quality_gate.strictness" "pedantic")
  tech_stack=$(config_get "tech_stack" "generic")
  app_status=$(config_get "app_status" "development")

  # Format reviewers as YAML list
  reviewers_yaml=$(echo "$reviewers" | sed 's/^/    - /')

  branch=$(git branch --show-current 2>/dev/null || echo 'unknown')
  qg_prompt="You are running quality-gate verification for a relay task.

Config (pre-loaded - DO NOT invoke /majestic:config):
  reviewers:
${reviewers_yaml}
  strictness: ${strictness}
  tech_stack: ${tech_stack}
  app_status: ${app_status}
  lessons_agent: ${lessons_agent}
  skip_lessons: ${skip_lessons}

Use the Task tool to invoke the quality-gate agent:

Task(${qg_agent}):
  prompt: |
    Context: ${task_id} - ${task_title}
    Branch: ${branch}
    AC Path: ${epic}
    Task ID: ${task_id}
    Lessons Agent: ${lessons_agent}
    Skip Lessons: ${skip_lessons}

Return the verdict exactly as: Verdict: APPROVED or Verdict: NEEDS CHANGES or Verdict: BLOCKED"

  fix_attempt=0
  while [[ $fix_attempt -lt 3 ]]; do
    echo -e "     ${BLUE}Running quality gate...${NC}"
    qg_temp=$(mktemp)
    claude -p "$qg_prompt" --permission-mode bypassPermissions 2>&1 | tee "$qg_temp" || true
    qg_output=$(cat "$qg_temp")
    rm -f "$qg_temp"

    qg_verdict=$(echo "$qg_output" | grep -oE 'Verdict: (APPROVED|NEEDS CHANGES|BLOCKED)' | tail -1 | cut -d' ' -f2- || true)

    if [[ "$qg_verdict" == "APPROVED" ]]; then
      echo -e "     ${GREEN}Quality gate: APPROVED${NC}"
      log_deferred_findings "$qg_output" "$task_id"
      return 0
    elif [[ "$qg_verdict" == "BLOCKED" ]]; then
      echo -e "     ${RED}Quality gate: BLOCKED${NC}"
      return 2
    elif [[ "$qg_verdict" == "NEEDS CHANGES" ]]; then
      fix_attempt=$((fix_attempt + 1))
      if [[ $fix_attempt -ge 3 ]]; then
        echo -e "     ${RED}Fix attempts exhausted${NC}"
        RESULT_STATUS="failure"
        RESULT_MESSAGE="Quality gate failed after 2 fix attempts"
        RESULT_ERROR_CAT="fix_loop_exhausted"
        return 1
      fi

      echo -e "     ${YELLOW}Fix attempt $fix_attempt/2...${NC}"
      findings=$(echo "$qg_output" | grep -A 50 "## Finding" || echo "$qg_output" | tail -30)

      if [[ -n "$session_id" ]]; then
        echo -e "     ${BLUE}Resuming session ${session_id:0:8}...${NC}"
        claude --resume "$session_id" -p "Fix these quality gate issues:\n\n$findings\n\nMake minimal changes. Run tests. Commit as: fix: address quality gate findings" --permission-mode bypassPermissions 2>&1 || true
      else
        claude -p "Fix these quality gate issues:\n\n$findings\n\nMake minimal changes. Run tests. Commit as: fix: address quality gate findings" --permission-mode bypassPermissions 2>&1 || true
      fi
    else
      echo -e "     ${YELLOW}Quality gate: unclear verdict${NC}"
      RESULT_STATUS="failure"
      RESULT_MESSAGE="Quality gate returned unclear verdict"
      RESULT_ERROR_CAT="quality_gate"
      return 1
    fi
  done
}
