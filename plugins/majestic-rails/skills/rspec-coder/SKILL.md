---
name: rspec-coder
description: This skill guides writing comprehensive RSpec tests for Ruby and Rails applications. Use when creating spec files, writing test cases, or testing new features. Covers RSpec syntax, describe/context organization, subject/let patterns, fixtures, mocking with allow/expect, and shoulda matchers.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch
---

# RSpec Coder

## Overview

This skill provides comprehensive guidance for writing effective RSpec tests in Ruby and Rails applications. Apply these standards when creating spec files, implementing test coverage for new features, or refactoring existing tests to ensure clarity, thoroughness, and maintainability using RSpec conventions and best practices.

## Core Philosophy

Prioritize:
- **AAA Pattern**: Arrange-Act-Assert structure for clarity
- **Behavior over Implementation**: Test what code does, not how it does it
- **Isolation**: Tests should be independent and not affect each other
- **Descriptive Names**: describe/context blocks should clearly explain expected behavior
- **Coverage**: Test both happy paths and edge cases (sad paths)
- **Fast Tests**: Minimize database operations and external calls
- **Readability**: Tests serve as living documentation
- **Fixtures**: Use fixtures for common data setup
- **Mocks and Stubs**: Use mocks and stubs for external dependencies
- **Shoulda Matchers**: Use shoulda matchers for common assertions

## Critical RSpec Conventions

### Don't Add `require 'rails_helper'`

RSpec imports `rails_helper` automatically via `.rspec` configuration file. Adding it manually creates redundancy.

```ruby
# ❌ BAD - redundant require
require 'rails_helper'

RSpec.describe User do
  # ...
end

# ✅ GOOD - no require needed
RSpec.describe User do
  # ...
end
```

### ❌ Don't Add Redundant Spec Type

RSpec Rails uses `RSpecRails/InferredSpecType` to automatically infer spec types from file location. Do not add explicit `:type` metadata.

```ruby
# ❌ BAD - redundant type declaration
RSpec.describe User, type: :model do
  # ...
end

# ✅ GOOD - type inferred from spec/models/ location
RSpec.describe User do
  # ...
end
```

### ✅ Use Fully Qualified Namespace WITHOUT Leading Double Colons

Follow RuboCop `Style/RedundantConstantBase` rule by using fully qualified paths without leading `::`.

```ruby
# ❌ BAD - leading double colons
RSpec.describe ::DynamicsGp::ERPSynchronizer do
  # ...
end

# ✅ GOOD - no leading double colons
RSpec.describe DynamicsGp::ERPSynchronizer do
  # ...
end
```

## Test Organization

### File Structure

Follow this standard Rails RSpec directory structure:

```
spec/
├── models/           # Model unit tests
├── services/         # Service object tests
├── controllers/      # Controller tests
├── requests/         # Request specs (API testing)
├── mailers/          # Mailer tests
├── jobs/             # Background job tests
├── lib/              # Library code tests
├── fixtures/         # Test data
├── support/          # Helper modules and shared examples
├── spec_helper.rb    # Core RSpec configuration
└── rails_helper.rb   # Rails-specific configuration
```

### Naming Conventions

**Spec files**: Mirror the application structure with `_spec.rb` suffix
- Model: `app/models/user.rb` → `spec/models/user_spec.rb`
- Service: `app/services/order_processor.rb` → `spec/services/order_processor_spec.rb`
- Controller: `app/controllers/posts_controller.rb` → `spec/controllers/posts_controller_spec.rb`

### Using `describe` and `context`

**`describe`**: Groups tests by method or functionality

**`context`**: Groups tests by specific conditions or scenarios

```ruby
RSpec.describe OrderProcessor do
  describe "#process" do
    context "with valid payment" do
      # Tests for valid payment scenario
    end

    context "with invalid payment" do
      # Tests for invalid payment scenario
    end

    context "when order is already processed" do
      # Tests for duplicate processing
    end
  end

  describe "#refund" do
    context "with full refund" do
      # Tests for full refund
    end

    context "with partial refund" do
      # Tests for partial refund
    end
  end
end
```

