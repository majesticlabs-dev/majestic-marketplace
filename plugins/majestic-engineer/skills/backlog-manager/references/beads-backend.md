# Beads Backend Reference

This reference covers using beads (`bd`) as the backlog system - a dependency-aware issue tracker designed for AI-supervised workflows.

## Prerequisites

- beads CLI installed:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh | bash
  ```
- Project initialized: `bd init` (creates `.beads/` directory)
- Verify installation: `bd list`

## Configuration

In your project's CLAUDE.md:

```yaml
backend: beads
beads_prefix: myapp               # Optional: custom issue prefix (default: auto-detected)
```

## Status Mapping

| Beads Status | Backlog Manager Status | Meaning |
|--------------|------------------------|---------|
| `open` | pending | Needs triage/approval |
| `in_progress` | ready | Actively being worked on |
| `closed` | complete | Work finished |

## Priority Mapping

| Beads Priority | Backlog Manager Priority | Meaning |
|----------------|--------------------------|---------|
| 0 | p1 | Critical - highest priority |
| 1-2 | p2 | Important |
| 3-4 | p3 | Nice-to-have |

## Operations

### CREATE - New Issue

**Basic:**
```bash
bd create "Brief description"
```

**With priority and type:**
```bash
bd create "Fix N+1 query in dashboard" -p 0 -t bug
bd create "Add user authentication" -p 1 -t feature
```

**With description and assignee:**
```bash
bd create "Implement caching layer" \
  -d "Add Redis caching for API responses" \
  -p 1 \
  -t feature \
  --assignee alice
```

### LIST - Query Issues

```bash
# All issues
bd list

# By status
bd list --status open
bd list --status in_progress
bd list --status closed

# By priority (0=highest)
bd list --priority 0

# JSON output for programmatic parsing
bd list --json
```

### VIEW - Read Issue Details

```bash
bd show bd-1
```

### UPDATE - Modify Issue

**Status:**
```bash
bd update bd-1 --status in_progress
bd update bd-1 --status open
```

**Priority:**
```bash
bd update bd-1 --priority 0
```

**Assignee:**
```bash
bd update bd-1 --assignee bob
```

### COMPLETE - Close Issue

```bash
# Close with reason
bd close bd-1 --reason "Fixed in PR #42"

# Close multiple issues
bd close bd-2 bd-3 --reason "Resolved together"

# Just close
bd close bd-1
```

## Dependency Management (Key Feature)

Beads tracks dependencies between issues, preventing agents from duplicating effort.

### Add Dependencies

```bash
# bd-2 blocks bd-1 (bd-2 must complete before bd-1 can start)
bd dep add bd-1 bd-2
```

### Dependency Types

| Type | Meaning |
|------|---------|
| `blocks` | Task B must complete before task A |
| `related` | Soft connection, doesn't block progress |
| `parent-child` | Epic/subtask hierarchical relationship |
| `discovered-from` | Auto-created when AI discovers related work |

### Visualize Dependencies

```bash
# Show dependency tree
bd dep tree bd-1

# Detect circular dependencies
bd dep cycles
```

## Ready Work (Key Feature)

The `bd ready` command shows issues that are ready to work on - meaning their status is "open" AND they have no blocking dependencies.

```bash
bd ready
```

This is ideal for AI agents to claim the next available work without duplicating effort.

## Agent Integration

Beads is designed for AI-supervised workflows:

- **Agents create issues** when discovering new work during implementation
- **`bd ready`** shows unblocked work ready for agents to claim
- **`--json` flags** enable programmatic parsing of all output
- **Dependencies** prevent multiple agents from duplicating effort
- **Auto git sync** keeps database synchronized across machines

## Git Workflow (Auto-Sync)

Beads automatically keeps git in sync:

- Exports to JSONL after CRUD operations (5s debounce)
- Imports from JSONL when newer than DB (after git pull)
- Works seamlessly across machines and team members

**Disable if needed:**
```bash
bd --no-auto-flush create "..."
bd --no-auto-import list
```

## Mapping to File-Based Workflow

| File Operation | Beads Equivalent |
|----------------|------------------|
| Create pending item | `bd create "..." -p 2` |
| Triage (approve) | `bd update bd-1 --status in_progress` |
| Mark complete | `bd close bd-1` |
| Check dependencies | `bd dep tree bd-1` or `bd ready` |
| List ready work | `bd ready` |

## Quick Reference

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh | bash

# Initialize in project
bd init

# Create backlog item
bd create "Fix login bug" -p 1 -t bug

# List ready work (no blocking deps)
bd ready

# Triage: open → in_progress
bd update bd-1 --status in_progress

# Add dependency
bd dep add bd-1 bd-2

# Complete
bd close bd-1 --reason "Fixed in commit abc123"
```

## See Also

For advanced graph analysis and robot mode, see [beads-viewer.md](./beads-viewer.md).
