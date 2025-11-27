# Majestic Rails

Ruby on Rails development tools. Includes 14 specialized agents, 3 commands, and 5 skills.

## Installation

```bash
claude /plugin install majestic-rails
```

## Agents

### Core

| Agent | Description |
|-------|-------------|
| `rails-refactorer` | Refactor Rails code following conventions, Sandi Metz rules, and idiomatic Ruby patterns |
| `rails-debugger` | Debug Rails issues and validate bug reports by analyzing errors and reproducing issues |
| `rubocop-fixer` | Fix Rubocop violations following project conventions |
| `github-resolver` | Resolve CI failures and PR review comments from GitHub |
| `lint` | Run rubocop, erblint, and brakeman before pushing |

### Frontend

| Agent | Description |
|-------|-------------|
| `frontend/hotwire-coder` | Build Hotwire/Turbo/Stimulus components following Rails 8 conventions |
| `frontend/tailwind-coder` | Apply Tailwind CSS styling with responsive design patterns |

### Admin

| Agent | Description |
|-------|-------------|
| `admin/avo-coder` | Build Avo admin interfaces (fetches latest docs dynamically) |

### Research & Review

| Agent | Description |
|-------|-------------|
| `research/gem-research` | Ruby gem evaluation, quality assessment, and implementation guidance |
| `review/dhh-code-reviewer` | Review code following DHH's 37signals/Rails conventions |
| `review/pragmatic-rails-reviewer` | Review code for quality, regressions, testability with pragmatic taste |
| `review/performance-reviewer` | Analyze code for performance issues, query optimization, and scalability |
| `review/data-integrity-reviewer` | Review migrations, data constraints, transactions, and privacy compliance |
| `review/simplicity-reviewer` | Simplify code, detect anti-patterns, find duplication, enforce YAGNI |

## Commands

| Command | Description |
|---------|-------------|
| `/workflows/build` | Execute work plans efficiently - build features following Rails conventions |
| `/workflows/plan` | Transform feature descriptions into well-structured Rails project plans |
| `/workflows/review` | Comprehensive code review using smart agent selection based on changed files |

## Skills

| Skill | Description |
|-------|-------------|
| `ruby-coder` | Write Ruby code following Ruby 3.x syntax and Sandi Metz's 4 Rules |
| `rspec-coder` | Write comprehensive RSpec tests with proper describe/context organization |
| `minitest-coder` | Write Minitest tests covering both traditional and spec styles |
| `dhh-coder` | Code following DHH's standards for Rails elegance and simplicity |
| `gem-builder` | Comprehensive guide for building production-quality Ruby gems |

## Usage Examples

```bash
# Refactor Rails code
claude agent rails-refactorer "Refactor the User model to follow Sandi Metz rules"

# Debug an issue
claude agent rails-debugger "Investigate why user registration is failing"

# Fix Rubocop violations
claude agent rubocop-fixer "Fix all Style cops in app/models/"

# Resolve CI failures or PR comments
claude agent github-resolver "Fix the failing tests in PR #123"

# Lint before pushing
claude agent lint "Run linters and fix issues"

# Build Hotwire components
claude agent frontend/hotwire-coder "Create a live search with Turbo Frames"

# Style with Tailwind
claude agent frontend/tailwind-coder "Style the user profile page"

# Build Avo admin
claude agent admin/avo-coder "Create an Avo resource for the Product model"

# Research a gem
claude agent research/gem-research "Evaluate devise vs rodauth for authentication"

# DHH-style code review
claude agent review/dhh-code-reviewer "Review my controller for Rails best practices"

# Pragmatic code review
claude agent review/pragmatic-rails-reviewer "Review my recent changes for regressions"

# Performance review
claude agent review/performance-reviewer "Check for N+1 queries and scalability issues"

# Data integrity review
claude agent review/data-integrity-reviewer "Review this migration for safety"

# Simplicity review
claude agent review/simplicity-reviewer "Simplify this implementation"

# Comprehensive code review (smart agent selection)
claude /workflows/review              # Review current branch vs main
claude /workflows/review #123         # Review PR #123
claude /workflows/review --staged     # Review staged changes
claude /workflows/review app/models/  # Review specific files
```

## Ruby Coding Standards

The `ruby-coder` skill enforces:
- Modern Ruby 3.x syntax
- Sandi Metz's 4 Rules for Developers
- Idiomatic Ruby patterns
- Clarity and maintainability

## Testing Framework Support

### RSpec (`rspec-coder`)
- describe/context organization
- subject/let patterns
- Mocking with allow/expect
- Shoulda matchers

### Minitest (`minitest-coder`)
- Traditional and spec styles
- Fixtures usage
- Mocking patterns
- Rails integration testing
