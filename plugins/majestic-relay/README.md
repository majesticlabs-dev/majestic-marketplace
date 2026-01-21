# majestic-relay

Fresh-context task execution with attempt ledger. Shell-orchestrated epic workflow that spawns new Claude instances per task to prevent context pollution.

> **Inspired by:** [gmickel/gmickel-claude-marketplace](https://github.com/gmickel/gmickel-claude-marketplace) (flow-next plugin)

## Commands

| Command | Description |
|---------|-------------|
| `/relay:init <blueprint.md>` | Parse blueprint → split into epics by phase → generate playlist |
| `/relay:status` | Show progress and gated tasks |
| `/relay:work` | Execute tasks with fresh contexts |
| `/relay:run-playlist` | Execute multiple epics sequentially (fail-fast) |
| `/relay:playlist-status` | Show playlist progress across all epics |

## Usage

```bash
# 1. Create blueprint (existing command)
/majestic:blueprint "Add user authentication"

# 2. Initialize relay (splits into epics + creates playlist)
/relay:init docs/plans/xxx.md

# 3. Execute tasks
/relay:work                    # All pending tasks
/relay:work T2                 # Specific task
/relay:work --max-attempts 5   # Override max attempts
```

### What `/relay:init` Does

1. Parses the blueprint's `## Implementation Tasks` section
2. Classifies tasks into phases:
   - **foundation** - migrations, models, schema, config
   - **core** - services, business logic, handlers
   - **integration** - controllers, endpoints, views
   - **polish** - tests, validation, error handling
3. Creates one epic file per phase in `.agents-os/relay/epics/`
4. Generates `playlist.yml` with all epics in order
5. Initializes `attempt-ledger.yml`

## File Structure

```
.agents-os/relay/
├── epic.yml                    # SYMLINK → epics/{current}.yml
├── attempt-ledger.yml          # Reset per epic
├── playlist.yml                # Tracks progress across epics
└── epics/
    ├── 260120-01-foundation.yml
    ├── 260120-02-core.yml
    ├── 260120-03-integration.yml
    └── 260120-04-polish.yml
```

- **Symlink approach**: `epic.yml` points to current epic (no file copying)
- **Fresh ledger per epic**: Each epic starts clean
- **Fail-fast**: Stops on first epic failure
- **Resume support**: Continue from `current` index after interruption

### Playlist Schema

```yaml
# playlist.yml (updated during execution)
version: 1
name: "260120-playlist"
created_at: "2026-01-20T10:00:00Z"
status: in_progress    # pending | in_progress | completed | failed
current: 2             # Index of current/next epic (0-based)
started_at: "2026-01-20T10:00:00Z"
ended_at: null
duration_minutes: null

epics:
  - file: 260120-01-foundation.yml
    status: completed
    started_at: "2026-01-20T10:00:00Z"
    completed_at: "2026-01-20T10:15:00Z"
  - file: 260120-02-core.yml
    status: in_progress
    started_at: "2026-01-20T10:15:00Z"
  - file: 260120-03-integration.yml
    status: pending
```

## Key Features

- **Fresh context per task**: Each task spawns a new Claude instance
- **Attempt ledger**: Tracks attempts with structured receipts
- **Re-anchoring**: Every task receives git state + spec + previous failures
- **Automatic gating**: Blocks tasks after max retry attempts (default: 3)
- **Quality gate**: Each successful task verified via quality-gate agent
- **Compound learning**: Extracts patterns from each task, aggregates at epic completion
- **Phase-based splitting**: Blueprints automatically split into logical phases

## Compound Learning

Each task attempt extracts a reusable learning (1 sentence + tags). At epic completion:

1. **Aggregate**: All learnings consolidated by semantic similarity
2. **Threshold**: Frequency determines action (1x=skip, 2x=watch, 3+=recommend)
3. **Categorize**: Project rules → AGENTS.md, quality rules → .agents.yml
4. **Apply**: User confirms before any file changes

```yaml
# Example learning in attempt receipt
receipt:
  summary: "Created migration"
  learning: "yq paths with dashes require quoting"
  pattern_tags: [yq, shell, quoting]
```
