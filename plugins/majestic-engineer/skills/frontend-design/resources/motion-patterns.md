# Motion Design Patterns

Purposeful animation that enhances UX without becoming decorative noise.

## Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Orchestration** | Stagger reveals in logical sequence |
| **Purpose** | Every animation communicates something |
| **Restraint** | High-impact moments > scattered micro-interactions |
| **Performance** | Prefer `transform` and `opacity` (GPU-accelerated) |

---

## Page Load Sequence

**Orchestrated reveal with staggered timing:**

```css
.reveal {
  opacity: 0;
  transform: translateY(20px);
  animation: fadeInUp 0.6s ease-out forwards;
}

.reveal:nth-child(1) { animation-delay: 0ms; }
.reveal:nth-child(2) { animation-delay: 100ms; }
.reveal:nth-child(3) { animation-delay: 200ms; }
.reveal:nth-child(4) { animation-delay: 300ms; }

@keyframes fadeInUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Timing guidelines:**

| Element Type | Delay | Duration |
|--------------|-------|----------|
| Hero headline | 0ms | 600ms |
| Hero subtext | 100ms | 500ms |
| Primary CTA | 200ms | 400ms |
| Trust signals | 400ms | 400ms |
| Below-fold content | On scroll | 500ms |

---

## Scroll-Triggered Reveals

**Intersection Observer pattern:**

```javascript
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target); // Fire once
      }
    });
  },
  { threshold: 0.2, rootMargin: '0px 0px -50px 0px' }
);

document.querySelectorAll('.scroll-reveal').forEach((el) => {
  observer.observe(el);
});
```

**CSS for scroll reveals:**

```css
.scroll-reveal {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}

.scroll-reveal.visible {
  opacity: 1;
  transform: translateY(0);
}

/* Stagger children within a revealed container */
.scroll-reveal.visible > * {
  animation: fadeInUp 0.5s ease-out forwards;
}

.scroll-reveal.visible > *:nth-child(1) { animation-delay: 0ms; }
.scroll-reveal.visible > *:nth-child(2) { animation-delay: 100ms; }
.scroll-reveal.visible > *:nth-child(3) { animation-delay: 200ms; }
```

---

## Hover Interactions

### Scale & Lift

```css
.card {
  transition: transform 0.3s ease-out, box-shadow 0.3s ease-out;
}

.card:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}
```

### Underline Reveal

```css
.link {
  position: relative;
}

.link::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 100%;
  height: 2px;
  background: var(--color-accent);
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 0.3s ease-out;
}

.link:hover::after {
  transform: scaleX(1);
  transform-origin: left;
}
```

### Magnetic Buttons

```javascript
document.querySelectorAll('.magnetic').forEach((btn) => {
  btn.addEventListener('mousemove', (e) => {
    const rect = btn.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;

    btn.style.transform = `translate(${x * 0.3}px, ${y * 0.3}px)`;
  });

  btn.addEventListener('mouseleave', () => {
    btn.style.transform = 'translate(0, 0)';
  });
});
```

```css
.magnetic {
  transition: transform 0.2s ease-out;
}
```

---

## Background Motion

### Subtle Gradient Shift

```css
.gradient-bg {
  background: linear-gradient(135deg, #0a0a0f, #1a1a2e);
  background-size: 200% 200%;
  animation: gradientShift 15s ease infinite;
}

@keyframes gradientShift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
```

### Floating Particles (Lightweight)

```css
.particle {
  position: absolute;
  width: 4px;
  height: 4px;
  background: var(--color-accent);
  border-radius: 50%;
  opacity: 0.3;
  animation: float 8s ease-in-out infinite;
}

.particle:nth-child(odd) { animation-delay: -4s; }

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}
```

---

## Transition Timing Reference

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Hover states | 200-300ms | ease-out |
| Page reveals | 500-700ms | ease-out |
| Modal open/close | 300-400ms | ease-out |
| Tooltips | 150ms | ease |
| Color/opacity | 200ms | ease |
| Layout shifts | 300ms | ease-in-out |

---

## Anti-Patterns

| Avoid | Why |
|-------|-----|
| Bouncy/elastic timing | Feels amateurish, distracting |
| Hover effects everywhere | Creates visual noise |
| Long durations (>1s) | Tests user patience |
| Animation on scroll position | Performance killer |
| Animating `width`/`height` | Causes layout thrashing |

---

## Performance Checklist

- [ ] Only animate `transform` and `opacity`
- [ ] Use `will-change` sparingly (not on everything)
- [ ] Prefer CSS animations over JS where possible
- [ ] Test on low-powered devices
- [ ] Respect `prefers-reduced-motion`

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
