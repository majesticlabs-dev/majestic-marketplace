# StoreModel Advanced Patterns

## Table of Contents
- [Nested Attributes](#nested-attributes)
- [Custom Types](#custom-types)
- [One-Of Types](#one-of-types)
- [Parent Tracking](#parent-tracking)
- [Unknown Attributes](#unknown-attributes)
- [Error Handling](#error-handling)
- [Database Considerations](#database-considerations)

## Nested Attributes

### accepts_nested_attributes_for

```ruby
class LineItem
  include StoreModel::Model

  attribute :name, :string
  attribute :quantity, :integer, default: 1
  attribute :price_cents, :integer
  attribute :_destroy, :boolean, default: false

  validates :name, :price_cents, presence: true
end

class Order < ApplicationRecord
  include StoreModel::NestedAttributes

  attribute :line_items, LineItem.to_array_type

  accepts_nested_attributes_for :line_items, allow_destroy: true
end
```

### Form Integration

```erb
<%= form_with model: @order do |f| %>
  <%= f.fields_for :line_items do |li| %>
    <%= li.text_field :name %>
    <%= li.number_field :quantity %>
    <%= li.number_field :price_cents %>
    <%= li.check_box :_destroy %>
  <% end %>
<% end %>
```

### Controller Params

```ruby
def order_params
  params.require(:order).permit(
    line_items_attributes: [:id, :name, :quantity, :price_cents, :_destroy]
  )
end
```

## Custom Types

### Define Custom Type

```ruby
class MoneyType < ActiveModel::Type::Value
  def cast(value)
    return value if value.is_a?(Money)
    return nil if value.blank?

    Money.new(value.to_i, "USD")
  end

  def serialize(value)
    value&.cents
  end
end

ActiveModel::Type.register(:money, MoneyType)
```

### Use in StoreModel

```ruby
class LineItem
  include StoreModel::Model

  attribute :name, :string
  attribute :price, :money  # Uses custom MoneyType

  validates :name, :price, presence: true
end
```

## One-Of Types

Handle polymorphic JSON structures where the type varies:

```ruby
class ShippingMethod
  include StoreModel::Model

  attribute :carrier, :string
end

class PickupMethod
  include StoreModel::Model

  attribute :store_id, :integer
  attribute :pickup_time, :datetime
end

class Order < ApplicationRecord
  attribute :delivery_method, StoreModel.one_of {
    if _json["type"] == "shipping"
      ShippingMethod
    else
      PickupMethod
    end
  }
end
```

### Usage

```ruby
# Shipping order
order = Order.new(delivery_method: { type: "shipping", carrier: "UPS" })
order.delivery_method.class  # => ShippingMethod
order.delivery_method.carrier  # => "UPS"

# Pickup order
order = Order.new(delivery_method: { type: "pickup", store_id: 42 })
order.delivery_method.class  # => PickupMethod
order.delivery_method.store_id  # => 42
```

## Parent Tracking

Access the parent ActiveRecord model from within StoreModel:

```ruby
class Configuration
  include StoreModel::Model

  attribute :max_items, :integer

  def computed_limit
    # Access parent model
    parent.premium? ? max_items * 2 : max_items
  end
end

class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  def premium?
    tier == "premium"
  end
end
```

### Disable Parent Tracking

For performance in large arrays:

```ruby
class Product < ApplicationRecord
  attribute :items, Item.to_array_type, track_parent: false
end
```

## Unknown Attributes

### Raise on Unknown (Strict Mode)

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string

  # Raise error if JSON contains unknown keys
  class << self
    def unknown_attributes
      :raise
    end
  end
end

Configuration.new(model: "rocket", unknown_key: "value")
# => raises StoreModel::UnknownAttributeError
```

### Allow Unknown Attributes (Default)

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string

  # Unknown attributes are silently ignored (default behavior)
end

config = Configuration.new(model: "rocket", unknown_key: "value")
config.model  # => "rocket"
# unknown_key is discarded
```

## Error Handling

### Merge Errors to Parent

```ruby
class User < ApplicationRecord
  attribute :address, Address.to_type

  # Merge nested errors with prefix
  validates :address, store_model: { merge_errors: true }
end

user = User.new(address: { city: "" })
user.valid?
user.errors.full_messages
# => ["Address city can't be blank"]
```

### Array Error Merging

```ruby
class Order < ApplicationRecord
  attribute :line_items, LineItem.to_array_type

  # Merge errors from array elements
  validates :line_items, store_model: { merge_array_errors: true }
end

order = Order.new(line_items: [{ name: "" }])
order.valid?
order.errors.full_messages
# => ["Line items[0] name can't be blank"]
```

### Custom Error Handling

```ruby
class Order < ApplicationRecord
  attribute :line_items, LineItem.to_array_type

  validate :validate_line_items

  private

  def validate_line_items
    line_items.each_with_index do |item, index|
      next if item.valid?

      item.errors.each do |error|
        errors.add(:base, "Line item #{index + 1}: #{error.full_message}")
      end
    end
  end
end
```

## Database Considerations

### Migration

```ruby
class AddConfigurationToProducts < ActiveRecord::Migration[7.1]
  def change
    # Use jsonb for PostgreSQL (better indexing and querying)
    add_column :products, :configuration, :jsonb, default: {}, null: false

    # Use json for SQLite/MySQL
    # add_column :products, :configuration, :json, default: {}, null: false

    # Add GIN index for faster JSON queries (PostgreSQL only)
    add_index :products, :configuration, using: :gin
  end
end
```

### Querying JSON (PostgreSQL)

StoreModel doesn't help with database queries. Use PostgreSQL operators directly:

```ruby
# Query by nested value
Product.where("configuration->>'model' = ?", "rocket")

# Query array elements
Order.where("line_items @> ?", [{ name: "Widget" }].to_json)

# Query with index (requires GIN index)
Product.where("configuration @> ?", { status: "active" }.to_json)
```

### Default Values

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type, default: -> { Configuration.new }
end
```

## I18n

```yaml
# config/locales/en.yml
en:
  activemodel:
    attributes:
      configuration:
        model: "Model name"
        color: "Color"
        status: "Status"
    errors:
      models:
        configuration:
          attributes:
            model:
              blank: "must be specified"
```

## Serialization

### As JSON

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :secret_key, :string

  def as_json(options = {})
    super(options.merge(except: [:secret_key]))
  end
end
```

### Custom Serialization

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :created_at, :datetime

  def to_api
    {
      model: model,
      created_at: created_at&.iso8601
    }
  end
end
```
