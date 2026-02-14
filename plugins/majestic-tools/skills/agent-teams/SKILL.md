---
name: agent-teams
description: Guide for coordinating multiple Claude Code instances as a team using Agent Teams. Covers TeammateTool operations, spawn backends, communication, task coordination, hooks, and orchestration patterns. Use when building multi-agent workflows requiring inter-agent communication.
---

# Agent Teams

Coordinate multiple Claude Code instances as a team with shared task lists, inter-agent messaging, and independent context windows. Fundamentally different from subagents (Task tool): teammates communicate directly with each other, not just back to the caller.

## When to Use Agent Teams vs Subagents

```
Does the work require inter-agent communication?
├── No → Use subagents (Task tool)
│   ├── Focused tasks where only the result matters
│   ├── Research/verification that reports back
│   └── Lower token cost (results summarized to main context)
└── Yes → Use Agent Teams
    ├── Teammates need to share findings mid-task
    ├── Adversarial debate / competing hypotheses
    ├── Self-organizing work from shared task list
    └── Complex coordination across 3+ parallel workers

How many parallel workers?
├── 1-3 independent tasks → Subagents (less overhead)
├── 3-5 coordinating workers → Agent Teams
└── 5+ workers → Agent Teams with delegate mode
```

**Best use cases:**
- Research + review from multiple perspectives simultaneously
- Multi-module features where teammates own different files
- Debugging with competing hypotheses (adversarial investigation)
- Cross-layer coordination (frontend, backend, tests)

**Avoid when:**
- Sequential tasks with many dependencies
- Same-file edits (causes overwrites)
- Simple focused work (coordination overhead not worth it)
- Routine tasks (single session more cost-effective)

## Environment Setup

Enable Agent Teams (experimental, disabled by default):

```json
// settings.json (user or project level)
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set in shell: `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## Tool Architecture

Agent Teams use four distinct tools (not a single "TeammateTool"):

| Tool | Purpose |
|------|---------|
| **TeamCreate** | Creates team config + task directory. Caller becomes lead |
| **SendMessage** | All inter-agent communication (5 message types below) |
| **TeamDelete** | Removes team resources after shutdown (cleanup) |
| **Task** (extended) | Spawns teammates when `name` + `team_name` params present |

### SendMessage Types

| Type | Parameters | Description |
|------|-----------|-------------|
| `message` | `recipient`, `content`, `summary` | Direct message to one teammate |
| `broadcast` | `content`, `summary` | Message to all teammates (expensive — N deliveries) |
| `shutdown_request` | `recipient`, `content` | Request teammate termination (lead only) |
| `shutdown_response` | `request_id`, `approve`, `content` | Accept/reject shutdown (teammate only) |
| `plan_approval_response` | `request_id`, `approve`, `recipient`, `content` | Approve/reject plan (lead only) |

**Critical:** Plain text output is NOT visible to teammates. Agents MUST use SendMessage for all inter-agent communication.

**Usage notes:**
- Prefer `message` over `broadcast` — broadcast creates N messages for N teammates
- Messages delivered automatically to recipient inboxes (no polling)
- Idle notifications sent automatically when teammates finish
- Only the lead should run TeamDelete — teammate context may not resolve correctly

## Spawning Teammates

**Method 1: Natural language** — Tell Claude to create a team and describe structure:

```
Create an agent team to review this PR. Spawn three reviewers:
- One focused on security
- One checking performance
- One validating test coverage
```

**Method 2: Task tool with team parameters:**

```
Task({
  team_name: "my-team",
  name: "worker-1",
  subagent_type: "general-purpose",
  prompt: "Review src/auth/ for security vulnerabilities...",
  model: "sonnet",
  run_in_background: true
})
```

**Teammate receives on spawn:**
- Same project context as regular session (CLAUDE.md, MCP servers, skills)
- The spawn prompt from the lead
- Does NOT inherit lead's conversation history

**Built-in agent types for teammates:**

| Type | Capabilities |
|------|-------------|
| `general-purpose` | All tools (Edit, Write, Bash, Task, etc.) |
| `Explore` | Read-only — codebase search and analysis |
| `Plan` | Read-only — architectural design |
| `Bash` | System commands only |

**Model selection:** Use Sonnet for most teammates (cost-effective). Reserve Opus for leads or complex reasoning tasks. Specify via `model` parameter or natural language ("Use Sonnet for each teammate").

## Spawn Backends

Controls how teammates display. Set via `teammateMode` in settings.json or `--teammate-mode` CLI flag.

