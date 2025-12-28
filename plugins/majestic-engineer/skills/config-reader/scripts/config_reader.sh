#!/usr/bin/env bash
# config_reader.sh - Read and merge .agents.yml with .agents.local.yml using yq
#
# Usage:
#   config_reader.sh                    # Returns full merged config
#   config_reader.sh <field>            # Returns specific field value
#   config_reader.sh <field> <default>  # Returns field or default if not found
#
# Examples:
#   config_reader.sh                              # Show merged config
#   config_reader.sh auto_preview false           # Get top-level field or "false"
#   config_reader.sh plan.auto_create_task false  # Get nested field or "false"
#   config_reader.sh tech_stack generic           # Get top-level field or "generic"
#
# Merge logic: Local overrides base (deep merge, local wins)
#
# Requirements: yq (https://github.com/mikefarah/yq)

set -euo pipefail

BASE_CONFIG=".agents.yml"
LOCAL_CONFIG=".agents.local.yml"

# Check yq is available
check_yq() {
  if ! command -v yq &> /dev/null; then
    echo "ERROR: yq is required but not installed." >&2
    echo "Install: brew install yq (macOS) or snap install yq (Linux)" >&2
    echo "See: https://github.com/mikefarah/yq#install" >&2
    exit 1
  fi
}

# Migration map: new_field -> old_field (for backwards compatibility)
# When requesting a new nested field, also check the old flat field
declare -A MIGRATION_MAP=(
  ["plan.auto_create_task"]="auto_create_task"
)

# Read a value from config files (local first, then base)
read_from_config() {
  local yq_path="$1"
  local value=""

  # Check local first (override)
  if [[ -f "$LOCAL_CONFIG" ]]; then
    value=$(yq eval "$yq_path // \"\"" "$LOCAL_CONFIG" 2>/dev/null || echo "")
    [[ "$value" == "null" ]] && value=""
  fi

  # Fall back to base if not in local
  if [[ -z "$value" && -f "$BASE_CONFIG" ]]; then
    value=$(yq eval "$yq_path // \"\"" "$BASE_CONFIG" 2>/dev/null || echo "")
    [[ "$value" == "null" ]] && value=""
  fi

  echo "$value"
}

# Get a single field value from merged config
# Supports dot notation: plan.auto_create_task, toolbox.build_task.design_system_path
# Includes backwards compatibility for migrated fields
get_field() {
  local field="$1"
  local default="${2:-}"
  local value=""

  # Try the requested field first
  value=$(read_from_config ".${field}")

  # If empty and field has a migration fallback, try the old path
  if [[ -z "$value" && -n "${MIGRATION_MAP[$field]:-}" ]]; then
    local old_field="${MIGRATION_MAP[$field]}"
    value=$(read_from_config ".${old_field}")
  fi

  # Return value or default
  echo "${value:-$default}"
}

# Show full merged config
show_full_config() {
  local has_base=false
  local has_local=false

  if [[ -f "$BASE_CONFIG" ]]; then
    has_base=true
  fi

  if [[ -f "$LOCAL_CONFIG" ]]; then
    has_local=true
  fi

  if [[ "$has_base" == false && "$has_local" == false ]]; then
    echo "ERROR: No config file found ($BASE_CONFIG or $LOCAL_CONFIG)" >&2
    exit 1
  fi

  # Deep merge: base * local (local overrides base)
  if [[ "$has_base" == true && "$has_local" == true ]]; then
    echo "# Merged config ($BASE_CONFIG + $LOCAL_CONFIG)"
    echo "# Local values override base values"
    echo ""
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$BASE_CONFIG" "$LOCAL_CONFIG"
  elif [[ "$has_base" == true ]]; then
    echo "# Config from $BASE_CONFIG"
    echo ""
    cat "$BASE_CONFIG"
  else
    echo "# Config from $LOCAL_CONFIG"
    echo ""
    cat "$LOCAL_CONFIG"
  fi
}

# Main
main() {
  check_yq

  if [[ $# -eq 0 ]]; then
    show_full_config
  elif [[ $# -eq 1 ]]; then
    get_field "$1"
  else
    get_field "$1" "$2"
  fi
}

main "$@"
