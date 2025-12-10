# Majestic Tools

Claude Code customization tools. Includes 8 agents, 15 commands, and 5 skills.

## Installation

```bash
claude /plugin install majestic-tools
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Find the right tool for my task | `/majestic-guide "what I want to do"` |
| Get expert perspectives on a difficult question | `/expert-panel "topic"` |
| Resume a saved expert panel discussion | `/expert-panel --resume {panel-id}` |
| List all saved panel sessions | `/expert-panel --list` |
| Export panel discussion to markdown | `/expert-panel --export {panel-id}` |
| Create a new agent | `/majestic-tools:meta:new-agent` |
| Create a new command | `/majestic-tools:meta:new-command` |
| Create a new hook | `/majestic-tools:meta:new-hook` |
| Track token usage | `/majestic-tools:insight:ccusage` |
| Brainstorm ideas | `skill brainstorming` |
| Deep multi-option analysis | `/majestic-tools:workflows:ultra-options` |

## Agents

Invoke with: `agent <name>`

| Agent | Description |
|-------|-------------|
| `reasoning-verifier` | Verify LLM reasoning using RCoT - detect overlooked conditions and hallucinations |
| `expert-perspective` | Simulate an expert's perspective with authentic voice and reasoning |
| `expert-panel-discussion` | Orchestrate multi-round expert panel discussions with synthesis |

## Commands

### Standalone

| Command | Description |
|---------|-------------|
| `/majestic-guide` | Guide to the right skill, command, or agent for any task |
| `/expert-panel` | Lead a panel of experts to address difficult questions from multiple perspectives |

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
| `set-title` | Set terminal window title to identify what the current session is working on |
| `skill-first` | Check for relevant skills before starting any task |

## Hooks

### check-file-size (Included)

Warns when code files exceed a configurable line limit after Write/Edit/MultiEdit operations.

| Setting | Environment Variable | Default |
|---------|---------------------|---------|
| Line limit | `CODE_FILE_SIZE_LIMIT` | 200 |
| File extensions | `CODE_FILE_SIZE_EXTENSIONS` | ts\|js\|py\|go\|rs\|java\|cpp\|c\|cs\|php\|rb\|swift\|kt\|scala\|clj\|hs\|elm\|dart\|vue\|svelte\|jsx\|tsx |

**Requires:** `jq`

### Optional Hooks

These hooks are available in `examples/hooks/` but not installed by default. Copy them to your hooks configuration manually if desired.

#### confetti (Optional)

Triggers Raycast confetti celebration when Claude completes a task.

**Location:** `examples/hooks/confetti.sh`

**Requires:** macOS + [Raycast](https://raycast.com)

**To enable:**
1. Copy `examples/hooks/confetti.sh` to your hooks directory
2. Add to your hooks.json:
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/confetti.sh",
            "timeout": 2000
          }
        ]
      }
    ]
  }
}
```

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

# Expert panel discussions
/expert-panel "Should we migrate from monolith to microservices?"
/expert-panel "What's the best authentication strategy for our SaaS app?"
/expert-panel --list                                    # List saved sessions
/expert-panel --resume 20251209-150000-microservices    # Resume discussion
/expert-panel --export 20251209-150000-microservices    # Export to markdown

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
