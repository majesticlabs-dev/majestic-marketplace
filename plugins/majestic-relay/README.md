# majestic-relay

Fresh-context task execution with attempt ledger. Shell-orchestrated epic workflow that spawns new Claude instances per task to prevent context pollution.

> **Inspired by:** [gmickel/gmickel-claude-marketplace](https://github.com/gmickel/gmickel-claude-marketplace) (flow-next plugin)

## Commands

| Command | Description |
|---------|-------------|
| `/relay:init <blueprint.md>` | Parse blueprint → `.agents-os/relay/epic.yml` |
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
/relay:work --max-attempts 5   # Override max attempts
```

## Key Features

- **Fresh context per task**: Each task spawns a new Claude instance
- **Attempt ledger**: Tracks attempts with structured receipts
- **Re-anchoring**: Every task receives git state + spec + previous failures
- **Automatic gating**: Blocks tasks after max retry attempts (default: 3)
- **Quality gate**: Each successful task verified via quality-gate agent
- **Compound learning**: Extracts patterns from each task, aggregates at epic completion

## File Structure

```
.agents-os/relay/
├── epic.yml              # Epic + tasks definition
└── attempt-ledger.yml    # Attempt tracking with receipts + learnings
```

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
