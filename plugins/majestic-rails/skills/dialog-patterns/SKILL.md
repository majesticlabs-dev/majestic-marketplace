---
name: dialog-patterns
description: Native HTML dialog patterns for Rails with Turbo and Stimulus. Use when building modals, confirmations, alerts, or any overlay UI. Triggers on modal, dialog, popup, confirmation, alert, or toast patterns.
---

# Native Dialog Patterns for Rails

Build accessible, modern dialog UIs using the native HTML `<dialog>` element with Turbo Frames and Stimulus. No JavaScript frameworks or heavy libraries required.

## When to Use This Skill

- Building modal dialogs for forms, confirmations, or content
- Creating toast/alert notifications
- Implementing confirmation dialogs (delete, destructive actions)
- Any overlay UI that needs focus management and accessibility

## Why Native `<dialog>`?

| Feature | Native `<dialog>` | Custom Modal |
|---------|-------------------|--------------|
| Focus trapping | Built-in | Manual implementation |
| ESC to close | Built-in | Manual implementation |
| Backdrop | Built-in (`::backdrop`) | Manual overlay |
| Accessibility | Native `role="dialog"` | Manual ARIA |
| Top layer | Automatic (above all content) | z-index battles |
| Scroll lock | Automatic | Manual `overflow: hidden` |

## Core Pattern: Async Modal with Turbo Frames

The recommended pattern for Rails modals combines three technologies:

1. **Turbo Frame** - Async content loading without page reload
2. **Native `<dialog>`** - Accessible modal presentation
3. **Stimulus controller** - Lifecycle management

### Step 1: Layout Container

Add a modal turbo-frame to your layout:

```erb
<%# app/views/layouts/application.html.erb %>
<body>
  <%= yield %>

  <%# Modal injection point %>
  <%= turbo_frame_tag :modal %>
</body>
```

### Step 2: Trigger Links

Target the modal frame from any link:

```erb
<%# Any view %>
<%= link_to "New Post", new_post_path, data: { turbo_frame: :modal } %>
<%= link_to "Edit", edit_post_path(@post), data: { turbo_frame: :modal } %>
<%= link_to "Confirm Delete", confirm_delete_post_path(@post), data: { turbo_frame: :modal } %>
```

### Step 3: Modal Content View

Wrap modal content in matching turbo-frame with nested inner frame:

```erb
<%# app/views/posts/new.html.erb %>
<%= turbo_frame_tag :modal do %>
  <%# Inner frame prevents flash during form validation %>
  <%= turbo_frame_tag :modal_content do %>
    <dialog data-controller="dialog" data-action="click->dialog#clickOutside" open>
      <article>
        <header>
          <h2>New Post</h2>
          <button data-action="dialog#close" aria-label="Close">&times;</button>
        </header>

        <%= render "form", post: @post %>
      </article>
    </dialog>
  <% end %>
<% end %>
```

### Step 4: Stimulus Controller

```javascript
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-open when content loads via Turbo
    this.element.showModal()

    // Store original scroll position
    this.scrollY = window.scrollY
  }

  disconnect() {
    // Clean up turbo-frame to prevent stale content flash
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.removeAttribute("src")
      // Safe DOM clearing without innerHTML
      frame.replaceChildren()
    }
  }

  close() {
    this.element.close()
  }

  clickOutside(event) {
    // Close when clicking backdrop (the dialog element itself, not content)
    if (event.target === this.element) {
      this.close()
    }
  }

  // Handle ESC key (native behavior, but can customize)
  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
```

### Step 5: Styling

```css
/* app/assets/stylesheets/components/dialog.css */
dialog {
  border: none;
  border-radius: 0.5rem;
  padding: 0;
  max-width: 32rem;
  width: 90vw;
  box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
}

dialog::backdrop {
  background: rgb(0 0 0 / 0.5);
  backdrop-filter: blur(2px);
}

dialog article {
  padding: 1.5rem;
}

dialog header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

/* Prevent background scroll when modal open */
body:has(dialog[open]) {
  overflow: hidden;
}
```

