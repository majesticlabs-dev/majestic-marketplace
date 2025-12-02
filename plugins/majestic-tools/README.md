# Majestic Tools

Claude Code customization tools. Includes 1 agent, 11 commands, 3 skills, and 2 hooks.

## Installation

```bash
claude /plugin install majestic-tools
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Find the right tool for my task | `/majestic-guide "what I want to do"` |
| Create a new agent | `/majestic-tools:meta:new-agent` |
| Create a new command | `/majestic-tools:meta:new-command` |
| Create a new hook | `/majestic-tools:meta:new-hook` |
| Track token usage | `/majestic-tools:insight:ccusage` |
| Brainstorm ideas | `skill brainstorming` |
| Deep multi-option analysis | `/majestic-tools:workflows:ultra-options` |

## Agents

Invoke with: `agent majestic-tools:<name>`

| Agent | Description |
|-------|-------------|
| `reasoning-verifier` | Verify LLM reasoning using RCoT - detect overlooked conditions and hallucinations |

## Commands

### Standalone

| Command | Description |
|---------|-------------|
| `/majestic-guide` | Guide to the right skill, command, or agent for any task |

### Categorized Commands

Invoke with: `/majestic-tools:<category>:<name>`

### insight

| Command | Description |
|---------|-------------|
| `insight:ccusage` | Analyze Claude Code token usage and costs |
| `insight:reflect` | Suggest improvements to AGENTS.md based on patterns |
| `insight:spotlight` | Activate aggressive intellectual challenge mode |

### meta

| Command | Description |
|---------|-------------|
| `meta:list-tools` | List all available tools with detailed information |
| `meta:new-agent` | Generate new Claude Code sub-agent configuration files |
| `meta:new-command` | Generate any Claude Code command with production patterns |
| `meta:new-hook` | Create and configure Claude Code hooks for automation |
| `meta:new-prompt` | Build a well-structured prompt following Anthropic's best practices |

### workflows

| Command | Description |
|---------|-------------|
| `workflows:ultra-options` | Deep analysis generating multiple solution options |
| `workflows:ultrathink-task` | Plan tasks with multiple agents (Architect, Research, Coder, Tester) |

## Skills

Invoke with: `skill majestic-tools:<name>`

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

## Configuration

### Sequential Thinking MCP Server

The `workflows:ultrathink-task` and `workflows:ultra-options` commands require the Sequential Thinking MCP server.

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
# Find the right tool for a task
/majestic-guide "write tests for my Rails model"
/majestic-guide "optimize database queries"
/majestic-guide "create a landing page"

# Create a new agent
/majestic-tools:meta:new-agent "Create an agent for database migrations"

# Create custom hooks
/majestic-tools:meta:new-hook "Add a hook that notifies Slack on PR creation"

# Generate a new command
/majestic-tools:meta:new-command "Create a command for database backup"

# Track token usage
/majestic-tools:insight:ccusage

# Reflect on improvements
/majestic-tools:insight:reflect

# Deep analysis with multiple options (requires Sequential Thinking MCP)
/majestic-tools:workflows:ultra-options "How should we implement caching?"

# Brainstorm before implementing
skill majestic-tools:brainstorming

# Create a new skill
skill majestic-tools:new-skill
```
