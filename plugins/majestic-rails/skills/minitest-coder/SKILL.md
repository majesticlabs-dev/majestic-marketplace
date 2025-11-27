---
name: minitest-coder
description: This skill guides writing comprehensive Minitest tests for Ruby and Rails applications. Use when creating test files, writing test cases, or testing new features. Covers both traditional and spec styles, fixtures, mocking, and Rails integration testing patterns.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch
---

# Minitest Coder

## Overview

This skill provides comprehensive guidance for writing effective Minitest tests in Ruby and Rails applications. Apply these standards when creating test files, implementing test coverage for new features, or refactoring existing tests to ensure clarity, thoroughness, and maintainability.

## Core Philosophy

Prioritize:
- **AAA Pattern**: Arrange-Act-Assert structure for clarity
- **Behavior over Implementation**: Test what code does, not how it does it
- **Isolation**: Tests should be independent and not affect each other
- **Descriptive Names**: Test descriptions should clearly explain expected behavior
- **Coverage**: Test both happy paths and edge cases
- **Fast Tests**: Minimize database operations and external calls
- **Readability**: Tests serve as living documentation

## Minitest Styles

Minitest supports two testing styles. Choose based on test complexity:

### Traditional Style (`Minitest::Test`)

**Best for**: Simple unit tests with straightforward assertions

**Syntax**: Uses `test "description"` blocks

**When to use**:
- Simple model validations
- Basic method testing
- Straightforward assertions without complex contexts

```ruby
class UserTest < ActiveSupport::TestCase
  test "validates presence of name" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end
end
```

### Spec Style (`Minitest::Spec`)

**Best for**: Complex scenarios with multiple contexts and shared setup

**Syntax**: Uses `describe`/`it` blocks with `let` and `subject`

**When to use**:
- Multiple related contexts
- Shared test data across tests
- Lazy evaluation needs
- Complex object setup

```ruby
class UserTest < ActiveSupport::TestCase
  describe "#full_name" do
    subject { user.full_name }

    let(:user) { User.new(first_name: "Buffy", last_name:) }

    describe "when user has single-word last name" do
      let(:last_name) { "Summers" }

      it "returns capitalized full name" do
        assert_equal "Buffy Summers", subject
      end
    end
  end
end
```

## Test Organization

### File Structure

Follow this standard Rails test directory structure:

```
test/
├── integration/      # Full-stack tests (UI, user flows)
├── models/           # Model unit tests
├── services/         # Service object tests
├── mailers/          # Mailer tests
├── jobs/             # Background job tests
├── fixtures/         # Test data
├── support/          # Helper modules and shared examples
└── test_helper.rb    # Rails test configuration
```

### Naming Conventions

**Test files**: Mirror the application structure
- Model: `app/models/user.rb` → `test/models/user_test.rb`
- Service: `app/services/order_processor.rb` → `test/services/order_processor_test.rb`
- Controller: `app/controllers/posts_controller.rb` → `test/controllers/posts_controller_test.rb`

**Test classes**: Use fully qualified namespace path with double colons
```ruby
# Good - fully qualified path
class Users::ProfileServiceTest < ActiveSupport::TestCase
end

# Avoid - nested modules
module Users
  class ProfileServiceTest < ActiveSupport::TestCase
  end
end
```

**Important**: Don't add `require 'test_helper'` to test files. Rails test runner imports it automatically.

### Organizing Test Cases

**Traditional style**: Group related tests together, use clear test names

```ruby
class UserTest < ActiveSupport::TestCase
  # Validation tests
  test "validates presence of name" do
    # ...
  end

  test "validates uniqueness of email" do
    # ...
  end

  # Method tests
  test "full_name returns first and last name" do
    # ...
  end
end
```

**Spec style**: Use `describe` blocks to group by method or context

```ruby
class UserTest < ActiveSupport::TestCase
  describe "#full_name" do
    # Tests for full_name method
  end

  describe "#avatar_url" do
    # Tests for avatar_url method
  end

  describe "validations" do
    # Validation tests
  end
end
```

## Spec Style Best Practices

### Use `let` for Shared Data

`let` provides lazy evaluation and clean variable management:

```ruby
class OrderProcessorTest < ActiveSupport::TestCase
  describe "#process" do
    # Lazy evaluation - only created when referenced
    let(:order) { orders(:paid_order) }
    let(:processor) { OrderProcessor.new(order) }
    let(:payment_amount) { 99.99 }

    it "charges the correct amount" do
      assert_equal payment_amount, processor.calculate_charge
    end
  end
end
```

