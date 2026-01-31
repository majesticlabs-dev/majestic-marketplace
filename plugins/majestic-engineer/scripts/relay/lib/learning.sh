#!/bin/bash
#
# learning.sh - Learning extraction from task attempts
#

# Extract learning from task attempt
# Usage: extract_learning "$TASK_ID" "$ATTEMPT_ID" "$TASK_TITLE" "$RESULT_STATUS" "$RESULT_MESSAGE" "$RESULT_ERROR_CAT" "$RESULT_SUGGESTION"
extract_learning() {
  local task_id="$1"
  local attempt_id="$2"
  local task_title="$3"
  local result_status="$4"
  local result_message="$5"
  local result_error_cat="${6:-}"
  local result_suggestion="${7:-}"

  echo -e "     ${BLUE}📚 Extracting learning...${NC}"

  local context="Task: $task_title
Result: $result_status
Summary: $result_message"
  [[ -n "$result_error_cat" ]] && context="$context
Error: $result_error_cat"
  [[ -n "$result_suggestion" ]] && context="$context
Suggestion: $result_suggestion"

  local prompt="Based on this task attempt, extract ONE reusable learning (1 sentence max).
Focus on: patterns, gotchas, techniques that apply beyond this specific task.

$context

Output format: LEARNING: <sentence> | TAGS: <comma-separated>
Or output 'none' if nothing generalizable."

  local output
  if output=$(claude -p "$prompt" --model haiku 2>/dev/null); then
    if [[ "$output" != *"none"* ]]; then
      local learning_text learning_tags
      learning_text=$(echo "$output" | grep -oE 'LEARNING: [^|]+' | sed 's/LEARNING: //' | head -1 || true)
      learning_tags=$(echo "$output" | grep -oE 'TAGS: .+' | sed 's/TAGS: //' | head -1 || true)

      if [[ -n "$learning_text" ]]; then
        ledger_record_learning "$task_id" "$attempt_id" "$learning_text" "$learning_tags"
        echo -e "     ${GREEN}📝 Learned: ${learning_text:0:60}...${NC}"
      fi
    fi
  fi
}

# Process learnings at epic completion
# Usage: process_epic_learnings "$EPIC" "$LEDGER"
process_epic_learnings() {
  local epic="$1"
  local ledger="$2"

  local stats total_learnings epic_id
  stats=$(ledger_get_learning_stats)
  total_learnings=$(echo "$stats" | jq -r '.total_learnings // 0')

  if [[ "$total_learnings" -gt 0 ]]; then
    echo ""
    echo -e "${BLUE}📚 Processing $total_learnings learnings from epic...${NC}"

    epic_id=$(yq -r '.id' "$epic")
    local prompt="You are the majestic-engineer:relay:learning-processor agent.

Use the workflow defined in your agent spec to:
1. Read learnings from: $ledger
2. Consolidate similar patterns
3. Apply frequency thresholds (1=skip, 2=emerging, 3+=recommend, 4+=strong)
4. Categorize into AGENTS.md vs .agents.yml
5. Present findings and ask user before applying changes

Epic: $epic_id
Ledger: $ledger

Read the ledger and process all learnings. Use AskUserQuestion before making any file changes."

    claude -p "$prompt" --allowedTools 'Read,Write,Edit,Grep,Glob,Bash(yq:*),Bash(grep:*),AskUserQuestion' 2>/dev/null || {
      echo -e "${YELLOW}⚠️  Learning processor skipped (non-critical)${NC}"
    }
  else
    echo -e "${YELLOW}📝 No learnings captured during epic${NC}"
  fi
}
