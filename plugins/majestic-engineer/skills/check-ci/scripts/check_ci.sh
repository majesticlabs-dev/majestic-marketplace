#!/usr/bin/env bash
set -euo pipefail

# Auto-detect PR number if not provided
if [[ -z "${1:-}" ]]; then
  PR=$(gh pr view --json number -q .number 2>/dev/null || echo "")
  if [[ -z "$PR" ]]; then
    echo "❌ No PR found for current branch and no PR number provided"
    exit 1
  fi
else
  PR="$1"
fi
INTERVAL="${2:-15}"   # seconds
TIMEOUT="${3:-600}"   # seconds
START=$(date +%s)

# Auto-detect repository owner and name if not provided
if [[ -z "${OWNER:-}" ]] || [[ -z "${REPO:-}" ]]; then
  REPO_INFO=$(gh repo view --json owner,name -q '.owner.login + "/" + .name')
  OWNER=$(echo "$REPO_INFO" | cut -d'/' -f1)
  REPO=$(echo "$REPO_INFO" | cut -d'/' -f2)
fi

echo "↪️  Polling PR #$PR every $INTERVAL s for $TIMEOUT s max"

while :; do
  # We use `|| true` so that `gh`'s non-zero exit code on pending or
  # failed checks doesn't trigger `set -e` and kill the script.
  CHECKS_OUTPUT=$(gh pr checks "$PR" --repo "$OWNER/$REPO" 2>&1 || true)

  if echo "$CHECKS_OUTPUT" | grep -E "fail|failure|error" -q; then
    echo "❌ PR #$PR is red"
    echo "$CHECKS_OUTPUT"
    exit 1
  elif echo "$CHECKS_OUTPUT" | grep "pending" -q; then
    echo "• $(date +"%H:%M:%S") → pending"
  elif ! echo "$CHECKS_OUTPUT" | grep -E "fail|failure|error|pending|skipping" -q; then
    # If there are no failing, pending, or skipping checks, we can assume success.
    # This is more robust than just checking for "pass", as some CIs might
    # not report a passing state explicitly if all jobs are neutral/successful.
    echo "✅ PR #$PR is green"
    echo "$CHECKS_OUTPUT"
    exit 0
  else
    # This state means there are no failures and no pending, but some are
    # skipping or in another state. We wait.
    echo "• $(date +"%H:%M:%S") → waiting for checks to complete"
  fi

  (( $(date +%s) - START > TIMEOUT )) && {
    echo "⏰ PR #$PR timed out"
    echo "$CHECKS_OUTPUT"
    exit 2
  }

  sleep "$INTERVAL"
done
