---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, or applications. Includes framework-specific guidance for Tailwind, React, Vue, and Rails/Hotwire ecosystems.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
---

# Frontend Design

## Overview

This skill provides guidance for creating distinctive, production-grade frontend interfaces that avoid generic AI aesthetics. Apply these standards when building web components, pages, or applications to ensure high design quality with intentional aesthetic direction.

## Core Philosophy

### Design Thinking First

Before writing any code, consider:

1. **Purpose**: What is this interface trying to achieve?
2. **Audience**: Who will use it and what are their expectations?
3. **Tone**: What feeling should it evoke?
4. **Constraints**: What technical or brand limitations exist?
5. **Differentiation**: What makes this distinctive?

### Pick an Extreme

Rather than defaulting to safe, generic designs, commit to a clear aesthetic direction:

- **Brutalist**: Raw, honest, utilitarian
- **Maximalist**: Bold, layered, expressive
- **Minimalist**: Restrained, precise, essential
- **Retro-futuristic**: Nostalgic tech, neon, gradients
- **Luxury**: Refined, spacious, premium
- **Playful**: Animated, colorful, delightful

Execute your chosen direction with conviction.

### Avoid "AI Slop"

Generic AI-generated aesthetics are immediately recognizable and forgettable. Avoid:

- **Default fonts**: Inter, Roboto, Arial, system fonts
- **Cliched color schemes**: Purple gradients, blue-to-purple fades
- **Predictable layouts**: Centered hero, three-column features, footer
- **Stock patterns**: Generic geometric backgrounds, bland cards
- **Safe choices**: Rounded corners everywhere, subtle shadows

## Implementation Priorities

### 1. Typography

**Choose distinctive fonts that elevate the design:**

```css
/* AVOID: Generic defaults */
font-family: Inter, system-ui, sans-serif;

/* PREFER: Distinctive pairings */
--font-display: 'Clash Display', 'Space Grotesk', 'Outfit', sans-serif;
--font-body: 'Satoshi', 'General Sans', 'Plus Jakarta Sans', sans-serif;

/* Or for specific moods */
--font-luxury: 'Cormorant Garamond', 'Playfair Display', serif;
--font-brutalist: 'JetBrains Mono', 'IBM Plex Mono', monospace;
--font-playful: 'Fredoka', 'Quicksand', 'Nunito', sans-serif;
```

**Typography scale with intention:**

```css
:root {
  /* Dramatic scale for impact */
  --text-hero: clamp(3rem, 10vw, 8rem);
  --text-display: clamp(2rem, 5vw, 4rem);
  --text-heading: clamp(1.5rem, 3vw, 2.5rem);
  --text-body: clamp(1rem, 1.5vw, 1.125rem);
  --text-small: 0.875rem;
}
```

### 2. Color & Theme

**Establish a cohesive aesthetic using CSS variables:**

```css
:root {
  /* Dominant + sharp accent approach */
  --color-bg: #0a0a0a;
  --color-fg: #fafafa;
  --color-accent: #ff3366;
  --color-accent-muted: #ff336633;

  /* Or bold complementary palette */
  --color-primary: #1a1a2e;
  --color-secondary: #16213e;
  --color-accent: #e94560;
  --color-highlight: #0f3460;
}
```

**Avoid timid palettes.** Commit to:
- High contrast for impact
- Limited palette (3-4 colors max)
- Accent colors that pop

### 3. Motion

**Prioritize high-impact moments over scattered micro-interactions:**

```css
/* Page load staggered reveal */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reveal {
  animation: fadeInUp 0.6s ease-out forwards;
}

.reveal:nth-child(1) { animation-delay: 0.1s; }
.reveal:nth-child(2) { animation-delay: 0.2s; }
.reveal:nth-child(3) { animation-delay: 0.3s; }
```

**Focus motion on:**
- Page load sequences
- Scroll-triggered reveals
- State transitions (hover, active, focus)
- Navigation changes

### 4. Spatial Composition

**Break the grid. Embrace:**

- **Asymmetry**: Offset elements intentionally
- **Overlap**: Layer elements for depth
- **Diagonal flow**: Guide the eye dynamically
- **Whitespace as design element**: Let content breathe

```css
/* Grid-breaking layout */
.hero {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.hero-content {
  padding-top: 20vh;  /* Asymmetric vertical positioning */
}

.hero-image {
  position: relative;
  top: -5vh;  /* Overlap the header */
  right: -2rem;  /* Extend past container */
}
```

### 5. Visual Details

**Add atmosphere and depth:**

