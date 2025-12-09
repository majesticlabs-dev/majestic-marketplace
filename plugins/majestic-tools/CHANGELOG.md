# Changelog

All notable changes to majestic-tools will be documented in this file.

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
