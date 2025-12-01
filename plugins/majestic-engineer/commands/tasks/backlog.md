---
description: Manage backlog items across files, GitHub Issues, Linear, or Beads
argument-hint: "[action] [details] - Actions: add, list, update, complete"
---

# Backlog Manager

Manage backlog items using your configured task management backend.

## Action

<action_request> $ARGUMENTS </action_request>

**If no arguments provided, ask the user:**

"What would you like to do with the backlog?"

Present these options using AskUserQuestion:
- **Add new item** - Create a new backlog item
- **List items** - Show existing backlog items
- **Update item** - Modify an existing item
- **Complete item** - Mark an item as done

## Invoke Skill

Once you understand what the user wants to do, invoke the backlog-manager skill:

```
skill backlog-manager
```

The skill will:
1. Read configuration from project's CLAUDE.md (`backend:` setting)
2. Load the appropriate backend (files, github, linear, or beads)
3. Execute the requested operation

## Quick Examples

```bash
# Add a new backlog item
/backlog add Refactor authentication to use JWT tokens

# List all pending items
/backlog list

# Update an item's priority
/backlog update ITEM-123 priority:p1

# Mark an item complete
/backlog complete ITEM-123
```

## Configuration

If no backend is configured, the skill defaults to file-based storage in `docs/todos/`.

To configure a different backend, add to your project's CLAUDE.md:

```yaml
## Task Management
backend: github  # Options: files, github, linear, beads
```