```css
/* Subtle gradient overlay */
.card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.05));
  pointer-events: none;
}

/* Texture overlay */
.section {
  background-image:
    url('/noise.png'),
    linear-gradient(to bottom, var(--color-bg), var(--color-secondary));
  background-blend-mode: overlay;
}

/* Glow effects */
.accent-element {
  box-shadow:
    0 0 20px var(--color-accent-muted),
    0 0 40px var(--color-accent-muted);
}
```

## Framework-Specific Guidance

### Tailwind CSS

**Customize the theme—don't use defaults:**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        display: ['Clash Display', 'sans-serif'],
        body: ['Satoshi', 'sans-serif'],
      },
      colors: {
        brand: {
          DEFAULT: '#ff3366',
          muted: 'rgba(255, 51, 102, 0.2)',
        },
        surface: {
          DEFAULT: '#0a0a0a',
          elevated: '#1a1a1a',
        },
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.6s ease-out forwards',
        'slide-in': 'slideIn 0.4s ease-out',
      },
    },
  },
}
```

**Avoid Tailwind's default color palette.** Create a custom palette that matches your aesthetic direction.

### React

**Component architecture for design systems:**

```jsx
// Design tokens as props
function Button({ variant = 'primary', size = 'md', children }) {
  const variants = {
    primary: 'bg-brand text-white hover:bg-brand/90',
    ghost: 'bg-transparent border border-brand text-brand hover:bg-brand/10',
    brutal: 'bg-black text-white border-2 border-black hover:translate-x-1 hover:-translate-y-1 shadow-brutal',
  };

  return (
    <button className={cn(variants[variant], sizes[size])}>
      {children}
    </button>
  );
}
```

**Animation with Framer Motion:**

```jsx
import { motion, stagger, useAnimate } from 'framer-motion';