With Tailwind:

```erb
<dialog class="rounded-lg shadow-xl max-w-lg w-[90vw] p-0 backdrop:bg-black/50 backdrop:backdrop-blur-sm"
        data-controller="dialog"
        data-action="click->dialog#clickOutside">
  <!-- content -->
</dialog>
```

## Why Nested Turbo Frames?

The nested frame pattern (`modal` > `modal_content`) prevents content flashing:

```erb
<%= turbo_frame_tag :modal do %>
  <%= turbo_frame_tag :modal_content do %>
    <dialog>...</dialog>
  <% end %>
<% end %>
```

**Problem without nested frame:**
When a form inside the modal has validation errors and re-renders, the outer frame briefly shows the old content before replacing it.

**Solution with nested frame:**
The inner frame handles form re-renders independently, keeping the modal structure stable.

## Form Handling in Modals

### Successful Submission

Redirect with Turbo to close modal and update page:

```ruby
# app/controllers/posts_controller.rb
def create
  @post = Post.new(post_params)

  if @post.save
    redirect_to posts_path, notice: "Post created!"
  else
    render :new, status: :unprocessable_entity
  end
end
```

The redirect navigates `_top` (full page), effectively closing the modal.

### Validation Errors

Re-render the form with `422` status to keep modal open:

```ruby
render :new, status: :unprocessable_entity
```

### Turbo Stream Response (Stay in Modal)

To update content without closing:

```ruby
def create
  @post = Post.new(post_params)

  if @post.save
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.append("posts", partial: "posts/post", locals: { post: @post }),
          turbo_stream.update("modal", "")  # Clear modal
        ]
      }
      format.html { redirect_to posts_path }
    end
  else
    render :new, status: :unprocessable_entity
  end
end
```

## Confirmation Dialog Pattern

For destructive actions like delete:

### The View

```erb
<%# app/views/posts/confirm_delete.html.erb %>
<%= turbo_frame_tag :modal do %>
  <dialog data-controller="dialog" data-action="click->dialog#clickOutside" open>
    <article>
      <h2>Delete Post?</h2>
      <p>Are you sure you want to delete "<%= @post.title %>"? This cannot be undone.</p>

      <footer class="flex gap-2 justify-end mt-4">
        <button data-action="dialog#close" class="btn btn-secondary">
          Cancel
        </button>
        <%= button_to "Delete", @post,
              method: :delete,
              class: "btn btn-danger",
              data: { turbo_confirm: false } %>
      </footer>
    </article>
  </dialog>
<% end %>
```

### The Route

```ruby
# config/routes.rb
resources :posts do
  member do
    get :confirm_delete
  end
end
```

### The Trigger

```erb
<%= link_to "Delete", confirm_delete_post_path(@post), data: { turbo_frame: :modal } %>
```

## Alert/Toast Pattern

For flash messages and notifications:

### Stimulus Controller

```javascript
// app/javascript/controllers/toast_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    duration: { type: Number, default: 5000 },
    dismissible: { type: Boolean, default: true }
  }

  connect() {
    this.element.showModal()

    if (this.durationValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.durationValue)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.close()
    this.element.remove()
  }
}
```

### Toast Component

```erb
<%# app/views/shared/_toast.html.erb %>
<dialog class="toast toast-<%= type %>"
        data-controller="toast"
        data-toast-duration-value="<%= duration || 5000 %>"
        data-toast-dismissible-value="true"
        data-action="click->toast#dismiss">
  <p><%= message %></p>
</dialog>
```

### Styling (Non-Modal Toast)

```css
/* Position as fixed notification, not centered modal */
dialog.toast {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  margin: 0;
  padding: 1rem;
  border-radius: 0.5rem;
}

dialog.toast::backdrop {
  display: none;  /* No backdrop for toasts */
}

dialog.toast-success { background: #10b981; color: white; }
dialog.toast-error { background: #ef4444; color: white; }
dialog.toast-warning { background: #f59e0b; color: white; }
dialog.toast-info { background: #3b82f6; color: white; }
```

