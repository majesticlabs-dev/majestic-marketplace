#!/bin/bash
#
# ledger.sh - Attempt ledger helper functions
#
# Functions for reading/writing .majestic/attempt-ledger.yml
#

LEDGER="${LEDGER:-.majestic/attempt-ledger.yml}"

# Get a setting from the ledger
# Usage: ledger_get_setting "key.path" "default"
ledger_get_setting() {
  local key="$1"
  local default="${2:-}"

  local value
  value=$(yq -r ".settings.${key} // \"${default}\"" "$LEDGER" 2>/dev/null)

  if [[ "$value" == "null" || -z "$value" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Get task status from ledger
# Usage: ledger_get_task_status "T1"
ledger_get_task_status() {
  local task_id="$1"

  # Check if gated first
  local gated
  gated=$(yq -r ".gated_tasks.${task_id} // \"\"" "$LEDGER" 2>/dev/null)
  if [[ -n "$gated" && "$gated" != "null" ]]; then
    echo "gated"
    return
  fi

  # Get normal status
  yq -r ".task_status.${task_id} // \"pending\"" "$LEDGER" 2>/dev/null
}

# Count tasks with a specific status
# Usage: ledger_count_status "completed"
ledger_count_status() {
  local status="$1"

  yq -r ".task_status | to_entries | map(select(.value == \"${status}\")) | length" "$LEDGER" 2>/dev/null || echo "0"
}

# Count attempts for a task
# Usage: ledger_count_attempts "T1"
ledger_count_attempts() {
  local task_id="$1"

  yq -r ".attempts.${task_id} | length // 0" "$LEDGER" 2>/dev/null || echo "0"
}

# Record attempt start
# Usage: ledger_record_attempt_start "T1" "1"
ledger_record_attempt_start() {
  local task_id="$1"
  local attempt_id="$2"
  local started_at
  started_at=$(date -Iseconds)

  # Update task status to in_progress
  yq -i ".task_status.${task_id} = \"in_progress\"" "$LEDGER"

  # Add new attempt entry
  yq -i ".attempts.${task_id} += [{
    \"id\": ${attempt_id},
    \"started_at\": \"${started_at}\",
    \"ended_at\": null,
    \"result\": \"in_progress\"
  }]" "$LEDGER"
}

# Record successful attempt
# Usage: ledger_record_attempt_success "T1" "1" "summary" "files_changed"
ledger_record_attempt_success() {
  local task_id="$1"
  local attempt_id="$2"
  local summary="$3"
  local files_changed="${4:-}"
  local ended_at
  ended_at=$(date -Iseconds)

  # Update task status
  yq -i ".task_status.${task_id} = \"completed\"" "$LEDGER"

  # Update attempt with receipt
  local idx=$((attempt_id - 1))
  yq -i ".attempts.${task_id}[${idx}].ended_at = \"${ended_at}\"" "$LEDGER"
  yq -i ".attempts.${task_id}[${idx}].result = \"success\"" "$LEDGER"
  yq -i ".attempts.${task_id}[${idx}].receipt.summary = \"${summary}\"" "$LEDGER"

  # Add files_changed if provided
  if [[ -n "$files_changed" ]]; then
    # Convert comma-separated to YAML array
    local files_yaml
    files_yaml=$(echo "$files_changed" | yq 'split(", ")')
    yq -i ".attempts.${task_id}[${idx}].receipt.files_changed = ${files_yaml}" "$LEDGER"
  fi

  # Update blocked tasks - check if any tasks depend on this one
  update_blocked_tasks "$task_id"
}

# Record failed attempt
# Usage: ledger_record_attempt_failure "T1" "1" "summary" "error_category" "suggestion"
ledger_record_attempt_failure() {
  local task_id="$1"
  local attempt_id="$2"
  local summary="$3"
  local error_category="${4:-}"
  local suggestion="${5:-}"
  local ended_at
  ended_at=$(date -Iseconds)

  # Keep task status as pending (will retry)
  yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER"

  # Update attempt with receipt
  local idx=$((attempt_id - 1))
  yq -i ".attempts.${task_id}[${idx}].ended_at = \"${ended_at}\"" "$LEDGER"
  yq -i ".attempts.${task_id}[${idx}].result = \"failure\"" "$LEDGER"
  yq -i ".attempts.${task_id}[${idx}].receipt.error_summary = \"${summary}\"" "$LEDGER"

  # Add optional fields if provided
  if [[ -n "$error_category" ]]; then
    yq -i ".attempts.${task_id}[${idx}].receipt.error_category = \"${error_category}\"" "$LEDGER"
  fi
  if [[ -n "$suggestion" ]]; then
    yq -i ".attempts.${task_id}[${idx}].receipt.suggestion = \"${suggestion}\"" "$LEDGER"
  fi
}

# Gate a task (block from further retries)
# Usage: ledger_gate_task "T1" "max_attempts_exceeded"
ledger_gate_task() {
  local task_id="$1"
  local reason="$2"
  local gated_at
  gated_at=$(date -Iseconds)

  yq -i ".gated_tasks.${task_id} = {
    \"reason\": \"${reason}\",
    \"gated_at\": \"${gated_at}\"
  }" "$LEDGER"

  # Update task status
  yq -i ".task_status.${task_id} = \"gated\"" "$LEDGER"
}

# Update tasks that were blocked by a completed task
# Usage: update_blocked_tasks "T1"
update_blocked_tasks() {
  local completed_task="$1"
  local epic="${EPIC:-.majestic/epic.yml}"

  # Get all task IDs
  local task_ids
  task_ids=$(yq -r '.tasks | keys | .[]' "$epic")

  for task_id in $task_ids; do
    local status
    status=$(ledger_get_task_status "$task_id")

    if [[ "$status" == "blocked" ]]; then
      # Check if all dependencies are now complete
      local deps
      deps=$(yq -r ".tasks.${task_id}.depends_on | .[]" "$epic" 2>/dev/null)

      local all_complete=true
      for dep in $deps; do
        local dep_status
        dep_status=$(ledger_get_task_status "$dep")
        if [[ "$dep_status" != "completed" ]]; then
          all_complete=false
          break
        fi
      done

      if [[ "$all_complete" == "true" ]]; then
        yq -i ".task_status.${task_id} = \"pending\"" "$LEDGER"
      fi
    fi
  done
}

# Find next executable task
# Usage: find_next_task "$EPIC" "$LEDGER"
find_next_task() {
  local epic="$1"
  local ledger="$2"

  # Get tasks in dependency order
  local groups
  groups=$(yq -r '.parallelization[].group' "$epic")

  for group in $groups; do
    local tasks
    tasks=$(yq -r ".parallelization[] | select(.group == \"${group}\") | .tasks[]" "$epic")

    for task_id in $tasks; do
      local status
      status=$(yq -r ".task_status.${task_id} // \"pending\"" "$ledger")

      # Skip completed and gated tasks
      if [[ "$status" == "completed" || "$status" == "gated" ]]; then
        continue
      fi

      # Check if blocked
      local deps
      deps=$(yq -r ".tasks.${task_id}.depends_on[]" "$epic" 2>/dev/null || true)

      local blocked=false
      for dep in $deps; do
        local dep_status
        dep_status=$(yq -r ".task_status.${dep} // \"pending\"" "$ledger")
        if [[ "$dep_status" != "completed" ]]; then
          blocked=true
          break
        fi
      done

      if [[ "$blocked" == "false" ]]; then
        echo "$task_id"
        return
      fi
    done
  done

  # No executable task found
  echo ""
}

