#!/bin/bash
# Detect default branch for the repository
# Usage: detect-branch.sh
# Returns: branch name (defaults to "main")

set -euo pipefail

# Try remote HEAD first
branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
[ -n "$branch" ] && echo "$branch" && exit 0

# Fallback: check for main
git show-ref --verify refs/heads/main &>/dev/null && echo "main" && exit 0

# Fallback: check for master
git show-ref --verify refs/heads/master &>/dev/null && echo "master" && exit 0

# Default
echo "main"
