# Changelog

All notable changes to majestic-tools will be documented in this file.

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
