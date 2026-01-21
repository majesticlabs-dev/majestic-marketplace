#!/bin/bash
#
# ledger.sh - Attempt ledger helper functions
#
# Functions for reading/writing .agents-os/relay/attempt-ledger.yml
#

LEDGER="${LEDGER:-.agents-os/relay/attempt-ledger.yml}"

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

  # Use strenv() to safely handle summaries with embedded quotes/special chars
  export SUMMARY_VAR="$summary"
  yq -i ".attempts.${task_id}[${idx}].receipt.summary = strenv(SUMMARY_VAR)" "$LEDGER"
  unset SUMMARY_VAR

  # Add files_changed if provided
  if [[ -n "$files_changed" ]]; then
    # Convert comma-separated to YAML array
    # Use strenv() to pass string safely (avoids yq trying to parse file paths as YAML)
    # Use -o=json so output can be interpolated into another yq expression
    local files_yaml
    export FILES_CHANGED_VAR="$files_changed"
    files_yaml=$(yq -n -o=json 'strenv(FILES_CHANGED_VAR) | split(", ")')
    unset FILES_CHANGED_VAR
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

  # Use strenv() to safely handle summaries with embedded quotes/special chars
  export SUMMARY_VAR="$summary"
  yq -i ".attempts.${task_id}[${idx}].receipt.error_summary = strenv(SUMMARY_VAR)" "$LEDGER"
  unset SUMMARY_VAR

  # Add optional fields if provided
  if [[ -n "$error_category" ]]; then
    yq -i ".attempts.${task_id}[${idx}].receipt.error_category = \"${error_category}\"" "$LEDGER"
  fi
  if [[ -n "$suggestion" ]]; then
    # Use strenv() for suggestion which may contain special chars
    export SUGGESTION_VAR="$suggestion"
    yq -i ".attempts.${task_id}[${idx}].receipt.suggestion = strenv(SUGGESTION_VAR)" "$LEDGER"
    unset SUGGESTION_VAR
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
  local epic="${EPIC:-.agents-os/relay/epic.yml}"

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

# ============================================
# Relay Process Status Tracking
# ============================================

# Record relay start
# Usage: ledger_relay_start
ledger_relay_start() {
  local started_at
  started_at=$(date -Iseconds)
  local pid=$$

  yq -i ".relay_status.state = \"running\"" "$LEDGER"
  yq -i ".relay_status.pid = ${pid}" "$LEDGER"
  yq -i ".relay_status.started_at = \"${started_at}\"" "$LEDGER"
  yq -i ".relay_status.last_exit_code = null" "$LEDGER"
  yq -i ".relay_status.last_exit_reason = null" "$LEDGER"
}

# Record relay stop
# Usage: ledger_relay_stop "exit_code" "reason"
# Reasons: epic_complete, no_runnable_tasks, error, interrupted
ledger_relay_stop() {
  local exit_code="$1"
  local reason="$2"
  local stopped_at
  stopped_at=$(date -Iseconds)

  yq -i ".relay_status.state = \"idle\"" "$LEDGER"
  yq -i ".relay_status.pid = null" "$LEDGER"
  yq -i ".relay_status.stopped_at = \"${stopped_at}\"" "$LEDGER"
  yq -i ".relay_status.last_exit_code = ${exit_code}" "$LEDGER"
  yq -i ".relay_status.last_exit_reason = \"${reason}\"" "$LEDGER"
}

# Check if relay is currently running (stale PID detection)
# Usage: ledger_relay_is_running
# Returns: 0 if running, 1 if not
ledger_relay_is_running() {
  local state
  state=$(yq -r '.relay_status.state // "idle"' "$LEDGER" 2>/dev/null)

  if [[ "$state" != "running" ]]; then
    return 1
  fi

  # Check if PID is still alive
  local pid
  pid=$(yq -r '.relay_status.pid // 0' "$LEDGER" 2>/dev/null)

  if [[ "$pid" -gt 0 ]] && kill -0 "$pid" 2>/dev/null; then
    return 0
  else
    # Stale running state - clean it up
    yq -i ".relay_status.state = \"idle\"" "$LEDGER"
    yq -i ".relay_status.last_exit_reason = \"crashed\"" "$LEDGER"
    return 1
  fi
}

# Get relay status summary
# Usage: ledger_relay_status
# Returns: JSON with state, last_run info
ledger_relay_status() {
  yq -o=json '.relay_status // {}' "$LEDGER" 2>/dev/null
}

# ============================================
# Epic & Task Timing
# ============================================