**Benefits of `let`**:
- Lazy evaluation (created only when needed)
- Memoized within a single test
- Re-evaluated for each test (no state leakage)
- Cleaner than `@instance_variables`
- Supports dependency chains

**When NOT to use `let`**:
- Variable used in only one test → define inline
- Need eager execution → use `before do...end`
- Complex setup that doesn't need direct reference

### Define `subject` for Method Under Test

`subject` makes tests more readable and enables reuse across contexts:

```ruby
class UserTest < ActiveSupport::TestCase
  describe "#display_name" do
    subject { user.display_name }

    let(:user) { User.new(first_name: "Alice", last_name: "Smith") }

    it "returns the full name" do
      assert_equal "Alice Smith", subject
    end

    describe "when user has no last name" do
      let(:user) { User.new(first_name: "Alice") }

      it "returns only first name" do
        assert_equal "Alice", subject
      end
    end
  end
end
```

### Leverage Nested `describe` Blocks

Use nested blocks for different contexts, but limit to 3 levels maximum:

```ruby
class PaymentProcessorTest < ActiveSupport::TestCase
  describe "#process_payment" do
    subject { processor.process_payment }

    let(:processor) { PaymentProcessor.new(order) }

    describe "with valid payment method" do
      let(:order) { orders(:with_valid_card) }

      it "returns success status" do
        assert subject.success?
      end

      describe "with promotional discount" do
        before { order.apply_discount(code: "SAVE10") }

        it "applies discount before charging" do
          assert_equal 90.00, subject.charged_amount
        end
      end
    end

    describe "with invalid payment method" do
      let(:order) { orders(:with_expired_card) }

      it "returns failure status" do
        assert_not subject.success?
      end
    end
  end
end
```

**Nesting guidelines**:
- Max 3 levels deep (readability)
- Each level adds meaningful context
- Use `let` overrides to change data per context
- Keep test output readable

### Use `before` for Complex Setup

Use `before` blocks when setup is complex or objects aren't directly referenced:

```ruby
class OrderProcessorTest < ActiveSupport::TestCase
  describe "#process" do
    let(:order) { orders(:paid_order) }
    let(:processor) { OrderProcessor.new(order) }

    before do
      # Complex setup not directly referenced in tests
      Account.create(order:, tokens: 100)
      NotificationService.enable_webhooks
      Cache.clear
    end

    it "processes the order successfully" do
      assert processor.process
    end
  end
end
```

## Fixtures

Use fixtures for test data instead of factories:

### Creating Fixtures

**Location**: `test/fixtures/users.yml`

```yaml
# test/fixtures/users.yml
alice:
  name: Alice Smith
  email: alice@example.com
  created_at: <%= 2.days.ago %>

bob:
  name: Bob Jones
  email: bob@example.com
  admin: true
```

### Using Fixtures in Tests

```ruby
class UserTest < ActiveSupport::TestCase
  fixtures :users  # Load specific fixtures

  test "validates uniqueness of email" do
    user = User.new(
      name: "Charlie",
      email: users(:alice).email,  # Reference fixture
      password: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end
end
```

**Fixture best practices**:
- Name fixtures descriptively (`:alice`, `:paid_order`, `:admin_user`)
- Keep fixtures minimal and focused
- Use ERB for dynamic data (`<%= 2.days.ago %>`)
- Prefer fixtures over factories for speed
- Define associations clearly

## Mocking and Stubbing

### Stubbing Return Values

Use `stub` to replace method return values:

```ruby
class OrderProcessorTest < ActiveSupport::TestCase
  test "processes payment with valid card" do
    order = orders(:pending_order)

    PaymentGateway.stub :charge, true do
      processor = OrderProcessor.new(order)
      assert processor.process
      assert_equal "completed", order.reload.status
    end
  end
end
```

### Spec Style Stubbing

Combine `stub` with `subject` for clean syntax:

```ruby
class OrderProcessorTest < ActiveSupport::TestCase
  describe "#process" do
    subject { processor.process }

    let(:order) { orders(:paid_order) }
    let(:processor) { OrderProcessor.new(order) }

    it "updates order status with valid payment" do
      PaymentGateway.stub :charge, true do
        assert_changes -> { order.reload.status }, to: "completed" do
          subject
        end
      end
    end

    it "sends confirmation email on success" do
      PaymentGateway.stub :charge, true do
        assert_difference "ActionMailer::Base.deliveries.size", 1 do
          subject
        end
      end
    end
  end
end
```

