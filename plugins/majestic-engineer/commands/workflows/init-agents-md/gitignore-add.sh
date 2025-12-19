#!/bin/bash
# Add entries to .gitignore idempotently
# Usage: gitignore-add.sh <entry> [entry2] [entry3] ...
# Example: gitignore-add.sh .agents.yml .agents.local.yml

set -euo pipefail

[ $# -eq 0 ] && { echo "Usage: $0 <entry> [entry2] ..." >&2; exit 1; }

for entry in "$@"; do
  # Escape dots for grep pattern
  pattern=$(echo "$entry" | sed 's/\./\\./g')

  if [ ! -f .gitignore ]; then
    echo "$entry" > .gitignore
    echo "Created .gitignore with: $entry"
  elif ! grep -q "^${pattern}$" .gitignore; then
    echo "$entry" >> .gitignore
    echo "Added to .gitignore: $entry"
  else
    echo "Already in .gitignore: $entry"
  fi
done
