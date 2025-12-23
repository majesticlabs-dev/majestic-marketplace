# Changelog

All notable changes to majestic-rails will be documented in this file.

## [3.12.0] - 2025-12-22

### Added

- **`litestream-coder` skill** - Continuous SQLite backup for Rails 8+ production apps:
  - Retention strategies by database type (main: 7d, cache: 1d, queue: 3d, cable: 1d)
  - Kamal 2 accessory configuration with read-only volume mount
  - Disaster recovery and point-in-time restore procedures
  - S3-compatible storage configuration (Hetzner, Backblaze, DigitalOcean)
  - Best practices for monitoring and testing restores

## [3.11.0] - 2025-12-22

### Added

- **`dialog-patterns` zero-JavaScript patterns** - Modern Invoker Commands API for dialogs without JavaScript:
  - `commandfor`/`command` attributes for declarative dialog control
  - `closedby="any"` for backdrop click and ESC dismissal
  - CSS `@starting-style` animations (no JS required)
  - `Turbo.config.forms.confirm` integration for styled confirmations
  - Browser support table (Chrome 135+, Firefox 144+, Safari 26.2+)
  - Decision guide: when to use zero-JS vs Stimulus patterns

### Changed

- **`dialog-patterns` refactored** - Extracted verbose patterns to resources:
  - `resources/zero-js-patterns.md` - Complete Invoker Commands examples
  - `resources/toast-slideover-patterns.md` - Full Toast/Slideover implementations
  - Main skill reduced from 487 to 433 lines while adding new content

## [3.10.0] - 2025-12-21

### Added

- **`database-optimizer` aggregate patterns** - New section in `resources/database-optimizer/patterns.md`:
  - `COUNT(*) FILTER (WHERE ...)` - Cleaner conditional aggregation than CASE WHEN
  - `LAG()/LEAD()` window functions for period-over-period comparisons
  - Month-over-month and year-over-year growth rate calculations
  - Rails scope examples and integration patterns

- **Rails slow query monitoring** - New section in `resources/database-admin/postgresql.md`:
  - `ActiveSupport::Notifications.subscribe` pattern for catching slow queries
  - Honeybadger/Sentry integration with context
  - Structured JSON logging variant for DataDog/CloudWatch
  - Sampling variant for high-traffic applications

## [3.9.0] - 2025-12-21

### Added

- **`hotwire-coder` lazy loading reference** - Comprehensive patterns for Turbo Frame lazy loading:
  - Skeleton UI placeholders (tables, cards, lists)
  - Reusable SkeletonComponent with ViewComponent
  - Infinite scroll with nested lazy frames
  - Stimulus loading controllers (spinner, progress bar)
  - Best practices for CLS prevention

## [3.8.0] - 2025-12-20

### Added

- **`anycable-coder` skill** - Real-time features with reliability guarantees:
  - LLM streaming patterns with at-least-once delivery
  - AnyCable vs Action Cable comparison and migration guide
  - Server-side channel implementations for streaming
  - Client-side JavaScript with @anycable/web
  - Presence tracking API
  - Deployment configuration (Procfile, Docker)
  - Based on Evil Martians' "AnyCable, Rails, and the pitfalls of LLM-streaming"

## [3.7.0] - 2025-12-20

### Added

- **`references/structured-events.md`** - Rails 8.1 `Rails.event` API for structured observability:
  - Core API: `Rails.event.notify` and `Rails.event.debug` (no traditional log levels)
  - Tags for nested context with stacking blocks
  - Request-scoped context via `Rails.event.set_context`
  - Custom event classes for strongly-typed payloads
  - Subscriber pattern for multiple destinations (Datadog, Sentry, etc.)
  - Migration guide from `Rails.logger`
  - Common patterns: model callbacks, job instrumentation, service tracing

## [3.6.0] - 2025-12-20

### Enhanced

