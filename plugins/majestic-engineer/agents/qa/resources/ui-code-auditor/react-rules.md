# React-Specific UI Audit Rules

Patterns specific to React/JSX codebases.

## Accessibility

### Critical

| Pattern | Issue | Fix |
|---------|-------|-----|
| `onClick` without `onKeyDown`/`onKeyUp` on non-button | Click-only handler | Use `<button>` or add keyboard handler |
| `<div onClick` or `<span onClick` | Non-semantic interactive | Use `<button>` element |
| `role="button"` without `tabIndex` | Not keyboard-focusable | Add `tabIndex={0}` |

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `useEffect` with focus management but no cleanup | Focus not restored | Return cleanup function to restore focus |
| `dangerouslySetInnerHTML` with user content | XSS risk, a11y unknown | Sanitize and ensure accessible structure |

## Component Library Detection

### Recommendations (not violations)

When detecting custom implementations, suggest accessible alternatives:

| Custom Pattern | Suggested Library |
|----------------|-------------------|
| Custom dropdown/select | Radix `Select`, React Aria `useSelect` |
| Custom modal/dialog | Radix `Dialog`, React Aria `useDialog` |
| Custom tabs | Radix `Tabs`, React Aria `useTabs` |
| Custom tooltip | Radix `Tooltip`, React Aria `useTooltip` |
| Custom combobox | Radix `Combobox`, React Aria `useComboBox` |

## List Rendering

### Moderate

| Pattern | Issue | Fix |
|---------|-------|-----|
| `.map()` without `key` prop | Missing key causes a11y issues | Add unique `key` prop |
| `key={index}` on dynamic list | Index as key breaks state | Use stable unique ID |

## Event Handlers

### Serious

| Pattern | Issue | Fix |
|---------|-------|-----|
| `onMouseEnter`/`onMouseLeave` for essential UI | Mouse-only interaction | Also handle `onFocus`/`onBlur` |
| `onDoubleClick` for primary action | No keyboard equivalent | Add keyboard shortcut or button |
