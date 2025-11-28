---
name: viewcomponent-coder
description: Build component-based UIs with ViewComponent and Lookbook. Use when creating reusable UI components, implementing slots and variants, or building component previews. Triggers on ViewComponent creation, component patterns, Lookbook previews, or UI component architecture.
---

# ViewComponent Patterns

Build modern, component-based UIs with ViewComponent - the Rails way to create reusable, testable UI components.

## When to Use This Skill

- Creating ViewComponent classes
- Implementing slots and variants
- Building Lookbook previews
- Testing components in isolation
- Refactoring partials to components

## Core Principle: Components Over Partials

**Prefer ViewComponents over partials** for reusable UI.

### Why ViewComponents?

- Better encapsulation than partials
- Testable in isolation
- Object-oriented approach with explicit contracts
- IDE support and type safety
- Performance benefits (compiled templates)

## Important Rules

**1. Prefix Rails helpers with `helpers.`**

```erb
<%# CORRECT %>
<%= helpers.link_to "Home", root_path %>
<%= helpers.image_tag "logo.png" %>
<%= helpers.inline_svg_tag "icons/user.svg" %>

<%# WRONG - will fail in component context %>
<%= link_to "Home", root_path %>
```

**Exception**: `t()` i18n helper does NOT need prefix:

```erb
<%= t('.title') %>
```

**2. SVG Icons as Separate Files**

Store SVGs in `app/assets/images/icons/` and render with `inline_svg` gem:

```erb
<%= helpers.inline_svg_tag "icons/user.svg", class: "w-5 h-5" %>
```

**Don't inline SVG markup in Ruby code** - use separate files instead.

## Basic Component

```ruby
# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant: :primary, **options)
    @text = text
    @variant = variant
    @options = options
  end
end
```

```erb
<%# app/components/button_component.html.erb %>
<button class="btn btn-<%= @variant %>" <%= html_attributes(@options) %>>
  <%= @text %>
</button>
```

## Component with Slots

```ruby
class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  renders_many :actions
end
```

```erb
<%= render CardComponent.new do |card| %>
  <% card.with_header do %>
    <h3>Title</h3>
  <% end %>

  <p>Body content</p>

  <% card.with_action do %>
    <%= helpers.link_to "Edit", edit_path %>
  <% end %>
<% end %>
```

## Component with Variants

```ruby
class BadgeComponent < ViewComponent::Base
  VARIANTS = {
    primary: "bg-blue-100 text-blue-800",
    success: "bg-green-100 text-green-800",
    warning: "bg-yellow-100 text-yellow-800",
    danger: "bg-red-100 text-red-800"
  }.freeze

  def initialize(text:, variant: :primary)
    @text = text
    @variant = variant
  end

  def variant_classes
    VARIANTS[@variant]
  end
end
```

## Conditional Rendering

```ruby
class AlertComponent < ViewComponent::Base
  def initialize(message:, type: :info, dismissible: true)
    @message = message
    @type = type
    @dismissible = dismissible
  end

  # Skip rendering if no message
  def render?
    @message.present?
  end
end
```

## Lookbook Previews

Required for shared components:

```ruby
# spec/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render ButtonComponent.new(text: "Click me")
  end

  def primary
    render ButtonComponent.new(text: "Primary", variant: :primary)
  end

  def danger
    render ButtonComponent.new(text: "Delete", variant: :danger)
  end
end
```

Access at: `http://localhost:3000/lookbook`

## Testing Components

```ruby
RSpec.describe ButtonComponent, type: :component do
  it "renders button text" do
    render_inline(ButtonComponent.new(text: "Click me"))
    expect(page).to have_button("Click me")
  end

  it "applies variant classes" do
    render_inline(ButtonComponent.new(text: "Save", variant: :primary))
    expect(page).to have_css("button.btn-primary")
  end
end
```

## Setup

```ruby
# Gemfile
gem "view_component"
gem "lookbook"  # For component previews
gem "inline_svg"  # For SVG icons
```

## Detailed References

For advanced patterns and examples:
- `references/patterns.md` - Slots, collections, polymorphic components, Turbo integration
