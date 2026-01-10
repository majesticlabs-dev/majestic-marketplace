# Majestic Tools

Claude Code customization tools. Includes 8 agents, 11 commands, and 5 skills.

## Installation

```bash
claude /plugin install majestic-tools
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Discover requirements through conversation | `/majestic-tools:interview "topic"` |
| Get expert perspectives on a difficult question | `/expert-panel "topic"` |
| Resume a saved expert panel discussion | `/expert-panel --resume {panel-id}` |
| List all saved panel sessions | `/expert-panel --list` |
| Export panel discussion to markdown | `/expert-panel --export {panel-id}` |
| Create a new agent | `/majestic-tools:meta:new-agent` |
| Create a new command | `/majestic-tools:meta:new-command` |
| Create a new hook | `/majestic-tools:meta:new-hook` |
| Track token usage | `/majestic-tools:insight:ccusage` |
| Brainstorm ideas | `skill brainstorming` |

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
| `interview` | Domain-aware discovery interview for engineering, brand, product, marketing, or sales |

## Skills

Invoke with: `skill majestic-tools:<name>`

| Skill | Description |
|-------|-------------|
| `brainstorming` | Refine rough ideas into fully-formed designs through collaborative questioning |
| `new-skill` | Create and manage Claude Code skills following Anthropic best practices |
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

These hooks are not installed by default. Add them to your settings manually.

#### today (Optional)

Injects current date/time into the session context on startup. **Workaround for subagents/commands not inheriting the parent session's date context.**

**Location:** `hooks/today.sh`

**Why:** While the main Claude session knows today's date, subagents spawned via `Task` tool and commands may not inherit this context, causing them to hallucinate dates (often defaulting to 2024).

**To enable:**

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/majestic-marketplace/plugins/majestic-tools/hooks/today.sh"
          }
        ]
      }
    ]
  }
}
```

**Output:** `[CONTEXT] Current date/time: Monday, 2025-12-30 14:32:15 UTC (+0000) | ISO: 2025-12-30T14:32:15+00:00`

**Timezone:** Set `TZ` environment variable to customize (defaults to UTC).

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

## Usage Examples

```bash
# Discovery interviews (auto-detects domain from keywords)
/majestic-tools:interview "brand voice"       # → brand domain
/majestic-tools:interview "new campaign"      # → marketing domain
/majestic-tools:interview "sales pitch"       # → sales domain
/majestic-tools:interview "user needs"        # → product domain
/majestic-tools:interview "new feature"       # → engineering domain (default)

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

# Brainstorm before implementing
skill majestic-tools:brainstorming

# Create a new skill
skill majestic-tools:new-skill
```

## Interview Command Deep Dive

The `/majestic-tools:interview` command provides domain-aware discovery through conversational probing.

### Domain Detection

| Domain | Trigger Keywords | Use Case |
|--------|-----------------|----------|
| `brand` | brand voice, tone, writing style | Codify voice and messaging |
| `product` | product, user research, discovery | Explore problem space and users |
| `marketing` | campaign, content strategy, audience | Plan campaigns and messaging |
| `sales` | sales process, objections, pitch | Prepare for deals and proposals |
| `engineering` | feature, bug, system (default) | Plan implementation |

### What Each Domain Covers

**Brand Discovery:**
- Voice identity (brand as a person)
- Audience connection
- Tone boundaries (what to avoid)
- Existing patterns that work

**Product Discovery:**
- Problem space (the pain, not the solution)
- User context (when/where it hurts)
- Current alternatives
- Success signals
- Scope boundaries (MVP vs v2)

**Marketing Discovery:**
- Campaign goals (desired action)
- Audience (where they are, what they believe)
- Core message (one thing to remember)
- Differentiation (why you vs others)
- Constraints (budget, channels, timeline)

**Sales Discovery:**
- Deal context (what, who, stakes)
- Buyer journey (stage, timeline, trigger)
- Decision makers (champion, skeptic, budget holder)
- Objections (stated and unstated)
- Competition and positioning

**Engineering Discovery:**
- Technical approach and tradeoffs
- System fit and dependencies
- Human/workflow impact
- Strategic scope (MVP, not-building)

### Output

Each domain produces a structured synthesis with:
- Key findings organized by domain area
- Quotable moments (verbatim insights)
- Open questions (things to resolve)
- Domain-appropriate next steps
