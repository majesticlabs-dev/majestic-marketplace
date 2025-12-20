# The Recording Pattern

A unifying abstraction used throughout 37signals applications (Basecamp, HEY) to handle diverse content types with shared behavior. This pattern combines **Delegated Types**, **Immutability**, and a **Tree Structure**.

## The Core Idea

In Basecamp, most user-created content (todos, messages, documents, comments) shares common needs:

- Event tracking / audit trails
- Access control and permissions
- Lifecycle management (archiving, copying, deleting)
- Creator attribution and timestamps
- Activity feeds and notifications
- Version history

Rather than duplicating this across every content type, 37signals uses a **Recording** abstraction that provides these capabilities once.

## Key Distinction: Recordings vs Recordables

| Aspect | Recording (Delegator) | Recordable (Delegatee) |
|--------|----------------------|------------------------|
| **Role** | Lightweight pointer with metadata | Actual content storage |
| **Contains** | Creator, timestamps, bucket, parent, color | Title, body, type-specific data |
| **Mutability** | **Mutable** - can change parent, bucket, pointer | **Immutable** - never updated in place |
| **Knowledge** | Knows context, access, hierarchy | "Dumb" - no knowledge of outside world |
| **On edit** | Updates `recordable_id` to new version | New row created, old preserved |

This separation enables **zero-cost copying** and **version history**.

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

Recordables are **"dumb" objects** - they hold content but have no connection to the outside world. They don't know about access control, parents, or who created them.

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

  # Capability defaults - override in specific types
  def subscribable? = false
  def exportable? = false
  def commentable? = false
  def completable? = false
  def copyable? = true
end
```

### Capability Pattern

Controllers ask the recordable what it can do:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  include Recordable

  def commentable? = true
  def subscribable? = true
  def exportable? = true
end

# app/models/comment.rb
class Comment < ApplicationRecord
  include Recordable

  # Comments can't have comments (no nesting)
  def commentable? = false
end
```

The controller checks capabilities before allowing actions:

```ruby
class CommentsController < ApplicationController
  before_action :ensure_commentable

  private
    def ensure_commentable
      head :forbidden unless @recording.recordable.commentable?
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

## Buckets: The Access Control Container

Buckets are containers for recordings (projects, teams, templates). They handle **access control** - if a user has access to a Bucket, they have access to the Recordings inside it.

```ruby
# app/models/bucket.rb
class Bucket < ApplicationRecord
  has_many :recordings, dependent: :destroy
  has_many :accesses, dependent: :destroy

  scope :accessible_to, ->(person) {
    joins(:accesses).where(accesses: { person: person })
  }

  def grant_access_to(person, level: :member)
    accesses.find_or_create_by!(person: person) do |access|
      access.level = level
    end
  end
end
```

Since recordables are "dumb," they rely entirely on the Bucket for security context:

```ruby
# Access check flows through bucket, not recordable
@recording = current_bucket.recordings.find(params[:id])
# If user can't access bucket, they can't access any recording in it
```

## Recording Concerns

### Event Tracking & Version History

Events link a Recording to a specific Recordable ID at a moment in time. Because recordables are **immutable**, old versions remain in the database.

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  belongs_to :recording
  belongs_to :actor, class_name: "Person"

  # Captures which recordable version existed at this moment
  # Enables "time travel" - view content exactly as it was
  attribute :recordable_id, :bigint
  attribute :recordable_type, :string
end

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
      recordable_id: recordable_id,      # Snapshot current version
      recordable_type: recordable_type,
      created_at: Time.current
    )
  end

  # View recording as it existed at a specific event
  def version_at(event)
    event.recordable_type.constantize.find(event.recordable_id)
  end

  private
    def track_creation
      track("created")
    end
end
```

This enables precise **time travel**:

```ruby
# Show document exactly as it looked 3 months ago
old_event = @recording.events.where("created_at < ?", 3.months.ago).last
old_content = @recording.version_at(old_event)
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

  # ZERO-COST COPYING
  # Does NOT duplicate content - creates new Recording pointing to SAME Recordable
  # Instant operation, saves massive storage
  def copy_to(destination_bucket, parent: nil)
    Recording.create!(
      bucket: destination_bucket,
      parent: parent,
      creator: Current.person,
      recordable: recordable,  # Points to EXISTING recordable row
      copied_from: self
    )
  end
end
```

**Why this matters**: Copying a project with 1000 documents is instant. No content duplication - just 1000 new Recording rows pointing to existing Recordable rows.

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

## Controller Usage: Rich Controller, Dumb Model

Logic is centralized in **generic controllers** (like `RecordingsController`) rather than type-specific controllers (like `MessagesController`). Operations like trashing, archiving, moving, and copying are implemented **once** for the Recording class.

