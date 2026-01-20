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

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Box drawing characters
BOX_TL='╔'
BOX_TR='╗'
BOX_BL='╚'
BOX_BR='╝'
BOX_H='═'
BOX_V='║'

# File paths
PLAYLIST="${1:-.agents-os/relay/playlist.yml}"
RELAY_DIR=$(dirname "$PLAYLIST")
EPICS_DIR="$RELAY_DIR/epics"
EPIC_SYMLINK="$RELAY_DIR/epic.yml"

# Announcement box
# Usage: announce "icon" "title" "subtitle"
announce() {
  local icon="$1"
  local title="$2"
  local subtitle="${3:-}"

  local width=65
  local padding=$((width - 4))

  echo ""
  echo -e "${CYAN}${BOX_TL}$(printf '%*s' "$width" | tr ' ' "$BOX_H")${BOX_TR}${NC}"
  printf "${CYAN}${BOX_V}${NC}  ${BOLD}%s %-*s${NC}${CYAN}${BOX_V}${NC}\n" "$icon" "$padding" "$title"
  if [[ -n "$subtitle" ]]; then
    printf "${CYAN}${BOX_V}${NC}  %-*s${CYAN}${BOX_V}${NC}\n" "$((width - 2))" "$subtitle"
  fi
  echo -e "${CYAN}${BOX_BL}$(printf '%*s' "$width" | tr ' ' "$BOX_H")${BOX_BR}${NC}"
  echo ""
}

# Check prerequisites
if [[ ! -f "$PLAYLIST" ]]; then
  echo -e "${RED}Error: Playlist not found at $PLAYLIST${NC}" >&2
  echo "Run '/relay:init-playlist' to create one." >&2
  exit 1
fi

if [[ ! -d "$EPICS_DIR" ]]; then
  echo -e "${RED}Error: Epics folder not found at $EPICS_DIR${NC}" >&2
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
    echo -e "${RED}Error: Epic not found: $epic_path${NC}" >&2
    exit 1
  fi
done

# Resume check
if [[ "$CURRENT" -gt 0 && "$STATUS" != "completed" ]]; then
  echo -e "${YELLOW}Resuming playlist from epic $((CURRENT + 1))/${EPIC_COUNT}${NC}"
fi

# Mark playlist started (if not already)
if [[ "$STATUS" == "pending" ]]; then
  playlist_mark_started
fi

echo -e "${BLUE}🚀 Starting playlist: ${PLAYLIST_NAME}${NC}"
echo -e "   Epics: ${EPIC_COUNT}"
echo -e "   Starting at: $((CURRENT + 1))"
echo ""

# Cleanup handler
cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo -e "${YELLOW}Playlist interrupted. Progress saved to $PLAYLIST${NC}"
  fi
}
trap cleanup EXIT INT TERM

# Main execution loop
for ((i=CURRENT; i<EPIC_COUNT; i++)); do
  epic_file=$(playlist_get_epic_file "$i")
  epic_path="$EPICS_DIR/$epic_file"

  # ═══════════════════════════════════════════
  # ANNOUNCE: Epic Starting
  # ═══════════════════════════════════════════
  announce "🎬 EPIC STARTED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

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
    # ═══════════════════════════════════════════
    # ANNOUNCE: Epic Completed
    # ═══════════════════════════════════════════
    announce "✅ EPIC COMPLETED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

    playlist_set_epic_status "$i" "completed"
    playlist_set_epic_timestamp "$i" "completed_at" "$(date -Iseconds)"
    playlist_set_num "current" "$((i + 1))"

  else
    # ═══════════════════════════════════════════
    # ANNOUNCE: Epic Failed
    # ═══════════════════════════════════════════
    announce "❌ EPIC FAILED" "$((i + 1))/${EPIC_COUNT}: $epic_file"

    playlist_set_epic_status "$i" "failed"
    playlist_set_epic_timestamp "$i" "failed_at" "$(date -Iseconds)"
    playlist_mark_failed

    echo -e "${RED}Playlist stopped. Completed: ${i}/${EPIC_COUNT}${NC}"
    echo ""
    echo "To resume after fixing:"
    echo "  1. Fix the failing epic or run '/relay:work' to retry"
    echo "  2. Run '/relay:run-playlist' to continue"
    exit 1
  fi
done

# ═══════════════════════════════════════════
# ANNOUNCE: Playlist Complete
# ═══════════════════════════════════════════
playlist_mark_completed
DURATION=$(playlist_get "duration_minutes" "?")

announce "🎉 PLAYLIST COMPLETED" "$PLAYLIST_NAME"

echo -e "${GREEN}📊 Summary:${NC}"
echo -e "   Epics completed: ${EPIC_COUNT}"
echo -e "   Duration: ${DURATION} minutes"
echo ""
