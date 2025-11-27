# Hotwire/Turbo Tips Reference

Practical patterns for Hotwire, Turbo Frames, Turbo Streams, and Stimulus.

## Turbo Frame Patterns

### Lazy-Loading Turbo Frames with Skeleton UI

Create loading placeholders for lazy-loaded frames:

```erb
<%# Lazy-loaded frame with skeleton placeholder %>
<%= turbo_frame_tag :table, src: "/table", lazy: true do %>
  <div class="animate-pulse">
    <div class="bg-neutral-50 rounded-xl h-16"></div>
    <div class="flex items-center justify-between my-4">
      <div class="bg-neutral-50 rounded-xl w-48 h-8"></div>
      <div class="bg-neutral-50 rounded-xl w-48 h-8"></div>
    </div>
    <div class="bg-neutral-50 rounded-xl h-96"></div>
  </div>
<% end %>
```

### Hard Refresh Frames

Force a full frame refresh when needed:

```erb
<%= turbo_frame_tag :participants_menu do %>
  <%= turbo_stream.update dom_id(@plan, :participant_count), @plan.users.size %>
  <%= turbo_stream.hard_refresh_frame @plan if params[:refresh] %>

  <%= render UI::Drawer.new do |d| %>
    <% d.header(title: "Participants") %>
    <% d.body do %>
      <!-- drawer content -->
    <% end %>
  <% end %>
<% end %>
```

## Turbo Stream Patterns

### Turbo Stream Action Tags in Views

Use `turbo_stream_action_tag` for explicit stream actions:

```erb
<%# Append new widgets and replace pager %>
<%= turbo_stream_action_tag(
  "append",
  target: "widgets",
  template: %(#{render @widgets})
) %>

<%= turbo_stream_action_tag(
  "replace",
  target: "pager",
  template: %(#{render "pager", pagy: @pagy})
) %>
```

## Stimulus Patterns

### Flash Messages with Auto-Dismiss

Create self-dismissing flash messages using Stimulus and CSS animations:

```erb
<%# app/views/shared/_flash.html.erb %>
<div class="flash"
     data-controller="element-removal"
     data-action="animationend->element-removal#remove">
  <div class="flash__inner">
    <%= notice %>
  </div>
</div>
```

```css
/* app/assets/stylesheets/flash.css */
.flash__inner {
  animation: appear-then-fade 5s 300ms both;
}

@keyframes appear-then-fade {
  0% { opacity: 0; transform: translateY(-10px); }
  10% { opacity: 1; transform: translateY(0); }
  90% { opacity: 1; transform: translateY(0); }
  100% { opacity: 0; transform: translateY(-10px); }
}
```

```javascript
// app/javascript/controllers/element_removal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove() {
    this.element.remove()
  }
}
```

## ViewComponent Patterns

### Card Component with Slots

Create flexible components using ViewComponent slots:

```ruby
# app/components/ui/card.rb
class UI::Card < ApplicationComponent
  renders_one :title
  renders_one :body

  attr_reader :title_text

  def initialize(title: nil)
    @title_text = title
  end
end
```

```erb
<%# app/components/ui/card.html.erb %>
<div class="rounded-2xl p-6 bg-white border shadow">
  <% if title? %>
    <%= title %>
  <% else %>
    <%= render UI::Heading.new(title: title_text, tag: :h2) %>
  <% end %>

  <%= body %>
</div>
```

```erb
<%# Usage with title string %>
<%= render UI::Card.new(title: "Hello!") do |c| %>
  <% c.body { "This is a card!" } %>
<% end %>

<%# Usage with custom title slot %>
<%= render UI::Card.new do |c| %>
  <% c.title do %>
    <h2>
      A <b>Fancy</b> title that breaks the norm
    </h2>
  <% end %>

  <% c.body { "This is a card!" } %>
<% end %>
```

## Infinite Scroll with Turbo Frames

Implement infinite scroll using nested lazy-loading frames:

```erb
<%# Wrap current page in a frame that loads the next page %>
<%= turbo_frame_tag "accounts_#{@accounts.current_page}" do %>
  <%= render @accounts %>

  <% unless @accounts.last_page? %>
    <%# Lazy-load next page when this frame comes into view %>
    <%= turbo_frame_tag "accounts_#{@accounts.next_page}",
                        src: path_to_next_page(@accounts),
                        loading: "lazy" do %>
      <span>Loading...</span>
    <% end %>
  <% end %>
<% end %>
```

## Like Button with Turbo Streams

Full implementation of a like/unlike toggle with real-time updates:

```ruby
# Controller
class LikesController < ApplicationController
  before_action :set_todo
  before_action :set_like, only: :destroy

  def create
    @like = @todo.likes.where(user: current_user).first_or_create
  end

  def destroy
    @like.destroy
    render :create
  end
end
```

```erb
<%# Views: likes/create.turbo_stream.erb %>
<%= turbo_stream.replace(dom_id(@todo, :like), partial: 'likes/like', locals: { todo: @todo, like: @like }) %>
<%= turbo_stream.update(dom_id(@todo, :likes_count), @todo.likes.count) %>

<%# In todos/_todo.html.erb %>
<p><%= todo.description %></p>

<%= render partial: 'likes/like', locals: { todo: todo, like: todo.likes.find_by(user: current_user) } %>
<%= tag.div(todo.likes.count, id: dom_id(todo, :likes_count)) %>

<%# In likes/_like.html.erb %>
<%= turbo_frame_tag dom_id(todo, :like) do %>
  <% if like&.persisted? %>
    <%= button_to 'Unlike', like_path(like, todo_id: todo.id), method: :delete %>
  <% else %>
    <%= button_to 'Like', likes_path(todo_id: todo.id), method: :post %>
  <% end %>
<% end %>
```

## Search with Turbo Frames

Implement real-time search that updates results via Turbo:

```ruby
# Controller
class PostsController < ApplicationController
  def index
    @pagy, @posts = pagy(Post.search(params[:q]).order(created_at: :desc))
  end
end
```

```slim
/ Views: posts/index.html.slim
= form_for posts_path, method: :get, html: { data: { turbo_frame: 'posts', turbo_action: 'advance' } } do
  = search_field_tag :q, params[:q], placeholder: 'Search...'

= turbo_frame_tag 'posts' do
  = render partial: 'posts/post', collection: @posts

  = pagy_nav(@pagy)

/ The turbo_action: 'advance' updates the URL with search params
/ Only the content in the turbo-frame will be extracted and replaced
/ Result: <turbo-frame id="posts" src="/posts?q=hotwire">...</turbo-frame>
```

## Tailwind CSS Integration

### Conditional Classes with Data Attributes

Use Tailwind variants with data attributes for conditional styling:

```html
<!-- Set data-admin on body or container element -->
<div class="flex flex-col gap-2 p-4" data-admin>
  <div class="bg-gray-100 p-2">
    <p>Another nice comment</p>

    <!-- Only show to admins using custom Tailwind variant -->
    <div class="hidden admin:block">
      <a href="#" class="text-blue-500">Delete</a>
    </div>
  </div>
</div>
```

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      // ...
    },
  },
  plugins: [
    function ({ addVariant }) {
      // Typically you'd set data-admin on the <body>
      addVariant('admin', 'div[data-admin] &')
    }
  ],
}
```
