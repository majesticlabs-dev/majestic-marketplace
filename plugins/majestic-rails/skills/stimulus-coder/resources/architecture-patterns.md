# Architecture Patterns for Stimulus

## SOLID Principles Applied to Stimulus

### Single Responsibility Principle

Each controller has one reason to change. Split controllers that mix concerns.

```javascript
// Bad: "page controller" doing everything
export default class extends Controller {
  openModal() { /* modal logic */ }
  submitForm() { /* form logic */ }
  filterTable() { /* table logic */ }
}

// Good: separate controllers
// modal_controller.js, form_controller.js, filter_controller.js
```

Compose in HTML:
```erb
<div data-controller="modal form filter">
  <button data-action="modal#open">Open</button>
  <form data-action="submit->form#handle">...</form>
  <input data-action="input->filter#apply">
</div>
```

### Open-Closed Principle

Extend through configuration, not modification. Use values and classes to vary behavior without changing controller code.

```javascript
// Base notification controller
export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }
  static classes = ["enter", "leave"]

  connect() {
    this.element.classList.add(this.enterClass)
    this.timeout = setTimeout(() => this.dismiss(), this.durationValue)
  }

  dismiss() {
    this.element.classList.replace(this.enterClass, this.leaveClass)
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}
```

```erb
<%# Success variant - no controller change needed %>
<div data-controller="notification"
     data-notification-duration-value="3000"
     data-notification-enter-class="slide-in-right"
     data-notification-leave-class="fade-out">

<%# Error variant - same controller, different config %>
<div data-controller="notification"
     data-notification-duration-value="10000"
     data-notification-enter-class="shake-in"
     data-notification-leave-class="slide-out-left">
```

### Dependency Inversion Principle

Controllers depend on abstractions (data attributes) not concrete implementations.

```javascript
// Controller doesn't know which search API is used
export default class extends Controller {
  static values = { url: String, method: { type: String, default: "GET" } }

  async search() {
    const response = await fetch(this.urlValue, { method: this.methodValue })
    this.dispatch("results", { detail: await response.json() })
  }
}
```

```erb
<%# Google search %>
<div data-controller="search" data-search-url-value="/api/google/search">

<%# Algolia search %>
<div data-controller="search" data-search-url-value="/api/algolia/search">
```

The search controller never changes. Provider switching happens in HTML.

## Application Controller

Shared base for cross-cutting concerns. Use sparingly.

```javascript
// app/javascript/controllers/application_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dispatch(name, detail = {}) {
    return super.dispatch(name, { detail, bubbles: true })
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
```

Before adding to ApplicationController, ask:
- Does every controller need this? → ApplicationController
- Do some controllers need this? → Mixin
- Does one controller need this? → Keep it local

## Mixin Pattern

Share behavior across unrelated controllers without inheritance.

```javascript
// mixins/debounce.js
export const Debounce = (controller) => {
  Object.assign(controller.prototype, {
    debounce(fn, wait = 300) {
      clearTimeout(this._debounceTimer)
      this._debounceTimer = setTimeout(() => fn.call(this), wait)
    }
  })
}

// Usage
import { Debounce } from "../mixins/debounce"

class SearchController extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  update() {
    this.debounce(() => this.performSearch(), this.delayValue)
  }
}

Debounce(SearchController)
export default SearchController
```

## Targetless Controllers

When a controller operates only on `this.element` without targets, keep it targetless. This makes it composable on any element.

```javascript
// Works on any element without target declarations
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) this.load() },
      { threshold: 0.1 }
    )
    this.observer.observe(this.element)
  }

  disconnect() { this.observer?.disconnect() }

  async load() {
    this.observer.disconnect()
    const response = await fetch(this.urlValue, { headers: { Accept: "text/html" } })
    this.element.outerHTML = await response.text()
  }
}
```

If a controller uses both `this.element` behavior and targets, consider splitting into two controllers that communicate via events.

## Namespaced Attributes

For dynamic configuration sets where predefined values are too rigid:

```javascript
export default class extends Controller {
  static values = { prefix: { type: String, default: "chart" } }

  get options() {
    const prefix = this.prefixValue
    return Object.fromEntries(
      Object.entries(this.element.dataset)
        .filter(([key]) => key.startsWith(prefix) && key !== `${prefix}Prefix`)
        .map(([key, val]) => [
          key.slice(prefix.length).replace(/^./, c => c.toLowerCase()),
          this.#coerce(val)
        ])
    )
  }

  #coerce(val) {
    if (val === "true") return true
    if (val === "false") return false
    if (!isNaN(val) && val !== "") return Number(val)
    return val
  }
}
```

```erb
<canvas data-controller="chart"
        data-chart-type="bar"
        data-chart-stacked="true"
        data-chart-max-y="100"
        data-chart-animation-duration="500">
```

All `data-chart-*` attributes become `{ type: "bar", stacked: true, maxY: 100, animationDuration: 500 }` without declaring each as a static value.
