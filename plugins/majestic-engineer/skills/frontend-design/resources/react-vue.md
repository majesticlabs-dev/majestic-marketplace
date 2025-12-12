# React & Vue Frontend Patterns

## React Components

**Design tokens as props:**

```jsx
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

## Framer Motion Animations

**Staggered list reveal:**

```jsx
import { motion } from 'framer-motion';

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

**Page transitions:**

```jsx
import { AnimatePresence, motion } from 'framer-motion';

function PageWrapper({ children }) {
  return (
    <AnimatePresence mode="wait">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        transition={{ duration: 0.3 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

## Vue Composition API

**Entrance animation:**

```vue
<script setup>
import { ref, onMounted } from 'vue';

const isVisible = ref(false);

onMounted(() => {
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
.fade-up-enter-active { transition: all 0.6s ease-out; }
.fade-up-enter-from { opacity: 0; transform: translateY(20px); }
</style>
```

## Vue TransitionGroup

**Staggered list:**

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

## Tailwind Configuration

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

**Avoid Tailwind's default color palette.** Create custom colors matching your aesthetic.