### Mock Objects for Verification

Use mocks when you need to verify method calls:

```ruby
test "calls payment gateway with correct parameters" do
  order = orders(:pending_order)
  mock = Minitest::Mock.new
  mock.expect :charge, true, [order.id, order.total]

  PaymentGateway.stub :instance, mock do
    OrderProcessor.new(order).process
  end

  mock.verify
end
```

**Mocking best practices**:
- Mock external services (APIs, payment gateways)
- Avoid mocking objects under test
- Use `stub` for simple return values
- Use `mock` when verifying calls
- Reset mocks in `teardown` if needed

## Assertions and Test Helpers

### Common Assertions

```ruby
# Boolean assertions
assert user.valid?
assert_not user.admin?

# Equality
assert_equal "Alice", user.name
assert_in_delta 0.1, user.balance, 0.001  # Float comparison

# Collections
assert_includes users, admin_user
assert_empty order.items
assert_nil user.deleted_at

# Exceptions
assert_raises ActiveRecord::RecordInvalid do
  user.save!
end

# Changes (Rails)
assert_changes -> { user.reload.status }, from: "pending", to: "active" do
  user.activate!
end

assert_difference "User.count", 1 do
  User.create(name: "Charlie")
end

# Pattern matching
assert_match /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, user.email
```

### Rails-Specific Assertions

```ruby
# Route testing
assert_recognizes({ controller: "users", action: "show", id: "1" }, "/users/1")
assert_generates "/users/1", controller: "users", action: "show", id: "1"

# Redirect testing
assert_redirected_to user_path(user)

# Response testing (integration tests)
assert_response :success
assert_response :not_found
```

## AAA Pattern (Arrange-Act-Assert)

Structure all tests following the AAA pattern for clarity:

```ruby
test "processes refund for cancelled order" do
  # Arrange - Set up test data
  order = orders(:completed_order)
  refund_amount = order.total
  original_balance = order.user.account_balance

  # Act - Perform the action
  result = order.process_refund

  # Assert - Verify outcomes
  assert result.success?
  assert_equal "refunded", order.reload.status
  assert_equal original_balance + refund_amount, order.user.reload.account_balance
end
```

**With spec style**:
```ruby
describe "#process_refund" do
  subject { order.process_refund }  # Act

  # Arrange
  let(:order) { orders(:completed_order) }
  let(:refund_amount) { order.total }

  it "updates order status to refunded" do
    subject  # Act
    assert_equal "refunded", order.reload.status  # Assert
  end

  it "credits user account with refund amount" do
    assert_changes -> { order.user.reload.account_balance }, by: refund_amount do
      subject  # Act
    end  # Assert
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

**Controllers** (Integration tests):
- Route mapping
- Response status codes
- Redirects
- View rendering
- Parameter handling

**Jobs**:
- Job execution
- Retry logic
- Error handling
- Idempotency

### Coverage Examples

```ruby
# Model validations
class UserTest < ActiveSupport::TestCase
  test "validates presence of name" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "validates email format" do
    user = User.new(name: "Alice", email: "invalid")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end
end

# Service happy and sad paths
class OrderProcessorTest < ActiveSupport::TestCase
  describe "#process" do
    subject { processor.process }
    let(:processor) { OrderProcessor.new(order) }

    describe "with valid order" do
      let(:order) { orders(:valid_order) }

      it "completes successfully" do
        assert subject.success?
      end
    end

    describe "with insufficient inventory" do
      let(:order) { orders(:out_of_stock) }

      it "fails with inventory error" do
        assert_not subject.success?
        assert_equal "insufficient_inventory", subject.error_code
      end
    end
  end
end
```

## Common Pitfalls and Anti-Patterns

### Spec Style Anti-Patterns

❌ **Too deeply nested** (>3 levels)
```ruby
describe "#method" do
  describe "context 1" do
    describe "context 2" do
      describe "context 3" do
        describe "context 4" do  # Too deep!
          it "does something" do
            # Unreadable test output
          end
        end
      end
    end
  end
end
```

✅ **Properly organized**
```ruby
describe "#method" do
  describe "with valid input" do
    it "succeeds" do
      # Clear and readable
    end
  end

  describe "with invalid input" do
    it "fails with error" do
      # Clear and readable
    end
  end
