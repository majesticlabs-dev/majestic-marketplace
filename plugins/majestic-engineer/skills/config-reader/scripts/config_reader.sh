#!/usr/bin/env bash
# config_reader.sh - Read and merge .agents.yml with .agents.local.yml
#
# Usage:
#   config_reader.sh                    # Returns full merged config (both files)
#   config_reader.sh <field>            # Returns specific field value
#   config_reader.sh <field> <default>  # Returns field or default if not found
#
# Examples:
#   config_reader.sh                         # Show both configs
#   config_reader.sh auto_preview            # Get auto_preview value
#   config_reader.sh auto_preview false      # Get auto_preview or "false"
#   config_reader.sh tech_stack generic      # Get tech_stack or "generic"
#
# Merge logic: Local overrides base (local checked first)

set -euo pipefail

BASE_CONFIG=".agents.yml"
LOCAL_CONFIG=".agents.local.yml"

# Get a single field value (local overrides base)
get_field() {
  local field="$1"
  local default="${2:-}"
  local value=""

  # Check local first (override)
  if [[ -f "$LOCAL_CONFIG" ]]; then
    value=$(grep -m1 "^${field}:" "$LOCAL_CONFIG" 2>/dev/null | cut -d: -f2- | sed 's/^ *//' || true)
  fi

  # Fall back to base if not in local
  if [[ -z "$value" && -f "$BASE_CONFIG" ]]; then
    value=$(grep -m1 "^${field}:" "$BASE_CONFIG" 2>/dev/null | cut -d: -f2- | sed 's/^ *//' || true)
  fi

  # Return value or default
  echo "${value:-$default}"
}

# Show full config (both files with override indication)
show_full_config() {
  local has_base=false
  local has_local=false

  if [[ -f "$BASE_CONFIG" ]]; then
    has_base=true
    echo "## Base Config ($BASE_CONFIG)"
    echo ""
    cat "$BASE_CONFIG"
    echo ""
  fi

  if [[ -f "$LOCAL_CONFIG" ]]; then
    has_local=true
    echo "## Local Overrides ($LOCAL_CONFIG)"
    echo ""
    cat "$LOCAL_CONFIG"
    echo ""
  fi

  if [[ "$has_base" == false && "$has_local" == false ]]; then
    echo "ERROR: No config file found ($BASE_CONFIG or $LOCAL_CONFIG)"
    exit 1
  fi

  # Show effective overrides
  if [[ "$has_base" == true && "$has_local" == true ]]; then
    echo "## Effective Overrides"
    echo ""
    echo "Keys in local that override base:"
    while IFS= read -r line; do
      if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*): ]]; then
        local key="${BASH_REMATCH[1]}"
        if grep -q "^${key}:" "$BASE_CONFIG" 2>/dev/null; then
          echo "  - $key (local wins)"
        fi
      fi
    done < "$LOCAL_CONFIG"
  fi
}

# Main
main() {
  if [[ $# -eq 0 ]]; then
    show_full_config
  elif [[ $# -eq 1 ]]; then
    get_field "$1"
  else
    get_field "$1" "$2"
  fi
}

main "$@"
