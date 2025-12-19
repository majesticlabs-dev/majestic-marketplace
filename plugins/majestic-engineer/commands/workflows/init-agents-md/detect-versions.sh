#!/bin/bash
# Detect language/framework versions from project files
# Usage: detect-versions.sh [ruby|rails|python|node|all]

set -euo pipefail

detect_ruby() {
  grep -E "^ruby" Gemfile 2>/dev/null | sed 's/ruby "\([^"]*\)".*/\1/' | head -1
}

detect_rails() {
  grep -E "gem ['\"]rails['\"]" Gemfile 2>/dev/null | sed "s/.*['\"]~> \([0-9.]*\)['\"].*/\1/" | head -1
}

detect_python() {
  # Try pyproject.toml first
  if [ -f pyproject.toml ]; then
    grep -E "^python\s*=" pyproject.toml 2>/dev/null | sed 's/.*"\([0-9.]*\)".*/\1/' | head -1 && return
    grep -E "requires-python" pyproject.toml 2>/dev/null | sed 's/.*>=\([0-9.]*\).*/\1/' | head -1 && return
  fi
  # Fallback to .python-version
  [ -f .python-version ] && cat .python-version | head -1
}

detect_node() {
  # Try .nvmrc first
  [ -f .nvmrc ] && cat .nvmrc | head -1 && return
  # Try .node-version
  [ -f .node-version ] && cat .node-version | head -1 && return
  # Fallback to current node
  node -v 2>/dev/null | sed 's/v//'
}

case "${1:-all}" in
  ruby)   detect_ruby ;;
  rails)  detect_rails ;;
  python) detect_python ;;
  node)   detect_node ;;
  all)
    echo "ruby=$(detect_ruby)"
    echo "rails=$(detect_rails)"
    echo "python=$(detect_python)"
    echo "node=$(detect_node)"
    ;;
  *)
    echo "Usage: $0 [ruby|rails|python|node|all]" >&2
    exit 1
    ;;
esac
