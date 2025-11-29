# Majestic Rails

Ruby on Rails development tools. Includes 23 specialized agents, 5 commands, and 9 skills.

## Recommended Workflow

```mermaid
flowchart TD
    A[Feature Request] --> B["/plan"]
    B --> C{Post-Generation<br/>Options}

    C -->|Start /build| D["/build"]
    C -->|Run /review| E["/review"]
    C -->|Create backlog item| F[backlog-manager]
    C -->|Simplify| G[Regenerate simpler]
    C -->|Rework| H[Regenerate with changes]

    G --> C
    H --> C
    F --> C

    D --> I[Implementation]
    I --> E
    E --> J{Issues Found?}

    J -->|Yes| K[Fix Issues]
    K --> E
    J -->|No| L[Ship It]

    style B fill:#4a9eff
    style D fill:#22c55e
    style E fill:#f59e0b
    style L fill:#10b981
```

**Quick start:**
1. `/majestic-rails:workflows:plan "your feature"` - Research and create plan
2. Choose next step: build, review, create backlog item, or refine
3. `/majestic-rails:workflows:build docs/plans/your-feature.md` - Implement
4. `/majestic-rails:workflows:review` - Smart multi-agent code review

## Installation

```bash
claude /plugin install majestic-rails
```

## Agents

Invoke with: `agent majestic-rails:<name>` or `agent majestic-rails:<category>:<name>`

### Core

| Agent | Description |
|-------|-------------|
| `rails-refactorer` | Refactor Rails code following conventions, Sandi Metz rules, and idiomatic Ruby patterns |
| `rails-debugger` | Debug Rails issues and validate bug reports by analyzing errors and reproducing issues |
| `rubocop-fixer` | Fix Rubocop violations following project conventions |
| `github-resolver` | Resolve CI failures and PR review comments from GitHub |
| `lint` | Run rubocop, erblint, and brakeman before pushing |
| `active-job-coder` | Create background jobs with Rails 8 conventions, Solid Queue patterns, and retry strategies |
| `action-mailer-coder` | Create emails with parameterized mailers, previews, and background delivery |
| `solid-queue-coder` | Configure Solid Queue for database-backed job processing (Rails 8 default) |
| `solid-cache-coder` | Configure Solid Cache for database-backed caching (Rails 8 default) |
| `database-optimizer` | Advanced query optimization, EXPLAIN analysis, complex SQL for PostgreSQL/SQLite |
| `database-admin` | Database operations, backups, monitoring, connection pooling for PostgreSQL/SQLite |
| `graphql-architect` | Design GraphQL schemas, resolvers, subscriptions using graphql-ruby patterns |
| `action-policy-coder` | Authorization with ActionPolicy - policies, scopes, caching, GraphQL integration |

### Frontend

| Agent | Description |
|-------|-------------|
| `frontend:hotwire-coder` | Build Turbo Drive, Frames, Streams with morphing, broadcasts, and real-time patterns |
| `frontend:stimulus-coder` | Create Stimulus controllers with targets, values, actions, and Turbo integration |
| `frontend:tailwind-coder` | Apply Tailwind CSS styling with responsive design patterns |

### Admin

| Agent | Description |
|-------|-------------|
| `admin:avo-coder` | Build Avo admin interfaces (fetches latest docs dynamically) |

### Research & Review

| Agent | Description |
|-------|-------------|
| `research:gem-research` | Ruby gem evaluation, quality assessment, and implementation guidance |
| `review:dhh-code-reviewer` | Review code following DHH's 37signals/Rails conventions |
| `review:pragmatic-rails-reviewer` | Review code for quality, regressions, testability with pragmatic taste |
| `review:performance-reviewer` | Analyze code for performance issues, query optimization, and scalability |
| `review:data-integrity-reviewer` | Review migrations, data constraints, transactions, and privacy compliance |
| `review:simplicity-reviewer` | Simplify code, detect anti-patterns, find duplication, enforce YAGNI |

## Commands

Invoke with: `/majestic-rails:<category>:<name>`

| Command | Description |
|---------|-------------|
| `workflows:build` | Execute work plans efficiently - build features following Rails conventions |
| `workflows:plan` | Transform feature descriptions into well-structured Rails project plans |
| `workflows:review` | Comprehensive code review using smart agent selection based on changed files |
| `gemfile:organize` | Organize Gemfile with categorized sections and alphabetized gems |
| `gemfile:upgrade` | Upgrade a gem safely with changelog review and testing |

