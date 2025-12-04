# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simplified simple naming without prefixes (Claude Code auto-namespaces) prefix for easier invocation
  - Old: `agent majestic-python:review:code-review-orchestrator`
  - New: `agent python-code-review`
  - Code review orchestrator renamed to avoid collision with Rails plugin
- Updated all documentation with new agent names

## [1.0.0] - 2025-11-27

### Added

- Initial release of majestic-python plugin
- `python-coder` agent for modern Python 3.12+ development with uv, ruff, FastAPI, async patterns
- `python-reviewer` agent for code review with high quality bar for type hints and Pythonic patterns