function StaggeredList({ items }) {
  return (
    <motion.ul
      initial="hidden"
      animate="visible"
      variants={{
        visible: { transition: { staggerChildren: 0.1 } }
      }}
    >
      {items.map((item) => (
        <motion.li
          key={item.id}
          variants={{
            hidden: { opacity: 0, y: 20 },
            visible: { opacity: 1, y: 0 }
          }}
        >
          {item.content}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### Vue

**Composition API for design utilities:**

```vue
<script setup>
import { ref, onMounted } from 'vue';

const isVisible = ref(false);

onMounted(() => {
  // Trigger entrance animation
  requestAnimationFrame(() => {
    isVisible.value = true;
  });
});
</script>

<template>
  <Transition name="fade-up">
    <div v-if="isVisible" class="hero">
      <slot />
    </div>
  </Transition>
</template>

<style>
.fade-up-enter-active {
  transition: all 0.6s ease-out;
}
.fade-up-enter-from {
  opacity: 0;
  transform: translateY(20px);
}
</style>
```

**TransitionGroup for lists:**

```vue
<TransitionGroup name="stagger" tag="ul">
  <li v-for="(item, index) in items" :key="item.id" :style="{ '--i': index }">
    {{ item.name }}
  </li>
</TransitionGroup>

<style>
.stagger-enter-active {
  transition: all 0.4s ease-out;
  transition-delay: calc(var(--i) * 0.1s);
}
.stagger-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
```

## Rails/Hotwire Focus

### ViewComponent

**Encapsulated UI components with sidecar styles:**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(variant: :default, elevated: false)
    @variant = variant
    @elevated = elevated
  end

  def classes
    class_names(
      "card",
      "card--#{@variant}",
      "card--elevated" => @elevated
    )
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<article class="<%= classes %>">
  <% if header? %>
    <header class="card__header">
      <%= header %>
    </header>
  <% end %>

  <div class="card__body">
    <%= content %>
  </div>
</article>
```

```css
/* app/components/card_component.css */
.card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
}

.card--elevated {
  box-shadow: var(--shadow-lg);
}

.card--brutal {
  border: 2px solid var(--color-fg);
  border-radius: 0;
  box-shadow: 4px 4px 0 var(--color-fg);
}
```

### Stimulus

**Controller patterns for interactivity:**

```javascript
// app/javascript/controllers/reveal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { delay: { type: Number, default: 100 } }

  connect() {
    this.itemTargets.forEach((item, index) => {
      item.style.animationDelay = `${index * this.delayValue}ms`
      item.classList.add("reveal")
    })
  }
}
```

```erb
<ul data-controller="reveal" data-reveal-delay-value="150">
  <% items.each do |item| %>
    <li data-reveal-target="item"><%= item.name %></li>
  <% end %>
</ul>
```

**Smooth transitions with Stimulus:**

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static classes = ["active"]

  toggle() {
    this.contentTarget.classList.toggle(this.activeClass)
  }
}
```

### Turbo

**Frames for dynamic updates without page reload:**

```erb
<%# Smooth content replacement %>
<turbo-frame id="search-results" data-turbo-action="replace">
  <%= render partial: "results", collection: @results %>
</turbo-frame>

<%# Search form targeting the frame %>
<%= form_with url: search_path, data: { turbo_frame: "search-results" } do |f| %>
  <%= f.search_field :q, data: { action: "input->search#submit" } %>
<% end %>
```

**Streams for real-time updates:**

```ruby
# Broadcasting updates with animation classes
Turbo::StreamsChannel.broadcast_prepend_to(
  "notifications",
  target: "notifications-list",
  partial: "notifications/notification",
  locals: { notification: notification, animate: true }
)
```

```erb
<%# app/views/notifications/_notification.html.erb %>
<li class="notification <%= 'notification--animate' if local_assigns[:animate] %>">
  <%= notification.message %>
</li>
```

### ERB Patterns

**Content blocks for flexible layouts:**

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head>
  <%= content_for?(:head) ? yield(:head) : "" %>
</head>
<body class="<%= content_for?(:body_class) ? yield(:body_class) : '' %>">
  <% if content_for?(:hero) %>
    <section class="hero">
      <%= yield(:hero) %>
    </section>
  <% end %>

  <main>
    <%= yield %>
  </main>
</body>
</html>
```

```erb
<%# app/views/pages/home.html.erb %>
<% content_for :body_class, "page--home" %>

<% content_for :hero do %>
  <h1 class="hero__title reveal">Welcome</h1>
  <p class="hero__subtitle reveal">Your tagline here</p>
<% end %>

<section class="features">
  <%# Main content %>
</section>
```

### Asset Pipeline

**CSS custom properties with Propshaft:**

```css
/* app/assets/stylesheets/design-tokens.css */
:root {
  /* Colors */
  --color-bg: #0a0a0a;
  --color-fg: #fafafa;
  --color-accent: #ff3366;

  /* Typography */
  --font-display: 'Clash Display', sans-serif;
  --font-body: 'Satoshi', sans-serif;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;

  /* Animation */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --duration-fast: 150ms;
  --duration-normal: 300ms;
}
```

**Import order for predictable cascading:**

```css
/* app/assets/stylesheets/application.css */
@import "design-tokens.css";
@import "reset.css";
@import "typography.css";
@import "components.css";
@import "utilities.css";
```

## Anti-Patterns to Avoid

### Typography Anti-Patterns

- Using Inter, Roboto, or Arial as primary fonts
- Single font family for everything
- Default browser font sizes
- Line heights that feel cramped

### Color Anti-Patterns

- Purple-to-blue gradients (overused in AI tools)
- Gray-on-gray low contrast
- Rainbow color schemes without cohesion
- Neon colors without purpose

### Layout Anti-Patterns

- Centered everything
- Perfectly symmetrical layouts
- Three-column feature grids
- Hero → features → testimonials → CTA pattern

### Motion Anti-Patterns

- Hover effects on every element
- Bouncy animations everywhere
- Animations that delay user interaction
- Motion that doesn't serve purpose

## Validation Checklist

Before finalizing any frontend implementation:

- [ ] Typography is distinctive (not default system fonts)
- [ ] Color palette is intentional and limited
- [ ] Layout breaks from predictable patterns
- [ ] Motion serves purpose and feels polished
- [ ] Design direction is clear and consistent
- [ ] Responsive behavior maintains design quality
- [ ] Accessibility is not sacrificed for aesthetics
- [ ] Performance is acceptable (fonts loaded efficiently)

## Resources

- [Google Fonts](https://fonts.google.com/) - Free fonts (look beyond the popular ones)
- [Fontshare](https://www.fontshare.com/) - Free quality fonts
- [Coolors](https://coolors.co/) - Color palette generator
- [Tailwind UI](https://tailwindui.com/) - Component examples (customize, don't copy)
- [Framer Motion](https://www.framer.com/motion/) - React animation library
- [ViewComponent](https://viewcomponent.org/) - Rails component framework

## Remember

**Match complexity to vision.** Maximalist designs need elaborate implementations. Minimalist designs demand precision in every detail.

**Every default is a choice.** If you're using defaults, you're making generic work. Make intentional choices.

**Context over trends.** What works for a fintech app doesn't work for a gaming community. Design for your specific context.
