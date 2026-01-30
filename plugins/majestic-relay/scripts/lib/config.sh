#!/bin/bash
#
# config.sh - Redirect to canonical config reader
#
# All config reading consolidated in majestic-engineer.
# This file sources the canonical implementation for backwards compatibility.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINEER_CONFIG="${SCRIPT_DIR}/../../../majestic-engineer/skills/config-reader/scripts/config_reader.sh"

if [[ -f "$ENGINEER_CONFIG" ]]; then
  source "$ENGINEER_CONFIG"
else
  echo "ERROR: config_reader.sh not found at $ENGINEER_CONFIG" >&2
  exit 1
fi