end
```

❌ **Using @ivar when let is cleaner**
```ruby
before do
  @user = User.new(name: "Alice")
  @order = Order.new(user: @user)
end

it "does something" do
  assert @order.user == @user
end
```

✅ **Using let for lazy evaluation**
```ruby
let(:user) { User.new(name: "Alice") }
let(:order) { Order.new(user:) }

it "does something" do
  assert_equal user, order.user
end
```

❌ **Missing subject definition**
```ruby
describe "#calculate_total" do
  let(:order) { orders(:with_items) }

  it "returns correct total" do
    assert_equal 100.00, order.calculate_total  # Repetitive
  end

  it "includes tax" do
    assert_equal 110.00, order.calculate_total  # Repetitive
  end
end
```

✅ **Using subject**
```ruby
describe "#calculate_total" do
  subject { order.calculate_total }
  let(:order) { orders(:with_items) }

  it "returns correct total" do
    assert_equal 100.00, subject
  end

  it "includes tax" do
    assert_equal 110.00, subject
  end
end
```

### General Anti-Patterns

❌ **Empty test implementations**
```ruby
test "validates something" do
  # TODO: implement
end
```

❌ **Wrong assertion methods**
```ruby
test "validates presence" do
  user = User.new
  user.valid?
  assert user.errors[:name].include?("can't be blank")  # Wrong!
end
```

✅ **Correct assertion methods**
```ruby
test "validates presence" do
  user = User.new
  assert_not user.valid?
  assert_includes user.errors[:name], "can't be blank"  # Correct!
end
```

❌ **Testing implementation details**
```ruby
test "calls private method" do
  user = User.new
  assert user.send(:private_method)  # Don't test private methods!
end
```

✅ **Testing behavior**
```ruby
test "formats name correctly" do
  user = User.new(first_name: "alice", last_name: "smith")
  assert_equal "Alice Smith", user.display_name  # Test public API
end
```

❌ **Not using fixtures**
```ruby
test "something" do
  user = User.create!(name: "Alice", email: "alice@example.com")
  # Creating records is slow!
end
```

✅ **Using fixtures**
```ruby
test "something" do
  user = users(:alice)  # Fast fixture lookup
end
```

## Best Practices Checklist

When writing Minitest tests, ensure:

**Test Organization**:
- [ ] Test files mirror application structure
- [ ] Using fully qualified namespace paths (::)
- [ ] NOT adding `require 'test_helper'` (auto-imported)
- [ ] Grouping related tests with describe blocks (spec style)

**Test Style**:
- [ ] Using traditional style for simple tests
- [ ] Using spec style for complex contexts
- [ ] Using `let` for shared data across tests
- [ ] Defining `subject` for method under test
- [ ] Limiting nesting to 3 levels maximum

**Test Data**:
- [ ] Using fixtures instead of factories
- [ ] Naming fixtures descriptively
- [ ] Keeping fixtures minimal and focused

**Test Structure**:
- [ ] Following AAA pattern (Arrange-Act-Assert)
- [ ] Testing behavior, not implementation
- [ ] Tests are isolated and independent
- [ ] Descriptive test names explaining expected behavior

**Test Coverage**:
- [ ] Testing happy path (success scenarios)
- [ ] Testing sad path (error handling)
- [ ] Testing edge cases and boundaries
- [ ] Mocking external services appropriately

**Assertions**:
- [ ] Using correct assertion methods (`assert_includes` not `.include?`)
- [ ] Using Rails helpers (`assert_changes`, `assert_difference`)
- [ ] Clear, specific assertions

**Performance**:
- [ ] Minimizing database operations
- [ ] Using fixtures for speed
- [ ] Mocking external API calls
- [ ] Tests run quickly

## When to Choose Traditional vs Spec Style

**Use Traditional Style when**:
- Testing simple validations
- Writing straightforward unit tests
- No need for shared setup across tests
- Testing doesn't require complex contexts

**Use Spec Style when**:
- Testing multiple related contexts
- Need lazy evaluation with `let`
- Testing requires nested scenarios
- Want to define `subject` for reuse
- Complex object setup needed

**Can mix both styles** in the same test file if it improves clarity.

## References

For additional testing patterns and tips:
- `references/testing-tips.md` - Fixture DEFAULTS, CI configuration, Overcommit hooks, priority job testing
