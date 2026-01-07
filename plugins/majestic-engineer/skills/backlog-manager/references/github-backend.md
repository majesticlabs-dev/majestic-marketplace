# GitHub Issues Backend Reference

This reference covers using GitHub Issues as the backlog system via the `gh` CLI.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated: `gh auth status`
- Repository must have Issues enabled
- Must be in a git repository with GitHub remote

## Configuration

In your project's `.agents.yml`:

```yaml
task_management: github
workflow_labels:                     # Issue workflow states
  - backlog
  - in-progress
  - ready-for-review
  - done
```

## Operations

### BEFORE Any Label Operations

**Always validate labels exist before using them:**
```bash
# Get list of existing labels in repository
gh label list --json name --jq '.[].name'

# Check if specific label exists
gh label list --json name --jq '.[].name' | grep -q "^backlog$" && echo "exists" || echo "missing"
```

**Only use labels that exist.** If a configured label doesn't exist:
1. Skip that label (create issue without it), OR
2. Create the label first (see "Setup labels" section below)

**Never attempt to use non-existent labels** - the `gh issue create` command will fail.

### CREATE - New Issue

**Basic (after validating label exists):**
```bash
gh issue create \
  --title "Brief description" \
  --body "Problem statement and acceptance criteria" \
  --label "backlog"
```

**With full template:**
```bash
gh issue create \
  --title "[P1] Fix N+1 query in dashboard" \
  --body "$(cat <<'EOF'
## Problem Statement

[What is broken or needs improvement]

## Definition of Done

| Item | Verification |
|------|--------------|
| [Feature behavior 1] | [command or manual] |
| [Feature behavior 2] | [command or manual] |

## Priority

P1 - Critical
EOF
)" \
  --label "backlog,p1"
```

**With milestone:**
```bash
gh issue create --title "..." --body "..." --milestone "Sprint 1"
```

### LIST - Query Issues

```bash
# All backlog items
gh issue list --label "backlog" --state open

# High priority only
gh issue list --label "p1" --state open

# Assigned to me
gh issue list --assignee @me --state open

# By milestone
gh issue list --milestone "Sprint 1"

# JSON output for parsing
gh issue list --label "backlog" --json number,title,labels,state
```

### VIEW - Read Issue Details

```bash
# View in terminal
gh issue view 123

# Open in browser
gh issue view 123 --web

# Get specific fields
gh issue view 123 --json title,body,labels,assignees
```

### UPDATE - Modify Issue

**Labels (priority/status):**
```bash
# Add label
gh issue edit 123 --add-label "ready"

# Remove label
gh issue edit 123 --remove-label "pending"

# Change priority
gh issue edit 123 --add-label "p2" --remove-label "p1"
```

**Assignment:**
```bash
gh issue edit 123 --add-assignee @username
gh issue edit 123 --remove-assignee @username
```

**Milestone:**
```bash
gh issue edit 123 --milestone "Sprint 2"
```

**Add work log (comment):**
```bash
gh issue comment 123 --body "$(cat <<'EOF'
## Work Log - 2024-01-15

**Actions:**
- Fixed N+1 query in `app/models/user.rb:42`
- Added eager loading for associations

**Status:** In progress
EOF
)"
```

### COMPLETE - Close Issue

```bash
# Close with comment
gh issue close 123 --comment "Completed: Fixed N+1 query, tests passing"

# Just close
gh issue close 123
```

## Label Conventions

Recommended label scheme matching file-based priorities:

| Label | Meaning | File Equivalent |
|-------|---------|-----------------|
| `p1` | Critical | p1 |
| `p2` | Important | p2 |
| `p3` | Nice-to-have | p3 |
| `backlog` | In backlog | Any status |
| `pending` | Needs triage | pending |
| `ready` | Approved/ready | ready |

### Setup Labels (One-Time)

**Before first use, check and create any missing labels:**
```bash
# List existing labels
gh label list --json name --jq '.[].name'

# Create only if missing (safe to run - errors if exists, no harm)
gh label create backlog --color 0000FF --description "Backlog item" 2>/dev/null || true
gh label create p1 --color FF0000 --description "Critical priority" 2>/dev/null || true
gh label create p2 --color FFA500 --description "Important priority" 2>/dev/null || true
gh label create p3 --color 00FF00 --description "Nice-to-have" 2>/dev/null || true
gh label create pending --color FFFF00 --description "Needs triage" 2>/dev/null || true
gh label create ready --color 00FFFF --description "Ready for work" 2>/dev/null || true
```

### Validate Before Use

**IMPORTANT:** Always verify labels exist before using `--label` flag:
```bash
# Get available labels as comma-separated (for scripting)
LABELS=$(gh label list --json name --jq '.[].name' | tr '\n' ',' | sed 's/,$//')
echo "Available: $LABELS"
```

If a label doesn't exist and you don't want to create it, simply omit the `--label` flag from your command.

## GitHub-Specific Features

### Milestones (Sprint Planning)

```bash
# Create milestone
gh api repos/{owner}/{repo}/milestones --method POST -f title="Sprint 1" -f due_on="2024-02-01T00:00:00Z"

# List milestones
gh api repos/{owner}/{repo}/milestones --jq '.[].title'

# Assign issue to milestone
gh issue edit 123 --milestone "Sprint 1"

# View milestone issues
gh issue list --milestone "Sprint 1"
```

### Project Boards

```bash
# Add issue to project
gh project item-add PROJECT_NUMBER --owner OWNER --url ISSUE_URL

# List project items
gh project item-list PROJECT_NUMBER --owner OWNER
```

### Dependencies (via issue links)

GitHub doesn't have native dependencies. Use issue references in body:

```markdown
## Dependencies

Blocked by:
- #101 - Database migration
- #102 - API endpoint

Blocks:
- #105 - Frontend integration
```

## Mapping to File-Based Workflow

| File Operation | GitHub Equivalent |
|----------------|-------------------|
| Create pending item | `gh issue create --label backlog,pending` |
| Triage (approve) | `gh issue edit --remove-label pending --add-label ready` |
| Mark complete | `gh issue close` |
| Add work log | `gh issue comment` |
| Check dependencies | Search issue body for `#` references |

## Quick Reference

```bash
# Create backlog item
gh issue create --title "..." --body "..." --label backlog

# List ready work
gh issue list --label ready --state open

# Triage: pending → ready
gh issue edit 123 --remove-label pending --add-label ready

# Complete
gh issue close 123 --comment "Done: [summary]"
```
