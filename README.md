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
4. Configure shell settings (env vars + alias)
5. Install all

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

#### Factory AI (Droid)

Use [droid-factory](https://github.com/iannuttall/droid-factory) to import Claude Code marketplace agents:

```bash
bunx droid-factory
```

This launches a guided installer that can import agents from Claude Code marketplaces into Factory's `.factory/droids/` directory.

**Prerequisites:** Enable Custom Droids in Factory (`/settings` → Experimental → Custom Droids)

**Note:** Skills and commands are Claude Code-specific and won't transfer directly.

## Majestic Plugins

| Plugin | Description |
|--------|-------------|
| [majestic-engineer](plugins/majestic-engineer/README.md) | Language-agnostic engineering workflows (17 agents, 8 commands, 12 skills) |
| [majestic-rails](plugins/majestic-rails/README.md) | Ruby on Rails development tools (23 agents, 5 commands, 9 skills) |
| [majestic-python](plugins/majestic-python/README.md) | Python development tools (2 agents) |
| [majestic-marketing](plugins/majestic-marketing/README.md) | Marketing and SEO tools (14 agents, 2 commands, 24 skills) |
| [majestic-sales](plugins/majestic-sales/README.md) | Sales acceleration tools (1 command, 6 skills) |
| [majestic-company](plugins/majestic-company/README.md) | Business operations and CEO tools (2 agents, 21 skills) |
| [majestic-tools](plugins/majestic-tools/README.md) | Claude Code customization tools (10 commands, 3 skills) |

## Recommended Plugins

Third-party plugins that complement the Majestic suite:

| Plugin | Description | Install |
|--------|-------------|---------|
| [osgrep](https://github.com/Ryandonofrio3/osgrep) | Semantic code search with natural language queries - find code by intent, not just keywords | `npm i -g osgrep && osgrep install-claude-code` |
| [beads](https://github.com/steveyegge/beads) | Dependency-aware issue tracker - issues chained like beads with blocking relationships | `curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh \| bash` |

## Recommended Settings

Add Claude Code environment variables to your shell profile:

```bash
# Option 1: Use the installer (menu option 4)
curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/install.sh | bash

# Option 2: Manual - append to ~/.zshrc or ~/.bashrc
curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/instructions/shell-settings.sh >> ~/.zshrc
source ~/.zshrc
```

| Setting | Description |
|---------|-------------|
| `ENABLE_BACKGROUND_TASKS` | Enables background task execution |
| `FORCE_AUTO_BACKGROUND_TASKS` | Automatically runs eligible tasks in background |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Keeps bash commands in project directory |
| `cly` alias | Launches Claude Code with auto-approve for trusted projects |

## Project CLAUDE.md Setup

Initialize a project-level CLAUDE.md with coding guidelines for your team:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/majesticlabs-dev/majestic-marketplace/master/install.sh)"
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
