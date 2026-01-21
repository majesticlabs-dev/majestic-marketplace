#!/bin/bash
#
# quality-gate.sh - Quality gate with fix loop
#

DEFERRED_LOG=".agents-os/relay/deferred-findings.log"

# Extract and log deferred findings from quality gate output
# Usage: log_deferred_findings "$qg_output" "$task_id"
log_deferred_findings() {
  local output="$1"
  local task_id="$2"
  local deferred timestamp

  # Extract content between markers
  deferred=$(echo "$output" | sed -n '/DEFERRED_FINDINGS_START/,/DEFERRED_FINDINGS_END/p' | grep -v 'DEFERRED_FINDINGS')

  if [[ -n "$deferred" ]]; then
    mkdir -p "$(dirname "$DEFERRED_LOG")"
    timestamp=$(date -Iseconds)

    echo "# [$timestamp] Task: $task_id" >> "$DEFERRED_LOG"
    echo "$deferred" >> "$DEFERRED_LOG"
    echo "" >> "$DEFERRED_LOG"

    local count
    count=$(echo "$deferred" | grep -c "^severity:" || echo "0")
    echo -e "     ${YELLOW}📋 Deferred $count finding(s) to log${NC}"
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

  branch=$(git branch --show-current 2>/dev/null || echo 'unknown')
  qg_prompt="You are running quality-gate verification for a relay task.

Use the Task tool to invoke the quality-gate agent:

Task(majestic-engineer:workflow:quality-gate):
  prompt: |
    Context: ${task_id} - ${task_title}
    Branch: ${branch}
    AC Path: ${epic}
    Task ID: ${task_id}

Return the verdict exactly as: Verdict: APPROVED or Verdict: NEEDS CHANGES or Verdict: BLOCKED"

  fix_attempt=0
  while [[ $fix_attempt -lt 3 ]]; do
    echo -e "     ${BLUE}🔍 Running quality gate...${NC}"
    qg_temp=$(mktemp)
    claude -p "$qg_prompt" --permission-mode bypassPermissions 2>&1 | tee "$qg_temp" || true
    qg_output=$(cat "$qg_temp")
    rm -f "$qg_temp"

    qg_verdict=$(echo "$qg_output" | grep -oE 'Verdict: (APPROVED|NEEDS CHANGES|BLOCKED)' | tail -1 | cut -d' ' -f2-)

    if [[ "$qg_verdict" == "APPROVED" ]]; then
      echo -e "     ${GREEN}✅ Quality gate: APPROVED${NC}"
      log_deferred_findings "$qg_output" "$task_id"
      return 0
    elif [[ "$qg_verdict" == "BLOCKED" ]]; then
      echo -e "     ${RED}🛑 Quality gate: BLOCKED${NC}"
      return 2
    elif [[ "$qg_verdict" == "NEEDS CHANGES" ]]; then
      fix_attempt=$((fix_attempt + 1))
      if [[ $fix_attempt -ge 3 ]]; then
        echo -e "     ${RED}❌ Fix attempts exhausted${NC}"
        RESULT_STATUS="failure"
        RESULT_MESSAGE="Quality gate failed after 2 fix attempts"
        RESULT_ERROR_CAT="fix_loop_exhausted"
        return 1
      fi

      echo -e "     ${YELLOW}🔧 Fix attempt $fix_attempt/2...${NC}"
      findings=$(echo "$qg_output" | grep -A 50 "## Finding" || echo "$qg_output" | tail -30)

      if [[ -n "$session_id" ]]; then
        echo -e "     ${BLUE}↻ Resuming session ${session_id:0:8}...${NC}"
        claude --resume "$session_id" -p "Fix these quality gate issues:\n\n$findings\n\nMake minimal changes. Run tests. Commit as: fix: address quality gate findings" --permission-mode bypassPermissions 2>&1 || true
      else
        claude -p "Fix these quality gate issues:\n\n$findings\n\nMake minimal changes. Run tests. Commit as: fix: address quality gate findings" --permission-mode bypassPermissions 2>&1 || true
      fi
    else
      echo -e "     ${YELLOW}⚠️ Quality gate: unclear verdict${NC}"
      RESULT_STATUS="failure"
      RESULT_MESSAGE="Quality gate returned unclear verdict"
      RESULT_ERROR_CAT="quality_gate"
      return 1
    fi
  done
}
