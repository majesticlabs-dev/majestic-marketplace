---
name: react-patterns
description: Expert guidance on modern React patterns including hooks, composition, state management, and concurrent features. Use when implementing React components or refactoring existing code.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch
---

# React Patterns

## Overview

This skill provides comprehensive guidance for implementing modern React patterns using hooks, component composition, state management, and concurrent features. Apply these patterns when building React applications to ensure maintainability, performance, and adherence to React best practices.

## Core Philosophy

Prioritize:
- **Component Composition**: Build complex UIs from simple, reusable pieces
- **Separation of Concerns**: Business logic in hooks, presentation in components
- **Explicit over Implicit**: Clear data flow and state management
- **Performance**: Minimize re-renders, optimize heavy computations
- **Accessibility**: Build inclusive, keyboard-navigable interfaces

## Component Composition Patterns

### Compound Components

Create flexible component APIs using shared context:

```tsx
import { createContext, useContext, useState, FC, ReactNode } from 'react';

interface AccordionContextValue {
  activeId: string | null;
  setActiveId: (id: string | null) => void;
}

const AccordionContext = createContext<AccordionContextValue | undefined>(undefined);

interface AccordionProps {
  children: ReactNode;
  defaultActiveId?: string | null;
}

export const Accordion: FC<AccordionProps> = ({ children, defaultActiveId = null }) => {
  const [activeId, setActiveId] = useState(defaultActiveId);

  return (
    <AccordionContext.Provider value={{ activeId, setActiveId }}>
      <div className="space-y-2">{children}</div>
    </AccordionContext.Provider>
  );
};

interface AccordionItemProps {
  id: string;
  title: string;
  children: ReactNode;
}

const AccordionItem: FC<AccordionItemProps> = ({ id, title, children }) => {
  const context = useContext(AccordionContext);
  if (!context) throw new Error('AccordionItem must be used within Accordion');

  const { activeId, setActiveId } = context;
  const isActive = activeId === id;

  return (
    <div className="border rounded-lg">
      <button
        onClick={() => setActiveId(isActive ? null : id)}
        className="w-full px-4 py-3 text-left font-medium"
      >
        {title}
      </button>
      {isActive && <div className="px-4 py-3">{children}</div>}
    </div>
  );
};

Accordion.Item = AccordionItem;

// Usage:
// <Accordion>
//   <Accordion.Item id="1" title="Section 1">Content 1</Accordion.Item>
//   <Accordion.Item id="2" title="Section 2">Content 2</Accordion.Item>
// </Accordion>
```

### Render Props Pattern

Share logic between components using render props:

```tsx
interface MouseTrackerProps {
  render: (position: { x: number; y: number }) => ReactNode;
}

const MouseTracker: FC<MouseTrackerProps> = ({ render }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouseMove = (e: MouseEvent) => {
    setPosition({ x: e.clientX, y: e.clientY });
  };

  useEffect(() => {
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return <>{render(position)}</>;
};

// Usage:
// <MouseTracker render={({ x, y }) => (
//   <div>Mouse at {x}, {y}</div>
// )} />
```

### Higher-Order Components (HOC)

Wrap components to add functionality (prefer hooks for new code):

```tsx
function withAuth<P extends object>(
  Component: FC<P>
): FC<P> {
  return (props: P) => {
    const { user, loading } = useAuth();

    if (loading) return <Spinner />;
    if (!user) return <Navigate to="/login" />;

    return <Component {...props} />;
  };
}

// Usage:
// const ProtectedDashboard = withAuth(Dashboard);
```

## Custom Hooks Patterns

### Data Fetching Hook

```tsx
interface UseApiOptions<T> {
  initialData?: T;
  enabled?: boolean;
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
}

interface UseApiResult<T> {
  data: T | undefined;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

export function useApi<T>(
  url: string,
  options: UseApiOptions<T> = {}
): UseApiResult<T> {
  const [data, setData] = useState<T | undefined>(options.initialData);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const json = await response.json();
      setData(json);
      options.onSuccess?.(json);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      options.onError?.(error);
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    if (options.enabled !== false) {
      fetchData();
    }
  }, [fetchData, options.enabled]);

  return { data, loading, error, refetch: fetchData };
}
```

### Form Management Hook

```tsx
interface UseFormOptions<T> {
  initialValues: T;
  validate?: (values: T) => Partial<Record<keyof T, string>>;
  onSubmit: (values: T) => void | Promise<void>;
}

export function useForm<T extends Record<string, any>>({
  initialValues,
  validate,
  onSubmit
}: UseFormOptions<T>) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (field: keyof T) => (
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setValues(prev => ({ ...prev, [field]: e.target.value }));
    if (touched[field] && validate) {
      const validationErrors = validate({ ...values, [field]: e.target.value });
      setErrors(validationErrors);
    }
  };

  const handleBlur = (field: keyof T) => () => {
    setTouched(prev => ({ ...prev, [field]: true }));
    if (validate) {
      const validationErrors = validate(values);
      setErrors(validationErrors);
    }
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    // Mark all fields as touched
    const allTouched = Object.keys(values).reduce(
      (acc, key) => ({ ...acc, [key]: true }),
      {} as Partial<Record<keyof T, boolean>>
    );
    setTouched(allTouched);

    // Validate
    if (validate) {
      const validationErrors = validate(values);
      setErrors(validationErrors);
      if (Object.keys(validationErrors).length > 0) {
        return;
      }
    }

    // Submit
    setIsSubmitting(true);
    try {
      await onSubmit(values);
    } finally {
      setIsSubmitting(false);
    }
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
  };

  return {
    values,
    errors,
    touched,
    isSubmitting,
    handleChange,
    handleBlur,
    handleSubmit,
    reset
  };
}
```

