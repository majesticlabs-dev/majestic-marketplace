# Changelog

All notable changes to majestic-engineer will be documented in this file.

## [1.13.0] - 2025-11-30

### Added

- `workflow:github-resolver` agent - Resolve CI failures and PR review comments with auto-detection for Ruby, Node.js, Python, Go, and Rust projects (migrated from majestic-rails and generalized)

## [1.12.2] - 2025-11-30

### Changed

- Added short aliases for git commands: `/commit`, `/create-pr`, `/changelog`, `/pr-review`

## [1.12.1] - 2025-11-30

### Fixed

- Removed `name:` from command frontmatter to restore path-based naming (`/majestic-engineer:workflows:*`)

## [1.12.0] - 2025-11-30

### Added

- `/workflows:guided-prd` command for discovering and refining product ideas through guided questioning before PRD generation

## [1.11.0] - 2025-11-27

### Added

- `qa:visual-validator` agent for skeptical visual QA - verify UI changes through screenshot analysis, accessibility verification, and design system compliance

## [1.10.0] - 2025-11-27

### Added

- `research:repo-analyst` agent for repository onboarding - analyze structure, conventions, issue templates, and implementation patterns

## [1.9.0] - 2025-11-27

### Added

- `research:docs-architect` agent for creating comprehensive technical documentation from codebases

## [1.7.0] - 2024-11-27

### Changed
- Moved `build` and `plan` commands to majestic-rails (Rails-specific workflows)
- Commands reduced from 9 to 7

### Added
- `test-reviewer` agent for reviewing test quality, coverage, and edge cases

## [1.6.0] - 2024-11-27

### Fixed
- Updated agent references in workflow commands to use correct names

## [1.5.0] - 2024-11-26

### Added
- Initial release with 12 agents, 9 commands, and 12 skills
- Research agents: web-research, git-researcher, docs-researcher, best-practices-researcher
- Planning agents: architect, plan-review, spec-reviewer, refactor-plan
- QA agents: security-review, test-create
- Workflow agent: ship
- Design agent: ui-ux-designer
