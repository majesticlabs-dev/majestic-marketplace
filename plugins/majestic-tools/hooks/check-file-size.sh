#!/bin/bash
# File size validation hook for Claude Code
# Checks if code files exceed the configured line limit after Write/Edit/MultiEdit operations
#
# Environment variables:
#   CODE_FILE_SIZE_LIMIT      - Line limit (default: 200)
#   CODE_FILE_SIZE_EXTENSIONS - Pipe-separated extensions to check
#                               (default: ts|js|py|go|rs|java|cpp|c|cs|php|rb|swift|kt|scala|clj|hs|elm|dart|vue|svelte|jsx|tsx)

# Extract file path from tool input JSON
file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit silently if no file path or file doesn't exist
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

# Get file extension
ext="${file_path##*.}"

# Define extensions to always ignore
ignored_extensions="md|txt|csv|json|yaml|yml|xml|html|css|scss|sass|less|log|env|gitignore|gitattributes|dockerignore|editorconfig|prettierrc|eslintrc|LICENSE|README"

# Check if current file extension should be ignored
if echo "$ext" | grep -qE "^($ignored_extensions)$"; then
  exit 0
fi

# Get extensions to check from environment variable or use default
extensions=${CODE_FILE_SIZE_EXTENSIONS:-"ts|js|py|go|rs|java|cpp|c|cs|php|rb|swift|kt|scala|clj|hs|elm|dart|vue|svelte|jsx|tsx"}

# Check if current file extension matches any of the configured extensions
if echo "$ext" | grep -qE "^($extensions)$"; then
  # Count lines in the file
  line_count=$(wc -l < "$file_path" 2>/dev/null || echo "0")

  # Get limit from environment variable or use default
  limit=${CODE_FILE_SIZE_LIMIT:-200}

  # Check if file exceeds limit
  if [ "$line_count" -gt "$limit" ]; then
    echo ""
    echo "WARNING: File size exceeded limit!"
    echo "File: $file_path"
    echo "Lines: $line_count (limit: $limit)"
    echo "Consider breaking this file into smaller modules for better maintainability."
    echo ""
  fi
else
  # Non-monitored file extension, exit silently
  exit 0
fi
