# ViewComponent Advanced Patterns

## Table of Contents
- [Slot Patterns](#slot-patterns)
- [Component Collections](#component-collections)
- [Polymorphic Components](#polymorphic-components)
- [Turbo Integration](#turbo-integration)
- [Form Components](#form-components)
- [Testing Patterns](#testing-patterns)

## Slot Patterns

### Named Slots

```ruby
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :footer

  def initialize(title: nil, size: :medium)
    @title = title
    @size = size
  end
end
```

```erb
<%# app/components/modal_component.html.erb %>
<div class="modal modal-<%= @size %>">
  <% if header %>
    <div class="modal-header">
      <%= header %>
    </div>
  <% elsif @title %>
    <div class="modal-header">
      <h2><%= @title %></h2>
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
class TabsComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    def initialize(title:, active: false)
      @title = title
      @active = active
    end
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
class ListComponent < ViewComponent::Base
  renders_many :items, ->(item:, **options) do
    ListItemComponent.new(item: item, **options)
  end
end
```

## Component Collections

### Rendering Collections

```ruby
class ArticleListComponent < ViewComponent::Base
  with_collection_parameter :article

  def initialize(article:, index: nil)
    @article = article
    @index = index
  end
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
class ItemComponent < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, item_counter:, item_iteration:)
    @item = item
    @counter = item_counter      # 1-indexed position
    @iteration = item_iteration  # Iteration object
  end

  def first?
    @iteration.first?
  end

  def last?
    @iteration.last?
  end
end
```

## Polymorphic Components

### Variant-Based Rendering

```ruby
class NotificationComponent < ViewComponent::Base
  TYPES = {
    info: { icon: "info-circle", bg: "bg-blue-50", text: "text-blue-800" },
    success: { icon: "check-circle", bg: "bg-green-50", text: "text-green-800" },
    warning: { icon: "exclamation", bg: "bg-yellow-50", text: "text-yellow-800" },
    error: { icon: "x-circle", bg: "bg-red-50", text: "text-red-800" }
  }.freeze

  def initialize(message:, type: :info, dismissible: true)
    @message = message
    @type = type
    @dismissible = dismissible
    @config = TYPES[@type]
  end

  delegate :[], to: :@config
end
```

```erb
<div class="<%= self[:bg] %> <%= self[:text] %> p-4 rounded-lg">
  <%= helpers.inline_svg_tag "icons/#{self[:icon]}.svg", class: "w-5 h-5" %>
  <span><%= @message %></span>
  <% if @dismissible %>
    <button data-action="notification#dismiss">
      <%= helpers.inline_svg_tag "icons/x.svg", class: "w-4 h-4" %>
    </button>
  <% end %>
</div>
```

### Subclass Pattern

```ruby
# Base component
class BaseCardComponent < ViewComponent::Base
  def initialize(title:, **options)
    @title = title
    @options = options
  end
end

# Specialized variants
class ArticleCardComponent < BaseCardComponent
  def initialize(article:, **options)
    @article = article
    super(title: article.title, **options)
  end
end

class UserCardComponent < BaseCardComponent
  def initialize(user:, **options)
    @user = user
    super(title: user.name, **options)
  end
end
```

## Turbo Integration

### Component with Turbo Frame

```ruby
class EditableFieldComponent < ViewComponent::Base
  def initialize(record:, field:)
    @record = record
    @field = field
  end

  def dom_id
    "#{@record.model_name.singular}_#{@record.id}_#{@field}"
  end
end
```

```erb
<%= turbo_frame_tag dom_id do %>
  <% if editing? %>
    <%= helpers.form_with model: @record, url: update_path do |f| %>
      <%= f.text_field @field %>
      <%= f.submit "Save" %>
    <% end %>
  <% else %>
    <span><%= @record.send(@field) %></span>
    <%= helpers.link_to "Edit", edit_path %>
  <% end %>
<% end %>
```

### Component with Turbo Stream Target

```ruby
class CommentsComponent < ViewComponent::Base
  def initialize(commentable:)
    @commentable = commentable
  end

  def target_id
    "#{helpers.dom_id(@commentable)}_comments"
  end
end
```

```erb
<div id="<%= target_id %>">
  <%= render CommentComponent.with_collection(@commentable.comments) %>
</div>
```

## Form Components

### Input Component

```ruby
class InputComponent < ViewComponent::Base
  def initialize(form:, field:, type: :text, label: nil, hint: nil, **options)
    @form = form
    @field = field
    @type = type
    @label = label || field.to_s.humanize
    @hint = hint
    @options = options
  end

  def error_messages
    @form.object.errors[@field]
  end

  def has_error?
    error_messages.any?
  end
end
```

```erb
<div class="form-group <%= 'has-error' if has_error? %>">
  <%= @form.label @field, @label, class: "form-label" %>

  <%= @form.send("#{@type}_field", @field,
        class: "form-input #{has_error? ? 'border-red-500' : ''}",
        **@options) %>

  <% if @hint %>
    <p class="form-hint"><%= @hint %></p>
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

## Best Practices

### File Organization

```
app/components/
├── application_component.rb    # Base class
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

### Base Component

```ruby
# app/components/application_component.rb
class ApplicationComponent < ViewComponent::Base
  include Turbo::FramesHelper
  include Turbo::StreamsHelper

  private

  def helpers
    ActionController::Base.helpers
  end
end
```

### Stimulus Integration

```erb
<%# Component with Stimulus controller %>
<div data-controller="dropdown" class="relative">
  <button data-action="dropdown#toggle">
    <%= @label %>
  </button>

  <div data-dropdown-target="menu" class="hidden">
    <%= content %>
  </div>
</div>
```
