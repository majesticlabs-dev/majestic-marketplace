# Event Model Patterns

## Table of Contents
- [Polymorphic Events](#polymorphic-events)
- [Shared Event Concern](#shared-event-concern)
- [Custom Event Types](#custom-event-types)
- [Event Metadata Patterns](#event-metadata-patterns)
- [Querying Events](#querying-events)

## Polymorphic Events

For applications with multiple eventable models:

### Migration

```ruby
class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true, null: false
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :event_type  # Optional: for STI
      t.jsonb :metadata, default: {}
      t.jsonb :snapshot, default: {}  # Optional: capture state at event time
      t.timestamps
    end

    add_index :events, :action
    add_index :events, :created_at
    add_index :events, [:eventable_type, :action]
  end
end
```

### Base Event Model

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :actor, class_name: "User"

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_type, ->(type) { where(eventable_type: type) }

  after_commit :broadcast_to_inboxes, on: :create

  private

  def broadcast_to_inboxes
    Event::BroadcastJob.perform_later(self)
  end
end
```

### Model-Specific Events with STI

```ruby
# app/models/events/issue_event.rb
module Events
  class IssueEvent < Event
    ACTIONS = %w[created assigned status_changed commented closed].freeze

    validates :action, inclusion: { in: ACTIONS }

    def issue
      eventable
    end
  end
end

# app/models/events/project_event.rb
module Events
  class ProjectEvent < Event
    ACTIONS = %w[created archived member_added member_removed].freeze

    validates :action, inclusion: { in: ACTIONS }

    def project
      eventable
    end
  end
end
```

## Shared Event Concern

Add event recording to any model:

```ruby
# app/models/concerns/eventable.rb
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  def record_event!(action:, actor:, metadata: {}, throttle: nil)
    return if throttle && recently_recorded?(action, throttle)

    event_class.create!(
      eventable: self,
      action: action,
      actor: actor,
      metadata: metadata.merge(default_metadata)
    )
  end

  def record_event_with_snapshot!(action:, actor:, metadata: {})
    event_class.create!(
      eventable: self,
      action: action,
      actor: actor,
      metadata: metadata,
      snapshot: snapshot_attributes
    )
  end

  private

  def event_class
    "Events::#{self.class.name}Event".constantize
  rescue NameError
    Event
  end

  def recently_recorded?(action, duration)
    events.where(action: action)
          .where("created_at > ?", duration.ago)
          .exists?
  end

  def default_metadata
    {}
  end

  def snapshot_attributes
    attributes.except("created_at", "updated_at")
  end
end
```

### Usage

```ruby
class Issue < ApplicationRecord
  include Eventable

  private

  def default_metadata
    { project_id: project_id }
  end
end

class Project < ApplicationRecord
  include Eventable
end

# Now both can record events
issue.record_event!(action: "created", actor: current_user)
project.record_event!(action: "archived", actor: current_user)
```

## Custom Event Types

### Typed Metadata with StoreModel

```ruby
# app/models/event_metadata/status_change.rb
module EventMetadata
  class StatusChange
    include StoreModel::Model

    attribute :from, :string
    attribute :to, :string
    attribute :reason, :string
    attribute :automated, :boolean, default: false

    validates :from, :to, presence: true
  end
end

# Usage
class Issue < ApplicationRecord
  def record_status_change!(from:, to:, actor:, reason: nil)
    record_event!(
      action: "status_changed",
      actor: actor,
      metadata: EventMetadata::StatusChange.new(
        from: from,
        to: to,
        reason: reason
      ).attributes
    )
  end
end
```

### Event with Attachments

```ruby
class Event < ApplicationRecord
  has_many_attached :attachments

  def attach_context(files)
    attachments.attach(files) if files.present?
  end
end

# Usage: Capture screenshots, logs, etc.
issue.record_event!(action: "bug_reported", actor: user).tap do |event|
  event.attach_context(params[:screenshots])
end
```

## Event Metadata Patterns

### Capture Previous Values

```ruby
# In model callback
before_update :capture_changes

def capture_changes
  return unless status_changed?

  @pending_event_metadata = {
    attribute: "status",
    from: status_was,
    to: status
  }
end

after_update :record_change_event

def record_change_event
  return unless @pending_event_metadata

  record_event!(
    action: "attribute_changed",
    actor: Current.user,
    metadata: @pending_event_metadata
  )

  @pending_event_metadata = nil
end
```

### Track Request Context

```ruby
# app/models/concerns/eventable.rb
def default_metadata
  {
    request_id: Current.request_id,
    ip_address: Current.ip_address,
    user_agent: Current.user_agent
  }.compact
end
```

### Batch Events

```ruby
class Event < ApplicationRecord
  belongs_to :batch, class_name: "EventBatch", optional: true
end

class EventBatch < ApplicationRecord
  has_many :events

  def self.wrap(description: nil)
    batch = create!(description: description)
    Current.event_batch = batch
    yield
  ensure
    Current.event_batch = nil
  end
end

# Usage
EventBatch.wrap(description: "Bulk status update") do
  issues.each { |issue| issue.close!(actor: current_user) }
end
```

## Querying Events

### Activity Feed Queries

```ruby
class ActivityFeed
  def initialize(user:, scope: :all)
    @user = user
    @scope = scope
  end

  def events
    case @scope
    when :my_activity
      Event.where(actor: @user)
    when :my_items
      Event.where(eventable: @user.issues)
    when :team
      Event.where(eventable: @user.team.issues)
    else
      Event.all
    end.recent.includes(:actor, :eventable).limit(50)
  end
end
```

### Event Statistics

```ruby
class EventStats
  def self.for_issue(issue)
    events = issue.events.group(:action).count

    {
      total_events: events.values.sum,
      comments: events["commented"] || 0,
      status_changes: events["status_changed"] || 0,
      assignments: events["assigned"] || 0
    }
  end

  def self.user_activity(user, since: 30.days.ago)
    Event.where(actor: user)
         .where("created_at > ?", since)
         .group(:action)
         .group_by_day(:created_at)
         .count
  end
end
```

### Time-Based Queries

```ruby
# Events in date range
Event.where(created_at: 1.week.ago..Time.current)

# Events by hour (for charts)
Event.group_by_hour(:created_at).count

# First event of each type
Event.select("DISTINCT ON (action) *").order(:action, :created_at)
```

### Full-Text Search on Metadata

```ruby
# PostgreSQL JSONB queries
Event.where("metadata->>'reason' ILIKE ?", "%urgent%")

Event.where("metadata @> ?", { automated: true }.to_json)

# With scope
class Event < ApplicationRecord
  scope :with_metadata, ->(key, value) {
    where("metadata->>? = ?", key.to_s, value.to_s)
  }

  scope :automated, -> { with_metadata(:automated, true) }
end
```
