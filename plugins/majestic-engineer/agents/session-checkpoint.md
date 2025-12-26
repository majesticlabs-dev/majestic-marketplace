---
name: session-checkpoint
description: Save current session state to ledger file for continuity across crashes or context switches
model: haiku
color: blue
allowed-tools: Read, Write, Task
---

# Session Checkpoint Agent

Autonomous agent that snapshots current session state to a ledger file. Designed to be triggered by other agents during long-running workflows.

## Invocation

```
Task(subagent_type="majestic-engineer:session-checkpoint", prompt="<optional context about current work>")
```

## Config Dependency

Requires `session.ledger: true` in `.agents.yml`:

```yaml
session:
  ledger: true
  ledger_path: .session_ledger.md  # optional, defaults to .session_ledger.md
```

## Process

### Step 1: Check Config

Invoke `config-reader` agent to get merged config:

```
Task(subagent_type="majestic-engineer:config-reader", prompt="field: session, default: {}")
```

**If `session.ledger` is false or missing:**
- Return: `Checkpoint skipped - session.ledger not enabled in .agents.yml`
- Exit without creating file

### Step 2: Determine Ledger Path

Use `session.ledger_path` from config, or default to `.session_ledger.md`.

### Step 3: Gather State

From the prompt context provided, extract:

1. **Goal** - What is being worked on (success criteria if known)
2. **Constraints/Assumptions** - Known limitations or decisions
3. **Key Decisions** - Important choices made during this work
4. **State**:
   - Done: Completed items
   - Now: Current focus
   - Next: Planned next step
5. **Open Questions** - Unresolved items (mark as `UNCONFIRMED` if uncertain)
6. **Working Set** - Key files, IDs, or commands relevant to current work

### Step 4: Write Ledger

Write to the ledger file using this format:

```markdown
# Session Ledger

_Last updated: <timestamp>_

## Goal
<goal and success criteria>

## Constraints/Assumptions
- <constraint 1>
- <constraint 2>

## Key Decisions
- <decision 1>
- <decision 2>

## State

### Done
- <completed item 1>
- <completed item 2>

### Now
<current focus>

### Next
<planned next step>

## Open Questions
- <question 1>
- <question 2> `UNCONFIRMED`

## Working Set
- Files: <key files>
- IDs: <relevant IDs>
- Commands: <useful commands>
```

### Step 5: Return Confirmation

Return a brief confirmation:

```
Checkpoint saved to .session_ledger.md
- Goal: <brief goal>
- State: <done count> done, now: <current>, next: <next>
```

## Integration Points

Other agents can invoke this checkpoint:

### Before risky operations
```markdown
Before starting major refactor, invoke `session-checkpoint` agent to save current state.
```

### After milestones
```markdown
After completing each major step, invoke `session-checkpoint` agent with current progress.
```

### Periodic checkpoints in long workflows
```markdown
If working for more than 10 minutes on a complex task, invoke `session-checkpoint` agent.
```

## Example Invocations

### From build-task
```
Task(
  subagent_type="majestic-engineer:session-checkpoint",
  prompt="Working on: Add user authentication. Done: Created User model, Added bcrypt gem. Now: Writing login controller. Next: Add session management."
)
```

### From debug workflow
```
Task(
  subagent_type="majestic-engineer:session-checkpoint",
  prompt="Debugging N+1 in OrdersController. Found root cause: missing includes on line_items. About to apply fix."
)
```

### Minimal checkpoint
```
Task(
  subagent_type="majestic-engineer:session-checkpoint",
  prompt="Implementing feature X, halfway done"
)
```

## Ledger vs Handoff vs TodoWrite

| Tool | Purpose | Persistence | Trigger |
|------|---------|-------------|---------|
| `session-checkpoint` | Crash recovery, quick state save | File (`.session_ledger.md`) | Agent-triggered |
| `/session:handoff` | Cross-session continuity | File (`.claude/handoffs/`) | User-triggered |
| `TodoWrite` | In-session task tracking | In-context only | Agent-triggered |

Use `session-checkpoint` for:
- Automated state preservation during workflows
- Recovery from unexpected session termination
- Quick snapshots before risky operations

Use `/session:handoff` for:
- Intentional session handoffs
- Detailed context for new sessions
- Structured handoff with analysis