**Organization best practices**:
- `describe` for methods: `describe "#process"`
- `describe` for classes: `describe User`
- `context` for conditions: `context "when user is admin"`
- Use descriptive names that explain behavior
- Nest contexts to build scenarios (max 3 levels)

## Subject and Let

### Using `subject`

`subject` defines the primary object or method under test:

```ruby
RSpec.describe User do
  describe "#full_name" do
    subject(:full_name) { user.full_name }

    let(:user) { User.new(first_name: "Alice", last_name: "Smith") }

    it { is_expected.to eq("Alice Smith") }

    context "when last name is missing" do
      let(:user) { User.new(first_name: "Alice") }

      it { is_expected.to eq("Alice") }
    end
  end
end
```

**Subject patterns**:
```ruby
# Named subject (preferred)
subject(:user) { User.new(name: "Alice") }

# Anonymous subject (for simple cases)
subject { User.new(name: "Alice") }

# Using is_expected with subject
it { is_expected.to be_valid }
it { is_expected.to_not be_admin }
```

### Using `let`

`let` provides lazy-evaluated, memoized test data:

```ruby
RSpec.describe OrderProcessor do
  let(:order) { orders(:paid_order) }
  let(:processor) { described_class.new(order) }
  let(:payment_amount) { 99.99 }

  describe "#process" do
    it "charges the correct amount" do
      expect(processor.calculate_charge).to eq(payment_amount)
    end
  end
end
```

**Benefits of `let`**:
- Lazy evaluation (created only when referenced)
- Memoized within a single test (same instance per test)
- Re-evaluated for each test (no state leakage)
- Can be overridden in nested contexts
- Supports dependency chains

**`let` vs `let!`**:
```ruby
# let - lazy evaluation (created when first used)
let(:user) { User.create(name: "Alice") }

# let! - eager evaluation (created immediately before each test)
let!(:admin) { User.create(name: "Admin", admin: true) }
```

**When to use `let!`**:
- Need records in database before test runs
- Side effects required for test setup
- Testing queries that depend on existing records

## Fixtures

Use fixtures for test data instead of factories:

### Creating Fixtures

**Location**: `spec/fixtures/users.yml`

```yaml
# spec/fixtures/users.yml
alice:
  name: Alice Smith
  email: alice@example.com
  created_at: <%= 2.days.ago %>
  admin: false

bob:
  name: Bob Jones
  email: bob@example.com
  admin: true
  created_at: <%= 1.week.ago %>
```

### Using Fixtures in Specs

```ruby
RSpec.describe User do
  fixtures :users  # Load specific fixtures

  describe "validations" do
    subject(:user) { users(:alice) }

    it { is_expected.to be_valid }
  end

  describe "uniqueness" do
    it "rejects duplicate email" do
      duplicate = User.new(
        name: "Charlie",
        email: users(:alice).email
      )

      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end
  end
end
```

**Fixture best practices**:
- Name fixtures descriptively (`:alice`, `:paid_order`, `:admin_user`)
- Keep fixtures minimal and focused
- Use ERB for dynamic data (`<%= 2.days.ago %>`)
- Prefer fixtures over factories for speed
- Define associations clearly
- Load only needed fixtures per test file

## Mocking and Stubbing

### Stubbing with `allow`

Use `allow` to stub method return values:

```ruby
RSpec.describe OrderProcessor do
  fixtures :orders

  let(:order) { orders(:pending_order) }
  let(:processor) { described_class.new(order) }

  describe "#process" do
    context "with valid payment" do
      before do
        allow(PaymentGateway).to receive(:charge).and_return(true)
      end

      it "updates order status to completed" do
        expect { processor.process }
          .to change { order.reload.status }
          .to("completed")
      end
    end

    context "with failed payment" do
      before do
        allow(PaymentGateway).to receive(:charge).and_return(false)
      end

      it "keeps order status as pending" do
        expect { processor.process }
          .to_not change { order.reload.status }
      end
    end
  end
end
```

