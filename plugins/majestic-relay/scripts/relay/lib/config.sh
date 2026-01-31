#!/bin/bash
#
# config.sh - Config reader for relay scripts
#
# Sources the canonical config reader from majestic-tools.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Discover tools plugin path via multiple fallback locations
find_config_reader() {
  local paths=(
    # Relative to majestic-relay plugin (marketplace dev mode)
    "${SCRIPT_DIR}/../../../../majestic-tools/skills/config-reader/scripts/config_reader.sh"
    # Via plugins directory traversal
    "${SCRIPT_DIR}/../../../../../majestic-tools/skills/config-reader/scripts/config_reader.sh"
    # Marketplace standard installed location
    "${HOME}/.claude/plugins/majestic-tools/skills/config-reader/scripts/config_reader.sh"
  )

  for path in "${paths[@]}"; do
    [[ -f "$path" ]] && echo "$path" && return 0
  done

  echo "ERROR: config_reader.sh not found. Install majestic-tools plugin." >&2
  echo "Tried paths:" >&2
  for path in "${paths[@]}"; do
    echo "  - $path" >&2
  done
  return 1
}

TOOLS_CONFIG=$(find_config_reader) || exit 1
source "$TOOLS_CONFIG"