| Mode | Setting | Requirements | Behavior |
|------|---------|-------------|----------|
| Auto (default) | `"auto"` | None | Split panes if in tmux, else in-process |
| In-process | `"in-process"` | None | All in main terminal. Shift+Up/Down to select |
| Split panes | `"tmux"` | tmux or iTerm2 | Each teammate gets own pane |

```json
// settings.json
{ "teammateMode": "in-process" }
```

```bash
# CLI override for single session
claude --teammate-mode in-process
```

**Auto-detection logic:**
1. `$TMUX` env var set → use tmux split panes
2. `$ITERM_SESSION_ID` set + `it2` available → use iTerm2
3. `which tmux` succeeds → use tmux
4. Fallback → in-process

**In-process navigation:**
- Shift+Up/Down → select teammate
- Enter → view teammate's session
- Escape → interrupt teammate's current turn
- Ctrl+T → toggle task list

**Split-pane navigation:**
- Click into pane to interact directly
- Each teammate has full terminal view

## Communication Patterns

**Direct message (`type: "message"`):** Send to one specific teammate via SendMessage. Use for targeted instructions, follow-ups, or redirecting approach.

**Broadcast (`type: "broadcast"`):** Send to all teammates simultaneously via SendMessage. Use sparingly — costs scale with team size. Good for: announcing shared decisions, requesting status updates.

**Automatic delivery:** Messages arrive at recipients automatically. Lead does not need to poll for updates.

**Idle notifications:** When a teammate finishes and stops, it automatically notifies the lead.

**Message type schemas:** See [resources/message-formats.yml](resources/message-formats.yml)

## Task Coordination

The shared task list coordinates work across the team. All agents see task status and can claim available work.

**Task lifecycle:** `pending` → `in_progress` → `completed`

**Assignment patterns:**
- Lead assigns explicitly ("Give task 3 to the security reviewer")
- Self-claim: after finishing a task, teammate picks next unassigned, unblocked task

**Dependencies:**
- Express with `blockedBy` field (array of task IDs)
- Auto-unblock: when blocking task completes, blocked tasks become available
- Enables sequential pipelines without polling

**File locking:** Task claiming uses file locking to prevent race conditions when multiple teammates try to claim simultaneously.

**Recommended task sizing:**
- 5-6 tasks per teammate for steady throughput
- Self-contained units producing clear deliverables
- Avoid: tasks too small (overhead > benefit) or too large (risk of wasted effort)

## Delegate Mode

Restricts the lead to coordination-only tools: spawning, messaging, shutting down teammates, and managing tasks. Prevents lead from implementing tasks itself.

**Enable:** Press Shift+Tab to cycle into delegate mode after starting a team.

**When to use:**
- Lead keeps implementing tasks instead of waiting for teammates
- You want pure orchestration (break down work, assign, synthesize)
- Large teams where lead should focus on coordination

**Known bug:** Teammates spawned AFTER entering delegate mode inherit restricted tool access (lose Read, Write, Edit, Bash, Glob, Grep). **Workaround:** Spawn all teammates BEFORE pressing Shift+Tab.

**When to skip:**
- Small teams where lead can contribute implementation
- Lead needs to do synthesis work requiring file edits

## Plan Approval Workflow

Require teammates to plan before implementing. Teammate works in read-only plan mode until lead approves.

**Spawn with plan approval:**

```
Spawn an architect teammate to refactor the auth module.
Require plan approval before they make any changes.
```

The `planModeRequired` field in team config controls this per-member.

**Workflow:**

```
1. Teammate spawned with planModeRequired: true
2. Teammate explores codebase, creates plan
3. Teammate sends plan_approval_request to lead
4. Lead reviews plan:
   ├── approvePlan → teammate exits plan mode, begins implementation
   └── rejectPlan(feedback) → teammate stays in plan mode, revises
5. Cycle repeats until approved
```

**Influence approval criteria via prompt:**

```
Only approve plans that include test coverage.
Reject plans that modify the database schema.
```

## File Conflict Avoidance

Two teammates editing the same file causes overwrites. Prevent this by assigning file ownership:

```
- teammate-1: owns src/api/ files
- teammate-2: owns src/ui/ files
- teammate-3: owns tests/ files
```

**Anti-pattern:** Multiple teammates modifying shared config files, package.json, or migration files simultaneously.

**Mitigation:** Use task dependencies to serialize edits to shared files.

## Hooks Integration

Two hook events for enforcing quality gates in agent teams:

