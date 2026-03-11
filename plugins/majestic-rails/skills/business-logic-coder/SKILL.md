---
name: business-logic-coder
description: Implement business logic with ActiveInteraction and AASM state machines. Routes to specialized skills for typed operations and state management.
---

# Business Logic Patterns

Orchestrator for structured business logic in Rails.

## Skill Routing

| Need | Skill | Use When |
|------|-------|----------|
| Typed operations | `active-interaction-coder` | Creating business operations, refactoring service objects |
| State machines | `aasm-coder` | Implementing workflows, managing state transitions |

## When to Use Each

### ActiveInteraction

Use for **operations** - things that happen once:

- User registration
- Order placement
- Payment processing
- Data imports
- Report generation

```ruby
# Example: One-time operation with typed inputs
outcome = Users::Create.run(email: email, name: name)
```

### AASM

Use for **state management** - things with lifecycle:

- Order status (pending → paid → shipped)
- Subscription state (trial → active → cancelled)
- Document workflow (draft → review → published)
- Task status (todo → in_progress → done)

```ruby
# Example: Stateful entity with transitions
order.pay!  # pending → paid
order.ship! # paid → shipped
```

## Combined Pattern

Often used together - interactions trigger state changes:

```ruby
module Orders
  class Process < ActiveInteraction::Base
    object :order, class: Order

    def execute
      order.process!  # AASM transition
      fulfill_order(order)
      order
    end
  end
end
```

## Setup

```ruby
# Gemfile
gem "active_interaction", "~> 5.3"
gem "aasm", "~> 5.5"
```

## Quick Reference

**ActiveInteraction:**
- `.run` - Returns outcome (check `.valid?`)
- `.run!` - Raises on failure
- `compose` - Call nested interactions

**AASM:**
- `.event!` - Transition or raise
- `.event` - Transition or return false
- `.may_event?` - Check if transition valid
- `.aasm.events` - List available events

## Transaction Boundaries

When business logic involves multi-step database operations, enforce proper transaction boundaries.

### Atomic Operations

```ruby
# PROBLEM: Partial failure leaves inconsistent state
def transfer_funds(from, to, amount)
  from.update!(balance: from.balance - amount)
  to.update!(balance: to.balance + amount)  # May fail!
end

# SOLUTION: Transaction wrapper with locking
def transfer_funds(from, to, amount)
  ActiveRecord::Base.transaction do
    from.lock!
    to.lock!
    from.update!(balance: from.balance - amount)
    to.update!(balance: to.balance + amount)
  end
end
```

### Isolation Levels

```ruby
# Default: READ COMMITTED (each query sees latest committed data)
# REPEATABLE READ: All reads see same snapshot
ActiveRecord::Base.transaction(isolation: :repeatable_read) do
  # Consistent reads for reports
end

# SERIALIZABLE: Full isolation (may cause serialization failures)
ActiveRecord::Base.transaction(isolation: :serializable) do
  # Strictest isolation, retry on failure
end
```

### Deadlock Prevention

**Rules:**
1. Lock records in consistent order (by ID ascending)
2. Keep transactions short
3. No user input inside transactions
4. No external API calls inside transactions

```ruby
# PROBLEM: Deadlock risk (inconsistent lock order)
def swap_owners(item_a, item_b)
  transaction do
    item_a.lock!  # Thread 1 locks A
    item_b.lock!  # Thread 2 locks B -> deadlock!
  end
end

# SOLUTION: Consistent lock order
def swap_owners(item_a, item_b)
  items = [item_a, item_b].sort_by(&:id)
  transaction do
    items.each(&:lock!)
    # Safe: always locks lower ID first
  end
end
```

### Transaction Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Long transactions | Lock contention | Split into smaller units |
| API calls inside | Timeout blocks DB | Call outside, then transact |
| User input inside | Indefinite locks | Validate first, transact last |
| Nested transactions | Savepoint confusion | Use `requires_new: true` explicitly |

### Nested Transactions

```ruby
# PROBLEM: Inner rollback doesn't work as expected
transaction do
  create_order!
  transaction do  # This is a savepoint, not new transaction
    charge_card!  # Failure rolls back to savepoint only
  end
end

# SOLUTION: Explicit new transaction
transaction do
  create_order!
  transaction(requires_new: true) do
    charge_card!  # Failure rolls back only this block
  end
end
```

## Related Skills

- **`event-sourcing-coder`** - Record domain events from state transitions
