---
name: frontend-performance
description: Use when modifying layouts, adding assets, or optimizing page speed. Frontend performance patterns for Core Web Vitals (LCP, CLS, INP). Covers font loading, resource preloading, asset scoping, and render-blocking elimination. Not for backend performance — use performance-reviewer instead.
---

# Frontend Performance

**Audience:** Developers modifying layouts, adding assets, or optimizing page load
**Goal:** Prevent performance regressions and improve Core Web Vitals

## Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5s - 4.0s | > 4.0s |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1 - 0.25 | > 0.25 |
| INP (Interaction to Next Paint) | < 200ms | 200ms - 500ms | > 500ms |

## Font Loading

Font swap causes CLS. Preload critical fonts before stylesheets.

### Correct Order in `<head>`

```html
<!-- 1. Preload critical fonts FIRST -->
<link rel="preload" href="/fonts/inter-400.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="/fonts/inter-700.woff2" as="font" type="font/woff2" crossorigin>

<!-- 2. Stylesheet AFTER preloads -->
<link rel="stylesheet" href="/application.css">
```

### Rules

- Only preload fonts used above the fold
- Secondary variants (italic, light, extra-bold) stay lazy-loaded
- Always include `crossorigin` on font preloads (even same-origin)
- Keep `font-display: swap` on all `@font-face` declarations

### @font-face Pattern

```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/inter-400.woff2") format("woff2");
  font-weight: 400;
  font-display: swap;
}
```

## Asset Scoping

Before adding any asset (JS, CSS, font) to a shared layout, ask:

> "Is this needed on every page or only a subset?"

### Decision Table

| Scope | Where to Load |
|-------|---------------|
| Every page (navigation, auth) | Application layout `<head>` |
| Admin pages only | Admin layout |
| Single page/feature | Page-specific partial or controller |
| Below the fold | Lazy load or defer |

### Render-Blocking Resources

Resources in `<head>` directly impact LCP. Minimize what loads globally.

```html
<!-- Render-blocking (delays LCP) -->
<link rel="stylesheet" href="/admin-charts.css">

<!-- Non-blocking alternatives -->
<link rel="stylesheet" href="/admin-charts.css" media="print" onload="this.media='all'">
<link rel="preload" href="/admin-charts.css" as="style" onload="this.rel='stylesheet'">
```

### Script Loading

```html
<!-- Blocks rendering — avoid in <head> -->
<script src="/heavy-lib.js"></script>

<!-- Non-blocking alternatives -->
<script src="/heavy-lib.js" defer></script>
<script src="/heavy-lib.js" async></script>
```

| Attribute | When to Use |
|-----------|-------------|
| `defer` | Depends on DOM, order matters (default choice) |
| `async` | Independent script, order doesn't matter (analytics, tracking) |
| None | Must execute before render (rare, avoid) |

## Image Optimization

Images are the most common LCP element.

| Technique | Impact |
|-----------|--------|
| `loading="lazy"` on below-fold images | Reduces initial payload |
| `fetchpriority="high"` on LCP image | Prioritizes hero/banner loading |
| Explicit `width` and `height` attributes | Prevents CLS from layout reflow |
| `decoding="async"` | Avoids blocking main thread |

```html
<!-- Hero image (LCP candidate) -->
<img src="/hero.webp" width="1200" height="600"
     fetchpriority="high" decoding="async"
     alt="Product screenshot">

<!-- Below-fold image -->
<img src="/feature.webp" width="800" height="400"
     loading="lazy" decoding="async"
     alt="Feature detail">
```

## CLS Prevention Checklist

| Cause | Fix |
|-------|-----|
| Images without dimensions | Add `width` and `height` attributes |
| Font swap flash | Preload critical fonts, use `font-display: swap` |
| Dynamically injected content above viewport | Reserve space with min-height or aspect-ratio |
| Ads/embeds without reserved space | Use `aspect-ratio` container or fixed dimensions |
| Late-loading CSS shifting layout | Inline critical CSS or preload stylesheet |

## Audit Patterns

When reviewing code for frontend performance:

```
For each file in layouts/:
  Check <head> for render-blocking resources
  Check font preload order (before stylesheets?)
  Count globally-loaded assets — flag if > 5 CSS or > 3 JS

For each new asset addition:
  Verify scoped to narrowest layout
  Verify not duplicated across entrypoints

For each image tag:
  Above fold? → needs fetchpriority="high", explicit dimensions
  Below fold? → needs loading="lazy"
  All images → need width, height, alt, decoding="async"
```
