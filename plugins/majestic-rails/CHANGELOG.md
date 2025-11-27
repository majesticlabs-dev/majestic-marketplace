# Changelog

All notable changes to majestic-rails will be documented in this file.

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
