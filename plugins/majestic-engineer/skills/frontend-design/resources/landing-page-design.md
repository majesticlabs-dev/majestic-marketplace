# Landing Page Visual Design

Visual design principles for high-converting, award-worthy landing pages. Complements `landing-page-builder` skill (copy) with implementation guidance.

## Pre-Code Checklist

Before writing any code, explicitly decide:

1. **Aesthetic direction** — Pick one from `frontend-design` skill (brutalist, luxury, retro-futuristic, etc.)
2. **Font pairing** — One display font, one body font (see Typography Pairings below)
3. **Color palette** — Maximum 5 hex values (bg, text, muted, accent, accent-muted)
4. **Hero hook** — One interactive element that makes the page memorable
5. **Company context** — Generate realistic placeholder content, never lorem ipsum

State these decisions explicitly before implementation. This prevents generic output.

---

## Section-by-Section Design

### 1. Hero Section

**Visual hierarchy:**

| Element | Treatment |
|---------|-----------|
| Headline | Largest text, display font, high contrast |
| Subheadline | 60% headline size, muted color |
| CTA | Bold accent color, generous padding |
| Trust signals | Small, grouped, subtle |

**Interactive hook ideas:**

- **Live demo preview**: Embedded product interaction
- **Cursor-following effect**: Subtle parallax on hero image
- **Typing animation**: Dynamic headline reveal
- **Counter/stat**: Animated numbers on scroll

**Hero layout patterns:**

```
┌──────────────────────────────────────┐
│  [Logo]                    [Nav CTA] │
├──────────────────────────────────────┤
│                                      │
│   HEADLINE                           │
│   Subtext goes here                  │
│                                      │
│   [Primary CTA]  [Secondary]         │
│                                      │
│   ○ ○ ○ ○ ○  Trust logos             │
└──────────────────────────────────────┘

Alternative: Split layout
┌─────────────────┬────────────────────┐
│                 │                    │
│  HEADLINE       │    [Product        │
│  Subtext        │     Visual]        │
│                 │                    │
│  [CTA]          │                    │
└─────────────────┴────────────────────┘
```

---

### 2. Problem/Solution Narrative

**Scroll-triggered storytelling:**

- Reveal problem statements one at a time
- Use parallax for depth on background elements
- Animate stats/numbers when they enter viewport

**Visual techniques:**

| Technique | Implementation |
|-----------|----------------|
| Before/After | Split view with slider |
| Pain visualization | Dark imagery → bright solution |
| Timeline | Horizontal scroll or sticky sections |
| Scenario cards | Hover-reveal expanded content |

---

### 3. Product Showcase

**Demo preview patterns:**

```css
.product-frame {
  background: linear-gradient(135deg, #1a1a2e 0%, #0a0a0f 100%);
  border-radius: 16px;
  padding: 24px;
  box-shadow:
    0 0 0 1px rgba(255, 255, 255, 0.1),
    0 20px 40px rgba(0, 0, 0, 0.4);
}

.product-screen {
  border-radius: 8px;
  overflow: hidden;
  position: relative;
}

/* Reflection effect */
.product-screen::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.1) 0%,
    transparent 50%
  );
  pointer-events: none;
}
```

**Technical credibility indicators:**

- Code snippets with syntax highlighting
- API response examples
- Architecture diagrams
- Performance metrics badges

---

### 4. Social Proof Section

**Testimonial card pattern:**

```css
.testimonial {
  display: grid;
  gap: 16px;
  padding: 32px;
  background: var(--surface-elevated);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.testimonial-quote {
  font-size: 1.125rem;
  line-height: 1.6;
  font-style: italic;
}

.testimonial-author {
  display: flex;
  align-items: center;
  gap: 12px;
}

.testimonial-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}
```

**Customer grid with hover states:**

- 4-6 logos in row
- Grayscale by default, color on hover
- Subtle scale transform on hover

```css
.customer-logo {
  filter: grayscale(1) opacity(0.6);
  transition: filter 0.3s, transform 0.3s;
}

.customer-logo:hover {
  filter: grayscale(0) opacity(1);
  transform: scale(1.05);
}
```

