# Changelog

All notable changes to majestic-engineer will be documented in this file.

## [1.26.0] - 2025-12-04

### Added

- **`.agents.yml` config file** - New machine-readable config for project settings
  - `default_branch`, `tech_stack`, `app_status`, `task_management`, `workflow`, `branch_naming`, `review_topics_path`
  - Commands now read config from `.agents.yml` instead of parsing AGENTS.md
  - Avoids shell parsing issues with complex `$()` substitution

### Changed

- `/majestic:init-agents-md` - Refactored to create `.agents.yml` with all config, simplified AGENTS.md to reference config file
- `/majestic:code-review` - Reads `tech_stack` from `.agents.yml`
- `/majestic:build-task` - Reads `workflow` and `branch_naming` from `.agents.yml`
- `/git:code-story` and `/git:changelog` - Read `default_branch` from `.agents.yml`
- Code review orchestrators - Read `review_topics_path` from `.agents.yml`
- `worktree-manager.sh` - Checks `.agents.yml` first for `default_branch`

## [1.25.0] - 2025-12-04

### Added

- `/majestic:design-plan` command - Plan UI/UX design direction through guided discovery before implementation. Covers aesthetic direction, typography, color, motion, and integrates with `frontend-design` skill and `ui-ux-designer` agent.

## [1.24.1] - 2025-12-04

### Fixed

- Fixed duplicate `.worktrees/` entries in `.gitignore` - improved regex pattern to handle trailing whitespace and CRLF line endings

## [1.24.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simplified simple naming without prefixes (Claude Code auto-namespaces) prefix for easier invocation
  - Old: `agent majestic-engineer:research:web-research`
  - New: `agent web-research`
- Updated all documentation with new agent names

## [1.24.0] - 2025-12-03

### Changed

- Updated `build-task` command to set terminal title after fetching the issue using `majestic-tools:set-title` agent (e.g., "🔨 #42: Add user authentication")

## [1.24.0] - 2025-12-03

### Added

- `/git:code-story` command - Generate documentary-style narrative of repository development history. Features 5-pass analysis (overview, timeline, decision points, synthesis, output), smart sampling for large repos, configurable detail levels (minimal/standard/comprehensive), and optional time/commit filtering.

## [1.16.0] - 2025-12-01

### Added

- `/workflows:build-task` command - Autonomous task implementation from GitHub Issues. Orchestrates the full development lifecycle: fetch issue, research (conditional), plan with architect agent, build with general-purpose agent, code review, fix feedback loop (max 3 iterations), and ship via PR with issue closure.

## [1.15.1] - 2025-12-01

### Added

- `beads-viewer.md` reference in backlog-manager skill - Documents bv robot mode commands for AI agent graph analysis

## [1.14.0] - 2025-11-30

### Added

- `/workflows:ship-it` command - Invokes the ship agent for complete checkout workflow (lint, commit, PR)

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
