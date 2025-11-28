# Majestic Marketplace

The Majestic marketplace where we share our workflows.

## Quick Start

Run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/install.sh | bash
```

This gives you options to:
1. Add marketplace (enables plugin installation)
2. Add output styles (formatting guides)
3. Add MCP servers (Sequential Thinking)
4. Install all

### Manual Installation

#### Claude Code

Run `claude` and add the marketplace:

```bash
/plugin marketplace add https://github.com/majesticlabs-dev/majestic-marketplace.git
```

Then install a plugin:

```bash
/plugin install {plugin-name}
```

#### Factory (Droid)

1) Install Droid (Factory):

```bash
bunx droid-factory
```

What this does: copies Claude Code marketplace commands/agents/subagents and converts them to Droid format.

Next:
- Start Droid
- In Settings, enable Sub-agents

You're done: use this source from Droid. You don't need to add it in Claude Code anymore.

## Majestic Plugins

| Plugin | Description |
|--------|-------------|
| [majestic-engineer](plugins/majestic-engineer/README.md) | Language-agnostic engineering workflows (5 agents, 14 commands, 4 skills) |
| [majestic-rails](plugins/majestic-rails/README.md) | Ruby on Rails development tools (2 agents, 4 skills) |
| [majestic-tools](plugins/majestic-tools/README.md) | Claude Code customization tools (10 commands) |

## Project CLAUDE.md Setup

Initialize a project-level CLAUDE.md with coding guidelines for your team:

```bash
curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/init-claude.sh | bash
```

Available modules:
- **critical-thinking** - Challenge assumptions, prioritize accuracy over validation
- **anti-overengineering** - YAGNI, KISS, DRY - avoid unnecessary complexity
- **analyze-vs-implement** - Distinguish suggestion from action
- **investigation-first** - Understand before proposing solutions

## Resources

| Resource | Description |
|----------|-------------|
| [Output Styles](output-styles/README.md) | Pre-built formatting guides for consistent responses |
| [Instructions](instructions/) | CLAUDE.md instruction modules |

## References

- [Antrhopic Marketplace](https://github.com/anthropics/claude-code/tree/main/plugins)
- [Every Marketplace](https://github.com/EveryInc/every-marketplace)
- [Superpowers](https://github.com/obra/superpowers)
- [Rails Development Skills](https://github.com/alec-c4/claude-skills-rails-dev)