---

### 5. Feature/Differentiator Grid

**Comparison table styling:**

```css
.comparison-table {
  --border-color: rgba(255, 255, 255, 0.1);
}

.comparison-table th {
  text-align: left;
  padding: 16px;
  border-bottom: 2px solid var(--border-color);
  font-weight: 600;
}

.comparison-table td {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
}

/* Highlight "us" column */
.comparison-table td:nth-child(2) {
  background: rgba(var(--accent-rgb), 0.05);
}

/* Check/X icons */
.check { color: #22c55e; }
.cross { color: #ef4444; opacity: 0.5; }
```

---

### 6. Conversion Section

**Form styling for dark themes:**

```css
.form-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 14px 16px;
  color: #fff;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(var(--accent-rgb), 0.2);
}

.form-input::placeholder {
  color: rgba(255, 255, 255, 0.4);
}
```

**Urgency elements (use sparingly):**

| Element | When Appropriate |
|---------|------------------|
| Countdown timer | Genuine deadline (launch, sale end) |
| Limited spots | Real capacity constraint |
| Social proof toast | "X people viewing now" if true |

---

### 7. Footer

**Minimal, sophisticated:**

```css
.footer {
  padding: 64px 0 32px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.footer-links {
  display: flex;
  gap: 32px;
  flex-wrap: wrap;
}

.footer-link {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 0.875rem;
  transition: color 0.2s;
}

.footer-link:hover {
  color: #fff;
}
```

---

## Color Palettes by Aesthetic

### Dark Theme (Recommended for Tech)

```css
:root {
  --bg-primary: #0a0a0f;
  --bg-elevated: #12121a;
  --bg-surface: #1a1a24;
  --text-primary: #ffffff;
  --text-muted: #a0a0a0;
  --text-subtle: #666666;
  --accent: #00d4ff;        /* Electric cyan */
  --accent-muted: rgba(0, 212, 255, 0.15);
}
```

### Light Theme (Sophisticated)

```css
:root {
  --bg-primary: #faf9f7;    /* Warm off-white */
  --bg-elevated: #ffffff;
  --bg-surface: #f0eeeb;
  --text-primary: #1a1a1a;
  --text-muted: #666666;
  --text-subtle: #999999;
  --accent: #d35400;        /* Terracotta */
  --accent-muted: rgba(211, 84, 0, 0.1);
}
```

---

## Typography Pairings

| Aesthetic | Headlines | Body |
|-----------|-----------|------|
| **Tech/Modern** | Space Grotesk, Clash Display | Satoshi, General Sans |
| **Luxury** | Cormorant Garamond, Playfair Display | Source Serif Pro |
| **Brutalist** | JetBrains Mono, IBM Plex Mono | IBM Plex Mono |
| **Playful** | Fredoka, Quicksand | DM Sans |

**Google Fonts load example:**

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Satoshi:wght@400;500&display=swap" rel="stylesheet">
```

---

## Single-File Implementation

For self-contained landing pages:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Product Name</title>
  <link href="https://fonts.googleapis.com/css2?family=..." rel="stylesheet">
  <style>
    /* All CSS here - use CSS custom properties for theming */
    :root { /* colors, fonts, spacing */ }
    /* Component styles */
  </style>
</head>
<body>
  <!-- Semantic HTML5 structure -->
  <header>...</header>
  <main>
    <section id="hero">...</section>
    <section id="problem">...</section>
    <section id="solution">...</section>
    <section id="proof">...</section>
    <section id="cta">...</section>
  </main>
  <footer>...</footer>

  <script>
    // Intersection Observer for scroll reveals
    // Magnetic button effects
    // Form handling
  </script>
</body>
</html>
```

---

## Related Resources

- `motion-patterns.md` - Animation timing and implementation
- `ui-implementation-guide.md` - Form fields, buttons, typography constraints
- `landing-page-builder` skill (majestic-marketing) - Copy structure and messaging
