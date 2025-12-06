---
name: business-logic-coder
description: Implement business logic with ActiveInteraction and AASM state machines. Use when creating typed operations, managing state transitions, or refactoring service objects. Triggers on interaction creation, state machines, workflows, or typed business operations.
---

# Business Logic Patterns

Implement business logic with ActiveInteraction and AASM state machines - the structured alternatives to service objects.

## When to Use This Skill

- Creating business operations with typed inputs
- Implementing state machines for workflows
- Refactoring service objects to interactions
- Managing complex state transitions
- Composing business operations

## Core Principle: Interactions Over Service Objects

**Use ActiveInteraction instead of service objects.**

| Service Objects | ActiveInteraction |
|-----------------|-------------------|
| No standard interface | Consistent `.run` / `.run!` |
| Manual type checking | Built-in type declarations |
| Manual validation | Standard Rails validations |
| Hard to compose | Native composition |
| Verbose boilerplate | Clean, self-documenting |

## Setup

```ruby
# Gemfile
gem "active_interaction", "~> 5.3"
gem "aasm", "~> 5.5"
```

## ActiveInteraction Basics

### Simple Interaction

```ruby
# app/interactions/users/create.rb
module Users
  class Create < ActiveInteraction::Base
    # Typed inputs
    string :email
    string :name
    string :password, default: nil

    # Validations
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :name, presence: true

    # Main logic
    def execute
      user = User.create!(
        email: email,
        name: name,
        password: password || SecureRandom.alphanumeric(32)
      )

      UserMailer.welcome(user).deliver_later
      user  # Return value becomes outcome.result
    end
  end
end
```

### Running Interactions

```ruby
# In controller
def create
  outcome = Users::Create.run(
    email: params[:email],
    name: params[:name]
  )

  if outcome.valid?
    redirect_to outcome.result, notice: "User created"
  else
    @errors = outcome.errors
    render :new, status: :unprocessable_entity
  end
end

# With bang method (raises on error)
user = Users::Create.run!(email: "user@example.com", name: "John")
```

### Input Types

```ruby
class MyInteraction < ActiveInteraction::Base
  # Primitives
  string :name
  integer :age
  float :price
  boolean :active
  symbol :status

  # Date/Time
  date :birthday
  time :created_at
  date_time :scheduled_at

  # Complex types
  array :tags
  hash :metadata

  # Model instances
  object :user, class: User

  # Typed arrays
  array :emails, default: [] do
    string
  end

  # Optional with default
  string :optional_field, default: nil
  integer :count, default: 0
end
```

### Composing Interactions

```ruby
module Users
  class Register < ActiveInteraction::Base
    string :email, :name, :password

    def execute
      # Compose calls another interaction
      user = compose(Users::Create,
        email: email,
        name: name,
        password: password
      )

      # Errors automatically merged if nested fails
      compose(Users::SendWelcomeEmail, user: user)
      user
    end
  end
end
```

## State Machines (AASM)

### Basic State Machine

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :paid
    state :processing
    state :shipped
    state :cancelled

    event :pay do
      transitions from: :pending, to: :paid

      after do
        OrderMailer.payment_received(self).deliver_later
      end
    end

    event :process do
      transitions from: :paid, to: :processing
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end

    event :cancel do
      transitions from: [:pending, :paid], to: :cancelled

      before do
        refund_payment if paid?
      end
    end
  end
end
```

### Usage

```ruby
order = Order.create!
order.pending?      # => true
order.may_pay?      # => true
order.pay!          # Transition + callbacks
order.paid?         # => true

order.may_ship?     # => false (must process first)
order.aasm.events   # => [:process, :cancel]

# Scopes created automatically
Order.pending
Order.paid.where(user: current_user)
```

### Guards

```ruby
event :pay do
  transitions from: :pending, to: :paid, guard: :payment_valid?
end

def payment_valid?
  payment_method.present? && total > 0
end

# Usage
order.pay!  # Raises AASM::InvalidTransition if guard fails
order.pay   # Returns false (no exception)
```

## Controller Pattern

```ruby
class ArticlesController < ApplicationController
  def create
    outcome = Articles::Create.run(
      title: params[:article][:title],
      body: params[:article][:body],
      author: current_user
    )

    if outcome.valid?
      redirect_to article_path(outcome.result), notice: "Article created"
    else
      @article = Article.new(article_params)
      @article.errors.merge!(outcome.errors)
      render :new, status: :unprocessable_entity
    end
  end
end
```

## Testing

### Testing Interactions

```ruby
RSpec.describe Users::Create do
  let(:valid_params) { { email: "user@example.com", name: "John" } }

  it "creates user with valid inputs" do
    expect { described_class.run(valid_params) }
      .to change(User, :count).by(1)
  end

  it "returns valid outcome" do
    outcome = described_class.run(valid_params)
    expect(outcome).to be_valid
    expect(outcome.result).to be_a(User)
  end

  it "validates email format" do
    outcome = described_class.run(valid_params.merge(email: "invalid"))
    expect(outcome).not_to be_valid
    expect(outcome.errors[:email]).to be_present
  end
end
```

### Testing State Machines

```ruby
RSpec.describe Order do
  let(:order) { create(:order) }

  it "starts in pending state" do
    expect(order).to be_pending
  end

  describe "pay event" do
    it "transitions to paid" do
      expect { order.pay! }
        .to change(order, :status).from("pending").to("paid")
    end
  end

  describe "ship event" do
    context "when pending" do
      it "raises error" do
        expect { order.ship! }.to raise_error(AASM::InvalidTransition)
      end
    end
  end
end
```

## Detailed References

For advanced patterns:
- `references/active-interaction.md` - Composition, error handling, custom types
- `references/aasm-patterns.md` - Callbacks, multiple state machines, persistence

## Related Skills

- **`event-sourcing-coder`** - For recording domain events and dispatching to inbox handlers. Use when AASM state transitions should trigger notifications, webhooks, or audit trails.
