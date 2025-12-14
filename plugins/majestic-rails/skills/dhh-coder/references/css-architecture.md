# Native CSS Architecture

Modern CSS patterns from 37signals - no preprocessors, no build complexity. Uses native CSS features: layers, nesting, custom properties, and OKLCH colors.

## Philosophy

- **No Sass/Less**: Native CSS has caught up
- **No Tailwind**: Utility classes in HTML are fine, but semantic CSS scales better for apps
- **Layers for specificity**: Predictable cascade, no `!important` wars
- **OKLCH for colors**: Perceptually uniform, better for programmatic manipulation
- **CSS nesting**: Scoped styles without BEM naming

## CSS Layers

Layers control specificity cascade. Later layers override earlier ones.

```css
/* app/assets/stylesheets/application.css */

/* Define layer order - this controls cascade priority */
@layer reset, base, components, utilities;

/* Reset layer - lowest priority */
@layer reset {
  *, *::before, *::after {
    box-sizing: border-box;
  }

  body {
    margin: 0;
    line-height: 1.5;
  }
}

/* Base layer - typography, colors */
@layer base {
  :root {
    --color-primary: oklch(55% 0.15 250);
    --color-text: oklch(20% 0.02 250);
    --color-bg: oklch(98% 0.01 250);
    --radius: 0.5rem;
    --shadow: 0 1px 3px oklch(0% 0 0 / 0.1);
  }

  body {
    font-family: system-ui, sans-serif;
    color: var(--color-text);
    background: var(--color-bg);
  }

  a {
    color: var(--color-primary);
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
}

/* Components layer - reusable UI patterns */
@layer components {
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: var(--radius);
    font-weight: 500;
    cursor: pointer;
    transition: background 0.15s;

    &.btn--primary {
      background: var(--color-primary);
      color: white;

      &:hover {
        background: oklch(from var(--color-primary) calc(l - 0.1) c h);
      }
    }

    &.btn--secondary {
      background: transparent;
      border: 1px solid currentColor;

      &:hover {
        background: oklch(0% 0 0 / 0.05);
      }
    }
  }

  .card {
    background: white;
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 1.5rem;
  }
}

/* Utilities layer - highest priority, single-purpose */
@layer utilities {
  .hidden { display: none; }
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
  }
  .truncate {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}
```

## OKLCH Color System

OKLCH provides perceptually uniform colors - adjusting lightness/chroma produces predictable results.

```css
:root {
  /* Primary palette - adjust lightness for variants */
  --primary-50:  oklch(97% 0.02 250);
  --primary-100: oklch(94% 0.04 250);
  --primary-200: oklch(88% 0.08 250);
  --primary-300: oklch(78% 0.12 250);
  --primary-400: oklch(65% 0.15 250);
  --primary-500: oklch(55% 0.15 250);  /* Base */
  --primary-600: oklch(48% 0.14 250);
  --primary-700: oklch(40% 0.12 250);
  --primary-800: oklch(33% 0.10 250);
  --primary-900: oklch(25% 0.08 250);

  /* Semantic colors */
  --color-success: oklch(65% 0.18 145);
  --color-warning: oklch(75% 0.15 85);
  --color-error:   oklch(55% 0.20 25);

  /* Neutral scale - near-zero chroma for grays */
  --gray-50:  oklch(98% 0.005 250);
  --gray-100: oklch(96% 0.005 250);
  --gray-200: oklch(92% 0.005 250);
  --gray-300: oklch(85% 0.005 250);
  --gray-400: oklch(70% 0.005 250);
  --gray-500: oklch(55% 0.005 250);
  --gray-600: oklch(45% 0.005 250);
  --gray-700: oklch(35% 0.005 250);
  --gray-800: oklch(25% 0.005 250);
  --gray-900: oklch(15% 0.005 250);
}
```

### OKLCH Explained

```css
/* oklch(lightness chroma hue / alpha) */

/* Lightness: 0% = black, 100% = white */
/* Chroma: 0 = gray, 0.4+ = vivid */
/* Hue: 0-360 degrees on color wheel */
/*   0/360 = red
/*   60 = yellow
/*   120 = green
/*   180 = cyan
/*   240 = blue
/*   300 = magenta */

/* Alpha is optional */
background: oklch(55% 0.15 250);           /* solid */
background: oklch(55% 0.15 250 / 0.5);     /* 50% transparent */
```

### Programmatic Color Manipulation

```css
/* Relative color syntax - derive colors from base */
.btn-hover {
  /* 10% darker than primary */
  background: oklch(from var(--primary-500) calc(l - 0.1) c h);
}

.btn-disabled {
  /* Desaturated version */
  background: oklch(from var(--primary-500) l 0.02 h);
}

.overlay {
  /* Black with 50% opacity */
  background: oklch(0% 0 0 / 0.5);
}
```

