---
name: rails-activity-timeline
description: Use when adding polymorphic activity timelines with live Turbo Stream updates to any Rails model. Covers migration, model, concern, shared partials, broadcasting, and optional AI-generated change summaries. Triggers on activity feed, audit trail, timeline, field change tracking, or Turbo Stream broadcasting patterns.
---

# Rails Activity Timeline

Add a polymorphic activity timeline with live Turbo Stream updates to any Rails model. Track field changes, status transitions, comments, attachments, and more with configurable icons and colors per action type.

## When to Use

- Adding an activity/audit timeline to any Rails model
- Tracking field changes, status transitions, comments, or attachments
- Displaying live-updating activity feeds via Turbo Streams
- Auto-logging lifecycle events on child/associated models
- Building activity feeds with configurable icons and colors

## Architecture

Four components:

1. **`ActivityEvent` model** (polymorphic) — the core event record
2. **`ActivityTrackable` concern** — auto-logs child model lifecycle events on a parent's timeline
3. **Shared timeline partial** — vertical timeline with Turbo Stream live updates
4. **Display configuration** — icon SVG path + accent color per action type, kept in the model

### Key Associations (on ActivityEvent)

```ruby
belongs_to :trackable, polymorphic: true            # parent entity whose timeline this belongs to
belongs_to :subject, polymorphic: true, optional: true  # related entity being acted upon
belongs_to :user, optional: true                     # who performed the action
```

### Generic Action Set

```ruby
ACTIONS = %w[
  created updated destroyed
  field_updated status_changed
  comment_added
  attachment_added attachment_removed
  assigned unassigned
  relationship_added relationship_removed
  tag_added tag_removed
].freeze
```

Add domain-specific actions (e.g., `published`, `approved`) to `ACTIONS` and the `DISPLAY` hash.

## Core Patterns

### Setup from Scratch

Migration, full `ActivityEvent` model, `ActivityTrackable` concern, and prerequisites.

See: `references/setup.md`

### Turbo Stream Broadcasting

Stream naming convention, broadcast methods, partial routing, shared timeline partial, and event partial.

See: `references/broadcasting.md`

### Display Configuration

The `DISPLAY` hash, adding custom actions with icons, display methods, customizing the event partial.

See: `references/display.md`

### AI Summaries (Optional)

AI-generated change summaries for `field_updated` events with long text changes.

See: `references/ai-summaries.md`

## Adding Timeline to a Model

### Step 1: Add the association

```ruby
class Project < ApplicationRecord
  has_many :activity_events, as: :trackable, dependent: :destroy
end
```

### Step 2: Add model type to broadcast routing

In `ActivityEvent#broadcast_partial`, add your model to the case statement:

```ruby
def broadcast_partial
  case trackable_type
  when "Project", "Article" then "activity_events/activity_event"
  else "activity_events/activity_event"
  end
end
```

### Step 3: Render the shared partial

```erb
<%= render "shared/activity_timeline", record: @project %>
```

### Step 4: Create events

```ruby
# Status change
ActivityEvent.create!(
  trackable: @project,
  user: current_user,
  action: "status_changed",
  details: { from_status: "draft", to_status: "active" }
)

# Field change
if @project.saved_change_to_status?
  ActivityEvent.create!(
    trackable: @project,
    user: current_user,
    action: "field_updated",
    details: { field: "status", from: @project.status_previously_was, to: @project.status }
  )
end
```

## ActivityTrackable Concern

For child models that auto-log on a parent's timeline:

```ruby
class Comment < ApplicationRecord
  include ActivityTrackable

  def activity_trackable = post
  def activity_action_created = "comment_added"
  def activity_action_destroyed = "comment_removed"
  def activity_label = body.truncate(60)
  def activity_user = user
end
```

Override `activity_created_details` or `activity_destroyed_details` for additional metadata:

```ruby
def activity_created_details
  { file_size: byte_size, content_type: content_type }
end
```

## Querying

```ruby
@project.activity_events.timeline          # recent, includes user, limit 50
@project.activity_events.by_type("status_changed")
ActivityEvent.where(subject: @task).recent
```

## Common Pitfalls

1. **Wrong trackable** — events appear on wrong timeline. `activity_trackable` must return the parent, not `self`.

2. **Missing broadcast routing for new types** — add new model types to the `broadcast_partial` case statement; without this broadcasts silently fail.

3. **Missing actions in ACTIONS + DISPLAY** — validation rejects unrecognized actions. Always add both.

4. **N+1 on timeline** — always use `.timeline` scope (includes `:user`). Add associations to the scope, not the partial.

5. **Turbo Stream not updating** — `turbo_stream_from` tag in view must match stream name in broadcast method. Convention: `"#{record_type}_{id}_activity"`.

## Prerequisites

- Rails 7+ with `turbo-rails`
- Action Cable or Solid Cable configured
- A `User` model (optional, for attribution)
- Tailwind CSS for default styling
