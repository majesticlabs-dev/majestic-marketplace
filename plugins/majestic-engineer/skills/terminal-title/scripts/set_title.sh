#!/usr/bin/env bash
# set_title.sh - Set terminal window title
#
# Usage:
#   set_title.sh "Your Title Here"
#   set_title.sh "🔨 #42: Add auth" "build-task"  # With optional context tag
#
# Environment:
#   CLAUDE_TITLE_PREFIX - Optional prefix (e.g., "🤖 Claude")
#
# How it works:
#   1. Stores title in ~/.claude/terminal_title (for shell hooks)
#   2. Emits ANSI escape sequence (works in Ghostty, iTerm2, xterm, etc.)

set -euo pipefail

# Exit silently if no title provided
if [[ -z "${1:-}" ]]; then
  exit 0
fi

# Sanitize input: remove control characters, limit to 80 chars
TITLE=$(echo "$1" | tr -d '\000-\037' | head -c 80)

# Exit if empty after sanitization
if [[ -z "$TITLE" ]]; then
  exit 0
fi

# Build final title with optional prefix
if [[ -n "${CLAUDE_TITLE_PREFIX:-}" ]]; then
  PREFIX=$(echo "$CLAUDE_TITLE_PREFIX" | tr -d '\000-\037' | head -c 40)
  if [[ -n "$PREFIX" ]]; then
    FINAL_TITLE="${PREFIX} | ${TITLE}"
  else
    FINAL_TITLE="${TITLE}"
  fi
else
  FINAL_TITLE="${TITLE}"
fi

# Store in file for shell hooks (atomic write)
TITLE_FILE="${HOME}/.claude/terminal_title"
mkdir -p "${HOME}/.claude"
TEMP_FILE="${TITLE_FILE}.tmp.$$"
echo "$FINAL_TITLE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$TITLE_FILE" 2>/dev/null || rm -f "$TEMP_FILE"

# Emit ANSI escape sequence to set terminal title
# Works in: Ghostty, iTerm2, Terminal.app, xterm, Alacritty, etc.
echo -ne "\033]0;${FINAL_TITLE}\007"
