# Web Interface Standards

Production-grade interaction and performance constraints for accessible, performant web interfaces.

> **Complements:** `ui-implementation-guide.md` (typography, color, forms), `motion-patterns.md` (animation timing), `css-polish-tips.md` (debugging)

---

## Keyboard Operability

All interactive elements must be keyboard-accessible:

| Requirement | Implementation |
|-------------|----------------|
| Tab order follows visual flow | Use semantic HTML, avoid `tabindex > 0` |
| Focus visible on all interactives | `:focus-visible` with 3:1 contrast |
| Escape closes overlays | Modal, dropdown, tooltip dismissal |
| Enter/Space activates buttons | Native `<button>` provides this |
| Arrow keys navigate composites | Radios, tabs, menus, listboxes |

### WAI-ARIA Widget Patterns

For custom widgets, follow [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/):

| Widget | Required Patterns |
|--------|-------------------|
| Modal dialog | Focus trap, `role="dialog"`, `aria-modal="true"` |
| Dropdown menu | `role="menu"`, arrow navigation, `aria-expanded` |
| Tabs | `role="tablist/tab/tabpanel"`, arrow keys between tabs |
| Combobox | `role="combobox"`, `aria-autocomplete`, live region |
| Accordion | `aria-expanded`, `aria-controls`, optional auto-collapse |

### Focus Management

```javascript
// After opening modal
dialogElement.focus();

// After closing modal - return focus to trigger
triggerElement.focus();

// After route change in SPA
document.querySelector('main').focus();
```

---

## Touch Targets

| Context | Minimum Size | Rationale |
|---------|--------------|-----------|
| Desktop | 24×24px | Mouse precision allows smaller targets |
| Mobile | 44×44px | Finger tap area requires larger targets |
| Spacing | 8px between | Prevent accidental adjacent taps |

**Visual bounds = interactive bounds:**
- Don't make hit area larger than visual element
- Users expect clicks outside visual bounds to do nothing

**Tailwind enforcement:**
```html
<!-- Mobile-friendly touch target -->
<button class="min-h-[44px] min-w-[44px] p-3">
  <IconSmall class="w-5 h-5" />
</button>
```

---

## Animation Accessibility

### prefers-reduced-motion (REQUIRED)

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### Animation Requirements

| Rule | Reason |
|------|--------|
| No autoplay that can't be paused | WCAG 2.2.2 |
| Animation < 5 seconds or user-controllable | WCAG 2.2.2 |
| No flashing > 3 times/second | WCAG 2.3.1 (seizure risk) |
| Provide pause/stop for moving content | WCAG 2.2.2 |

---

## Form Behavior

### Implicit Submission (REQUIRED)

Forms must submit when user presses Enter in a text field:

```html
<!-- Correct: Has submit button, Enter works -->
<form>
  <input type="text" name="search" />
  <button type="submit">Search</button>
</form>

<!-- Also correct: Hidden submit enables Enter -->
<form>
  <input type="text" name="search" />
  <button type="submit" class="sr-only">Submit</button>
  <button type="button" onclick="customSubmit()">Search</button>
</form>
```

### Password Manager Compatibility

| Field | autocomplete Value |
|-------|-------------------|
| Username/email | `username` or `email` |
| Current password | `current-password` |
| New password | `new-password` |
| One-time code | `one-time-code` |
| Credit card | `cc-number`, `cc-exp`, `cc-csc` |

```html
<input type="email" autocomplete="email" />
<input type="password" autocomplete="current-password" />
```

### Mobile Keyboard Optimization

| Data Type | input type | Keyboard |
|-----------|------------|----------|
| Email | `email` | @ symbol prominent |
| Phone | `tel` | Numeric pad |
| URL | `url` | .com shortcut |
| Number | `inputmode="numeric"` | Number pad (use for codes, not quantities) |
| Search | `search` | Search icon on keyboard |

---

## Network Performance Budgets

| Operation | Target | Measurement |
|-----------|--------|-------------|
| POST/PATCH/DELETE | < 500ms perceived | Time to success feedback |
| Page navigation | < 1s perceived | Largest Contentful Paint |
| Time to Interactive | < 3.8s | Mobile 4G baseline |
| First Input Delay | < 100ms | User can interact |

### List Virtualization

**Required when:** List > 100 items OR item render > 10ms

```jsx
// React with react-window
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={400}
  itemCount={items.length}
  itemSize={50}
>
  {({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  )}
</FixedSizeList>
```

### Resource Hints

```html
<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://api.example.com" />
<link rel="preconnect" href="https://fonts.googleapis.com" crossorigin />

<!-- Prefetch next likely navigation -->
<link rel="prefetch" href="/dashboard" />

<!-- Preload critical resources -->
<link rel="preload" href="/fonts/Inter.woff2" as="font" type="font/woff2" crossorigin />
```

---

## Copywriting for UI

### Button Labels

| Pattern | Example | Why |
|---------|---------|-----|
| Verb + noun | "Save changes" | Clear action |
| Specific action | "Send invitation" | Not generic "Submit" |
| Consequences clear | "Delete account" | User understands impact |

**Avoid:**
- "Submit" (generic)
- "Click here" (no context)
- "OK" / "Cancel" (ambiguous)

### Error Messages

| Component | Content |
|-----------|---------|
| What happened | "Email address is invalid" |
| How to fix | "Enter an email like name@example.com" |

```html
<div role="alert" class="text-error">
  <strong>Email address is invalid.</strong>
  Enter an email like name@example.com.
</div>
```

### Confirmation Dialogs

| Pattern | Example |
|---------|---------|
| Action-specific title | "Delete this project?" not "Are you sure?" |
| Consequences stated | "This will permanently delete 24 files." |
| Primary = destructive | "Delete project" button, not "Yes" |
| Secondary = safe | "Keep project" or "Cancel" |

---

## Checklist

Before shipping, verify:

- [ ] All interactive elements keyboard-accessible
- [ ] Focus indicators visible (3:1 contrast)
- [ ] Touch targets ≥ 44px on mobile
- [ ] `prefers-reduced-motion` honored
- [ ] Forms submit on Enter
- [ ] `autocomplete` attributes set for credentials
- [ ] Network operations < 500ms perceived
- [ ] Lists > 100 items virtualized
- [ ] Error messages include resolution guidance
