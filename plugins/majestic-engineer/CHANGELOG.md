# Changelog

All notable changes to majestic-engineer will be documented in this file.

## [3.2.0] - 2025-12-15

### Enhanced

- **`/majestic:build-task`** - Now supports plan files and auto-detection
  - Accept `docs/plans/*.md` files directly (from `/majestic:plan`)
  - Auto-detect most recent plan if no argument given
  - Skips task-fetcher, claim, and completion steps for plan files
  - Uses plan content directly for build step (skips architect planning)

### Changed

- **Renamed `/majestic:design-plan` → `/majestic:ux-brief`** - Clearer name that signals UI/UX focus

## [3.0.1] - 2025-12-13

### Changed

- **`/majestic:prd`** - Added `--guided` flag for interactive discovery mode
  - Default: Batch 3-5 clarifying questions upfront
  - `--guided`: One question at a time with context gathering and synthesis

### Removed

- **`/majestic:guided-prd`** - Merged into `/majestic:prd --guided`
  - Use `/majestic:prd --guided` for the same interactive discovery flow
  - Follows DRY principle: one command with a flag vs two separate commands

## [3.0.0] - 2025-12-12

### Changed

- **Refactored** - All skills trimmed to ≤500 lines, verbose examples extracted to `resources/`
- **Version unified** - All majestic plugins now at v3.0.0

## [1.40.1] - 2025-12-11

### Fixed

- **`/majestic:build-task`** - Fixed terminal title setting (Step 3)
  - Replaced ambiguous `Skill: majestic-tools:set-title` pseudo-syntax with direct Bash escape sequence
  - Now uses `printf '\033]0;...\007'` which works reliably in Claude Code's terminal

## [1.40.0] - 2025-12-09

### Changed

- **Performance optimization** - Replaced `config_get()` bash blocks with inline bash mode (`!` prefix)
  - Config values now load automatically before Claude sees the prompt (zero execution tokens)
  - Updated commands: `code-review`, `debug`, `add-lesson`
  - Updated agents: `github-resolver`, `quality-gate`, `ship`, `task-fetcher`, `task-status-updater`, `workspace-setup`
  - Net savings: ~100 lines removed across 9 files

## [1.39.0] - 2025-12-08

### Enhanced

- **Commands** - Adopted Claude Code v2.0.62 UX improvements
  - Added "(Recommended)" indicators to `AskUserQuestion` options where there's a clear best choice
  - Updated `/majestic:plan` - "Start building" marked as recommended
  - Updated `/majestic:prd` - "Done" marked as recommended (balanced PRD is sufficient by default)
  - Updated `/majestic:ux-brief` - "Start building" marked as recommended
  - Updated `/changelog` - "Display only" marked as recommended
  - Added `argument-hint:` frontmatter to `/pr-review` and `/pickup` commands for better discoverability

## [1.38.0] - 2025-12-08

### Enhanced

- **`mermaid-builder` skill** - Added comprehensive data lineage visualization patterns
  - Simple Data Pipeline pattern (ETL processes)
  - Multi-Layer Data Architecture (data lake/warehouse layers)
  - Cross-System Data Flow (with timing and sequence diagrams)
  - Database Schema Lineage (table relationships and provenance)
  - Data Transformation Flow with Metadata (quality checks, record counts)
  - Streaming Data Lineage (Kafka/Kinesis patterns)
  - Column-Level Lineage (field-level data provenance)
  - Best practices for data lineage diagrams (metadata, transformations, styling)
  - Common anti-patterns to avoid (too much detail, bidirectional flows, missing transformations)

## [1.37.0] - 2025-12-07

### Added

- **`config-reader` agent** - Centralized config reading with proper layering
  - Reads `.agents.yml` (base config) then `.agents.local.yml` (local overrides)
  - Returns merged config with local values taking precedence
  - Uses haiku model for fast execution
  - Gray color for utility/infrastructure agent

### Changed

- **Renamed `preview_created_files` to `auto_preview`** - Shorter, clearer setting name
- **Updated auto-preview pattern** - Commands now use `config-reader` agent instead of inline Read calls
  - `/majestic:plan`
  - `/majestic:prd`
  - `/majestic:ux-brief`
  - `/majestic:handoff`
- **Imperative instructions** - Auto-preview check now uses "MUST" language to ensure execution
- **Fixed agent count** - Updated description from 20 to 25 agents (was out of sync)

## [1.36.0] - 2025-12-07

### Fixed

- **`/majestic:init-agents-md`** - Now properly creates hierarchical AGENTS.md structure
  - Added Step 1.0: Check existing state for existing codebases (Regenerate/Enhance/Skip options)
  - Added Step 1.2-1.4: Explicit phases with verification checkpoints
  - Added final verification to confirm sub-folder AGENTS.md files were created
  - Updated output summaries to show hierarchical structure expectations

## [1.35.0] - 2025-12-06

### Added

- **`cloudflare-worker` skill** - Build edge-first TypeScript applications on Cloudflare Workers
  - Covers Workers API, Hono framework, KV/D1/R2 storage, Durable Objects, Queues
  - Testing patterns with Vitest + Miniflare
  - WebSocket Hibernation API patterns for Durable Objects
  - Common patterns: API key auth, rate limiting, caching, background tasks
  - CLI command reference for wrangler

## [1.34.0] - 2025-12-05

### Added

- **`quality_gate` config section** - Customize which reviewers run during quality gate checks
  - Override semantics: configured list completely replaces defaults
  - Shorthand names resolve to full agent paths (e.g., `security-review` → `majestic-engineer:qa:security-review`)
  - 12 reviewers available: security, test, project-topics, simplicity, pragmatic-rails, performance, data-integrity, dhh, python, react, codex, gemini
  - Tech stack-specific defaults when not configured

### Changed

- **`quality-gate` agent** - Now reads `quality_gate.reviewers` from `.agents.yml` before falling back to tech stack defaults
- **`/majestic:init-agents-md`** - Generates `quality_gate` section in all templates (Rails, Python, Node, Generic)
- **`CLAUDE.md`** - Added Quality Gate Fields documentation with available reviewers table

## [1.29.0] - 2025-12-04

### Added

- **`pr-screenshot-docs` skill** - Capture and document UI changes with before/after screenshots for pull requests
  - Mobile-first screenshot workflow (320px default viewport)
  - PR description template with before/after comparison table
  - Viewport recommendations for different component sizes
  - Best practices for visual documentation in code review
  - Integrates with `visual-validator` and `ui-ux-designer` agents

## [1.27.0] - 2025-12-04

### Added

- **`AGENTS_CONFIG` environment variable** - Override the default `.agents.yml` config filename
  - All commands and scripts use `${AGENTS_CONFIG:-.agents.yml}` pattern
  - Allows custom config paths per-project (e.g., `export AGENTS_CONFIG=".my-config.yml"`)
  - Backward compatible - defaults to `.agents.yml` when not set

### Changed

- Updated all commands, agents, and scripts to support `AGENTS_CONFIG` override:
  - Git commands: `create-pr`, `changelog`, `code-story`
  - Workflow commands: `code-review`, `debug`, `build-task`
  - Agents: `github-resolver`, `ship`, code review orchestrators
  - Scripts: `worktree-manager.sh`

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

- `/majestic:ux-brief` command - Plan UI/UX design direction through guided discovery before implementation. Covers aesthetic direction, typography, color, motion, and integrates with `frontend-design` skill and `ui-ux-designer` agent.

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
