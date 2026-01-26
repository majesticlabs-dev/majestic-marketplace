#!/bin/bash
# Verify /majestic:init setup is complete
# Usage: verify-setup.sh
# Returns: verification results with pass/fail indicators

set -euo pipefail

errors=0

echo "=== Verification Results ==="
echo ""

# Check root AGENTS.md
echo -n "Root AGENTS.md: "
if [ -f AGENTS.md ]; then
  lines=$(wc -l < AGENTS.md)
  if [ "$lines" -lt 200 ]; then
    echo "✓ exists ($lines lines)"
  else
    echo "⚠ exists but over 200 lines ($lines)"
  fi
else
  echo "✗ missing"
  ((++errors))
fi

# Check sub-folder AGENTS.md files
echo -n "Sub-folder AGENTS.md: "
count=$(find . -mindepth 2 -name "AGENTS.md" -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  2>/dev/null | wc -l | tr -d ' ')
if [ "$count" -gt 0 ]; then
  echo "✓ found $count file(s)"
else
  echo "○ none (may be OK for simple projects)"
fi

# Check .agents.yml
echo -n ".agents.yml: "
if [ -f .agents.yml ]; then
  echo "✓ exists"
else
  echo "✗ missing"
  ((++errors))
fi

# Check CLAUDE.md symlink
echo -n "CLAUDE.md symlink: "
if [ -L CLAUDE.md ]; then
  target=$(readlink CLAUDE.md)
  if [ "$target" = "AGENTS.md" ]; then
    echo "✓ points to AGENTS.md"
  else
    echo "⚠ points to $target"
  fi
elif [ -f CLAUDE.md ]; then
  echo "⚠ exists but not a symlink"
else
  echo "✗ missing"
  ((++errors))
fi

# Check .gitignore entries
echo -n ".claude/current_task.txt in .gitignore: "
if [ -f .gitignore ] && grep -q "^\.claude/current_task\.txt$" .gitignore; then
  echo "✓"
else
  echo "○ not found"
fi

echo ""
if [ "$errors" -eq 0 ]; then
  echo "=== Setup Complete ==="
else
  echo "=== $errors issue(s) found ==="
  # Exit 0 - script succeeded, issues are informational output
  # Exit 1 reserved for actual script failures
fi
