# Dialog Implementation Examples

## Stimulus Controller (Full Implementation)

```javascript
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.showModal()
    this.scrollY = window.scrollY
  }

  disconnect() {
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.removeAttribute("src")
      frame.replaceChildren()
    }
  }

  close() {
    this.element.close()
  }

  clickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
```

## CSS Styling

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

body:has(dialog[open]) {
  overflow: hidden;
}
```

### Tailwind Version

```erb
<dialog class="rounded-lg shadow-xl max-w-lg w-[90vw] p-0 backdrop:bg-black/50 backdrop:backdrop-blur-sm"
        data-controller="dialog"
        data-action="click->dialog#clickOutside">
  <!-- content -->
</dialog>
```

## Confirmation Dialog (Full Example)

### View

```erb
<%# app/views/posts/confirm_delete.html.erb %>
<%= turbo_frame_tag :modal do %>
  <dialog data-controller="dialog" data-action="click->dialog#clickOutside" open>
    <article>
      <h2>Delete Post?</h2>
      <p>Are you sure you want to delete "<%= @post.title %>"? This cannot be undone.</p>
      <footer class="flex gap-2 justify-end mt-4">
        <button data-action="dialog#close" class="btn btn-secondary">Cancel</button>
        <%= button_to "Delete", @post, method: :delete, class: "btn btn-danger", data: { turbo_confirm: false } %>
      </footer>
    </article>
  </dialog>
<% end %>
```

### Route

```ruby
resources :posts do
  member do
    get :confirm_delete
  end
end
```

### Trigger

```erb
<%= link_to "Delete", confirm_delete_post_path(@post), data: { turbo_frame: :modal } %>
```

## Enhanced Accessibility

```erb
<dialog aria-labelledby="dialog-title"
        aria-describedby="dialog-description"
        data-controller="dialog">
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-description">This action cannot be undone.</p>
</dialog>
```

### Focus Return

```javascript
connect() {
  this.previouslyFocused = document.activeElement
  this.element.showModal()
}

close() {
  this.element.close()
  this.previouslyFocused?.focus()
}
```

## Turbo Stream Response (Stay in Modal)

```ruby
def create
  @post = Post.new(post_params)
  if @post.save
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.append("posts", partial: "posts/post", locals: { post: @post }),
          turbo_stream.update("modal", "")
        ]
      }
      format.html { redirect_to posts_path }
    end
  else
    render :new, status: :unprocessable_entity
  end
end
```
