---
name: backlog-manager
description: Manage backlog items across multiple backends (files, GitHub Issues, Linear). Configure your preferred task system in project CLAUDE.md.
---

# Backlog Manager Skill

## Overview

The backlog manager provides a unified interface for tracking work items across different task management systems. Choose your backend based on team preferences and existing tooling.

**Supported Backends:**

| Backend | Integration | Best For |
|---------|-------------|----------|
| **Files** | Local markdown in `docs/todos/` | Solo developers, simple projects |
| **GitHub** | `gh` CLI | Teams using GitHub Issues |
| **Linear** | MCP server | Teams using Linear |

## Configuration

Configure your preferred backend in your project's CLAUDE.md:

```yaml
## Task Management

backend: files  # Options: files, github, linear

# GitHub configuration (when backend: github)
# github_labels: ["backlog"]
# github_assignee: "@me"

# Linear configuration (when backend: linear)
# linear_team_id: TEAM-123
# linear_project_id: PROJECT-456
```

**Default:** If no configuration is found, uses file-based backend.

## When to Use This Skill

**Create a backlog item when:**
- Work requires more than 15-20 minutes
- Needs research, planning, or multiple approaches considered
- Has dependencies on other work
- Requires approval or prioritization
- Part of larger feature or refactor
- Technical debt needing documentation

**Act immediately instead when:**
- Issue is trivial (< 15 minutes)
- Complete context available now
- No planning needed
- User explicitly requests immediate action
- Simple bug fix with obvious solution

## Core Concepts

### Status Lifecycle

All backends follow this status workflow:

```
pending → ready → complete
```

| Status | Meaning |
|--------|---------|
| **pending** | Needs triage/approval before work begins |
| **ready** | Approved and ready for implementation |
| **complete** | Work finished, acceptance criteria met |

### Priority Levels

| Priority | Meaning |
|----------|---------|
| **p1** | Critical - blocks other work or users |
| **p2** | Important - should be done soon |
| **p3** | Nice-to-have - can wait |

### Core Operations

Each backend implements these operations:

| Operation | Purpose |
|-----------|---------|
| **CREATE** | Add new backlog item |
| **LIST** | Query existing items |
| **UPDATE** | Modify item (status, priority, details) |
| **COMPLETE** | Mark item as done |

## Backend Selection

When this skill is invoked:

1. **Read configuration** from project CLAUDE.md
2. **Load appropriate reference** based on `backend` setting:
   - `files` → `references/file-backend.md`
   - `github` → `references/github-backend.md`
   - `linear` → `references/linear-backend.md`
3. **Follow backend-specific instructions** for operations

### Fallback Behavior

If the configured backend is unavailable:
- **GitHub unavailable** (gh not authenticated): Fall back to files
- **Linear unavailable** (MCP not configured): Fall back to files
- **Warn user** about the fallback

## Integration with Development Workflows

| Trigger | Flow |
|---------|------|
| Code review findings | Review → Create items → Triage → Work |
| PR comments | Resolve PR → Create items for complex fixes |
| Planning sessions | Brainstorm → Create items → Prioritize → Work |
| Technical debt | Document → Create item → Schedule |
| Feature requests | Analyze → Create item → Prioritize |

## Key Distinctions

**Backlog manager (this skill):**
- Persisted tracking across sessions
- Multiple backend options
- Team collaboration
- Project/sprint planning

**TodoWrite tool:**
- In-memory task tracking during single session
- Temporary progress tracking
- Not persisted to disk
- Different purpose from backlog management
