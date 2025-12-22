# Lazy Loading Patterns

## Turbo Frame Lazy Loading

### Basic Lazy Frame

```erb
<%= turbo_frame_tag :dashboard_stats, src: stats_path, loading: :lazy do %>
  <p>Loading stats...</p>
<% end %>
```

### Skeleton UI Placeholder

Match skeleton dimensions to actual content to prevent layout shift:

```erb
<%= turbo_frame_tag :table, src: table_path, loading: :lazy do %>
  <div class="animate-pulse">
    <%# Header row %>
    <div class="bg-neutral-100 rounded-xl h-16 mb-4"></div>

    <%# Filter bar %>
    <div class="flex items-center justify-between my-4">
      <div class="bg-neutral-100 rounded-xl w-48 h-8"></div>
      <div class="bg-neutral-100 rounded-xl w-48 h-8"></div>
    </div>

    <%# Table body %>
    <div class="bg-neutral-100 rounded-xl h-96"></div>
  </div>
<% end %>
```

### Card Grid Skeleton

```erb
<%= turbo_frame_tag :cards, src: cards_path, loading: :lazy do %>
  <div class="grid grid-cols-3 gap-4 animate-pulse">
    <% 6.times do %>
      <div class="bg-neutral-100 rounded-xl h-48"></div>
    <% end %>
  </div>
<% end %>
```

### List Skeleton

```erb
<%= turbo_frame_tag :notifications, src: notifications_path, loading: :lazy do %>
  <div class="space-y-3 animate-pulse">
    <% 5.times do %>
      <div class="flex items-center gap-3">
        <div class="bg-neutral-100 rounded-full w-10 h-10"></div>
        <div class="flex-1 space-y-2">
          <div class="bg-neutral-100 rounded h-4 w-3/4"></div>
          <div class="bg-neutral-100 rounded h-3 w-1/2"></div>
        </div>
      </div>
    <% end %>
  </div>
<% end %>
```

## Skeleton Component

Extract reusable skeleton component:

```ruby
# app/components/skeleton_component.rb
class SkeletonComponent < ViewComponent::Base
  renders_one :placeholder

  def initialize(frame_id:, src:, loading: :lazy)
    @frame_id = frame_id
    @src = src
    @loading = loading
  end
end
```

```erb
<%# app/components/skeleton_component.html.erb %>
<%= turbo_frame_tag @frame_id, src: @src, loading: @loading do %>
  <div class="animate-pulse">
    <%= placeholder %>
  </div>
<% end %>
```

```erb
<%# Usage %>
<%= render SkeletonComponent.new(frame_id: :stats, src: stats_path) do |c| %>
  <% c.with_placeholder do %>
    <div class="bg-neutral-100 rounded-xl h-32"></div>
  <% end %>
<% end %>
```

## Infinite Scroll

Nest lazy frames for paginated content:

```erb
<%= turbo_frame_tag "posts_page_#{@pagy.page}" do %>
  <%= render @posts %>

  <% if @pagy.next %>
    <%= turbo_frame_tag "posts_page_#{@pagy.next}",
                        src: posts_path(page: @pagy.next),
                        loading: :lazy do %>
      <div class="animate-pulse py-4">
        <div class="bg-neutral-100 rounded h-24"></div>
      </div>
    <% end %>
  <% end %>
<% end %>
```

## Loading States with Stimulus

### Spinner on Frame Load

```javascript
// app/javascript/controllers/frame_loader_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "content"]

  connect() {
    this.element.addEventListener("turbo:frame-load", () => this.loaded())
  }

  loaded() {
    this.spinnerTarget.classList.add("hidden")
    this.contentTarget.classList.remove("hidden")
  }
}
```

### Progress Bar

```javascript
// app/javascript/controllers/progress_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]

  connect() {
    document.addEventListener("turbo:before-fetch-request", () => this.start())
    document.addEventListener("turbo:frame-load", () => this.complete())
  }

  start() {
    this.barTarget.style.width = "0%"
    this.barTarget.classList.remove("hidden")
    this.animate()
  }

  animate() {
    this.barTarget.style.width = "80%"
  }

  complete() {
    this.barTarget.style.width = "100%"
    setTimeout(() => this.barTarget.classList.add("hidden"), 200)
  }
}
```

## Best Practices

| Pattern | Use Case |
|---------|----------|
| `loading: :lazy` | Below-fold content, secondary panels |
| `loading: :eager` | Critical above-fold content |
| Skeleton placeholders | Tables, cards, lists with known structure |
| Spinner | Unknown content structure |
| Progress bar | Multiple sequential loads |

### Skeleton Design Rules

- **Match dimensions**: Skeleton should approximate actual content size
- **Rounded shapes**: Use `rounded-xl` or `rounded-full` for organic feel
- **Subtle color**: `bg-neutral-100` (light) or `bg-neutral-800` (dark mode)
- **Animation**: `animate-pulse` is sufficient, avoid complex animations
- **Prevent CLS**: Set explicit height to prevent Cumulative Layout Shift
