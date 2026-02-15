# Minitest Spec Style Patterns

## Using `let` for Shared Data

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

## Defining `subject` for Method Under Test

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

## Nested `describe` Blocks

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

## Using `before` for Complex Setup

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

---

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
