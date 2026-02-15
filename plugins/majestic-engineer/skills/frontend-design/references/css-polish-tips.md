# CSS Polish Tips

Quick wins for accessibility, scroll behavior, and debugging.

## Accessibility Debugging

Highlight problems during development:

```css
/* Images missing alt text */
img:not([alt]) {
  border: 5px solid red;
}

/* Empty alt (decorative) vs missing alt */
img:not([alt]) { outline: 5px solid red; }      /* Missing - bad */
img[alt=""] { outline: 5px solid orange; }      /* Empty - intentional decorative */

/* Links without accessible text */
a:not([aria-label]):empty {
  outline: 3px solid red;
}

/* Buttons without accessible names */
button:not([aria-label]):empty {
  outline: 3px solid red;
}

/* Form inputs without labels */
input:not([id]):not([aria-label]) {
  outline: 3px solid red;
}
```

## Scroll Behavior

Essential scroll polish for any site:

```css
html {
  /* Account for fixed headers on anchor jumps */
  scroll-padding-top: var(--header-height, 80px);

  /* Prevent scroll chaining (bounce at boundaries) */
  overscroll-behavior: none;

  /* Smooth anchor navigation */
  scroll-behavior: smooth;
}

/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
```

## Focus & Selection

```css
/* Better focus visibility */
:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

/* Remove outline for mouse users */
:focus:not(:focus-visible) {
  outline: none;
}

/* Custom text selection */
::selection {
  background: var(--color-accent);
  color: var(--color-bg);
}
```

## Performance Hints

```css
/* Hint browser about expensive animations */
.will-animate {
  will-change: transform, opacity;
}

/* Contain layout recalculations */
.card {
  contain: layout style paint;
}

/* Hardware acceleration for smooth animations */
.smooth-transform {
  transform: translateZ(0);
}
```

## Defensive CSS

```css
/* Prevent image overflow */
img {
  max-width: 100%;
  height: auto;
}

/* Prevent long words breaking layout */
.text-content {
  overflow-wrap: break-word;
  word-break: break-word;
}

/* Flexbox gap fallback detection */
@supports not (gap: 1rem) {
  .flex-container > * + * {
    margin-left: 1rem;
  }
}
```

## Dark Mode Helpers

```css
/* System preference detection */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #0a0a0a;
    --color-fg: #fafafa;
  }
}

/* Invert images that don't have dark variants */
@media (prefers-color-scheme: dark) {
  img.invertible {
    filter: invert(1) hue-rotate(180deg);
  }
}
```