### Debounced Value Hook

```tsx
export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}

// Usage:
// const SearchBar = () => {
//   const [query, setQuery] = useState('');
//   const debouncedQuery = useDebounce(query, 300);
//
//   useEffect(() => {
//     if (debouncedQuery) {
//       searchApi(debouncedQuery);
//     }
//   }, [debouncedQuery]);
//
//   return <input value={query} onChange={e => setQuery(e.target.value)} />;
// };
```

### Previous Value Hook

```tsx
export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// Usage:
// const Counter = () => {
//   const [count, setCount] = useState(0);
//   const prevCount = usePrevious(count);
//   return <div>Now: {count}, Before: {prevCount}</div>;
// };
```

## State Management Patterns

### Context + useReducer for Complex State

```tsx
type Action =
  | { type: 'ADD_ITEM'; payload: Item }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'CLEAR_CART' };

interface CartState {
  items: Item[];
  total: number;
}

const cartReducer = (state: CartState, action: Action): CartState => {
  switch (action.type) {
    case 'ADD_ITEM':
      return {
        items: [...state.items, action.payload],
        total: state.total + action.payload.price
      };
    case 'REMOVE_ITEM':
      const itemToRemove = state.items.find(i => i.id === action.payload);
      return {
        items: state.items.filter(i => i.id !== action.payload),
        total: state.total - (itemToRemove?.price ?? 0)
      };
    case 'CLEAR_CART':
      return { items: [], total: 0 };
    default:
      return state;
  }
};

interface CartContextValue extends CartState {
  addItem: (item: Item) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
}

const CartContext = createContext<CartContextValue | undefined>(undefined);

export const CartProvider: FC<{ children: ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(cartReducer, { items: [], total: 0 });

  const addItem = (item: Item) => dispatch({ type: 'ADD_ITEM', payload: item });
  const removeItem = (id: string) => dispatch({ type: 'REMOVE_ITEM', payload: id });
  const clearCart = () => dispatch({ type: 'CLEAR_CART' });

  return (
    <CartContext.Provider value={{ ...state, addItem, removeItem, clearCart }}>
      {children}
    </CartContext.Provider>
  );
};

export const useCart = () => {
  const context = useContext(CartContext);
  if (!context) throw new Error('useCart must be used within CartProvider');
  return context;
};
```

## Performance Optimization Patterns

### Memoization

```tsx
const ProductList: FC<{ products: Product[]; filter: string }> = ({ products, filter }) => {
  // Memoize expensive computation
  const filteredProducts = useMemo(
    () => products.filter(p => p.name.toLowerCase().includes(filter.toLowerCase())),
    [products, filter]
  );

  // Memoize callback
  const handleSelect = useCallback((id: string) => {
    console.log('Selected:', id);
  }, []);

  return (
    <div>
      {filteredProducts.map(product => (
        <ProductCard key={product.id} product={product} onSelect={handleSelect} />
      ))}
    </div>
  );
};

// Memoize component
const ProductCard = memo<{ product: Product; onSelect: (id: string) => void }>(
  ({ product, onSelect }) => {
    return (
      <div onClick={() => onSelect(product.id)}>
        {product.name} - ${product.price}
      </div>
    );
  }
);
```

### Code Splitting

```tsx
// Route-level splitting
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

const App = () => (
  <Suspense fallback={<PageLoader />}>
    <Routes>
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  </Suspense>
);

// Component-level splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'));

const Dashboard = () => (
  <div>
    <Header />
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  </div>
);
```

## Error Handling Patterns

### Error Boundaries

```tsx
class ErrorBoundary extends Component<
  { children: ReactNode; fallback?: ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Log to error reporting service
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 bg-red-50 text-red-800 rounded-md">
          <h2>Something went wrong</h2>
          <p>{this.state.error?.message}</p>
        </div>
      );
    }

    return this.props.children;
  }
}
```

## Accessibility Patterns

### Focus Management

```tsx
const Modal: FC<{ isOpen: boolean; onClose: () => void; children: ReactNode }> = ({
  isOpen,
  onClose,
  children
}) => {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousActiveElement = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      previousActiveElement.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();
    } else {
      previousActiveElement.current?.focus();
    }
  }, [isOpen]);

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') onClose();
  };

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
      onKeyDown={handleKeyDown}
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center"
    >
      <div className="bg-white p-6 rounded-lg">
        {children}
        <button onClick={onClose} aria-label="Close modal">
          ×
        </button>
      </div>
    </div>
  );
};
```

## Best Practices

1. **Extract custom hooks** when logic is reused or complex
2. **Use compound components** for flexible component APIs
3. **Memoize** expensive computations and callbacks passed to memoized children
4. **Code split** routes and heavy components
5. **Handle errors** with error boundaries at appropriate levels
6. **Manage focus** in modals and dynamic content
7. **Use semantic HTML** and ARIA labels for accessibility
8. **Test hooks** in isolation from components
9. **Keep components small** (< 200 lines)
10. **Colocate state** with its usage
