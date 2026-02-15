# Zero-JavaScript Dialog Patterns

Modern browsers support the **Invoker Commands API** for declarative dialog control—no JavaScript required.

## Basic Pattern

```html
<button commandfor="delete-dialog" command="show-modal">Delete</button>

<dialog id="delete-dialog" closedby="any" role="alertdialog"
        aria-labelledby="confirm-title" aria-describedby="confirm-desc">
  <h3 id="confirm-title">Delete this item?</h3>
  <p id="confirm-desc">This action cannot be undone.</p>
  <footer>
    <button commandfor="delete-dialog" command="close">Cancel</button>
    <button type="submit" formmethod="dialog">Delete</button>
  </footer>
</dialog>
```

## Key Attributes

| Attribute | Purpose |
|-----------|---------|
| `commandfor="id"` | References the dialog to control |
| `command="show-modal"` | Opens as modal (backdrop, focus trap) |
| `command="close"` | Closes the dialog |
| `closedby="any"` | Enables backdrop click and ESC to close |

## Rails ERB Example

```erb
<%# Inline confirmation - no extra route needed %>
<%= button_tag "Delete", commandfor: "delete-#{post.id}", command: "show-modal", class: "btn-danger" %>

<dialog id="delete-<%= post.id %>" closedby="any" role="alertdialog">
  <h3>Delete "<%= post.title %>"?</h3>
  <p>This cannot be undone.</p>
  <footer>
    <button commandfor="delete-<%= post.id %>" command="close">Cancel</button>
    <%= button_to "Delete", post, method: :delete, class: "btn-danger" %>
  </footer>
</dialog>
```

## CSS-Only Animations with @starting-style

Animate dialog enter/exit without JavaScript:

```css
dialog {
  opacity: 0;
  transform: scale(0.95);
  transition: opacity 0.2s, transform 0.2s, overlay 0.2s allow-discrete, display 0.2s allow-discrete;
}

dialog[open] {
  opacity: 1;
  transform: scale(1);
}

@starting-style {
  dialog[open] {
    opacity: 0;
    transform: scale(0.95);
  }
}

dialog::backdrop {
  background: rgb(0 0 0 / 0);
  transition: background 0.2s, overlay 0.2s allow-discrete, display 0.2s allow-discrete;
}

dialog[open]::backdrop {
  background: rgb(0 0 0 / 0.5);
}

@starting-style {
  dialog[open]::backdrop {
    background: rgb(0 0 0 / 0);
  }
}
```

## Turbo Confirm Integration

Replace the browser's ugly `confirm()` dialog with your styled dialog:

```javascript
// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails"

Turbo.config.forms.confirm = (message, element) => {
  const dialog = document.getElementById("turbo-confirm-dialog")
  const messageEl = dialog.querySelector("[data-confirm-message]")
  const confirmBtn = dialog.querySelector("[data-confirm-accept]")

  messageEl.textContent = message

  return new Promise((resolve) => {
    confirmBtn.onclick = () => { dialog.close(); resolve(true) }
    dialog.onclose = () => resolve(false)
    dialog.showModal()
  })
}
```

### Layout Dialog Template

```erb
<%# app/views/layouts/application.html.erb %>
<dialog id="turbo-confirm-dialog" closedby="any" role="alertdialog">
  <h3>Confirm</h3>
  <p data-confirm-message></p>
  <footer>
    <button commandfor="turbo-confirm-dialog" command="close">Cancel</button>
    <button data-confirm-accept class="btn-danger">Confirm</button>
  </footer>
</dialog>
```

Now `data-turbo-confirm` uses your styled dialog:

```erb
<%= button_to "Delete", @post, method: :delete, data: { turbo_confirm: "Delete this post?" } %>
```

## Browser Support

| Feature | Chrome | Safari | Firefox |
|---------|--------|--------|---------|
| `command`/`commandfor` | 135+ | 26.2+ | 144+ |
| `closedby` | 135+ | 26.2+ (polyfill) | 144+ |
| `@starting-style` | 117+ | 17.5+ | 129+ |

For `closedby` in Safari, include the [invokers polyfill](https://github.com/nickshanks/invokers).

## Progressive Enhancement

Use Stimulus patterns as the baseline, enhance with Invoker Commands where supported:

```erb
<%# Works everywhere, enhanced where supported %>
<button commandfor="dialog" command="show-modal"
        data-action="click->dialog#open">
  Open
</button>
```
