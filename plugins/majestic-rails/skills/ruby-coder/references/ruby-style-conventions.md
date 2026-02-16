# Ruby Style Conventions Reference

## Naming Conventions

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

## Naming Patterns

- Predicate methods end with `?`: `valid?`, `active?`, `empty?`
- Dangerous methods end with `!`: `save!`, `update!`, `destroy!`
- Boolean variables: `is_admin`, `has_permission`, `can_edit`

## Semantic Methods

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

## Symbols Over Strings

Use symbols for identifiers and hash keys for better performance:

```ruby
# Good - symbols for identifiers
status = :active
options = { method: :post, format: :json }
```

## Enumerable Methods

```ruby
prices = items.map(&:price)
active_users = users.select(&:active?)
valid_emails = emails.reject(&:blank?)
total = prices.reduce(0, :+)

grouped = items.each_with_object({}) do |item, hash|
  hash[item.category] ||= []
  hash[item.category] << item
end

has_admin = users.any?(&:admin?)
all_valid = records.all?(&:valid?)
```

## Composition Over Inheritance

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

report = Report.new(DatabaseSource.new, PDFFormatter.new)
```
