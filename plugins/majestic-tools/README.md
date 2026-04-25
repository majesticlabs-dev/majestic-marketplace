# Majestic Tools

Claude Code customization tools. Includes 0 agents, 1 command, and 14 skills.

## Installation

```bash
claude /plugin install majestic-tools
```

## Quick Reference

| I want to... | Use this |
|--------------|----------|
| Discover requirements through conversation | `/interview "topic"` |
| Get expert perspectives on a difficult question | `/expert-panel "topic"` |
| Resume a saved expert panel discussion | `/expert-panel --resume {panel-id}` |
| List all saved panel sessions | `/expert-panel --list` |
| Export panel discussion to markdown | `/expert-panel --export {panel-id}` |
| Reflect on session improvements | `Skill("reflect")` |
| Capture learnings | `Skill("learn")` |
| Evaluate a skill | `Skill("skill-eval")` |
| Brainstorm ideas | `Skill("brainstorming")` |

## Commands

| Command | Description |
|---------|-------------|
| `/interview` | Domain-aware discovery for engineering, brand, product, marketing, or sales |

## Skills

Invoke with: `skill majestic-tools:<name>`

| Skill | Description |
|-------|-------------|
| `brainstorming` | Refine rough ideas into fully-formed designs through collaborative questioning |
| `compound-learnings` | Identify and persist valuable patterns as reusable artifacts |
| `devils-advocate` | Challenge ideas and expose weak reasoning |
| `learn` | Extract cross-session patterns from git history and handoffs, recommend artifacts |
| `reflect` | Reflect on the current session and suggest AGENTS.md improvements |
| `skill-eval` | Test and iterate on a skill using parallel eval runs with graded results |

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
/interview "brand voice"       # → brand domain
/interview "new campaign"      # → marketing domain
/interview "sales pitch"       # → sales domain
/interview "user needs"        # → product domain
/interview "new feature"       # → engineering domain (default)

# Expert panel discussions
/expert-panel "Should we migrate from monolith to microservices?"
/expert-panel "What's the best authentication strategy for our SaaS app?"
/expert-panel --list                                    # List saved sessions
/expert-panel --resume 20251209-150000-microservices    # Resume discussion
/expert-panel --export 20251209-150000-microservices    # Export to markdown

# Reflect on improvements
Skill("reflect")

# Capture cross-session learnings
Skill("learn")

# Brainstorm before implementing
Skill("brainstorming")
```

## Interview Command Deep Dive

The `/interview` command provides domain-aware discovery through conversational probing.

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
