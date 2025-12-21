# Rails 8.1 Structured Event Reporting

Replace unstructured `Rails.logger` with `Rails.event` for modern observability.

## Why Structured Events

- Observability platforms parse JSON, build dashboards, alert on conditions
- Unstructured logs require brittle regex parsing
- Events include automatic metadata: timestamps, source locations, request context

## Core API

### Basic Event Emission

```ruby
# WRONG: Unstructured logging
Rails.logger.info("User created: id=#{user.id}, name=#{user.name}")

# CORRECT: Structured event
Rails.event.notify("user.signup", user_id: user.id, email: user.email)
```

### Two Methods Only

| Method | Purpose |
|--------|---------|
| `notify` | Production-relevant events |
| `debug` | Developer-focused debugging |

No traditional log levels (`info`, `warn`, `error`).

## Event Metadata

Every event automatically includes:

- **name**: Event identifier
- **payload**: Your event-specific data
- **tags**: Hierarchical context (nested)
- **context**: Request/job-level metadata
- **timestamp**: Nanosecond precision
- **source_location**: File, line, method

## Tags for Nested Context

Tags stack within blocks for logical grouping:

```ruby
Rails.event.tagged("checkout") do
  Rails.event.notify("checkout.started", cart_id: @cart.id)
  process_payment
  Rails.event.notify("checkout.completed", order_id: @order.id)
end
```

## Context for Request Scope

Set request-level metadata once, attached to all events:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_event_context

  private
    def set_event_context
      Rails.event.set_context(
        request_id: request.request_id,
        user_id: Current.user&.id,
        ip_address: request.remote_ip
      )
    end
end
```

## Debug Mode

Conditional debugging without polluting production:

```ruby
Rails.event.with_debug do
  Rails.event.debug("sql.query", sql: query, binds: binds)
end
```

## Subscribers

Register handlers for event processing:

```ruby
class LogSubscriber
  def emit(event)
    Rails.logger.info("[#{event[:name]}] #{event[:payload]}")
  end
end

# Multiple destinations
Rails.event.subscribe(LogSubscriber.new)
Rails.event.subscribe(DatadogSubscriber.new)
Rails.event.subscribe(SentrySubscriber.new)
```

## Custom Event Classes

Strongly-typed events for complex payloads:

```ruby
class OrderCompletedEvent
  attr_reader :order_id, :total, :item_count, :payment_method

  def initialize(order_id:, total:, item_count:, payment_method:)
    @order_id = order_id
    @total = total
    @item_count = item_count
    @payment_method = payment_method
  end
end

Rails.event.notify(OrderCompletedEvent.new(
  order_id: @order.id,
  total: @order.total,
  item_count: @order.items.count,
  payment_method: @order.payment_method
))
```

## Common Patterns

### Model Callbacks

```ruby
class Order < ApplicationRecord
  after_create_commit :emit_created_event

  private
    def emit_created_event
      Rails.event.notify("order.created",
        order_id: id,
        total: total,
        user_id: user_id
      )
    end
end
```

### Job Instrumentation

```ruby
class ProcessOrderJob < ApplicationJob
  def perform(order_id)
    Rails.event.tagged("jobs", "process_order") do
      Rails.event.set_context(order_id: order_id)

      Rails.event.notify("order.processing.started")
      process(order_id)
      Rails.event.notify("order.processing.completed")
    end
  end
end
```

### Service Instrumentation

```ruby
class PaymentProcessor
  def charge(amount:, payment_method:)
    Rails.event.tagged("payments") do
      Rails.event.notify("payment.initiated", amount: amount)

      result = gateway.charge(amount, payment_method)

      if result.success?
        Rails.event.notify("payment.succeeded", transaction_id: result.id)
      else
        Rails.event.notify("payment.failed", error: result.error)
      end

      result
    end
  end
end
```

## Migration from Rails.logger

| Before | After |
|--------|-------|
| `Rails.logger.info("msg")` | `Rails.event.notify("event.name", data: value)` |
| `Rails.logger.debug("msg")` | `Rails.event.debug("event.name", data: value)` |
| `Rails.logger.error("msg")` | `Rails.event.notify("error.type", error: msg)` |
| `Rails.logger.tagged("tag")` | `Rails.event.tagged("tag")` |

## Naming Conventions

Use dot-notation for event names:

```ruby
# Domain.action pattern
"user.signup"
"order.created"
"payment.failed"
"checkout.completed"

# Domain.resource.action for nested
"api.users.created"
"admin.orders.refunded"
```
