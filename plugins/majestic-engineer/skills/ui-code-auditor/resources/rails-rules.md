# Rails-Specific UI Audit Rules

Patterns specific to Rails views, ERB templates, and Hotwire.

## ERB Templates

### Critical

| Pattern | Issue | Fix |
|---------|-------|-----|
| `image_tag` without `alt:` | Missing alt text | Add `alt: "description"` |
| `link_to` with only icon/image | Link without accessible name | Add text or `aria-label:` |
| `button_tag` with only icon | Button without accessible name | Add text or `aria-label:` |

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `form_with` without visible submit | No implicit submission | Add submit button |
| `text_field` without `label` | Orphan input | Use `label` helper or `aria-label` |

## Hotwire/Turbo

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `turbo-frame` replacing content without ARIA | Screen reader not notified | Add `aria-live="polite"` or `aria-busy` |
| `turbo-stream` append/prepend without announcement | Dynamic content invisible to a11y | Use `aria-live` region |

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `data-turbo-permanent` on focusable element | Focus may be lost on navigation | Ensure focus management |

## Stimulus Controllers

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `show`/`hide` controller without focus management | Focus lost when hiding | Move focus to appropriate element |
| Modal controller without focus trap | Focus escapes modal | Implement focus trapping |

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `toggle` controller without `aria-expanded` | State not announced | Update `aria-expanded` attribute |
| Dropdown controller without `aria-haspopup` | Menu not announced | Add `aria-haspopup="menu"` |

## View Components

### Recommendations

| Pattern | Suggestion |
|---------|------------|
| Custom modal partial | Consider ViewComponent with built-in a11y |
| Custom dropdown partial | Consider accessible dropdown component |
| Custom tabs partial | Ensure ARIA tab pattern or use component |
