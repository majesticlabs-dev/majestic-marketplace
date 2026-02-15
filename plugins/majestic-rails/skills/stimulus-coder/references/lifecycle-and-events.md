# Lifecycle and Event Management

## Lifecycle Callbacks

### connect()

Called when controller's element enters the DOM. Use **only** for:
- Third-party plugin initialization (Chart.js, Swiper, Sortable)
- IntersectionObserver/MutationObserver setup
- One-time DOM measurements

Do NOT use for:
- State initialization → use Values API with defaults
- Event listeners → use `data-action` declarations
- Fetching data → use Turbo Frames with `loading: :lazy`

```javascript
// Good: plugin init
connect() {
  this.map = new MapLibre(this.element, {
    center: [this.lngValue, this.latValue],
    zoom: this.zoomValue
  })
}

// Bad: state + events in connect
connect() {
  this.isOpen = false  // Use: static values = { open: Boolean }
  this.element.addEventListener("click", this.toggle)  // Use: data-action="click->..."
}
```

### disconnect()

Called when element leaves the DOM. Must clean up everything from `connect()`:

```javascript
disconnect() {
  this.map?.remove()
  this.map = null
  this.observer?.disconnect()
  this.observer = null
}
```

Rules:
- Nullify references after cleanup
- Check for existence before destroying (element may disconnect before async init completes)
- A controller can connect/disconnect many times during Turbo navigation

### Value Changed Callbacks

Triggered when a value attribute changes (internally or externally):

```javascript
static values = { count: { type: Number, default: 0 } }

countValueChanged(current, previous) {
  // current: new value, previous: old value
  this.counterTarget.textContent = current

  if (current > previous) {
    this.element.classList.add("incremented")
  }
}
```

Key behaviors:
- Called on `connect()` with initial value (previous is undefined)
- Called when value attribute changes in DOM (Turbo Stream, other JS)
- NOT called if new value equals current value

### Target Connected/Disconnected

```javascript
static targets = ["item"]

itemTargetConnected(target) {
  // Called for each matching target when it enters DOM
  this.updateCount()
}

itemTargetDisconnected(target) {
  // Called when target is removed from DOM
  this.updateCount()
}
```

## Turbo-Specific Lifecycle

### Before-Cache Teardown

Turbo caches page snapshots. If your controller modifies DOM, cached state will be stale.

```javascript
connect() {
  this.boundTeardown = this.teardown.bind(this)
  document.addEventListener("turbo:before-cache", this.boundTeardown)

  // Third-party that modifies DOM
  this.sortable = new Sortable(this.element, {
    animation: 150,
    onSort: () => this.dispatch("sorted")
  })
}

teardown() {
  // Restore DOM to server-rendered state before caching
  this.sortable?.destroy()
  this.sortable = null
}

disconnect() {
  document.removeEventListener("turbo:before-cache", this.boundTeardown)
  this.teardown()
}
```

When to implement teardown:
- Controller adds/removes CSS classes dynamically
- Third-party library restructures DOM (sliders, sortables, date pickers)
- Controller creates elements not present in server HTML

When NOT needed:
- Controller only reads DOM (no mutations)
- Values API handles all state (already in data attributes)
- Only `data-action` events are used (Stimulus manages these)

### Template-Based DOM Restoration

For libraries that heavily mutate DOM, store original markup:

```javascript
connect() {
  // Save original HTML before library mutates it
  this.template = document.createElement("template")
  this.template.innerHTML = this.element.innerHTML

  this.widget = new HeavyWidget(this.element)
}

teardown() {
  this.widget?.destroy()
  this.element.innerHTML = ""
  this.element.insertAdjacentHTML("afterbegin", this.template.innerHTML)
}
```

## Event Management Patterns

### Declarative Global Events

Prefer `data-action` with `@window` or `@document` over manual listeners:

```erb
<div data-controller="sidebar"
     data-action="resize@window->sidebar#adjustLayout
                  keydown.escape@window->sidebar#close
                  turbo:load@document->sidebar#reset">
```

Stimulus automatically manages listener lifecycle for these declarations.

### Manual Listeners (When Required)

Some events require programmatic registration (e.g., specific options, dynamic targets):

```javascript
connect() {
  // Store bound reference - critical for removal
  this.boundScroll = this.handleScroll.bind(this)
  this.boundKeydown = this.handleKeydown.bind(this)

  window.addEventListener("scroll", this.boundScroll, { passive: true })
  document.addEventListener("keydown", this.boundKeydown)
}

disconnect() {
  window.removeEventListener("scroll", this.boundScroll)
  document.removeEventListener("keydown", this.boundKeydown)
}
```

Common mistake: calling `.bind()` inline creates new functions. Removal silently fails:

```javascript
// BROKEN: removeEventListener gets a different function reference
connect() {
  window.addEventListener("scroll", this.handleScroll.bind(this))
}
disconnect() {
  window.removeEventListener("scroll", this.handleScroll.bind(this)) // Does nothing!
}
```

### Event Options Parity

Options must match between add and remove:

```javascript
// If you add with capture:
window.addEventListener("click", this.boundClick, { capture: true })

// You must remove with capture:
window.removeEventListener("click", this.boundClick, { capture: true })
```

### AbortController Pattern

Alternative to storing multiple bound references:

```javascript
connect() {
  this.abortController = new AbortController()
  const { signal } = this.abortController

  window.addEventListener("resize", () => this.layout(), { signal })
  window.addEventListener("scroll", () => this.parallax(), { signal, passive: true })
  document.addEventListener("keydown", (e) => this.shortcut(e), { signal })
}

disconnect() {
  this.abortController.abort()
}
```

One `abort()` call removes all listeners. No bound references needed.

## Custom Event Contracts

Document event names and detail shapes as constants:

```javascript
// events.js - shared event contracts
export const EVENTS = {
  CART_UPDATED: "cart:updated",     // detail: { itemCount: Number, total: Number }
  FORM_SUBMITTED: "form:submitted", // detail: { id: String, success: Boolean }
  MODAL_CLOSED: "modal:closed"      // detail: { reason: "backdrop" | "button" | "escape" }
}
```

```javascript
import { EVENTS } from "../events"

// Sender
this.dispatch("updated", {
  detail: { itemCount: this.items.length, total: this.totalValue },
  prefix: "cart"
})

// Receiver in HTML
// data-action="cart:updated->header#refreshBadge"
```
