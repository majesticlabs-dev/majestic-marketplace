# Changelog

All notable changes to majestic-rails will be documented in this file.

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
