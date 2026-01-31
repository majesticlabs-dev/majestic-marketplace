#!/bin/bash
#
# config.sh - Config reader for relay scripts
#
# Sources the canonical config reader from majestic-engineer.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINEER_CONFIG="${SCRIPT_DIR}/../../../skills/config-reader/scripts/config_reader.sh"

if [[ -f "$ENGINEER_CONFIG" ]]; then
  source "$ENGINEER_CONFIG"
else
  echo "ERROR: config_reader.sh not found at $ENGINEER_CONFIG" >&2
  exit 1
fi