### Verifying Calls with `expect`

Use `expect` with `to receive` to verify method calls:

```ruby
RSpec.describe NotificationService do
  describe "#send_welcome_email" do
    let(:user) { users(:alice) }

    it "sends email to user" do
      expect(UserMailer).to receive(:welcome_email)
        .with(user)
        .and_return(double(deliver_later: true))

      described_class.send_welcome_email(user)
    end
  end
end
```

### Common Mocking Patterns

```ruby
# Stub with specific return value
allow(service).to receive(:call).and_return(result)

# Stub with multiple return values
allow(service).to receive(:call).and_return(true, false, true)

# Stub with block
allow(service).to receive(:call) { |arg| arg * 2 }

# Stub to raise error
allow(service).to receive(:call).and_raise(StandardError, "Error message")

# Expect with arguments
expect(service).to receive(:call).with(arg1, arg2)

# Expect call count
expect(service).to receive(:call).once
expect(service).to receive(:call).twice
expect(service).to receive(:call).exactly(3).times

# Expect with hash including
expect(service).to receive(:call).with(hash_including(key: value))

# Expect any instance
allow_any_instance_of(User).to receive(:admin?).and_return(true)
```

**Mocking best practices**:
- Mock external services (APIs, payment gateways, email delivery)
- Avoid mocking objects under test
- Use `allow` for stubbing return values
- Use `expect(...).to receive` for verifying calls
- Reset mocks automatically (RSpec does this by default)
- Don't over-mock; prefer real objects when fast enough

## RSpec Matchers

### Basic Matchers

```ruby
# Equality
expect(user.name).to eq("Alice")
expect(user.age).to be(30)

# Identity
expect(object).to be(same_object)
expect(object).to equal(same_object)

# Truthiness
expect(user.valid?).to be_truthy
expect(user.admin?).to be_falsey
expect(value).to be_nil

# Comparison
expect(user.age).to be > 18
expect(user.age).to be <= 65
expect(price).to be_between(10, 100).inclusive
```

### Collection Matchers

```ruby
# Include
expect(users).to include(admin_user)
expect(user.errors[:email]).to include("is invalid")

# Size
expect(users).to be_empty
expect(orders).to have(3).items  # Or: expect(orders.size).to eq(3)

# All
expect(users).to all(be_valid)
expect(ages).to all(be > 0)

# Contain exactly
expect(statuses).to contain_exactly("pending", "active", "completed")
```

### Change Matchers

```ruby
# Change by amount
expect { User.create(name: "Alice") }
  .to change(User, :count).by(1)

# Change from/to
expect { user.activate! }
  .to change { user.status }
  .from("pending").to("active")

# Multiple changes
expect { order.process }
  .to change { order.status }.to("completed")
  .and change { order.processed_at }.from(nil)

# No change
expect { user.save }
  .to_not change { user.created_at }
```

### Error Matchers

```ruby
# Raise error
expect { user.save! }
  .to raise_error(ActiveRecord::RecordInvalid)

# Raise with message
expect { divide_by_zero }
  .to raise_error(ZeroDivisionError, "divided by 0")

# Raise any error
expect { risky_operation }
  .to raise_error
```

### Type Matchers

```ruby
expect(user).to be_a(User)
expect(user).to be_an_instance_of(User)
expect(user).to be_kind_of(ActiveRecord::Base)
expect(response).to respond_to(:status)
```

### Predicate Matchers

RSpec automatically creates matchers for predicate methods:

```ruby
# For user.valid? method
expect(user).to be_valid

# For user.admin? method
expect(user).to be_admin

# For order.empty? method
expect(order).to be_empty

# For user.persisted? method
expect(user).to be_persisted
```

## Shoulda Matchers

Shoulda matchers provide concise syntax for common Rails validations and associations:

### Validation Matchers

