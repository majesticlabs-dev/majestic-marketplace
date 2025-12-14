# Reusable Stimulus Controllers Catalog

Copy-paste-ready Stimulus controllers from 37signals' production applications. These are generic, reusable patterns - no domain-specific logic.

## Design Principles

- **Static values/classes**: Configure behavior through data attributes
- **Dispatch for communication**: Controllers emit events, don't call each other directly
- **Private methods**: Keep internal logic private
- **Small and focused**: One controller, one responsibility

## Copy to Clipboard

Universal clipboard controller for any copyable content.

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]
  static values = { content: String }
  static classes = ["copied"]

  copy(event) {
    event.preventDefault()
    const text = this.hasContentValue ? this.contentValue : this.sourceTarget.value

    navigator.clipboard.writeText(text).then(() => {
      this.element.classList.add(this.copiedClass)
      this.dispatch("copied", { detail: { text } })

      setTimeout(() => {
        this.element.classList.remove(this.copiedClass)
      }, 2000)
    })
  }
}
```

```erb
<%# Usage: Copy from value %>
<div data-controller="clipboard" data-clipboard-copied-class="bg-green-100">
  <input data-clipboard-target="source" value="Copy this text" readonly>
  <button data-action="clipboard#copy">Copy</button>
</div>

<%# Usage: Copy from data attribute %>
<button data-controller="clipboard"
        data-clipboard-content-value="secret-token-123"
        data-action="clipboard#copy">
  Copy Token
</button>
```

## Element Removal

Self-removing elements (flash messages, dismissible alerts).

```javascript
// app/javascript/controllers/element_removal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove() {
    this.element.remove()
  }
}
```

```erb
<%# Auto-dismiss on animation end %>
<div data-controller="element-removal"
     data-action="animationend->element-removal#remove"
     class="flash">
  <%= notice %>
</div>

<%# Manual dismiss button %>
<div data-controller="element-removal" class="alert">
  <p>Alert content</p>
  <button data-action="element-removal#remove">Dismiss</button>
</div>
```

## Auto-Click

Automatically click an element after connection (modal triggers, auto-submit).

```javascript
// app/javascript/controllers/auto_click_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.click()
  }
}
```

```erb
<%# Auto-open modal on page load %>
<button data-controller="auto-click"
        data-action="click->modal#open">
  Hidden Trigger
</button>
```

## Toggle Class

Toggle CSS classes on elements (accordions, tabs, show/hide).

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static classes = ["active", "hidden"]
  static values = { exclusive: Boolean }

  toggle(event) {
    const item = event.currentTarget

    if (this.exclusiveValue) {
      this.itemTargets.forEach(target => {
        target.classList.remove(this.activeClass)
        target.classList.add(this.hiddenClass)
      })
    }

    item.classList.toggle(this.activeClass)
    item.classList.toggle(this.hiddenClass)

    this.dispatch("toggled", { detail: { item } })
  }

  show(event) {
    const item = this.#findItem(event)
    item?.classList.remove(this.hiddenClass)
    item?.classList.add(this.activeClass)
  }

  hide(event) {
    const item = this.#findItem(event)
    item?.classList.add(this.hiddenClass)
    item?.classList.remove(this.activeClass)
  }

  #findItem(event) {
    const id = event.params?.id
    return id ? this.itemTargets.find(t => t.id === id) : event.currentTarget
  }
}
```

```erb
<%# Accordion %>
<div data-controller="toggle"
     data-toggle-active-class="border-blue-500"
     data-toggle-hidden-class="hidden"
     data-toggle-exclusive-value="true">
  <button data-action="toggle#toggle" data-toggle-target="item">Section 1</button>
  <button data-action="toggle#toggle" data-toggle-target="item">Section 2</button>
</div>
```

## Autoresize Textarea

Auto-expanding textarea that grows with content.

```javascript
// app/javascript/controllers/autoresize_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { minRows: { type: Number, default: 2 } }

  connect() {
    this.resize()
  }

  resize() {
    this.element.style.height = "auto"
    const minHeight = this.minRowsValue * parseInt(getComputedStyle(this.element).lineHeight)
    this.element.style.height = Math.max(this.element.scrollHeight, minHeight) + "px"
  }

  reset() {
    this.element.style.height = "auto"
  }
}
```