```ruby
class RecordingsController < ApplicationController
  before_action :set_recording

  def show
    @recordable = @recording.recordable
    render template: "#{@recordable.class.name.underscore.pluralize}/show"
  end

  def copy
    return head :forbidden unless @recording.recordable.copyable?
    @copy = @recording.copy_to(target_bucket)
    redirect_to recording_path(@copy)
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

## Tree Structure & Hierarchical Queries

Recordings are organized hierarchically via `parent_id`:

```
Bucket (Project)
└── Message Board (Recording)
    └── Message (Recording)
        └── Comment (Recording)
        └── Comment (Recording)
    └── Message (Recording)
```

Query the tree through the recordings table:

```ruby
class Recording < ApplicationRecord
  belongs_to :parent, class_name: "Recording", optional: true
  has_many :children, class_name: "Recording", foreign_key: :parent_id

  # Type-specific scopes (auto-generated by delegated_type)
  # Recording.messages, Recording.comments, etc.
end

# Get all messages in a bucket
bucket.recordings.messages

# Get comments on a specific message
message_recording.children.comments

# Get the full tree
def descendants
  children + children.flat_map(&:descendants)
end
```

## Global Timeline & Activity Feed

Because `created_at` and `bucket_id` live on the Recording, you can efficiently paginate and sort **mixed content types** in a single query without joining dozens of tables.

```ruby
class Bucket < ApplicationRecord
  has_many :recordings

  # "Everything that happened today" - single table query
  def timeline(limit: 50)
    recordings
      .includes(:creator, :recordable)
      .order(created_at: :desc)
      .limit(limit)
  end

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
<%# app/views/buckets/_timeline.html.erb %>
<% bucket.timeline.each do |recording| %>
  <div class="timeline-item" data-type="<%= recording.recordable_type.downcase %>">
    <%= render recording.recordable %>
  </div>
<% end %>
```

## Russian Doll Caching

Caching is done at the **Recording** level - identical logic for every content type:

```erb
<%# Works for messages, documents, todos, comments - all the same %>
<% cache recording do %>
  <%= render recording.recordable %>
<% end %>
```

## Resilient API for Mobile

The API exposes Recordings, not type-specific endpoints. Mobile apps can ingest generic recordings and handle unknown types gracefully:

```ruby
class Api::RecordingsController < Api::BaseController
  def index
    @recordings = current_bucket.recordings
      .accessible_to(Current.person)
      .includes(:recordable)
      .order(created_at: :desc)

    render json: @recordings.map { |r| recording_json(r) }
  end

  private
    def recording_json(recording)
      {
        id: recording.id,
        type: recording.recordable_type,
        created_at: recording.created_at,
        creator: recording.creator.name,
        # Generic metadata always present
        title: recording.recordable.title,
        excerpt: recording.recordable.excerpt,
        # Type-specific data (mobile can ignore unknown fields)
        data: recording.recordable.as_json
      }
    end
end
```

When a new type is added (e.g., "Hill Chart"), old mobile apps don't crash - they display generic metadata or a fallback because the interface is uniform.

## Pros

- **Rapid feature development** - New content types (Kanban boards, Hill Charts) inherit all generic behaviors instantly: comments, trash, history, move/copy
- **Database performance** - The `recordings` table is lean (mostly IDs and dates), fast to index. Heavy content (text blobs) sits in separate tables accessed less frequently
- **Zero-cost operations** - Copying is instant (new pointer, same content). Moving is a single parent_id update
- **Unified queries** - Global timelines, activity feeds, and search work across all types with single-table queries
- **Scalability** - Pattern has supported Basecamp for 10+ years. Avoids STI's wide tables and polymorphic joins
- **Refactoring-friendly** - Sharding or migrating is easier because recordings is just a table of references
- **Generic services** - Exporters, copiers, trash, and permissions written once

## Cons

- **Learning curve** - Not the "standard" Rails way. New developers may be confused by "empty" models that lack logic
- **Abstraction cost** - Cannot easily implement context-aware logic inside recordables
  - A Comment cannot know its parent's title by itself (has no parent reference)
  - Must pass the Recording into the Recordable for context-aware operations
- **Indirection** - Rarely interact with concrete tables directly. Always go through Recording to access data
- **Convention over strictness** - No compiler enforcement preventing invalid hierarchies (e.g., Comment inside ToDo List) without explicit checks

## When to Use This Pattern

**Use Recording pattern when:**
- Multiple content types (5+) share significant behavior
- You need unified activity feeds/audit trails
- Access control spans content types
- Lifecycle operations (archive, copy, delete) are consistent
- Version history is important
- You expect to add new content types over time

**Skip it when:**
- Content types are truly independent
- You only have 2-3 simple models
- Shared behavior is minimal
- You don't need unified timelines or cross-type queries