```ruby
RSpec.describe User do
  describe "validations" do
    subject(:user) { users(:valid_user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { is_expected.to validate_numericality_of(:age).is_greater_than(0) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending active inactive]) }
    it { is_expected.to allow_value("user@example.com").for(:email) }
    it { is_expected.to_not allow_value("invalid").for(:email) }
  end
end
```

### Association Matchers

```ruby
RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_and_belong_to_many(:roles) }
    it { is_expected.to have_many(:comments).through(:posts) }
  end
end
```

### Database Matchers

```ruby
RSpec.describe User do
  describe "database" do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_index(:email).unique(true) }
  end
end
```

## AAA Pattern (Arrange-Act-Assert)

Structure all tests following the AAA pattern:

```ruby
RSpec.describe OrderProcessor do
  fixtures :orders

  describe "#process_refund" do
    let(:order) { orders(:completed_order) }
    let(:processor) { described_class.new(order) }

    it "credits user account with refund amount" do
      # Arrange
      original_balance = order.user.account_balance
      refund_amount = order.total

      # Act
      result = processor.process_refund

      # Assert
      expect(result).to be_success
      expect(order.reload.status).to eq("refunded")
      expect(order.user.reload.account_balance)
        .to eq(original_balance + refund_amount)
    end
  end
end
```

**With subject and let**:
```ruby
RSpec.describe OrderProcessor do
  fixtures :orders

  describe "#process_refund" do
    subject(:process_refund) { processor.process_refund }

    let(:order) { orders(:completed_order) }
    let(:processor) { described_class.new(order) }

    it "updates order status to refunded" do
      process_refund  # Act
      expect(order.reload.status).to eq("refunded")  # Assert
    end

    it "credits user account" do
      expect { process_refund }  # Act
        .to change { order.user.reload.account_balance }  # Assert
        .by(order.total)
    end
  end
end
```

## Test Coverage Standards

### What to Test

**Models**:
- Validations (presence, uniqueness, format, custom)
- Associations (belongs_to, has_many, has_one)
- Scopes (default scope, named scopes)
- Callbacks (before_save, after_create, etc.)
- Instance methods (public methods)
- Class methods (finders, calculations)

**Services**:
- Happy path (successful execution)
- Sad path (error handling)
- Edge cases (boundary conditions)
- External service integration (with mocking)

**Controllers/Requests**:
- HTTP status codes
- Response formats (JSON, HTML)
- Parameter handling
- Authentication/authorization
- Redirects

**Jobs**:
- Job execution
- Retry logic
- Error handling
- Idempotency

### Coverage Example

```ruby
RSpec.describe User do
  fixtures :users

  describe "validations" do
    subject(:user) { users(:valid_user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    context "with invalid email format" do
      let(:user) { User.new(name: "Alice", email: "invalid") }

      it { is_expected.to_not be_valid }

      it "adds error to email" do
        user.valid?
        expect(user.errors[:email]).to include("is invalid")
      end
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_one(:profile) }
  end

  describe "#full_name" do
    subject(:full_name) { user.full_name }

    let(:user) { User.new(first_name: "Alice", last_name: "Smith") }

    it { is_expected.to eq("Alice Smith") }

    context "when last name is missing" do
      let(:user) { User.new(first_name: "Alice") }

      it { is_expected.to eq("Alice") }
    end
  end
end
```

## Common Pitfalls and Anti-Patterns

### ❌ Adding `require 'rails_helper'`

```ruby
# ❌ BAD - redundant require
require 'rails_helper'

RSpec.describe User do
  # ...
end
```

### ❌ Adding redundant spec type

```ruby
# ❌ BAD - type is inferred from location
RSpec.describe User, type: :model do
  # ...
end
```

### ❌ Using leading double colons

```ruby
# ❌ BAD - leading double colons
RSpec.describe ::DynamicsGp::ERPSynchronizer do
  # ...
end

# ✅ GOOD
RSpec.describe DynamicsGp::ERPSynchronizer do
  # ...
end
```

### ❌ Empty test implementations

```ruby
# ❌ BAD
it "validates something" do
  # TODO: implement
end
```

