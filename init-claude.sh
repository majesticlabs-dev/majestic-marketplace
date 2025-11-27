#!/bin/bash
# Majestic Project CLAUDE.md Initializer
# Usage: curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/init-claude.sh | bash

set -e

REPO_RAW="https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master"
CLAUDE_MD="./CLAUDE.md"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║   Majestic CLAUDE.md Initializer       ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
  echo ""
}

main() {
  print_header

  local instructions=(
    "critical-thinking:Challenge assumptions and prioritize accuracy"
    "anti-overengineering:YAGNI, KISS, avoid unnecessary complexity"
    "analyze-vs-implement:Distinguish suggestion from action"
    "investigation-first:Understand before proposing solutions"
  )

  echo "Available instruction modules:"
  echo ""

  local i=1
  for item in "${instructions[@]}"; do
    local name="${item%%:*}"
    local desc="${item##*:}"
    echo "  $i) $name - $desc"
    ((i++))
  done
  echo "  a) Install all"
  echo "  0) Cancel"
  echo ""

  read -p "Select modules (comma-separated, e.g., 1,2,4 or 'a' for all): " choices

  if [ "$choices" = "0" ]; then
    echo "Cancelled."
    exit 0
  fi

  # Handle existing CLAUDE.md
  if [ -f "$CLAUDE_MD" ]; then
    echo ""
    echo "CLAUDE.md already exists. Options:"
    echo "  1) Append (add to existing)"
    echo "  2) Replace (backup to CLAUDE.md.bak)"
    echo "  3) Cancel"
    read -p "Choice: " existing_choice

    case $existing_choice in
      1) ;; # append - continue
      2) cp "$CLAUDE_MD" "${CLAUDE_MD}.bak" && echo "" > "$CLAUDE_MD" ;;
      *) echo "Cancelled."; exit 0 ;;
    esac
  fi

  # Determine which modules to install
  local selected=()
  if [ "$choices" = "a" ] || [ "$choices" = "A" ]; then
    selected=("critical-thinking" "anti-overengineering" "analyze-vs-implement" "investigation-first")
  else
    IFS=',' read -ra nums <<< "$choices"
    local names=("critical-thinking" "anti-overengineering" "analyze-vs-implement" "investigation-first")
    for num in "${nums[@]}"; do
      num=$(echo "$num" | tr -d ' ')
      if [[ "$num" =~ ^[1-4]$ ]]; then
        selected+=("${names[$((num-1))]}")
      fi
    done
  fi

  if [ ${#selected[@]} -eq 0 ]; then
    echo -e "${RED}No valid modules selected.${NC}"
    exit 1
  fi

  # Add header if new file
  if [ ! -f "$CLAUDE_MD" ] || [ ! -s "$CLAUDE_MD" ]; then
    echo "# Project Guidelines" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
  fi

  # Fetch and append selected modules
  for module in "${selected[@]}"; do
    echo "  Adding: $module"
    curl -fsSL "$REPO_RAW/instructions/$module.md" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
  done

  echo ""
  echo -e "${GREEN}✓ CLAUDE.md updated in current directory${NC}"
  echo ""
  echo "Commit this file to share with your team:"
  echo "  git add CLAUDE.md && git commit -m 'Add Claude Code guidelines'"
}

main