```erb
<%= form.text_area :body,
  data: {
    controller: "autoresize",
    autoresize_min_rows_value: 3,
    action: "input->autoresize#resize"
  } %>
```

## Hotkey

Keyboard shortcut bindings.

```javascript
// app/javascript/controllers/hotkey_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    key: String,
    ctrl: Boolean,
    meta: Boolean,
    shift: Boolean
  }

  connect() {
    this.boundHandler = this.#handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandler)
  }

  #handleKeydown(event) {
    if (this.#matchesKey(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  #matchesKey(event) {
    const keyMatches = event.key.toLowerCase() === this.keyValue.toLowerCase()
    const ctrlMatches = !this.ctrlValue || event.ctrlKey
    const metaMatches = !this.metaValue || event.metaKey
    const shiftMatches = !this.shiftValue || event.shiftKey

    return keyMatches && ctrlMatches && metaMatches && shiftMatches
  }
}
```

```erb
<%# Cmd+K to open search %>
<button data-controller="hotkey"
        data-hotkey-key-value="k"
        data-hotkey-meta-value="true"
        data-action="click->search#open">
  Search (⌘K)
</button>
```

## Local Time

Display times in user's local timezone.

```javascript
// app/javascript/controllers/local_time_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    datetime: String,
    format: { type: String, default: "relative" }
  }

  connect() {
    this.#render()
    if (this.formatValue === "relative") {
      this.interval = setInterval(() => this.#render(), 60000)
    }
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  #render() {
    const date = new Date(this.datetimeValue)

    switch (this.formatValue) {
      case "relative":
        this.element.textContent = this.#relativeTime(date)
        break
      case "date":
        this.element.textContent = date.toLocaleDateString()
        break
      case "time":
        this.element.textContent = date.toLocaleTimeString()
        break
      case "datetime":
        this.element.textContent = date.toLocaleString()
        break
    }
  }

  #relativeTime(date) {
    const now = new Date()
    const diff = now - date
    const seconds = Math.floor(diff / 1000)
    const minutes = Math.floor(seconds / 60)
    const hours = Math.floor(minutes / 60)
    const days = Math.floor(hours / 24)

    if (seconds < 60) return "just now"
    if (minutes < 60) return `${minutes}m ago`
    if (hours < 24) return `${hours}h ago`
    if (days < 7) return `${days}d ago`
    return date.toLocaleDateString()
  }
}
```

```erb
<time data-controller="local-time"
      data-local-time-datetime-value="<%= message.created_at.iso8601 %>"
      data-local-time-format-value="relative"
      datetime="<%= message.created_at.iso8601 %>">
  <%= message.created_at %>
</time>
```

## Fetch on Visible

Lazy-load content when element enters viewport.

```javascript
// app/javascript/controllers/fetch_on_visible_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.observer = new IntersectionObserver(
      entries => entries.forEach(entry => this.#handleIntersection(entry)),
      { threshold: 0.1 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  #handleIntersection(entry) {
    if (entry.isIntersecting) {
      this.observer.disconnect()
      this.#fetch()
    }
  }

  async #fetch() {
    try {
      const response = await fetch(this.urlValue, {
        headers: { "Accept": "text/html" }
      })
      this.element.outerHTML = await response.text()
    } catch (error) {
      console.error("Fetch on visible failed:", error)
    }
  }
}
```

```erb
<%# Lazy-load comments when scrolled into view %>
<div data-controller="fetch-on-visible"
     data-fetch-on-visible-url-value="<%= post_comments_path(@post) %>">
  <span class="loading">Loading comments...</span>
</div>
```

## Dialog (Modal)

Native HTML dialog with Stimulus.

```javascript
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = { closeOnOutsideClick: { type: Boolean, default: true } }

  connect() {
    if (this.closeOnOutsideClickValue) {
      this.dialogTarget.addEventListener("click", this.#handleBackdropClick.bind(this))
    }
  }

  open() {
    this.dialogTarget.showModal()
    document.body.style.overflow = "hidden"
    this.dispatch("opened")
  }

  close() {
    this.dialogTarget.close()
    document.body.style.overflow = ""
    this.dispatch("closed")
  }

  #handleBackdropClick(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
```

