# Database Patterns Reference

37signals database patterns from the Fizzy codebase. These emphasize simplicity, auditability, and avoiding external dependencies.

## Primary Key Strategy: UUIDv7

Use time-sortable UUIDs instead of auto-incrementing integers.

### Why UUIDs?

- **No enumeration attacks**: Can't guess `/users/1`, `/users/2`
- **Client-side generation**: Create IDs before hitting the database
- **Distributed systems**: No coordination needed across nodes
- **Merge-friendly**: Import/export without ID conflicts

### Implementation

```ruby
# config/initializers/generators.rb
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end

# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Base36-encoded UUIDv7 for shorter, URL-safe IDs
  before_create :set_uuid

  private
    def set_uuid
      self.id ||= generate_uuid7_base36
    end

    def generate_uuid7_base36
      # UUIDv7: timestamp-based, sortable
      uuid = SecureRandom.uuid_v7
      uuid.delete("-").to_i(16).to_s(36).rjust(25, "0")
    end
end
```

### Migration Pattern

```ruby
class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards, id: :string, limit: 25 do |t|
      t.string :title, null: false
      t.references :board, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

## Hard Deletes Over Soft Deletes

Delete records entirely rather than marking with `deleted_at`.

### Why No Soft Deletes?

- **No pervasive null checks**: Every query doesn't need `where(deleted_at: nil)`
- **Smaller tables**: No accumulating deleted records
- **Simpler queries**: No risk of accidentally including deleted data
- **Audit via event logs**: Separate system captures what was deleted

### Implementation

```ruby
# WRONG: Soft deletes
class Card < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }

  def destroy
    update!(deleted_at: Time.current)
  end
end

# CORRECT: Hard deletes with event logging
class Card < ApplicationRecord
  after_destroy :log_deletion

  private
    def log_deletion
      Event.create!(
        action: "card.destroyed",
        recordable_type: "Card",
        recordable_id: id,
        metadata: attributes.except("id"),
        actor: Current.user
      )
    end
end

# Event model for audit trail
class Event < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true

  # Query deleted items when needed
  scope :deletions, -> { where("action LIKE ?", "%.destroyed") }
end
```

## State as Records

Track state via separate records rather than boolean columns.

### Why State Records?

- **Full audit trail**: WHO changed it, WHEN, and optionally WHY
- **Natural timestamps**: `created_at` on state record
- **Efficient queries**: `joins(:closure)` vs `where(closed: true)`
- **Reversibility**: Delete the state record to undo

### Implementation

```ruby
# WRONG: Boolean column
class Card < ApplicationRecord
  # closed: boolean column
end
card.update!(closed: true)
# Lost: who closed it, when, why

# CORRECT: State as record
class Card < ApplicationRecord
  has_one :closure
  has_one :publication

  def close(by:, reason: nil)
    create_closure!(closed_by: by, reason: reason)
  end

  def reopen
    closure&.destroy!
  end

  def closed?
    closure.present?
  end

  def publish(by:)
    create_publication!(
      published_by: by,
      public_token: SecureRandom.urlsafe_base64(16)
    )
  end
end

class Closure < ApplicationRecord
  belongs_to :card, touch: true
  belongs_to :closed_by, class_name: "User"
end
```

## Counter Caches

Denormalize counts for performance.

### When to Use

- Frequently displayed counts (e.g., "42 comments")
- Sorting by count
- Avoiding N+1 in lists

### Implementation

```ruby
class Board < ApplicationRecord
  has_many :cards
  # cards_count column on boards table
end

class Card < ApplicationRecord
  belongs_to :board, counter_cache: true
end

# Migration
add_column :boards, :cards_count, :integer, default: 0, null: false

# Reset counters after data migration
Board.find_each { |b| Board.reset_counters(b.id, :cards) }
```

### Manual Counter for Complex Cases

```ruby
class Card < ApplicationRecord
  has_many :comments

  def comments_count
    # Use counter cache for performance, computed value as fallback
    read_attribute(:comments_count) || comments.count
  end

  after_commit :update_board_counts, on: [:create, :destroy]

  private
    def update_board_counts
      board.update_columns(
        open_cards_count: board.cards.where(closed: false).count,
        closed_cards_count: board.cards.where(closed: true).count
      )
    end
end
```

## Strategic Indexing

Index columns that are frequently queried.

### Index Guidelines

| Column Type | Index? | Why |
|-------------|--------|-----|
| Foreign keys | Always | Join performance |
| Status/state columns | Yes | Filtering |
| Timestamp columns used in ORDER BY | Yes | Sorting |
| Unique constraints | Yes | Enforced at DB level |
| Text searched with LIKE | Consider | Full-text might be better |

### Composite Indexes

Order matters: put equality conditions first, then range conditions.

```ruby
# Common query: cards for a board, ordered by position
add_index :cards, [:board_id, :position]

# Query: active cards in a column, by due date
add_index :cards, [:column_id, :status, :due_at]

# Wrong order: range condition before equality
# add_index :cards, [:due_at, :status]  # Less efficient
```

## Multi-Tenancy Pattern

Use `account_id` foreign key for tenant isolation.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class AccountRecord < ApplicationRecord
  self.abstract_class = true

  belongs_to :account
  default_scope { where(account: Current.account) if Current.account }

  before_validation :set_account, on: :create

  private
    def set_account
      self.account ||= Current.account
    end
end

class Card < AccountRecord
  # Automatically scoped to Current.account
end
```

## Infrastructure Without Redis

Use database-backed alternatives for simpler operations.

### Background Jobs: Solid Queue

```ruby
# config/application.rb
config.active_job.queue_adapter = :solid_queue

# No Redis dependency, uses your existing database
# Includes web UI at /jobs for monitoring
```

### Caching: Solid Cache

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store

# Cache lives in database, survives deploys
# Auto-expiration, no memory limits to manage
```

### WebSockets: Solid Cable

```ruby
# config/cable.yml
production:
  adapter: solid_cable

# Action Cable backed by database
# No Redis pub/sub to maintain
```

### Benefits

- **Single backup strategy**: Database backup covers everything
- **Single point of monitoring**: Just the database
- **Simplified deployment**: No Redis to provision/scale
- **Lower operational cost**: One less service to run

## Search Architecture (Advanced)

For high-volume search, shard across multiple databases.

```ruby
# CRC32-based account-to-shard mapping
class SearchShard
  SHARD_COUNT = 16

  def self.for_account(account)
    shard_id = Zlib.crc32(account.id.to_s) % SHARD_COUNT
    establish_connection(shard_config(shard_id))
  end

  def self.shard_config(shard_id)
    {
      adapter: "mysql2",
      host: "search-#{shard_id}.internal",
      database: "search_#{shard_id}"
    }
  end
end
```

## Lambda Defaults for Context

Use callable defaults to inherit context:

```ruby
class Card < ApplicationRecord
  belongs_to :account, default: -> { board.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :column, default: -> { board.default_column }
end

# Automatically sets account, creator, column on create
Card.create!(title: "New card", board: @board)
```
