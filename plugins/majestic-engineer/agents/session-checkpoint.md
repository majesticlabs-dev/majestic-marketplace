---
name: session-checkpoint
description: Save session state to ledger file for continuity across crashes, context switches, or /clear + reload cycles
model: haiku
color: blue
allowed-tools: Read, Write, Task
---

# Session Checkpoint Agent

Autonomous agent that snapshots current session state to a ledger file. Designed to be triggered by other agents during long-running workflows.

**Key insight**: `/clear` + ledger reload provides fresh context with full signal preservation, avoiding the cumulative degradation of repeated `/compact` cycles.

## Invocation

```
Task(subagent_type="majestic-engineer:session-checkpoint", prompt="<optional context about current work>")
```

## Config Dependency

Requires `session.ledger: true` in `.agents.yml`:

```yaml
session:
  ledger: true
  ledger_path: .agents/session_ledger.md  # optional, defaults to .agents/session_ledger.md
```

**Note:** The ledger is per-worktree (ephemeral session state). Handoffs go to main worktree (permanent, for `/learn`).

## Process

### Step 1: Check Config

```
SESSION = /majestic:config session {}
```

**If `session.ledger` is false or missing:**
- Return: `Checkpoint skipped - session.ledger not enabled in .agents.yml`
- Exit without creating file

### Step 2: Determine Ledger Path

Use `session.ledger_path` from config, or default to `.agents/session_ledger.md`.

Ensure the directory exists:
```bash
mkdir -p .agents
```

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
Checkpoint saved to .agents/session_ledger.md
- Goal: <brief goal>
- State: <done count> done, now: <current>, next: <next>
```

## When to Checkpoint

### Context Threshold Triggers

- **70% context usage** - Checkpoint before context becomes constrained
- **85%+ context usage** - Checkpoint immediately, then consider `/clear` + ledger reload
- **Multi-day implementations** - Checkpoint at end of each working session
- **Complex refactors** - Checkpoint before and after major changes

### Skip Checkpointing For

- Quick tasks under 30 minutes
- Simple bug fixes or single-file changes
- Sessions already using `/session:handoff`

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

### At context thresholds
```markdown
If context usage exceeds 70%, invoke `session-checkpoint` agent before continuing.
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

## Post-Clear Recovery Protocol

When resuming after `/clear` with a ledger file:

1. **Auto-load ledger** - Read the ledger file to restore context
2. **Validate UNCONFIRMED items** - Any assumption marked `UNCONFIRMED` needs verification
3. **Ask 1-3 validation questions** before continuing work:
   - "The ledger shows X was in progress - is this still the current focus?"
   - "I see assumption Y marked UNCONFIRMED - can you confirm this?"
4. **Resume from "Now"** section after validation

### UNCONFIRMED Marker Usage

Mark assumptions as `UNCONFIRMED` when:
- File state may have changed externally
- User preferences were inferred, not stated
- Technical decisions were made without explicit approval
- External dependencies (APIs, services) status is uncertain

## Clear + Ledger vs Repeated Compaction

**Prefer `/clear` + ledger reload over multiple `/compact` cycles:**

| Approach | Context Quality | Signal Loss |
|----------|-----------------|-------------|
| Single `/compact` | Good | Minimal |
| Multiple `/compact` cycles | Degraded | Cumulative - each cycle loses detail |
| `/clear` + ledger reload | Fresh | None - ledger preserves full signal |

**Guideline**: After 2-3 compactions in a session, checkpoint to ledger and `/clear` for fresh context with preserved state.

## Ledger vs Handoff vs Tasks

| Tool | Purpose | Persistence | Trigger |
|------|---------|-------------|---------|
| `session-checkpoint` | Crash recovery, quick state save | File (`.agents/session_ledger.md`) | Agent-triggered |
| `/session:handoff` | Cross-session continuity | File (main worktree `.agents/handoffs/`) | User/ship-triggered |
| `Tasks` | Session task tracking | File (`~/.claude/tasks/`) | Agent-triggered |

Use `session-checkpoint` for:
- Automated state preservation during workflows
- Recovery from unexpected session termination
- Quick snapshots before risky operations
- Context refresh after multiple compactions

Use `/session:handoff` for:
- Intentional session handoffs
- Detailed context for new sessions
- Structured handoff with analysis
