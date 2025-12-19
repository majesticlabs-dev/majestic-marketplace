#!/bin/bash
# Detect tech stack from project files
# Usage: detect-tech-stack.sh [stack|framework|all]
# Returns: detected values

set -euo pipefail

detect_stack() {
  [ -f Gemfile ] && echo "rails" && return
  [ -f pyproject.toml ] || [ -f requirements.txt ] && echo "python" && return
  [ -f package.json ] && echo "node" && return
  echo "generic"
}

detect_python_framework() {
  local files="pyproject.toml requirements.txt"
  for f in $files; do
    [ -f "$f" ] || continue
    grep -qi "fastapi" "$f" 2>/dev/null && echo "fastapi" && return
    grep -qi "django" "$f" 2>/dev/null && echo "django" && return
    grep -qi "flask" "$f" 2>/dev/null && echo "flask" && return
  done
  echo "none"
}

detect_node_framework() {
  [ -f package.json ] || { echo "none"; return; }
  grep -q '"next"' package.json 2>/dev/null && echo "nextjs" && return
  grep -q '"nuxt"' package.json 2>/dev/null && echo "nuxt" && return
  grep -q '"vue"' package.json 2>/dev/null && echo "vue" && return
  grep -q '"svelte"' package.json 2>/dev/null && echo "svelte" && return
  grep -q '"express"' package.json 2>/dev/null && echo "express" && return
  grep -q '"fastify"' package.json 2>/dev/null && echo "fastify" && return
  grep -q '"react"' package.json 2>/dev/null && echo "react" && return
  echo "none"
}

detect_typescript() {
  [ -f tsconfig.json ] && echo "true" || echo "false"
}

case "${1:-all}" in
  stack)      detect_stack ;;
  python-fw)  detect_python_framework ;;
  node-fw)    detect_node_framework ;;
  typescript) detect_typescript ;;
  all)
    echo "stack=$(detect_stack)"
    echo "python_framework=$(detect_python_framework)"
    echo "node_framework=$(detect_node_framework)"
    echo "typescript=$(detect_typescript)"
    ;;
  *)
    echo "Usage: $0 [stack|python-fw|node-fw|typescript|all]" >&2
    exit 1
    ;;
esac
