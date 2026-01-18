---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, or applications. Includes framework-specific guidance for Tailwind, React, Vue, and Rails/Hotwire ecosystems.
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
---

# Frontend Design

Orchestrator for creating distinctive, production-grade interfaces.

## Skill Routing

Based on needs, invoke specialized skills:

| Need | Skill | Content |
|------|-------|---------|
| Design direction | `frontend-design-philosophy` | Aesthetic extremes, anti-patterns |
| CSS implementation | `frontend-css-patterns` | Typography, color, motion, spatial |
| React/Vue patterns | See `resources/react-vue.md` | Framer Motion, Vue Transitions |
| Rails/Hotwire | See `resources/rails-hotwire.md` | ViewComponent, Stimulus, Turbo |

## Framework Resources

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

## Implementation Resources

| Resource | Content |
|----------|---------|
| [ui-implementation-guide.md](resources/ui-implementation-guide.md) | Typography rules, color, forms, buttons, tables |
| [motion-patterns.md](resources/motion-patterns.md) | Page load, scroll triggers, hover, performance |
| [css-polish-tips.md](resources/css-polish-tips.md) | Accessibility, scroll, focus, defensive CSS |
| [landing-page-design.md](resources/landing-page-design.md) | Section design, palettes, typography pairings |

## Workflow

```
1. Clarify design direction
   - Invoke `frontend-design-philosophy` for aesthetic guidance
   - User picks: brutalist, minimalist, luxury, playful, etc.

2. Implement CSS foundation
   - Invoke `frontend-css-patterns` for typography, color, motion
   - Customize Tailwind or write CSS variables

3. Apply framework patterns
   - React/Vue: Use resources/react-vue.md
   - Rails/Hotwire: Use resources/rails-hotwire.md

4. Polish and validate
   - Use resources/css-polish-tips.md for accessibility
   - Use resources/motion-patterns.md for animation
   - Run validation checklist from philosophy skill
```

## Quick Reference

### Web Interface Standards

See [resources/web-interface-standards.md](resources/web-interface-standards.md) for:
- Keyboard operability requirements (WAI-ARIA widget patterns)
- Touch target sizing (44px mobile, 24px desktop)
- Form behavior (Enter submission, autocomplete, mobile keyboards)
- Animation accessibility (`prefers-reduced-motion`)
- Network performance budgets (POST < 500ms, virtualization thresholds)

**Validation Checklist:**
- [ ] Distinctive typography (not default fonts)
- [ ] Intentional, limited color palette
- [ ] Layout breaks predictable patterns
- [ ] Motion serves purpose
- [ ] Clear design direction
- [ ] Responsive quality maintained
- [ ] Accessibility preserved