- **`references/recording-pattern.md`** - Comprehensive update with 37signals video insights:
  - **Immutable Recordables** - Content never updated in place; new versions created for edits
  - **Version History via Events** - Events snapshot recordable_id for precise time-travel
  - **Zero-Cost Copying** - New Recording points to existing Recordable (no data duplication)
  - **Capability Pattern** - Recordables define `subscribable?`, `commentable?`, `exportable?` etc.
  - **Buckets as Security Boundaries** - Access control at container level, recordables are "dumb"
  - **Tree Structure** - Hierarchical parent/child queries through recordings table
  - **Global Timeline** - Efficient cross-type pagination with single-table queries
  - **Russian Doll Caching** - Recording-level cache keys for all content types
  - **Resilient API** - Mobile clients handle unknown types gracefully
  - **Pros/Cons Analysis** - Comprehensive trade-offs for pattern adoption

## [3.5.0] - 2025-12-20

### Added

- **`coding_styles` in toolbox manifest** - Rails toolbox now declares `dhh-coder` as default coding style
  - Automatically activates DHH's 37signals style during `/majestic:build-task` for Rails projects
  - Configurable: users can override or add styles in `.agents.yml`

### Changed

- **Toolbox manifest structure** - Added `coding_styles` field to `toolbox.yml`
  - Default: `[majestic-rails:dhh-coder]`
  - Follows new consolidated schema from majestic-engineer 3.5.0

## [3.3.4] - 2025-12-20

### Enhanced

- **`dhh-coder` skill** - Added patterns from compound-engineering plugin:
  - **State as Records** - Explicit guidance on using database records instead of boolean columns for state tracking
  - **REST URL Transformations** - Table mapping custom actions to nested resource controllers (e.g., `POST /cards/:id/close` → `POST /cards/:id/closure`)
  - **Success Indicators** - 9-item checklist for validating DHH style compliance
- **`references/patterns.md`** - Enhanced scope naming catalog:
  - Added ordering scopes: `chronologically`, `reverse_chronologically`, `latest`, `recently_updated`
  - Added indexed lookups: `indexed_by_room`, `indexed_by_creator`
  - Added `preloaded` scope for full eager loading
  - New Scope Naming Conventions table with 8 patterns

## [3.3.2] - 2025-12-17

### Fixed

- **Bash permission errors** - Replaced `!` interpolations with `config-reader` agent invocation
  - `rails-code-review-orchestrator` and `/rails:build` command now use `config-reader` agent
  - Eliminates compound bash commands that failed Claude Code permission checks

## [3.1.0] - 2025-12-14

### Added

- **`references/stimulus-catalog.md`** - 11 copy-paste-ready Stimulus controllers
  - clipboard, toggle, autoresize, hotkey, local-time, fetch-on-visible, dialog, form, local-save, element-removal, auto-click
  - Design principles: static values, dispatch for communication, private methods
- **`references/css-architecture.md`** - Native CSS patterns (no Sass/Tailwind)
  - CSS @layer system for cascade control
  - OKLCH color system with programmatic manipulation
  - Native CSS nesting patterns
  - Dark mode (system preference + manual toggle)
- **Multi-tenancy via URL structure** in `references/config-tips.md`
  - AccountSlug middleware pattern
  - SCRIPT_NAME-based URL generation
  - Testing helpers for account-scoped tests

### Enhanced

- **`dhh-code-reviewer` agent** - Added comprehensive "What 37signals Deliberately Avoids" section
  - 10 categories: Auth, Authorization, Jobs, Caching, WebSockets, Testing, Architecture, JavaScript, CSS, Infrastructure
  - Each with: what to avoid, why, and the vanilla Rails alternative

## [3.0.1] - 2025-12-13

### Removed

- **`/rails:code-review` command** - Redundant with `/majestic:code-review` which auto-detects Rails projects
  - Use `/majestic:code-review` instead (delegates to same orchestrator for Rails projects)
  - Follows DRY/YAGNI principles

## [3.0.0] - 2025-12-12

### Changed

- **Refactored** - All agents trimmed to ≤300 lines, templates extracted to `resources/`
- **Refactored** - All skills trimmed to ≤500 lines, verbose examples extracted to `resources/`
- **Version unified** - All majestic plugins now at v3.0.0

## [1.27.0] - 2025-12-09

