# Majestic Tools

Claude Code customization tools. Includes 10 commands, 3 skills, and 2 hooks.

## Installation

```bash
claude /plugin install majestic-tools
```

## Commands

### meta/
| Command | Description |
|---------|-------------|
| `/meta/new-agent` | Generate new Claude Code sub-agent configuration files |
| `/meta/new-hook` | Create and configure Claude Code hooks for automation |
| `/meta/new-command` | Generate any Claude Code command with production patterns |
| `/meta/new-prompt` | Build a well-structured prompt following Anthropic's best practices |
| `/meta/list-tools` | List all available tools with detailed information |

### insight/
| Command | Description |
|---------|-------------|
| `/insight/ccusage` | Analyze Claude Code token usage and costs |
| `/insight/reflect` | Suggest improvements to AGENTS.md based on patterns |
| `/insight/spotlight` | Activate aggressive intellectual challenge mode |

### workflows/
| Command | Description |
|---------|-------------|
| `/workflows/ultrathink-task` | Plan tasks with multiple agents (Architect, Research, Coder, Tester) |
| `/workflows/ultra-options` | Deep analysis generating multiple solution options |

## Skills

| Skill | Description |
|-------|-------------|
| `brainstorming` | Refine rough ideas into fully-formed designs through collaborative questioning |
| `new-skill` | Create and manage Claude Code skills following Anthropic best practices |
| `skill-first` | Check for relevant skills before starting any task |

## Hooks

### check-file-size

Warns when code files exceed a configurable line limit after Write/Edit/MultiEdit operations.

| Setting | Environment Variable | Default |
|---------|---------------------|---------|
| Line limit | `CODE_FILE_SIZE_LIMIT` | 200 |
| File extensions | `CODE_FILE_SIZE_EXTENSIONS` | ts\|js\|py\|go\|rs\|java\|cpp\|c\|cs\|php\|rb\|swift\|kt\|scala\|clj\|hs\|elm\|dart\|vue\|svelte\|jsx\|tsx |

**Requires:** `jq`

### confetti

Triggers Raycast confetti celebration when Claude completes a task.

**Requires:** macOS + [Raycast](https://raycast.com)

Fails silently if Raycast is not installed.

## Prerequisites

### Sequential Thinking MCP Server

The `/workflows/ultrathink-task` and `/workflows/ultra-options` commands require the Sequential Thinking MCP server.

**Installation:**

1. Add to your Claude Code MCP settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-sequential-thinking"]
    }
  }
}
```

2. Restart Claude Code to load the MCP server.

## Usage Examples

```bash
# Create a new agent
/meta/new-agent "Create an agent for database migrations"

# Create custom hooks
/meta/new-hook "Add a hook that notifies Slack on PR creation"

# Generate a new command
/meta/new-command "Create a command for database backup"

# Track token usage
/insight/ccusage

# Reflect on improvements
/insight/reflect

# Deep analysis with multiple options (requires Sequential Thinking MCP)
/workflows/ultra-options "How should we implement caching?"
```
