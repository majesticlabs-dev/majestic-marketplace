---
name: react-patterns
description: Expert guidance on modern React patterns including hooks, composition, state management, and concurrent features. Use when implementing React components or refactoring existing code.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch
---

# React Patterns

Expert guidance for implementing modern React patterns using hooks, component composition, state management, and concurrent features.

## Core Philosophy

| Priority | Description |
|----------|-------------|
| **Component Composition** | Build complex UIs from simple, reusable pieces |
| **Separation of Concerns** | Business logic in hooks, presentation in components |
| **Explicit over Implicit** | Clear data flow and state management |
| **Performance** | Minimize re-renders, optimize heavy computations |
| **Accessibility** | Build inclusive, keyboard-navigable interfaces |

## Pattern Categories

### Component Composition Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| Compound Components | Flexible component APIs with shared context | Accordion, Tabs, Menu |
| Render Props | Share logic between components | MouseTracker, Scroll position |
| Higher-Order Components | Wrap components to add functionality | withAuth, withLoading |

See [resources/examples.md](resources/examples.md) for full code examples.

### Custom Hooks Patterns

| Hook | Purpose |
|------|---------|
| `useApi` | Data fetching with loading/error states |
| `useForm` | Form state management with validation |
| `useDebounce` | Debounce rapidly changing values |
| `usePrevious` | Access previous value of state/prop |
| `useLocalStorage` | Persist state to localStorage |

See [resources/examples.md](resources/examples.md) for implementations.

### State Management Patterns

| Type | When to Use | Examples |
|------|-------------|----------|
| **useState** | Simple UI state | Toggles, form inputs, pagination |
| **useReducer** | Complex state logic | Multi-step forms, shopping cart |
| **Context** | Theme, auth, app-wide settings | User session, feature flags |
| **URL State** | Shareable/bookmarkable state | Filters, search params, tabs |
| **Server State** | API data (React Query/SWR) | User profiles, product catalogs |
| **Global Store** | Cross-feature coordination | Zustand/Redux for complex apps |

**Context + useReducer Pattern**: Best for complex state with multiple actions that need to be shared across components. See [resources/examples.md](resources/examples.md).

## Performance Optimization

### When to Use Memoization

| Tool | Use When |
|------|----------|
| `useMemo` | Expensive calculations (sorting, filtering large arrays) |
| `useCallback` | Functions passed to memoized children or used in deps |
| `memo` | Pure components that re-render often with same props |

### Code Splitting Strategy

| Level | Implementation |
|-------|---------------|
| Route-level | `lazy(() => import('./pages/Dashboard'))` |
| Component-level | Heavy components like charts, editors |
| Conditional | Features behind feature flags |

**Always wrap lazy components in `<Suspense>` with appropriate fallback.**

## Error Handling

| Strategy | Scope |
|----------|-------|
| Error Boundaries | Component tree errors (class components) |
| try/catch | Async operations, event handlers |
| React Query onError | API errors with automatic retry |

**Error Boundary Placement**: App-level for fatal errors, feature-level for graceful degradation.

## Accessibility Patterns

| Requirement | Implementation |
|-------------|---------------|
| Focus Management | Return focus to trigger on modal close |
| Keyboard Navigation | Support Tab, Enter, Escape in interactive elements |
| ARIA Labels | Icon buttons, form inputs without visible labels |
| Semantic HTML | Use `<nav>`, `<main>`, `<button>` appropriately |

See [resources/examples.md](resources/examples.md) for accessible modal implementation.

## Best Practices Checklist

1. **Extract custom hooks** when logic is reused or complex (>20 lines)
2. **Use compound components** for flexible component APIs
3. **Memoize** expensive computations and callbacks passed to memoized children
4. **Code split** routes and heavy components
5. **Handle errors** with error boundaries at appropriate levels
6. **Manage focus** in modals and dynamic content
7. **Use semantic HTML** and ARIA labels for accessibility
8. **Test hooks** in isolation from components
9. **Keep components small** (< 200 lines)
10. **Colocate state** with its usage