### Using `show()` vs `showModal()`

- `showModal()` - Centers dialog, adds backdrop, traps focus (use for modals)
- `show()` - Opens without backdrop or focus trap (use for toasts/alerts)

```javascript
// For toasts, use show() not showModal()
connect() {
  this.element.show()  // Non-modal, no backdrop
}
```

## Slideover Panel Pattern

For side panels (settings, filters, details):

```erb
<dialog class="slideover"
        data-controller="dialog"
        data-action="click->dialog#clickOutside">
  <aside>
    <header>
      <h2>Filters</h2>
      <button data-action="dialog#close">&times;</button>
    </header>
    <div class="slideover-content">
      <%= render "filters" %>
    </div>
  </aside>
</dialog>
```

```css
dialog.slideover {
  margin: 0;
  margin-left: auto;
  height: 100vh;
  max-height: 100vh;
  width: 24rem;
  max-width: 90vw;
  border-radius: 0;
}

dialog.slideover[open] {
  animation: slide-in 0.2s ease-out;
}

@keyframes slide-in {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}
```

## Accessibility Checklist

Native `<dialog>` handles most accessibility, but verify:

- [ ] **Focus management** - First focusable element receives focus on open
- [ ] **Focus trap** - Tab cycling stays within dialog (native behavior)
- [ ] **ESC closes** - Native behavior with `showModal()`
- [ ] **Background inert** - Content behind dialog is not interactive (native)
- [ ] **Visible close button** - Not just ESC, provide visible control
- [ ] **Descriptive title** - Use `<h2>` or `aria-labelledby`
- [ ] **Return focus** - Focus returns to trigger element on close

### Enhanced Accessibility

```erb
<dialog aria-labelledby="dialog-title"
        aria-describedby="dialog-description"
        data-controller="dialog">
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-description">This action cannot be undone.</p>
  <!-- content -->
</dialog>
```

### Focus Return

```javascript
// Enhanced dialog controller with focus return
connect() {
  this.previouslyFocused = document.activeElement
  this.element.showModal()
}

close() {
  this.element.close()
  this.previouslyFocused?.focus()
}
```

## Common Patterns Summary

| Pattern | Container | Stimulus | `show` method |
|---------|-----------|----------|---------------|
| Modal form | `turbo_frame_tag :modal` | `dialog` | `showModal()` |
| Confirmation | `turbo_frame_tag :modal` | `dialog` | `showModal()` |
| Toast/Alert | Fixed position | `toast` | `show()` |
| Slideover | `turbo_frame_tag :modal` | `dialog` | `showModal()` |

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Custom modal without `<dialog>` | No native accessibility | Use native `<dialog>` |
| Missing nested turbo-frame | Content flash on validation | Add inner frame |
| Not clearing frame on close | Stale content on reopen | Clear with `replaceChildren()` in `disconnect()` |
| z-index for stacking | Battles with other elements | `<dialog>` uses top layer |
| Manual focus trap | Complex, error-prone | `showModal()` handles it |
| Inline backdrop div | Extra markup | Use `::backdrop` pseudo-element |

## Testing Dialogs

```ruby
# System test
RSpec.describe "Post creation modal", type: :system do
  it "opens modal and creates post" do
    visit posts_path
    click_link "New Post"

    within "dialog" do
      fill_in "Title", with: "My Post"
      click_button "Create"
    end

    expect(page).to have_text("Post created!")
    expect(page).not_to have_selector("dialog[open]")
  end

  it "shows validation errors in modal" do
    visit posts_path
    click_link "New Post"

    within "dialog" do
      click_button "Create"  # Empty form
      expect(page).to have_text("Title can't be blank")
    end

    expect(page).to have_selector("dialog[open]")  # Modal stays open
  end
end
```

## Browser Support

Native `<dialog>` is supported in all modern browsers (Chrome 37+, Firefox 98+, Safari 15.4+, Edge 79+). For older browsers, include the [dialog polyfill](https://github.com/GoogleChrome/dialog-polyfill).
