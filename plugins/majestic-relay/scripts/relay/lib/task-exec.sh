#!/bin/bash
#
# task-exec.sh - Task execution with JSON output
#

# Execute task and parse JSON result
# Sets: RESULT_STATUS, RESULT_MESSAGE, RESULT_FILES, RESULT_ERROR_CAT, RESULT_SUGGESTION, TASK_SESSION_ID
# Usage: execute_task "$PROMPT" "$SCHEMA"
execute_task() {
  local prompt="$1"
  local schema="$2"
  local temp_output exit_code output

  temp_output=$(mktemp)
  echo ""
  claude -p "$prompt" --permission-mode bypassPermissions --output-format json --json-schema "$schema" 2>&1 | tee "$temp_output" || true
  exit_code=${PIPESTATUS[0]}
  echo ""

  output=$(cat "$temp_output")
  rm -f "$temp_output"

  # Extract session_id for potential fix loop resume
  TASK_SESSION_ID=$(echo "$output" | jq -r '.session_id // empty' 2>/dev/null)

  # Validate JSON before parsing
  if ! echo "$output" | jq empty 2>/dev/null; then
    RESULT_STATUS="failure"
    RESULT_MESSAGE="CLI error: $(echo "$output" | head -1 | cut -c1-100)"
    RESULT_FILES=""
    RESULT_ERROR_CAT="cli_error"
    RESULT_SUGGESTION="Claude CLI returned non-JSON output (exit code: $exit_code). May be transient."
    return 1
  fi

  # Parse structured result
  RESULT_STATUS=$(echo "$output" | jq -r '.structured_output.status // "failure"')
  RESULT_MESSAGE=$(echo "$output" | jq -r '.structured_output.summary // "No summary provided"')
  RESULT_FILES=$(echo "$output" | jq -r '.structured_output.files_changed // [] | join(", ")')
  RESULT_ERROR_CAT=$(echo "$output" | jq -r '.structured_output.error_category // ""')
  RESULT_SUGGESTION=$(echo "$output" | jq -r '.structured_output.suggestion // ""')
}
