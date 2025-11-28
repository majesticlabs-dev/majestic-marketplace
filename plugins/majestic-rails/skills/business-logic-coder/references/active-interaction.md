# ActiveInteraction Advanced Patterns

## Table of Contents
- [Input Filters](#input-filters)
- [Validation](#validation)
- [Composition](#composition)
- [Error Handling](#error-handling)
- [Testing Patterns](#testing-patterns)
- [Organization](#organization)

## Input Filters

### All Input Types

```ruby
class CompleteInteraction < ActiveInteraction::Base
  # String inputs
  string :name
  string :description, default: nil  # Optional

  # Numeric inputs
  integer :quantity
  float :price
  decimal :tax_rate  # BigDecimal

  # Boolean inputs
  boolean :active
  boolean :featured, default: false

  # Symbol inputs
  symbol :status
  symbol :priority, default: :normal

  # Date/Time inputs
  date :start_date
  time :start_time
  date_time :scheduled_at

  # Complex inputs
  array :tags, default: []
  hash :metadata, default: {}

  # Model inputs
  object :user, class: User
  object :author, class: User, default: nil

  # Interface inputs (duck typing)
  interface :notifier  # Must respond to specific methods
end
```

### Typed Arrays

```ruby
class BulkCreate < ActiveInteraction::Base
  # Array of strings
  array :emails do
    string
  end

  # Array of integers
  array :quantities do
    integer
  end

  # Array of objects
  array :users do
    object class: User
  end

  # Nested array
  array :matrix do
    array do
      integer
    end
  end
end
```

### Typed Hashes

```ruby
class CreateWithSettings < ActiveInteraction::Base
  hash :settings do
    boolean :notifications
    integer :max_items
    string :theme, default: "light"

    # Nested hash
    hash :email_preferences do
      boolean :marketing
      boolean :transactional
    end
  end

  def execute
    User.create!(
      settings: settings
    )
  end
end
```

### Custom Filters

```ruby
class MoneyFilter < ActiveInteraction::Filter
  def database_column_type
    :decimal
  end

  def cast(value, context)
    return value if value.is_a?(Money)

    Money.new(value.to_d * 100, context[:currency] || "USD")
  end
end

ActiveInteraction::Base.filter(:money, MoneyFilter)

class ProcessPayment < ActiveInteraction::Base
  money :amount

  def execute
    # amount is now a Money object
    PaymentService.charge(amount)
  end
end
```

## Validation

### Standard Validations

```ruby
class CreateUser < ActiveInteraction::Base
  string :email
  string :name
  string :password
  integer :age

  # Standard Rails validations
  validates :email,
    presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 100 }

  validates :password,
    length: { minimum: 12 },
    allow_nil: true

  validates :age,
    numericality: { greater_than_or_equal_to: 18 }
end
```

### Custom Validations

```ruby
class CreateArticle < ActiveInteraction::Base
  string :title
  string :body
  object :author, class: User

  validate :author_can_create_articles
  validate :title_not_duplicate

  private

  def author_can_create_articles
    return if author.can?(:create, Article)

    errors.add(:author, "is not allowed to create articles")
  end

  def title_not_duplicate
    return unless Article.exists?(title: title)

    errors.add(:title, "already exists")
  end
end
```

### Conditional Validation

```ruby
class CreateOrder < ActiveInteraction::Base
  string :email
  object :user, class: User, default: nil
  boolean :guest_checkout, default: false

  validates :email,
    presence: true,
    if: :guest_checkout

  validates :user,
    presence: true,
    unless: :guest_checkout
end
```

## Composition

### Basic Composition

```ruby
module Orders
  class Process < ActiveInteraction::Base
    object :order, class: Order

    def execute
      # Compose validates and runs the nested interaction
      # If it fails, errors are merged and execution stops
      compose(ValidateInventory, order: order)
      compose(ChargePayment, order: order)
      compose(CreateShipment, order: order)
      compose(SendConfirmation, order: order)

      order.process!
      order
    end
  end
end
```

### Conditional Composition

```ruby
class ProcessOrder < ActiveInteraction::Base
  object :order, class: Order

  def execute
    compose(ValidateInventory, order: order)

    if order.requires_payment?
      compose(ChargePayment, order: order)
    end

    if order.requires_shipping?
      compose(CreateShipment, order: order)
    end

    order.complete!
  end
end
```

### Error Handling in Composition

```ruby
class CreateUserWithProfile < ActiveInteraction::Base
  string :email
  string :name
  hash :profile_data

  def execute
    user = compose(CreateUser, email: email, name: name)

    # If CreateUser fails, this line never executes
    # and errors from CreateUser are returned

    compose(CreateProfile, user: user, data: profile_data)

    user
  rescue => e
    errors.add(:base, e.message)
    nil
  end
end
```

## Error Handling

### Manual Errors

```ruby
class TransferFunds < ActiveInteraction::Base
  object :from_account, class: Account
  object :to_account, class: Account
  decimal :amount

  def execute
    if from_account.balance < amount
      errors.add(:amount, "exceeds available balance")
      return
    end

    if from_account == to_account
      errors.add(:base, "Cannot transfer to same account")
      return
    end

    perform_transfer
  end

  private

  def perform_transfer
    ActiveRecord::Base.transaction do
      from_account.withdraw!(amount)
      to_account.deposit!(amount)
    end
  end
end
```

### Merging Errors from Models

```ruby
class CreateArticle < ActiveInteraction::Base
  string :title
  string :body

  def execute
    article = Article.new(title: title, body: body)

    unless article.save
      errors.merge!(article.errors)
      return
    end

    article
  end
end
```

### Controller Error Handling

```ruby
class ArticlesController < ApplicationController
  def create
    outcome = Articles::Create.run(article_params)

    if outcome.valid?
      redirect_to outcome.result
    else
      @article = Article.new(article_params)
      @article.errors.merge!(outcome.errors)
      render :new, status: :unprocessable_entity
    end
  end

  # API response
  def create_api
    outcome = Articles::Create.run(article_params)

    if outcome.valid?
      render json: outcome.result, status: :created
    else
      render json: { errors: outcome.errors }, status: :unprocessable_entity
    end
  end
end
```

## Testing Patterns

### Unit Testing

```ruby
RSpec.describe Users::Create do
  describe ".run" do
    let(:valid_inputs) do
      {
        email: "user@example.com",
        name: "John Doe",
        password: "SecurePassword123"
      }
    end

    context "with valid inputs" do
      it "creates a user" do
        expect { described_class.run(valid_inputs) }
          .to change(User, :count).by(1)
      end

      it "returns valid outcome" do
        outcome = described_class.run(valid_inputs)
        expect(outcome).to be_valid
      end

      it "returns the created user" do
        outcome = described_class.run(valid_inputs)
        expect(outcome.result).to be_a(User)
        expect(outcome.result.email).to eq("user@example.com")
      end

      it "sends welcome email" do
        expect { described_class.run(valid_inputs) }
          .to have_enqueued_mail(UserMailer, :welcome)
      end
    end

    context "with invalid inputs" do
      it "returns invalid outcome for missing email" do
        outcome = described_class.run(valid_inputs.except(:email))
        expect(outcome).not_to be_valid
        expect(outcome.errors[:email]).to include("is required")
      end

      it "validates email format" do
        outcome = described_class.run(valid_inputs.merge(email: "invalid"))
        expect(outcome).not_to be_valid
        expect(outcome.errors[:email]).to include("is invalid")
      end

      it "does not create user" do
        expect { described_class.run(valid_inputs.merge(email: nil)) }
          .not_to change(User, :count)
      end
    end
  end

  describe ".run!" do
    it "raises on invalid inputs" do
      expect { described_class.run!(email: nil) }
        .to raise_error(ActiveInteraction::InvalidInteractionError)
    end
  end
end
```

### Testing Composition

```ruby
RSpec.describe Orders::Process do
  let(:order) { create(:order) }

  it "validates inventory" do
    expect(ValidateInventory).to receive(:run!)
      .with(order: order)
      .and_call_original

    described_class.run!(order: order)
  end

  it "charges payment" do
    expect(ChargePayment).to receive(:run!)
      .with(order: order)
      .and_call_original

    described_class.run!(order: order)
  end

  context "when inventory validation fails" do
    before do
      allow(ValidateInventory).to receive(:run)
        .and_return(double(valid?: false, errors: double(full_messages: ["Out of stock"])))
    end

    it "returns invalid outcome" do
      outcome = described_class.run(order: order)
      expect(outcome).not_to be_valid
    end

    it "does not charge payment" do
      expect(ChargePayment).not_to receive(:run)
      described_class.run(order: order)
    end
  end
end
```

## Organization

### File Structure

```
app/interactions/
├── application_interaction.rb  # Base class
├── users/
│   ├── create.rb
│   ├── update.rb
│   ├── delete.rb
│   └── send_welcome_email.rb
├── articles/
│   ├── create.rb
│   ├── update.rb
│   ├── publish.rb
│   └── archive.rb
└── orders/
    ├── create.rb
    ├── process.rb
    ├── cancel.rb
    └── refund.rb
```

### Base Interaction

```ruby
# app/interactions/application_interaction.rb
class ApplicationInteraction < ActiveInteraction::Base
  # Shared behavior for all interactions

  private

  def current_user
    # Access from context if needed
    @_current_user
  end

  def log_action(action, details = {})
    Rails.logger.info("#{self.class.name} - #{action}: #{details}")
  end
end
```

### Namespaced Interactions

```ruby
# app/interactions/users/create.rb
module Users
  class Create < ApplicationInteraction
    string :email
    string :name

    def execute
      User.create!(email: email, name: name)
    end
  end
end

# Usage
Users::Create.run!(email: "user@example.com", name: "John")
```
