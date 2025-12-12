# RSpec Anti-Patterns

## ❌ Adding `require 'rails_helper'`

```ruby
# ❌ BAD - redundant require
require 'rails_helper'

RSpec.describe User do
  # ...
end
```

## ❌ Adding redundant spec type

```ruby
# ❌ BAD - type is inferred from location
RSpec.describe User, type: :model do
  # ...
end
```

## ❌ Using leading double colons

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

## ❌ Empty test implementations

```ruby
# ❌ BAD
it "validates something" do
  # TODO: implement
end
```

## ❌ Not using shoulda matchers for validations

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

## ❌ Testing implementation details

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

## ❌ Not using fixtures

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

## ❌ Poor describe/context organization

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
