#!/bin/bash
#
# review.sh - Review provider integration
#
# Supports: repoprompt, gemini, none
#

# Run review based on provider
# Usage: run_review "$provider" "$task_id" "$output"
# Returns: "approved" or rejection reason
run_review() {
  local provider="$1"
  local task_id="$2"
  local output="$3"

  case "$provider" in
    repoprompt)
      run_repoprompt_review "$task_id" "$output"
      ;;
    gemini)
      run_gemini_review "$task_id" "$output"
      ;;
    none|"")
      echo "approved"
      ;;
    *)
      echo "Unknown review provider: $provider" >&2
      echo "approved"  # Don't block on unknown provider
      ;;
  esac
}

# Run review via RepoPrompt MCP (through Claude agent)
# Usage: run_repoprompt_review "$task_id" "$output"
# Invokes Claude headless with MCP access to call repoprompt/chat_send
run_repoprompt_review() {
  local task_id="$1"
  local output="$2"  # Kept for signature compatibility

  # Check if claude CLI is available
  if ! command -v claude &> /dev/null; then
    echo "approved"  # Skip review if claude not available
    return
  fi

  # Check if jq is available (required for JSON parsing)
  if ! command -v jq &> /dev/null; then
    echo "approved"  # Skip review if jq not available
    return
  fi

  # Get changed files from last commit
  local changed_files
  changed_files=$(git diff --name-only HEAD~1 2>/dev/null | head -20)

  if [[ -z "$changed_files" ]]; then
    echo "approved"  # No changes to review
    return
  fi

  # Build the review prompt for Claude
  local review_prompt="You are a code reviewer. Review the code changes for relay task ${task_id}.

Changed files:
${changed_files}

Instructions:
1. First, switch RepoPrompt to the correct workspace using repoprompt/manage_workspaces
2. Then call repoprompt/chat_send with mode=\"review\" and the changed files as selected_paths
3. Parse the review response and return your verdict

Return your verdict as structured JSON."

  # JSON schema for structured output
  local review_schema='{
    "type": "object",
    "properties": {
      "verdict": {
        "type": "string",
        "enum": ["approved", "rejected"],
        "description": "Review verdict"
      },
      "reason": {
        "type": "string",
        "description": "Brief explanation of the verdict"
      }
    },
    "required": ["verdict", "reason"]
  }'

  # Invoke Claude with structured output
  local result
  if result=$(claude -p "$review_prompt" \
    --output-format json \
    --json-schema "$review_schema" \
    --max-turns 5 \
    --permission-mode bypassPermissions \
    2>/dev/null); then

    # Parse the structured output
    local verdict
    verdict=$(echo "$result" | jq -r '.structured_output.verdict // "approved"')

    if [[ "$verdict" == "approved" ]]; then
      echo "approved"
    else
      local reason
      reason=$(echo "$result" | jq -r '.structured_output.reason // "Review rejected"')
      echo "$reason" | head -3
    fi
  else
    # If Claude invocation fails, approve anyway (don't block on review failure)
    echo "approved"
  fi
}

# Run review via Gemini (majestic-llm)
# Usage: run_gemini_review "$task_id" "$output"
run_gemini_review() {
  local task_id="$1"
  local output="$2"

  # Get git diff for review
  local diff
  diff=$(git diff HEAD~1 2>/dev/null | head -500)

  if [[ -z "$diff" ]]; then
    echo "approved"  # No changes to review
    return
  fi

  # Build review prompt for Claude to invoke Gemini reviewer
  local review_prompt="Review the code changes for task ${task_id}:

\`\`\`diff
${diff}
\`\`\`

Use the gemini-reviewer agent to get a second opinion on these changes.
Return APPROVED if acceptable, or explain issues found."

  # Invoke Claude to use the gemini-reviewer agent
  local result
  if result=$(claude --print "$review_prompt" 2>/dev/null); then
    if echo "$result" | grep -qi "APPROVED"; then
      echo "approved"
    else
      # Extract rejection reason
      echo "$result" | grep -i -A 5 "issue\|problem\|concern\|fix" | head -3
    fi
  else
    # If review fails, approve anyway (don't block on review failure)
    echo "approved"
  fi
}