### Changed

- **Performance optimization** - Replaced `config_get()` bash blocks with inline bash mode (`!` prefix)
  - Config values now load automatically before Claude sees the prompt (zero execution tokens)
  - Updated commands: `build`, `code-review`
  - Updated agents: `code-review-orchestrator`
  - Net savings: ~50 lines removed across 3 files

## [1.26.0] - 2025-12-08

### Enhanced

- **Commands** - Adopted Claude Code v2.0.62 UX improvements
  - Added "(Recommended)" indicators to `AskUserQuestion` options where there's a clear best choice
  - Updated `/rails:build` - "Parallel work with worktree" marked as recommended for better workflow isolation
  - Updated `/gemfile:upgrade` - "Upgrade to latest minor" marked as recommended and placed first (safer than major upgrades)

## [1.23.0] - 2025-12-05

### Added

- `event-sourcing-coder` skill - Pragmatic event sourcing for Rails monoliths
  - Record domain events with typed metadata and throttling
  - Inbox pattern for decoupled event processing (notifications, webhooks, automation)
  - Activity feeds, audit trails, and analytics patterns
  - Integration with AASM state machines
  - Based on BoringRails "Event Sourcing for Smooth Brains" pattern
  - Includes 3 reference files: event-model.md, inbox-pattern.md, use-cases.md

## [1.22.1] - 2025-12-04

### Enhanced

- **action-policy-coder** agent - Added advanced caching patterns from AppSignal blog:
  - External cache stores (Redis) - configuration for cross-request persistence
  - Policy instance memoization - `policy_cache_key` override and collection permission preloading

## [1.22.0] - 2025-12-04

### Enhanced

- **Code review orchestrator** - Now reads `app_status` from `.agents.yml` to adjust breaking change severity
  - `production` → Breaking changes are P1 Critical (blocker)
  - `development` → Breaking changes are P2 Important (informational)

## [1.20.0] - 2025-12-03

### Changed

- **BREAKING**: All agents now use simple naming without prefixes - Claude Code auto-namespaces with plugin + directory path
  - Old: `agent majestic-rails:research:gem-research`
  - New: `agent gem-research`
  - Display: `majestic-rails:research:gem-research`
  - Code review orchestrator renamed: `rails-code-review` (to avoid collision with Python plugin)
- Updated all documentation with new agent names

## [1.16.1] - 2025-12-02

### Enhanced

- `dhh-coder` skill - Added 5 new reference files based on 37signals Fizzy SaaS patterns:
  - `concerns-organization.md` - Model-specific vs common concerns, facade pattern
  - `delegated-types.md` - Polymorphism without STI problems
  - `caching-strategies.md` - Russian Doll caching, Solid Cache, performance analysis formula
  - `turbo-morphing.md` - Turbo 8 page refresh with morphing (`broadcast_refresh`)
  - `recording-pattern.md` - Unifying abstraction for diverse content types
- `dhh-coder` skill - Updated `resources.md` with Fizzy SaaS repository links and 37signals Dev blog articles
- Added "Fizzy" as trigger keyword in skill description

## [1.16.0] - 2025-11-30

### Added

- `store-model-coder` skill - Wrap JSON-backed database columns with ActiveModel-like classes using store_model gem

## [1.15.0] - 2025-11-30

### Removed

- `github-resolver` agent - Migrated to majestic-engineer as a generic, language-agnostic agent (use `agent majestic-engineer:workflow:github-resolver` instead)

## [1.14.2] - 2025-11-30

### Fixed

- Removed `name:` from command frontmatter to restore path-based naming (`/majestic-rails:gemfile:*`, `/majestic-rails:workflows:*`)

## [1.14.1] - 2025-11-29

### Enhanced

- `database-optimizer` agent - Added mechanical sympathy section (pages/buffers/MVCC/HOT updates), keyset pagination strategies, pagy gem, query source logging
- `database-admin` agent - Added pghero gem integration, autovacuum tuning, data lifecycle management (archival, partitioning, materialized views, rollups)
- `data-integrity-reviewer` agent - Added safety-linted SQL tools section (strong_migrations, database_consistency, squawk, anchor_migrations)
- `performance-reviewer` agent - Added defensive patterns (strict_loading, query timeouts, idle transaction timeouts), counter caches, prepared statements

