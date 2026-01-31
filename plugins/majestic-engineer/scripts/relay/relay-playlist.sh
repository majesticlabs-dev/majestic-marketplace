#!/bin/bash
#
# relay-playlist.sh - Multi-epic playlist orchestrator
#
# Executes multiple epics sequentially with fail-fast behavior.
# Uses symlinks to point epic.yml to current epic in epics/ folder.
#
# Usage:
#   relay-playlist.sh [playlist.yml]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/playlist.sh"

# File paths
PLAYLIST="${1:-.agents-os/relay/playlist.yml}"
RELAY_DIR=$(dirname "$PLAYLIST")
EPICS_DIR="$RELAY_DIR/epics"
EPIC_SYMLINK="$RELAY_DIR/epic.yml"

# Check prerequisites
if [[ ! -f "$PLAYLIST" ]]; then
  echo -e "${PLAYLIST_RED}Error: Playlist not found at $PLAYLIST${PLAYLIST_NC}" >&2
  echo "Run '/majestic-engineer:relay:init-playlist' to create one." >&2
  exit 1
fi

if [[ ! -d "$EPICS_DIR" ]]; then
  echo -e "${PLAYLIST_RED}Error: Epics folder not found at $EPICS_DIR${PLAYLIST_NC}" >&2
  exit 1
fi

# Load playlist info
PLAYLIST_NAME=$(playlist_get "name" "Unnamed Playlist")
EPIC_COUNT=$(playlist_epic_count)
CURRENT=$(playlist_get "current" "0")
STATUS=$(playlist_get "status" "pending")

# Validate all epics exist before starting
for ((i=0; i<EPIC_COUNT; i++)); do
  epic_file=$(playlist_get_epic_file "$i")
  epic_path="$EPICS_DIR/$epic_file"

  if [[ ! -f "$epic_path" ]]; then
    echo -e "${PLAYLIST_RED}Error: Epic not found: $epic_path${PLAYLIST_NC}" >&2
    exit 1
  fi
done

# Resume check
if [[ "$CURRENT" -gt 0 && "$STATUS" != "completed" ]]; then
  echo -e "${PLAYLIST_YELLOW}Resuming playlist from epic $((CURRENT + 1))/${EPIC_COUNT}${PLAYLIST_NC}"
fi

# Mark playlist started (if not already)
if [[ "$STATUS" == "pending" ]]; then
  playlist_mark_started
fi

echo -e "${PLAYLIST_BLUE}🚀 Starting playlist: ${PLAYLIST_NAME}${PLAYLIST_NC}"
echo -e "   Epics: ${EPIC_COUNT}"
echo -e "   Starting at: $((CURRENT + 1))"
echo ""

# Cleanup handler
cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo -e "${PLAYLIST_YELLOW}Playlist interrupted. Progress saved to $PLAYLIST${PLAYLIST_NC}"
  fi
}
trap cleanup EXIT INT TERM

# Main execution loop
for ((i=CURRENT; i<EPIC_COUNT; i++)); do
  epic_file=$(playlist_get_epic_file "$i")
  epic_path="$EPICS_DIR/$epic_file"

  # Announce: Epic Starting
  playlist_announce "🎬 EPIC STARTED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

  # Create/update symlink to current epic
  ln -sf "epics/$epic_file" "$EPIC_SYMLINK"

  # Initialize fresh ledger for this epic
  init_fresh_ledger "$epic_path"

  # Update playlist status
  playlist_set_num "current" "$i"
  playlist_set_epic_status "$i" "in_progress"
  playlist_set_epic_timestamp "$i" "started_at" "$(date -Iseconds)"

  # Execute epic via relay-work.sh
  EPIC_RESULT=0
  "$SCRIPT_DIR/relay-work.sh" || EPIC_RESULT=$?

  if [[ $EPIC_RESULT -eq 0 ]]; then
    # Announce: Epic Completed
    playlist_announce "✅ EPIC COMPLETED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

    playlist_set_epic_status "$i" "completed"
    playlist_set_epic_timestamp "$i" "completed_at" "$(date -Iseconds)"
    playlist_set_num "current" "$((i + 1))"

  else
    # Announce: Epic Failed
    playlist_announce "❌ EPIC FAILED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

    playlist_set_epic_status "$i" "failed"
    playlist_set_epic_timestamp "$i" "failed_at" "$(date -Iseconds)"
    playlist_mark_failed

    echo -e "${PLAYLIST_RED}Playlist stopped. Completed: ${i}/${EPIC_COUNT}${PLAYLIST_NC}"
    echo ""
    echo "To resume after fixing:"
    echo "  1. Fix the failing epic or run '/majestic-engineer:relay:work' to retry"
    echo "  2. Run '/majestic-engineer:relay:run-playlist' to continue"
    exit 1
  fi
done

# Announce: Playlist Complete
playlist_mark_completed
DURATION=$(playlist_get "duration_minutes" "?")

playlist_announce "🎉 PLAYLIST COMPLETED" "$PLAYLIST_NAME"

echo -e "${PLAYLIST_GREEN}📊 Summary:${PLAYLIST_NC}"
echo -e "   Epics completed: ${EPIC_COUNT}"
echo -e "   Duration: ${DURATION} minutes"
echo ""
