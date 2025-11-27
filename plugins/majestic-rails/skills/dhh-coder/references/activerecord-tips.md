# ActiveRecord Tips Reference

Practical ActiveRecord patterns and tips for Rails applications.

## Query Building

### Using where.not for Negated Conditions

`where` can be called without arguments, returning a `WhereChain` for advanced queries like negation.

```ruby
# Find all invoices that are NOT paid
Invoice.where.not(state: :paid)
# => WHERE state != 'paid'

# where.not accepts multiple columns with AND
Invoice.where.not(state: :paid, amount_due: 0)
# => WHERE NOT (state = 'paid' AND amount_due = 0)

# Combine where and where.not (joined with AND)
Invoice.where('amount_due > 0').where.not(state: :paid)
# => WHERE amount_due > 0 AND state != 'paid'
```

### Finding Records With/Without Associations

Use `where.missing` and `where.associated` to query based on association presence:

```ruby
# Find invoices without a payment
Invoice.where.missing(:payments)
# => Invoices where there are no associated payments

# Find invoices that have a payment
Invoice.where.associated(:payments)
# => Invoices with at least one payment

# Note: #missing and #associated use joins, so duplicates may occur
# Use .distinct to remove duplicates
Invoice.where.associated(:payments).distinct
```

### Sorting by Enum Values with in_order_of

Sort ActiveRecord models by enum values using a SQL CASE statement:

```ruby
class Proposal < ApplicationRecord
  enum status: {
    in_review: 0,
    accepted: 1,
    rejected: 2
  }
end

# Sort by custom enum order, then by name
Proposal
  .in_order_of(:status, %[accepted in_review rejected])
  .order(:name)
```

### Combining Scopes with OR

Use `#or` to combine relations with OR operator:

```ruby
# Identify accounts at risk of churn
inactive_accounts = Account.where('last_activity_at < ?', 14.days.ago)
low_activity_accounts = Account.where('actions_last_month < ?', 10)

# Combine with OR
target_accounts = inactive_accounts.or(low_activity_accounts)
# => WHERE last_activity_at < '...' OR actions_last_month < 10

# Use #or with HAVING clauses for grouped queries
top_revenue_accounts = Invoice.group(:account_id).having('SUM(total_amount) > ?', 10_000_00)
top_repeat_business_accounts = Invoice.group(:account_id).having('COUNT(*) >= 50')

top_accounts_count = top_revenue_accounts.or(top_repeat_business_accounts).count
# => GROUP BY account_id HAVING SUM(total_amount) > 1000000 OR COUNT(*) >= 50
```

## Validation Patterns

### Conditional Validation with Context

Use validation contexts to apply different rules in different scenarios:

```ruby
class User < ApplicationRecord
  # Validation for regular users (create/update contexts)
  validates :login, length: { minimum: 6 }, on: [:create, :update]

  # Different validation for admin contexts
  validates :login, length: { minimum: 1 }, on: [:admin_create, :admin_update]
end

class Admin::UsersController < Admin::ApplicationController
  def update
    user = User.find(params[:id])
    user.assign_attributes(user_params)

    # Can't use #update because there's no way to pass context
    # Instead, assign attributes first, then call save with context
    if user.save(context: :admin_update)
      redirect_to [:admin, user]
    end
  end
end
```

### Blocking Disposable Email Domains

Validate emails against a denylist of disposable email providers:

```ruby
# Script to populate denylist from external source
url = URI('https://raw.githubusercontent.com/disposable/disposable-email-domains/master/domains.txt')
response = Net::HTTP.get_response(url)
domains = response.body.split("\n")

domains.each do |domain|
  REDIS_CLIENT.sadd('users:denylist:domain', domain)
  print '.'
end

# app/models/user.rb
class User < ApplicationRecord
  validate :validate_email_domain_denylist

  def validate_email_domain_denylist
    if email.present? && REDIS_CLIENT.sismember('users:denylist:domain', email.split('@').last)
      errors.add(:email, 'not valid. Please contact support@example.com')
    end
  end
end
```

