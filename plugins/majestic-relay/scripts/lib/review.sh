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

# Run review via RepoPrompt MCP
# Usage: run_repoprompt_review "$task_id" "$output"
run_repoprompt_review() {
  local task_id="$1"
  local output="$2"

  # Check if RepoPrompt MCP is available
  if ! command -v mcp-cli &> /dev/null; then
    echo "approved"  # Skip review if mcp-cli not available
    return
  fi

  # Get changed files
  local changed_files
  changed_files=$(git diff --name-only HEAD~1 2>/dev/null | head -10)

  if [[ -z "$changed_files" ]]; then
    echo "approved"  # No changes to review
    return
  fi

  # Build review prompt
  local review_prompt="Review the following code changes for task ${task_id}:

Files changed:
${changed_files}

Please check for:
1. Code quality and best practices
2. Potential bugs or issues
3. Security concerns
4. Missing edge cases

Respond with APPROVED if the changes are acceptable, or explain what needs to be fixed."

  # Call RepoPrompt for review
  # Note: This assumes RepoPrompt MCP is configured
  local result
  if result=$(mcp-cli call repoprompt/review "$(echo "$review_prompt" | jq -Rs .)" 2>/dev/null); then
    if echo "$result" | grep -qi "APPROVED"; then
      echo "approved"
    else
      echo "$result" | head -5
    fi
  else
    # If MCP call fails, approve anyway (don't block on review failure)
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