```erb
<div data-controller="dialog">
  <button data-action="dialog#open">Open Modal</button>

  <dialog data-dialog-target="dialog" class="modal">
    <div class="modal-content">
      <h2>Modal Title</h2>
      <p>Modal content here</p>
      <button data-action="dialog#close">Close</button>
    </div>
  </dialog>
</div>
```

```css
/* Native dialog backdrop styling */
dialog::backdrop {
  background: rgba(0, 0, 0, 0.5);
}

dialog {
  border: none;
  border-radius: 0.5rem;
  padding: 0;
  max-width: 32rem;
}
```

## Form Controller

Enhanced form handling with loading states and validation.

```javascript
// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "error"]
  static classes = ["loading", "error"]
  static values = { resetOnSuccess: Boolean }

  connect() {
    this.element.addEventListener("turbo:submit-start", this.#onSubmitStart.bind(this))
    this.element.addEventListener("turbo:submit-end", this.#onSubmitEnd.bind(this))
  }

  #onSubmitStart() {
    this.submitTarget.disabled = true
    this.element.classList.add(this.loadingClass)
    this.#clearErrors()
  }

  #onSubmitEnd(event) {
    this.submitTarget.disabled = false
    this.element.classList.remove(this.loadingClass)

    if (event.detail.success) {
      this.dispatch("success")
      if (this.resetOnSuccessValue) this.element.reset()
    } else {
      this.element.classList.add(this.errorClass)
      this.dispatch("error")
    }
  }

  #clearErrors() {
    this.element.classList.remove(this.errorClass)
    this.errorTargets.forEach(el => el.textContent = "")
  }
}
```

```erb
<%= form_with model: @message,
  data: {
    controller: "form",
    form_loading_class: "opacity-50",
    form_error_class: "border-red-500",
    form_reset_on_success_value: true
  } do |f| %>

  <%= f.text_field :body %>
  <span data-form-target="error"></span>

  <%= f.submit "Send", data: { form_target: "submit" } %>
<% end %>
```

## Local Save (Draft Persistence)

Auto-save form content to localStorage.

```javascript
// app/javascript/controllers/local_save_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]
  static values = { key: String, debounce: { type: Number, default: 1000 } }

  connect() {
    this.#restore()
  }

  save() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const data = {}
      this.fieldTargets.forEach(field => {
        data[field.name] = field.value
      })
      localStorage.setItem(this.keyValue, JSON.stringify(data))
      this.dispatch("saved")
    }, this.debounceValue)
  }

  clear() {
    localStorage.removeItem(this.keyValue)
    this.dispatch("cleared")
  }

  #restore() {
    const saved = localStorage.getItem(this.keyValue)
    if (!saved) return

    const data = JSON.parse(saved)
    this.fieldTargets.forEach(field => {
      if (data[field.name]) field.value = data[field.name]
    })
    this.dispatch("restored")
  }
}
```

```erb
<%= form_with model: @post,
  data: {
    controller: "local-save",
    local_save_key_value: "post_draft_#{current_user.id}",
    action: "turbo:submit-end->local-save#clear"
  } do |f| %>

  <%= f.text_field :title, data: {
    local_save_target: "field",
    action: "input->local-save#save"
  } %>

  <%= f.text_area :body, data: {
    local_save_target: "field",
    action: "input->local-save#save"
  } %>

  <%= f.submit %>
<% end %>
```

## Controller Communication Pattern

Controllers communicate via dispatched events, not direct references.

```javascript
// parent_controller.js
export default class extends Controller {
  handleChildEvent(event) {
    const { text } = event.detail
    // React to child event
  }
}

// child_controller.js
export default class extends Controller {
  doSomething() {
    this.dispatch("done", { detail: { text: "completed" } })
  }
}
```

```erb
<div data-controller="parent"
     data-action="child:done->parent#handleChildEvent">
  <button data-controller="child"
          data-action="click->child#doSomething">
    Click Me
  </button>
</div>
```
