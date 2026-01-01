# Changelog

All notable changes to majestic-engineer will be documented in this file.

## [3.33.0] - 2026-01-01

### Added

- **Learnings Discovery System** - Unified institutional memory for workflows
  - New `lessons-discoverer` agent discovers relevant lessons using Claude headless mode for semantic scoring
  - Lessons are surfaced at the right moment: planning, debugging, review, or implementation
  - Returns paths and scores (not full content) to minimize token overhead
  - Integrates with `/majestic:blueprint`, `/majestic:debug`, and `quality-gate`

- **New config field: `lessons_path`** - Configurable location for lessons storage
  - Default: `.claude/lessons/`
  - Replaces fragmented `review_topics_path` approach with unified system

- **New YAML frontmatter fields for fix-reporter** - Enable discovery opt-in
  - `lesson_type`: antipattern, gotcha, pattern, setup, workflow
  - `workflow_phase`: planning, debugging, review, implementation
  - `tech_stack`: rails, python, react, node, generic
  - `impact`: blocks_work, major_time_sink, minor_inconvenience
  - `keywords`: semantic keywords for task matching

### Changed

- **`/majestic:blueprint`** - New Step 2.5 discovers relevant lessons before research
  - Lessons context passed to architect agent for informed design decisions
  - Non-blocking: failures don't stop workflow

- **`/majestic:debug`** - Discovers similar past issues before investigation
  - High-confidence matches (>70 score) presented first
  - User can read documented solution or continue with full investigation

- **`quality-gate` agent** - New Step 2.6 discovers critical patterns
  - Anti-patterns with workflow_phase: review are injected into all reviewer prompts
  - Consistent pattern checking across all reviewers

- **`fix-reporter` skill** - Now writes to `lessons_path` (default: `.claude/lessons/`)
  - New decision menu option: "Enable discovery" to add workflow_phase fields
  - Template includes commented discovery fields for easy opt-in

- **Config schema bump to 1.5** - See CONFIG-SYSTEM.md for migration guide

### Removed

- **`/majestic:add-lesson` command** - Replaced by fix-reporter with `workflow_phase: review`
- **`project-topics-reviewer` agent** - Replaced by lessons-discoverer with `workflow_phase: review`
- **`review_topics_path` config** - Deprecated, use `lessons_path` instead

### Migration

Replace in `.agents.yml`:
```yaml
# Old
review_topics_path: docs/agents/review-topics.md

# New
lessons_path: .claude/lessons/
```

Create `.claude/lessons/` directory and move review topics to lessons with `workflow_phase: [review]` frontmatter.

## [3.24.1] - 2025-12-29

### Fixed

- **Workflow commands** - Clarity and noise reduction
  - `/majestic:build-task`: Corrected plan-mode skip steps (1, 2, 6, 14 not 1, 2, 7, 15)
  - `/majestic:build-task`: Fixed recovery instructions to use correct command name
  - `/majestic:build-task`: Aligned toolbox-resolver prompt format with documented multiline structure
  - Removed terminal-title from `build-task`, `build-plan`, and `plan` commands (ANSI escape noise)

## [3.24.0] - 2025-12-29

### Fixed

- **Protected branch safety guards** - Prevent accidental commits/pushes to main/master
  - `ship` agent now validates branch before any shipping actions (Step 0: MANDATORY)
  - `build-task` command adds branch check after workspace-setup (Step 3.5: MANDATORY)
  - Defense in depth: both command and agent validate independently
  - Clear error messages with recovery instructions

## [3.23.0] - 2025-12-28

### Enhanced

- **`/changelog` command** - Business-friendly weekly summaries for stakeholders
  - New `weekly-summary` argument: calendar week (Mon-Sun of last week)
  - Defaults to business audience with benefit-focused language
  - No PR numbers or technical jargon
  - Engaging emojis for each bullet point
  - `business` modifier works with any time period (`/changelog daily business`)

## [3.22.0] - 2025-12-28

### Enhanced

