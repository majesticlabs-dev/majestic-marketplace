---
name: rails-tiptap-autosave
description: Use when adding Tiptap rich text editing with debounced autosave to Rails models. Stores markdown in text columns (not ActionText). Triggers on rich text editor, Tiptap, autosave, inline editing, or markdown content fields. Not for ActionText or basic textarea inputs.
---

# Rails Tiptap Autosave

Add rich text editing with automatic background saving to any Rails model using Tiptap, Stimulus, and markdown stored in plain text columns.

## When to Use

1. Adding rich text editing to Rails models without ActionText
2. Implementing inline autosave for text fields
3. Integrating Tiptap editor with Stimulus controllers
4. Building content editing UIs with formatting toolbars
5. Debugging Tiptap + Turbo cache conflicts

## Architecture

**Key decision: Markdown in text columns, NOT ActionText.**

- No extra tables or polymorphic attachments
- Content is plain text — easy to query, diff, and version
- Markdown renders cleanly in non-browser contexts (emails, APIs, CLI)
- Simpler than ActionText's rich text blobs

How it works:
1. Tiptap editor (initialized via Stimulus) converts user input to markdown
2. On every keystroke (debounced 1 second), PATCH to autosave endpoint
3. Controller saves markdown via `update_column`
4. Status indicator shows "Saving..." → "Saved" → fades

### Key Files

| File | Purpose |
|------|---------|
| `app/javascript/controllers/rich_text_editor_controller.js` | Tiptap Stimulus controller |
| `app/views/shared/_rich_text_field.html.erb` | Reusable editor partial |
| `app/views/shared/_bubble_menu.html.erb` | Formatting toolbar |

## Core Patterns

### Installation & Build Pipeline

npm packages, `@rails/request.js` for CSRF, JS bundler setup (Tiptap does **not** work with importmap), and editor CSS.

See: `references/installation.md`

### Stimulus Controller

Full `rich_text_editor_controller.js` — Tiptap initialization, debounced autosave, BubbleMenu target relocation, Turbo cache cleanup, and bubble menu formatting commands.

See: `references/stimulus-controller.md`

### View Partials

Reusable `_rich_text_field.html.erb` and `_bubble_menu.html.erb` with Stimulus data attributes.

See: `references/partials.md`

### Optional Audit Trail

Debounced change tracking that groups rapid edits into single audit events.

See: `references/audit-trail.md`

## Adding Rich Text to a Model

### Step 1: Add a text column

```ruby
class AddBodyToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :body, :text  # Must be :text, NOT :string (255 char limit)
  end
end
```

### Step 2: Add autosave route

```ruby
resources :articles do
  member { patch :autosave }
end
```

### Step 3: Add autosave action

```ruby
AUTOSAVE_FIELDS = %w[body summary notes].freeze

def autosave
  field = params[:field].to_s
  return render json: { error: "field not allowed" }, status: :bad_request unless AUTOSAVE_FIELDS.include?(field)

  @article.update_column(field.to_sym, params[:value])
  render json: { status: "saved" }
end
```

Key points:
- `update_column` bypasses validations/callbacks — correct for autosave performance
- Field whitelist prevents writing to arbitrary columns
- `set_article` must include `:autosave` in `only:` list

### Step 4: Render the partial

```erb
<%= render "shared/rich_text_field",
    url: autosave_article_path(@article),
    field: "body",
    content: @article.body,
    placeholder: "Write your article...",
    label: "Body" %>
```

## Multiple Rich Text Fields

Each field gets its own controller instance. Each is fully independent:

```erb
<%= render "shared/rich_text_field", url: autosave_article_path(@article),
    field: "body", content: @article.body, label: "Body" %>

<%= render "shared/rich_text_field", url: autosave_article_path(@article),
    field: "summary", content: @article.summary, label: "Summary" %>
```

## Rendering Saved Markdown

```ruby
# Gemfile: gem "redcarpet"
module MarkdownHelper
  def render_markdown(text)
    return "" if text.blank?
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true,
      fenced_code_blocks: true, strikethrough: true)
    markdown.render(text).html_safe
  end
end
```

```erb
<div class="prose prose-sm max-w-none"><%= render_markdown(@article.body) %></div>
```

## Common Pitfalls

1. **Wrong column type**: Use `text`, not `string` (255-char limit silently truncates)
2. **Missing route**: `patch :autosave` member route must exist or you get 404s
3. **Missing before_action**: `set_article` must include `:autosave` in `only:` list
4. **Broadcast conflicts**: Never use `broadcasts_refreshes` on models with Tiptap — Turbo morphing destroys editor mid-edit. Scope broadcasts to exclude the editing user.
5. **ActionText confusion**: This is NOT ActionText. Do not add `has_rich_text` declarations.
6. **Importmap incompatibility**: Tiptap is not ESM-compatible with importmap. Use esbuild or vite. See `references/installation.md`.
7. **BubbleMenu target relocation**: Tiptap moves the DOM element outside Stimulus controller scope, making `this.bubbleMenuTarget` unreachable. Save a reference before calling `new Editor()`. See `references/stimulus-controller.md`.
8. **Turbo cache stale editors**: Back-button shows a broken editor without proper `turbo:before-cache` handling. Destroy the editor and restore DOM before Turbo caches the page. See `references/stimulus-controller.md`.
