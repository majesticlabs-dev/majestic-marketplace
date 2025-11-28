# ViewComponent Advanced Patterns

## Table of Contents
- [Slot Patterns](#slot-patterns)
- [Component Collections](#component-collections)
- [Polymorphic Components](#polymorphic-components)
- [Turbo Integration](#turbo-integration)
- [Form Components](#form-components)
- [Testing Patterns](#testing-patterns)
- [File Organization](#file-organization)
- [Preview Helpers](#preview-helpers)

## Slot Patterns

### Named Slots

```ruby
class ModalComponent < ApplicationViewComponent
  renders_one :header
  renders_one :body
  renders_one :footer

  option :title, default: -> { nil }
  option :size, default: -> { :medium }
end
```

```erb
<%# app/components/modal_component.html.erb %>
<div class="modal modal-<%= size %>">
  <% if header %>
    <div class="modal-header">
      <%= header %>
    </div>
  <% elsif title %>
    <div class="modal-header">
      <h2><%= title %></h2>
    </div>
  <% end %>

  <div class="modal-body">
    <% if body %>
      <%= body %>
    <% else %>
      <%= content %>
    <% end %>
  </div>

  <% if footer %>
    <div class="modal-footer">
      <%= footer %>
    </div>
  <% end %>
</div>
```

### Typed Slots

```ruby
class TabsComponent < ApplicationViewComponent
  renders_many :tabs, "TabComponent"

  class TabComponent < ApplicationViewComponent
    option :title
    option :active, default: -> { false }
  end
end
```

```erb
<%= render TabsComponent.new do |tabs| %>
  <% tabs.with_tab(title: "Overview", active: true) do %>
    Overview content here
  <% end %>

  <% tabs.with_tab(title: "Settings") do %>
    Settings content here
  <% end %>
<% end %>
```

### Lambda Slots

```ruby
class ListComponent < ApplicationViewComponent
  renders_many :items, ->(item:, **options) do
    ListItemComponent.new(item: item, **options)
  end
end
```

## Component Collections

### Rendering Collections

```ruby
class ArticleListComponent < ApplicationViewComponent
  with_collection_parameter :article

  option :article
  option :index, default: -> { nil }
end
```

```erb
<%# Usage %>
<%= render ArticleListComponent.with_collection(@articles) %>

<%# With additional options %>
<%= render ArticleListComponent.with_collection(@articles, size: :large) %>
```

### Collection Counters

```ruby
class ItemComponent < ApplicationViewComponent
  with_collection_parameter :item

  option :item
  option :item_counter, default: -> { nil }
  option :item_iteration, default: -> { nil }

  def first?
    item_iteration&.first?
  end

  def last?
    item_iteration&.last?
  end
end
```

## Polymorphic Components

### Variant-Based Rendering with Style Variants

```ruby
class NotificationComponent < ApplicationViewComponent
  include ViewComponentContrib::StyleVariants

  option :message
  option :type, default: -> { :info }
  option :dismissible, default: -> { true }

  style do
    base { %w[p-4 rounded-lg flex items-center gap-3] }

    variants {
      type {
        info { %w[bg-blue-50 text-blue-800] }
        success { %w[bg-green-50 text-green-800] }
        warning { %w[bg-yellow-50 text-yellow-800] }
        error { %w[bg-red-50 text-red-800] }
      }
    }

    defaults { { type: :info } }
  end

  ICONS = {
    info: "info-circle",
    success: "check-circle",
    warning: "exclamation",
    error: "x-circle"
  }.freeze

  def icon
    ICONS[type]
  end
end
```

```erb
<div class="<%= style(type:) %>">
  <%= helpers.inline_svg_tag "icons/#{icon}.svg", class: "w-5 h-5" %>
  <span><%= message %></span>
  <% if dismissible %>
    <button data-action="notification#dismiss">
      <%= helpers.inline_svg_tag "icons/x.svg", class: "w-4 h-4" %>
    </button>
  <% end %>
</div>
```

### Subclass Pattern

```ruby
# Base component
class BaseCardComponent < ApplicationViewComponent
  option :title
end

# Specialized variants
class ArticleCardComponent < BaseCardComponent
  option :article

  def initialize(article:, **options)
    super(title: article.title, **options)
    @article = article
  end
end

class UserCardComponent < BaseCardComponent
  option :user

  def initialize(user:, **options)
    super(title: user.name, **options)
    @user = user
  end
end
```

## Turbo Integration

### Component with Turbo Frame

```ruby
class EditableFieldComponent < ApplicationViewComponent
  option :record
  option :field

  def dom_id
    "#{record.model_name.singular}_#{record.id}_#{field}"
  end
end
```

```erb
<%= turbo_frame_tag dom_id do %>
  <% if editing? %>
    <%= helpers.form_with model: record, url: update_path do |f| %>
      <%= f.text_field field %>
      <%= f.submit "Save" %>
    <% end %>
  <% else %>
    <span><%= record.send(field) %></span>
    <%= helpers.link_to "Edit", edit_path %>
  <% end %>
<% end %>
```

### Component with Turbo Stream Target

```ruby
class CommentsComponent < ApplicationViewComponent
  option :commentable

  def target_id
    "#{helpers.dom_id(commentable)}_comments"
  end
end
```

```erb
<div id="<%= target_id %>">
  <%= render CommentComponent.with_collection(commentable.comments) %>
</div>
```

## Form Components

### Input Component

```ruby
class InputComponent < ApplicationViewComponent
  include ViewComponentContrib::StyleVariants

  option :form
  option :field
  option :type, default: -> { :text }
  option :label, default: -> { nil }
  option :hint, default: -> { nil }

  style do
    base { "form-input" }

    variants {
      error {
        yes { "border-red-500" }
        no { "" }
      }
    }
  end

  def computed_label
    label || field.to_s.humanize
  end

  def error_messages
    form.object.errors[field]
  end

  def has_error?
    error_messages.any?
  end
end
```

```erb
<div class="form-group <%= 'has-error' if has_error? %>">
  <%= form.label field, computed_label, class: "form-label" %>

  <%= form.send("#{type}_field", field,
        class: style(error: has_error? ? :yes : :no)) %>

  <% if hint %>
    <p class="form-hint"><%= hint %></p>
  <% end %>

  <% if has_error? %>
    <% error_messages.each do |error| %>
      <p class="form-error"><%= error %></p>
    <% end %>
  <% end %>
</div>
```

### Form Builder Integration

```ruby
# app/helpers/component_form_builder.rb
class ComponentFormBuilder < ActionView::Helpers::FormBuilder
  def input(field, **options)
    @template.render(InputComponent.new(form: self, field: field, **options))
  end

  def submit_button(text = "Submit", **options)
    @template.render(ButtonComponent.new(text: text, type: :submit, **options))
  end
end
```

```erb
<%= form_with model: @article, builder: ComponentFormBuilder do |f| %>
  <%= f.input :title %>
  <%= f.input :body, type: :text_area %>
  <%= f.submit_button "Create Article" %>
<% end %>
```

## Testing Patterns

### Component Unit Tests

```ruby
RSpec.describe CardComponent, type: :component do
  it "renders with title slot" do
    render_inline(CardComponent.new) do |card|
      card.with_header { "My Title" }
    end

    expect(page).to have_css(".card-header", text: "My Title")
  end

  it "renders multiple actions" do
    render_inline(CardComponent.new) do |card|
      card.with_action { "Edit" }
      card.with_action { "Delete" }
    end

    expect(page).to have_css(".card-actions a", count: 2)
  end
end
```

### Testing with Capybara Matchers

```ruby
RSpec.describe NotificationComponent, type: :component do
  it "renders success notification" do
    render_inline(NotificationComponent.new(
      message: "Saved!",
      type: :success
    ))

    expect(page).to have_css(".bg-green-50")
    expect(page).to have_text("Saved!")
  end

  it "renders dismissible button when dismissible" do
    render_inline(NotificationComponent.new(
      message: "Info",
      dismissible: true
    ))

    expect(page).to have_button
  end

  it "hides dismiss button when not dismissible" do
    render_inline(NotificationComponent.new(
      message: "Info",
      dismissible: false
    ))

    expect(page).not_to have_button
  end
end
```

### Integration with System Tests

```ruby
RSpec.describe "Articles", type: :system do
  it "displays article cards" do
    create_list(:article, 3)

    visit articles_path

    expect(page).to have_css("[data-component='article-card']", count: 3)
  end
end
```

## File Organization

### Standard Organization

```
app/components/
├── application_view_component.rb    # Base class
├── button_component.rb
├── button_component.html.erb
├── card_component.rb
├── card_component.html.erb
├── forms/
│   ├── input_component.rb
│   └── input_component.html.erb
└── layouts/
    ├── modal_component.rb
    └── modal_component.html.erb
```

### Sidecar Folder Organization (view_component-contrib)

```
app/components/
├── application_view_component.rb
├── button/
│   ├── component.rb
│   ├── component.html.erb
│   ├── preview.rb
│   └── component.css        # Optional scoped CSS
├── card/
│   ├── component.rb
│   ├── component.html.erb
│   └── preview.rb
└── forms/
    └── input/
        ├── component.rb
        ├── component.html.erb
        └── preview.rb
```

Configure sidecar paths:
```ruby
# config/application.rb
config.view_component.view_component_path = "app/components"
config.view_component.component_parent_class = "ApplicationViewComponent"
```

## Preview Helpers

### ViewComponentContrib::Preview Helpers

```ruby
class ButtonComponentPreview < ApplicationViewComponentPreview
  # Auto-infers component from class name
  def default
    render_component(text: "Click me")
  end

  # Wrap in custom container
  def with_dark_background
    render_with(wrapper: :dark_container) do
      render_component(text: "Light button", color: :secondary)
    end
  end

  # Multiple components in one preview
  def all_variants
    render_with(wrapper: :flex_row) do
      safe_join([
        render(ButtonComponent.new(text: "Primary", color: :primary)),
        render(ButtonComponent.new(text: "Secondary", color: :secondary)),
        render(ButtonComponent.new(text: "Danger", color: :danger))
      ])
    end
  end
end
```

### Preview Configuration

```ruby
# config/application.rb
config.view_component.preview_paths << Rails.root.join("spec/components/previews")
config.view_component.preview_controller = "PreviewController"
```

## Stimulus Integration

```erb
<%# Component with Stimulus controller %>
<div data-controller="dropdown" class="relative">
  <button data-action="dropdown#toggle">
    <%= label %>
  </button>

  <div data-dropdown-target="menu" class="hidden">
    <%= content %>
  </div>
</div>
```

## Base Component with Common Helpers

```ruby
# app/components/application_view_component.rb
class ApplicationViewComponent < ViewComponentContrib::Base
  extend Dry::Initializer
  include Turbo::FramesHelper
  include Turbo::StreamsHelper

  private

  # Access all Rails helpers
  def helpers
    ActionController::Base.helpers
  end
end
```
