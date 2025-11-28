# Style Variants DSL

Comprehensive guide to ViewComponentContrib::StyleVariants - a powerful DSL for managing CSS classes in ViewComponents, inspired by [Tailwind Variants](https://www.tailwind-variants.org/) and [CVA](https://cva.style/).

## Table of Contents
- [Basic Usage](#basic-usage)
- [Variants](#variants)
- [Compound Variants](#compound-variants)
- [Boolean Variants](#boolean-variants)
- [Multiple Style Sets](#multiple-style-sets)
- [Inheritance Strategies](#inheritance-strategies)
- [TailwindMerge Integration](#tailwindmerge-integration)
- [Tailwind LSP Configuration](#tailwind-lsp-configuration)

## Basic Usage

Include the module and define styles with the `style` DSL:

```ruby
class ButtonComponent < ApplicationViewComponent
  include ViewComponentContrib::StyleVariants

  option :color, default: -> { :primary }
  option :size, default: -> { :md }

  style do
    base { %w[font-medium rounded-full transition-colors] }

    variants {
      color {
        primary { %w[bg-blue-500 text-white hover:bg-blue-600] }
        secondary { %w[bg-gray-500 text-white hover:bg-gray-600] }
        danger { %w[bg-red-500 text-white hover:bg-red-600] }
      }
      size {
        sm { "text-sm px-2 py-1" }
        md { "text-base px-4 py-2" }
        lg { "text-lg px-6 py-3" }
      }
    }

    defaults { { color: :primary, size: :md } }
  end
end
```

In the template, call `style()` with variant values:

```erb
<button class="<%= style(color:, size:) %>">
  <%= text %>
</button>
```

## Variants

Variants are named groups of CSS classes that can be toggled based on component options.

### Defining Variants

```ruby
style do
  variants {
    # Each variant group
    color {
      primary { %w[bg-blue-500 text-white] }
      secondary { %w[bg-gray-200 text-gray-800] }
      ghost { %w[bg-transparent text-gray-600] }
    }

    size {
      xs { "text-xs px-1.5 py-0.5" }
      sm { "text-sm px-2 py-1" }
      md { "text-base px-4 py-2" }
      lg { "text-lg px-6 py-3" }
      xl { "text-xl px-8 py-4" }
    }

    rounded {
      none { "rounded-none" }
      sm { "rounded-sm" }
      md { "rounded-md" }
      lg { "rounded-lg" }
      full { "rounded-full" }
    }
  }
end
```

### Using Variants

```erb
<%# Using component options directly with Ruby 3.1+ shorthand %>
<button class="<%= style(color:, size:, rounded:) %>">

<%# Explicit values %>
<button class="<%= style(color: :primary, size: :lg, rounded: :full) %>">

<%# Partial - uses defaults for unspecified %>
<button class="<%= style(size: :sm) %>">
```

## Compound Variants

Apply additional classes when multiple variant conditions match:

```ruby
style do
  variants {
    color {
      primary { %w[bg-blue-500 text-white] }
      danger { %w[bg-red-500 text-white] }
    }
    size {
      sm { "text-sm" }
      lg { "text-lg" }
    }
    outline {
      yes { "bg-transparent border-2" }
      no { "" }
    }
  }

  # Single compound
  compound(size: :lg, color: :primary) { "uppercase tracking-wide" }

  # Multiple compounds
  compound(color: :danger, outline: :yes) { "border-red-500 text-red-500" }
  compound(color: :primary, outline: :yes) { "border-blue-500 text-blue-500" }

  # Compound with multiple values (matches any)
  compound(color: [:primary, :secondary], size: :lg) { "font-bold" }
end
```

## Boolean Variants

Boolean options are automatically converted to `:yes` / `:no` values:

```ruby
class ButtonComponent < ApplicationViewComponent
  include ViewComponentContrib::StyleVariants

  option :disabled, default: -> { false }
  option :loading, default: -> { false }

  style do
    variants {
      disabled {
        yes { "opacity-50 cursor-not-allowed pointer-events-none" }
        no { "cursor-pointer" }
      }
      loading {
        yes { "animate-pulse" }
        no { "" }
      }
    }
  end
end
```

```erb
<%# Pass boolean directly - converted to :yes/:no automatically %>
<button class="<%= style(disabled:, loading:) %>" <%= "disabled" if disabled %>>
  <%= loading ? "Loading..." : text %>
</button>
```

## Multiple Style Sets

Define multiple named style sets for different elements:

```ruby
class CardComponent < ApplicationViewComponent
  include ViewComponentContrib::StyleVariants

  option :variant, default: -> { :default }

  # Default style set (unnamed)
  style do
    base { %w[rounded-lg shadow-md overflow-hidden] }
    variants {
      variant {
        default { "bg-white" }
        elevated { "bg-white shadow-xl" }
        bordered { "bg-white border border-gray-200" }
      }
    }
  end

  # Named style set for header
  style :header do
    base { %w[px-6 py-4 border-b] }
    variants {
      variant {
        default { "border-gray-200" }
        elevated { "border-gray-100" }
        bordered { "border-gray-200 bg-gray-50" }
      }
    }
  end

  # Named style set for body
  style :body do
    base { "px-6 py-4" }
  end

  # Named style set for footer
  style :footer do
    base { %w[px-6 py-4 border-t border-gray-200 bg-gray-50] }
  end
end
```

```erb
<div class="<%= style(variant:) %>">
  <% if header %>
    <div class="<%= style(:header, variant:) %>">
      <%= header %>
    </div>
  <% end %>

  <div class="<%= style(:body) %>">
    <%= content %>
  </div>

  <% if footer %>
    <div class="<%= style(:footer) %>">
      <%= footer %>
    </div>
  <% end %>
</div>
```

## Inheritance Strategies

When extending components, choose how styles are inherited:

### Override (Default)

Completely replaces parent styles:

```ruby
class PrimaryButtonComponent < ButtonComponent
  # Replaces all parent styles
  style do
    base { %w[bg-blue-600 text-white font-bold] }
  end
end
```

### Merge (Deep Merge)

Preserves all parent variant keys unless explicitly overwritten:

```ruby
class DangerButtonComponent < ButtonComponent
  style(inherit: :merge) do
    # Only override the color variants, keep size variants from parent
    variants {
      color {
        primary { %w[bg-red-500 text-white] }  # Override primary to be red
      }
    }
  end
end
```

### Extend (Shallow Merge)

Adds to parent styles without overwriting:

```ruby
class IconButtonComponent < ButtonComponent
  style(inherit: :extend) do
    # Add new variant while keeping all parent variants
    variants {
      icon_position {
        left { "flex-row-reverse" }
        right { "flex-row" }
      }
    }
  end
end
```

## TailwindMerge Integration

Use postprocessing to resolve conflicting Tailwind classes with [tailwind_merge](https://github.com/gjtorikern/tailwind_merge):

```ruby
# config/initializers/view_component.rb
require "tailwind_merge"

ViewComponentContrib::StyleVariants.postprocess = ->(classes) do
  TailwindMerge::Merger.new.merge(classes)
end
```

Now conflicting classes are automatically resolved:

```ruby
style do
  base { %w[p-4 bg-blue-500] }

  variants {
    size {
      lg { "p-8" }  # Will override base p-4
    }
    color {
      red { "bg-red-500" }  # Will override base bg-blue-500
    }
  }
end
```

```erb
<%# Without TailwindMerge: "p-4 bg-blue-500 p-8 bg-red-500" (conflicting) %>
<%# With TailwindMerge: "p-8 bg-red-500" (resolved) %>
<div class="<%= style(size: :lg, color: :red) %>">
```

## Tailwind LSP Configuration

To enable Tailwind CSS IntelliSense for the Style Variants DSL in VS Code:

```json
// .vscode/settings.json
{
  "tailwindCSS.includeLanguages": {
    "erb": "html",
    "ruby": "html"
  },
  "tailwindCSS.experimental.classRegex": [
    "%w\\[([^\\]]*)\\]",
    "\"([^\"]*)\""
  ]
}
```

This enables:
- Class autocompletion inside `%w[]` and strings
- Color swatches preview
- Hover documentation for Tailwind classes
- Lint warnings for invalid classes

## Best Practices

### 1. Use Base for Common Styles

Put classes that apply to all variants in `base`:

```ruby
style do
  base { %w[inline-flex items-center justify-center font-medium transition-colors] }
  variants { ... }
end
```

### 2. Keep Variants Focused

Each variant group should control one aspect:

```ruby
# Good - focused variants
variants {
  color { ... }      # Controls colors
  size { ... }       # Controls sizing
  rounded { ... }    # Controls border radius
}

# Avoid - mixed concerns in one variant
variants {
  type {
    primary_large { "bg-blue-500 text-lg px-6" }  # Mixing color and size
  }
}
```

### 3. Use Compound for Complex Combinations

When styles depend on multiple variants:

```ruby
# Instead of complex conditionals in template
compound(size: :lg, color: :primary) { "uppercase" }
compound(disabled: :yes, loading: :yes) { "cursor-wait" }
```

### 4. Leverage Defaults

Set sensible defaults to reduce template verbosity:

```ruby
style do
  defaults { { color: :primary, size: :md, rounded: :md } }
end
```

```erb
<%# Just override what you need %>
<button class="<%= style(size: :lg) %>">
```
