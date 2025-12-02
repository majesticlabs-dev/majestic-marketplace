# Turbo 8 Morphing Patterns

How 37signals uses Turbo 8's page refresh with morphing for simpler real-time updates.

## The Problem with Traditional Turbo Streams

Before Turbo 8, real-time updates required crafting specific DOM operations:

```ruby
# Old way: Manual stream actions for every change
class Card < ApplicationRecord
  after_create_commit -> {
    broadcast_append_to board, :cards,
      target: "column_#{column_id}_cards",
      partial: "cards/card"
  }

  after_update_commit -> {
    broadcast_replace_to board, :cards,
      target: dom_id(self),
      partial: "cards/card"
  }

  after_destroy_commit -> {
    broadcast_remove_to board, :cards,
      target: dom_id(self)
  }
end
```

**Problems:**
- Must craft different actions for create/update/destroy
- Target IDs must match exactly
- Partial rendering context can differ from page context
- Complex nested updates are error-prone

## Turbo 8 Page Refresh with Morphing

Turbo 8 introduces a simpler approach: broadcast a `refresh` signal and let morphing handle the DOM diff.

### Basic Setup

```erb
<%# app/views/layouts/application.html.erb %>
<head>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
</head>
```

### Model Broadcasting

```ruby
class Board < ApplicationRecord
  has_many :columns, dependent: :destroy
  has_many :cards, through: :columns

  # Single broadcast handles all update types
  after_update_commit -> { broadcast_refresh }
end

class Column < ApplicationRecord
  belongs_to :board, touch: true
  has_many :cards, dependent: :destroy
end

class Card < ApplicationRecord
  belongs_to :column, touch: true

  # Touch propagates up: Card -> Column -> Board -> broadcast_refresh
end
```

### How It Works

1. Card updates, touches Column
2. Column touches Board
3. Board broadcasts refresh to subscribers
4. Turbo fetches fresh page HTML
5. Morphing algorithm diffs and patches only changed elements
6. Scroll position, form state, focus preserved

## Subscription Setup

```erb
<%# app/views/boards/show.html.erb %>
<%= turbo_stream_from @board %>

<div id="<%= dom_id(@board) %>">
  <h1><%= @board.name %></h1>

  <div class="columns" id="columns">
    <%= render @board.columns %>
  </div>
</div>
```

```erb
<%# app/views/columns/_column.html.erb %>
<div id="<%= dom_id(column) %>" class="column">
  <h2><%= column.name %></h2>

  <div class="cards" id="<%= dom_id(column, :cards) %>">
    <%= render column.cards %>
  </div>
</div>
```

## When to Use Morphing vs Traditional Streams

### Use Morphing (broadcast_refresh)

```ruby
# Complex nested structures
class Project < ApplicationRecord
  after_update_commit -> { broadcast_refresh }
end

# When multiple elements change together
class Todolist < ApplicationRecord
  after_update_commit -> { broadcast_refresh }
  # Refreshes todolist AND all its todos in one operation
end

# Dashboard-style pages with many components
class Dashboard < ApplicationRecord
  after_update_commit -> { broadcast_refresh }
end
```

### Use Traditional Streams

```ruby
# Simple append to a list (more efficient for single additions)
class Message < ApplicationRecord
  after_create_commit -> {
    broadcast_append_to room, :messages,
      target: "messages",
      partial: "messages/message"
  }
end

# Precise single-element updates
class Notification < ApplicationRecord
  after_update_commit -> {
    broadcast_replace_to user, :notifications,
      target: dom_id(self)
  }
end
```

## Morphing with Stimulus

Morphing preserves Stimulus controller state by default:

```javascript
// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dirty: Boolean }

  // State preserved across morphs
  markDirty() {
    this.dirtyValue = true
  }
}
```

### Handling Morph Events

```javascript
// Reset specific state after morph
document.addEventListener("turbo:morph", (event) => {
  // Re-initialize components that need it
  initializeTooltips()
})

// Element-level morph events
document.addEventListener("turbo:before-morph-element", (event) => {
  if (event.target.hasAttribute("data-preserve")) {
    event.preventDefault() // Don't morph this element
  }
})
```

## Broadcast Patterns

### Scoped Broadcasting

```ruby
class Card < ApplicationRecord
  belongs_to :board

  # Broadcast to board's stream
  after_update_commit -> { board.broadcast_refresh }

  # Or with explicit stream name
  after_update_commit -> {
    broadcast_refresh_to [board, :cards]
  }
end
```

### Conditional Broadcasting

```ruby
class Card < ApplicationRecord
  after_update_commit :broadcast_changes

  private
    def broadcast_changes
      return unless saved_change_to_position? || saved_change_to_column_id?
      board.broadcast_refresh
    end
end
```

### Debounced Broadcasting

```ruby
class Board < ApplicationRecord
  # Avoid rapid-fire refreshes
  after_update_commit :broadcast_refresh_later

  private
    def broadcast_refresh_later
      BroadcastRefreshJob.set(wait: 100.milliseconds).perform_later(self)
    end
end

class BroadcastRefreshJob < ApplicationJob
  def perform(board)
    board.broadcast_refresh
  end
end
```

## View Considerations

### Stable DOM IDs

```erb
<%# GOOD: Stable IDs for morphing %>
<div id="<%= dom_id(card) %>">
  <%= card.title %>
</div>

<%# BAD: Random IDs break morphing %>
<div id="card-<%= SecureRandom.hex %>">
  <%= card.title %>
</div>
```

### Preserving Elements

```erb
<%# Prevent morphing specific elements %>
<div data-turbo-permanent id="flash-messages">
  <%= render "shared/flash" %>
</div>

<%# Video/audio won't restart %>
<video data-turbo-permanent id="player">
  <source src="<%= @video.url %>">
</video>
```

## Performance Tips

1. **Use touch: true** - Propagate changes up the hierarchy
2. **Morph at the right level** - Don't refresh entire page for small changes
3. **Stable IDs** - Let morphing match elements efficiently
4. **Debounce rapid updates** - Batch changes with short delays
5. **data-turbo-permanent** - Exclude heavy elements from morphing

## Key Benefits

- **Simpler code** - One broadcast type handles create/update/destroy
- **Fewer bugs** - No target ID mismatches
- **Full page context** - Rendering uses same context as initial load
- **Preserved state** - Scroll, focus, forms maintained automatically
