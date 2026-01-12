#!/bin/bash
#
# prompt.sh - Re-anchoring prompt builder
#
# Builds context-rich prompts for fresh Claude instances
#

# Build task execution prompt with re-anchoring context
# Usage: build_task_prompt "$EPIC" "$LEDGER" "$TASK_ID"
build_task_prompt() {
  local epic="$1"
  local ledger="$2"
  local task_id="$3"

  # Gather git state
  local git_branch
  git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  local git_commit
  git_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "unknown")

  local git_changes
  git_changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  # Get epic info
  local epic_title
  epic_title=$(yq -r '.title' "$epic")

  local epic_description
  epic_description=$(yq -r '.description' "$epic")

  local epic_source
  epic_source=$(yq -r '.source' "$epic")

  # Get task info
  local task_title
  task_title=$(yq -r ".tasks.${task_id}.title" "$epic")

  local task_files
  task_files=$(yq -r ".tasks.${task_id}.files | .[]" "$epic" 2>/dev/null | sed 's/^/- /')

  local task_ac
  task_ac=$(yq -r ".tasks.${task_id}.acceptance_criteria | .[]" "$epic" 2>/dev/null | sed 's/^/- [ ] /')

  local task_deps
  task_deps=$(yq -r ".tasks.${task_id}.depends_on | .[]" "$epic" 2>/dev/null)

  # Build dependencies status
  local deps_status=""
  if [[ -n "$task_deps" ]]; then
    for dep in $task_deps; do
      local dep_title
      dep_title=$(yq -r ".tasks.${dep}.title" "$epic")
      local dep_status
      dep_status=$(yq -r ".task_status.${dep}" "$ledger")
      deps_status+="- ${dep}: ${dep_title} ✅
"
    done
  fi

  # Get previous attempts
  local prev_attempts=""
  local attempt_count
  attempt_count=$(yq -r ".attempts.${task_id} | length // 0" "$ledger")

  if [[ "$attempt_count" -gt 0 ]]; then
    prev_attempts="### Previous Attempts on This Task
"
    for ((i=0; i<attempt_count; i++)); do
      local attempt_result
      attempt_result=$(yq -r ".attempts.${task_id}[${i}].result" "$ledger")

      if [[ "$attempt_result" == "failure" ]]; then
        local error_summary
        error_summary=$(yq -r ".attempts.${task_id}[${i}].receipt.error_summary // \"Unknown error\"" "$ledger")

        prev_attempts+="
**Attempt $((i+1)) (failed):**
- Error: ${error_summary}
"
      fi
    done

    if [[ "$attempt_count" -gt 0 ]]; then
      prev_attempts+="
**What to do differently:** Address the errors from previous attempts before trying the same approach.
"
    fi
  fi

  # Build the prompt
  cat <<EOF
# Task Execution Context

## Current State
- **Git branch:** ${git_branch}
- **Last commit:** ${git_commit}
- **Uncommitted changes:** ${git_changes} files

## Epic: ${epic_title}
${epic_description}

Source: ${epic_source}

---

## Your Task: ${task_id} - ${task_title}

### Files to Modify
${task_files}

### Acceptance Criteria
${task_ac}

$(if [[ -n "$deps_status" ]]; then echo "### Dependencies (completed)"; echo "$deps_status"; fi)

${prev_attempts}

---

## Instructions

1. Implement this task only - do not work on other tasks
2. Run tests to verify acceptance criteria
3. If successful, commit with message: "${task_id}: ${task_title}"
4. If blocked by an issue you cannot resolve, explain what's missing

Your response will be automatically structured as JSON. Focus on the implementation.
The orchestrator will capture your result status and summary.
EOF
}
