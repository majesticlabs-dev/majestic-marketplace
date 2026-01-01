---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, or applications. Includes framework-specific guidance for Tailwind, React, Vue, and Rails/Hotwire ecosystems.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
---

# Frontend Design

## Core Philosophy

### Design Thinking First

Before writing code, consider:

1. **Purpose**: What is this interface trying to achieve?
2. **Audience**: Who will use it and what are their expectations?
3. **Tone**: What feeling should it evoke?
4. **Differentiation**: What makes this distinctive?

### Pick an Extreme

Rather than defaulting to safe, generic designs, commit to a clear aesthetic direction:

- **Brutalist**: Raw, honest, utilitarian
- **Maximalist**: Bold, layered, expressive
- **Minimalist**: Restrained, precise, essential
- **Retro-futuristic**: Nostalgic tech, neon, gradients
- **Luxury**: Refined, spacious, premium
- **Playful**: Animated, colorful, delightful

### Avoid "AI Slop"

Generic AI-generated aesthetics are immediately recognizable. Avoid:

- **Default fonts**: Inter, Roboto, Arial, system fonts
- **Cliched colors**: Purple gradients, blue-to-purple fades
- **Predictable layouts**: Centered hero, three-column features
- **Safe choices**: Rounded corners everywhere, subtle shadows

## Implementation Priorities

### 1. Typography

```css
/* AVOID: Generic defaults */
font-family: Inter, system-ui, sans-serif;

/* PREFER: Distinctive pairings */
--font-display: 'Clash Display', 'Space Grotesk', sans-serif;
--font-body: 'Satoshi', 'General Sans', sans-serif;

/* Specific moods */
--font-luxury: 'Cormorant Garamond', serif;
--font-brutalist: 'JetBrains Mono', monospace;
--font-playful: 'Fredoka', 'Quicksand', sans-serif;
```

**Typography scale:**

```css
:root {
  --text-hero: clamp(3rem, 10vw, 8rem);
  --text-display: clamp(2rem, 5vw, 4rem);
  --text-heading: clamp(1.5rem, 3vw, 2.5rem);
  --text-body: clamp(1rem, 1.5vw, 1.125rem);
}
```

### 2. Color & Theme

```css
:root {
  /* Dominant + sharp accent */
  --color-bg: #0a0a0a;
  --color-fg: #fafafa;
  --color-accent: #ff3366;
  --color-accent-muted: #ff336633;
}
```

Commit to: high contrast, limited palette (3-4 colors), accent colors that pop.

### 3. Motion

**Focus on high-impact moments over scattered micro-interactions:**

```css
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.reveal {
  animation: fadeInUp 0.6s ease-out forwards;
}

.reveal:nth-child(1) { animation-delay: 0.1s; }
.reveal:nth-child(2) { animation-delay: 0.2s; }
```

Focus on: page load sequences, scroll-triggered reveals, state transitions.

### 4. Spatial Composition

**Break the grid:**

- **Asymmetry**: Offset elements intentionally
- **Overlap**: Layer elements for depth
- **Diagonal flow**: Guide the eye dynamically
- **Whitespace**: Let content breathe

```css
.hero-image {
  position: relative;
  top: -5vh;      /* Overlap the header */
  right: -2rem;   /* Extend past container */
}
```

### 5. Visual Details

```css
/* Gradient overlay */
.card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.05));
  pointer-events: none;
}

/* Glow effects */
.accent-element {
  box-shadow: 0 0 20px var(--color-accent-muted), 0 0 40px var(--color-accent-muted);
}
```

## Framework Guidance

### Tailwind CSS

**Customize the theme—don't use defaults:**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: { display: ['Clash Display', 'sans-serif'] },
      colors: { brand: { DEFAULT: '#ff3366', muted: 'rgba(255, 51, 102, 0.2)' } },
    },
  },
}
```

### React/Vue

See [resources/react-vue.md](resources/react-vue.md) for:
- Framer Motion staggered animations
- Vue Transition/TransitionGroup patterns
- Component architecture with design tokens

### Rails/Hotwire

See [resources/rails-hotwire.md](resources/rails-hotwire.md) for:
- ViewComponent with sidecar styles
- Stimulus reveal/toggle controllers
- Turbo Frames & Streams with animations
- ERB layout patterns with content_for
- CSS design tokens and import order

### Implementation Constraints

See [resources/ui-implementation-guide.md](resources/ui-implementation-guide.md) for specific numeric rules:
- Typography: 4-size rule, line heights (1.5× body, 1.0-1.2× headlines)
- Color: HSB manipulation, WCAG 4.5:1 contrast, dark mode execution
- Forms: Label placement, input states, selection control usage
- Buttons: Padding ratios (2:1 horizontal:vertical), 48×48dp touch targets
- Data tables: Right-align numbers, sticky headers, condensed subtext

### Motion & Animation

See [resources/motion-patterns.md](resources/motion-patterns.md) for:
- Page load orchestration (staggered reveals, timing guidelines)
- Scroll-triggered animations (Intersection Observer patterns)
- Hover interactions (magnetic buttons, underline reveals)
- Background motion (gradient shifts, floating particles)
- Performance checklist and `prefers-reduced-motion` support

### CSS Polish & Debugging

See [resources/css-polish-tips.md](resources/css-polish-tips.md) for:
- Accessibility debugging selectors (highlight missing alt, labels)
- Scroll behavior (padding, overscroll, smooth)
- Focus & selection styling
- Performance hints (will-change, contain)
- Defensive CSS patterns

### Landing Pages

See [resources/landing-page-design.md](resources/landing-page-design.md) for:
- Section-by-section visual design (hero, proof, CTA)
- Color palettes by aesthetic (dark tech, light sophisticated)
- Typography pairings for different moods
- Single-file HTML implementation patterns
- Complements `landing-page-builder` skill (copy) with visual guidance

## Anti-Patterns

| Category | Avoid |
|----------|-------|
| Typography | Inter/Roboto as primary, single font for all |
| Color | Purple-to-blue gradients, gray-on-gray |
| Layout | Centered everything, symmetrical grids |
| Motion | Hover effects everywhere, bouncy animations |

## Validation Checklist

- [ ] Typography is distinctive (not default fonts)
- [ ] Color palette is intentional and limited
- [ ] Layout breaks from predictable patterns
- [ ] Motion serves purpose and feels polished
- [ ] Design direction is clear and consistent
- [ ] Responsive behavior maintains quality
- [ ] Accessibility not sacrificed for aesthetics

## Resources

- [Fontshare](https://www.fontshare.com/) - Free quality fonts
- [Coolors](https://coolors.co/) - Color palette generator
- [Framer Motion](https://www.framer.com/motion/) - React animation
- [ViewComponent](https://viewcomponent.org/) - Rails components

---

**Remember:** Every default is a choice. If you're using defaults, you're making generic work.
