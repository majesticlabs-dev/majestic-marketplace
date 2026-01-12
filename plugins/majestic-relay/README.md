# majestic-relay

Fresh-context task execution with attempt ledger. Shell-orchestrated epic workflow that spawns new Claude instances per task to prevent context pollution.

> **Inspired by:** [gmickel/gmickel-claude-marketplace](https://github.com/gmickel/gmickel-claude-marketplace) (flow-next plugin)

## Commands

| Command | Description |
|---------|-------------|
| `/relay:init <blueprint.md>` | Parse blueprint → `.majestic/epic.yml` |
| `/relay:status` | Show progress and gated tasks |
| `/relay:work` | Execute tasks with fresh contexts |

## Usage

```bash
# 1. Create blueprint (existing command)
/majestic:blueprint "Add user authentication"

# 2. Initialize epic from blueprint
/relay:init docs/plans/xxx.md

# 3. Execute tasks
/relay:work                    # All pending tasks
/relay:work T2                 # Specific task
/relay:work --dry-run          # Preview only
```

## Key Features

- **Fresh context per task**: Each task spawns a new Claude instance
- **Attempt ledger**: Tracks attempts with structured receipts
- **Re-anchoring**: Every task receives git state + spec + previous failures
- **Automatic gating**: Blocks tasks after max retry attempts
- **Configurable review**: Optional repoprompt/gemini validation

## Configuration

In `.agents.yml`:

```yaml
relay:
  max_attempts_per_task: 3
  timeout_minutes: 15
  review:
    enabled: true
    provider: none  # repoprompt | gemini | none
```

## File Structure

```
.majestic/
├── epic.yml              # Epic + tasks definition
└── attempt-ledger.yml    # Attempt tracking with receipts
```