### TeammateIdle

Fires when a teammate is about to go idle after finishing its turn.

- Exit 0 → allow idle
- Exit 2 → keep working (stderr fed back as feedback to teammate)
- No matcher support (fires on every occurrence)
- Input includes: `teammate_name`, `team_name`

### TaskCompleted

Fires when a task is being marked as completed (via TaskUpdate or when teammate finishes with in-progress tasks).

- Exit 0 → allow completion
- Exit 2 → prevent completion (stderr fed back as feedback)
- No matcher support (fires on every occurrence)
- Input includes: `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name`

**TeammateIdle:** command hooks only (no prompt/agent hooks). **TaskCompleted:** supports command, prompt, and agent handler types.

See [resources/hook-examples.yml](resources/hook-examples.yml) for configuration examples.

## Graceful Shutdown

**Shutdown sequence:**

```
1. Lead sends requestShutdown to each teammate
2. Teammate receives request:
   ├── approveShutdown → finishes current request/tool call, terminates
   └── rejectShutdown(reason) → continues working
3. Wait for all teammates to terminate
4. Lead calls cleanup
   ├── If active teammates remain → cleanup fails
   └── If all terminated → removes team config + task directories
```

**Important:**
- Shutdown can be slow — teammates finish current request before terminating
- Always use lead for cleanup (not teammates)
- For orphaned tmux sessions: `tmux ls && tmux kill-session -t <name>`

## Permissions

- Teammates start with lead's permission settings
- If lead uses `--dangerously-skip-permissions`, all teammates do too
- Can change individual teammate modes after spawning
- Cannot set per-teammate modes at spawn time
- Pre-approve common operations in permission settings to reduce prompt interruptions

## File Structure

```
~/.claude/
├── teams/
│   └── {team-name}/
│       ├── config.json          # team config (members, lead, settings)
│       └── inboxes/
│           └── {agent}.json     # per-agent message inbox
└── tasks/
    └── {team-name}/
        ├── 1.json               # task files (auto-incremented IDs)
        ├── 2.json
        └── N.json
```

See [resources/team-config-schema.yml](resources/team-config-schema.yml) for full schemas.

## Known Limitations

| Limitation | Impact | Workaround |
|-----------|--------|------------|
| No session resumption with in-process teammates | `/resume` and `/rewind` don't restore teammates | Tell lead to spawn new teammates after resume |
| Task status can lag | Teammates sometimes fail to mark tasks completed | Manually update or tell lead to nudge teammate |
| Shutdown can be slow | Teammates finish current request before stopping | Wait patiently or spawn replacement |
| One team per session | Cannot manage multiple teams from one lead | Clean up current team before starting new one |
| No nested teams | Teammates cannot spawn their own teams | Only leads manage team structure |
| Lead is fixed | Cannot promote teammate or transfer leadership | Plan team structure before starting |
| Permissions set at spawn | All teammates inherit lead's permission mode | Change individual modes after spawning |
| Split panes require tmux/iTerm2 | Not supported in VS Code terminal, Windows Terminal, Ghostty | Use in-process mode as fallback |
| 5-minute heartbeat timeout | Inactive teammates auto-marked inactive | Keep teammates active with tasks |
| Broadcast scales linearly | N messages for N teammates | Prefer targeted `message` over `broadcast` |
| Delegate mode spawn bug | Teammates spawned after Shift+Tab lose file tools | Spawn all teammates before entering delegate mode |

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| "Cannot cleanup with active members" | Teammates still running | `requestShutdown` all teammates first |
| "Already leading a team" | Team already exists | `cleanup` existing team or use different name |
| "Agent not found" | Wrong teammate name/ID | Check `config.json` for correct agent IDs |
| "Team does not exist" | No team created | Run `spawnTeam` first |
| Teammates not appearing | Various | Shift+Down to cycle; check task complexity; verify tmux installed |
| Too many permission prompts | Teammate permissions bubble to lead | Pre-approve common operations in settings |
| Lead shuts down before work done | Lead thinks team is finished | Tell lead to wait for teammates |

## Orchestration Patterns

See [resources/orchestration-patterns.md](resources/orchestration-patterns.md) for 4 detailed patterns:

1. **Parallel Review** — Multiple specialists review simultaneously with distinct lenses
2. **Competing Hypotheses** — Adversarial investigation prevents anchoring bias
3. **Multi-Module Feature** — File ownership + task dependencies for coordinated implementation
4. **Research Pipeline** — Research phase feeds into plan-approved implementation