## CSS Nesting

Native CSS nesting replaces Sass nesting. Scopes styles without BEM.

```css
/* Component with nested states and elements */
.message {
  padding: 1rem;
  border-radius: var(--radius);
  background: white;

  /* Nested element */
  & .message__header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.5rem;
  }

  & .message__body {
    line-height: 1.6;
  }

  & .message__time {
    color: var(--gray-500);
    font-size: 0.875rem;
  }

  /* State modifiers */
  &.is-highlighted {
    background: var(--primary-50);
    border-left: 3px solid var(--primary-500);
  }

  &.is-unread {
    font-weight: 600;
  }

  /* Pseudo-classes */
  &:hover {
    box-shadow: var(--shadow);
  }

  /* Media queries nested inside component */
  @media (max-width: 640px) {
    padding: 0.75rem;

    & .message__header {
      flex-direction: column;
    }
  }
}
```

## Dark Mode

Use CSS custom properties with `prefers-color-scheme`.

```css
:root {
  /* Light mode (default) */
  --color-bg: oklch(98% 0.01 250);
  --color-surface: white;
  --color-text: oklch(20% 0.02 250);
  --color-text-muted: oklch(45% 0.02 250);
  --color-border: oklch(90% 0.01 250);
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: oklch(15% 0.02 250);
    --color-surface: oklch(20% 0.02 250);
    --color-text: oklch(92% 0.01 250);
    --color-text-muted: oklch(65% 0.01 250);
    --color-border: oklch(30% 0.02 250);
  }
}

/* Components use semantic variables - auto dark mode */
.card {
  background: var(--color-surface);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}
```

### Manual Dark Mode Toggle

```css
/* Support both system preference and manual toggle */
:root {
  color-scheme: light dark;
}

/* System preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-bg: oklch(15% 0.02 250);
    /* ... dark values ... */
  }
}

/* Manual override */
[data-theme="dark"] {
  --color-bg: oklch(15% 0.02 250);
  /* ... dark values ... */
}

[data-theme="light"] {
  --color-bg: oklch(98% 0.01 250);
  /* ... light values ... */
}
```

```erb
<%# Toggle in layout %>
<html data-theme="<%= current_user&.theme || 'system' %>">
```

## File Organization

```
app/assets/stylesheets/
├── application.css          # @layer definitions, imports
├── reset.css                # CSS reset
├── base.css                 # Typography, colors, variables
├── components/
│   ├── buttons.css
│   ├── cards.css
│   ├── forms.css
│   └── navigation.css
└── utilities.css            # Single-purpose helpers
```

```css
/* application.css */
@layer reset, base, components, utilities;

@import "reset.css" layer(reset);
@import "base.css" layer(base);
@import "components/buttons.css" layer(components);
@import "components/cards.css" layer(components);
@import "components/forms.css" layer(components);
@import "utilities.css" layer(utilities);
```

## Animation Patterns

```css
/* Reusable animation custom properties */
:root {
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-in-out: cubic-bezier(0.45, 0, 0.55, 1);
  --duration-fast: 150ms;
  --duration-normal: 300ms;
}

/* Flash message appear and fade */
@keyframes appear-then-fade {
  0% {
    opacity: 0;
    transform: translateY(-0.5rem);
  }
  10% {
    opacity: 1;
    transform: translateY(0);
  }
  90% {
    opacity: 1;
    transform: translateY(0);
  }
  100% {
    opacity: 0;
    transform: translateY(-0.5rem);
  }
}

.flash {
  animation: appear-then-fade 5s var(--ease-out) forwards;
}

/* Skeleton loading pulse */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.skeleton {
  animation: pulse 2s var(--ease-in-out) infinite;
  background: var(--gray-200);
  border-radius: var(--radius);
}
```

## Form Styling

```css
@layer components {
  .form-input {
    display: block;
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius);
    font: inherit;
    transition: border-color var(--duration-fast);

    &:focus {
      outline: none;
      border-color: var(--primary-500);
      box-shadow: 0 0 0 3px oklch(from var(--primary-500) l c h / 0.2);
    }

    &:invalid:not(:placeholder-shown) {
      border-color: var(--color-error);
    }

    &::placeholder {
      color: var(--color-text-muted);
    }
  }

  .form-label {
    display: block;
    margin-bottom: 0.25rem;
    font-weight: 500;
    font-size: 0.875rem;
  }

  .form-error {
    color: var(--color-error);
    font-size: 0.875rem;
    margin-top: 0.25rem;
  }

  .form-group {
    margin-bottom: 1rem;

    &.has-error {
      & .form-input {
        border-color: var(--color-error);
      }
    }
  }
}
```
