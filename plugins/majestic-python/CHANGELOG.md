# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2025-12-12

### Added

**Agents (5 new, 8 total)**
- `fastapi-coder` - Modern async FastAPI development with Pydantic, dependency injection, background tasks
- `pytest-coder` - Comprehensive pytest patterns with fixtures, parametrization, async testing
- `django-coder` - Django models, views, DRF, admin, services pattern
- `python-debugger` - Error diagnosis, pdb, traceback analysis, debugging strategies
- `python-db` - SQLAlchemy 2.0, async patterns, Alembic migrations, query optimization

### Changed

- **Version unified** - All majestic plugins now at v3.0.0

## [1.7.0] - 2025-12-09

### Changed

- **Performance optimization** - Replaced `config_get()` bash blocks with inline bash mode (`!` prefix)
  - Config values now load automatically before Claude sees the prompt (zero execution tokens)
  - Updated agents: `code-review-orchestrator`
  - Net savings: ~20 lines removed

## [1.6.0] - 2025-12-04

### Enhanced

- **Code review orchestrator** - Now reads `app_status` from `.agents.yml` to adjust breaking change severity
  - `production` → Breaking changes are P1 Critical (blocker)
  - `development` → Breaking changes are P2 Important (informational)

## [1.4.0] - 2025-12-03

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