### Rich Error Objects with Symbols

Use symbol error codes for better i18n and testing:

```ruby
class Admin < ApplicationRecord
  EMAIL_DOMAIN = "@company.com"

  validate :email_domain_valid

  private

  def email_domain_valid
    return if email.blank?
    return if email.end_with?(EMAIL_DOMAIN)

    # Instead of string messages, use symbols with parameters
    errors.add(
      :email,                        # Attribute name
      :invalid_email_domain,         # Error code (for i18n lookup)
      expected: EMAIL_DOMAIN,        # Error parameters
      actual: email.split('@').last
    )
    # Error message via i18n: errors.messages.invalid_email_domain
  end
end

# Access detailed error info
admin.errors.details[:email]
# => [{:error=>:invalid_email_domain, :expected=>"@company.com", :actual=>"example.com"}]

# Build expressive test assertions
def assert_error(model, attribute, error)
  assert(
    model.errors.details[attribute].any? { _1[:error] == error },
    -> { "Expected #{model.class.name} to have an error #{error} on #{attribute}, but it wasn't found." }
  )
end
```

## Association Patterns

### Default Association Values with Block

Populate associations with defaults when empty:

```ruby
class Invoice < ApplicationRecord
  has_many :payment_reminders, -> { order_by_id },
    class_name: "Invoice::PaymentReminder",
    inverse_of: :invoice,
    dependent: :destroy do
      def with_defaults_if_none
        load_target

        if target.empty?
          Invoice::PaymentReminder::DEFAULTS.each do |attributes|
            build(attributes)
          end
        end

        target
      end
    end
end

# Usage
invoice = Invoice.find(1)

# Returns existing reminders, or builds defaults if none exist
invoice.payment_reminders                    # => []
invoice.payment_reminders.with_defaults_if_none  # => [<built defaults>]
```

## Migration Patterns

### Virtual Columns with SQL Expressions

Create derived columns stored in the database:

```ruby
class AddEncryptionKeyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :encryption_key, :virtual, options
  end

  private

  def options
    {
      type: :string,
      as: "LEFT(device_token, 12)",  # SQL expression
      stored: true                    # Persist in database
    }
  end
end

# Usage
user.device_token     # => "wTIsM5YiSmGS2r4fMJa7EZGea8xs3YzJ"
user.encryption_key   # => "wTIsM5YiSmGS" (auto-computed)
```

## Concern Patterns

### Resettable Attributes Concern

Reset attributes to column defaults dynamically:

```ruby
# app/models/concerns/resettable.rb
module Resettable
  extend ActiveSupport::Concern

  included do
    attribute_method_affix prefix: 'reset_', suffix: '_to_default!'
  end

  private

  def reset_attribute_to_default!(attr)
    send("#{attr}=", defaults[attr])
    save!
  end

  def defaults
    self.class.column_defaults
  end
end

# app/models/setting.rb
class Setting < ApplicationRecord
  include Resettable
end

# Usage
Setting.column_defaults  # => { 'theme_preference' => :light_default, ... }

setting = Setting.create(theme_preference: :dark_mode)
setting.theme_preference  # => :dark_mode

setting.reset_theme_preference_to_default!
setting.theme_preference  # => :light_default
```

## Performance Patterns

### Slow Query Monitoring with Notifications

Subscribe to ActiveRecord notifications to detect slow queries:

```ruby
# config/initializers/slow_query_monitoring.rb
class SlowQueryError < StandardError; end

ActiveSupport::Notifications.subscribe('sql.active_record') do |_, start, finish, _, payload|
  duration = finish.to_f - start.to_f

  if duration > 3.0  # Query took longer than 3 seconds
    # Notify error tracking service
    Honeybadger.notify(SlowQueryError.new(payload[:sql].to_s))
  end
end
```
