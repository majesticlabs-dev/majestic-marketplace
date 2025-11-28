# Linear Backend Reference

This reference covers using Linear as the backlog system via MCP (Model Context Protocol).

## Prerequisites

- Linear MCP server configured in Claude Code
- Team ID from Linear (required for creating issues)
- Linear account with appropriate permissions

## MCP Server Configuration

Add to your Claude Code MCP config:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    }
  }
}
```

First use will prompt for OAuth authentication.

## Configuration

In your project's CLAUDE.md:

```yaml
backend: linear
linear_team_id: TEAM-123           # Required: your Linear team ID
linear_project_id: PROJECT-456     # Optional: default project
linear_default_labels: ["ai-generated"]
```

**Finding your team ID:**
Use `mcp__linear__list_teams` to get available teams and their IDs.

## Operations

### CREATE - New Issue

**Tool:** `mcp__linear__create_issue`

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `title` | Yes | Brief description |
| `description` | No | Full markdown body |
| `teamId` | Yes | From configuration |
| `priority` | No | 1 (urgent) to 4 (low) |
| `projectId` | No | Project to assign to |
| `labelIds` | No | Array of label IDs |
| `assigneeId` | No | User ID to assign |

**Priority mapping:**
| Linear Priority | File Equivalent |
|-----------------|-----------------|
| 1 (Urgent) | p1 |
| 2 (High) | p1 |
| 3 (Medium) | p2 |
| 4 (Low) | p3 |

**Example:**
```
Use mcp__linear__create_issue with:
- title: "Fix N+1 query in dashboard"
- description: "## Problem\n\nSlow page load...\n\n## Acceptance Criteria\n\n- [ ] Query optimized"
- teamId: "TEAM-123"
- priority: 2
```

### LIST - Query Issues

**Tool:** `mcp__linear__list_issues`

Filter by:
- Team
- Status (Backlog, Todo, In Progress, Done)
- Assignee
- Project
- Labels

**Tool:** `mcp__linear__list_my_issues`

Get issues assigned to the authenticated user.

### VIEW - Read Issue Details

**Tool:** `mcp__linear__get_issue`

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Issue ID (e.g., "ABC-123") |

Returns full issue details including:
- Title and description
- Status and priority
- Assignee
- Labels
- Comments
- Activity history

### UPDATE - Modify Issue

**Tool:** `mcp__linear__update_issue`

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Issue ID |
| `title` | No | New title |
| `description` | No | New description |
| `stateId` | No | New status (get IDs from `list_issue_statuses`) |
| `priority` | No | 1-4 |
| `assigneeId` | No | New assignee |
| `labelIds` | No | Replace labels |

**Status workflow:**
Use `mcp__linear__list_issue_statuses` to get available statuses for your team. Common states:
- Backlog
- Todo
- In Progress
- In Review
- Done
- Cancelled

### COMPLETE - Mark Done

**Tool:** `mcp__linear__update_issue`

Set `stateId` to the "Done" status ID from your team's workflow.

**Example:**
```
1. Get status IDs: mcp__linear__list_issue_statuses
2. Find "Done" stateId
3. Update: mcp__linear__update_issue with id and stateId
```

## Linear-Specific Features

### Cycles (Sprint Planning)

Issues can be assigned to cycles (time-boxed iterations):

```
Use mcp__linear__update_issue with:
- id: "ABC-123"
- cycleId: "CYCLE-ID"
```

List cycles: `mcp__linear__list_cycles`

### Estimates

Use `estimate` parameter when creating/updating issues.
Value depends on team settings (story points or T-shirt sizes).

### Parent Issues (Epics)

Create sub-issues with `parentId` parameter:

```
Use mcp__linear__create_issue with:
- title: "Subtask"
- teamId: "TEAM-123"
- parentId: "PARENT-ISSUE-ID"
```

### Comments as Work Logs

**Tool:** `mcp__linear__create_comment`

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `issueId` | Yes | Issue to comment on |
| `body` | Yes | Markdown content |

**Example work log:**
```
Use mcp__linear__create_comment with:
- issueId: "ABC-123"
- body: "## Work Log - 2024-01-15\n\n**Actions:**\n- Fixed query\n\n**Status:** In progress"
```

### Projects

Group related issues under a project:

```
Use mcp__linear__create_issue with:
- ...
- projectId: "PROJECT-ID"
```

List projects: `mcp__linear__list_projects`

## Verifying MCP Tools

Before using Linear backend, verify the MCP tools are available:

```
Use ListMcpResourcesTool with server: "linear"
```

This confirms:
- MCP server is configured
- Authentication is complete
- Tools are accessible

## Mapping to File-Based Workflow

| File Operation | Linear Equivalent |
|----------------|-------------------|
| Create pending item | `create_issue` with Backlog status |
| Triage (approve) | `update_issue` status to Todo |
| Mark complete | `update_issue` status to Done |
| Add work log | `create_comment` |
| Set priority | `update_issue` with priority 1-4 |
| Check dependencies | Use parent issues or project grouping |

## Quick Reference

```
# Create issue
mcp__linear__create_issue
  title, description, teamId, priority

# List issues
mcp__linear__list_issues
mcp__linear__list_my_issues

# View issue
mcp__linear__get_issue
  id

# Update issue
mcp__linear__update_issue
  id, stateId, priority, assigneeId

# Add comment
mcp__linear__create_comment
  issueId, body
```

## Resources

- [Linear MCP Documentation](https://linear.app/docs/mcp)
- [Linear API Reference](https://developers.linear.app/docs)
