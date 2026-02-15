---
name: tailwind-styling
description: Generate responsive, performant Tailwind CSS styles for React components. Use when styling components, building design systems, or implementing responsive layouts.
allowed-tools: Read Write Edit Grep Glob WebSearch
---

# Tailwind CSS for React

## Overview

This skill provides guidance for styling React components with Tailwind CSS using utility classes, responsive design, and performance best practices.

## Core Philosophy

- **Utility-first**: Compose designs from utility classes
- **Responsive by default**: Mobile-first breakpoint system
- **Component extraction**: Extract patterns into reusable components
- **Performance**: Minimize bundle size with JIT mode

## Common Component Patterns

### Button Variants

```tsx
interface ButtonProps {
  children: ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  onClick?: () => void;
}

export const Button: FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  onClick
}) => {
  const baseClasses = 'font-medium rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2';

  const variantClasses = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-blue-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500'
  };

  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  };

  return (
    <button
      onClick={onClick}
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`}
    >
      {children}
    </button>
  );
};
```

### Card Component

```tsx
export const Card: FC<{ title: string; children: ReactNode; footer?: ReactNode }> = ({
  title,
  children,
  footer
}) => {
  return (
    <div className="bg-white shadow rounded-lg overflow-hidden">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-medium text-gray-900">{title}</h3>
      </div>
      <div className="px-6 py-4">{children}</div>
      {footer && (
        <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
          {footer}
        </div>
      )}
    </div>
  );
};
```

### Form Input

```tsx
interface InputProps {
  label: string;
  error?: string;
  type?: string;
  value: string;
  onChange: (value: string) => void;
}

export const Input: FC<InputProps> = ({ label, error, type = 'text', value, onChange }) => {
  return (
    <div className="space-y-1">
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={`
          block w-full rounded-md shadow-sm sm:text-sm
          ${error
            ? 'border-red-300 text-red-900 placeholder-red-300 focus:border-red-500 focus:ring-red-500'
            : 'border-gray-300 focus:border-blue-500 focus:ring-blue-500'
          }
        `}
      />
      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
};
```

## Layout Patterns

### Container

```tsx
export const Container: FC<{ children: ReactNode }> = ({ children }) => {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      {children}
    </div>
  );
};
```

### Grid

```tsx
export const ProductGrid: FC<{ products: Product[] }> = ({ products }) => {
  return (
    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
};
```

### Flexbox Layouts

```tsx
// Sidebar layout
export const SidebarLayout: FC<{ sidebar: ReactNode; children: ReactNode }> = ({
  sidebar,
  children
}) => {
  return (
    <div className="flex flex-col md:flex-row gap-6">
      <aside className="w-full md:w-64 flex-shrink-0">
        {sidebar}
      </aside>
      <main className="flex-1">
        {children}
      </main>
    </div>
  );
};
```

## Responsive Design

### Breakpoints

- `sm:` - 640px
- `md:` - 768px
- `lg:` - 1024px
- `xl:` - 1280px
- `2xl:` - 1536px

### Mobile-First Pattern

```tsx
<div className="
  text-base           /* Mobile */
  sm:text-lg          /* Tablet */
  lg:text-xl          /* Desktop */
  xl:text-2xl         /* Large screens */
">
  Responsive text
</div>

<div className="
  grid grid-cols-1    /* Mobile: 1 column */
  sm:grid-cols-2      /* Tablet: 2 columns */
  lg:grid-cols-3      /* Desktop: 3 columns */
  gap-4
">
  {/* Grid items */}
</div>
```

### Show/Hide Based on Screen Size

```tsx
<div className="block md:hidden">Mobile only</div>
<div className="hidden md:block">Desktop only</div>
```

## Dark Mode

### Configuration

```js
// tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
  // ...
};
```

### Implementation

```tsx
export const ThemeToggle = () => {
  const [dark, setDark] = useState(false);

  useEffect(() => {
    if (dark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [dark]);

  return (
    <button onClick={() => setDark(!dark)}>
      Toggle Theme
    </button>
  );
};

// Component with dark mode
<div className="bg-white dark:bg-gray-800 text-gray-900 dark:text-white">
  Content
</div>
```

## Custom Utilities

### Extend Tailwind Config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          // ... more shades
          900: '#0c4a6e',
        }
      },
      spacing: {
        '128': '32rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        }
      }
    }
  }
};
```

## Component Library Pattern

```tsx
// components/ui/index.ts
export { Button } from './Button';
export { Card } from './Card';
export { Input } from './Input';
export { Badge } from './Badge';

// Usage
import { Button, Card } from '@/components/ui';
```

## Performance Tips

1. **Use JIT mode**: Generates only used classes
2. **Purge unused CSS**: Configure content paths correctly
3. **Extract components**: Reduce class duplication
4. **Use `@apply` sparingly**: Prefer utility classes
5. **Group utilities**: Use editor plugins for organization

## Best Practices

1. **Follow mobile-first**: Start with mobile, add larger breakpoints
2. **Use semantic class names**: For extracted components
3. **Maintain consistency**: Use design tokens from config
4. **Leverage plugins**: Forms, typography, aspect-ratio
5. **Group related utilities**: Readability > brevity
6. **Use arbitrary values sparingly**: `w-[137px]` as last resort
7. **Implement dark mode**: Plan for it from the start
8. **Test responsiveness**: Check all breakpoints
