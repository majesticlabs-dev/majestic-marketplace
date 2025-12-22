# Toast and Slideover Dialog Patterns

## Alert/Toast Pattern

For flash messages and notifications using `<dialog>` with non-modal presentation.

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
    this.element.show()  // Non-modal, no backdrop

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

### Styling

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

### show() vs showModal()

- `showModal()` - Centers dialog, adds backdrop, traps focus (use for modals)
- `show()` - Opens without backdrop or focus trap (use for toasts/alerts)

## Slideover Panel Pattern

For side panels (settings, filters, details):

### Template

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

### Styling

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

### Right-side vs Left-side

For left-side panels:

```css
dialog.slideover-left {
  margin: 0;
  margin-right: auto;  /* Push to left */
}

dialog.slideover-left[open] {
  animation: slide-in-left 0.2s ease-out;
}

@keyframes slide-in-left {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
}
```
