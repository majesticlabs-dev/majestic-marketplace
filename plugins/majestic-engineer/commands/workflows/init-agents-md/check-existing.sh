#!/bin/bash
# Check for existing AGENTS.md and CLAUDE.md files
# Usage: check-existing.sh [agents|claude|all]
# Returns: file paths and status

set -euo pipefail

check_agents() {
  echo "=== AGENTS.md Files ==="
  find . -name "AGENTS.md" -type f \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/vendor/*' \
    2>/dev/null || true

  if [ -f AGENTS.md ]; then
    echo ""
    echo "=== Root AGENTS.md ==="
    echo "Lines: $(wc -l < AGENTS.md)"
  fi
}

check_claude() {
  echo "=== CLAUDE.md Status ==="
  if [ -L CLAUDE.md ]; then
    echo "Symlink: $(ls -la CLAUDE.md)"
  elif [ -f CLAUDE.md ]; then
    echo "File exists (not a symlink)"
    echo "Lines: $(wc -l < CLAUDE.md)"
  else
    echo "Does not exist"
  fi
}

case "${1:-all}" in
  agents) check_agents ;;
  claude) check_claude ;;
  all)
    check_agents
    echo ""
    check_claude
    ;;
  *)
    echo "Usage: $0 [agents|claude|all]" >&2
    exit 1
    ;;
esac
