---
name: ruby-coder
description: This skill guides writing of new Ruby code following modern Ruby 3.x syntax, Sandi Metz's 4 Rules for Developers, and idiomatic Ruby best practices. Use when creating new Ruby files, writing Ruby methods, or refactoring Ruby code to ensure adherence to clarity, simplicity, and maintainability standards.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch
---

# Ruby Coder

## Overview

This skill provides comprehensive guidance for writing clean, idiomatic Ruby code that follows modern Ruby 3.x syntax, Sandi Metz's 4 Rules for Developers, and established best practices. Apply these standards when creating new Ruby files, implementing features, or refactoring existing code to ensure clarity, maintainability, and adherence to Ruby conventions.

## Core Philosophy

Prioritize:
- **Clarity over cleverness**: Code should be immediately understandable
- **Simplicity**: Prefer simple, readable solutions over clever code
- **Idiomatic Ruby**: Use Ruby's expressive capabilities appropriately
- **Sandi Metz's Rules**: Enforce strict limits to maintain code quality
- **DRY (Don't Repeat Yourself)**: Eliminate duplication thoughtfully
- **Composition over Inheritance**: Design for flexibility and reusability

## Ruby 3.x Modern Syntax

### Naming Conventions

```ruby
# snake_case for methods and variables
def calculate_total_price
  user_name = "David"
end

# CamelCase for classes and modules
module Vendors
  class User
  end
end

# SCREAMING_SNAKE_CASE for constants
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30
```

### Hash Shorthand Syntax

Use the shorthand syntax when hash keys match local variable names (requires exact matching between symbol key and variable name):

```ruby
# Modern Ruby 3.x shorthand
age = 49
name = "David"
user = { name:, age: }

# Instead of the verbose form
user = { name: name, age: age }
```

### String Interpolation

Prefer string interpolation over concatenation:

```ruby
# Good - interpolation
greeting = "Hello, #{user_name}!"
message = "Total: #{quantity * price}"

# Avoid - concatenation
greeting = "Hello, " + user_name + "!"
```

### Modern Hash Syntax

Use symbol keys with colon syntax:

```ruby
# Good - modern syntax
options = { timeout: 30, retry: true, method: :post }

# Avoid - hash rocket syntax (only use for non-symbol keys)
options = { :timeout => 30, :retry => true }
```

## Sandi Metz's 4 Rules for Developers

These rules enforce strict limits to maintain code quality. Breaking them requires explicit justification.

### Rule 1: Classes Can Be No Longer Than 100 Lines

**Limit**: Maximum 100 lines of code per class

**Check**: When a class exceeds this limit, extract secondary concerns to new classes

```ruby
# When exceeding 100 lines, extract secondary concerns:
class UserProfilePresenter  # Presentation logic
class UserProfileValidator  # Validation logic
class UserProfileNotifier   # Notification logic
```

**Exceptions**: Valid Single Responsibility Principle (SRP) justification required

### Rule 2: Methods Can Be No Longer Than 5 Lines

**Limit**: Maximum 5 lines per method

**Check**: Each if/else branch counts as lines; extract helper methods when needed

```ruby
# Good - 5 lines or fewer
def validate_user
  return if anonymous?
  check_email_format
  check_age_restriction
end

# Good - extraction when logic is complex
def process_order
  validate_order
  calculate_totals
  apply_discounts
  finalize_payment
end

private

def validate_order
  return false unless items.any?
  return false unless valid_address?
  true
end

def calculate_totals
  self.subtotal = items.sum(&:price)
  self.tax = subtotal * tax_rate
  self.total = subtotal + tax
end
```

**Exceptions**: Pair approval required (Rule 0: break rules with agreement)

### Rule 3: Pass No More Than 4 Parameters

**Limit**: Maximum 4 parameters per method

**Check**: Use parameter objects or hashes when more data is needed

```ruby
# Good - 4 parameters or fewer
def create_post(user, title, content, category)
  Post.create(
    user:,
    title:,
    content:,
    category:
  )
end

# Better - use parameter object when data is related
def create_post(post_params)
  Post.create(
    user: post_params.user,
    title: post_params.title,
    content: post_params.content,
    category: post_params.category,
    tags: post_params.tags
  )
end

# Good - hash options for flexible parameters
def send_notification(user, message, options = {})
  priority = options[:priority] || :normal
  delivery = options[:delivery] || :email
  # ...
end
```

**Exceptions**: Rails view helpers like `link_to` or `form_for` are exempt

### Rule 4: Controllers May Instantiate Only One Object

**Limit**: Controllers should instantiate only one object; other objects come through that object

**Pattern**: Use facade pattern to aggregate data and hide collaborator access

```ruby
# ✅ GOOD - single object via facade
class DashboardController < ApplicationController
  def show
    @dashboard = DashboardFacade.new(current_user)
  end
end

# ❌ AVOID - multiple instance variables
class DashboardController < ApplicationController
  def show
    @user = current_user
    @posts = @user.posts.recent
    @notifications = @user.notifications.unread
  end
end
```

**Implementation Tips**:
- Prefix unused instance variables with underscore: `@_calculation`
- Use facade pattern for complex views
- Avoid direct collaborator access in views: `@user.profile.avatar` → use facade method

## Idiomatic Ruby Patterns

### Use Semantic Methods

Leverage Ruby's expressive semantic methods instead of manual checks:

```ruby
# Good - semantic methods
return unless items.any?
return if email.blank?
return if user.present?

# Avoid - manual checks
return unless items.length > 0
return if email.nil? || email.empty?
return if !user.nil?
```

Common semantic methods:
- `any?` / `empty?` - for collections
- `present?` / `blank?` - for presence checks (Rails)
- `nil?` - for nil checks
- `zero?` / `positive?` / `negative?` - for numbers

### Prefer Symbols Over Strings

Use symbols for identifiers and hash keys for better performance:

```ruby
# Good - symbols for identifiers
status = :active
options = { method: :post, format: :json }

# Avoid - strings for identifiers
status = "active"
options = { method: "post", format: "json" }
```

### Leverage Enumerable Methods

Use Ruby's rich enumerable methods effectively:

```ruby
# map - transform collections
prices = items.map(&:price)
names = users.map { |u| u.display_name }

# select/reject - filter collections
active_users = users.select(&:active?)
valid_emails = emails.reject(&:blank?)

# reduce - aggregate values
total = prices.reduce(0, :+)
sum = numbers.reduce { |acc, n| acc + n }

# each_with_object - build new structures
grouped = items.each_with_object({}) do |item, hash|
  hash[item.category] ||= []
  hash[item.category] << item
end

# any?/all?/none? - boolean checks
has_admin = users.any?(&:admin?)
all_valid = records.all?(&:valid?)
```

### Use Guard Clauses

Prefer early returns over nested conditionals:

```ruby
# Good - guard clauses
def process_payment(order)
  return unless order.valid?
  return if order.paid?
  return unless sufficient_funds?

  charge_customer(order)
  send_confirmation(order)
end

# Avoid - nested conditionals
def process_payment(order)
  if order.valid?
    if !order.paid?
      if sufficient_funds?
        charge_customer(order)
        send_confirmation(order)
      end
    end
  end
end
```

### Prefer Blocks and Yield

Use blocks to make code more expressive and flexible:

```ruby
# Good - with blocks
def measure_time
  start = Time.now
  yield
  Time.now - start
end

duration = measure_time { expensive_operation }

# Good - block parameters
users.each do |user|
  user.send_welcome_email
end

# Good - using & to convert symbol to proc
names = users.map(&:name)
```

## Code Quality Standards

### Composition Over Inheritance

Prefer composing behavior from smaller objects over deep inheritance hierarchies:

```ruby
# Good - composition
class Report
  def initialize(data_source, formatter)
    @data_source = data_source
    @formatter = formatter
  end

  def generate
    data = @data_source.fetch
    @formatter.format(data)
  end
end

# Usage
report = Report.new(DatabaseSource.new, PDFFormatter.new)

# Avoid - deep inheritance
class PDFReport < Report < BaseReport
  # Rigid hierarchy
end
```

### Proper Naming

Use descriptive, intention-revealing names:

```ruby
# Good - clear intent
def calculate_shipping_cost(weight, distance)
  base_rate = 5.00
  weight_charge = weight * 0.50
  distance_charge = distance * 0.10
  base_rate + weight_charge + distance_charge
end

# Avoid - unclear abbreviations
def calc_ship(w, d)
  br = 5.00
  wc = w * 0.50
  dc = d * 0.10
  br + wc + dc
end
```

Naming conventions:
- Predicate methods end with `?`: `valid?`, `active?`, `empty?`
- Dangerous methods end with `!`: `save!`, `update!`, `destroy!`
- Boolean variables: `is_admin`, `has_permission`, `can_edit`

### Thread Safety

Write thread-safe code when necessary:

```ruby
# Good - thread-safe singleton
class Configuration
  @instance_mutex = Mutex.new

  def self.instance
    return @instance if @instance

    @instance_mutex.synchronize do
      @instance ||= new
    end
  end
end

# Good - avoid shared mutable state
class RequestProcessor
  def initialize
    @mutex = Mutex.new
  end

  def process(request)
    @mutex.synchronize do
      # Critical section
    end
  end
end
```

### Idempotent Operations

Design operations to be safely repeatable:

```ruby
# Good - idempotent
def activate_user
  return if user.active?
  user.update(active: true)
  send_activation_email unless email_sent?
end

# Avoid - non-idempotent
def activate_user
  user.update(active: true)
  send_activation_email  # Sends every time!
end
```

## Refactoring Triggers

Extract classes when:
- Class exceeds 100 lines (Sandi Metz Rule 1)
- Class has multiple responsibilities
- Class name contains "And" or "Or"

Extract methods when:
- Method exceeds 5 lines (Sandi Metz Rule 2)
- Conditional logic is complex
- Code has nested loops or conditionals
- Comments explain what code does (code should be self-explanatory)

Use parameter objects when:
- Methods require more than 4 parameters (Sandi Metz Rule 3)
- Related parameters are always passed together
- Parameter list is growing over time

Create facades when:
- Controllers need multiple objects (Sandi Metz Rule 4)
- Views access nested collaborators
- Complex data aggregation is needed

## Best Practices Checklist

When writing Ruby code, ensure:

- [ ] Classes are under 100 lines
- [ ] Methods are 5 lines or fewer
- [ ] Methods have 4 or fewer parameters
- [ ] Controllers instantiate only one object
- [ ] Using modern Ruby 3.x syntax (hash shorthand, symbols)
- [ ] String interpolation instead of concatenation
- [ ] Semantic methods (`any?`, `present?`, `blank?`)
- [ ] Guard clauses instead of nested conditionals
- [ ] Symbols for identifiers and hash keys
- [ ] Enumerable methods (`map`, `select`, `reduce`)
- [ ] Composition over inheritance
- [ ] Descriptive, intention-revealing names
- [ ] Thread-safe code where needed
- [ ] Idempotent operations where appropriate

## When to Break Rules

Sandi Metz's "Rule 0": Break any of the 4 rules only with pair approval or clear justification.

Valid exceptions:
- **Rule 1 (100 lines)**: Clear SRP justification required
- **Rule 2 (5 lines)**: Complex but irreducible algorithms
- **Rule 3 (4 params)**: Rails view helpers exempt
- **Rule 4 (1 object)**: Simple views without facades

Document all exceptions with clear reasoning in code comments.

## References

For additional Sandi Metz guidance (code smells, refactoring, testing principles):
- `references/sandi-metz.md`
- `references/ruby-tips.md` - Type conversion, hash patterns, proc composition, refinements
