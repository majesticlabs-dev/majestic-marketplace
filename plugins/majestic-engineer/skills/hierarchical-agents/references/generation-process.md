# Hierarchical AGENTS.md Generation Process

Complete step-by-step guide for generating hierarchical AGENTS.md documentation, with special focus on Ruby and Rails projects.

## Table of Contents

- [Phase 1: Repository Analysis](#phase-1-repository-analysis)
- [Phase 2: Generate Root AGENTS.md](#phase-2-generate-root-agentsmd)
- [Phase 3: Generate Sub-Folder AGENTS.md](#phase-3-generate-sub-folder-agentsmd)
- [Phase 4: Special Considerations](#phase-4-special-considerations)
- [Ruby/Rails Specific Patterns](#rubyrails-specific-patterns)
- [Templates](#templates)


## Phase 1: Repository Analysis

### Analysis Checklist

Run these commands to understand the codebase:

```bash
# 1. Identify repository type
ls -la | grep -E "Gemfile|package.json|pyproject.toml"

# 2. Rails application?
ls -la | grep -E "app|config|db|lib" | wc -l
[ -f config/routes.rb ] && echo "Rails app detected"

# 3. Find major directories
tree -L 2 -d -I 'node_modules|vendor|tmp|log'

# 4. Check for engines or gems
ls -d engines/* 2>/dev/null || echo "No engines"
ls *.gemspec 2>/dev/null || echo "Not a gem"

# 5. Test framework
grep -r "rspec" Gemfile.lock 2>/dev/null && echo "RSpec"
grep -r "minitest" Gemfile.lock 2>/dev/null && echo "Minitest"

# 6. Database
grep -E "pg|mysql|sqlite" Gemfile.lock | head -3

# 7. Background jobs
grep -E "sidekiq|delayed_job|resque|good_job" Gemfile.lock

# 8. API framework
grep -E "grape|rails-api|jsonapi" Gemfile.lock
```

### Questions to Answer

Present findings in this structure:

```markdown
# Repository Analysis

## 1. Repository Type
- [ ] Rails monolith
- [ ] Rails engines (modular monolith)
- [ ] Rails API + frontend monorepo
- [ ] Ruby gem
- [ ] Multiple Rails apps in monorepo

## 2. Primary Technology Stack
- **Framework**: Rails X.X
- **Ruby Version**: X.X.X (from .ruby-version)
- **Database**: PostgreSQL / MySQL / SQLite
- **Test Framework**: RSpec / Minitest
- **Background Jobs**: Sidekiq / GoodJob / etc.
- **Frontend**: Hotwire / React / Vue / API-only

## 3. Major Directories Requiring AGENTS.md

### Core Rails Directories
- [ ] `app/models/` - Domain models and business logic
- [ ] `app/controllers/` - HTTP request handling
- [ ] `app/services/` - Service objects (if present)
- [ ] `app/jobs/` - Background jobs
- [ ] `lib/` - Library code and modules

### Additional Packages
- [ ] `engines/*/` - Rails engines (if present)
- [ ] `gems/*/` - Custom gems (if present)
- [ ] `frontend/` - Frontend app (if separate)

## 4. Build & Test System
- **Dependencies**: `bundle install`
- **Database Setup**: `bin/rails db:setup` or `bin/setup`
- **Test Command**: `bundle exec rspec` or `bin/rails test`
- **Linting**: `bundle exec rubocop`
- **Type Checking**: RBS/Sorbet? (if present)

## 5. Key Patterns to Document
- Code organization (services, queries, decorators?)
- Naming conventions
- Testing patterns (factories, fixtures, mocks)
- Important example files
- Anti-patterns to avoid
```


## Phase 2: Generate Root AGENTS.md

### Template for Rails Monolith

```markdown
# Project Name

## Project Snapshot

Rails X.X application with [PostgreSQL/MySQL]. Primary stack: Ruby X.X, [Hotwire/React], [RSpec/Minitest]. See subdirectory AGENTS.md files for detailed patterns.

## Root Setup Commands

\`\`\`bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Run tests
bundle exec rspec  # or: bin/rails test

# Lint
bundle exec rubocop

# Start development server
bin/dev  # or: bin/rails server
\`\`\`

## Universal Conventions

- **Code Style**: Standard Ruby (enforced by RuboCop)
- **Tests**: Write tests before implementation (TDD)
- **Commits**: Conventional Commits format
- **PRs**: Require passing tests + RuboCop + review
- **Naming**: Follow Rails conventions (snake_case files, PascalCase classes)

## Security & Secrets

- Never commit `.env` files or `config/master.key`
- Secrets go in Rails credentials: `bin/rails credentials:edit`
- Use `Rails.application.credentials` to access secrets
- No hardcoded API keys or passwords

## JIT Index (what to open, not what to paste)

### Directory Structure
- Models: `app/models/` → [see app/models/AGENTS.md](app/models/AGENTS.md)
- Controllers: `app/controllers/` → [see app/controllers/AGENTS.md](app/controllers/AGENTS.md)
- Services: `app/services/` → [see app/services/AGENTS.md](app/services/AGENTS.md)
- Jobs: `app/jobs/` → [see app/jobs/AGENTS.md](app/jobs/AGENTS.md)
- Views: `app/views/` → [see app/views/AGENTS.md](app/views/AGENTS.md)
- Library code: `lib/` → [see lib/AGENTS.md](lib/AGENTS.md)

### Quick Find Commands
\`\`\`bash
# Find a model
rg -n "class.*< ApplicationRecord" app/models

# Find a controller action
rg -n "def (index|show|create|update|destroy)" app/controllers

# Find a service
rg -n "class.*Service" app/services

# Find a job
rg -n "class.*Job.*< ApplicationJob" app/jobs

# Find a specific method
rg -n "def method_name" app/**/*.rb

# Find tests for a class
rg -n "describe ClassName|context 'ClassName'" spec
\`\`\`

## Acceptance Criteria

Before creating a PR:
- [ ] All tests pass: `bundle exec rspec`
- [ ] RuboCop passes: `bundle exec rubocop`
- [ ] Database migrations tested: `bin/rails db:migrate:redo`
- [ ] Locally tested in browser / API client
- [ ] New code has tests (aim for >80% coverage)
\`\`\`

### Template for Rails Engine / Modular Monolith

```markdown
# Project Name

## Project Snapshot

Modular Rails X.X monolith with engines. Ruby X.X, PostgreSQL. Each engine is self-contained with its own models, controllers, and tests. See engine-specific AGENTS.md files for patterns.

## Root Setup Commands

\`\`\`bash
bundle install
bin/rails db:setup
bundle exec rspec  # Run all engines' tests
bundle exec rubocop
bin/dev
\`\`\`

## Universal Conventions

- **Code Style**: Standard Ruby (RuboCop)
- **Engine Boundaries**: No direct cross-engine model access (use APIs or events)
- **Tests**: Each engine has its own spec directory
- **Commits**: Conventional Commits with engine scope: `feat(auth): add login`

## Security & Secrets

- Rails credentials: `bin/rails credentials:edit`
- Engine-specific secrets in main app credentials under engine namespace

## JIT Index

### Engine Structure
- Auth: `engines/auth/` → [see engines/auth/AGENTS.md](engines/auth/AGENTS.md)
- Billing: `engines/billing/` → [see engines/billing/AGENTS.md](engines/billing/AGENTS.md)
- Admin: `engines/admin/` → [see engines/admin/AGENTS.md](engines/admin/AGENTS.md)

### Quick Find Commands
\`\`\`bash
# Find engine by name
ls -d engines/*/

# Find cross-engine dependencies
rg -n "::Engine" engines/**/lib/*.rb

# Find all models
rg -n "class.*< ApplicationRecord" engines/**/app/models

# Find engine routes
rg -n "mount.*::Engine" config/routes.rb
\`\`\`

## Acceptance Criteria

- [ ] All tests pass: `bundle exec rspec`
- [ ] RuboCop clean: `bundle exec rubocop`
- [ ] No cross-engine violations (models don't reference other engines)
- [ ] Engine routes tested
\`\`\`


## Phase 3: Generate Sub-Folder AGENTS.md

### Required Sections (Template)

```markdown
# [Package/Directory Name]

## Package Identity

[Brief description of what this directory contains and its purpose]
Technology: [Rails models / Controllers / Services / Hotwire views / etc.]

## Setup & Run

\`\`\`bash
# Run tests for this directory only
bundle exec rspec spec/[directory]

# Lint only this directory
bundle exec rubocop app/[directory]

# Database commands (if models)
bin/rails db:migrate
bin/rails db:rollback
\`\`\`

## Patterns & Conventions

### ✅ DO
- [Pattern]: Copy from `[actual/file/path.rb]`
- [Pattern]: Example in `[another/file.rb:123]`

### ❌ DON'T
- [Anti-pattern]: See legacy code in `[old/file.rb]` (do not copy)
- [Anti-pattern]: Avoid X pattern (deprecated)

### File Organization
- [Where things go]
- [Naming rules]
- [Directory structure]

## Touch Points / Key Files

- **[Purpose]**: `[path/to/file.rb]`
- **[Purpose]**: `[path/to/another.rb]`
- **[Config]**: `[config/file.yml]`

## JIT Index Hints

\`\`\`bash
# Find [something]
rg -n "pattern" app/[directory]

# Find [something else]
rg -n "class.*< Base" app/[directory]

# Find tests
find spec/[directory] -name "*_spec.rb"
\`\`\`

## Common Gotchas

- [Gotcha 1]: [Explanation]
- [Gotcha 2]: [Explanation]

## Pre-PR Checks

\`\`\`bash
bundle exec rspec spec/[directory] && bundle exec rubocop app/[directory]
\`\`\`
```


## Phase 4: Special Considerations

### A. Models Directory (`app/models/AGENTS.md`)

```markdown
# Models

## Package Identity

Domain models and business logic. All models inherit from `ApplicationRecord`.
Uses ActiveRecord ORM with PostgreSQL.

## Setup & Run

\`\`\`bash
# Run model tests
bundle exec rspec spec/models

# Check schema
bin/rails db:schema:dump

# Generate migration
bin/rails generate migration AddColumnToTable column:type
\`\`\`

## Patterns & Conventions

### ✅ DO
- **Simple models**: Copy pattern from `app/models/user.rb`
- **Validations**: Group at top, example in `app/models/article.rb:5-12`
- **Associations**: Define after validations, see `app/models/post.rb:14-17`
- **Scopes**: Use class methods or scopes, example `app/models/user.rb:20-25`
- **Callbacks**: Use sparingly, prefer service objects for complex logic

### ❌ DON'T
- **Fat models**: Don't put business logic in models (see `app/models/legacy_order.rb` - DO NOT COPY)
- **Callbacks for side effects**: No sending emails in callbacks
- **Complex validations**: Extract to custom validator classes

### Naming Conventions
- File: `snake_case.rb`
- Class: `PascalCase`
- Tables: Pluralized snake_case
- Foreign keys: `model_id`
- Joins: Alphabetical order (e.g., `articles_tags`)

## Touch Points / Key Files

- **Base model**: `app/models/application_record.rb`
- **Example simple model**: `app/models/user.rb`
- **Example complex model**: `app/models/order.rb`
- **Custom validators**: `app/validators/`
- **Database schema**: `db/schema.rb`

## JIT Index Hints

\`\`\`bash
# Find a model
rg -n "class .* < ApplicationRecord" app/models

# Find associations
rg -n "(has_many|belongs_to|has_one)" app/models

# Find validations
rg -n "validates?" app/models

# Find scopes
rg -n "scope :" app/models

# Find callbacks
rg -n "(before|after)_(save|create|update|destroy)" app/models
\`\`\`

## Common Gotchas

- **N+1 queries**: Always use `includes` for associations (check with Bullet gem)
- **Validation bypass**: `save(validate: false)` skips validations - use sparingly
- **Mass assignment**: Use strong parameters in controllers, not `attr_accessible` in models

## Pre-PR Checks

\`\`\`bash
bundle exec rspec spec/models && bundle exec rubocop app/models
\`\`\`
```

### B. Controllers Directory (`app/controllers/AGENTS.md`)

```markdown
# Controllers

## Package Identity

HTTP request handling following RESTful conventions.
All controllers inherit from `ApplicationController`.

## Setup & Run

\`\`\`bash
# Run controller tests
bundle exec rspec spec/controllers
# or: bundle exec rspec spec/requests

# Check routes
bin/rails routes | grep ControllerName
\`\`\`

## Patterns & Conventions

### ✅ DO
- **RESTful actions**: Copy pattern from `app/controllers/articles_controller.rb`
- **Strong parameters**: See example in `app/controllers/users_controller.rb:45-49`
- **Before actions**: Use for authentication/authorization, example `app/controllers/admin/base_controller.rb:3-8`
- **Respond to formats**: Use `respond_to` block, see `app/controllers/api/v1/posts_controller.rb:15-20`

### ❌ DON'T
- **Business logic**: Don't put in controllers (extract to services)
- **Fat actions**: Keep actions under 10 lines (see `app/controllers/legacy/orders_controller.rb` - DO NOT COPY)
- **Direct model calls**: Use service objects for complex operations

### File Organization
- RESTful controllers: `app/controllers/resource_controller.rb`
- Namespaced: `app/controllers/admin/resource_controller.rb`
- API versions: `app/controllers/api/v1/resource_controller.rb`

### Action Order
1. `index`
2. `show`
3. `new`
4. `create`
5. `edit`
6. `update`
7. `destroy`
8. Private methods

## Touch Points / Key Files

- **Base controller**: `app/controllers/application_controller.rb`
- **Auth logic**: `app/controllers/concerns/authenticable.rb`
- **Example REST controller**: `app/controllers/articles_controller.rb`
- **Example API controller**: `app/controllers/api/v1/base_controller.rb`

## JIT Index Hints

\`\`\`bash
# Find a controller
rg -n "class.*Controller < " app/controllers

# Find an action
rg -n "def (index|show|create|update|destroy)" app/controllers

# Find strong parameters
rg -n "params.require.*permit" app/controllers

# Find before actions
rg -n "before_action :" app/controllers

# Find respond_to blocks
rg -n "respond_to do" app/controllers
\`\`\`

## Common Gotchas

- **Authenticity token**: API controllers should skip CSRF: `skip_before_action :verify_authenticity_token`
- **Strong parameters**: Always use `require().permit()`, never `params` directly
- **Respond to format**: Don't forget `format.html` for HTML requests

## Pre-PR Checks

\`\`\`bash
bundle exec rspec spec/controllers spec/requests && bundle exec rubocop app/controllers
\`\`\`
```

### C. Services Directory (`app/services/AGENTS.md`)

```markdown
# Services

## Package Identity

Service objects for complex business logic extracted from models and controllers.
Single Responsibility Principle: one service, one job.

## Setup & Run

\`\`\`bash
# Run service tests
bundle exec rspec spec/services

# Check service usage
rg -n "ServiceName.call" app/controllers app/jobs
\`\`\`

## Patterns & Conventions

### ✅ DO
- **Simple service**: Copy pattern from `app/services/user_registration_service.rb`
- **Result object**: Return structured result, see `app/services/order_processor.rb:30-35`
- **Single public method**: Usually `call` or `perform`
- **Dependency injection**: Pass dependencies to `initialize`, see `app/services/payment_processor.rb:5-8`

### ❌ DON'T
- **Multiple responsibilities**: One service = one job
- **Side effects without return**: Always return success/failure indicator
- **Direct controller/view coupling**: Services shouldn't know about HTTP

### Service Patterns

**Basic Service**:
\`\`\`ruby
# app/services/user_registration_service.rb
class UserRegistrationService
  def initialize(params)
    @params = params
  end

  def call
    user = User.new(@params)
    if user.save
      send_welcome_email(user)
      Result.success(user)
    else
      Result.failure(user.errors)
    end
  end

  private

  def send_welcome_email(user)
    UserMailer.welcome(user).deliver_later
  end
end
\`\`\`

**Usage in Controller**:
\`\`\`ruby
result = UserRegistrationService.new(user_params).call
if result.success?
  redirect_to result.value
else
  @errors = result.errors
  render :new
end
\`\`\`

## Touch Points / Key Files

- **Example service**: `app/services/user_registration_service.rb`
- **Result object**: `app/services/result.rb` or gem like `dry-monads`
- **Service base**: `app/services/application_service.rb` (if present)

## JIT Index Hints

\`\`\`bash
# Find all services
rg -n "class.*Service" app/services

# Find service calls
rg -n "\.call\(|\.perform\(" app/controllers app/jobs

# Find service tests
find spec/services -name "*_spec.rb"
\`\`\`

## Common Gotchas

- **Transaction safety**: Wrap DB operations in `ActiveRecord::Base.transaction`
- **Error handling**: Always handle exceptions, don't let them bubble
- **Return values**: Be consistent - always return Result object or similar

## Pre-PR Checks

\`\`\`bash
bundle exec rspec spec/services && bundle exec rubocop app/services
\`\`\`
```

### D. Jobs Directory (`app/jobs/AGENTS.md`)

```markdown
# Jobs

## Package Identity

Background jobs using [Sidekiq/GoodJob/etc.].
All jobs inherit from `ApplicationJob`.

## Setup & Run

\`\`\`bash
# Run job tests
bundle exec rspec spec/jobs

# Check job queue
bin/rails runner "puts Sidekiq::Stats.new.inspect"

# Run job manually in console
bin/rails console
> MyJob.perform_now(args)
\`\`\`

## Patterns & Conventions

### ✅ DO
- **Simple job**: Copy pattern from `app/jobs/send_email_job.rb`
- **Retry logic**: Use `retry_on` for transient failures, see `app/jobs/api_sync_job.rb:3-5`
- **Idempotency**: Make jobs safe to run multiple times
- **Small jobs**: Keep jobs focused and fast

### ❌ DON'T
- **Long-running jobs**: Split into smaller jobs (>5 min is too long)
- **Direct model logic**: Extract to services
- **Unhandled failures**: Always define retry/discard strategy

### Job Pattern
\`\`\`ruby
# app/jobs/send_email_job.rb
class SendEmailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.notification(user).deliver_now
  end
end
\`\`\`

## Touch Points / Key Files

- **Base job**: `app/jobs/application_job.rb`
- **Example job**: `app/jobs/send_email_job.rb`
- **Queue config**: `config/sidekiq.yml` or similar

## JIT Index Hints

\`\`\`bash
# Find all jobs
rg -n "class.*Job < ApplicationJob" app/jobs

# Find job enqueues
rg -n "\.perform_later|\.perform_async" app/

# Find retry configurations
rg -n "retry_on|discard_on" app/jobs
\`\`\`

## Common Gotchs

- **Arguments**: Only pass IDs, not ActiveRecord objects (they don't serialize well)
- **Idempotency**: Check if work already done before executing
- **Timeouts**: Set explicit timeouts for external API calls

## Pre-PR Checks

\`\`\`bash
bundle exec rspec spec/jobs && bundle exec rubocop app/jobs
\`\`\`
```


## Ruby/Rails Specific Patterns

### Testing Patterns

#### RSpec Structure
\`\`\`ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:posts) }
  end

  describe '#full_name' do
    it 'returns first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
\`\`\`

#### Minitest Structure
\`\`\`ruby
# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should validate presence of email" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "full_name returns first and last name" do
    user = users(:one)
    assert_equal "John Doe", user.full_name
  end
end
\`\`\`

### Common Rails Conventions

- **Files**: `snake_case.rb`
- **Classes**: `PascalCase`
- **Methods**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Controllers**: `resources_controller.rb` (plural)
- **Models**: `resource.rb` (singular)
- **Views**: `app/views/resources/action.html.erb`

### Directory Structure Reference

\`\`\`
app/
  assets/         # Images, fonts, stylesheets (if using asset pipeline)
  channels/       # ActionCable channels
  controllers/    # HTTP request handling
  helpers/        # View helpers
  jobs/           # Background jobs
  mailers/        # Email logic
  models/         # Domain models
  services/       # Business logic services (custom)
  views/          # Templates

config/
  environments/   # Environment-specific config
  initializers/   # Initialization code
  locales/        # I18n translations
  routes.rb       # URL routing

db/
  migrate/        # Database migrations
  seeds.rb        # Seed data
  schema.rb       # Current database schema

lib/
  tasks/          # Custom Rake tasks
  (modules)       # Custom library code

spec/ (or test/)
  models/
  controllers/
  services/
  factories/      # FactoryBot factories
  fixtures/       # Test fixtures
  support/        # Test helpers
\`\`\`


## Templates

### Quick Template: Root AGENTS.md (Rails App)

\`\`\`markdown
# [Project Name]

Rails X.X app with [DB]. Stack: Ruby X.X, [Frontend], [Test Framework].

## Setup
\`\`\`bash
bundle install && bin/rails db:setup && bundle exec rspec
\`\`\`

## Conventions
- Standard Ruby (RuboCop)
- TDD with [RSpec/Minitest]
- Conventional Commits

## Security
- Credentials: `bin/rails credentials:edit`
- No `.env` commits

## JIT Index
- Models: [app/models/AGENTS.md](app/models/AGENTS.md)
- Controllers: [app/controllers/AGENTS.md](app/controllers/AGENTS.md)
- Services: [app/services/AGENTS.md](app/services/AGENTS.md)

## Quick Find
\`\`\`bash
rg -n "class.*< ApplicationRecord" app/models    # Models
rg -n "def (index|show)" app/controllers          # Actions
\`\`\`

## Acceptance Criteria
\`\`\`bash
bundle exec rspec && bundle exec rubocop
\`\`\`
\`\`\`

### Quick Template: Sub-Folder AGENTS.md

\`\`\`markdown
# [Directory Name]

[What this directory does]. Technology: [Rails models/controllers/etc.]

## Setup
\`\`\`bash
bundle exec rspec spec/[dir] && bundle exec rubocop app/[dir]
\`\`\`

## Patterns

### ✅ DO
- [Pattern]: `[actual/file/path.rb]`

### ❌ DON'T
- [Anti-pattern]: See `[legacy/file.rb]`

## Key Files
- **[Purpose]**: `[path/to/file.rb]`

## Find
\`\`\`bash
rg -n "pattern" app/[dir]
\`\`\`

## Gotchas
- [Gotcha 1]
\`\`\`


## Completion Checklist

After generating all AGENTS.md files:

- [ ] Root AGENTS.md < 200 lines
- [ ] All sub-folder AGENTS.md created for major directories
- [ ] All file paths verified to exist
- [ ] All commands tested and working
- [ ] ✅ DO examples point to real files
- [ ] ❌ DON'T examples reference real anti-patterns
- [ ] No duplication between root and sub-files
- [ ] JIT Index links all sub-files
- [ ] Acceptance Criteria is clear and executable
- [ ] Ruby/Rails conventions documented
- [ ] Test framework patterns included
- [ ] Pre-PR checks are single commands


**Reference Status**: COMPLETE ✅
**Focus**: Ruby/Rails applications with practical examples ✅