### ❌ Not using shoulda matchers for validations

```ruby
# ❌ BAD - verbose
it "validates presence of name" do
  user = User.new
  user.valid?
  expect(user.errors[:name]).to include("can't be blank")
end

# ✅ GOOD - concise with shoulda
it { is_expected.to validate_presence_of(:name) }
```

### ❌ Testing implementation details

```ruby
# ❌ BAD - testing private methods
it "calls private method" do
  expect(user).to receive(:private_method)
  user.public_method
end

# ✅ GOOD - test behavior
it "formats name correctly" do
  user = User.new(first_name: "alice", last_name: "smith")
  expect(user.display_name).to eq("Alice Smith")
end
```

### ❌ Not using fixtures

```ruby
# ❌ BAD - slow database operations
it "does something" do
  user = User.create!(name: "Alice", email: "alice@example.com")
  # ...
end

# ✅ GOOD - fast fixture lookup
fixtures :users

it "does something" do
  user = users(:alice)
  # ...
end
```

### ❌ Poor describe/context organization

```ruby
# ❌ BAD - unclear organization
describe "User" do
  it "works" do
    # ...
  end
end

# ✅ GOOD - clear organization
RSpec.describe User do
  describe "#full_name" do
    context "when both names present" do
      it "returns combined name" do
        # ...
      end
    end
  end
end
```

## Best Practices Checklist

When writing RSpec tests, ensure:

**Critical Conventions**:
- [ ] NOT adding `require 'rails_helper'` (imported via .rspec)
- [ ] NOT adding redundant spec type (inferred from location)
- [ ] Using fully qualified namespace WITHOUT leading `::`
- [ ] Using `RSpec.describe` (not just `describe`)

**Test Organization**:
- [ ] Spec files mirror application structure
- [ ] Using `describe` for methods/classes
- [ ] Using `context` for conditions/scenarios
- [ ] Descriptive block names explaining behavior
- [ ] Limiting nesting to 3 levels maximum

**Test Data**:
- [ ] Using `fixtures` instead of factories
- [ ] Loading only needed fixtures per file
- [ ] Using `let` for lazy-loaded data
- [ ] Using `let!` only when eager evaluation needed
- [ ] Defining `subject` for method under test

**Test Structure**:
- [ ] Following AAA pattern (Arrange-Act-Assert)
- [ ] Testing behavior, not implementation
- [ ] Tests are isolated and independent
- [ ] Using `is_expected.to` with subject

**Test Coverage**:
- [ ] Testing happy path (success scenarios)
- [ ] Testing sad path (error handling)
- [ ] Testing edge cases and boundaries
- [ ] Mocking external services appropriately

**Matchers**:
- [ ] Using shoulda matchers for validations
- [ ] Using shoulda matchers for associations
- [ ] Using appropriate RSpec matchers
- [ ] Using `change` matcher for state changes
- [ ] Clear, specific expectations

**Mocking**:
- [ ] Using `allow` for stubbing return values
- [ ] Using `expect(...).to receive` for verifying calls
- [ ] Mocking external services, not objects under test
- [ ] Not over-mocking; preferring real objects when fast

**Performance**:
- [ ] Minimizing database operations
- [ ] Using fixtures for speed
- [ ] Mocking external API calls
- [ ] Tests run quickly

## Quick Reference

### File Setup
```ruby
# ✅ Minimal spec file setup
RSpec.describe User do
  fixtures :users

  # Your tests here
end
```

### Common Patterns
```ruby
# Subject with let
subject(:full_name) { user.full_name }
let(:user) { users(:alice) }

# Shoulda matchers
it { is_expected.to validate_presence_of(:name) }
it { is_expected.to have_many(:posts) }

# Change matcher
expect { user.save }.to change(User, :count).by(1)

# Mocking
allow(Service).to receive(:call).and_return(result)
expect(Service).to receive(:call).with(args)

# Is expected
it { is_expected.to be_valid }
it { is_expected.to_not be_admin }
```