## [1.14.0] - 2025-11-27

### Added

- `gemfile:organize` command - Organize Gemfile with categorized sections and alphabetized gems
- `gemfile:upgrade` command - Upgrade gems safely with changelog review and testing

### Changed

- Total commands increased from 3 to 5

## [1.13.0] - 2025-11-27

### Added

- `viewcomponent-coder` skill - Build component-based UIs with ViewComponent, slots, variants, and Lookbook previews
- `inertia-coder` skill - Build modern SPAs with Inertia.js + Rails using React, Vue, or Svelte (includes framework-specific reference docs)
- `business-logic-coder` skill - Implement business logic with ActiveInteraction (typed operations, composition) and AASM state machines

### Changed

- Total skills increased from 5 to 8
- Added keywords: viewcomponent, inertia, inertia-js, active-interaction, aasm, state-machine

## [1.12.0] - 2025-11-27

### Added

- `action-policy-coder` agent - Authorization with ActionPolicy including policies, scopes, caching, I18n, testing, and GraphQL integration

## [1.11.0] - 2025-11-27

### Added

- `graphql-architect` agent - Design GraphQL schemas, resolvers, and subscriptions using graphql-ruby, graphql-batch, and ActionCable patterns

## [1.10.0] - 2025-11-27

### Added
- `database-optimizer` agent - Advanced query optimization, EXPLAIN ANALYZE interpretation, complex SQL (CTEs, window functions), indexing strategies for PostgreSQL/SQLite
- `database-admin` agent - Database operations, backups (pg_dump), monitoring (pg_stat_statements), connection pooling (PgBouncer), maintenance for PostgreSQL/SQLite

### Changed
- Total agents increased from 19 to 21
- Added keywords: postgresql, sqlite, database

## [1.9.0] - 2025-11-27

### Added
- `active-job-coder` agent - Create background jobs with Rails 8 conventions, Solid Queue patterns, retry strategies, and concurrency control
- `action-mailer-coder` agent - Create emails with parameterized mailers, callbacks, previews, and background delivery
- `frontend/stimulus-coder` agent - Create Stimulus controllers with targets, values, actions, and Turbo integration
- `solid-queue-coder` agent - Configure Solid Queue for database-backed job processing (Rails 8 default)
- `solid-cache-coder` agent - Configure Solid Cache for database-backed caching (Rails 8 default)

### Changed
- Enhanced `frontend/hotwire-coder` with Turbo 8 morphing, broadcasts with strict locals, and comprehensive patterns
- Total agents increased from 14 to 19

## [1.8.0] - 2025-11-27

### Added
- `review` command - Comprehensive code review using smart agent selection
  - Supports multiple scope modes: PR, branch, staged, or specific files
  - Smart agent selection based on changed file types
  - Always runs simplicity-reviewer and pragmatic-rails-reviewer
  - Conditionally adds data-integrity, dhh-code, or performance reviewers
  - Consolidated P1/P2/P3 severity output with APPROVED/NEEDS CHANGES/BLOCKED status

## [1.7.0] - 2024-11-27

### Added
- `build` command - Execute work plans for Rails features
- `plan` command - Transform feature descriptions into Rails project plans
- Commands section added (2 commands)

### Changed
- Workflows moved from majestic-engineer to majestic-rails (Rails-specific)

## [1.6.0] - 2024-11-26

### Added
- Initial release with 14 agents and 5 skills
- Core agents: rails-refactorer, rails-debugger, rubocop-fixer, github-resolver, lint
- Frontend agents: hotwire-coder, tailwind-coder
- Admin agents: avo-coder
- Research agents: gem-research
- Review agents: dhh-code-reviewer, pragmatic-rails-reviewer, performance-reviewer, data-integrity-reviewer, simplicity-reviewer
- Skills: ruby-coder, rspec-coder, minitest-coder, dhh-coder, gem-builder
