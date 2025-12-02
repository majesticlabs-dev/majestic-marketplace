# The Recording Pattern

A unifying abstraction used throughout 37signals applications to handle diverse content types with shared behavior.

## The Core Idea

In Basecamp, most user-created content (todos, messages, documents, comments) shares common needs:

- Event tracking / audit trails
- Access control and permissions
- Lifecycle management (archiving, copying, deleting)
- Creator attribution and timestamps
- Activity feeds and notifications

Rather than duplicating this across every content type, 37signals uses a **Recording** abstraction that provides these capabilities once.

## Basic Structure

### The Recording Model

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  include Completable
  include Copyable
  include Incineratable
  include Mentionable
  include Tracked

  belongs_to :bucket        # Container (project, team, etc.)
  belongs_to :creator, class_name: "Person"
  belongs_to :parent, class_name: "Recording", optional: true

  has_many :children, class_name: "Recording", foreign_key: :parent_id
  has_many :events, dependent: :destroy
  has_many :accesses, dependent: :destroy

  delegated_type :recordable, types: Recordable::TYPES

  scope :active, -> { where(discarded_at: nil) }
  scope :discarded, -> { where.not(discarded_at: nil) }
  scope :accessible_to, ->(person) {
    joins(:accesses).where(accesses: { person: person })
  }
end
```

### The Recordable Module

```ruby
# app/models/recordable.rb
module Recordable
  extend ActiveSupport::Concern

  TYPES = %w[
    Todo
    Todolist
    Message
    Document
    Comment
    Upload
    Schedule
    Question
    Answer
  ]

  included do
    has_one :recording, as: :recordable, touch: true
    delegate :bucket, :creator, :created_at, :events, to: :recording
  end

  # Override in specific types as needed
  def title
    raise NotImplementedError
  end

  def excerpt
    title.truncate(100)
  end
end
```

### Content Type Models

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  include Recordable

  has_rich_text :description
  belongs_to :todolist

  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def title
    description.to_plain_text.lines.first&.strip || "Untitled"
  end

  def complete!
    update!(completed_at: Time.current, completer: Current.person)
  end
end

# app/models/message.rb
class Message < ApplicationRecord
  include Recordable

  has_rich_text :content
  belongs_to :message_board

  def title
    subject.presence || content.to_plain_text.truncate(50)
  end
end

# app/models/document.rb
class Document < ApplicationRecord
  include Recordable

  has_rich_text :content

  def title
    name
  end
end
```

## Recording Concerns

### Event Tracking

```ruby
# app/models/recording/tracked.rb
module Recording::Tracked
  extend ActiveSupport::Concern

  included do
    has_many :events, dependent: :destroy
    after_create :track_creation
  end

  def track(action, details: {})
    events.create!(
      action: action,
      actor: Current.person,
      details: details,
      created_at: Time.current
    )
  end

  private
    def track_creation
      track("created")
    end
end
```

### Lifecycle Management

```ruby
# app/models/recording/incineratable.rb
module Recording::Incineratable
  extend ActiveSupport::Concern

  def incinerate
    transaction do
      track("incinerated")
      Incineration.create!(recording: self)
    end
  end

  def incinerate_later
    IncinerationJob.perform_later(self)
  end
end

# app/models/recording/copyable.rb
module Recording::Copyable
  extend ActiveSupport::Concern

  included do
    has_many :copies, foreign_key: :source_recording_id
  end

  def copy_to(destination_bucket, parent: nil)
    copies.create!(
      destination_bucket: destination_bucket,
      destination_parent: parent,
      copier: Current.person
    )
  end
end
```

### Access Control

```ruby
# app/models/recording/accessible.rb
module Recording::Accessible
  extend ActiveSupport::Concern

  included do
    has_many :accesses, dependent: :destroy
    scope :accessible_to, ->(person) {
      joins(:accesses).where(accesses: { person: person })
    }
  end

  def grant_access_to(person, level: :viewer)
    accesses.find_or_create_by!(person: person) do |access|
      access.level = level
    end
  end

  def revoke_access_from(person)
    accesses.find_by(person: person)&.destroy
  end

  def accessible_by?(person)
    accesses.exists?(person: person)
  end
end
```

## Controller Usage

```ruby
class RecordingsController < ApplicationController
  before_action :set_recording

  def show
    @recordable = @recording.recordable
    render template: "#{@recordable.class.name.underscore.pluralize}/show"
  end

  def copy
    @copy = @recording.copy_to(target_bucket)
    redirect_to recording_path(@copy.destination_recording)
  end

  def archive
    @recording.archive!
    redirect_back fallback_location: bucket_path(@recording.bucket)
  end

  def incinerate
    @recording.incinerate_later
    redirect_to bucket_path(@recording.bucket),
      notice: "Recording will be permanently deleted"
  end

  private
    def set_recording
      @recording = current_bucket.recordings
        .accessible_to(Current.person)
        .find(params[:id])
    end
end
```

## Activity Feed

The Recording pattern makes activity feeds trivial:

```ruby
class Bucket < ApplicationRecord
  has_many :recordings

  def recent_activity(limit: 20)
    recordings
      .includes(:creator, :recordable, events: :actor)
      .joins(:events)
      .order("events.created_at DESC")
      .limit(limit)
  end
end
```

```erb
<%# app/views/buckets/_activity.html.erb %>
<% bucket.recent_activity.each do |recording| %>
  <% recording.events.recent.each do |event| %>
    <div class="activity-item">
      <%= event.actor.name %> <%= event.action %>
      <%= link_to recording.recordable.title, recording %>
    </div>
  <% end %>
<% end %>
```

## Benefits

1. **Single source of truth** for cross-cutting concerns
2. **Consistent behavior** across all content types
3. **Unified queries** - find all recordings in a bucket regardless of type
4. **Activity feed** - events tracked uniformly
5. **Access control** - permissions applied consistently
6. **Lifecycle management** - archive, copy, delete work the same way

## When to Use This Pattern

**Use Recording pattern when:**
- Multiple content types share significant common behavior
- You need unified activity feeds/audit trails
- Access control spans content types
- Lifecycle operations (archive, copy, delete) are consistent

**Skip it when:**
- Content types are truly independent
- You only have 2-3 simple models
- Shared behavior is minimal