- **`/session:pickup` command** - State verification before resuming handoffs
  - Verifies documented files still exist in codebase
  - Detects changes since handoff date via `git log`
  - Validates key code patterns are still present
  - Presents ✅/⚠️/❓ verification summary
  - Asks user to address drift or proceed
  - Skip verification with `--skip-verify` flag
  - Inspired by [Continuous-Claude-v2](https://github.com/parcadei/Continuous-Claude-v2) resume_handoff skill

## [3.21.0] - 2025-12-28

### Added

- **`/majestic:build-plan` command** - Execute all tasks in a plan using build-task workflow
  - Parses `## Implementation Tasks` section from plan file
  - Orders tasks by dependencies
  - Runs `/majestic:build-task` for each task reference
  - Updates plan checkboxes as tasks complete
  - Integrates with ralph-wiggum for autonomous execution
  - Outputs `BUILD_PLAN_COMPLETE` promise for ralph loop detection

- **Ralph-wiggum integration in `/majestic:plan`** - New step 10 after task creation
  - "Build all tasks now" option using build-plan
  - "Build with ralph (autonomous)" shows ralph-loop command
  - Enables overnight/walkaway task execution

## [3.20.0] - 2025-12-28

### Added

- **Commit hooks** - Custom pre/post commit prompts for LLM-based validation
  - New config fields: `commit.pre_prompt`, `commit.post_prompt` in `.agents.yml`
  - Pre-commit: validate staged changes (debug statements, TODOs, secrets)
  - Post-commit: trigger follow-up actions (changelog updates, notifications)
  - Non-blocking execution: reports issues but continues
  - Added Read, Grep, Edit tools to `/commit` command for hook execution

## [3.17.0] - 2025-12-27

### Added

- **Task breakdown agent** - Break implementation plans into small, actionable tasks
  - New `task-breakdown` agent in `agents/plan/`
  - Uses Fibonacci story points based on Complexity + Effort + Uncertainty
  - Target: 1-3 points per task; tasks above 3 trigger `architect` agent for decomposition
  - Assigns task priorities (p1, p2, p3)
  - Creates parallelization matrix showing concurrent execution groups
  - Identifies dependencies between tasks
  - Appends `## Implementation Tasks` section to plan file
  - If > 10 tasks, stops and suggests splitting into epics

- **Task breakdown integration in `/majestic:plan`** - New post-generation option
  - "Break into small tasks" option after plan creation
  - Agent stores tasks in plan document only (no external creation)
  - User reviews tasks, then optionally creates in task manager
  - Task creation handled by main `/majestic:plan` command when approved

- **Post-create hooks for workspace-setup** - Run project-specific scripts after creating worktree/branch
  - New config: `workspace_setup.post_create` in `.agents.yml`
  - Non-blocking execution: logs warning on failure, continues with setup
  - Report shows hook status: executed, failed, or none configured
  - Example: `bin/setup-worktree` for database isolation, env setup

## [3.16.4] - 2025-12-26

### Fixed

- **Removed redundant test execution from `test-reviewer`** - Now performs static analysis only
  - `always-works-verifier` handles test execution
  - `test-reviewer` focuses on test quality review (coverage gaps, assertion quality, anti-patterns)
  - Prevents duplicate test runs when both agents are used in quality gate

## [3.16.3] - 2025-12-26

### Fixed

- **Terminal title skill not being invoked** - Commands now use explicit `Skill()` call
  - Updated build-task and plan to call `Skill(skill: "majestic-engineer:terminal-title", args: "...")`
  - Updated skill with `allowed-tools: Bash` and clear execution instructions

## [3.16.2] - 2025-12-26

### Added

- **Terminal title support for build-task and plan commands**
  - Build-task: Shows `#<ID>: <short_title>` after fetching task
  - Plan: Shows `<short_feature_summary>` when starting research
  - New `terminal-title` skill with execution instructions

### Fixed

- **Removed incorrect CLAUDE.md learning** about Bash tool not having TTY access

## [3.16.1] - 2025-12-26

### Fixed

- **GitHub labels not applied in build-task workflow** - `task-status-updater` agent now properly manages workflow labels
  - Claim action: Adds `workflow_labels[1]` (in-progress) in addition to removing backlog
  - Ship action: Removes in-progress label, adds `workflow_labels[2]` (ready-for-review)
  - Added explicit instructions for reading `workflow_labels` array from `.agents.yml`
  - Falls back to default labels (`backlog`, `in-progress`, `ready-for-review`, `done`) if not configured

## [3.16.0] - 2025-12-26

### Changed

- **Version bump** for terminal title preparation (features moved to 3.16.2)

## [3.15.3] - 2025-12-26

### Removed

- **Terminal title step from build-task** - Claude Code's Bash tool has no TTY access
  - ANSI escape sequences are captured as text, not interpreted by terminal
  - Neither inline `printf` nor skill invocation can set terminal title
  - Removed non-functional step and renumbered workflow (15 steps → 14 steps)

## [3.15.2] - 2025-12-26

### Fixed

- **Agent references using short names** - Session commands now use fully-qualified agent names
  - `config-reader` → `majestic-engineer:config-reader`
  - `session-checkpoint` → `majestic-engineer:session-checkpoint`
  - Fixes "Agent type not found" errors in `session-checkpoint` agent and `/session:ledger-clear` command

## [3.15.1] - 2025-12-24

### Fixed

- **Terminal title not working in build-task** - Changed from Bash tool to `!` prefix for direct terminal execution
  - Bash tool runs in subprocess without TTY access, escape sequences were captured not displayed
  - `! printf` runs directly in terminal session with TTY access

## [3.13.5] - 2025-12-24

### Fixed

- **Worktree workflow not working in build-task** - Upgraded `workspace-setup` agent from haiku to sonnet
  - Haiku was not reliably following skill invocation instructions for git-worktree
  - Projects with `workflow: worktrees` now correctly create worktrees instead of branches

## [3.13.4] - 2025-12-24

### Fixed

- **Config migration not triggering** - Major workflows now invoke `config-reader` in Mode 1 (full config) first
  - Mode 2 (field lookup) was skipping version check and auto-migration entirely
  - Added "Config Version Check" section to `/majestic:build-task`, `/majestic:plan`, `/majestic:code-review`, `/majestic:quality-gate`
  - Migration to version 1.1 (adding `workflow_labels`) now happens on first workflow use
  - Prevents stale `.agents.yml` files from missing new config fields

## [3.13.3] - 2025-12-24

### Added

- **Auto-actions in config templates** - `/majestic:init` now enables auto-preview and auto-create-task by default
  - All templates (Rails, Python, Node, Generic) include `auto_preview: true` and `auto_create_task: true`
  - `.agents.local.yml` template includes commented override examples
  - CONFIG-SYSTEM.md examples updated to show these fields

## [3.13.2] - 2025-12-24

### Fixed

- **GitHub backend label validation** - backlog-manager now validates labels exist before use
  - Added "BEFORE Any Label Operations" section with `gh label list` validation
  - Prevents `gh issue create` failures from non-existent labels
  - Added safe idempotent label creation commands with error suppression
  - Clear guidance: skip missing labels OR create them first

## [3.13.1] - 2025-12-22

### Fixed

- **`/majestic:build-task` terminal title reliability** - Reverted to inline `printf` ANSI escape
  - Removed `majestic-tools:set-title` skill invocation (skill was deleted as redundant)
  - Direct bash command is simpler and more reliable than skill indirection
  - `Skill` remains in allowed-tools for Step 8 coding_styles

## [3.13.0] - 2025-12-22

### Fixed

- **`/majestic:build-task` terminal title not working** - Step 3 now uses `majestic-tools:set-title` skill
  - Added `Skill` to allowed-tools (also fixes Step 8 coding_styles invocations)
  - Replaced raw `printf` escape sequence with proper skill invocation

- **Missing task reference in PR creation** - PRs now include `Closes #<ID>` for auto-closing
  - `build-task` Step 14 passes task ID to ship-it
  - `ship-it` accepts and forwards `closes #123` argument
  - `ship` agent passes task reference to `/create-pr`
  - `create-pr` includes `Closes #XXX` in PR body when provided

## [3.12.0] - 2025-12-22

### Added

- **Version verification rule in `hierarchical-agents` skill** - AGENTS.md templates now include Implementation Rules section
  - Mandates WebSearch to verify latest versions before adding external dependencies
  - Covers gems, npm packages, GitHub Actions, Docker images, APIs, CDN links
  - Prevents Claude from trusting stale training data for version numbers

## [3.11.0] - 2025-12-22

### Added

- **DevOps-aware planning in `/majestic:plan`** - Plan command now detects infrastructure features
  - Keyword detection for IaC tools, cloud providers, resources, provisioning, edge/serverless, secrets
  - Checks for existing `.tf` and `cloud-init*.yml` files
  - Runs `infra-security-review` agent during research phase when IaC files exist
  - Maps detected providers to relevant `majestic-devops` skills (opentofu-coder, hetzner-coder, etc.)
  - DevOps detection is ADDITIVE - supplements primary tech stack (Rails + DevOps both detected)
  - New "Infrastructure Context" section in all plan templates (MINIMAL, MORE, A LOT)

## [3.10.0] - 2025-12-22

### Changed

- **`/majestic:plan` timestamped filenames** - Plan files now include timestamp prefix for better organization
  - New format: `docs/plans/[YYYYMMDDHHMMSS]_<issue_title>.md`
  - Example: `docs/plans/20250115143022_feat-add-user-authentication.md`

## [3.9.0] - 2025-12-22

### Fixed

- **`/majestic:plan` auto_preview not working** - Rewrote Post-Generation Options section with imperative instructions
  - Changed suggestive "Check for" language to imperative "MUST invoke"
  - Added explicit state tracking (PREVIEWED, TASK_CREATED) for option gating
  - Sequential steps now enforce config-reader invocation before presenting options
  - Options are now state-gated tables instead of disconnected subsections

### Changed

- **`config-reader` agent model** - Changed from `haiku` to `sonnet` for more reliable config parsing

## [3.8.0] - 2025-12-21

### Added

- **`frontend-design` skill enhancements** - Two new resource files for richer design guidance
  - `resources/motion-patterns.md` - Animation timing, scroll reveals, magnetic buttons, Intersection Observer patterns, performance checklist, `prefers-reduced-motion` support
  - `resources/landing-page-design.md` - Section-by-section visual design, dark/light color palettes, typography pairings, single-file HTML patterns
  - Complements `landing-page-builder` skill (copy) with visual implementation guidance

## [3.7.0] - 2025-12-21

### Added

- **`session-checkpoint` agent** - Autonomous agent for saving session state to file
  - Triggered by other agents during long-running workflows
  - Saves goal, decisions, state (done/now/next), and working set
  - Config-gated: requires `session.ledger: true` in `.agents.yml`
  - Survives session crashes for recovery

- **`/session:ledger-clear` command** - Clear the session ledger file
  - Simple reset for starting fresh
  - Respects `session.ledger_path` config if set

- **`session` config section** - New configuration for session state management
  - `session.ledger`: Enable/disable checkpointing (default: false)
  - `session.ledger_path`: Custom ledger file path (default: `.session_ledger.md`)

### Changed

- **CONFIG-SYSTEM.md** - Added session state management documentation

## [3.6.1] - 2025-12-20

### Changed

- **Renamed `/majestic:init-agents-md` to `/majestic:init`** - Simpler, shorter command name
  - All references updated across documentation
  - Helper scripts directory renamed from `init-agents-md/` to `init/`

## [3.5.0] - 2025-12-20

### Added

- **`coding_styles` field in toolbox schema** - New field allows specifying skills to apply during build phase
  - Skills like `dhh-coder`, `tdd-workflow` can now be activated automatically during `/majestic:build-task`
  - Configurable in `.agents.yml` under `toolbox.build_task.coding_styles`

### Changed

- **Consolidated toolbox schema** - All workflow config now lives under `toolbox` section
  - `quality_gate.reviewers` moved to `toolbox.quality_gate.reviewers` (backwards compatible)
  - Consistent precedence: user override → plugin manifest → hardcoded fallback
  - Top-level `quality_gate` is deprecated but still supported

- **Updated agents:**
  - `toolbox-resolver` - Now returns `coding_styles` and supports new schema structure
  - `quality-gate` - Checks `toolbox.quality_gate.reviewers` first, with fallback to deprecated format
  - `build-task` - Passes `coding_styles` to build agent for style-aware implementation

## [3.4.4] - 2025-12-17

### Fixed

- **Bash permission errors** - Replaced `!` interpolations with `config-reader` agent invocation
  - Root cause: `|| echo "default"` in bash commands created compound commands that failed permission checks
  - Solution: Commands/agents now invoke `config-reader` agent to get config values with proper defaults
  - `config-reader` agent enhanced with single field lookup mode: `field: <key>, default: <value>`
  - Benefits: No bash permission issues, proper config merge (`.agents.yml` + `.agents.local.yml`)

### Changed

- **Commands updated** (5 files):
  - `/git:create-pr`, `/git:changelog`, `/git:code-story`, `/majestic:code-review`
- **Agents updated** (7 files):
  - `quality-gate`, `workspace-setup`, `task-fetcher`, `task-status-updater`, `slop-remover`

## [3.4.2] - 2025-12-17

### Fixed

- **Git commands** - Remove `${}` parameter substitution from context expansions
  - `/git:create-pr`, `/git:changelog`, `/git:code-story` now work correctly
  - Claude Code's permission check was blocking shell parameter substitution syntax
  - Simplified default_branch config reading to avoid the issue

## [3.2.0] - 2025-12-15

### Enhanced

- **`/majestic:build-task`** - Now supports plan files and auto-detection
  - Accept `docs/plans/*.md` files directly (from `/majestic:plan`)
  - Auto-detect most recent plan if no argument given
  - Skips task-fetcher, claim, and completion steps for plan files
  - Uses plan content directly for build step (skips architect planning)
  - Slimmed from 589 → 164 lines (lean orchestration for Opus 4.5)

- **`/majestic:plan`** - Auto-create task support
  - New `auto_create_task` config option in `.agents.yml`
  - If enabled, automatically creates GitHub issue / Beads task / Linear issue
  - Reports task link/reference after creation
  - Updated options flow to handle task creation state

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