# Record epic completion
# Usage: ledger_epic_complete
ledger_epic_complete() {
  local ended_at
  ended_at=$(date -Iseconds)

  yq -i ".ended_at = \"${ended_at}\"" "$LEDGER"

  # Calculate duration if started_at exists
  local started_at
  started_at=$(yq -r '.started_at // ""' "$LEDGER")

  if [[ -n "$started_at" ]]; then
    # Calculate duration in minutes (portable approach)
    local start_epoch end_epoch duration_minutes
    start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${started_at%[-+]*}" "+%s" 2>/dev/null || date -d "$started_at" "+%s" 2>/dev/null)
    end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${ended_at%[-+]*}" "+%s" 2>/dev/null || date -d "$ended_at" "+%s" 2>/dev/null)

    if [[ -n "$start_epoch" && -n "$end_epoch" ]]; then
      duration_minutes=$(( (end_epoch - start_epoch) / 60 ))
      yq -i ".duration_minutes = ${duration_minutes}" "$LEDGER"
    fi
  fi
}

# Get task timing summary
# Usage: ledger_get_task_timing "T1"
# Returns: JSON with started_at, ended_at, duration_minutes, attempts
ledger_get_task_timing() {
  local task_id="$1"

  local first_start last_end attempt_count

  # Get first attempt start
  first_start=$(yq -r ".attempts.${task_id}[0].started_at // \"\"" "$LEDGER")

  # Get last attempt end
  attempt_count=$(yq -r ".attempts.${task_id} | length // 0" "$LEDGER")
  if [[ "$attempt_count" -gt 0 ]]; then
    local last_idx=$((attempt_count - 1))
    last_end=$(yq -r ".attempts.${task_id}[${last_idx}].ended_at // \"\"" "$LEDGER")
  fi

  # Output JSON
  cat <<EOF
{
  "started_at": "${first_start}",
  "ended_at": "${last_end}",
  "attempts": ${attempt_count}
}
EOF
}

# ============================================
# Compound Learning Functions
# ============================================

# Record learning from an attempt
# Usage: ledger_record_learning "T1" "1" "learning text" "tag1,tag2"
ledger_record_learning() {
  local task_id="$1"
  local attempt_id="$2"
  local learning="$3"
  local tags="${4:-}"

  # Skip if learning is empty or "none"
  if [[ -z "$learning" || "$learning" == "none" || "$learning" == "null" ]]; then
    return 0
  fi

  local idx=$((attempt_id - 1))

  # Escape special characters for yq
  export LEARNING_VAR="$learning"
  yq -i ".attempts.${task_id}[${idx}].receipt.learning = strenv(LEARNING_VAR)" "$LEDGER"
  unset LEARNING_VAR

  # Add tags if provided
  if [[ -n "$tags" ]]; then
    export TAGS_VAR="$tags"
    local tags_yaml
    # Use -o=json so output can be interpolated into another yq expression
    tags_yaml=$(yq -n -o=json 'strenv(TAGS_VAR) | split(",")')
    unset TAGS_VAR
    yq -i ".attempts.${task_id}[${idx}].receipt.pattern_tags = ${tags_yaml}" "$LEDGER"
  fi
}

# Get all learnings from ledger
# Usage: ledger_get_all_learnings
# Returns: YAML list of learnings with context
ledger_get_all_learnings() {
  yq -o=yaml '
    .attempts | to_entries | .[] |
    .key as $task |
    .value[] |
    select(.receipt.learning != null and .receipt.learning != "") |
    {
      "task": $task,
      "attempt": .id,
      "result": .result,
      "learning": .receipt.learning,
      "tags": (.receipt.pattern_tags // []),
      "error_category": (.receipt.error_category // null)
    }
  ' "$LEDGER" 2>/dev/null
}

# Get learning summary stats
# Usage: ledger_get_learning_stats
# Returns: JSON with counts
ledger_get_learning_stats() {
  local total success_learnings failure_learnings

  total=$(yq -r '
    [.attempts | to_entries | .[] | .value[] | select(.receipt.learning != null and .receipt.learning != "")] | length
  ' "$LEDGER" 2>/dev/null || echo "0")

  success_learnings=$(yq -r '
    [.attempts | to_entries | .[] | .value[] | select(.result == "success" and .receipt.learning != null and .receipt.learning != "")] | length
  ' "$LEDGER" 2>/dev/null || echo "0")

  failure_learnings=$(yq -r '
    [.attempts | to_entries | .[] | .value[] | select(.result == "failure" and .receipt.learning != null and .receipt.learning != "")] | length
  ' "$LEDGER" 2>/dev/null || echo "0")

  cat <<EOF
{
  "total_learnings": ${total},
  "from_success": ${success_learnings},
  "from_failure": ${failure_learnings}
}
EOF
}

# Clear all learnings from ledger after promotion to AGENTS.md
# Usage: ledger_clear_learnings
ledger_clear_learnings() {
  # Remove learning and pattern_tags from all attempt receipts
  yq -i '
    .attempts |= with_entries(
      .value |= map(
        del(.receipt.learning) |
        del(.receipt.pattern_tags)
      )
    )
  ' "$LEDGER" 2>/dev/null

  echo "Learnings cleared from ledger"
}

