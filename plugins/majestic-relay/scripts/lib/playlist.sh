#!/bin/bash
#
# playlist.sh - Playlist helper functions
#
# Functions for reading/writing .agents-os/relay/playlist.yml
#

PLAYLIST="${PLAYLIST:-.agents-os/relay/playlist.yml}"

# Colors
PLAYLIST_RED='\033[0;31m'
PLAYLIST_GREEN='\033[0;32m'
PLAYLIST_YELLOW='\033[0;33m'
PLAYLIST_BLUE='\033[0;34m'
PLAYLIST_CYAN='\033[0;36m'
PLAYLIST_BOLD='\033[1m'
PLAYLIST_NC='\033[0m' # No Color

# Announcement box
# Usage: playlist_announce "icon" "title" "subtitle"
playlist_announce() {
  local icon="$1"
  local title="$2"
  local subtitle="${3:-}"

  local width=65

  echo ""
  echo -e "${PLAYLIST_CYAN}╔$(printf '%*s' "$width" | tr ' ' '═')╗${PLAYLIST_NC}"
  printf "${PLAYLIST_CYAN}║${PLAYLIST_NC}  ${PLAYLIST_BOLD}%s %-$((width - 4))s${PLAYLIST_NC}${PLAYLIST_CYAN}║${PLAYLIST_NC}\n" "$icon" "$title"
  if [[ -n "$subtitle" ]]; then
    printf "${PLAYLIST_CYAN}║${PLAYLIST_NC}  %-$((width - 2))s${PLAYLIST_CYAN}║${PLAYLIST_NC}\n" "$subtitle"
  fi
  echo -e "${PLAYLIST_CYAN}╚$(printf '%*s' "$width" | tr ' ' '═')╝${PLAYLIST_NC}"
  echo ""
}

# Get playlist field
# Usage: playlist_get "field.path" "default"
playlist_get() {
  local key="$1"
  local default="${2:-}"

  local value
  value=$(yq -r ".${key} // \"${default}\"" "$PLAYLIST" 2>/dev/null)

  if [[ "$value" == "null" || -z "$value" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Set playlist field
# Usage: playlist_set "field.path" "value"
playlist_set() {
  local key="$1"
  local value="$2"

  yq -i ".${key} = \"${value}\"" "$PLAYLIST"
}

# Set playlist field (numeric)
# Usage: playlist_set_num "field.path" 123
playlist_set_num() {
  local key="$1"
  local value="$2"

  yq -i ".${key} = ${value}" "$PLAYLIST"
}

# Get epic count
# Usage: playlist_epic_count
playlist_epic_count() {
  yq -r '.epics | length' "$PLAYLIST" 2>/dev/null || echo "0"
}

# Get epic file at index
# Usage: playlist_get_epic_file 0
playlist_get_epic_file() {
  local index="$1"

  yq -r ".epics[${index}].file // \"\"" "$PLAYLIST" 2>/dev/null
}

# Get epic status at index
# Usage: playlist_get_epic_status 0
playlist_get_epic_status() {
  local index="$1"

  yq -r ".epics[${index}].status // \"pending\"" "$PLAYLIST" 2>/dev/null
}

# Set epic status
# Usage: playlist_set_epic_status 0 "in_progress"
playlist_set_epic_status() {
  local index="$1"
  local status="$2"

  yq -i ".epics[${index}].status = \"${status}\"" "$PLAYLIST"
}

# Set epic timestamp
# Usage: playlist_set_epic_timestamp 0 "started_at" "2024-01-15T10:00:00Z"
playlist_set_epic_timestamp() {
  local index="$1"
  local field="$2"
  local timestamp="$3"

  yq -i ".epics[${index}].${field} = \"${timestamp}\"" "$PLAYLIST"
}

# Count completed epics
# Usage: playlist_count_completed
playlist_count_completed() {
  yq -r '[.epics[] | select(.status == "completed")] | length' "$PLAYLIST" 2>/dev/null || echo "0"
}

# Mark playlist started
# Usage: playlist_mark_started
playlist_mark_started() {
  local started_at
  started_at=$(date -Iseconds)

  yq -i ".status = \"in_progress\"" "$PLAYLIST"
  yq -i ".started_at = \"${started_at}\"" "$PLAYLIST"
}

# Mark playlist completed
# Usage: playlist_mark_completed
playlist_mark_completed() {
  local ended_at
  ended_at=$(date -Iseconds)

  yq -i ".status = \"completed\"" "$PLAYLIST"
  yq -i ".ended_at = \"${ended_at}\"" "$PLAYLIST"

  # Calculate duration
  local started_at
  started_at=$(playlist_get "started_at" "")

  if [[ -n "$started_at" ]]; then
    local start_epoch end_epoch duration_minutes
    start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${started_at%[-+]*}" "+%s" 2>/dev/null || date -d "$started_at" "+%s" 2>/dev/null)
    end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${ended_at%[-+]*}" "+%s" 2>/dev/null || date -d "$ended_at" "+%s" 2>/dev/null)

    if [[ -n "$start_epoch" && -n "$end_epoch" ]]; then
      duration_minutes=$(( (end_epoch - start_epoch) / 60 ))
      yq -i ".duration_minutes = ${duration_minutes}" "$PLAYLIST"
    fi
  fi
}

# Mark playlist failed
# Usage: playlist_mark_failed
playlist_mark_failed() {
  yq -i ".status = \"failed\"" "$PLAYLIST"
}

# Initialize fresh ledger for an epic
# Usage: init_fresh_ledger "epic_path"
init_fresh_ledger() {
  local epic_path="$1"
  local ledger=".agents-os/relay/attempt-ledger.yml"

  # Get epic info
  local epic_id
  epic_id=$(yq -r '.id // "unknown"' "$epic_path")

  # Get all task IDs from epic
  local task_status_yaml
  task_status_yaml=$(yq -r '.tasks | keys | .[] | . + ": pending"' "$epic_path" | sed 's/^/  /')

  local started_at
  started_at=$(date -Iseconds)

  cat > "$ledger" <<EOF
version: 1
epic_id: "${epic_id}"
started_at: "${started_at}"
ended_at: null
duration_minutes: null

settings:
  max_attempts_per_task: 3
  timeout_minutes: 15

task_status:
${task_status_yaml}

attempts: {}

gated_tasks: {}

relay_status:
  state: idle
  pid: null
  started_at: null
  stopped_at: null
  last_exit_code: null
  last_exit_reason: null
EOF
}
