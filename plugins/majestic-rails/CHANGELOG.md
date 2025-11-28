# Changelog

All notable changes to majestic-rails will be documented in this file.

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
