# Rails/Hotwire Frontend Patterns

## ViewComponent

**Encapsulated UI components with sidecar styles:**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(variant: :default, elevated: false)
    @variant = variant
    @elevated = elevated
  end

  def classes
    class_names("card", "card--#{@variant}", "card--elevated" => @elevated)
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<article class="<%= classes %>">
  <% if header? %>
    <header class="card__header"><%= header %></header>
  <% end %>
  <div class="card__body"><%= content %></div>
</article>
```

```css
/* app/components/card_component.css */
.card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
}

.card--elevated { box-shadow: var(--shadow-lg); }

.card--brutal {
  border: 2px solid var(--color-fg);
  border-radius: 0;
  box-shadow: 4px 4px 0 var(--color-fg);
}
```

## Stimulus Controllers

**Reveal animation controller:**

```javascript
// app/javascript/controllers/reveal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { delay: { type: Number, default: 100 } }

  connect() {
    this.itemTargets.forEach((item, index) => {
      item.style.animationDelay = `${index * this.delayValue}ms`
      item.classList.add("reveal")
    })
  }
}
```

```erb
<ul data-controller="reveal" data-reveal-delay-value="150">
  <% items.each do |item| %>
    <li data-reveal-target="item"><%= item.name %></li>
  <% end %>
</ul>
```

**Toggle controller:**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static classes = ["active"]

  toggle() {
    this.contentTarget.classList.toggle(this.activeClass)
  }
}
```

## Turbo Frames & Streams

**Frames for dynamic updates:**

```erb
<turbo-frame id="search-results" data-turbo-action="replace">
  <%= render partial: "results", collection: @results %>
</turbo-frame>

<%= form_with url: search_path, data: { turbo_frame: "search-results" } do |f| %>
  <%= f.search_field :q, data: { action: "input->search#submit" } %>
<% end %>
```

**Streams with animations:**

```ruby
Turbo::StreamsChannel.broadcast_prepend_to(
  "notifications",
  target: "notifications-list",
  partial: "notifications/notification",
  locals: { notification: notification, animate: true }
)
```

```erb
<li class="notification <%= 'notification--animate' if local_assigns[:animate] %>">
  <%= notification.message %>
</li>
```

## ERB Layout Patterns

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head><%= content_for?(:head) ? yield(:head) : "" %></head>
<body class="<%= content_for?(:body_class) ? yield(:body_class) : '' %>">
  <% if content_for?(:hero) %>
    <section class="hero"><%= yield(:hero) %></section>
  <% end %>
  <main><%= yield %></main>
</body>
</html>
```

```erb
<%# Page using content_for %>
<% content_for :body_class, "page--home" %>
<% content_for :hero do %>
  <h1 class="hero__title reveal">Welcome</h1>
<% end %>
```

## CSS Design Tokens

```css
/* app/assets/stylesheets/design-tokens.css */
:root {
  --color-bg: #0a0a0a;
  --color-fg: #fafafa;
  --color-accent: #ff3366;

  --font-display: 'Clash Display', sans-serif;
  --font-body: 'Satoshi', sans-serif;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-6: 1.5rem;

  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --duration-fast: 150ms;
  --duration-normal: 300ms;
}
```

**Import order:**

```css
@import "design-tokens.css";
@import "reset.css";
@import "typography.css";
@import "components.css";
@import "utilities.css";
```