## Skills

Invoke with: `skill majestic-rails:<name>`

| Skill | Description |
|-------|-------------|
| `business-logic-coder` | Implement business logic with ActiveInteraction and AASM state machines |
| `dhh-coder` | Code following DHH's standards for Rails elegance and simplicity |
| `gem-builder` | Comprehensive guide for building production-quality Ruby gems |
| `inertia-coder` | Build modern SPAs with Inertia.js + Rails using React, Vue, or Svelte |
| `minitest-coder` | Write Minitest tests covering both traditional and spec styles |
| `rspec-coder` | Write comprehensive RSpec tests with proper describe/context organization |
| `ruby-coder` | Write Ruby code following Ruby 3.x syntax and Sandi Metz's 4 Rules |
| `store-model-coder` | Wrap JSON-backed database columns with ActiveModel-like classes using store_model |
| `viewcomponent-coder` | Build component-based UIs with ViewComponent, slots, variants, and Lookbook |

## Usage Examples

```bash
# Refactor Rails code
agent majestic-rails:rails-refactorer "Refactor the User model to follow Sandi Metz rules"

# Debug an issue
agent majestic-rails:rails-debugger "Investigate why user registration is failing"

# Fix Rubocop violations
agent majestic-rails:rubocop-fixer "Fix all Style cops in app/models/"

# Resolve CI failures or PR comments
agent majestic-rails:github-resolver "Fix the failing tests in PR #123"

# Lint before pushing
agent majestic-rails:lint "Run linters and fix issues"

# Create background jobs
agent majestic-rails:active-job-coder "Create a job to process uploaded files"

# Create emails
agent majestic-rails:action-mailer-coder "Create a welcome email with parameterized mailer"

# Configure Solid Queue
agent majestic-rails:solid-queue-coder "Set up Solid Queue with recurring jobs"

# Configure Solid Cache
agent majestic-rails:solid-cache-coder "Configure Solid Cache with separate database"

# Optimize database queries
agent majestic-rails:database-optimizer "Analyze slow query with EXPLAIN and recommend indexes"

# Database administration
agent majestic-rails:database-admin "Set up pg_stat_statements monitoring and backup strategy"

# Design GraphQL API
agent majestic-rails:graphql-architect "Design schema for user posts with N+1 prevention"

# Authorization with ActionPolicy
agent majestic-rails:action-policy-coder "Create PostPolicy with owner and admin rules"

# Build Hotwire components
agent majestic-rails:frontend:hotwire-coder "Create a live search with Turbo Frames"

# Create Stimulus controllers
agent majestic-rails:frontend:stimulus-coder "Create a dropdown controller with keyboard navigation"

# Style with Tailwind
agent majestic-rails:frontend:tailwind-coder "Style the user profile page"

# Build Avo admin
agent majestic-rails:admin:avo-coder "Create an Avo resource for the Product model"

# Research a gem
agent majestic-rails:research:gem-research "Evaluate devise vs rodauth for authentication"

# DHH-style code review
agent majestic-rails:review:dhh-code-reviewer "Review my controller for Rails best practices"

# Pragmatic code review
agent majestic-rails:review:pragmatic-rails-reviewer "Review my recent changes for regressions"

# Performance review
agent majestic-rails:review:performance-reviewer "Check for N+1 queries and scalability issues"

# Data integrity review
agent majestic-rails:review:data-integrity-reviewer "Review this migration for safety"

# Simplicity review
agent majestic-rails:review:simplicity-reviewer "Simplify this implementation"

# Plan a feature (with post-generation options: build, review, backlog, simplify, rework)
/majestic-rails:workflows:plan "Add user authentication with OAuth"

# Build from a plan
/majestic-rails:workflows:build docs/plans/add-user-authentication.md

# Comprehensive code review (smart agent selection)
/majestic-rails:workflows:review              # Review current branch vs main
/majestic-rails:workflows:review #123         # Review PR #123
/majestic-rails:workflows:review --staged     # Review staged changes
/majestic-rails:workflows:review app/models/  # Review specific files

# Gemfile management
/majestic-rails:gemfile:organize              # Organize Gemfile with categories
/majestic-rails:gemfile:upgrade rails         # Upgrade a specific gem
/majestic-rails:gemfile:upgrade --outdated    # Review all outdated gems
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
