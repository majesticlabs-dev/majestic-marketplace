# Changelog

All notable changes to majestic-tools will be documented in this file.

## [3.2.0] - 2025-12-20

### Removed

- **External LLM agents and commands extracted to majestic-llm** - All external LLM integration moved to dedicated plugin
  - `codex-consult` agent → `majestic-llm`
  - `codex-reviewer` agent → `majestic-llm`
  - `gemini-consult` agent → `majestic-llm`
  - `gemini-reviewer` agent → `majestic-llm`
  - `multi-llm-coordinator` agent → `majestic-llm`
  - `/external-llm:consult` command → `/majestic-llm:consult`
  - `/external-llm:review` command → `/majestic-llm:review`
  - Users should install `majestic-llm` plugin for external LLM features

## [3.1.0] - 2025-12-17

### Added

- **Commands HUD** - `/majestic:commands-hud` displays all marketplace commands in a formatted table
  - Groups by plugin (default) or category
  - Filter by specific plugin with `--plugin`
  - Helper script at `helpers/hud-commands.sh`

## [3.0.0] - 2025-12-12

### Changed

- **Version unified** - All majestic plugins now at v3.0.0

## [1.14.0] - 2025-12-09

### Changed

- **Expert Panel Moved to majestic-experts** - Expert panel discussion system moved to dedicated plugin
  - `/expert-panel` command → `majestic-experts`
  - `expert-panel-discussion` agent → `majestic-experts`
  - `expert-perspective` agent → `majestic-experts`
  - Users should install `majestic-experts` plugin for panel discussions

## [1.13.0] - 2025-12-09

### Added

- **Dynamic Expert Discovery** - Expert panel now discovers experts from `majestic-experts` plugin
  - Auto-loads expert registry from `plugins/majestic-experts/experts/_registry.yml`
  - Expert definitions loaded on-demand for authentic persona embodiment
  - Fallback to built-in experts if plugin not installed
  - User configuration via `.agents.yml`:
    - `expert_panel.enabled_categories` - Enable only specific categories
    - `expert_panel.disabled_categories` - Disable unwanted categories
    - `expert_panel.disabled_experts` - Remove individual experts
    - `expert_panel.custom_experts_path` - Add project-specific experts

### Changed

- **expert-panel.md** - Updated Step 3 for dynamic expert discovery with filtering
- **expert-panel-discussion.md** - Now passes expert definition paths to panelists
- **expert-perspective.md** - Reads definition files for authentic voice and positions

## [1.12.0] - 2025-12-09

### Added

- **Expert Panel Discussion System** - Multi-agent expert panel for exploring difficult questions
  - `/expert-panel` command - Lead structured expert discussions from multiple perspectives
  - `expert-panel-discussion` orchestrator agent - Manages rounds, launches experts, synthesizes findings
  - `expert-perspective` agent - Simulates individual expert voices with authentic reasoning
  - Support for 4 discussion types:
    - `round-table` - Quick single-round perspectives (5-10 min)
    - `debate` - Two opposing camps with rebuttals (10-20 min)
    - `consensus-seeking` - Iterate until agreement or impasse (10-30 min)
    - `deep-dive` - Three-round sequential exploration (20-40 min)
  - Color-coded experts (🔴🔵🟢🟡🟣) for visual distinction
  - Parallel expert invocation for efficiency
  - Sequential thinking integration for orchestrator analysis
  - Synthesis with consensus, divergence, and unique insights
  - Actionable recommendations with confidence assessment
  - **Save/Resume Functionality** - Persist and continue expert panel sessions
    - `/expert-panel --list` - List all saved panel sessions with metadata
    - `/expert-panel --resume {panel-id}` - Resume in-progress discussions from any round
    - `/expert-panel --export {panel-id}` - Export completed panels to markdown
    - JSON session persistence in `.claude/panels/` directory
    - Automatic state saving after each round completion
    - Context reconstruction from previous rounds when resuming

## [1.11.3] - 2025-12-08

### Fixed

- **plugin.json** - Removed redundant hooks field
  - Claude Code automatically loads hooks/hooks.json
  - Manifest should only reference additional hook files
  - Fixes "Duplicate hooks file detected" error

## [1.11.2] - 2025-12-08

### Changed

- **Hooks** - Removed confetti Stop hook from shipped hooks
  - Moved confetti.sh to examples/hooks/ for optional user installation
  - Confetti is fun but opinionated - better as an opt-in example
  - Plugin now ships with only the file-size-checker PostToolUse hook

## [1.11.1] - 2025-12-08

### Fixed

- **hooks.json** - Updated schema to match Claude Code requirements
  - Wrapped hook definitions in top-level "hooks" object
  - Fixes "invalid_type" error when loading plugin

## [1.11.0] - 2025-12-08

### Enhanced

- **Commands** - Adopted Claude Code v2.0.62 UX improvements
  - Added `argument-hint:` frontmatter to 5 meta commands for better discoverability
  - `/spotlight` - "[topic or question to challenge]"
  - `/new-prompt` - "[prompt description or 'optimize: <prompt>']"
  - `/new-agent` - "[agent-description]"
  - `/new-hook` - "[hook-description]"
  - `/list-tools` - "[optional: context or category]"

## [1.10.1] - 2025-12-07

### Changed

- Renamed external LLM "brainstorm" agents to "consult" for clearer intent
  - `codex-brainstorm` → `codex-consult`
  - `gemini-brainstorm` → `gemini-consult`
  - `/external-llm:brainstorm` → `/external-llm:consult`
- Updated `multi-llm-coordinator` references to use new naming

## [1.7.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simplified simple naming without prefixes (Claude Code auto-namespaces) prefix for easier invocation
  - Old: `agent majestic-tools:reasoning-verifier`
  - New: `agent reasoning-verifier`
- Updated all documentation with new agent names

## [1.7.0] - 2025-12-03

### Added

- `set-title` agent - Set terminal window title via ANSI escape sequences to identify what each Claude Code session is working on. Supports `CLAUDE_TITLE_PREFIX` environment variable for custom prefixes. Compatible with Ghostty, iTerm2, Alacritty, Kitty, and other modern terminals.

## [1.2.1] - 2025-11-30

### Fixed

- Removed `name:` from `spotlight` command frontmatter, added missing description
- Added documentation about `name:` field trade-offs in `/new-command` template

## [1.2.0] - 2025-11-30

### Added
- `reasoning-verifier` agent using Reverse Chain-of-Thought (RCoT) methodology to verify and correct LLM reasoning by detecting overlooked conditions and hallucinated assumptions

## [1.1.1] - 2025-11-30

### Enhanced
- `/new-prompt` command now supports prompt optimization in addition to prompt creation
  - Optimization mode: analyze and improve existing prompts
  - Creation mode: build new prompts from scratch (existing behavior)
  - Automatic mode detection based on arguments

## [1.1.0] - 2024-11-26

### Added
- Initial release with 10 commands, 3 skills, and 2 hooks
- Meta commands for creating new agents, commands, hooks, and prompts
- Skills for plugin development
- Hooks for workflow automation
