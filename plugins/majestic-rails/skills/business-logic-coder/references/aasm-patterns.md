# AASM State Machine Patterns

## Table of Contents
- [Basic Setup](#basic-setup)
- [Events and Transitions](#events-and-transitions)
- [Guards](#guards)
- [Callbacks](#callbacks)
- [Scopes](#scopes)
- [Multiple State Machines](#multiple-state-machines)
- [Testing](#testing)
- [Best Practices](#best-practices)

## Basic Setup

### Simple State Machine

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :paid
    state :processing
    state :shipped
    state :delivered
    state :cancelled
    state :refunded

    event :pay do
      transitions from: :pending, to: :paid
    end

    event :process do
      transitions from: :paid, to: :processing
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end

    event :deliver do
      transitions from: :shipped, to: :delivered
    end

    event :cancel do
      transitions from: [:pending, :paid], to: :cancelled
    end

    event :refund do
      transitions from: :delivered, to: :refunded
    end
  end
end
```

### Configuration Options

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status,                    # Database column
       enum: true,                          # Use Rails enum
       whiny_transitions: true,             # Raise on invalid transitions
       whiny_persistence: true,             # Raise on save failures
       skip_validation_on_save: false,      # Run validations
       no_direct_assignment: true do        # Prevent status = "paid"

    state :pending, initial: true
    # ...
  end
end
```

## Events and Transitions

### Multiple Transitions

```ruby
event :approve do
  transitions from: :pending, to: :approved, guard: :manager_approval?
  transitions from: :pending, to: :auto_approved, guard: :auto_approve?
  transitions from: :rejected, to: :approved  # Re-approval
end
```

### Transition with Conditions

```ruby
event :complete do
  transitions from: :processing, to: :completed,
    if: -> { items_delivered? && payment_received? }

  transitions from: :processing, to: :partial,
    unless: :all_items_shipped?
end
```

### Dynamic Transitions

```ruby
event :escalate do
  transitions from: :open, to: :escalated,
    after: -> { assign_to(next_level_support) }
end

event :assign do
  transitions from: [:open, :escalated], to: :assigned,
    after: ->(assignee) { update!(assigned_to: assignee) }
end

# Usage
ticket.assign!(current_user)
```

## Guards

### Simple Guards

```ruby
event :pay do
  transitions from: :pending, to: :paid, guard: :payment_valid?
end

private

def payment_valid?
  payment_method.present? && total > 0
end
```

### Multiple Guards

```ruby
event :ship do
  transitions from: :processing, to: :shipped,
    guards: [:address_valid?, :inventory_available?, :payment_cleared?]
end

# All guards must return true for transition to proceed
```

### Guard with Parameters

```ruby
event :approve do
  transitions from: :pending, to: :approved,
    guard: :can_approve?
end

def can_approve?(approver)
  approver.manager? || approver.admin?
end

# Usage
order.approve!(current_user)  # approver passed to guard
```

### Guard Classes

```ruby
class OrderShippingGuard
  def call(order)
    order.shipping_address.present? &&
      order.items.all?(&:in_stock?) &&
      order.payment_cleared?
  end
end

event :ship do
  transitions from: :processing, to: :shipped,
    guard: OrderShippingGuard.new
end
```

## Callbacks

### Callback Types

```ruby
event :pay do
  before do
    validate_payment_method!
  end

  after do
    send_receipt
    update_inventory
  end

  success do
    Rails.logger.info "Order #{id} paid successfully"
  end

  error do |e|
    Rails.logger.error "Payment failed: #{e.message}"
    notify_admin(e)
  end

  transitions from: :pending, to: :paid
end
```

### Callback Order

```ruby
# Execution order:
# 1. before (on event)
# 2. before_exit (on from state)
# 3. before_enter (on to state)
# 4. [TRANSITION HAPPENS]
# 5. after_exit (on from state)
# 6. after_enter (on to state)
# 7. after (on event)
# 8. success (on event, only if save succeeds)

state :pending do
  exit do
    log_state_exit(:pending)
  end
end

state :paid do
  enter do
    record_payment_time
  end
end
```

### Async Callbacks

```ruby
event :pay do
  after do
    PaymentReceiptJob.perform_later(self)
    InventoryUpdateJob.perform_later(self)
  end

  transitions from: :pending, to: :paid
end
```

### Transaction Safety

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status, requires_new_transaction: false do
    # Callbacks run within the same transaction as state change
  end

  event :pay do
    after do
      # This runs in the same transaction
      # If this raises, the state change is rolled back
      Payment.create!(order: self, amount: total)
    end

    transitions from: :pending, to: :paid
  end
end
```

## Scopes

### Automatic Scopes

```ruby
# AASM creates scopes for each state
Order.pending      # => All pending orders
Order.paid         # => All paid orders
Order.shipped      # => All shipped orders

# Chainable with other scopes
Order.paid.where(user: current_user)
Order.pending.where("created_at < ?", 1.day.ago)
```

### Disable Automatic Scopes

```ruby
aasm column: :status, create_scopes: false do
  # No scopes created
end
```

### Custom Scopes

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status do
    # ...
  end

  # Custom scope combining states
  scope :active, -> { where(status: %w[pending paid processing shipped]) }
  scope :completed, -> { where(status: %w[delivered refunded]) }
  scope :problematic, -> { cancelled.or(where("created_at < ? AND status = ?", 7.days.ago, "pending")) }
end
```

## Multiple State Machines

### Separate Concerns

```ruby
class Article < ApplicationRecord
  include AASM

  # Publication workflow
  aasm :publication, column: :publication_status do
    state :draft, initial: true
    state :submitted
    state :approved
    state :published
    state :archived

    event :submit do
      transitions from: :draft, to: :submitted
    end

    event :approve do
      transitions from: :submitted, to: :approved
    end

    event :publish do
      transitions from: :approved, to: :published
    end

    event :archive do
      transitions from: :published, to: :archived
    end
  end

  # Review workflow
  aasm :review, column: :review_status do
    state :unreviewed, initial: true
    state :reviewing
    state :reviewed

    event :start_review do
      transitions from: :unreviewed, to: :reviewing
    end

    event :complete_review do
      transitions from: :reviewing, to: :reviewed
    end
  end
end

# Usage
article.submit!          # publication workflow
article.start_review!    # review workflow

article.published?       # publication state check
article.reviewing?       # review state check
```

### Coordinated State Machines

```ruby
class Order < ApplicationRecord
  include AASM

  aasm :order, column: :status do
    state :pending, initial: true
    state :completed

    event :complete do
      transitions from: :pending, to: :completed,
        guard: :payment_completed?
    end
  end

  aasm :payment, column: :payment_status do
    state :unpaid, initial: true
    state :paid
    state :refunded

    event :pay do
      transitions from: :unpaid, to: :paid
      after { complete! if may_complete? }
    end
  end

  def payment_completed?
    paid?  # From payment state machine
  end
end
```

## Testing

### State Testing

```ruby
RSpec.describe Order do
  describe "state machine" do
    let(:order) { create(:order) }

    it "starts in pending state" do
      expect(order).to be_pending
      expect(order.status).to eq("pending")
    end

    describe "#may_pay?" do
      context "when pending" do
        it "returns true" do
          expect(order.may_pay?).to be true
        end
      end

      context "when already paid" do
        before { order.pay! }

        it "returns false" do
          expect(order.may_pay?).to be false
        end
      end
    end
  end
end
```

### Transition Testing

```ruby
RSpec.describe Order do
  describe "#pay!" do
    let(:order) { create(:order) }

    it "transitions from pending to paid" do
      expect { order.pay! }
        .to change(order, :status).from("pending").to("paid")
    end

    it "sends payment receipt" do
      expect { order.pay! }
        .to have_enqueued_mail(OrderMailer, :payment_receipt)
    end

    context "when already paid" do
      before { order.pay! }

      it "raises error" do
        expect { order.pay! }
          .to raise_error(AASM::InvalidTransition)
      end
    end
  end
end
```

### Guard Testing

```ruby
RSpec.describe Order do
  describe "#ship!" do
    let(:order) { create(:order, :paid, :processed) }

    context "with valid shipping address" do
      before { order.update!(shipping_address: "123 Main St") }

      it "transitions to shipped" do
        expect { order.ship! }
          .to change(order, :status).from("processing").to("shipped")
      end
    end

    context "without shipping address" do
      before { order.update!(shipping_address: nil) }

      it "raises error" do
        expect { order.ship! }
          .to raise_error(AASM::InvalidTransition)
      end

      it "returns false with non-bang method" do
        expect(order.ship).to be false
      end
    end
  end
end
```

### Callback Testing

```ruby
RSpec.describe Order do
  describe "pay event callbacks" do
    let(:order) { create(:order) }

    it "runs before callback" do
      expect(order).to receive(:validate_payment_method!)
      order.pay!
    end

    it "runs after callback" do
      expect(order).to receive(:send_receipt)
      order.pay!
    end

    it "enqueues background job" do
      expect { order.pay! }
        .to have_enqueued_job(PaymentProcessingJob)
    end
  end
end
```

## Best Practices

### Keep States Simple

```ruby
# Good: Clear, meaningful states
state :pending
state :approved
state :rejected

# Avoid: Compound or unclear states
state :pending_approval_from_manager
state :approved_but_not_processed
```

### Use Guards for Business Rules

```ruby
# Good: Guard encapsulates business logic
event :approve do
  transitions from: :pending, to: :approved,
    guard: :meets_approval_criteria?
end

# Avoid: Logic in controller
def approve
  if order.total < 1000 && order.customer.verified?
    order.approve!
  end
end
```

### Prefer Callbacks Over Controller Logic

```ruby
# Good: Side effects in callbacks
event :ship do
  after do
    create_shipment_record
    send_tracking_email
    update_inventory
  end

  transitions from: :processing, to: :shipped
end

# Avoid: Side effects in controller
def ship
  @order.ship!
  Shipment.create!(order: @order)
  OrderMailer.tracking(@order).deliver_later
  @order.items.each(&:decrement_stock!)
end
```

### Document State Transitions

```ruby
class Order < ApplicationRecord
  # Order Lifecycle:
  #
  # pending -> paid (customer completes payment)
  #         -> cancelled (customer cancels)
  #
  # paid -> processing (warehouse begins fulfillment)
  #      -> cancelled (refund issued)
  #
  # processing -> shipped (package handed to carrier)
  #
  # shipped -> delivered (carrier confirms delivery)
  #
  # delivered -> refunded (customer requests refund)

  include AASM
  # ...
end
```
