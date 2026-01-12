#!/bin/bash
#
# analyze.sh - LLM failure analysis for relay tasks
#
# Analyzes task failures to detect patterns and suggest fixes
#

# Analyze a single task's failures before gating
# Usage: analyze_task_failures "$EPIC" "$LEDGER" "$TASK_ID"
# Returns: JSON with fixable, suggestion, action fields
analyze_task_failures() {
  local epic="$1"
  local ledger="$2"
  local task_id="$3"

  # Get task info
  local task_title
  task_title=$(yq -r ".tasks.${task_id}.title" "$epic")

  local task_ac
  task_ac=$(yq -r ".tasks.${task_id}.acceptance_criteria | .[]" "$epic" 2>/dev/null | sed 's/^/- /')

  local task_files
  task_files=$(yq -r ".tasks.${task_id}.files | .[]" "$epic" 2>/dev/null | sed 's/^/- /')

  # Get all attempts for this task
  local attempts_json
  attempts_json=$(yq -o=json ".attempts.${task_id}" "$ledger")

  # Build analysis prompt
  local prompt
  prompt=$(cat <<EOF
## Task Failure Analysis

**Task:** ${task_id} - ${task_title}

**Files:**
${task_files}

**Acceptance Criteria:**
${task_ac}

**Failed Attempts:**
${attempts_json}

---

Analyze these failures and determine if the task can be fixed with a hint.

Return ONLY valid JSON:
{
  "pattern": "brief description of failure pattern",
  "root_cause": "likely cause",
  "fixable": true or false,
  "suggestion": "specific fix hint for next attempt (if fixable)",
  "action": "RETRY" or "GATE"
}

Common fixable patterns:
- Missing import/require statement
- Wrong file path assumption
- Test setup issue
- Syntax error in generated code

Unfixable patterns (should GATE):
- Unclear requirements
- Missing external dependency
- Architectural conflict with existing code
EOF
)

  # Call Claude for analysis (use haiku for speed/cost)
  local result
  result=$(claude -p "$prompt" \
    --model haiku \
    --permission-mode bypassPermissions \
    --output-format json \
    --json-schema '{
      "type": "object",
      "properties": {
        "pattern": {"type": "string"},
        "root_cause": {"type": "string"},
        "fixable": {"type": "boolean"},
        "suggestion": {"type": "string"},
        "action": {"type": "string", "enum": ["RETRY", "GATE"]}
      },
      "required": ["pattern", "fixable", "action"]
    }' 2>&1)

  # Extract structured output
  echo "$result" | jq -r '.structured_output // {"fixable": false, "action": "GATE", "pattern": "Analysis failed"}'
}

# Batch analyze all failed/gated tasks on relay exit
# Usage: analyze_batch_failures "$EPIC" "$LEDGER"
# Returns: JSON summary of patterns across all failures
analyze_batch_failures() {
  local epic="$1"
  local ledger="$2"

  # Get gated tasks
  local gated_tasks
  gated_tasks=$(yq -r '.gated_tasks | keys | .[]' "$ledger" 2>/dev/null)

  # Get tasks with failed attempts (last attempt was failure)
  local failed_info=""
  for task_id in $(yq -r '.attempts | keys | .[]' "$ledger"); do
    local last_result
    last_result=$(yq -r ".attempts.${task_id}[-1].result" "$ledger")

    if [[ "$last_result" == "failure" ]]; then
      local task_title
      task_title=$(yq -r ".tasks.${task_id}.title" "$epic")

      local error_summary
      error_summary=$(yq -r ".attempts.${task_id}[-1].receipt.error_summary // .attempts.${task_id}[-1].receipt.summary" "$ledger")

      failed_info+="- ${task_id}: ${task_title}
  Error: ${error_summary}
"
    fi
  done

  if [[ -z "$failed_info" && -z "$gated_tasks" ]]; then
    echo '{"patterns": [], "summary": "No failures to analyze"}'
    return
  fi

  # Build batch analysis prompt
  local prompt
  prompt=$(cat <<EOF
## Batch Failure Analysis

**Gated Tasks:** ${gated_tasks:-none}

**Failed Tasks:**
${failed_info:-none}

---

Analyze patterns across these failures.

Return ONLY valid JSON:
{
  "patterns": [
    {"type": "pattern name", "affected_tasks": ["T1", "T2"], "description": "what's happening"}
  ],
  "common_root_cause": "if there's a shared cause, describe it",
  "recommended_action": "what should the human do next",
  "summary": "one sentence summary"
}

Look for:
- Same error across multiple tasks
- Dependency chain issues
- Blueprint/spec problems
- Environment issues
EOF
)

  # Call Claude for batch analysis
  local result
  result=$(claude -p "$prompt" \
    --model haiku \
    --permission-mode bypassPermissions \
    --output-format json \
    --json-schema '{
      "type": "object",
      "properties": {
        "patterns": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "type": {"type": "string"},
              "affected_tasks": {"type": "array", "items": {"type": "string"}},
              "description": {"type": "string"}
            }
          }
        },
        "common_root_cause": {"type": "string"},
        "recommended_action": {"type": "string"},
        "summary": {"type": "string"}
      },
      "required": ["patterns", "summary"]
    }' 2>&1)

  echo "$result" | jq -r '.structured_output // {"patterns": [], "summary": "Batch analysis failed"}'
}

# Store analysis result in ledger
# Usage: ledger_store_analysis "$TASK_ID" "$ANALYSIS_JSON"
ledger_store_analysis() {
  local task_id="$1"
  local analysis="$2"

  yq -i ".analysis.tasks.${task_id} = ${analysis}" "$LEDGER"
}

# Store batch analysis in ledger
# Usage: ledger_store_batch_analysis "$ANALYSIS_JSON"
ledger_store_batch_analysis() {
  local analysis="$1"

  yq -i ".analysis.batch = ${analysis}" "$LEDGER"
  yq -i ".analysis.analyzed_at = \"$(date -Iseconds)\"" "$LEDGER"
}
