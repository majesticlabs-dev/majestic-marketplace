# Generic UI Audit Rules

Universal patterns that apply to all web frameworks.

## Accessibility (WCAG 2.1)

### Critical (Verdict: FAIL if found)

| Pattern | Grep Pattern | Issue | Fix |
|---------|--------------|-------|-----|
| Image without alt | `<img[^>]*(?!alt=)[^>]*>` | Missing alt text | Add `alt="description"` or `alt=""` for decorative |
| Button without accessible name | `<button[^>]*>\s*<(?:svg\|img\|i\s)` | Icon button missing label | Add `aria-label` |
| Link without content | `<a[^>]*>\s*</a>` | Empty link | Add text or `aria-label` |
| Input without label | `<input(?![^>]*aria-label)(?![^>]*id=)` | Orphan input | Add `<label for>` or `aria-label` |
| Non-semantic button | `<div[^>]*onClick` or `<span[^>]*onClick` | DIV/SPAN as button | Use `<button>` element |

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `tabindex="[1-9]"` | Disrupts natural tab order | Use `tabindex="0"` or remove |
| `outline:\s*none` without alternative | Removes focus indicator | Add custom `:focus-visible` style |
| `aria-hidden="true"` on focusable | Hidden but keyboard-reachable | Remove `aria-hidden` or make unfocusable |

## Touch Targets

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `class="[^"]*w-4[^"]*h-4[^"]*"` on interactive | Touch target 16px (< 44px) | Use `min-w-11 min-h-11` (44px) |
| `class="[^"]*w-5[^"]*h-5[^"]*"` on interactive | Touch target 20px (< 44px) | Use `min-w-11 min-h-11` |
| `class="[^"]*w-6[^"]*h-6[^"]*"` on interactive | Touch target 24px (< 44px) | Use `min-w-11 min-h-11` |

## Animation Patterns

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `@keyframes` without `prefers-reduced-motion` | No reduced-motion support | Add `@media (prefers-reduced-motion)` |
| `animate-` class without reduced-motion check | Animation ignores preference | Wrap in reduced-motion media query |

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `animation:.*width` or `animation:.*height` | Layout-triggering animation | Use `transform: scale()` instead |
| `transition:.*width` or `transition:.*height` | Layout-triggering transition | Use `transform: scale()` |
| `will-change:` (more than 3 occurrences) | Excessive will-change | Only use on elements that will animate |

## Form Patterns

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `<form` without `<button type="submit"` | No implicit submission | Add submit button (can be visually hidden) |
| `type="password"` without `autocomplete` | Password manager incompatible | Add `autocomplete="current-password"` |

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `<input type="text"` for email | Wrong keyboard on mobile | Use `type="email"` |
| `<input type="text"` for phone | Wrong keyboard on mobile | Use `type="tel"` |

## Performance Patterns

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `<img` without `loading="lazy"` (below fold) | Eager loading | Add `loading="lazy"` for below-fold images |
| Inline SVG > 50 lines | Large inline SVG | Move to sprite or external file |

## Color/Contrast

### Serious (if detectable)

| Pattern | Issue | Fix |
|---------|-------|-----|
| `text-gray-400` on `bg-white` | Low contrast (~2.5:1) | Use `text-gray-600` or darker |
| `text-gray-500` on `bg-gray-100` | Low contrast | Increase contrast ratio |
