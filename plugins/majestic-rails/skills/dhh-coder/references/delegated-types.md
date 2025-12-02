# Delegated Types Pattern

How 37signals uses delegated types for polymorphism without Single Table Inheritance problems.

## Why Delegated Types Over STI

| Problem with STI | Delegated Types Solution |
|-----------------|-------------------------|
| Sparse columns (many NULLs) | Each type has its own table |
| Growing monster table | Normalized storage |
| Type-specific validations awkward | Natural per-type models |
| Hard to add type-specific columns | Just add to the specific table |

## Basic Setup

### The Parent Model

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
  include Contactables

  belongs_to :account
  has_many :accesses, dependent: :destroy

  scope :accessible_to, ->(user) {
    joins(:accesses).where(accesses: { user: user })
  }
end

# app/models/contact/contactables.rb
module Contact::Contactables
  extend ActiveSupport::Concern

  included do
    delegated_type :contactable,
                   types: Contactable::TYPES,
                   inverse_of: :contact,
                   dependent: :destroy
  end
end
```

### The Shared Module

```ruby
# app/models/contactable.rb
module Contactable
  extend ActiveSupport::Concern

  TYPES = %w[ User Extension Alias Person Service Tombstone ]

  included do
    has_one :contact, as: :contactable, inverse_of: :contactable, touch: true
    belongs_to :account, default: -> { contact&.account }
  end

  # Shared behavior across all contactable types
  def display_name
    raise NotImplementedError
  end
end
```

### Type-Specific Models

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include Contactable

  has_secure_password
  has_many :sessions, dependent: :destroy

  def display_name
    name.presence || email
  end
end

# app/models/person.rb
class Person < ApplicationRecord
  include Contactable

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def display_name
    name
  end
end

# app/models/service.rb
class Service < ApplicationRecord
  include Contactable

  validates :name, :api_key, presence: true
  encrypts :api_key

  def display_name
    "#{name} (Service)"
  end
end
```

## Database Schema

```ruby
# db/migrate/xxx_create_contacts.rb
class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :contactable_type, null: false
      t.bigint :contactable_id, null: false
      t.timestamps

      t.index [:contactable_type, :contactable_id], unique: true
    end

    create_table :users do |t|
      t.string :name
      t.string :email, null: false
      t.string :password_digest
      t.timestamps
    end

    create_table :people do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.timestamps
    end

    create_table :services do |t|
      t.string :name, null: false
      t.string :api_key
      t.timestamps
    end
  end
end
```

## Usage Patterns

### Creating Records

```ruby
# Create a user with contact
user = User.create!(name: "David", email: "david@hey.com", password: "secret")
contact = Contact.create!(account: account, contactable: user)

# Or use nested attributes
contact = Contact.create!(
  account: account,
  contactable: User.new(name: "David", email: "david@hey.com")
)
```

### Querying

```ruby
# All contacts (regardless of type)
account.contacts.accessible_to(current_user)

# Specific type via delegation
Contact.where(contactable_type: "User")

# Rails provides type-specific scopes automatically
Contact.users  # Returns contacts where contactable_type = "User"
Contact.people # Returns contacts where contactable_type = "Person"
```

### Type Checking

```ruby
contact.user?     # true if contactable_type == "User"
contact.person?   # true if contactable_type == "Person"
contact.service?  # true if contactable_type == "Service"

# Access the underlying record
contact.contactable        # Returns the User/Person/Service
contact.user               # Returns User or nil
contact.person             # Returns Person or nil
```

### Polymorphic Behavior

```ruby
# Works regardless of underlying type
contact.contactable.display_name

# Type-specific behavior when needed
case contact.contactable
when User
  contact.contactable.sessions.destroy_all
when Service
  contact.contactable.revoke_api_key!
end
```

## Another Example: Entries

From HEY's email system:

```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  delegated_type :entryable, types: Entryable::TYPES

  belongs_to :topic
  has_many :attachments, dependent: :destroy
end

# app/models/entryable.rb
module Entryable
  extend ActiveSupport::Concern

  TYPES = %w[ Message Comment Draft Forward ]

  included do
    has_one :entry, as: :entryable, touch: true
  end
end

# app/models/message.rb
class Message < ApplicationRecord
  include Entryable

  has_rich_text :body
  has_many :recipients
end

# app/models/comment.rb
class Comment < ApplicationRecord
  include Entryable

  belongs_to :parent_entry, class_name: "Entry"
  has_rich_text :body
end
```

## When to Use Delegated Types

**Use delegated types when:**
- Types share some attributes but have type-specific data
- You want clean separation of concerns
- Types have different validation rules
- You're modeling real-world entities that share an interface

**Stick with STI when:**
- Types are very similar (only 1-2 different columns)
- You need to query across types frequently with type-specific data
- Simplicity trumps normalization

## Key Benefits

1. **No sparse columns** - Each type stores only what it needs
2. **Type-specific models** - Natural place for type-specific logic
3. **Unified interface** - Query all types through parent model
4. **Clean associations** - Parent handles shared relationships
5. **Rails conventions** - Automatic scopes and predicates
