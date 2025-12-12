# Minitest Anti-Patterns

## Spec Style Anti-Patterns

### ❌ Too deeply nested (>3 levels)

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

### ✅ Properly organized

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

### ❌ Using @ivar when let is cleaner

```ruby
before do
  @user = User.new(name: "Alice")
  @order = Order.new(user: @user)
end

it "does something" do
  assert @order.user == @user
end
```

### ✅ Using let for lazy evaluation

```ruby
let(:user) { User.new(name: "Alice") }
let(:order) { Order.new(user:) }

it "does something" do
  assert_equal user, order.user
end
```

### ❌ Missing subject definition

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

### ✅ Using subject

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

---

## General Anti-Patterns

### ❌ Empty test implementations

```ruby
test "validates something" do
  # TODO: implement
end
```

### ❌ Wrong assertion methods

```ruby
test "validates presence" do
  user = User.new
  user.valid?
  assert user.errors[:name].include?("can't be blank")  # Wrong!
end
```

### ✅ Correct assertion methods

```ruby
test "validates presence" do
  user = User.new
  assert_not user.valid?
  assert_includes user.errors[:name], "can't be blank"  # Correct!
end
```

### ❌ Testing implementation details

```ruby
test "calls private method" do
  user = User.new
  assert user.send(:private_method)  # Don't test private methods!
end
```

### ✅ Testing behavior

```ruby
test "formats name correctly" do
  user = User.new(first_name: "alice", last_name: "smith")
  assert_equal "Alice Smith", user.display_name  # Test public API
end
```

### ❌ Not using fixtures

```ruby
test "something" do
  user = User.create!(name: "Alice", email: "alice@example.com")
  # Creating records is slow!
end
```

### ✅ Using fixtures

```ruby
test "something" do
  user = users(:alice)  # Fast fixture lookup
end
```
