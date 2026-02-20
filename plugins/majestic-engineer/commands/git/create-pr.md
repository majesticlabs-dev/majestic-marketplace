---
name: create-pr
allowed-tools: Bash(git *), Bash(gh *), Task
description: Create a pull request for the current feature branch
model: haiku
disable-model-invocation: true
---

## Context

- Default branch: !`git remote show origin | grep 'HEAD branch' | awk '{print $NF}'`
- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Pending changes: !`git diff --stat`
- Commits for PR: !`DEFAULT=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}'); git log --oneline origin/${DEFAULT:-main}..HEAD 2>/dev/null || git log --oneline -10`

## Your Task

Create a pull request with a well-structured description based on commit analysis.

### Step 1: Validate State

- Check for uncommitted changes → commit first or warn user
- Verify branch differs from default branch
- Confirm commits exist between branches

### Step 2: Analyze Commits

Run: `git log --format="### %s%n%n%b%n---" origin/<default-branch>..HEAD` (use default branch from Context above)

For each commit, extract:
- **What** changed (from subject + diff)
- **Why** it changed (from body, or infer and mark as "Inferred:")

### Step 3: Push Branch

If no upstream: `git push -u origin <branch-name>`

### Step 4: Generate PR Description

Synthesize commits into structured sections:

```bash
gh pr create --title "<synthesized from most meaningful commit>" --body "$(cat <<'EOF'
## Summary
- [2-5 concrete bullets of high-level changes]
- [Focus on WHAT changed, not HOW]

## Why
[Motivation: reliability, security, performance, product need, or tech debt]

## Changes
[Per-commit breakdown if multiple commits, or detailed explanation if single]

### <Commit subject 1>
- **What:** [concrete change]
- **Why:** [motivation or "Inferred: likely reason"]

## Testing
- [ ] [Specific verification for this PR]
- [ ] [Edge cases to check]

## Risk & Rollout
- **Risk:** [Low/Medium/High] - [brief justification]
- **Rollback:** [How to revert if needed]
- **Monitoring:** [What to watch post-merge]

Closes #XXX
EOF
)"
```

### Section Guidelines

| Section | Required | Notes |
|---------|----------|-------|
| Summary | Yes | 2-5 bullets, concrete changes |
| Why | Yes | Connect to business/technical value |
| Changes | If >1 commit | Per-commit What/Why breakdown |
| Testing | Yes | Specific to this PR, not generic |
| Risk & Rollout | If non-trivial | Skip for tiny fixes |

### Uncertainty Flagging

When inferring motivation or impact:
- Prefix with "Inferred:" or "Likely:"
- Never invent details not in commits
- Preserve original commit subjects exactly

## Arguments

- `$ARGUMENTS` for context, title override, or issue linking
- Examples:
  - `/create-pr Fix R2 storage issue` - overrides title
  - `/create-pr closes #42` - adds issue link
  - `/create-pr` - auto-generates everything from commits

**Task linking:** Include `Closes #123` only if provided in arguments or found in commit messages.

## Expected Output

- Confirmation branch was pushed (if needed)
- Pull request URL
- Brief summary of sections generated
